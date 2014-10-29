//
//  TimeLogManager.h
//  ServiceMaxiPad
//
//  Created by Chinnababu on 28/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimeLogModel.h"

@interface TimeLogManager : NSObject

+ (instancetype) sharedInstance;
+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

- (void) logResponseTimeEntryToCache:(TimeLogModel *)logModel;
- (NSArray *)getRequestParameterForLogging;

@end
