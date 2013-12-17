//
//  SMSalesForceRestAPI.m
//  iService
//
//  Created by Vipindas on 11/18/13.
//
//

#import "SMSalesForceRestAPI.h"
#import "SMConnectionManager.h"
#import "SMRequestHelper.h"


NSString * const kMobileSDKVersion   = @"2.4.2";
NSString * const kSFRestAPIVersion   = @"v26.0";
NSString * const kSFRestAPIContentTypeJSON   = @"application/json";


static dispatch_once_t _sharedInstanceGuard;
static SMSalesForceRestAPI *_instance;


@implementation SMSalesForceRestAPI

@synthesize apiVersion=_apiVersion;
@synthesize rkClient;
@synthesize currentRequests;


#pragma mark - init/setup

- (id)init
{
    self = [super init];
    
    if (self != nil)
    {
        self.apiVersion = kSFRestAPIVersion;
        
        NSMutableSet *requestSets = [[NSMutableSet alloc] initWithCapacity:4];
        self.currentRequests = requestSets;
        [requestSets  release];
    }
    return self;
}


- (void)dealloc
{
    [_client release]; _client = nil;
    [currentRequests release]; currentRequests = nil;
     
    [super dealloc];
}


#pragma mark - singleton

+ (SMSalesForceRestAPI *)sharedInstance {
    dispatch_once(&_sharedInstanceGuard,
                  ^{
                      _instance = [[SMSalesForceRestAPI alloc] init];
                  });
    return _instance;
}


- (RKClient *)rkClient
{
    if (nil == _client)
    {
        [[SMConnectionManager sharedInstance] refreshConnectionInfo];
        _client = [[RKClient alloc] initWithBaseURLString:[SMConnectionManager sharedInstance].instanceURL];
        [_client setValue:kSFRestAPIContentTypeJSON forHTTPHeaderField:@"Content-Type"];
        [_client setValue:[SMSalesForceRestAPI userAgentString] forHTTPHeaderField:@"User-Agent"];
    }
    return _client;
}


+ (NSString *)userAgentString
{
    UIDevice *curDevice  = [UIDevice currentDevice];
    NSString *appName    = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
    
    NSString *userAgent = [NSString stringWithFormat:
                             @"SalesforceMobileSDK/%@ %@/%@ (%@) %@/%@",
                             kMobileSDKVersion,
                             [curDevice systemName],
                             [curDevice systemVersion],
                             [curDevice model],
                             appName,
                             appVersion];
    
    return userAgent;
}


- (void)sendRequest:(SMRestRequest *)request withDelegate:(id<SMRestRequestDelegate>)reqDelegate
{
    SMRequestHelper *helper = [SMRequestHelper getHelperForRequest:request];
    [self.currentRequests addObject:helper];
    [helper sendRequestWithDelegate:reqDelegate];
}


- (SMRestRequest *)requestForQuery:(NSString *)soql
{
    NSString            *path = [NSString stringWithFormat:@"/%@/query", self.apiVersion];
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:soql, @"q", nil];
    
    return [[[SMRestRequest alloc] initWithMethod:RKRequestMethodGET path:path andParameters:queryParams] autorelease];
}


- (SMRestRequest *)requestForRetrieveWithObjectType:(NSString *)objectType
                                           objectId:(NSString *)objectId
                                          fieldList:(NSString *)fieldList
{
    NSDictionary *queryParams = (fieldList ?
                                 [NSDictionary dictionaryWithObjectsAndKeys:fieldList, @"fields", nil]
                                 : nil);
    NSString *path = [NSString stringWithFormat:@"/%@/sobjects/%@/%@", self.apiVersion, objectType, objectId];
    
    return [[[SMRestRequest alloc] initWithMethod:RKRequestMethodGET path:path andParameters:queryParams] autorelease];
}

/*
// http://www.salesforce.com/us/developer/docs/api_rest/index_Left.htm#CSHID=dome_versions.htm|StartTopic=Content%2Fdome_versions.htm|SkinName=webhelp

 https://na1.salesforce.com/services/data/v20.0/sobjects/Attachment/001D000000INjVe/body
 */

- (SMRestRequest *)requestForRetrieveBlobWithObjectType:(NSString *)objectType
                                               objectId:(NSString *)objectId
                                              fieldName:(NSString *)fieldName
{
    
    NSString *path = [NSString stringWithFormat:@"/%@/sobjects/%@/%@/%@", self.apiVersion, objectType, objectId, fieldName];
    
    return [[[SMRestRequest alloc] initWithMethod:RKRequestMethodGET path:path andParameters:nil] autorelease];
}

- (void)sendRequestForQuery:(SMRestRequest *)request withDelegate:(id<SMRestRequestDelegate>)reqDelegate
{
    [self sendRequest:request withDelegate:reqDelegate];
}


- (void)removeCurrentRequestsObject:(SMRequestHelper *)requestHelper
{
    [self.currentRequests removeObject:requestHelper];
}

@end
