//
//  BaseSFNamedSearchFilters.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFNamedSearchFilterModel.h
 *  @class  SFNamedSearchFilterModel
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


@interface SFNamedSearchFilterModel : NSObject

@property(nonatomic) BOOL allowOverride;
@property(nonatomic) BOOL defaultOn;

@property(nonatomic, strong) NSString *Id;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *namedSearchId;
@property(nonatomic, strong) NSString *ruleType;
@property(nonatomic, strong) NSString *parentObjectCriteria;
@property(nonatomic, strong) NSString *sourceObjectName;
@property(nonatomic, strong) NSString *fieldName;
@property(nonatomic, strong) NSString *sequence;
@property(nonatomic, strong) NSString *advancedExpression;

- (id)init;
+ (NSDictionary*)getMappingDictionary;

@end