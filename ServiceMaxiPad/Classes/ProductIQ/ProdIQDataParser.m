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

@implementation ProdIQDataParser


-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData {
    @synchronized([self class]){
        @autoreleasepool {
            
            if (![responseData isKindOfClass:[NSDictionary class]]) {
                return nil;
            }
            
            NSDictionary *responseDictionary = (NSDictionary *)responseData;
            NSLog(@"responseDictionary: %@", responseDictionary);
            
            NSMutableArray *callBackValueMapArray = [[NSMutableArray alloc] init];

            ResponseCallback *callbk = [[ResponseCallback alloc] init];
            callbk.callBack = NO;
            
            RequestParamModel *newRequestModel = [[RequestParamModel alloc] init];
            callbk.callBackData = newRequestModel;
            
            NSDictionary *levelDict, *callBackDict, *timeLogDict, *lastIndexDict;
            
            NSArray *valueMapArray = [responseDictionary objectForKey:kSVMXSVMXMap];
            
            for (NSDictionary *valueMapDict in valueMapArray) {
                NSString *key = [valueMapDict objectForKey:kSVMXKey];
                
                if ([StringUtil isStringEmpty:key]) {
                    
                }
                
                else if ([key isEqualToString:@"LEVEL"]) {
                    levelDict = valueMapDict;
                }
                else if ([key isEqualToString:kWorkOrderSite] || [key isEqualToString:kInstalledProductTableName]) {
                    NSArray *values = [valueMapDict objectForKey:kSVMXValues];
                    [self addEntriesInHeapTableForObject:key andValues:values];
                    
                }
                else if ([key isEqualToString:kSVMXCallBack]) {
                    callbk.callBack = [[valueMapDict objectForKey:kSVMXValue] boolValue];
                    callBackDict = valueMapDict;
                }
                else if ([key isEqualToString:kTimeLogId]) {
                    timeLogDict = valueMapDict;
                }
                else if ([key isEqualToString:@"CURRENT_LEVEL_LOCATION_ID"]) {
//                    currentLevelDict = valueMapDict;
                }
                else if ([key isEqualToString:@"NEXT_LEVEL_LOCATION_ID"]) {
//                    nextLevelDict = valueMapDict;
                }
                else if ([key isEqualToString:@"LAST_INDEX"]) {
                    lastIndexDict = valueMapDict;
                }
            }
            
            if (callbk.callBack) {
                [callBackValueMapArray addObjectsFromArray:@[levelDict, callBackDict, timeLogDict, lastIndexDict]];
                newRequestModel.valueMap = callBackValueMapArray;
                newRequestModel.values = @[];
//                return callbk;
            }
            else {
                if (lastIndexDict != nil && [[lastIndexDict objectForKey:kSVMXValue] integerValue] == 1) {
                    [callBackValueMapArray addObjectsFromArray:@[lastIndexDict, timeLogDict]];
                    callbk.callBack = YES;
                    newRequestModel.valueMap = callBackValueMapArray;
                    newRequestModel.values = @[];
//                    return callbk;
                }
            }
            return nil;
        }
    }
}

-(void)addEntriesInHeapTableForObject:(NSString *)objectName andValues:(NSArray *)values {
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


@end
