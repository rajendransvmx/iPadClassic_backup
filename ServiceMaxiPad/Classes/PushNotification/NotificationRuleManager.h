//
//  NotificationRuleManager.h
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 04/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlowNode.h"
@interface NotificationRuleManager : NSObject

// + (instancetype) sharedInstance;

+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

// ...

/**
 * @name   sharedInstance
 *
 * @author Vipindas Palli
 *
 * @brief  Shared instance of the application manager.
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Shared Object of application manager class.
 *
 */

+ (instancetype)sharedInstance;

-(BOOL)shouldprocessNotificationRequest;

@end
