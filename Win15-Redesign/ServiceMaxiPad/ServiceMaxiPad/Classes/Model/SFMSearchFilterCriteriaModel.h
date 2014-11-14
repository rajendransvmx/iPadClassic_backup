//
//  BaseSFM_Search_Filter_Criteria.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFMSearchFilterCriteriaModel.h
 *  @class  SFMSearchFilterCriteriaModel
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

@interface SFMSearchFilterCriteriaModel : NSObject


@property(nonatomic) NSInteger localId;
@property(nonatomic, strong) NSString *identifier;
@property(nonatomic, strong) NSString *displayType;
@property(nonatomic, strong) NSString *expressionRule;
@property(nonatomic, strong) NSString *fieldName;
@property(nonatomic, strong) NSString *objectName2;
@property(nonatomic, strong) NSString *operand;
@property(nonatomic, strong) NSString *operatorValue;
@property(nonatomic, strong) NSString *objectID;
@property(nonatomic, strong) NSString *lookupFieldAPIName;
@property(nonatomic, strong) NSString *fieldRelationshipName;
@property(nonatomic, strong) NSString *objectName;
@property(nonatomic, strong) NSString *sequence;

+ (NSDictionary *)getMappingDictionary;
@end