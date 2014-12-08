//
//  BarCodeScannerUtility.h
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 06/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
// ADD: import barcode reader APIs
#import "ZBarSDK.h"

/**
 *  @file   BarCodeScannerUtility.h
 *  @class  BarCodeScannerUtility
 *
 *  @brief Bar code scanner responsible for scanning and returning the desired results.
 *  
 *  @usage Example
 *  
 *  Instantiate BarCodeScannerUtility and call loadScannerOnViewController.
 *  Implement protocol and get the desired Output.
 *
 *  @author Krishna shanbhag
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

@protocol BarCodeScannerProtocol <NSObject>

/**
 * @protocol <BarCodeScannerProtocol>
 *
 * @name BarCodeScannerProtocol
 *
 * @author Krishna Shanbhag
 *
 * @brief <Bar code scanner completion delegates>
 *
 * \par
 *  < Depicts the success or failure of the scanned image>
 *
 */

- (void) barcodeSuccessfullyDecodedWithData:(NSString *)decodedData;
- (void) barcodeCaptureCancelled;

@end



@interface BarCodeScannerUtility : NSObject <ZBarReaderDelegate>

@property (nonatomic, assign) id <BarCodeScannerProtocol> scannerDelegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

- (void)loadScannerOnViewController:(UIViewController *)viewController;

@end
