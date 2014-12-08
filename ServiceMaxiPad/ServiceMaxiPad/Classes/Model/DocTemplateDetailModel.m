//
//  BaseDOC_TEMPLATE_DETAILS.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//



/**
 *  @file   DocTemplateDetailModel.m
 *  @class  DocTemplateDetailModel
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


#import "DocTemplateDetailModel.h"


@implementation DocTemplateDetailModel 

@synthesize docTemplate;
@synthesize docTemplateDetailId;
@synthesize headerReferenceField;
@synthesize alias;
@synthesize objectName;
@synthesize soql;
@synthesize docTemplateDetailUniqueId;
@synthesize fields;
@synthesize type;
@synthesize idTable;

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
    docTemplate = nil;
    docTemplateDetailId = nil;
    headerReferenceField = nil;
    alias = nil;
    objectName = nil;
    soql = nil;
	docTemplateDetailUniqueId = nil;
    fields = nil;
    type = nil;
    idTable = nil;
}

- (void)explainMe
{
    SXLogInfo(@"docTemplate : %@ \n docTemplateDetailId : %@ \n headerReferenceField : %@ \n alias : %@ \n  objectName : %@ \n soql : %@ \n docTemplateDetailUniqueId : %@ \n  fields : %@ \n type : %@ \n idTable : %@ \n",  docTemplate,docTemplateDetailId, headerReferenceField, alias,objectName,soql,docTemplateDetailUniqueId,fields,type,idTable);
}

+ (NSDictionary*)getMappingDictionary {
    
    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:kDocTempDetailDocTemplate, @"docTemplate", kDocTempDetailId, @"docTemplateDetailId", kDocTempDetailheaderRefField, @"headerReferenceField", kDocTempDetailalias, @"alias", kDocTempDetailobjectName, @"objectName", kDocTempDetailsoql, @"soql", kDocTempDetailUniqueId, @"docTemplateDetailUniqueId", kDocTempDetailfields, @"fields", kDocTempDetailtype, @"type", kDocTempDetailidTable, @"idTable", nil];
    
    return mapDictionary;
}

@end