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
#import "SMDatabase.h"
#import "OpDocHelper.h"


#import "DatabaseIndexManager.h"
@interface DatabaseConfigurationManager ()
{
    BOOL    jobLogsEnbaled;
}

@property (nonatomic, strong) NSDictionary *dataSetForMigration;

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

@synthesize dataSetForMigration;

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

- (NSArray*)getAllTheSchemaForIndexCreation {
    return nil;
}

- (NSArray*)getAllTheSchemaForDropIndex {
    return nil;
}

/**
 * @name  - (void)performDatabaseVacuumization;
 *
 * @author Shubha S
 *
 * @brief this rebuilds the entire database
  // PCRD-220
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
                //NSLog(@"Vacuum failed with error : %@ ", [db lastErrorMessage]);
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
    
    [queue closeDatabase];
  
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
    NSLog(@"Database config pre setup");
    
    /*
     Added below code to fix 016652 issue.
     Modfified By: Rahman
     Mod Date: June-16-2015.
     */
    [[OpDocHelper sharedManager] clearOpDocHTMLAndSignatureFilesOnReset];
        

    if ( [self closeDatabase])
    {
        NSLog(@"Closed database");
    }
    else
    {
        NSLog(@"Unable to close database - but removing file");
    }
    
    if ([FileManager deleteFileAtPath:[FileManager getAttachmentsSubDirectoryPath]])
    {
        [FileManager createFileAtPath:[FileManager getAttachmentsSubDirectoryPath]];
    }
    
    if ([FileManager deleteFileAtPath:[FileManager getProductManualSubDirectoryPath]])
    {
        [FileManager createFileAtPath:[FileManager getProductManualSubDirectoryPath]];
    }
    
    if ([FileManager deleteFileAtPath:[FileManager getTroubleshootingSubDirectoryPath]])
    {
        [FileManager createFileAtPath:[FileManager getTroubleshootingSubDirectoryPath]];
    }
    
    
    // 27690
    [FileManager recopyStaticResourcesFromBundle];
    
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
            NSLog(@"Invalid db skipping config");
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
            NSLog(@"db error sync : %d - %@", syncResult, [NSString stringWithUTF8String:errMessageSynch]);
        }

        if (journalResult != SQLITE_OK)
        {
            NSLog(@"db error jorunal mode : %d - %@", journalResult, [NSString stringWithUTF8String:errMessageJournalMod]);
        }

        if (cacheSizeResult != SQLITE_OK)
        {
            NSLog(@"db error cache size : %d - %@", journalResult, [NSString stringWithUTF8String:errMessageJournalMod]);
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
                    //NSLog(@"Insert failed with error : %@ ", [db lastErrorMessage]);
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
                  //NSLog(@"Insert failed with error : %@ ", [db lastErrorMessage]);
              }
          }
      }];
      }
      
      return recordArray;
}

/**
 * @name doPriorDatabaseConfigurationForMetaSync
 *
 * @author Shubha S
 * @author Vipindas Palli
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
        
        BOOL tempDatabaseFileExistAtPath = [[NSFileManager defaultManager] fileExistsAtPath:[[DatabaseManager sharedInstance] secondaryDatabasePath]];
        
        if (tempDatabaseFileExistAtPath)
        {
            // Found old back up file file already exist, lets remove it
            NSURL *url = [NSURL fileURLWithPath:[[DatabaseManager sharedInstance] secondaryDatabasePath]];
            BOOL fileRemoved = [FileManager deleteFileAtPath:[url path]];
           
            if (fileRemoved)
            {
                NSLog(@"Old back up file removed");
            }
            else
            {
                NSLog(@"Old back up file removal failed");
            }
        }
        
        if (fileExistAtPath)
        {
           BOOL fileMoved = [FileManager moveFileAtPath:[[DatabaseManager sharedInstance] primaryDatabasePath]
                                                 toPath:[[DatabaseManager sharedInstance] secondaryDatabasePath]];
            
            if (fileMoved)
            {
                NSLog(@"Back up file generated for db file");
            }
            else
            {
                NSLog(@"Back up file generation failed");
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
    BOOL dataMigrated = NO;
    
    /*
     1. Make attachment Database connection
     2. Migrate data from old db to new db
     3. Dettach database connection
     4. On success remove temporary db
     */

    BOOL fileExistAtPath = [[NSFileManager defaultManager] fileExistsAtPath:[[DatabaseManager sharedInstance] secondaryDatabasePath]];
    
    BOOL databaseAttached = NO;
    
    if (fileExistAtPath)
    {
        databaseAttached = [self attachDatabaseByName:[[DatabaseManager sharedInstance] databaseAttachmentName]
                                              andPath:[[DatabaseManager sharedInstance] secondaryDatabasePath]];
        
        if (databaseAttached)
        {
            dataMigrated = [self migrateDataFromOldDatabaseToNewDatabase];
            
            [self detachDatabaseByName:[[DatabaseManager sharedInstance] databaseAttachmentName]];
            
            DatabaseManager *dbManager = [DatabaseManager sharedInstance];
            DatabaseQueue *dbQueue = [dbManager databaseQueue];
            [dbQueue closeDatabase];
            [dbManager resetDatabasePath];
        }
        else
        {
            NSLog(@"db attachment failure; db migration too");
        }
    }
    
    if (dataMigrated)
    {
        [self updateStaticTableDataForNewDataBase];
        
        //Create all indexes previously created. which is deleted as part of database migration
        [[DatabaseIndexManager sharedInstance] createAllIndices];
        
        // lets remove temporary database
        [FileManager deleteFileAtPath:[[DatabaseManager sharedInstance] secondaryDatabasePath]];
        [PlistManager saveJobLogsEnabled:YES];
        SXLogInfo(@"data migrated successfully");
    }
    else
    {
        NSLog(@"db migration failure, job log disabled");
        [PlistManager saveJobLogsEnabled:NO];
    }
    
    return dataMigrated;
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
    BOOL isSuccessful = NO;
    
    //Close main Database
    if ([self closeDatabase])
    {
        NSLog(@"db closed now");
    }
    else
    {
        NSLog(@"Unable to close db");
    }
    
    // Delete main database file
    [self removeDb];
    
    // Reset main database path
    [[DatabaseManager sharedInstance] resetDatabasePath];
    
    BOOL fileExistAtPath = [[NSFileManager defaultManager] fileExistsAtPath:[[DatabaseManager sharedInstance] secondaryDatabasePath]];
    
    // Verify back-up database file existence
    if (fileExistAtPath)
    {
        BOOL fileMoved = [FileManager moveFileAtPath:[[DatabaseManager sharedInstance] secondaryDatabasePath]
                                              toPath:[[DatabaseManager sharedInstance] primaryDatabasePath]];
        if (fileMoved)
        {
            fileExistAtPath = NO;
            
            isSuccessful = YES;
            
            fileExistAtPath = [[NSFileManager defaultManager] fileExistsAtPath:[[DatabaseManager sharedInstance] secondaryDatabasePath]];
            
            if (fileExistAtPath)
            {
                [FileManager  deleteFileAtPath:[[DatabaseManager sharedInstance] secondaryDatabasePath]];

               // NSLog(@"After restoring back up db destroyed");
            }
            else
            {
                NSLog(@"After restoring back up db is not existing");
            }
        }
        else
        {
            NSLog(@"Unable restore db from back up");
        }
    }
    else
    {
        NSLog(@"db back up is not found");
    }
    
    if (isSuccessful)
    {
        [PlistManager saveJobLogsEnabled:YES];
    }
    else
    {
        [PlistManager saveJobLogsEnabled:NO];
    }

    return isSuccessful;
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
    BOOL isSuccess = NO;
    
    DatabaseQueue *dbQueue = [[DatabaseManager sharedInstance] databaseQueue];
   
    if (     ([dbQueue database] == nil)
          || ([[dbQueue database] sqliteHandle] == nil))
    {
        //Skipping database attachment operation since db is Null pointer
        NSLog(@"Skipping database attachment operation since db is Null pointer!");
        isSuccess = NO;
    }
    else
    {
      if ((![StringUtil isStringEmpty:attachmentName]) && (![StringUtil isStringEmpty:path]))
      {
          
          //const char* dbAttachQuery = [[NSString stringWithFormat:@"ATTACH DATABASE '%@' AS encrypted KEY '%@';", encryptedDataBasePath, [self dbSecretKey]] UTF8String];
          
            NSString * attachementQuery = [[NSString alloc] initWithFormat:@"ATTACH DATABASE '%@' AS %@ KEY '%s';", path, attachmentName, [[SMDatabase dataBaseKey] UTF8String]];

            char * errMessage = nil;

            int  result =  sqlite3_exec([[dbQueue database] sqliteHandle],
                                        [attachementQuery UTF8String],
                                        NULL,
                                        NULL,
                                        &errMessage);

            if (result == SQLITE_OK)
            {
                NSLog(@"db Attachment created with name %@", attachmentName);
                isSuccess = YES;
            }
            else
            {
                NSLog(@"Attachment failed with error : : %d - %@", result, [NSString stringWithUTF8String:errMessage]);
                isSuccess = NO;
            }
       }
       else
       {
           NSLog(@"Skipping db attachment since attachment name or path is invalid");
       }
    }
    
    return isSuccess;
}

/**
 * @name detachDatabaseByName:(NSString *)databaseName
 *
 * @author Shubha S
 *
 * @brief This method is used to dettach database
 *
 *
 * @param database database name
 * @return bool
 *
 */

- (BOOL)detachDatabaseByName:(NSString *)attachmentName
{
    BOOL isSuccess = NO;
    
    DatabaseQueue *dbQueue = [[DatabaseManager sharedInstance] databaseQueue];
    
    if (   ([dbQueue database] == nil)
        || ([[dbQueue database] sqliteHandle] == nil))
    {
        //Skipping database detachment operation since db is Null pointer
        NSLog(@"Skipping database dettachment operation since db is Null pointer!");
        isSuccess = NO;
    }
    else
    {
        if (![StringUtil isStringEmpty:attachmentName])
        {
            NSString * attachementQuery = [[NSString alloc] initWithFormat:@"DETACH DATABASE '%@'", attachmentName];
            
            char * errMessage = nil;
            
            int  result =  sqlite3_exec([[dbQueue database] sqliteHandle],
                                        [attachementQuery UTF8String],
                                        NULL,
                                        NULL,
                                        &errMessage);
            
            if (result == SQLITE_OK)
            {
               NSLog(@"db dettachment completed");
               isSuccess = YES;
            }
            else
            {
                NSLog(@"db dettachment failed with error : %d - %@", result, [NSString stringWithUTF8String:errMessage]);
                isSuccess = NO;
            }
        }
        else
        {
            NSLog(@"Skipping db detachment since invalid attachment name");
        }
    }
    return isSuccess;
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
    NSArray *schemaArray = [NSArray arrayWithObjects:kTableJobLogsSchema,kTableAttachmentErrorSchema,kTableAttachmentsSchema,kTableBusinessRuleSchema,kTableChatterPostDetailsSchema,kTableContactImageSchema,kTableDocumentSchema,kTableDocumentTemplateDetailSchema,kTableDocumentTemplateSchema,kTableEventLocalIdsSchema,kTableInternetConflictsSchema,kTableLinkedSFMProcessSchema,kTableLocalEventUpdateSchema,kTableMetaSyncDueSchema,kTableMetaSyncStatusSchema,kTableMobileDeviceSettingsSchema,kTableMobileDeviceTagsSchema,kTableModifiedRecordsSchema,kTableObjectNameFieldValueSchema,kTableOnDemandDownloadSchema,kTableProcessBusinessRuleSchema,kTableProductImageDataSchema,kTableRTDpPickListSchema,kTableServiceReportLogoSchema,kTableSFAttachmentTrailerSchema,kTableSFChildRelationshipSchema,kTableSFDataTrailerSchema,kTableSFDataTrailerTempSchema,kTableSFExpressionComponentSchema,kTableSFExpressionSchema,kTableSFMSearchFieldSchema,kTableSFMSearchFilterCriteriaSchema,kTableSFMSearchProcessSchema,kTableSFNamedSearchComponentSchema,kTableSFNamedSearchFiltersSchema,kTableSFNamedSearchSchema, kTableSFObjectFieldSchema,kTableSFObjectMappingComponentSchema,kTableSFObjectMappingSchema,kTableSFObjectSchema,kTableOPDocHtmlDataSchema,kTableOPDocSignatureDataSchema,kTableSFPickListSchema,kTableSFProcessComponentSchema,kTableSFProcessSchema,kTableSFProcessTestSchema,kTableSFRecordTypeSchema,kTableSFReferenceToSchema,kTableSFRequiredPdfSchema,kTableSFRequiredSignatureSchema,kTableSFSearchObjectsSchema,kTableSFSignatureDataSchema,kTableSFWizardComponentSchema,kTableSFWizardSchema,kTableSourceUpdateObjectSchema,kTableSourceUpdateSchema,kTableStaticResourceSchema,kTableSummaryPDFSchema,kTableUserGPSLogSchema,kTableSYNCErrorConflictSchema,kTableSYNCHistorySchema,kTableSyncRecordsHeapSchema,kTableTroubleshootDataSchema,kTableUserImagesSchema,kTableRecentsSchema,kTableDataPurgeHeap,kProductManualSchema,kTableAttachmentLocalSchema,kTableSFMCustomActionParams,kTableSFMCustomActionRequestParams,KTableRecordName,KTableTranslations,KTableFieldDescribe,KTableConfiguration,KTableObjectDescribe,KTableInstallBaseObject,KTableClientSyncLogTransient, kTableDescribeLayout, nil];
    
    return schemaArray;
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
        
        NSDictionary *migrationDataDictionary = [self dataSetForDataMigration];
        
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
                
                //NSLog(@" Schema matching : %@ ", table);
            }
            else
            {
               // NSLog(@"Schema not matching : %@ Details old : %d  == %d ", table, [oldSchemaDictionary count], [newSchemaDictionary count]);
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
                else
                {
                    //NSLog(@"Data type not matching  fieldName - %@ => %@", oldDataType, newDataType);
                }
            }
            else
            {
               // NSLog(@"New Data type for fieldName - %@ => %@", oldDataType, newDataType);
            }
        }
    }
    return intersectedFields;
}


- (BOOL)migrateDataAfterCompareSchema:(NSDictionary *)newSchema withOldSchema:(NSDictionary *)oldSchema
{
    __block  BOOL dataMigratedSuccessfully = NO;
    
    @autoreleasepool
    {
        DatabaseQueue *dbQueue = [[DatabaseManager sharedInstance] databaseQueue];
        
        for (NSString * tableName in oldSchema)
        {
            NSDictionary * oldSchemaForTable = [oldSchema objectForKey:tableName];
            NSDictionary * newSchemaForTable = [newSchema objectForKey:tableName];
            
            NSString * compactableFields =  [self fieldNamesIntersectionOfOldSchema:oldSchemaForTable
                                                                       andNewSchema:newSchemaForTable];
            
            if ([compactableFields length] > 0)
            {
                NSString * dataMigrationQuery = [NSString stringWithFormat:@"INSERT INTO '%@' (%@) SELECT %@ FROM %@.'%@'", tableName, compactableFields, compactableFields, [[DatabaseManager sharedInstance] databaseAttachmentName], tableName];

                [dbQueue inTransaction:^(SMDatabase *db, BOOL *rollback){

                    BOOL isTableDataMigrated = [db executeUpdate:dataMigrationQuery];

                    dataMigratedSuccessfully = isTableDataMigrated;
                    
                    //NSLog(@"tbl : %@ -- %d", tableName, isTableDataMigrated);

                    if (! isTableDataMigrated)
                    {
                        NSLog(@"Data migration failed - details :  error : %@ - query : %@", [db lastErrorMessage],dataMigrationQuery);
                    }
                }];
            }
            else
            {
                NSLog(@"Non Compactable : %@ -- %@", oldSchemaForTable, newSchemaForTable);
            }
        }
    }

    return dataMigratedSuccessfully;
}


- (NSMutableArray *)listOfObjectNames
{
    static NSString *fieldName = @"objectName";

    NSArray  *fieldNames = [NSArray arrayWithObjects:fieldName, nil];
    
    DBRequestSelect *selectQuery = [[DBRequestSelect alloc] initWithTableName:kSFObject andFieldNames:fieldNames];
    [selectQuery setDistinctRowsOnly];
    
    DatabaseQueue *dbQueue = [[DatabaseManager sharedInstance] databaseQueue];
    
    NSMutableArray *objectNames = [[NSMutableArray alloc] initWithCapacity:0];
    
    [dbQueue inTransaction:^(SMDatabase *db, BOOL *rollback){
        
        NSString * query = [selectQuery query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
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
    }];
    
    NSArray *staticTables =  [DataMigrationHelper fetchAllStaticTables];
    [objectNames addObjectsFromArray:staticTables];
    return objectNames;
}



- (BOOL)isLogsEnabled
{
   return jobLogsEnbaled;
}

#pragma mark - Data Migration

- (NSDictionary *)fieldNameAndTypeForObject:(NSString *)objectName
{
    return [DataMigrationHelper populateTableSchemaForTables:@[objectName]];
}


- (void)populateDataForMigration
{
    self.dataSetForMigration = [DataMigrationHelper fetchMigrationMetaDataFromOldDatabase];
}

- (NSDictionary *)dataSetForDataMigration
{
    return self.dataSetForMigration;
}

- (void)resetDataMigration
{
    self.dataSetForMigration = nil;
}

- (void)updateStaticTableDataForNewDataBase
{
    @autoreleasepool {
        NSSet *txnTables = [self getAllTransactionTable];
        
        for (NSString *objectName in txnTables) {
            
            if (![DataMigrationHelper checkObjectPermission:objectName]) {
                [self deleteRecordsFromStaticTableByObjectName:objectName];
            }
        }
        txnTables = nil;
    }
}

- (NSSet *)getAllTransactionTable
{
    NSMutableSet *allTables = [NSMutableSet setWithArray:[self.dataSetForMigration allKeys]];
    [allTables minusSet:[NSSet setWithArray:[DataMigrationHelper fetchAllStaticTables]]];
    return allTables;
}

- (void)deleteRecordsFromStaticTableByObjectName:(NSString *)objectName
{
    [self executeQuertForObject:objectName tableName:@"RecentRecord"];
    [self executeQuertForObject:objectName tableName:kSyncErrorConflictTableName];
}

- (void)executeQuertForObject:(NSString *)objectName tableName:(NSString *)tableName
{
    @autoreleasepool {
        DatabaseQueue *dbQueue = [[DatabaseManager sharedInstance] databaseQueue];
        
        __block NSString * deleteQuery = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE %@ = '%@'", tableName, kobjectName, objectName];
        
        [dbQueue inTransaction:^(SMDatabase *db, BOOL *rollback){
            
            BOOL result = [db executeUpdate:deleteQuery];
            
            if (! result)
            {
                NSLog(@"Delete query failed = %@", deleteQuery);
            }
            deleteQuery = nil;
        }];
    }
}
@end
