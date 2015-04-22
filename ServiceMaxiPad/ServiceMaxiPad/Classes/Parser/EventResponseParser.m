//
//  EventResponseParser.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 22/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "EventResponseParser.h"
#import "ResponseCallback.h"
#import "StringUtil.h"
#import "SyncRecordHeapModel.h"
#import "FactoryDAO.h"
#import "SyncHeapDAO.h"
#import "PlistManager.h"
@implementation EventResponseParser

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
            ResponseCallback * callBackObj = [[ResponseCallback alloc] init];
            BOOL callBack = NO;
            NSArray * objectsArray =[responseDict objectForKey:kSVMXRequestSVMXMap];
            if ([objectsArray isKindOfClass:[NSArray class]] && [objectsArray count] > 0) {
                
                for (int counter = 0; counter < [objectsArray count]; counter++) {
                    
                    NSDictionary *objectDict = [objectsArray objectAtIndex:counter];
                    NSString *objectName  =  [objectDict objectForKey:kSVMXRequestValue];
                    if ([StringUtil isStringEmpty:objectName]) {
                        continue;
                    }
                    
                    /*TODO : Check for LAST_SYNC key */
                    /** storing in userdefaults */
                    NSString *lastSyncKey  =  [objectDict objectForKey:kSVMXRequestKey];
                    if (![StringUtil isStringEmpty:lastSyncKey] && [lastSyncKey isEqualToString:kLastSync]) {
                        [self updateLastSyncTime:objectDict];
                        continue;
                    }
                    
                    NSArray *innerValueMap = [objectDict objectForKey:kSVMXRequestSVMXMap];
                    if ([innerValueMap count] > 0) {
                        
                        for (int jCounter = 0; jCounter < [innerValueMap count]; jCounter++) {
                            NSDictionary *innerMap = [innerValueMap objectAtIndex:jCounter];
                            NSString *jsonString = [innerMap objectForKey:kSVMXRequestValue];
                            NSData *jsonData = nil;
                            if (jsonString != nil && ![jsonString isKindOfClass:[NSNull class]]) {
                                
                                jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                                NSError *e = nil;
                                NSArray *finalIdsArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
                                
                                if ([finalIdsArray isKindOfClass:[NSArray class] ] && [finalIdsArray count] > 0) {
                                    
                                    [self addIdsFromJSONArray:finalIdsArray toDictionary:heapDictionary forObjectName:objectName];
                                }
                            }
                        }
                    }
                    
                }
            }
            //INSERT INTO HEAP TABLE
            if ([heapDictionary count] > 0) {
                [self createAndInsertHeapModel:[ NSMutableArray arrayWithArray:[heapDictionary allValues]]];
                
            }
            // Callback will be false always
            callBackObj.callBack = callBack;
            return callBackObj;
            
        }
    }
    
}
- (void)createAndInsertHeapModel:(NSMutableArray *)valuesArray {
    
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSyncHeap];
    
    if ([daoService conformsToProtocol:@protocol(SyncHeapDAO)]) {
        [daoService saveRecordModels:valuesArray];
    }
    
}

- (void)addIdsFromJSONArray:(NSArray *)finalIdsArray toDictionary:(NSMutableDictionary *)heapDictionary forObjectName:(NSString *)objectName {
    for (int idCounter = 0; idCounter < [finalIdsArray count]; idCounter++) {
        
        NSDictionary *objectDictionary = [finalIdsArray objectAtIndex:idCounter];
        NSString *recordId = [objectDictionary objectForKey:kId];
        if ([StringUtil isStringEmpty:recordId]) {
            continue;
        }
        SyncRecordHeapModel * modelObj = [[SyncRecordHeapModel alloc] init];
        modelObj.sfId =recordId;
        modelObj.objectName = objectName;
        modelObj.syncType = @"EventSync"; //TODO : Remove hard coding
        modelObj.syncFlag = NO;
        
        [heapDictionary setObject:modelObj forKey:recordId];
    }
}


- (void)updateLastSyncTime:(NSDictionary *)lastSyncDictionary{
    NSString *lastDate = [lastSyncDictionary objectForKey:kSVMXRequestValue];
    if (![StringUtil isStringEmpty:lastDate]) {
        [PlistManager storeOneCallSyncTime:lastDate];
    }
}

@end
