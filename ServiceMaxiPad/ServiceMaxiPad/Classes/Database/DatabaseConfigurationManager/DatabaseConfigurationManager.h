//
//  DatabaseConfigurationManager.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/27/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sqlite3.h>


@interface DatabaseConfigurationManager : NSObject

// ...

//+ (instancetype) sharedInstance;

+ (instancetype) alloc  __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init   __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new    __attribute__((unavailable("new not available, call sharedInstance instead")));

// ...

/**
 * @name  + (DatabaseConfigurationManager *)sharedInstance;
 *
 * @author Shubha S
 *
 * @brief this creates sharedInstance i.e) At a time Only one instance of the object will be there.
 *
 *
 *
 * @param
 * @return void
 *
 */

+ (instancetype)sharedInstance;

/**
 * @name  - (BOOL)performDatabaseVacuumization;
 *
 * @author Shubha S
 *
 * @brief this rebuilds the entire database
 * @reference http://www.sqlite.org/lang_vacuum.html
 *
 *
 * @param
 * @return void
 *
 */

- (BOOL)performDatabaseVacuumization;

/**
 * @name  - (void)performDatabaseInitialConfigurationForNewUser
 *
 * @author Shubha S
 *
 * @brief This does initial configuration of the database for new user.
 *
 *
 *
 * @param
 * @return void
 *
 */

- (void)performDatabaseInitialConfigurationForNewUser;

/**
 * @name  - (void)closeDatabase
 * @author Shubha S
 *
 * @brief This will close database
 *
 *
 *
 * @param
 * @return void
 *
 */

- (BOOL)closeDatabase;

/**
 * @name  performDatabaseConfigurationForSwitchUser
 *
 * @author Shubha S
 * @author Vipindas Palli
 *
 * @brief This configure the database for switch user
 *
 *
 *
 * @param
 * @return void
 *
 */

- (void)performDatabaseConfigurationForSwitchUser;

/**
 * @name - (void)dropAllTableIndex
 *
 * @author Shubha S
 *
 * @brief to drop all the index created for the table
 *
 *
 *
 * @param  database object which is of class sqlite3
 * @return void
 *
 */

- (void)dropAllTableIndex;

/**
 * @name  - (void)insertRecordIntoTable:(NSString*)tableNameOrObjectName andRecords:(NSArray*)records
 *
 * @author Shubha S
 *
 * @brief This method is used to insert records into table..
 *
 *
 * @param array of dictionary with field name and value
 * @return void
 */

- (void)insertRecordIntoTable:(NSString*)tableNameOrObjectName andRecords:(NSArray*)records;

/**
 * @name - (NSArray*)getAllRecordsForTable:(NSString *)tableNameOrObjectName byConditions:(NSDictionary*)dictionary
 
 *
 * @author Shubha S
 *
 * @brief This method is used to insert multiple records for a table.
 *
 *
 * @param  database object which is of class sqlite3
 * @return NSArray (set of records which satisfies condition)
 *
 */

- (NSArray*)getAllRecordsForTable:(NSString *)tableNameOrObjectName byConditions:(NSDictionary*)dictionary;

/**
 * @name - (void)doPriorDatabaseConfigurationForMetaSync
 *
 * @author Shubha S
 *
 * @brief This method is getting called before datasync operation.
 *
 *
 * @param  database object which is of class sqlite3
 * @return void 
 *
 */

- (void)doPriorDatabaseConfigurationForMetaSync;

/**
 * @name - (void)postMetaSyncDatabaseConfigurationByResult:(BOOL)isConfigurationSuccess *
 * @author Shubha S
 *
 * @brief This method is getting called after datasync operation.
 *
 *
 * @param  bool variable isConfigurationSuccess
 * @return BOOL value
 *
 */

- (BOOL)postMetaSyncDatabaseConfigurationByResult:(BOOL)isConfigurationSuccess;


- (NSString *)getSqliteDataTypeForSalesforceType:(NSString *)salesforceType ;


- (void)preInitialSyncDBPreparation;

- (BOOL)isLogsEnabled;

- (void)populateDataForMigration;

- (NSDictionary *)dataSetForDataMigration;

- (void)resetDataMigration;


@end
