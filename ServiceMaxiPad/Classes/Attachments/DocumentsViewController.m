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
#import "SyncManager.h"
#import "DatabaseConstant.h"
#import "DateUtil.h"
#import "StringUtil.h"
#import "AttachmentUtility.h"
#import "PushNotificationHeaders.h"
#import "AttachmentService.h"
#import "FactoryDAO.h"
#import "AttachmentErrorService.h"


@interface DocumentsViewController ()

@property(nonatomic, strong) NSMutableArray *documentsArray;
@property(nonatomic, strong) NSMutableArray *selectedDocumentsArray;
@property(nonatomic, strong) NSMutableDictionary *attachmentIdIndexDictionary;
@property(nonatomic, strong) AttachmentsDownloadManager *downloadManager;
@property(nonatomic, strong) UIAlertView *cancelDownloadAlert;
@property(nonatomic, strong) UIPopoverController *sharePopOver;
@property(nonatomic, strong) UIActivityViewController * sharingView;

-(void)showPreviewViewController:(AttachmentTXModel*)attachmentModel;
-(void)updateTags;

@end

static NSInteger const kDeleteButton = 321;
static NSString *const kDocumentsTableViewCell = @"DocumentsTableViewCell";
static NSString *const kDocumentsErrorTableViewCell = @"DocumentsErrorTableViewCell";
static NSString *const kAttachmentErrorMessage = @"message";
static NSString *const kAttachmentErrorCode = @"errorCode";



@implementation DocumentsViewController

- (CGFloat)heightOfTheView
{
    if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        return 690.0f;
    }
    else
    {
        return 900.0f;
    }
}

- (BOOL)scrollableTableView {
    return NO;
}

- (BOOL)isBorderNeeded {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateTags];
    [self.deleteButton setHidden:_isViewMode];
    self.documentsTableView.allowsMultipleSelectionDuringEditing = YES;
    self.documentsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.documentsTableView registerNib:[UINib nibWithNibName:kDocumentsTableViewCell
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kDocumentsTableViewCell];
    [self.documentsTableView registerNib:[UINib nibWithNibName:kDocumentsErrorTableViewCell
                                                        bundle:[NSBundle mainBundle]]
                  forCellReuseIdentifier:kDocumentsErrorTableViewCell];
    self.selectedDocumentsArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.attachmentIdIndexDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    _downloadManager = [AttachmentsDownloadManager sharedManager];
    _downloadManager.documentsDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPage) name:kNetworkConnectionChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPage) name:kDataSyncStatusNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPage) name:OPDocSavedNotification object:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(selectButtonStatus) userInfo:nil repeats:YES];
    
    [self registerForPopOverDismissNotification];
}

- (void)setDocumentsArray:(NSMutableArray *)documentsArray
{
    _documentsArray = documentsArray;
    _selectButton.enabled = [_documentsArray count];
}

-(void)updateTags
{
    [self.selectButton setTitle:[[TagManager sharedInstance] tagByName:kTag_Select] forState:UIControlStateNormal];
    [self.cancelButton setTitle:[[TagManager sharedInstance] tagByName:kCancelButtonTitle] forState:UIControlStateNormal];
    self.titleLabel.text = [[TagManager sharedInstance] tagByName:kTagDocuments];
}

- (void)selectButtonStatus {
    
    self.selectButton.enabled = [self.documentsArray count];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _downloadManager.documentsDelegate = self;
    [self reloadPage];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _downloadManager.documentsDelegate = nil;
}

- (void)reloadPage
{
    self.documentsArray = [AttachmentHelper getDocAttachmentsLinkedToParentId:self.parentId andOPDocsForRecordId:self.recordId];
    [self cancelAction:nil];
    [self.documentsTableView reloadData];
}

- (void)refreshPage
{
    if([[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
    {
        [self reloadPage];
    }
    else
    {
       [self.documentsTableView reloadData];
    }
    
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
    __autoreleasing AttachmentTXModel *attachmentModel = [self.documentsArray objectAtIndex:indexPath.row];
    [self.attachmentIdIndexDictionary setValue:[NSNumber numberWithInteger:indexPath.row] forKey:attachmentModel.localId];
    
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
    
    return [self.documentsArray count];
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
    if ([self.documentsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.documentsTableView setLayoutMargins:UIEdgeInsetsZero];
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }

}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AttachmentTXModel *selectedModel = [self.documentsArray objectAtIndex:indexPath.row];
    
    if (self.documentsTableView.isEditing) {
        
        if(selectedModel.isDownloaded && !selectedModel.isOutputdoc)
            return indexPath;
        else
            return nil;
        
    }
    return indexPath;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AttachmentTXModel *selectedModel = [self.documentsArray objectAtIndex:indexPath.row];
    
    if (self.documentsTableView.isEditing) {
        
        if(selectedModel.isDownloaded && !selectedModel.isOutputdoc)
            return YES;
        else
            return NO;
        
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AttachmentTXModel *selectedModel = [self.documentsArray objectAtIndex:indexPath.row];    
    
    if (!selectedModel.isDownloaded &&
        ![[SNetworkReachabilityManager sharedInstance] isNetworkReachable] &&
        ![_downloadManager.downloadingDictionary objectForKey:selectedModel.localId])
    {
        [AttachmentUtility showNewWorkErrorAlert:selectedModel];
    }
    if (self.documentsTableView.isEditing) {
        [self updateEditHeader];
        [self.selectedDocumentsArray addObject:selectedModel];
    }
    else if(selectedModel.isDownloaded) {
        [self showPreviewViewController:selectedModel];
    }
    else if([_downloadManager.downloadingDictionary objectForKey:selectedModel.localId]) {
        
        NSString *yesString = [[TagManager sharedInstance] tagByName:kTagYes];
        NSString *noString = [[TagManager sharedInstance] tagByName:kTagNo];
        
        self.cancelDownloadAlert = [[UIAlertView alloc] initWithTitle:@""
                                                          message:[NSString stringWithFormat:@"%@\n%@",kAttachmentCancelDownload,selectedModel.name]
                                                         delegate:self
                                                cancelButtonTitle:noString
                                                otherButtonTitles:yesString,nil];
        self.cancelDownloadAlert.tag = indexPath.row;
        [self.cancelDownloadAlert show];

    }
    else {
        if (![AttachmentUtility doesFileExists:[AttachmentUtility fileNameForAttachment:selectedModel]] &&
            ![_downloadManager.downloadingDictionary objectForKey:selectedModel.localId] &&
            [[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
        {
            if (!selectedModel.errorCode) {
                selectedModel.errorCode = 0;
                selectedModel.errorMessage = nil;
                [self.documentsArray replaceObjectAtIndex:indexPath.row withObject:selectedModel];
                [self.documentsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                id <AttachmentErrorDAO> attachmentErrorService = [FactoryDAO serviceByServiceType:ServiceTypeAttachmentError];
                BOOL status =[attachmentErrorService insertAttachmentErrorTableWithModel:selectedModel];
                if  (status){
                    [_downloadManager addDocumentAttachmentForDownload:selectedModel];
                    
                }
            }
            

        }
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.documentsTableView.isEditing)
    {
        [self updateEditHeader];
        AttachmentTXModel *selectedModel = [self.documentsArray objectAtIndex:indexPath.row];
        if ([self.selectedDocumentsArray containsObject:selectedModel]) {
            [self.selectedDocumentsArray removeObject:selectedModel];
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
    
    self.editProcessHeaderLabel.text = [NSString stringWithFormat:@"0 %@",[[TagManager sharedInstance] tagByName:kTag_ItemSelected]];
    [self.selectedDocumentsArray removeAllObjects];
    [self.documentsTableView setEditing:NO animated:YES];
    [self.documentsTableView reloadData];
    self.editProcessHeaderView.hidden = YES;
    self.viewProcessHeaderView.hidden = NO;
    
}

- (IBAction)deleteAction:(UIButton *)sender {
    
    if (self.deleteButton.isSelected) {
        
        NSString *delete = [[TagManager sharedInstance] tagByName:kTagDeleteButtonTitle];
        NSString *cancel = [[TagManager sharedInstance] tagByName:kCancelButtonTitle];

        [[AlertMessageHandler sharedInstance] showCustomMessage:[NSString stringWithFormat:[[TagManager sharedInstance] tagByName: kTag_TheSelectedAttachementWillBeRemoved], self.parentObjectName] withDelegate:self tag:kDeleteButton title:@"" cancelButtonTitle:cancel andOtherButtonTitles:[NSArray arrayWithObject:delete]];
    }
}

- (void)didDeleteAttachment:(AttachmentTXModel*)attachment {
    
    if (![StringUtil isStringEmpty:attachment.idOfAttachment])
    {
        self.sfmPage.isAttachmentEdited = YES;
    }
    
    if ([self.documentsArray containsObject:attachment]) {
        [self.documentsArray removeObject:attachment];
    }
    
}

- (void)updateEditHeader
{
    NSArray *selectedRows = [self.documentsTableView indexPathsForSelectedRows];
    BOOL noItemsAreSelected = selectedRows.count == 0;
    [self.shareButton setSelected:!noItemsAreSelected];
    [self.deleteButton setSelected:!noItemsAreSelected];
    NSString *title = [NSString stringWithFormat:@"%lu %@", (unsigned long)selectedRows.count,[[TagManager sharedInstance] tagByName:kTag_ItemSelected]];
    self.editProcessHeaderLabel.text = title;
    

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
            NSInteger row = [[self.attachmentIdIndexDictionary valueForKey:attachmentId] integerValue];
            NSIndexPath *indexPathToRefresh = [NSIndexPath indexPathForRow:row inSection:0];
            DocumentsTableViewCell *docCell = (DocumentsTableViewCell*)[self.documentsTableView cellForRowAtIndexPath:indexPathToRefresh];
            [docCell configureDocuments:[self.documentsArray objectAtIndex:row]];
        }
    }
}

- (void)documentDownloadRequestFinished:(NSDictionary *)downloadInfoDict {
    
    NSString *attachmentId = [downloadInfoDict valueForKey:kDocumentsDownloadKeyFileId];
    NSInteger row = [[self.attachmentIdIndexDictionary valueForKey:attachmentId] integerValue];
    AttachmentTXModel *attachmentModel = [self.documentsArray objectAtIndex:row];
    NSIndexPath *indexPathToRefresh = [NSIndexPath indexPathForRow:row inSection:0];
    id <AttachmentErrorDAO> attachmentErrorService = [FactoryDAO serviceByServiceType:ServiceTypeAttachmentError];
    if ([AttachmentUtility doesFileExists:[AttachmentUtility fileNameForAttachment:attachmentModel]])
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString * fileContent=[[NSString alloc]initWithContentsOfFile:[[AttachmentUtility getFullPath:attachmentId] stringByAppendingString:attachmentModel.extensionName] encoding:NSUTF8StringEncoding error:nil];
        SXLogInfo(@"%@",fileContent);
        NSData *fileData = [fileContent dataUsingEncoding:NSUTF8StringEncoding];
        if (fileData){
            id fileArray=[NSJSONSerialization JSONObjectWithData:fileData options:0 error:nil];
            if ([fileArray isKindOfClass:[NSArray class]]) {
                for (NSDictionary *fileJson in fileArray) {
                    
                    if([fileJson objectForKey:kAttachmentErrorCode]){
                        attachmentModel.errorCode=NSURLErrorFileDoesNotExist;
                        attachmentModel.errorMessage =[fileJson objectForKey:kAttachmentErrorMessage];
                        BOOL statusError=[attachmentErrorService updateAttachmentErrorTableWithModel:attachmentModel];
                        if(statusError){
                            NSError *fileManagerError;
                            [fileManager removeItemAtPath:[[AttachmentUtility getFullPath:attachmentId] stringByAppendingString:attachmentModel.extensionName] error:&fileManagerError];
                            if(fileManagerError){
                                SXLogInfo(@"Error Deleting : %@",fileManagerError.description);
                            }
                        }
                    }
                }

            }
            
        }
        else{
            attachmentModel.isDownloaded = YES;
            [attachmentErrorService deleteAttachmentsFromDBDirectoryForParentId:attachmentModel.parentId];
        }

        
        [self.documentsArray replaceObjectAtIndex:row withObject:attachmentModel];
        //TODO: Remove from attachment error table
    }
    [self.documentsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToRefresh] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)documentDownloadRequestCanceled:(NSDictionary *)downloadInfoDict {
    
    NSString *attachmentId = [downloadInfoDict valueForKey:kDocumentsDownloadKeyFileId];
    NSInteger row = [[self.attachmentIdIndexDictionary valueForKey:attachmentId] integerValue];
    AttachmentTXModel *attachmentModel = [self.documentsArray objectAtIndex:row];
    id <AttachmentErrorDAO> attachmentErrorService = [FactoryDAO serviceByServiceType:ServiceTypeAttachmentError];
    [attachmentErrorService deleteAttachmentsFromDBDirectoryForParentId:attachmentModel.parentId];

    NSIndexPath *indexPathToRefresh = [NSIndexPath indexPathForRow:row inSection:0];
    NSInteger errorCode = [[downloadInfoDict valueForKey:kDocumentsDownloadKeyErrorCode] integerValue];
    if (errorCode != AttachmentDownloadErrorUserForceQuit &&
        errorCode != AttachmentDownloadErrorUserCancelled) {
        attachmentModel.errorCode = errorCode;
        attachmentModel.errorMessage = [AttachmentUtility getAttachmentAPIErrorMessage:(int)errorCode];
        [self.documentsArray replaceObjectAtIndex:row withObject:attachmentModel];
        //TODO : Update database attachment error table
    }
    [attachmentErrorService deleteAttachmentsFromDBDirectoryForParentId:attachmentModel.parentId];

    [self.documentsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToRefresh] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark-
#pragma AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView == self.cancelDownloadAlert) {
        
        if (buttonIndex != [alertView cancelButtonIndex])
        {
          AttachmentTXModel *cancelModel = [self.documentsArray objectAtIndex:self.cancelDownloadAlert.tag];
          [_downloadManager cancelDownloadWithId:cancelModel.localId];
        }
        self.cancelDownloadAlert = nil;

    }
    
    if (alertView.tag == kDeleteButton) {
        
        if (buttonIndex != [alertView cancelButtonIndex])
        {
            NSMutableArray *localIdsToDelete = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray *modifiedArray = [[NSMutableArray alloc] initWithCapacity:0];
            
            for (AttachmentTXModel *deleteModel in self.selectedDocumentsArray)
            {
                
             BOOL isSuccess = [AttachmentUtility deleteAttachment:deleteModel];
                
                if (isSuccess) {
                    
                    if (![StringUtil isStringEmpty:deleteModel.idOfAttachment]) {
                        self.sfmPage.isAttachmentEdited = YES;
                        ModifiedRecordModel *modifiedModel = [[ModifiedRecordModel alloc] init];
                        modifiedModel.syncFlag = YES;
                        modifiedModel.sfId = deleteModel.idOfAttachment;
                        modifiedModel.recordType = kRecordTypeDetail;
                        modifiedModel.operation = kModificationTypeDelete;
                        modifiedModel.objectName = kAttachmentTableName;
                        modifiedModel.parentObjectName = self.parentSFObjectName;
                        modifiedModel.recordLocalId = deleteModel.localId;
                        modifiedModel.parentLocalId = _parentId;
                        modifiedModel.timeStamp = [DateUtil getDatabaseStringForDate:[NSDate date]];
                        [modifiedArray addObject:modifiedModel];
                        [AttachmentHelper addModifiedRecordLocalId:deleteModel.localId];
                    }
                    
                    if ([self.documentsArray containsObject:deleteModel]) {
                        [self.documentsArray removeObject:deleteModel];
                        [localIdsToDelete addObject:deleteModel.localId];
                    }
                    
                }
                else {
                    //TODO: handle error
                }
            }
            [AttachmentHelper saveDeleteAttachmentsToModifiedRecords:modifiedArray];
            [self.selectedDocumentsArray removeAllObjects];
            [self.documentsTableView reloadData];
            [self updateEditHeader];
        }
    }
}

- (void)showPreviewViewController:(AttachmentTXModel *)attachmentModel {
    
    if (![self.navigationController.topViewController isKindOfClass:[AttachmentWebView class]])
    {
        AttachmentWebView *attachmentWebview = [[AttachmentWebView alloc] initWithNibName:@"AttachmentWebView" bundle:[NSBundle mainBundle]];
        attachmentWebview.isInViewMode = self.isViewMode;
        attachmentWebview.attachmentTXModel = attachmentModel;
        attachmentWebview.parentObjectName = self.parentObjectName;
        attachmentWebview.parentSFObjectName = self.parentSFObjectName;
        attachmentWebview.parentId = self.parentId;
        attachmentWebview.webviewdelgate = self;
        [self.navigationController pushViewController:attachmentWebview animated:YES];
    }
    
}

#pragma AttachmentSharing options

//D-00003728
- (IBAction)shareAction:(UIButton *)sender {
    
    if (self.shareButton.isSelected) {
        
        NSMutableArray *urlItemsArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (AttachmentTXModel *shareModel in self.selectedDocumentsArray)
        {
            NSData * data =  [AttachmentUtility getEncodedDataForExistingAttachment:shareModel];
            
            if (data != nil && ![data isKindOfClass:[NSNull class]])
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
                                                                      UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact,
                                                                      UIActivityTypePostToWeibo, UIActivityTypePostToFlickr,
                                                                      UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo,UIActivityTypeSaveToCameraRoll]];
    excludedActivities = sharingOptions;
    sharingView.excludedActivityTypes = excludedActivities;
    
    if (!self.sharePopOver )
    {
        self.sharePopOver = [[UIPopoverController alloc] initWithContentViewController:sharingView];
        self.sharePopOver .delegate = self;
    }
    [self.sharePopOver  presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
/* TODO : Enable this code after migrating to minversion iOS8 - Anoop
#ifdef isIOS8ANDABOVE
     [sharingView setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
     SXLogDebug (@"Activity Type = %@ Completed = %d returned items %@ error %@", activityType, completed, returnedItems, activityError);
#else
     [sharingView setCompletionHandler:^(NSString *activityType, BOOL completed) {
     SXLogDebug (@"Activity Type = %@ Completed = %d", activityType, completed);
#endif
*/
     [sharingView setCompletionHandler:^(NSString *activityType, BOOL completed) {
     SXLogDebug (@"Activity Type = %@ Completed = %d", activityType, completed);
        if (activityType == UIActivityTypeMail)
        {
            if (![MFMailComposeViewController canSendMail])
            {
                NSString *cancel = [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
                NSString *message = [[TagManager sharedInstance] tagByName:kTagAlertConfigureMail];
                [[AlertMessageHandler sharedInstance] showCustomMessage:message withDelegate:nil tag:0 title:[[TagManager sharedInstance] tagByName:kTagAlertApplicationError] cancelButtonTitle:cancel andOtherButtonTitles:nil];
                // device is not configured to send mail
            }
        }
        [self.sharePopOver dismissPopoverAnimated:YES];
        
        if (self.sharePopOver != nil)
            self.sharePopOver = nil;
    }];
    sharingView = nil;
    
}

- (void) dealloc {
    
    _recordId = nil;
    _parentId = nil;
    _parentObjectName = nil;
    _parentSFObjectName = nil;
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
    [_selectedDocumentsArray removeAllObjects];
    _selectedDocumentsArray = nil;
    [_attachmentIdIndexDictionary removeAllObjects];
    _attachmentIdIndexDictionary = nil;
    _cancelDownloadAlert = nil;
    [_sharePopOver dismissPopoverAnimated:NO];
    _sharePopOver = nil;
    _sharingView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNetworkConnectionChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDataSyncStatusNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPDocSavedNotification object:nil];
    
    [self deregisterForPopOverDismissNotification];
}

-(void)registerForPopOverDismissNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissPopover)
                                                 name:POP_OVER_DISMISS
                                               object:nil];
}

-(void)deregisterForPopOverDismissNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:POP_OVER_DISMISS object:nil];
}

- (void)dismissPopover
{
    [self performSelectorOnMainThread:@selector(dismissPopoverIfNeeded) withObject:self waitUntilDone:YES];
}

- (void)dismissPopoverIfNeeded
{
    if ([self.sharePopOver isPopoverVisible] &&
        self.sharePopOver) {
        
        [self.sharePopOver dismissPopoverAnimated:YES];
        self.sharePopOver = nil;
    }
}

@end
