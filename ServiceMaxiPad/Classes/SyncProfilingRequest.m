//
//  SyncProfilingRequest.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 11/14/16.
//  Copyright © 2016 ServiceMax Inc. All rights reserved.
//

#import "SyncProfilingRequest.h"
#import "AppMetaData.h"
#import "PlistManager.h"
#import "DateUtil.h"
#import "CustomerOrgInfo.h"

@implementation SyncProfilingRequest


-(NSString *)getUrlWithStringApppended:(NSString*)stringToAppend {
    return nil;
}

- (NSDictionary *)httpHeaderParameters {
    @synchronized([self class]){
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *headerParams = [NSMutableDictionary dictionary];
        [headerParams setObject:kSyncProfileAppName forKey:kSyncProfileFromKey]; // from
        [headerParams setObject:[userDefaults objectForKey:kSalesForceOrgId] forKey:kSyncProfileClientIdKey]; // org id
        [headerParams setObject:[userDefaults objectForKey:kSalesForceOrgName] forKey:kSyncProfileClientNameKey]; // org name
        [headerParams setObject:@"application/json" forKey:@"Content-Type"]; // content type
        return headerParams;
    }
}

-(NSDictionary *) httpPostBodyParameters {
    @synchronized([self class]){
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *syncProfileType = [userDefaults valueForKey:kSyncProfileType];
        
        // datetime read from user defaults which is saved at the time of sync end request when there's no network
        NSString *currentDate = [userDefaults valueForKey:kSPSyncTime];
        if (currentDate == nil)
        {
            currentDate = [DateUtil getCurrentDateForSyncProfiling];
        }
        else
        {
            [userDefaults setValue:nil forKey:kSPSyncTime];
            [userDefaults synchronize];
        }
        
        if ([syncProfileType isEqualToString:kSPTypeStart])
        {
            NSString *salesforceProfileId = [userDefaults valueForKey:kSalesForceProfileId];
            [[AppMetaData sharedInstance] loadApplicationMetaData];
            NSString *deviceName = [[AppMetaData sharedInstance] getCurrentDeviceVersion];
            NSString *groupProfileId = [userDefaults valueForKey:kGroupProfileId];
            NSString *groupProfileName = [userDefaults valueForKey:kGroupProfileName];
            NSString *requestId = [userDefaults valueForKey:kSyncprofileStartReqId];
            NSDictionary *profileDictionary = [NSDictionary
                                               dictionaryWithObjects:@[groupProfileId, groupProfileName]
                                               forKeys:@[kSyncProfileIdKey, kSyncProfileNameKey]];
            NSDictionary *userDictionary = [NSDictionary
                                            dictionaryWithObjects:@[self.userId, [[CustomerOrgInfo sharedInstance] userDisplayName]]
                                            forKeys:@[kSyncProfileIdKey, kSyncProfileNameKey]];

            
            [params setObject:requestId forKey:kSyncProfileRequestIdKey]; // request id
            [params setObject:currentDate forKey:kSyncProfileStartTimeKey]; // start time
            [params setObject:salesforceProfileId forKey:kSyncProfileSFProfileIdKey]; // salesforce profile id
            [params setObject:userDictionary forKey:kSyncProfileUserIdKey]; // user id
            [params setObject:profileDictionary forKey:kSyncProfileGroupProfileKey]; // group profile id
            [params setObject:deviceName forKey:kSyncProfileDeviceNameKey]; // device name
        }
        else if ([syncProfileType isEqualToString:kSPTypeEnd])
        {
            NSString *requestId = [userDefaults valueForKey:kSyncprofileEndReqId];
            NSString *requestTimeOut = [userDefaults valueForKey:kSPReqTimedOut];
            [params setObject:requestId forKey:kSyncProfileRequestIdKey]; // request id
            [params setObject:currentDate forKey:kSyncProfileEndTimeKey]; // end time
            [params setObject:requestTimeOut forKey:kSyncProfileRequestTimeOutKey]; // request timeout
        }
        self.requestParameter.requestInformation = params;
        return params;
    }
}



@end
