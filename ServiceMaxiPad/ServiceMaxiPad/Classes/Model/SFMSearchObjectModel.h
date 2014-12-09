//
//  BaseSFM_SearchObjects.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFMSearchObjectModel.h
 *  @class  SFMSearchObjectModel
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

/**
 This is a Model Class which represents SFM Search object
 */
@interface SFMSearchObjectModel : NSObject
@property (nonatomic, strong) NSString *moduleId;
@property (nonatomic, strong) NSString *name;
//@property (nonatomic, strong) NSString *searchProcessSfId;
@property (nonatomic, strong) NSString *searchProcessUniqueId;
@property (nonatomic, strong) NSString *targetObjectName;
@property (nonatomic, strong) NSString *advancedExpression;
@property (nonatomic, strong) NSString *parentObjectCriteria;
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSArray *searchFields;
@property (nonatomic, strong) NSArray *displayFields;
@property (nonatomic, strong) NSArray *sortFields;
@property (nonatomic) double sequence;

+ (NSDictionary *) getMappingDictionary;
@end