//
//  MobileDeviceTagParser.m
//  ServiceMaxMobile
//
//  Created by Pushpak on 19/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//
/**
 *  @file MobileDeviceTagParser.m
 *  @class MobileDeviceTagParser.m
 *
 *  @brief Specific parser class to handle MobileDeviceTags response.
 *
 *  @author Pushpak
 *
 *  @bug No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "MobileDeviceTagParser.h"
#import "MobileDeviceTagModel.h"
#import "StringUtil.h"
#import "FactoryDAO.h"
#import "MobileDeviceTagDAO.h"

@implementation MobileDeviceTagParser

-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData;
{
    @autoreleasepool {
        
        if ([responseData isKindOfClass:[NSDictionary class]])
        {
            NSArray *valueMaps = [responseData objectForKey:kSVMXRequestSVMXMap];
            if ([valueMaps count] > 0) {
                NSMutableArray *tagModelArray = [[NSMutableArray alloc]init];
                
                @autoreleasepool {
                    
                    for (NSDictionary *dictObj in valueMaps) {
                        [tagModelArray addObject:[self getTagModelFromDictionary:dictObj]];
                    }
                }
                id daoService = [FactoryDAO serviceByServiceType:ServiceTypeMobileDeviceTag];
                
                if ([daoService conformsToProtocol:@protocol(MobileDeviceTagDAO)]) {
                    BOOL resultStatus = [daoService saveRecordModels:tagModelArray];
                    if (resultStatus) {
                        SXLogDebug(@"Inserted mob-tags successfully");
                    }
                }
            }
        }
        
    }

    return nil;
}

#pragma mark - Internal Methods

- (MobileDeviceTagModel *)getTagModelFromDictionary:(NSDictionary *)pDict {
    
    MobileDeviceTagModel *modelObject = [[MobileDeviceTagModel alloc]init];
    NSString *settingId = [pDict objectForKey:kSVMXRequestKey];
    if ([StringUtil checkIfStringEmpty:settingId]) {
        settingId = @"";
    }
    NSString *settingValue = [pDict objectForKey:kSVMXRequestValue];
    if ([StringUtil checkIfStringEmpty:settingValue]) {
        settingValue = @"";
    }
    modelObject.tagId = settingId;
    modelObject.value = settingValue;
    return modelObject;
}


@end
