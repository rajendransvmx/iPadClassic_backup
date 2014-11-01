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

- (void)assignValueForPropety:(NSDictionary *)dict;

@end

static NSString *kValue                   = @"value";
static NSString *kKey                     = @"key";
static NSString *kAllowOverride           = @"allow_override";
static NSString *kDefaultOn               = @"default_on";
static NSString *kFieldName               = @"field_name";
static NSString *kIdentifier                      = @"id";
static NSString *kModule                  = @"module";
static NSString *kName                    = @"name";
static NSString *kParentObjectCriteria    = @"parent_object_criteria";
static NSString *kRuleType                = @"rule_type";
static NSString *kSequence                = @"sequence";
static NSString *kSourceObjectName        = @"source_object_name";
static NSString *kDescription             = @"description";

@implementation SFNamedSearchFilterModel 

@synthesize localId;
@synthesize Id;
@synthesize name;
@synthesize namedSearchId;
@synthesize ruleType;
@synthesize parentObjectCriteria;
@synthesize sourceObjectName;
@synthesize fieldName;
@synthesize sequence;
@synthesize advancedExpression;
@synthesize allowOverride;
@synthesize defaultOn;
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

/*To assign value to the proerty, accoding to the key*/
- (void)assignValueForPropety:(NSDictionary *)dict
{
    NSString *key = [dict objectForKey:kKey];
    NSString *value = [dict objectForKey:kValue];
    
    if ([key isEqualToString:kAllowOverride])
    {
        [self setAllowOverride:[value boolValue]];
    }
    else if ([key isEqualToString:kDefaultOn])
    {
        [self setDefaultOn:[value boolValue]];
    }
    else if ([key isEqualToString:kFieldName])
    {
        [self setFieldName:value];
    }
    else if ([key isEqualToString:kIdentifier])
    {
        [self setId:value];
    }
    else if ([key isEqualToString:kModule])
    {
        [self setNamedSearchId:value];
    }
    else if ([key isEqualToString:kName])
    {
        [self setName:value];
    }
    else if ([key isEqualToString:kParentObjectCriteria])
    {
        [self setParentObjectCriteria:value];
    }
    else if ([key isEqualToString:kRuleType])
    {
        [self setRuleType:value];
    }
    else if ([key isEqualToString:kSequence])
    {
        [self setSequence:value];
    }
    else if ([key isEqualToString:kSourceObjectName])
    {
        [self setSourceObjectName:value];
    }
    else if ([key isEqualToString:kDescription])
    {
        [self setDescription:value];
    }
}

- (void)dealloc
{
    Id = nil;
    name = nil;
    
    namedSearchId = nil;
    ruleType = nil;
	parentObjectCriteria = nil;
    sourceObjectName = nil;
    fieldName = nil;
    sequence = nil;
    advancedExpression = nil;
    description = nil;
}


@end