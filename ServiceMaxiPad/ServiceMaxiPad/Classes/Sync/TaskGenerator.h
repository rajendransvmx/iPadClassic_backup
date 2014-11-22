//
//  TaskGenerator.h
//  ServiceMaxMobile
//
//  Created by Sahana on 12/08/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskModel.h"
#import "RequestParamModel.h"

@interface TaskGenerator : NSObject

+(TaskModel *)generateTaskFor:(CategoryType)catogoryType
                 requestParam:(RequestParamModel *)requestParam
               callerDelegate:(id)callerdelegate;
@end
