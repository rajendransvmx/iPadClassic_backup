//
//  TaskModel.h
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 11/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   TaskModel.h
 *  @class  TaskModel
 *
 *  @brief  Task model 
 *
 *  @author  Krishna Shanbhag
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/
#import <Foundation/Foundation.h>
#import "RequestParamModel.h"
#import "SyncConstants.h"



@interface TaskModel : NSObject

@property (nonatomic, copy)   NSString              *taskId;
@property (nonatomic, assign) CategoryType          categoryType;
@property (nonatomic, strong) RequestParamModel     *requestParamObj;
@property (nonatomic, assign) id                    callerDelegate;

-(id)initWitTaskId:(NSString *)taskId withCategoryType:(CategoryType)categoryType requestParam:(RequestParamModel *)requestParamObj andCallerDelegate:(id)delegate;
@end
