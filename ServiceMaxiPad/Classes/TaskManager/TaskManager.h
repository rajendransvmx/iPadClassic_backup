//
//  TaskManager.h
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 12/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   TaskManager.h
 *  @class  TaskManager
 *
 *  @brief  Manages Tasks, Responsible for cancelling a task, converting a task to flow node .
 *
 *  @author  Krishna Shanbhag
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>

@class TaskModel;

@interface TaskManager : NSObject

// ...

// + (instancetype) sharedInstance;

+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

// ...
/**
 * @name   sharedInstance
 *
 * @author Krishna Shanbhag
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

/**
 * @name   addTask:
 *
 * @author Krishna Shanbhag
 *
 * @brief  Adds the task object to the flow in FlowManager.
 *
 * \par
 *  Task object to be added
 *
 * @return Shared Object of application manager class.
 *
 */

- (void) addTask:(TaskModel *)taskObject;

- (void)removeFlowNodeWithId:(NSString *)flowNodeId;

- (void)cancelFlowNodeWithId:(NSString *)flowNodeId;

- (NSArray *) currentlyRunningOperations;
@end
