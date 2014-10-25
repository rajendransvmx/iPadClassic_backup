//
//  BaseDocument.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   DocumentModel.m
 *  @class  DocumentModel
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



#import "DocumentModel.h"

@implementation DocumentModel 

@synthesize localId;
@synthesize authorId;
@synthesize body;
@synthesize bodyLength;
@synthesize contentType;
@synthesize createdById;
@synthesize description;
@synthesize developerName;
@synthesize folderId;
@synthesize Id;
@synthesize isBodySearchable;
@synthesize isDeleted;
@synthesize isInternalUseOnly;
@synthesize isPublic;
@synthesize keywords;
@synthesize lastModifiedById;
@synthesize name;
@synthesize namespacePrefix;
@synthesize systemModeStamp;
@synthesize type;

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
    authorId = nil;
	body = nil;
    contentType = nil;
    createdById = nil;
    description = nil;
    developerName = nil;
    folderId = nil;
    Id = nil;
    keywords = nil;
	lastModifiedById = nil;
    name = nil;
    namespacePrefix = nil;
    systemModeStamp = nil;
    type = nil;
}

- (void)explainMe
{
    NSLog(@"authorId : %@ \n body : %@ \n contentType : %@ \n createdById : %@ \n  description : %@ \n developerName : %@ \n folderId : %@ \n  idTable : %@ \n keywords : %@ \n lastModifiedById : %@ \n name : %@ \n namespacePrefix : %@ \n  systemModeStamp : %@ \n type : %@ \n",  authorId,body, contentType, createdById,description,developerName,folderId,Id,keywords,lastModifiedById,name,namespacePrefix,systemModeStamp,type);
}


+ (NSDictionary *) getMappingDictionary
{

    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"DeveloperName",@"developerName",@"Name",@"name",@"Id",@"Id",@"Type",@"type",@"namespacePrefix",@"NamespacePrefix",@"Keywords",@"keywords",@"IsDeleted",@"isDeleted",@"FolderId",@"folderId",@"Description",@"description",@"ContentType",@"contentType",@"BodyLength",@"BodyLength",nil];
    return mapDictionary;
}

@end