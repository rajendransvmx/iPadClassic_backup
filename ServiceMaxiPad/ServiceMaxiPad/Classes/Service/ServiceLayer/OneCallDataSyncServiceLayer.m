//
//  OneCallDataSyncServiceLayer.m
//  ServiceMaxMobile
//
//  Created by Anoop on 8/13/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "OneCallDataSyncServiceLayer.h"
#import "ParserFactory.h"
#import "OneCallDataSyncHelper.h"


@implementation OneCallDataSyncServiceLayer

- (instancetype) initWithCategoryType:(CategoryType)categoryType
                          requestType:(RequestType)requestType {
    
    self = [super initWithCategoryType:categoryType requestType:requestType];
    
    if (self != nil) {
        //Intialize if required
        
    }
    
    return self;
    
}

- (ResponseCallback*)processResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                      responseData:(id)responseData {
    ResponseCallback *callBack = nil;
    WebServiceParser *parserObj = (WebServiceParser *)[ParserFactory parserWithRequestType:self.requestType];
    if ([parserObj conformsToProtocol:@protocol(WebServiceParserProtocol)]) {
        
        parserObj.clientRequestIdentifier = self.requestIdentifier;
        callBack = [parserObj parseResponseWithRequestParam:requestParamModel
                                               responseData:responseData];
        
    }
    return callBack;
}

- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)count
{
    NSArray * finalArray  = [super getRequestParametersWithRequestCount:count];
    if(finalArray != nil)
    {
        return finalArray;
    }
    switch (self.requestType) {
        case RequestAdvancedDownLoadCriteria:
            return [self getParamterForAdvancedDownloadCriteria];
            break;
        case RequestDownloadCriteria:
            break;
        case RequestGetPriceDataTypeZero:
            return [self getRequestParamModelForGetPriceData:RequestGetPriceDataTypeZero];
            break;
        case RequestGetPriceDataTypeOne:
            return [self getRequestParamModelForGetPriceData:RequestGetPriceDataTypeOne];
            break;
        case RequestGetPriceDataTypeTwo:
            return [self getRequestParamModelForGetPriceData:RequestGetPriceDataTypeTwo];
            break;
        case RequestGetPriceDataTypeThree:
            return [self getRequestParamModelForGetPriceData:RequestGetPriceDataTypeThree];
            break;
        case RequestOneCallDataSync:
        {
            
            self.requestParamHelper = [[IncrementalSyncRequestParamHelper alloc] initWithRequestIdentifier:self.requestIdentifier];
             RequestParamModel *model = [self.requestParamHelper createSyncParamters:nil andContext:nil];
            return @[model];
        }
        break;
        case RequestTXFetch:
        {
            OneCallDataSyncHelper *helper = [[OneCallDataSyncHelper alloc] init];
            [helper deleteIdsFromSyncHeapForResponseType:kGetDeleteDCOptimized];
           
           return [self getTxFetcRequestParamsForRequestCount:count];
        }
            break;
        default:
            break;
    }
    return nil;
    
}

- (NSArray *)getParamterForAdvancedDownloadCriteria {
     RequestParamModel *paramObj = [[RequestParamModel alloc]init];
     NSDictionary *lastSyncTime = [self getLastSyncTimeForRecords];
     paramObj.valueMap = @[lastSyncTime];
    return @[paramObj];
}

@end
