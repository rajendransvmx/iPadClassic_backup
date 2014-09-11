//
//  cameraAttachmentViewController.m
//  ServiceMaxMobile
//
//  Created by Kirti on 08/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import "cameraAttachmentViewController.h"

@interface cameraAttachmentViewController ()

@end

@implementation cameraAttachmentViewController
@synthesize cameraViewController;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(cameraViewController == nil) {
        
        /**< instansiate UIImagePickerController object */
        
        UIImagePickerController *tempController = [[UIImagePickerController alloc] init];
        self.cameraViewController = tempController;
        [tempController release];
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - start capturing
#pragma mark

- (BOOL) startCameraControllerFromViewController:(UIViewController *)controller andisImageFromCamera:(BOOL)isCameraCapture {
    
    
    /**< Check isSourceTypeAvailable for possible sources (camera and photolibrary) */
    
    if (([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] == NO) || ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary] == NO))
        return NO;
    
    /**< if editing is required*/
    
    cameraViewController.allowsEditing = YES;
    cameraViewController.delegate = self;
    
    if(isCameraCapture) {
        
        // still camera image,
        cameraViewController.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        // if video is not needed then remove below line
        cameraViewController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else {
        //capture image from gallery
        
        cameraViewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraViewController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [self presentViewController:cameraViewController animated:YES completion:nil];
    
    return YES;
    
}

#pragma mark - Button Actions
#pragma mark
- (IBAction)CaptureCameraImageBtnAction:(id)sender {
    
    isImageFromCamera = YES;
    [self startCameraControllerFromViewController:self andisImageFromCamera:isImageFromCamera];
}

- (IBAction)CaptureGalleryImageBtnAction:(id)sender {
    
    isImageFromCamera = NO;
    [self startCameraControllerFromViewController:self andisImageFromCamera:isImageFromCamera];
    
}


/**< support only potrait orientation for UIImagePickerController ( as per apple doc )*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
