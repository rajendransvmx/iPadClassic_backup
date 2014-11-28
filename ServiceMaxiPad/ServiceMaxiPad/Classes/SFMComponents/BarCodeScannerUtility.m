//
//  BarCodeScannerUtility.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 06/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "BarCodeScannerUtility.h"
#import "SMAppDelegate.h"

@interface BarCodeScannerUtility ()

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
- (void)loadScannerOnViewController:(UIViewController *)viewController {
    
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    
    // DO: (optional) additional reader configuration can be done here

    // Disabling rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [viewController presentViewController:reader animated:YES completion:^{
        
    }];

}
#pragma mark - ZBar Delegates.
- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        //Grab the first barcode
        break;
    
    //do something useful with the barcode data
    if (self.scannerDelegate && [self.scannerDelegate respondsToSelector:@selector(barcodeSuccessfullyDecodedWithData:)]) {
        
        [self.scannerDelegate performSelector:@selector(barcodeSuccessfullyDecodedWithData:) withObject:symbol.data];
    }
    
    //    using the barcode original image
    //    imageview.image = [info objectForKey: UIImagePickerControllerOriginalImage];
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
   
    if (self.scannerDelegate && [self.scannerDelegate respondsToSelector:@selector(barcodeCaptureCancelled)]) {
        
        [self.scannerDelegate performSelector:@selector(barcodeCaptureCancelled)];
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
