//
//  Cache.m
//  ServiceMaxMobile
//
//  Created by Damodar on 8/13/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "Cache.h"
#import "CacheConstants.h"

@implementation Cache

- (id)init
{
    self = [super init];
    if(self)
    {
        _bucket = [[NSMutableArray alloc] init];
        _cacheMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)optimizeCache
{
    SXLogError(@"Error : Cannot perform operation on object of type Cache");
}

- (void)clearCache
{
    [self.bucket removeAllObjects];
    [self.cacheMap removeAllObjects];
}

- (NSUInteger)getCacheSizeInuse
{
    return [self.bucket count];
}



@end
