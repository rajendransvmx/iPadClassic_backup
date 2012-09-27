//
//  CameraViewController.h
//  TabView
//
//  Created by Siva Manne on 15/05/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <MapKit/Mapkit.h>
@class AVCamCaptureManager, AVCamPreviewView, AVCaptureVideoPreviewLayer;
@interface CameraViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate,UINavigationControllerDelegate,MKMapViewDelegate>
{
    AVCaptureSession            *capturedSession;
    AVCaptureStillImageOutput	*capturedStillImageOutput;
	AVCaptureVideoOrientation	orientation;
    
    
	UIView                      *mainView;
	UIView                      *overlayView;
    UIImageView                 *overlayImageView;
    
    BOOL                        scanning;
}
// Properties for UIKit Screenshot
@property (nonatomic, retain)		IBOutlet		UIView                      *mainView;
@property (nonatomic, retain)		IBOutlet		UIView                      *overlayView;
@property (nonatomic, retain)       IBOutlet        MKMapView                   *overlayMapView;
@property (nonatomic, retain)       IBOutlet        UIImageView                 *backgroundImageView;
@property (nonatomic, retain)       IBOutlet        UINavigationItem            *cameraNavigationItem;

// Properties for AVFoundation (camera) Screenshot
@property (nonatomic, retain)						AVCaptureSession			*capturedSession;
@property (nonatomic, retain)						AVCaptureStillImageOutput	*capturedStillImageOutput;
@property (nonatomic,assign)						AVCaptureVideoOrientation	orientation;
@property (nonatomic, retain)                       AVCaptureVideoPreviewLayer  *previewLayer;

@property (nonatomic, retain)                       NSDictionary                *attachmentDataDict;

@property                           BOOL                                        scanning;

//Member Variables
@property (nonatomic, retain)                       NSString                    *imageFileName;
// Screenshot Camera Methods
- (void) showHelp;
@end
