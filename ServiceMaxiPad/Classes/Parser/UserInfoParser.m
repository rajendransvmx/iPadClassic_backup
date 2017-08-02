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
            [[NSUserDefaults standardUserDefaults] setObject:orgAddress forKey:kOrgAddressKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    return nil;
}

@end
