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
#import "AttachmentHelper.h"
#import "StyleManager.h"

#define MaximumDuration 120.f

@interface ImagesVideosViewController ()

@property(nonatomic, strong)NSMutableArray *selectedImagesAndVideosArray;

-(void)createImagePickerController;
-(void)hideImagePickerController;

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
@synthesize popoverImageViewController;

static NSString *const kDownloadedCollectionViewCell = @"DownloadedCollectionViewCell";
static NSString *const kNonDownloadedCollectionViewCell = @"NonDownloadedCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.collectionView.allowsMultipleSelection = YES;
    self.imagesAndVideosArray = [AttachmentHelper getImagesAndVideosAttachmentsLinkedToParentId:self.parentId];
    [self.collectionView registerNib:[UINib nibWithNibName:kDownloadedCollectionViewCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kDownloadedCollectionViewCell];
    [self.collectionView registerNib:[UINib nibWithNibName:kNonDownloadedCollectionViewCell bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kNonDownloadedCollectionViewCell];
    self.collectionView.delegate = self;
    self.collectionView.dataSource= self;
    self.editProcessHeaderView.hidden=YES;
    self.collectionView.backgroundColor=[UIColor whiteColor];
    [self createImagePickerController];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    // _data is a class member variable that contains one array per section.
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imagesAndVideosArray count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row]%2==0) {
        DownloadedCollectionViewCell* newCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kDownloadedCollectionViewCell forIndexPath:indexPath];
        newCell.datelbl.text=@"12-12-2014";
        return newCell;
    }else{
        NonDownloadedCollectionViewCell* newCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kNonDownloadedCollectionViewCell forIndexPath:indexPath];
        [newCell initialSerup:nil Iserror:NO];
        newCell.fileNamelbl.text=@"An_Average_Filename.jpg";
        newCell.fileSizelbl.text=@"3.5 MB";
        newCell.selected=NO;
        return newCell;
    }
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
}
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
}
- (BOOL)collectionView:(UICollectionView *)collectionViewLoc shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (IBAction)selectAction:(UIButton *)sender
{
    imageAndVideoView.hidden = YES;
    editProcessHeaderView.hidden = NO;
    [self.collectionView reloadData];
}

-(void)refreshHeaderTitle:(int)selectedItems
{
    editProcessHeaderLabel.text=[NSString stringWithFormat:@"%d Items Selected",selectedItems];
}

- (IBAction)cancelAction:(UIButton *)sender
{
    imageAndVideoView.hidden = NO;
    editProcessHeaderView.hidden = YES;
    [self.collectionView reloadData];
}
- (IBAction)shareAction:(UIButton *)sender
{
    
}
- (IBAction)deleteAction:(UIButton *)sender{
    
}

-(void)updateShareAndDeleteButton
{
    [self refreshHeaderTitle:0];
    if (1 > 0) {
        [self.shareButton setSelected:YES];
        [self.deleteButton setSelected:YES];
    }else{
        [self.shareButton setSelected:NO];
        [self.deleteButton setSelected:NO];
    }
}

-(void)createImagePickerController
{
    UIImagePickerViewController *picker = [[UIImagePickerViewController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes=[UIImagePickerViewController availableMediaTypesForSourceType:picker.sourceType];
    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
}

-(IBAction) showimagePicker:(UIButton*)button
{
    [self hideImagePickerController];
    //the rectangle here is the frame of the object that presents the popover,
    //in this case, the UIButton…
    CGRect popRect = CGRectMake(button.frame.origin.x,
                                button.frame.origin.y,
                                button.frame.size.width,
                                button.frame.size.height);
    CGSize popoverSize=CGSizeMake(230,300);
    [popoverController setPopoverContentSize:popoverSize];
    [popoverController presentPopoverFromRect:popRect
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionUp
                                     animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    BOOL isVideoTaken=false;
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
    picker.videoMaximumDuration = MaximumDuration;

    // Handle a still image capture
    //UIImage * originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //TO FIX orientation incase of portrait.
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    /** Pushpak
     * defect 10742
     * resolution of image was getting spoilt due to trimming, solution was to remove trimming as salesforce limit is raised from 5mb to 25 mb
     */
    //NSData *dataToSaveFromImage = UIImagePNGRepresentation(originalImage);
    if([mediaType isEqualToString:@"public.movie"])
    {
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
            [self performSelector:@selector(dataFromCapturedImage:) withObject:info];
        }
    }
    
}

-(void)videoCaptured:(NSURL*)inputPathURL isCaptured:(BOOL)isCaptured picker:(UIImagePickerController *)picker
{
    [self hideImagePickerController];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(error)
    {
        
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    //Do required stuff.
    if(error)
    {
        
    }
}

- (void) dataFromCapturedImage:(NSDictionary *)ImageInfo {
    //upload image from here
    [self hideImagePickerController];
}

- (void)hideImagePickerController
{
    if ([popoverController isPopoverVisible]) {
        [popoverController dismissPopoverAnimated:YES];
    }
}

@end
