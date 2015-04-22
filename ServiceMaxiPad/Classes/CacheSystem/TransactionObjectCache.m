//
//  TransactionObjectCache.m
//  ServiceMaxMobile
//
//  Created by Damodar on 13/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "TransactionObjectCache.h"
#import "TransactionObjectModel.h"
#import "CacheConstants.h"

@interface TransactionObjectCache ()

@property (nonatomic, strong) NSMutableDictionary *internalMap;

@end


@implementation TransactionObjectCache
#pragma mark - Singleton class Implementation
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
    _internalMap = [[NSMutableDictionary alloc] init];
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}


#pragma mark - interface methods

- (void)cacheObject:(id)object
{
    // If cache limit hits remove least used object
    if([self.bucket count] >= MAX_TXN_CACHE_ITEMS)
    {
        NSString *key = [self.bucket lastObject];
        
        // remove from internal map
        NSString  *recLocalId = [self.cacheMap objectForKey:key];
        [self.internalMap removeObjectForKey:recLocalId];
        
        // remove from cacheMap
        [self.cacheMap removeObjectForKey:key];
        
        // remove from bucket
        [self.bucket removeLastObject];
    }
    
    TransactionObjectModel *txnModel = (TransactionObjectModel*)object;

    NSString *recLocalId = txnModel.recordLocalId;
    NSString *salesforceId = txnModel.salesForceId;
    
    // if key already present in the bucket / cacheMap / internalMap , replace it.
    NSUInteger indexInBucket = [self.bucket indexOfObject:salesforceId];
    if(indexInBucket == NSNotFound) // If salesforce Id is not found check if record local id is present
    {
        indexInBucket = [self.bucket indexOfObject:recLocalId];
        
        if(indexInBucket != NSNotFound)
        {
            // remove from internal map
            NSString  *recLocId = [self.cacheMap objectForKey:recLocalId];
            [self.internalMap removeObjectForKey:recLocId];
            
            // remove from cacheMap
            [self.cacheMap removeObjectForKey:recLocalId];
        }
    }
    else // if key present in the bucket then remove it. Current object will be inserted after.
    {
        // remove from internal map
        NSString  *recLocId = [self.cacheMap objectForKey:salesforceId];
        [self.internalMap removeObjectForKey:recLocId];
        
        // remove from cacheMap
        [self.cacheMap removeObjectForKey:salesforceId];
    }
    
    if(indexInBucket != NSNotFound)
        [self.bucket removeObjectAtIndex:indexInBucket];
    
    
    // Insert the object in cache.
    [self.internalMap setObject:txnModel forKey:recLocalId];
    if(salesforceId != nil)
    {
        if(recLocalId == nil)
        {
            SXLogWarning(@"Could not cache, local Id missing for TXN Object");
            return;
        }
        
        [self.cacheMap setObject:recLocalId forKey:salesforceId];
        [self.bucket insertObject:salesforceId atIndex:0];
    }
    else
    {
        if(recLocalId == nil)
        {
            SXLogWarning(@"Could not cache, local Id missing for TXN Object");
            return;
        }

        [self.cacheMap setObject:recLocalId forKey:recLocalId];
        [self.bucket insertObject:recLocalId atIndex:0];
    }
}

- (id)getCachedObjectFor:(NSString*)key
{
    if([self.bucket containsObject:key])
    {
        [self.bucket removeObject:key];
        [self.bucket insertObject:key atIndex:0];
    }
    
    NSString *recLocalId = [self.cacheMap objectForKey:key];
    
    if(recLocalId == nil)
        recLocalId = key;
    
    TransactionObjectModel *txnModel = [self.internalMap objectForKey:recLocalId];
    
    return txnModel;
}

- (void)optimizeCache
{
    SXLogWarning(@"Operation will be performed on Transaction Object Cache");
    
    NSUInteger optimizeCount = (NSUInteger)(MAX_TXN_CACHE_ITEMS * OPTIMIZE_PERCENTAGE / 100);
    
    while([self.bucket count] >= optimizeCount)
    {
        NSString *key = [self.bucket lastObject];
        
        // remove from internal map
        NSString  *recLocalId = [self.cacheMap objectForKey:key];
        [self.internalMap removeObjectForKey:recLocalId];
        
        // remove from cacheMap
        [self.cacheMap removeObjectForKey:key];
        
        // remove from bucket
        [self.bucket removeLastObject];
    }

}

@end
