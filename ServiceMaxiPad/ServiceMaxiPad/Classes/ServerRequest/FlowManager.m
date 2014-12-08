//
//  FlowManager.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 6/1/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   FlowManager.m
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


#import "FlowManager.h"
#import "FlowNode.h"
#import "RuleManager.h"

@interface FlowManager()
{
   
}

@property (nonatomic, strong) FlowNode *currentFlow;
@property (nonatomic)BOOL shouldCancellAllFlow;

@end


@implementation FlowManager

@synthesize currentFlow;

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
    currentFlow = nil;
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}


- (BOOL)cancelRequestByRequestIdentifier:(NSString *)identifier
{
    return YES;
}

- (BOOL)pauseRequestByRequestIdentifier:(NSString *)identifier
{
    return YES;
}


- (void)addRequest:(id)request
{
   
}

- (BOOL)isEmptyFlow
{
    if(self.currentFlow == nil)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (void)cancelAllFlow:(BOOL)cancel
{
    self.shouldCancellAllFlow = cancel;
}


- (FlowNode *)getMasterFlow
{
    FlowNode *masterFlow = nil;
    
    if ([self isEmptyFlow])
    {
        return masterFlow;
    }
    else
    {
        if ([self.currentFlow isHead])
        {
            masterFlow = self.currentFlow;
        }
        else
        {
             masterFlow = self.currentFlow;
            
            if ([self.currentFlow parallel] != nil)
            {
                masterFlow = [self.currentFlow parallel];
            }
        }
    }
    
    return masterFlow;
}


- (void)removeFlow:(FlowNode *)flowNode
{
    
}

- (void)removeCompletedFlow:(FlowNode *)flowNode
{
    
}

- (void)removeCandcelledFlow:(FlowNode *)flowNode
{
    
}


- (void)manageFlow
{
    [self startTraverse];
}

- (void)startTraverse
{
    if (self.currentFlow == nil)
    {
        return;
    }
    else
    {
        
    }
}


- (instancetype)generateFlowForRequest:(id)request
{
    return nil;
}

- (void)setAsParallelFlow:(FlowNode *)flowNode toParentFlow:(FlowNode *)parentFlow
{
    if (parentFlow.parallel == nil )
    {
        parentFlow.parallel = flowNode;
    }
    else
    {
        [self setAsParallelFlow:flowNode
                   toParentFlow:parentFlow.next];
    }
    return;
}

- (void)pauseFlow:(FlowNode *)flow
{
    if ([flow parallel] != nil)
    {
        [self pauseFlow:[flow parallel]];
    }
    
    if ([flow  nodeStatus] == NodeStatusInprogress)
    {
        [flow setNodeStatus:NodeStatusPaused];
    }
}

- (NSString *)actionNameFromStartFlow:(FlowNode *)startFlow toNextFlow:(FlowNode *)nextFlow
{
    return [[RuleManager sharedInstance] actionNameByPlacedFlowName:[startFlow name]
                                            withIncomingFlow:[nextFlow name]];
    
}

- (void)injectFlow:(FlowNode *)flowNode  withHeadFlow:(FlowNode *)headFlow  andTailFlow:(FlowNode *)tailFlow
{
    if (headFlow == nil)
    {
        headFlow = flowNode;
    }
    else
    {
        NSString *actionName = [self actionNameFromStartFlow:headFlow
                                                  toNextFlow:flowNode];
        
        if ([actionName caseInsensitiveCompare:kFlowActionNext] == NSOrderedSame)
        {
            if (tailFlow == nil)
            {
                tailFlow = flowNode;
            }
            else
            {
                NSString *nextActionName = [self actionNameFromStartFlow:tailFlow
                                                              toNextFlow:flowNode];
                
                
                if ([nextActionName caseInsensitiveCompare:kFlowActionNext] == NSOrderedSame)
                {
                    [self injectFlow:flowNode withHeadFlow:tailFlow andTailFlow:tailFlow.next];
                }
                else if ([nextActionName caseInsensitiveCompare:kFlowActionImmediate] == NSOrderedSame)
                {
                    /** Insert in the middle of flow */
                    
                    FlowNode *tempFlow = headFlow.next;
                    headFlow.next = flowNode;
                    flowNode.next = tempFlow;
                }
                
                nextActionName = nil;
            }
        }
        else if ([actionName caseInsensitiveCompare:kFlowActionImmediate] == NSOrderedSame)
        {
            /** Insert in the begining of current flow */
            [self pauseFlow:headFlow];
            flowNode.next = headFlow;
            
        }
        else if ([actionName caseInsensitiveCompare:kFlowActionParallel] == NSOrderedSame)
        {
            // Set Flow is Parallel to current flow
            [self setAsParallelFlow:flowNode
                       toParentFlow:headFlow];
        }
        else
        {
            // Flow is not allowed in this sequences... So marking for destroying
            
            [flowNode setNodeStatus:NodeStatusDisallowed];
        }
        
        actionName = nil;
    }
    
    return;
}


- (void)insertFlow:(FlowNode *)incomingFlow
{
    if (incomingFlow != nil)
    {
        [incomingFlow setNodeStatus:NodeStatusYetToStart];
    }
    
    FlowNode *tailFlow = nil;

    if (self.currentFlow != nil)
    {
       tailFlow = self.currentFlow.next;
    }

    [self injectFlow:incomingFlow withHeadFlow:self.currentFlow andTailFlow:tailFlow];

    @autoreleasepool
    {
        if ([incomingFlow nodeStatus] == NodeStatusDisallowed)
        {
            incomingFlow = nil;
        }
    }
}

- (void)cancelOrCompleteFlow:(FlowNode *)flow
{
    if ( ([flow nodeStatus] == NodeStatusCancelled) || ([flow nodeStatus] == NodeStatusCompleted))
    {
        if ([flow isHead])
        {
            if (flow.parallel != nil)
            {
                FlowNode *parallelFlow  = flow.parallel;
                parallelFlow.next = flow.next;
                [parallelFlow setAsHead:YES];
                [self setCurrentFlow:parallelFlow];
                [self cancelOrCompleteFlow:parallelFlow];
                flow = nil;
                return;
            }
            else
            {
                if (flow.next != nil)
                {
                    FlowNode *nextFlow  = flow.next;
                    nextFlow.next = flow.next;
                    [self cancelOrCompleteFlow:nextFlow];
                }
            }
        }
    }
    
}

- (void)manageFlowIncaseOfJobCompletionOrCancellation
{
    if (![self isEmptyFlow])
    {
        FlowNode *rootFlow = self.currentFlow;
        [self cancelOrCompleteFlow:rootFlow];
    }
}

- (void)addFlow:(FlowNode *)flowNode
{
    if (flowNode != nil)
    {
        [self insertFlow:flowNode];
    }
}

- (BOOL)cancelFlowByFlowIdentifier:(NSString *)identifier
{
    return YES;
}

- (BOOL)pauseFlowByFlowIdentifier:(NSString *)identifier
{
    return YES;
}


@end
