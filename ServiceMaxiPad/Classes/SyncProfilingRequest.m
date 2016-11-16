//
//  SyncProfilingRequest.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 11/14/16.
//  Copyright © 2016 ServiceMax Inc. All rights reserved.
//

#import "SyncProfilingRequest.h"
#import "AppMetaData.h"

@implementation SyncProfilingRequest


-(NSString *)getUrlWithStringApppended:(NSString*)stringToAppend {
    return nil;
}

- (NSDictionary *)httpHeaderParameters {
    @synchronized([self class]){
        NSString *orgId = ([self.groupId length] == 18)?[self.groupId substringToIndex:15]:self.groupId;
        NSDictionary *headerParams = [NSDictionary dictionaryWithObjects:@[@"ServiceMaxNow", orgId, @"", @"application/json"] forKeys:@[@"From", @"clientId", @"clientName", @"Content-Type"]];
        return headerParams;
    }
}

-(NSDictionary *) httpPostBodyParameters {
    @synchronized([self class]){
        
        [[AppMetaData sharedInstance] loadApplicationMetaData];
        NSString *deviceName = [[AppMetaData sharedInstance]getCurrentDeviceVersion];
        
        NSDictionary *bodyParams = [NSDictionary dictionaryWithObjects:@[@"2016-11-14 13:47:00", self.userId, self.groupId, self.profileId, deviceName] forKeys:@[@"syncstartime", @"classicuserid", @"classicprofileid", @"svmxprofile", @"devicename"]];
        self.requestParameter.requestInformation = bodyParams;
        return bodyParams;
    }
}

@end
