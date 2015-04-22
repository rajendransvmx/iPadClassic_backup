
//
//  ApplicationVersionWatchDog.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/12/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   ApplicationVersionWatchDog.h
 *  @class  ApplicationVersionWatchDog
 *
 *  @brief  Class for checks the feature supported for existing server version and client version
 *
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import <Foundation/Foundation.h>


@interface ApplicationVersionWatchDog : NSObject

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
+ (BOOL)isServiceFlowMangerSearchFeatureEnabled;

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

+ (BOOL)isGetPriceFeatureEnabled;

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

+ (BOOL)isLocationPingFeatureEnabled;
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

+ (BOOL)isBussinessRuleFeatureEnabled;
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

+ (BOOL)isAttachmentFeatureEnabled;
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

+ (BOOL)isDataPurgeFeatureEnabled;
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

+ (BOOL)isSyncAppLogsToServerFeatureEnabled;

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

+ (BOOL)isLookUpFilterFeatureEnabled;


@end
