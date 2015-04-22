//
//  ApplicationVersionWatchDog.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/12/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   FileNaApplicationVersionWatchDog.m
 *  @class  ApplicationVersionWatchDog
 *
 *  @brief  Class for checks the feature supported for existing server version and client version
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "ApplicationVersionWatchDog.h"
#import "CustomerOrgInfo.h"
#import "StringUtil.h"

static float const kVersionConstant      = 100000.0f;        /** Multiplication constant for version value   */

static float const kMinServerPackageVersionForServiceFlowManagerSearch      = 9.1f;        /** SFM Search  */
static float const kMinServerPackageVersionForLocationPing                  = 9.1f;        /** Location Ping */
static float const kMinServerPackageVersionForGetPrice                      = 10.40000f;   /** Get Price */
static float const kMinServerPackageVersionForLookUpfilters                 = 11.2f;       /** Lookup Filter */
static float const kMinServerPackageVersionForBussinessRule                 = 12.00000f;   /** Bussiness Rule  */
static float const kMinServerPackageVersionForAttachment                    = 12.10000f;   /** Attachment  */
static float const kMinServerPackageVersionForSyncAppLogsToServer           = 12.10000f;   /** Sync Applogs to server */
static float const kMinServerPackageVersionForDataPurge                     = 14.19100f;   /** Datapurge */


@implementation ApplicationVersionWatchDog

/**
 * @name   isFeatureEnabledForMinVersion:
 *
 * @author Vipindas Palli
 *
 * @brief  Validate current server/client version supports SFM search feature
 *
 * \par
 *  <Longer description starts here>
 *
 * @param  featureRequiredMinVersion Min server version required feature for feature to enable. 
 *
 * @return bool  value
 *
 */


+ (BOOL)isFeatureEnabledForMinVersion:(float)featureRequiredMinVersion
{
    NSString *serverVersion = [[CustomerOrgInfo sharedInstance] serverVersion];

    if ([StringUtil isStringEmpty:serverVersion])
    {
        /** Wooo serverversion is empty, not supporting feature */
        return NO;
    }
    else
    {
        int currentServerVersion = [serverVersion intValue];
        
        float requiredMinVersion = (featureRequiredMinVersion * kVersionConstant);
        
        if (currentServerVersion >= requiredMinVersion)
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
}

/**
 * @name  isServiceFlowMangerSearchFeatureEnabled
 *
 * @author Vipindas Palli
 *
 * @brief Validate current server/client version supports SFM search feature
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return bool  value
 *
 */


+ (BOOL)isServiceFlowMangerSearchFeatureEnabled
{
    return [ApplicationVersionWatchDog isFeatureEnabledForMinVersion:kMinServerPackageVersionForServiceFlowManagerSearch];
}

/**
 * @name  isGetPriceFeatureEnabled
 *
 * @author Vipindas Palli
 *
 * @brief Validate current server/client version supports Get Price feature
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return bool  value
 *
 */

+ (BOOL)isGetPriceFeatureEnabled
{
    return [ApplicationVersionWatchDog isFeatureEnabledForMinVersion:kMinServerPackageVersionForGetPrice];
}

/**
 * @name  isLocationPingFeatureEnabled
 *
 * @author Vipindas Palli
 *
 * @brief Validate current server/client version supports location ping/monitoring feature
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return bool  value
 *
 */

+ (BOOL)isLocationPingFeatureEnabled
{
    return [ApplicationVersionWatchDog isFeatureEnabledForMinVersion:kMinServerPackageVersionForLocationPing];
}

/**
 * @name  isBussinessRuleFeatureEnabled
 *
 * @author Vipindas Palli
 *
 * @brief Validate current server/client version supports Biz (Bussiness) rules feature
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return bool  value
 *
 */

+ (BOOL)isBussinessRuleFeatureEnabled
{
    return [ApplicationVersionWatchDog isFeatureEnabledForMinVersion:kMinServerPackageVersionForBussinessRule];
}

/**
 * @name  isAttachmentFeatureEnabled
 *
 * @author Vipindas Palli
 *
 * @brief Validate current server/client version supports Attachment feature
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return bool  value
 *
 */

+ (BOOL)isAttachmentFeatureEnabled
{
    return [ApplicationVersionWatchDog isFeatureEnabledForMinVersion:kMinServerPackageVersionForAttachment];
}

/**
 * @name  isDataPurgeFeatureEnabled
 *
 * @author Vipindas Palli
 *
 * @brief Validate current server/client version supports Data purge feature
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return bool  value
 *
 */

+ (BOOL)isDataPurgeFeatureEnabled
{
    return [ApplicationVersionWatchDog isFeatureEnabledForMinVersion:kMinServerPackageVersionForDataPurge];
}

/**
 * @name  isSyncAppLogsToServerFeatureEnabled
 *
 * @author Vipindas Palli
 *
 * @brief Validate current server/client version supports sync application log to server feature
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return bool  value
 *
 */

+ (BOOL)isSyncAppLogsToServerFeatureEnabled
{
    return [ApplicationVersionWatchDog isFeatureEnabledForMinVersion:kMinServerPackageVersionForSyncAppLogsToServer];
}

/**
 * @name  isLookUpFilterFeatureEnabled
 *
 * @author Vipindas Palli
 *
 * @brief Validate current server/client version supports Lookup feature
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return bool  value
 *
 */

+ (BOOL)isLookUpFilterFeatureEnabled
{
    return [ApplicationVersionWatchDog isFeatureEnabledForMinVersion:kMinServerPackageVersionForLookUpfilters];
}

@end
