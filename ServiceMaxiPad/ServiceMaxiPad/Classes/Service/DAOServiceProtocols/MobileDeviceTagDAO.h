//
//  MobileDeviceTagDAO.h
//  ServiceMaxMobile
//
//  Created by Pushpak on 19/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//
/**
 *  @file MobileDeviceTagDAO.h
 *  @class MobileDeviceTagDAO.h
 *
 *  @brief Specific DAO protocol to handle MobileDeviceTags table.
 *
 *  @author Pushpak
 *
 *  @bug No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>
#import "MobileDeviceTagModel.h"
#import "CommonServiceDAO.h"

@protocol MobileDeviceTagDAO <CommonServiceDAO>
/**
 * @name - (NSDictionary *)fetchAllTagsWithError:(NSError * __autoreleasing *)pError;
 *
 * @author Pushpak
 *
 * @brief Used to get all tags at one shot.
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param pError NSError pointer to hold error incase saving fails.
 *
 * @return array of MobileDeviceTagModels from database is returned as array.
 *
 */
- (NSArray *)fetchAllTagsWithError:(NSError * __autoreleasing *)pError;
@end