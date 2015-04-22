//
//  UserTrunkDataParser.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 13/01/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "UserTrunkDataParser.h"
#import "StringUtil.h"
#import "PlistManager.h"

@implementation UserTrunkDataParser

- (ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel responseData:(id)responseData {
    @synchronized([self class]){
        @autoreleasepool {
            
            if ([responseData isKindOfClass:[NSDictionary class]]) {
                
                [PlistManager removeUserTechnicianLocation];
                
                NSDictionary *dict = (NSDictionary *)responseData;
                
                NSArray *valueMap = [dict objectForKey:@"valueMap"];
                
                for (NSDictionary *valueDict in valueMap) {
                    
                    NSString *key = [valueDict objectForKey:@"key"];
                    
                    if ([key isEqualToString:kWorkOrderSite]) {
                
                        NSString *jsonValue = [valueDict objectForKey:@"value"];
                        
                        if ((![jsonValue isKindOfClass:[NSNull class]]) && (![StringUtil isStringEmpty:jsonValue])) {
                            
                            NSError *jsonError = nil;
                            
                            NSData *objectData = [jsonValue dataUsingEncoding:NSUTF8StringEncoding];
                            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:objectData
                                                                                 options:NSJSONReadingMutableContainers
                                                                                   error:&jsonError];
                            if ([jsonArray count] > 0) {
                                NSDictionary *locationDict = [jsonArray objectAtIndex:0];
                                NSString *technicianId = [locationDict objectForKey:kId];
                                if (![StringUtil isStringEmpty:technicianId]) {
                                    [PlistManager storeTechnicianLocationId:technicianId];
                                }
                                NSString *name = [locationDict objectForKey:@"Name"];
                                if (![StringUtil isStringEmpty:name]) {
                                    [PlistManager storeTechnicianLocation:name];
                                }
                            }
                            
                        }
                    }
                }
            }
        }
    }
    return nil;
}



@end
