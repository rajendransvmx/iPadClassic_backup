//
//  RuleManager.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/31/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @file   RuleManager.h
 *  @class  RuleManager
 *
 *  @brief  This class manage rules for request which used across the application
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


extern NSString * const kFlowActionImmediate;
extern NSString * const kFlowActionNext;
extern NSString * const kFlowActionParallel;
extern NSString * const kFlowActionNotAllowed;


@interface RuleManager : NSObject

// ...

+ (instancetype) sharedInstance;

+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

// ...

- (void)loadRules;

- (NSDictionary *)rulesByName:(NSString *)name;

- (NSString *)actionNameByPlacedFlowName:(NSString *)primeFlowName
                        withIncomingFlow:(NSString *)secondFlowName;

@end
