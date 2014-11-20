//
//  GenericCache.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 23/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   GenericCache.h
 *  @class  GenericCache
 *
 *  @brief  Generic cache management
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>
#import "Cache.h"

@interface GenericCache : Cache

/**
 * @name   + (GenericCache *)sharedInstance
 *
 * @author Vipindas Palli
 *
 * @brief
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Generic cache object
 *
 */

+ (GenericCache *)sharedInstance;

/**
 * @name   cacheData:(id)data forKey:(NSString *)key;
 *
 * @author Vipindas Palli
 *
 * @brief
 *
 * \par
 *  <Longer description starts here>
 *
 * @return void
 *
 */

- (void)cacheData:(id)data forKey:(NSString *)key;

/**
 * @name   cacheDataWithCleanupProtection:(id)data forKey:(NSString *)key
 *
 * @author Vipindas Palli
 *
 * @brief
 *
 * \par
 *  <Longer description starts here>
 *
 * @return void
 *
 */

- (void)cacheDataWithCleanupProtection:(id)data forKey:(NSString *)key;

/**
 * @name   getCachedDataByKey:(NSString*)key
 *
 * @author Vipindas Palli
 *
 * @brief
 *
 * \par
 *  <Longer description starts here>
 *
 * @return instance type
 *
 */

- (id)getCachedDataByKey:(NSString*)key;

/**
 * @name   removeCachedDataByKey:(NSString*)key
 *
 * @author Vipindas Palli
 *
 * @brief
 *
 * \par
 *  <Longer description starts here>
 *
 * @return instance type
 *
 */

- (void)removeCachedDataByKey:(NSString*)key;

@end
