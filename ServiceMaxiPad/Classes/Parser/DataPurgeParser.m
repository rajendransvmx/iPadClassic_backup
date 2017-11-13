//
//  DataPurgeParser.m
//  ServiceMaxiPad
//
//  Created by Chinnababu on 03/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "DataPurgeParser.h"
#import "RequestConstants.h"
#import "StringUtil.h"
#import "ResponseCallback.h"
#import "FactoryDAO.h"
#import "DataPurgeDAO.h"
#import "DataPurgeModel.h"
#import "SVMXSystemConstant.h"
#import "SMDataPurgeManager.h"
#import "PlistManager.h"
#import "SFObjectFieldDAO.h"

@interface DataPurgeParser ()

@property (nonatomic, assign) BOOL isWOCountZero;
@property (nonatomic, assign) BOOL shouldCallBack;
@property (nonatomic, assign) BOOL warrantyHasValues;

@property (nonatomic, strong) NSString* lastIndex;
@property (nonatomic, strong) NSString* lastID;

@property (nonatomic, strong) NSMutableArray *callBackValuesFromFirstAPIResponse;

@property (nonatomic, strong) NSMutableDictionary *heapModelDict;
@property (nonatomic, strong) NSMutableDictionary *partiallyExecutedObjectValueMap;

@property (nonatomic, strong) NSMutableArray *objectNames;

@end

@implementation DataPurgeParser
- (ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                      responseData:(id)responseData
{
    @synchronized([self class]){
        @autoreleasepool {
            
            if (![responseData isKindOfClass:[NSDictionary class]]) {
                return nil;
            }
            
            RequestType requestType = RequestTypeNone;
            ResponseCallback *callback;
            
            NSString *requestTypeStr = [requestParamModel.requestInformation objectForKey:@"key"];
            if(requestTypeStr){
                requestType = [requestTypeStr intValue];
            }
            
            switch (requestType) {
                case RequestDatPurgeDownloadCriteria:
                {
                    callback = [self parseDCResponseWithRequestParammodel:requestParamModel
                                                           responseData:responseData];
                }
                break;
                case RequestDataPurgeAdvancedDownLoadCriteria:
                {
                    callback = [self parseADCResponseWithRequestParammodel:requestParamModel
                                                            responseData:responseData];
                }
                break;
                case RequestDataPurgeGetPriceDataTypeZero:
                case RequestDataPurgeGetPriceDataTypeOne:
                case RequestDataPurgeGetPriceDataTypeTwo:
                case RequestDataPurgeGetPriceDataTypeThree:
                {
                    callback = [self parseAnaAddaIdsForGetPriceResponse:responseData];
                }
                break;
                case RequestDataPurgeFrequency:
                {
                    callback = [self saveLastconfigSyncTimeFromResponseData:responseData];
                }
                    break;
                    
                case RequestDataPurgeProductIQData:
                {
                    //TODO: implement parser logic for ProductIQData.
                    callback = [self parseAnaAddaIdsForProductIQDataResponse:responseData];
                }
                    break;

                default:
                    break;
            }
            
            return callback;
        }
    }
}

- (ResponseCallback *)parseDCResponseWithRequestParammodel:(RequestParamModel*)requestParamModel
                                              responseData:(id)responseData
{
    BOOL callBack;
    
    NSDictionary *responseDict = (NSDictionary *)responseData;
    NSMutableDictionary *heapDictionary = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *callBackValues = [[NSMutableArray alloc] init];
    
    /* partiallyExecutedObjectValueMap : Stores valueMap of Partially executed object.
     key     : PARTIALLY_EXECUTED_OBJECT
     value   : Object Name
     values  : List of SFIds received in current response of the object
     */
    NSMutableDictionary *partiallyExecutedObjectDictionary = [[NSMutableDictionary alloc] init];
    
     NSArray *valuesArray = [responseDict objectForKey:kSVMXRequestValues];
    
    ResponseCallback *callbk = [[ResponseCallback alloc] init];
    callbk.callBack = NO;
    
    RequestParamModel *newRequestModel = [[RequestParamModel alloc] init];
    callbk.callBackData = newRequestModel;
    NSArray *objectsArray = [responseDict objectForKey:kSVMXRequestSVMXMap];
    if ([objectsArray isKindOfClass:[NSArray class]] && [objectsArray count] > 0)
    {
        /* Parse every object in main valueMap of response */
        for (int counter = 0; counter < [objectsArray count]; counter++)
        {
            NSDictionary *objectValueMap = objectsArray[counter];
            NSString *objectName = [objectValueMap objectForKey:kSVMXRequestKey];
            
            if([objectName isEqualToString:kADCPartiallyExecutedObjectKey])  /* Partially executed object valueMap */
            {
                [partiallyExecutedObjectDictionary addEntriesFromDictionary:objectValueMap];
            }
            else if([objectName isEqualToString:kADCCallBackKey]) /*  CallBack valueMap */
            {
                callBack = [[objectValueMap objectForKey:kSVMXRequestValue] boolValue];
                
                if(callBack)
                    [callBackValues addObjectsFromArray:[responseDict objectForKey:kSVMXRequestValues]];
            }
            else  /* Objects' valueMap */
            {
                /* Parse valuemaps for all other objects */
                [self parseAndAddIdsForDowNloadCriteriaFromResponse:objectValueMap toDictionary:heapDictionary forObjectName:objectName];
            }
        }
        
        if([[partiallyExecutedObjectDictionary allKeys] count])
        {
            NSString *finalValue = nil;
            
            NSString *partiallyExecutedObjName = [partiallyExecutedObjectDictionary objectForKey:kSVMXRequestValue];
            
            if((![partiallyExecutedObjName isEqualToString:@""]) && (partiallyExecutedObjName != nil))
            {
                NSArray *callbackArray = [partiallyExecutedObjectDictionary objectForKey:kSVMXRequestSVMXMap];
                finalValue = [[callbackArray lastObject] objectForKey:kSVMXRequestValue];
                if (finalValue != nil) {
                    [partiallyExecutedObjectDictionary setObject:@[finalValue] forKey:kSVMXRequestValues];
                    newRequestModel.valueMap = @[partiallyExecutedObjectDictionary];
                    callbk.callBack = YES;
                    [partiallyExecutedObjectDictionary setObject:@[] forKey:kSVMXRequestSVMXMap];
                    if (valuesArray != nil) {
                        newRequestModel.values = valuesArray;
                    }
                    else{
                        newRequestModel.values = @[];
                    }
                }
            }
        }
    }
    
    return  callbk;
}


-(void)parseAndAddIdsForDowNloadCriteriaFromResponse:(NSDictionary *)objectValueMap
                                        toDictionary:(NSMutableDictionary *)heapDictionary
                                       forObjectName:(NSString *)objectName
{
    NSString *jsonString = [objectValueMap objectForKey:kSVMXRequestValue];
    NSData *jsonData;
    if (jsonString.length > 0 && jsonString != nil && ![jsonString isKindOfClass:[NSNull class]]) {
        
        jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSArray *sfIdResponseArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
        
        if ([sfIdResponseArray isKindOfClass:[NSArray class] ] && [sfIdResponseArray count] > 0) {
            
            NSMutableArray *models = [[NSMutableArray alloc]initWithCapacity:0];
            for (NSDictionary *sfIdValueMap in sfIdResponseArray)
            {
                NSString *sfId = [sfIdValueMap objectForKey:kId];
                if ([StringUtil isStringEmpty:sfId]) {
                    continue;
                }
                sfId = [sfId stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                sfId = [sfId stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                DataPurgeModel *model = [DataPurgeModel new];
                model.sfId = sfId;
                model.objectName = objectName;
                [models addObject:model];
            }
            [self saveModelsToDataPurgeTable:models];
        }
    }
}

- (ResponseCallback *)parseADCResponseWithRequestParammodel:(RequestParamModel*)requestParamModel
                                               responseData:(id)responseData
{
    NSDictionary *responseDict = (NSDictionary *)responseData;
    
    NSMutableDictionary *partiallyExecutedObjectDictionary = [[NSMutableDictionary alloc] init];
    
    ResponseCallback *callbk = [[ResponseCallback alloc] init];
    callbk.callBack = NO;
    
    NSArray *objectsArray = [responseDict objectForKey:kSVMXRequestSVMXMap];
    
    NSArray *objectNameValues = [responseDict objectForKey:kSVMXRequestValues];
    
    if ([objectsArray isKindOfClass:[NSArray class]] && [objectsArray count] > 0)
    {
        /* Parse every object in main valueMap of response */
        for (int counter = 0; counter < [objectsArray count]; counter++)
        {
            NSDictionary *objectValueMap = objectsArray[counter];
            NSString *objectName = [objectValueMap objectForKey:kSVMXRequestKey];
            
            if([objectName isEqualToString:kADCPartiallyExecutedObjectKey])  /* Partially executed object valueMap */
            {
                [partiallyExecutedObjectDictionary addEntriesFromDictionary:objectValueMap];
            }
            else if([objectName isEqualToString:kADCDeleteKey])  /* Delete valueMap */
            {
                // [self deletedIdsFromResponse:objectValueMap];
                //Need to delete records from respective tables.
            }
            else if([objectName isEqualToString:kADCCallBackKey]) /*  CallBack valueMap */
            {
                callbk.callBack = [[objectValueMap objectForKey:kSVMXRequestValue] boolValue];
                
            }
            else  /* Objects' valueMap */
            {
                /* Parse valuemaps for all other objects */
                [self saveSFIDsFromADCResponse:objectValueMap forObjectName:objectName];
            }
        }
        
        NSArray *sfidsArray = nil;
        // Only if there are entries inside partiallyExecutedObjectValueMap then fill in the data
        if([partiallyExecutedObjectDictionary count])
        {
            NSString *partiallyExecutedObjName = [partiallyExecutedObjectDictionary objectForKey:kSVMXRequestValue];
            
            if((![partiallyExecutedObjName isEqualToString:@""]) && (partiallyExecutedObjName != nil))
            {
                id daoService = [FactoryDAO serviceByServiceType:ServiceTypeDataPurge];
                
                if ([daoService conformsToProtocol:@protocol(DataPurgeDAO)]) {
                    sfidsArray = [daoService fetchSfIdsForObjectName:partiallyExecutedObjName];
                    NSMutableArray *sfids = [[NSMutableArray alloc] init];
                    for (DataPurgeModel *model in sfidsArray) {
                        [sfids addObject:model.sfId];
                    }
                    
                    //Add sfids to partiallyExecutedObjectDictionary with values
                    [partiallyExecutedObjectDictionary setObject:sfids forKey:kSVMXRequestValues];
                }
            }
        }
        
        // First object  : Remaining Objects;
        // Second object : Partially Executed Object ValueMap;
        if (callbk.callBack) {
            
            RequestParamModel *callbackData = [[RequestParamModel alloc] init];
            callbackData.values = objectNameValues;
            
            //[NSArray arrayWithObjects:callBackValues, sfidsArray, nil];
            
            NSDictionary *adcOptimized = [NSDictionary dictionaryWithObjects:@[kADCOptimized, kTrue] forKeys:@[kSVMXKey, kSVMXValue]]; // IPAD-4698
            
            if ([partiallyExecutedObjectDictionary count] > 0) {
                callbackData.valueMap = [NSArray arrayWithObjects:partiallyExecutedObjectDictionary, adcOptimized, nil]; // removed last_sync_time key, not needed for data purge.
            }
            callbk.callBackData = callbackData;
            
        }

    }
    return callbk;
}

- (void)saveSFIDsFromADCResponse:(NSDictionary *)objectValueMap forObjectName:(NSString *)objectName
{
    NSArray *sfIdResponseArray = [objectValueMap objectForKey:kSVMXRequestSVMXMap];
    if ([sfIdResponseArray isKindOfClass:[NSArray class]] && [sfIdResponseArray count] > 0)
    {
        NSMutableArray *models = [[NSMutableArray alloc]initWithCapacity:0];
        for (NSDictionary *sfIdValueMap in sfIdResponseArray)
        {
            NSString *sfId = [sfIdValueMap objectForKey:kSVMXRequestValue];
            if ([StringUtil isStringEmpty:sfId]) {
                continue;
            }
            sfId = [sfId stringByReplacingOccurrencesOfString:@"\\" withString:@""];
            sfId = [sfId stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            DataPurgeModel *model = [DataPurgeModel new];
            model.sfId = sfId;
            model.objectName = objectName;
            [models addObject:model];
        }
        [self saveModelsToDataPurgeTable:models];
    }
}

- (ResponseCallback *)parseAnaAddaIdsForGetPriceResponse:(NSDictionary *)rawResponseData
{
    ResponseCallback * callBack;
    NSString *lastIndex;
    if(lastIndex == nil)
    {
        NSArray *objectsArray = [rawResponseData objectForKey:kSVMXSVMXMap];
        if ([objectsArray isKindOfClass:[NSArray class]] && [objectsArray count] > 0)
        {
            for (NSDictionary * svmxMapObject in objectsArray)
            {
                NSString *key = [svmxMapObject objectForKey:kSVMXRequestKey];
                
                
                if([key isEqualToString:kGetPriceDataPricingData])
                {
                    NSString *apiIndex = [svmxMapObject objectForKey:kSVMXValue];
                    
                    // TODO : 010974 : Response is not proper; To be solved while configuring on server or in server side code
                    if(((NSNull *) apiIndex == [NSNull null]) || [apiIndex isKindOfClass:[NSNull class]] || apiIndex == NULL || apiIndex == nil)
                        return nil;
                    
                    NSDictionary *lastIndexValueMap = [self getLastIndexValueMap:rawResponseData];
                    switch ([apiIndex intValue])
                    {
                        case 1:
                            SXLogDebug(@"Call One");
                            callBack.callBack = [self processFirstAndLastResponse:svmxMapObject];
                            if(callBack.callBack && !self.isWOCountZero) {
                                callBack.callBackData.valueMap = [NSArray arrayWithObjects:lastIndexValueMap, [self getCallBackValueMap:rawResponseData], self.callBackValuesFromFirstAPIResponse, nil];
                                callBack.callBackData.values = [NSArray arrayWithArray:self.objectNames];
                            }
                            break;
                        case 2:
                            SXLogDebug(@"Call Two");
                            callBack.callBack = [self processResponse:svmxMapObject];
                            if(callBack.callBack)
                            {
                                NSDictionary *peo =[self getPartiallyExecutedObjectValueMap];
                                if([[peo allKeys] count]) {
                                    callBack.callBackData.valueMap = [NSArray arrayWithObjects:lastIndexValueMap, [self getCallBackValueMap:rawResponseData], peo, nil];
                                }
                                else {
                                    callBack.callBackData.valueMap = [NSArray arrayWithObjects:lastIndexValueMap, [self getCallBackValueMap:rawResponseData], peo, nil];
                                }
                                callBack.callBackData.values = [NSArray arrayWithArray:self.objectNames];
                            }
                            break;
                        case 3:
                            callBack.callBack = [self processResponse:svmxMapObject];
                            if(callBack.callBack)
                            {
                                NSDictionary *peo =[self getPartiallyExecutedObjectValueMap];
                                if([[peo allKeys] count]) {
                                    callBack.callBackData.valueMap = [NSArray arrayWithObjects:lastIndexValueMap, [self getCallBackValueMap:rawResponseData], peo, nil];
                                }
                                else {
                                    callBack.callBackData.valueMap = [NSArray arrayWithObjects:lastIndexValueMap, [self getCallBackValueMap:rawResponseData], peo, nil];
                                }
                                callBack.callBackData.values = [NSArray arrayWithArray:self.objectNames];
                            }
                            SXLogDebug(@"Call Three");
                            break;
                        case 4:
                            callBack.callBack = [self processFirstAndLastResponse:svmxMapObject];
                            
                            if(callBack.callBack && (![self.lastID isEqualToString:@""]) && (self.lastID != nil) && self.warrantyHasValues)
                            {
                                callBack.callBackData.valueMap = [NSArray arrayWithObjects:lastIndexValueMap, [self getCallBackValueMap:rawResponseData], [self getLastIDValueMap:rawResponseData], nil];
                                callBack.callBackData.values = [NSArray arrayWithArray:self.objectNames];
                            }
                            else
                            {
                                callBack.callBack = NO;
                            }
                            
                            SXLogDebug(@"Call Four");
                            break;
                        default:
                            break;
                    } // END : Switch
                    
                }
            }
        }
    }
    return callBack;
}

-(ResponseCallback*)parseAnaAddaIdsForProductIQDataResponse:(NSDictionary *)responseData {
    
    @synchronized([self class]){
        @autoreleasepool {
            
            if (![responseData isKindOfClass:[NSDictionary class]]) {
                return nil;
            }
            
            if (![[responseData objectForKey:@"success"] isKindOfClass:[NSNull class]] &&[[responseData objectForKey:@"success"] intValue] == 0) {
                return nil;
            }
            
            NSDictionary *responseDictionary = (NSDictionary *)responseData;
            
            BOOL siteIdsExist = YES, ibIdsExist = YES;
            NSMutableArray *callBackValueMapArray = [[NSMutableArray alloc] init];
            ResponseCallback *callbk = [[ResponseCallback alloc] init];
            callbk.callBack = NO;
            
            RequestParamModel *newRequestModel = [[RequestParamModel alloc] init];
            callbk.callBackData = newRequestModel;
            
            NSDictionary *levelDict, *callBackDict, *timeLogDict, *lastIndexDict, *lastSyncTimeDict;
            
            NSArray *valueMapArray = [responseDictionary objectForKey:kSVMXSVMXMap];
            
            if ([valueMapArray count] <= 1) {
                if ([valueMapArray count] == 1) {
                    lastSyncTimeDict = [valueMapArray objectAtIndex:0];
                    if ([[lastSyncTimeDict objectForKey:kSVMXKey] isEqualToString:@"PRODUCTIQ_LAST_SYNC"]) {
                        // no call back.. one of objects' permission is disabled..
//                        // don't call PIQ TxFetch during initial sync if object permission is disbaled..
//                        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"kProdIQDataPermissionFailed"];
//                        [[NSUserDefaults standardUserDefaults] synchronize];
//                        
//                        [self updateProdIQLastSyncTime:lastSyncTimeDict];
                    }
                }
                // no call back.. end the request
            }
            else {
                
                for (NSDictionary *valueMapDict in valueMapArray) {
                    NSString *key = [valueMapDict objectForKey:kSVMXKey];
                    
                    if ([StringUtil isStringEmpty:key]) {
                        
                    }
                    else if ([key isEqualToString:@"LEVEL"]) {
                        levelDict = valueMapDict;
                    }
                    else if ([key isEqualToString:kWorkOrderSite]) {
                        NSArray *values = [valueMapDict objectForKey:kSVMXValues];
                        if ([values count] > 0) {
                            [self addFirstIndexEntriesInDataPurgeTableForObject:key andValues:values];
                        }
                        else {
                            siteIdsExist = NO;
                        }
                    }
                    else if ([key isEqualToString:kInstalledProductTableName]) {
                        NSString *value = [valueMapDict objectForKey:kSVMXValue];
                        NSData *jsonData = [value dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *e = nil;;
                        NSArray *valueArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e]
                        ;
                        
                        if ([valueArray count] > 0) {
                            [self addSecondIndexEntriesDataPurgeTable:valueArray];
                        }
                        else {
                            ibIdsExist = NO;
                        }
                    }
                    else if ([key isEqualToString:kSVMXCallBack]) {
                        callbk.callBack = [[valueMapDict objectForKey:kSVMXValue] boolValue];
                        callBackDict = valueMapDict;
                    }
                    else if ([key isEqualToString:kTimeLogId]) {
                        timeLogDict = valueMapDict;
                    }
                    else if ([key isEqualToString:@"LAST_INDEX"]) {
                        lastIndexDict = valueMapDict;
                    }
                    else if ([key isEqualToString:@"PRODUCTIQ_LAST_SYNC"]) {
                        lastSyncTimeDict = valueMapDict;
                    }
                }
                
                // end of loop..
                
                
                if (callbk.callBack) {
                    // make call back
                    NSArray *tempArray =  @[levelDict, callBackDict, lastIndexDict];
                    [callBackValueMapArray addObjectsFromArray:tempArray];
                    newRequestModel.valueMap = callBackValueMapArray;
                    newRequestModel.values = @[];
                    return callbk;
                }
                else {
                    // transition phase..
                    if (siteIdsExist == NO  && [[lastIndexDict objectForKey:kSVMXValue] integerValue] == 1) {
                        siteIdsExist = YES; //  resetting - so this block won't get called again..
                        
                        NSArray *tempArray = @[lastIndexDict];
                        
                        [callBackValueMapArray addObjectsFromArray:tempArray];
                        callbk.callBack = YES;
                        newRequestModel.valueMap = callBackValueMapArray;
                        newRequestModel.values = @[];
                        return callbk;
                    }
                    else if (ibIdsExist == NO) {
                        // stop - no call back - request ends here..
                        if (lastSyncTimeDict) {
//                            [self updateProdIQLastSyncTime:lastSyncTimeDict];
                        }
                    }
                    else {
                        // ib call back..
                        
                        NSArray *tempArray = @[levelDict, callBackDict, lastIndexDict];
                        [callBackValueMapArray addObjectsFromArray:tempArray];
                        newRequestModel.valueMap = callBackValueMapArray;
                        newRequestModel.values = @[];
                        return callbk;
                    }
                }
                
            }
            return nil;
        }
    }
}

-(void)addFirstIndexEntriesInDataPurgeTableForObject:(NSString *)objectName andValues:(NSArray *)values {
    NSMutableArray *dataPurgeArray = [[NSMutableArray alloc] init];
    for (NSString *sfID in values) {
        
        DataPurgeModel *model = [DataPurgeModel new];
        model.sfId = sfID;
        model.objectName = objectName;
        
        [dataPurgeArray addObject:model];
    }
    
    if([dataPurgeArray count] > 0) {
        [self saveModelsToDataPurgeTable:dataPurgeArray];
    }
}

-(void)addSecondIndexEntriesDataPurgeTable:(NSArray *)valuesArray {
    
    NSArray *fieldsArray = @[kId, kProductField, kWorkOrderCompanyId, kWorkOrderSite, KSubLocationTableName, kTopLevelId];
    id <SFObjectFieldDAO> objectFieldService = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    NSMutableArray *dataPurgeArray = [NSMutableArray array];
    
    for (NSDictionary *recordDict in valuesArray) {
        for (NSString *fieldName in recordDict) {
            if ([fieldsArray containsObject:fieldName]) {
                NSString *objectName = nil;
                if ([fieldName isEqualToString:kId]) {
                    objectName = kInstalledProductTableName;
                }
                else {
                    objectName = [objectFieldService getReferenceToFromFieldName:fieldName andObjectName:kInstalledProductTableName];
                }
                
                if (![StringUtil isStringEmpty:objectName]) {
                    
                    DataPurgeModel *model = [DataPurgeModel new];
                    model.sfId = [recordDict objectForKey:fieldName];;
                    model.objectName = objectName;
                    [dataPurgeArray addObject:model];
                }
                
            }
        }
    }
    
    if ([dataPurgeArray count] > 0) {
        [self saveModelsToDataPurgeTable:dataPurgeArray];
    }
}


- (NSDictionary*)getCallBackValueMap:(NSDictionary *)rawResponseData
{
    NSDictionary *svmxReturnMapObject = [NSDictionary dictionary];
    NSArray *objectsArray = [rawResponseData objectForKey:kSVMXSVMXMap];
    if ([objectsArray isKindOfClass:[NSArray class]] && [objectsArray count] > 0)
    {
        for (NSDictionary * svmxMapObject in objectsArray)
        {
            NSString *key = [svmxMapObject objectForKey:kSVMXRequestKey];
            if([key isEqualToString:kGetPriceDataPricingData])
            {
                NSArray *valueMapArray = [svmxMapObject objectForKey:kSVMXSVMXMap];
                for(int j = 0; j < [valueMapArray count]; j++)
                {
                    svmxReturnMapObject = [valueMapArray objectAtIndex:j];
                    NSString *key = [svmxReturnMapObject objectForKey:kSVMXRequestKey];
                    if([key isEqualToString:kSVMXCallBack])
                        break;
                }
            }
        }
    }
    
    return svmxReturnMapObject;
}

- (NSDictionary*)getLastIDValueMap:(NSDictionary *)rawResponseData
{
    NSDictionary *svmxReturnMapObject = [NSDictionary dictionary];
    NSArray *objectsArray = [rawResponseData objectForKey:kSVMXSVMXMap];
    if ([objectsArray isKindOfClass:[NSArray class]] && [objectsArray count] > 0)
    {
        for (NSDictionary * svmxMapObject in objectsArray)
        {
            NSString *key = [svmxMapObject objectForKey:kSVMXRequestKey];
            if([key isEqualToString:kGetPriceDataPricingData])
            {
                NSArray *valueMapArray = [svmxMapObject objectForKey:kSVMXSVMXMap];
                for(int j = 0; j < [valueMapArray count]; j++)
                {
                    svmxReturnMapObject = [valueMapArray objectAtIndex:j];
                    NSString *key = [svmxReturnMapObject objectForKey:kSVMXKey];
                    if([key isEqualToString:kGetPriceDataLastId])
                        break;
                }
            }
        }
    }
    
    return svmxReturnMapObject;
}


- (NSDictionary*)getLastIndexValueMap:(NSDictionary *)rawResponseData
{
    NSDictionary *svmxReturnMapObject = [NSDictionary dictionary];
    if(self.lastIndex == nil)
    {
        NSArray *objectsArray = [rawResponseData objectForKey:kSVMXSVMXMap];
        if ([objectsArray isKindOfClass:[NSArray class]] && [objectsArray count] > 0)
        {
            for (NSDictionary * svmxMapObject in objectsArray)
            {
                NSString *key = [svmxMapObject objectForKey:kSVMXRequestKey];
                if([key isEqualToString:kGetPriceDataPricingData])
                {
                    NSArray *valueMapArray = [svmxMapObject objectForKey:kSVMXSVMXMap];
                    for(int j = 0; j < [valueMapArray count]; j++)
                    {
                        svmxReturnMapObject = [valueMapArray objectAtIndex:j];
                        NSString *key = [svmxReturnMapObject objectForKey:kSVMXRequestKey];
                        if([key isEqualToString:kGetPriceDataLastIndex])
                        {
                           // [self setLastIndexAndCurrentRequestType:svmxReturnMapObject];
                            break;
                        }
                    }
                    
                }
            }
        }
    }
    return svmxReturnMapObject;
}



- (BOOL)processFirstAndLastResponse:(NSDictionary*)inputMapObject
{
    self.isWOCountZero = FALSE;
    
    NSArray *valueMapArray = [inputMapObject objectForKey:kSVMXSVMXMap];
    
    for(int j = 0; j < [valueMapArray count]; j++)
    {
        NSDictionary *svmxMapObject = [valueMapArray objectAtIndex:j];
        NSString *key = [svmxMapObject objectForKey:kSVMXRequestKey];
        
        if([key isEqualToString:kSVMXCallBack])
        {
            self.shouldCallBack = [[svmxMapObject objectForKey:kSVMXValue] boolValue];
        }
        else if([key isEqualToString:kGetPriceDataLastIndex])
        {
            //[self setLastIndexAndCurrentRequestType:svmxMapObject];
        }
        else if([key isEqualToString:kGetPriceDataLastId])
        {
            self.lastID = [svmxMapObject objectForKey:kSVMXValue];
        }
        else if([key isEqualToString:kWorkOrderTableName])
        {
            NSString *jsonRecord = [svmxMapObject objectForKey:kSVMXValue];
            NSData *jsonData = [jsonRecord dataUsingEncoding:NSUTF8StringEncoding];
        
            
            NSArray *sfIdArray = [[NSArray alloc]initWithObjects:svmxMapObject, nil];
            [self parseSfIdsWithTheArray:sfIdArray forTheObjectName:key];
            
            if ([jsonData length] && ![jsonRecord isKindOfClass:[NSNull class]]) {
                
                NSError *e;
                NSArray * json_array = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
                if(json_array && [json_array count])
                {
                    [self.callBackValuesFromFirstAPIResponse addObjectsFromArray:json_array];
                }
                else
                {
                    self.isWOCountZero = TRUE;
                }
            }
        }
        else
        {
            NSArray *sfIdArray = [[NSArray alloc]initWithObjects:svmxMapObject, nil];
            [self parseSfIdsWithTheArray:sfIdArray forTheObjectName:key];
            
            NSString *jsonRecord = [svmxMapObject objectForKey:kSVMXValue];
            NSData *jsonData = [jsonRecord dataUsingEncoding:NSUTF8StringEncoding];
            
            if([jsonData length] && ![jsonRecord isKindOfClass:[NSNull class]])
            {
                NSError *e;
                NSArray * json_array = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
                
                if(json_array && [json_array count])
                {
                  // For fourth API call
                    if([key isEqualToString:kGetPriceWarrantyObjectName])
                        self.warrantyHasValues = TRUE;
                    
                } // END : if json_array
                
            } // END : if jsonRecord
            
        } // END : else
        
    } // END : valueMap loop
    
    return self.shouldCallBack;
    
}

- (BOOL)processResponse:(NSDictionary*)smxMapObject
{
    BOOL callBack = FALSE;
    NSArray *objectsArray = [smxMapObject objectForKey:kSVMXSVMXMap];
    NSMutableDictionary *objectNameDict = [[NSMutableDictionary alloc] init];
    
    if ([objectsArray isKindOfClass:[NSArray class]] && [objectsArray count])
    {
        
        /* Parse every object in main valueMap of response */
        for (int counter = 0; counter < [objectsArray count]; counter++)
        {
            NSDictionary *objectValueMap = objectsArray[counter];
            NSString *objectName = [objectValueMap objectForKey:kSVMXRequestKey];
            
            if([objectName isEqualToString:kADCPartiallyExecutedObjectKey])  /* Partially executed object valueMap */
            {
                self.partiallyExecutedObjectValueMap = [NSMutableDictionary dictionary];
                [self.partiallyExecutedObjectValueMap addEntriesFromDictionary:objectValueMap];
            }
            else if([objectName isEqualToString:kGetPriceDataLastIndex])
            {
               // [self setLastIndexAndCurrentRequestType:objectValueMap];
            }
            else if([objectName isEqualToString:kADCCallBackKey]) /*  CallBack valueMap */
            {
                callBack = [[objectValueMap objectForKey:kSVMXValue] boolValue];
            }
            else if([objectName isEqualToString:kGetPriceDataLastId])
            {
                self.lastID = [objectValueMap objectForKey:kSVMXValue];
            }
            else  /* Objects' valueMap */
            {
                /* Parse valuemaps for all other objects */
                
                NSArray *sfIdResponseArray = [objectValueMap objectForKey:kSVMXSVMXMap];
                
                if ([sfIdResponseArray isKindOfClass:[NSArray class]] && [sfIdResponseArray count] > 0)
                {
                    
                    NSMutableArray *valueArray = [[NSMutableArray alloc] init];
                    
                    for (NSDictionary *sfIdValueMap in sfIdResponseArray)
                    {
                        NSString *jsonString = [sfIdValueMap objectForKey:kSVMXValue];
                        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                        
                        if([jsonData length] && ![jsonString isKindOfClass:[NSNull class]])
                        {
                            NSError *e;
                            
                            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
                            NSString *sfId = [jsonDict objectForKey:@"Id"];
                            sfId = [sfId stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                            sfId = [sfId stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                            
                            if (![valueArray containsObject:sfId] && [sfId length]) {
                                [valueArray addObject:sfId];
                            }
                            
                            /*if(json_array && [json_array count])
                            {
                                // For fourth API call
                                if([objectName isEqualToString:kGetPriceWarrantyObjectName])
                                    self.warrantyHasValues = TRUE;
                                
                            }*/ // END : if json_array
                            
                        } // END : if jsonRecord
                    }
                    if([valueArray count])
                    {
                        [self insertSfIdsWithTheArray:valueArray forTheObjectName:objectName];
                        // For fourth API call
                        if([objectName isEqualToString:kGetPriceWarrantyObjectName])
                            self.warrantyHasValues = TRUE;
                    }
                }
            }
        }
        
        /* Only if there are entries inside partiallyExecutedObjectValueMap then fill in the data */
        if([[self.partiallyExecutedObjectValueMap allKeys] count])
        {
            NSString *partiallyExecutedObjName = [self.partiallyExecutedObjectValueMap objectForKey:kSVMXValue];
            
            if((![partiallyExecutedObjName isEqualToString:@""]) && (partiallyExecutedObjName != nil))
            {
                NSDictionary *sfids = [objectNameDict objectForKey:partiallyExecutedObjName];
                NSArray *listOfPEOIds = [sfids allKeys];
                if((listOfPEOIds != nil) || [listOfPEOIds count])
                    [self.partiallyExecutedObjectValueMap setObject:listOfPEOIds forKey:kSVMXValues];
                else
                {
                    self.partiallyExecutedObjectValueMap = nil;
                    if([self.objectNames count])
                    {
                        [self.objectNames removeObject:partiallyExecutedObjName];
                        if(![self.objectNames count])
                            callBack = FALSE;
                    }
                }
            }
        }
    }
    return callBack;
}


- (NSDictionary*)getPartiallyExecutedObjectValueMap
{
    return self.partiallyExecutedObjectValueMap;
}



- (void)insertSfIdsWithTheArray:(NSArray *)sfIdArray forTheObjectName:(NSString *)objectName
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    

    for(NSString *string in sfIdArray)
    {
        NSString *sfId = string;
        if ([StringUtil isStringEmpty:sfId]) {
            continue;
        }
        sfId = [sfId stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        sfId = [sfId stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        DataPurgeModel *model = [DataPurgeModel new];
        model.sfId = sfId;
        model.objectName = objectName;
        [models addObject:model];
    }
    [self saveModelsToDataPurgeTable:models];
}

- (void)parseSfIdsWithTheArray:(NSArray *)sfIdArray forTheObjectName:(NSString *)objectName
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    
    for (NSDictionary *sfIdValueMap in sfIdArray)
    {
        NSString *jsonRecord = [sfIdValueMap objectForKey:kSVMXRequestValue];
        
        // NSString *jsonRecord = [svmxMapObject objectForKey:kSVMXValue];
        NSData *jsonData = [jsonRecord dataUsingEncoding:NSUTF8StringEncoding];
        
        if([jsonData length] && ![jsonRecord isKindOfClass:[NSNull class]])
        {
            NSError *e;
            NSArray * jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
            for(NSString *string in jsonArray)
            {
                NSString *sfId = string;
                if ([StringUtil isStringEmpty:sfId]) {
                    continue;
                }
                sfId = [sfId stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                sfId = [sfId stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                
                DataPurgeModel *model = [DataPurgeModel new];
                model.sfId = sfId;
                model.objectName = objectName;
                [models addObject:model];
            }
        }
    }
    
    [self saveModelsToDataPurgeTable:models];
}


- (BOOL)saveModelsToDataPurgeTable:(NSMutableArray *)models {
    
    BOOL status = NO;
    if ([models count]) {
        id service = [FactoryDAO serviceByServiceType:ServiceTypeDataPurge];
        if ([service conformsToProtocol:@protocol(DataPurgeDAO)]) {
            status = [service saveRecordModels:models];
            if (status) {
                /** Success **/
            }
        }
    }
    return status;
}

- (ResponseCallback *)saveLastconfigSyncTimeFromResponseData:(id)responseData
{
    ResponseCallback *callbk = [[ResponseCallback alloc] init];
    callbk.callBack = NO;
    NSDictionary *responseDict = (NSDictionary *)responseData;
    NSArray *valueMap = [responseDict objectForKey:kSVMXRequestSVMXMap];
    if ([valueMap isKindOfClass:[NSArray class]] && [valueMap count] > 0)
    {
        for (NSDictionary * svmxMapObject in valueMap)
        {
            NSString *key = [svmxMapObject objectForKey:kSVMXRequestKey];
            if([key isEqualToString:kWSAPIResponseDataPurgeConfigLastModifiedDate])
            {
                NSString *value = [svmxMapObject objectForKey:kSVMXRequestValue];
                if (value && value.length) {
                    [SMDataPurgeManager sharedInstance].responseLastConfigTime = [value stringByAppendingString:@" +0000"];
                    return callbk;
                }
            }
        }
    }
    else
    {//Defect Fix:029743
         [SMDataPurgeManager sharedInstance].responseLastConfigTime = @"";
    }
    
    return callbk;
}

- (NSDictionary *)getLastSyncTimeForRecords {
    NSMutableDictionary *lastSyncTimeDict = [NSMutableDictionary dictionary];
    [lastSyncTimeDict setObject:kLastSyncTime forKey:kSVMXRequestKey];
    NSString *lastSyncTime = [PlistManager getInitialSyncTime];
    if (lastSyncTime == nil) {
        lastSyncTime = @"";
    }
    [lastSyncTimeDict setObject:lastSyncTime forKey:kSVMXRequestValue];
    return lastSyncTimeDict;
}


@end
