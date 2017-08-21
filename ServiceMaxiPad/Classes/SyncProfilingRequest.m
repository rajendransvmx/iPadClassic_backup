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
#import "SyncManager.h"

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
        NSString *syncProfileType = [[SyncManager sharedInstance] profileType];
        
        if ([syncProfileType isEqualToString:kSPTypeStart])
        {
            NSString *currentDate = [DateUtil getCurrentDateForSyncProfiling];
            NSString *salesforceProfileId = [userDefaults objectForKey:kSalesForceProfileId];
            [[AppMetaData sharedInstance] loadApplicationMetaData];
            NSString *deviceName = [[AppMetaData sharedInstance] getCurrentDeviceVersion];
            NSString *groupProfileId = [userDefaults objectForKey:kGroupProfileId];
            NSString *groupProfileName = [userDefaults objectForKey:kGroupProfileName];
            NSString *requestId = [userDefaults objectForKey:kSyncprofileReqId];
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
            NSString *currentDate = [userDefaults objectForKey:kSPSyncTime];
            NSString *requestId = [userDefaults objectForKey:kSyncprofilePreviousReqId];
            NSString *requestTimeOut = ([[SyncManager sharedInstance] isRequestTimedOut])?@"YES":@"NO";
            [params setObject:requestId forKey:kSyncProfileRequestIdKey]; // request id
            [params setObject:currentDate forKey:kSyncProfileEndTimeKey]; // end time
            [params setObject:requestTimeOut forKey:kSyncProfileRequestTimeOutKey]; // request timeout
            
            // IPH-2778
            NSNumber *dataSize = [NSNumber numberWithInteger:[[SyncManager sharedInstance] syncProfileDataSize]];
            if (dataSize) {
                [params setObject:dataSize forKey:kSyncProfileDataSizeKey];
            }
            
            NSString *status = [[NSUserDefaults standardUserDefaults] objectForKey:kSyncProfileFailType];
            [params setObject:status forKey:kSyncProfileStatusKey];
        }
        self.requestParameter.requestInformation = params;
        return params;
    }
}



@end
