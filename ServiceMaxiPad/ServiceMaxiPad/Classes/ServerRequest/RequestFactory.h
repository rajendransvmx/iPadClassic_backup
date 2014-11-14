//
//  RequestFactory.h
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 31/05/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

/**
 *  @file   RequestFactory.h
 *  @class  RequestFactory
 *
 *  @brief This class is responsible for giving the Request object based on the request type
 *
 *
 *  @author Krishna Shanbhag
 *  @author Shubha
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/
#import <Foundation/Foundation.h>
#import "RequestConstants.h"

@interface RequestFactory : NSObject

/**
 * @name  + (id)requestForRequestType:(RequestType)requestType;
 *
 * @author Krishna Shanbhag
 *
 * @brief Factory method to generate request object for request type
 *
 *
 * @param  type Context of the request
 *
 * @return object Object of Request class
 *
 */

+ (id)requestForRequestType:(RequestType)requestType;

@end
