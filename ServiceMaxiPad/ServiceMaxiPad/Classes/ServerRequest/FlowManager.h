//
//  FlowManager.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 6/1/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   FlowManager.h
 *  @class  FlowManager
 *
 *  @brief  This class will mainitain all reequest flow across the application
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


@class FlowNode;

@interface FlowManager : NSObject



// ...

+ (instancetype) sharedInstance;

+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

// ...


- (BOOL)cancelRequestByRequestIdentifier:(NSString *)identifier;
- (BOOL)pauseRequestByRequestIdentifier:(NSString *)identifier;

- (BOOL)cancelFlowByFlowIdentifier:(NSString *)identifier;
- (BOOL)pauseFlowByFlowIdentifier:(NSString *)identifier;


- (void)addFlow:(FlowNode *)flowNode;
- (void)addRequest:(id)request;
- (void)manageFlow;

- (BOOL)isEmptyFlow;
- (void)cancelAllFlow:(BOOL)cancel;

@end




