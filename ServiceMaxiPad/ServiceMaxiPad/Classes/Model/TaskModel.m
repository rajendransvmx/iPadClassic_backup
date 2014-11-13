//
//  TaskModel.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 11/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   TaskModel.m
 *  @class  TaskModel
 *
 *  @brief  Implementation for Task model
 *
 *  @author  Krishna Shanbhag
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/
#import "TaskModel.h"

@implementation TaskModel

-(id)initWitTaskId:(NSString *)taskId withCategoryType:(CategoryType)categoryType requestParam:(RequestParamModel *)requestParamObj andCallerDelegate:(id)delegate
{
    self = [super init];
    if(self != nil)
    {
        self.taskId = taskId;
        self.categoryType = categoryType;
        self.requestParamObj= requestParamObj;
        self.callerDelegate = delegate;
    }
    
    return self;
}

@end
