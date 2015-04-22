//
//  DataTypeCache.m
//  ServiceMaxMobile
//
//  Created by Damodar on 13/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "DataTypeCache.h"
#import "CacheConstants.h"

@implementation DataTypeCache
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

#pragma mark - Interface Methods
- (void)cacheDataType:(NSString*)dataType forFieldName:(NSString*)fieldName inObject:(NSString*)objectName
{
    /*---------------------------------------------
     |objectName --- |   fieldname -|- dataType   |
     |               |   fieldname -|- dataType   |
     |               |   fieldname -|- dataType   |
     |---------------------------------------------
     |objectName --- |   fieldname -|- dataType   |
     |               |   fieldname -|- dataType   |
     |---------------------------------------------
     |objectName --- |   fieldname -|- dataType   |
     |               |   fieldname -|- dataType   |
     |               |   fieldname -|- dataType   |
     ----------------------------------------------
     */
    
    // If cache limit hits remove least used object
    if([self.bucket count] >= MAX_DATATYPE_CACHE_ITEMS)
    {
        NSString *key = [self.bucket lastObject];
        
        // remove from cacheMap
        [self.cacheMap removeObjectForKey:key];
        
        // remove from bucket
        [self.bucket removeLastObject];
    }

    // If key is already present in the bucket, remove it, Current one will be added after.
    NSUInteger indexOfObject = [self.bucket indexOfObject:objectName];
    if(indexOfObject != NSNotFound)
    {
        [self.bucket removeObjectAtIndex:indexOfObject];
    }
    
    @autoreleasepool {
        // Get the existing set of field data types for the object name from cacheMap
        NSMutableDictionary *fieldMap = [self.cacheMap objectForKey:objectName];
        
        
        if((dataType == nil) || (fieldName == nil))
        {
            SXLogWarning(@"Could not cache, Invalid data for Data Type cache!");
            return;
        }
        
        // If doesnot exist create a new dictionary to add the new object
        if(fieldMap == nil)
        {
            fieldMap = [[NSMutableDictionary alloc] init];
        }
        
        [fieldMap setObject:dataType forKey:fieldName];
        
        [self.cacheMap setObject:fieldMap forKey:objectName];
        
        [self.bucket insertObject:objectName atIndex:0];
    }
}

- (NSString*)getCachedDataTypeForFieldName:(NSString*)fieldName inObject:(NSString*)objectName
{
    if([self.bucket containsObject:objectName])
    {
        [self.bucket removeObject:objectName];
        [self.bucket insertObject:objectName atIndex:0];
    }

    NSMutableDictionary *fieldMap = [self.cacheMap objectForKey:objectName];
    NSString *dataType = [fieldMap objectForKey:fieldName];
    return dataType;
}

- (void)optimizeCache\
{
    SXLogWarning(@"Operation will be performed on DataType Cache");
    
    NSUInteger optimizeCount = (NSUInteger)(MAX_DATATYPE_CACHE_ITEMS * OPTIMIZE_PERCENTAGE / 100);
    
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
