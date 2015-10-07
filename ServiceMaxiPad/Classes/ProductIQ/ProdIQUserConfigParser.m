//
//  ProdIQUserConfigParser.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 29/09/15.
//  Copyright © 2015 ServiceMax Inc. All rights reserved.
//

#import "ProdIQUserConfigParser.h"
#import "CommonServices.h"

@implementation ProdIQUserConfigParser

-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData {
    @synchronized([self class]){
        @autoreleasepool {
            NSDictionary *dictionary = (NSDictionary *)responseData;
            NSError *err = nil;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&err];
            if (jsonData != nil) {
               NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//                NSLog(@"jsonString: %@", jsonString);
                [self insertProdIQUserConfigToDB:jsonString];
            }
            return nil;
        }
    }
}

-(void)insertProdIQUserConfigToDB:(NSString *)configString {
    NSDictionary *recordDict = [NSDictionary dictionaryWithObjects:@[@"user", @"", configString] forKeys:@[@"Type", @"Key", @"Value"]];
    CommonServices *service = [[CommonServices alloc] init];
    [service saveRecordFromDictionary:recordDict forFields:[recordDict allKeys] inTable:@"Configuration"];
}

@end
