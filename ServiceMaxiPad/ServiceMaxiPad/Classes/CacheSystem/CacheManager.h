//
//  CacheManager.h
//  ServiceMaxMobile
//
//  Created by Damodar on 8/12/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//
/**
 *  @file   CacheManager.h
 *  @class  CacheManager
 *
 *  @brief  Manage caching in applications
 *
 *  @author  Damodar
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import <Foundation/Foundation.h>

@interface CacheManager : NSObject
// ...

// + (instancetype) sharedInstance;

+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

// ...
/**
 * @name   sharedInstance
 *
 * @author Damodar
 *
 * @brief  Create only Single instance of the class and provides the same instance every time
 *
 * \par
 *  <Longer description starts here>
 *
 * @return Instance of CacheManager
 *
 */

+ (instancetype)sharedInstance;

/**
 * @name   cacheTransactionObject:(id)object;
 *
 * @author Damodar
 *
 * @brief  Caches only transaction object based on salesforce id which if not available uses record id
 *
 * \par
 *  <Longer description starts here>
 *
 * @return void
 *
 */

- (void)cacheTransactionObject:(id)object;

/**
 * @name   cachePageData:(id)pageData forObject:(NSString*)objectName
 *
 * @author Damodar
 *
 * @brief  Caches only Page data object for the given object name and process id of the page
 *
 * \par
 *  <Longer description starts here>
 *
 * @return void
 *
 */

- (void)cachePageData:(id)pageData forObject:(NSString*)objectName;

/**
 * @name   cacheDataType:(NSString*)dataType forField:(NSString*)fieldName forObject:(NSString*)objectName
 *
 * @author Damodar
 *
 * @brief  Caches only data type for the given object name and field name
 *
 * \par
 *  <Longer description starts here>
 *
 * @return void
 *
 */

- (void)cacheDataType:(NSString*)dataType forField:(NSString*)fieldName forObject:(NSString*)objectName;

/**
 * @name   getTransactionObjectForKey:(NSString*)key
 *
 * @author Damodar
 *
 * @brief  get cached object from by key
 *
 * \par
 *  <Longer description starts here>
 *
 * @return instance type
 *
 */

- (id)getTransactionObjectForKey:(NSString*)key;

/**
 * @name   getPageDataForObject:(NSString*)objectAPIName withProcessId:(NSString*)processId
 *
 * @author Damodar
 *
 * @brief  get cached object from by object name and process id
 *
 * \par
 *  <Longer description starts here>
 *
 * @return instance type
 *
 */

- (id)getPageDataForObject:(NSString*)objectAPIName withProcessId:(NSString*)processId;

/**
 * @name   getDataTypeFor:(NSString*)fieldname fromObject:(NSString*)objectName;
 *
 * @author Damodar
 *
 * @brief  get cached data type for given object name and field name
 *
 * \par
 *  <Longer description starts here>
 *
 * @return data type
 *
 */

- (NSString*)getDataTypeFor:(NSString*)fieldname fromObject:(NSString*)objectName;

/**
 * @name   clearCache
 *
 * @author Damodar
 *
 * @brief  Empties the cache storage completely
 *
 * \par
 *  <Longer description starts here>
 *
 * @return void
 *
 */

- (void)clearCache;

/**
 * @name   optimizeCache
 *
 * @author Damodar
 *
 * @brief  Optimizes the cache storage by remove least used objects from all cache. Reduces the currently used cache size by predefined percentage.
 *
 * \par
 *  <Longer description starts here>
 *
 * @return void
 *
 */

- (void)optimizeCache;


/**
 * @name   pushToCache:(id)object byKey:(NSString *)key;
 *
 * @author Vipindas Palli
 *
 * @brief  Generic Caching mechanism
 *
 * \par
 *  <Longer description starts here>
 *
 * @return void
 *
 */

- (void)pushToCache:(id)object byKey:(NSString *)key;

/**
 * @name   pushToCacheWithAutoDataCleanupProtection:(id)object byKey:(NSString *)key
 *
 * @author Vipindas Palli
 *
 * @brief  Store data into cache with automatice data cleanup protection
 *
 * \par
 *     Cached data protect from auto data cleanup process. There are two types of cleanup process.
 * First, if cache exceeded limits system automatically remove least used obejct from cache.
 * Second, in case of recieiving memory warning from application system automatically remove least used obejct from  cache.
 * This data protected from above mentioned both automatice cleanup method.
 *
 * User must use 'clearCacheByKey:' to remove data from the cache
 *
 * @return void
 *
 */

- (void)pushToCacheWithAutomaticDataCleanupProtection:(id)object byKey:(NSString *)key;

/**
 * @name   getCachedObjectByKey:(NSString *)key
 *
 * @author Vipindas Palli
 *
 * @brief  get cached object from by key
 *
 * \par
 *  <Longer description starts here>
 *
 * @return instance type
 *
 */

- (id)getCachedObjectByKey:(NSString *)key;

/**
 * @name   pushToCache:(id)object byKey:(NSString *)key;
 *
 * @author Vipindas Palli
 *
 * @brief  Generic Caching mechanism
 *
 * \par
 *  <Longer description starts here>
 *
 * @return void
 *
 */

- (void)clearCacheByKey:(NSString *)key;

@end
