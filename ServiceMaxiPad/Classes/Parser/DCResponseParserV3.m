//
//  DCResponseParserV3.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 28/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "DCResponseParserV3.h"
#import "ResponseCallback.h"
#import "StringUtil.h"
#import "SyncRecordHeapModel.h"
#import "FactoryDAO.h"
#import "SyncHeapDAO.h"
#import "ResponseConstants.h"
#import "RequestConstants.h"
#import "GetPriceManager.h"
#import "SyncConstants.h"

@implementation DCResponseParserV3

-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData
{
    @synchronized([self class]){
        @autoreleasepool {
            
            if (![responseData isKindOfClass:[NSDictionary class]]) {
                return nil;
            }
            
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
            
            NSArray *valuesArray = [responseDict objectForKey:kSVMXRequestValues];
            
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
                    else if([objectName isEqualToString:kADCDeleteKey])  /* Delete valueMap */
                    {
                        //Need to delete records from respective tables.
                    }
                    else if([objectName isEqualToString:kADCCallBackKey]) /*  CallBack valueMap */
                    {
                        callbk.callBack = [[objectValueMap objectForKey:kSVMXRequestValue] boolValue];
                        
                        if(callbk.callBack)
                            [callBackValues addObjectsFromArray:[responseDict objectForKey:kSVMXRequestValues]];
                    }
                    else  /* Objects' valueMap */
                    {
                        /* Parse valuemaps for all other objects */
                        [self parseAndAddIdsFromResponse:objectValueMap toDictionary:heapDictionary forObjectName:objectName];
                    }
                }
                /* insert into sync heap table */
                if([[heapDictionary allKeys] count] > 0) {
                    [self createAndInsertHeapModel:[ NSMutableArray arrayWithArray:[heapDictionary allValues]]];
                }
                //NSArray *sfidsArray = nil;
                /* Only if there are entries inside partiallyExecutedObjectValueMap then fill in the data */
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
            return callbk;
        }
    }
    
    return nil;
}

- (void)createAndInsertHeapModel:(NSMutableArray *)valuesArray {
    
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSyncHeap];
    
    if ([daoService conformsToProtocol:@protocol(SyncHeapDAO)]) {
        [daoService saveRecordModels:valuesArray];
    }
    
}
-(void)parseAndAddIdsFromResponse:(NSDictionary *)objectValueMap toDictionary:(NSMutableDictionary *)heapDictionary forObjectName:(NSString *)objectName
{
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
                    
                    // To avoid duplicate entries
                    SyncRecordHeapModel * modelObj = [[SyncRecordHeapModel alloc] init];
                    modelObj.sfId =sfId;
                    modelObj.objectName = objectName;
                    modelObj.syncType = @"DC"; //TODO : Remove hard coding
                    modelObj.syncFlag = NO;
                    
                    /* get price call for new change */
                    if ([[GetPriceManager sharedInstance] isGetPriceInProgress])
                    {
                        modelObj.parallelSyncType = kParallelGetPriceSync;
                    }
                    
                    [heapDictionary setObject:modelObj forKey:sfId];
                }
            }
        }
    }
}
@end



