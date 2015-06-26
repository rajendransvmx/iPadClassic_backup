//
//  BaseSFExpressionComponent.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFExpressionComponentModel.m
 *  @class  SFExpressionComponentModel
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

#import "SFExpressionComponentModel.h"
#import "ResponseConstants.h"

@interface SFExpressionComponentModel ()

/*To assign value to the proerty, accoding to the key*/
- (void)assignValueForPropety:(NSDictionary *)dict;

@end

static NSString *kValue                   = @"value";
static NSString *kKey                     = @"key";
static NSString *kExpressionIdentifier    = @"expression_id";
static NSString *kSequence                = @"sequence";
static NSString *kSourceFieldName         = @"source_field_name";
static NSString *kFieldType               = @"field_type";
static NSString *kComponentRhs            = @"value";
static NSString *kExpressionType          = @"expression_type";
static NSString *kParameterType           = @"parameter_type";
static NSString *kOperator                = @"operator";
static NSString *kFormula                = @"formula";
static NSString *kActionType                = @"action_type";

@implementation SFExpressionComponentModel 

@synthesize localId;
@synthesize expressionId;
@synthesize componentSequenceNumber;
@synthesize componentLHS;
@synthesize componentRHS;
@synthesize fieldType;
@synthesize expressionType;
@synthesize parameterType;
@synthesize operatorValue;
@synthesize formula;
@synthesize actionType;
@synthesize description;

- (id)init
{
	self = [super init];
	if (self != nil)
    {
		//Initialization
	}
	return self;
}

- (id)initWithArray:(NSArray *)dataArray;
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


- (void)assignValueForPropety:(NSDictionary *)dict
{
    NSString *key = [dict objectForKey:kKey];
    NSString *value = [dict objectForKey:kValue];
    
    if ([key isEqualToString:kExpressionIdentifier])
    {
        [self setExpressionId:value];
    }
    else if([key isEqualToString:kSequence])
    {
        double doubleValue = [value doubleValue];
        [self setComponentSequenceNumber:doubleValue];
    }
    else if([key isEqualToString:kSourceFieldName])
    {
        [self setComponentLHS:value];
    }
    else if([key isEqualToString:kFieldType])
    {
        [self setFieldType:value];
    }
    else if([key isEqualToString:kComponentRhs])
    {
        [self setComponentRHS:value];
    }
    else if([key isEqualToString:kExpressionType])
    {
        [self setExpressionType:value];
    }
    else if([key isEqualToString:kParameterType])
    {
        [self setParameterType:value];
    }
    else if([key isEqualToString:kOperator])
    {
        [self setOperatorValue:value];
    }
    else if([key isEqualToString:kFormula])
    {
        [self setFormula:value];
    } else if([key isEqualToString:kActionType])
    {
        [self setActionType:value];
    }
}

+ (NSDictionary *)getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   kExpressionCompExprRule,@"expressionId",
                                   kExpressionCompSequence,@"componentSequenceNumber",
                                   kExpressionCompFieldName,@"componentLHS",
                                   kExpressionCompOperand,@"componentRHS",
                                   kExpressionCompOperator,@"operatorValue",
                                   kExpressionCompDisplayType,@"fieldType",
                                   kExpressionCompExprtype,@"expressionType",
                                   kExpressionCompParentType,@"parameterType",
                                   kExpressionCompActionType,@"actionType",
                                   kExpressionCompFormula,@"formula",
                                   kExpressionCompDescription,@"description", nil];
    
    return mapDictionary;
}

- (void)dealloc
{
    expressionId = nil;
    componentLHS = nil;
    componentRHS = nil;
    fieldType = nil;
	expressionType = nil;
    parameterType = nil;
    actionType = nil;
    formula = nil;
    description = nil;

	//[super dealloc];
}


@end