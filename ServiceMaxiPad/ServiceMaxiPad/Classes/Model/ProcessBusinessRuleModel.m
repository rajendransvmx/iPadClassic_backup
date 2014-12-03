//
//  BaseProcessBusinessRule.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   ProcessBusinessRuleModel.m
 *  @class  ProcessBusinessRuleModel
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

#import "ProcessBusinessRuleModel.h"

@implementation ProcessBusinessRuleModel 

@synthesize Id;
@synthesize businessRule;
@synthesize errorMessage;
@synthesize name;
@synthesize processNodeObject;
@synthesize sequence;
@synthesize targetManager;

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
    businessRule = nil;
	errorMessage = nil;
    name = nil;
	processNodeObject = nil;
    sequence = nil;
    targetManager = nil;
}

- (void)explainMe
{
    SXLogInfo(@"Id : %@ \n businessRule : %@ \n errorMessage : %@ \n name : %@ \n  processNodeObject : %@ \n sequence : %@ \n targetManager : %@ \n  ",  Id,businessRule, errorMessage, name,processNodeObject,sequence,targetManager);
}

+ (NSDictionary *) getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:kBizRulesId,@"Id",kBizRule,@"businessRule",kBizRulesErrorMsg,@"errorMessage",kBizRulesName,@"name",kBizRulesProcessNodeObject,@"processNodeObject",kBizRulesSequence,@"sequence",kBizRulesTargetManager,@"targetManager",nil];
    
    return mapDictionary;
}


@end