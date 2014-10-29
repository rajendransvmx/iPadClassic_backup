//
//  BaseSFM_Search_Field.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFMSearchFieldModel.h
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
//NSString *const kTableSFMSearchFieldSchema = @"CREATE TABLE IF NOT EXISTS SFM_Search_Field ('localId' INTEGER PRIMARY KEY NOT NULL DEFAULT (0), 'identifier' VARCHAR, 'displayType' VARCHAR, 'expressionRule' VARCHAR, 'fieldName' VARCHAR, 'objectName2' VARCHAR, 'fieldType' VARCHAR, 'objectID' VARCHAR, 'lookupFieldAPIName' VARCHAR, 'fieldRelationshipName' VARCHAR, 'objectName' VARCHAR, 'sortOrder' VARCHAR, 'sequence' DOUBLE)";

//Krishna : changed the schema (objectName2 to ObjectName, ObjectName to relatedObjectName)

@interface SFMSearchFieldModel : NSObject
@property(nonatomic) NSInteger localId;
@property(nonatomic, strong) NSString *identifier;
@property(nonatomic, strong) NSString *displayType;
@property(nonatomic, strong) NSString *expressionRule;
@property(nonatomic, strong) NSString *fieldName;
@property(nonatomic, strong) NSString *objectName;
@property(nonatomic, strong) NSString *fieldType;
@property(nonatomic, strong) NSString *objectID;
@property(nonatomic, strong) NSString *lookupFieldAPIName;
@property(nonatomic, strong) NSString *fieldRelationshipName;
@property(nonatomic, strong) NSString *relatedObjectName;
@property(nonatomic, strong) NSString *sortOrder;
@property(nonatomic, strong) NSString *sequence;


- (id)init;
+ (NSDictionary *)getMappingDictionary;
- (NSString *)getDisplayField;

@end