//
//  GenericCache.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 23/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   GenericCache.m
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


#import "GenericCache.h"
#import "CacheConstants.h"

@interface  GenericCache()

@property (nonatomic, strong) NSMutableSet *protectedDataKeys;

@end

@implementation GenericCache

@synthesize protectedDataKeys;
#pragma mark - Singleton class Implementation

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

- (void)cacheData:(id)data forKey:(NSString *)key
{
    // If cache limit hits remove least used object
    if([self.bucket count] >= MAX_GENERIC_CACHE_ITEMS)
    {
        [self optimizeCache];
    }
    
    // If key is already present in the bucket, remove it, Current one will be added after.
    NSUInteger indexOfObject = [self.bucket indexOfObject:key];
    if(indexOfObject != NSNotFound)
    {
        [self.bucket removeObjectAtIndex:indexOfObject];
    }

    [self.cacheMap setObject:data forKey:key];
    
    [self.bucket   insertObject:key atIndex:0];
}

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

- (void)cacheDataWithCleanupProtection:(id)data forKey:(NSString *)key
{
    if (protectedDataKeys == nil)
    {
        NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:0];
        self.protectedDataKeys = set;
    }
    
    if (![protectedDataKeys containsObject:key])
    {
        [protectedDataKeys addObject:key];
    }
    
    [self cacheData:data forKey:key];
}

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

- (id)getCachedDataByKey:(NSString*)key
{
    if([self.bucket containsObject:key])
    {
        [self.bucket removeObject:key];
        [self.bucket insertObject:key atIndex:0];
    }
    
    return [self.cacheMap objectForKey:key];
}


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

- (void)removeCachedDataByKey:(NSString*)key
{
    // remove from cacheMap
    [self.cacheMap removeObjectForKey:key];
    
    // remove from bucket
    [self.bucket removeObject:key];
    
    if (self.protectedDataKeys != nil)
    {
        [self.protectedDataKeys removeObject:key];
    }
}

/**
 * @name   recacheProtectedData:(NSDictionary *)dataDictionary
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

- (void)recacheProtectedData:(NSDictionary *)dataDictionary
{
   NSArray *keys = [dataDictionary allKeys];
    for (NSString *key in keys)
    {
        if ([dataDictionary objectForKey:key] != nil)
        {
            [self cacheDataWithCleanupProtection:[dataDictionary objectForKey:key] forKey:key];
        }
    }
}

/**
 * @name   optimizeCache
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

- (void)optimizeCache
{
    
    NSUInteger optimizeCount = (NSUInteger)(MAX_GENERIC_CACHE_ITEMS * OPTIMIZE_PERCENTAGE / 100);
    
    /** Lets protect protection marked data  */
    @autoreleasepool {
        NSDictionary *protectedData = nil;
        
        if (protectedDataKeys != nil)
        {
            /** Get subset of the protected data */
            NSArray *protectedValues = [self.cacheMap objectsForKeys:[protectedDataKeys allObjects] notFoundMarker:@""];
            protectedData = [[NSMutableDictionary alloc] initWithObjects:protectedValues
                                                                  forKeys:[protectedDataKeys allObjects]];
            if ([protectedData count] >= MAX_GENERIC_CACHE_ITEMS)
            {
                // Woo it has more data than limit lets donot protect them... :)
                protectedData = nil;
            }
        }
        
        // If cache limit hits remove least used object
        while([self.bucket count] >= optimizeCount)
        {
            NSString *lastKey = [self.bucket lastObject];
            
            // remove from cacheMap
            [self.cacheMap removeObjectForKey:lastKey];
            
            // remove from bucket
            [self.bucket removeObject:lastKey];
            
            if (self.protectedDataKeys != nil)
            {
                [self.protectedDataKeys removeObject:lastKey];
            }
        }
        
        if (protectedData != nil)
        {
            [self recacheProtectedData:protectedData];
        }
    }
}

@end
