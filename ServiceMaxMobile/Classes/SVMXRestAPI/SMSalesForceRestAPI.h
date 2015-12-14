//
//  SMSalesForceRestAPI.h
//  iService
//
//  Created by Vipindas on 11/18/13.
//
//

#import <Foundation/Foundation.h>

#import "SMRestRequest.h"

#import "RestRequest.h"

extern NSString * const kMobileSDKVersion;
extern NSString * const kSFRestAPIVersion;
extern NSString * const kSFRestAPIContentTypeJSON;


@interface SMSalesForceRestAPI : NSObject
{
    NSString *_apiVersion;
    
}

@property (nonatomic,  retain) NSString *apiVersion;


@property (nonatomic,  retain) NSMutableSet *currentRequests;


+ (SMSalesForceRestAPI *)sharedInstance;


- (void)sendRequestForQuery:(SMRestRequest *)request withDelegate:(id<SMRestRequestDelegate>)reqDelegate;

- (void)sendRequest:(SMRestRequest *)request withDelegate:(id<SMRestRequestDelegate>)reqDelegate;

- (void)removeCurrentRequestsObject:(RestRequest *)requestHelper;


/* SalesForce Rest API methods */

- (SMRestRequest *)requestForQuery:(NSString *)soql;

- (SMRestRequest *)requestForRetrieveBlobWithObjectType:(NSString *)objectType
                                               objectId:(NSString *)objectId
                                              fieldName:(NSString *)fieldName;

- (SMRestRequest *)requestForRetrieveWithObjectType:(NSString *)objectType
                                           objectId:(NSString *)objectId
                                          fieldList:(NSString *)fieldList;




@end
