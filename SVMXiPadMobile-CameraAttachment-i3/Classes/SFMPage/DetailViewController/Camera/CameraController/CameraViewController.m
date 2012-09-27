//
//  CameraViewController.m
//  TabView
//
//  Created by Siva Manne on 15/05/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "iServiceAppDelegate.h"

@interface CameraViewController ()
// Screenshot Methods
- (void)renderView:(UIView*)view inContext:(CGContextRef)context;
- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;
-(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize;
// AVFoundation (Camera) Methods
- (void)setupCaptureSession;
- (void)captureStillImage;
- (void)autofocusNotSupported;
- (void)flashNotSupported;
- (void)captureStillImageFailedWithError:(NSError *)error;
- (void)cannotWriteToAssetLibrary;
- (void)cameraOn;
- (void)cameraOff;

@end

@implementation CameraViewController
@synthesize mainView;
@synthesize overlayView;
@synthesize overlayMapView;
@synthesize backgroundImageView;
@synthesize cameraNavigationItem;
@synthesize capturedSession;
@synthesize capturedStillImageOutput;
@synthesize orientation;
@synthesize previewLayer;
@synthesize attachmentDataDict;
@synthesize scanning;
@synthesize imageFileName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.cameraNavigationItem.title = NSLocalizedString(@"Camera", @"Camera");
        //self.tabBarItem.image = [UIImage imageNamed:@"camera"];
    }
    return self;
}
- (void)dealloc
{
	[mainView release];
	[overlayView release];
    [overlayImageView release];
	[backgroundImageView release];
    [cameraNavigationItem release];
    [capturedSession release];
    [previewLayer release];  
    [attachmentDataDict release];
    [imageFileName release];
    [super dealloc];
}
- (void)DismissModalViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark UIView Controller Methods

- (void)viewDidLoad
{
	[super viewDidLoad];
    
	self.scanning = NO;
	
    [self.backgroundImageView setBackgroundColor:[UIColor blackColor]];    
    iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *moduleName = [appDelegate.wsInterface.tagsDictionary objectForKey:CAM_CameraModule_Name];
    NSString *viewName = [appDelegate.wsInterface.tagsDictionary objectForKey:CAM_View_Name];
    self.cameraNavigationItem.title = [NSString stringWithFormat:@"%@ %@",moduleName,viewName];
	    
    //Add Navigation Bar Buttons
    overlayMapView.showsUserLocation = YES;
    UIButton * backButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)] autorelease];
    [backButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Back-Arrow-Button"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(DismissModalViewController:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem * backBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    self.cameraNavigationItem.leftBarButtonItem = backBarButtonItem;
    
    //Add Right Bar Buttons
    NSMutableArray * buttons = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    //Sync Image View
    //iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIBarButtonItem * syncBarButton = [[UIBarButtonItem alloc] initWithCustomView:appDelegate.animatedImageView];
    [buttons addObject:syncBarButton];
    [syncBarButton setTarget:self];
    syncBarButton.width =26;
    [syncBarButton release];

    //Start or Stop Button
    UIButton *recordButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 40)] autorelease];
    UIImage * actionImage = [UIImage imageNamed:@"SFM-Screen-Done-Back-Button.png"];
    [actionImage stretchableImageWithLeftCapWidth:9 topCapHeight:9];
    [recordButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [recordButton setTitle:@"Capture" forState:UIControlStateNormal];
    [recordButton setBackgroundImage:actionImage forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * startBarButton = [[UIBarButtonItem alloc] initWithCustomView:recordButton];
    [buttons addObject:startBarButton];
    
    //Help Button
    UIButton * helpButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)] autorelease];
    UIImage * helpImage = [UIImage imageNamed:@"iService-Screen-Help.png"];
    //[helpImage stretchableImageWithLeftCapWidth:9 topCapHeight:9];
    [helpButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [helpButton setBackgroundImage:helpImage forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * helpBarButton = [[UIBarButtonItem alloc] initWithCustomView:helpButton];
    [buttons addObject:helpBarButton];
    
    UIToolbar* toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 196, 44)] autorelease];
    [toolbar setItems:buttons];
    self.cameraNavigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolbar] autorelease];
    //Call Camera Setup Method
    //[self performSelector:@selector(cameraOn)];

}

- (void)viewWillAppear:(BOOL)animated
{
    //[self performSelector:@selector(cameraOn)];
    [super viewWillAppear:animated];
}
- (void) viewDidAppear:(BOOL)animated
{
    NSLog(@"View Did Appear");
    [super viewDidAppear:animated];
    [self performSelector:@selector(cameraOn)];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [self cameraOff];
    
    [super viewWillDisappear:animated];
}



- (void)viewDidUnload
{
	[super viewDidUnload];
    
    self.mainView = nil;
    self.overlayView = nil;
    self.overlayMapView = nil;
    self.backgroundImageView = nil;
    self.cameraNavigationItem = nil;
    self.attachmentDataDict  = nil;
    self.imageFileName = nil;
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{

    if((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || 
        (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
        orientation = interfaceOrientation;
    else
        orientation = AVCaptureVideoOrientationLandscapeLeft;
    self.previewLayer.orientation = orientation;
    NSLog(@"orientation = %d",self.previewLayer.orientation);
    NSLog(@"UI orientation = %d",interfaceOrientation);
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark -
#pragma mark Methods for OpenGL & UIKView Screenshots based on Q&A 1702, Q&A 1703, Q&A 1704, & Q&A 1714

- (void)renderView:(UIView*)view inContext:(CGContextRef)context
{
	//////////////////////////////////////////////////////////////////////////////////////
	//																					//
	// This works like a charm when you have multiple views that need to be rendered	//
	// in a UIView when one of those views is an OpenGL CALayer view or a camera stream	//
	// or some other view that will not work with - (UIImage*)screenshot, as defined 	//
	// in Technical Q&A QA1703, "Screen Capture in UIKit Applications".					//
	//																					//
	//////////////////////////////////////////////////////////////////////////////////////
	
	
	//
	// -renderInContext: renders in the coordinate space of the layer,
    // so we must first apply the layer's geometry to the graphics context.
	//
    CGContextSaveGState(context);
    
	
	//
	// Center the context around the window's anchor point.
	//
    CGContextTranslateCTM(context, [view center].x, [view center].y);
    
	//
	// Apply the window's transform about the anchor point.
	//
    CGContextConcatCTM(context, [view transform]);
	
	
	//
    // Offset by the portion of the bounds left of and above the anchor point.
	//
    CGContextTranslateCTM(context,
                          -[view bounds].size.width * [[view layer] anchorPoint].x,
                          -[view bounds].size.height * [[view layer] anchorPoint].y);
    
	//
	// Render the layer hierarchy to the current context.
	//
    [[view layer] renderInContext:context];
	
    
	//
	// Restore the context. BTW, you're done.
	//
    CGContextRestoreGState(context);
}




#pragma mark -
#pragma mark IBAction Methods for Camera and Scanning

- (void)cameraOn
{
	
	[self setupCaptureSession];
    self.backgroundImageView.image = nil;
    //
	// This creates the preview of the camera
	//
	self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.capturedSession];
    self.previewLayer.frame = self.backgroundImageView.bounds; // Assume you want the preview layer to fill the view
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    orientation = [[UIDevice currentDevice] orientation];
    if((orientation == UIInterfaceOrientationLandscapeLeft) ||
      (orientation == UIInterfaceOrientationLandscapeRight))
        self.previewLayer.orientation = orientation;
    else
        self.previewLayer.orientation = UIInterfaceOrientationLandscapeLeft;
    
	[self.backgroundImageView.layer addSublayer:self.previewLayer];				
    
}



- (void)cameraOff
{
    //
    // Camera is now off.
    //
    [self.capturedSession stopRunning];
    [self.backgroundImageView setBackgroundColor:[UIColor blackColor]];
    [self.previewLayer removeFromSuperlayer];
}



- (IBAction)scan
{
    //	NSLog(@"Scanning");
	self.scanning = YES;
    [UIView animateWithDuration:0.1 animations:^{
        
	}
					 completion:^( BOOL finished ){
						 if (finished) 
						 {
							 [self captureStillImage];
						 }
					 }];
    
}

static void capture_cleanup(void* p)
{
    CameraViewController* ar = (CameraViewController *)p; // cast to original context instance
    [ar release];  // releases capture session if dealloc is called
}

// Create and configure a capture session and start it running
- (void)setupCaptureSession 
{
    //	NSLog(@"setupCaptureSession");
	
    NSError *error = nil;
	
	
    //
    // Create the session
	//
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
	
	
    //
    // Configure the session to produce lower resolution video frames, if your 
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
	//
    //session.sessionPreset = AVCaptureSessionPreset640x480;
    session.sessionPreset = AVCaptureSessionPreset1280x720;
    
    //
	// Find a suitable AVCaptureDevice
	//
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	
    //
	// Support auto-focus locked mode
	//
	//if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) 
    if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) 
	{
		NSError *error = nil;
		if ([device lockForConfiguration:&error]) 
        {
			//device.focusMode = AVCaptureFocusModeAutoFocus;
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
			[device unlockForConfiguration];
		}
		else 
		{
            NSLog(@"Oops! Focus Error");
            if ([self respondsToSelector:@selector(autofocusNotSupported)]) 
            {
                [self autofocusNotSupported];
            }
		}
	}
	
	
    //
	// Support auto flash mode
	//
	if ([device isFlashModeSupported:AVCaptureFlashModeAuto]) 
	{
		NSError *error = nil;
		if ([device lockForConfiguration:&error]) 
        {
			device.flashMode = AVCaptureFlashModeAuto;
			[device unlockForConfiguration];
		}
		else 
		{
            NSLog(@"Oops! Flash Mode Problem");
            if ([self respondsToSelector:@selector(flashNotSupported)]) 
            {
                [self flashNotSupported];
            }
		}
	}	
	
	
    //
    // Create a device input with the device and add it to the session.
	//
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device 
                                                                        error:&error];
    if (!input) 
	{
        // Handling the error appropriately.
    }
    else
        [session addInput:input];
	
	
    //
    // Create a AVCaputreStillImageOutput instance and add it to the session
	//
	AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
	NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
	[stillImageOutput setOutputSettings:outputSettings];
    [outputSettings release];
	
	
	[session addOutput:stillImageOutput];
	
	
    //
	// This is what actually gets the AVCaptureSession going
	//
    [session startRunning];
    
    
    //
    // Assign session we've created here to our AVCaptureSession ivar.
	//
	// KEY POINT: With this AVCaptureSession property, you can start/stop scanning to your hearts content, or 
	// until the code you are trying to read has read it.
	//
	self.capturedStillImageOutput  = stillImageOutput;
    [stillImageOutput release];
    
    //Session Cleaning
    dispatch_queue_t queue = dispatch_queue_create("com.servicemax.mobile.camera", NULL);
    dispatch_set_context(queue, self);
    dispatch_set_finalizer_f(queue, capture_cleanup);
    //[stillImageOutput setSampleBufferDelegate: self queue: queue];
    dispatch_release(queue);
    [self retain];
    
	self.capturedSession  = session;
    [session release];
}

-(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize 
{  
    UIGraphicsBeginImageContext(newSize);  
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];  
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();  
    UIGraphicsEndImageContext();    
    return newImage;  
}

#pragma mark -
#pragma mark Screenshot Methods Using AVFoundation and UIKit as shown in Technical Q&A 1714

- (void) captureStillImage
{
    // Flash the screen white and fade it out to give UI feedback that a still image was taken
    CGRect videoFrame = [[self backgroundImageView] frame];
    UIView *flashView = [[UIView alloc] initWithFrame:videoFrame];
    [flashView setBackgroundColor:[UIColor whiteColor]];
    [[self view]  addSubview:flashView];
    
    [UIView animateWithDuration:.4f
                     animations:^{
                         [flashView setAlpha:0.f];
                     }
                     completion:^(BOOL finished){
                         [flashView removeFromSuperview];
                         [flashView release];
                     }
     ];
    UIActivityIndicatorView *activityView  = [[UIActivityIndicatorView alloc] 
                                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityView setFrame:CGRectMake(500, 364, 50, 50)];
    [[self view]  addSubview:activityView];
    [activityView startAnimating];

    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[self.capturedStillImageOutput connections]];
	
    if ([videoConnection isVideoOrientationSupported]) 
	{
        AVCaptureVideoOrientation videoOrientation = [[UIDevice currentDevice] orientation];
        NSLog(@"Orientation = %d",videoOrientation);
        if((videoOrientation == AVCaptureVideoOrientationLandscapeRight) || (videoOrientation == AVCaptureVideoOrientationLandscapeLeft))
        {
            [videoConnection setVideoOrientation:videoOrientation]; 
        }
        else {
            [videoConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft]; 
        }
	}
	
    [self.capturedStillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
															   completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) 
     {
         // 
         // If this line is not commented-out, the animationWithDuration:animations:^ never gets called. Weird...
         //
         if (imageDataSampleBuffer != NULL) 
         {

             //
             // Grab the image data as a JPEG still image from the AVCaptureStillImageOutput and create a UIImage image with it.
             //
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
             UIImage *image = [[UIImage alloc] initWithData:imageData];
             
             
             //
             // Now, we're going to using -renderView:inContext to build-up our screenshot.
             //
             //
             // Create a graphics context with the target size
             //
            // CGSize imageSize = [[UIScreen mainScreen] bounds].size;
             CGSize imageSize = CGSizeMake(1024, 748);
             UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
             
             CGContextRef context = UIGraphicsGetCurrentContext();
             
             
             //
             // Draw the image returned by the camera sample buffer into the context. 
             // Draw it into the same sized rectangle as the view that is displayed on the screen.
             //
             //			CGFloat menubarUIOffset = 20.0;
             //			CGFloat	tabbarUIOffset = 44.0;
             UIGraphicsPushContext(context);
             [image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
             UIGraphicsPopContext();
             
             
             
             //
             // Render the camera overlay view into the graphic context that we created above.
             //
             [self renderView:self.overlayView inContext:context];
             
             
             //
             // Retrieve the screenshot image containing both the camera content and the overlay view
             //
             UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
             
             //UIImage *smallImage = [UIImage imageWithCGImage:screenshot.CGImage scale:0.1 orientation:screenshot.imageOrientation];
             UIImage *smallImage = [self scaleImage:screenshot toSize:CGSizeMake(900, 600)];
             
             //
             // We're done with the image context, so close it out.
             //
             UIGraphicsEndImageContext();
             NSData *screenshotImageData = UIImagePNGRepresentation(smallImage);
             NSUInteger size = [screenshotImageData length];
             float sizeinMB = (1.0 *size)/1048576;
             NSString *imgSize = [NSString stringWithFormat:@"%0.3f MB",sizeinMB];
             
             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
             [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
             NSDate *date = [NSDate date];
             NSString *attachmentName = [attachmentDataDict objectForKey:@"WorkOrderNumber"];
             NSLog(@"Attachment Name = :%@:",attachmentName);
             if([attachmentName isEqualToString:@""]|| ([attachmentName length] == 0))
             {
                 
                 imageFileName = [NSString stringWithFormat:@"image+%@.png",[dateFormatter stringFromDate:date]];
             }
             else
             {
                 imageFileName = [NSString stringWithFormat:@"%@+%@.png",attachmentName,[dateFormatter stringFromDate:date]];
             }
             [dateFormatter release];
             NSLog(@"Image File Name = %@",imageFileName);
             
            iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
            NSMutableDictionary *cameraDataDict = [[NSMutableDictionary alloc] init];
             
            NSString *attachment_Id    =  [attachmentDataDict objectForKey:@"attachment_Id"];
            NSString *apiName          =  [attachmentDataDict objectForKey:@"object_api_name"];
            NSString *objectNumber     =  [attachmentDataDict objectForKey:@"WorkOrderNumber"];
            NSString *recordId         =  [attachmentDataDict objectForKey:@"record_Id"];
             
            [cameraDataDict setObject:attachment_Id forKey:@"attachment_Id"];
            [cameraDataDict setObject:apiName forKey:@"object_api_name"];
            [cameraDataDict setObject:objectNumber forKey:@"WorkOrderNumber"];
            [cameraDataDict setObject:recordId forKey:@"record_Id"];
            [cameraDataDict setObject:imageFileName forKey:@"fileName"];
            [cameraDataDict setObject:@"Image" forKey:@"fileType"];
            [cameraDataDict setObject:imgSize forKey:@"size"];
             
            [appDelegate.calDataBase insertCameraData:screenshotImageData withInfo:cameraDataDict];
            [cameraDataDict release];
            [image release];
             
            [activityView stopAnimating];
            [activityView removeFromSuperview];
            [activityView release];
         } 
         else if (error) 
         {
             NSLog(@"Oops! Image Capture Error");
             if ([self respondsToSelector:@selector(captureStillImageFailedWithError:)]) 
             {
                 [self captureStillImageFailedWithError:error];
             }
         }
     }];
	

    // 
	// Clean-up a bit here to make sure that we're not gathering data for a new image and the state of the 
    // "scan" button reflects that.
	//
	self.scanning = NO;
}



- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
	for ( AVCaptureConnection *connection in connections ) 
	{
		for ( AVCaptureInputPort *port in [connection inputPorts] ) 
		{
			if ( [[port mediaType] isEqual:mediaType] ) 
			{
				return [[connection retain] autorelease];
			}
		}
	}
	return nil;
}


#pragma mark -
#pragma mark Error Handling Methods

- (void) autofocusNotSupported
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Autofocus Not Supported On This Device"
                                                        message:@"Autofocus is not supported on your device. However, you can still use the camera."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];        
}



- (void) flashNotSupported
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Flash Available On This Device"
                                                        message:@"Your device does not have a camera flash. However, you can still use the camera."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];        
}



- (void) captureStillImageFailedWithError:(NSError *)error
{
    iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *errorMsg = [appDelegate.wsInterface.tagsDictionary objectForKey:CAM_ImageCapture_Failure];
    NSString *okString = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorMsg
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:okString
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}



- (void) cannotWriteToAssetLibrary
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Incompatible with Asset Library"
                                                        message:@"The captured file cannot be written to the asset library. It is likely an audio-only file."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];        
}
#pragma mark - MapView Delegate Methods
- (void)mapViewDidFinishLoadingMap:(MKMapView *)newMapView
{
    CLLocationCoordinate2D annotationCoord;
    annotationCoord.latitude = newMapView.userLocation.location.coordinate.latitude;
    annotationCoord.longitude = newMapView.userLocation.location.coordinate.longitude;
    
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = annotationCoord;
    annotationPoint.title = newMapView.userLocation.title;
    annotationPoint.subtitle = newMapView.userLocation.subtitle;
    [newMapView addAnnotation:annotationPoint]; 
    [annotationPoint release];
}
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    NSLog(@"Failed to Load the Map View");
}
#pragma mark - help method
- (void) showHelp
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Show Help" message:@"Show the Help File" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];    
}
@end
