//
//  GetPriceDataServiceLayer.m
//  ServiceMaxiPad
//
//  Created by Anoop on 4/10/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "GetPriceDataServiceLayer.h"
#import "ParserFactory.h"
#import "FactoryDAO.h"
#import "TransactionObjectService.h"
#import "TransactionObjectModel.h"
#import "SFPicklistService.h"
#import "SFPicklistModel.h"
#import "PlistManager.h"
#import "TXFetchHelper.h"
#import "TimeLogCacheManager.h"
#import "SyncHeapDAO.h"
#import "SyncConstants.h"

@interface GetPriceDataServiceLayer ()

@property(nonatomic, copy) NSString *lastSyncTime;

@end

@implementation GetPriceDataServiceLayer


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
        parserObj.categoryType = self.categoryType;
        callBack = [parserObj parseResponseWithRequestParam:requestParamModel
                                               responseData:responseData];
        
    }
    return callBack;
}

- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)count
{
    switch (self.requestType)
    {
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
        case RequestTXFetch:
            return [self getTxFetcRequestParamsForRequestCount:count];
            break;
        case RequestSyncTimeLogs:
            return [super getRequestParametersWithRequestCount:count];
            break;
          default:
            break;
    }
    return nil;
}

-(NSArray*)getRequestParamModelForGetPriceData:(RequestType)getPriceDataType {
    
    RequestParamModel *paramObj = [[RequestParamModel alloc]init];
    
    switch (getPriceDataType) {
            
        case RequestGetPriceDataTypeZero:
            paramObj.valueMap = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:kGetPriceDataLastIndex,kSVMXKey,@0,kSVMXValue, nil]];
            break;
            
        case RequestGetPriceDataTypeOne:
            paramObj.valueMap = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:kGetPriceDataLastIndex,kSVMXKey,@1,kSVMXValue, nil]];
            break;
            
        case RequestGetPriceDataTypeTwo: {
            
            NSMutableArray *valueMaps = [[NSMutableArray alloc] initWithCapacity:0];
            NSArray *valuesLabour = [self getValuesArrayForLabour];
            if (valuesLabour == nil) {
                valuesLabour = @[];
            }
            NSArray *valuesIsoCurrency = [self getValuesArrayForCurrencyISO];
            
            if ([valuesLabour count]) {
                NSDictionary *laborDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Labor",kSVMXRequestKey,valuesLabour,kSVMXRequestValues, nil];
                [valueMaps addObject:laborDict];
            }
            
            if ([valuesIsoCurrency count]) {
                NSDictionary *currencyDict = [NSDictionary dictionaryWithObjectsAndKeys:@"CurrencyISO",kSVMXRequestKey,valuesIsoCurrency,kSVMXRequestValues, nil];
                [valueMaps addObject:currencyDict];
            }
            
            NSArray *pricebookIds = [self getPricebookIds];
            if (pricebookIds == nil) {
                pricebookIds = @[];
            }
            
            NSArray *servicepricebookIds = [self getServicePricebookIds];
            if (servicepricebookIds == nil) {
                servicepricebookIds = @[];
            }
            
            if ([pricebookIds count]) {
                NSDictionary *pricebookIdsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"PRICEBOOK_IDs",kSVMXRequestKey,pricebookIds, kSVMXRequestValues, nil];
                [valueMaps addObject:pricebookIdsDict];
            }
            
            if ([servicepricebookIds count]) {
                NSDictionary *servicepricebookIdsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"SERVICE_PRICEBOOK_IDs",kSVMXRequestKey,servicepricebookIds, kSVMXRequestValues, nil];
                [valueMaps addObject:servicepricebookIdsDict];
            }
            
            [valueMaps addObject:[NSDictionary dictionaryWithObjectsAndKeys:kGetPriceDataLastIndex,kSVMXKey,@2,kSVMXValue, nil]];
            paramObj.valueMap = [NSArray arrayWithArray:valueMaps];
            
        }
            break;
            
        case RequestGetPriceDataTypeThree:
            paramObj.valueMap = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:kGetPriceDataLastIndex,kSVMXKey,@3,kSVMXValue, nil]];
            break;
            
            
        default:
            SXLogWarning(@"Invalid post body parama for unidentified get price request");
            break;
    }
    NSDictionary *lastSyncTimeDict = [self getLastSyncTimeForRecords];
    paramObj.valueMap = [paramObj.valueMap arrayByAddingObject:lastSyncTimeDict];
    
    return [NSArray arrayWithObject:paramObj];
}

- (NSDictionary *)getLastSyncTimeForRecords
{
    NSMutableDictionary *lastSyncTimeDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [lastSyncTimeDict setObject:kLastSyncTime forKey:kSVMXRequestKey];
    if (self.lastSyncTime != nil)
    {
        [lastSyncTimeDict setObject:self.lastSyncTime forKey:kSVMXRequestValue];
        return lastSyncTimeDict;
    }
    self.lastSyncTime = [PlistManager getGetPriceSyncTime];
    if (self.lastSyncTime == nil)
    {
        self.lastSyncTime = [PlistManager getOneCallSyncTime];
    }
    if (self.lastSyncTime == nil)
    {
        self.lastSyncTime = @"";
    }
    [lastSyncTimeDict setObject:self.lastSyncTime forKey:kSVMXRequestValue];
    return lastSyncTimeDict;
}

-(NSArray*)getValuesArrayForLabour {
    
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:0];
    
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFPickList];
    NSArray * objectsList = nil;
    if ([daoService conformsToProtocol:@protocol(SFPicklistDAO)]) {
        objectsList = [daoService getListOfLaborActivityType];
    }
    for(SFPicklistModel *picklistModel in objectsList)
    {
        [values addObject:picklistModel.value];
    }
    return values;
    
}

-(NSArray*)getValuesArrayForCurrencyISO {
    
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:0];
    
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    NSArray * objectsList = nil;
    if ([daoService conformsToProtocol:@protocol(TransactionObjectDAO)]) {
        objectsList = [daoService getListWorkorderCurrencies];
    }
    for(TransactionObjectModel *transObjectModel in objectsList)
    {
        if ([transObjectModel valueForField:@"CurrencyISO"]) {
            [values addObject:[transObjectModel valueForField:@"CurrencyISO"]];
        }
    }
    return values;
}

-(NSArray*)getPricebookIds
{
    NSArray *sfidsArray = [[NSArray alloc] init];
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSyncHeap];
    if ([daoService conformsToProtocol:@protocol(SyncHeapDAO)]) {
        sfidsArray = [daoService getAllIdsFromHeapTableForObjectName:@"PRICEBOOK_IDs"
                                                            forLimit:0 forParallelSyncType:kParallelGetPriceSync];
    }
    return sfidsArray;
}

-(NSArray*)getServicePricebookIds
{
    NSArray *sfidsArray = [[NSArray alloc] init];
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSyncHeap];
    if ([daoService conformsToProtocol:@protocol(SyncHeapDAO)]) {
        sfidsArray = [daoService getAllIdsFromHeapTableForObjectName:@"SERVICE_PRICEBOOK_IDs"
                                                            forLimit:0 forParallelSyncType:kParallelGetPriceSync];
    }
    return sfidsArray;
}

- (NSArray *)getTxFetcRequestParamsForRequestCount:(NSInteger )requestCount {
    @autoreleasepool
    {
        TXFetchHelper *helper = [[TXFetchHelper alloc] init];
        NSMutableArray *requestParams = [[NSMutableArray alloc] initWithCapacity:0];
        for (int counter = 0; counter < requestCount; counter++)
        {
            NSDictionary *recordIdDict =  [helper getIdListFromSyncHeapTableWithLimit:kOverallIdLimit forParallelSyncType:kParallelGetPriceSync];
            if ([recordIdDict count] <= 0) {
                break;
            }
            RequestParamModel *paramObj = [[RequestParamModel alloc]init];
            paramObj.requestInformation = recordIdDict;
            paramObj.valueMap = [helper getValueMapDictionary:recordIdDict];
            [requestParams addObject:paramObj];
        }
        return requestParams;
    }
}


@end
