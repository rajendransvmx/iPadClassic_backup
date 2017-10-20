//
//  UserInfoParser.m
//  ServiceMaxiPad
//
//  Created by Padmashree on 8/2/17.
//  Copyright © 2017 ServiceMax Inc. All rights reserved.
//

#import "UserInfoParser.h"

@implementation UserInfoParser

-(ResponseCallback *)parseResponseWithRequestParam:(RequestParamModel *)requestParamModel responseData:(id)responseData
{
    
    @synchronized ([self class])
    {
        if (responseData && [responseData isKindOfClass:[NSDictionary class]])
        {
            NSString *orgAddress = [responseData objectForKey:kAddressField];
            if(orgAddress)
            {
                [[NSUserDefaults standardUserDefaults] setObject:orgAddress forKey:kOrgAddressKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            // Multi-server support
            NSString *svmxVersion = [responseData objectForKey:kSVMXVersion];
            if (svmxVersion) {
                [[NSUserDefaults standardUserDefaults] setObject:svmxVersion forKey:kServerVersionKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
    
    return nil;
}

@end
