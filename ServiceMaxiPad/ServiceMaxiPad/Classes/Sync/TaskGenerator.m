//
//  TaskGenerator.m
//  ServiceMaxMobile
//
//  Created by Sahana on 12/08/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import "TaskGenerator.h"
#import "AppManager.h"


@implementation TaskGenerator
+(TaskModel *)generateTaskFor:(CategoryType)catogoryType requestParam:(RequestParamModel *)requestParam callerDelegate:(id)callerdelegate
{
    TaskModel * model = [[TaskModel alloc] initWitTaskId:[TaskGenerator generateTaskIdentifier]
                                        withCategoryType:catogoryType
                                            requestParam:requestParam
                                       andCallerDelegate:callerdelegate];
    return model;
}

+ (NSString *)generateTaskIdentifier
{
    return [AppManager generateUniqueId];
}

@end
