//
//  ZKSDescribeObjectRequest.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 06/08/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import "ZKSRequest.h"

@interface ZKSDescribeObjectRequest : ZKSRequest

@property(nonatomic,copy) NSString *describeObjectName;

/**
 * @name - (id)initWithType:(RequestType)requestType;
 *
 * @author Shubha
 *
 * @brief init based on request type.
 *
 *
 *
 * @param
 * @param
 *
 * @return id
 *
 */

- (id)initWithType:(RequestType)requestType;

@end
