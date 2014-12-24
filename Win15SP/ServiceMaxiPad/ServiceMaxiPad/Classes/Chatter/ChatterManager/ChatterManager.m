//
//  ChatterManager.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 19/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ChatterManager.h"
#import "TaskGenerator.h"
#import "TaskModel.h"
#import "TaskManager.h"
#import "FlowDelegate.h"


@interface ChatterManager () <FlowDelegate>

@end

@implementation ChatterManager

- (void)getProductIamgeAndChatterPostDetails
{
    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeChatter
                                             requestParam:nil
                                           callerDelegate:self];
    
    [[TaskManager sharedInstance] addTask:taskModel];
    
}

- (void)flowStatus:(id)status
{
    
    
}


@end
