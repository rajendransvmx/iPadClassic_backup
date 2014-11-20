//
//  BaseSFM_Search_Field.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFMSearchFieldModel.m
 *  @class  SFMSearchFieldModel
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

#import "SFMSearchFieldModel.h"
#import "ResponseConstants.h"

@implementation SFMSearchFieldModel 

@synthesize localId;
@synthesize identifier;
@synthesize displayType;
@synthesize expressionRule;
@synthesize fieldName;
@synthesize objectName;
@synthesize fieldType;
@synthesize objectID;
@synthesize lookupFieldAPIName;
@synthesize fieldRelationshipName;
@synthesize relatedObjectName;
@synthesize sortOrder;
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

+ (NSDictionary *)getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:
                                   
                                   kSearchDetailSFID,@"identifier",
                                   kSearchDisplayType,@"displayType",
                                   kSearchExpRule,@"expressionRule",
                                   kSearchFieldName,@"fieldName",
                                   kSearchObjName2,@"objectName",
                                   kSearchObjFieldType,@"fieldType",
                                   kSearchExpRule,@"objectID",
                                   kSearchLookupFieldApiName,@"lookupFieldAPIName",
                                   kSearchFieldRelationShipName,@"fieldRelationshipName",
                                   kSearchObjName,@"relatedObjectName",
                                   kSearchSortOrder,@"sortOrder",
                                   kSearchCriteriaSequence,@"sequence",
                                   nil];
    
    return mapDictionary;
}



- (NSString *)getDisplayField {
    
    NSString *disFieldName = self.fieldName;
    if (self.lookupFieldAPIName.length > 2) {
        disFieldName = [NSString stringWithFormat:@"%@.%@",self.objectName,self.fieldName];
    }
    return disFieldName;
}


@end