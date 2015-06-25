//
//  BaseBusinessRule.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   BusinessRuleModel.m
 *  @class  BusinessRuleModel
 *
 *  @brief 
 *
 *   This is a modle class which holds all the info.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "BusinessRuleModel.h"
#import "ResponseConstants.h"

@implementation BusinessRuleModel 

@synthesize Id;
@synthesize advancedExpression;
@synthesize description;
@synthesize errorMessage;
@synthesize messageType;
@synthesize name;
@synthesize processId;
@synthesize sourceObjectName;
@synthesize ruleType;

- (id)init
{
	self = [super init];
	if (self != nil)
    {
		//Initialization 
	}
	return self;
}

- (void)dealloc
{
    Id = nil;
    advancedExpression = nil;
    description = nil;
    errorMessage = nil;
    messageType = nil;
	name = nil;
    processId = nil;
    sourceObjectName = nil;
    ruleType = nil;
}

- (void)explainMe
{
    SXLogInfo(@"Id : %@ \n advancedExpression : %@ \n description : %@ \n errorMessage : %@ \n  messageType : %@ \n name : %@ \n processId : %@ \n  sourceObjectName : %@ \n bizRuleType : %@ \n",  Id,advancedExpression, description, errorMessage,messageType,name,processId,sourceObjectName,ruleType);
}


+ (NSDictionary *) getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:kBizRulesId,@"Id",kBizRulesAdvExpression,@"advancedExpression",kBizRulesDescription,@"description",kBizRulesErrorMsg,@"errorMessage",kBizRulesMsgType,@"messageType",kBizRulesName,@"name",kBizRulesDescription,@"processId",kBizRulesSrcObjectName,@"sourceObjectName", kBizRulesRuleType,@"ruleType", nil];
    
    return mapDictionary;
}




@end