//
//  SFMOnlineLookUpParser.m
//  ServiceMaxiPad
//
//  Created by Admin on 11/09/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "SFMOnlineLookUpParser.h"
#import "TransactionObjectModel.h"
#import "CacheManager.h"
#import "CacheConstants.h"

@implementation SFMOnlineLookUpParser

- (ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel responseData:(id)responseData {
    
    if (![responseData isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    @synchronized([self class]){
        @autoreleasepool {
            
            NSDictionary *responseDictionary = (NSDictionary *)responseData;
//            NSArray *objectsArray =[responseDict objectForKey:kSVMXRequestSVMXMap];
//            
//
//            NSMutableArray *onlineDataArray = [[NSMutableArray alloc] initWithCapacity:0];
//            
//            //TODO: remove unwanted code from this method once we get the actual response from server.
//            NSString *jsonStr = @"{\"records\":[{\"attributes\":{\"type\":\"Account\"},\"Name\":\"Santosh Nadagowda\"},{\"attributes\":{\"type\":\"Account\"},\"Name\":\"San Francisco\"},{\"attributes\":{\"type\":\"Account\"},\"Name\":\"Sangam\"}]}";
//            
//            NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
//            
//            
//            responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

            NSMutableArray *onlineDataArray = [[NSMutableArray alloc] initWithCapacity:0];

            NSArray *records = [responseDictionary objectForKey:@"records"];
            for (NSDictionary *dictionary in records) {
                TransactionObjectModel * model = [[TransactionObjectModel alloc] init];
                [model mergeFieldValueDictionaryForFields:dictionary];
                if (model != nil) {
                    [onlineDataArray addObject:model];
                }
            }
            [self pushResponseDataToCache:onlineDataArray];
        }
    }
    return nil;
}


-(void)pushResponseDataToCache:(NSArray *)onlineDataArray {
    [[CacheManager sharedInstance] pushToCache:onlineDataArray byKey:kSFMOnlineLookUpCacheData];
}

@end
