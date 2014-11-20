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

#define MaximumDuration 120
static NSInteger const kDeleteButton = 321;

@interface ImagesVideosViewController ()

@property(nonatomic, assign) BOOL compressionCompleted;
@property(nonatomic, strong) NSMutableArray *imagesAndVideosArray;
@property(nonatomic, strong) NSMutableArray *selectedImagesAndVideosArray;
@property(nonatomic, strong) NSMutableDictionary *attachmentIdIndexDictionary;
@property(nonatomic, strong) AttachmentsDownloadManager *downloadManager;
@property(nonatomic, strong) AttachmentsUploadManager *uploadManager;
@property(nonatomic, strong) UIAlertView *cancelDownloadAlert;
@property(nonatomic, strong) SVMXImagePickerController *cameraViewController;

-(void)showPreviewViewController:(AttachmentTXModel*)attachmentModel;
-(void)createAttachmentPopover;
-(void)hideAttachmentPopover;
-(void)hideImagePickerPopover;

@end

@implementation ImagesVideosViewController

@synthesize collectionView;
@synthesize imageAndVideoView;
@synthesize editProcessHeaderView;
@synthesize editProcessHeaderLabel;
@synthesize imagesAndVideosArray;
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
    
    [self.deleteButton setHidden:_isViewMode];
    [self.loadPickerbtn setHidden:_isViewMode];
    [self setUpCollectionView];
    self.imagesAndVideosArray = [AttachmentHelper getImagesAndVideosAttachmentsLinkedToParentId:self.parentId];
    self.selectedImagesAndVideosArray = [[NSMutableArray alloc] initWithCapacity:0];
    _attachmentIdIndexDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    _downloadManager = [AttachmentsDownloadManager sharedManager];
    _uploadManager = [AttachmentsUploadManager sharedManager];
    _downloadManager.imagesVideosDelegate = self;
    [self createAttachmentPopover];
    [self cancelAction:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInternetConnectionChange) name:kNetworkConnectionChanged object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.collectionView reloadData];
}

- (void)didInternetConnectionChange
{
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
    if (_isViewMode)
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
    
    __autoreleasing AttachmentTXModel *attachmentModel = [imagesAndVideosArray objectAtIndex:indexPath.row];
    [_attachmentIdIndexDictionary setValue:[NSNumber numberWithInteger:indexPath.row] forKey:attachmentModel.localId];
    
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
    
    AttachmentTXModel *selectedModel = [imagesAndVideosArray objectAtIndex:indexPath.row];
    
    if (imageAndVideoView.hidden)
    {
        if (selectedModel.isDownloaded)
        {
            DownloadedCollectionViewCell *downLoadCell = (DownloadedCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
            selectedModel.isSelected = YES;
            downLoadCell.checkmarkImageView.image = [UIImage imageNamed:@"Attachment-SelectionCheckfilled"];
            [imagesAndVideosArray replaceObjectAtIndex:indexPath.row withObject:selectedModel];
            [_selectedImagesAndVideosArray addObject:selectedModel];
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
            if (selectedModel.errorCode)
            {
                selectedModel.errorCode = 0;
                selectedModel.errorMessage = nil;
                [imagesAndVideosArray replaceObjectAtIndex:indexPath.row withObject:selectedModel];
                [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
            }
            [_downloadManager addDocumentAttachmentForDownload:selectedModel];
                [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (imageAndVideoView.hidden)
    {
        AttachmentTXModel *selectedModel = [imagesAndVideosArray objectAtIndex:indexPath.row];
        if (selectedModel.isDownloaded)
        {
            DownloadedCollectionViewCell *downLoadCell = (DownloadedCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
            selectedModel.isSelected = NO;
            downLoadCell.checkmarkImageView.image = [UIImage imageNamed:@"Attachment-SelectionCheckempty"];
            [imagesAndVideosArray replaceObjectAtIndex:indexPath.row withObject:selectedModel];
            if ([_selectedImagesAndVideosArray containsObject:selectedModel]) {
                [_selectedImagesAndVideosArray removeObject:selectedModel];
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
            NSInteger row = [[_attachmentIdIndexDictionary valueForKey:attachmentId] integerValue];
            NSIndexPath *indexPathToRefresh = [NSIndexPath indexPathForRow:row inSection:0];
            NonDownloadedCollectionViewCell *downloadingCell = (NonDownloadedCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPathToRefresh];
            [downloadingCell configureNonDownloadedCell:[imagesAndVideosArray objectAtIndex:row] isEditMode:NO];
        }
    }
}

- (void)imagesVideosDownloadRequestFinished:(NSDictionary *)downloadInfoDict
{
    NSString *attachmentId = [downloadInfoDict valueForKey:kDocumentsDownloadKeyFileId];
    NSString *extension = [downloadInfoDict valueForKey:kDocumentsDownloadKeyFileExtension];
    if (![extension length]) {
        extension = @"";
    }
    NSInteger row = [[_attachmentIdIndexDictionary valueForKey:attachmentId] integerValue];
    AttachmentTXModel *attachmentModel = [imagesAndVideosArray objectAtIndex:row];
    NSIndexPath *indexPathToRefresh = [NSIndexPath indexPathForRow:row inSection:0];
    
    if ([AttachmentUtility doesFileExists:[AttachmentUtility fileNameForAttachment:attachmentModel]])
    {
        attachmentModel.isDownloaded = YES;
        if ([_downloadManager.imgDict valueForKey:extension])
        {
            attachmentModel.thumbnailImage = [AttachmentUtility scaleImage:[AttachmentUtility filePathForAttachment:attachmentModel] toSize:CGSizeMake(170.0f, 170.0f)];
        }
        if ([_downloadManager.videoDict valueForKey:extension]) {
            UIImage *videoImage = [AttachmentUtility getThumbnailImageForFilePath:[AttachmentUtility filePathForAttachment:attachmentModel]];
            attachmentModel.thumbnailImage = [UIImage scaleImage:videoImage toSize:CGSizeMake(170.0f, 170.0f)];
        }
        [imagesAndVideosArray replaceObjectAtIndex:row withObject:attachmentModel];
        //TODO: Remove from attachment error table
    }
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPathToRefresh]];
}

- (void)imagesVideosDownloadRequestCanceled:(NSDictionary *)downloadInfoDict
{
    NSString *attachmentId = [downloadInfoDict valueForKey:kDocumentsDownloadKeyFileId];
    NSInteger row = [[_attachmentIdIndexDictionary valueForKey:attachmentId] integerValue];
    AttachmentTXModel *attachmentModel = [imagesAndVideosArray objectAtIndex:row];
    NSIndexPath *indexPathToRefresh = [NSIndexPath indexPathForRow:row inSection:0];
    NSInteger errorCode = [[downloadInfoDict valueForKey:kDocumentsDownloadKeyErrorCode] integerValue];
    if (errorCode != AttachmentDownloadErrorUserForceQuit &&
        errorCode != AttachmentDownloadErrorUserCancelled)
    {
        attachmentModel.errorCode = errorCode;
        attachmentModel.errorMessage = [AttachmentUtility getAttachmentAPIErrorMessage:(int)errorCode];
        [imagesAndVideosArray replaceObjectAtIndex:row withObject:attachmentModel];
        //TODO : Update database attachment error table
    }
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
    editProcessHeaderLabel.text=[NSString stringWithFormat:@"%ld Items Selected",(long)selectedItems];
}

- (IBAction)cancelAction:(UIButton *)sender
{
    for (AttachmentTXModel *attachmentModel in imagesAndVideosArray)
    {
        attachmentModel.isSelected = NO;
    }
    [_selectedImagesAndVideosArray removeAllObjects];
    [self updateShareAndDeleteButton];
    imageAndVideoView.hidden = NO;
    editProcessHeaderView.hidden = YES;
    [self.collectionView reloadData];
}

- (IBAction)shareAction:(UIButton *)sender
{
    if (self.shareButton.isSelected) {
        
        NSMutableArray *urlItemsArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (AttachmentTXModel *shareModel in _selectedImagesAndVideosArray)
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

- (IBAction)deleteAction:(UIButton *)sender
{
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
    
    if ([imagesAndVideosArray containsObject:attachment]) {
        [imagesAndVideosArray removeObject:attachment];
    }
    if ([_selectedImagesAndVideosArray containsObject:attachment]) {
        [_selectedImagesAndVideosArray removeObject:attachment];
    }
    
}

- (void)updateShareAndDeleteButton
{
    [self refreshHeaderTitle:[_selectedImagesAndVideosArray count]];
    if ([_selectedImagesAndVideosArray count])
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
    
    if (alertView == _cancelDownloadAlert) {
        
        if (buttonIndex != [alertView cancelButtonIndex])
        {
            AttachmentTXModel *cancelModel = [imagesAndVideosArray objectAtIndex:_cancelDownloadAlert.tag];
            [_downloadManager cancelDownloadWithId:cancelModel.localId];
        }
        
    }
    
    if (alertView.tag == kDeleteButton) {
        
        if (buttonIndex != [alertView cancelButtonIndex])
        {
            NSMutableArray *localIdsToDelete = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray *modifiedArray = [[NSMutableArray alloc] initWithCapacity:0];
            
            for (AttachmentTXModel *deleteModel in _selectedImagesAndVideosArray)
            {
                if (![_uploadManager isFileUploading:deleteModel.localId])
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
                        
                        [localIdsToDelete addObject:deleteModel.localId];
                        [_uploadManager deleteFileFromQueue:deleteModel.localId];
                        
                        if ([imagesAndVideosArray containsObject:deleteModel]) {
                            [imagesAndVideosArray removeObject:deleteModel];
                            
                        }
                        
                    }
                    else {
                        //TODO: handle error
                    }

                }
                else
                {
                    NSString *ok = [[TagManager sharedInstance] tagByName:kTagAlertErrorOk];
                    if (![ok length]) {
                        ok = @"Ok";
                    }
                    
                    [[AlertMessageHandler sharedInstance] showCustomMessage:[NSString stringWithFormat:@"%@ \n %@",kAttachmentUnableDelete, deleteModel.name] withDelegate:nil tag:0 title:[[TagManager sharedInstance] tagByName:kTagAlertApplicationError] cancelButtonTitle:ok andOtherButtonTitles:nil];
                }
                
            }
            [AttachmentHelper deleteAttachmentsWithLocalIds:localIdsToDelete];
            [AttachmentHelper saveDeleteAttachmentsToModifiedRecords:modifiedArray];
            [_selectedImagesAndVideosArray removeAllObjects];
            [self.collectionView reloadData];
            [self updateShareAndDeleteButton];
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

#pragma mark-
#pragma AttachmentSharing options

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

#pragma mark -
#pragma mark === UIImagePicker and Add Image, Video Related ===
#pragma mark -

- (IBAction) showimagePicker:(UIButton*)button
{
    [self hideAttachmentPopover];
    [popoverController setPopoverContentSize:CGSizeMake(300.0f, 119.0f)];
    popoverController.contentViewController.view.backgroundColor = [UIColor colorWithHexString:kActionBgColor];
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
    
    if(selectedIndex == ImagePickerOptionFromCameraRoll)
    {
        [self startCameraControllerFromViewControllerisImageFromCamera:NO isVideoMode:NO];
    }
    else
    {
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        
        if (status != ALAuthorizationStatusAuthorized)
        {
            
            if (selectedIndex == ImagePickerOptionNewPicture)
            {
                [self startCameraControllerFromViewControllerisImageFromCamera:NO isVideoMode:NO];
            }
            else if(selectedIndex == ImagePickerOptionNewVideo)
            {
                [self startCameraControllerFromViewControllerisImageFromCamera:NO isVideoMode:NO];
            }
            
        } else {
            
            if (selectedIndex == ImagePickerOptionNewPicture)
            {
                [self startCameraControllerFromViewControllerisImageFromCamera:YES isVideoMode:NO];
            }
            else if(selectedIndex == ImagePickerOptionNewVideo)
            {
                
                [self startCameraControllerFromViewControllerisImageFromCamera:YES isVideoMode:YES];
            }
        }
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
        [self presentViewController:self.cameraViewController animated:YES completion:nil];
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
    UIImage * originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //TO FIX orientation incase of portrait.
    
    originalImage = [originalImage fixOrientation];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    /** Pushpak
     * defect 10742
     * resolution of image was getting spoilt due to trimming, solution was to remove trimming as salesforce limit is raised from 5mb to 25 mb
     */
    //UIImage * trimmedImage= [self scaleImage:originalImage toSize:CGSizeMake(900,600)];
    NSData *dataToSaveFromImage = UIImagePNGRepresentation(originalImage);
    
    if([mediaType isEqualToString:@"public.movie"])
    {
        //@"VIDEO"
        picker.view.userInteractionEnabled = NO;
        [self videoCaptured:videoURL isCaptured:!isVideoTaken picker:picker];
    }
    else if([mediaType isEqualToString:@"public.image"])
    {
        if([info objectForKey:UIImagePickerControllerReferenceURL] == nil)
        {
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            UIImageWriteToSavedPhotosAlbum(image,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
        }
        
        if(self && [self respondsToSelector:@selector(dataFromCapturedImage:)]) {
            [self performSelector:@selector(dataFromCapturedImage:) withObject:dataToSaveFromImage];
        }
        //@"camera"
    }
    
    [self hideImagePickerPopover];
    
}

- (void) dataFromCapturedImage:(NSData *)capturedImageData {
    
    NSString *local_id = [AppManager generateUniqueId];
    bool canAttach = [AttachmentUtility canAttachthisfile:capturedImageData type:@".png"];
    if(canAttach)
    {
        [AttachmentUtility writeAttachmentToDocumentDirectory:capturedImageData localId:local_id withExt:@".png"];

        //TODO: update model and save it to database
        [self saveAttachmentInfoDictWithId:local_id andExtension:@".png"];
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
    NSString *local_id = [AppManager generateUniqueId];
    NSString *outputPath = [AttachmentUtility pathToAttachmentfile:local_id withExt:@".mov"];
    NSURL *outputUrl = [NSURL fileURLWithPath:outputPath];
    NSData *databeforeCompres = [NSData dataWithContentsOfURL:inputPathURL];
    NSUInteger sizebeforeCompression = [databeforeCompres length];
    float sizeinMB = (1.0 *sizebeforeCompression)/1048576;
    
    if (sizeinMB > 25) {
        
        [self convertVideoToLowQualityWithInputURL:inputPathURL outputURL:outputUrl successHandler:nil failureHandler:nil];
        
        while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, 1.0f, NO))
        {
            //@"Compressing video"
            
            if(_compressionCompleted == YES)
            {
                break;
            }
        }
        // Video under upload limit check
        NSData *dataAfterCompres = [NSData dataWithContentsOfURL:outputUrl];
        BOOL canAttach= [AttachmentUtility canAttachthisfile:dataAfterCompres type:@".mov"];
        // Adding details to dict
        if(canAttach)
        {
            [self saveAttachmentInfoDictWithId:local_id andExtension:@".mov"];
        }
    }
    else {
        
        if([[NSFileManager defaultManager] fileExistsAtPath:[outputUrl path]])
            [[NSFileManager defaultManager] removeItemAtURL:outputUrl error:nil];
        [[NSFileManager defaultManager] createFileAtPath:[outputUrl path] contents:databeforeCompres attributes:nil];
        [self saveAttachmentInfoDictWithId:local_id andExtension:@".mov"];
        
    }
    picker.view.userInteractionEnabled = TRUE;
    [self hideImagePickerPopover];
    
}

-(void)saveAttachmentInfoDictWithId:(NSString*)localId andExtension:(NSString*)extension
{
    AttachmentTXModel *attachmentModel = [[AttachmentTXModel alloc] init];
    attachmentModel.localId = localId;
    attachmentModel.extensionName = extension;
    attachmentModel.name = [AttachmentUtility generateAttachmentNamefor:_parentObjectName extension:extension];
    attachmentModel.nameWithoutExtension = [attachmentModel.name stringByDeletingPathExtension];
    attachmentModel.lastModifiedDate = [DateUtil getDatabaseStringForDate:[NSDate date]];
    attachmentModel.displayDateString = [DateUtil getDateStringForDBDateTime:attachmentModel.lastModifiedDate inFormat:kDateImagesAndVideosAttachment];
    attachmentModel.parentId = self.parentId;
    attachmentModel.isPrivate = @"False";
    attachmentModel.isDownloaded = YES;
    if ([_downloadManager.imgDict valueForKey:extension])
    {
        attachmentModel.thumbnailImage = [AttachmentUtility scaleImage:[AttachmentUtility filePathForAttachment:attachmentModel] toSize:CGSizeMake(170.0f, 170.0f)];
    }
    if ([_downloadManager.videoDict valueForKey:extension]) {
        UIImage *videoImage = [AttachmentUtility getThumbnailImageForFilePath:[AttachmentUtility filePathForAttachment:attachmentModel]];
        attachmentModel.thumbnailImage = [UIImage scaleImage:videoImage toSize:CGSizeMake(170.0f, 170.0f)];
        attachmentModel.isVideo = YES;
    }
    [imagesAndVideosArray insertObject:attachmentModel atIndex:0];
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
            _compressionCompleted = YES;
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
    [self.cameraViewController dismissViewControllerAnimated:YES completion:nil];
    if(self.popoverImagePickerController)
    {
        [self.popoverImagePickerController dismissPopoverAnimated:YES];
    }
    [self.collectionView reloadData];
}

@end
