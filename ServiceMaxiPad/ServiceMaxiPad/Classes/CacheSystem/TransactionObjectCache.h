//
//  TransactionObjectCache.h
//  ServiceMaxMobile
//
//  Created by Damodar on 13/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "Cache.h"

@interface TransactionObjectCache : Cache


+ (TransactionObjectCache*)sharedInstance;

- (void)cacheObject:(id)object;
- (id)getCachedObjectFor:(NSString*)key;

@end
