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

@interface TaskHelper : NSObject

+ (NSArray *)fetchAllTask;
+ (void)addNewTask:(SFMTaskModel *)model;
+ (void)updateTask:(SFMTaskModel *)model;
+ (void)deleteTask:(SFMTaskModel *)model;

@end
