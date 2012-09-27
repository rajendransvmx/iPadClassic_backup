//
//  VideoViewController.m
//  TabView
//
//  Created by Siva Manne on 15/05/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import "VideoViewController.h"
#import "AVCamCaptureManager.h"
#import "AVCamRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "iServiceAppDelegate.h"
static void *AVCamFocusModeObserverContext = &AVCamFocusModeObserverContext;

@interface VideoViewController ()<UIGestureRecognizerDelegate>
@end
@interface VideoViewController (InternalMethods)
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates;
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)updateButtonStates;
@end

@interface VideoViewController (AVCamCaptureManagerDelegate) <AVCamCaptureManagerDelegate>
@end

@implementation VideoViewController
@synthesize isRegistered;
@synthesize captureManager;
@synthesize cameraToggleButton;
@synthesize recordButton;
@synthesize focusModeLabel;
@synthesize videoPreviewView;
@synthesize captureVideoPreviewLayer;
@synthesize videoNavigationItem;
@synthesize attachmentDataDict;
@synthesize videoFileName;
@synthesize myAnimatedView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.videoNavigationItem.title = NSLocalizedString(@"Video", @"Video");
        //self.tabBarItem.image = [UIImage imageNamed:@"video"];
    }
    return self;
}
- (void)DismissModalViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void) showHelp
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Show Help" message:@"Show the Help File" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];    
}

- (NSString *)stringForFocusMode:(AVCaptureFocusMode)focusMode
{
	NSString *focusString = @"";
	
	switch (focusMode) {
		case AVCaptureFocusModeLocked:
			focusString = @"locked";
			break;
		case AVCaptureFocusModeAutoFocus:
			focusString = @"auto";
			break;
		case AVCaptureFocusModeContinuousAutoFocus:
			focusString = @"continuous";
			break;
	}
	
	return focusString;
}

- (void)dealloc
{
    if(isRegistered)
    {   
        [self removeObserver:self forKeyPath:@"captureManager.videoInput.device.focusMode"];
        isRegistered = NO;
    }
	[captureManager release];
    [videoPreviewView release];
	[captureVideoPreviewLayer release];
    [cameraToggleButton release];
    [recordButton release];
	[focusModeLabel release];
	[videoNavigationItem release];
    [attachmentDataDict release];
    [videoFileName release];
    [myAnimatedView release];
    [super dealloc];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self recordButton] setTitle:@"Record" forState:UIControlStateNormal];
    if([self captureManager])
    {    
        [[self captureManager] release];
        self.captureManager = nil;
    }
    
	if ([self captureManager] == nil) {
		AVCamCaptureManager *manager = [[AVCamCaptureManager alloc] init];
		[self setCaptureManager:manager];
		[manager release];
		
		[[self captureManager] setDelegate:self];
        
		if ([[self captureManager] setupSession]) {
            // Create video preview layer and add it to the UI
			AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureManager] session]];
			UIView *view = [self videoPreviewView];
			CALayer *viewLayer = [view layer];
			[viewLayer setMasksToBounds:YES];
			
			CGRect bounds = [view bounds];
			[newCaptureVideoPreviewLayer setFrame:bounds];
			
			if ([newCaptureVideoPreviewLayer isOrientationSupported]) 
            {
                UIInterfaceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
                if (deviceOrientation == UIDeviceOrientationLandscapeRight)
                {
                    NSLog(@"Device Orientation Right");
                    [newCaptureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationLandscapeLeft];                
                }
                else
                {
                    NSLog(@"Device Orientation Left");
                    [newCaptureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationLandscapeRight];
                }
			}
			
			[newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
			
			[viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
			
			[self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
            [newCaptureVideoPreviewLayer release];
			
            // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[[[self captureManager] session] startRunning];
			});
			
            [self updateButtonStates];
			
            [self addObserver:self forKeyPath:@"captureManager.videoInput.device.focusMode" options:NSKeyValueObservingOptionNew context:AVCamFocusModeObserverContext];
            isRegistered = YES;

            // Add a single tap gesture to focus on the point tapped, then lock focus
			UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToAutoFocus:)];
			[singleTap setDelegate:self];
			[singleTap setNumberOfTapsRequired:1];
			[view addGestureRecognizer:singleTap];
			
            // Add a double tap gesture to reset the focus mode to continuous auto focus
			UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToContinouslyAutoFocus:)];
			[doubleTap setDelegate:self];
			[doubleTap setNumberOfTapsRequired:2];
			[singleTap requireGestureRecognizerToFail:doubleTap];
			[view addGestureRecognizer:doubleTap];
			
			[doubleTap release];
			[singleTap release];
		}		
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[self captureManager] stopRecording];
    self.captureManager = nil;
    videoNavigationItem = nil;
    attachmentDataDict =nil;
    videoFileName = nil;
    myAnimatedView = nil;
}
- (void) viewWillDisappear:(BOOL)animated
{
    [self cameraOff];
    [super viewWillDisappear:animated];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    AVCaptureVideoPreviewLayer *videoPreviewLayer = [[self captureVideoPreviewLayer] retain];
    BOOL result = NO;
    if((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
       (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
    {
        UIInterfaceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
        if (deviceOrientation == UIDeviceOrientationLandscapeRight)
        {
            NSLog(@"Device Orientation Right");
            [videoPreviewLayer setOrientation:AVCaptureVideoOrientationLandscapeLeft];                
        }
        else
        {
            NSLog(@"Device Orientation Left");
            [videoPreviewLayer setOrientation:AVCaptureVideoOrientationLandscapeRight];
        }
        
        result =  YES;
    }
    [videoPreviewLayer release];
    return result;
}

- (void)viewDidLoad
{
    iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *moduleName = [appDelegate.wsInterface.tagsDictionary objectForKey:CAM_VideoModule_Name];
    NSString *viewName = [appDelegate.wsInterface.tagsDictionary objectForKey:CAM_View_Name];

    self.videoNavigationItem.title = [NSString stringWithFormat:@"%@ %@",moduleName,viewName];
    
    UIButton * backButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)] autorelease];
    [backButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Back-Arrow-Button"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(DismissModalViewController:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * backBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    self.videoNavigationItem.leftBarButtonItem = backBarButtonItem;
    
    //Add Right Bar Buttons
    NSMutableArray * buttons = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    //Sync Image View
    //iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIBarButtonItem * syncBarButton = [[UIBarButtonItem alloc] initWithCustomView:appDelegate.animatedImageView];
    [buttons addObject:syncBarButton];
    [syncBarButton setTarget:self];
    syncBarButton.width =26;
    [syncBarButton release];

    //Start or Stop Record Button
    /*
    recordButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 40)] autorelease];
    UIImage * actionImage = [UIImage imageNamed:@"SFM-Screen-Done-Back-Button.png"];
    [actionImage stretchableImageWithLeftCapWidth:9 topCapHeight:9];
    [recordButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    [recordButton setBackgroundImage:actionImage forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(toggleRecording:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * startBarButton = [[UIBarButtonItem alloc] initWithCustomView:recordButton];
     [buttons addObject:startBarButton];
    */

    isViewAnimating = NO;
    NSArray *myImages = [NSArray arrayWithObjects:
                         [UIImage imageNamed:@"record1.png"],
                         [UIImage imageNamed:@"record2.png"],
                         nil];
    
	myAnimatedView = [[UIImageView alloc] autorelease];
	[myAnimatedView initWithFrame:CGRectMake(0, 0, 44, 44)];
	myAnimatedView.animationImages = myImages;
	myAnimatedView.animationDuration = 1;
	myAnimatedView.animationRepeatCount = 0;
	[myAnimatedView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
    [myAnimatedView addGestureRecognizer:tap];
    [tap release];
    myAnimatedView.tag = 1;
    [myAnimatedView setImage:[UIImage imageNamed:@"record1.png"]];
    UIBarButtonItem *imageButton = [[[UIBarButtonItem alloc] initWithCustomView:myAnimatedView] autorelease];
    [buttons addObject:imageButton];
     
 
    //Help Button
    UIButton * helpButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)] autorelease];
    UIImage * helpImage = [UIImage imageNamed:@"iService-Screen-Help.png"];
    //[helpImage stretchableImageWithLeftCapWidth:9 topCapHeight:9];
    [helpButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [helpButton setBackgroundImage:helpImage forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * helpBarButton = [[UIBarButtonItem alloc] initWithCustomView:helpButton];
    [buttons addObject:helpBarButton];
    
    UIToolbar* toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 140, 44)] autorelease];
    [toolbar setItems:buttons];
    self.videoNavigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolbar] autorelease];
    [super viewDidLoad];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == AVCamFocusModeObserverContext) {
        // Update the focus UI overlay string when the focus mode changes
		[focusModeLabel setText:[NSString stringWithFormat:@"focus: %@", [self stringForFocusMode:(AVCaptureFocusMode)[[change objectForKey:NSKeyValueChangeNewKey] integerValue]]]];
	} else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Custom Methods
- (void) updateAnimation
{
    if(isViewAnimating)
    {
        [myAnimatedView stopAnimating];
        isViewAnimating = NO;
    }
    else 
    {
        [myAnimatedView startAnimating];
        isViewAnimating = YES;
    }
    [self performSelector:@selector(toggleRecording:)];
}

#pragma mark Toolbar Actions
- (void)tapEvent:(UITapGestureRecognizer *)gesture
{
    NSLog(@"Touched Bar Button");
    [self updateAnimation];
}
- (IBAction)toggleCamera:(id)sender
{
    // Toggle between cameras when there is more than one
    [[self captureManager] toggleCamera];
    
    // Do an initial focus
    [[self captureManager] continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}

- (IBAction)toggleRecording:(id)sender
{
    // Start recording if there isn't a recording running. Stop recording if there is.
    //[[self recordButton] setEnabled:NO];
    if (![[[self captureManager] recorder] isRecording])
    {
        [[self captureManager] startRecording];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
        NSDate *date  = [NSDate date];
        NSString *objectNumber    =  [attachmentDataDict objectForKey:@"WorkOrderNumber"];
        NSLog(@"WO Name = %@",objectNumber);
        if([objectNumber isEqualToString:@""])
        {
            videoFileName = [NSString stringWithFormat:@"video+%@.mov",[dateFormatter stringFromDate:date]];
            NSLog(@"No Work Order");
        }
        else 
        {
            videoFileName = [NSString stringWithFormat:@"%@+%@.mov",objectNumber,[dateFormatter stringFromDate:date]];
        }
        [[self captureManager] setFileName:videoFileName];
    }
    else
    {
        [[self captureManager] stopRecording];
    }
}
- (void)cameraOff
{
    //
    // Camera is now off.
    //
    [self.captureManager.session stopRunning];
    //[self.videoPreviewView.layer removeFromSuperlayer];
    NSLog(@"Hello");
}
- (void) moveVideoFile
{
    iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableDictionary *cameraDataDict = [[NSMutableDictionary alloc] init];
    
    NSString *attachment_Id    =  [attachmentDataDict objectForKey:@"attachment_Id"];
    NSString *apiName    =  [attachmentDataDict objectForKey:@"object_api_name"];
    NSString *objectNumber    =  [attachmentDataDict objectForKey:@"WorkOrderNumber"];
    NSString *recordId    =  [attachmentDataDict objectForKey:@"record_Id"];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSLog(@"Attachment Name = :%@:",objectNumber);
    NSLog(@"Video File Name = %@",videoFileName);
	NSString *destinationPath = [documentsDirectory stringByAppendingFormat:@"/videos/%@",videoFileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSDictionary *attributesDict = [fileManager attributesOfItemAtPath:destinationPath error:&error];
    double size;
    if(error != nil)
        size = 0;
    else
        size = [[attributesDict objectForKey:@"NSFileSize"] longValue];

    NSString *videoSize = [NSString stringWithFormat:@"%0.3lf MB",(size/1048576)];
    [cameraDataDict setObject:attachment_Id forKey:@"attachment_Id"];
    [cameraDataDict setObject:apiName forKey:@"object_api_name"];
    [cameraDataDict setObject:objectNumber forKey:@"WorkOrderNumber"];
    [cameraDataDict setObject:recordId forKey:@"record_Id"];
    [cameraDataDict setObject:videoFileName forKey:@"fileName"];
    [cameraDataDict setObject:@"Video" forKey:@"fileType"];
    [cameraDataDict setObject:videoSize forKey:@"size"];
    [appDelegate.calDataBase insertCameraData:nil withInfo:cameraDataDict];
    [cameraDataDict release];
}
@end
@implementation VideoViewController (InternalMethods)
// Convert from view coordinates to camera coordinates, where {0,0} represents the top left of the picture area, and {1,1} represents
// the bottom right in landscape mode with the home button on the right.
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = [[self videoPreviewView] frame].size;
    
    if ([captureVideoPreviewLayer isMirrored]) {
        viewCoordinates.x = frameSize.width - viewCoordinates.x;
    }    
    
    if ( [[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize] ) {
		// Scale, switch x and y, and reverse x
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in [[[self captureManager] videoInput] ports]) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ( [[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
						// If point is inside letterboxed area, do coordinate conversion; otherwise, don't change the default value returned (.5,.5)
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
							// Scale (accounting for the letterboxing on the left and right of the video preview), switch x and y, and reverse x
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
						// If point is inside letterboxed area, do coordinate conversion. Otherwise, don't change the default value returned (.5,.5)
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
							// Scale (accounting for the letterboxing on the top and bottom of the video preview), switch x and y, and reverse x
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if ([[captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
					// Scale, switch x and y, and reverse x
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2; // Account for cropped height
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2); // Account for cropped width
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

// Auto focus at a particular point. The focus mode will change to locked once the auto focus happens.
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[captureManager videoInput] device] isFocusPointOfInterestSupported]) {
        CGPoint tapPoint = [gestureRecognizer locationInView:[self videoPreviewView]];
        CGPoint convertedFocusPoint = [self convertToPointOfInterestFromViewCoordinates:tapPoint];
        [captureManager autoFocusAtPoint:convertedFocusPoint];
    }
}

// Change to continuous auto focus. The camera will constantly focus at the point choosen.
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[captureManager videoInput] device] isFocusPointOfInterestSupported])
        [captureManager continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}

// Update button states based on the number of available cameras and mics
- (void)updateButtonStates
{
	NSUInteger cameraCount = [[self captureManager] cameraCount];
	NSUInteger micCount = [[self captureManager] micCount];
    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        if (cameraCount < 2) {
            [[self cameraToggleButton] setEnabled:NO]; 
            
            if (cameraCount < 1) {
                
                if (micCount < 1)
                    [[self recordButton] setEnabled:NO];
                else
                    [[self recordButton] setEnabled:YES];
            } else {
                [[self recordButton] setEnabled:YES];
            }
        } else {
            [[self cameraToggleButton] setEnabled:YES];
            [[self recordButton] setEnabled:YES];
        }
    });
}

@end

@implementation VideoViewController (AVCamCaptureManagerDelegate)

- (void)captureManager:(AVCamCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *ok_Btn_Title = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:ok_Btn_Title
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    });
}

- (void)captureManagerRecordingBegan:(AVCamCaptureManager *)captureManager
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [[self recordButton] setTitle:@"Stop" forState:UIControlStateNormal];
        [[self recordButton] setEnabled:YES];
    });
}

- (void)captureManagerRecordingFinished:(AVCamCaptureManager *)captureManager
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [[self recordButton] setTitle:@"Record" forState:UIControlStateNormal];
        [[self recordButton] setEnabled:YES];
    });
    [self moveVideoFile];
}

- (void)captureManagerStillImageCaptured:(AVCamCaptureManager *)captureManager
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
    });
}

- (void)captureManagerDeviceConfigurationChanged:(AVCamCaptureManager *)captureManager
{
	[self updateButtonStates];
}

@end
