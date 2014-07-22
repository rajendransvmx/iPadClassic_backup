//
//  ImageCollectionView.m
//  ServiceMaxMobile
//
//  Created by Sahana on 07/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import "ImageCollectionView.h"
#import "SFMPageController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "AttachmentUtility.h"
#import "DataBaseGlobals.h"
#import "Globals.h"
#import "Utility.h" //9196

/*Accessibility Changes*/
#import "AccessibilityAttachmentConstants.h"
#import "UIImage+FixOrientation.h"

@interface ImageCollectionView ()

//11429
@property (retain, nonatomic) IBOutlet UILabel *selectItemsCount;
@property (retain, nonatomic)IBOutlet UILabel *itemLabel;

-(void)reloadCollectionView;
- (IBAction)EditList:(id)sender;
-(NSDictionary *)getDictionaryForindexpath:(NSIndexPath *)indexPath;
-(void)fillImageDataAtIndexPath:(NSIndexPath *)indexPath collectionViewcell:(imageCollectionViewCell *)cell initiateViews:(BOOL)initiateViews;
-(NSString *)getDocumentFileName:(NSIndexPath *)indexPath;
-(void)hideEditbuttons:(BOOL)hide;
-(void)hideAttachmentBuutons:(BOOL)hide;
@property (nonatomic) BOOL multipleSelection;
-(void)videoCaptured:(NSURL*)path isCaptured:(BOOL)isCaptured picker:(UIImagePickerController *)picker;
-(IMAGE_CELL_TYPE)getImageType:(NSIndexPath *)indexPath attachmentStatus:(ATTACHMENT_STATUS)attachmentStatus;
- (void)loadProgressBars;

@end

@implementation ImageCollectionView
@synthesize title_label;
@synthesize deletedList;
@synthesize EditList;
@synthesize Sfmdelegate;
@synthesize imageViewDelegate;
@synthesize attachButton,compressionCompleted;
@synthesize isViewMode;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
             [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInternetConnectionChange:) name:kInternetConnectionChanged object:nil];
        [self addAttachmentDownloadObserver];
            }
    return self;
}
- (void) didInternetConnectionChange:(NSNotification *)notification
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber * currentReach = (NSNumber *) notification.object;
    BOOL isReachable = [currentReach boolValue];
    if (isReachable)
    {
        SMLog(kLogLevelVerbose,@"DetailViewController Internet Reachable");
    }
    else
    {
        SMLog(kLogLevelVerbose,@"DetailViewController Internet Not Reachable");
    }
    [self.CollectionView reloadData];
}


- (void) shouldShowCameraPopover:(BOOL) status
{
    [self.attachButton setHidden:status];
    [self.addIcon setHidden:status];
//    [self.EditList setHidden:status]; //D-00003728
}
- (void) setIsViewMode:(BOOL)newMode
{
    isViewMode = newMode;
    [self.EditList setHidden:NO]; //D-00003728
    [self shouldShowCameraPopover:newMode];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*Accessibility Changes*/
    if (self.isViewMode)
    {
        [self setAccessibilityIdentifierForInstanceVariable:NO];
    }
    else
    {
        [self setAccessibilityIdentifierForInstanceVariable:YES];
    }
    
    
    self.multipleSelection = FALSE;
    compressionCompleted = NO;
    [self.CollectionView registerClass:[imageCollectionViewCell class] forCellWithReuseIdentifier:@"FlickrCell"];
    self.CollectionView.backgroundColor = [UIColor whiteColor];
    self.CollectionView.allowsMultipleSelection = NO;
    // Do any additional setup after loading the view from its nib.
     [self hideEditbuttons:TRUE];
    [self shouldShowCameraPopover:isViewMode];
    [self clearSelectedData]; //Defect 11352
    
    attachmentPopoverController = [[AttachmentPopoverViewController alloc] initWithNibName:@"AttachmentPopoverViewController" bundle:nil];
    popoverController = [[UIPopoverController alloc] initWithContentViewController:attachmentPopoverController];
    attachmentPopoverController.view.frame=CGRectMake(0, 0, 50, 50);
    
    NSString *addFromCamera = [appDelegate.wsInterface.tagsDictionary objectForKey:ADD_FROM_CAMERA];
    NSString *takeNewPicture = [appDelegate.wsInterface.tagsDictionary objectForKey:TAKE_NEW_PIC];
    NSString *takeNewVideo = [appDelegate.wsInterface.tagsDictionary objectForKey:TAKE_NEW_VIDEO];
    
    attachmentPopoverController.popoverArray=[NSArray arrayWithObjects:addFromCamera,takeNewPicture,takeNewVideo, nil];
    attachmentPopoverController.attachmentDelegate=self;
    attachmentPopoverController.view.backgroundColor=[UIColor clearColor];
	//defect #9224
    //self.view.backgroundColor =[UIColor clearColor];
    
    NSString *cancel=[appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON];
    NSString *addImagetitle=[NSString stringWithFormat:@"%@",[appDelegate.wsInterface.tagsDictionary objectForKey:ADD_PHOTO_VIDEO]]; //D-00003728
    

    NSString *delete=[appDelegate.wsInterface.tagsDictionary objectForKey:DELETE_BUTTON_TITLE];//9211

    title_label.text=[appDelegate.wsInterface.tagsDictionary objectForKey:PHOTOS_VIDEOS];
    
    title_label.backgroundColor = [UIColor clearColor];
    title_label.textColor = [appDelegate colorForHex:@"2d5d83"];// [UIColor whiteColor];
    
    title_label.font = [UIFont boldSystemFontOfSize:16];

    //D-00003728
    [attachButton setTitle:addImagetitle forState:UIControlStateNormal];
    attachButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    attachButton.highlighted = NO;
    [attachButton setTitleColor:[appDelegate colorForHex:@"157DFB"] forState:UIControlStateNormal];
    
    [_cancel setTitle:cancel forState:UIControlStateNormal];
    
    //D-00003728
    [EditList setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:EDIT_LIST] forState:UIControlStateNormal];
    EditList.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    EditList.highlighted = NO;
    [EditList setTitleColor:[appDelegate colorForHex:@"157DFB"] forState:UIControlStateNormal];
    
//    [_deleteAction setTitle:delete forState:UIControlStateNormal];
    
    if (self.attachmentProgressBarsDictionary == nil) {
        [self loadProgressBars];
    }
    
    //defect #9101
    [self handlingEditButtonStatus];
    
    //defect #9224
     self.view.backgroundColor = [UIColor whiteColor];
    
     [self hideSelectItemLabel:YES]; //11429

}

/*Accessibility Changes*/
- (void) setAccessibilityIdentifierForInstanceVariable:(BOOL)element
{
    if (!element)
    {
        [attachButton setAccessibilityIdentifier:nil];
        [_deleteAction setAccessibilityIdentifier:nil];
        [_cancel setAccessibilityIdentifier:nil];
        [EditList setAccessibilityIdentifier:nil];
    }
    else
    {
       attachButton.isAccessibilityElement = element;
       [attachButton setAccessibilityIdentifier:kAccAttach];
              
       _deleteAction.isAccessibilityElement = element;
       [_deleteAction setAccessibilityIdentifier:kAccDeleteAttachment];
       
       _cancel.isAccessibilityElement = element;
       [_cancel setAccessibilityIdentifier:kAccCancelAttachment];
        
        EditList.isAccessibilityElement = YES;
        [EditList setAccessibilityIdentifier:kAccEditAttachment];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [self hideSelectItemLabel:YES]; //11429
     //defect #9101
    self.multipleSelection = NO;
    [self hideEditbuttons:TRUE];
    [self handlingEditButtonStatus];
    //Defect 11352
    [self shouldShowCameraPopover:isViewMode];
    [self clearSelectedData];
    [self.CollectionView reloadData];

}

 //defect #9101
-(void)enableEditButton:(BOOL)enable
{
    self.EditList.enabled = enable;
    if(!enable)
    {
        [self.EditList setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    }
}
 //defect #9101
-(void)handlingEditButtonStatus
{
    NSArray * itemsArray = [AttachmentUtility getAttachmentObjectsListofType:IMAGES_DICT dictionaryType:OBJECT_LIST];
    if([itemsArray count] > 0)
    {
        [self enableEditButton:YES];
    }
    else
    {
        if (isViewMode) //D-00003728
        {
            self.EditList.hidden = YES;
        }
        else
        {
            [self enableEditButton:NO];
        }
    }
}

- (void)dismissImagePickerView {
    [self.CollectionView reloadData];
    [imageViewDelegate dismissImageView];
}

- (void) dataFromCapturedImage:(NSData *)capturedImageData {

    // Mem_leak_fix - Vipindas 9493 Jan 18
    NSString *local_id = [[AppDelegate GetUUID] retain];
    [AttachmentUtility writeAttachmentToDocumentDirectory:capturedImageData localId:local_id withExt:@"png"];
     bool canAttach= [AttachmentUtility canAttachthisfile:capturedImageData type:IMAGES_DICT];
    if(canAttach)
    {
        NSMutableDictionary *attachmentInfo=[[NSMutableDictionary alloc]init];
        [attachmentInfo setObject:IMAGES_DICT forKey:@"AttachmentType"];
        [attachmentInfo setObject:NEW_ATTACHMENT forKey:@"Operation"];
        [attachmentInfo setObject:local_id forKey:@"local_id"];
        [attachmentInfo setObject:@"png" forKey:@"Extension"];
        [AttachmentUtility attachmentDictonary:attachmentInfo];
    }
    [self dismissImagePickerView];
    [local_id release];

}

-(void)videoCaptured:(NSURL*)path isCaptured:(BOOL)isCaptured picker:(UIImagePickerController *)picker
{
    // Mem_leak_fix - Vipindas 9493 Jan 18
    NSString *local_id=[[AppDelegate GetUUID] retain];
    NSString *outputPath= [AttachmentUtility pathToAttachmentfile:local_id withExt:@"mov"];
    NSURL *outputUrl=[NSURL fileURLWithPath:outputPath];
    NSData *databeforeCompres = [NSData dataWithContentsOfURL:path];
    NSUInteger sizebeforeCompression = [databeforeCompres length];
    int aspectRatio=20;
    if(isCaptured)
        aspectRatio=5;
    float sizeinMB = (1.0 *sizebeforeCompression)/1048576;
    int limit=sizeinMB/aspectRatio;
    
    NSString *Title=[appDelegate.wsInterface.tagsDictionary objectForKey:alert_application_error];
    
    NSString *error_message=[appDelegate.wsInterface.tagsDictionary objectForKey:LARGE_VIDEO_WARNING];//@"This video is too large. Video may not exceed 30 sec in length";
    /** Pushpak
     * attachment limit raised from 5mb to 25 mb limit.
     */
    if(limit > 25)
    {
        [AttachmentUtility alert:Title message:error_message];
        [self dismissImagePickerView];
        return;
    }
    
    [self convertVideoToLowQualityWithInputURL:path outputURL:outputUrl successHandler:nil failureHandler:nil];
    
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
        SMLog(kLogLevelVerbose,@"Compressing video");
        
        if(compressionCompleted == YES)
        {
            break;
        }
    }
  
    // Video under upload limit check
    NSData *dataAfterCompres = [NSData dataWithContentsOfURL:outputUrl];
    BOOL canAttach= [AttachmentUtility canAttachthisfile:dataAfterCompres type:@"Videos"];
    // Adding details to dict
    if(canAttach)
    {
        NSMutableDictionary *attachmentInfo=[[NSMutableDictionary alloc]init];
        [attachmentInfo setObject:IMAGES_DICT forKey:@"AttachmentType"];
        [attachmentInfo setObject:NEW_ATTACHMENT forKey:@"Operation"];
        [attachmentInfo setObject:local_id forKey:@"local_id"];
        [attachmentInfo setObject:@"mov" forKey:@"Extension"];
        [AttachmentUtility attachmentDictonary:attachmentInfo];
    }
    picker.view.userInteractionEnabled = TRUE;
    [self dismissImagePickerView];
    
    // Mem_leak_fix - Vipindas 9493 Jan 18
    [local_id release];
}
- (void)convertVideoToLowQualityWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL successHandler:(void (^)())successHandler failureHandler:(void (^)(NSError *))failureHandler {
    if([[NSFileManager defaultManager] fileExistsAtPath:[outputURL path]]) [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            compressionCompleted = YES;
            SMLog(kLogLevelVerbose,@"Success");
        } else {
            SMLog(kLogLevelVerbose,@"%ld,%@",(long)exportSession.status,exportSession.error);
            SMLog(kLogLevelVerbose,@"Failed");
            [self dismissImagePickerView];
        }
    }];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    NSMutableArray * itemsArray = [AttachmentUtility getAttachmentObjectsListofType:IMAGES_DICT dictionaryType:OBJECT_LIST];
    return [itemsArray count];
}
// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   imageCollectionViewCell *cell = (imageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"FlickrCell" forIndexPath:indexPath];

    if(cell != nil)
    {
        NSArray *subViews = [cell subviews];
        for(UIView *subView in subViews)
        {
            [subView removeFromSuperview];
        }
        for(UIImageView *subView in subViews)
        {
            [subView removeFromSuperview];
        }
        
    }
    ATTACHMENT_STATUS attachmentStatus = [self getAttachmentStatus:indexPath];
   // [cell setBackgroundColor: [UIColor blueColor]];
    IMAGE_CELL_TYPE celltype = [self getImageType:indexPath attachmentStatus:attachmentStatus];
    
    
    [self fillImageDataAtIndexPath:indexPath collectionViewcell:cell initiateViews:NO];
    [cell fillCollectionviewcell:celltype];
    [self fillImageDataAtIndexPath:indexPath collectionViewcell:cell initiateViews:YES];
    if(self.multipleSelection )
    {
        if(attachmentStatus != ATTACHMENT_STATUS_YET_TO_DOWNLOAD && attachmentStatus != ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS && attachmentStatus != ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE && attachmentStatus != ATTACHMENT_STATUS_ERROR_IN_DOWNLOAD)//9212
        {
            if([self isItemAvailable:cell.localId]){
                [cell highlightcellForDeletion];
            }
            else
            {
                [cell UnhighlightcellFromDeletion];
                [self updateItemLabelText:[appDelegate.wsInterface.tagsDictionary objectForKey:SELECTITEMS]]; //11429
            }
        }
        else if (attachmentStatus == ATTACHMENT_STATUS_YET_TO_DOWNLOAD) //D-00003728
        {
            [self hideAttachemtForCell:cell];
        }
    }
    /*Adding pg view*/
    [self handleProgressBarToCell:cell withStatus:attachmentStatus andDictionary:[self getDictionaryForindexpath:indexPath]];
    //9212
    [self handleErrorForCell:cell withAttachment:[self getDictionaryForindexpath:indexPath] andStatus:attachmentStatus];
    return cell;
}
-(NSDictionary *)getDictionaryForindexpath:(NSIndexPath *)indexPath
{
    NSArray * itemsArray = [AttachmentUtility getAttachmentObjectsListofType:IMAGES_DICT dictionaryType:OBJECT_LIST];
    NSDictionary * dict = [itemsArray objectAtIndex:indexPath.row];
    return dict;
}
- (BOOL) isItemAvailable:(NSString *)localID
{
    return [self.deletedList containsObject:localID];   
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
   
    if(!self.multipleSelection)
    {
       // IMAGE_CELL_TYPE cellType = [self getImageType:indexPath attachmentStatus:<#(ATTACHMENT_STATUS)#>];
        NSArray * itemsArray = [AttachmentUtility getAttachmentObjectsListofType:IMAGES_DICT dictionaryType:OBJECT_LIST];
        NSDictionary * dict = [itemsArray objectAtIndex:indexPath.row];
        NSString * attachmentId = [dict objectForKey:K_ATTACHMENT_ID];
        NSString * fileName = [dict objectForKey:K_NAME];
        
        ATTACHMENT_STATUS attachmentStatus = [AttachmentUtility getAttachmentStaus:dict];
        if(attachmentStatus ==  ATTACHMENT_STATUS_EXISTS) {
             [imageViewDelegate displayAttachment:attachmentId fielName:fileName];
        }
        else if (attachmentStatus == ATTACHMENT_STATUS_YET_TO_DOWNLOAD){
            [self  downloadAttachment:dict];
            imageCollectionViewCell * cell = ( imageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
            [self handleProgressBarToCell:cell withStatus:ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS andDictionary:dict];
        }
        else if(attachmentStatus == ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS || attachmentStatus == ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE){
            
            self.selectAttachmentForCancel = dict;
            NSString *confirmationMessage = @"Are you sure you want to cancel the download?";
            //Download is in que. Cannot take any action as of now
            [self showAlertForCancelConfirmationAlert:fileName andMessage:confirmationMessage];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{

     if(self.multipleSelection)
     {
         
         imageCollectionViewCell * cell = ( imageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
         
         //IMAGE_CELL_TYPE cellType = [self getImageType:indexPath];
          ATTACHMENT_STATUS attachmentStatus = [AttachmentUtility getAttachmentStaus:[self getDictionaryForindexpath:indexPath]];
       //  IMAGE_CELL_TYPE cellType = [self getImageType:indexPath attachmentStatus:attachmentStatus];
         if(attachmentStatus != ATTACHMENT_STATUS_YET_TO_DOWNLOAD && attachmentStatus != ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS && attachmentStatus != ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE && attachmentStatus != ATTACHMENT_STATUS_ERROR_IN_DOWNLOAD  &&  attachmentStatus != ATTACHMENT_STATUS_UPLOAD_IN_PROGRESS)//9212 
         {
             [self enableDelete:YES];
             [self enableShare:YES]; //D-00003728
             BOOL deleted = [cell select];
             if(deleted)
             {
                 [self.deletedList addObject:cell.localId];
                 //D-00003728
                 NSString * fileName = [self getDocumentFileName:indexPath];
                 if (fileName != nil && [fileName length] > 0)
                 {
                    NSString * attachmentName = [self getFileName:indexPath];

                    //Defect 11338
                    if (attachmentName != nil)
                    {
                        [self.sharingAttachmentList setValue:attachmentName forKey:cell.localId];//Defect 11338
                    }
                 }
             }
             else
             {
                 if([self.deletedList containsObject:cell.localId])
                 {
                     [self.deletedList removeObject:cell.localId];
                 }
                 if ([self.sharingAttachmentList count] > 0) //D-00003728
                 {
                     [self.sharingAttachmentList removeObjectForKey:cell.localId]; 
                 }
             }
//             [cell UnhighlightcellFromDeletion];
         }
         //defect #9101
         if([self.deletedList count] > 0)
         {
             [self setDeleteImage:@"iOS-Trash-Can-Blue.png"];
             [self enableDelete:YES];
             
         }
         if ([self.sharingAttachmentList count] > 0)
         {
             [self setShareImage:@"iOS-Share-Blue.png"];
             [self enableShare:YES]; //D-00003728
         }
         if ([self.deletedList count] > 0 || [self.sharingAttachmentList count] > 0) //11429
         {
             [self updateItemLabelText:[appDelegate.wsInterface.tagsDictionary objectForKey:ITEMSELECTED]];
             [self updateSelectItemCount:[self.deletedList count]];
         }
         else if (([self.deletedList count] == 0 || [self.sharingAttachmentList count] == 0) //11429
                  && (self.share.userInteractionEnabled || self.deleteAction.userInteractionEnabled) )
         {
             [self updateEmptyTextToSelectItemCount];
             [self updateItemLabelText:[appDelegate.wsInterface.tagsDictionary objectForKey:SELECTITEMS]];
         }
         else
         {
             [self setDeleteImage:@"iOS-Trash-Can-Gray.png"];
              [self enableDelete:NO];
             [self setShareImage:@"iOS-Share-Gray.png"];
             [self enableShare:NO]; //D-00003728
         }
            
         
     }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize retval = CGSizeMake(225, 203);
    return retval;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
     return UIEdgeInsetsMake(10, 10,10, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    
    return 3.0;
}
- (void)dealloc {
    [self removeAttachmentDownloadObserver];
    [_CollectionView release];
    [popoverController release];
    [attachButton release];
    [_collectionviewFlowLayout release];
    [EditList release];
    [_deleteAction release];
    [_cancel release];
    [title_label release];
    [_share release];
    [_sharingAttachmentList release]; //D-00003728
    [_addIcon release];
    [super dealloc];
}

- (UIEdgeInsets)insetsForItemAtIndexPath:(NSIndexPath *)indexPath {
    return UIEdgeInsetsMake(2, 2, 5, 2);

}


-(void)fillImageDataAtIndexPath:(NSIndexPath *)indexPath collectionViewcell:(imageCollectionViewCell *)cell initiateViews:(BOOL)initiateViews
{
    NSArray * itemsArray = [AttachmentUtility getAttachmentObjectsListofType:IMAGES_DICT dictionaryType:OBJECT_LIST];
    NSDictionary * dict = [itemsArray objectAtIndex:indexPath.row];
    
    if(initiateViews)
    {
        NSString * lastModf = [AttachmentUtility getDate:[dict objectForKey:K_LASTMODIFIEDDATE] withFormat:ATTACHMENT_DATE_FORMAT];
        cell.lastModifiedDate.text =  lastModf;
        cell.fileName.text = [dict objectForKey:K_NAME];
        NSString *attachmentSize = [dict valueForKey:K_SIZE];
        NSString * size_text = @"";
        if(attachmentSize != nil)
        {
            size_text = [Utility formattedFileSizeForAttachment:[attachmentSize longLongValue]];//9196
            //[NSString stringWithFormat:@"%@MB",[AttachmentUtility getFormattedSize:attachmentSize]];;
        }
        cell.fileSize.text = size_text;
    }
    else
    {
        cell.localId = [dict objectForKey:K_ATTACHMENT_ID];
        cell.Attachmentsf_id = [dict objectForKey:K_ATTACHMENT_SFID];
        NSString * extension =  [AttachmentUtility fileExtension:[dict objectForKey:K_NAME]];
        cell.fileType =[AttachmentUtility getFileType:extension];
        cell.DocumentName = [self getDocumentFileName:indexPath];
    }
}

- (ATTACHMENT_STATUS)getAttachmentStatus:(NSIndexPath *)indexPath
{
    NSString * documentName = [self getDocumentFileName:indexPath];
    NSArray * itemsArray = [AttachmentUtility getAttachmentObjectsListofType:IMAGES_DICT dictionaryType:OBJECT_LIST];
    NSDictionary * dict = [itemsArray objectAtIndex:indexPath.row];
    NSString * attachmentId = [dict objectForKey:K_ATTACHMENT_ID];

    ATTACHMENT_STATUS status = [AttachmentUtility getAttachmentStaus:dict];
    if([AttachmentUtility doesFileExists:documentName])
    {
        return ATTACHMENT_STATUS_EXISTS;
    }
    else if([AttachmentUtility ErrorInDownloading:attachmentId])
    {
        return ATTACHMENT_STATUS_ERROR_IN_DOWNLOAD;
    }
    return status;
}

-(IMAGE_CELL_TYPE)getImageType:(NSIndexPath *)indexPath attachmentStatus:(ATTACHMENT_STATUS)attachmentStatus
{
    
    if(attachmentStatus == ATTACHMENT_STATUS_EXISTS)
    {
        return IMAGE_EXISTS;
    }
    else if(attachmentStatus == ATTACHMENT_STATUS_YET_TO_DOWNLOAD)
    {
        return DOWNLOAD_IMAGE;
    }
    else if(attachmentStatus == ATTACHMENT_STATUS_ERROR_IN_DOWNLOAD)
    {
        return ERROR_IN_DOWNLOAD;
    }
    return DOWNLOAD_IMAGE;
}


-(NSString *)getDocumentFileName:(NSIndexPath *)indexPath
{
    NSArray * itemsArray = [AttachmentUtility getAttachmentObjectsListofType:IMAGES_DICT dictionaryType:OBJECT_LIST];
    NSDictionary * dict = [itemsArray objectAtIndex:indexPath.row];
    NSString * attachmentId = [dict objectForKey:K_ATTACHMENT_ID];
    NSString * fileName = [dict objectForKey:K_NAME];
    NSString * extension = [AttachmentUtility fileExtension:fileName];
    NSString *objectName=@"";
    objectName  = appDelegate.sfmPageController.objectName;
    NSString * documentName = [AttachmentUtility fileName:attachmentId extension:extension];
    return documentName;
}

#pragma mark - UIImagePickerController delegates
#pragma mark

/**< For responding to the user tapping Cancel. */
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [self.CollectionView reloadData];

    [imageViewDelegate dismissImageView];
}

#define capture_time 30;
- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo:(NSDictionary *) info {
    
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

    picker.videoQuality=UIImagePickerControllerQualityTypeMedium;
    picker.videoMaximumDuration=capture_time;
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
        SMLog(kLogLevelVerbose,@"VIDEO");
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
        SMLog(kLogLevelVerbose,@"camera");
    }

    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if(error)
    {
        [appDelegate CustomizeAletView:error alertType:APPLICATION_ERROR Dict:Nil exception:nil];
        SMLog(kLogLevelError,@"Failed to save image");
    }
}
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    //Do required stuff.
    if(error)
    {
        [appDelegate CustomizeAletView:error alertType:APPLICATION_ERROR Dict:Nil exception:nil];
        SMLog(kLogLevelError,@"Failed to save video");

    }
}
#pragma popover implementation

- (IBAction)showPopover:(UIButton *)sender
{
    if ([popoverController isPopoverVisible]) {
        [popoverController dismissPopoverAnimated:YES];
    } else {
        //the rectangle here is the frame of the object that presents the popover,
        //in this case, the UIButton…
        CGRect popRect = CGRectMake(self.attachButton.frame.origin.x,
                                    self.attachButton.frame.origin.y,
                                    self.attachButton.frame.size.width,
                                    self.attachButton.frame.size.height);
        CGSize popoverSize=CGSizeMake(230,125);
        [popoverController setPopoverContentSize:popoverSize];
        [popoverController presentPopoverFromRect:popRect
                                           inView:self.view
                         permittedArrowDirections:UIPopoverArrowDirectionUp
                                         animated:YES];
    }
}
#pragma popover end

-(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (IBAction)cancelDeletion:(id)sender
{
    if(isViewMode) //D-00003728
    {
       [self enableViewModeButton:YES];
        self.multipleSelection = FALSE;
    }
    else
    {
        [self hideAttachmentBuutons:FALSE];
        [self hideEditbuttons:TRUE];
    }
    [self.deletedList removeAllObjects];
    [self.sharingAttachmentList removeAllObjects];
    [self refreshSelectitems]; //11429
    [self.CollectionView reloadData];
   
}

- (IBAction)performDeletion:(id)sender
{
    [self hideAttachmentBuutons:FALSE];
    [self hideEditbuttons:TRUE];
    [AttachmentUtility conformationforDelete:self];
   
}

//D-00003728
- (IBAction)shareAttachment:(id)sender
{
    if (isViewMode)
    {
        [self enableViewModeButton:YES];
        self.multipleSelection = FALSE;
    }
    else
    {
        [self hideAttachmentBuutons:FALSE];
        [self hideEditbuttons:TRUE];
    }
    if ([Utility notIOS7])
    {
        self.share.hidden = NO;
    }
    
    if ([self.sharingAttachmentList count] > 0)
    {
        //Defect 11338
        [self createDuplicateAttachmentFile:self.sharingAttachmentList];
        NSArray * urls = [[self getAttachemntUrlsForSharing:[self.sharingAttachmentList allValues]] retain];
        if ([imageViewDelegate conformsToProtocol:@protocol(ImageViewControllerDelegate)])
        {
            [imageViewDelegate displayAttachmentSharingView:urls viewName:COLLECTIONVIEW sender:(UIButton *)sender];
        }
        [urls release];
    }
    [self.deletedList removeAllObjects];
}

//Defect 11338
- (void)deleteAttachmetFiles
{
    if ([self.sharingAttachmentList count] > 0)
    {
       SMLog(kLogLevelVerbose,@"Images/Vidoes Slected to share = %@", [self.sharingAttachmentList allValues]);
        NSArray * array = [self.sharingAttachmentList allValues];
        [self deleteDuplicateAttachmentsCreated:array];
    }
    [self.sharingAttachmentList removeAllObjects];
     self.share.hidden = YES
    ;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Start 009139
    if (alertView.tag == DOWNLOAD_CANCEL_ALERT) {
        if(buttonIndex == 0){
            [self  cancelDownloadForAttachment:self.selectAttachmentForCancel];
        }
        self.selectAttachmentForCancel = nil;
    }
    else {
        
        if(buttonIndex == 1) //D-00003728
        {
            [AttachmentUtility deleteIdsFromAttachmentlist:self.deletedList forType:IMAGES_DICT];
            [self handlingEditButtonStatus];
            [self.deletedList removeAllObjects];
            [self.sharingAttachmentList removeAllObjects]; //D-00003728
            [self refreshSelectitems]; //11429
            [self.CollectionView reloadData];
        }
        /*else if(buttonIndex == 2) //D-00003728
        {
            // Vipin - 9088
            [AttachmentUtility removeSelectedAttachmentFiles:self.deletedList];
        }*/
        else if (buttonIndex == 0) //Handling Cancel funtionality
        {
            [self hideAttachmentBuutons:YES];
            [self hideEditbuttons:NO];
            [self enableDelete:YES];
            [self enableShare:YES];
        }
        
 //defect #9101
       
    }
    //End 009139
    
}

-(void)hideEditbuttons:(BOOL)hide
{
    self.deleteAction.hidden = hide;
    self.cancel.hidden = hide;
    self.multipleSelection = !hide;
    self.share.hidden = hide; //D-00003728
    [self enableDelete:NO];
    [self enableShare:NO]; //D-00003728
}
-(void)hideAttachmentBuutons:(BOOL)hide
{
    self.EditList.hidden = hide;
    self.attachButton.hidden = hide;
    self.addIcon.hidden = hide; //D-00003728
}
- (IBAction)EditList:(id)sender
{    
    self.multipleSelection = TRUE;
    [self hideAttachmentBuutons:TRUE];
    [self setShareImage:@"iOS-Share-Gray.png"];
    [self setDeleteImage:@"iOS-Trash-Can-Gray.png"];
    [self hideSelectItemLabel:NO]; //11429
    [self updateEmptyTextToSelectItemCount];
    if(isViewMode)
    {
        self.share.hidden = NO; //D-00003728
        [self enableShare:NO];
        self.cancel.hidden = NO;
    }
    else
    {
        [self hideEditbuttons:FALSE];
    }
    
    [self reloadCollectionView];
}

#pragma attachment popover delegates
-(void)selectedOption:(int)selectedAction
{
    CAPTURE_OPTION def_capture;
    
    if(selectedAction == 0)
        def_capture = IMPORT_GALLERY;
    else if (selectedAction == 1)
        def_capture = CAPTURE_IMAGES;
    else
        def_capture = CAPTURE_VIDEOS;
    
    [imageViewDelegate ButtonClick:def_capture];
    [popoverController dismissPopoverAnimated:YES];
}
- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

-(void)enableDelete:(BOOL)enable
{
//    self.deleteAction.enabled=enable;
    self.deleteAction.userInteractionEnabled = enable;
}

//D-00003728
-(void)enableShare:(BOOL)enable
{
//    self.share.enabled = enable;
    self.share.userInteractionEnabled = enable;
}

#pragma mark - Attachment Sharing
//D-00003728
-(void)enableViewModeButton:(BOOL)enable
{
    self.share.hidden = enable;
    self.EditList.hidden = !enable;
    self.EditList.enabled = enable;
    self.cancel.hidden = enable;
}

//D-00003728
- (void)hideAttachemtForCell:(imageCollectionViewCell *)cellView
{
    CGPoint viewOrigin = cellView.bounds.origin;
    CGSize viewSize = cellView.bounds.size;
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(viewOrigin.x, viewOrigin.x, viewSize.width, viewSize.height)];
    view.backgroundColor = [appDelegate colorForHex:@"E4E4E4"];
    view.alpha = 0.5;
    [cellView  addSubview:view];
    [cellView  bringSubviewToFront:view];
    [view release];
}

//D-00003728
- (void)setShareImage:(NSString *)imageName
{
    [self.share setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)setDeleteImage:(NSString *)imageName
{
    [self.deleteAction setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

//Defect 11352
- (void)clearSelectedData
{
    if(self.deletedList == nil)
    {
        self.deletedList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    else
    {
        [self.deletedList removeAllObjects];
    }
    //D-00003728
    if (self.sharingAttachmentList == nil)
    {
        self.sharingAttachmentList = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    else
    {
        [self.sharingAttachmentList removeAllObjects];
    }
}

-(NSString *)getFileName:(NSIndexPath *)indexPath
{
    NSArray * itemsArray = [AttachmentUtility getAttachmentObjectsListofType:IMAGES_DICT dictionaryType:OBJECT_LIST];
    NSDictionary * dict = [itemsArray objectAtIndex:indexPath.row];
    NSString * fileName = [dict objectForKey:K_NAME];
    return fileName;
}
//11429
- (void)hideSelectItemLabel:(BOOL)hide
{
    self.selectItemsCount.hidden = hide;
    self.itemLabel.hidden = hide;
}

- (void)updateSelectItemCount:(NSInteger)count
{
    self.selectItemsCount.text = [NSString stringWithFormat:@"%d", count];
    if (count > 1)
    {
        [self updateItemLabelText:[appDelegate.wsInterface.tagsDictionary objectForKey:ITEMSSELECTED]];
    }
}

- (void)updateEmptyTextToSelectItemCount
{
    self.selectItemsCount.text = @"";
}

- (void)hideSelectItemCount
{
    self.selectItemsCount.text = @"";
    self.selectItemsCount.hidden = YES;
}

- (void)updateItemLabelText:(NSString *)text
{
    if (![text isEqualToString:self.itemLabel.text])
    {
        self.itemLabel.text = text;
    }
}

- (void)refreshSelectitems
{
    [self updateEmptyTextToSelectItemCount];
    [self updateItemLabelText:@""];
}

#pragma mark - END

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - Adds the progress view to given cell
-(void)handleProgressBarToCell:(imageCollectionViewCell *)cellView  withStatus:(ATTACHMENT_STATUS)status andDictionary:(NSDictionary *)imageDict
{
    if (status == ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS || status == ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE) {
        NSString * attachmentId = [imageDict objectForKey:K_ATTACHMENT_ID];
        UIProgressView *pgView = [self.attachmentProgressBarsDictionary objectForKey:attachmentId];
        pgView.frame = CGRectMake(50, 55, 125, 20);
        if (pgView != nil) {
            [pgView removeFromSuperview];
            [cellView  addSubview:pgView];
            [cellView  bringSubviewToFront:pgView];
            cellView.backgroundImage.alpha = 0.3;
        }
    }
}

#pragma mark - Attachment Downlaod status hanlders - overidden methods
- (void)downloadCompleteForId:(NSString *)attachmentId {
    [super downloadCompleteForId:attachmentId];
    [self removeProgressbarForId:attachmentId];
    [AttachmentUtility deleteFromAttachmentTrailerForDownload:attachmentId];
    [self reloadCollectionView];
    
    //9182
    //Commenting below lines of code as per 9182. User will explicitely tap to open the attachment
    //009077
    //If multiple documets are tapped to download, then the last downloaded document will be presented to the user
//    if(self.view.window && (attachmentProgressBarsDictionary !=nil) && ([attachmentProgressBarsDictionary count]== 0))
//    {
//        NSMutableArray * itemsArray = [AttachmentUtility getAttachmentObjectsListofType:IMAGES_DICT dictionaryType:OBJECT_LIST];
//        NSString *fileName = nil;
//        for (NSDictionary *docDict in itemsArray) {
//            if ([[docDict valueForKey:K_ATTACHMENT_ID] isEqualToString:attachmentId]) //009197
//            {
//                fileName = [docDict valueForKey:K_NAME];
//                break;
//            }
//        }
//        [imageViewDelegate displayAttachment:attachmentId fielName:fileName];
//    }

}

- (void)downloadFailedForId:(NSString *)attachmentId withError:(NSError *)error {
    [self removeProgressbarForId:attachmentId];
    [super downloadFailedForId:attachmentId withError:error];
    [AttachmentUtility deleteFromAttachmentTrailerForDownload:attachmentId];
    [self reloadCollectionView];
}
-(void)reloadCollectionView
{
    [self.CollectionView reloadData];
}

//Start 009139
- (void)reloadViewData {
    [self reloadCollectionView];
}
//End 009139

#pragma mark -
- (void)loadProgressBars{
    
    NSArray * itemsArray = [AttachmentUtility getAttachmentObjectsListofType:IMAGES_DICT dictionaryType:OBJECT_LIST];
    for (int counter = 0;counter < [itemsArray count] ; counter++) {
        NSDictionary *documentDict = [itemsArray objectAtIndex:counter];
        NSString *attachmmentId = [documentDict objectForKey:K_ATTACHMENT_ID];
        if (attachmmentId != nil) {
            ATTACHMENT_STATUS attachmentStatus = [AttachmentUtility getAttachmentStaus:documentDict];
            if (attachmentStatus == ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS || attachmentStatus == ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE) {
                UIProgressView *progressView = [self.attachmentProgressBarsDictionary objectForKey:attachmmentId];
                if (progressView == nil) {
                    UIProgressView *progressView = [self createProgressBar];
                    [self addProgressBar:progressView ForId:attachmmentId];
                }
            }
            else{
                UIProgressView *progressView = [self.attachmentProgressBarsDictionary objectForKey:attachmmentId];
                if (progressView != nil) {
                    [self removeProgressbarForId:attachmmentId];
                }
            }
        }
    }

}
#pragma mark- 9212
-(void)handleErrorForCell:(imageCollectionViewCell *)cell
           withAttachment:(NSDictionary *)documentDict
                andStatus:(ATTACHMENT_STATUS)status {
    if (status == ATTACHMENT_STATUS_ERROR_IN_DOWNLOAD) {
        NSString *attachmentId = [documentDict objectForKey:K_ATTACHMENT_ID];
        SMAttachmentRequestErrorCode errorCode = (SMAttachmentRequestErrorCode)[appDelegate.attachmentDataBase getErrorCodeForAttachmentId:attachmentId];
        NSString *message = [AttachmentUtility getAttachmentAPIErrorMessage:errorCode];
        cell.errorMsg.text = message;
        [cell bringSubviewToFront:cell.errorMsg];
        //Get the text and set the color to red or else blue
    }
    else{
        cell.errorMsg.text = nil;
    }
}


@end
