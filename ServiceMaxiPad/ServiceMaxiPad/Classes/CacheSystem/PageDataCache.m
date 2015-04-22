//
//  PageDataCache.m
//  ServiceMaxMobile
//
//  Created by Damodar on 13/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "PageDataCache.h"
#import "CacheConstants.h"
#import "SFMPage.h"
#import "SFMProcess.h"

@implementation PageDataCache

static dispatch_once_t _sharedPageDataCacheInstanceGuard;
static PageDataCache *_instance;

#pragma mark - Singleton class Implementation

- (id)init
{
    return [PageDataCache sharedInstance];
}


- (id)initializePageDataCache
{
    self = [super init];
    
    if (self)
    {
        
    }
    return self;
}


+ (PageDataCache*)sharedInstance
{
    dispatch_once(&_sharedPageDataCacheInstanceGuard,
                  ^{
                      _instance = [[PageDataCache alloc] initializePageDataCache];
                  });
    return _instance;
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


- (id)retain
{
    return self;
}


- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    // never release
}

- (id)autorelease
{
    return self;
}

#pragma mark - Interface methods
- (void)cachePageData:(id)object forKey:(NSString*)key
{
    /*------------------------------------------------
     |objectAPIName --- |   processId -|- PageData   |
     |                  |   processId -|- PageData   |
     |                  |   processId -|- PageData   |
     |------------------------------------------------
     |objectAPIName --- |   processId -|- PageData   |
     |                  |   processId -|- PageData   |
     |------------------------------------------------
     |objectAPIName --- |   processId -|- PageData   |
     |                  |   processId -|- PageData   |
     |                  |   processId -|- PageData   |
     -------------------------------------------------
     */

    // If cache limit hits remove least used object
    if([self.bucket count] >= MAX_PAGEDATA_CACHE_ITEMS)
    {
        NSString *key = [self.bucket lastObject];
        
        // remove from cacheMap
        [self.cacheMap removeObjectForKey:key];
        
        // remove from bucket
        [self.bucket removeLastObject];
    }
    
    // If key is already present in the bucket, remove it, Current one will be added after.
    NSUInteger indexOfObject = [self.bucket indexOfObject:key];
    if(indexOfObject != NSNotFound)
    {
        [self.bucket removeObjectAtIndex:indexOfObject];
    }
    
    SFMPage *page = (SFMPage*)object;
    
    // Get the existing set of field data types for the object name from cacheMap
    NSMutableDictionary *fieldMap = [self.cacheMap objectForKey:key];
    
    // If doesnot exist create a new dictionary to add the new object
    if(fieldMap == nil)
        fieldMap = [[NSMutableDictionary alloc] init];
    
    if((object == nil) || (key == nil) || (page.process.processInfo.processId == nil))
    {
        SXLogWarning(@"Could not cache the data, Invalid Page Data send to cache");
        return;
    }

    
    [fieldMap setObject:object forKey:page.process.processInfo.processId];
    
    [self.cacheMap setObject:fieldMap forKey:key];
    
    [self.bucket insertObject:key atIndex:0];
}

- (id)getCachedObjectFor:(NSString*)objectName withProcessId:(NSString*)processId
{
    if([self.bucket containsObject:objectName])
    {
        [self.bucket removeObject:objectName];
        [self.bucket insertObject:objectName atIndex:0];
    }
    
    NSMutableDictionary *fieldMap = [self.cacheMap objectForKey:objectName];
    NSString *dataType = [fieldMap objectForKey:processId];
    return dataType;
}

- (void)optimizeCache
{
    NSLog(@"Warning : Operation will be performed on PageData Cache");
    
    NSUInteger optimizeCount = (NSUInteger)(MAX_PAGEDATA_CACHE_ITEMS * OPTIMIZE_PERCENTAGE / 100);
    
    // If cache limit hits remove least used object
    while([self.bucket count] >= optimizeCount)
    {
        NSString *key = [self.bucket lastObject];
        
        // remove from cacheMap
        [self.cacheMap removeObjectForKey:key];
        
        // remove from bucket
        [self.bucket removeLastObject];
    }
}

@end
