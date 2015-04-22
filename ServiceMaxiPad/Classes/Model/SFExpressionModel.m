//
//  BaseSFExpression.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFExpressionModel.m
 *  @class  SFExpressionModel
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

#import "SFExpressionModel.h"
#import "ResponseConstants.h"

@interface SFExpressionModel ()
/*To assign value to the proerty, accoding to the key*/
- (void)assignValueForPropety:(NSDictionary *)dict;

@end

static NSString *kValue                   = @"value";
static NSString *kKey                     = @"key";
static NSString *kExpressionIdentifier    = @"expression_id";
static NSString *kExpressionName          = @"expression_name";
static NSString *kAdvanceExpression       = @"advance_expression";
static NSString *kErrorMessage            = @"error_message";

@implementation SFExpressionModel 

@synthesize localId;
@synthesize expressionId;
@synthesize expression;
@synthesize expressionName;
@synthesize errorMessage;
@synthesize sourceObjectName;
@synthesize sequence;

- (id)init
{
	self = [super init];
	if (self != nil)
    {
		//Initialization
	}
	return self;
}

- (id)initWithArray:(NSArray *)dataArray
{
    self = [super init];
	if (self != nil)
    {
        for (NSDictionary * dict in dataArray)
        {
            [self assignValueForPropety:dict];
        }
	}
	return self;
}

+ (NSDictionary *)getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:kExpressionId,@"expressionId",kExpressionProcessId,@"expressionName",kExpressionSourceObjName,@"sourceObjectName", kExpressionSequence,@"sequence",kExpressionAdvExpression,@"expression",kExpressionErrorMsg,@"errorMessage",nil];
    
    return mapDictionary;
}


- (void)assignValueForPropety:(NSDictionary *)dict
{
    NSString *key = [dict objectForKey:kKey];
    NSString *value = [dict objectForKey:kValue];
    
    if ([key isEqualToString:kExpressionIdentifier])
    {
        [self setExpressionId:value];
    }
    else if ([key isEqualToString:kExpressionName])
    {
        [self setExpressionName:value];
    }
    else if ([key isEqualToString:kAdvanceExpression])
    {
        [self setExpression:value];
    }
    else if ([key isEqualToString:kErrorMessage])
    {
        [self setErrorMessage:value];
    }
}


- (void)dealloc
{
    expressionId = nil;
    expression = nil;
	expressionName = nil;
    errorMessage = nil;
    sourceObjectName = nil;
    sequence = nil;
	//[super dealloc];
}


@end