//
//  BarCodeScannerUtility.h
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 06/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>

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
@optional
- (void) barcodeCaptureCancelled;

@end



@interface BarCodeScannerUtility : NSObject 

@property (nonatomic, assign) id <BarCodeScannerProtocol> scannerDelegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

//Madhusudhan, #024468, As we should define presentationStyle model for scanner viewController.
- (void)loadScannerOnViewController:(UIViewController *)viewController forModalPresentationStyle:(NSInteger)presentationStyle;

@end
