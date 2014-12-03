//
//  ZKSRequest.h
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 01/06/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

/**
 *  @file   ZKSRequest
 *  @class  ZKSRequest.m
 *
 *  @brief  A ZKS Request object derived from the SVMXServerRequest
 *
 *  @author  Krishna Shanbhag
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/
#import "SVMXServerRequest.h"
#import "ZKSforce.h"
#import "ZKDescribeLayoutResult.h"
#import "ZKRecordTypeMapping.h"

@interface ZKSRequest : SVMXServerRequest
{
    @protected BOOL synchronousOperationComplete;
}

@property(nonatomic,copy) NSString *objectName;

@end


