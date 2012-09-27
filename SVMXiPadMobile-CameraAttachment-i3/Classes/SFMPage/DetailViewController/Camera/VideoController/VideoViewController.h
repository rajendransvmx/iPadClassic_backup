//
//  VideoViewController.h
//  TabView
//
//  Created by Siva Manne on 15/05/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class AVCamCaptureManager, AVCamPreviewView, AVCaptureVideoPreviewLayer;
@interface VideoViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>
{
    BOOL isViewAnimating;
}
@property (nonatomic,retain) AVCamCaptureManager        *captureManager;
@property (nonatomic,retain) IBOutlet UIView            *videoPreviewView;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,retain) IBOutlet UIButton          *cameraToggleButton;
@property (nonatomic,retain) IBOutlet UIButton          *recordButton;
@property (nonatomic,retain) IBOutlet UILabel           *focusModeLabel;
@property (nonatomic,retain) IBOutlet UINavigationItem  *videoNavigationItem;
@property (nonatomic,assign) BOOL                       isRegistered;
@property (nonatomic,retain)          NSDictionary      *attachmentDataDict;
@property (nonatomic,retain)          NSString          *videoFileName;
@property (nonatomic, retain)         UIImageView       *myAnimatedView;

- (void) showHelp;

#pragma mark Toolbar Actions
- (IBAction)toggleRecording:(id)sender;
- (IBAction)toggleCamera:(id)sender;
- (void)cameraOff;
- (void) moveVideoFile;

@end
