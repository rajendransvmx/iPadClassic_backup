//
//  SMSalesForceRestAPI.h
//  iService
//
//  Created by Vipindas on 11/18/13.
//
//

#import <Foundation/Foundation.h>

#import "SMRestRequest.h"

extern NSString * const kMobileSDKVersion;
extern NSString * const kSFRestAPIVersion;
extern NSString * const kSFRestAPIContentTypeJSON;

@class SMRequestHelper;

@interface SMSalesForceRestAPI : NSObject
{
    NSString *_apiVersion;
    RKClient *_client;
    
}

@property (nonatomic,  retain) NSString *apiVersion;

@property (nonatomic,  retain) RKClient *rkClient;

@property (nonatomic,  retain) NSMutableSet *currentRequests;

+ (NSString *)userAgentString;

+ (SMSalesForceRestAPI *)sharedInstance;


- (void)sendRequestForQuery:(SMRestRequest *)request withDelegate:(id<SMRestRequestDelegate>)reqDelegate;

- (void)sendRequest:(SMRestRequest *)request withDelegate:(id<SMRestRequestDelegate>)reqDelegate;

- (void)removeCurrentRequestsObject:(SMRequestHelper *)requestHelper;


/* SalesForce Rest API methods */

- (SMRestRequest *)requestForQuery:(NSString *)soql;

- (SMRestRequest *)requestForRetrieveBlobWithObjectType:(NSString *)objectType
                                               objectId:(NSString *)objectId
                                              fieldName:(NSString *)fieldName;

- (SMRestRequest *)requestForRetrieveWithObjectType:(NSString *)objectType
                                           objectId:(NSString *)objectId
                                          fieldList:(NSString *)fieldList;




@end
