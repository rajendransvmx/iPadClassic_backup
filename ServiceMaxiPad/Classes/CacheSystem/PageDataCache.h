//
//  PageDataCache.h
//  ServiceMaxMobile
//
//  Created by Damodar on 13/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "Cache.h"

@interface PageDataCache : Cache


+ (PageDataCache*)sharedInstance;

- (void)cachePageData:(id)object forKey:(NSString*)key;
- (id)getCachedObjectFor:(NSString*)objectName withProcessId:(NSString*)processId;

@end
