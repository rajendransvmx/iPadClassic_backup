//
//  SyncScheduler.h
//  ServiceMaxMobile
//
//  Created by Damodar on 21/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncConstants.h"

@protocol SchedulerDelegate <NSObject>

@optional
- (void)sync:(SyncType)sync firedAt:(NSDate*)date;

@end

@interface SyncScheduler : NSObject

@property (nonatomic, assign) id<SchedulerDelegate> delegate;

- (void)scheduleForSync:(SyncType)syncType withInterval:(NSTimeInterval)timeInterval andDelegate:(id<SchedulerDelegate>)delegate;

- (void)skipNextSchedule;

- (void)invalidateScheduler;

- (void)reScheduleWithTimeInterval:(NSTimeInterval)interval;

@end
