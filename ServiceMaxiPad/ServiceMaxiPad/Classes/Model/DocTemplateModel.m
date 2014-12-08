//
//  BaseDOC_TEMPLATE.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   DocTemplateModel.m
 *  @class  DocTemplateModel
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

#import "DocTemplateModel.h"

@implementation DocTemplateModel 

@synthesize docTemplateName;
@synthesize idTable;
@synthesize docTemplateId;
@synthesize isStandard;
@synthesize detailObjectCount;
@synthesize mediaResources;

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
	docTemplateName = nil;
	idTable = nil;
	docTemplateId = nil;
	mediaResources = nil;
}

- (void)explainMe
{
    SXLogInfo(@"docTemplateName : %@ \n idTable : %@ \n docTemplateId : %@ \n isStandard : %d \n detailObjectCount : %d \n mediaResources : %@ \n  ", docTemplateName,idTable, docTemplateId, isStandard, detailObjectCount,mediaResources);
}

+ (NSDictionary*)getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys: kDocTemplateName, @"docTemplateName", kDocTemplateTableId, @"idTable", kDocTemplateId, @"docTemplateId", kDocTemplateIsStandard, @"isStandard", kDocTemplateDetailObjectCount, @"detailObjectCount", kDocTemplateMediaResources, @"mediaResources", nil];
    return mapDictionary;
}

@end