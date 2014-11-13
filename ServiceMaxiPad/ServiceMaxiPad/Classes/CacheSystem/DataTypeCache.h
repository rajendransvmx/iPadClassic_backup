//
//  DataTypeCache.h
//  ServiceMaxMobile
//
//  Created by Damodar on 13/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "Cache.h"

@interface DataTypeCache : Cache


+ (DataTypeCache*)sharedInstance;

- (void)cacheDataType:(NSString*)dataType forFieldName:(NSString*)fieldName inObject:(NSString*)objectName;
- (NSString*)getCachedDataTypeForFieldName:(NSString*)fieldName inObject:(NSString*)objectName;

@end
