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

@interface DocumentsViewController ()

@property(nonatomic, strong) NSMutableArray *documentsArray;
@property(nonatomic, strong) NSMutableArray *selectedDocumentsArray;
@property(nonatomic, strong) NSMutableDictionary *attachmentIdIndexDictionary;
@property(nonatomic, strong) AttachmentsDownloadManager *downloadManager;
@property(nonatomic, strong) UIAlertView *cancelDownloadAlert;

@end

static NSInteger const kDeleteButton = 321;
static NSString *const kDocumentsTableViewCell = @"DocumentsTableViewCell";
static NSString *const kDocumentsErrorTableViewCell = @"DocumentsErrorTableViewCell";

@implementation DocumentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

#pragma mark -
#pragma mark === UITableViewDelegate ===
#pragma mark -

-(UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

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
    else if([_downloadManager.downloadingDictionary objectForKey:selectedModel.localId]) {
        
        NSString *yesString = [[TagManager sharedInstance] tagByName:kTagRescheduleYes];
        if(![yesString length])
            yesString = @"Yes";
        
        NSString *noString = [[TagManager sharedInstance] tagByName:kTagRescheduleNo];
        if(![noString length])
            noString = @"No";
        
        _cancelDownloadAlert = [[UIAlertView alloc] initWithTitle:@""
                                                          message:kAttachmentCancelDownload
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
    if (_documentsTableView.isEditing) {
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
    self.editProcessHeaderView.hidden = YES;
    self.viewProcessHeaderView.hidden = NO;
    
}

- (IBAction)shareAction:(UIButton *)sender {
    
    if (self.shareButton.isSelected) {
        
    }
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
        NSString *attachmentId = [downloadInfoDict valueForKey:kDocumentsDownloadKeyFileId];
        NSInteger row = [[_attachmentIdIndexDictionary valueForKey:attachmentId] integerValue];
        NSIndexPath *indexPathToRefresh = [NSIndexPath indexPathForRow:row inSection:0];
        DocumentsTableViewCell *docCell = (DocumentsTableViewCell*)[_documentsTableView cellForRowAtIndexPath:indexPathToRefresh];
        [docCell configureDocuments:[_documentsArray objectAtIndex:row]];
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
            for (AttachmentTXModel *deleteModel in _selectedDocumentsArray)
            {
                
             BOOL isSuccess = [AttachmentUtility deleteAttachment:deleteModel];
                
                if (isSuccess) {
                    
                    if ([_documentsArray containsObject:deleteModel]) {
                        [_documentsArray removeObject:deleteModel];
                    }
                    //TODO : DAtatrailer table remove record
                }
                else {
                    //TODO: handle error
                }
            }
            [_documentsTableView reloadData];
            [self updateEditHeader];
        }
    }
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
