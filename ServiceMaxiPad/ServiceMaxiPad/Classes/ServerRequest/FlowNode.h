//
//  FlowNode.h
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 31/05/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskModel.h"
#import "SVMXServerRequest.h"
#import "FlowDelegate.h"

typedef NS_ENUM(NSUInteger, NodeStatus)
{
    NodeStatusYetToStart = 1, /** Yet to start flow */
    NodeStatusInprogress = 2, /** In Progress */
    NodeStatusCompleted  = 3, /** Flow Completed */
    NodeStatusCancelled  = 4, /** Cancelled */
    NodeStatusDisallowed = 5, /** This status indicates that flow not allowed to execute */
    NodeStatusPaused     = 6, /** Flow paused by flow manager incase of higher priority flow induced */
};


@class RequestParamModel;

@protocol FlowDelegate;


@interface FlowNode : NSObject <SVMXRequestDelegate>


@property (nonatomic) NodeStatus nodeStatus;

@property (nonatomic, copy)   NSString          *name;

/** TODO : Changes needs to be done */

@property (nonatomic, copy)   NSString          *flowId;
@property (nonatomic, assign) CategoryType      nodecategoryType;
@property (nonatomic, weak)   id                callerDelegate;
@property (nonatomic, strong) RequestParamModel *requestParam;

@property (nonatomic, strong) FlowNode *next;
@property (nonatomic, strong) FlowNode *parallel;

@property (nonatomic, strong) NSMutableDictionary *requestDict;


- (id)initWithTask:(id)task;

- (BOOL)isTail;

- (BOOL)isParallelNodeStarter;

- (BOOL)isHead;

- (void)setAsHead:(BOOL)headNode;

- (void)startFlow;

@end
