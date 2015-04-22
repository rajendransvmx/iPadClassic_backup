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

@synthesize local_id;
@synthesize AuthorId;
@synthesize Body;
@synthesize BodyLength;
@synthesize ContentType;
@synthesize CreatedById;
@synthesize Description;
@synthesize DeveloperName;
@synthesize FolderId;
@synthesize Id;
@synthesize IsBodySearchable;
@synthesize IsDeleted;
@synthesize IsInternalUseOnly;
@synthesize IsPublic;
@synthesize Keywords;
@synthesize LastModifiedById;
@synthesize Name;
@synthesize NamespacePrefix;
@synthesize SystemModstamp;
@synthesize Type;

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
    AuthorId = nil;
	Body = nil;
    ContentType = nil;
    CreatedById = nil;
    Description = nil;
    DeveloperName = nil;
    FolderId = nil;
    Id = nil;
    Keywords = nil;
	LastModifiedById = nil;
    Name = nil;
    NamespacePrefix = nil;
    SystemModstamp = nil;
    Type = nil;
}

- (void)explainMe
{
    SXLogInfo(@"authorId : %@ \n body : %@ \n contentType : %@ \n createdById : %@ \n  description : %@ \n developerName : %@ \n folderId : %@ \n  idTable : %@ \n keywords : %@ \n lastModifiedById : %@ \n name : %@ \n namespacePrefix : %@ \n  systemModeStamp : %@ \n type : %@ \n",  AuthorId,Body, ContentType, CreatedById,Description,DeveloperName,FolderId,Id,Keywords,LastModifiedById,Name,NamespacePrefix, SystemModstamp ,Type);
}


+ (NSDictionary *) getMappingDictionary
{

    NSDictionary *mapDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"DeveloperName",@"DeveloperName",@"Name",@"Name",@"Id",@"Id",@"Type",@"Type",@"NamespacePrefix",@"NamespacePrefix",@"Keywords",@"Keywords",@"IsDeleted",@"IsDeleted",@"FolderId",@"FolderId",@"Description",@"Description",@"ContentType",@"ContentType",@"BodyLength",@"BodyLength",nil];
    return mapDictionary;
}

@end

/*
 
 FOR REFERENCE :
 ===============
 
 @"CREATE TABLE IF NOT EXISTS Document ('local_id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE DEFAULT (0), 'AuthorId' VARCHAR,
 'Body' VARCHAR, 'BodyLength' INTEGER, 'ContentType' VARCHAR, 'CreatedById' VARCHAR, 'Description' VARCHAR, 'DeveloperName' VARCHAR,
 'FolderId' VARCHAR, 'Id' VARCHAR, 'IsBodySearchable' BOOL, 'IsDeleted' BOOL, 'IsInternalUseOnly' BOOL, 'IsPublic' BOOL, 'Keywords' TEXT,
 'LastModifiedById' VARCHAR, 'LastModifiedDate' DATETIME, 'Name' VARCHAR, 'NamespacePrefix' VARCHAR,
 'SystemModstamp' VARCHAR, 'Type' VARCHAR)"

 */