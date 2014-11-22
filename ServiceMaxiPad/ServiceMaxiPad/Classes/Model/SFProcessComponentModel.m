//
//  BaseSFProcessComponent.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFProcessComponentModel.m
 *  @class  SFProcessComponentModel
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

#import "SFProcessComponentModel.h"
#import "ResponseConstants.h"
@implementation SFProcessComponentModel 

@synthesize  processId;
@synthesize layoutId;
@synthesize objectName;
@synthesize sourceObjectName;
@synthesize expressionId;
@synthesize objectMappingId;
@synthesize componentType;
@synthesize parentColumnName;
@synthesize valueMappingId;
@synthesize sortingOrder;
@synthesize processNodeId;
@synthesize docTemplateDetailId;
@synthesize targetObjectLabel;
@synthesize sfId;
@synthesize parentObjectId;
@synthesize parentObjectName;
@synthesize enableAttachment;
@synthesize localId;


- (id)init
{
	self = [super init];
	if (self != nil)
    {
		//Initialization
	}
	return self;
}


+ (NSDictionary *) getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:kPCompSFId,@"sfId",
                                    kPCompProcessId,@"processId",
                                    kPCompPageLayout,@"layoutId",
                                    kPCompObjectName,@"objectName",
                                    kPCompEntryCriteria,@"expressionId",
                                    kPCompObjectMappingId,@"objectMappingId",
                                    kPCompType,@"componentType",
                                    kPCompParentColumnName,@"parentColumnName",
                                    kPCompValueMappingId,@"valueMappingId",
                                    kPCompValuesC,@"sortingOrder",
                                   kPCompProcessNodeId,@"processNodeId",
                                   kPCompDocTemplateId,@"docTemplateDetailId",
                                   kPCompTargetObjLabel,@"targetObjectLabel",
                                   kPCompEnableAttachment,@"enableAttachment",
                                   kPCompSequence,@"sequence",
                                   kPCompParentObjectName,@"parentObjectName",
                                   kPCompParentNodeId,@"parentObjectId",
                                   
                                   nil];
    
    return mapDictionary;
}

@end