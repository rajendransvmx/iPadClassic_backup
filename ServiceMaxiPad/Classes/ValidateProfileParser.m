//
//  ValidateProfileParser.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 11/15/16.
//  Copyright © 2016 ServiceMax Inc. All rights reserved.
//

#import "ValidateProfileParser.h"
#import "PlistManager.h"
#import "SyncManager.h"

@implementation ValidateProfileParser

-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel responseData:(id)responseData {
    
    @autoreleasepool {
        if ([responseData isKindOfClass:[NSDictionary class]]) {
            
            [self resetDataForSyncProfiling];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

            NSArray *valueMaps = [responseData objectForKey:kSVMXRequestSVMXMap];
            if ([valueMaps count] > 0) {
                for(NSDictionary *dict in valueMaps) {
                    NSString *key = [dict objectForKey:kSVMXRequestKey];
                    NSString *value = [dict objectForKey:kSVMXRequestValue];
                    
                    if([key isEqualToString:kValidateProfileSFProfileId]) {
                        [userDefaults setObject:value forKey:kSalesForceProfileId];
                    }
                    if([key isEqualToString:kValidateProfileOrgName]) {
                        [userDefaults setObject:value forKey:kSalesForceOrgName];
                    }
                    if ([key isEqualToString:kValidateProfileOrgId]) {
                        [userDefaults setObject:value forKey:kSalesForceOrgId];
                    }
                    if ([key isEqualToString:kValidateProfileSyncProfiling]) {
                        [userDefaults setObject:value forKey:kSyncProfileEnabled];
                        [SyncManager sharedInstance].isSyncProfileEnabled = [value boolValue];
                    }
                    if ([key isEqualToString:kValidateProfileGroupProfileName]) {
                        [userDefaults setObject:value forKey:kGroupProfileName];
                    }
                    
                    // SECSCAN-260
                    if ([key isEqualToString:kValidateProfileSSLPinning]) {
                        [userDefaults setObject:value forKey:kSSLPinningEnabled];
                    }
                    if ([key isEqualToString:kValidateProfileSyncProfileOrgType]) {
                        [userDefaults setObject:value forKey:kSyncProfileOrgType];
                    }
                    if ([key isEqualToString:kValidateProfileSyncProfileEndPointUrl]) {
                        [userDefaults setObject:value forKey:kSyncProfileEndPointUrl];
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

-(void)resetDataForSyncProfiling {
    [SyncManager sharedInstance].isSyncProfileEnabled = NO ;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kSalesForceProfileId];
    [userDefaults removeObjectForKey:kSalesForceOrgName];
    [userDefaults removeObjectForKey:kSalesForceOrgId];
    [userDefaults removeObjectForKey:kSyncProfileEnabled];
    [userDefaults removeObjectForKey:kGroupProfileName];
    [userDefaults removeObjectForKey:kGroupProfileId];
    [userDefaults removeObjectForKey:kGroupProfileName];
    
    // SECSCAN-260
    [userDefaults removeObjectForKey:kSSLPinningEnabled];
    [userDefaults removeObjectForKey:kSyncProfileEndPointUrl];
    [userDefaults removeObjectForKey:kSyncProfileOrgType];
    [userDefaults synchronize];
}

@end
