//
//  SFMobileDevSettingDAO.h
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 20/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
#import "MobileDeviceSettingsModel.h"

@protocol MobileDeviceSettingDAO <CommonServiceDAO>

- (MobileDeviceSettingsModel *)fetchDataForSettingId:(NSString *)settingId;

/**
 * @name   configurationSyncFrequency
 *
 * @author Vipindas Palli
 *
 * @brief  Get scheduled Configuration sync frequency
 *
 * \par
 *  <Longer description starts here>
 *
 * @return NSInteger value
 *
 */

- (NSInteger)configurationSyncFrequency;

/**
 * @name   dataSyncFrequency
 *
 * @author Vipindas Palli
 *
 * @brief  Get scheduled data sync frequency
 *
 * \par
 *  <Longer description starts here>
 *
 * @return NSInteger value
 *
 */
- (NSInteger)dataSyncFrequency;


@end