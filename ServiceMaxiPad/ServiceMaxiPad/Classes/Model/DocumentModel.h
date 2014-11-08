//
//  BaseDocument.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   DocumentModel.h
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


@interface DocumentModel : NSObject

@property(nonatomic) NSInteger local_id;
@property(nonatomic) NSInteger BodyLength;

@property(nonatomic) BOOL IsBodySearchable;
@property(nonatomic) BOOL IsDeleted;
@property(nonatomic) BOOL IsInternalUseOnly;
@property(nonatomic) BOOL IsPublic;

@property(nonatomic, strong) NSString *AuthorId;
@property(nonatomic, strong) NSString *Body;
@property(nonatomic, strong) NSString *ContentType;
@property(nonatomic, strong) NSString *CreatedById;
@property(nonatomic, strong) NSString *Description;
@property(nonatomic, strong) NSString *DeveloperName;
@property(nonatomic, strong) NSString *FolderId;
@property(nonatomic, strong) NSString *Id;
@property(nonatomic, strong) NSString *Keywords;
@property(nonatomic, strong) NSString *LastModifiedById;
@property(nonatomic, strong) NSString *Name;
@property(nonatomic, strong) NSString *NamespacePrefix;
@property(nonatomic, strong) NSString *SystemModstamp;
@property(nonatomic, strong) NSString *Type;

- (id)init;

- (void)explainMe;

+ (NSDictionary *) getMappingDictionary;


@end