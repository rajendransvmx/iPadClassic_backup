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
#import "ResolveConflictsHelper.h"
#import "SyncHeapService.h"
#import "CalenderHelper.h"
#import "SuccessiveSyncManager.h"

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
        parserObj.categoryType = self.categoryType;
        callBack = [parserObj parseResponseWithRequestParam:requestParamModel
                                               responseData:responseData];
        
        if (self.requestType == RequestTXFetch &&  !callBack.callBack ) {
            /* tx fetch is done*/
            [self updateSfIdForSVMXEvent];
        }
        
    }
    return callBack;
}

- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)count
{
    if(self.requestType == RequestSyncTimeLogs)
    {
        NSArray * finalArray  = [super getRequestParametersWithRequestCount:count];
        if(finalArray != nil)
        {
            return finalArray;
        }
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
        case RequestTypePurgeRecords:
        {
            RequestParamModel *model = [self getRequestParamModelForPurgeEventRecords];
            return @[model];
        }
        break;
        case RequestTXFetch:
        {
            OneCallDataSyncHelper *helper = [[OneCallDataSyncHelper alloc] init];
            [helper deleteIdsFromSyncHeapForResponseType:kGetDeleteDCOptimized];
            
            // delete conflict records from heap table..
            NSArray *conflictIds = [ResolveConflictsHelper fetchSfIdsFromConflictRecords];
            if (conflictIds > 0) {
                SyncHeapService *heapServiceObj = [[SyncHeapService alloc] init];
                [heapServiceObj deleteRecordsForSfIds:conflictIds forParallelSyncType:nil];
            }
            return [self getTxFetcRequestParamsForRequestCount:count];
        }
            break;
        case RequestTypeUserTrunk:
        {
            RequestParamModel *model = [[RequestParamModel alloc] init];
            return @[model];
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
    paramObj.requestInformation = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.categoryType] forKey:@"categoryType"];
    paramObj.valueMap = @[lastSyncTime];
    return @[paramObj];
}

- (RequestParamModel *)getRequestParamModelForPurgeEventRecords {

    RequestParamModel *model = [[RequestParamModel alloc] init];
    
    model.value = self.requestIdentifier;
    
    NSMutableArray *valueMapArray = [[NSMutableArray alloc] init];
 
    OneCallDataSyncHelper *helper = [[OneCallDataSyncHelper alloc] init];

    //check whether any what id is associated with another event, if yes, remove the what id from request parameters
    for (NSString *objectName in [[[SuccessiveSyncManager sharedSuccessiveSyncManager] whatIdsToDelete] allKeys]) {
        
        NSArray *valusArray = [[[SuccessiveSyncManager sharedSuccessiveSyncManager] whatIdsToDelete] objectForKey:objectName];
        
        NSMutableArray *originalValuesArray = [NSMutableArray arrayWithArray:valusArray];
        
        for (NSString *whatId in valusArray) {
            
            if ([helper checkIfWhatIdIsAssociatedWithAnyOtherEvent:whatId]) {
                
                [originalValuesArray removeObject:whatId];
                
                //remove child lines also if parent wo is removed
                if ([objectName isEqualToString:kWorkOrderTableName]) {
                    
                    NSArray *childLines = [helper getChildLineIdsForWO:whatId];
                    NSMutableArray *childValuesArray = [NSMutableArray arrayWithArray:[[[SuccessiveSyncManager sharedSuccessiveSyncManager] whatIdsToDelete] objectForKey:kWorkOrderDetailTableName]];
                    [childValuesArray removeObjectsInArray:childLines];
                    [[[SuccessiveSyncManager sharedSuccessiveSyncManager] whatIdsToDelete] setValue:childValuesArray forKey:kWorkOrderDetailTableName];
                }
            }
        }
        valusArray = [NSArray arrayWithArray:originalValuesArray];
        [[[SuccessiveSyncManager sharedSuccessiveSyncManager] whatIdsToDelete] setValue:valusArray forKey:objectName];
    }
    
    for (NSString *objectName in [[[SuccessiveSyncManager sharedSuccessiveSyncManager] whatIdsToDelete] allKeys]) {

        NSArray *valusArray = [[[SuccessiveSyncManager sharedSuccessiveSyncManager] whatIdsToDelete] objectForKey:objectName];

        NSMutableDictionary *valueMapDictToSend = [[NSMutableDictionary alloc] init];
        [valueMapDictToSend setObject:@"Object_Name" forKey:@"key"];
        [valueMapDictToSend setObject:objectName forKey:@"value"];
        [valueMapDictToSend setObject:valusArray forKey:@"values"];
        
        [valueMapArray addObject:valueMapDictToSend];
    }

    model.valueMap = valueMapArray;
    
    return model;
}

- (void)updateSfIdForSVMXEvent
{
    [CalenderHelper updateOriginalSfIdForSVMXEvent];
}

@end
