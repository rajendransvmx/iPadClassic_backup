//
//  IncrementalSyncHelper.h
//  ServiceMaxMobile
//
//  Created by Sahana on 08/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IncrementalSyncHelper : NSObject


-(NSArray *)getFieldsForObject:(NSString *)obejctName;

- (void)fillUpDataInSyncRecords:(NSArray *)syncRecords;

-(NSDictionary *)getUpdateRecords;
- (NSInteger)getMaximumLocalId;
- (NSString *)getMasterColumnNameForObject:(NSString *)objectName; // padmashree, made public because using for resolve conflicts.

@end



