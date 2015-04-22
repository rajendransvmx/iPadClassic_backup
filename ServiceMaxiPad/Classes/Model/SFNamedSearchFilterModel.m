//
//  BaseSFNamedSearchFilters.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFNamedSearchFilterModel.m
 *  @class  SFNamedSearchFilterModel
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

#import "SFNamedSearchFilterModel.h"

@interface SFNamedSearchFilterModel ()

@end

static NSString *kValue                   = @"value";
static NSString *kKey                     = @"key";
static NSString *kAllowOverride           = @"allow_override";
static NSString *kDefaultOn               = @"default_on";
static NSString *kFieldName               = @"field_name";
static NSString *kIdentifier              = @"id";
static NSString *kModule                  = @"module";
static NSString *kName                    = @"name";
static NSString *kParentObjectCriteria    = @"parent_object_criteria";
static NSString *kRuleType                = @"rule_type";
static NSString *kSequence                = @"sequence";
static NSString *kSourceObjectName        = @"source_object_name";
static NSString *kDescription             = @"description";

@implementation SFNamedSearchFilterModel 

- (id)init
{
	self = [super init];
	if (self != nil)
    {
		//Initialization
	}
	return self;
}

+ (NSDictionary*)getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys: kSearchFiltrerId, @"Id", kSearchFilterName, @"name", kSearchFilterModuleId, @"namedSearchId",  kSearchFilterRuleType, @"ruleType",
        kSearchFilterParentObjectCriteria, @"parentObjectCriteria", kSearchFilterSourceObjectName, @"sourceObjectName", kSearchFilterFieldName, @"fieldName", kSearchFilterSequence, @"sequence",kSearchFilterAdvanceExpression, @"advancedExpression", kSearchFilterAllowOveride, @"allowOverride",
        kSaerchFilterDefaultOn, @"defaultOn", nil];
    
    return mapDictionary;
}
- (void)dealloc
{
    _Id = nil;
    _name = nil;
    _namedSearchId = nil;
    _ruleType = nil;
	_parentObjectCriteria = nil;
    _sourceObjectName = nil;
    _fieldName = nil;
    _sequence = nil;
    _advancedExpression = nil;
}


@end