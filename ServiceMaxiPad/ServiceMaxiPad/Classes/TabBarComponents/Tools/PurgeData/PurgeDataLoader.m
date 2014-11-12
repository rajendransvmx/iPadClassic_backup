//
//  PurgeDataLoader.m
//  ServiceMaxiPad
//
//  Created by Niraj Kumar on 11/1/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "PurgeDataLoader.h"
#import "TaskModel.h"
#import "TaskManager.h"
#import "TaskGenerator.h"


@implementation PurgeDataLoader


+ (void)makeRequestForFrequencyWithTheCallerDelegate:(id)delegate ForTheCategory:(CategoryType )category{
    
    TaskModel *taskModel = [TaskGenerator generateTaskFor:category
                                             requestParam:nil
                                           callerDelegate:delegate];
    
    [[TaskManager sharedInstance] addTask:taskModel];

}
@end
