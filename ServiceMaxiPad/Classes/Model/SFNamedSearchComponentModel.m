//
//  BaseSFNamedSearchComponent.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFNamedSearchComponentModel.m
 *  @class  SFNamedSearchComponentModel
 *
 *  @brief
 *
 *   This is a model class which holds all the info.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

/* SFSearchObjectDetail */

#import "SFNamedSearchComponentModel.h"

@implementation SFNamedSearchComponentModel
@synthesize localId;
@synthesize expressionType;
@synthesize fieldName;
@synthesize namedSearchId;
@synthesize searchObjectFieldType;
@synthesize fieldDataType;
@synthesize fieldRelationshipName;
@synthesize sequence;
@synthesize keyNameField;

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
    expressionType = nil;
    fieldName = nil;
    namedSearchId = nil;
    searchObjectFieldType = nil;
    fieldDataType = nil;
    fieldRelationshipName = nil;
    keyNameField = nil;
    
}

- (void)explainMe {
    
    SXLogInfo(@"expressionType : %@ fieldName : %@ \n namedSearchId : %@ \n searchObjectFieldType : %@ \n fieldType : %@ \n fieldRelationshipName : %@ \n sequence : %f \n keyNameField: %@ \n", expressionType, fieldName, namedSearchId, searchObjectFieldType, fieldDataType, fieldRelationshipName, keyNameField, sequence);
}

+ (NSDictionary*)getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys: kNSComponentExpressionType, @"expressionType", kNSComponentFieldName, @"fieldName", kNSComponentNamedSearchId, @"namedSearchId", kNSComponentSearchFieldType, @"searchObjectFieldType", kNSComponentFieldDataType, @"fieldDataType", kNSComponentFieldRelation, @"fieldRelationshipName", kNSCompoentKeyNameField, @"keyNameField", kNSComponentSequence, @"sequence",nil];
    
    return mapDictionary;
}

@end