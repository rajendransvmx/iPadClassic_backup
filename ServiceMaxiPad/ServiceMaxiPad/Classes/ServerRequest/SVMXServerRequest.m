//
//  SVMXServerRequest.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 31/05/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

/**
 *  @file   SVMXServerRequest.m
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

#import "SVMXServerRequest.h"
#import "AFHTTPRequestOperation.h"
#import "AppMetaData.h"
#import "CustomerOrgInfo.h"

@implementation SVMXServerRequest

@synthesize startTime;

- (id)initWithType:(RequestType)requestType
{
    self = [super init];
	if (self != nil)
    {
        
        CustomerOrgInfo *customerOrgInfoInstance = [CustomerOrgInfo sharedInstance];
        
        self.oAuthId     = [customerOrgInfoInstance accessToken];

        self.timeOut     = 180;
	}
	return self;
}

- (id)init
{
	self = [super init];
	if (self != nil)
    {
		//Initialization
	}
	return self;
}


- (BOOL)isInProgress
{
    return YES;
}

- (void)start
{
    @synchronized([self class])
    {
        [super start];
    }
}


- (NSString*)getUrlWithStringApppended:(NSString*)stringToAppend
{
    return nil;
//    CustomerOrgInfo *customerOrgInfoInstance = [CustomerOrgInfo sharedInstance];
//    return [NSString stringWithFormat:@"%@/%@",[customerOrgInfoInstance restAPIUrl],stringToAppend];
}

- (NSString *) getHttpMethodForRequest:(NSString *)httpMethod
{
    if (httpMethod != nil)
    {
        return httpMethod;
    }
    return @"POST";
}


- (NSInteger) timeOutForRequest
{
    //Hard coded TODO : change it later
    return 180;
    
}

- (void)cancel
{
    @synchronized([self class])
    {
        [super cancel];
        
    }
}

- (void)didReceiveResponseSuccessfully:(id)responseObject
{
    NSLog(@"Response Success: %@",responseObject);
}

- (void)didRequestFailedWithError:(id)error andResponse:(id)someResponseObj
{
    NSLog(@"Response Failed:%@",error);
}



#pragma mark - public methods

- (void)addRequestParametersForRequest:(RequestParamModel*)requestParamObj
{
    self.requestParameter = requestParamObj;
}
- (void)addClientRequestIdentifier:(NSString *)clientId {
    self.clientRequestIdentifier = clientId;
}

@end
