//
//  SFMPageHistoryServiceLayer.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 25/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SFMPageHistoryServiceLayer.h"
#import "ParserFactory.h"
#import "TransactionObjectModel.h"
#import "CacheManager.h"
#import "NonTagConstant.h"
#import "DateUtil.h"

@implementation SFMPageHistoryServiceLayer

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
        case RequestTypeProductHistory:
            requestArray = [self getRequestParametersForProHistory];
            break;
            
        case RequestTypeAccountHistory:
            requestArray = [self getRequestParametersForAccHistory];
        default:
            NSLog(@"Invalid request type");
            break;
    }
    return requestArray;
}

- (NSArray *)getRequestParametersForAccHistory
{
    RequestParamModel *param = nil;
    
    TransactionObjectModel *model = [[CacheManager sharedInstance] getCachedObjectByKey:kAccHistory];
    if (model != nil) {
        
        NSString *createdDate = [self getdate:[model valueForField:kTextCreateDate]];
        
        NSString *query  = [NSString stringWithFormat:@"SELECT Id, SVMXC__Problem_Description__c,CreatedDate  FROM SVMXC__Service_Order__c  WHERE ( (  ( CreatedDate <= %@ )  AND   ( %@ = 'Closed' )  AND   ( Id != '%@' )  AND   ( %@ = '%@' ) ) )", createdDate, kOrderStatus, [model valueForField:kId], kWorkOrderCompanyId, [model valueForField:kWorkOrderCompanyId] ];
        param = [[RequestParamModel alloc] init];
        param.value = query;
    
        SXLogInfo(@"ACCOUNT HISTORY = %@", query);
        
    }
    return @[param];
}

- (NSArray *)getRequestParametersForProHistory
{
    RequestParamModel *param = nil;
    
    NSString *query = nil;
    
    TransactionObjectModel *model = [[CacheManager sharedInstance] getCachedObjectByKey:kProHistory];
    if (model != nil) {
        
        NSString *createdDate = [self getdate:[model valueForField:kTextCreateDate]];
        NSString *topLevelId = [model valueForField:kTopLevelId];
        NSString *productId = [model valueForField:kComponentId];
        
        if ([topLevelId length] > 0) {
            query  = [NSString stringWithFormat:@"SELECT Id, SVMXC__Problem_Description__c,CreatedDate  FROM SVMXC__Service_Order__c  WHERE ( (  ( CreatedDate <= %@ )  AND   ( %@ = 'Closed' )  AND   ( Id != '%@' )  AND   ( %@ = '%@' ) ) )", createdDate, kOrderStatus,
                      [model valueForField:kId], kTopLevelId, [model valueForField:kTopLevelId] ];
        }
        else if ([productId length] > 0) {
            query  = [NSString stringWithFormat:@"SELECT Id, SVMXC__Problem_Description__c,CreatedDate  FROM SVMXC__Service_Order__c  WHERE ( (  ( CreatedDate <= %@ )  AND   ( %@ = 'Closed' )  AND   ( Id != '%@' )  AND   ( %@ = '%@' ) ) )", createdDate, kOrderStatus,
                      [model valueForField:kId], kComponentId, [model valueForField:kComponentId] ];
        }
        
        param = [[RequestParamModel alloc] init];
        param.value = query;
        
        SXLogInfo(@"Product History = %@", query);
    }
    return @[param];
}

- (NSString *)getdate:(NSString *)cretedDate
{
    return [cretedDate stringByReplacingOccurrencesOfString:@".000+0000" withString:@".000Z"];
}
@end
