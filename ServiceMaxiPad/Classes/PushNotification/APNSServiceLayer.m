//
//  APNSServiceLayer.m
//  ServiceMaxiPad
//
//  Created by Himanshi Sharma on 10/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "APNSServiceLayer.h"
#import "ParserFactory.h"
#import "DODHelper.h"
#import "CacheManager.h"


@implementation APNSServiceLayer

- (instancetype)initWithCategoryType:(CategoryType)categoryType requestType:(RequestType)requestType {
    self = [super initWithCategoryType:categoryType requestType:requestType];
    if (self != nil) {
        //Intialize if required
    }
    return self;
}


- (ResponseCallback*)processResponseWithRequestParam:(RequestParamModel*)requestParamModel responseData:(id)responseData {
    ResponseCallback *callBack = nil;
    WebServiceParser *parserObj = (WebServiceParser *)[ParserFactory parserWithRequestType:self.requestType];
    if ([parserObj conformsToProtocol:@protocol(WebServiceParserProtocol)]) {
        parserObj.clientRequestIdentifier = self.requestIdentifier;
        callBack = [parserObj parseResponseWithRequestParam:requestParamModel responseData:responseData];
    }
    return callBack;
}

- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)requestCount
{
    
    NSArray *requestArray;
    switch (self.requestType) {
        case RequestDataPushNotification:
            //fill Data
            
            requestArray =[self fetchRequestParametersForAPNSRequest];
            
            break;
            
        default:
            SXLogWarning(@"Invalid request type");
            break;
    }
    
    return requestArray;
    
}


- (NSArray *)fetchRequestParametersForAPNSRequest
{
    NSArray *resultArray;
  

    
    NSString *objectName = [[CacheManager sharedInstance]getCachedObjectByKey:@"searchObjectName"];
    NSString *recordId = [[CacheManager sharedInstance]getCachedObjectByKey:@"searchSFID"];
    
    //pushNotificationModel.objectName = @"SVMXC__Service_Order_Line__c";
    //pushNotificationModel.sfId = @"a39J00000002zUfIAI";
    
    
    NSMutableDictionary *valueMapForObject = [[NSMutableDictionary alloc]initWithCapacity:0];
    [valueMapForObject setObject:@"Object_Name" forKey:kSVMXKey];
    [valueMapForObject setObject:objectName forKey:kSVMXValue];
    
    
    
    NSMutableDictionary *valueMap_RecordId = [[NSMutableDictionary alloc]initWithCapacity:0];
    [valueMap_RecordId setObject:@"Record_Id" forKey:kSVMXKey];
    [valueMap_RecordId setObject:recordId forKey:kSVMXValue];
    
    
    NSArray *valueMapArray  = [NSArray arrayWithObjects:valueMap_RecordId,nil];
    [valueMapForObject setObject:valueMapArray forKey:kSVMXSVMXMap];
    
    
    RequestParamModel *reqParModel = [[RequestParamModel alloc]init];
    
    reqParModel.valueMap = @[valueMapForObject];
    
    resultArray = @[reqParModel];
    
    return resultArray;
}



@end
