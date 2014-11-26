//
//  SFMSearchParser.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 12/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SFMSearchParser.h"
#import "TransactionObjectModel.h"
#import "StringUtil.h"
#import "CacheManager.h"
#import "CacheConstants.h"

@implementation SFMSearchParser

- (ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel responseData:(id)responseData {
    @synchronized([self class]){
        @autoreleasepool {
            
            NSDictionary *responseDict = (NSDictionary *)responseData;
            NSArray *objectsArray =[responseDict objectForKey:kSVMXRequestSVMXMap];
            
            NSMutableDictionary *responseDictionary = [[NSMutableDictionary alloc] init];
            
            for (NSDictionary *objectDict in objectsArray) {
                
                NSString *objectId = [objectDict valueForKey:kSVMXRequestKey]; // object ID
                NSString *recordId = [objectDict valueForKey:kSVMXRequestValue]; // record sfID
                NSArray *fieldsArray = [objectDict objectForKey:kSVMXRequestSVMXMap];
                
                NSMutableDictionary *fieldsDictionary = [NSMutableDictionary dictionary];
                [fieldsDictionary setObject:fieldsArray forKey:kSVMXRequestSVMXMap];
                
                if ([StringUtil isStringNotNULL:recordId]) {
                    [fieldsDictionary setValue:recordId forKey:kId];
                }
                
                // set all records belonging to same object Id in array..
                NSMutableArray *recordsArray = nil;
                if ([responseDictionary count] > 0) {
                    NSArray *existingRecords = [responseDictionary objectForKey:objectId];
                    if (existingRecords == nil || [existingRecords count] == 0) {
                        recordsArray = [NSMutableArray arrayWithObject:fieldsDictionary];
                    }
                    else {
                        recordsArray = [NSMutableArray arrayWithArray:existingRecords];
                        [recordsArray addObject:fieldsDictionary];
                    }
                }
                else {
                    recordsArray = [NSMutableArray arrayWithObject:fieldsDictionary];
                }
                [responseDictionary setObject:recordsArray forKey:objectId];
            }
            
            [self pushResponseDataToCache:responseDictionary];
        }
    }
    return nil;
}


-(void)pushResponseDataToCache:(NSDictionary *)aResponseDictionary {
    [[CacheManager sharedInstance] pushToCache:aResponseDictionary byKey:kSFMSearchCacheId];
}



@end
