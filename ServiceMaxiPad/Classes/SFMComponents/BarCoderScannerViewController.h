//
//  BarCoderScannerViewController.h
//  ServiceMaxMobile
//
//  Created by Thiruppathi Gandhi on 26/July/2016.
//  Copyright (c) 2016 ServiceMax. All rights reserved.
//

#import "ZXingObjC.h"

@protocol BarCoderScannerViewDelegate <NSObject>

- (void)decoded:(NSString*)data;
- (void)cancelled;

@end

@interface BarCoderScannerViewController : UIViewController <ZXCaptureDelegate>

@property (nonatomic, assign) id <BarCoderScannerViewDelegate> readerDelegate;

@end
