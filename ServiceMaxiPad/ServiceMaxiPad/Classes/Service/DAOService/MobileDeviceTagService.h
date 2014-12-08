//
//  MobileDeviceTagService.h
//  ServiceMaxMobile
//
//  Created by Pushpak on 19/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//
/**
 *  @file MobileDeviceTagService.h
 *  @class MobileDeviceTagService.h
 *
 *  @brief Specific service class implementing DAO protocol methods to handle MobileDeviceTags table.
 *
 *  @author Pushpak
 *
 *  @bug No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/
#import <Foundation/Foundation.h>
#import "MobileDeviceTagDAO.h"
#import "CommonServices.h"

@interface MobileDeviceTagService : CommonServices<MobileDeviceTagDAO>

@end
