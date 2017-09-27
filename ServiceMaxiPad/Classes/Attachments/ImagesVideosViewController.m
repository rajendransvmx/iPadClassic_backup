//
//  ImagesVideosViewController.m
//  ServiceMaxiPad
//
//  Created by Anoop on 10/27/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ImagesVideosViewController.h"
#import "DownloadedCollectionViewCell.h"
#import "NonDownloadedCollectionViewCell.h"
#import "ErrorDownloadedCollectionViewCell.h"
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
#import "UIImage+SMXCustomMethods.h"
#import "AttachmentsUploadManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "UIImage+FixOrientation.h"
#import "AppManager.h"
#import "DateUtil.h"
#import "StyleManager.h"
#import "StyleGuideConstants.h"
#import "SyncManager.h"
#import "StringUtil.h"
#import "SMLogger.h"
#import "PushNotificationHeaders.h"
#import "FactoryDAO.h"
#import "AttachmentErrorDAO.h"
#import "AttachmentErrorService.h"
#import "Photos/Photos.h"

#define MaximumDuration 120
static NSInteger const kDeleteButton = 321;
static NSString *const kMovExtension = @"mov";
static NSString *const kJpgExtension = @"jpg";
static NSString *const kAttachmentErrorMessage = @"message";
static NSString *const kAttachmentErrorCode = @"errorCode";

@interface ImagesVideosViewController ()

@property(nonatomic, assign) BOOL compressionCompleted;
@property(nonatomic, strong) NSMutableArray *imagesAndVideosArray;
@property(nonatomic, strong) NSMutableArray *selectedImagesAndVideosArray;
@property(nonatomic, strong) NSMutableDictionary *attachmentIdIndexDictionary;
@property(nonatomic, strong) AttachmentsDownloadManager *downloadManager;
@property(nonatomic, strong) AttachmentsUploadManager *uploadManager;
@property(nonatomic, strong) UIAlertView *cancelDownloadAlert;
@property(nonatomic, strong) SVMXImagePickerController *cameraViewController;
@property(nonatomic, strong) UIPopoverController *sharePopOver;

-(void)showPreviewViewController:(AttachmentTXModel*)attachmentModel;
-(void)createAttachmentPopover;
-(void)hideAttachmentPopover;
-(void)hideImagePickerPopover;
-(void)updateTags;

@end

@implementation ImagesVideosViewController

@synthesize collectionView;
@synthesize imageAndVideoView;
@synthesize editProcessHeaderView;
@synthesize editProcessHeaderLabel;
@synthesize parentId;
@synthesize loadPickerbtn;
@synthesize popoverController;
@synthesize popoverImagePickerController;

static NSString *const kDownloadedCollectionViewCell = @"DownloadedCollectionViewCell";
static NSString *const kNonDownloadedCollectionViewCell = @"NonDownloadedCollectionViewCell";
static NSString *const kErrorDownloadedCollectionViewCell = @"ErrorDownloadedCollectionViewCell";

- (CGFloat)heightOfTheView {
    
    if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        return 690.0f;
    }
    else
    {
        return 900.0f;
    }

}

- (BOOL)scrollableTableView
{
    return NO;
}

- (BOOL)isBorderNeeded
{
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateTags];
    [self.deleteButton setHidden:self.isViewMode];
    [self.loadPickerbtn setHidden:self.isViewMode];
    [self setUpCollectionView];
    self.selectedImagesAndVideosArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.attachmentIdIndexDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    _downloadManager = [AttachmentsDownloadManager sharedManager];
    _uploadManager = [AttachmentsUploadManager sharedManager];
    _downloadManager.imagesVideosDelegate = self;
    [self createAttachmentPopover];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPage) name:kNetworkConnectionChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPage) name:kDataSyncStatusNotification object:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(selectButtonStatus) userInfo:nil repeats:YES];
    [self registerForPopOverDismissNotification];
}

- (void)setImagesAndVideosArray:(NSMutableArray *)imagesAndVideosArray
{
    _imagesAndVideosArray = imagesAndVideosArray;
    _selectButton.enabled = [_imagesAndVideosArray count];
}

-(void)updateTags
{
    [self.selectButton setTitle:[[TagManager sharedInstance] tagByName:kTag_Select] forState:UIControlStateNormal];
    [self.cancelButton setTitle:[[TagManager sharedInstance] tagByName:kCancelButtonTitle] forState:UIControlStateNormal];
    self.titleLabel.text = [[TagManager sharedInstance] tagByName:kTag_ImagesAndVideo];
    //kAttachmentImagesAndVideos;
}

- (void)selectButtonStatus {
    
   self.selectButton.enabled = [self.imagesAndVideosArray count];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _downloadManager.imagesVideosDelegate = self;
    [self refreshPage];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _downloadManager.imagesVideosDelegate = nil;
}

- (void)refreshPage
{
    self.imagesAndVideosArray = [AttachmentHelper getImagesAndVideosAttachmentsLinkedToParentId:self.parentId];
    [self cancelAction:nil];
    [self.collectionView reloadData];
}

- (void)setUpCollectionView {
    
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView registerNib:[UINib nibWithNibName:kDownloadedCollectionViewCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kDownloadedCollectionViewCell];
    [self.collectionView registerNib:[UINib nibWithNibName:kNonDownloadedCollectionViewCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kNonDownloadedCollectionViewCell];
    [self.collectionView registerNib:[UINib nibWithNibName:kErrorDownloadedCollectionViewCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kErrorDownloadedCollectionViewCell];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark === UICollectionViewDataSource ===
#pragma mark -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.collectionView performBatchUpdates:nil completion:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isViewMode)
    {
        if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
        {
            return CGSizeMake(170.0f, 170.0f);
        }
        else
        {
            return CGSizeMake(185.0f, 185.0f);
        }
    }
    else
    {
        if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
        {
            return CGSizeMake(165.0f, 165.0f);
        }
        else
        {
            return CGSizeMake(180.0f, 180.0f);
        }
        
    }
    return CGSizeMake(170.0f, 170.0f);
   
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.imagesAndVideosArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    __autoreleasing AttachmentTXModel *attachmentModel = [self.imagesAndVideosArray objectAtIndex:indexPath.row];
    [self.attachmentIdIndexDictionary setValue:[NSNumber numberWithInteger:indexPath.row] forKey:attachmentModel.localId];
    
    if (!attachmentModel.errorCode)
    {
        if(attachmentModel.isDownloaded)
        {
            DownloadedCollectionViewCell *downloadedCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kDownloadedCollectionViewCell forIndexPath:indexPath];
            [downloadedCell configureDownloadedCell:attachmentModel isEditMode:imageAndVideoView.hidden];
            attachmentModel = nil;
            return downloadedCell;
        }
        else
        {
            NonDownloadedCollectionViewCell *nonDownloadedCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kNonDownloadedCollectionViewCell forIndexPath:indexPath];
            [nonDownloadedCell configureNonDownloadedCell:attachmentModel isEditMode:imageAndVideoView.hidden];
            attachmentModel = nil;
            return nonDownloadedCell;
        }
        
    }
    else
    {
        ErrorDownloadedCollectionViewCell *errorCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kErrorDownloadedCollectionViewCell forIndexPath:indexPath];
        [errorCell configureErrorCell:attachmentModel isEditMode:imageAndVideoView.hidden];
        attachmentModel = nil;
        return errorCell;
    }
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:kNonDownloadedCollectionViewCell forIndexPath:indexPath];
}

#pragma mark -
#pragma mark === UICollectionViewDelegateSource ===
#pragma mark -

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    
    AttachmentTXModel *selectedModel = [self.imagesAndVideosArray objectAtIndex:indexPath.row];
    
    if (!selectedModel.isDownloaded &&
        ![[SNetworkReachabilityManager sharedInstance] isNetworkReachable] &&
        ![_downloadManager.downloadingDictionary objectForKey:selectedModel.localId])
    {
        [AttachmentUtility showNewWorkErrorAlert:selectedModel];
    }
    if (imageAndVideoView.hidden)
    {
        if (selectedModel.isDownloaded)
        {
            DownloadedCollectionViewCell *downLoadCell = (DownloadedCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
            selectedModel.isSelected = YES;
            downLoadCell.checkmarkImageView.image = [UIImage imageNamed:@"Attachment-SelectionCheckfilled"];
            [self.imagesAndVideosArray replaceObjectAtIndex:indexPath.row withObject:selectedModel];
            [self.selectedImagesAndVideosArray addObject:selectedModel];
            [self updateShareAndDeleteButton];
        }
    }
    else if(selectedModel.isDownloaded)
    {
        [self showPreviewViewController:selectedModel];
    }
    else if([_downloadManager.downloadingDictionary objectForKey:selectedModel.localId])
    {
        
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
            if (!selectedModel.errorCode)
            {
                selectedModel.errorCode = 0;
                selectedModel.errorMessage = nil;
                [self.imagesAndVideosArray replaceObjectAtIndex:indexPath.row withObject:selectedModel];
                [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
                
                id <AttachmentErrorDAO> attachmentErrorService = [FactoryDAO serviceByServiceType:ServiceTypeAttachmentError];
                BOOL status =[attachmentErrorService insertAttachmentErrorTableWithModel:selectedModel];
                if  (status){
                    [_downloadManager addDocumentAttachmentForDownload:selectedModel];
                    
                }

                [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
            }
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (imageAndVideoView.hidden)
    {
        AttachmentTXModel *selectedModel = [self.imagesAndVideosArray objectAtIndex:indexPath.row];
        if (selectedModel.isDownloaded)
        {
            DownloadedCollectionViewCell *downLoadCell = (DownloadedCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
            selectedModel.isSelected = NO;
            downLoadCell.checkmarkImageView.image = [UIImage imageNamed:@"Attachment-SelectionCheckempty"];
            [self.imagesAndVideosArray replaceObjectAtIndex:indexPath.row withObject:selectedModel];
            if ([self.selectedImagesAndVideosArray containsObject:selectedModel]) {
                [self.selectedImagesAndVideosArray removeObject:selectedModel];
            }
            [self updateShareAndDeleteButton];
        }

    }
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark === ImagesAndVideosDownloadDelegate Methods ===
#pragma mark -

- (void)imagesVideosDownloadRequestStarted:(NSDictionary *)downloadInfoDict
{
    [self showProgressOfDownLoad:downloadInfoDict];
}

- (void)imagesVideosDownloadRequestProgress:(NSDictionary *)downloadInfoDict
{
    [self showProgressOfDownLoad:downloadInfoDict];
}

- (void)showProgressOfDownLoad:(NSDictionary*)downloadInfoDict {
    
    @autoreleasepool {
        
        if (editProcessHeaderView.hidden) {
            
            NSString *attachmentId = [downloadInfoDict valueForKey:kDocumentsDownloadKeyFileId];
            NSInteger row = [[self.attachmentIdIndexDictionary valueForKey:attachmentId] integerValue];
            NSIndexPath *indexPathToRefresh = [NSIndexPath indexPathForRow:row inSection:0];
            NonDownloadedCollectionViewCell *downloadingCell = (NonDownloadedCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPathToRefresh];
            [downloadingCell configureNonDownloadedCell:[self.imagesAndVideosArray objectAtIndex:row] isEditMode:NO];
        }
    }
}

- (void)imagesVideosDownloadRequestFinished:(NSDictionary *)downloadInfoDict
{
    NSString *attachmentId = [downloadInfoDict valueForKey:kDocumentsDownloadKeyFileId];
    NSString *extension = [downloadInfoDict valueForKey:kDocumentsDownloadKeyFileExtension];
    if ([StringUtil isStringEmpty:extension]) {
        extension = @"";
    }
    NSInteger row = [[self.attachmentIdIndexDictionary valueForKey:attachmentId] integerValue];
    AttachmentTXModel *attachmentModel = [self.imagesAndVideosArray objectAtIndex:row];
    NSIndexPath *indexPathToRefresh = [NSIndexPath indexPathForRow:row inSection:0];
    
    if ([AttachmentUtility doesFileExists:[AttachmentUtility fileNameForAttachment:attachmentModel]])
    {
        if ([_downloadManager.imgDict valueForKey:extension])
        {
            attachmentModel.thumbnailImage = [AttachmentUtility scaleImage:[AttachmentUtility filePathForAttachment:attachmentModel] toSize:CGSizeMake(170.0f, 170.0f)];
        }
        if ([_downloadManager.videoDict valueForKey:extension]) {
            UIImage *videoImage = [AttachmentUtility getThumbnailImageForFilePath:[AttachmentUtility filePathForAttachment:attachmentModel]];
            attachmentModel.thumbnailImage = [UIImage scaleImage:videoImage toSize:CGSizeMake(170.0f, 170.0f)];
        }
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString * fileContent=[[NSString alloc]initWithContentsOfFile:[[AttachmentUtility getFullPath:attachmentId] stringByAppendingString:attachmentModel.extensionName] encoding:NSUTF8StringEncoding error:nil];
        SXLogInfo(@"%@",fileContent);
        id <AttachmentErrorDAO> attachmentErrorService = [FactoryDAO serviceByServiceType:ServiceTypeAttachmentError];

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
        
        
        
        [self.imagesAndVideosArray replaceObjectAtIndex:row withObject:attachmentModel];
        //TODO: Remove from attachment error table
    }
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPathToRefresh]];
}

- (void)imagesVideosDownloadRequestCanceled:(NSDictionary *)downloadInfoDict
{
    NSString *attachmentId = [downloadInfoDict valueForKey:kDocumentsDownloadKeyFileId];
    NSInteger row = [[self.attachmentIdIndexDictionary valueForKey:attachmentId] integerValue];
    AttachmentTXModel *attachmentModel = [self.imagesAndVideosArray objectAtIndex:row];
    NSIndexPath *indexPathToRefresh = [NSIndexPath indexPathForRow:row inSection:0];
    NSInteger errorCode = [[downloadInfoDict valueForKey:kDocumentsDownloadKeyErrorCode] integerValue];
    if (errorCode != AttachmentDownloadErrorUserForceQuit &&
        errorCode != AttachmentDownloadErrorUserCancelled)
    {
        attachmentModel.errorCode = errorCode;
        attachmentModel.errorMessage = [AttachmentUtility getAttachmentAPIErrorMessage:(int)errorCode];
        [self.imagesAndVideosArray replaceObjectAtIndex:row withObject:attachmentModel];
        //TODO : Update database attachment error table
    }
    
    id <AttachmentErrorDAO> attachmentErrorService = [FactoryDAO serviceByServiceType:ServiceTypeAttachmentError];
    [attachmentErrorService deleteAttachmentsFromDBDirectoryForParentId:attachmentModel.parentId];
    
    
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPathToRefresh]];
    
}


#pragma mark -
#pragma mark === UI Actions ===
#pragma mark -

- (IBAction)selectAction:(UIButton *)sender
{
    imageAndVideoView.hidden = YES;
    editProcessHeaderView.hidden = NO;
    [self.collectionView reloadData];
}

- (void)refreshHeaderTitle:(NSInteger)selectedItems
{
    editProcessHeaderLabel.text=[NSString stringWithFormat:@"%ld %@",(long)selectedItems,[[TagManager sharedInstance] tagByName:kTag_ItemSelected]];
}

- (IBAction)cancelAction:(UIButton *)sender
{
    for (AttachmentTXModel *attachmentModel in self.imagesAndVideosArray)
    {
        attachmentModel.isSelected = NO;
    }
    [self.selectedImagesAndVideosArray removeAllObjects];
    [self updateShareAndDeleteButton];
    imageAndVideoView.hidden = NO;
    editProcessHeaderView.hidden = YES;
    [self.collectionView reloadData];
}

- (IBAction)shareAction:(UIButton *)sender
{
    if (self.shareButton.isSelected) {
        
        NSMutableArray *urlItemsArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (AttachmentTXModel *shareModel in self.selectedImagesAndVideosArray)
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

- (IBAction)deleteAction:(UIButton *)sender
{
    if (self.deleteButton.isSelected) {
        
        NSString *delete = [[TagManager sharedInstance] tagByName:kTagDeleteButtonTitle];
        NSString *cancel = [[TagManager sharedInstance] tagByName:kTagCancelButton];

        [[AlertMessageHandler sharedInstance] showCustomMessage:[NSString stringWithFormat:[[TagManager sharedInstance] tagByName: kTag_TheSelectedAttachementWillBeRemoved], self.parentObjectName] withDelegate:self tag:kDeleteButton title:@"" cancelButtonTitle:cancel andOtherButtonTitles:[NSArray arrayWithObject:delete]];
    }
    
}

- (void)didDeleteAttachment:(AttachmentTXModel*)attachment {
    
    if (![StringUtil isStringEmpty:attachment.idOfAttachment])
    {
        self.sfmPage.isAttachmentEdited = YES;
    }
    if ([self.imagesAndVideosArray containsObject:attachment]) {
        [self.imagesAndVideosArray removeObject:attachment];
    }
    if ([self.selectedImagesAndVideosArray containsObject:attachment]) {
        [self.selectedImagesAndVideosArray removeObject:attachment];
    }
    
}

- (void)updateShareAndDeleteButton
{
    [self refreshHeaderTitle:[self.selectedImagesAndVideosArray count]];
    if ([self.selectedImagesAndVideosArray count])
    {
        [self.shareButton setSelected:YES];
        [self.deleteButton setSelected:YES];
    }else
    {
        [self.shareButton setSelected:NO];
        [self.deleteButton setSelected:NO];
    }
}

#pragma mark-
#pragma AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView == self.cancelDownloadAlert) {
        
        if (buttonIndex != [alertView cancelButtonIndex])
        {
            AttachmentTXModel *cancelModel = [self.imagesAndVideosArray objectAtIndex:self.cancelDownloadAlert.tag];
            [_downloadManager cancelDownloadWithId:cancelModel.localId];
        }
        
    }
    
    if (alertView.tag == kDeleteButton) {
        
        if (buttonIndex != [alertView cancelButtonIndex])
        {
            NSMutableArray *localCreatedIds = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray *modifiedArray = [[NSMutableArray alloc] initWithCapacity:0];
            
            for (AttachmentTXModel *deleteModel in self.selectedImagesAndVideosArray)
            {
                if (![_uploadManager isFileUploading:deleteModel.localId])
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
                            modifiedModel.parentLocalId = self.parentId;
                            modifiedModel.timeStamp = [DateUtil getDatabaseStringForDate:[NSDate date]];
                            [modifiedArray addObject:modifiedModel];
                            [AttachmentHelper addModifiedRecordLocalId:deleteModel.localId];
                        }
                        else
                        {
                            [localCreatedIds addObject:deleteModel.localId];
                        }
                        
                        [_uploadManager deleteFileFromQueue:deleteModel.localId];
                        
                        if ([self.imagesAndVideosArray containsObject:deleteModel]) {
                            [self.imagesAndVideosArray removeObject:deleteModel];
                            
                        }
                        
                    }
                    else {
                        //TODO: handle error
                    }

                }
                else
                {
                    NSString *ok = [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
                    [[AlertMessageHandler sharedInstance] showCustomMessage:[NSString stringWithFormat:@"%@ \n %@",kAttachmentUnableDelete, deleteModel.name] withDelegate:nil tag:0 title:[[TagManager sharedInstance] tagByName:kTagAlertApplicationError] cancelButtonTitle:ok andOtherButtonTitles:nil];
                }
                
            }
            [AttachmentHelper deleteAttachmentsWithLocalIds:localCreatedIds];
            [AttachmentHelper saveDeleteAttachmentsToModifiedRecords:modifiedArray];
            [self.selectedImagesAndVideosArray removeAllObjects];
            [self.collectionView reloadData];
            [self updateShareAndDeleteButton];
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

#pragma mark-
#pragma AttachmentSharing options

//D-00003728
- (void)displaySharingView:(NSArray*)urlItems sender:(UIButton *)button
{
    //11450
    UIActivityViewController * sharingView = [[UIActivityViewController alloc] initWithActivityItems:urlItems applicationActivities:nil];
    NSArray * excludedActivities = nil;
    NSMutableArray *sharingOptions = [NSMutableArray arrayWithArray:@[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                                                      UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact,
                                                                      UIActivityTypePostToWeibo, UIActivityTypePostToFlickr,
                                                                      UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo,]];
    
    excludedActivities = sharingOptions;
    sharingView.excludedActivityTypes = excludedActivities;
    //12123
    if (!self.sharePopOver)
    {
        self.sharePopOver = [[UIPopoverController alloc] initWithContentViewController:sharingView];
        self.sharePopOver.delegate = self;
    }
    [self.sharePopOver presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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

#pragma mark -
#pragma mark === UIImagePicker and Add Image, Video Related ===
#pragma mark -

- (IBAction) showimagePicker:(UIButton*)button
{
    [self hideAttachmentPopover];
    [popoverController setPopoverContentSize:CGSizeMake(300.0f, 119.0f)];
    popoverController.contentViewController.view.backgroundColor = [UIColor getUIColorFromHexValue:kActionBgColor];
    [popoverController presentPopoverFromRect:button.frame
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
}

-(void)createAttachmentPopover
{
    AttachmentPopoverViewController *attachmentPopoverController = [[AttachmentPopoverViewController alloc] initWithNibName:@"AttachmentPopoverViewController" bundle:nil];
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:attachmentPopoverController];
    attachmentPopoverController.view.frame = CGRectMake(0.0f, 0.0f, 300.0f, 119.0f);
    attachmentPopoverController.attachmentDelegate = self;
    attachmentPopoverController.view.backgroundColor = [UIColor clearColor];
}

-(void)selectedOption:(ImagePickerOptions)selectedIndex {
    
    [self hideAttachmentPopover];
    
    //Check for PhotoLibrary access persmissions
    PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus];
    if (photoStatus == PHAuthorizationStatusAuthorized) {
        [self evaluateAdditionalAccessPermissionAndLaunchSelectedIndexOptions:selectedIndex];
    }
    else if (photoStatus == PHAuthorizationStatusDenied) {
        //Do Nothing
    }
    else if (photoStatus == PHAuthorizationStatusNotDetermined) {
        //Request photo library access authorization
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self evaluateAdditionalAccessPermissionAndLaunchSelectedIndexOptions:selectedIndex];
            }
        }];
    }
    else if (photoStatus == PHAuthorizationStatusRestricted) {
        // Restricted access - normally won't happen.
    }
}
-(void)evaluateAdditionalAccessPermissionAndLaunchSelectedIndexOptions:(ImagePickerOptions)selectedIndex{
    if (selectedIndex == ImagePickerOptionNewVideo || selectedIndex==ImagePickerOptionNewPicture) {
        //Check for camera access permissions
        AVAuthorizationStatus cameraStatus = (AVAuthorizationStatus)[AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (cameraStatus == AVAuthorizationStatusAuthorized) {
            if (selectedIndex== ImagePickerOptionNewVideo) {
                //Check for microphone access permissions
                AVAuthorizationStatus micStatus = (AVAuthorizationStatus)[AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                if (micStatus!=AVAuthorizationStatusNotDetermined) {
                    [self showCaptureViewWhenPermissionIsAuthorizedWithSelectedIndex:selectedIndex];
                }else{
                    //Request microphone access authorization
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted)
                     {
                         [self showCaptureViewWhenPermissionIsAuthorizedWithSelectedIndex:selectedIndex];
                     }];
                }
                
            }
            else{
                [self showCaptureViewWhenPermissionIsAuthorizedWithSelectedIndex:selectedIndex];
            }
        }
        else if (cameraStatus == AVAuthorizationStatusDenied) {
            //Do nothing
        }
        else if (cameraStatus == AVAuthorizationStatusNotDetermined) {
            //Request camera access authorization
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
             {
                 if (granted) {
                     [self showCaptureViewWhenPermissionIsAuthorizedWithSelectedIndex:selectedIndex];
                 }
             }];
        }
        else if (cameraStatus == AVAuthorizationStatusRestricted) {
            // Restricted access - normally won't happen.
        }
    }
    else{
        [self showCaptureViewWhenPermissionIsAuthorizedWithSelectedIndex:selectedIndex];
    }
}

-(void)showCaptureViewWhenPermissionIsAuthorizedWithSelectedIndex:(ImagePickerOptions)selectedIndex{
    if (selectedIndex==ImagePickerOptionFromCameraRoll) {
        [self startCameraControllerFromViewControllerisImageFromCamera:NO isVideoMode:NO];
    }
    else if (selectedIndex==ImagePickerOptionNewPicture) {
        [self startCameraControllerFromViewControllerisImageFromCamera:YES isVideoMode:NO];
    }
    else if (selectedIndex==ImagePickerOptionNewVideo) {
        [self startCameraControllerFromViewControllerisImageFromCamera:YES isVideoMode:YES];
    }
}
- (BOOL) startCameraControllerFromViewControllerisImageFromCamera:(BOOL)isCameraCapture isVideoMode:(BOOL)isVideoMode {
    
    if(!self.cameraViewController)
    self.cameraViewController = [[SVMXImagePickerController alloc] init];
    /**< Check isSourceTypeAvailable for possible sources (camera and photolibrary) */
    
    if (([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] == NO) || ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary] == NO))
        return NO;
    
    /**< if editing is required*/
    
    self.cameraViewController.allowsEditing = NO;
    self.cameraViewController.delegate = self;
    self.cameraViewController.videoQuality=UIImagePickerControllerQualityTypeMedium;
   
    if(isCameraCapture) {
        
        // still camera image,
        self.cameraViewController.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.cameraViewController.videoMaximumDuration = MaximumDuration;
        // if video is not needed then remove below line
        self.cameraViewController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if(isVideoMode)
        {
            
            self.cameraViewController.cameraCaptureMode =UIImagePickerControllerCameraCaptureModeVideo;
        }
        else
        {
            self.cameraViewController.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
            
        }
        self.cameraViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        AttachmentPopoverViewController *attachmentPopVC = (AttachmentPopoverViewController*)self.popoverController.contentViewController;
        attachmentPopVC.attachmentTableView.userInteractionEnabled = NO;
        [self presentViewController:self.cameraViewController animated:YES completion:^{attachmentPopVC.attachmentTableView.userInteractionEnabled = YES;}];
    }
    else {
        //capture image from gallery
        self.cameraViewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.cameraViewController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
        UIPopoverController *popOver = [[UIPopoverController alloc] initWithContentViewController:self.cameraViewController];
        popOver.delegate = self;
        self.popoverImagePickerController = popOver;
        [self.popoverImagePickerController setPopoverContentSize:CGSizeMake(320.0f, 480.0f)];
        [self.popoverImagePickerController presentPopoverFromRect:self.loadPickerbtn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }
    
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    BOOL isVideoTaken=false;
    //Handle video
    NSURL *videoURL = [info valueForKey:UIImagePickerControllerMediaURL];
    NSString *pathToVideo = [videoURL path];
    if(![pathToVideo isEqualToString:@""] && pathToVideo != nil) {
        BOOL okToSaveVideo = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(pathToVideo);
        if (okToSaveVideo && [info objectForKey:UIImagePickerControllerReferenceURL] == nil) {
            isVideoTaken = TRUE;
            UISaveVideoAtPathToSavedPhotosAlbum(pathToVideo, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
        }
    }
    
    picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    picker.videoMaximumDuration = MaximumDuration;
    // Handle a still image capture
    /**
     * Pushpak defect 014109
     */
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSString *extension =[[info objectForKey:UIImagePickerControllerReferenceURL]pathExtension];
    
    if([mediaType isEqualToString:@"public.movie"])
    {
        SXLogInfo(@"VIDEO");
        picker.view.userInteractionEnabled = NO;
        [self videoCaptured:videoURL isCaptured:!isVideoTaken picker:picker];
    }
    else if([mediaType isEqualToString:@"public.image"])
    {
        if([info objectForKey:UIImagePickerControllerReferenceURL] == nil)
        {
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            image = [image fixImageOrientation];
            NSData *dataToSaveFromImage = UIImageJPEGRepresentation(image,0.5);
            UIImageWriteToSavedPhotosAlbum(image,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
            /**
             * Pushpak defect 014109
             */
            if(self && [self respondsToSelector:@selector(dataFromCapturedImage:extension:)]) {
                [self performSelector:@selector(dataFromCapturedImage:extension:) withObject:dataToSaveFromImage withObject:nil];
            }
            [self hideImagePickerPopover];
            
        } else {
            
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            __block UIImage *image = nil;
            __block NSData *dataToSaveFromImage;
            
            [library assetForURL:[info valueForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {

                if (asset){
                    //////////////////////////////////////////////////////
                    // SUCCESS POINT #1 - asset is what we are looking for
                    //////////////////////////////////////////////////////
                    image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
                    
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    Byte *buffer = (Byte*)malloc(rep.size);
                    NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
                    dataToSaveFromImage = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                    
                    if(self && [self respondsToSelector:@selector(dataFromCapturedImage:extension:)]) {
                        [self performSelector:@selector(dataFromCapturedImage:extension:) withObject:dataToSaveFromImage withObject:extension];
                    }
                    SXLogInfo(@"Camera");
                    [self hideImagePickerPopover];

                }
                else {
                    // On iOS 8.1 [library assetForUrl] Photo Streams always returns nil. Try to obtain it in an alternative way
                    
                    [library enumerateGroupsWithTypes:ALAssetsGroupPhotoStream
                                           usingBlock:^(ALAssetsGroup *group, BOOL *stop)
                     {
                         [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                             if([result.defaultRepresentation.url isEqual:[info valueForKey:UIImagePickerControllerReferenceURL]])
                             {
                                 ///////////////////////////////////////////////////////
                                 // SUCCESS POINT #2 - result is what we are looking for
                                 ///////////////////////////////////////////////////////
                                 image = [UIImage imageWithCGImage:[[result defaultRepresentation] fullResolutionImage]];
                                 
                                 ALAssetRepresentation *rep = [result defaultRepresentation];
                                 Byte *buffer = (Byte*)malloc(rep.size);
                                 NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
                                 dataToSaveFromImage = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                                 
                                 if(self && [self respondsToSelector:@selector(dataFromCapturedImage:extension:)]) {
                                     [self performSelector:@selector(dataFromCapturedImage:extension:) withObject:dataToSaveFromImage withObject:extension];
                                 }
                                 SXLogInfo(@"Camera");
                                 [self hideImagePickerPopover];
                                 *stop = YES;
                             }
                         }];
                     }
                     failureBlock:^(NSError *error)
                     {
                         NSLog(@"Error: Cannot load asset from photo stream - %@", [error localizedDescription]);
                     }];
                }
            } failureBlock:^(NSError *error) {
                
                NSLog(@"error : %@", error);
                /**
                 * Pushpak defect 014109
                 */
                if(self && [self respondsToSelector:@selector(dataFromCapturedImage:extension:)]) {
                    [self performSelector:@selector(dataFromCapturedImage:extension:) withObject:dataToSaveFromImage withObject:extension];
                }
                SXLogInfo(@"Camera");
                [self hideImagePickerPopover];
            }];
        }
    }
}

- (void) dataFromCapturedImage:(NSData *)capturedImageData extension:(NSString *)extension
{
    if ([StringUtil isStringEmpty:extension]) {
        extension = kJpgExtension;
    }
    
    extension = [[NSString stringWithFormat:@".%@", extension] lowercaseString];
    NSString *local_id = [AppManager generateUniqueId];
    bool canAttach = [AttachmentUtility canAttachthisfile:capturedImageData type:extension];
    if(canAttach)
    {
        [AttachmentUtility writeAttachmentToDocumentDirectory:capturedImageData localId:local_id withExt:extension];

        //TODO: update model and save it to database
        [self saveAttachmentInfoDictWithId:local_id andExtension:extension];
    }
    [self hideImagePickerPopover];
    
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(error)
    {
        [[AlertMessageHandler sharedInstance] showCustomMessage:error.localizedDescription withDelegate:nil tag:0 title:[[TagManager sharedInstance] tagByName:kTagAlertApplicationError] cancelButtonTitle:[[TagManager sharedInstance] tagByName:kTagAlertErrorOk]andOtherButtonTitles:nil];
        //@"Failed to save image"
    }
}
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    //Do required stuff.
    if(error)
    {
        [[AlertMessageHandler sharedInstance] showCustomMessage:error.localizedDescription withDelegate:nil tag:0 title:[[TagManager sharedInstance] tagByName:kTagAlertApplicationError] cancelButtonTitle:[[TagManager sharedInstance] tagByName:kTagAlertErrorOk]andOtherButtonTitles:nil];
        //@"Failed to save video"
        
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self hideImagePickerPopover];
}

-(void)videoCaptured:(NSURL*)inputPathURL isCaptured:(BOOL)isCaptured picker:(UIImagePickerController *)picker
{
    NSString *extension = [inputPathURL pathExtension];
    if (![StringUtil isStringEmpty:extension]) {
        extension = [extension lowercaseString];
    }
    else {
        extension = kMovExtension;
    }
    extension = [NSString stringWithFormat:@".%@", extension];
    NSString *local_id = [AppManager generateUniqueId];
    NSString *outputPath = [AttachmentUtility pathToAttachmentfile:local_id withExt:extension];
    NSURL *outputUrl = [NSURL fileURLWithPath:outputPath];
    //NSData *databeforeCompres = [NSData dataWithContentsOfURL:inputPathURL];
    //NSUInteger sizebeforeCompression = [databeforeCompres length];
    NSUInteger sizebeforeCompression = [[NSData dataWithContentsOfURL:inputPathURL] length]; //SecScan-580

    
    float sizeinMB = (1.0 *sizebeforeCompression)/1048576;
    
    if (sizeinMB > 25) {
        
        [self convertVideoToLowQualityWithInputURL:inputPathURL outputURL:outputUrl successHandler:nil failureHandler:nil];
        
        while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, 1.0f, NO))
        {
            //@"Compressing video"
            
            if(self.compressionCompleted == YES)
            {
                break;
            }
        }
        // Video under upload limit check
        NSData *dataAfterCompres = [NSData dataWithContentsOfURL:outputUrl];
        BOOL canAttach= [AttachmentUtility canAttachthisfile:dataAfterCompres type:extension];
        // Adding details to dict
        if(canAttach)
        {
            [self saveAttachmentInfoDictWithId:local_id andExtension:extension];
        }
    }
    else {
        
        if([[NSFileManager defaultManager] fileExistsAtPath:[outputUrl path]])
            [[NSFileManager defaultManager] removeItemAtURL:outputUrl error:nil];
        //[[NSFileManager defaultManager] createFileAtPath:[outputUrl path] contents:databeforeCompres attributes:nil];
        [[NSFileManager defaultManager] createFileAtPath:[outputUrl path] contents:[NSData dataWithContentsOfURL:inputPathURL] attributes:nil];//SecScan-580

        
        [self saveAttachmentInfoDictWithId:local_id andExtension:extension];
        
    }
    picker.view.userInteractionEnabled = TRUE;
    [self hideImagePickerPopover];
    
}

-(void)saveAttachmentInfoDictWithId:(NSString*)localId andExtension:(NSString*)extension
{
    AttachmentTXModel *attachmentModel = [[AttachmentTXModel alloc] init];
    attachmentModel.localId = localId;
    attachmentModel.extensionName = extension;
    attachmentModel.name = [AttachmentUtility generateAttachmentNamefor:self.parentObjectName extension:extension];
    attachmentModel.nameWithoutExtension = [attachmentModel.name stringByDeletingPathExtension];
    attachmentModel.createdDate = [DateUtil getDatabaseStringForDate:[NSDate date]];
    //Anoop: This will be updated on PageEditViewController
    //attachmentModel.lastModifiedDate = [DateUtil getDatabaseStringForDate:[NSDate date]];
    attachmentModel.displayDateString = [DateUtil getDateStringForDBDateTime:attachmentModel.createdDate inFormat:kDateImagesAndVideosAttachment];
    attachmentModel.parentId = self.parentId;
    attachmentModel.isPrivate = kFalse;
    attachmentModel.isDownloaded = YES;
    attachmentModel.bodyLength = [AttachmentUtility getSizeforFileAtPath:[AttachmentUtility filePathForAttachment:attachmentModel]];
    if ([_downloadManager.imgDict valueForKey:extension])
    {
        attachmentModel.thumbnailImage = [AttachmentUtility scaleImage:[AttachmentUtility filePathForAttachment:attachmentModel] toSize:CGSizeMake(170.0f, 170.0f)];
    }
    if ([_downloadManager.videoDict valueForKey:extension]) {
        UIImage *videoImage = [AttachmentUtility getThumbnailImageForFilePath:[AttachmentUtility filePathForAttachment:attachmentModel]];
        attachmentModel.thumbnailImage = [UIImage scaleImage:videoImage toSize:CGSizeMake(170.0f, 170.0f)];
        attachmentModel.isVideo = YES;
    }
    [self.imagesAndVideosArray insertObject:attachmentModel atIndex:0];
    [AttachmentHelper saveLocallyAddedAttachment:attachmentModel];
}

- (void)convertVideoToLowQualityWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL successHandler:(void (^)())successHandler failureHandler:(void (^)(NSError *))failureHandler {
    if([[NSFileManager defaultManager] fileExistsAtPath:[outputURL path]]) [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            self.compressionCompleted = YES;
            //@"Success"
        } else {
            //SMLog(kLogLevelVerbose,@"%ld,%@",(long)exportSession.status,exportSession.error);
            //SMLog(kLogLevelVerbose,@"Failed");
            [self hideImagePickerPopover];
        }
    }];
    
}

- (void)hideAttachmentPopover
{
    if ([popoverController isPopoverVisible])
    {
        [popoverController dismissPopoverAnimated:YES];
    }
}

-(void)hideImagePickerPopover
{
    if(!self.cameraViewController.isBeingDismissed)
       [self.cameraViewController dismissViewControllerAnimated:YES completion:nil];
    if(self.popoverImagePickerController)
    {
        [self.popoverImagePickerController dismissPopoverAnimated:YES];
    }
    [self.collectionView reloadData];
}

-(void)dealloc
{
    collectionView.delegate = nil;
    collectionView.dataSource = nil;
    editProcessHeaderView = nil;
    imageAndVideoView = nil;
    editProcessHeaderLabel = nil;
    loadPickerbtn = nil;
    _selectButton = nil;
    _cancelButton = nil;
    _shareButton = nil;
    _deleteButton = nil;
    parentId = nil;
    _parentObjectName = nil;
    _parentSFObjectName = nil;
    [popoverController dismissPopoverAnimated:NO];
    popoverController = nil;
    [popoverImagePickerController dismissPopoverAnimated:NO];
    popoverImagePickerController = nil;
    [_sharePopOver dismissPopoverAnimated:NO];
    _sharePopOver = nil;
    [_imagesAndVideosArray removeAllObjects];
    _imagesAndVideosArray = nil;
    [_selectedImagesAndVideosArray removeAllObjects];
    _selectedImagesAndVideosArray = nil;
    [_attachmentIdIndexDictionary removeAllObjects];
    _attachmentIdIndexDictionary = nil;
    _cancelDownloadAlert = nil;
    _cameraViewController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNetworkConnectionChanged object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDataSyncStatusNotification object:nil];
    
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
    
    if ([self.popoverController isPopoverVisible] &&
        self.popoverController) {
        
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;
    }
    
    if ([self.popoverImagePickerController isPopoverVisible] &&
        self.popoverImagePickerController) {
        
        [self.popoverImagePickerController dismissPopoverAnimated:YES];
        self.popoverImagePickerController = nil;
    }
    if ([self.sharePopOver isPopoverVisible] &&
        self.sharePopOver) {
        
        [self.sharePopOver dismissPopoverAnimated:YES];
        self.sharePopOver = nil;
    }
    
}



@end
