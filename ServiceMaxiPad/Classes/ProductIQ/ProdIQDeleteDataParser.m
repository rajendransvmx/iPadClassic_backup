//
//  ProdIQDeleteDataParser.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 30/11/15.
//  Copyright © 2015 ServiceMax Inc. All rights reserved.
//

#import "ProdIQDeleteDataParser.h"
#import "StringUtil.h"
#import "PlistManager.h"
#import "OneCallDataSyncHelper.h"

@implementation ProdIQDeleteDataParser

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
            
            ResponseCallback *callbk = [[ResponseCallback alloc] init];
            RequestParamModel *newRequestModel = [[RequestParamModel alloc] init];
            callbk.callBackData = newRequestModel;
            callbk.callBack = NO;
            
            NSMutableArray *valueMapArray = [responseDictionary objectForKey:kSVMXSVMXMap];
            NSMutableDictionary *partiallyExObj = nil;
            NSMutableDictionary *objectNameAndIds = [NSMutableDictionary dictionary];
            
            for (NSDictionary *vMDictionary in valueMapArray) {
                NSString *key = [vMDictionary objectForKey:kSVMXKey];
                if ([StringUtil isStringEmpty:key]) {
                    
                }
                else if ([key isEqualToString:kPartiallyExecutedobj]) {
                    NSString *pExeObjectName = [vMDictionary objectForKey:kSVMXValue];
                    if (![StringUtil isStringEmpty:pExeObjectName]) {
                        NSArray *valueMap = [vMDictionary objectForKey:kSVMXSVMXMap];
                        if ([valueMap count] == 1) {
                            NSString *lastDeleteID = [[valueMap lastObject]objectForKey:kSVMXValue];
                            if (![StringUtil isStringEmpty:lastDeleteID]) {
                                partiallyExObj = [NSMutableDictionary dictionaryWithDictionary:vMDictionary];
                                [partiallyExObj setObject:@[lastDeleteID] forKey:kSVMXValues];
                                [partiallyExObj setObject:@[] forKey:kSVMXSVMXMap];
                                NSDictionary *lastSyncTime = [self getProdIQDataLastSyncTime];
                                newRequestModel.valueMap = @[partiallyExObj, lastSyncTime];
                                if ([[responseDictionary objectForKey:kSVMXValues] count] > 0) {
                                    newRequestModel.values = [responseDictionary objectForKey:kSVMXValues];
                                    callbk.callBack = YES;
                                }
                            }
                        }
                    }
                }
                else {
                    NSString *value = [vMDictionary objectForKey:kSVMXValue];
                    NSData *jsonData = [value dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *e = nil;;
                    NSArray *valueArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e]
                    ;
                    
                    NSMutableDictionary *idsDictionary = [NSMutableDictionary dictionary];
                    for (NSDictionary *valueIds in valueArray) {
                        NSString *idValue = [valueIds objectForKey:kId];
                        [idsDictionary setObject:idValue forKey:idValue];
                    }
                    [objectNameAndIds setObject:idsDictionary forKey:key];
                }
            }
            
            if ([objectNameAndIds count] > 0) {
                OneCallDataSyncHelper *syncHelper = [[OneCallDataSyncHelper alloc] init];
                [syncHelper deleteFromAllTable:objectNameAndIds];
            }
            
            return callbk;
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

@end

