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

@implementation DataPurgeParser
- (ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                      responseData:(id)responseData
{
    @synchronized([self class]){
        @autoreleasepool {
            
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
                    callBack = YES;
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
    NSDictionary *svmxReturnMapObject = [NSDictionary dictionary];
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
                    NSArray *valueMapArray = [svmxMapObject objectForKey:kSVMXSVMXMap];
                    for(int j = 0; j < [valueMapArray count]; j++)
                    {
                        svmxReturnMapObject = [valueMapArray objectAtIndex:j];
                        NSString *key = [svmxReturnMapObject objectForKey:kSVMXRequestKey];
                        if([key isEqualToString:kGetPriceDataLastIndex])
                        {
                            
                        }
                        if([key isEqualToString:kADCCallBackKey])
                        {
                            if (callBack == nil) {
                                callBack = [ResponseCallback new];
                            }
                            
                            callBack.callBack = [[svmxReturnMapObject objectForKey:kSVMXValue] boolValue];;
                            
                        }
                        else
                        {
                            NSArray *sfIdArray = [[NSArray alloc]initWithObjects:svmxReturnMapObject, nil];
                            [self parseSfIdsWithTheArray:sfIdArray forTheObjectName:key];
                            
                        }
                    }
                    
                }
            }
        }
    }
    return callBack;
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
                    [SMDataPurgeManager sharedInstance].responseLastConfigTime = value;
                    return callbk;
                }
            }
        }
    }
    return callbk;
}
@end
