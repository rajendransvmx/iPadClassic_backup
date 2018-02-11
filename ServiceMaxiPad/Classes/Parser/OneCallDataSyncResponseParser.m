//
//  OneCallDataSyncResponseParser.m
//  ServiceMaxiPhone
//
//  Created by Shravya shridhar on 3/17/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "OneCallDataSyncResponseParser.h"
#import "StringUtil.h"
#import "ResponseCallback.h"
#import "ModifiedRecordModel.h"
#import "SVMXSystemConstant.h"
#import "OneCallDataSyncHelper.h"
#import "SyncRecordHeapModel.h"
#import "PlistManager.h"
#import "IncrementalSyncRequestParamHelper.h"
#import "FactoryDAO.h"
#import "SyncErrorConflictDAO.h"
#import "SyncErrorConflictModel.h"
#import "SMInternalErrorUtility.h"
#import "TransactionObjectDAO.h"
#import "ModifiedRecordsDAO.h"
#import "DateUtil.h"
#import "ModifiedRecordsService.h"
#import "FlowNode.h"
#import "SuccessiveSyncManager.h"

typedef enum {
    OneCallSyncPutDelete = 1,
    OneCallSyncPutInsert = 2,
    OneCallSyncPutUpdate = 3,
    OneCallSyncLastSync  = 4,
    OneCallSyncGetDelete = 5,
    OneCallSyncGetDeleteDCOptmized = 6,
    OneCallSyncGetUpdate = 7,
    OneCallSyncGetUpdateDCOptmized = 8,
    OneCallSyncCallback = 9,
    OneCallSyncLastIndex = 10
}OneCallSyncResponseType;

@interface OneCallDataSyncResponseParser()

@property(nonatomic,strong) NSMutableDictionary *callBackContextDictionary;
@property(nonatomic,strong) OneCallDataSyncHelper *oneCallSyncHelper;
@property(nonatomic, strong) NSMutableArray *deletedIds;

- (NSError *)handleErrorIfAny:(NSArray *)valuemap;
- (void)updateErrorsInCallBack:(NSDictionary *)dataDictionary
                   andCallBack:(ResponseCallback * )callBack;
@end



@implementation OneCallDataSyncResponseParser



-(void)initialize {
   self.eventNameToIndex = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSNumber numberWithInteger:OneCallSyncPutDelete],kPutDelete,
                                 [NSNumber numberWithInteger:OneCallSyncPutInsert],kPutInsert,
                                 [NSNumber numberWithInteger:OneCallSyncPutUpdate],kPutUpdate,
                                 [NSNumber numberWithInteger:OneCallSyncLastSync],kLastSync,
                                 [NSNumber numberWithInteger:OneCallSyncGetDelete],kGetDelete,
                                 [NSNumber numberWithInteger:OneCallSyncGetDeleteDCOptmized],kGetDeleteDCOptimized,
                                 [NSNumber numberWithInteger:OneCallSyncGetUpdate],kGetUpdate,
                                 [NSNumber numberWithInteger:OneCallSyncGetUpdateDCOptmized],kGetUpdateDCOptimized,
                                 [NSNumber numberWithInteger:OneCallSyncCallback],kSVMXCallBack,
                                 [NSNumber numberWithInteger:OneCallSyncLastIndex],kLastIndex,
                                 nil];
        
        self.oneCallSyncHelper = [[OneCallDataSyncHelper alloc] init];
        self.deletedIds = [[NSMutableArray alloc]initWithCapacity:0];
}


-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)newResponseData { 
    
    if (![newResponseData isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    @synchronized([self class ]){
        
        @autoreleasepool {
            
           
            if (self.eventNameToIndex == nil) {
                [self initialize];
            }
            NSDictionary *responsedata = (NSDictionary *)newResponseData;
            
//            SBJsonWriter *writer = [[SBJsonWriter alloc] init];
//            NSString *jsonString = [writer stringWithObject:responsedata];
            
            
            ResponseCallback *callBack = [[ResponseCallback alloc] init];
            callBack.callBack = NO;
            self.callBackContextDictionary = [[NSMutableDictionary alloc] init];
            
            
            NSArray *valueMap = [responsedata objectForKey:kSVMXRequestSVMXMap];
            for (int counter = 0; counter < [valueMap count]; counter++) {
                
                NSDictionary *dataDictionary = [valueMap objectAtIndex:counter];
                NSString *valueKey = [dataDictionary objectForKey:kSVMXRequestKey];
                
                if ([StringUtil isStringEmpty:valueKey]) {
                    continue;
                }
                NSArray *innerValueMap =  [dataDictionary objectForKey:kSVMXRequestSVMXMap];
                NSInteger eventIndex = [[self.eventNameToIndex objectForKey:valueKey] intValue];
                if ((eventIndex == OneCallSyncPutDelete) || (eventIndex == OneCallSyncPutInsert) || (eventIndex == OneCallSyncPutUpdate)) {
                    [self updateErrorsInCallBack:dataDictionary andCallBack:callBack];
                }
                switch (eventIndex) {
                    case OneCallSyncPutDelete:
                        [self handlePutDeleteResponse:[dataDictionary objectForKey:kLastInternalResponse]];
                        break;
                    case OneCallSyncPutInsert:
                        [self handlePutInsertResponse:[dataDictionary objectForKey:kLastInternalResponse]];
                        break;
                    case OneCallSyncPutUpdate:
                        [self handlePutUpdateResponse:[dataDictionary objectForKey:kLastInternalResponse]];
                        break;
                    case OneCallSyncLastSync:
                        [self handleLastSyncTime:dataDictionary andResponseCallBack:callBack];
                        break;
                    case OneCallSyncGetDelete:
                        [self handleGetDeleteResponse:innerValueMap responseType:OneCallSyncGetDelete];
                        break;
                    case OneCallSyncGetDeleteDCOptmized:
                        [self handleGetDeleteResponse:innerValueMap responseType:OneCallSyncGetDeleteDCOptmized];
                        break;
                    case OneCallSyncGetUpdate:
                        [self handleGetUpdateResponse:innerValueMap responseType:OneCallSyncGetUpdate];
                        break;
                    case OneCallSyncGetUpdateDCOptmized:
                        [self handleGetUpdateResponse:innerValueMap responseType:OneCallSyncGetUpdateDCOptmized];
                        break;
                    case OneCallSyncCallback:
                        [self handleCallBackobject:dataDictionary andResponseCallBack:callBack];
                        break;
                    case OneCallSyncLastIndex:
                        // [self handleLastIndex:dataDictionary andResponseCallBack:callBack];
                        break;
                    default:
                        SXLogInfo(@"Event Name %@",valueKey);
                        break;
                }
                
            }
            
            if (callBack.errorInParsing != nil) {
                
                callBack.callBack = NO;
                return callBack;
            }
            else if (callBack.callBack) {
                
                /* Fill up the parameters based on the previous call */
                [self continueDataSyncWithCallBackContext:callBack];
            }
            if(!callBack.callBack)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DoGetPrice"
                                                                    object:self
                                                                  userInfo:nil];
                // Multi-server support
                NSString *serverVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kServerVersionKey];
                float sVersion = [serverVersion floatValue];
                
                // if server version is less than Win 17, then PurgeRecords for Events will not be handled.
                if(sVersion < 17.10) {

                 [[SuccessiveSyncManager sharedSuccessiveSyncManager] setWhatIdsToDelete:nil];
                }
                
            }
            return callBack;
        }
        
        return nil;
    }
}

- (void)continueDataSyncWithCallBackContext:(ResponseCallback *)callBack{
    @synchronized([self class]){
        
        NSDictionary *callBackContext = nil;
        NSDictionary *lastIndexDictionary = nil;
        NSString *partiallyExecutedObject = nil;
        NSArray *values = nil;
        NSString *callBackContextKey = nil;
        @autoreleasepool {
            /*Yet to be done */
            
            if ([self.callBackContextDictionary count] > 0) {
                NSDictionary *callBackDictionary = self.callBackContextDictionary;
                callBackContext = [callBackDictionary objectForKey:kCallBack];
                
                callBackContextKey = [callBackDictionary objectForKey:kCurrentContextKey];
                if (callBackContextKey != nil) {
                    lastIndexDictionary = [callBackDictionary objectForKey:callBackContextKey];
                    
                    if ([callBackContextKey isEqualToString:kGetUpdateDCOptimized]) {
                        partiallyExecutedObject = [callBackDictionary objectForKey:kPartiallyExecutedobjUpdate];
                        
                    }
                    
                    if ([callBackContextKey isEqualToString:kGetDeleteDCOptimized]) {
                        partiallyExecutedObject = [callBackDictionary objectForKey:kPartiallyExecutedobjDelete];
                        
                    }
                    
                }
            }
            
            if (partiallyExecutedObject != nil && callBackContextKey != nil ) {
                values = [self.oneCallSyncHelper getIdsFromSyncHeapTableForObjectName:partiallyExecutedObject andEventType:callBackContextKey];
            }
            IncrementalSyncRequestParamHelper *requestHelper =  [[IncrementalSyncRequestParamHelper alloc] initWithRequestIdentifier:self.clientRequestIdentifier];
           RequestParamModel *model =  [requestHelper createSyncParamters:lastIndexDictionary andContext:callBackContext];
            model.values = values;
            callBack.callBackData = model;
        }
    }
}

#pragma mark - Response handlers for Put delete/Put update etc
- (void)handleLastPutUpdateTime:(NSDictionary *)lastUpdateTimeStampDictionary
{
    NSString * syncTimeStamp = [lastUpdateTimeStampDictionary objectForKey:kSVMXRequestValue];
    if (![StringUtil isStringEmpty:syncTimeStamp]) {
        [PlistManager storePutUpdateTime:syncTimeStamp];
    }
}


- (void)prepareDeleteStringFor:(NSString *)objectName deleteObjectMapIds:(NSMutableDictionary *)deleteObjectMapIds valuemapArray:(NSArray *)tempvalueMapArray operationType:(NSString *)operationType {
    NSMutableArray *deletedRecordsArray = [deleteObjectMapIds objectForKey:objectName];
    if(deletedRecordsArray == nil)
    {
        deletedRecordsArray = [[NSMutableArray alloc] init];
        [deleteObjectMapIds setObject:deletedRecordsArray forKey:objectName];
    }
    
    for (NSDictionary * dict in tempvalueMapArray)
    {
        NSString * valueKey = [dict objectForKey:kSVMXRequestValue];
        
        NSString * keyValue = [dict objectForKey:kSVMXRequestKey];
        
        NSString * recordId = ([operationType isEqualToString:kModificationTypeInsert])?keyValue:valueKey;
        
        if (recordId != nil) {
            [deletedRecordsArray addObject:recordId];
        }
    }
}

- (void)parsePutResponse:(NSArray *)internalResponse  withOperationType:(NSString *)operationType{
    
    @autoreleasepool {
        if([internalResponse count]<=0)
        {
            return;
        }
        
        
        
        NSDictionary * responseDict = [internalResponse objectAtIndex:0];
        NSArray * valueMap = [responseDict objectForKey:kSVMXRequestSVMXMap];
        
        NSMutableDictionary * objectMapIds = [[NSMutableDictionary alloc] init];
        NSMutableDictionary * deleteObjectMapIds = [[NSMutableDictionary alloc] init];
        NSMutableDictionary * deleteConflictObjMapIds = [[NSMutableDictionary alloc] init];
        
        for(NSDictionary * eachValueMap in valueMap)
        {
            NSString * responseKey = [eachValueMap objectForKey:kSVMXRequestKey];
            responseKey = (![StringUtil isStringEmpty:responseKey])?responseKey:@"";
            NSArray * internalValueMapArray = [eachValueMap objectForKey:kSVMXRequestSVMXMap];
            
            
            if([responseKey isEqualToString:kObjectName] || [responseKey isEqualToString:kParentObject] || [responseKey isEqualToString:kChildObject] )
            {
                NSString * objectName = [eachValueMap objectForKey:kSVMXRequestValue];
                
                [self prepareDeleteStringFor:objectName deleteObjectMapIds:deleteObjectMapIds valuemapArray:internalValueMapArray operationType:operationType];
                
                for (NSDictionary * eachDict in internalValueMapArray ) {
                    
                    NSString * recordSfId = [eachDict objectForKey:kSVMXRequestValue];
                    NSString * recordlocalId = [eachDict objectForKey:kSVMXRequestKey];
                    
                    NSString * finalId =  ([operationType isEqualToString:kModificationTypeInsert])?recordlocalId:recordSfId;
                    
                    NSMutableDictionary * idsDict = [objectMapIds objectForKey:objectName];
                    if(idsDict == nil)
                    {
                        idsDict = [[NSMutableDictionary alloc] init];
                        [objectMapIds setObject:idsDict forKey:objectName];
                    }
                    [idsDict setObject:finalId forKey: recordSfId];
                    
                    if([operationType isEqualToString:kModificationTypeInsert])
                    {
                        [self.oneCallSyncHelper updateSfId:recordSfId withLocalId:finalId andObjectName:objectName];
                    }
                }
            }
            else if([responseKey isEqualToString:@"DELETED_IDS"])
            {
                [self handleDeletedIds:internalValueMapArray];
                
                
            }
            else if([responseKey isEqualToString:kConflict] || [responseKey isEqualToString:kError])
            {
                [self handleConflicts:internalValueMapArray withOperationType:operationType withErrorType:responseKey];
                for (NSDictionary * eachDict in internalValueMapArray )
                {
                    NSString * objectName = [eachDict objectForKey:kSVMXRequestKey];
                    
                    NSArray * tempvalueMapArray = [eachDict objectForKey:kSVMXRequestSVMXMap];
                    
                    [self prepareDeleteStringFor:objectName deleteObjectMapIds:deleteConflictObjMapIds valuemapArray:tempvalueMapArray operationType:operationType];
                }
                
            }
        }
        
        /* Insert records into syncHeap table*/
        if([operationType isEqualToString:kModificationTypeInsert] || [operationType isEqualToString:kModificationTypeUpdate])
        {
            if ([objectMapIds count] > 0) {
                /*Insert into data base */
                
                if([operationType isEqualToString:kModificationTypeInsert] ){
                    [self checkIfRecordsStillExist:objectMapIds];
                }
                [self.oneCallSyncHelper  insertIdsIntoSyncHeapTable:objectMapIds];
            }
        }
        
        
        /* delete Ids From syncTrailer Table*/
        if([deleteObjectMapIds count] >0)
        {
            [self.oneCallSyncHelper  deleteSyncRecordsFromSyncModificationTableWithIndex:deleteObjectMapIds
                                                                    withModificationType:operationType];
        }
        
        if ([deleteConflictObjMapIds count] > 0) {
            [self.oneCallSyncHelper  deleteSyncRecordsFromSyncModificationTableWithIndex:deleteConflictObjMapIds
                                                                    withModificationType:operationType];
            [self.oneCallSyncHelper deleteConflictRecordsFromSuccessiveSyncEntry:deleteConflictObjMapIds
                                                            withModificationType:operationType];
        }
        
        /* Insert conflict records into syncConflict table*/
        
        if([operationType isEqualToString:kModificationTypeDelete] )
        {
            for (NSString * objectName in [deleteObjectMapIds allKeys]) {
                NSArray * deleteIds = [deleteObjectMapIds objectForKey:objectName];
                [self.oneCallSyncHelper deleteRecordIds:deleteIds fromObject:objectName];
            }
        }
    }
    
}


- (void)handleConflicts:(NSArray *)internalValueMapArray  withOperationType:(NSString *)operationType withErrorType:(NSString *)errorType
{
    
    NSMutableArray * syncConflictsRecords = nil;
    
    for (NSDictionary * eachDict in internalValueMapArray ) {
        
        SyncErrorConflictModel *conflictRecord = [[SyncErrorConflictModel alloc] init];
        
        NSString * objectName = [eachDict objectForKey:kSVMXRequestKey];
        NSString * errorMsg = [eachDict objectForKey:kSVMXRequestValue];
        NSArray * tempvalueMapArray = [eachDict objectForKey:kSVMXRequestSVMXMap];
        for (NSDictionary * dict in tempvalueMapArray)
        {
            NSString * valueKey = [dict objectForKey:kSVMXRequestValue];
            NSString * keyValue = [dict objectForKey:kSVMXRequestKey];
            NSString * recordId = ([operationType isEqualToString:kModificationTypeInsert])?keyValue:valueKey;
            if([operationType isEqualToString:kModificationTypeInsert]){
                conflictRecord.localId = recordId;
            }
            else {
                conflictRecord.sfId = recordId;
            }
        }
        
        conflictRecord.objectName = objectName;
        conflictRecord.errorMessage = errorMsg;
        conflictRecord.errorType = errorType;
        conflictRecord.operationType = operationType;
        
        // If there are earlier changes in modified record fetch them add in conflict table
        ModifiedRecordsService *modifiedRecordService = [[ModifiedRecordsService alloc]init];
        NSString *existingModifiedFields = [modifiedRecordService fetchExistingModifiedFieldsJsonFromModifiedRecordForRecordId:conflictRecord.localId andSfId:conflictRecord.sfId];
        if (existingModifiedFields != nil) {
            conflictRecord.fieldsModified = existingModifiedFields;
        }
        
        if([self.deletedIds containsObject:conflictRecord.sfId]){
            continue;
        }
        
        
        if(syncConflictsRecords == nil){
            syncConflictsRecords = [[NSMutableArray alloc] init];
        }
        
        [syncConflictsRecords addObject:conflictRecord];
        SXLogDebug(@"================================");
        SXLogDebug(@"Conflict");
        SXLogInfo(@"objectName = %@",objectName);
        SXLogInfo(@"message = %@",errorMsg);
        SXLogInfo(@"errorType = %@",errorType);
        SXLogInfo(@"operationType = %@",operationType);
        SXLogInfo(@"================================");
    }
    
    if(syncConflictsRecords != nil)
    {
        id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSyncErrorConflict];
        
        if ([daoService conformsToProtocol:@protocol(SyncErrorConflictDAO)]) {
            BOOL resultStatus = [daoService saveRecordModels:syncConflictsRecords];
            if (resultStatus) {
                SXLogDebug(@"SyncErrorConflict models inserted successfully!");
            }
        }

    }
    
}

- (void)handlePutDeleteResponse:(NSArray *)internalResponse {
    
    [self parsePutResponse:internalResponse withOperationType:kModificationTypeDelete];
}
- (void)handlePutUpdateResponse:(NSArray *)internalResponse {
    [self parsePutResponse:internalResponse withOperationType:kModificationTypeUpdate];
}
- (void)handlePutInsertResponse:(NSArray *)internalResponse {
    [self parsePutResponse:internalResponse withOperationType:kModificationTypeInsert];
}

#pragma mark -End

#pragma mark - Get delete response handlers

- (void)handleGetDeleteResponse:(NSArray *)valueMap responseType:(OneCallSyncResponseType)responseType
{
    NSInteger valueMapCount = [valueMap count];
    
    NSMutableDictionary *objectIdsDictionary = [[NSMutableDictionary alloc] init];
    for (int counter = 0; counter < valueMapCount; counter++) {
        
        NSDictionary *objectDictionary = [valueMap objectAtIndex:counter];
        NSString *keyType = [objectDictionary objectForKey:kSVMXRequestKey];
        if ([StringUtil isStringEmpty:keyType]) {
            continue;
        }
        if ([keyType isEqualToString:kParentObject] || [keyType isEqualToString:kChildObject]) {
            [self fillUpIdsFrom:objectDictionary intoDictionary:objectIdsDictionary];
        }
        else if([keyType isEqualToString:kServicemaxEventObject])
        {
            [self fillUpIdsIncaseOfServicemaxEventFrom:objectDictionary intoDictionary:objectIdsDictionary];
        }
        else if([keyType isEqualToString:kLastIndex]){
            [self handleLastIndex:objectDictionary andResponseCallBack:self.callBack andContextName:kGetDeleteDCOptimized];
        }
        if ([keyType isEqualToString:kPartiallyExecutedobj]) {
            [self handlePartiallyExecutedobject:objectDictionary andResponseCallBack:self.callBack andEventType:kPartiallyExecutedobjDelete];
        }

    }
    
    if ([objectIdsDictionary count] > 0) {
        
        [self backUpDeletedIds:objectIdsDictionary];
        /* DELETE ids from sync heap table, data trailer table, respective tables etc*/
        [self.oneCallSyncHelper deleteFromAllTable:objectIdsDictionary];
        
        /*Insert the the ids to sync record table*/
        NSString *responseTypeStr = nil;
        switch (responseType) {
            case OneCallSyncGetDeleteDCOptmized:
                responseTypeStr = kGetDeleteDCOptimized;
                [self.oneCallSyncHelper insertDCRecordIdsintoSyncHeapTable:objectIdsDictionary andResponseType:responseTypeStr];
               
                break;
            default:
                break;
        }
    }
}

-(void)backUpDeletedIds:(NSMutableDictionary *)objectDictionary
{
    NSMutableArray *idsArray = [[NSMutableArray alloc] init];
    for (NSString *objectName in [objectDictionary allKeys]) {
        
        NSMutableDictionary *someDictionary = [objectDictionary objectForKey:objectName];
        NSArray *idsArrayNew  = [someDictionary allKeys ];
        [idsArray addObjectsFromArray:idsArrayNew];
    }
    
    [self.deletedIds addObjectsFromArray:idsArray];
}
#pragma mark - End
#pragma mark - Get Update Response Handlers


- (void)handleGetUpdateResponse:(NSArray *)valueMap responseType:(OneCallSyncResponseType)responseType {
    SXLogInfo(@"Number of objects updated: %d",[valueMap count]);
    NSMutableDictionary *idsDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *allEvenstDict = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *allservicemaxEvenstDict = [[NSMutableDictionary alloc]init];

    BOOL allEventsExist = NO;
    BOOL allServiceMaxEventsExists = NO;
    for (NSDictionary *eachObjectDict in valueMap) {
        NSString *key = [eachObjectDict valueForKey:kSVMXRequestKey];
        
        if ([key isEqualToString:kAllEvents]) {
            /*Handle event purging here*/
            allEventsExist = YES;
            [self fillUpIdsFrom:eachObjectDict intoDictionary:allEvenstDict];
        }
        else if([key isEqualToString:kParentObject] || [key isEqualToString:kChildObject])
        {
            [self fillUpIdsFrom:eachObjectDict intoDictionary:idsDict];
        }
        else if([key isEqualToString:kServicemaxEventObject])
        {
            [self fillUpIdsIncaseOfServicemaxEventFrom:eachObjectDict intoDictionary:idsDict];
        }
        else if([key isEqualToString:kLastIndex]){
            [self handleLastIndex:eachObjectDict andResponseCallBack:self.callBack andContextName:kGetUpdateDCOptimized];
        }
        else if ([key isEqualToString:kPartiallyExecutedobj]) {
            [self handlePartiallyExecutedobject:eachObjectDict andResponseCallBack:self.callBack andEventType:kPartiallyExecutedobjUpdate];
        }
         else if ([key isEqualToString:kLastOneCallSyncPutUpdateTime])
         {
             [self handleLastPutUpdateTime:eachObjectDict];
         }
         else if ([key isEqualToString:@"ALL_SVMXEVENTS"]){
            
             allServiceMaxEventsExists = YES;
             [self fillUpIdsFrom:eachObjectDict intoDictionary:allservicemaxEvenstDict];
             
         }
        
    }
    if ([idsDict count]>0) {
        
        NSString *responseTypeStr = nil;
        switch (responseType) {
            case OneCallSyncGetUpdate:
                responseTypeStr = kGetUpdate;
                break;
            case OneCallSyncGetUpdateDCOptmized:
                responseTypeStr = kGetUpdateDCOptimized;
                break;

            default:
                break;
        }
        /*Insert the the ids to sync record table*/
       [self.oneCallSyncHelper insertDCRecordIdsintoSyncHeapTable:idsDict andResponseType:responseTypeStr];
    }
    /*Delete events form Event, Modifiedrecords and Sync_Records_Heap table*/
    if (allEventsExist) {
        if ([allEvenstDict count]>0) {
            [self.oneCallSyncHelper purgeEventsFromServer:allEvenstDict];
        }
        else {
            [self.oneCallSyncHelper deleteAllEventsOfTheLoggedInUserFromObject:kEventObject];
        }

    }
    
    if (allServiceMaxEventsExists) {
        if ([allservicemaxEvenstDict count]>0) {
            [self.oneCallSyncHelper purgeEventsFromServer:allservicemaxEvenstDict];
        }
        else {
            [self.oneCallSyncHelper deleteAllEventsOfTheLoggedInUserFromObject:kServicemaxEventObject];
        }
    }
}

#pragma mark - Last sync time and call back objects response handlers
- (void)handleLastSyncTime:(NSDictionary *)lastDictionary andResponseCallBack:(ResponseCallback *)callBack {
    NSString *lastSyncValue = [lastDictionary objectForKey:kSVMXRequestValue];
    if (![StringUtil isStringEmpty:lastSyncValue]) {
        [PlistManager storeTempOneCallSyncTime:lastSyncValue];
    }
}

- (void)handleCallBackobject:(NSDictionary *)callbackDict
         andResponseCallBack:(ResponseCallback *)callBack {
    
    
    NSString *boolString = [callbackDict objectForKey:kSVMXRequestValue];
    
    if (![StringUtil    isStringEmpty:boolString] && [StringUtil isItTrue:boolString]) {
        callBack.callBack = YES;
    }
    else{
        return;
    }
    NSArray *callbackValueMap = [callbackDict objectForKey:kSVMXRequestSVMXMap];
    if ([callbackValueMap count] > 0) {
        
         NSDictionary *callBackDictionary = [callbackValueMap objectAtIndex:0];
        NSString *callBackKey = [callBackDictionary objectForKey:kSVMXRequestKey];
        if (![StringUtil isStringEmpty:callBackKey]) {
            
            NSMutableDictionary *callbackContext = self.callBackContextDictionary;
            [callbackContext setObject:callbackDict forKey:kCallBack];
            
            NSString *callBackValue = [callBackDictionary objectForKey:kSVMXRequestValue];
            
            if (![StringUtil isStringEmpty:callBackValue]) {
                [callbackContext setObject:callBackValue forKey:kCurrentContextKey];
            }
        }
    }
}

- (void)handleLastIndex:(NSDictionary *)dataDictionary
    andResponseCallBack:(ResponseCallback *)callBack
         andContextName:(NSString *)contextName{
    
    [self.callBackContextDictionary setObject:dataDictionary forKey:contextName];
    
//    if ([callBack.callBackData count] > 0) {
//        
//        NSMutableDictionary *callbackContext = [callBack.callBackData objectAtIndex:0];
//        [callbackContext setObject:dataDictionary forKey:contextName];
//        
//    }
}

- (void)handlePartiallyExecutedobject:(NSDictionary *)dataDictionary
                  andResponseCallBack:(ResponseCallback *)callBack andEventType:(NSString *)type{
    NSString *partialObject = [dataDictionary objectForKey:kSVMXRequestValue];
    
    if (![StringUtil isStringEmpty:partialObject]) {
        [self.callBackContextDictionary setObject:partialObject forKey:type];
    }
    
    //    NSString *partialObject = [dataDictionary objectForKey:kSVMXResponseValue];
    //
    //    if (![SMXiPhone_Utility isStringEmpty:partialObject]) {
    //        if ([callBack.callBackData count] > 0) {
    //
    //            NSMutableDictionary *callbackContext = [callBack.callBackData objectAtIndex:0];
    //            [callbackContext setObject:partialObject forKey:type];
    //
    //        }
    //    }
}


#pragma mark - End

#pragma mark - fill up ids

- (void)fillUpIdsFrom:(NSDictionary *)dataDictionary
       intoDictionary:(NSMutableDictionary *)objectNamesAndIds {
    
    NSString *objectName  =  [dataDictionary objectForKey:kSVMXRequestValue];
    if ([StringUtil isStringEmpty:objectName]) {
        return;
    }
   
    
    NSArray *innerValueMap = [dataDictionary objectForKey:kSVMXRequestSVMXMap];
    if ([innerValueMap count] > 0) {
        
        for (int jCounter = 0; jCounter < [innerValueMap count]; jCounter++) {
            NSDictionary *innerMap = [innerValueMap objectAtIndex:jCounter];
            NSString *jsonString = [innerMap objectForKey:kSVMXRequestValue];
            if (jsonString != nil) {
                
                NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                NSError *e = nil;;
                NSArray *finalIdsArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
                
               
                if ([finalIdsArray isKindOfClass:[NSArray class] ] && [finalIdsArray count] > 0) {
                   
                    NSMutableDictionary *idsDict =  [objectNamesAndIds objectForKey:objectName];
                    if (idsDict == nil) {
                        
                        idsDict = [[NSMutableDictionary alloc] init];
                        [objectNamesAndIds setObject:idsDict forKey:objectName];
                        
                    }

                    [self addIdsFromJSONArray:finalIdsArray  toDictionary:idsDict];
                }
                
            }
        }
    }
}

- (void)addIdsFromJSONArray:(NSArray *)finalIdsArray  toDictionary:(NSMutableDictionary *)toDict{
    for (int idCounter = 0; idCounter < [finalIdsArray count]; idCounter++) {
        
        NSDictionary *objectDictionary = [finalIdsArray objectAtIndex:idCounter];
        NSString *objectId = [objectDictionary objectForKey:kId];
        if ([StringUtil isStringEmpty:objectId]) {
            continue;
        }
        [toDict setObject:objectId forKey:objectId];
    }
}


#pragma mark -Handle error

- (void)updateErrorsInCallBack:(NSDictionary *)dataDictionary
                   andCallBack:(ResponseCallback * )callBack {
    NSArray *internalResponse = [dataDictionary objectForKey:kLastInternalResponse];
    if ([internalResponse isKindOfClass:[NSArray class]]) {
        NSError *error = [self handleErrorIfAny:internalResponse];
        if (error != nil) {
            callBack.errorInParsing = error;
            //Send the error to AWS
            if([internalResponse count] > 0){
                
                NSDictionary *someDictionary = [internalResponse objectAtIndex:0];
                NSArray *errors = [someDictionary objectForKey:@"errors"];
                if ([errors count ] > 0) {
                    [FlowNode reportErrorToAWS:nil withResponseObject:internalResponse withRequestObject:nil];
                }
            }
           //AWS error handling ends here
            
        }
    }
}
- (NSError *)handleErrorIfAny:(NSArray *)valuemap{
    if([valuemap count] > 0){
        
        NSDictionary *someDictionary = [valuemap objectAtIndex:0];
        NSArray *errors = [someDictionary objectForKey:@"errors"];
        if ([errors count ] > 0) {
           NSError *error =  [SMInternalErrorUtility checkForErrorInResponse:someDictionary withStatusCode:-999 andError:nil];
            return error;
        }
    }
    return nil;
}

- (void)handleDeletedIds:(NSArray *)valueMap {
    
    /* Delete allids*/
    for (NSDictionary *eachDict in valueMap) {
        NSString *objectName =  [eachDict objectForKey:kSVMXRequestKey];
         NSString *valueStr =  [eachDict objectForKey:kSVMXRequestValue];
        
        if ([valueStr isKindOfClass:[NSString class]]) {
            
            NSData *jsonData = [valueStr dataUsingEncoding:NSUTF8StringEncoding];
            NSError *e = nil;;
            NSArray *sfIdsList = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
            if ([sfIdsList count] > 0) {
                
               
                /* DELETE ids from sync heap table, data trailer table, respective tables etc*/
                
                [self.oneCallSyncHelper deleteRecordWithIds:sfIdsList fromObjectName:kModifiedRecords andCriteriaFieldName:kSyncRecordSFId];
                [self.oneCallSyncHelper deleteRecordWithIds:sfIdsList fromObjectName:@"Sync_Records_Heap" andCriteriaFieldName:@"sfId"];
                
                /* Delete from respective table , modified records table and sync heap table */
                [self.oneCallSyncHelper deleteRecordWithIds:sfIdsList fromObjectName:objectName andCriteriaFieldName:kId];
                /*Delete from Custom Action Params Table */
                [self.oneCallSyncHelper deleteRecordWithIds:sfIdsList fromObjectName:kCustomActionRequestParams andCriteriaFieldName:kSyncRecordSFId];

            }
        }
    }
}

- (void)checkIfRecordsStillExist:(NSMutableDictionary *)objectMapDictionary {
    for (NSString *objectName in objectMapDictionary) {
       
        NSMutableDictionary *allIdsDictionary = (NSMutableDictionary *)[objectMapDictionary objectForKey:objectName];
    
        NSArray *allIds = [allIdsDictionary allKeys];
        if ([allIds count] > 0) {
            
            NSDictionary *allLocalIdsWithSfid = [self getSfidVsLocalIdDictionaryForSFids:allIds andObjectName:objectName];
            for (NSString *eachSfid in allIds) {
             
               NSString *localId =  [allLocalIdsWithSfid objectForKey:eachSfid];
                if (localId.length < 30) {
                    [allIdsDictionary removeObjectForKey:eachSfid];
                    
                      id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
                    
                    /*ADD entry in modified record*/
                    ModifiedRecordModel *newModifiedRecord = [[ModifiedRecordModel alloc] init];
                    newModifiedRecord.recordLocalId = localId;
                    newModifiedRecord.sfId = eachSfid;
                    newModifiedRecord.objectName = objectName;
                    newModifiedRecord.recordType = kRecordTypeDetail;
                    newModifiedRecord.operation = kModificationTypeDelete;
                    newModifiedRecord.timeStamp = [DateUtil getDatabaseStringForDate:[NSDate date]];
                    [modifiedRecordService saveRecordModel:newModifiedRecord];
                }
            }
            
        }
    }
}

- (NSMutableDictionary*)getSfidVsLocalIdDictionaryForSFids:(NSArray*)listOfSfid
                                             andObjectName:(NSString*)objectName
{
    NSMutableDictionary *sfIdVsLocalIdDictionary = [[NSMutableDictionary alloc]init];
    DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:listOfSfid];
    id <TransactionObjectDAO> transactionObject = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    NSArray * sourceRecords = [transactionObject fetchDataForObject:objectName fields:@[kId,kLocalId] expression:@" 1 " criteria:@[criteria]];
    
    for ( TransactionObjectModel * objectModel in sourceRecords) {
        NSMutableDictionary * sourceDict = [objectModel getFieldValueMutableDictionary];
        NSString *sfId = ([sourceDict objectForKey:kId] == nil)?@"":[sourceDict objectForKey:kId];
        NSString *localId = ([sourceDict objectForKey:kLocalId] == nil)?@"":[sourceDict objectForKey:kLocalId];
        [sfIdVsLocalIdDictionary setValue:localId forKeyPath:sfId];
    }
    return sfIdVsLocalIdDictionary;
}


- (void)fillUpIdsIncaseOfServicemaxEventFrom:(NSDictionary *)dataDictionary
                              intoDictionary:(NSMutableDictionary *)objectNamesAndIds {
    
    NSString *objectName  =  [dataDictionary objectForKey:kSVMXRequestKey];
    if ([StringUtil isStringEmpty:objectName]) {
        return;
    }
    NSString *jsonString = [dataDictionary objectForKey:kSVMXRequestValue];
    if (jsonString != nil) {
        
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e = nil;;
        NSArray *finalIdsArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
        
        
        if ([finalIdsArray isKindOfClass:[NSArray class] ] && [finalIdsArray count] > 0) {
            
            NSMutableDictionary *idsDict =  [objectNamesAndIds objectForKey:objectName];
            if (idsDict == nil) {
                
                idsDict = [[NSMutableDictionary alloc] init];
                [objectNamesAndIds setObject:idsDict forKey:objectName];
                
            }
            
            [self addIdsFromJSONArray:finalIdsArray  toDictionary:idsDict];
        }
        
    }
}



@end
