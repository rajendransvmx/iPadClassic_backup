//
//  TaskManager.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 12/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//
/**
 *  @file   TaskManager.m
 *  @class  TaskManager
 *
 *  @brief  Manage task objects thats are injected.
 *
 *  @author  Krishna Shanbhag
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/
#import "TaskManager.h"
#import "TaskModel.h"
#import "FlowNode.h"
#import "FlowManager.h"

@interface TaskManager()
@property(nonatomic,strong)NSMutableDictionary *flowNodeDictionary;

@end

@implementation TaskManager


#pragma mark Singleton Methods

+ (instancetype) sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initInstance];
    });
    return sharedInstance;
}

- (instancetype) initInstance {
    self = [super init];
    // Do any other initialisation stuff here
    // ...
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

/**
 * @name   sharedInstance
 *
 * @author Krishna Shanbhag
 *
 * @brief  This method is exposed to caller to inject a new task.
 *
 * \par
 *  <Longer description starts here>
 *
 * @return NA.
 *
 */

- (void) addTask:(TaskModel *)taskObject {
    
    FlowNode *node = [self createFlowNodeForTask:taskObject];
    
    // TEMP : TODO - correct workflow
    [node startFlow];
    
    [self addFlowNodeToFlowManager:node];
}
/**
 * @name   sharedInstance
 *
 * @author Krishna Shanbhag
 *
 * @brief  This method is exposed to caller to cancel a task based on ID.
 *
 * \par
 *  <Longer description starts here>
 *
 * @return NA.
 *
 */
- (void) cancelTask:(NSString *) taskId {
}
/**
 * @name   sharedInstance
 *
 * @author Krishna Shanbhag
 *
 * @brief  Brief description of task object is copied to the flow node.
 *
 * \par
 *  <Longer description starts here>
 *
 * @return NA.
 *
 */
- (FlowNode *) createFlowNodeForTask:(TaskModel *)taskObject {
    
    FlowNode *node = [[FlowNode alloc] init];
    node.flowId = taskObject.taskId;
    node.callerDelegate = taskObject.callerDelegate;
    node.requestParam = taskObject.requestParamObj;
    node.nodecategoryType = taskObject.categoryType;
    
    return node;
    
}
/**
 * @name   sharedInstance
 *
 * @author Krishna Shanbhag
 *
 * @brief  Inject the created flow node to flow manager.
 *
 * \par
 *  <Longer description starts here>
 *
 * @return NA.
 *
 */
- (void)addFlowNodeToFlowManager:(FlowNode *)flowNode {
    //TODO : This has to be filled, once the flow manger is up.
    if (self.flowNodeDictionary == nil) {
        self.flowNodeDictionary = [[NSMutableDictionary alloc] init];
        
    }
    [self.flowNodeDictionary setObject:flowNode forKey:flowNode.flowId];
    
}

- (void)removeFlowNodeWithId:(NSString *)flowNodeId {
    [self.flowNodeDictionary removeObjectForKey:flowNodeId];
}
- (void)cancelFlowNodeWithId:(NSString *)flowNodeId {
    if (flowNodeId != nil) {
        FlowNode *flowNode  = [self.flowNodeDictionary objectForKey:flowNodeId];
        [flowNode cancelFlow];
    }
}
- (NSArray *) currentlyRunningOperations {
    NSMutableArray *array = nil;
    if ([self.flowNodeDictionary count] > 0) {
        
    array = [[NSMutableArray alloc] init];
    for (FlowNode *node in [self.flowNodeDictionary allValues])
        [array addObject:[NSNumber numberWithUnsignedInt:node.nodecategoryType]];
    }
    return array;
}
@end
