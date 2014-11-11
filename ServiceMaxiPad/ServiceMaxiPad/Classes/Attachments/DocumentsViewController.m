//
//  DocumentsViewController.m
//  ServiceMaxiPad
//
//  Created by Anoop on 10/27/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "DocumentsViewController.h"
#import "DocumentsTableViewCell.h"
#import "DocumentsErrorTableViewCell.h"
#import "AttachmentHelper.h"
#import "SNetworkReachabilityManager.h"
#import "AttachmentUtility.h"
#import "AlertMessageHandler.h"
#import "TagConstant.h"
#import "TagManager.h"
#import "NonTagConstant.h"
#import "Utility.h"
#import <MessageUI/MessageUI.h>
#import "ModifiedRecordModel.h"

@interface DocumentsViewController ()

@property(nonatomic, strong) NSMutableArray *documentsArray;
@property(nonatomic, strong) NSMutableArray *selectedDocumentsArray;
@property(nonatomic, strong) NSMutableDictionary *attachmentIdIndexDictionary;
@property(nonatomic, strong) AttachmentsDownloadManager *downloadManager;
@property(nonatomic, strong) UIAlertView *cancelDownloadAlert;

-(void)showPreviewViewController:(AttachmentTXModel*)attachmentModel;

@end

static NSInteger const kDeleteButton = 321;
static NSString *const kDocumentsTableViewCell = @"DocumentsTableViewCell";
static NSString *const kDocumentsErrorTableViewCell = @"DocumentsErrorTableViewCell";

@implementation DocumentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.deleteButton setHidden:_isViewMode];
    self.documentsTableView.allowsMultipleSelectionDuringEditing = YES;
    self.documentsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.documentsTableView registerNib:[UINib nibWithNibName:kDocumentsTableViewCell
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kDocumentsTableViewCell];
    [self.documentsTableView registerNib:[UINib nibWithNibName:kDocumentsErrorTableViewCell
                                                        bundle:[NSBundle mainBundle]]
                  forCellReuseIdentifier:kDocumentsErrorTableViewCell];
    _documentsArray = [AttachmentHelper getDocAttachmentsLinkedToParentId:self.parentId];
    _selectedDocumentsArray = [[NSMutableArray alloc] initWithCapacity:0];
    _attachmentIdIndexDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    _downloadManager = [AttachmentsDownloadManager sharedManager];
    _downloadManager.documentsDelegate = self;
    [self cancelAction:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInternetConnectionChange) name:kNetworkConnectionChanged object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.documentsTableView reloadData];
}

- (void)didInternetConnectionChange {
    [_documentsTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark === UITableViewDataSource ===
#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   __autoreleasing AttachmentTXModel *attachmentModel = [_documentsArray objectAtIndex:indexPath.row];
    [_attachmentIdIndexDictionary setValue:[NSNumber numberWithInteger:indexPath.row] forKey:attachmentModel.localId];
    
    if (!attachmentModel.errorCode) {
        DocumentsTableViewCell *cellDetail = [tableView dequeueReusableCellWithIdentifier:kDocumentsTableViewCell];
        [cellDetail configureDocuments:attachmentModel];
        attachmentModel = nil;
        return cellDetail;
    }
    else {
        DocumentsErrorTableViewCell *cellError = [tableView dequeueReusableCellWithIdentifier:kDocumentsErrorTableViewCell];
        [cellError configureErrorDocuments:attachmentModel];
        attachmentModel = nil;
        return cellError;
    }
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Unknown"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_documentsArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleNone;
}


#pragma mark -
#pragma mark === UITableViewDelegate ===
#pragma mark -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.documentsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.documentsTableView setSeparatorInset:UIEdgeInsetsZero];
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
#ifdef __IPHONE_8_0
    if ([self.documentsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.documentsTableView setLayoutMargins:UIEdgeInsetsZero];
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
#endif

}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AttachmentTXModel *selectedModel = [_documentsArray objectAtIndex:indexPath.row];
    
    if (_documentsTableView.isEditing) {
        
        if(selectedModel.isDownloaded)
            return indexPath;
        else
            return nil;
        
    }
    return indexPath;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AttachmentTXModel *selectedModel = [_documentsArray objectAtIndex:indexPath.row];
    
    if (_documentsTableView.isEditing) {
        
        if(selectedModel.isDownloaded)
            return YES;
        else
            return NO;
        
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AttachmentTXModel *selectedModel = [_documentsArray objectAtIndex:indexPath.row];
    
    if (_documentsTableView.isEditing) {
        [self updateEditHeader];
        [_selectedDocumentsArray addObject:selectedModel];
    }
    else if(selectedModel.isDownloaded) {
        [self showPreviewViewController:selectedModel];
    }
    else if([_downloadManager.downloadingDictionary objectForKey:selectedModel.localId]) {
        
        NSString *yesString = [[TagManager sharedInstance] tagByName:kTagYes];
        if(![yesString length])
            yesString = @"Yes";
        
        NSString *noString = [[TagManager sharedInstance] tagByName:kTagNo];
        if(![noString length])
            noString = @"No";
        
        _cancelDownloadAlert = [[UIAlertView alloc] initWithTitle:@""
                                                          message:[NSString stringWithFormat:@"%@\n%@",kAttachmentCancelDownload,selectedModel.name]
                                                         delegate:self
                                                cancelButtonTitle:noString
                                                otherButtonTitles:yesString,nil];
        _cancelDownloadAlert.tag = indexPath.row;
        [_cancelDownloadAlert show];

    }
    else {
        if (![AttachmentUtility doesFileExists:[AttachmentUtility fileNameForAttachment:selectedModel]] &&
            ![_downloadManager.downloadingDictionary objectForKey:selectedModel.localId] &&
            [[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
        {
            if (selectedModel.errorCode) {
                selectedModel.errorCode = 0;
                selectedModel.errorMessage = nil;
                [_documentsArray replaceObjectAtIndex:indexPath.row withObject:selectedModel];
                [_documentsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            [_downloadManager addDocumentAttachmentForDownload:selectedModel];
        }
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_documentsTableView.isEditing)
    {
        [self updateEditHeader];
        AttachmentTXModel *selectedModel = [_documentsArray objectAtIndex:indexPath.row];
        if ([_selectedDocumentsArray containsObject:selectedModel]) {
            [_selectedDocumentsArray removeObject:selectedModel];
        }
    }

}


#pragma mark -
#pragma mark === Button Action methods ===
#pragma mark -


- (IBAction)selectAction:(UIButton *)sender {
    
    [self.documentsTableView setEditing:YES animated:YES];
    self.editProcessHeaderView.hidden = NO;
    self.viewProcessHeaderView.hidden = YES;

}

- (IBAction)cancelAction:(UIButton *)sender {
    
    self.editProcessHeaderLabel.text = [NSString stringWithFormat:@"0 Items Selected"];
    [_selectedDocumentsArray removeAllObjects];
    [self.documentsTableView setEditing:NO animated:YES];
    [self.documentsTableView reloadData];
    self.editProcessHeaderView.hidden = YES;
    self.viewProcessHeaderView.hidden = NO;
    
}

- (IBAction)deleteAction:(UIButton *)sender {
    
    if (self.deleteButton.isSelected) {
        
        NSString *delete = [[TagManager sharedInstance] tagByName:kTagDeleteButtonTitle];
        if (![delete length]) {
            delete = @"Delete";
        }
        NSString *cancel = [[TagManager sharedInstance] tagByName:kCancelButtonTitle];
        if (![cancel length]) {
            cancel = @"Cancel";
        }
        [[AlertMessageHandler sharedInstance] showCustomMessage:[NSString stringWithFormat:@"The selected attachments will be removed from the %@ and will be deleted from the server at the next sync. This action cannot be undone.", _parentObjectName] withDelegate:self tag:kDeleteButton title:@"" cancelButtonTitle:cancel andOtherButtonTitles:[NSArray arrayWithObject:delete]];
    }
}

- (void)didDeleteAttachment:(AttachmentTXModel*)attachment {
    
    if ([_documentsArray containsObject:attachment]) {
        [_documentsArray removeObject:attachment];
    }
    
}

- (void)updateEditHeader
{
    NSArray *selectedRows = [self.documentsTableView indexPathsForSelectedRows];
    BOOL noItemsAreSelected = selectedRows.count == 0;
    [self.shareButton setSelected:!noItemsAreSelected];
    [self.deleteButton setSelected:!noItemsAreSelected];
    self.editProcessHeaderLabel.text = [NSString stringWithFormat:@"%lu Items Selected", (unsigned long)selectedRows.count];
}

#pragma Mark-
#pragma DocumentsDownloadDelegateMethods

- (void)documentDownloadRequestStarted:(NSDictionary *)downloadInfoDict {
    
    [self showProgressOfDownLoad:downloadInfoDict];
}

- (void)documentDownloadRequestProgress:(NSDictionary *)downloadInfoDict {
    
    [self showProgressOfDownLoad:downloadInfoDict];
}

- (void)showProgressOfDownLoad:(NSDictionary*)downloadInfoDict {
    
    @autoreleasepool {
        
        if (!self.documentsTableView.isEditing) {
            
            NSString *attachmentId = [downloadInfoDict valueForKey:kDocumentsDownloadKeyFileId];
            NSInteger row = [[_attachmentIdIndexDictionary valueForKey:attachmentId] integerValue];
            NSIndexPath *indexPathToRefresh = [NSIndexPath indexPathForRow:row inSection:0];
            DocumentsTableViewCell *docCell = (DocumentsTableViewCell*)[_documentsTableView cellForRowAtIndexPath:indexPathToRefresh];
            [docCell configureDocuments:[_documentsArray objectAtIndex:row]];
        }
    }
}

- (void)documentDownloadRequestFinished:(NSDictionary *)downloadInfoDict {
    
    NSString *attachmentId = [downloadInfoDict valueForKey:kDocumentsDownloadKeyFileId];
    NSInteger row = [[_attachmentIdIndexDictionary valueForKey:attachmentId] integerValue];
    AttachmentTXModel *attachmentModel = [_documentsArray objectAtIndex:row];
    NSIndexPath *indexPathToRefresh = [NSIndexPath indexPathForRow:row inSection:0];
    
    if ([AttachmentUtility doesFileExists:[AttachmentUtility fileNameForAttachment:attachmentModel]])
    {
        attachmentModel.isDownloaded = YES;
        [_documentsArray replaceObjectAtIndex:row withObject:attachmentModel];
        //TODO: Remove from attachment error table
    }
    [_documentsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToRefresh] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)documentDownloadRequestCanceled:(NSDictionary *)downloadInfoDict {
    
    NSString *attachmentId = [downloadInfoDict valueForKey:kDocumentsDownloadKeyFileId];
    NSInteger row = [[_attachmentIdIndexDictionary valueForKey:attachmentId] integerValue];
    AttachmentTXModel *attachmentModel = [_documentsArray objectAtIndex:row];
    NSIndexPath *indexPathToRefresh = [NSIndexPath indexPathForRow:row inSection:0];
    NSInteger errorCode = [[downloadInfoDict valueForKey:kDocumentsDownloadKeyErrorCode] integerValue];
    if (errorCode != AttachmentDownloadErrorUserForceQuit &&
        errorCode != AttachmentDownloadErrorUserCancelled) {
        attachmentModel.errorCode = errorCode;
        attachmentModel.errorMessage = [AttachmentUtility getAttachmentAPIErrorMessage:(int)errorCode];
        [_documentsArray replaceObjectAtIndex:row withObject:attachmentModel];
        //TODO : Update database attachment error table
    }
    [_documentsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToRefresh] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark-
#pragma AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView == _cancelDownloadAlert) {
        
        if (buttonIndex != [alertView cancelButtonIndex])
        {
          AttachmentTXModel *cancelModel = [_documentsArray objectAtIndex:_cancelDownloadAlert.tag];
          [_downloadManager cancelDownloadWithId:cancelModel.localId];
        }

    }
    
    if (alertView.tag == kDeleteButton) {
        
        if (buttonIndex != [alertView cancelButtonIndex])
        {
            NSMutableArray *localIdsToDelete = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray *modifiedArray = [[NSMutableArray alloc] initWithCapacity:0];
            
            for (AttachmentTXModel *deleteModel in _selectedDocumentsArray)
            {
                
             BOOL isSuccess = [AttachmentUtility deleteAttachment:deleteModel];
                
                if (isSuccess) {
                    
                    if ([deleteModel.idOfAttachment length]) {
                        
                        ModifiedRecordModel *modifiedModel = [[ModifiedRecordModel alloc] init];
                        modifiedModel.syncFlag = YES;
                        modifiedModel.sfId = deleteModel.idOfAttachment;
                        modifiedModel.recordType = kRecordTypeDetail;
                        modifiedModel.operation = kModificationTypeDelete;
                        modifiedModel.objectName = kAttachmentTableName;
                        modifiedModel.parentObjectName = _parentSFObjectName;
                        modifiedModel.recordLocalId = deleteModel.localId;
                        [modifiedArray addObject:modifiedModel];
                    }
                    
                    if ([_documentsArray containsObject:deleteModel]) {
                        [_documentsArray removeObject:deleteModel];
                        [localIdsToDelete addObject:deleteModel.localId];
                    }
                    
                }
                else {
                    //TODO: handle error
                }
            }
            [AttachmentHelper deleteAttachmentsWithLocalIds:localIdsToDelete];
            [AttachmentHelper saveDeleteAttachmentsToModifiedRecords:modifiedArray];
            [_documentsTableView reloadData];
            [self updateEditHeader];
        }
    }
}

- (void)showPreviewViewController:(AttachmentTXModel *)attachmentModel {
    
    AttachmentWebView *attachmentWebview = [[AttachmentWebView alloc] initWithNibName:@"AttachmentWebView" bundle:[NSBundle mainBundle]];
    attachmentWebview.isInViewMode = _isViewMode;
    attachmentWebview.attachmentTXModel = attachmentModel;
    attachmentWebview.parentObjectName = _parentObjectName;
    attachmentWebview.parentSFObjectName = _parentSFObjectName;
    attachmentWebview.webviewdelgate = self;
    [self.navigationController pushViewController:attachmentWebview animated:YES];
    
}

#pragma AttachmentSharing options

//D-00003728
- (IBAction)shareAction:(UIButton *)sender {
    
    if (self.shareButton.isSelected) {
        
        NSMutableArray *urlItemsArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (AttachmentTXModel *shareModel in _selectedDocumentsArray)
        {
            NSData * data =  [AttachmentUtility getEncodedDataForExistingAttachment:shareModel];
            
            if ([data length])
            {
                [AttachmentUtility saveDuplicateAttachmentData:data forAttachment:shareModel];
                
                NSURL * fileUrl = [AttachmentUtility getDuplicateAttachmentURL:shareModel];
                
                if (fileUrl != nil)
                {
                    [urlItemsArray addObject:fileUrl];
                }
            }
        }
        [self displaySharingView:urlItemsArray sender:sender];
    }
}


//D-00003728
- (void)displaySharingView:(NSArray*)urlItems sender:(UIButton *)button
{
    //11450
    UIActivityViewController * sharingView = [[UIActivityViewController alloc] initWithActivityItems:urlItems applicationActivities:nil];
    
    NSArray * excludedActivities = nil;
    NSMutableArray *sharingOptions = [NSMutableArray arrayWithArray:@[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                                                      UIActivityTypePostToWeibo, UIActivityTypePostToFlickr,
                                                                      UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo,UIActivityTypeAssignToContact]];
    
    if ([Utility isDeviceIOS8]) {
        [sharingOptions addObject:UIActivityTypePrint];
    }
    excludedActivities = sharingOptions;
    
    //12123
    __block UIPopoverController * popover = nil;
    popover = [[UIPopoverController alloc] initWithContentViewController:sharingView];
    popover.delegate = self;
    [popover presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    [sharingView setCompletionHandler:^(NSString *activityType, BOOL completed) {
        NSLog (@"Activity Type = %@ Completed = %d", activityType, completed);
        
        if (activityType == UIActivityTypeMail)
        {
            if (![MFMailComposeViewController canSendMail])
            {
                NSString *cancel = [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
                if (![cancel length]) {
                    cancel = [[TagManager sharedInstance]tagByName:kTagAlertErrorOk];
                }
                
                NSString *message = [[TagManager sharedInstance] tagByName:kTagAlertConfigureMail];
                if (![message length]) {
                    message = @"Configure email in your device";
                }
                
                [[AlertMessageHandler sharedInstance] showCustomMessage:message withDelegate:nil tag:0 title:[[TagManager sharedInstance] tagByName:kTagAlertApplicationError] cancelButtonTitle:cancel andOtherButtonTitles:nil];
                // device is not configured to send mail
            }
        }
        if (popover != nil)
            popover = nil;
    }];
    
}

- (void) dealloc {
    
    _documentsTableView = nil;
    _viewProcessHeaderView = nil;
    _selectButton = nil;
    _editProcessHeaderView = nil;
    _editProcessHeaderLabel = nil;
    _cancelButton = nil;
    _shareButton = nil;
    _deleteButton = nil;
    [_documentsArray removeAllObjects];
    _documentsArray = nil;
    
}
@end