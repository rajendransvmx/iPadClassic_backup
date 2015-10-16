//
//  ProdIQObjectDescribeParser.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 12/10/15.
//  Copyright © 2015 ServiceMax Inc. All rights reserved.
//

#import "ProdIQObjectDescribeParser.h"
#import "CommonServices.h"

@implementation ProdIQObjectDescribeParser


-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData {
    @synchronized([self class]){
        @autoreleasepool {
            NSDictionary *dictionary = (NSDictionary *)responseData;
            NSError *err = nil;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&err];
            if (jsonData != nil) {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                [self insertProdIQObjectDescribeToDB:jsonString forObject:requestParamModel.value];
            }
            return nil;
        }
    }
}

-(void)insertProdIQObjectDescribeToDB:(NSString *)dataString forObject:(NSString *)objectName {
    NSDictionary *recordDict = [NSDictionary dictionaryWithObjects:@[objectName, dataString] forKeys:@[@"ObjectName", @"DescribeResult"]];
    CommonServices *service = [[CommonServices alloc] init];
    [service saveRecordFromDictionary:recordDict forFields:[recordDict allKeys] inTable:@"ObjectDescribe"];
}


@end
