//
//  ADCResponseParser.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 26/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "ADCResponseParser.h"
#import "ResponseCallback.h"
#import "StringUtil.h"
#import "SyncRecordHeapModel.h"
#import "FactoryDAO.h"
#import "SyncHeapDAO.h"
#import "ResponseConstants.h"
#import "RequestConstants.h"
#import "PlistManager.h"
#import "RequestParamModel.h"
#import "OneCallDataSyncHelper.h" 

@implementation ADCResponseParser
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
            
            /* partiallyExecutedObjectValueMap : Stores valueMap of Partially executed object.
             key     : PARTIALLY_EXECUTED_OBJECT
             value   : Object Name
             values  : List of SFIds received in current response of the object
             */
            NSMutableDictionary *partiallyExecutedObjectDictionary = [[NSMutableDictionary alloc] init];
            
            /* *********** ResponseCallBack parameter usage ***********
             
             requestIdentifier  : holds ADC request Id
             callBackEventName  : holds the ADC event name
             callBack           : If true make a callback else response ends here
             
             callBackData       : Always has 2 objects
             1. Remaining objects if any else an empty array
             2. Partially executed object valueMap if any else an empty dictionary
             [ ===== Hence while calling back check if data is available in any one ===== ]
             
             */
            ResponseCallback *callbk = [[ResponseCallback alloc] init];
            callbk.callBack = NO;
            
            NSArray *objectNameValues = [responseDict objectForKey:kSVMXRequestValues];
            
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
                        [self deletedIdsFromResponse:objectValueMap];
                        //Need to delete records from respective tables.
                    }
                    else if([objectName isEqualToString:kADCCallBackKey]) /*  CallBack valueMap */
                    {
                        callbk.callBack = [[objectValueMap objectForKey:kSVMXRequestValue] boolValue];
                        
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
                NSArray *sfidsArray = nil;
                /* Only if there are entries inside partiallyExecutedObjectValueMap then fill in the data */
                if([partiallyExecutedObjectDictionary count])
                {
                    NSString *partiallyExecutedObjName = [partiallyExecutedObjectDictionary objectForKey:kSVMXRequestValue];
                    
                    if((![partiallyExecutedObjName isEqualToString:@""]) && (partiallyExecutedObjName != nil))
                    {
                        //IPAD-4743
                        sfidsArray = [heapDictionary allValues];
                        NSArray *objectIds = [sfidsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@" objectName == [c] %@", partiallyExecutedObjName]];
                        NSMutableArray *sfids = [[NSMutableArray alloc] init];
                        if ([objectIds count] > 0) {
                            SyncRecordHeapModel *model  = [objectIds lastObject];
                            [sfids addObject:model.sfId];
                        }
                        [partiallyExecutedObjectDictionary setObject:sfids forKey:kSVMXRequestValues];
                        
                        /*
                        id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSyncHeap];
                        
                        if ([daoService conformsToProtocol:@protocol(SyncHeapDAO)]) {
                            sfidsArray = [daoService getAllIdsFromHeapTableForObjectName:partiallyExecutedObjName
                                                                                forLimit:0 forParallelSyncType:nil];
                            NSMutableArray *sfids = [[NSMutableArray alloc] init];
                            for (SyncRecordHeapModel *model in sfidsArray) {
                                [sfids addObject:model.sfId];
                            }
                            
                            //Add sfids to partiallyExecutedObjectDictionary with values
                            [partiallyExecutedObjectDictionary setObject:sfids forKey:kSVMXRequestValues];
                        }
                         */
                    }
                }
                
                // First object  : Remaining Objects;
                // Second object : Partially Executed Object ValueMap;
                if (callbk.callBack) {
                    
                    RequestParamModel *callbackData = [[RequestParamModel alloc] init];
                    callbackData.values = objectNameValues;
                    callbackData.requestInformation = requestParamModel.requestInformation; //IPAD-4743
                    
                    //[NSArray arrayWithObjects:callBackValues, sfidsArray, nil];
                    
                    if ([partiallyExecutedObjectDictionary count] > 0) {
                        NSDictionary *adcOptimized = [NSDictionary dictionaryWithObjects:@[kADCOptimized, kTrue] forKeys:@[kSVMXKey, kSVMXValue]]; // IPAD-4698
                        CategoryType type = [[requestParamModel.requestInformation objectForKey:@"categoryType"] intValue];
                        if (type == CategoryTypeDataSync || type == CategoryTypeOneCallDataSync) { //IPAD-4743
                            callbackData.valueMap = [NSArray arrayWithObjects:[self getLastSyncTimeForRecords],partiallyExecutedObjectDictionary, adcOptimized, nil]; // IPAD-4698
                        }
                        else {
                            callbackData.valueMap = [NSArray arrayWithObjects:partiallyExecutedObjectDictionary, adcOptimized, nil]; // IPAD-4698
                        }
                    }
                    callbk.callBackData = callbackData;
                    
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
            
            // To avoid duplicate entries
            SyncRecordHeapModel * modelObj = [[SyncRecordHeapModel alloc] init];
            modelObj.sfId =sfId;
            modelObj.objectName = objectName;
            modelObj.syncType = @"ADC"; //TODO : Remove hard coding
            modelObj.syncFlag = NO;

            
            [heapDictionary setObject:modelObj forKey:sfId];
        }
    }
}
-(void)deletedIdsFromResponse:(NSDictionary *)objectValueMap
{
    
    NSMutableDictionary *objIdsToBeDeleted = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *deleteObjectMapIds = [[NSMutableDictionary alloc]init];
    NSArray *delValueMapArray = [objectValueMap objectForKey:kSVMXRequestSVMXMap];
    if ([delValueMapArray isKindOfClass:[NSArray class]] && [delValueMapArray count] > 0)
    {
        /* Parse valuemap array of DELETE key */
        for (NSDictionary *valueMapObj in delValueMapArray)
        {
            NSString *objName = [valueMapObj objectForKey:kSVMXRequestKey];
            NSArray *listOfIds = [valueMapObj objectForKey:kSVMXRequestValues];
            NSMutableDictionary * deletedIDsDict = nil;
            
            NSMutableString *deleteRecordsStr = [deleteObjectMapIds objectForKey:objName];
            if(deleteRecordsStr == nil)
            {
                deleteRecordsStr = [[NSMutableString alloc] init];
                [deleteObjectMapIds setObject:deleteRecordsStr forKey:objName];
            }
            
            for (NSString * eachId in listOfIds) {
                
                if(deletedIDsDict == nil){
                    deletedIDsDict = [[NSMutableDictionary alloc] init];
                }
                
                if([deleteRecordsStr length]  == 0){
                    [deleteRecordsStr appendFormat:@"'%@'",eachId];
                }
                else{
                    [deleteRecordsStr appendFormat:@",'%@'",eachId];
                }
                [deletedIDsDict setObject:eachId forKey:eachId];
            }
            
            if((objName != nil) && (![objName isEqualToString:@""]) && (deletedIDsDict != nil) && [deletedIDsDict count])
                [objIdsToBeDeleted setObject:deletedIDsDict forKey:objName];
        }
    }
    
    // TODO : Insert in to corresponding object table for deleting the records
    /* delete Ids From syncTrailer Table*/
    if([objIdsToBeDeleted count] >0)
    {
        OneCallDataSyncHelper *syncHelper = [[OneCallDataSyncHelper alloc] init];
        [syncHelper deleteFromAllTable:objIdsToBeDeleted];
    }
    
}
- (NSDictionary *)getLastSyncTimeForRecords {
    NSMutableDictionary *lastSyncTimeDict = [NSMutableDictionary dictionary];
    [lastSyncTimeDict setObject:kLastSyncTime forKey:kSVMXRequestKey];
    NSString *lastSyncTime = [PlistManager getOneCallSyncTime];
    if (lastSyncTime == nil) {
        lastSyncTime = @"";
    }
    [lastSyncTimeDict setObject:lastSyncTime forKey:kSVMXRequestValue];
    return lastSyncTimeDict;
}
@end
