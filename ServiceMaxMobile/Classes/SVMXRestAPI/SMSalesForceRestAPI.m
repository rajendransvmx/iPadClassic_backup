//
//  SMSalesForceRestAPI.m
//  iService
//
//  Created by Vipindas on 11/18/13.
//
//

#import "SMSalesForceRestAPI.h"


NSString * const kMobileSDKVersion   = @"2.4.2";
NSString * const kSFRestAPIVersion   = @"v26.0";
NSString * const kSFRestAPIContentTypeJSON   = @"application/json";


static dispatch_once_t _sharedInstanceGuard;
static SMSalesForceRestAPI *_instance;


@implementation SMSalesForceRestAPI

@synthesize apiVersion=_apiVersion;
@synthesize currentRequests;


#pragma mark - init/setup

- (id)init
{
    self = [super init];
    
    if (self != nil)
    {
        self.apiVersion = kSFRestAPIVersion;
        
        // Vipin - 9167
        NSMutableSet *requestSets = [[NSMutableSet alloc] initWithCapacity:0];
        self.currentRequests = requestSets;
        [requestSets  release];
    }
    return self;
}


- (void)dealloc
{
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





- (void)sendRequest:(SMRestRequest *)request withDelegate:(id<SMRestRequestDelegate>)reqDelegate
{
    RestRequest *helper = [RestRequest getHelperForRequest:request];
    [helper sendRequestWithDelegate:reqDelegate];
    [self.currentRequests addObject:helper];
    // Vipin - 9167
}


- (SMRestRequest *)requestForQuery:(NSString *)soql
{
    NSString            *path = [NSString stringWithFormat:@"/%@/query", self.apiVersion];
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:soql, @"q", nil];
    
    return [[[SMRestRequest alloc] initWithMethod:@"GET" path:path andParameters:queryParams] autorelease];
}


- (SMRestRequest *)requestForRetrieveWithObjectType:(NSString *)objectType
                                           objectId:(NSString *)objectId
                                          fieldList:(NSString *)fieldList
{
    NSDictionary *queryParams = (fieldList ?
                                 [NSDictionary dictionaryWithObjectsAndKeys:fieldList, @"fields", nil]
                                 : nil);
    NSString *path = [NSString stringWithFormat:@"/%@/sobjects/%@/%@", self.apiVersion, objectType, objectId];
    
    return [[[SMRestRequest alloc] initWithMethod:@"GET" path:path andParameters:queryParams] autorelease];
}

/*
// http://www.salesforce.com/us/developer/docs/api_rest/index_Left.htm#CSHID=dome_versions.htm|StartTopic=Content%2Fdome_versions.htm|SkinName=webhelp

 https://na1.salesforce.com/services/data/v20.0/sobjects/Attachment/001D000000INjVe/body
 */

- (SMRestRequest *)requestForRetrieveBlobWithObjectType:(NSString *)objectType
                                               objectId:(NSString *)objectId
                                              fieldName:(NSString *)fieldName
{
    
   // NSString *path = [NSString stringWithFormat:@"/%@/sobjects/%@/%@/%@", self.apiVersion, objectType, objectId, fieldName];
    
   // return [[[SMRestRequest alloc] initWithMethod:@"GET" path:path andParameters:nil] autorelease];
    
    
    return [[[SMRestRequest alloc] initWithMethod:@"GET" objectName:objectType andSfId:objectId] autorelease];
}

- (void)sendRequestForQuery:(SMRestRequest *)request withDelegate:(id<SMRestRequestDelegate>)reqDelegate
{
    [self sendRequest:request withDelegate:reqDelegate];
}


- (void)removeCurrentRequestsObject:(RestRequest *)requestHelper
{
    // Vipin - 9167
    [requestHelper retain];

    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        [self removeRequest:requestHelper];
    });
    [requestHelper release];
}

// Vipin - 9167
- (void)removeRequest:(RestRequest *)requestHelper
{
    [requestHelper retain];
    [self.currentRequests removeObject:requestHelper];
    [requestHelper autorelease];
}

@end
