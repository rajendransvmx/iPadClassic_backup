//
//  SMDataPurgeRequest.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 12/31/13.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "INTF_WebServicesDefServiceSvc.h"
#import "WSIntfGlobals.h"

#import "SMDataPurgeCallBackData.h"

@class SMDataPurgeRequest;
@class SMDataPurgeResponse;
@class SMDataPurgeResponseError;



/**************   Request Protocol   **************/

@protocol SMDataPurgeRequestDelegate <NSObject>

- (void)request:(SMDataPurgeRequest *)request completedWithResponse:(SMDataPurgeResponse *)response;
- (void)request:(SMDataPurgeRequest *)request failedWithError:(SMDataPurgeResponseError *)error;

@end



/**************       Request       **************/

@interface SMDataPurgeRequest : NSObject<INTF_WebServicesDefBindingResponseDelegate>
{
 

}

@property(assign) BOOL isMetaSync;

@property(nonatomic, copy) NSString *requestId;
@property(nonatomic, copy) NSString *eventName;
@property(nonatomic, assign) id<SMDataPurgeRequestDelegate> requestDelegate;
@property(nonatomic, retain) NSString * index;
@property(nonatomic, retain) NSArray * data;
@property(nonatomic, retain) NSMutableDictionary * partialObject;
@property(nonatomic, retain) NSArray * partialExecutedData;


- (id)initWithRequestIdentifier:(NSString *)identifier withCallBackValues:(SMDataPurgeCallBackData *)callBack;

- (void)makeConfigurationLastModifiedDateRequest;
- (void)makeDownloadCriteriaRequest;
- (void)makeAdvancedDownloadCriteriaRequest;
- (void)makeCleanUpRequest;
- (void)makeGetPriceRequest;


@end
