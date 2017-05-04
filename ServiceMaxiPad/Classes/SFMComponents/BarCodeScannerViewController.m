//
//  BarCoderScannerViewController.m
//  ServiceMaxMobile
//
//  Created by Thiruppathi Gandhi on 26/July/2016.
//  Copyright (c) 2016 ServiceMax. All rights reserved.
//


#import <AudioToolbox/AudioToolbox.h>
#import "BarCoderScannerViewController.h"

@interface BarCoderScannerViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnInfo;
- (IBAction)btnInfo:(id)sender;
- (IBAction)btnCancel:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *scannerControllerView;
@property (nonatomic, strong) UIActivityIndicatorView * activityView;

@property (nonatomic, strong) ZXCapture *capture;
@property (nonatomic, weak) IBOutlet UIView *scanRectView;
@property (nonatomic, weak) IBOutlet UILabel *decodedLabel;

@end

@implementation BarCoderScannerViewController {
	CGAffineTransform _captureSizeTransform;
}

#pragma mark - View Controller Methods

- (void)dealloc {
  [self.capture.layer removeFromSuperlayer];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.capture = [[ZXCapture alloc] init];
  self.capture.camera = self.capture.back;
  self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
  self.activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

  [self.view.layer addSublayer:self.capture.layer];
  
  [self.view bringSubviewToFront:self.scanRectView];
  [self.view bringSubviewToFront:self.decodedLabel];
  [self.view bringSubviewToFront:self.scannerControllerView];
 
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  self.capture.delegate = self;
  [self applyOrientation];
}

- (void)updateActionFrame {
    CGRect viewframe = self.view.frame;
    CGRect frame = CGRectMake(0,
                              viewframe.size.height- self.scannerControllerView.frame.size.height,
                              viewframe.size.width,
                              self.scannerControllerView.frame.size.height);
    self.scannerControllerView.frame = frame;
    self.btnInfo.frame = CGRectMake(viewframe.size.width-110,self.btnInfo.frame.origin.y, 22, 22);

}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self applyOrientation];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
	} completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
	{
		[self applyOrientation];
	}];
}

#pragma mark - Private
- (void)applyOrientation {
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	float scanRectRotation;
	float captureRotation;

	switch (orientation) {
		case UIInterfaceOrientationPortrait:
			captureRotation = 0;
			scanRectRotation = 90;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			captureRotation = 90;
			scanRectRotation = 180;
			break;
		case UIInterfaceOrientationLandscapeRight:
			captureRotation = 270;
			scanRectRotation = 0;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			captureRotation = 180;
			scanRectRotation = 270;
			break;
		default:
			captureRotation = 0;
			scanRectRotation = 90;
			break;
	}
	[self applyRectOfInterest:orientation];
	CGAffineTransform transform = CGAffineTransformMakeRotation((CGFloat) (captureRotation / 180 * M_PI));
	[self.capture setTransform:transform];
	[self.capture setRotation:scanRectRotation];
	self.capture.layer.frame = self.view.frame;
    [self updateActionFrame];
}

- (void)applyRectOfInterest:(UIInterfaceOrientation)orientation {
	CGFloat scaleVideo, scaleVideoX, scaleVideoY;
	CGFloat videoSizeX, videoSizeY;
	CGRect transformedVideoRect = self.scanRectView.frame;
	if([self.capture.sessionPreset isEqualToString:AVCaptureSessionPreset1920x1080]) {
		videoSizeX = 1080;
		videoSizeY = 1920;
	} else {
		videoSizeX = 720;
		videoSizeY = 1280;
	}
	if(UIInterfaceOrientationIsPortrait(orientation)) {
		scaleVideoX = self.view.frame.size.width / videoSizeX;
		scaleVideoY = self.view.frame.size.height / videoSizeY;
		scaleVideo = MAX(scaleVideoX, scaleVideoY);
		if(scaleVideoX > scaleVideoY) {
			transformedVideoRect.origin.y += (scaleVideo * videoSizeY - self.view.frame.size.height) / 2;
		} else {
			transformedVideoRect.origin.x += (scaleVideo * videoSizeX - self.view.frame.size.width) / 2;
		}
	} else {
		scaleVideoX = self.view.frame.size.width / videoSizeY;
		scaleVideoY = self.view.frame.size.height / videoSizeX;
		scaleVideo = MAX(scaleVideoX, scaleVideoY);
		if(scaleVideoX > scaleVideoY) {
			transformedVideoRect.origin.y += (scaleVideo * videoSizeX - self.view.frame.size.height) / 2;
		} else {
			transformedVideoRect.origin.x += (scaleVideo * videoSizeY - self.view.frame.size.width) / 2;
		}
	}
	_captureSizeTransform = CGAffineTransformMakeScale(1/scaleVideo, 1/scaleVideo);
	self.capture.scanRect = CGRectApplyAffineTransform(transformedVideoRect, _captureSizeTransform);
}

#pragma mark - Private Methods

- (NSString *)barcodeFormatToString:(ZXBarcodeFormat)format {
  switch (format) {
    case kBarcodeFormatAztec:
      return @"Aztec";

    case kBarcodeFormatCodabar:
      return @"CODABAR";

    case kBarcodeFormatCode39:
      return @"Code 39";

    case kBarcodeFormatCode93:
      return @"Code 93";

    case kBarcodeFormatCode128:
      return @"Code 128";

    case kBarcodeFormatDataMatrix:
      return @"Data Matrix";

    case kBarcodeFormatEan8:
      return @"EAN-8";

    case kBarcodeFormatEan13:
      return @"EAN-13";

    case kBarcodeFormatITF:
      return @"ITF";

    case kBarcodeFormatPDF417:
      return @"PDF417";

    case kBarcodeFormatQRCode:
      return @"QR Code";

    case kBarcodeFormatRSS14:
      return @"RSS 14";

    case kBarcodeFormatRSSExpanded:
      return @"RSS Expanded";

    case kBarcodeFormatUPCA:
      return @"UPCA";

    case kBarcodeFormatUPCE:
      return @"UPCE";

    case kBarcodeFormatUPCEANExtension:
      return @"UPC/EAN extension";

    default:
      return @"Unknown";
  }
}

#pragma mark - ZXCaptureDelegate Methods

- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result {
  if (!result) return;
    NSString *formatString = [self barcodeFormatToString:result.barcodeFormat];
    NSLog(@"Barcode formatted string[%@]",formatString);
    [self.capture stop];
    if (self.readerDelegate && [self.readerDelegate respondsToSelector:@selector(decoded:)]) {
        [self.readerDelegate performSelector:@selector(decoded:) withObject:result.text];
    }
}

- (IBAction)btnInfo:(id)sender {
    
    UIWebView *helpWebView = [[UIWebView alloc] init];
    [helpWebView setBackgroundColor:[UIColor darkGrayColor]];
    [self.scannerControllerView setBackgroundColor:[UIColor darkGrayColor]];
    helpWebView.tag = 100;
    CGRect frame = CGRectMake(0,
                              0,
                              self.view.frame.size.width,
                              self.view.frame.size.height- self.scannerControllerView.frame.size.height);
    
    helpWebView.frame = frame;
    helpWebView.delegate = self;
    
    [helpWebView loadHTMLString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BarCodeScannerHelp" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil] baseURL: [[NSBundle mainBundle] bundleURL]];

    [self.view addSubview:helpWebView];
     self.activityView.center = CGPointMake(helpWebView.bounds.size.width/2, helpWebView.bounds.size.height/2);
    [helpWebView addSubview:self.activityView];
    
    self.btnInfo.hidden=YES;
    self.btnCancel.hidden = YES;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tag = 200;
    [button addTarget:self action:@selector(btnDone:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Done" forState:UIControlStateNormal];
    button.frame = CGRectMake(self.btnInfo.frame.origin.x-30, self.btnInfo.frame.origin.y-8, 50, 40.0);
    
    [self.scannerControllerView addSubview:button];
    [self.capture stop];
}

- (IBAction)btnCancel:(id)sender {
    [self.capture stop];
    if (self.readerDelegate && [self.readerDelegate respondsToSelector:@selector(cancelled)]) {
        [self.readerDelegate performSelector:@selector(cancelled)];
    }
}

- (IBAction)btnDone:(id)sender {
    UIView *doneButton = [self.scannerControllerView viewWithTag:200];
    [doneButton removeFromSuperview];
    UIWebView *webView = [self.view viewWithTag:100];
    [webView removeFromSuperview];
    self.btnInfo.hidden = NO;
    self.btnCancel.hidden = NO;
    [self.scannerControllerView setBackgroundColor:[UIColor blackColor]];
    [self.capture start];
}

#pragma mark UIWebViewDelegate Methods
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.activityView stopAnimating];
    
}
@end
