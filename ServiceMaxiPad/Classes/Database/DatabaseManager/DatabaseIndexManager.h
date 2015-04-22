//
//  DatabaseIndexManager.h
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 10/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sqlite3.h>


@interface DatabaseIndexManager : NSObject

+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

/**
 * @name  + (DatabaseIndexManager *)sharedInstance;
 *
 * @author Krishna shnabhag
 *
 * @brief this creates sharedInstance i.e) At a time Only one instance of the object will be there.
 *
 * @param
 * @return void
 *
 */

+ (instancetype)sharedInstance;

- (void) createAllIndicesForStaticTables;

- (void) dropAllIndicesForStaticTables;
- (void) dropAllIndicesForDynamicTables;
- (void) dropAllIndices;

- (void) registerTableNameForSingleIndexing:(NSString *)tableName;

- (void) clearAllRegisteredCompositeTables;
- (void) clearCache;

- (void) generateIndexingForCompositeIndices;

//After config sync if you want to re add the index.
- (void) createAllIndices;
- (void) addCompositeIndices:(NSArray *)indices ToTable:(NSString *)tableName ;

@end
