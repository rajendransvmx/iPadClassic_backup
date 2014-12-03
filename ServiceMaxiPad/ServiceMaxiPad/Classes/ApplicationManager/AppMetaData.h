//
//  AppMetaData.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 4/15/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Constant Declaration
 * Client Info dictionary - Key
 *
 */
extern  NSString const *kDeviceType;
extern  NSString const *kOSVersion;
extern  NSString const *kApplicationVersion;
extern  NSString const *kDevVersion;


@interface AppMetaData : NSObject


/**
 * @name   sharedInstance
 *
 * @author Vipindas Palli
 *
 * @brief  Shared instance of the Application Meta data
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Shared Object of application Meta data class.
 *
 */

+ (id)sharedInstance;

/**
 * @name   loadApplicationMetaData
 *
 * @author Vipindas Palli
 *
 * @brief  Load application meta data like Device OS version, Device name, OS type and current application, etc
 *
 * \par
 *  <Longer description starts here>
 *
 * @return void
 *
 */

- (void)loadApplicationMetaData;

/**
 * @name   getOSVersion
 *
 * @author Vipindas Palli
 *
 * @brief  Get iOS version of the device
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Device OS version
 *
 */

- (NSString *)getOSVersion;

/**
 * @name  getDeviceType
 *
 * @author Vipindas Palli
 *
 * @brief  Will return device type - like iPad 2, etc
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return Device type
 *
 */

- (NSString *)getDeviceType;

/**
 * @name  getDeviceType
 *
 * @author Vipindas Palli
 *
 * @brief  Will return device type - like iPad 2, etc
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return Device type
 *
 */

- (NSString *)getDeviceVersion;
- (NSString *)getApplicationVersion;

- (NSString *)getCurrentOSVersion;
- (NSString *)getCurrentDeviceType;
- (NSString *)getCurrentDeviceVersion;
- (NSString *)getCurrentApplicationVersion;

- (NSDictionary *)getApplicationMetaInfo;

@end
