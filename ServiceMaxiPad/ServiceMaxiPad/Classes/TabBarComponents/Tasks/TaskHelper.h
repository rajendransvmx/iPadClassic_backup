//
//  TaskHelper.h
//  ServiceMaxMobile
//
//  Created by Pushpak on 02/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionObjectModel.h"
#import "SFMTaskModel.h"

extern NSString *const kTaskPriorityLow;
extern NSString *const kTaskPriorityNormal;
extern NSString *const kTaskPriorityHigh;

@interface TaskHelper : NSObject

+ (NSArray *)fetchAllTask;
+ (void)addNewTask:(SFMTaskModel *)model;
+ (void)updateTask:(SFMTaskModel *)model;
+ (void)deleteTask:(SFMTaskModel *)model;

@end
