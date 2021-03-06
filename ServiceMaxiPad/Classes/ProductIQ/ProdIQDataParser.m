//
//  ProdIQDataParser.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 21/10/15.
//  Copyright © 2015 ServiceMax Inc. All rights reserved.
//

#import "ProdIQDataParser.h"
#import "StringUtil.h"
#import "SyncRecordHeapModel.h"
#import "FactoryDAO.h"
#import "SyncHeapDAO.h"
#import "SFObjectFieldDAO.h"
#import "PlistManager.h"

@implementation ProdIQDataParser


-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData {
    @synchronized([self class]){
        @autoreleasepool {
            
            if (![responseData isKindOfClass:[NSDictionary class]]) {
                return nil;
            }
            
            if (![[responseData objectForKey:@"success"] isKindOfClass:[NSNull class]] &&[[responseData objectForKey:@"success"] intValue] == 0) {
                return nil;
            }
            
            NSDictionary *responseDictionary = (NSDictionary *)responseData;
            NSLog(@"responseDictionary: %@", responseDictionary);
            
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
                        // don't call PIQ TxFetch during initial sync if object permission is disbaled..
                        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"kProdIQDataPermissionFailed"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [self updateProdIQLastSyncTime:lastSyncTimeDict];
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
                            [self addFirstIndexEntriesInHeapTableForObject:key andValues:values];
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
                            [self addSecondIndexEntriesToHeapTable:valueArray];
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
                
               NSDictionary *currentSyncTimeDict = [self getProdIQDataLastSyncTime];
                
                if (callbk.callBack) {
                    // make call back
                    NSArray *tempArray = nil;
                    if (self.categoryType == CategoryTypeProductIQData) {
                        tempArray = @[levelDict, callBackDict, lastIndexDict, currentSyncTimeDict];
                    }
                    else {
                        tempArray = @[levelDict, callBackDict, lastIndexDict];
                    }
                    [callBackValueMapArray addObjectsFromArray:tempArray];
                    newRequestModel.valueMap = callBackValueMapArray;
                    newRequestModel.values = @[];
                    return callbk;
                }
                else {
                    // transition phase..
                    if (siteIdsExist == NO  && [[lastIndexDict objectForKey:kSVMXValue] integerValue] == 1) {
                        siteIdsExist = YES; //  resetting - so this block won't get called again..
                        
                        NSArray *tempArray = nil;
                        if (self.categoryType == CategoryTypeProductIQData) {
                            tempArray = @[lastIndexDict, currentSyncTimeDict];
                        }
                        else {
                            tempArray = @[lastIndexDict];
                        }
                        
                        [callBackValueMapArray addObjectsFromArray:tempArray];
                        callbk.callBack = YES;
                        newRequestModel.valueMap = callBackValueMapArray;
                        newRequestModel.values = @[];
                        return callbk;
                    }
                    else if (ibIdsExist == NO) {
                        // stop - no call back - request ends here..
                        if (lastSyncTimeDict) {
                            [self updateProdIQLastSyncTime:lastSyncTimeDict];
                        }
                    }
                    else {
                        // ib call back..
                        
                        NSArray *tempArray = nil;
                        if (self.categoryType == CategoryTypeProductIQData) {
                            tempArray = @[levelDict, callBackDict, lastIndexDict, currentSyncTimeDict];
                        }
                        else {
                            tempArray = @[levelDict, callBackDict, lastIndexDict];
                        }
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

-(void)addFirstIndexEntriesInHeapTableForObject:(NSString *)objectName andValues:(NSArray *)values {
    NSMutableArray *heapArray = [[NSMutableArray alloc] init];
    for (NSString *sfID in values) {
        SyncRecordHeapModel * modelObj = [[SyncRecordHeapModel alloc] init];
        modelObj.sfId =sfID;
        modelObj.objectName = objectName;
        modelObj.syncType = @"ProductIQ";
        modelObj.syncFlag = NO;
        [heapArray addObject:modelObj];
    }
    
    if([heapArray count] > 0) {
        id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSyncHeap];
        if ([daoService conformsToProtocol:@protocol(SyncHeapDAO)]) {
            [daoService saveRecordModels:heapArray];
        }
    }
}

-(void)addSecondIndexEntriesToHeapTable:(NSArray *)valuesArray {
    
    NSArray *fieldsArray = @[kId, kProductField, kWorkOrderCompanyId, kWorkOrderSite, KSubLocationTableName, kTopLevelId];
    id <SFObjectFieldDAO> objectFieldService = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    NSMutableArray *heapArray = [NSMutableArray array];
    
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
                    SyncRecordHeapModel * modelObj = [[SyncRecordHeapModel alloc] init];
                    modelObj.sfId = [recordDict objectForKey:fieldName];
                    modelObj.objectName = objectName;
                    modelObj.syncType = @"ProductIQ";
                    modelObj.syncFlag = NO;
                    [heapArray addObject:modelObj];
                }
                
            }
        }
    }
    
    if ([heapArray count] > 0) {
        id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSyncHeap];
        if ([daoService conformsToProtocol:@protocol(SyncHeapDAO)]) {
            [daoService saveRecordModels:heapArray];
        }
    }
}


-(NSDictionary *)getProdIQDataLastSyncTime {
    NSMutableDictionary *syncTimeDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [syncTimeDict setObject:kProdIQLastSyncTime forKey:kSVMXRequestKey];
    NSString *lastSyncTime = [PlistManager getProdIQDataSyncTime];
    
    if (lastSyncTime == nil) {
        lastSyncTime = [PlistManager getOneCallSyncTime];
    }
    
    if (lastSyncTime == nil) {
        lastSyncTime = @"";
    }
    [syncTimeDict setObject:lastSyncTime forKey:kSVMXRequestValue];
    return syncTimeDict;
}


-(void)updateProdIQLastSyncTime:(NSDictionary *)syncTimeDict {
    [PlistManager storeProdIQDataSyncTime:[syncTimeDict objectForKey:kSVMXRequestValue]];
}

@end
