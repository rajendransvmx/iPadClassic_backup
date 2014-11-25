//
//  Cache.h
//  ServiceMaxMobile
//
//  Created by Damodar on 8/13/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Cache : NSObject


@property (nonatomic, strong) NSMutableArray *bucket;
@property (nonatomic, strong) NSMutableDictionary *cacheMap;

- (void)optimizeCache;
- (void)clearCache;
- (NSUInteger)getCacheSizeInuse;

@end
