//
//  BaseSFProcess_test.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFProcessTestModel.m
 *  @class  SFProcessTestModel
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

#import "SFProcessTestModel.h"

@interface SFProcessTestModel ()

/*To assign value to the proerty, accoding to the key*/
- (void)assignValueForPropety:(NSDictionary *)dict;

@end

static NSString *kValue                   = @"value";
static NSString *kKey                     = @"key";
static NSString *kObjectName              = @"object_name";
static NSString *kEnableAttachment        = @"enable_attachment";
static NSString *kComponentType           = @"component_type";
static NSString *kTargetObject            = @"target_object_label";
static NSString *kProcessId               = @"process_id";
static NSString *kSfId                    = @"local_id";
static NSString *kLayoutId                = @"layout_id";
static NSString *kNodeParentName          = @"node_parent_api";
static NSString *kExpressionIdentifier    = @"expression_id";
static NSString *kValueMapId              = @"value_mapping_id";
static NSString *kParentObject            = @"parent_object";
static NSString *kSortingOrder            = ORG_NAME_SPACE@"__Values__c";
static NSString *kDocTemplateDetailId     = @"doc_template_Detail_id";
static NSString *kParentColumn            = @"parent_column";

@implementation SFProcessTestModel

@synthesize processId;
@synthesize layoutId;
@synthesize objectName;
@synthesize expressionId;
@synthesize objectMappingId;
@synthesize componentType;
@synthesize localId;
@synthesize parentColumn;
@synthesize valueId;
@synthesize parentObject;
@synthesize sortingOrder;
@synthesize processNodeId;
@synthesize docTemplateDetailId;
@synthesize targetObjectLabel;
@synthesize sfID;
@synthesize enable_attachment;

- (id)init
{
	self = [super init];
	if (self != nil)
    {
		//Initialization
	}
	return self;
}


/* initialize the values to the respective property using array*/
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
    
    
    if ([key isEqualToString:kObjectName])
    {
        [self setObjectName:value];
    }
    else if ([key isEqualToString:kEnableAttachment])
    {
        BOOL boolValue = [value boolValue];
        
        [self setEnable_attachment:boolValue];
    }
    else if ([key isEqualToString:kComponentType])
    {
        [self setComponentType:value];
    }
    else if ([key isEqualToString:kTargetObject])
    {
        [self setTargetObjectLabel:value];
    }
    else if ([key isEqualToString:kProcessId])
    {
        [self setProcessId:value];
    }
    else if ([key isEqualToString:kSfId])
    {
        [self setSfID:value];
    }
    else if ([key isEqualToString:kLayoutId])
    {
        [self setLayoutId:value];
    }
    else if ([key isEqualToString:kNodeParentName])
    {
        [self setProcessNodeId:value];
    }
    else if ([key isEqualToString:kExpressionIdentifier])
    {
        [self setExpressionId:value];
    }
    else if ([key isEqualToString:kValueMapId])
    {
        [self setValueId:value];
    }
    else if ([key isEqualToString:kParentObject])
    {
        [self setParentObject:value];
    }
    else if ([key isEqualToString:kSortingOrder])
    {
        [self setSortingOrder:value];
    }
    else if ([key isEqualToString:kDocTemplateDetailId])
    {
        [self setDocTemplateDetailId:value];
    }
    else if ([key isEqualToString:kParentColumn])
    {
        [self setParentColumn:value];
    }
}

- (void)dealloc
{
	processId = nil;
    layoutId = nil;
	objectName = nil;
	expressionId = nil;
	objectMappingId = nil;
    componentType = nil;
    parentColumn = nil;
    valueId = nil;
    parentObject = nil;
    sortingOrder = nil;
    processNodeId = nil;
    docTemplateDetailId = nil;
    targetObjectLabel = nil;
    sfID = nil;
}


@end