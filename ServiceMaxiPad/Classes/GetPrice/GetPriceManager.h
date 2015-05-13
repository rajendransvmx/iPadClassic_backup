//
//  GetPriceManager.h
//  ServiceMaxMobile
//
//  Created by Anoop on 4/13/15.
//  Copyright (c) 2015 ServiceMax, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncConstants.h"
#import "FlowDelegate.h"

/**
 *  @file   GetPriceManager.h
 *  @class  GetPriceManager
 *
 *  @brief  This class maintains the GetPrice set of calls status and request
 *
 *
 *
 *  @author  Anoop
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2015 ServiceMax, Inc. All rights reserved.
 *
 **/

@interface GetPriceManager : NSObject <FlowDelegate>

// ...
+ (instancetype) sharedInstance;
+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

-(void)intiateGetPriceSync;
-(BOOL)isGetPriceInProgress;

@end
