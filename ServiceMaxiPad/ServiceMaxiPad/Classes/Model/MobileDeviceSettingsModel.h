//
//  BaseMobileDeviceSettings.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 22/05/14
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   MobileDeviceSettingsModel.h
 *  @class  MobileDeviceSettingsModel
 *
 *  @brief
 *
 *   This is a modle class which holds all the info.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/




@interface MobileDeviceSettingsModel : NSObject

@property(nonatomic) NSInteger localId;
@property(nonatomic, strong) NSString *settingId;
@property(nonatomic, strong) NSString *value;

- (id)init;

- (void)explainMe;

+ (NSDictionary *) getMappingDictionary;

+ (NSDictionary *)getMappingDictionaryForMobileDeviceConfig;

@end