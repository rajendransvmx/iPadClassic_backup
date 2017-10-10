//
//  BarCodeScannerUtility.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 06/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "BarCodeScannerUtility.h"
#import "SMAppDelegate.h"
#import "BarCoderScannerViewController.h"
#import <Photos/Photos.h>

@interface BarCodeScannerUtility () <BarCoderScannerViewDelegate>

@property (nonatomic, strong)BarCoderScannerViewController *scanner;

@end

@implementation BarCodeScannerUtility

/**
 * @name  <loadScannerOnViewController>
 *
 * @author Krishna Shanbhag
 *
 * @brief <initiate the scanner>
 *
 * \par
 *  < Load the scanner view controller. Which will scan the image and decodes the bar codes>
 *
 *
 * @param  Viewcontroller
 * View controller on which the scanner view has to be loaded.
 *
 *
 *
 */
- (void)loadScannerOnViewController:(UIViewController *)viewController forModalPresentationStyle:(NSInteger)presentationStyle {
    AVAuthorizationStatus cameraStatus = (AVAuthorizationStatus)[AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (cameraStatus == AVAuthorizationStatusAuthorized) {
        [self loadBarCodeScannerOnViewController:viewController forModalPresentationStyle:presentationStyle];
    }
    else if (cameraStatus == AVAuthorizationStatusDenied) {
        //Don nothing.
    }
    else if (cameraStatus == AVAuthorizationStatusNotDetermined) {
        //Request camera access authorization
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
         {
             if (granted) {
                 [self loadBarCodeScannerOnViewController:viewController forModalPresentationStyle:presentationStyle];
             }
         }];
    }
    else if (cameraStatus == PHAuthorizationStatusRestricted) {
        // Restricted access - normally won't happen.
    }
}

-(void)loadBarCodeScannerOnViewController:(UIViewController *)viewController forModalPresentationStyle:(NSInteger)presentationStyle{

    SXLogDebug(@"\n\n\n Loaded scanner");
    self.scanner = [[BarCoderScannerViewController alloc] initWithNibName:@"BarCoderScannerViewController" bundle:nil];
    self.scanner.readerDelegate = self;
    self.scanner.view.frame = viewController.view.frame;
    if(presentationStyle)
        self.scanner.modalPresentationStyle = presentationStyle;
    
    if(presentationStyle ==   UIModalPresentationFullScreen) {
        CGRect viewframe = [[UIScreen mainScreen] bounds];
         if (viewframe.size.width != [UIApplication sharedApplication].statusBarFrame.size.width) {
         viewframe = CGRectMake(0, 0, viewframe.size.height, viewframe.size.width);
         }
         self.scanner.view.frame = viewframe;
    }

    [viewController presentViewController:self.scanner animated:NO completion:^{
        
    }];

}

- (void)dealloc
{
    _scannerDelegate = nil;
    _scanner = nil;
}

#pragma mark ZXingDelegates

- (void)decoded:(NSString*)data {
    [self.scanner dismissViewControllerAnimated:NO completion:^{
        self.scanner = nil;
        if (self.scannerDelegate && [self.scannerDelegate respondsToSelector:@selector(barcodeSuccessfullyDecodedWithData:)]) {
            
            [self.scannerDelegate performSelector:@selector(barcodeSuccessfullyDecodedWithData:) withObject:data];
        }
    }];
    
}

- (void)cancelled {
    
    [self.scanner dismissViewControllerAnimated:NO completion:^{
        self.scanner = nil;
        if (self.scannerDelegate && [self.scannerDelegate respondsToSelector:@selector(barcodeCaptureCancelled)]) {
            [self.scannerDelegate performSelector:@selector(barcodeCaptureCancelled)];
        }
        
    }];
}



@end
