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
    // BUG:018451
    // key has to be the previous failed onecalldatasync. The taskID is used as identifier which the server remembers. So send the previously failed onecall request's id.
    NSString *uniqueKey = nil;
    if (catogoryType == CategoryTypeOneCallDataSync) {
        
        uniqueKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"requestIdentifier"];
        if (!uniqueKey && uniqueKey.length==0) {
            uniqueKey = [TaskGenerator generateTaskIdentifier];
        }
    }
    else
    {
        uniqueKey = [TaskGenerator generateTaskIdentifier];
    }
    
    
    TaskModel * model = [[TaskModel alloc] initWitTaskId:uniqueKey
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
