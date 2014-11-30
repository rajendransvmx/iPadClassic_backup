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

@implementation DataPurgeParser
- (ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                      responseData:(id)responseData
{
    @synchronized([self class])
    {
        @synchronized([self class]){
            @autoreleasepool {
                
                RequestType currentRequestType = RequestTypeNone;
                
                NSString * requestTypeStr = nil;
                
                requestTypeStr = [requestParamModel.requestInformation objectForKey:@"key"];
                if(requestTypeStr != nil){
                    currentRequestType = [requestTypeStr intValue];
                }
                ResponseCallback *callback = [[ResponseCallback alloc] init];
                callback.callBack = NO;
                
                if( currentRequestType == RequestDatPurgeDownloadCriteria)
                {
                    callback.callBack = [self ParseDataForDownLoadcriteriaForresponseData:responseData];
                    return callback;
                }
                if( currentRequestType == RequestDataPurgeAdvancedDownLoadCriteria)
                {
                    callback.callBack = [self ParseDataForAdvancedDownLoadcriteriaForResponseData:responseData];
                    return callback;
                    
                }
                if(( currentRequestType == RequestDataPurgeGetPriceDataTypeZero) ||
                   (currentRequestType == RequestDataPurgeGetPriceDataTypeOne)  ||
                    (currentRequestType = RequestDataPurgeGetPriceDataTypeTwo ) ||
                   (currentRequestType = RequestDataPurgeGetPriceDataTypeThree ))
                {
                    
                    
                    callback.callBack = [self parseAnaAddaIdsForGetPriceResponse:responseData andRequestMpdel:requestParamModel] ;
                }
                
                
            }
        }
           return nil;
    }
}

- ( BOOL)ParseDataForDownLoadcriteriaForresponseData:(id)responseData
{
    BOOL callBack = NO;
    NSDictionary *responseDict = (NSDictionary *)responseData;
    NSMutableDictionary *heapDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *callBackValues = [[NSMutableArray alloc] init];
    NSMutableDictionary *partiallyExecutedObjectDictionary = [[NSMutableDictionary alloc] init];
    NSArray *objectsArray = [responseDict objectForKey:kSVMXRequestSVMXMap];
    if ([objectsArray isKindOfClass:[NSArray class]] && [objectsArray count] > 0)
    {
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
//                    newRequestModel.valueMap = @[partiallyExecutedObjectDictionary];
                    callBack = YES;
                }
                
            }
        }
    }

    return  callBack;
}


-(void)parseAndAddIdsForDowNloadCriteriaFromResponse:(NSDictionary *)objectValueMap
                                        toDictionary:(NSMutableDictionary *)heapDictionary
                                       forObjectName:(NSString *)objectName
{
    NSMutableArray *sfIdArrary = [[NSMutableArray alloc] init];
    NSString *jsonString = [objectValueMap objectForKey:kSVMXRequestValue];
    NSData *jsonData = nil;
    if (jsonString.length > 0 && jsonString != nil && ![jsonString isKindOfClass:[NSNull class]]) {
        
        jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSArray *sfIdResponseArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
        
        if ([sfIdResponseArray isKindOfClass:[NSArray class] ] && [sfIdResponseArray count] > 0) {
            
            {
                for (NSDictionary *sfIdValueMap in sfIdResponseArray)
                {
                    NSString *sfId = [sfIdValueMap objectForKey:kId];
                    if ([StringUtil isStringEmpty:sfId]) {
                        continue;
                    }
                    sfId = [sfId stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                    sfId = [sfId stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    
                    [sfIdArrary addObject:sfId];
                }
               // [self insertDetailsIntoHeapTableWithObjectName:objectName andSfIdArray:sfIdArrary];
            }
        }
    }
}
- (BOOL)ParseDataForAdvancedDownLoadcriteriaForResponseData:(id)responseData
{
    BOOL callBack =  NO;
    NSDictionary *responseDict = (NSDictionary *)responseData;
    NSMutableDictionary *heapDictionary = [[NSMutableDictionary alloc] init];
    
       NSMutableDictionary *partiallyExecutedObjectDictionary = [[NSMutableDictionary alloc] init];
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
              callBack = [[objectValueMap objectForKey:kSVMXRequestValue] boolValue];
                
            }
            else  /* Objects' valueMap */
            {
                /* Parse valuemaps for all other objects */
                [self parseAndAddIdsForAdvanceDowNloadCriteriaFromResponse:objectValueMap toDictionary:heapDictionary forObjectName:objectName];
            }
        }
        /* insert into sync heap table */
    }
    return callBack;
}

-(void)parseAndAddIdsForAdvanceDowNloadCriteriaFromResponse:(NSDictionary *)objectValueMap
                                               toDictionary:(NSMutableDictionary *)heapDictionary
                                              forObjectName:(NSString *)objectName
{
    
    
    NSArray *sfIdResponseArray = [objectValueMap objectForKey:kSVMXRequestSVMXMap];
    if ([sfIdResponseArray isKindOfClass:[NSArray class]] && [sfIdResponseArray count] > 0)
    {
        for (NSDictionary *sfIdValueMap in sfIdResponseArray)
        {
            NSString *sfId = [sfIdValueMap objectForKey:kSVMXRequestValue];
            if ([StringUtil isStringEmpty:sfId]) {
                continue;
            }
            sfId = [sfId stringByReplacingOccurrencesOfString:@"\\" withString:@""];
            sfId = [sfId stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
                 }
    }

    
}

- (BOOL)parseAnaAddaIdsForGetPriceResponse:(NSDictionary *)rawResponseData andRequestMpdel:(RequestParamModel*)requestParamModel
{
    BOOL callBack = NO;
//    ResponseCallback * callBack =[[ResponseCallback alloc] init];
//    callBack.callBack = NO;
//    callBack.callBackData = [[RequestParamModel alloc] init];
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
                            callBack = [[svmxReturnMapObject objectForKey:kSVMXRequestValue] boolValue];
                            
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
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
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
            }
            //[self insertDetailsIntoHeapTableWithObjectName:objectName andSfIdArray:array];
                
            }
    }

    
    
}





@end
