//
//  ThirdPartyAppActivity.h
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 18/05/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThirdPartyApp.h"

@interface ThirdPartyAppActivity : UIActivity
@property (nonatomic, strong) ThirdPartyApp *thirdPartyApp;

- (instancetype)initWithThirdPartyApp:(ThirdPartyApp *)appInfo;
@end