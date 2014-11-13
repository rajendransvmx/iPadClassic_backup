//
//  BaseSFObjectMappingComponent.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFObjectMappingComponentModel.h
 *  @class  SFObjectMappingComponentModel
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


@interface SFObjectMappingComponentModel : NSObject


@property(nonatomic) NSInteger localId;

@property(nonatomic) BOOL mappingValueFlag;

@property(nonatomic, strong) NSString *objectMappingId;
@property(nonatomic, strong) NSString *sourceFieldName;
@property(nonatomic, strong) NSString *targetFieldName;
@property(nonatomic, strong) NSString *mappingValue;
@property(nonatomic, strong) NSString *mappingComponentType;
@property(nonatomic, strong) NSString *preference2;
@property(nonatomic, strong) NSString *preference3;

+ (NSDictionary *) getMappingDictionary;
@end