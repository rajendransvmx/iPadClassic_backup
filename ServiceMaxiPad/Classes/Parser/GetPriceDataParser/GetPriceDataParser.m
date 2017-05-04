//
//  GetPriceDataParser.m
//  ServiceMaxMobile
//
//  Created by Anoop on 8/25/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "GetPriceDataParser.h"
#import "ResponseCallback.h"
#import "StringUtil.h"
#import "SyncRecordHeapModel.h"
#import "FactoryDAO.h"
#import "SyncHeapDAO.h"
#import "RequestParamModel.h"
#import "GetPriceManager.h"
#import "SyncConstants.h"
#import "PlistManager.h"
#import "OneCallRestIntialSyncServiceLayer.h"
static NSString *GetPriceDataZero = @"0";
static NSString *GetPriceDataOne = @"1";
static NSString *GetPriceDataTwo = @"2";

@implementation GetPriceDataParser


-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData
{
    if (![responseData isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self.rawResponseData = responseData;
    
    @synchronized([self class])
    {
        @autoreleasepool
        {
            // NSLog(@"GetPrice Response ********************* \n %@",responsedata);
            
            // objectNamesAndIds : Stores sfid as key and heap model as object
            self.heapModelDict = [NSMutableDictionary dictionary];
            
            // callBackValues : Stores remaining objects pending in the request. This array is sent in callBack values array.
            self.callBackValuesFromFirstAPIResponse = [NSMutableArray array];
            
            self.partiallyExecutedObjectValueMap = [NSMutableDictionary dictionary];
            
            self.warrantyHasValues = FALSE;
            
            self.lastID = nil;
            
            /* *********** ResponseCallBack parameter usage ***********
             requestIdentifier  : holds request Id
             callBackEventName  : holds the GetPrice event name
             callBack           : If true make a callback else response ends here
             
             callBackData       : Holds 3 values
             at index 0 : last_index valuemap from response
             at index 1 : call_back valuemap from response
             at index 2 : Depends upon which GetPriceRequestType API call
             for GetPriceDataType1 : Array of Ids (Work Order)
             for GetPriceDataType2 : Partially executed object valuemap having list of ids in values
             for GetPriceDataType3 : Partially executed object valuemap having list of ids in values
             for GetPriceDataType4 : Last_ID value map
             */
            
            ResponseCallback *callBack = [[ResponseCallback alloc] init];
            callBack.callBackData = [[RequestParamModel alloc] init];
            callBack.callBack = NO;
            
            NSArray *objectsArray = [responseData objectForKey:kSVMXSVMXMap];
            if ([objectsArray isKindOfClass:[NSArray class]] && [objectsArray count] > 0)
            {
                for (NSDictionary * svmxMapObject in objectsArray)
                {
                    NSString *key = [svmxMapObject objectForKey:kSVMXRequestKey];
                    if([key isEqualToString:kGetPriceDataPricingData])
                    {
                        self.objectNames = [NSMutableArray array];
                        NSArray *objnams = [svmxMapObject objectForKey:kSVMXRequestValues];
                        if([objnams count])
                            [self.objectNames addObjectsFromArray:objnams];
                        
                        
                        NSString *apiIndex = [svmxMapObject objectForKey:kSVMXValue];
                        // TODO : 010974 : Response is not proper; To be solved while configuring on server or in server side code
                        if(((NSNull *) apiIndex == [NSNull null]) || [apiIndex isKindOfClass:[NSNull class]] || apiIndex == NULL || apiIndex == nil)
                            return nil;
                        
                        NSDictionary *lastIndexValueMap = [self getLastIndexValueMap];
                        switch ([apiIndex intValue])
                        {
                            case 1:
                                SXLogDebug(@"Call One");
                                callBack.callBack = [self processFirstAndLastResponse:svmxMapObject];
                                if(callBack.callBack && !self.isWOCountZero) {
                                    callBack.callBackData.valueMap = [NSArray arrayWithObjects:lastIndexValueMap, [self getCallBackValueMap], nil];
                                    callBack.callBackData.values = self.callBackValuesFromFirstAPIResponse;
                                }
                                else
                                {
                                    callBack.callBack = NO;
                                }
                                break;
                            case 2:
                                SXLogDebug(@"Call Two");
                                callBack.callBack = [self processResponse:svmxMapObject];
                                if(callBack.callBack)
                                {
                                    NSDictionary *peo =[self getPartiallyExecutedObjectValueMap];
                                    if([[peo allKeys] count]) {
                                        callBack.callBackData.valueMap = [NSArray arrayWithObjects:lastIndexValueMap, [self getCallBackValueMap], peo, nil];
                                    }
                                    else {
                                        callBack.callBackData.valueMap = [NSArray arrayWithObjects:lastIndexValueMap, [self getCallBackValueMap], peo, nil];
                                    }
                                    callBack.callBackData.values = [NSArray arrayWithArray:self.objectNames];
                                }
                                break;
                            case 3:
                                callBack.callBack = [self processResponse:svmxMapObject];
                                if(callBack.callBack)
                                {
                                    NSDictionary *peo =[self getPartiallyExecutedObjectValueMap];
                                    OneCallRestIntialSyncServiceLayer *syncServiceLayer=[[OneCallRestIntialSyncServiceLayer alloc]init];
                                    
                                    NSMutableArray *valueMapArray=[[NSMutableArray alloc]initWithObjects:lastIndexValueMap, [self getCallBackValueMap], peo, nil];
                                    
                                    /*Defect fix 039546*/
                                    NSArray *valuesLabour = [syncServiceLayer getValuesArrayForLabour];
                                    NSArray *valuesIsoCurrency = [syncServiceLayer getValuesArrayForCurrencyISO];

                                    if ([valuesLabour count]) {
                                        NSDictionary *laborDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Labor",kSVMXRequestKey,valuesLabour,kSVMXRequestValues, nil];
                                        [valueMapArray addObject:laborDict];
                                    }
                                    if ([valuesIsoCurrency count]) {
                                        NSDictionary *currencyDict = [NSDictionary dictionaryWithObjectsAndKeys:@"CurrencyISO",kSVMXRequestKey,valuesIsoCurrency,kSVMXRequestValues, nil];
                                        [valueMapArray addObject:currencyDict];
                                    }
                                    /*End of Defect fix 039546*/

                                    callBack.callBackData.valueMap = [NSArray arrayWithArray:valueMapArray];


                                    callBack.callBackData.values = [NSArray arrayWithArray:self.objectNames];
                                }
                                SXLogDebug(@"Call Three");
                                break;
                            case 4:
                                callBack.callBack = [self processFirstAndLastResponse:svmxMapObject];
                                
                                if(callBack.callBack && (![self.lastID isEqualToString:@""]) && (self.lastID != nil) && self.warrantyHasValues)
                                {
                                    callBack.callBackData.valueMap = [NSArray arrayWithObjects:lastIndexValueMap, [self getCallBackValueMap], [self getLastIDValueMap], nil];
                                    callBack.callBackData.values = [NSArray arrayWithArray:self.objectNames];
                                }
                                else
                                {
                                    callBack.callBack = NO;
                                }
                                //storing get price lase call,
                                [self gettingLastSyncTimeFromGetPrice:svmxMapObject];
                                SXLogDebug(@"Call Four");
                                break;
                            default:
                                break;
                        } // END : Switch
                        
                    } // END : if key = "PRICING_DATA"
                    
                } // END : Loop objectsArray
                
            } // END : if objectsArray
            
            return callBack;
        }
        
    } // END : synthesize
    
    return nil;
}

#pragma mark - Helper Methods

- (NSDictionary*)getCallBackValueMap
{
    NSDictionary *svmxReturnMapObject = [NSDictionary dictionary];
    NSArray *objectsArray = [self.rawResponseData objectForKey:kSVMXSVMXMap];
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

- (NSDictionary*)getLastIDValueMap
{
    NSDictionary *svmxReturnMapObject = [NSDictionary dictionary];
    NSArray *objectsArray = [self.rawResponseData objectForKey:kSVMXSVMXMap];
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


- (NSDictionary*)getLastIndexValueMap
{
    NSDictionary *svmxReturnMapObject = [NSDictionary dictionary];
    if(self.lastIndex == nil)
    {
        NSArray *objectsArray = [self.rawResponseData objectForKey:kSVMXSVMXMap];
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
                           [self setLastIndexAndCurrentRequestType:svmxReturnMapObject];
                            break;
                        }
                    }
                    
                }
            }
        }
    }
    return svmxReturnMapObject;
}

- (NSDictionary*)getPartiallyExecutedObjectValueMap
{
    return self.partiallyExecutedObjectValueMap;
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
            [self setLastIndexAndCurrentRequestType:svmxMapObject];
        }
        else if([key isEqualToString:kGetPriceDataLastId])
        {
            self.lastID = [svmxMapObject objectForKey:kSVMXValue];
        }
        else if([key isEqualToString:kWorkOrderTableName])
        {
            NSString *jsonRecord = [svmxMapObject objectForKey:kSVMXValue];
            NSData *jsonData = [jsonRecord dataUsingEncoding:NSUTF8StringEncoding];
            
            if ([jsonData length] && ![jsonRecord isKindOfClass:[NSNull class]]) {
                
                NSError *e;
                NSArray * json_array = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
                if(json_array && [json_array count])
                {
                   [self createHeapModelWithIdKey:json_array forObjectName:key toDictionary:self.heapModelDict];
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
            NSString *jsonRecord = [svmxMapObject objectForKey:kSVMXValue];
            NSData *jsonData = [jsonRecord dataUsingEncoding:NSUTF8StringEncoding];
            
            if([jsonData length] && ![jsonRecord isKindOfClass:[NSNull class]])
            {
                NSError *e;
                NSArray * json_array = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
                
                if(json_array && [json_array count])
                {
                    [self createHeapModelWithIdKey:json_array forObjectName:key toDictionary:self.heapModelDict];
                    
                    if([self.heapModelDict count])
                    {
                        // For fourth API call
                        if([key isEqualToString:kGetPriceWarrantyObjectName])
                            self.warrantyHasValues = TRUE;
                        
                    } // END : if([dataArray count])
                    
                } // END : if json_array
                
            } // END : if jsonRecord
            
        } // END : else
        
    } // END : valueMap loop
    
    if([[self.heapModelDict allKeys] count])
    {
        [self createAndInsertHeapModel:[ NSMutableArray arrayWithArray:[self.heapModelDict allValues]]];
    }
    
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
                [self setLastIndexAndCurrentRequestType:objectValueMap];
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
                
                NSMutableDictionary *valueDict = [[NSMutableDictionary alloc] init];
                NSArray *sfIdResponseArray = [objectValueMap objectForKey:kSVMXSVMXMap];
                
                if ([sfIdResponseArray isKindOfClass:[NSArray class]] && [sfIdResponseArray count] > 0)
                {
                    for (NSDictionary *sfIdValueMap in sfIdResponseArray)
                    {
                        NSString *jsonString = [sfIdValueMap objectForKey:kSVMXValue];
                        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            
                        if ([jsonData length] && ![jsonString isKindOfClass:[NSNull class]]) {
                            
                            NSError *e;
                            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
                            NSString *sfId = [jsonDict objectForKey:@"Id"];
                            sfId = [sfId stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                            sfId = [sfId stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                            
                            // To avoid duplicate entries
                            [valueDict setObject:sfId forKey:sfId];
                        }
                    }
                }
                
                /* Adding the List of Ids for an Object */
                if([[valueDict allKeys] count])
                {
                    [objectNameDict setObject:valueDict forKey:objectName];
                    [self createHeapModelWithIdKey:[valueDict allKeys] forObjectName:objectName toDictionary:self.heapModelDict];
                    
                    // For fourth API call
                    if([objectName isEqualToString:kGetPriceWarrantyObjectName])
                        self.warrantyHasValues = TRUE;
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
    
    if([[self.heapModelDict allKeys] count])
    {
        [self createAndInsertHeapModel:[NSMutableArray arrayWithArray:[self.heapModelDict allValues]]];
    }
    
    return callBack;
}

- (void) setLastIndexAndCurrentRequestType:(NSDictionary*)mappingDict
{
    self.lastIndex = [mappingDict objectForKey:kSVMXValue];
    
    if([self.lastIndex isEqualToString:GetPriceDataZero])
        self.requestType = RequestGetPriceDataTypeZero;
    else if([self.lastIndex isEqualToString:GetPriceDataOne])
        self.requestType = RequestGetPriceDataTypeOne;
    else if([self.lastIndex isEqualToString:GetPriceDataTwo])
        self.requestType = RequestGetPriceDataTypeTwo;
    else
        self.requestType = RequestGetPriceDataTypeThree;

}

- (RequestType)getCurrentRequestType
{
    return self.requestType;
}

- (void)createAndInsertHeapModel:(NSMutableArray *)valuesArray
{
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSyncHeap];
    
    if ([daoService conformsToProtocol:@protocol(SyncHeapDAO)]) {
        [daoService saveRecordModels:valuesArray];
    }
}

- (void)createHeapModelWithIdKey:(NSArray *)idsArray forObjectName:(NSString *)objectName toDictionary:(NSMutableDictionary *)heapDictionary {
    
    for (int idCounter = 0; idCounter < [idsArray count]; idCounter++) {
        
        NSString *recordId = [idsArray objectAtIndex:idCounter];
        if ([StringUtil isStringEmpty:recordId]) {
            continue;
        }
        SyncRecordHeapModel * modelObj = [[SyncRecordHeapModel alloc] init];
        modelObj.sfId =recordId;
        modelObj.objectName = objectName;
        modelObj.syncType = @"DataSync";
        modelObj.syncFlag = NO;
        if ([[GetPriceManager sharedInstance] isGetPriceInProgress])
        {
            modelObj.parallelSyncType = kParallelGetPriceSync;
        }
        
        // To avoid duplicates
        [heapDictionary setObject:modelObj forKey:recordId];
    }
}
//taking time log from responce, and updating for get price...
-(void)gettingLastSyncTimeFromGetPrice:(NSDictionary *)inputMapObject
{
    NSArray *valueMapArray = [inputMapObject objectForKey:kSVMXSVMXMap];
    for(NSDictionary *svmxMapObject in valueMapArray)
    {
        NSString *key = [svmxMapObject objectForKey:kSVMXRequestKey];
        if ([key isEqualToString:kGetPriceLastSyncTime]) {
            [PlistManager storeGetPriceSyncTime:[svmxMapObject objectForKey:kSVMXRequestValue]];
        }
    }
}

@end
