//
//  CacheManager.m
//  ServiceMaxMobile
//
//  Created by Damodar on 8/12/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   CacheManager.m
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



#import "CacheManager.h"
#import "CacheConstants.h"

#import "TransactionObjectCache.h"
#import "DataTypeCache.h"
#import "PageDataCache.h"
#import "GenericCache.h"

@interface CacheManager ()

- (NSUInteger)getCacheSizeInUse;

- (void)runUnitTests;
- (BOOL)runTransactionObjectCacheTests;
- (BOOL)runDataTypeCacheTests;
- (BOOL)runPageDataCacheTests;

@end

@implementation CacheManager

#pragma mark Singleton Methods

+ (instancetype) sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initInstance];
    });
    return sharedInstance;
}

- (instancetype) initInstance {
    self = [super init];
    // Do any other initialisation stuff here
    // ...
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

#pragma mark - Interface methods

- (void)cacheTransactionObject:(id)object
{
    // Get the shared instance TransactionObjectCache
    TransactionObjectCache *txnCache = [TransactionObjectCache sharedInstance];
    
    // Pass the object to cache
    [txnCache cacheObject:object];
}

- (void)cachePageData:(id)pageData forObject:(NSString*)objectName
{
    // Get the shared instance PageDataCache
    PageDataCache *pageCache = [PageDataCache sharedInstance];
    
    // Pass the object to cache
    [pageCache cachePageData:pageData forKey:objectName];
}

- (void)cacheDataType:(NSString*)dataType forField:(NSString*)fieldName forObject:(NSString*)objectName
{
    // Get the shared instance DataTypeCache
    DataTypeCache *dTCache = [DataTypeCache sharedInstance];
    
    // Pass the object to cache
    [dTCache cacheDataType:dataType forFieldName:fieldName inObject:objectName];
}

- (id)getTransactionObjectForKey:(NSString*)key
{
    TransactionObjectCache *txnCache = [TransactionObjectCache sharedInstance];
    
    return [txnCache getCachedObjectFor:key];
}

- (id)getPageDataForObject:(NSString*)objectAPIName withProcessId:(NSString*)processId
{
    PageDataCache *pageCache = [PageDataCache sharedInstance];
    
    return [pageCache getCachedObjectFor:objectAPIName withProcessId:processId];
}

- (NSString*)getDataTypeFor:(NSString*)fieldname fromObject:(NSString*)objectName
{
    DataTypeCache *dtcache = [DataTypeCache sharedInstance];
    
    return [dtcache getCachedDataTypeForFieldName:fieldname inObject:objectName];
}


#pragma mark - Geniric cache methods

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

- (void)pushToCache:(id)object byKey:(NSString *)key
{
    GenericCache *genericCache = [GenericCache sharedInstance];
    
    return [genericCache cacheData:object forKey:key];
    
}

/**
 * @name   pushToCacheWithAutoDataCleanupProtection:(id)object byKey:(NSString *)key
 *
 * @author Vipindas Palli
 *
 * @brief  Store data inot cache with automatice data cleanup protection
 *
 * \par
 *     Cached data protect from auto data cleanup process. There are two types of cleanup process.
 * First, if cache limits exceeded system automatically remove least used obejct cache.
 * Second, in case of recieiving memory warning from application system automatically remove least used obejct cache.
 * This data protected from above mentioned both automatice cleanup method.
 *
 * User must use 'clearCacheByKey:' to remove data from the cache
 *
 * @return void
 */

- (void)pushToCacheWithAutomaticDataCleanupProtection:(id)object byKey:(NSString *)key
{
    GenericCache *genericCache = [GenericCache sharedInstance];
    
    return [genericCache cacheDataWithCleanupProtection:object forKey:key];
}

/**
 * @name   getCachedObjectByKey:(NSString *)key
 *
 * @author Vipindas Palli
 *
 * @brief  Generic Caching mechanism
 *
 * \par
 *  <Longer description starts here>
 *
 * @return instance type
 *
 */

- (id)getCachedObjectByKey:(NSString *)key
{
    GenericCache *genericCache = [GenericCache sharedInstance];
    
    return [genericCache getCachedDataByKey:key];
    return nil;
}

/**
 * @name   clearCacheByKey:(NSString *)key
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

- (void)clearCacheByKey:(NSString *)key
{
    GenericCache *genericCache = [GenericCache sharedInstance];
    
    return [genericCache removeCachedDataByKey:key];
}


- (void)clearCache
{
    
}

- (void)optimizeCache
{
    
}

#pragma mark - Private methods

- (NSUInteger)getCacheSizeInUse
{
    return 0;
}

#pragma mark - Unit Test cases
- (void)runUnitTests
{
    NSLog(@"START : Unit test");
    if([self runTransactionObjectCacheTests])
        if([self runDataTypeCacheTests])
            if([self runPageDataCacheTests])
                return;
    
    NSLog(@"DONE : Unit test");
}

- (BOOL)runTransactionObjectCacheTests
{
    NSLog(@"START : Transaction object cache Test cases");
    
    // Scenario 1 :
    // If test failed : return NO;
    
    // Scenario 2 :
    // If test failed : return NO;
    
    NSLog(@"DONE : Transaction object cache Test cases");
    return TRUE;
}

- (BOOL)runDataTypeCacheTests
{
    NSLog(@"START : Data Type cache Test cases");

    // Scenario 1 :
    // If test failed : return NO;
    
    // Scenario 2 :
    // If test failed : return NO;
    
    NSLog(@"DONE : Data Type cache Test cases");
    return TRUE;
}

- (BOOL)runPageDataCacheTests
{
    NSLog(@"START : Page Data cache Test cases");

    // Scenario 1 :
    // If test failed : return NO;
    
    // Scenario 2 :
    // If test failed : return NO;
    
    NSLog(@"DONE : Page Data cache Test cases");
    return TRUE;
}



@end
