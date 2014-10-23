//
//  SVMXServerRequest.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 31/05/14.
//  Copyright (c) 2014 ServiceMax All rights reserved.
//


/**
 *  @file   SVMXServerRequest.h
 *  @class  SVMXServerRequest
 *
 *  @brief
 *
 *   This is base class for request.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>
#import "RequestFactory.h"
#import "RequestParamModel.h"
#import "AppManager.h"
#import "NSString+StringUtility.h"
#import "RequestConstants.h"

@protocol SVMXRequestDelegate <NSObject>

- (void)didReceiveResponseSuccessfully:(id)responseObject andRequestObject:(id)request;
- (void)didRequestFailedWithError:(NSError *)error Response:(id)responseObject andRequestObject:(id)request;

@end

@interface SVMXServerRequest : NSOperation

@property(weak) id serverRequestdelegate;

@property(nonatomic) NSInteger timeOut;
@property(nonatomic) NSTimeInterval latency;

@property(nonatomic,copy) NSString *oAuthId;
@property(nonatomic,copy) NSString *url;
@property(nonatomic,copy) NSString *requestIdentifier;

@property(nonatomic,assign) RequestType requestType;
@property(nonatomic,assign) RequestType nextRequestType;
@property(nonatomic,strong) RequestParamModel *requestParameter;

@property(nonatomic,strong) NSString *clientRequestIdentifier;

- (id)init;
- (BOOL)isInProgress;
- (NSInteger) timeOutForRequest;

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


/**
 * @name - (void)addRequestParametersForRequest:(RequestParamModel*)requestParamObj
 *
 * @author Shubha
 *
 * @brief
 * It will add requestParameter to the request.
 *
 *
 * @param requestParamObject
 * @param
 *
 * @return void
 *
 */

- (void)addRequestParametersForRequest:(RequestParamModel*)requestParamObj;

- (void)addClientRequestIdentifier:(NSString *)clientId;

@end
