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

@interface ImageCollectionView ()
-(void)reloadCollectionView;
- (IBAction)EditList:(id)sender;
-(NSDictionary *)getDictionaryForindexpath:(NSIndexPath *)indexPath;
-(void)fillImageDataAtIndexPath:(NSIndexPath *)indexPath collectionViewcell:(imageCollectionViewCell *)cell initiateViews:(BOOL)initiateViews;
-(NSString *)getDocumentFileName:(NSIndexPath *)indexPath;
-(void)hideEditbuttons:(BOOL)hide;
-(void)hideAttachment:(BOOL)hide;
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
    [self.EditList setHidden:status];
    [self.pencilIcon setHidden:status];
}
- (void) setIsViewMode:(BOOL)newMode
{
    isViewMode = newMode;
    [self shouldShowCameraPopover:newMode];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.multipleSelection = FALSE;
    compressionCompleted = NO;
    [self.CollectionView registerClass:[imageCollectionViewCell class] forCellWithReuseIdentifier:@"FlickrCell"];
    self.CollectionView.backgroundColor = [UIColor whiteColor];
    self.CollectionView.allowsMultipleSelection = NO;
    // Do any additional setup after loading the view from its nib.
     [self hideEditbuttons:TRUE];
    [self shouldShowCameraPopover:isViewMode];
    if(self.deletedList == nil)
    {
        self.deletedList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    else
    {
        [self.deletedList removeAllObjects];
    }
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
    NSString *addImagetitle=[NSString stringWithFormat:@"+ %@",[appDelegate.wsInterface.tagsDictionary objectForKey:ADD_PHOTO_VIDEO]];
    

    NSString *delete=[appDelegate.wsInterface.tagsDictionary objectForKey:DELETE_BUTTON_TITLE];//9211

    title_label.text=[appDelegate.wsInterface.tagsDictionary objectForKey:PHOTOS_VIDEOS];
    
    title_label.backgroundColor = [UIColor clearColor];
    title_label.textColor = [appDelegate colorForHex:@"2d5d83"];// [UIColor whiteColor];
    
    title_label.font = [UIFont boldSystemFontOfSize:16];

    
    [attachButton setTitle:addImagetitle forState:UIControlStateNormal];
    [_cancel setTitle:cancel forState:UIControlStateNormal];
    [EditList setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:EDIT_LIST] forState:UIControlStateNormal];
    
    [_deleteAction setTitle:delete forState:UIControlStateNormal];
    
    if (self.attachmentProgressBarsDictionary == nil) {
        [self loadProgressBars];
    }
    
    //defect #9101
    [self handlingEditButtonStatus];
    
    //defect #9224
     self.view.backgroundColor = [UIColor whiteColor];

}
-(void)viewDidAppear:(BOOL)animated
{
     //defect #9101
    [self handlingEditButtonStatus];
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
        [self enableEditButton:NO];
    }
}

- (void)dismissImagePickerView {
    [self.CollectionView reloadData];
    [imageViewDelegate dismissImageView];
}

- (void) dataFromCapturedImage:(NSData *)capturedImageData {

    NSString *local_id = [AppDelegate GetUUID];
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

}

-(void)videoCaptured:(NSURL*)path isCaptured:(BOOL)isCaptured picker:(UIImagePickerController *)picker
{
    NSString *local_id=[AppDelegate GetUUID];
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
    if(limit > 5)
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
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    NSMutableArray * itemsArray = [AttachmentUtility getAttachmentObjectsListofType:IMAGES_DICT dictionaryType:OBJECT_LIST];
    return [itemsArray count];
}
// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
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
        if(attachmentStatus != ATTACHMENT_STATUS_YET_TO_DOWNLOAD && attachmentStatus != ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS && attachmentStatus != ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE)
        {
            if([self isItemAvailable:cell.localId]){
                [cell highlightcellForDeletion];
            }
            else
            {
                [cell UnhighlightcellFromDeletion];
            }
        }
    }
    /*Adding pg view*/
    [self handleProgressBarToCell:cell withStatus:attachmentStatus andDictionary:[self getDictionaryForindexpath:indexPath]];
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
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
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
        
        
      /*  if(cellType == IMAGE_EXISTS)
        {
           
        }
        else if(cellType == DOWNLOAD_IMAGE)
        {
            //Insert download request  into queue
            [dict setValue:@"DOWNLOAD" forKey:K_ACTION];
            [AttachmentUtility insertIntoAttachmentTrailer:dict];
            return;
        }
        else if(cellType == DOWNLOAD_INQUEUE || cellType == ERROR_IN_DOWNLOAD)
        {
            return;
        }*/
    }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
{

     if(self.multipleSelection)
     {
         
         imageCollectionViewCell * cell = ( imageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
         
         //IMAGE_CELL_TYPE cellType = [self getImageType:indexPath];
          ATTACHMENT_STATUS attachmentStatus = [AttachmentUtility getAttachmentStaus:[self getDictionaryForindexpath:indexPath]];
       //  IMAGE_CELL_TYPE cellType = [self getImageType:indexPath attachmentStatus:attachmentStatus];
         if(attachmentStatus != ATTACHMENT_STATUS_YET_TO_DOWNLOAD && attachmentStatus != ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS && attachmentStatus != ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE)
         {
             [self enableDelete:YES];
             BOOL deleted = [cell select];
             if(deleted)
             {
                 [self.deletedList addObject:cell.localId];
             }
             else
             {
                 if([self.deletedList containsObject:cell.localId])
                 {
                     [self.deletedList removeObject:cell.localId];
                 }
             }
             [cell UnhighlightcellFromDeletion];
         }
         //defect #9101
         if([self.deletedList count] > 0)
         {
             [self enableDelete:YES];
         }
         else
         {
              [self enableDelete:NO];
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
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage * trimmedImage=[self scaleImage:originalImage toSize:CGSizeMake(900,600)];
    NSData *dataToSaveFromImage = UIImagePNGRepresentation(trimmedImage);
    
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
    [self hideAttachment:FALSE];
    [self hideEditbuttons:TRUE];
    [self.deletedList removeAllObjects];
    [self.CollectionView reloadData];
}

- (IBAction)performDeletion:(id)sender
{
    [self hideAttachment:FALSE];
    [self hideEditbuttons:TRUE];
    [AttachmentUtility conformationforDelete:self];
   
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
        
        if(buttonIndex == 1)
        {
            [AttachmentUtility deleteIdsFromAttachmentlist:self.deletedList forType:IMAGES_DICT];
        }
        else if(buttonIndex == 2)
        {
            // Vipin - 9088
            [AttachmentUtility removeSelectedAttachmentFiles:self.deletedList];
        }
        
 //defect #9101
        [self handlingEditButtonStatus];
        [self.deletedList removeAllObjects];
        [self.CollectionView reloadData];
    }
    //End 009139
    
}

-(void)hideEditbuttons:(BOOL)hide
{
    self.deleteAction.hidden = hide;
    self.cancel.hidden = hide;
    self.multipleSelection = !hide;
    [self enableDelete:NO];
}
-(void)hideAttachment:(BOOL)hide
{
    self.EditList.hidden = hide;
    self.pencilIcon.hidden=hide;
    self.attachButton.hidden = hide;
}
- (IBAction)EditList:(id)sender
{
    
    self.multipleSelection = TRUE;
    [self hideAttachment:TRUE];
    [self  hideEditbuttons:FALSE];
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
    self.deleteAction.enabled=enable;
}


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

@end
