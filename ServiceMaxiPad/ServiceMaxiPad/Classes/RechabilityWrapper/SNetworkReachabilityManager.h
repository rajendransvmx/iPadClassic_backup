//
//  SNetworkReachabilityManager.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 3/25/14.
//  Copyright (c) 2013 ServiceMax. All rights reserved.
//

/**
 *  @file   SNetworkReachabilityManager.h
 *  @class  SNetworkReachabilityManager
 *
 *  @brief  Observer and manage device Network Reachability changes
 *
 *
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>
#import "Reachability.h"

#define kNetworkConnectionChanged          @"kNetworkConnectionChanged"

@interface SNetworkReachabilityManager : NSObject
{
   
}
// ...

//+ (instancetype) sharedInstance;

+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

// ...
+ (instancetype)sharedInstance;

/**
 * @name   isNetworkReachable
 *
 * @author Vipindas Palli
 *
 * @brief
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return BOOL Yes, if network reachable, otherwise No
 *
 */

- (BOOL)isNetworkReachable;


/**
 * @name   reachabilityStatus
 *
 * @author Vipindas Palli
 *
 * @brief  Status of reachability
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return void
 *
 */

- (void)reachabilityStatus;

@end
