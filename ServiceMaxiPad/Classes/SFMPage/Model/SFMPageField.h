//
//  SFMPageField.h
//  ServiceMaxMobile
//
//  Created by Aparna on 13/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   SFMPageField.h
 *  @class  SFMPageField
 *
 *  @brief
 *
 *   This is a model class used to hold the each page field meta data .
 *
 *  @author Aparna
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

@interface SFMPageField : NSObject

@property(nonatomic, strong) NSString *fieldName;
@property(nonatomic, strong) NSString *dataType;
@property(nonatomic, strong) NSString *relatedObjectName;
@property(nonatomic, strong) NSString *label;
@property(nonatomic, strong) NSString *controlerField;
@property(nonatomic, assign) BOOL isReadOnly;
@property(nonatomic, assign) BOOL isRequired;

/**
 string which represents whether the picklist is dependant on any other field value
 */
@property(nonatomic, strong) NSString    *isDependentPicklist;

@property(nonatomic, strong) NSString *lookUpContext;
@property(nonatomic, strong) NSString *lookUpQueryField;
@property(nonatomic, strong) NSString *namedSearch;
@property(nonatomic, strong) NSString *fieldMappingId;
@property(nonatomic, strong) NSString *sourceObjectField;
@property(nonatomic, strong) NSNumber *allowOverRide;

@property(nonatomic, strong) NSNumber *precision;
@property(nonatomic, strong) NSNumber *scale;

- (id)initWithDictionary:(NSDictionary *)pageFieldDict;

@end
