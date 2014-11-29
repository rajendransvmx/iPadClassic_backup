//
//  BaseSFM_Search_Filter_Criteria.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFMSearchFilterCriteriaModel.m
 *  @class  SFMSearchFilterCriteriaModel
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

#import "SFMSearchFilterCriteriaModel.h"

@implementation SFMSearchFilterCriteriaModel 

@synthesize identifier;
@synthesize displayType;
@synthesize expressionRule;
@synthesize fieldName;
@synthesize objectName2;
@synthesize operand;
@synthesize operatorValue;
@synthesize objectID;
@synthesize lookupFieldAPIName;
@synthesize fieldRelationshipName;
@synthesize objectName;
@synthesize sequence;

+ (NSDictionary *)getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:
                                   
                                   
                                   kSearchDetailSFID,@"identifier",
                                   kSearchCriteriaSequence,@"sequence",
                                   kSearchDisplayType,@"displayType",
                                   kSearchExpRule,@"expressionRule",
                                   kSearchFieldName,@"fieldName",
                                   kSearchObjName2,@"objectName2",
                                   kSearchOperand,@"operand",
                                   kSearchOperator,@"operatorValue",
                                   kSearchLookupFieldApiName,@"lookupFieldAPIName",
                                   kSearchFieldRelationShipName,@"fieldRelationshipName",
                                   nil];
    
    return mapDictionary;
}
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
    identifier = nil;
    displayType = nil;
    expressionRule = nil;
    fieldName = nil;
    objectName2 = nil;
    operand = nil;
    operatorValue = nil;
    objectID = nil;
    lookupFieldAPIName = nil;
    fieldRelationshipName = nil;
    objectName = nil;
    sequence = nil;
}


@end