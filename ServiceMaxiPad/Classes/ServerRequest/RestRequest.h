//
//  RestRequest.h
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 01/06/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   RestRequest
 *  @class  RestRequest.m
 *
 *  @brief  A REST Request object derived from the SVMXServerRequest
 *
 *  @author  Krishna Shanbhag
 *  @author  Shubha
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/
#import "SVMXServerRequest.h"
#import "RequestParamModel.h"
#import "CustomXMLParser.h"


@interface RestRequest : SVMXServerRequest <xmlParserProtocolDelegate>

@property (nonatomic, strong) NSMutableDictionary *dataDictionary;
@property(nonatomic,copy) NSString *contentType;
@property(nonatomic,copy) NSString *httpMethod;
@property(nonatomic,copy) NSString *groupId;
@property(nonatomic,copy) NSString *userId;
@property(nonatomic,copy) NSString *eventName;
@property(nonatomic,copy) NSString *eventType;
@property(nonatomic,copy) NSString *profileId;
@property(nonatomic,copy) NSString *apiType;    //To say whether request is soap,rest or zks. Not using now
@property(nonatomic)      NSInteger *pageNumber;






/**
 * @name - (NSString *)getURLStringForDpPicklistWithObject:(NSString*)objectName
 *
 * @author Shubha
 *
 * @brief
 * It will return url with object name appended
 *
 *
 * @param objectname
 * @param
 *
 * @return Url for DPPIcklisr rest api
 *
 */

- (NSString *)getURLStringForDpPicklistWithObject:(NSString*)objectName;

- (RequestParamModel *)getRequestParameters;



@end
