//
//  RequestParamModel.h
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 11/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//
/**
 *  @file   RequestParamModel.h
 *  @class  RequestParamModel
 *
 *  @brief  Request parameter Model, space for dynamic parameters to attach with request.
 *
 *  @author  Krishna Shanbhag
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/
#import <Foundation/Foundation.h>

@interface RequestParamModel : NSObject

@property (nonatomic, strong)   NSDictionary    *requestInformation;
@property (nonatomic, copy)     NSString        *value;
@property (nonatomic, strong)   NSArray         *values;
@property (nonatomic, strong)   NSArray         *valueMap;
@property (nonatomic, strong)   NSDictionary    *context;
@property (nonatomic, assign)   NSInteger       retryCount;
@end
