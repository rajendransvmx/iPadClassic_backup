//
//  ValidateProfileParser.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 11/15/16.
//  Copyright © 2016 ServiceMax Inc. All rights reserved.
//

#import "ValidateProfileParser.h"
#import "PlistManager.h"

@implementation ValidateProfileParser

-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel responseData:(id)responseData {
    
    @autoreleasepool {
        if ([responseData isKindOfClass:[NSDictionary class]]) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

            NSArray *valueMaps = [responseData objectForKey:kSVMXRequestSVMXMap];
            if ([valueMaps count] > 0) {
                for(NSDictionary *dict in valueMaps) {
                    NSString *key = [dict objectForKey:kSVMXRequestKey];
                    NSString *value = [dict objectForKey:kSVMXRequestValue];
                    
                    if([key isEqualToString:kValidateProfileSFProfileId]) {
                        [userDefaults setValue:value forKey:kSalesForceProfileId];
                    }
                    if([key isEqualToString:kValidateProfileOrgName]) {
                        [userDefaults setValue:value forKey:kSalesForceOrgName];
                    }
                    if ([key isEqualToString:kValidateProfileOrgId]) {
                        [userDefaults setValue:value forKey:kSalesForceOrgId];
                    }
                    if ([key isEqualToString:kValidateProfileSyncProfiling]) {
                        [userDefaults setValue:value forKey:kSyncProfileEnabled];
                    }
                    if ([key isEqualToString:kValidateProfileGroupProfileName]) {
                        [userDefaults setValue:value forKey:kGroupProfileName];
                    }
                }
            }
            
            NSArray *values = [responseData objectForKey:kSVMXRequestValues];
            if([values count] == 1) {
                NSString *groupProfileId = [values firstObject];
                [userDefaults setObject:groupProfileId forKey:kGroupProfileId];
            }
            [userDefaults synchronize];
        }
    }
    
    return nil;
}

@end
