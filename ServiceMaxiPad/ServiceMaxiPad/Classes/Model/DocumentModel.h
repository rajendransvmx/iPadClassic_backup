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

@property(nonatomic) NSInteger localId;
@property(nonatomic) NSInteger bodyLength;

@property(nonatomic) BOOL isBodySearchable;
@property(nonatomic) BOOL isDeleted;
@property(nonatomic) BOOL isInternalUseOnly;
@property(nonatomic) BOOL isPublic;

@property(nonatomic, strong) NSString *authorId;
@property(nonatomic, strong) NSString *body;
@property(nonatomic, strong) NSString *contentType;
@property(nonatomic, strong) NSString *createdById;
@property(nonatomic, strong) NSString *description;
@property(nonatomic, strong) NSString *developerName;
@property(nonatomic, strong) NSString *folderId;
@property(nonatomic, strong) NSString *Id;
@property(nonatomic, strong) NSString *keywords;
@property(nonatomic, strong) NSString *lastModifiedById;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *namespacePrefix;
@property(nonatomic, strong) NSString *systemModeStamp;
@property(nonatomic, strong) NSString *type;

- (id)init;

- (void)explainMe;

+ (NSDictionary *) getMappingDictionary;


@end