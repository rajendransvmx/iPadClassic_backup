//
//  BaseSFObjectMapping.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   SFObjectMappingModel.h
 *  @class  SFObjectMappingModel
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


@interface SFObjectMappingModel : NSObject

@property(nonatomic) NSInteger localId;

@property(nonatomic, strong) NSString *objectMappingId;
@property(nonatomic, strong) NSString *sourceObjectName;
@property(nonatomic, strong) NSString *targetObjectName;

+ (NSDictionary *) getMappingDictionary;

@end