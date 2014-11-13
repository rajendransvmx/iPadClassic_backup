//
//  DatabaseConfigurationManager.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/27/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "DatabaseConfigurationManager.h"
#import "StringUtil.h"
#import "FileManager.h"
#import "DatabaseSchemaConstant.h"
#import "DatabaseManager.h"
#import "DatabaseIndexConstant.h"
#import "DatabaseConstant.h"
#import "DBRequestSelect.h"
#import "SQLResultSet.h"
#import "DataMigrationHelper.h"
#import "SyncManager.h"
#import "PlistManager.h"


@interface DatabaseConfigurationManager ()
{
    BOOL    jobLogsEnbaled;
}

- (void)resetConfiguration;

- (void)createAllTables;

- (void)createTableIndex;

- (BOOL)attachDatabaseByName:(NSString *)attachmentName andPath:(NSString *)path;

- (BOOL)detachDatabaseByName:(NSString *)databaseName;

- (void)removeDb;

- (NSArray*)getAllTheSchemaForCreateTable;

- (NSArray*)getAllTheSchemaForIndexCreation;

- (NSArray*)getAllTheSchemaForDropIndex;


@end

@implementation DatabaseConfigurationManager

#pragma mark Singleton Methods

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
    jobLogsEnbaled = [PlistManager storedJobLogsEnabledValue];
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

/**
 * @name  - (void)performDatabaseVacuumization;
 *
 * @author Shubha S
 *
 * @brief this rebuilds the entire database
 * @reference http://www.sqlite.org/lang_vacuum.html
 *
 *
 *
 * @param
 * @return void
 *
 */

- (BOOL)performDatabaseVacuumization
{
    NSString *queryStatement = @"VACUUM;";
    
    __block BOOL sucessFull = NO;
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        
       sucessFull = [db executeUpdate:queryStatement];
        
        if (!sucessFull)
        {
            if ([db hadError])
            {
                SXLogError(@"Vacuum failed with error : %@ ", [db lastErrorMessage]);
            }
        }
    }];
    }
    return sucessFull;
}

/**
 * @name  - (void)performDatabaseInitialConfigurationForNewUser
 *
 * @author Shubha S
 *
 * @brief this performs database initial configuration for new user
 *
 *
 *
 * @param
 * @return void
 *
 */

- (void)performDatabaseInitialConfigurationForNewUser
{
    [self resetConfiguration];
    [self createAllTables];
}

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

- (BOOL)closeDatabase
{
    BOOL sucessFull = YES;

    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue close];
    

    return sucessFull;
}

/**
 * @name  performDatabaseConfigurationForSwitchUser
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

- (void)performDatabaseConfigurationForSwitchUser
{
    NSLog(@" Database config preset up");
    if ( [self closeDatabase])
    {
        NSLog(@" closed database ");
    }
    else
    {
        NSLog(@" Unable to close database - but removing file");
    }
    
    [self removeDb];
    
    [[DatabaseManager sharedInstance] resetDatabasePath];
    
    // Lets create new database file
    [[DatabaseManager sharedInstance] createEditableDatabaseIfNeeded];
}

#pragma mark - private method

/**
 * @name    resetConfiguration
 * @author  Shubha S
 *
 * @brief This is gets called for reset the configuration.
 *
 *
 *
 * @param
 * @return void
 *
 */

- (void)resetConfiguration
{
    @autoreleasepool {

        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];

        SMDatabase *db = [queue database];

        if (db == nil)
        {
            NSLog(@"invalid db skipping config");
            return;
        }

        char * errMessageSynch;
        char * errMessageJournalMod;
        char * errMessagePageSize;
        char * errMessageCacheSize;

        int  pageSizeResult =  sqlite3_exec([db sqliteHandle], "PRAGMA page_size = 64", NULL, NULL, &errMessagePageSize);
        int  syncResult     =  sqlite3_exec([db sqliteHandle], "PRAGMA synchronous = OFF", NULL, NULL, &errMessageSynch);
        int  journalResult  =  sqlite3_exec([db sqliteHandle], "PRAGMA journal_mode = MEMORY", NULL, NULL, &errMessageJournalMod);
        int  cacheSizeResult = sqlite3_exec([db sqliteHandle], "PRAGMA cache_size = 50", NULL, NULL, &errMessageCacheSize);

        if (pageSizeResult != SQLITE_OK)
        {
            NSLog(@"db error page size : %d - %@", pageSizeResult, [NSString stringWithUTF8String:errMessagePageSize]);
        }

        if (syncResult != SQLITE_OK)
        {
            NSLog(@" db error sync : %d - %@", syncResult, [NSString stringWithUTF8String:errMessageSynch]);
        }

        if (journalResult != SQLITE_OK)
        {
            NSLog(@"db error jorunal mode : %d - %@", journalResult, [NSString stringWithUTF8String:errMessageJournalMod]);
        }

        if (cacheSizeResult != SQLITE_OK)
        {
            NSLog(@" db error cache size : %d - %@", journalResult, [NSString stringWithUTF8String:errMessageJournalMod]);
        }

        NSLog(@"db config - %d - %d - %d - %d", pageSizeResult, syncResult, journalResult, cacheSizeResult);
    }
}

/**
 * @name  - (void)createAllTables:(NSArray*)listOfTableName
 *
 * @author Shubha S
 *
 * @brief This creates all the static tables.
 *
 *
 *
 * @param
 * @return void
 
 *
 */

- (void)createAllTables
{
    NSArray *tableSchemaArray = [self getAllTheSchemaForCreateTable];
    
    NSString *sqlStatement;
    
    __block BOOL sucessFull = NO;
    
    @autoreleasepool {
        
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        for (int i = 0; i < [tableSchemaArray count]; i++)
        {
            sqlStatement = [tableSchemaArray objectAtIndex:i];
    
            [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        
                sucessFull = [db executeUpdate:sqlStatement];
        
                if (!sucessFull)
                {
                    if ([db hadError])
                    {
                        NSLog(@"Create table failed with error : %@ ", [db lastErrorMessage]);
                    }
                    else
                    {
                        NSLog(@"Create table failed with unknown error");
                    }
                }
                else
                {
                    if  (!jobLogsEnbaled)
                    {
                        if ([kTableJobLogsSchema isEqualToString:sqlStatement])
                        {
                            [PlistManager saveJobLogsEnabled:YES];
                            jobLogsEnbaled = YES;
                        }
                    }
                }
            }];
        }
    }
}

/**
 * @name  - (void)createTableIndex
 *
 * @author Shubha S
 *
 * @brief This creates table indexes.
 *
 *
 *
 * @param
 * @return void
 *
 *
 */

- (void)createTableIndex
{
    NSArray *createTableIndexSchemaArray = [self getAllTheSchemaForIndexCreation];
    
    NSString *sqlStatement;
    
    __block BOOL sucessFull = NO;
    
    @autoreleasepool {
        
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        for (int i = 0; i < [createTableIndexSchemaArray count]; i++)
        {
            sqlStatement = [createTableIndexSchemaArray objectAtIndex:i];
        
            [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
                
                sucessFull = [db executeUpdate:sqlStatement];
                
                if (!sucessFull)
                {
                    if ([db hadError])
                    {
                        NSLog(@"Create table index failed with error : %@ ", [db lastErrorMessage]);
                    }
                    else
                    {
                        NSLog(@"Create table index failed with unknown error");
                    }
                }
            }];
        }
    }
}

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

- (void)dropAllTableIndex
{
    NSArray *dropTableIndexSchemaArray = [self getAllTheSchemaForDropIndex];
    
    NSString *sqlStatement;
    
    __block BOOL sucessFull = NO;
    
    @autoreleasepool {
    
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        for (int i = 0; i < [dropTableIndexSchemaArray count]; i++)
        {
            sqlStatement = [dropTableIndexSchemaArray objectAtIndex:i];
        
            [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
                
                sucessFull = [db executeUpdate:sqlStatement];
                
                if (!sucessFull)
                {
                    if ([db hadError])
                    {
                        NSLog(@"Drop table Index failed with error : %@ ", [db lastErrorMessage]);
                    }
                    else
                    {
                        NSLog(@"Drop table Index failed with unknown error ");
                    }
                }
            }];
        }
    }
}

/**
 * @name - (void)insertRecordIntoTable:(NSString*)tableNameOrObjectName andRecords:(NSArray*)records
 *
 * @author Shubha S
 *
 * @brief This method is used to insert multiple records for a table.
 *
 *
 * @param  database object which is of class sqlite3
 * @return void
 *
 */

- (void)insertRecordIntoTable:(NSString*)tableNameOrObjectName andRecords:(NSArray*)records
{
    //Execute query for all the records.here records should be array of dictionaries
    
    for (int i = 0; i < [records count]; i++) {
        
        NSDictionary *fieldValueDictionary = [records objectAtIndex:i];
        
        //Get all the fields of dictionary and form a query
        
        NSArray *listOfField = [fieldValueDictionary allKeys];
        
        NSMutableString *queryFields = [[NSMutableString alloc] init];
        
        for(int j = 0; j < [listOfField count]; j++)
        {
            if(j)
            {
                [queryFields  appendString:@","];
            }
            [queryFields appendFormat:@"'%@'",[listOfField objectAtIndex:j]];
        }
        
        //Get all the value of dictionary and form a query
        
        NSArray *listOfValue = [fieldValueDictionary allValues];
        
        NSMutableString *queryValue = [[NSMutableString alloc] init];
        
        for(int j = 0; j < [listOfValue count]; j++)
        {
            if(j)
            {
                [queryValue  appendString:@","];
            }
            [queryValue appendFormat:@"'%@'",[listOfValue objectAtIndex:j]];
        }
    
        NSString *insertQueryStatement = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)",tableNameOrObjectName,queryFields,queryValue];
        
        
        __block BOOL sucessFull = NO;
        @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            sucessFull = [db executeUpdate:insertQueryStatement];
            
            if (!sucessFull)
            {
                if ([db hadError])
                {
                    SXLogError(@"Insert failed with error : %@ ", [db lastErrorMessage]);
                }
            }
        }];
        }
    }
}

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

- (NSArray*)getAllRecordsForTable:(NSString *)tableNameOrObjectName byConditions:(NSDictionary*)dictionary
  {
    NSArray *recordArray = [[NSArray alloc]init];
    
    NSMutableString *conditionStatement = [[NSMutableString alloc] init];
    
    for (int i = 0; i < [dictionary count] ; i++) {
        
        //Form statement from given condition dictionary
        
        conditionStatement = [[dictionary allKeys] objectAtIndex:i];
        
        [conditionStatement  appendString:@"="];
        
        [conditionStatement appendFormat:@"'%@'",[[dictionary allValues] objectAtIndex:i]];
    }
    
    NSString *queryStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@",tableNameOrObjectName,conditionStatement];
    
      __block BOOL sucessFull = NO;
      @autoreleasepool {
      DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
      
      [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
          
          sucessFull = [db executeUpdate:queryStatement];
          
          if (!sucessFull)
          {
              if ([db hadError])
              {
                  SXLogError(@"Insert failed with error : %@ ", [db lastErrorMessage]);
              }
          }
      }];
      }
      
      return recordArray;
}

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

- (void)doPriorDatabaseConfigurationForMetaSync
{
    if ([self closeDatabase])
    {
        BOOL fileExistAtPath = [[NSFileManager defaultManager] fileExistsAtPath:[[DatabaseManager sharedInstance] primaryDatabasePath]];
        
        if (fileExistAtPath)
        {
           BOOL fileMoved = [FileManager moveFileAtPath:[[DatabaseManager sharedInstance] primaryDatabasePath]
                                                 toPath:[[DatabaseManager sharedInstance] secondaryDatabasePath]];
            
            if (fileMoved)
            {
                NSLog(@" back up file generated for db file");
            }
            else
            {
                NSLog(@" back up file generation failed");
            }
            
            [self removeDb];
            
            [[DatabaseManager sharedInstance] resetDatabasePath];
            
            // Lets create new database file
            [[DatabaseManager sharedInstance] createEditableDatabaseIfNeeded];
            
            [self preInitialSyncDBPreparation];
        }
        else
        {
            NSLog(@"Database is not found on executable path - %@", [[DatabaseManager sharedInstance] primaryDatabasePath]);
        }
    }
    else
    {
        NSLog(@"Unable to close database");
    }
}

/**
 * @name - (void)postMetaSyncDatabaseConfigurationByResult:(BOOL)isConfigurationSuccess *
 * @author Shubha S
 *
 * @brief This method is getting called after datasync operation.
 *
 *
 * @param  bool variable isConfigurationSuccess
 * @return void
 *
 */

- (BOOL)postMetaSyncDatabaseConfigurationByResult:(BOOL)isConfigurationSuccess
{
    if(isConfigurationSuccess)
    {
        return [self doPostMetaSyncDatabaseConfigurationInSuccess];
    }
    else
    {
        return  [self doPostMetaSyncDatabaseConfigurationInFailure];
    }
}

/**
 * @name doPostMetaSyncDatabaseConfigurationInSuccess
 *
 * @author Shubha S
 * @author Vipindas palli
 *
 * @brief This method is getting called after datasync operation.if configuration success.
 *
 *
 * @param
 * @return bool value
 *
 */

- (BOOL)doPostMetaSyncDatabaseConfigurationInSuccess
{
      return NO;
//    DatabaseManager *dbManager = [DatabaseManager sharedInstance];
    /*
    BOOL dataMigrated = NO;
    
    NSString *documentFolderPath = [FileManager getRootPath];
    NSString *secondaryDatabasePath =  [documentFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", kSecondaryDatabaseFileName, kMainDatabaseFileExtension]];
    
//    [self attachDatabaseByName:@"tempsfm"  andPath:[dbManager databasePath]];
    
    BOOL databaseAttached = NO;
    
    if (fileExistAtPath)
    {
        databaseAttached = [self attachDatabaseByName:@"tempsfm"  andPath:secondaryDatabasePath]; // Clear
    }
    
//    [FileManager copyFileFromPath:[dbManager databasePath] toPath:@""];
    
    
    DatabaseManager *dbManager = [DatabaseManager sharedInstance];
    [dbManager close];
    
    [dbManager resetDatabasePath];
    [dbManager open];
    
    if (dataMigrated)
    {
        // lets remove temporary database
        [FileManager deleteFileAtPath:secondaryDatabasePath];
    }
    
    return dataMigrated;
    // Remove TempDatabase
     */
}



/**
 * @name doPostMetaSyncDatabaseConfigurationInFailure
 *
 * @author Shubha S
 * @author Vipindas palli
 *
 * @brief This method is getting called after datasync operation.if configuration fails.
 *
 *
 * @param
 * @return void
 *
 */


- (BOOL)doPostMetaSyncDatabaseConfigurationInFailure
{
      return NO;
//    DatabaseManager *dbManager = [DatabaseManager sharedInstance];

    /*
    //CloseDatabase main
    [self closeDatabase];
    
    // Delete main database file
    [self removeDb];
    
    NSString *documentFolderPath = [FileManager getRootPath];
    
//    [FileManager moveFileAtPath:[dbManager databasePath] toPath:@""];
    
    BOOL fileExistAtPath = [[NSFileManager defaultManager] fileExistsAtPath:secondaryDatabasePath];
    
    if (fileExistAtPath)
    {
        BOOL isDatabaseReplaced = [FileManager moveFileAtPath:secondaryDatabasePath
                                                       toPath:mainDatabasePath];
        
        if (isDatabaseReplaced)
        {
            DatabaseManager *dbManager = [DatabaseManager sharedInstance];
            [dbManager resetDatabasePath];
            [dbManager open];
            
            // lets remove temporary database
            [FileManager deleteFileAtPath:secondaryDatabasePath];
            
            isSuccessful = YES;
        }
        else
        {
            NSLog(@"Unable to perform database Database replacement");
            isSuccessful = NO;
        }
    }
     */
    
   // return isSuccessful;
}

/**
 * @name - (BOOL)attachDatabase:(sqlite3*)database byName:(NSString *)attachmentName andPath:(NSString *)path

 *
 * @author Shubha S
 *
 * @brief This method is used to attach two databases
 *
 *
 * @param database , attachment name and path
 * @return bool
 *
 */

- (BOOL)attachDatabaseByName:(NSString *)attachmentName andPath:(NSString *)path
{
    return NO;
    /*
    SXLogDebug(@" Database ATTACH now ");
    BOOL isSuccess = YES;
    
    DatabaseManager *dbManager = [DatabaseManager sharedInstance];
   
    if ([dbManager sqliteHandle] == nil)
    {
        //Skipping database attachment operation since db is Null pointer
        SXLogDebug(@"[DB] Skipping database attachment operation since db is Null pointer!");
        isSuccess = NO;
    }      // Validating file path and attachment name
//    else if ( (! [StringUtil isValidOrZeroLengthString:path]) || (! [StringUtil isValidOrZeroLengthString:attachmentName]) )
//    {
//        //Skipping database attachment operation since invalid file path or database name
//        SXLogDebug(@"[DB] Skipping database attachment operation since invalid file path or database name!");
//        isSuccess = NO;
//    }
    else
    {
        NSString * attachementQuery = [[NSString alloc] initWithFormat:@"ATTACH DATABASE '%@' AS %@", path, attachmentName];
    
        BOOL sucessFull = NO;
        
        if ([dbManager open])
        {
            sucessFull = [dbManager executeUpdate:attachementQuery];
            
            if (!sucessFull)
            {
                if ([dbManager hadError])
                {
                    SXLogError(@"Attachment failed with error : %@ ", [dbManager lastErrorMessage]);
                }
            }
            else
            {
                 NSLog(@"Attachment successfull: %@", attachmentName);
            }
        }
        
        isSuccess = sucessFull;
    }
    
    return isSuccess;
     */
}

/**
 * @name - (BOOL)detachDatabase:(sqlite3*)database byName:(NSString *)databaseName
 *
 * @author Shubha S
 *
 * @brief This method is used to dettach databases
 *
 *
 * @param database ,database name
 * @return bool
 *
 */

- (BOOL)detachDatabaseByName:(NSString *)databaseName
{
    return NO;/*
    SXLogDebug(@" Database dettaching now ");
    
    DatabaseManager *dbManager = [DatabaseManager sharedInstance];
    
    if ([dbManager sqliteHandle] == nil)
    {
        //Skipping database detachment operation since db is Null pointer
        SXLogDebug(@"[DB] Skipping database detachment operation since db is Null pointer!");
        return NO;
    }
    
    NSString * detachQuery = [NSString stringWithFormat:@"DETACH DATABASE '%@'", databaseName];
    
    BOOL sucessFull = NO;
    
    if ([dbManager open])
    {
        sucessFull = [dbManager executeUpdate:detachQuery];
        
        if (!sucessFull)
        {
            if ([dbManager hadError])
            {
                SXLogError(@"Insert failed with error : %@ ", [dbManager lastErrorMessage]);
            }
        }
        else
        {
            NSLog(@"Dettachment successfull: %@", databaseName);
        }
    }
    
    return sucessFull;
  */
}

/**
 * @name - (void)removeDb
 *
 * @author Shubha S
 *
 * @brief This method is used to remove database.
 *
 *
 * @param 
 * @return void
 *
 */

- (void)removeDb
{
    NSURL *url = [NSURL fileURLWithPath:[[DatabaseManager sharedInstance] primaryDatabasePath]];
    
    [FileManager deleteFileAtPath:[url path]];
    
    [PlistManager saveJobLogsEnabled:NO];
    jobLogsEnbaled = NO;
}

/**
 * @name - (NSArray*)getAllTheSchemaForCreateTable
 *
 * @author Shubha S
 *
 * @brief This method returns sqlstatement to create all the table ina array.
 *
 *
 * @param
 * @return array of query
 *
 */

- (NSArray*)getAllTheSchemaForCreateTable
{
    NSArray *schemaArray = [NSArray arrayWithObjects:kTableJobLogsSchema,kTableAttachmentErrorSchema,kTableAttachmentsSchema,kTableBusinessRuleSchema,kTableChatterPostDetailsSchema,kTableContactImageSchema,kTableDocumentSchema,kTableDocumentTemplateDetailSchema,kTableDocumentTemplateSchema,kTableEventLocalIdsSchema,kTableInternetConflictsSchema,kTableLinkedSFMProcessSchema,kTableLocalEventUpdateSchema,kTableMetaSyncDueSchema,kTableMetaSyncStatusSchema,kTableMobileDeviceSettingsSchema,kTableMobileDeviceTagsSchema,kTableModifiedRecordsSchema,kTableObjectNameFieldValueSchema,kTableOnDemandDownloadSchema,kTableProcessBusinessRuleSchema,kTableProductImageSchema,kTableRTDpPickListSchema,kTableServiceReportLogoSchema,kTableSFAttachmentTrailerSchema,kTableSFChildRelationshipSchema,kTableSFDataTrailerSchema,kTableSFDataTrailerTempSchema,kTableSFExpressionComponentSchema,kTableSFExpressionSchema,kTableSFMSearchFieldSchema,kTableSFMSearchFilterCriteriaSchema,kTableSFMSearchProcessSchema,kTableSFNamedSearchComponentSchema,kTableSFNamedSearchFiltersSchema,kTableSFNamedSearchSchema, kTableSFObjectFieldSchema,kTableSFObjectMappingComponentSchema,kTableSFObjectMappingSchema,kTableSFObjectSchema,kTableOPDocHtmlDataSchema,kTableOPDocSignatureDataSchema,kTableSFPickListSchema,kTableSFProcessComponentSchema,kTableSFProcessSchema,kTableSFProcessTestSchema,kTableSFRecordTypeSchema,kTableSFReferenceToSchema,kTableSFRequiredPdfSchema,kTableSFRequiredSignatureSchema,kTableSFSearchObjectsSchema,kTableSFSignatureDataSchema,kTableSFWizardComponentSchema,kTableSFWizardSchema,kTableSourceUpdateObjectSchema,kTableSourceUpdateSchema,kTableStaticResourceSchema,kTableSummaryPDFSchema,kTableUserGPSLogSchema,kTableSYNCErrorConflictSchema,kTableSYNCHistorySchema,kTableSyncRecordsHeapSchema,kTableTroubleshootDataSchema,kTableUserImagesSchema,kTableRecentsSchema,kTableDataPurgeHeap,nil];
    
    return schemaArray;
}

/**
 * @name - (NSArray*)getAllTheSchemaForIndexCreation
 *
 * @author Shubha S
 *
 * @brief This method returns sqlstatement to create all the index in a array.
 *
 *
 * @param
 * @return array of query
 *
 */


- (NSArray*)getAllTheSchemaForIndexCreation
{
    NSArray *listOfIndexCreationSchema = [NSArray arrayWithObjects:kTableIndexSyncRecordHeapIndex,
                                          kTableIndexSyncRecordHeapIndex2,
                                          kTableIndexSyncRecordHeapIndex3,
                                          kTableIndexSyncRecordHeapIndex4,
                                          kTableIndexSFObjectFieldIndex,
                                          kTableIndexSFObjectFieldIndex2,
                                          kTableIndexRTIndex,
                                          kTableIndexSFNamedSearchIndex,
                                          kTableIndexSFNamedSearchComponentIndex,
                                          kTableIndexSFChildRelationshipIndex1,
                                          kTableIndexSFChildRelationshipIndex2,
                                          kTableIndexProcessBusinessRuleIndex,
                                          kTableIndexBusinessRuleIndex,nil];
    return listOfIndexCreationSchema;
    
}

/**
 * @name - (NSArray*)getAllTheSchemaForDropIndex
 *
 * @author Shubha S
 *
 * @brief This method returns sqlstatement to drop all the index created, in a array.
 *
 *
 * @param
 * @return array of query
 *
 */

- (NSArray*)getAllTheSchemaForDropIndex
{
    NSArray *listOfDropIndexSchema = [NSArray arrayWithObjects:kTableDropIndexSyncRecordHeapIndex,
                                          kTableDropIndexSyncRecordHeapIndex2,
                                          kTableDropIndexSyncRecordHeapIndex3,
                                          kTableDropIndexSyncRecordHeapIndex4,
                                          kTableDropIndexSFObjectFieldIndex,
                                          kTableDropIndexSFObjectFieldIndex2,
                                          kTableDropIndexRTIndex,
                                          kTableDropIndexSFNamedSearchIndex,
                                          kTableDropIndexSFNamedSearchComponentIndex,
                                          kTableDropIndexSFChildRelationshipIndex1,
                                          kTableDropIndexSFChildRelationshipIndex2,
                                          kTableDropIndexProcessBusinessRuleIndex,
                                          kTableDropIndexBusinessRuleIndex,nil];
    return listOfDropIndexSchema;
}

- (NSString *)getSqliteDataTypeForSalesforceType:(NSString *)salesforceType {
    
    NSString *dataType = salesforceType;
    
    if (NSOrderedSame == [dataType caseInsensitiveCompare:kSfDTBoolean])
    {
        return @"BOOL";
    }
    else if (   (NSOrderedSame == [dataType caseInsensitiveCompare:kSfDTCurrency])
             || (NSOrderedSame == [dataType caseInsensitiveCompare:kSfDTDouble])
             || (NSOrderedSame == [dataType caseInsensitiveCompare:kSfDTPercent]))
    {
        return @"DOUBLE";
    }
    else if (NSOrderedSame == [dataType caseInsensitiveCompare:kSfDTInteger])
    {
        return @"INTEGER";
    }
    else if (   (NSOrderedSame == [dataType caseInsensitiveCompare:kSfDTDate])
             || (NSOrderedSame == [dataType caseInsensitiveCompare:kSfDTDateTime]))
    {
        return @"DATETIME";
    }
    else if (NSOrderedSame == [dataType caseInsensitiveCompare:kSfDTTextArea])
    {
        return @"VARCHAR";
    }
    else
    {
        return @"TEXT";
    }
}

- (void)preInitialSyncDBPreparation {
    
    [self performDatabaseInitialConfigurationForNewUser];
}


#pragma - Config Sync Data Migration Implementation


- (BOOL)migrateDataFromOldDatabaseToNewDatabase
{
    
    /**
     * 1. Filter tables
     * 2. Filter Schema
     * 3. Copy eligible data to new data base
     *
     *
     */
    
    @autoreleasepool
    {
        BOOL dataMigrated = NO;
        
        NSMutableDictionary * newSchemaDict = [NSMutableDictionary dictionaryWithCapacity:0];
        NSMutableDictionary * oldSchemaDict = [NSMutableDictionary dictionaryWithCapacity:0];
        
        SyncManager *manager = [SyncManager sharedInstance];
        NSDictionary *migrationDataDictionary = [manager dataSetForDataMigration];
        
        NSMutableArray * allNewTableNames = [self listOfObjectNames];
        
    /**
     *
     *  Filter tables
     *  Compare old and new tables by name.
     *  If matching found copy them to next level of comparison - schema level of comparison
     *
     */
        
        for (NSString * table in allNewTableNames)
        {
            NSDictionary * oldSchemaDictionary = [migrationDataDictionary objectForKey:table];
            NSDictionary * newSchemaDictionary = [[self fieldNameAndTypeForObject:table] objectForKey:table];
            
            if (   (oldSchemaDictionary != nil)
                && ([oldSchemaDictionary count] > 0)
                && (newSchemaDictionary != nil)
                && ([newSchemaDictionary count] > 0))
            {
                [newSchemaDict setObject:newSchemaDictionary forKey:table];
                [oldSchemaDict setObject:oldSchemaDictionary forKey:table];
            }
        }
        
        if ([oldSchemaDict count] > 0)
        {
            dataMigrated = [self migrateDataAfterCompareSchema:newSchemaDict withOldSchema:oldSchemaDict];
        }
        else //If no records exists in the table, set success flag as true.
        {
            dataMigrated = YES;
        }
        return dataMigrated;
    }
}

- (NSString *)fieldNamesIntersectionOfOldSchema:(NSDictionary *)oldSchema andNewSchema:(NSDictionary *)newSchema
{
    NSMutableString * intersectedFields = [[NSMutableString alloc] initWithCapacity:0];
    @autoreleasepool
    {
        for (NSString * fieldName in oldSchema)
        {
            NSString * oldDataType = [oldSchema objectForKey:fieldName];
            NSString * newDataType = [newSchema objectForKey:fieldName];
            
            if ((newDataType != nil) && [newDataType length] > 0)
            {
                if ([oldDataType isEqualToString:newDataType])
                {
                    if ([intersectedFields length] > 0)
                    {
                        [intersectedFields appendString:@", "];
                        [intersectedFields appendString:fieldName];
                    }
                    else
                    {
                        [intersectedFields appendString:fieldName];
                    }
                }
            }
        }
    }
    return intersectedFields;
}


- (BOOL)migrateDataAfterCompareSchema:(NSDictionary *)newSchema withOldSchema:(NSDictionary *)oldSchema
{
    BOOL dataMigratedSuccessfully = NO;
    
    return dataMigratedSuccessfully;
    /*

    DatabaseManager *databaseManger = [DatabaseManager sharedInstance];
    
    @autoreleasepool
    {
        for (NSString * tableName in oldSchema)
        {
            NSDictionary * oldSchemaForTable = [oldSchema objectForKey:tableName];
            NSDictionary * newSchemaForTable = [newSchema objectForKey:tableName];
            
            NSString * compactableFields =  [self fieldNamesIntersectionOfOldSchema:oldSchemaForTable
                                                                       andNewSchema:newSchemaForTable];
            if ([compactableFields length] > 0)
            {
                NSString * dataMigrationQuery = [NSString stringWithFormat:@"INSERT INTO '%@' (%@) SELECT %@ FROM %@.'%@'", tableName,compactableFields, compactableFields, @"tempsfm", tableName];
                
                if ([databaseManger open])
                {
                    BOOL isTableDataMigrated =  [databaseManger executeUpdate:dataMigrationQuery];
                    dataMigratedSuccessfully = isTableDataMigrated;
                    
                    if (! isTableDataMigrated)
                    {
                        NSLog(@" Data migration failed - details :  error : %@ - query : %@", [databaseManger lastErrorMessage],dataMigrationQuery);
                        break;
                    }
                }
                else
                {
                    NSLog(@" Data migration failed - unable to open database - possible error %@", [databaseManger lastErrorMessage]);
                    dataMigratedSuccessfully = NO;
                    break;
                }
            }
        }
    }
    return dataMigratedSuccessfully;
    */
}


- (NSMutableArray *)listOfObjectNames
{
    return nil;
    /*
    
    static NSString *fieldName = @"objectName";
    NSArray  *fieldNames = [NSArray arrayWithObjects:fieldName, nil];
    
    DBRequestSelect *selectQuery = [[DBRequestSelect alloc] initWithTableName:kSFObject andFieldNames:fieldNames];
    [selectQuery setDistinctRowsOnly];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];

    NSMutableArray *objectNames = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (didOpen)
    {
        NSString * query = [selectQuery query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next])
        {
            NSDictionary * dict = [resultSet resultDictionary];
            
            if ( (dict != nil) && ([dict count] > 0))
            {
                NSString *objectName = [dict valueForKey:fieldName];
                
                if (![objectName isKindOfClass:[NSNull class]]) {
                    
                    if ([[objectName lowercaseString] isEqualToString:@"pricebook2"])
                    {
                        objectName = @"Pricebook2";
                    }
                    else if ([[objectName lowercaseString] isEqualToString:@"pricebookentry"])
                    {
                        objectName = @"PricebookEntry";
                    }
                    
                    [objectNames addObject:objectName];
                }
            }
        }
    }
    
    return objectNames;
     */
}


- (NSDictionary *)fieldNameAndTypeForObject:(NSString *)objectName
{
    return [DataMigrationHelper populateTableSchemaForTables:@[objectName]];
}

- (BOOL)isLogsEnabled
{
   return jobLogsEnbaled;
}

@end
