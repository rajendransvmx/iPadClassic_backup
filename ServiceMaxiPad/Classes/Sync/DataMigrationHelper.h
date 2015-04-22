//
//  DataMigrationHelper.h
//  ServiceMaxiPad
//
//  Created by Pushpak on 29/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataMigrationHelper : NSObject

+ (NSDictionary *)fetchMigrationMetaDataFromOldDatabase;
+ (NSDictionary *)populateTableSchemaForTables:(NSArray *)tables;
+ (NSArray *)fetchAllStaticTables;
+ (BOOL)checkObjectPermission:(NSString *)objectName;

@end
