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

@interface DatabaseConfigurationManager ()

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
    
    DatabaseManager *dbManager = [DatabaseManager sharedInstance];
    
    BOOL sucessFull = NO;
    
    if ([dbManager open])
    {
       sucessFull = [dbManager executeUpdate:queryStatement];
        
        if (!sucessFull)
        {
            if ([dbManager hadError])
            {
                SXLogError(@"Vacuum failed with error : %@ ", [dbManager lastErrorMessage]);
            }
        }
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
    DatabaseManager *dbManager = [DatabaseManager sharedInstance];
    
    BOOL sucessFull = NO;
    
    if ([dbManager open])
    {
        sucessFull = [dbManager close];

        if (!sucessFull)
        {
            if ([dbManager hadError])
            {
                SXLogError(@"Database closing failed with error : %@ ", [dbManager lastErrorMessage]);
            }
        }
    }

    return sucessFull;
}

/**
 * @name  - (void)PerformDatabaseConfigurationForSwitchUser
 * @author Shubha S
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
    [self closeDatabase];
    [self removeDb];
}

#pragma mark - private method

/**
 * @name  - (void)resetConfiguration
 * @author Shubha S
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

    DatabaseManager *dbManager = [DatabaseManager sharedInstance];
    
    if ([dbManager open])
    {
        
        BOOL  pageSizeResult = YES;
        //BOOL  pageSizeResult =  [dbManager executeUpdate:@"PRAGMA page_size = 4096"];
        
        //BOOL  pageSizeResult =  [dbManager executeUpdate:@"PRAGMA page_size = 4096" withArgumentsInArray:nil];
    
        SQLResultSet * resultSet = [dbManager executeQuery:@"PRAGMA page_size = 4096", nil];
        
        if (!pageSizeResult)
        {
            if ([dbManager hadError])
            {
                SXLogError(@"page_size Error: %@ ", [dbManager lastErrorMessage]);
            }
        }
        
        BOOL  syncResult     =  YES;// [dbManager executeUpdate:@"PRAGMA synchronous = OFF"];
        
        resultSet = [dbManager executeQuery:@"PRAGMA synchronous = OFF"];
        
        if (!syncResult)
        {
            if ([dbManager hadError])
            {
                SXLogError(@"synchronous Error : %@ ", [dbManager lastErrorMessage]);
            }
        }
        
        BOOL  journalResult  =  YES;//[dbManager executeUpdate:@"PRAGMA journal_mode = MEMORY"];
        
        resultSet = [dbManager executeQuery:@"PRAGMA synchronous = OFF"];
        
        if (!journalResult)
        {
            if ([dbManager hadError])
            {
                SXLogError(@"journal_mode Error: %@ ", [dbManager lastErrorMessage]);
            }
        }
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
    
    for (int i = 0; i < [tableSchemaArray count]; i++)
    {
        DatabaseManager *dbManager = [DatabaseManager sharedInstance];
        
        sqlStatement = [tableSchemaArray objectAtIndex:i];
        
        BOOL sucessFull = NO;
        
        if ([dbManager open])
        {
            sucessFull = [dbManager executeUpdate:sqlStatement];
            
            if (!sucessFull)
            {
                if ([dbManager hadError])
                {
                    SXLogError(@"Create table failed with error : %@ ", [dbManager lastErrorMessage]);
                }
            }
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
    
    for (int i = 0; i < [createTableIndexSchemaArray count]; i++)
    {
        DatabaseManager *dbManager = [DatabaseManager sharedInstance];
        
        sqlStatement = [createTableIndexSchemaArray objectAtIndex:i];
        
        BOOL sucessFull = NO;
        
        if ([dbManager open])
        {
            sucessFull = [dbManager executeUpdate:sqlStatement];
            
            if (!sucessFull)
            {
                if ([dbManager hadError])
                {
                    SXLogError(@"Create table index failed with error : %@ ", [dbManager lastErrorMessage]);
                }
            }
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
    //To Do : pass query to database manager
    
    NSArray *dropTableIndexSchemaArray = [self getAllTheSchemaForDropIndex];
    
    NSString *sqlStatement;
    
    for (int i = 0; i < [dropTableIndexSchemaArray count]; i++)
    {
        DatabaseManager *dbManager = [DatabaseManager sharedInstance];
        
        sqlStatement = [dropTableIndexSchemaArray objectAtIndex:i];
        
        BOOL sucessFull = NO;
        
        if ([dbManager open])
        {
            sucessFull = [dbManager executeUpdate:sqlStatement];
            
            if (!sucessFull)
            {
                if ([dbManager hadError])
                {
                    SXLogError(@"Drop Table Index failed : %@ ", [dbManager lastErrorMessage]);
                }
            }
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
                [queryFields  appendString:@","];
            [queryFields appendFormat:@"'%@'",[listOfField objectAtIndex:j]];
        }
        
        //Get all the value of dictionary and form a query
        
        NSArray *listOfValue = [fieldValueDictionary allValues];
        
        NSMutableString *queryValue = [[NSMutableString alloc] init];
        
        for(int j = 0; j < [listOfValue count]; j++)
        {
            if(j)
                [queryValue  appendString:@","];
            [queryValue appendFormat:@"'%@'",[listOfValue objectAtIndex:j]];
        }
    
        NSString *insertQueryStatement = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)",tableNameOrObjectName,queryFields,queryValue];
        
        DatabaseManager *dbManager = [DatabaseManager sharedInstance];
        
        BOOL sucessFull = NO;
        
        if ([dbManager open])
        {
            sucessFull = [dbManager executeUpdate:insertQueryStatement];
            
            if (!sucessFull)
            {
                if ([dbManager hadError])
                {
                    SXLogError(@"Insert failed with error : %@ ", [dbManager lastErrorMessage]);
                }
            }
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
    
    DatabaseManager *dbManager = [DatabaseManager sharedInstance];
    
    BOOL sucessFull = NO;
    
    if ([dbManager open])
    {
        sucessFull = [dbManager executeUpdate:queryStatement];
        
        if (!sucessFull)
        {
            if ([dbManager hadError])
            {
                SXLogError(@"Insert failed with error : %@ ", [dbManager lastErrorMessage]);
            }
        }
    }
    
    return recordArray;
}

/**
 * @name - (void)preMetaSyncDatabaseOperation
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

- (void)preMetaSyncDatabaseOperation
{
    [self closeDatabase];
    
    //TO Do::
    //file manager copyFileFromPath method
    
    //Copy existing file from temp
    
    [self performDatabaseInitialConfigurationForNewUser];
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

- (void)postMetaSyncDatabaseConfigurationByResult:(BOOL)isConfigurationSuccess
{
    if(isConfigurationSuccess)
    {
        [self doPostMetaSyncDatabaseConfigurationInSuccess];
    }
    else
    {
        [self doPostMetaSyncDatabaseConfigurationInFailure];
    }
}

/**
 * @name - (void)doPostMetaSyncDatabaseConfigurationInSuccess
 *
 * @author Shubha S
 *
 * @brief This method is getting called after datasync operation.if configuration success.
 *
 *
 * @param
 * @return void
 *
 */

- (void)doPostMetaSyncDatabaseConfigurationInSuccess
{
    DatabaseManager *dbManager = [DatabaseManager sharedInstance];
    
    //TO:DO
    
    //Attach Database
    
    [self attachDatabaseByName:@"tempsfm"  andPath:[dbManager databasePath]];
    
    // TODO:- Vipindas
    
    //Compare OLD tables with New tables and merge them

    //Copy data from OLD to New
    
    [FileManager copyFileFromPath:[dbManager databasePath] toPath:@""];
    
    //Dettach database by name
    
    [self detachDatabaseByName:@"tempsfm"];
    
    // Remove temp database
}

/**
 * @name - (void)doPostMetaSyncDatabaseConfigurationInFailure
 *
 * @author Shubha S
 *
 * @brief This method is getting called after datasync operation.if configuration fails.
 *
 *
 * @param
 * @return void
 *
 */


- (void)doPostMetaSyncDatabaseConfigurationInFailure
{
    DatabaseManager *dbManager = [DatabaseManager sharedInstance];

    //CloseDatabase main
    
    [self closeDatabase];
    
    // Delete main database file
    
    [self removeDb];
    
    //  Rename database backup file to main database file

    // VIPIN-imp will take care this path
    
    [FileManager moveFileAtPath:[dbManager databasePath] toPath:@""];
    
    // Copy database file
    
    //ResetConfiguration
    
    [self resetConfiguration];
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
    SXLogDebug(@" Database ATTACH now ");
    BOOL isSuccess = YES;
    
    DatabaseManager *dbManager = [DatabaseManager sharedInstance];
   
    if ([dbManager sqliteHandle] == nil)
    {
        //Skipping database attachment operation since db is Null pointer
        SXLogDebug(@"[DB] Skipping database attachment operation since db is Null pointer!");
        isSuccess = NO;
    }      // Validating file path and attachment name
    else if ( (! [StringUtil isValidOrZeroLengthString:path]) || (! [StringUtil isValidOrZeroLengthString:attachmentName]) )
    {
        //Skipping database attachment operation since invalid file path or database name
        SXLogDebug(@"[DB] Skipping database attachment operation since invalid file path or database name!");
        isSuccess = NO;
    }
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
        }
        
        isSuccess = sucessFull;
    }
    
    return isSuccess;
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
    }
    
    return sucessFull;
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
    DatabaseManager *dbManager = [DatabaseManager sharedInstance];
    
    NSURL *url = [NSURL fileURLWithPath:[dbManager databasePath]];
    
    [FileManager deleteFileAtPath:[url path]];
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
    NSArray *schemaArray = [NSArray arrayWithObjects:kTableAttachmentErrorSchema,kTableAttachmentsSchema,kTableBusinessRuleSchema,kTableChatterPostDetailsSchema,kTableContactImageSchema,kTableDocumentSchema,kTableDocumentTemplateDetailSchema,kTableDocumentTemplateSchema,kTableEventLocalIdsSchema,kTableInternetConflictsSchema,kTableLinkedSFMProcessSchema,kTableLocalEventUpdateSchema,kTableMetaSyncDueSchema,kTableMetaSyncStatusSchema,kTableMobileDeviceSettingsSchema,kTableMobileDeviceTagsSchema,kTableModifiedRecordsSchema,kTableObjectNameFieldValueSchema,kTableOnDemandDownloadSchema,kTableProcessBusinessRuleSchema,kTableProductImageSchema,kTableRTDpPickListSchema,kTableServiceReportLogoSchema,kTableSFAttachmentTrailerSchema,kTableSFChildRelationshipSchema,kTableSFDataTrailerSchema,kTableSFDataTrailerTempSchema,kTableSFExpressionComponentSchema,kTableSFExpressionSchema,kTableSFMSearchFieldSchema,kTableSFMSearchFilterCriteriaSchema,kTableSFMSearchProcessSchema,kTableSFNamedSearchComponentSchema,kTableSFNamedSearchFiltersSchema,kTableSFNamedSearchSchema, kTableSFObjectFieldSchema,kTableSFObjectMappingComponentSchema,kTableSFObjectMappingSchema,kTableSFObjectSchema,kTableOPDocHtmlDataSchema,kTableOPDocSignatureDataSchema,kTableSFPickListSchema,kTableSFProcessComponentSchema,kTableSFProcessSchema,kTableSFProcessTestSchema,kTableSFRecordTypeSchema,kTableSFReferenceToSchema,kTableSFRequiredPdfSchema,kTableSFRequiredSignatureSchema,kTableSFSearchObjectsSchema,kTableSFSignatureDataSchema,kTableSFWizardComponentSchema,kTableSFWizardSchema,kTableSourceUpdateObjectSchema,kTableSourceUpdateSchema,kTableStaticResourceSchema,kTableSummaryPDFSchema,kTableJobLogsSchema,kTableUserGPSLogSchema,kTableSYNCErrorConflictSchema,kTableSYNCHistorySchema,kTableSyncRecordsHeapSchema,kTableTroubleshootDataSchema,kTableUserImagesSchema,kTableRecentsSchema,nil];
    
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
        return @"BOOL";
    else if (NSOrderedSame == [dataType caseInsensitiveCompare:kSfDTCurrency] || NSOrderedSame == [dataType caseInsensitiveCompare:kSfDTDouble] || NSOrderedSame == [dataType caseInsensitiveCompare:kSfDTPercent])
        return @"DOUBLE";
    else if (NSOrderedSame == [dataType caseInsensitiveCompare:kSfDTInteger])
        return @"INTEGER";
    else if (NSOrderedSame == [dataType caseInsensitiveCompare:kSfDTDate] ||NSOrderedSame == [dataType caseInsensitiveCompare:kSfDTDateTime])
        return @"DATETIME";
    else if (NSOrderedSame == [dataType caseInsensitiveCompare:kSfDTTextArea])
        return @"VARCHAR";
    else
        return @"TEXT";
}

- (void)preInitialSyncDBPreparation {
    
    [self performDatabaseInitialConfigurationForNewUser];
}

@end
