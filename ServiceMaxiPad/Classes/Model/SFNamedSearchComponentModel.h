//
//  BaseSFNamedSearchComponent.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFNamedSearchComponentModel.h
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

@interface SFNamedSearchComponentModel : NSObject

@property(nonatomic, readwrite) NSInteger localId;
@property(nonatomic, copy) NSString *expressionType;
@property(nonatomic, copy) NSString *fieldName;
@property(nonatomic, copy) NSString *namedSearchId;
@property(nonatomic, copy) NSString *searchObjectFieldType;
@property(nonatomic, copy) NSString *fieldDataType;
@property(nonatomic, copy) NSString *fieldRelationshipName;
@property(nonatomic, assign) double sequence;

- (id)init;

- (void)explainMe;

+ (NSDictionary*)getMappingDictionary;

@end