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
    
    if((object == nil) || (key == nil) || (page.process.processInfo.processId == nil))
    {
        SXLogWarning(@"Could not cache the data, Invalid Page Data send to cache");
        return;
    }

    // If doesnot exist create a new dictionary to add the new object
    @autoreleasepool
    {
        if(fieldMap == nil)
        {
            fieldMap = [[NSMutableDictionary alloc] init];
        }
        
        [fieldMap setObject:object forKey:page.process.processInfo.processId];
        
        [self.cacheMap setObject:fieldMap forKey:key];
        
        [self.bucket insertObject:key atIndex:0];
    }
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
    //NSLog(@"Warning : Operation will be performed on PageData Cache");
    
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
