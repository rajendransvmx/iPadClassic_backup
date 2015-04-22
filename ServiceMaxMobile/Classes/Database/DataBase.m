//
//  DataBase.m
//  iService
//
//  Created by Developer on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataBase.h"
#import "LocalizationGlobals.h"
#import "AppDelegate.h"
#import "PopoverButtons.h"
#import "PerformanceAnalytics.h"
#import "Utility.h" // Damodar - OPDoc
#import "SSZipArchive.h"
#import "Util.h"
#import "AttachmentUtility.h"
#import "SMXLogger.h"
#import "SMXMonitor.h"
#import "SMXPing.h"
#import "SMObjectRelationModel.h"  //Data Purge

// Vipin-db-optmz
// DB Constatns
static NSString * const kDBBeginTransaction = @"BEGIN TRANSACTION";
static NSString * const kDBEndTransaction = @"END TRANSACTION";

// Attachment name constant
static NSString * const kAttachementNameTempSFM = @"tempsfm";
static NSString * const kAttachementNameSFM = @"sfm";



void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);
static NSString *const TECHNICIAN_CURRENT_LOCATION = @"usr_tech_loc_filters";
static NSString *const TECHNICIAN_CURRENT_LOCATION_ID = @"usr_tech_loc_filters_id";

//Aparna: Source Update
@interface DataBase()

- (NSString *)sourceObjectNameForProcessId:(NSString *)processId;

- (NSString *)targetObjectNameForSettingId:(NSString *)settingId;
- (void)insertIntoSourceUpdateTable:(NSDictionary *)processDictionary;
- (NSString *)processIdForSfId:(NSString *)sfId;

//Camera
-(NSString*)concatinateStringForInsertQuery:(NSArray*)elements;

@end


@implementation DataBase 

@synthesize dbFilePath;
@synthesize didInsertTable;
@synthesize MyPopoverDelegate;
@synthesize tempDb;
@synthesize didTechnicianLocationUpdated;
@synthesize didUserGPSLocationUpdated;

// Vipin-db-optmz
@synthesize dbTransactionCount;
@synthesize dbOperationCounterDict;


//Damodar - OPDoc
@synthesize zipArchiver;
@synthesize didSubmitHTML;
@synthesize didGeneratePDF;

@synthesize requiredHtmlArray;
@synthesize requiredSignatureArray;
@synthesize deletableRequiredPdfArray;
@synthesize signaturesNotInServer;
@synthesize isResponseWithIds;
//@synthesize db;
-(id)init
{
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    return self;
}

- (void)loadTempDatabaseFileFromPath
{
    filepath = @"";
    NSArray *searchPaths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolderPath = [appDelegate getAppCustomSubDirectory]; // [searchPaths objectAtIndex: 0];
    filepath = [documentFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", TEMPDATABASENAME, DATABASETYPE1]];
}


// Vipin-db-optmz
#pragma mark - Database Transaction Management
- (int)beginTransaction
{
    if (self.dbTransactionCount > 0)
    {
        self.dbTransactionCount++;
        NSLog(@"[TXN] + db_txn_count - %d", self.dbTransactionCount);
        
        return SQLITE_OK;
    }
    
    char * err;
    int  executionResult = synchronized_sqlite3_exec(appDelegate.db, [kDBBeginTransaction UTF8String], NULL, NULL, &err);
    
    if (executionResult != SQLITE_OK )
    {
        NSLog(@"[TXN] + db_txn begin failed : %d : %@", executionResult, [NSString stringWithUTF8String:err]);
    }
    else
    {
        // Lets record as first transaction
        self.dbTransactionCount = 1;
        NSLog(@"[TXN] + db_txn_count - %d - begin", self.dbTransactionCount);
    }
    return executionResult;
}

// Vipin-db-optmz
- (int)endTransaction
{
    if (self.dbTransactionCount > 1)
    {
        self.dbTransactionCount--;
        NSLog(@"[TXN] - db_txn_count - %d", self.dbTransactionCount);
        return SQLITE_OK;
    }
    
    char * err;
    int  executionResult = synchronized_sqlite3_exec(appDelegate.db, [kDBEndTransaction UTF8String], NULL, NULL, &err);
    
    if (executionResult != SQLITE_OK )
    {
        NSLog(@"[TXN] - db_txn end failed : %d : %@", executionResult, [NSString stringWithUTF8String:err]);
    }
    else
    {
        // Lets reset to Zero since we closed all transaction safely.
        self.dbTransactionCount = 0;
        NSLog(@"[TXN] - db_txn_count - %d - commit", self.dbTransactionCount);
    }
    
    return executionResult;
}

// Vipin-db-optmz
- (void)cleanupDatabase
{
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"cleanupDatabase" andRecordCount:1];
    
    char * err;
    int  executionResult = synchronized_sqlite3_exec(appDelegate.db, "VACUUM;", 0, 0, &err);
    
    if ( executionResult == SQLITE_OK)
    {
        NSLog(@"Vacuumed DataBase");
        NSLog(@"[DB] Vacuumed DataBase");

        // Mem_leak_fix - Vipindas 9493 Jan 18
        if (self.dbTransactionCount == 0)
        {
//            NSLog(@" ------------ RD vipin-memopt 16-1 9493 ---------------");
            [self closeDatabase:appDelegate.db];
            [appDelegate releaseMainDatabase];
        }
    }
    else
    {
        //NSLog(@"[DB] NOT Vacuumed DataBase : %d %@", executionResult, [NSString stringWithUTF8String:err]);
    }

    // RD vipin-memopt 16-1 9493
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"cleanupDatabase" andRecordCount:0];
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"cleanupDatabase"
                                                                      andRecordCount:0];
}

// Vipin-db-optmz
#pragma mark - Table Index Management

- (void)doTableIndexCreation
{
    
    SMLog(kLogLevelVerbose,@"sync_Record_Heap_Index Creating....");
    
    NSString *query = [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS sync_Record_Heap_Index ON sync_Records_Heap (sf_id ASC, local_id ASC, object_name ASC, sync_flag ASC)"];
    [self createTable:query];
    
    // Vipin -- Creating new 3 index <
    
    query = [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS sync_Record_Heap_Index_2 ON sync_Records_Heap (sync_flag ASC, record_type ASC, sync_type ASC)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS sync_Record_Heap_Index_3 ON sync_Records_Heap (sync_flag ASC, object_name ASC)"];
    
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS sync_Record_Heap_Index_4 ON sync_Records_Heap (sync_type ASC, object_name ASC)"];
    
    [self createTable:query];
    
    
    // 1. SFObjectField
    // BOOL objFlag = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS SFObjectFieldIndex ON SFObjectField (object_api_name, api_name, label)"]];
    
    // 2. SFRTPicklist
    //BOOL RTIndexFlag = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS RTIndex ON SFRTPicklist (object_api_name, field_api_name, recordtypename, defaultlabel, defaultvalue, label, value)"]];
    
    // 3. SFNamedSearch
    //BOOL searchFlag = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS SFNamedSearchIndex ON SFNamedSearch (default_lookup_column, object_name, is_default,is_standard)"]];
    
    // 4. SFNamedSearchComponent
    //BOOL cmpndIndxFlag = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS SFNamedSearchComponentIndex ON SFNamedSearchComponent (field_name, search_object_field_type, sequence,field_type,field_relationship_name )"]];
    
    // 5. sync_Records_Heap
    //BOOL rcrdHeapFlag = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS sync_Record_Heap_Index ON sync_Records_Heap (sf_id ASC, local_id ASC, object_name ASC, sync_flag ASC)"]];
    
    // NSString *SFObjectFieldIndexCreatedMessage = objFlag ? @"SFObjectFieldIndex creation success":@" SFObjectFieldIndex failed creation";
    
    //NSString *RTIndexCreatedMessage = RTIndexFlag ? @"RTIndex creation success":@" RTIndex failed creation";
    
    //NSString *SFNamedSearchIndexCreatedMessage = searchFlag ? @"SFNamedSearchIndex creation success":@" SFNamedSearchIndex failed creation";
    
    //NSString *SFNamedSearchComponentIndexCreatedMessage = cmpndIndxFlag ? @"SFNamedSearchComponentIndex creation success":@" SFNamedSearchComponentIndex failed creation";
    
    //NSString *SyncRecordHeapIndexCreatedMessage = rcrdHeapFlag ? @"sync_Record_Heap_Index creation success":@" sync_Record_Heap_Index failed creation";
    
    //    SMLog(kLogLevelVerbose,@"%@\n", SyncRecordHeapIndexCreatedMessage);
}

// Vipin-db-optmz
- (void)dropAllExistingTableIndex
{
    // 1. SFObjectField
    // BOOL objFlag = [self createTable:[NSString stringWithFormat:@"DROP INDEX IF EXISTS SFObjectFieldIndex ON SFObjectField"]];
    
    // 2. SFRTPicklist
    //BOOL RTIndexFlag = [self createTable:[NSString stringWithFormat:@"DROP INDEX IF EXISTS RTIndex ON SFRTPicklist"]];
    
    // 3. SFNamedSearch
    //BOOL searchFlag = [self createTable:[NSString stringWithFormat:@"DROP INDEX IF EXISTS SFNamedSearchIndex ON SFNamedSearch"]];
    
    // 4. SFNamedSearchComponent
    //BOOL cmpndIndxFlag = [self createTable:[NSString stringWithFormat:@"DROP INDEX IF EXISTS SFNamedSearchComponentIndex ON SFNamedSearchComponent"]];
    
    // 5. sync_Records_Heap
    BOOL rcrdHeapFlag1 = [self createTable:[NSString stringWithFormat:@"DROP INDEX IF EXISTS sync_Record_Heap_Index "]];
    BOOL rcrdHeapFlag2 = [self createTable:[NSString stringWithFormat:@"DROP INDEX IF EXISTS sync_Record_Heap_Index_2 "]];
    BOOL rcrdHeapFlag3 = [self createTable:[NSString stringWithFormat:@"DROP INDEX IF EXISTS sync_Record_Heap_Index_3 "]];
    BOOL rcrdHeapFlag4 = [self createTable:[NSString stringWithFormat:@"DROP INDEX IF EXISTS sync_Record_Heap_Index_4 "]];
    
    //NSString *SFObjectFieldIndexDeletionMessage = objFlag ? @"SFObjectFieldIndex deletion success":@" SFObjectFieldIndex failed deletion";
    
    //NSString *RTIndexDeletionMessage = RTIndexFlag ? @"RTIndex deletion success":@" RTIndex failed deletion";
    
    //NSString *SFNamedSearchIndexDeletionMessage = searchFlag ? @"SFNamedSearchIndex deletion success":@" SFNamedSearchIndex failed deletion";
    
    //NSString *SFNamedSearchComponentIndexDeletionMessage = cmpndIndxFlag ? @"SFNamedSearchComponentIndex deletion success":@" SFNamedSearchComponentIndex failed deletion";
    
    NSString *SyncRecordHeapIndexDeletionMessage1 = rcrdHeapFlag1 ? @"sync_Record_Heap_Index deletion success":@" sync_Record_Heap_Index failed deletion";
    
    NSString *SyncRecordHeapIndexDeletionMessage2 = rcrdHeapFlag2 ? @"sync_Record_Heap_Index_2 deletion success":@" sync_Record_Heap_Index_2 failed deletion";
    
    NSString *SyncRecordHeapIndexDeletionMessage3 = rcrdHeapFlag3 ? @"sync_Record_Heap_Index_3 deletion success":@" sync_Record_Heap_Index_3 failed deletion";
    
    NSString *SyncRecordHeapIndexDeletionMessage4 = rcrdHeapFlag4 ? @"sync_Record_Heap_Index_4 deletion success":@" sync_Record_Heap_Index_4 failed deletion";
    
    
    SMLog(kLogLevelError,@"\n%@\n%@\n%@\n%@", SyncRecordHeapIndexDeletionMessage1, SyncRecordHeapIndexDeletionMessage2, SyncRecordHeapIndexDeletionMessage3, SyncRecordHeapIndexDeletionMessage4);
    
    
}


#pragma mark - Prepared Statement Binding Text

- (void)preparedStatement:(sqlite3_stmt *)preparedStatement
           bindTextString:(NSString *)text
                  atIndex:(int)index
{
    char * _textValue = [appDelegate convertStringIntoChar:text];
    sqlite3_bind_text(preparedStatement, index, _textValue, strlen(_textValue), SQLITE_TRANSIENT);
}


#pragma mark - SFM Search

- (void) createTablesForSFMSearch
{
    NSString *packgeVersion;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFM_Search_Process ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'Id' VARCHAR,'Name' VARCHAR,'SVMXC__Active__c' VARCHAR,'SVMXC__Description__c' VARCHAR,'SVMXC__IsDefault__c' VARCHAR,'SVMXC__IsStandard__c' VARCHAR,'SVMXC__Name__c' VARCHAR,'SVMXC__Number_of_Lookup_Records__c' VARCHAR,'SVMXC__Rule_Type__c' VARCHAR)"]];
    if(result == YES)
        SMLog(kLogLevelVerbose,@"SFM_Search_Process Table Create Success");
    else
        SMLog(kLogLevelError,@"SFM_Search_Process Table Create Failed");
    

    packgeVersion = [userDefaults objectForKey:kPkgVersionCheckForGPS_AND_SFM_SEARCH];
    int _stringNumber = [packgeVersion intValue];
    int check = (kMinSFMSearchSorting * 100000);
    SMLog(kLogLevelVerbose,@"%d", check);
    if(_stringNumber >= check)
    {
        appDelegate.isSfmSearchSortingAvailable=TRUE;
        result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFM_Search_Objects ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0),'SVMXC__Module__c' VARCHAR,'SVMXC__ProcessID__c' VARCHAR,'SVMXC__Target_Object_Name__c' VARCHAR,'ProcessName' VARCHAR,'ProcessId' VARCHAR,'ObjectID' VARCHAR,'SVMXC__Advance_Expression__c' VARCHAR,'SVMXC__Parent_Object_Criteria__c' VARCHAR,'SVMXC__Name__c' VARCHAR)"]];
        if(result == YES)
            SMLog(kLogLevelVerbose,@"SFM_Search_Objects Table Create Success");
        else
            SMLog(kLogLevelError,@"SFM_Search_Objects Table Create Failed");
        
        result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFM_Search_Field ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'Id' VARCHAR,'SVMXC__Expression_Rule__c' VARCHAR,'SVMXC__Field_Name__c' VARCHAR,'SVMXC__Object_Name2__c' VARCHAR,'SVMXC__Search_Object_Field_Type__c' VARCHAR,'ObjectId' VARCHAR,'SVMXC__Lookup_Field_API_Name__c' VARCHAR,'SVMXC__Field_Relationship_Name__c' VARCHAR,SVMXC__Display_Type__c VARCHAR,'SVMXC__Object_Name__c' VARCHAR,'SVMXC__Sort_Order__c' VARCHAR)"]];
        
        if(result == YES)
            SMLog(kLogLevelVerbose,@"SFM_Search_Field Table Create Success");
        else
            SMLog(kLogLevelError,@"SFM_Search_Field Table Create Failed");
        
        result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFM_Search_Filter_Criteria ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'Id' VARCHAR,'SVMXC__Display_Type__c' VARCHAR,'SVMXC__Expression_Rule__c' VARCHAR,'SVMXC__Field_Name__c' VARCHAR,'SVMXC__Object_Name2__c' VARCHAR,'SVMXC__Operand__c' VARCHAR,'SVMXC__Operator__c' VARCHAR,'ObjectId' VARCHAR,'SVMXC__Lookup_Field_API_Name__c' VARCHAR,'SVMXC__Field_Relationship_Name__c' VARCHAR,'SVMXC__Object_Name__c' VARCHAR)"]];
        if(result == YES)
            SMLog(kLogLevelVerbose,@"SFM_Search_Filter_Criteria Table Create Success");
        else
            SMLog(kLogLevelError,@"SFM_Search_Filter_Criteria Table Create Failed");
    }
    else
    {
        appDelegate.isSfmSearchSortingAvailable=FALSE;
        result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFM_Search_Objects ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0),'SVMXC__Module__c' VARCHAR,'SVMXC__ProcessID__c' VARCHAR,'SVMXC__Target_Object_Name__c' VARCHAR,'ProcessName' VARCHAR,'ProcessId' VARCHAR,'ObjectID' VARCHAR,'SVMXC__Advance_Expression__c' VARCHAR,'SVMXC__Name__c' VARCHAR)"]];
        if(result == YES)
            SMLog(kLogLevelVerbose,@"SFM_Search_Objects Table Create Success");
        else
            SMLog(kLogLevelError,@"SFM_Search_Objects Table Create Failed");
        
        result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFM_Search_Field ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'Id' VARCHAR,'SVMXC__Expression_Rule__c' VARCHAR,'SVMXC__Field_Name__c' VARCHAR,'SVMXC__Object_Name2__c' VARCHAR,'SVMXC__Search_Object_Field_Type__c' VARCHAR,'ObjectId' VARCHAR)"]];
        
        if(result == YES)
            SMLog(kLogLevelVerbose,@"SFM_Search_Field Table Create Success");
        else
            SMLog(kLogLevelError,@"SFM_Search_Field Table Create Failed");
        
        result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFM_Search_Filter_Criteria ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'Id' VARCHAR,'SVMXC__Display_Type__c' VARCHAR,'SVMXC__Expression_Rule__c' VARCHAR,'SVMXC__Field_Name__c' VARCHAR,'SVMXC__Object_Name2__c' VARCHAR,'SVMXC__Operand__c' VARCHAR,'SVMXC__Operator__c' VARCHAR,'ObjectId' VARCHAR)"]];
        if(result == YES)
            SMLog(kLogLevelVerbose,@"SFM_Search_Filter_Criteria Table Create Success");
        else
            SMLog(kLogLevelError,@"SFM_Search_Filter_Criteria Table Create Failed");
    }
}

- (void) insertValuesintoSFMProcessTable:(NSMutableArray *) processData
{
    // Vipin-db-optmz
    [self beginTransaction];
    
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    [keys addObject:@"Id"];
    [keys addObject:@"Name"];
    [keys addObject:@"SVMXC__Active__c"];
    [keys addObject:@"SVMXC__Description__c"];
    [keys addObject:@"SVMXC__IsDefault__c"];
    [keys addObject:@"SVMXC__IsStandard__c"];
    [keys addObject:@"SVMXC__Name__c"];
    [keys addObject:@"SVMXC__Number_of_Lookup_Records__c"];
    [keys addObject:@"SVMXC__Rule_Type__c"];

    NSMutableString *queryFields = [[NSMutableString alloc] init];
    for(int i=0;i<[keys count]; i++)
    {
        if(i)
            [queryFields  appendString:@","];
        [queryFields appendFormat:@"'%@'",[keys objectAtIndex:i]];
    }
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFM_Search_Process-x"
                                                         andRecordCount:0];
    
    // PUT INTO OBSERVATION
    for (int k=0; k< [ processData count]; k++)
    {
        NSMutableString *valueFields = [[NSMutableString alloc] init];
        
        for(int j=0;j<[keys count]; j++)
        {
            if(j)
                [valueFields  appendString:@","];
            NSString *key = [keys objectAtIndex:j];
            NSString *process_data=[[processData objectAtIndex:k] objectForKey:key];
            process_data=[process_data  stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            [valueFields appendFormat:@"'%@'",process_data];
        }

        NSString  *queryStatement = [NSString stringWithFormat:@"INSERT INTO SFM_Search_Process (%@) VALUES (%@)",queryFields,valueFields ];
        
        
        
        char * err;
        if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                [MyPopoverDelegate performSelector:@selector(throwException)];
            SMLog(kLogLevelError,@"%@", queryStatement);
			SMLog(kLogLevelError,@"METHOD: insertValuesintoSFMProcessTable");
			SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
            /*
			[appDelegate printIfError:nil ForQuery:queryStatement type:INSERTQUERY];
             */
        }
        [valueFields release];
    }
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFM_Search_Process-x"
                                                         andRecordCount:[processData count]];
    
    [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[processData count]];
    
    
    [keys release];
    [queryFields release];
    [self insertValuesintoSFMObjectTable:processData];
    
    // Vipin-db-optmz
    [self endTransaction];
}


    // Vipin-db-optmz
- (void) insertValuesintoSFMObjectTable:(NSMutableArray *) processData
{
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString  *queryStatementSearchObject =  [NSString stringWithFormat:@"INSERT INTO SFM_Search_Objects ('SVMXC__Module__c','SVMXC__ProcessID__c','SVMXC__Target_Object_Name__c','ProcessName','ProcessId','ObjectId','SVMXC__Advance_Expression__c','SVMXC__Name__c','SVMXC__Parent_Object_Criteria__c') VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9)"];

    sqlite3_stmt * preparedStmtSearchObject;
    int preparedStmtSearchObjectResult = synchronized_sqlite3_prepare_v2(appDelegate.db,
                                                 [queryStatementSearchObject UTF8String],
                                                 strlen([queryStatementSearchObject UTF8String]),
                                                 &preparedStmtSearchObject, NULL);
    
    
    
   NSString *queryStatementSearchFieldSorting = [NSString stringWithFormat:@"INSERT INTO SFM_Search_Field ('Id','SVMXC__Expression_Rule__c','SVMXC__Field_Name__c','SVMXC__Object_Name2__c','SVMXC__Search_Object_Field_Type__c','ObjectId','SVMXC__Display_Type__c','SVMXC__Lookup_Field_API_Name__c','SVMXC__Field_Relationship_Name__c','SVMXC__Object_Name__c','SVMXC__Sort_Order__c') VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11)"];
    
    sqlite3_stmt * preparedStmtSearchFieldSorting;
    int preparedStmtSearchFieldSortingResult = synchronized_sqlite3_prepare_v2(appDelegate.db,
                                                                         [queryStatementSearchFieldSorting UTF8String],
                                                                         strlen([queryStatementSearchFieldSorting UTF8String]),
                                                                         &preparedStmtSearchFieldSorting, NULL);
    
    
    
  
    NSString *queryStatementSearchField = [NSString stringWithFormat:@"INSERT INTO SFM_Search_Field ('Id','SVMXC__Expression_Rule__c','SVMXC__Field_Name__c','SVMXC__Object_Name2__c','SVMXC__Search_Object_Field_Type__c','ObjectId','SVMXC__Display_Type__c','SVMXC__Lookup_Field_API_Name__c','SVMXC__Field_Relationship_Name__c','SVMXC__Object_Name__c') VALUES (?1,?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10)"];
    
    sqlite3_stmt * preparedStmtSearchField;
    int preparedStmtSearchFieldResult = synchronized_sqlite3_prepare_v2(appDelegate.db,
                                                                               [queryStatementSearchField UTF8String],
                                                                               strlen([queryStatementSearchField UTF8String]),
                                                                               &preparedStmtSearchField, NULL);
    
    
    NSString *queryStatementFilterCriteria = [NSString stringWithFormat:@"INSERT INTO SFM_Search_Filter_Criteria ('Id','SVMXC__Display_Type__c','SVMXC__Expression_Rule__c','SVMXC__Field_Name__c','SVMXC__Object_Name2__c','SVMXC__Operand__c','SVMXC__Operator__c','ObjectId','SVMXC__Lookup_Field_API_Name__c','SVMXC__Field_Relationship_Name__c','SVMXC__Object_Name__c') VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11)"];
    
    sqlite3_stmt * preparedStmtFilterCriteria;
    int preparedStmtFilterCriteriaResult = synchronized_sqlite3_prepare_v2(appDelegate.db,
                                                                        [queryStatementFilterCriteria UTF8String],
                                                                        strlen([queryStatementFilterCriteria UTF8String]),
                                                                        &preparedStmtFilterCriteria, NULL);
    
    

    // Vipin-db-optmz
    [self beginTransaction];
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFM_Search_Process"
                                                         andRecordCount:0];
    
    
    for(int k=0; k< [processData count]; k++)
    {
        NSDictionary *processDict = [processData objectAtIndex:k];
        NSString *processName = [processDict objectForKey:@"Name"];
        processName=[processName stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
        NSString *processId = [processDict objectForKey:@"Id"];
        NSArray *objectsArray = [processDict objectForKey:@"Objects"];
        SMLog(kLogLevelVerbose,@"Process Name = %@ and Objects = %@",processName, objectsArray);
        NSString *parentObjCriteria=@"";
        
        if(appDelegate.isSfmSearchSortingAvailable)
        {
           
            for(int m=0; m<[objectsArray count]; m++)
            {
                NSDictionary *objectDict = [objectsArray objectAtIndex:m];
                SMLog(kLogLevelVerbose,@"Object ID = %@",[objectDict objectForKey:@"Id"] );
                parentObjCriteria= [objectDict  objectForKey:@"SVMXC__Advance_Expression__c"];
//                parentObjCriteria= [objectDict  objectForKey:@"SVMXC__Parent_Object_Criteria__c"];

                SMLog(kLogLevelVerbose,@"%@",parentObjCriteria);
                if(![[objectDict  objectForKey:@"SVMXC__Advance_Expression__c"] isEqualToString:@"(null)"])
                {
                    if(!(parentObjCriteria ==NULL))
                    {
                        parentObjCriteria=[parentObjCriteria stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
                    }
                    else
                    {
                        parentObjCriteria=@"(null)";
                    }
                }
                else
                {
                    parentObjCriteria=@"(null)";
                }
                
                NSString *targetObjectNameFull = [objectDict objectForKey:@"SVMXC__Target_Object_Name__c"];
                targetObjectNameFull= [targetObjectNameFull stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                NSString *targetObjectName = [self getFieldLabelForApiName:targetObjectNameFull];
                targetObjectName=[targetObjectName stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
                NSString * Name = [objectDict objectForKey:@"SVMXC__Name__c"];
                Name = [Name stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
                NSString * Module = [objectDict objectForKey:@"SVMXC__Module__c"];
                Module = [Module  stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
                NSString *AdvanceExp=[objectDict objectForKey:@"SVMXC__Parent_Object_Criteria__c"];
//                NSString *AdvanceExp=[objectDict objectForKey:@"SVMXC__Advance_Expression__c"];

                
                // Vipin-db-optmz
                [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFM_Searc_Objects"
                                                                     andRecordCount:0];
                
                if (preparedStmtSearchObjectResult == SQLITE_OK)
                {
                    char * _Module = [appDelegate convertStringIntoChar:Module];
                    sqlite3_bind_text(preparedStmtSearchObject, 1, _Module, strlen(_Module), SQLITE_TRANSIENT);
                    
                    char * _processID = [appDelegate convertStringIntoChar:[objectDict objectForKey:@"SVMXC__ProcessID__c"]];
                    sqlite3_bind_text(preparedStmtSearchObject, 2, _processID, strlen(_processID), SQLITE_TRANSIENT);
                    
                    char * _targetObjectName = [appDelegate convertStringIntoChar:targetObjectName];
                    sqlite3_bind_text(preparedStmtSearchObject, 3, _targetObjectName, strlen(_targetObjectName), SQLITE_TRANSIENT);
                    
                    char * _processName = [appDelegate convertStringIntoChar:processName];
                    sqlite3_bind_text(preparedStmtSearchObject, 4, _processName, strlen(_processName), SQLITE_TRANSIENT);
                    
                    char * _processId = [appDelegate convertStringIntoChar:processId];
                    sqlite3_bind_text(preparedStmtSearchObject, 5, _processId, strlen(_processId), SQLITE_TRANSIENT);
                    
                    char * _id = [appDelegate convertStringIntoChar:[objectDict objectForKey:@"Id"]];
                    sqlite3_bind_text(preparedStmtSearchObject, 6, _id, strlen(_id), SQLITE_TRANSIENT);
                    
                    char * _AdvanceExp = [appDelegate convertStringIntoChar:AdvanceExp];
                    sqlite3_bind_text(preparedStmtSearchObject, 7, _AdvanceExp, strlen(_AdvanceExp), SQLITE_TRANSIENT);
                    
                    char * _Name = [appDelegate convertStringIntoChar:Name];
                    sqlite3_bind_text(preparedStmtSearchObject, 8, _Name, strlen(_Name), SQLITE_TRANSIENT);
                    
                    char * _parentObjCriteria = [appDelegate convertStringIntoChar:parentObjCriteria];
                    sqlite3_bind_text(preparedStmtSearchObject, 9, _parentObjCriteria, strlen(_parentObjCriteria), SQLITE_TRANSIENT);
                    
                    
                    if (synchronized_sqlite3_step(preparedStmtSearchObject) != SQLITE_DONE)
                    {
                        SMLog(kLogLevelError,@"insertValuesintoSFMObjectTable : Commit Failed! - SFM_Search_Objects\n");
                    }
                    
                    sqlite3_clear_bindings(preparedStmtSearchObject);
                    sqlite3_reset(preparedStmtSearchObject);
                }
                else
                {
                    SMLog(kLogLevelError,@"insertValuesintoSFMObjectTable : prepare Failed! - SFM_Search_Objects - SFM_Searc_Objects\n   message : %d - %@",  preparedStmtSearchObjectResult, [NSString stringWithUTF8String:sqlite3_errmsg(appDelegate.db)]);
                }
                
                [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:1];
                // Vipin-db-optmz
                [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"SFM_Searc_Objects"
                                                                     andRecordCount:1];

                
                
                NSArray *objectConfigDataArray = [objectDict objectForKey:@"ConfigData"];
                for(int n=0; n<[objectConfigDataArray count]; n++)
                {
                    NSDictionary *objectConfigDict = [objectConfigDataArray objectAtIndex:n];
                    NSArray *keys = [objectConfigDict allKeys];
                    
                    NSString *fieldNameFull = [objectConfigDict objectForKey:@"SVMXC__Field_Name__c"];
                    NSString *fieldName     = [self getFieldLabelForApiName:fieldNameFull];

                    NSString *objectName2Full = [objectConfigDict objectForKey:@"SVMXC__Object_Name2__c"];
                    NSString *objectName2     = [self getFieldLabelForApiName:objectName2Full];
                    
                    NSString *fieldType = ([objectConfigDict objectForKey:@"SVMXC__Display_Type__c"]!=nil||[[objectConfigDict objectForKey:@"SVMXC__Display_Type__c"] length]>0)?[objectConfigDict objectForKey:@"SVMXC__Display_Type__c"]:@"";
                    
                    NSString *lookUpField=([objectConfigDict objectForKey:@"SVMXC__Lookup_Field_API_Name__c"]!=nil||[[objectConfigDict objectForKey:@"SVMXC__Lookup_Field_API_Name__c"] length]>0)?[objectConfigDict objectForKey:@"SVMXC__Lookup_Field_API_Name__c"]:@"";
                    
                    NSString *fieldRelationShip=([objectConfigDict objectForKey:@"SVMXC__Field_Relationship_Name__c"]!=nil||[[objectConfigDict objectForKey:@"SVMXC__Field_Relationship_Name__c"] length]>0)?[objectConfigDict objectForKey:@"SVMXC__Field_Relationship_Name__c"]:@"";
                   
                    NSString *objectName=([objectConfigDict objectForKey:@"SVMXC__Object_Name__c"]!=nil||[[objectConfigDict objectForKey:@"SVMXC__Object_Name__c"] length]>0)?[objectConfigDict objectForKey:@"SVMXC__Object_Name__c"]:@"";
                    
                    NSString *sortOrder=([objectConfigDict objectForKey:@"SVMXC__Sort_Order__c"]!=nil||[[objectConfigDict objectForKey:@"SVMXC__Sort_Order__c"] length]>0)?[objectConfigDict objectForKey:@"SVMXC__Sort_Order__c"]:@"";
                        BOOL isSortingFieldPresent=[self isColumnPresentInTable:@"SFM_Search_Field" columnName:@"SVMXC__Sort_Order__c"];
                    
                    
                    if([keys containsObject:@"SVMXC__Search_Object_Field_Type__c"])
                    {
                        if(isSortingFieldPresent)
                        {
                            if (preparedStmtSearchFieldSortingResult == SQLITE_OK)
                            {
                                // Vipin-db-optmz
                                [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFO-FieldSorting"
                                                                                     andRecordCount:0];
                                
                                
                                [self preparedStatement:preparedStmtSearchFieldSorting
                                         bindTextString:[objectConfigDict objectForKey:@"Id"]
                                                atIndex:1];
                                [self preparedStatement:preparedStmtSearchFieldSorting
                                         bindTextString:[objectConfigDict objectForKey:@"SVMXC__Expression_Rule__c"]
                                                atIndex:2];
                                [self preparedStatement:preparedStmtSearchFieldSorting
                                         bindTextString:fieldName
                                                atIndex:3];
                                [self preparedStatement:preparedStmtSearchFieldSorting
                                         bindTextString:objectName2
                                                atIndex:4];
                                [self preparedStatement:preparedStmtSearchFieldSorting
                                         bindTextString:[objectConfigDict objectForKey:@"SVMXC__Search_Object_Field_Type__c"]
                                                atIndex:5];
                                [self preparedStatement:preparedStmtSearchFieldSorting
                                         bindTextString:[objectDict objectForKey:@"Id"]
                                                atIndex:6];
                                [self preparedStatement:preparedStmtSearchFieldSorting
                                         bindTextString:fieldType
                                                atIndex:7];
                                [self preparedStatement:preparedStmtSearchFieldSorting
                                         bindTextString:lookUpField
                                                atIndex:8];
                                [self preparedStatement:preparedStmtSearchFieldSorting
                                         bindTextString:fieldRelationShip
                                                atIndex:9];                                
                                [self preparedStatement:preparedStmtSearchFieldSorting
                                         bindTextString:objectName
                                                atIndex:10];                                
                                [self preparedStatement:preparedStmtSearchFieldSorting
                                         bindTextString:sortOrder
                                                atIndex:11];                                
                                
                                if (synchronized_sqlite3_step(preparedStmtSearchFieldSorting) != SQLITE_DONE)
                                {
                                    SMLog(kLogLevelError,@"insertValuesintoSFMObjectTable : Commit Failed! - SFM_Search_Objects - FieldSorting\n");
                                }
                                
                                sqlite3_clear_bindings(preparedStmtSearchFieldSorting);
                                sqlite3_reset(preparedStmtSearchFieldSorting);
                                
                                // Vipin-db-optmz
                                [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"SFO-FieldSorting"
                                                                                                  andRecordCount:1];
                                [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:1];
                                
                                
                            }
                            else
                            {
                                SMLog(kLogLevelError,@"insertValuesintoSFMObjectTable : prepare Failed! - SFM_Search_Objects - FieldSorting \n  message : %d - %@",  preparedStmtSearchFieldSortingResult, [NSString stringWithUTF8String:sqlite3_errmsg(appDelegate.db)]);
                            }
                        }
                        else
                        {
                            if (preparedStmtSearchFieldResult == SQLITE_OK) 
                            {
                                // Vipin-db-optmz
                                [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFO-Search Field"
                                                                                     andRecordCount:0];
                                
                                
                                [self preparedStatement:preparedStmtSearchField
                                         bindTextString:[objectConfigDict objectForKey:@"Id"]
                                                atIndex:1];
                                
                                [self preparedStatement:preparedStmtSearchField
                                         bindTextString:[objectConfigDict objectForKey:@"SVMXC__Expression_Rule__c"]
                                                atIndex:2];
                                
                                [self preparedStatement:preparedStmtSearchField
                                         bindTextString:fieldName
                                                atIndex:3];
                                
                                [self preparedStatement:preparedStmtSearchField
                                         bindTextString:objectName2
                                                atIndex:4];
                                
                                [self preparedStatement:preparedStmtSearchField
                                         bindTextString:[objectConfigDict objectForKey:@"SVMXC__Search_Object_Field_Type__c"]
                                                atIndex:5];
                                
                                [self preparedStatement:preparedStmtSearchField
                                         bindTextString:[objectDict objectForKey:@"Id"]
                                                atIndex:6];
                            
                                [self preparedStatement:preparedStmtSearchField
                                         bindTextString:fieldType
                                                atIndex:7];
                                
                                [self preparedStatement:preparedStmtSearchField
                                         bindTextString:lookUpField
                                                atIndex:8];
                                
                                [self preparedStatement:preparedStmtSearchField
                                         bindTextString:fieldRelationShip
                                                atIndex:9];
                                
                                [self preparedStatement:preparedStmtSearchField
                                         bindTextString:objectName
                                                atIndex:10];
                                
                                if (synchronized_sqlite3_step(preparedStmtSearchField) != SQLITE_DONE)
                                {
                                    SMLog(kLogLevelError,@"insertValuesintoSFMObjectTable : Commit Failed! - SFM_Search_Objects - Search Field \n");
                                }
                                
                                sqlite3_clear_bindings(preparedStmtSearchField);
                                sqlite3_reset(preparedStmtSearchField);
                                
                                // Vipin-db-optmz
                                [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"SFO-Search Field"
                                                                                                  andRecordCount:1];
                                [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:1];
                                
                            }
                            else
                            {
                                SMLog(kLogLevelError,@"insertValuesintoSFMObjectTable : prepare Failed! - SFM_Search_Objects - Search Field \n  message : %d - %@",  preparedStmtSearchFieldResult, [NSString stringWithUTF8String:sqlite3_errmsg(appDelegate.db)]);
                            }
                        }
                    }
                    else
                    {
                        if (preparedStmtFilterCriteriaResult == SQLITE_OK)
                        {
                            // Vipin-db-optmz
                            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFO-Filter Criteria"
                                                                                 andRecordCount:0];
                            

                            [self preparedStatement:preparedStmtFilterCriteria
                                     bindTextString:[objectConfigDict objectForKey:@"Id"]
                                            atIndex:1];
                            
                            [self preparedStatement:preparedStmtFilterCriteria
                                     bindTextString:[objectConfigDict objectForKey:@"SVMXC__Display_Type__c"]
                                            atIndex:2];
                            
                            [self preparedStatement:preparedStmtFilterCriteria
                                     bindTextString:[objectConfigDict objectForKey:@"SVMXC__Expression_Rule__c"]
                                            atIndex:3];
                            
                            [self preparedStatement:preparedStmtFilterCriteria
                                     bindTextString:fieldName
                                            atIndex:4];
                            
                            [self preparedStatement:preparedStmtFilterCriteria
                                     bindTextString:objectName2
                                            atIndex:5];
                            
                            [self preparedStatement:preparedStmtFilterCriteria
                                     bindTextString:[objectConfigDict objectForKey:@"SVMXC__Operand__c"]
                                            atIndex:6];
                            
                            [self preparedStatement:preparedStmtFilterCriteria
                                     bindTextString:[objectConfigDict objectForKey:@"SVMXC__Operator__c"]
                                            atIndex:7];
                            
                            [self preparedStatement:preparedStmtFilterCriteria
                                     bindTextString:[objectDict objectForKey:@"Id"]
                                            atIndex:8];
                            
                            [self preparedStatement:preparedStmtFilterCriteria
                                     bindTextString:lookUpField
                                            atIndex:9];
                            
                            [self preparedStatement:preparedStmtFilterCriteria
                                     bindTextString:fieldRelationShip
                                            atIndex:10];
                            
                            [self preparedStatement:preparedStmtFilterCriteria
                                     bindTextString:objectName
                                            atIndex:11];
                            
                            
                            if (synchronized_sqlite3_step(preparedStmtFilterCriteria) != SQLITE_DONE)
                            {
                                SMLog(kLogLevelError,@"insertValuesintoSFMObjectTable : Commit Failed! - SFM_Search_Objects - Filter Criteria\n");
                            }
                            
                            sqlite3_clear_bindings(preparedStmtFilterCriteria);
                            sqlite3_reset(preparedStmtFilterCriteria);
                            
                            // Vipin-db-optmz
                            [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"SFO-Filter Criteria"
                                                                                              andRecordCount:1];
                            [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:1];
                            
                        }
                        else
                        {
                            SMLog(kLogLevelError,@"insertValuesintoSFMObjectTable : prepare Failed! - SFM_Search_Objects - Filter Criteria\n message %d - %@",  preparedStmtFilterCriteriaResult, [NSString stringWithUTF8String:sqlite3_errmsg(appDelegate.db)]);
                        }
                    }
                }
            }
        }
        else
        {
            sqlite3_stmt * bulkStmt;
            
            //Query 1
            NSString  *queryStatement =  [NSString stringWithFormat:@"INSERT INTO SFM_Search_Objects ('SVMXC__Module__c','SVMXC__ProcessID__c','SVMXC__Target_Object_Name__c','ProcessName','ProcessId','ObjectId','SVMXC__Advance_Expression__c','SVMXC__Name__c') VALUES (?1,?2,?3,?4,?5,?6,?7,?8)"];
            
            sqlite3_stmt * bulkStmtForSearch;
            sqlite3_stmt * bulkStmtForFilter;
            
            //Query 2
            NSString  *queryStatementSearchField = [NSString stringWithFormat:@"INSERT INTO SFM_Search_Field ('Id','SVMXC__Expression_Rule__c','SVMXC__Field_Name__c','SVMXC__Object_Name2__c','SVMXC__Search_Object_Field_Type__c','ObjectId') VALUES (?1, ?2, ?3, ?4, ?5, ?6)"];

            //[objectConfigDict objectForKey:@"Id"],[objectConfigDict objectForKey:@"SVMXC__Expression_Rule__c"],fieldName,objectName2,[objectConfigDict objectForKey:@"SVMXC__Search_Object_Field_Type__c"],[objectDict objectForKey:@"Id"]
            
            //Query 3
            
            NSString  *queryStatementFilterCriteria = [NSString stringWithFormat:@"INSERT INTO SFM_Search_Filter_Criteria ('Id','SVMXC__Display_Type__c','SVMXC__Expression_Rule__c','SVMXC__Field_Name__c','SVMXC__Object_Name2__c','SVMXC__Operand__c','SVMXC__Operator__c','ObjectId') VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)"];
                                                       
            //,[objectConfigDict objectForKey:@"Id"],[objectConfigDict objectForKey:@"SVMXC__Display_Type__c"],[objectConfigDict objectForKey:@"SVMXC__Expression_Rule__c"],fieldName,objectName2,[objectConfigDict objectForKey:@"SVMXC__Operand__c"],[objectConfigDict objectForKey:@"SVMXC__Operator__c"],[objectDict objectForKey:@"Id"] ];

            
            /*
             queryStatement = [NSString stringWithFormat:@"INSERT INTO SFM_Search_Filter_Criteria ('Id','SVMXC__Display_Type__c','SVMXC__Expression_Rule__c','SVMXC__Field_Name__c','SVMXC__Object_Name2__c','SVMXC__Operand__c','SVMXC__Operator__c','ObjectId') VALUES ('%@','%@','%@','%@','%@','%@','%@','%@')",[objectConfigDict objectForKey:@"Id"],[objectConfigDict objectForKey:@"SVMXC__Display_Type__c"],[objectConfigDict objectForKey:@"SVMXC__Expression_Rule__c"],fieldName,objectName2,[objectConfigDict objectForKey:@"SVMXC__Operand__c"],[objectConfigDict objectForKey:@"SVMXC__Operator__c"],[objectDict objectForKey:@"Id"] ];
             }
             */
            
    
            int result = synchronized_sqlite3_prepare_v2(appDelegate.db,
                                                        [queryStatement UTF8String],
                                                        strlen([queryStatement UTF8String]),
                                                        &bulkStmt, NULL);
            
            int resultSearch = synchronized_sqlite3_prepare_v2(appDelegate.db,
                                                         [queryStatementSearchField UTF8String],
                                                         strlen([queryStatementSearchField UTF8String]),
                                                         &bulkStmtForSearch, NULL);
            
            int resultFilter = synchronized_sqlite3_prepare_v2(appDelegate.db,
                                                               [queryStatementFilterCriteria UTF8String],
                                                               strlen([queryStatementFilterCriteria UTF8String]),
                                                               &bulkStmtForFilter, NULL);

            if (result == SQLITE_OK)
            {
                // Vipin-db-optmz
                [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFM_Search_Objects"
                                                                     andRecordCount:0];
                for(int m=0; m<[objectsArray count]; m++)
                {

                    
                   
                    
                    NSDictionary *objectDict = [objectsArray objectAtIndex:m];
                    SMLog(kLogLevelVerbose,@"Object ID = %@",[objectDict objectForKey:@"Id"] );
                    
                    parentObjCriteria= [objectDict  objectForKey:@"SVMXC__Advance_Expression__c"];
                    SMLog(kLogLevelVerbose,@"%@",parentObjCriteria);
                    
                    if(![[objectDict  objectForKey:@"SVMXC__Advance_Expression__c"] isEqualToString:@"(null)"])
                    {
                        if(!(parentObjCriteria ==NULL))
                        {
                            parentObjCriteria=[parentObjCriteria stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
                        }
                        else
                        {
                            parentObjCriteria=@"(null)";
                        }
                    }
                    else
                    {
                        parentObjCriteria=@"(null)";
                    }
                    
                    
                    NSString *targetObjectNameFull = [objectDict objectForKey:@"SVMXC__Target_Object_Name__c"];
                    targetObjectNameFull= [targetObjectNameFull stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
                    
                    NSString *targetObjectName = [self getFieldLabelForApiName:targetObjectNameFull];
                    targetObjectName=[targetObjectName stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
                    
                    NSString * Name = [objectDict objectForKey:@"SVMXC__Name__c"];
                    Name = [Name stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
                    
                    NSString * Module = [objectDict objectForKey:@"SVMXC__Module__c"];
                    Module = [Module  stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
                
                    char * _Module = [appDelegate convertStringIntoChar:Module];
                    sqlite3_bind_text(bulkStmt, 1, _Module, strlen(_Module), SQLITE_TRANSIENT);
            
                    char * _process = [appDelegate convertStringIntoChar:[objectDict objectForKey:@"SVMXC__ProcessID__c"]];
                    sqlite3_bind_text(bulkStmt, 2, _process, strlen(_process), SQLITE_TRANSIENT);                
                    
                    char * _targetObjectName = [appDelegate convertStringIntoChar:targetObjectName];
                    sqlite3_bind_text(bulkStmt, 3, _targetObjectName, strlen(_targetObjectName), SQLITE_TRANSIENT);
                
                    char * _processName = [appDelegate convertStringIntoChar:processName];
                    sqlite3_bind_text(bulkStmt, 4, _processName, strlen(_processName), SQLITE_TRANSIENT);
                    
                    char * _processId = [appDelegate convertStringIntoChar:processId];
                    sqlite3_bind_text(bulkStmt, 5, _processId, strlen(_processId), SQLITE_TRANSIENT);

                    char * _Id = [appDelegate convertStringIntoChar:[objectDict objectForKey:@"Id"]];
                    sqlite3_bind_text(bulkStmt, 6, _Id, strlen(_Id), SQLITE_TRANSIENT);

                    char * _parentObjCriteria = [appDelegate convertStringIntoChar:parentObjCriteria];
                    sqlite3_bind_text(bulkStmt, 7, _parentObjCriteria, strlen(_parentObjCriteria), SQLITE_TRANSIENT);

                    char * _Name = [appDelegate convertStringIntoChar:Name];
                    sqlite3_bind_text(bulkStmt, 8, _Name, strlen(_Name), SQLITE_TRANSIENT);

                   if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                   {
                       SMLog(kLogLevelError,@" insertValuesintoSFMObjectTable : Commit Failed! - SFM_Search_Objects \n");
                   }
                    
                   sqlite3_clear_bindings(bulkStmt);
                   sqlite3_reset(bulkStmt);
                   [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:1];
                    
                    NSArray *objectConfigDataArray = [objectDict objectForKey:@"ConfigData"];
                    for(int n=0; n<[objectConfigDataArray count]; n++)
                    {
                        NSDictionary *objectConfigDict = [objectConfigDataArray objectAtIndex:n];
                        NSArray   *keys = [objectConfigDict allKeys];
                        
                        NSString  *fieldNameFull = [objectConfigDict objectForKey:@"SVMXC__Field_Name__c"];
                        NSString  *fieldName = [self getFieldLabelForApiName:fieldNameFull];
                        
                        NSString *objectName2Full = [objectConfigDict objectForKey:@"SVMXC__Object_Name2__c"];
                        NSString *objectName2 = [self getFieldLabelForApiName:objectName2Full];

                        if([keys containsObject:@"SVMXC__Search_Object_Field_Type__c"])
                        {
                            if (resultSearch == SQLITE_OK)
                            {
                                [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"ConfigData : SFM_Search_Field"
                                                                                     andRecordCount:0];
                                
                            
                                char * _Id = [appDelegate convertStringIntoChar:[objectConfigDict objectForKey:@"Id"]];
                                sqlite3_bind_text(bulkStmtForSearch, 1, _Id, strlen(_Id), SQLITE_TRANSIENT);
                                
                                char * _expRules = [appDelegate convertStringIntoChar:[objectConfigDict objectForKey:@"SVMXC__Expression_Rule__c"]];
                                sqlite3_bind_text(bulkStmtForSearch, 2, _expRules, strlen(_expRules), SQLITE_TRANSIENT);
                                
                                char * _fieldName = [appDelegate convertStringIntoChar:fieldName];
                                sqlite3_bind_text(bulkStmtForSearch, 3, _fieldName, strlen(_fieldName), SQLITE_TRANSIENT);
                                
                                char * _objectName2 = [appDelegate convertStringIntoChar:objectName2];
                                sqlite3_bind_text(bulkStmtForSearch, 4, _objectName2, strlen(_objectName2), SQLITE_TRANSIENT);
                                
                                char * _fieldType = [appDelegate convertStringIntoChar:[objectConfigDict objectForKey:@"SVMXC__Search_Object_Field_Type__c"]];
                                sqlite3_bind_text(bulkStmtForSearch, 5, _fieldType, strlen(_fieldType), SQLITE_TRANSIENT);
                                
                                char * _objectId = [appDelegate convertStringIntoChar:[objectDict objectForKey:@"Id"]];
                                sqlite3_bind_text(bulkStmtForSearch, 6, _objectId, strlen(_objectId), SQLITE_TRANSIENT);
                                
                                
                                if (synchronized_sqlite3_step(bulkStmtForSearch) != SQLITE_DONE)
                                {
                                    SMLog(kLogLevelError,@"insertValuesintoSFMObjectTable : Commit Failed! - ConfigData : SFM_Search_Field\n");
                                }
                                
                                sqlite3_clear_bindings(bulkStmtForSearch);
                                sqlite3_reset(bulkStmtForSearch);
                            
                                // Vipin-db-optmz
                                [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"ConfigData : SFM_Search_Field"
                                                                                                  andRecordCount:1];
                                
                                [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:1];
                            }
                            else
                            {
                                  SMLog(kLogLevelError,@"insertValuesintoSFMObjectTable : Prepared Failed! - ConfigData : SFM_Search_Field \n message %d - %@",  resultSearch, [NSString stringWithUTF8String:sqlite3_errmsg(appDelegate.db)]);
                            }
                        }
                        else
                        {
                            if (resultFilter == SQLITE_OK)
                            {
                                // Vipin-db-optmz
                                [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"ConfigData : SFM_Filter_Criteria"
                                                                                     andRecordCount:0];
                                int result = SQLITE_OK;
                                char * _Id = [appDelegate convertStringIntoChar:[objectConfigDict objectForKey:@"Id"]];
                                result = sqlite3_bind_text(bulkStmtForFilter, 1, _Id, strlen(_Id), SQLITE_TRANSIENT);
                                
                                
                                char * _types = [appDelegate convertStringIntoChar:[objectConfigDict objectForKey:@"SVMXC__Display_Type__c"]];
                                result = sqlite3_bind_text(bulkStmtForFilter, 2, _types, strlen(_types), SQLITE_TRANSIENT);
                                
                                
                                char * _expRules = [appDelegate convertStringIntoChar:[objectConfigDict objectForKey:@"SVMXC__Expression_Rule__c"]];
                                result = sqlite3_bind_text(bulkStmtForFilter, 3, _expRules, strlen(_expRules), SQLITE_TRANSIENT);
                                
                                
                                char * _fieldName = [appDelegate convertStringIntoChar:fieldName];
                                result = sqlite3_bind_text(bulkStmtForFilter, 4, _fieldName, strlen(_fieldName), SQLITE_TRANSIENT);
                                
                                char * _objectName2 = [appDelegate convertStringIntoChar:objectName2];
                                result =  sqlite3_bind_text(bulkStmtForFilter, 5, _objectName2, strlen(_objectName2), SQLITE_TRANSIENT);
                                
                                char * _operand = [appDelegate convertStringIntoChar:[objectConfigDict objectForKey:@"SVMXC__Operand__c"]];
                                result = sqlite3_bind_text(bulkStmtForFilter, 6, _operand, strlen(_operand), SQLITE_TRANSIENT);
                                
                                
                                char * _operator = [appDelegate convertStringIntoChar:[objectConfigDict objectForKey:@"SVMXC__Operator__c"]];
                                result = sqlite3_bind_text(bulkStmtForFilter, 7, _operator, strlen(_operator), SQLITE_TRANSIENT);
                                
                                char * _objectId = [appDelegate convertStringIntoChar:[objectDict objectForKey:@"Id"]];
                                result = sqlite3_bind_text(bulkStmtForFilter, 8, _objectId, strlen(_objectId), SQLITE_TRANSIENT);
                                
                                int successfullyExecuted = synchronized_sqlite3_step(bulkStmtForFilter);
                                
                                if ( successfullyExecuted != SQLITE_DONE)
                                {
                                    SMLog(kLogLevelError,@"insertValuesintoSFMObjectTable : Commit Failed! - ConfigData : SFM_Filter_Criteria \n message %d - %@",  successfullyExecuted, [NSString stringWithUTF8String:sqlite3_errmsg(appDelegate.db)]);
                                }
                                
                                sqlite3_clear_bindings(bulkStmtForFilter);
                                sqlite3_reset(bulkStmtForFilter);
                                
                                // Vipin-db-optmz
                                [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"ConfigData : SFM_Filter_Criteria"
                                                                                                  andRecordCount:1];
                                
                                [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:1];
                                
                            }else
                            {
                                SMLog(kLogLevelError,@"insertValuesintoSFMObjectTable : Prepared Failed! - ConfigData : SFM_Filter_Criteria\n message %d - %@",  resultFilter, [NSString stringWithUTF8String:sqlite3_errmsg(appDelegate.db)]);
                            }
                        }
                        

                    }
                }
                
                // Vipin-db-optmz
                [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"SFM_Search_Objects"
                                                                                  andRecordCount:[objectsArray count]];
            }
            else
            {
                
                SMLog(kLogLevelError,@"insertValuesintoSFMObjectTable : prepare Failed! - SFM_Search_Objects - second\n message : %d - %@", result, [NSString stringWithUTF8String:sqlite3_errmsg(appDelegate.db)]);
                
            }
            
            synchronized_sqlite3_finalize(bulkStmtForFilter);
            synchronized_sqlite3_finalize(bulkStmtForSearch);
            synchronized_sqlite3_finalize(bulkStmt);
            
        }
    }
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"SFM_Search_Process"
                                                                      andRecordCount:[processData count]];
    [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:0];
    
    
    // Vipin-db-optmz
    [self endTransaction];
    
    synchronized_sqlite3_finalize(preparedStmtSearchObject);
    synchronized_sqlite3_finalize(preparedStmtSearchFieldSorting);
    synchronized_sqlite3_finalize(preparedStmtSearchField);
    synchronized_sqlite3_finalize(preparedStmtFilterCriteria);
    
    [pool drain];
    pool = nil;
}

- (NSMutableArray *) getSFMSearchConfigurationSettings
{
    NSMutableArray *configSettings = [[NSMutableArray alloc] init];
    NSString *processQuery = [NSString stringWithFormat:@"SELECT Name,SVMXC__Description__c,SVMXC__Name__c,Id FROM SFM_Search_Process"];
    sqlite3_stmt * statement;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [processQuery UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *processDict = [[NSMutableDictionary alloc] init];

            const char * name = (char *)synchronized_sqlite3_column_text(statement, 0);
            if ((name !=nil) && strlen(name))
                [processDict setObject:[NSString stringWithUTF8String:name] forKey:@"Name"] ;
            else
                [processDict setObject:@"" forKey:@"Name"] ;

            const char * description = (char *)synchronized_sqlite3_column_text(statement, 1);
            if ((description != nil) && strlen(description))
                [processDict setObject:[NSString stringWithUTF8String:description] forKey:@"SVMXC__Description__c"] ;
            else
                [processDict setObject:@"" forKey:@"SVMXC__Description__c"] ;

            const char * search_process_name = (char *)synchronized_sqlite3_column_text(statement, 2);
            if ((search_process_name != nil) && strlen(search_process_name))
                [processDict setObject:[NSString stringWithUTF8String:search_process_name] forKey:@"SVMXC__Name__c"] ;
            else
                [processDict setObject:@"" forKey:@"SVMXC__Name__c"] ;
            
            const char * processId = (char *)synchronized_sqlite3_column_text(statement, 3);
            if ((processId != nil) && strlen(processId))
                [processDict setObject:[NSString stringWithUTF8String:processId] forKey:@"Id"] ;
            else
                [processDict setObject:@"" forKey:@"Id"] ;

            
            /*
            sqlite3_stmt * objectStatement;
            NSMutableArray *objectArray = [[NSMutableArray alloc] init];
            if (synchronized_sqlite3_prepare_v2(appDelegate.db, [objectQuery UTF8String], -1, &objectStatement, NULL) == SQLITE_OK)
            {
                while (synchronized_sqlite3_step(objectStatement) == SQLITE_ROW)
                {
                    NSMutableDictionary *objectDict = [[NSMutableDictionary alloc] init];
                    const char * object_processid = (char *)synchronized_sqlite3_column_text(objectStatement, 0);
                    if ((object_processid != nil)&& strlen(object_processid))
                        [objectDict setObject:[NSString stringWithUTF8String:object_processid] forKey:@"ObjectId"] ;
                    else
                        [objectDict setObject:@"" forKey:@"ObjectId"] ;
                    
                    const char * object_name = (char *)synchronized_sqlite3_column_text(objectStatement, 1);
                    if ((object_name!=nil)&&strlen(object_name))
                        [objectDict setObject:[NSString stringWithUTF8String:object_name] forKey:@"ObjectName"] ;
                    else
                        [objectDict setObject:@"" forKey:@"ObjectName"] ;
                    
                    const char * object_Description = (char *)synchronized_sqlite3_column_text(objectStatement, 2);
                    if ((object_Description!=nil)&&strlen(object_Description))
                        [objectDict setObject:[NSString stringWithUTF8String:object_Description] forKey:@"ObjectDescription"] ;
                    else
                        [objectDict setObject:@"" forKey:@"ObjectDescription"] ;
                    // get searchable fields
                    NSMutableArray *searchableFieldsArray = [[self getSearchableFieldsForObject:[objectDict objectForKey:@"ObjectId"]] retain];
                    [objectDict setObject:searchableFieldsArray forKey:@"SearchableFields"] ;
                    [searchableFieldsArray release];
                    //get display fields
                    NSMutableArray *displayFieldsArray = [[self getDisplayFieldsForObject:[objectDict objectForKey:@"ObjectId"]] retain];
                    [objectDict setObject:displayFieldsArray forKey:@"DisplayFields"] ;
                    [displayFieldsArray release];
                    //get search criteria fields
                    NSMutableArray *searchCriteriaArray = [[self getSearchCriteriaForObject:[objectDict objectForKey:@"ObjectId"]] retain];
                    [objectDict setObject:searchCriteriaArray forKey:@"SearchCriteriaFields"] ;
                    [searchCriteriaArray release];

                    [objectArray addObject:objectDict];
                    [objectDict release];
                }
            }
             synchronized_sqlite3_finalize(objectStatement);
             
            [processDict setObject:objectArray forKey:@"Objects"];
            [objectArray release];
             */
            [configSettings addObject:processDict];
            [processDict release];
        }
    }
    
    synchronized_sqlite3_finalize(statement);
    return [configSettings autorelease];
}
- (NSArray *) getConfigurationForProcess:(NSString *) processName 
{
    sqlite3_stmt * objectStatement;
    NSString *objectQuery = [NSString stringWithFormat:@"SELECT ObjectId,SVMXC__Target_Object_Name__c,SVMXC__Name__c FROM SFM_Search_Objects where ProcessName = '%@'",processName];
    SMLog(kLogLevelVerbose,@"Object Query = %@",objectQuery);
    NSMutableArray *objectArray = [[NSMutableArray alloc] init];
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [objectQuery UTF8String], -1, &objectStatement, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(objectStatement) == SQLITE_ROW)
        {
            NSMutableDictionary *objectDict = [[NSMutableDictionary alloc] init];
            const char * object_processid = (char *)synchronized_sqlite3_column_text(objectStatement, 0);
            if ((object_processid != nil)&& strlen(object_processid))
                [objectDict setObject:[NSString stringWithUTF8String:object_processid] forKey:@"ObjectId"] ;
            else
                [objectDict setObject:@"" forKey:@"ObjectId"] ;
            
            const char * object_name = (char *)synchronized_sqlite3_column_text(objectStatement, 1);
            if ((object_name!=nil)&&strlen(object_name))
                [objectDict setObject:[NSString stringWithUTF8String:object_name] forKey:@"ObjectName"] ;
            else
                [objectDict setObject:@"" forKey:@"ObjectName"] ;
            
            const char * object_Description = (char *)synchronized_sqlite3_column_text(objectStatement, 2);
            if ((object_Description!=nil)&&strlen(object_Description))
                [objectDict setObject:[NSString stringWithUTF8String:object_Description] forKey:@"ObjectDescription"] ;
            else
                [objectDict setObject:@"" forKey:@"ObjectDescription"] ;
            // get searchable fields
            NSMutableArray *searchableFieldsArray = [[self getSearchableFieldsForObject:[objectDict objectForKey:@"ObjectId"]] retain];
            [objectDict setObject:searchableFieldsArray forKey:@"SearchableFields"] ;
            [searchableFieldsArray release];
            //get display fields
            NSMutableArray *displayFieldsArray = [[self getDisplayFieldsForObject:[objectDict objectForKey:@"ObjectId"]] retain];
            [objectDict setObject:displayFieldsArray forKey:@"DisplayFields"] ;
            [displayFieldsArray release];
            //get search criteria fields
            NSMutableArray *searchCriteriaArray = [[self getSearchCriteriaForObject:[objectDict objectForKey:@"ObjectId"]] retain];
            [objectDict setObject:searchCriteriaArray forKey:@"SearchCriteriaFields"] ;
            [searchCriteriaArray release];
            if(appDelegate.isSfmSearchSortingAvailable)
            {
                NSMutableArray *sortfieldArray = [[self getSortObjects:[objectDict objectForKey:@"ObjectId"]] retain];
                [objectDict setObject:sortfieldArray forKey:@"SortingFields"] ;
                [sortfieldArray release];
            }
            [objectArray addObject:objectDict];
            [objectDict release];
        }
    }
    synchronized_sqlite3_finalize(objectStatement);
    
    return [objectArray autorelease];
}
- (NSMutableArray *) getSearchableFieldsForObject:(NSString *)objectId
{
    NSMutableArray *searchableArray = [[NSMutableArray alloc] init];
    NSArray *fieldArray;
    if(appDelegate.isSfmSearchSortingAvailable)
    {
         fieldArray=[[NSArray alloc] initWithObjects:OBJECT_ID,FIELD_NAME,OBJECT_NAME2,LOOKUP_FIELD_API_NAME, FIELD_RELATIONSHIP_NAME, OBJECT_FIELD_NAME,nil];
//        objectQuery = [NSString stringWithFormat:@"SELECT Id,SVMXC__Field_Name__c, SVMXC__Object_Name2__c,SVMXC__Lookup_Field_API_Name__c,SVMXC__Field_Relationship_Name__c,SVMXC__Object_Name__c FROM SFM_Search_Field where SVMXC__Search_Object_Field_Type__c = 'Search' and ObjectId = '%@'",objectId];
    }
    else
    {
        fieldArray=[[NSArray alloc] initWithObjects:OBJECT_ID,FIELD_NAME,OBJECT_NAME2,nil];;

//        objectQuery = [NSString stringWithFormat:@"SELECT Id,SVMXC__Field_Name__c, SVMXC__Object_Name2__c FROM SFM_Search_Field where SVMXC__Search_Object_Field_Type__c = 'Search' and ObjectId = '%@'",objectId];
    }
    NSMutableString *selectString=[[NSMutableString alloc]init];;
    for (int i=0; i<[fieldArray count]; i++) {
        if(i !=0)
            [selectString appendString:@" , "];
        [selectString appendString:[fieldArray objectAtIndex:i]];
    }
    NSString *objectQuery=[NSString stringWithFormat:@"SELECT %@ FROM SFM_Search_Field where SVMXC__Search_Object_Field_Type__c = 'Search' and ObjectId = '%@'",selectString,objectId];

    sqlite3_stmt * objectStatement;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [objectQuery UTF8String], -1, &objectStatement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(objectStatement) == SQLITE_ROW)
        {
            NSMutableDictionary *searchDict = [[NSMutableDictionary alloc] init];
            /*
            const char * searchid = (char *)synchronized_sqlite3_column_text(objectStatement, 0);
            if (strlen(searchid))
                [searchDict setObject:[NSString stringWithUTF8String:searchid] forKey:@"Id"] ;
            else
                [searchDict setObject:@"" forKey:@"Id"] ;
            
            const char * field_name = (char *)synchronized_sqlite3_column_text(objectStatement, 1);
            if (strlen(field_name))
                [searchDict setObject:[NSString stringWithUTF8String:field_name] forKey:@"SVMXC__Field_Name__c"] ;
            else
                [searchDict setObject:@"" forKey:@"SVMXC__Field_Name__c"] ;

            const char * object_name = (char *)synchronized_sqlite3_column_text(objectStatement, 2);
            if (strlen(object_name))
                [searchDict setObject:[NSString stringWithUTF8String:object_name] forKey:@"SVMXC__Object_Name2__c"] ;
            else
                [searchDict setObject:@"" forKey:@"SVMXC__Object_Name2__c"] ;
            
            const char * lookUpfield = (char *)synchronized_sqlite3_column_text(objectStatement, 3);
            if (strlen(lookUpfield))
                [searchDict setObject:[NSString stringWithUTF8String:lookUpfield] forKey:@"SVMXC__Lookup_Field_API_Name__c"] ;
            else
                [searchDict setObject:@"" forKey:@"SVMXC__Lookup_Field_API_Name__c"] ;

            const char * fieldRelation = (char *)synchronized_sqlite3_column_text(objectStatement, 4);
            if (strlen(fieldRelation))
                [searchDict setObject:[NSString stringWithUTF8String:fieldRelation] forKey:@"SVMXC__Field_Relationship_Name__c"] ;
            else
                [searchDict setObject:@"" forKey:@"SVMXC__Field_Relationship_Name__c"] ;
            
            const char * objectName = (char *)synchronized_sqlite3_column_text(objectStatement, 5);
            if (strlen(objectName))
                [searchDict setObject:[NSString stringWithUTF8String:objectName] forKey:@"SVMXC__Object_Name__c"] ;
            else
                [searchDict setObject:@"" forKey:@"SVMXC__Object_Name__c"] ;
            */
            //
            
            for(int i = 0 ; i< [fieldArray count]; i++)
            {
                NSString * key = [fieldArray objectAtIndex:i];
                char * temp_value= (char *)synchronized_sqlite3_column_text(objectStatement, i);
                NSString *value=@"";
                if(temp_value != nil)
                {
                    value = [NSString stringWithUTF8String:temp_value];
                    [searchDict setObject:value forKey:key];
                }
            }
            [searchableArray addObject:searchDict];
            [searchDict release];
        }
    }
    [selectString release];
    synchronized_sqlite3_finalize(objectStatement);
    return [searchableArray autorelease];
    
}
- (NSMutableArray *) getDisplayFieldsForObject:(NSString *)objectId
{
    NSMutableArray *displayFieldsArray = [[NSMutableArray alloc] init];
    NSArray *fieldKeys;
    if(appDelegate.isSfmSearchSortingAvailable)
    {
        fieldKeys=[[NSArray alloc] initWithObjects:OBJECT_ID,FIELD_NAME,OBJECT_NAME2,LOOKUP_FIELD_API_NAME, FIELD_RELATIONSHIP_NAME, OBJECT_FIELD_NAME,nil];
//        NSString *objectQuery = [NSString stringWithFormat:@"SELECT Id,SVMXC__Field_Name__c, SVMXC__Object_Name2__c,SVMXC__Lookup_Field_API_Name__c,SVMXC__Field_Relationship_Name__c,SVMXC__Object_Name__c FROM SFM_Search_Field where SVMXC__Search_Object_Field_Type__c = 'Result' and ObjectId = '%@'",objectId];
    }
    else
    {
        fieldKeys=[[NSArray alloc] initWithObjects:OBJECT_ID,FIELD_NAME,OBJECT_NAME2,nil];
//        NSString *objectQuery = [NSString stringWithFormat:@"SELECT Id,SVMXC__Field_Name__c, SVMXC__Object_Name2__c FROM SFM_Search_Field where SVMXC__Search_Object_Field_Type__c = 'Result' and ObjectId = '%@'",objectId];    
    }
    
    NSMutableString *selectString=[[NSMutableString alloc]init];;
    for (int i=0; i<[fieldKeys count]; i++) {
        if(i !=0)
            [selectString appendString:@" , "];
        [selectString appendString:[fieldKeys objectAtIndex:i]];
    }
    
    NSString *objectQuery = [NSString stringWithFormat:@"SELECT %@ FROM SFM_Search_Field where SVMXC__Search_Object_Field_Type__c = 'Result' and ObjectId = '%@'",selectString,objectId];
    sqlite3_stmt * objectStatement;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [objectQuery UTF8String], -1, &objectStatement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(objectStatement) == SQLITE_ROW)
        {
            NSMutableDictionary *displayDict = [[NSMutableDictionary alloc] init];
            /*
            const char * displayid = (char *)synchronized_sqlite3_column_text(objectStatement, 0);
            if (strlen(displayid))
                [displayDict setObject:[NSString stringWithUTF8String:displayid] forKey:@"Id"] ;
            else
                [displayDict setObject:@"" forKey:@"Id"] ;
            
            const char * field_name = (char *)synchronized_sqlite3_column_text(objectStatement, 1);
            if (strlen(field_name))
                [displayDict setObject:[NSString stringWithUTF8String:field_name] forKey:@"SVMXC__Field_Name__c"] ;
            else
                [displayDict setObject:@"" forKey:@"SVMXC__Field_Name__c"] ;
            
            const char * object_name = (char *)synchronized_sqlite3_column_text(objectStatement, 2);
            if (strlen(object_name))
                [displayDict setObject:[NSString stringWithUTF8String:object_name] forKey:@"SVMXC__Object_Name2__c"] ;
            else
                [displayDict setObject:@"" forKey:@"SVMXC__Object_Name2__c"] ;
            
            const char * lookuField = (char *)synchronized_sqlite3_column_text(objectStatement, 3);
            if (strlen(lookuField))
                [displayDict setObject:[NSString stringWithUTF8String:lookuField] forKey:@"SVMXC__Lookup_Field_API_Name__c"] ;
            else
                [displayDict setObject:@"" forKey:@"SVMXC__Lookup_Field_API_Name__c"] ;
            
            const char * fieldRelation = (char *)synchronized_sqlite3_column_text(objectStatement, 4);
            if (strlen(fieldRelation))
                [displayDict setObject:[NSString stringWithUTF8String:fieldRelation] forKey:@"SVMXC__Field_Relationship_Name__c"] ;
            else
                [displayDict setObject:@"" forKey:@"SVMXC__Field_Relationship_Name__c"] ;
            
            const char * objectName = (char *)synchronized_sqlite3_column_text(objectStatement, 5);
            if (strlen(objectName))
                [displayDict setObject:[NSString stringWithUTF8String:objectName] forKey:@"SVMXC__Object_Name__c"] ;
            else
                [displayDict setObject:@"" forKey:@"SVMXC__Object_Name__c"] ;
            */
            for(int i = 0 ; i< [fieldKeys count]; i++)
            {
                NSString * key = [fieldKeys objectAtIndex:i];
                char * temp_value= (char *)synchronized_sqlite3_column_text(objectStatement, i);
                NSString *value=@"";
                if(temp_value != nil)
                {
                    value = [NSString stringWithUTF8String:temp_value];
                    [displayDict setObject:value forKey:key];
                }
            }
            [displayFieldsArray addObject:displayDict];
            [displayDict release];
        }
    }
    synchronized_sqlite3_finalize(objectStatement);
    return [displayFieldsArray autorelease];
}
- (NSMutableArray *) getSearchCriteriaForObject:(NSString *)objectId
{
    NSMutableArray *searchCriteriaArray = [[NSMutableArray alloc] init];
    NSArray *fieldKeys;
    if(appDelegate.isSfmSearchSortingAvailable)
    {
        fieldKeys=[[NSArray alloc] initWithObjects:OBJECT_ID,DISPLAY_TYPE,FIELD_NAME,OBJECT_NAME2,OPERAND,OPERATOR,OBJECT_FIELD_NAME, FIELD_RELATIONSHIP_NAME,nil];
//        NSString *objectQuery = [NSString stringWithFormat:@"SELECT Id,SVMXC__Display_Type__c,SVMXC__Field_Name__c, SVMXC__Object_Name2__c,SVMXC__Operand__c,SVMXC__Operator__c,SVMXC__Object_Name__c,SVMXC__Field_Relationship_Name__c FROM SFM_Search_Filter_Criteria where ObjectId = '%@'",objectId];
    }
    else
    {
        fieldKeys=[[NSArray alloc] initWithObjects:OBJECT_ID,DISPLAY_TYPE,FIELD_NAME,OBJECT_NAME2,OPERAND,OPERATOR,nil];
//        NSString *objectQuery = [NSString stringWithFormat:@"SELECT Id,SVMXC__Display_Type__c,SVMXC__Field_Name__c, SVMXC__Object_Name2__c,SVMXC__Operand__c,SVMXC__Operator__c FROM SFM_Search_Filter_Criteria where ObjectId = '%@'",objectId];
    }

    NSMutableString *selectString=[[NSMutableString alloc]init];;
    for (int i=0; i<[fieldKeys count]; i++) {
        if(i !=0)
            [selectString appendString:@" , "];
        [selectString appendString:[fieldKeys objectAtIndex:i]];
    }
    NSString *objectQuery =[NSString stringWithFormat:@"SELECT %@ FROM SFM_Search_Filter_Criteria where ObjectId = '%@'",selectString,objectId];
    sqlite3_stmt * objectStatement;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [objectQuery UTF8String], -1, &objectStatement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(objectStatement) == SQLITE_ROW)
        {
            NSMutableDictionary *searchCriteriaDict = [[NSMutableDictionary alloc] init];
          /*
            const char * criteriaid = (char *)synchronized_sqlite3_column_text(objectStatement, 0);
            if (strlen(criteriaid))
                [searchCriteriaDict setObject:[NSString stringWithUTF8String:criteriaid] forKey:@"Id"] ;
            else
                [searchCriteriaDict setObject:@"" forKey:@"Id"] ;

            const char * display_type = (char *)synchronized_sqlite3_column_text(objectStatement, 1);
            if (strlen(display_type))
                [searchCriteriaDict setObject:[NSString stringWithUTF8String:display_type] forKey:@"SVMXC__Display_Type__c"] ;
            else
                [searchCriteriaDict setObject:@"" forKey:@"SVMXC__Display_Type__c"] ;

            const char * field_name = (char *)synchronized_sqlite3_column_text(objectStatement, 2);
            if (strlen(field_name))
                [searchCriteriaDict setObject:[NSString stringWithUTF8String:field_name] forKey:@"SVMXC__Field_Name__c"] ;
            else
                [searchCriteriaDict setObject:@"" forKey:@"SVMXC__Field_Name__c"] ;
            
            const char * object_name = (char *)synchronized_sqlite3_column_text(objectStatement, 3);
            if (strlen(object_name))
                [searchCriteriaDict setObject:[NSString stringWithUTF8String:object_name] forKey:@"SVMXC__Object_Name2__c"] ;
            else
                [searchCriteriaDict setObject:@"" forKey:@"SVMXC__Object_Name2__c"] ;

            const char * operand = (char *)synchronized_sqlite3_column_text(objectStatement, 4);
            if (strlen(operand))
                [searchCriteriaDict setObject:[NSString stringWithUTF8String:operand] forKey:@"SVMXC__Operand__c"] ;
            else
                [searchCriteriaDict setObject:@"" forKey:@"SVMXC__Operand__c"] ;

            const char * operator = (char *)synchronized_sqlite3_column_text(objectStatement, 5);
            if (strlen(operator))
                [searchCriteriaDict setObject:[NSString stringWithUTF8String:operator] forKey:@"SVMXC__Operator__c"] ;
            else
                [searchCriteriaDict setObject:@"" forKey:@"SVMXC__Operator__c"] ;

            const char * objName = (char *)synchronized_sqlite3_column_text(objectStatement, 6);
            if (strlen(objName))
                [searchCriteriaDict setObject:[NSString stringWithUTF8String:objName] forKey:@"SVMXC__Object_Name__c"] ;
            else
                [searchCriteriaDict setObject:@"" forKey:@"SVMXC__Object_Name__c"] ;
            const char * fieldRelation = (char *)synchronized_sqlite3_column_text(objectStatement, 7);
            if (strlen(fieldRelation))
                [searchCriteriaDict setObject:[NSString stringWithUTF8String:fieldRelation] forKey:@"SVMXC__Field_Relationship_Name__c"] ;
            else
                [searchCriteriaDict setObject:@"" forKey:@"SVMXC__Field_Relationship_Name__c"] ;
           */
            for(int i = 0 ; i< [fieldKeys count]; i++)
            {
                NSString * key = [fieldKeys objectAtIndex:i];
                char * temp_value= (char *)synchronized_sqlite3_column_text(objectStatement, i);
                NSString *value=@"";
                if(temp_value != nil)
                {
                    value = [NSString stringWithUTF8String:temp_value];
                    [searchCriteriaDict setObject:value forKey:key];
                }
            }

            [searchCriteriaArray addObject:searchCriteriaDict];
            [searchCriteriaDict release];
        }
    }
    synchronized_sqlite3_finalize(objectStatement);
    return [searchCriteriaArray autorelease];

}
-(NSMutableArray*)getSortObjects:(NSString *)objectId
{
    NSMutableArray *sortObjectArray = [[NSMutableArray alloc] init];
    NSString *objectQuery = [NSString stringWithFormat:@"SELECT Id,SVMXC__Field_Name__c, SVMXC__Object_Name2__c,SVMXC__Lookup_Field_API_Name__c,SVMXC__Field_Relationship_Name__c,SVMXC__Object_Name__c,SVMXC__Sort_Order__c FROM SFM_Search_Field where SVMXC__Search_Object_Field_Type__c = 'OrderBy' and ObjectId = '%@'",objectId];
    sqlite3_stmt * objectStatement;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [objectQuery UTF8String], -1, &objectStatement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(objectStatement) == SQLITE_ROW)
        {
            NSMutableDictionary *sortingDict = [[NSMutableDictionary alloc] init];
            const char * displayid = (char *)synchronized_sqlite3_column_text(objectStatement, 0);
            if (strlen(displayid))
                [sortingDict setObject:[NSString stringWithUTF8String:displayid] forKey:@"Id"] ;
            else
                [sortingDict setObject:@"" forKey:@"Id"] ;
            
            const char * field_name = (char *)synchronized_sqlite3_column_text(objectStatement, 1);
            if (strlen(field_name))
                [sortingDict setObject:[NSString stringWithUTF8String:field_name] forKey:@"SVMXC__Field_Name__c"] ;
            else
                [sortingDict setObject:@"" forKey:@"SVMXC__Field_Name__c"] ;
            
            const char * object_name = (char *)synchronized_sqlite3_column_text(objectStatement, 2);
            if (strlen(object_name))
                [sortingDict setObject:[NSString stringWithUTF8String:object_name] forKey:@"SVMXC__Object_Name2__c"] ;
            else
                [sortingDict setObject:@"" forKey:@"SVMXC__Object_Name2__c"] ;
            
            const char * lookuField = (char *)synchronized_sqlite3_column_text(objectStatement, 3);
            if (strlen(lookuField))
                [sortingDict setObject:[NSString stringWithUTF8String:lookuField] forKey:@"SVMXC__Lookup_Field_API_Name__c"] ;
            else
                [sortingDict setObject:@"" forKey:@"SVMXC__Lookup_Field_API_Name__c"] ;
            
            const char * fieldRelation = (char *)synchronized_sqlite3_column_text(objectStatement, 4);
            if (strlen(fieldRelation))
                [sortingDict setObject:[NSString stringWithUTF8String:fieldRelation] forKey:@"SVMXC__Field_Relationship_Name__c"] ;
            else
                [sortingDict setObject:@"" forKey:@"SVMXC__Field_Relationship_Name__c"] ;
            
            const char * objectName = (char *)synchronized_sqlite3_column_text(objectStatement, 5);
            if (strlen(objectName))
                [sortingDict setObject:[NSString stringWithUTF8String:objectName] forKey:@"SVMXC__Object_Name__c"] ;
            else
                [sortingDict setObject:@"" forKey:@"SVMXC__Object_Name__c"] ;
            
            const char * sortOrder = (char *)synchronized_sqlite3_column_text(objectStatement, 6);
            if (strlen(sortOrder))
                [sortingDict setObject:[NSString stringWithUTF8String:sortOrder] forKey:@"SVMXC__Sort_Order__c"] ;
            else
                [sortingDict setObject:@"" forKey:@"SVMXC__Sort_Order__c"] ;
            
            [sortObjectArray addObject:sortingDict];
            [sortingDict release];
        }
    }
    synchronized_sqlite3_finalize(objectStatement);
    return [sortObjectArray autorelease];
}
- (NSMutableArray *) getResults:(NSString *)object withConfigData:(NSDictionary *)dataForObject
{
    NSMutableArray *searchableArray = [dataForObject objectForKey:@"SearchableFields"];
    if(![searchableArray count]>0)
    {
        NSMutableDictionary *dictforSearchObject=[[NSMutableDictionary alloc]init];
        [dictforSearchObject setObject:object forKey:@"SVMXC__Object_Name2__c"];
        [dictforSearchObject setObject:[self getNameFiled:object] forKey:@"SVMXC__Field_Name__c"];
        [searchableArray addObject:dictforSearchObject];
    }
    NSDictionary *uiControlsValue=[dataForObject objectForKey:@"uiControls"];
    NSArray *displayArray = [dataForObject objectForKey:@"DisplayFields"];
    NSMutableArray *displayFieldsArray = [[NSMutableArray alloc] init];
    NSMutableArray *TableArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *tableArrayDict=[[NSMutableDictionary alloc]init];
    NSArray *criteriaArray = [dataForObject objectForKey:@"SearchCriteriaFields"];
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSMutableString *finalQuery = [[NSMutableString alloc] init];
    NSMutableArray* refrenceObjectAtIndex=[[NSMutableArray alloc]init ];
    NSMutableString *queryFields = [[NSMutableString alloc] init];
    NSMutableString *joinFields = [[NSMutableString alloc] init];
    NSDictionary *dict;
    NSString *objectId=[dataForObject  objectForKey:@"ObjectId"];
    NSMutableDictionary *dictforparsing=[[NSMutableDictionary alloc]init];
    NSDictionary *logicalParsingResult=[[NSDictionary alloc ]init];
    NSMutableArray *searchFieldsArr=[[NSMutableArray alloc]init];
    NSMutableString *customizeSearch=[[NSMutableString alloc]init];
    [dictforparsing setObject:object forKey:@"object"];
    int fieldsCount = 2;
    /*
     NSString *refrence_to=[self getReferencetoFiledForObject:[self getApiNameFromFieldLabel:[[displayArray objectAtIndex:0]objectForKey:@"SVMXC__Object_Name2__c"]] api_Name:[[displayArray objectAtIndex:0]objectForKey:@"SVMXC__Field_Name__c"]];
     if([refrence_to length]>0)
     [queryFields appendString:[NSString stringWithFormat:@"'%@'.Id",refrence_to]];
     else
     */
    [queryFields appendString:[NSString stringWithFormat:@"'%@'.Id",object]]; // Change it to 1st display field
    
    [queryFields appendString:@","];
    [queryFields appendString:[NSString stringWithFormat:@"'%@'.local_id",object]];
    @try
    {
        for(int i=0; i<[displayArray count]; i++)
        {
            [queryFields appendString:@","];
            NSString *fieldName = [[displayArray objectAtIndex:i] objectForKey:@"SVMXC__Field_Name__c"];
            NSString *TableName = [[displayArray objectAtIndex:i] objectForKey:@"SVMXC__Object_Name2__c"];
            NSMutableArray *fieldArrayTogetassociatedtable=[[[NSMutableArray alloc]init]autorelease];
            NSString *ApifieldName = [self getApiNameFromFieldLabel:fieldName];
            [fieldArrayTogetassociatedtable addObject:ApifieldName];
            NSString *ApiTableName = [self getApiNameFromFieldLabel:TableName];
            [fieldArrayTogetassociatedtable addObject:ApiTableName];
            [queryFields appendFormat:@"'%@'.%@",ApiTableName,ApifieldName];
            for (int i=0; i<[fieldArrayTogetassociatedtable count]; i++)
            {
                
                NSMutableString * queryStatementIstable = [[NSMutableString alloc]initWithCapacity:0];
                queryStatementIstable = [NSMutableString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@'",[fieldArrayTogetassociatedtable objectAtIndex:i]];
                sqlite3_stmt * labelstmt;
                const char *selectStatement = [queryStatementIstable UTF8String];
                char *fieldIsTable=nil;
                if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
                {
                    if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
                    {
                        fieldIsTable = (char *) synchronized_sqlite3_column_text(labelstmt,0);
                        
                    }
                }
                
                synchronized_sqlite3_finalize(labelstmt);
                
                if(!(fieldIsTable != nil &&strlen(fieldIsTable)))
                {
                    sqlite3_stmt * labelstmtGetTableName;
                    NSMutableString * queryStatementGetTableName= [[NSMutableString alloc]initWithCapacity:0];
                    queryStatementGetTableName = [NSMutableString stringWithFormat:@"SELECT reference_to FROM SFReferenceTo where object_api_name='%@' and field_api_name='%@'",object,[fieldArrayTogetassociatedtable objectAtIndex:i]];
                    const char *selectStatementGetTableName = [queryStatementGetTableName UTF8String];
                    char *TableName=nil;
                    NSString *strTableName=@"";
                    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatementGetTableName,-1, &labelstmtGetTableName, nil) == SQLITE_OK )
                    {
                        if(synchronized_sqlite3_step(labelstmtGetTableName) == SQLITE_ROW)
                        {
                            TableName=(char *) synchronized_sqlite3_column_text(labelstmtGetTableName,0);
                            if(TableName !=nil && strlen(TableName))
                            {
                                strTableName=[NSString stringWithFormat:@"%s",TableName];
                            }
                        }
                    }
                    synchronized_sqlite3_finalize(labelstmtGetTableName);
                    if([strTableName length]>0)
                    {
                        if(![TableArray containsObject:strTableName]&& [strTableName length]>0)
                        {
                            [TableArray addObject:strTableName];
                            NSMutableArray * arry = [[NSMutableArray alloc] initWithCapacity:0];
                            [arry addObject:ApifieldName];
                            [tableArrayDict setObject:arry forKey:strTableName ];
                        }
                        else
                        {
                            NSMutableArray * array =  [tableArrayDict objectForKey:strTableName];
                            [array addObject:ApifieldName];
                        }
                    }
                    
                }
                if((fieldIsTable != nil &&strlen(fieldIsTable))&& [ApiTableName length] > 0)
                {
                    if(![TableArray containsObject:ApiTableName] )
                    {
                        [TableArray addObject:ApiTableName];
                        NSMutableArray * arry = [[NSMutableArray alloc] initWithCapacity:0];
                        [arry addObject:ApifieldName];
                        //                    [tableArrayDict setObject:ApifieldName forKey:ApiTableName ];
                        [tableArrayDict setObject:arry forKey:ApiTableName ];
                    }
                    else
                    {
                        NSMutableArray * array =  [tableArrayDict objectForKey:ApiTableName];
                        [array addObject:ApifieldName];
                    }
                }
            }
            [displayFieldsArray addObject:ApifieldName];
            
            fieldsCount++;
        }
        for(int i=0; i<[searchableArray count]; i++)
        {
            NSString *searchableField = [[searchableArray objectAtIndex:i] objectForKey:@"SVMXC__Field_Name__c"];
            NSString *searchableObject = [self getApiNameFromFieldLabel:[[searchableArray objectAtIndex:i] objectForKey:@"SVMXC__Object_Name2__c"]];
            if([searchableObject length] > 0)
            {
                if(![TableArray containsObject:searchableObject] )
                {
                    [TableArray addObject:searchableObject];
                    NSMutableArray * arry = [[NSMutableArray alloc] initWithCapacity:0];
                    [arry addObject:searchableField];
                    //            [tableArrayDict setObject:searchableField forKey:searchableObject ];
                    [tableArrayDict setObject:arry forKey:searchableObject ];
                    
                }
                else
                {
                    //            NSArray *  allKeys = [tableArrayDict allKeys];
                    NSMutableArray * array =  [tableArrayDict objectForKey:searchableObject];
                    [array addObject:searchableField];
                    
                }
            }
            searchableField = [self getApiNameFromFieldLabel:searchableField];
            NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
            NSString *searchableFieldTableName=@"";
            queryStatement1 = [NSMutableString stringWithFormat:@"SELECT label FROM SFObjectField where object_api_name = '%@'and api_name='%@'",object,searchableField];
            sqlite3_stmt * labelstmt;
            const char *selectStatement = [queryStatement1 UTF8String];
            char *field1=nil;
            if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
            {
                if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
                {
                    field1 = (char *) synchronized_sqlite3_column_text(labelstmt,0);
                    if((field1 !=nil) && strlen(field1))
                        searchableFieldTableName = [self getApiNameFromFieldLabel:[NSString stringWithFormat:@"%s",field1]];
                    else
                        searchableFieldTableName = @"";
                }
            }
            
            synchronized_sqlite3_finalize(labelstmt);
            
            NSMutableString * queryStatementIstable = [[NSMutableString alloc]initWithCapacity:0];
            queryStatementIstable = [NSMutableString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@'",searchableFieldTableName];
            sqlite3_stmt * labelstmtIstable ;
            const char *selectStatementIstable  = [queryStatementIstable UTF8String];
            char *fieldIsTable=nil;
            if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatementIstable ,-1, &labelstmtIstable , nil) == SQLITE_OK )
            {
                if(synchronized_sqlite3_step(labelstmtIstable) == SQLITE_ROW)
                {
                    fieldIsTable = (char *) synchronized_sqlite3_column_text(labelstmtIstable,0);
                    
                }
            }
            
             synchronized_sqlite3_finalize(labelstmtIstable);
            
            if(!(fieldIsTable != nil &&strlen(fieldIsTable)))
            {
                sqlite3_stmt * labelstmtGetTableName;
                NSMutableString * queryStatementGetTableName= [[NSMutableString alloc]initWithCapacity:0];
                queryStatementGetTableName = [NSMutableString stringWithFormat:@"SELECT reference_to FROM SFReferenceTo where object_api_name='%@' and field_api_name='%@'",object,searchableField];
                const char *selectStatementGetTableName = [queryStatementGetTableName UTF8String];
                char *TableName=nil;
                NSString *strTableName=@"";
                if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatementGetTableName,-1, &labelstmtGetTableName, nil) == SQLITE_OK )
                {
                    if(synchronized_sqlite3_step(labelstmtGetTableName) == SQLITE_ROW)
                    {
                        TableName=(char *) synchronized_sqlite3_column_text(labelstmtGetTableName,0);
                        if(TableName !=nil && strlen(TableName))
                        {
                            strTableName=[NSString stringWithFormat:@"%s",TableName];
                            searchableFieldTableName=strTableName;
                        }
                    }
                }
                synchronized_sqlite3_finalize(labelstmtGetTableName);
            }
            
            NSMutableString * queryStatementIstable2 = [[NSMutableString alloc]initWithCapacity:0];
            queryStatementIstable2 = [NSMutableString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@'",searchableFieldTableName];
            sqlite3_stmt * labelstmtIstable2 ;
            const char *selectStatementIstable2  = [queryStatementIstable2 UTF8String];
            char *fieldIsTable2=nil;
            if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatementIstable2 ,-1, &labelstmtIstable2 , nil) == SQLITE_OK )
            {
                if(synchronized_sqlite3_step(labelstmtIstable2) == SQLITE_ROW)
                {
                    fieldIsTable2 = (char *) synchronized_sqlite3_column_text(labelstmtIstable2,0);
                    
                }
            }
            
             synchronized_sqlite3_finalize(labelstmtIstable2);
            
            if((fieldIsTable2 != nil &&strlen(fieldIsTable2))||(fieldIsTable != nil &&strlen(fieldIsTable)))
            {
                if([searchableFieldTableName length] > 0)
                {
                    if(![TableArray containsObject:searchableFieldTableName] )
                    {
                        [TableArray addObject:searchableFieldTableName];
                        NSMutableArray * arry = [[NSMutableArray alloc] initWithCapacity:0];
                        [arry addObject:searchableField];
                        [tableArrayDict setObject:arry forKey:searchableFieldTableName ];
                    }
                    else
                    {
                        NSMutableArray * array =  [tableArrayDict objectForKey:searchableFieldTableName];
                        [array addObject:searchableField];
                        
                    }
                }
                
            }
            NSString * searchfield=[NSString stringWithFormat:@"'%@'.%@",[self getApiNameFromFieldLabel:[[searchableArray objectAtIndex:i] objectForKey:@"SVMXC__Object_Name2__c"]],searchableField];
            [searchFieldsArr addObject:searchfield];
            SMLog(kLogLevelVerbose,@"%@",searchFieldsArr);
            if(![displayFieldsArray containsObject:searchableField])
            {
                [queryFields appendString:@","];
                [queryFields appendFormat:@"'%@'.%@",[self getApiNameFromFieldLabel:[[searchableArray objectAtIndex:i] objectForKey:@"SVMXC__Object_Name2__c"]],searchableField];
            }
            fieldsCount++;
        }
        [displayFieldsArray release];
        NSString *queryStatement;
        BOOL RecordExistForSearchField=FALSE;
        //for adding search field in the where clause
        for (int i=0; i<[searchFieldsArr count]; i++)
        {
            if(i !=0)
                [customizeSearch appendString:@" OR "];
            NSDictionary *name_field=[ self getNameFieldForRefrenceObject:[searchableArray objectAtIndex:i]];
            if([name_field count]>0)
            {
                //For Adding Name filed in search String
                [customizeSearch appendString:[NSString stringWithFormat:@"'%@'.%@",[name_field objectForKey:@"reference_to"],[name_field objectForKey:@"namefiled"]]];
                RecordExistForSearchField=[self isTableEmpty:[name_field objectForKey:@"reference_to"]];
                [customizeSearch appendString:@" LIKE "];
                NSString *strSearchCriteria=[self getSearchCriteriaStringFromUserData:[uiControlsValue objectForKey:@"searchCriteria"] withSearchString:[uiControlsValue objectForKey:@"searchString"]];
                [customizeSearch appendFormat:@"'%@'",strSearchCriteria];
            }
            else
            {
                
                [customizeSearch appendString:[searchFieldsArr objectAtIndex:i]];
                BOOL flag =[self isTableEmpty:[searchFieldsArr objectAtIndex:i]];
                if(flag)
                {
                    RecordExistForSearchField = TRUE;
                }
                [customizeSearch appendString:@" LIKE "];
                NSString *strSearchCriteria=[self getSearchCriteriaStringFromUserData:[uiControlsValue objectForKey:@"searchCriteria"] withSearchString:[uiControlsValue objectForKey:@"searchString"]];
                [customizeSearch appendFormat:@"'%@'",strSearchCriteria];
                //getjoinfields Dict pass Table array and object
            }
        }
        if([criteriaArray count] == 0 )
        {
            NSMutableDictionary *dict_Join_field=[[NSMutableDictionary alloc]init ];
            [dict_Join_field setObject:TableArray forKey:@"TableArray"];
            [dict_Join_field setObject:tableArrayDict forKey:@"tableArrayDict"];
            [dict_Join_field setObject:object forKey:@"object"];
            joinFields=[self getJoinFields:dict_Join_field];
            if([joinFields length]>0)
            {
                if([customizeSearch length]>0)
                {
                    if([[uiControlsValue objectForKey:@"searchString"] length]>0)
                        queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@' %@ WHERE %@ LIMIT %@",queryFields,object,joinFields,customizeSearch,[uiControlsValue objectForKey:@"searchLimitString"]];
                    else
                        queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@' %@ LIMIT %@",queryFields,object,joinFields,[uiControlsValue objectForKey:@"searchLimitString"]];
                    
                }
                else
                    queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@' %@",queryFields,object,joinFields];
            }
            else
            {
                if([customizeSearch length]>0)
                {
                    if([[uiControlsValue objectForKey:@"searchString"] length]>0)
                        queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@' WHERE %@ LIMIT %@",queryFields,object,customizeSearch,[uiControlsValue objectForKey:@"searchLimitString"]];
                    else
                        queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@' LIMIT %@",queryFields,object,[uiControlsValue objectForKey:@"searchLimitString"]];
                    
                }
                else
                    queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@'",queryFields,object];
            }
        }
        else
        {
            
            
            NSMutableString * conditionqueryStatement = [[NSMutableString alloc]initWithCapacity:0];
            conditionqueryStatement = [NSMutableString stringWithFormat:@"SELECT SVMXC__Advance_Expression__c,SVMXC__Target_Object_Name__c from SFM_Search_Objects where ObjectID='%@'",objectId];
            sqlite3_stmt * conditionlabelstmt;
            const char *conditionselectStatement = [conditionqueryStatement UTF8String];
            char *fieldforCondition=nil,*TargetObject=nil;
            NSString *Expression=@"",*strTargetObject=@"";
            if ( synchronized_sqlite3_prepare_v2(appDelegate.db, conditionselectStatement,-1, &conditionlabelstmt, nil) == SQLITE_OK )
            {
                if(synchronized_sqlite3_step(conditionlabelstmt) == SQLITE_ROW)
                {
                    fieldforCondition = (char *) synchronized_sqlite3_column_text(conditionlabelstmt,0);
                    TargetObject = (char *) synchronized_sqlite3_column_text(conditionlabelstmt,1);
                    if((fieldforCondition !=nil) && strlen(fieldforCondition))
                        Expression=[NSString stringWithFormat:@"%s",fieldforCondition] ;
                    if((TargetObject !=nil) && strlen(TargetObject))
                        strTargetObject=[NSString stringWithUTF8String:TargetObject] ;
                }
            }
            synchronized_sqlite3_finalize(conditionlabelstmt);
            SMLog(kLogLevelVerbose,@"Adv Exp = %@",Expression);
            if(![Expression isEqualToString:@"(null)"])
            {
                SMLog(kLogLevelVerbose,@"%@",Expression);
                int iTokenCount=-1;
                Expression=[Expression stringByReplacingOccurrencesOfString:@")" withString:@" ) "];
                Expression=[Expression stringByReplacingOccurrencesOfString:@"(" withString:@" ( "];
                NSMutableArray  *tokens = [[NSMutableArray alloc] init];
                NSMutableArray  *alltokens = [[NSMutableArray alloc] init];
                NSArray *logicalArray = [NSArray arrayWithObjects:@" AND ",@" OR ", nil];
                int index = 0;
                if([Expression rangeOfString:[logicalArray objectAtIndex:index]].length > 0)
                {    
                    NSArray *logicalTokens = [Expression componentsSeparatedByString:[logicalArray objectAtIndex:index]];
                    for(int i=0; i<[logicalTokens count]; i++)
                    {
                        NSString *token = [logicalTokens objectAtIndex:i];
                        if(i)
                            [tokens addObject:[logicalArray objectAtIndex:index]];
                        [tokens addObject:token];
                    }
                }
                SMLog(kLogLevelVerbose,@"Tokens = %@",tokens);
                if([tokens count] == 0)
                {
                    [tokens addObject:Expression];
                }
                index++;
                for(NSString *data in tokens)
                {
                    if([data rangeOfString:[logicalArray objectAtIndex:index]].length > 0)
                    {   
                        NSArray *logicalTokens = [data componentsSeparatedByString:[logicalArray objectAtIndex:index]];
                        for(int i=0; i<[logicalTokens count]; i++)
                        {
                            NSString *token = [logicalTokens objectAtIndex:i];
                            if(i)
                                [alltokens addObject:[logicalArray objectAtIndex:index]];
                            [alltokens addObject:token];
                        }
                    }
                    else
                    {
                        [alltokens addObject:data];
                    }
                }
                [dictforparsing setObject:TableArray forKey:@"TableArray"];
                [dictforparsing setObject:tableArrayDict forKey:@"tableArrayDict"];
                [dictforparsing setObject:strTargetObject forKey:@"strTargetObject"];
                [dictforparsing setObject:criteriaArray forKey:@"criteriaArray"];
                SMLog(kLogLevelVerbose,@"AllTokens = %@",alltokens);
                if(!([alltokens count]>0))
                {
                    alltokens=[NSString stringWithFormat:@"%@",Expression];
                    [dictforparsing setObject:finalQuery forKey:@"finalQuery"];
                    [dictforparsing setObject:alltokens forKey:@"token"];
                    logicalParsingResult= [self getupdatedToken:dictforparsing];
                    TableArray=[logicalParsingResult objectForKey:@"TableArray"];
                    tableArrayDict=[logicalParsingResult objectForKey:@"tableArrayDict"];
                    finalQuery=[logicalParsingResult objectForKey:@"finalQuery"];
                    [finalQuery appendString:@" COLLATE NOCASE"]; 
                }
                else
                {
                    for(NSString *token in alltokens)
                    {
                        if([token Contains:@" AND "]||([token Contains:@" OR "]))
                        {
                            [finalQuery appendFormat:@" %@ ",token];
                            continue;
                        }
                        iTokenCount++;
                        [dictforparsing setObject:[NSString stringWithFormat:@"%d",iTokenCount ] forKey:@"Count"];
                        [dictforparsing setObject:finalQuery forKey:@"finalQuery"];
                        [dictforparsing setObject:token forKey:@"token"];
                        logicalParsingResult= [self getupdatedToken:dictforparsing];
                        TableArray=[logicalParsingResult objectForKey:@"TableArray"];
                        tableArrayDict=[logicalParsingResult objectForKey:@"tableArrayDict"];
                        finalQuery=[logicalParsingResult objectForKey:@"finalQuery"];
                        [finalQuery appendString:@" COLLATE NOCASE"]; 

                    }
                    [alltokens release];
                    [tokens release];
                }
            }
            for(int j=0;j<[criteriaArray count]; j++)
            {
                NSString *fieldName=@"",*TableName=@"";
                dict = [criteriaArray objectAtIndex:j];
                NSString *displayType = [dict objectForKey:@"SVMXC__Display_Type__c"];
                if ([displayType isEqualToString:@"REFERENCE"])
                {
                    [refrenceObjectAtIndex addObject:[NSString stringWithFormat:@"%d",j]];
                    NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
                    queryStatement1 = [NSMutableString stringWithFormat:@"SELECT reference_to FROM SFObjectField where api_name='%@' and object_api_name='%@'",[dict objectForKey:@"SVMXC__Field_Name__c"],object];
                    sqlite3_stmt * labelstmt;
                    const char *selectStatement = [queryStatement1 UTF8String];
                    char *reference_to_field=nil;
                    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
                    {
                        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
                        {
                            reference_to_field = (char *) synchronized_sqlite3_column_text(labelstmt,0);
                            if((reference_to_field != nil) && strlen(reference_to_field))
                                TableName = [NSString stringWithFormat:@"%s",reference_to_field];
                            
                        }
                    }
                    
                    NSMutableString * queryStatement2 = [[NSMutableString alloc]initWithCapacity:0];
                    queryStatement2 = [NSMutableString stringWithFormat:@"SELECT api_name FROM SFObjectField where name_field='TRUE' and object_api_name='%@'",object];
                    sqlite3_stmt * labelstmt2;
                    const char *selectStatement2 = [queryStatement2 UTF8String];
                    char *nameofObjectField;
                    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement2,-1, &labelstmt2, nil) == SQLITE_OK )
                    {
                        if(synchronized_sqlite3_step(labelstmt2) == SQLITE_ROW)
                        {
                            nameofObjectField = (char *) synchronized_sqlite3_column_text(labelstmt2,0);
                            if((nameofObjectField !=nil)&&strlen(nameofObjectField))
                                fieldName = [NSString stringWithFormat:@"%s",nameofObjectField];
                            
                        }
                    }
                
                    if ([TableName length]>0) 
                        TableName = [self getApiNameFromFieldLabel:TableName];
                    if(![TableArray containsObject:TableName]&& [TableName length] > 0 )
                    {
                        [TableArray addObject:TableName];
                        NSMutableArray * arry = [[NSMutableArray alloc] initWithCapacity:0];
                        [arry addObject:[dict objectForKey:@"SVMXC__Field_Name__c"]];
                        [tableArrayDict setObject:arry forKey:TableName];

                    }
                    else
                    {
                        NSMutableArray * array =  [tableArrayDict objectForKey:TableName];
                        [array addObject:[dict objectForKey:@"SVMXC__Field_Name__c"]];

                    }
 
                    synchronized_sqlite3_finalize(labelstmt);
                    synchronized_sqlite3_finalize(labelstmt2);
                }
            }
            NSMutableDictionary *dict_Join_field=[[NSMutableDictionary alloc]init ];
            [dict_Join_field setObject:TableArray forKey:@"TableArray"];
            [dict_Join_field setObject:tableArrayDict forKey:@"tableArrayDict"];
            [dict_Join_field setObject:object forKey:@"object"];
            joinFields=[self getJoinFields:dict_Join_field];
            
            
            
            if([finalQuery length] > 0)
            {
                if([customizeSearch length]>0)
                {
                    if([[uiControlsValue objectForKey:@"searchString"] length]>0)
                        queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@' %@ WHERE (%@) AND (%@) COLLATE NOCASE LIMIT %@",queryFields,object,joinFields,finalQuery,customizeSearch,[uiControlsValue objectForKey:@"searchLimitString"]];
                    else
                        queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@' %@ WHERE (%@) COLLATE NOCASE LIMIT %@",queryFields,object,joinFields,finalQuery,[uiControlsValue objectForKey:@"searchLimitString"]];
                    
                }
                else
                    queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@' %@ WHERE (%@) COLLATE NOCASE LIMIT %@",queryFields,object,joinFields,finalQuery,[uiControlsValue objectForKey:@"searchLimitString"]];

            }
            else
            {
                if([customizeSearch length]>0)
                {
                    if([[uiControlsValue objectForKey:@"searchString"] length]>0)
                        queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@'%@ WHERE (%@) LIMIT %@",queryFields,object,joinFields,customizeSearch,[uiControlsValue objectForKey:@"searchLimitString"]];
                    else
                        queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@'%@ LIMIT %@",queryFields,object,joinFields,[uiControlsValue objectForKey:@"searchLimitString"]];
                }
                else
                    queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM '%@'%@ LIMIT %@",queryFields,object,joinFields,[uiControlsValue objectForKey:@"searchLimitString"]];
                
            }
            
        }
        [queryFields release];
        sqlite3_stmt * statement;
        SMLog(kLogLevelVerbose,@"Query = %@",queryStatement);
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                NSString *value=nil,*refrenceValue=nil;
                for(int j=0; j< fieldsCount; j++)
                {
                    const char * _type = (char *)synchronized_sqlite3_column_text(statement, j);
                    if ( !_type)
                    {
                        _type = "";
                    }
                    value = [NSString stringWithUTF8String:_type];
                    if(value == nil)
                    {
                        value = @"";
                    }
                    if(j==0)
                    {
                        [dict setObject:value forKey:@"Id"];
                    }
                    else
                        if(j==1)
                        {
                            [dict setObject:value forKey:@"local_id"];
                        }
                        else
                        {
                            if(j<([displayArray count] +2))
                            {
                                NSDictionary *object = [displayArray objectAtIndex:j-2];
                                if([value length])
                                {
                                    refrenceValue=[self getvalueforReference:object value:value];
                                    if(refrenceValue)
                                    {
                                        [dict setObject:refrenceValue forKey:[NSString stringWithFormat:@"%@.%@",[object objectForKey:@"SVMXC__Object_Name2__c"],[object objectForKey:@"SVMXC__Field_Name__c"]]];
                                    }
                                    else
                                    {
                                        [dict setObject:value forKey:[NSString stringWithFormat:@"%@.%@",[object objectForKey:@"SVMXC__Object_Name2__c"],[object objectForKey:@"SVMXC__Field_Name__c"]]];
                                    }
                                    
                                }
                                else
                                {
                                    [dict setObject:value forKey:[NSString stringWithFormat:@"%@.%@",[object
                                                                                                      objectForKey:@"SVMXC__Object_Name2__c"],[object 
                                                                                                                                               objectForKey:@"SVMXC__Field_Name__c"]]];
                                }
                            }
                            else
                            {
                                int indexValue = j - [displayArray count] - 2;
                                NSString *object_name_2 = [[searchableArray objectAtIndex:indexValue ] objectForKey:@"SVMXC__Object_Name2__c"];
                                NSString *field_name = [[searchableArray objectAtIndex:indexValue ] objectForKey:@"SVMXC__Field_Name__c"];
                                NSString *key = [NSString stringWithFormat:@"%@.%@",object_name_2,field_name];
                                if(![[dict allKeys] containsObject:key])
                                {
                                    refrenceValue=[self getvalueforReference:[searchableArray objectAtIndex:indexValue ]  value:value];
                                    if(refrenceValue)
                                    {
                                        [dict setObject:refrenceValue forKey:[NSString stringWithFormat:@"%@.%@",[[searchableArray objectAtIndex:indexValue ] objectForKey:@"SVMXC__Object_Name2__c"],[[searchableArray objectAtIndex:indexValue ] objectForKey:@"SVMXC__Field_Name__c"]]];
                                    }
                                    else
                                    {
                                        [dict setObject:value forKey:[NSString stringWithFormat:@"%@.%@",[[searchableArray objectAtIndex:indexValue ] objectForKey:@"SVMXC__Object_Name2__c"],[[searchableArray objectAtIndex:indexValue ] objectForKey:@"SVMXC__Field_Name__c"]]]; 
                                    }
                                    
                                }
                            }
                        }
                }
                [results addObject:dict];
            }
        }
        synchronized_sqlite3_finalize(statement);
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name Database :getResults %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason Database :getResults %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    return [results autorelease];
}

-(BOOL)isColumnPresentInTable:(NSString*)TableName columnName:(NSString*)colName
{
    NSString *tempString=[NSString stringWithFormat:@"%%%@%%",colName];
    NSString *queryStatementName = [NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE name = '%@' and sql like '%@'",TableName,tempString];
    sqlite3_stmt * labelstmtName;
    BOOL isfieldPresent=FALSE;
    const char *selectStatementName = [queryStatementName UTF8String];
    char *nameofObjectField;
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatementName,-1, &labelstmtName, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmtName) == SQLITE_ROW)
        {
            nameofObjectField = (char *) synchronized_sqlite3_column_text(labelstmtName,0);
            if((nameofObjectField !=nil)&&strlen(nameofObjectField))
                isfieldPresent = TRUE;
            else
                isfieldPresent=FALSE;
            
        }
    }
    synchronized_sqlite3_finalize(labelstmtName);
    return isfieldPresent;
}
-(NSMutableString *)stringForSelectFields:(NSArray*)queryfields
{
    NSMutableString *queryField=[[NSMutableString alloc]init];
    for (int i=0; i<[queryfields count]; i++)
    {
        [queryField appendString:[NSString stringWithFormat:@",%@",[queryfields objectAtIndex:i]]];

    }
    return [queryField autorelease];
}

-(NSMutableString *)stringForSortingFields:(NSArray*)queryfields
{
    NSMutableString *orderByString=[[NSMutableString alloc]init];
    for (int i=0; i<[queryfields count]; i++)
    {
        if(i !=0)
           [orderByString appendFormat:@" , "];
        else
            [orderByString appendFormat:@"ORDER BY"];
        NSDictionary *sortFields=[queryfields objectAtIndex:i];
        [orderByString appendFormat:@" %@",[sortFields objectForKey:@"sort_Object"]];
        [orderByString appendFormat:@" %@",[sortFields objectForKey:@"sort_Order"]];
    }
    return [orderByString autorelease];
}
    
-(NSMutableArray*)parsingExpression:(NSString*)Expression
{    
    NSMutableArray  *tokens = [[NSMutableArray alloc] init];
    NSMutableArray  *alltokens = [[NSMutableArray alloc] init];
    NSArray *logicalArray = [NSArray arrayWithObjects:@" AND ",@" OR ",@" NOT ", nil];
    int index = 0;
    if([Expression rangeOfString:[logicalArray objectAtIndex:index]].length > 0)
    {
        NSArray *logicalTokens = [Expression componentsSeparatedByString:[logicalArray objectAtIndex:index]];
        for(int i=0; i<[logicalTokens count]; i++)
        {
            NSString *token = [logicalTokens objectAtIndex:i];
            if(i)
                [tokens addObject:[logicalArray objectAtIndex:index]];
            [tokens addObject:token];
        }
    }
    SMLog(kLogLevelVerbose,@"Tokens = %@",tokens);
    if([tokens count] == 0)
    {
        [tokens addObject:Expression];
    }
    index++;
    for(NSString *data in tokens)
    {
        if([data rangeOfString:[logicalArray objectAtIndex:index]].length > 0)
        {
            NSArray *logicalTokens = [data componentsSeparatedByString:[logicalArray objectAtIndex:index]];
            for(int i=0; i<[logicalTokens count]; i++)
            {
                NSString *token = [logicalTokens objectAtIndex:i];
                if(i)
                    [alltokens addObject:[logicalArray objectAtIndex:index]];
                [alltokens addObject:token];
            }
        }
        else
        {
            [alltokens addObject:data];
        }
    }
    SMLog(kLogLevelVerbose,@"all token =%@",alltokens);
    return alltokens;
}
-(NSString *) CreateRandomString:(NSString*)objectName
{
    NSString *randomString=@"";
    
    //Keerti - 7275
    if(arrayofAlias == nil || arrayofAlias == NULL || ![arrayofAlias count]>0)
    {
        arrayofAlias=[[NSMutableArray alloc]init];
    }
    if([objectName length]>0 || objectName != nil)
    {
        NSArray *arrayOfKeywords=[NSArray arrayWithObjects:@"AS",@"BY",@"IF",@"IN",@"IS",@"NO",@"OF",@"ON",@"OR",@"TO",nil];
        unichar characters[2];
        objectName=[self getFieldLabelForApiName:objectName];
        characters[0]=[objectName characterAtIndex:0];
        characters[ 1 ] = 'A' + arc4random_uniform(26) ;
        randomString=[ NSString stringWithCharacters:characters length:2 ];
        while([arrayOfKeywords containsObject:randomString] ||[arrayofAlias containsObject:randomString]) //arrayofalias - Keerti - 7275
        {
            characters[ 1 ] = 'A' + arc4random_uniform(26) ;
            randomString=[ NSString stringWithCharacters:characters length:2 ];
            SMLog(kLogLevelVerbose,@"%@",randomString);
        }
        
        //Keerti - 7275
        [arrayofAlias addObject:randomString];
        SMLog(kLogLevelVerbose,@"arrayofAlias %@",arrayofAlias);
    }
    else if(isSortingDone)
    {
        [arrayofAlias release];
        arrayofAlias=nil;
    }
    return randomString;
}
/*
-(NSString*)random
{
    unichar characters[2];
    for( int index=0; index < 2; ++index )
    {
        characters[ index ] = 'A' + arc4random_uniform(26) ;
    }
    return [ NSString stringWithCharacters:characters length:2 ] ;
}
*/
-(NSString*) getNameFiled:(NSString*)obejctName
{
    NSMutableString * queryStatementName = [[NSMutableString alloc]initWithCapacity:0];
    queryStatementName = [NSMutableString stringWithFormat:@"SELECT api_name FROM SFObjectField where name_field='TRUE' and object_api_name='%@'",obejctName];
    sqlite3_stmt * labelstmtName;
    NSString *fieldName=@"";
    const char *selectStatementName = [queryStatementName UTF8String];
    char *nameofObjectField;
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatementName,-1, &labelstmtName, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmtName) == SQLITE_ROW)
        {
            nameofObjectField = (char *) synchronized_sqlite3_column_text(labelstmtName,0);
            if((nameofObjectField !=nil)&&strlen(nameofObjectField))
                fieldName = [NSString stringWithUTF8String:nameofObjectField];
            
        }
    }
    synchronized_sqlite3_finalize(labelstmtName);
    return fieldName;
    
}
-(NSMutableString*)getJoinFields:(NSDictionary*)dict
{
    NSMutableArray *TableArray = [dict objectForKey:@"TableArray"];
    NSMutableString *joinFields = [[NSMutableString alloc] init];
    NSMutableArray *arrayForApiName=[[[NSMutableArray alloc]init]autorelease];
    @try
    {
       for (int i=0; i<[TableArray count]; i++)
       {
           NSMutableArray *arrApiName=[[[NSMutableArray alloc]init]autorelease];

            if(![[TableArray objectAtIndex:i]isEqual:[dict objectForKey:@"object"]])
            {
                sqlite3_stmt * labelstmtforlabel;
                NSMutableString * queryStatementforLabel= [[NSMutableString alloc]initWithCapacity:0];
                queryStatementforLabel = [NSMutableString stringWithFormat:@"SELECT label FROM SFObjectField where object_api_name ='%@'",[dict objectForKey:@"object"]];
                const char *selectStatementForlabel = [queryStatementforLabel UTF8String];
                char *label=nil;   
                NSString *strlabel=@"";
                NSMutableArray *labelForObject=[[NSMutableArray alloc]init];
                if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatementForlabel,-1, &labelstmtforlabel, nil) == SQLITE_OK )
                {
                    while(synchronized_sqlite3_step(labelstmtforlabel) == SQLITE_ROW)
                    {
                        label=(char *) synchronized_sqlite3_column_text(labelstmtforlabel,0);
                        if(label !=nil && strlen(label))
                        {
                            strlabel=[NSString stringWithFormat:@"%s",label];
                        }
                        [labelForObject addObject:strlabel];
                    }
                }
                synchronized_sqlite3_finalize(labelstmtforlabel);
                
                char *apiName=nil,*type=nil,*relationshipName=nil,*reference_to=nil;   
                NSString *strapiName=@"",*strtype=@"",*strrelationshipName=@"",*strreference_to=@"";
                if([labelForObject containsObject: [self getFieldLabelForApiName:[TableArray objectAtIndex:i]]])
                {
                    NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
                    queryStatement1 = [NSMutableString stringWithFormat:@"SELECT api_name,type,relationship_name,reference_to FROM SFObjectField where object_api_name = '%@'and label='%@'",[dict objectForKey:@"object"], [self getFieldLabelForApiName:[TableArray objectAtIndex:i]]];   
                    const char *selectStatement = [queryStatement1 UTF8String];
                    sqlite3_stmt * labelstmt;
                    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
                    {
                        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
                        {
                            NSMutableDictionary *dictRefrenceFileds=[[[NSMutableDictionary alloc]init]autorelease];
                            apiName = (char *) synchronized_sqlite3_column_text(labelstmt,0);
                            if((apiName !=nil) && strlen(apiName))
                            {
                                strapiName=[NSString stringWithFormat:@"%s",apiName];
                                [dictRefrenceFileds setObject:strapiName forKey:@"apiName"];
                            }
                            type = (char *) synchronized_sqlite3_column_text(labelstmt,1);
                            if((type !=nil) && strlen(type))
                            {
                                strtype=[NSString stringWithFormat:@"%s",type];
                                [dictRefrenceFileds setObject:strtype forKey:@"type"];

                            }
                            relationshipName = (char *) synchronized_sqlite3_column_text(labelstmt,2);
                            if((relationshipName !=nil) && strlen(relationshipName))
                            {
                                strrelationshipName=[NSString stringWithFormat:@"%s",relationshipName];
                                [dictRefrenceFileds setObject:strrelationshipName forKey:@"relationshipName"];

                            }
                            reference_to =(char *) synchronized_sqlite3_column_text(labelstmt,3);
                            if((reference_to !=nil) && strlen(reference_to))
                            {
                                strreference_to=[NSString stringWithFormat:@"%s",reference_to];
                                [dictRefrenceFileds setObject:strreference_to forKey:@"reference_to"];

                            }
                            [arrApiName addObject:dictRefrenceFileds];
                        }
                    }
                    synchronized_sqlite3_finalize(labelstmt);
                }
                else
                {
                    NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
                    /*queryStatement1 = [NSMutableString stringWithFormat:@"SELECT api_name,type,relationship_name,reference_to FROM SFObjectField where object_api_name = '%@'and reference_to='%@'and api_name='%@'",object, [self getApiNameFromFieldLabel:[TableArray objectAtIndex:i]],[tableArrayDict objectForKey:[self getApiNameFromFieldLabel:[TableArray objectAtIndex:i]]]]; */
                   
                    queryStatement1 = [NSMutableString stringWithFormat:@"SELECT api_name,type,relationship_name,reference_to FROM SFObjectField where object_api_name = '%@'and reference_to='%@'",[dict objectForKey:@"object"], [self getApiNameFromFieldLabel:[TableArray objectAtIndex:i]]];
                    const char *selectStatement = [queryStatement1 UTF8String];
                    sqlite3_stmt * labelstmt;
                    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
                    {
                        while(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
                        {
                            NSMutableDictionary *dictRefrenceFileds=[[[NSMutableDictionary alloc]init]autorelease];
                            apiName = (char *) synchronized_sqlite3_column_text(labelstmt,0);
                            if((apiName !=nil) && strlen(apiName))
                            {
                                strapiName=[NSString stringWithFormat:@"%s",apiName];
                                [dictRefrenceFileds setObject:strapiName forKey:@"apiName"];
                            }
                            type = (char *) synchronized_sqlite3_column_text(labelstmt,1);
                            if((type !=nil) && strlen(type))
                            {
                                strtype=[NSString stringWithFormat:@"%s",type];
                                [dictRefrenceFileds setObject:strtype forKey:@"type"];
                                
                            }
                            relationshipName = (char *) synchronized_sqlite3_column_text(labelstmt,2);
                            if((relationshipName !=nil) && strlen(relationshipName))
                            {
                                strrelationshipName=[NSString stringWithFormat:@"%s",relationshipName];
                                [dictRefrenceFileds setObject:strrelationshipName forKey:@"relationshipName"];
                                
                            }
                            reference_to =(char *) synchronized_sqlite3_column_text(labelstmt,3);
                            if((reference_to !=nil) && strlen(reference_to))
                            {
                                strreference_to=[NSString stringWithFormat:@"%s",reference_to];
                                [dictRefrenceFileds setObject:strreference_to forKey:@"reference_to"];
                                
                            }
                            [arrayForApiName addObject:dictRefrenceFileds];
                        }
                    }
                    synchronized_sqlite3_finalize(labelstmt);
                    if([arrayForApiName count]>0)
                    {
                        NSString *objectApiName=[self getApiNameFromFieldLabel:[TableArray objectAtIndex:i]];
                        NSArray* refrence_to_array =[[dict objectForKey:@"tableArrayDict"] objectForKey:objectApiName];
                        for(int i=0;i<[refrence_to_array count];i++)
                        {
                            for (int j=0; j<[arrayForApiName count]; j++)
                            {
                                if([[[arrayForApiName objectAtIndex:j]objectForKey:@"apiName"] Contains:[refrence_to_array objectAtIndex:i]]&& [strtype isEqualToString:@"reference"])
                                {
                                    [arrApiName addObject:[arrayForApiName objectAtIndex:j]];
                                }
                            }
                            
                        }
                        if(![arrApiName count]>0)
                            arrApiName=arrayForApiName;
                    }
                    

                }
                
                if([strtype isEqualToString:@"reference"])
                {
                    [joinFields appendFormat:@" LEFT OUTER JOIN"];
                    [joinFields appendFormat:@" '%@'",[TableArray objectAtIndex:i]];
                    [joinFields appendFormat:@" ON"];
                    
                    if ([arrApiName count] > 0)
                    {
                        for (int join = 0; join < [arrApiName count]; join++)
                        {
                            BOOL isChild =  [appDelegate.databaseInterface IsChildObject:[dict objectForKey:@"object"]];
                            SMLog(kLogLevelVerbose,@"isChild :%d",isChild);
                            NSDictionary * refDict = [arrApiName objectAtIndex:join];
                            if (join == 0)
                            {
                                if(!isChild)
                                {
                                    [joinFields appendFormat:@"('%@'.%@ = '%@'.Id",[dict objectForKey:@"object"],[refDict objectForKey:@"apiName"],[self getApiNameFromFieldLabel:[TableArray objectAtIndex:i]]];
                                }
                                else
                                {
                                    [joinFields appendFormat:@"('%@'.%@ = '%@'.local_id",[dict objectForKey:@"object"],[refDict objectForKey:@"apiName"],[self getApiNameFromFieldLabel:[TableArray objectAtIndex:i]]];                                    
                                }
                            }
                            else 
                            {
                                if([[refDict objectForKey:@"type"] isEqualToString:@"reference"])
                                {
                                     if(!isChild)
                                     {
                                        [joinFields appendFormat:@" or '%@'.%@ = '%@'.Id",[dict objectForKey:@"object"],[refDict objectForKey:@"apiName"],[self getApiNameFromFieldLabel:[TableArray objectAtIndex:i]]];
                                     }
                                    else
                                    {
                                        [joinFields appendFormat:@" or '%@'.%@ = '%@'.local_id",[dict objectForKey:@"object"],[refDict objectForKey:@"apiName"],[self getApiNameFromFieldLabel:[TableArray objectAtIndex:i]]];

                                    }
                                }
                            }
                            
                            
                        }
                        [joinFields appendFormat:@" )"];
                    }
                   
                }
            }
       }
   }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name Database :getJoinFields %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason Database :getJoinFields %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    return [joinFields autorelease];
}

-(NSString*)getapiNameforObject:(NSString*)objectName RelationshipName:(NSString*)relName
{
    NSString *queryStatement = [NSString stringWithFormat:@"SELECT api_name FROM SFObjectField where object_api_name='%@' and relationship_name='%@'",objectName,relName];
    sqlite3_stmt * statement;
    NSString *apiName = relName;
    if(appDelegate == nil)
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * label = (char *)synchronized_sqlite3_column_text(statement, 0);
            if ((label !=nil) && strlen(label))
            {
                apiName = [NSString stringWithUTF8String:label];
                
            }
        }
        synchronized_sqlite3_finalize(statement);
    }
    
    
    return [apiName retain];
    
}
- (NSString *) getDataTypeFor:(NSString *)objectName inArray:(NSArray *)dataArray
{
    NSString *dataType = nil;
    for(NSDictionary *dict in dataArray)
    {
        NSString *objName = [dict objectForKey:@"SVMXC__Field_Name__c"];
        if([objName isEqualToString:objectName])
        {
            dataType = [dict objectForKey:@"SVMXC__Display_Type__c"];
            break;
        }
    }
    return dataType;
}
-(NSString*)getReferencetoFiledForObject:(NSString*)objectName api_Name:(NSString*)api_name
{
    NSString *strRefrence_to=@"";
    NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
    queryStatement1 = [NSMutableString stringWithFormat:@"SELECT reference_to FROM SFObjectField where object_api_name = '%@'and api_name='%@'",objectName,api_name];
    sqlite3_stmt * labelstmt;
    const char *selectStatement = [queryStatement1 UTF8String];
    char *refrence_to=nil;
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
        {
            refrence_to = (char *) synchronized_sqlite3_column_text(labelstmt,0);
        }
    }
    
    if((refrence_to != nil)&& strlen(refrence_to))
        strRefrence_to=[NSString stringWithFormat:@"%s",refrence_to];
    else
        strRefrence_to=@"";
    synchronized_sqlite3_finalize(labelstmt);

    return strRefrence_to;
}

- (NSString *) getSearchCriteriaStringFromUserData:(NSString *)criteriaString withSearchString:searchString
{
    NSString *resultSearchString = nil;
    SMLog(kLogLevelVerbose,@"Criteria String = :%@:",criteriaString);
    SMLog(kLogLevelVerbose,@"Criteria String From Dict = :%@:",[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_CONTAINS]);
@try
    {
    if([criteriaString isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_CONTAINS]])
    {
        resultSearchString = [NSString stringWithFormat:@"%%%@%%",searchString];
        SMLog(kLogLevelVerbose,@"Matched Contains");
    }
    if([criteriaString isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_EXTACT_MATCH]])
    {
        resultSearchString = searchString;
    }
    if([criteriaString isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_ENDS_WITH]])
    {
        resultSearchString = [NSString stringWithFormat:@"%%%@",searchString];
    }
    if([criteriaString isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_STARTS_WITH]])
    {
        resultSearchString = [NSString stringWithFormat:@"%@%%",searchString];
    }
}@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name Database :getSearchCriteriaStringFromUserData %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason Database :getSearchCriteriaStringFromUserData %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    return resultSearchString;
}

-(NSMutableDictionary*) getupdatedToken:(NSMutableDictionary*)dictforparsing
{
    NSArray *operatorArray = [NSArray arrayWithObjects:@"!=",@"<=",@">=",@"<>",@"=",@"<",@">",@"NOT LIKE",@" LIKE ",@" NOT IN ",@" IN ", nil];
    int Count=-1;
    if(appDelegate == nil)
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    int tokenCount=[[dictforparsing objectForKey:@"Count"] integerValue];
    NSMutableArray *TableArray = [dictforparsing objectForKey:@"TableArray"];
    NSMutableDictionary *tableArrayDict=[dictforparsing objectForKey:@"tableArrayDict"];
    NSMutableDictionary *resultDict=[[NSMutableDictionary alloc]init ];
    NSMutableString *finalQuery=[dictforparsing objectForKey:@"finalQuery"];
    NSString *token=[dictforparsing objectForKey:@"token"];
    token=[token stringByReplacingOccurrencesOfString:@" ( " withString:@"("];
    token=[token stringByReplacingOccurrencesOfString:@" ) " withString:@")"];
    NSArray * criteria_array  = [dictforparsing objectForKey:@"criteriaArray"];
    NSString *rhs=@"";
    NSString *NameFiled=@"",*Objecttype=@"";
    NSString *refrence_to=@"";
    NSString * NotOp = @"NOT(";
    @try
    {
    if([token rangeOfString:NotOp].length >0)
    {
        
        token = [token stringByReplacingOccurrencesOfString:@"(NOT(" withString:@" "];
        token = [token stringByReplacingOccurrencesOfString:@"LIKE" withString:@"NOT LIKE"];
       // token = [token stringByReplacingOccurrencesOfString:@")" withString:@" "];
        if([token rangeOfString:@")"].length >0)
        {
            NSRange  range = [token rangeOfString:@")"];
            NSUInteger location= range.location;
            token = [token stringByReplacingCharactersInRange:NSMakeRange(location, 2) withString:@""];
        }
    }
    
    for(NSString *operator in operatorArray)
    {
        if([token rangeOfString:operator].length > 0)
        {
            Count++;
            NSArray *operatorTokens = [token componentsSeparatedByString:operator];
            NSString *objectDef   = [operatorTokens objectAtIndex:0];
            NSString *objectValue = [operatorTokens objectAtIndex:1];
            NSString *objectDefWithoutBrace=[objectDef stringByReplacingOccurrencesOfString:@"(" withString:@""];      
            objectDefWithoutBrace=[objectDefWithoutBrace stringByReplacingOccurrencesOfString:@")" withString:@""];
            NSString *objectValueWithoutBrace=[objectValue stringByReplacingOccurrencesOfString:@"(" withString:@""];
            objectValueWithoutBrace=[objectValueWithoutBrace stringByReplacingOccurrencesOfString:@")" withString:@""];
            NSString *svmxLiterals=[objectValueWithoutBrace stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *fieldName=@"",*tableName=@"";
            if([objectDef rangeOfString:@"."].length >0)
            {
                SMLog(kLogLevelVerbose,@"Table Name is there");
                NSArray *fieldArray = [objectDef componentsSeparatedByString:@"."];
                tableName = [fieldArray objectAtIndex:0];
                fieldName = [fieldArray objectAtIndex:1];
                tableName = [tableName stringByReplacingOccurrencesOfString:@" " withString:@""];
                fieldName = [fieldName stringByReplacingOccurrencesOfString:@" " withString:@""];
                refrence_to=[self getRefrenceToField:[dictforparsing objectForKey:@"object"] relationship:objectDefWithoutBrace];
                if([tableName rangeOfString:@"__r"].length >0)
                {
                    NSDictionary *countDict=[self occurenceOfBraces:tableName];
                    tableName=[tableName stringByReplacingOccurrencesOfString:@"(" withString:@""];
                    tableName=[tableName stringByReplacingOccurrencesOfString:@")" withString:@""];
                    NSMutableString * queryStatementForRefrence = [[NSMutableString alloc]initWithCapacity:0];
                    queryStatementForRefrence = [NSMutableString stringWithFormat:@"SELECT reference_to from SFObjectField where object_api_name='%@' and relationship_name='%@'",[dictforparsing objectForKey:@"object"],tableName];    
                    sqlite3_stmt * labelstmtForRefrence;
                    const char *selectStatementForRefrence = [queryStatementForRefrence UTF8String];
                    char *field1;        
                    NSString *referenceObjectName=@"";
                    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatementForRefrence,-1, &labelstmtForRefrence, nil) == SQLITE_OK )
                    {
                        if(synchronized_sqlite3_step(labelstmtForRefrence) == SQLITE_ROW)
                        {
                            field1 = (char *) synchronized_sqlite3_column_text(labelstmtForRefrence,0);
                            if((field1 !=nil) && strlen(field1))
                                referenceObjectName =[NSString stringWithFormat:@"%s",field1];
                        }
                    }
                    synchronized_sqlite3_finalize(labelstmtForRefrence);

                    for (int i=0; i<[[countDict objectForKey:@"rightBraces"] intValue]; i++) 
                    {
                        if(!((i==0) && ([objectValue Contains:@"SVMX.CURRENTUSER"] || [objectValue Contains:@"SVMX.OWNER"])))
                        {
                            [finalQuery appendFormat:@"("];
                        }
                    }
                    if([objectValue rangeOfString:@"null"options:NSCaseInsensitiveSearch].length >0 &&([operator isEqualToString:@"!="] || [operator isEqualToString:@"<>"]) )
                    {
                        rhs=[NSString stringWithFormat:@"'%@'.%@",referenceObjectName,fieldName];
                        [finalQuery appendFormat:@"trim('%@'.%@)",referenceObjectName,fieldName];
                        for (int i=0; i<[[countDict objectForKey:@"leftBraces"] intValue]; i++)
                        {
                        	if(!((i==0) && ([objectValue Contains:@"SVMX.CURRENTUSER"] || [objectValue Contains:@"SVMX.OWNER"])))
	                            [finalQuery appendFormat:@" COLLATE NOCASE )"];
                        }
                    }
                    else if(![objectValue Contains:@"SVMX.CURRENTUSER"] && ![objectValue Contains:@"SVMX.OWNER"]&&![refrence_to isEqualToString:@"User"])
                    {
                        rhs=[NSString stringWithFormat:@"%@.%@",referenceObjectName,fieldName];
                        [finalQuery appendString:referenceObjectName];
                        [finalQuery appendString:@"."];
                        [finalQuery appendString:fieldName];
                        for (int i=0; i<[[countDict objectForKey:@"leftBraces"] intValue]; i++)
                        {
                            [finalQuery appendFormat:@" COLLATE NOCASE )"];
                        }
                    }
                    else
                    {
                        NameFiled=[self getRefrenceToField:[dictforparsing objectForKey:@"object"] relationship:referenceObjectName];
                        NSString *field=[[[dictforparsing objectForKey:@"criteriaArray"] objectAtIndex:tokenCount] objectForKey:@"SVMXC__Field_Name__c"];
                        Objecttype=[self getfieldTypeForApi:field fieldName:fieldName];
                    }
                    
                  
                }
                else
                {
                    NSDictionary *countBracesintableName=[self occurenceOfBraces:tableName];
                    NSDictionary *countBracesinFiledName=[self occurenceOfBraces:fieldName];
                    NSString * objectName = [dictforparsing objectForKey:@"object"];
                    refrence_to=[self getRefrenceToField:objectName relationship:[tableName stringByReplacingOccurrencesOfString:@"(" withString:@""]];
                    for (int i=0; i<[[countBracesintableName objectForKey:@"rightBraces"] intValue]; i++) 
                    {
                        if(!((i==0) && ([operator isEqualToString:@" NOT IN "] || [operator isEqualToString:@" IN "])))
                        {
                            [finalQuery appendFormat:@"("];
                        }
                    }
                    if([tableName isEqualToString:@"RecordType"])
                    {
                        
                        NSString * component_expression = [NSString stringWithFormat:@"'%@'.RecordTypeId   in   (select  record_type_id  from SFRecordType where record_type %@ %@ )" , objectName, operator,objectValue]; 
                        [finalQuery appendFormat:@"%@" , component_expression];
                    }
                    else if(![objectValue Contains:@"SVMX.CURRENTUSER"] && ![objectValue Contains:@"SVMX.OWNER"]&&![refrence_to isEqualToString:@"User"])
                    {
                        if([objectValue rangeOfString:@"null"options:NSCaseInsensitiveSearch].length >0 &&([operator isEqualToString:@"!="] || [operator isEqualToString:@"<>"]) )
                        {
                            [finalQuery appendFormat:@"trim('%@'.%@)",tableName,fieldName];
                        }
                        else
                        {
                            [finalQuery appendFormat:@"'%@'.%@",tableName,fieldName];
                        }
                        for (int i=0; i<[[countBracesinFiledName objectForKey:@"leftBraces"] intValue]; i++) 
                        {
                            if(!((i==0) && ([objectValue Contains:@"SVMX.CURRENTUSER"] || [objectValue Contains:@"SVMX.OWNER"])))
                            {
                                [finalQuery appendFormat:@" COLLATE NOCASE )"];
                            }
                        }
                        NSString *random=[self CreateRandomString:objectName] ;
                        NSString *refObjName=[self getRefrenceToField:objectName relationship:tableName];
                        if(![TableArray containsObject:tableName] && [tableName length] > 0)
                        {
                           /*
                            [TableArray addObject:tableName];
                            NSMutableArray * arry = [[NSMutableArray alloc] initWithCapacity:0];
                            [arry addObject:[[[dictforparsing objectForKey:@"criteriaArray"] objectAtIndex: Count] objectForKey:@"SVMXC__Field_Name__c"]];
                            [tableArrayDict setObject:arry forKey:tableName];
                            [tableArrayDict setObject:[[[dictforparsing objectForKey:@"criteriaArray"] objectAtIndex: Count] objectForKey:@"SVMXC__Field_Name__c"]  forKey:tableName ];
                            */
                            // releationShipName.Filed
                            [TableArray addObject:refObjName];
                            NSMutableDictionary *dictRel=[[NSMutableDictionary alloc]init];
                            [dictRel setObject:random forKey:tableName];
                            [tableArrayDict setObject:dictRel forKey:refObjName];
                            
                        }
                        else
                        {
                            /*
                            NSMutableArray * array =  [tableArrayDict objectForKey:tableName];
                            [array addObject:[[[dictforparsing objectForKey:@"criteriaArray"] objectAtIndex: Count] objectForKey:@"SVMXC__Field_Name__c"]];
                             */
                            NSMutableDictionary *Dict =  [tableArrayDict objectForKey:refObjName];
                            NSArray *keys=[Dict allKeys];
                            if(![keys containsObject:tableName])
                            {
                                [Dict setObject:random forKey:tableName];
                            }
                        }
                    }
                }
                
                [finalQuery appendString:@" "];
            }
            else 
            {
                refrence_to=[self getRefrenceToField:[dictforparsing objectForKey:@"object"] relationship:objectDefWithoutBrace];
                SMLog(kLogLevelVerbose,@"Table Name is not there. Append Object Name as Table Name");
                NSDictionary *dictforBraces=[self occurenceOfBraces:objectDef];
                for (int i=0; i<[[dictforBraces objectForKey:@"rightBraces"] intValue]; i++) 
                {
                    if(!((i==0) && ([objectValue Contains:@"SVMX.CURRENTUSER"]||[objectValue Contains:@"SVMX.OWNER"])))
                    {
                        [finalQuery appendFormat:@"("];
                    }
                }
                
                if([objectValue rangeOfString:@"null"options:NSCaseInsensitiveSearch].length >0 &&([operator isEqualToString:@"!="] || [operator isEqualToString:@"<>"]) )
                {
                    
                    [finalQuery appendFormat:@"trim('%@'.%@)",[self getApiNameFromFieldLabel:[dictforparsing objectForKey:@"strTargetObject"]],objectDefWithoutBrace];
                    rhs=[NSString stringWithFormat:@"'%@'.%@",[self getApiNameFromFieldLabel:[dictforparsing objectForKey:@"strTargetObject"]],objectDefWithoutBrace];
                }
                else if(![objectValue Contains:@"SVMX.CURRENTUSER"] && ![objectValue Contains:@"SVMX.OWNER"])
                {
                    rhs=[NSString stringWithFormat:@"'%@'.%@",[self getApiNameFromFieldLabel:[dictforparsing objectForKey:@"strTargetObject"]],objectDefWithoutBrace];
                    [finalQuery appendFormat:@"'%@'",[self getApiNameFromFieldLabel:[dictforparsing objectForKey:@"strTargetObject"]]];
                    [finalQuery appendString:@"."];
                    [finalQuery appendString:objectDefWithoutBrace];
                }
                fieldName = objectDefWithoutBrace;
                fieldName = [fieldName stringByReplacingOccurrencesOfString:@" " withString:@""];
                for (int i=0; i<[[dictforBraces objectForKey:@"leftBraces"] intValue]; i++) 
                {
                    if(!((i==0) && ([objectValue Contains:@"SVMX.CURRENTUSER"] || [objectValue Contains:@"SVMX.OWNER"])))
                    {
                        [finalQuery appendFormat:@" COLLATE NOCASE )"];
                    }
                }
            }
            if([objectValue rangeOfString:@"null"options:NSCaseInsensitiveSearch].length >0)
            {
                NSDictionary *Bracesinvalue=[self occurenceOfBraces:objectValue];
                if([objectValueWithoutBrace Contains:@"null"] &&([operator isEqualToString:@"!="] || [operator isEqualToString:@"<>"]) )
                {
                    //Keerti: 5157
                    if([rhs length]>0)
                    {
                        [finalQuery appendFormat:@" !='' OR %@ IS NOT NULL",rhs];
                    }
                    else
                    [finalQuery appendFormat:@" != '' "];
                }
                else
                {
//                    [finalQuery appendString:@" isnull"];
                    //Keerti: 5157
                    if([rhs length]>0)
                    {
                        [finalQuery appendFormat:@" ='' OR %@ isnull",rhs];
                    }
                    else
                        [finalQuery appendFormat:@"= '' "];
                }
                
                
                for (int i=0; i<[[Bracesinvalue objectForKey:@"leftBraces"] intValue]; i++) 
                {
                    if(!((i==0) && ([objectValue Contains:@"SVMX.CURRENTUSER"] || [objectValue Contains:@"SVMX.OWNER"])))
                    {
                        [finalQuery appendFormat:@" COLLATE NOCASE )"];
                    }
                }
            }
            else if([refrence_to isEqualToString:@"User"]||[objectValue Contains:@"SVMX.CURRENTUSER"] || [objectValue Contains:@"SVMX.OWNER"])
            {
                NSString * objectName = [dictforparsing objectForKey:@"object"];
                refrence_to=[self getRefrenceToField:objectName relationship:[tableName stringByReplacingOccurrencesOfString:@"(" withString:@""]];
                NSString * component_expression=@"";
                
                if([objectValue Contains:@"SVMX.CURRENTUSER"] || [objectValue Contains:@"SVMX.OWNER"])
                {
                    if([Objecttype length]>0)
                    Objecttype=[self getfieldTypeForApi:objectName fieldName:fieldName];
                    if(![Objecttype isEqualToString:@"refrence"]||![Objecttype isEqualToString:@"refrence"])
                    {
                        
                        NSString *UserFullName=@"", *UserNameValue=@"";
                        if(![appDelegate.userDisplayFullName length]>0)
                        {
                            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                            if ([[userDefaults objectForKey:USERFULLNAME] length]>0)
                            {
                                UserFullName = [userDefaults objectForKey:USERFULLNAME]; //To get user display name not email id
                                SMLog(kLogLevelVerbose,@"User Full Name  = %@",UserFullName);
                            }
                            else
                            {
                                UserFullName=[self getLoggedInUser:appDelegate.username];
                            }
                        }
                        else
                        {
                            UserFullName=appDelegate.userDisplayFullName;
                        }
                        if([UserFullName length]>0)
                        {
                            if([objectValue Contains:@"SVMX.CURRENTUSER"])
                            {
                                UserNameValue=[objectValue stringByReplacingOccurrencesOfString:@"SVMX.CURRENTUSER" withString:UserFullName];
                            }
                            else if([objectValue Contains:@"SVMX.OWNER"])
                            {
                                UserNameValue=[objectValue stringByReplacingOccurrencesOfString:@"SVMX.OWNER" withString:UserFullName];

                            }
                            //Keerti - 7275
                            NSMutableString *strTemp=[[[NSMutableString alloc]init]autorelease]; // Defect 008301 
                            [strTemp appendString:UserNameValue];
                            [strTemp appendString:@" COLLATE NOCASE "];
                            UserNameValue=strTemp;
                        }

                        if([refrence_to length]>0)
                        {
                                component_expression = [NSString stringWithFormat:@"'%@'.%@ %@ %@" , refrence_to,fieldName, operator,UserNameValue];
                        }
                        else
                        {
                                component_expression = [NSString stringWithFormat:@"'%@'.%@ %@ %@" ,[dictforparsing objectForKey:@"object"] ,fieldName, operator,UserNameValue];

                        }
                        [finalQuery appendString:component_expression];
                        
                    }
                    else
                    {
                        if(appDelegate.loggedInUserId == nil)
                        {
                            appDelegate.loggedInUserId=[self getLoggedInUserId:appDelegate.username];
                        }
                        NSString *field=[[[dictforparsing objectForKey:@"criteriaArray"] objectAtIndex:Count] objectForKey:@"SVMXC__Field_Name__c"];
                        component_expression = [NSString stringWithFormat:@"'%@'.%@ %@ '%@'" , objectName,field, operator,appDelegate.loggedInUserId];
                        [finalQuery appendString:component_expression];
                        [finalQuery appendString:@" COLLATE NOCASE "];
                          
                    }
                }
                else
                {
                    NSString *field=[[[dictforparsing objectForKey:@"criteriaArray"] objectAtIndex:Count] objectForKey:@"SVMXC__Field_Name__c"];
                    component_expression = [NSString stringWithFormat:@"'%@'.%@   in   (select  Id  from User where Name %@ %@ )" , objectName,field, operator,objectValue];
                    [finalQuery appendString:component_expression];
                }
                NSDictionary *valueBracesOccurence=[self occurenceOfBraces:objectValue];

                for (int i=0; i<[[valueBracesOccurence objectForKey:@"leftBraces"] intValue]; i++)
                {

                    if(!([objectValue Contains:@"SVMX.CURRENTUSER"] || [objectValue Contains:@"SVMX.OWNER"]))
                    {
                        [finalQuery appendFormat:@" COLLATE NOCASE )"];
                    }
                }
            }

            else if(([[self getDataTypeFor:fieldName inArray:criteria_array] isEqualToString:BOOLEAN]) && ([objectValue rangeOfString:@"True"options:NSCaseInsensitiveSearch].length >0))
            {
                NSDictionary *Bracesinvalue=[self occurenceOfBraces:objectValue];
                [finalQuery appendString:operator];
//                objectValueWithoutBrace=[objectValueWithoutBrace stringByReplacingOccurrencesOfString:@"True"withString:@"1"];
                objectValueWithoutBrace=[objectValueWithoutBrace stringByReplacingOccurrencesOfString:@"True"withString:@"1" options:NSCaseInsensitiveSearch range:NSMakeRange(0,[objectValueWithoutBrace length] )];

                [finalQuery appendString:objectValueWithoutBrace];
                for (int i=0; i<[[Bracesinvalue objectForKey:@"leftBraces"] intValue]; i++) 
                {
                    if(!((i==0) && ([operator isEqualToString:@" NOT IN "] || [operator isEqualToString:@" IN "])))
                    {
                        [finalQuery appendFormat:@" COLLATE NOCASE )"];
                    }
                }
            }
            else if(([[self getDataTypeFor:fieldName inArray:criteria_array] isEqualToString:BOOLEAN]) && ([objectValue rangeOfString:@"False"options:NSCaseInsensitiveSearch].length>0))
            {
                NSDictionary *Bracesinvalue=[self occurenceOfBraces:objectValue];
                [finalQuery appendString:operator];
                objectValueWithoutBrace=[objectValueWithoutBrace stringByReplacingOccurrencesOfString:@"False"withString:@"0" options:NSCaseInsensitiveSearch range:NSMakeRange(0,[objectValueWithoutBrace length] )];

//                objectValueWithoutBrace=[objectValueWithoutBrace stringByReplacingOccurrencesOfString:@"False"withString:@"0"];
                [finalQuery appendString:objectValueWithoutBrace];
                for (int i=0; i<[[Bracesinvalue objectForKey:@"leftBraces"] intValue]; i++) 
                {
                    if(!((i==0) && ([operator isEqualToString:@" NOT IN "] || [operator isEqualToString:@" IN "])))
                    {
                        [finalQuery appendFormat:@" COLLATE NOCASE )"];
                    }
                }
            }   
          else if (([svmxLiterals caseInsensitiveCompare:MACRO_TODAY]== NSOrderedSame) ||
                 ([svmxLiterals caseInsensitiveCompare:MACRO_TOMMOROW]== NSOrderedSame) ||
                 ([svmxLiterals caseInsensitiveCompare:MACRO_YESTERDAY]== NSOrderedSame)||
                 ([svmxLiterals caseInsensitiveCompare:MACRO_NOW]== NSOrderedSame ))
            {
                NSDictionary *Bracesinvalue=[self occurenceOfBraces:objectValue];
                
                
                NSTimeInterval secondsPerDay = 24 * 60 * 60;
                
                NSString * today_Date ,* tomorow_date ,* yesterday_date;
                
                NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                NSDate *today = [NSDate date];;
                
                NSDate *tomorrow, *yesterday;
                
                tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
                
                yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
                
        
                
                //for macros expantion
                if([[self getDataTypeFor:fieldName inArray:criteria_array] isEqualToString:@"DATE"])
                {
                    [finalQuery appendString:operator];
                    [finalQuery appendString:@"'"];
                    
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    
                    today_Date = [dateFormatter stringFromDate:today];
                    tomorow_date = [dateFormatter stringFromDate:tomorrow];
                    yesterday_date = [dateFormatter stringFromDate:yesterday];
                    
                    if([svmxLiterals caseInsensitiveCompare:MACRO_TODAY]== NSOrderedSame)
                    {
                        [finalQuery appendString:today_Date];
                        
                    }
                    if([svmxLiterals caseInsensitiveCompare:MACRO_TOMMOROW]== NSOrderedSame)
                    {
                       [finalQuery appendString:tomorow_date];
                        
                    }
                    if([svmxLiterals caseInsensitiveCompare:MACRO_YESTERDAY]== NSOrderedSame)
                    {
                        [finalQuery appendString:yesterday_date];
                    }
                    for (int i=0; i<[[Bracesinvalue objectForKey:@"leftBraces"] intValue]; i++) 
                    {
                        if(!((i==0) && ([operator isEqualToString:@" NOT IN "] || [operator isEqualToString:@" IN "])))
	                        [finalQuery appendFormat:@"  COLLATE NOCASE )"];
                    }
                    [finalQuery appendString:@"'"];

                }
                
                if([[self getDataTypeFor:fieldName inArray:criteria_array] isEqualToString:@"DATETIME"])
                {
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    NSString *start_datetime,*end_datetime;
                    today_Date = [dateFormatter stringFromDate:today];
                    tomorow_date = [dateFormatter stringFromDate:tomorrow];
                    yesterday_date = [dateFormatter stringFromDate:yesterday];

                    if(([svmxLiterals caseInsensitiveCompare:MACRO_TODAY]== NSOrderedSame)||
                       ([svmxLiterals caseInsensitiveCompare:MACRO_NOW]== NSOrderedSame) )
                    {
                        start_datetime = [today_Date stringByAppendingFormat:@"T00:00:00.000+0000"];
                        end_datetime   = [today_Date stringByAppendingFormat:@"T24:00:00.000+0000"];  
                        if([operator isEqualToString:@"="])
                        {
                                        
                            [finalQuery appendString:@" >= "];
                            [finalQuery appendFormat:@"'%@'",start_datetime];
                            [finalQuery appendFormat:@" AND %@",rhs];
                            [finalQuery appendFormat:@" < '%@",end_datetime];
                        }
                        else if([operator isEqualToString:@"<"] || [operator isEqualToString:@"<="])
                        {
                            [finalQuery appendFormat:@" %@",operator];
                            [finalQuery appendFormat:@"'%@",start_datetime];
                        }
                        else if([operator isEqualToString:@">"] || [operator isEqualToString:@">="])
                        {
                            [finalQuery appendFormat:@" %@",operator];
                            [finalQuery appendFormat:@"'%@",end_datetime];
                            
                        }
                        else if ([operator isEqualToString:@"<>"])
                        {
                            [finalQuery appendFormat:@"<"];
                            [finalQuery appendFormat:@"'%@'",start_datetime];
                            [finalQuery appendFormat:@" AND %@",rhs];
                            
                            [finalQuery appendFormat:@">"];
                            [finalQuery appendFormat:@"'%@",end_datetime];
                        }
                    }
                    
                    if([svmxLiterals caseInsensitiveCompare:MACRO_TOMMOROW] == NSOrderedSame)
                    {
                        start_datetime = [tomorow_date stringByAppendingFormat:@"T00:00:00.000+0000"];
                        end_datetime   = [tomorow_date stringByAppendingFormat:@"T24:00:00.000+0000"];  
                        if([operator isEqualToString:@"="])
                        {
                            
                            [finalQuery appendString:@" >= "];
                            [finalQuery appendFormat:@"'%@'",start_datetime];
                            [finalQuery appendFormat:@" AND %@",rhs];
                            [finalQuery appendFormat:@" < '%@",end_datetime];
                        }
                        else if([operator isEqualToString:@"<"] || [operator isEqualToString:@"<="])
                        {
                            [finalQuery appendFormat:@" %@",operator];
                            [finalQuery appendFormat:@"'%@",start_datetime];
                            
                        }
                        else if([operator isEqualToString:@">"] || [operator isEqualToString:@">="])
                        {
                            [finalQuery appendFormat:@" %@",operator];
                            [finalQuery appendFormat:@"'%@",end_datetime];
                            
                        }
                        else if ([operator isEqualToString:@"<>"])
                        {
                            [finalQuery appendFormat:@"<"];
                            [finalQuery appendFormat:@"'%@'",start_datetime];
                            [finalQuery appendFormat:@" AND %@",rhs];
                            
                            [finalQuery appendFormat:@">"];
                            [finalQuery appendFormat:@"'%@",end_datetime];
                        }
                    }
                    
                    if([svmxLiterals caseInsensitiveCompare:MACRO_YESTERDAY] == NSOrderedSame)
                    {
                        start_datetime = [yesterday_date stringByAppendingFormat:@"T00:00:00.000+0000"];
                        end_datetime   = [yesterday_date stringByAppendingFormat:@"T24:00:00.000+0000"];  
                        if([operator isEqualToString:@"="])
                        {
                            
                            [finalQuery appendString:@" >= "];
                            [finalQuery appendFormat:@"'%@'",start_datetime];
                            [finalQuery appendFormat:@" AND %@",rhs];
                            [finalQuery appendFormat:@" < '%@",end_datetime];
                        }
                        else if([operator isEqualToString:@"<"] || [operator isEqualToString:@"<="])
                        {
                            [finalQuery appendFormat:@" %@",operator];
                            [finalQuery appendFormat:@"'%@",start_datetime];
                            
                        }
                        else if([operator isEqualToString:@">"] || [operator isEqualToString:@">="])
                        {
                            [finalQuery appendFormat:@" %@",operator];
                            [finalQuery appendFormat:@"'%@",end_datetime];
                            
                        }
                        else if ([operator isEqualToString:@"<>"])
                        {
                            [finalQuery appendFormat:@"<"];
                            [finalQuery appendFormat:@"'%@'",start_datetime];
                            [finalQuery appendFormat:@" AND %@",rhs];
                            
                            [finalQuery appendFormat:@">"];
                            [finalQuery appendFormat:@"'%@",end_datetime];
                        }
                    }
                    for (int i=0; i<[[Bracesinvalue objectForKey:@"leftBraces"] intValue]; i++) 
                    {
                        if(!((i==0) && ([operator isEqualToString:@" NOT IN "] || [operator isEqualToString:@" IN "])))
                        {
                            [finalQuery appendFormat:@" COLLATE NOCASE )"];
                        }
                    }
                    [finalQuery appendString:@"'"];
                }
                //krishna 23-1 memory opt 9493
                [dateFormatter release];
                dateFormatter = nil;
            }
            else
            {
                NSDictionary *valueBracesOccurence=[self occurenceOfBraces:objectValue];
                if(![tableName isEqualToString:@"RecordType"] &&![objectValue Contains:@"SVMX.CURRENTUSER"] &&![objectValue Contains:@"SVMX.OWNER"]&&![refrence_to isEqualToString:@"User"])
                {
                    if([operator isEqualToString:@" NOT IN "] || [operator isEqualToString:@" IN "])
                    {
                        [finalQuery appendString:operator];
                         [finalQuery appendString:@"("];
                        [finalQuery appendString:objectValueWithoutBrace];

                    }
                    else
                    {
                        [finalQuery appendFormat:@" %@",operator];
                        [finalQuery appendString:objectValueWithoutBrace];
						if([operator isEqualToString:@">="] || [operator isEqualToString:@">"]) //Keerti Fix for #5157
						{
							[finalQuery appendString:@" AND"];
							[finalQuery appendString:rhs];
							[finalQuery appendString:@"!= ''"];
							[finalQuery appendString:@" AND"];
							[finalQuery appendString:rhs];
							[finalQuery appendString:@"!= ' '"];
							
						}
                    }
                    for (int i=0; i<[[valueBracesOccurence objectForKey:@"leftBraces"] intValue]; i++) 
                    {
                        if(!((i==0) && ([operator isEqualToString:@" NOT IN "] || [operator isEqualToString:@" IN "])))
                        {
                            [finalQuery appendFormat:@" COLLATE NOCASE )"];
                        }
                    }
                }
                                
            }
            [resultDict setObject:TableArray forKey:@"TableArray"];
            [resultDict setObject:tableArrayDict forKey:@"tableArrayDict"];
            [resultDict setObject:finalQuery forKey:@"finalQuery"];
            break;    
        }    
    }
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name Database :getupdatedToken %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason Database :getupdatedToken %@",exp.reason);
         [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    return resultDict;
}
-(NSString*) getRefrenceToField:(NSString*)objectName relationship:(NSString*) relationship_name
{
    NSMutableString * queryStatementForRefrence = [[NSMutableString alloc]initWithCapacity:0];
    queryStatementForRefrence = [NSMutableString stringWithFormat:@"SELECT reference_to from SFObjectField where object_api_name='%@' and relationship_name='%@'",objectName,relationship_name];    
    sqlite3_stmt * labelstmtForRefrence;
    const char *selectStatementForRefrence = [queryStatementForRefrence UTF8String];
    char *field1=nil;
    NSString *referenceObjectName=@"";
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatementForRefrence,-1, &labelstmtForRefrence, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmtForRefrence) == SQLITE_ROW)
        {
            field1 = (char *) synchronized_sqlite3_column_text(labelstmtForRefrence,0);
            if((field1 !=nil) && strlen(field1))
                referenceObjectName =[NSString stringWithFormat:@"%s",field1];
        }
    }
    synchronized_sqlite3_finalize(labelstmtForRefrence);
    return referenceObjectName;

}
-(NSMutableDictionary*) occurenceOfBraces:(NSString*)token
{
    NSUInteger countRight = 0,countLeft=0;
    NSMutableDictionary *bracesCount=[[NSMutableDictionary alloc]init];
    @try
    {
    if([token Contains:@"("])
    {
        NSUInteger length = [token length];
        NSRange range = NSMakeRange(0, length); 
        while(range.location != NSNotFound)
        {
            range = [token rangeOfString: @"(" options:0 range:range];
            if(range.location != NSNotFound)
            {
                range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
                countRight++; 
            }
        }
        
        [bracesCount setObject:[NSString stringWithFormat:@"%d",countRight] forKey:@"rightBraces"];
    }
    else
    {
        [bracesCount setObject:[NSString stringWithFormat:@"%d",countRight] forKey:@"rightBraces"];

    }
    if([token Contains:@")"])
    {
            NSUInteger length = [token length];
            NSRange range = NSMakeRange(0, length); 
            while(range.location != NSNotFound)
            {
                range = [token rangeOfString: @")" options:0 range:range];
                if(range.location != NSNotFound)
                {
                    range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
                    countLeft++; 
                }
            }
            [bracesCount setObject:[NSString stringWithFormat:@"%d",countLeft] forKey:@"leftBraces"];
    }
    else
    {
        [bracesCount setObject:[NSString stringWithFormat:@"%d",countLeft] forKey:@"leftBraces"];

    }
   }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name Database :occurenceOfBraces %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason Database :occurenceOfBraces %@",exp.reason);
       [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    return bracesCount;
}

-(NSString *)getvalueforReference:(NSDictionary*) tableArray value:(NSString*)value
{
    NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
    queryStatement1 = [NSMutableString stringWithFormat:@"SELECT type,reference_to FROM SFObjectField where object_api_name = '%@'and api_name='%@'",[appDelegate.dataBase getApiNameFromFieldLabel:[tableArray objectForKey:@"SVMXC__Object_Name2__c"]],[appDelegate.dataBase getApiNameFromFieldLabel:[tableArray objectForKey:@"SVMXC__Field_Name__c"]]];
    sqlite3_stmt * labelstmt;
    const char *selectStatement = [queryStatement1 UTF8String];
    char *type=nil,*refrence_to=nil,*name_field=nil;
    NSString *strName_field=nil,*namefiled=@"";
    @try
    {
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
        {
            type = (char *) synchronized_sqlite3_column_text(labelstmt,0);
            refrence_to = (char *) synchronized_sqlite3_column_text(labelstmt,1);
        }
    }
        
    NSString *strType,*strRefrence_to;
    if((type != nil)&& strlen(type))
        strType=[NSString stringWithFormat:@"%s",type];
    else
        strType=@" ";
    if((refrence_to != nil)&& strlen(refrence_to))
        strRefrence_to=[NSString stringWithFormat:@"%s",refrence_to];
    else
        strRefrence_to=@" ";
    
    synchronized_sqlite3_finalize(labelstmt); //keerti - 7276

    if([strType isEqualToString:@"reference"])
    {
        
        queryStatement1 = [NSMutableString stringWithFormat:@"SELECT api_name FROM SFObjectField where name_field='TRUE' and object_api_name='%@'",strRefrence_to];    
        sqlite3_stmt * labelstmt;
        const char *selectStatement = [queryStatement1 UTF8String];
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
        {
            if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
            {
                name_field = (char *) synchronized_sqlite3_column_text(labelstmt,0);
                if ((name_field !=nil) && strlen(name_field))
                    namefiled=[NSString stringWithFormat:@"%s",name_field];
            }
        }
        synchronized_sqlite3_finalize(labelstmt);
        
        NSString *queryRefrefield = [NSMutableString stringWithFormat:@"SELECT %@ FROM '%@' where Id='%@'",namefiled,strRefrence_to,value]; //strReference_to added - Keerti - 7276
        sqlite3_stmt * queryRefrefieldstmt;
        const char *queryRefrefieldselectStatement = [queryRefrefield UTF8String];
        char *obejctFiled;
        NSString *refrenceObject=nil;
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, queryRefrefieldselectStatement,-1, &queryRefrefieldstmt, nil) == SQLITE_OK )
        {
            if(synchronized_sqlite3_step(queryRefrefieldstmt) == SQLITE_ROW)
            {
                obejctFiled = (char *) synchronized_sqlite3_column_text(queryRefrefieldstmt,0);
                if ((obejctFiled !=nil) && strlen(obejctFiled))
                {
                    refrenceObject=[NSString stringWithFormat:@"%s",obejctFiled];
                    strName_field=refrenceObject;
                }
            }
        }
        if(!refrenceObject)
        {
           strName_field=[self getValueFromLookupwithId:value];
            if (![strName_field length]>0)
            {
                strName_field=value;
            }
        }
        synchronized_sqlite3_finalize(queryRefrefieldstmt); //Keerti - 7276
    }
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Reason Database :getvalueforReference %@ \n reason :%@",exp.name, exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    return strName_field;

}
- (NSString *)getValueFromLookupwithId:(NSString *)_Id
{
    NSString * Id = @"";
	NSString * selectQuery = [NSString stringWithFormat:@"Select DISTINCT value from LookUpFieldValue where Id = '%@'", _Id];
	
	sqlite3_stmt * statement;
    const char * _selectQuery = [selectQuery UTF8String];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, _selectQuery,-1, &statement, nil) == SQLITE_OK)
    {
        
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW){
            char * field1 = (char *) synchronized_sqlite3_column_text(statement, COLUMN_1);
            if (field1 != nil)
                Id = [[NSString alloc] initWithUTF8String:field1];
            
        }
    }
    synchronized_sqlite3_finalize(statement); 
	
	return Id;
}
 
- (NSString *) getFieldLabelForApiName:(NSString *)apiName
{
    NSString *queryStatement = [NSString stringWithFormat:@"SELECT label from SFObject where api_name = '%@'",apiName];
    //    SMLog(kLogLevelVerbose,@"Query Statement = %@",queryStatement);
    sqlite3_stmt * statement;
    NSString *apiLabel = apiName;
    if(appDelegate == nil)
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
//            const char * label = (char *)synchronized_sqlite3_column_text(statement, 0);
            char * label = (char *)synchronized_sqlite3_column_text(statement, 0);
            if ((label != nil) && strlen(label))
            {
                apiLabel = [NSString stringWithUTF8String:label];
//                apiLabel = [NSString stringWithFormat:@"%s",label];
            }
        }
    }
    
    synchronized_sqlite3_finalize(statement);
    return apiLabel;
       
}
- (NSString *) getApiNameFromFieldLabel:(NSString *)labelName
{
    NSString *queryStatement = [NSString stringWithFormat:@"SELECT api_name from SFObject where label = '%@'",labelName];
    sqlite3_stmt * statement;
    NSString *apiName = labelName;
    if(appDelegate == nil)
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * label = (char *)synchronized_sqlite3_column_text(statement, 0);
            if ((label !=nil) && strlen(label))
            {
                apiName = [NSString stringWithUTF8String:label];

            }
        }
        synchronized_sqlite3_finalize(statement);
    }
    return [apiName retain];
}
- (NSString*) getLabelFromApiName:(NSString*)api_name objectName:(NSString*) objectName
{ 
    NSString *queryStatement = [NSString stringWithFormat:@"SELECT label from SFObjectField where api_name ='%@' and object_api_name='%@'",api_name,objectName];
    sqlite3_stmt * statement;
    NSString *apiLabel = api_name;
    if(appDelegate == nil)
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * label = (char *)synchronized_sqlite3_column_text(statement, 0);
            if ((label != nil) && strlen(label))
            {
                apiLabel = [NSString stringWithUTF8String:label];   
            }
        }
    }
    
    synchronized_sqlite3_finalize(statement);
    return apiLabel;
    
}

#pragma mark - SFM Search Alias
- (NSMutableArray *) getResultsForSFM:(NSString *)object withConfigData:(NSDictionary *)dataForObject
{
    // For Alias and sorting implementation
    isSortingDone=FALSE; //Keerti - 7275
    NSMutableArray *searchableArray = [dataForObject objectForKey:@"SearchableFields"];
    if(![searchableArray count]>0)
    {
        NSMutableDictionary *dictforSearchObject=[[NSMutableDictionary alloc]init];
        [dictforSearchObject setObject:object forKey:@"SVMXC__Object_Name2__c"];
        [dictforSearchObject setObject:[self getNameFiled:object] forKey:@"SVMXC__Field_Name__c"];
        [dictforSearchObject setObject:@"" forKey:LOOKUP_FIELD_API_NAME]; 
        [dictforSearchObject setObject:@"" forKey:FIELD_RELATIONSHIP_NAME];
        [dictforSearchObject setObject:@"" forKey:OBJECT_FIELD_NAME];
        [searchableArray addObject:dictforSearchObject];
        [dictforSearchObject release];
    }
    NSDictionary *uiControlsValue=[dataForObject objectForKey:@"uiControls"];
    NSMutableArray *searchableArrayTemp=[[NSMutableArray alloc]init];
    NSArray *displayArray = [dataForObject objectForKey:@"DisplayFields"];
    NSMutableArray *displayArrayTemp=[[NSMutableArray alloc]init];
    NSMutableArray *TableArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *tableArrayDict=[[NSMutableDictionary alloc]init];
    NSArray *criteriaArray = [dataForObject objectForKey:@"SearchCriteriaFields"];
    NSMutableArray * sortingArray=[dataForObject objectForKey:@"SortingFields"];
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSMutableString *finalQuery = [[NSMutableString alloc] init];
    NSMutableString *queryFields = [[NSMutableString alloc] init];
    NSMutableString *joinFields = [[NSMutableString alloc] init];
    NSMutableString *selectQueryElement = [[NSMutableString alloc] init];
    NSMutableString *orderByElement = [[NSMutableString alloc] init];
    NSString *objectId = [dataForObject objectForKey:@"ObjectId"];
    NSMutableDictionary *dictforparsing = [[NSMutableDictionary alloc]init];
    NSDictionary *logicalParsingResult = [[NSDictionary alloc ]init];
    NSMutableArray *searchFieldsArr = [[NSMutableArray alloc]init];
    NSMutableArray *sortingFieldArray = [[NSMutableArray alloc]init];
    NSMutableString *customizeSearch = [[NSMutableString alloc]init];
    NSMutableArray *arrayQueryField = [[NSMutableArray alloc]init];
    NSString *relationship_name=@"";
    NSMutableArray *skippedFields=[[NSMutableArray alloc]init];
    [dictforparsing setObject:object forKey:@"object"];
    int fieldsCount = 2;
    [queryFields appendString:[NSString stringWithFormat:@"'%@'.Id",object]]; // Change it to 1st display field
    [queryFields appendString:@","];
    [queryFields appendString:[NSString stringWithFormat:@"'%@'.local_id",object]];
    @try{
        for (int i=0; i<[displayArray count]; i++)
        {
            NSString *fieldName = [[displayArray objectAtIndex:i] objectForKey:@"SVMXC__Field_Name__c"];//field
            NSString *ApifieldName = [self getApiNameFromFieldLabel:fieldName];
            NSString *TableName = [[displayArray objectAtIndex:i] objectForKey:@"SVMXC__Object_Name2__c"];//Table
            NSString *ApiTableName = [self getApiNameFromFieldLabel:TableName];
            
            NSString *lookupRelationship = [[displayArray objectAtIndex:i] objectForKey:@"SVMXC__Lookup_Field_API_Name__c"];
            NSString *fieldRelation = [[displayArray objectAtIndex:i] objectForKey:@"SVMXC__Field_Relationship_Name__c"];
            NSString *random=[self CreateRandomString:ApiTableName] ;
            if([self isTabelExistInDB:ApiTableName])
            {
                if(![ApiTableName isEqualToString:object])
                {
                    if(![lookupRelationship length]>0)
                    {
                        relationship_name=fieldRelation;
                    }
                    else
                    {
                        relationship_name=lookupRelationship;
                    }
                    if(![TableArray containsObject:ApiTableName] )
                    {
                        [TableArray addObject:ApiTableName];
                        NSMutableDictionary *dictRel=[[NSMutableDictionary alloc]init];
                        [dictRel setObject:random forKey:relationship_name];
                        [tableArrayDict setObject:dictRel forKey:ApiTableName ];
//                        if(![arrayQueryField containsObject:[NSString stringWithFormat:@"'%@'.%@",random ,ApifieldName]]) //commented - keerti - 7275
                        [arrayQueryField addObject:[NSString stringWithFormat:@"'%@'.%@",random ,ApifieldName]];
                        
                    }
                    else
                    {
                        NSMutableDictionary *Dict =  [tableArrayDict objectForKey:ApiTableName];
                        NSArray *keys=[Dict allKeys];
                        if(![keys containsObject:relationship_name])
                        {
                            [Dict setObject:random forKey:relationship_name];
//                            if(![arrayQueryField containsObject:[NSString stringWithFormat:@"'%@'.%@",random ,ApifieldName]]) //commented - keerti - 7275
                            [arrayQueryField addObject:[NSString stringWithFormat:@"'%@'.%@",random ,ApifieldName]];
                        }
                        else
                        {
                            NSString *aliasName = [Dict objectForKey:relationship_name];
                            
                            [arrayQueryField addObject:[NSString stringWithFormat:@"'%@'.%@",aliasName ,ApifieldName]];
                        }
                    }
                    
                }
                else
                {
//                    if(![arrayQueryField containsObject:[NSString stringWithFormat:@"'%@'.%@",object ,ApifieldName]]) //commented - keerti - 7275
                    {
                        [arrayQueryField addObject:[NSString stringWithFormat:@"'%@'.%@",object ,ApifieldName]];
                    }
                }
                fieldsCount++;
                [displayArrayTemp addObject:[displayArray objectAtIndex:i]];
            }
            else
            {
                [skippedFields addObject:[NSString stringWithFormat:@"%@.%@",ApiTableName ,ApifieldName]];
                SMLog(kLogLevelVerbose,@"Display Field skipped as no table named %@ ",[NSString stringWithFormat:@"%@.%@",ApiTableName ,ApifieldName]);
            }
        }
        
        for (int i=0; i<[searchableArray count]; i++)
        {
            ///////////////////////// Search Fields ///////////////////////////////////////////////////////////
            ///// Search on name for 1st and 2nd level objects, For 2 level 2 join req to access Name filed////
            NSMutableArray *objectArray=[[NSMutableArray alloc]init];
            
            NSString *fieldName = [[searchableArray objectAtIndex:i] objectForKey:@"SVMXC__Field_Name__c"];//field
            NSString *ApifieldName = [self getApiNameFromFieldLabel:fieldName];

            NSString *TableName = [[searchableArray objectAtIndex:i] objectForKey:@"SVMXC__Object_Name2__c"];//Table
            NSString *ApiTableName = [self getApiNameFromFieldLabel:TableName];
            
            [objectArray addObject:ApiTableName];
            
            NSString *lookupRelationship = [[searchableArray objectAtIndex:i] objectForKey:@"SVMXC__Lookup_Field_API_Name__c"];
            NSString *fieldRelation = [[searchableArray objectAtIndex:i] objectForKey:@"SVMXC__Field_Relationship_Name__c"];
            NSString *objectName = [[searchableArray objectAtIndex:i] objectForKey:@"SVMXC__Object_Name__c"];
            if([objectName length]>0)
            {
                [objectArray addObject:objectName];
            }
            // Changes for 2 level in SVMXC__Field_Relationship_Name__c and SVMXC__Lookup_Field_API_Name__c
            if([objectName length]>0)
            {
                ApiTableName=objectName; // For 2nd Level In search field no need to refer 1st level hierarchy
            }
            if([self isTabelExistInDB:ApiTableName])
            {
                if(![ApiTableName isEqualToString:object])
                {
                    if(![lookupRelationship length]>0)
                    {
                        relationship_name=fieldRelation;
                        ApifieldName=[[self getNameFiled:ApiTableName]length] >0?[self getNameFiled:ApiTableName]:ApifieldName;
                    }
                    else
                    {
                        if(![lookupRelationship length]>0)
                        {
                            relationship_name=fieldRelation;
                        }
                        else
                        {
                            relationship_name=lookupRelationship;
                        }
                        
                        ApifieldName=[[self getNameFiled:ApiTableName] length] >0?[self getNameFiled:ApiTableName]:ApifieldName;
                    }
                    for(int i=0;i<[objectArray count];i++)
                    {
                        // For Joining the 1st and 2nd level Tables 
                        if(![[objectArray objectAtIndex:i ]  isEqualToString:object] && [self isTabelExistInDB:[objectArray objectAtIndex:i]])
                        {
                            NSString *random=[self CreateRandomString:ApiTableName];
                            NSString *tempTableName=@"";
                            if(![TableArray containsObject:[objectArray objectAtIndex:i]] )
                            {
                                [TableArray addObject:[objectArray objectAtIndex:i]];
                                NSMutableDictionary *dictRel=[[NSMutableDictionary alloc]init];
                                if([[tableArrayDict allKeys] containsObject:ApiTableName])
                                {
                                    NSDictionary *DictRelationsList = [tableArrayDict objectForKey:ApiTableName];
                                    NSArray *keys=[DictRelationsList allKeys];
                                    if(![keys containsObject:relationship_name])
                                    {
                                        [dictRel setObject:random forKey:relationship_name];
                                        //                            [arrayQueryField addObject:[NSString stringWithFormat:@"'%@'.%@",random ,ApifieldName]];
                                        tempTableName=random;
                                        
                                    }
                                    else
                                    {
                                        tempTableName=[DictRelationsList objectForKey:relationship_name];
                                    }

                                }
                                else
                                {
                                    [dictRel setObject:random forKey:relationship_name];
                                    [tableArrayDict setObject:dictRel forKey:ApiTableName ];
                                    tempTableName=random;
                                    
                                }
                                [dictRel release];
                            }
                            else
                            {
                                NSMutableDictionary *localDict =  [tableArrayDict objectForKey:[objectArray objectAtIndex:i]];
                                NSArray *keys=[localDict allKeys];
                                if(![keys containsObject:relationship_name])
                                {
                                    [localDict setObject:random forKey:relationship_name];
                                    tempTableName=random;
                                    
                                }
                                else
                                {
                                    tempTableName=[localDict objectForKey:relationship_name];
                                }
                            }
                            if([ApiTableName isEqualToString:[objectArray objectAtIndex:i]])
                            {
                                //Only 2nd level object add in Array to select Query 
                                ApiTableName=tempTableName;
                            }
                        }
                    }
                    objectArray=nil;
                    [objectArray release];
                }
                else
                {
                    ApiTableName=object;
//                    if(![arrayQueryField containsObject:[NSString stringWithFormat:@"'%@'.%@",object ,ApifieldName]])
//                    {
//                        [arrayQueryField addObject:[NSString stringWithFormat:@"'%@'.%@",object ,ApifieldName]];
//                    }
                }
//                if(![arrayQueryField containsObject:[NSString stringWithFormat:@"'%@'.%@",ApiTableName ,ApifieldName]]) //commented - keerti - 7275
                {
                    [arrayQueryField addObject:[NSString stringWithFormat:@"'%@'.%@",ApiTableName ,ApifieldName]];
                }
                [searchFieldsArr addObject:[NSString stringWithFormat:@"'%@'.%@",ApiTableName ,ApifieldName]];
                fieldsCount++;
                [searchableArrayTemp addObject:[searchableArray objectAtIndex:i]];
            }
            else
            {
                SMLog(kLogLevelVerbose,@"Search Field %@ skipped as no table named ",[NSString stringWithFormat:@"%@.%@",ApiTableName ,ApifieldName]);
            }
        }
        for (int i=0; i<[sortingArray count]; i++)
        {
            NSString *fieldName = [[sortingArray objectAtIndex:i] objectForKey:@"SVMXC__Field_Name__c"];//field
            NSString *ApifieldName = [self getApiNameFromFieldLabel:fieldName];
            NSString *TableName = [[sortingArray objectAtIndex:i] objectForKey:@"SVMXC__Object_Name2__c"];//Table
            NSString *ApiTableName = [self getApiNameFromFieldLabel:TableName];
            NSString *lookupRelationship = [[sortingArray objectAtIndex:i] objectForKey:@"SVMXC__Lookup_Field_API_Name__c"];
            NSString *fieldRelation = [[sortingArray objectAtIndex:i] objectForKey:@"SVMXC__Field_Relationship_Name__c"];
            NSString *objectName = [[sortingArray objectAtIndex:i] objectForKey:@"SVMXC__Object_Name__c"];
            NSString *orderBy=[[sortingArray objectAtIndex:i] objectForKey:@"SVMXC__Sort_Order__c"];
            NSMutableArray *objectArray=[[NSMutableArray alloc]init];
            [objectArray addObject:ApiTableName];
            
            if([objectName length]>0)
            {
                [objectArray addObject:objectName];
            }
            
            if([objectName length]>0)
            {
                ApiTableName=objectName;
            }
            if([self isTabelExistInDB:ApiTableName])
            {
                if(![ApiTableName isEqualToString:object])
                {
                    
                    if(![lookupRelationship length]>0)
                    {
                        relationship_name=fieldRelation;
                        ApifieldName=[[self getNameFiled:ApiTableName]length] >0?[self getNameFiled:ApiTableName]:ApifieldName;
                    }
                    else
                    {
                        if([fieldRelation length]>0)
                        {
                            relationship_name=fieldRelation;
                        }
                        else
                        {
                            relationship_name=lookupRelationship;
                        }
                        ApifieldName=[[self getNameFiled:ApiTableName] length] >0?[self getNameFiled:ApiTableName]:ApifieldName;
                    }
                    for(int i=0;i<[objectArray count];i++)
                    {
                        // Mapping 2 level object for Joining them
                        if(![[objectArray objectAtIndex:i ]  isEqualToString:object] && [self isTabelExistInDB:[objectArray objectAtIndex:i]])
                        {
                            NSString *random=[self CreateRandomString:ApiTableName];
                            NSString *tempTableName=@"";
                            if(![TableArray containsObject:ApiTableName] )
                            {
                                [TableArray addObject:ApiTableName];
                                NSMutableDictionary *dictRel=[[NSMutableDictionary alloc]init];
                                [dictRel setObject:random forKey:relationship_name];
                                [tableArrayDict setObject:dictRel forKey:ApiTableName ];
                                //                    [arrayQueryField addObject:[NSString stringWithFormat:@"'%@'.%@",random ,ApifieldName]];
                                tempTableName=random;
                            }
                            else
                            {
                                NSMutableDictionary *localDict =  [tableArrayDict objectForKey:ApiTableName];
                                NSArray *keys=[localDict allKeys];
                                if(![keys containsObject:relationship_name])
                                {
                                     [localDict setObject:random forKey:relationship_name];
                                //                            [arrayQueryField addObject:[NSString stringWithFormat:@"'%@'.%@",random ,ApifieldName]];
                                    tempTableName=random;

                                }
                                else
                                {
                                    tempTableName=[localDict objectForKey:relationship_name];
                                }
                            }
                            if([ApiTableName isEqualToString:[objectArray objectAtIndex:i]])
                            {
                                //For displaying 2nd level object in sorting fields
                                ApiTableName=tempTableName;
                            }
                        }

                    }
                    objectArray=nil;
                    [objectArray release];
                }
                NSMutableDictionary *sortDict=[[NSMutableDictionary alloc]init];
//                if(![arrayQueryField containsObject:[NSString stringWithFormat:@"'%@'.%@",ApiTableName ,ApifieldName]]) //commented - keerti - 7275
                {
                    [arrayQueryField addObject:[NSString stringWithFormat:@"'%@'.%@",ApiTableName ,ApifieldName]];
                }
                [sortDict setObject:[NSString stringWithFormat:@"'%@'.%@",ApiTableName ,ApifieldName] forKey:@"sort_Object"];
                if([orderBy isEqualToString:@"Descending"])
                    orderBy=@" COLLATE NOCASE DESC ";
                else
                    orderBy=@" COLLATE NOCASE ASC ";
                [sortDict setObject:orderBy forKey:@"sort_Order"];
                [sortingFieldArray addObject:sortDict];
                 fieldsCount++;
                sortDict=nil;
                [sortDict release];
            }
            else
            {
                SMLog(kLogLevelError,@"Sort Field %@ skipped as no table named ",[NSString stringWithFormat:@"%@.%@",ApiTableName ,ApifieldName]);
            }
        }
        NSString *queryStatement;
        //for adding search field in the where clause
        for (int i=0; i<[searchFieldsArr count]; i++)
        {
            if(i !=0)
                [customizeSearch appendString:@" OR "];
            [customizeSearch appendString:[searchFieldsArr objectAtIndex:i]];
            [customizeSearch appendString:@" LIKE "];
            NSString *strSearchCriteria=[self getSearchCriteriaStringFromUserData:[uiControlsValue objectForKey:@"searchCriteria"] withSearchString:[uiControlsValue objectForKey:@"searchString"]];
            [customizeSearch appendFormat:@"'%@'",strSearchCriteria];
        }
        searchFieldsArr=nil;
        [searchFieldsArr release];
        if([criteriaArray count] == 0 )
        {
            NSMutableDictionary *dict_Join_field=[[NSMutableDictionary alloc]init ];
            [dict_Join_field setObject:TableArray forKey:@"TableArray"];
            [dict_Join_field setObject:tableArrayDict forKey:@"tableArrayDict"];
            [dict_Join_field setObject:object forKey:@"object"];
            joinFields=[self getJoinFieldsForSFM:dict_Join_field];
            selectQueryElement=[self stringForSelectFields:arrayQueryField];
            if([sortingFieldArray count]>0)
            orderByElement=[self stringForSortingFields:sortingFieldArray];
            if([joinFields length]>0)
            {
                if([customizeSearch length]>0)
                {
                    if([[uiControlsValue objectForKey:@"searchString"] length]>0)
                        queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ %@ FROM '%@' %@ WHERE %@ %@ LIMIT %@",queryFields,selectQueryElement,object,joinFields,customizeSearch,orderByElement,[uiControlsValue objectForKey:@"searchLimitString"]];
                    else
                        queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ %@ FROM '%@' %@ %@  LIMIT %@",queryFields,selectQueryElement,object,joinFields,orderByElement,[uiControlsValue objectForKey:@"searchLimitString"]];
                    
                }
                else
                    queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ %@ FROM '%@' %@ %@",queryFields,selectQueryElement,object,joinFields,orderByElement];
            }
            else
            {
                if([customizeSearch length]>0)
                {
                    if([[uiControlsValue objectForKey:@"searchString"] length]>0)
                        queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ %@ FROM '%@' WHERE %@ %@ LIMIT %@",queryFields,selectQueryElement,object,customizeSearch,orderByElement,[uiControlsValue objectForKey:@"searchLimitString"]];
                    else
                        queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ %@ FROM '%@' %@ LIMIT %@",queryFields,selectQueryElement,object,orderByElement,[uiControlsValue objectForKey:@"searchLimitString"]];
                    
                }
                else
                    queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ %@ FROM '%@' %@",queryFields,selectQueryElement,object,orderByElement];
            }
        }
        else
        {
            /////////////////////////////////////////////////
            for(int j=0;j<[criteriaArray count]; j++)
            {
                NSString *fieldName=@"",*TableName=@"";
                NSDictionary * dict = [criteriaArray objectAtIndex:j];
                NSString *displayType = [dict objectForKey:@"SVMXC__Display_Type__c"];
                if ([displayType isEqualToString:@"REFERENCE"])
                {
                    // Direct Object 
                    TableName=[self getReferencetoFiledForObject:object api_Name:[dict objectForKey:@"SVMXC__Field_Name__c"]];
                    if(![TableName length]>0)
                    {
                        // For reference object of process object
                        TableName=[self getReferencetoFiledForObject:object api_Name:[dict objectForKey:@"SVMXC__Object_Name__c"]];
                    }
                    fieldName=[self getNameFiled:object];
                    /*
                     NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
                     queryStatement1 = [NSMutableString stringWithFormat:@"SELECT reference_to FROM SFObjectField where api_name='%@' and object_api_name='%@'",[dict objectForKey:@"SVMXC__Field_Name__c"],object];
                     sqlite3_stmt * labelstmt;
                     const char *selectStatement = [queryStatement1 UTF8String];
                     char *reference_to_field=nil;
                     if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
                     {
                     if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
                     {
                     reference_to_field = (char *) synchronized_sqlite3_column_text(labelstmt,0);
                     if((reference_to_field != nil) && strlen(reference_to_field))
                     TableName = [NSString stringWithFormat:@"%s",reference_to_field];
                     
                     }
                     }
                     
                     NSMutableString * queryStatement2 = [[NSMutableString alloc]initWithCapacity:0];
                     queryStatement2 = [NSMutableString stringWithFormat:@"SELECT api_name FROM SFObjectField where name_field='TRUE' and object_api_name='%@'",object];
                     sqlite3_stmt * labelstmt2;
                     const char *selectStatement2 = [queryStatement2 UTF8String];
                     char *nameofObjectField;
                     if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement2,-1, &labelstmt2, nil) == SQLITE_OK )
                     {
                     if(synchronized_sqlite3_step(labelstmt2) == SQLITE_ROW)
                     {
                     nameofObjectField = (char *) synchronized_sqlite3_column_text(labelstmt2,0);
                     if((nameofObjectField !=nil)&&strlen(nameofObjectField))
                     fieldName = [NSString stringWithFormat:@"%s",nameofObjectField];
                     
                     }
                     }
                     */
                    
                    if ([TableName length]>0)
                        TableName = [self getApiNameFromFieldLabel:TableName];
                    NSString *random=@"",*relationship_name=@"";
                    if([TableName length]>0)
                    {
                        random=[self CreateRandomString:TableName];
                        relationship_name=[[criteriaArray objectAtIndex:j] objectForKey:@"SVMXC__Field_Relationship_Name__c"];
                        
                        if(![TableName isEqualToString:object] && ![TableName isEqualToString:@"RecordType"])
                        {
                            if(![TableArray containsObject:TableName] )
                            {
                                [TableArray addObject:TableName];
                                NSMutableDictionary *dictRel=[[NSMutableDictionary alloc]init];
                                [dictRel setObject:random forKey:relationship_name];
                                [tableArrayDict setObject:dictRel forKey:TableName ];
                            }
                            else
                            {
                                NSMutableDictionary *Dict =  [tableArrayDict objectForKey:TableName];
                                NSArray *keys=[Dict allKeys];
                                if(![keys containsObject:relationship_name])
                                {
                                    [Dict setObject:random forKey:relationship_name];
                                }
                            }
                        }
                    }
                    //                synchronized_sqlite3_finalize(labelstmt);
                    //                synchronized_sqlite3_finalize(labelstmt2);
                }
            }
            /////////////////////////////////////////////////
            
            // Parsing Parent Obejct criteria
            NSMutableString * conditionqueryStatement = [[NSMutableString alloc]initWithCapacity:0];
            conditionqueryStatement = [NSMutableString stringWithFormat:@"SELECT SVMXC__Parent_Object_Criteria__c,SVMXC__Target_Object_Name__c,SVMXC__Advance_Expression__c from SFM_Search_Objects where ObjectID='%@'",objectId];
            sqlite3_stmt * conditionlabelstmt;
            const char *conditionselectStatement = [conditionqueryStatement UTF8String];
            char *fieldforCondition=nil,*TargetObject=nil,*advanceExp=nil ;
            NSString *Expression=@"",*strTargetObject=@"",*strAdvanceExpression=@"";
            if ( synchronized_sqlite3_prepare_v2(appDelegate.db, conditionselectStatement,-1, &conditionlabelstmt, nil) == SQLITE_OK )
            {
                if(synchronized_sqlite3_step(conditionlabelstmt) == SQLITE_ROW)
                {
                    fieldforCondition = (char *) synchronized_sqlite3_column_text(conditionlabelstmt,0);
                    TargetObject = (char *) synchronized_sqlite3_column_text(conditionlabelstmt,1);
                    advanceExp=(char *) synchronized_sqlite3_column_text(conditionlabelstmt,2);
                    if((fieldforCondition !=nil) && strlen(fieldforCondition))
                        Expression=[NSString stringWithFormat:@"%s",fieldforCondition] ;
                    if((TargetObject !=nil) && strlen(TargetObject))
                        strTargetObject=[NSString stringWithUTF8String:TargetObject] ;
                    if((advanceExp !=nil) && strlen(advanceExp))
                        strAdvanceExpression=[NSString stringWithUTF8String:advanceExp] ;
                }
                synchronized_sqlite3_finalize(conditionlabelstmt);
            }
            SMLog(kLogLevelVerbose,@"Adv Exp = %@",Expression);
            if(![Expression isEqualToString:@"(null)"])
            {
                SMLog(kLogLevelVerbose,@"%@",Expression);
                int iTokenCount=-1;
                Expression=[Expression stringByReplacingOccurrencesOfString:@")" withString:@" ) "];
                Expression=[Expression stringByReplacingOccurrencesOfString:@"(" withString:@" ( "];
                strAdvanceExpression=[strAdvanceExpression uppercaseString];
                strAdvanceExpression=[strAdvanceExpression stringByReplacingOccurrencesOfString:@")" withString:@" ) "];
                strAdvanceExpression=[strAdvanceExpression stringByReplacingOccurrencesOfString:@"(" withString:@" ( "];
                NSMutableArray  *tokens = [[NSMutableArray alloc] init];
                NSMutableArray  *alltokens = [[NSMutableArray alloc] init];
                NSMutableArray *advTokens=[[NSMutableArray alloc]init];
                alltokens=[self parsingExpression:Expression];
                advTokens=[self parsingExpression:strAdvanceExpression];
                
                [dictforparsing setObject:TableArray forKey:@"TableArray"];
                [dictforparsing setObject:tableArrayDict forKey:@"tableArrayDict"];
                [dictforparsing setObject:strTargetObject forKey:@"strTargetObject"];
                [dictforparsing setObject:criteriaArray forKey:@"criteriaArray"];
                SMLog(kLogLevelVerbose,@"AllTokens = %@",alltokens);
                if(!([alltokens count]>0))
                {
                    alltokens=[NSString stringWithFormat:@"%@",Expression];
                    //                [dictforparsing setObject:finalQuery forKey:@"finalQuery"];
                    [dictforparsing setObject:alltokens forKey:@"token"];
                    logicalParsingResult= [self getupdatedTokenForSFM:dictforparsing];
                    TableArray=[logicalParsingResult objectForKey:@"TableArray"];
                    tableArrayDict=[logicalParsingResult objectForKey:@"tableArrayDict"];
                    finalQuery=[logicalParsingResult objectForKey:@"finalQuery"];
                    [finalQuery appendString:@" COLLATE NOCASE"];
                }
                else
                {
                    int countToken=-1;
                    for(NSString *token in alltokens)
                    {
                        countToken++;
                        if([token Contains:@" AND "]||([token Contains:@" OR "]))
                        {
                            [finalQuery appendFormat:@" %@ ",token];
                            continue;
                        }
                        iTokenCount++;
                        [dictforparsing setObject:[NSString stringWithFormat:@"%d",iTokenCount ] forKey:@"Count"];
                        //                    [dictforparsing setObject:finalQuery forKey:@"finalQuery"];
                        [dictforparsing setObject:token forKey:@"token"];
                        logicalParsingResult= [self getupdatedTokenForSFM:dictforparsing];
                        TableArray=[logicalParsingResult objectForKey:@"TableArray"];
                        tableArrayDict=[logicalParsingResult objectForKey:@"tableArrayDict"];
                        NSString *finalQueryTemp=[logicalParsingResult objectForKey:@"finalQuery"];
                        if(![[advTokens objectAtIndex:0] Contains:@"NULL"] && [advTokens count] == [alltokens count])
                        {
                            NSDictionary *dictBraces=[self occurenceOfBraces:[advTokens objectAtIndex:countToken]];
                            for (int i=0; i<[[dictBraces objectForKey:@"rightBraces"] intValue]; i++)
                            {
                                [finalQuery appendFormat:@"("];
                            }
                        }
                        [finalQuery appendString:finalQueryTemp];
                        if(![[advTokens objectAtIndex:0] Contains:@"NULL"] && [advTokens count] == [alltokens count])
                        {
                            NSDictionary *dictBraces=[self occurenceOfBraces:[advTokens objectAtIndex:countToken]];
                            for (int i=0; i<[[dictBraces objectForKey:@"leftBraces"] intValue]; i++)
                            {
                                [finalQuery appendFormat:@" COLLATE NOCASE )"];
                            }
                        }
                    }
                    [finalQuery appendString:@" COLLATE NOCASE"];
                    dictforparsing=nil;
                    logicalParsingResult=nil;
                    advTokens=nil;
                    alltokens=nil;
                    tokens=nil;
                    [dictforparsing release];
                    [logicalParsingResult release];
                    [advTokens release];
                    [alltokens release];
                    [tokens release];
                }
            }
            NSMutableDictionary *dict_Join_field=[[NSMutableDictionary alloc]init ];
            [dict_Join_field setObject:TableArray forKey:@"TableArray"];
            [dict_Join_field setObject:tableArrayDict forKey:@"tableArrayDict"];
            [dict_Join_field setObject:object forKey:@"object"];
            joinFields=[self getJoinFieldsForSFM:dict_Join_field];
            selectQueryElement=[self stringForSelectFields:arrayQueryField];
            if([sortingFieldArray count]>0)
            orderByElement=[self stringForSortingFields:sortingFieldArray];
            
            if([finalQuery length] > 0)
            {
                if([customizeSearch length]>0)
                {
                    if([[uiControlsValue objectForKey:@"searchString"] length]>0)
                        queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ %@ FROM '%@' %@ WHERE (%@) AND (%@) COLLATE NOCASE %@ LIMIT %@",queryFields,selectQueryElement,object,joinFields,finalQuery,customizeSearch,orderByElement,[uiControlsValue objectForKey:@"searchLimitString"]];
                    else
                        queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ %@ FROM '%@' %@ WHERE (%@) COLLATE NOCASE %@ LIMIT %@",queryFields,selectQueryElement,object,joinFields,finalQuery,orderByElement,[uiControlsValue objectForKey:@"searchLimitString"]];
                    
                }
                else
                    queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ %@ FROM '%@' %@ WHERE (%@) COLLATE NOCASE %@ LIMIT %@",queryFields,selectQueryElement,object,joinFields,finalQuery,orderByElement,[uiControlsValue objectForKey:@"searchLimitString"]];
                
            }
            else
            {
                if([customizeSearch length]>0)
                {
                    if([[uiControlsValue objectForKey:@"searchString"] length]>0)
                        queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ %@ FROM '%@'%@ WHERE (%@) %@ LIMIT %@",queryFields,selectQueryElement,object,joinFields,customizeSearch,orderByElement,[uiControlsValue objectForKey:@"searchLimitString"]];
                    else
                        queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ %@ FROM '%@'%@ %@ LIMIT %@",queryFields,selectQueryElement,object,joinFields,orderByElement,[uiControlsValue objectForKey:@"searchLimitString"]];
                }
                else
                    queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT %@ %@ FROM '%@'%@ %@ LIMIT %@",queryFields,selectQueryElement,object,joinFields,orderByElement,[uiControlsValue objectForKey:@"searchLimitString"]];
                
            }
            
        }
        TableArray=nil;
        tableArrayDict=nil;
        joinFields=nil;
        selectQueryElement=nil;
        queryFields=nil;
        customizeSearch=nil;
        arrayQueryField=nil;
        [TableArray release];
        [tableArrayDict release];
        [joinFields release];
        [selectQueryElement release];
        [queryFields release];
        [arrayQueryField release];
        [customizeSearch release];
        SMLog(kLogLevelVerbose,@"Query = %@",queryStatement);
        sqlite3_stmt * statement;
        int retVal = synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL);
        if (retVal == SQLITE_OK)
        {
            while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                NSString *value=nil,*refrenceValue=nil;
                for(int j=0; j< fieldsCount; j++)
                {
                    const char * _type = (char *)synchronized_sqlite3_column_text(statement, j);
                    if ( !_type)
                    {
                        _type = "";
                    }
                    value = [NSString stringWithUTF8String:_type];
                    if(value == nil)
                    {
                        value = @"";
                    }
                    if(j==0)
                    {
                        [dict setObject:value forKey:@"Id"];
                    }
                    else
                        if(j==1)
                        {
                            [dict setObject:value forKey:@"local_id"];
                        }
                        else
                        {
                            if(j<([displayArrayTemp count] +2))
                            {
                                NSDictionary *object = [displayArrayTemp objectAtIndex:j-2];
//                                NSDictionary *object = [displayArray objectAtIndex:j-2];
                                if([value length])
                                {
                                    refrenceValue=[self getvalueforReference:object value:value];
                                    if(refrenceValue)
                                    {
                                        [dict setObject:refrenceValue forKey:[NSString stringWithFormat:@"%@.%@",[object objectForKey:@"SVMXC__Object_Name2__c"],[object objectForKey:@"SVMXC__Field_Name__c"]]];
                                    }
                                    else
                                    {
                                        [dict setObject:value forKey:[NSString stringWithFormat:@"%@.%@",[object objectForKey:@"SVMXC__Object_Name2__c"],[object objectForKey:@"SVMXC__Field_Name__c"]]];
                                    }
                                    
                                }
                                else
                                {
                                    [dict setObject:value forKey:[NSString stringWithFormat:@"%@.%@",[object
                                          objectForKey:@"SVMXC__Object_Name2__c"],[object objectForKey:@"SVMXC__Field_Name__c"]]];
                                }
                            }
                            else if(j<([searchableArrayTemp count]+[displayArrayTemp count]+2))
                            {
                                int indexValue = j - [displayArrayTemp count] - 2;
                                NSString *object_name_2 = [[searchableArrayTemp objectAtIndex:indexValue ] objectForKey:@"SVMXC__Object_Name2__c"];
                                NSString *field_name = [[searchableArrayTemp objectAtIndex:indexValue ] objectForKey:@"SVMXC__Field_Name__c"];
                                NSString *key = [NSString stringWithFormat:@"%@.%@",object_name_2,field_name];
                                if(![[dict allKeys] containsObject:key])
                                {
                                    refrenceValue=[self getvalueforReference:[searchableArrayTemp objectAtIndex:indexValue ]  value:value];
                                    if(refrenceValue)
                                    {
                                        [dict setObject:refrenceValue forKey:[NSString stringWithFormat:@"%@.%@",[[searchableArrayTemp objectAtIndex:indexValue ] objectForKey:@"SVMXC__Object_Name2__c"],[[searchableArrayTemp objectAtIndex:indexValue ] objectForKey:@"SVMXC__Field_Name__c"]]];
                                    }
                                    else
                                    {
                                        [dict setObject:value forKey:[NSString stringWithFormat:@"%@.%@",[[searchableArrayTemp objectAtIndex:indexValue ] objectForKey:@"SVMXC__Object_Name2__c"],[[searchableArrayTemp objectAtIndex:indexValue ] objectForKey:@"SVMXC__Field_Name__c"]]];
                                    }
                                }
                            }
                            else
                            {
                                int indexValue = j - [displayArrayTemp count] -[searchableArrayTemp count]- 2;
                                NSString *object_name_2 = [[sortingArray objectAtIndex:indexValue ] objectForKey:@"SVMXC__Object_Name2__c"];
                                NSString *field_name = [[sortingArray objectAtIndex:indexValue ] objectForKey:@"SVMXC__Field_Name__c"];
                                NSString *key = [NSString stringWithFormat:@"%@.%@",object_name_2,field_name];
                                if(![[dict allKeys] containsObject:key])
                                {
                                    refrenceValue=[self getvalueforReference:[sortingArray objectAtIndex:indexValue ]  value:value];
                                    if(refrenceValue)
                                    {
                                        [dict setObject:refrenceValue forKey:[NSString stringWithFormat:@"%@.%@",[[sortingArray objectAtIndex:indexValue ] objectForKey:@"SVMXC__Object_Name2__c"],[[sortingArray objectAtIndex:indexValue ] objectForKey:@"SVMXC__Field_Name__c"]]];
                                    }
                                    else
                                    {
                                        [dict setObject:value forKey:[NSString stringWithFormat:@"%@.%@",[[sortingArray objectAtIndex:indexValue ] objectForKey:@"SVMXC__Object_Name2__c"],[[sortingArray objectAtIndex:indexValue ] objectForKey:@"SVMXC__Field_Name__c"]]];
                                    }
                                }
                            }
                        }
                }
                for (int i=0; i<[skippedFields count]; i++) {
                    [dict setObject:@"--" forKey:[skippedFields objectAtIndex:i]];
                }
                [results addObject:dict];
            }
        }
        else
        {
            const char * error = sqlite3_errmsg(appDelegate.db);
            if(!([[NSString stringWithUTF8String:error] Contains:@"unknown error"]))
            {
                [appDelegate printIfError:[NSString stringWithUTF8String:error] ForQuery:queryStatement type:SELECTQUERY];
            }
        }
        skippedFields=nil;
        displayArrayTemp=nil;
        searchableArrayTemp=nil;
        sortingFieldArray=nil;
        [displayArrayTemp release];
        [searchableArrayTemp release];
        [skippedFields release];
        [sortingFieldArray release];
        //////////////// DO not use this code try to find new way to print exception///////////
       /* if(SQLITE_OK != sqlite3_step(statement))
        {
            const char * error = sqlite3_errmsg(appDelegate.db);
            if(!([[NSString stringWithUTF8String:error] Contains:@"unknown error"]))
            {
                [appDelegate printIfError:[NSString stringWithUTF8String:error] ForQuery:queryStatement type:SELECTQUERY];
            }
        }*/
        synchronized_sqlite3_finalize(statement);
        SMLog(kLogLevelVerbose, @"result %@",results);
    }@catch (NSException *exp) {
    
         SMLog(kLogLevelError,@"Exception Name Database :getResultsForSFM name : %@ \n reason : %@",exp.name, exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    isSortingDone=TRUE;//keerti - 7275
    [self CreateRandomString:nil];

    return [results autorelease];
}
-(NSMutableDictionary*) getupdatedTokenForSFM:(NSMutableDictionary*)dictforparsing
{
    // Alias and braces mapping removed
    NSArray *operatorArray = [NSArray arrayWithObjects:@"!=",@"<=",@">=",@"<>",@"=",@"<",@">",@"NOT LIKE",@" LIKE ",@" NOT IN ",@" IN ", nil];
    int Count=-1;
    if(appDelegate == nil)
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    int tokenCount=[[dictforparsing objectForKey:@"Count"] integerValue];
    NSMutableArray *TableArray = [dictforparsing objectForKey:@"TableArray"];
    NSMutableDictionary *tableArrayDict=[dictforparsing objectForKey:@"tableArrayDict"];
    NSMutableDictionary *resultDict=[[NSMutableDictionary alloc]init ];
    NSMutableString *finalQuery=[[NSMutableString alloc]init];//[dictforparsing objectForKey:@"finalQuery"];
    NSString *token=[dictforparsing objectForKey:@"token"];
    token=[token stringByReplacingOccurrencesOfString:@" ( " withString:@"("];
    token=[token stringByReplacingOccurrencesOfString:@" ) " withString:@")"];
    NSArray * criteria_array  = [dictforparsing objectForKey:@"criteriaArray"];
    NSString *rhs=@"";
    NSString *Objecttype=@"";
    NSString *refrence_to=@"";
    NSString * NotOp = @"NOT(";
    @try
    {
        if([token rangeOfString:NotOp].length >0)
        {
            
            token = [token stringByReplacingOccurrencesOfString:@"(NOT(" withString:@" "];
            token= [token stringByReplacingOccurrencesOfString:@"NOT(" withString:@" "];
            token = [token stringByReplacingOccurrencesOfString:@"LIKE" withString:@"NOT LIKE"];
            if([token rangeOfString:@")"].length >0)
            {
                NSRange  range = [token rangeOfString:@")"];
                NSUInteger location= range.location;
                token = [token stringByReplacingCharactersInRange:NSMakeRange(location, 2) withString:@""];
            }
        }
        
        for(NSString *operator in operatorArray)
        {
            if([token rangeOfString:operator].length > 0)
            {
                Count++; //Counter for tokens
                NSArray *operatorTokens = [token componentsSeparatedByString:operator];
                NSString *objectDef   = [operatorTokens objectAtIndex:0];
                NSString *objectValue = [operatorTokens objectAtIndex:1];
                
                objectDef=[objectDef stringByReplacingOccurrencesOfString:@"(" withString:@""];
                objectDef=[objectDef stringByReplacingOccurrencesOfString:@")" withString:@""];
                objectDef=[objectDef stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                objectValue=[objectValue stringByReplacingOccurrencesOfString:@"(" withString:@""];
                objectValue=[objectValue stringByReplacingOccurrencesOfString:@")" withString:@""];
                objectValue=[objectValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                NSString *fieldName=@"",*tableName=@"";
                //REFERENCE OBJ ASSOCIATION START
                if([objectDef rangeOfString:@"."].length >0)
                {
                    SMLog(kLogLevelVerbose,@"Table Name is there");
                    NSArray *fieldArray = [objectDef componentsSeparatedByString:@"."];
                    tableName = [fieldArray objectAtIndex:0];
                    fieldName = [fieldArray objectAtIndex:1];
                    tableName = [tableName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    fieldName = [fieldName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    refrence_to=[self getRefrenceToField:[dictforparsing objectForKey:@"object"] relationship:tableName];
                    
                    if([tableName rangeOfString:@"__r"].length >0)
                    {
                        if(([objectValue isEqualToString:@"null"]) && ([operator isEqualToString:@"!="] || [operator isEqualToString:@"<>"]) )
                        {
                            NSString *alias=[[tableArrayDict objectForKey:refrence_to] objectForKey:tableName]!=nil ?[[tableArrayDict objectForKey:refrence_to] objectForKey:tableName]:refrence_to;
                            rhs=[NSString stringWithFormat:@"%@.%@",alias,fieldName];
                            [finalQuery appendFormat:@"trim(%@.%@)",alias,fieldName];
                        }
                        else if(![objectValue Contains:@"SVMX.CURRENTUSER"] && ![objectValue Contains:@"SVMX.OWNER"]&&![refrence_to isEqualToString:@"User"])
                        {
                            NSString *alias=[[tableArrayDict objectForKey:refrence_to] objectForKey:tableName]!=nil ?[[tableArrayDict objectForKey:refrence_to] objectForKey:tableName]:refrence_to;
                            rhs=[NSString stringWithFormat:@"%@.%@",alias,fieldName];
                            [finalQuery appendString:alias];
                            [finalQuery appendString:@"."];
                            [finalQuery appendString:fieldName];
                        }
                        else
                        {
                            NSString *field=[[[dictforparsing objectForKey:@"criteriaArray"] objectAtIndex:tokenCount] objectForKey:@"SVMXC__Field_Name__c"];
                            Objecttype=[self getfieldTypeForApi:field fieldName:fieldName];
                        }
                        
                    }
                    else
                    {
                        NSString * objectName = [dictforparsing objectForKey:@"object"];
                        refrence_to=[self getRefrenceToField:objectName relationship:tableName];
                        if([tableName isEqualToString:@"RecordType"])
                        {
                            NSString * component_expression = [NSString stringWithFormat:@"'%@'.RecordTypeId   in   (select  record_type_id  from SFRecordType where record_type %@ %@ )" , objectName, operator,objectValue];
                            [finalQuery appendFormat:@"%@" , component_expression];
                        }
                        else if(![objectValue Contains:@"SVMX.CURRENTUSER"] && ![objectValue Contains:@"SVMX.OWNER"]&&![refrence_to isEqualToString:@"User"])
                        {
                            NSString *alias=[[tableArrayDict objectForKey:refrence_to] objectForKey:tableName] !=nil ?[[tableArrayDict objectForKey:refrence_to] objectForKey:tableName]:refrence_to;
                            
                            if(([objectValue Contains:@"null"]) &&([operator isEqualToString:@"!="] || [operator isEqualToString:@"<>"]) )
                            {
                                [finalQuery appendFormat:@"trim(%@.%@)",alias,fieldName];
                            }
                            else
                            {
                                [finalQuery appendFormat:@"%@.%@",alias,fieldName];
                            }
                            NSString *random=[self CreateRandomString:tableName] ;
                            NSString *refObjName=[self getRefrenceToField:objectName relationship:tableName];
                            if(![refObjName isEqualToString:[dictforparsing objectForKey:@"object"]])
                            {
                                if(![TableArray containsObject:refObjName] && [refObjName length] > 0)
                                {
                                    [TableArray addObject:refObjName];
                                    NSMutableDictionary *dictRel=[[NSMutableDictionary alloc]init];
                                    [dictRel setObject:random forKey:tableName];
                                    [tableArrayDict setObject:dictRel forKey:refObjName];
                                    
                                }
                                else
                                {
                                    NSMutableDictionary *Dict =  [tableArrayDict objectForKey:refObjName];
                                    NSArray *keys=[Dict allKeys];
                                    if(![keys containsObject:tableName])
                                    {
                                        [Dict setObject:random forKey:tableName];
                                    }
                                }
                            }
                        }
                    }
                    
                    [finalQuery appendString:@" "];
                } //REFRENCE OBJECT ASSOCIATION END
                else
                {
                    //                    refrence_to=[self getRefrenceToField:[dictforparsing objectForKey:@"object"] relationship:objectDef];
                    SMLog(kLogLevelVerbose,@"Table Name is not there. Append Object Name as Table Name");
                    if([objectValue rangeOfString:@"null"options:NSCaseInsensitiveSearch].length >0 &&([operator isEqualToString:@"!="] || [operator isEqualToString:@"<>"]) )
                    {
                        [finalQuery appendFormat:@"trim('%@'.%@)",[self getApiNameFromFieldLabel:[dictforparsing objectForKey:@"strTargetObject"]],objectDef];
                        rhs=[NSString stringWithFormat:@"'%@'.%@",[self getApiNameFromFieldLabel:[dictforparsing objectForKey:@"strTargetObject"]],objectDef];
                    }
                    else if(![objectValue Contains:@"SVMX.CURRENTUSER"] && ![objectValue Contains:@"SVMX.OWNER"])
                    {
                        rhs=[NSString stringWithFormat:@"'%@'.%@",[self getApiNameFromFieldLabel:[dictforparsing objectForKey:@"strTargetObject"]],objectDef];
                        [finalQuery appendFormat:@"'%@'",[self getApiNameFromFieldLabel:[dictforparsing objectForKey:@"strTargetObject"]]];
                        [finalQuery appendString:@"."];
                        [finalQuery appendString:objectDef];
                    }
                    fieldName = objectDef;
                }
                
                // For RHS handling
                if([objectValue rangeOfString:@"null"options:NSCaseInsensitiveSearch].length >0)
                {
                    if([objectValue Contains:@"null"] &&([operator isEqualToString:@"!="] || [operator isEqualToString:@"<>"]) )
                    {
                        if([rhs length]>0)
                        {
                            [finalQuery appendFormat:@" !='' OR %@ IS NOT NULL",rhs];
                        }
                        else
                            [finalQuery appendFormat:@" != '' "];
                    }
                    else
                    {
                        //                    [finalQuery appendString:@" isnull"];
                        if([rhs length]>0)
                        {
                            [finalQuery appendFormat:@" ='' OR %@ isnull",rhs];
                        }
                        else
                            [finalQuery appendFormat:@"= '' "];
                    }
                    
                }
                else if([refrence_to isEqualToString:@"User"]||[objectValue Contains:@"SVMX.CURRENTUSER"] || [objectValue Contains:@"SVMX.OWNER"])
                {
                    NSString * objectName = [dictforparsing objectForKey:@"object"];
                    refrence_to=[self getRefrenceToField:objectName relationship:tableName];
                    NSString * component_expression=@"";
                    NSString *alias=[[tableArrayDict objectForKey:refrence_to] objectForKey:tableName] !=nil?[[tableArrayDict objectForKey:refrence_to] objectForKey:tableName]:refrence_to;
                    
                    if([objectValue Contains:@"SVMX.CURRENTUSER"] || [objectValue Contains:@"SVMX.OWNER"])
                    {
                        if([Objecttype length]>0 || Objecttype !=nil)
                        {
                            Objecttype=[self getfieldTypeForApi:objectName fieldName:fieldName];
                        }
                        if(![Objecttype isEqualToString:@"reference"])
                        {
                            
                            NSString *UserFullName=@"", *UserNameValue=@"";
                            if(![appDelegate.userDisplayFullName length] > 0 )
                            {
                                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                if ([[userDefaults objectForKey:USERFULLNAME] length]>0)
                                {
                                    UserFullName = [userDefaults objectForKey:USERFULLNAME]; //To get user display name not email id 
                                    SMLog(kLogLevelVerbose,@"User Full Name  = %@",UserFullName);
                                }
                                else
                                {
                                    UserFullName=[self getLoggedInUser:appDelegate.username];
                                }
                            }
                            else
                            {
                                UserFullName=appDelegate.userDisplayFullName;
                            }
                            if([UserFullName length]>0)
                            {
                                if([objectValue Contains:@"SVMX.CURRENTUSER"])
                                {
                                    UserNameValue=[objectValue stringByReplacingOccurrencesOfString:@"SVMX.CURRENTUSER" withString:UserFullName];
                                }
                                else if([objectValue Contains:@"SVMX.OWNER"])
                                {
                                    UserNameValue=[objectValue stringByReplacingOccurrencesOfString:@"SVMX.OWNER" withString:UserFullName];
                                }

                            }
                            
                            if([refrence_to length]>0)
                            {
                                component_expression = [NSString stringWithFormat:@"%@.%@ %@ %@" , alias,fieldName, operator,UserNameValue];
                            }
                            else
                            {
                                component_expression = [NSString stringWithFormat:@"'%@'.%@ %@ %@" ,[dictforparsing objectForKey:@"object"] ,fieldName, operator,UserNameValue];
                                
                            }
                            [finalQuery appendString:component_expression];
                            
                        }
                        else
                        {
                            if(appDelegate.loggedInUserId == nil)
                            {
                                appDelegate.loggedInUserId=[self getLoggedInUserId:appDelegate.username];
                            }
                            NSString *field=[[[dictforparsing objectForKey:@"criteriaArray"] objectAtIndex:Count] objectForKey:@"SVMXC__Field_Name__c"];
                            component_expression = [NSString stringWithFormat:@"'%@'.%@ %@ '%@'" , objectName,field, operator,appDelegate.loggedInUserId]; //Need to test this case
                            [finalQuery appendString:component_expression];
                        }
                    }
                    else
                    {
                        NSString *field=[[[dictforparsing objectForKey:@"criteriaArray"] objectAtIndex:Count] objectForKey:@"SVMXC__Field_Name__c"];
                        component_expression = [NSString stringWithFormat:@"'%@'.%@   in   (select  Id  from User where Name %@ %@ )" , objectName,field, operator,objectValue];
                        [finalQuery appendString:component_expression];
                    }
                    
                }
                
                else if(([[self getDataTypeFor:fieldName inArray:criteria_array] isEqualToString:BOOLEAN]) && ([objectValue rangeOfString:@"True"options:NSCaseInsensitiveSearch].length >0))
                {
                    [finalQuery appendString:operator];
//                    objectValue=[objectValue stringByReplacingOccurrencesOfString:@"True"withString:@"1"];
                    objectValue=[objectValue stringByReplacingOccurrencesOfString:@"true" withString:@"1" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [objectValue length])];
                    [finalQuery appendString:objectValue];
                }
                else if(([[self getDataTypeFor:fieldName inArray:criteria_array] isEqualToString:BOOLEAN]) && ([objectValue rangeOfString:@"False"options:NSCaseInsensitiveSearch].length>0))
                {
                    [finalQuery appendString:operator];
                    objectValue=[objectValue stringByReplacingOccurrencesOfString:@"false" withString:@"0" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [objectValue length])];
//                    objectValue=[objectValue stringByReplacingOccurrencesOfString:@"False"withString:@"0"];
                    [finalQuery appendString:objectValue];
                }
                else if (([objectValue caseInsensitiveCompare:MACRO_TODAY]== NSOrderedSame) ||
                         ([objectValue caseInsensitiveCompare:MACRO_TOMMOROW]== NSOrderedSame) ||
                         ([objectValue caseInsensitiveCompare:MACRO_YESTERDAY]== NSOrderedSame)||
                         ([objectValue caseInsensitiveCompare:MACRO_NOW]== NSOrderedSame ))
                {
                    
                    NSTimeInterval secondsPerDay = 24 * 60 * 60;
                    
                    NSString * today_Date ,* tomorow_date ,* yesterday_date;
                    
                    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    
                    NSDate *today = [NSDate date];;
                    
                    NSDate *tomorrow, *yesterday;
                    
                    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
                    
                    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
                    
                    
                    
                    //for macros expantion
                    if([[self getDataTypeFor:fieldName inArray:criteria_array] isEqualToString:@"DATE"])
                    {
                        [finalQuery appendString:operator];
                        [finalQuery appendString:@"'"];
                        
                        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                        
                        today_Date = [dateFormatter stringFromDate:today];
                        tomorow_date = [dateFormatter stringFromDate:tomorrow];
                        yesterday_date = [dateFormatter stringFromDate:yesterday];
                        
                        if([objectValue caseInsensitiveCompare:MACRO_TODAY]== NSOrderedSame)
                        {
                            [finalQuery appendString:today_Date];
                            
                        }
                        if([objectValue caseInsensitiveCompare:MACRO_TOMMOROW]== NSOrderedSame)
                        {
                            [finalQuery appendString:tomorow_date];
                            
                        }
                        if([objectValue caseInsensitiveCompare:MACRO_YESTERDAY]== NSOrderedSame)
                        {
                            [finalQuery appendString:yesterday_date];
                        }
                         [finalQuery appendString:@"'"];
                    }
                    
                    if([[self getDataTypeFor:fieldName inArray:criteria_array] isEqualToString:@"DATETIME"])
                    {
                        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                        NSString *start_datetime,*end_datetime;
                        today_Date = [dateFormatter stringFromDate:today];
                        tomorow_date = [dateFormatter stringFromDate:tomorrow];
                        yesterday_date = [dateFormatter stringFromDate:yesterday];
                        
                        if(([objectValue caseInsensitiveCompare:MACRO_TODAY]== NSOrderedSame)||
                           ([objectValue caseInsensitiveCompare:MACRO_NOW]== NSOrderedSame) )
                        {
                            start_datetime = [today_Date stringByAppendingFormat:@"T00:00:00.000+0000"];
                            end_datetime   = [today_Date stringByAppendingFormat:@"T24:00:00.000+0000"];
                            
                            if([operator isEqualToString:@"="])
                            {
                                [finalQuery appendString:@" >= "];
                                [finalQuery appendFormat:@"'%@'",start_datetime];
                                [finalQuery appendFormat:@" AND %@",rhs];
                                [finalQuery appendFormat:@" < '%@",end_datetime];
                            }
                            else if([operator isEqualToString:@"<"] || [operator isEqualToString:@"<="])
                            {
                                [finalQuery appendFormat:@" %@",operator];
                                [finalQuery appendFormat:@"'%@",start_datetime];
                            }
                            else if([operator isEqualToString:@">"] || [operator isEqualToString:@">="])
                            {
                                [finalQuery appendFormat:@" %@",operator];
                                [finalQuery appendFormat:@"'%@",end_datetime];
                                
                            }
                            else if ([operator isEqualToString:@"<>"])
                            {
                                [finalQuery appendFormat:@"<"];
                                [finalQuery appendFormat:@"'%@'",start_datetime];
                                [finalQuery appendFormat:@" AND %@",rhs];
                                
                                [finalQuery appendFormat:@">"];
                                [finalQuery appendFormat:@"'%@",end_datetime];
                            }
                        }
                        
                        if([objectValue caseInsensitiveCompare:MACRO_TOMMOROW] == NSOrderedSame)
                        {
                            start_datetime = [tomorow_date stringByAppendingFormat:@"T00:00:00.000+0000"];
                            end_datetime   = [tomorow_date stringByAppendingFormat:@"T24:00:00.000+0000"];
                            if([operator isEqualToString:@"="])
                            {
                                
                                [finalQuery appendString:@" >= "];
                                [finalQuery appendFormat:@"'%@'",start_datetime];
                                [finalQuery appendFormat:@" AND %@",rhs];
                                [finalQuery appendFormat:@" < '%@",end_datetime];
                            }
                            else if([operator isEqualToString:@"<"] || [operator isEqualToString:@"<="])
                            {
                                [finalQuery appendFormat:@" %@",operator];
                                [finalQuery appendFormat:@"'%@",start_datetime];
                                
                            }
                            else if([operator isEqualToString:@">"] || [operator isEqualToString:@">="])
                            {
                                [finalQuery appendFormat:@" %@",operator];
                                [finalQuery appendFormat:@"'%@",end_datetime];
                                
                            }
                            else if ([operator isEqualToString:@"<>"])
                            {
                                [finalQuery appendFormat:@"<"];
                                [finalQuery appendFormat:@"'%@'",start_datetime];
                                [finalQuery appendFormat:@" AND %@",rhs];
                                
                                [finalQuery appendFormat:@">"];
                                [finalQuery appendFormat:@"'%@",end_datetime];
                            }
                        }
                        
                        if([objectValue caseInsensitiveCompare:MACRO_YESTERDAY] == NSOrderedSame)
                        {
                            start_datetime = [yesterday_date stringByAppendingFormat:@"T00:00:00.000+0000"];
                            end_datetime   = [yesterday_date stringByAppendingFormat:@"T24:00:00.000+0000"];
                            if([operator isEqualToString:@"="])
                            {
                                
                                [finalQuery appendString:@" >= "];
                                [finalQuery appendFormat:@"'%@'",start_datetime];
                                [finalQuery appendFormat:@" AND %@",rhs];
                                [finalQuery appendFormat:@" < '%@",end_datetime];
                            }
                            else if([operator isEqualToString:@"<"] || [operator isEqualToString:@"<="])
                            {
                                [finalQuery appendFormat:@" %@",operator];
                                [finalQuery appendFormat:@"'%@",start_datetime];
                                
                            }
                            else if([operator isEqualToString:@">"] || [operator isEqualToString:@">="])
                            {
                                [finalQuery appendFormat:@" %@",operator];
                                [finalQuery appendFormat:@"'%@",end_datetime];
                                
                            }
                            else if ([operator isEqualToString:@"<>"])
                            {
                                [finalQuery appendFormat:@"<"];
                                [finalQuery appendFormat:@"'%@'",start_datetime];
                                [finalQuery appendFormat:@" AND %@",rhs];

                                [finalQuery appendFormat:@">"];
                                [finalQuery appendFormat:@"'%@",end_datetime];
                            }
                        }
                         [finalQuery appendString:@"'"];
                    }
                    //krishna 23-1 memory opt 9493
                    [dateFormatter release];
                    dateFormatter = nil;
                }
                else
                {
                    if(![tableName isEqualToString:@"RecordType"] &&![objectValue Contains:@"SVMX.CURRENTUSER"] &&![objectValue Contains:@"SVMX.OWNER"]&&![refrence_to isEqualToString:@"User"])
                    {
                        if([operator isEqualToString:@" NOT IN "] || [operator isEqualToString:@" IN "])
                        {
                            [finalQuery appendString:operator];
                            [finalQuery appendString:@"("];
                            [finalQuery appendString:objectValue];
                            [finalQuery appendString:@")"]; //Defect 9571
                            
                        }
                        else
                        {
                            [finalQuery appendFormat:@" %@",operator];
                            [finalQuery appendString:objectValue];
                            if([operator isEqualToString:@">="] || [operator isEqualToString:@">"]) //Keerti Fix for #5157
                            {
                                [finalQuery appendString:@" AND"];
                                [finalQuery appendString:rhs];
                                [finalQuery appendString:@"!= ''"];
                                [finalQuery appendString:@" AND"];
                                [finalQuery appendString:rhs];
                                [finalQuery appendString:@"!= ' '"];
                                
                            }
                        }
                    }
                    
                }
                [resultDict setObject:TableArray forKey:@"TableArray"];
                [resultDict setObject:tableArrayDict forKey:@"tableArrayDict"];
                [resultDict setObject:finalQuery forKey:@"finalQuery"];
                finalQuery=nil;
                [finalQuery release];
                break;
            }
        }
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name Database :getupdatedTokenForSFM %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason Database :getupdatedTokenForSFM %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    return [resultDict autorelease];
}
-(NSMutableString*)getJoinFieldsForSFM:(NSDictionary*)dict
{
    NSMutableArray *TableArray = [dict objectForKey:@"TableArray"];
    NSMutableString *joinFields = [[NSMutableString alloc] init];
    @try
    {
        for (int i=0; i<[TableArray count]; i++)
        {
            NSMutableDictionary *dictApiName=[[dict objectForKey:@"tableArrayDict"] objectForKey:[TableArray objectAtIndex:i]];
            SMLog(kLogLevelVerbose,@"%@ ",dictApiName);
            for (int j=0; j<[[dictApiName allKeys] count]; j++)
            {
                BOOL isChild =  [appDelegate.databaseInterface IsChildObject:[dict objectForKey:@"object"]];
                SMLog(kLogLevelVerbose,@"isChild New:%d",isChild);
                NSString *relationshipName=[[dictApiName allKeys] objectAtIndex:j];
                NSString *alias=[dictApiName objectForKey:relationshipName]!=nil ?[dictApiName objectForKey:relationshipName]:relationshipName;
                [joinFields appendFormat:@" LEFT OUTER JOIN"];
                [joinFields appendFormat:@" '%@'",[TableArray objectAtIndex:i]];
                [joinFields appendFormat:@" %@ ",alias];
                [joinFields appendFormat:@" ON "];
                
                if(!isChild)
                {
                [joinFields appendFormat:@"('%@'.%@ = %@.Id",[dict objectForKey:@"object"],[self getapiNameforObject:[dict objectForKey:@"object"] RelationshipName:relationshipName],alias];
                }
                else
                {
                    [joinFields appendFormat:@"('%@'.%@ = %@.local_id",[dict objectForKey:@"object"],[self getapiNameforObject:[dict objectForKey:@"object"] RelationshipName:relationshipName],alias];

                }
                [joinFields appendFormat:@" )"];
            }
        }
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name Database :getJoinFieldsForSFM %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason Database :getJoinFieldsForSFM %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    return [joinFields autorelease];
}

#pragma mark - Record Type
-(NSArray*)getRecordTypeObject
{
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT record_type_id FROM SFRecordType where record_type !='nil' AND record_type is not null AND record_type !='' "];
    sqlite3_stmt * statement;
    NSString *record_typeStr;
    NSMutableArray *recordTypeArray=[[NSMutableArray alloc] init];
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * record_type_id = (char *) synchronized_sqlite3_column_text(statement,0);
            if ((record_type_id != nil) && strlen(record_type_id))
                record_typeStr = [[NSString alloc] initWithUTF8String:record_type_id];
            [recordTypeArray addObject:record_typeStr];
            record_typeStr = nil;
            [record_typeStr release];
        }
    }
    synchronized_sqlite3_finalize(statement);
    return [recordTypeArray autorelease];
}
-(void) insertRecordTypeIntoHeapTable
{
    NSArray *arrayRecordType=[self getRecordTypeObject];
    if(![arrayRecordType count]>0)
    {
        return;
    }
    
    [self beginTransaction];
    
    NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@','%@', '%@', '%@', '%@','%@','%@') VALUES (?1, ?2, ?3, ?4,?5,?6,?7)", SYNC_RECORD_HEAP, @"sf_id", @"object_name", @"sync_type", @"sync_flag",@"local_id",@"json_record",@"record_type"];
    
    sqlite3_stmt * bulkStmt;
    
    int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
    
    if (ret_value == SQLITE_OK)
    {
        // Vipin-db-optmz
        [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"insertRecordTypeIntoHeapTable"
                                                             andRecordCount:[arrayRecordType count]];
        [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[arrayRecordType count]];
        
        
        for (int i = 0; i < [arrayRecordType count]; i++)
        {
            
            char * _recordId = [appDelegate convertStringIntoChar:([arrayRecordType objectAtIndex:i]!= nil)?[arrayRecordType objectAtIndex:i]:@""];
            
            sqlite3_bind_text(bulkStmt, 1, _recordId, strlen(_recordId), SQLITE_TRANSIENT);
            
            char * _RecordType = [appDelegate convertStringIntoChar:@"RecordType"];
            
            sqlite3_bind_text(bulkStmt, 2, _RecordType, strlen(_RecordType), SQLITE_TRANSIENT);
            
            char * _syncType = [appDelegate convertStringIntoChar:@"DATA_SYNC"];
            
            sqlite3_bind_text(bulkStmt, 3, _syncType, strlen(_syncType), SQLITE_TRANSIENT);
            
            char * _syncFlag = [appDelegate convertStringIntoChar:@"false"];
            
            sqlite3_bind_text(bulkStmt, 4, _syncFlag, strlen(_syncFlag), SQLITE_TRANSIENT);
            
            char * _localId = [appDelegate convertStringIntoChar:@""];
            
            sqlite3_bind_text(bulkStmt, 5, _localId, strlen(_localId), SQLITE_TRANSIENT);
            char * _jsonRecord = [appDelegate convertStringIntoChar:@""];
            
            sqlite3_bind_text(bulkStmt, 6, _jsonRecord, strlen(_jsonRecord), SQLITE_TRANSIENT);
            char * _recordtype = [appDelegate convertStringIntoChar:@""];
            
            sqlite3_bind_text(bulkStmt, 7, _recordtype, strlen(_recordtype), SQLITE_TRANSIENT);
            
                        
            if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
            {
                SMLog(kLogLevelError,@"Commit Failed! - SYNC_RECORD_HEAP \n");
            }
            
            sqlite3_clear_bindings(bulkStmt);
            sqlite3_reset(bulkStmt);
        
        }
        
        // Vipin-db-optmz
        [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"insertRecordTypeIntoHeapTable"
                                                             andRecordCount:0];
        
    }
    
    [self endTransaction];
    synchronized_sqlite3_finalize(bulkStmt);
}
#pragma mark - Location Ping
- (void) createUserGPSTable
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"createUserGPSTable"
                                                         andRecordCount:1];

    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SVMXC__User_GPS_Log__c ('local_id' VARCHAR PRIMARY KEY  NOT NULL  DEFAULT (0), 'SVMXC__Status__c' TEXT, 'SVMXC__Latitude__c' VARCHAR, SVMXC__User__c 'TEXT', 'OwnerId' TEXT, 'SVMXC__Device_Type__c' TEXT, 'CreatedById' TEXT, 'SVMXC__Additional_Info__c' VARCHAR, 'SVMXC__Time_Recorded__c' VARCHAR, 'SVMXC__Longitude__c' VARCHAR)"]];
    if(result == YES)
        SMLog(kLogLevelVerbose,@"SVMXC__User_GPS_Log__c Table Create Success");
    else
        SMLog(kLogLevelError,@"SVMXC__User_GPS_Log__c Table Create Failed");
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"createUserGPSTable"
                                                                      andRecordCount:0];

}
- (void) deleteRecordFromUserGPSTable:(NSString *) localId
{
    NSString * queryStatementGPSLog = [NSString stringWithFormat:@"DELETE FROM SVMXC__User_GPS_Log__c where local_id='%@'",localId];
    char * err;
    if(localId != nil)
    {
        if (synchronized_sqlite3_exec(appDelegate.db, [queryStatementGPSLog UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            SMLog(kLogLevelError,@"%@", queryStatementGPSLog);
			SMLog(kLogLevelError,@"METHOD:deleteRecordFromUserGPSTable");
			SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
			[appDelegate printIfError:nil ForQuery:queryStatementGPSLog type:DELETEQUERY];
        }
    }
}

// delete seq
- (void) deleteSequenceofTable:(NSString *)tableName 
{
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"deleteSequenceofTable"
                                                         andRecordCount:1];
    
    NSString *sql =[NSString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@'",tableName];
    sqlite3_stmt *statement;
    char *table_name;
    NSString *tblname;
    if(appDelegate == nil)
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
        {
            table_name  = (char *) synchronized_sqlite3_column_text(statement, 0);
            if(table_name!=nil)
                tblname=[NSString stringWithFormat:@"%s",table_name];
                
        }        
    }
    synchronized_sqlite3_finalize(statement);

    if([tblname isEqualToString:tableName])
    {
        SMLog(kLogLevelVerbose,@"%@ Table exist",tableName);
        NSString * queryStatement = [NSString stringWithFormat:@"delete from sqlite_sequence where name='SVMXC__User_GPS_Log__c'"];
        
        char * err;
        
        if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            SMLog(kLogLevelError,@"%@", queryStatement);
			SMLog(kLogLevelError,@"METHOD:deleteSequenceofTable");
			SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
			[appDelegate printIfError:nil ForQuery:queryStatement type:DELETEQUERY];      
        }
    }
    
    [[PerformanceAnalytics sharedInstance] addDeletedRecordsNumber:1];
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"DeleterecordFromTable"
                                                                      andRecordCount:0];
}
-(void) insertrecordIntoUserGPSLog:(NSDictionary *)locationInfo
{
   @try
    {
   char *err;
    if(appDelegate == nil)
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if(appDelegate.metaSyncRunning||appDelegate.dataSyncRunning)
    {
        SMLog(kLogLevelVerbose,@"Sync is Running");
        return;
    }

    [self purgeLocationPingTable];
    NSString *latitude = [locationInfo objectForKey:@"latitude"];
    NSString *longitude = [locationInfo objectForKey:@"longitude"];
    NSString *time = [locationInfo objectForKey:@"timestamp"];
    
    NSString *additionalInfo = [locationInfo objectForKey:@"additionalInfo"];
    NSString *status = [locationInfo objectForKey:@"status"];
    if(appDelegate == nil)
        appDelegate = (AppDelegate *)[[ UIApplication sharedApplication] delegate];

    if(appDelegate.loggedInUserId == nil)
    {
        appDelegate.loggedInUserId=[self getLoggedInUserId:appDelegate.username];
    }
    SMLog(kLogLevelVerbose,@"Logged In User Id = %@",appDelegate.loggedInUserId);
    if(latitude == nil)
        latitude = @"";
    if(longitude == nil)
        longitude = @"";
    if(time == nil)
        time = @"";
    if(additionalInfo == nil)
        additionalInfo = @"";
    if(status == nil)
        status = @"";
    
    // Vipin-db-optmz    
    [self beginTransaction];
        
    // Mem_leak_fix - Vipindas 9493 Jan 18
    NSString *id_value = [[AppDelegate GetUUID] retain];
    NSString *device=@"iPad";
    NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO SVMXC__User_GPS_Log__c('local_id','SVMXC__Status__c','SVMXC__Latitude__c','SVMXC__User__c','OwnerId','SVMXC__Device_Type__c', 'CreatedById','SVMXC__Additional_Info__c','SVMXC__Longitude__c','SVMXC__Time_Recorded__c') VALUES ('%@','%@','%@','%@','','%@','','%@','%@','%@')",id_value,status,latitude,appDelegate.loggedInUserId,device,additionalInfo,longitude,time];    
    BOOL isInsertedIntoLocationTable=TRUE;
    SMLog(kLogLevelVerbose,@"Query = %@",sql);
    if(synchronized_sqlite3_exec(appDelegate.db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        isInsertedIntoLocationTable=FALSE;
        SMLog(kLogLevelError,@"%@", sql);
		SMLog(kLogLevelError,@"METHOD: insertrecordIntoUserGPSLog");
        SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
		[appDelegate printIfError:nil ForQuery:sql type:INSERTQUERY];
    }
        
    [id_value release];
    // Vipin-db-optmz
    [self endTransaction];
    
   
    if(isInsertedIntoLocationTable)
    {
        SMLog(kLogLevelVerbose,@"Success to Insert Data in Table");
        /*
        [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:id_value SF_id:@"" record_type:MASTER operation:INSERT object_name:@"SVMXC__User_GPS_Log__c" sync_flag:@"false" parentObjectName:@"" parent_loacl_id:@""];*/
        SMLog(kLogLevelVerbose,@"Insertion success");
        [self updateTechnicianLocation];
        [self updateUserGPSLocation];
    }
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name Database :insertrecordIntoUserGPSLog %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason Database :insertrecordIntoUserGPSLog %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    
}

- (void) purgeLocationPingTable
{   
    NSString *sql = @"SELECT Count(*) FROM SVMXC__User_GPS_Log__c";
    sqlite3_stmt *statement;
    int row_count;
    char *Id,*local_id;
    if(appDelegate == nil)
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
        {
            row_count = synchronized_sqlite3_column_int(statement, 0);
            SMLog(kLogLevelVerbose,@"No of location records in DB %d",row_count );
            
        }
        synchronized_sqlite3_finalize(statement);
    }
    //get limit from table
    NSString *limitLocationRecords = [appDelegate.settingsDict objectForKey:MAX_LOCATION_RECORD];
    limitLocationRecords = (limitLocationRecords!=nil)?limitLocationRecords:@"100";
    if(row_count < [limitLocationRecords intValue])
    {
        return;
    }
    while (row_count >=[limitLocationRecords intValue])
    {
        sql = @"select rowid,local_id from SVMXC__User_GPS_Log__c  asc limit 1";
        NSString *strId=nil,*strlocal_id=nil;
        
        if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)
        {
            if (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
            {
                Id = (char *) sqlite3_column_text(statement, 0);
                local_id = (char *) sqlite3_column_text(statement, 1);
                
                if (Id != nil && strlen(Id))
                    strId =   [[NSString alloc] initWithUTF8String:Id];
                SMLog(kLogLevelVerbose,@"Id =%@",strId);
                if (local_id != nil && strlen(local_id))
                    strlocal_id =   [[NSString alloc] initWithUTF8String:local_id];
                SMLog(kLogLevelVerbose,@"local_id =%@",strlocal_id);
            }
        }
        
        synchronized_sqlite3_finalize(statement);
        
        NSString * queryStatementGPSLog = [NSString stringWithFormat:@"DELETE FROM SVMXC__User_GPS_Log__c where rowid=%@",strId];
        BOOL isDataDeletedFromUser_GPS_Log=TRUE;
        char * err;
        if(strId != nil)
        {
            if (synchronized_sqlite3_exec(appDelegate.db, [queryStatementGPSLog UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                SMLog(kLogLevelError,@"%@", queryStatementGPSLog);
				SMLog(kLogLevelError,@"METHOD:purgeLocationPingTable");
				SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
				[appDelegate printIfError:nil ForQuery:queryStatementGPSLog type:DELETEQUERY];
                isDataDeletedFromUser_GPS_Log=FALSE;
            }
            
            [[PerformanceAnalytics sharedInstance] addDeletedRecordsNumber:1];
        }
        /*
        if(isDataDeletedFromUser_GPS_Log)
            [appDelegate.databaseInterface DeleterecordFromTable:@"SFDataTrailer" Forlocal_id:strlocal_id];        
         */
        
        row_count--;
    }
    
}
//  Unused methods
//- (NSString *) getSettingValueWithName:(NSString *)settingName
//{
//	NSString *settingValue = nil;
//    NSString *queryStatement;
//    sqlite3_stmt * statement;
//    if(appDelegate == nil)
//        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//    if(appDelegate.metaSyncRunning )
//    {
//        SMLog(kLogLevelVerbose,@"Meta Sync is Running");
//        return  nil;
//    }
//    queryStatement = [NSString stringWithFormat:@"SELECT 'SettingsValue'.SVMXC__Internal_Value__c FROM 'SettingsValue' LEFT OUTER  JOIN 'SettingsInfo' ON ('SettingsInfo'.Id= 'SettingsValue'.'SVMXC__Setting_ID__c')  where SVMXC__Setting_Unique_ID__c ='%@'",settingName];
//        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
//        {
//            if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
//            {
//                const char * value = (char *)synchronized_sqlite3_column_text(statement, 0);
//                if ((value !=nil) && strlen(value))
//                {
//                    settingValue = [NSString stringWithUTF8String:value];   
//                }
//                else 
//                {
//                    SMLog(kLogLevelVerbose,@"Value is nil");
//                    //return nil; vipin-db-
//                }
//            }
//            else 
//            {
//                SMLog(kLogLevelVerbose,@"No Records Found");
//            }
//        }
//        else
//        {
//            SMLog(kLogLevelVerbose,@"Query Execution Failed");
//        }
//    
//    synchronized_sqlite3_finalize(statement);
//    return settingValue;
//}
- (void)updateUserGPSLocation
{
    if(appDelegate == nil)
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if(appDelegate.metaSyncRunning)
    {
        SMLog(kLogLevelVerbose,@"Sync is Running");
        return;
    }    
    
    NSString *sql = @"SELECT SVMXC__Latitude__c,SVMXC__Longitude__c,SVMXC__Status__c,SVMXC__User__c,SVMXC__Device_Type__c,SVMXC__Additional_Info__c,SVMXC__Time_Recorded__c,local_id FROM SVMXC__User_GPS_Log__c  ORDER BY rowid desc";
    sqlite3_stmt *statement;
    char *_longitude = NULL;
    char *_latitude = NULL;
    char *_status = NULL;
    char *_user = NULL;
    char *_deviceType = NULL;
    char *_additional_info = NULL;
    char *_timeRecorded = NULL;
    char *_local_id = NULL;
    
    NSString *longitude = nil;
    NSString *latitude = nil;
    NSString *status = nil;
    NSString *user = nil;
    NSString *deviceType = nil;
    NSString *additional_info = nil;
    NSString *timeRecorded = nil;
    NSString *localId = nil;    
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];

    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
        {
            _latitude  = (char *) synchronized_sqlite3_column_text(statement, 0);
            _longitude = (char *) synchronized_sqlite3_column_text(statement, 1);
            _status = (char *) synchronized_sqlite3_column_text(statement, 2);
            _user = (char *) synchronized_sqlite3_column_text(statement, 3);
            _deviceType = (char *) synchronized_sqlite3_column_text(statement, 4);
            _additional_info = (char *) synchronized_sqlite3_column_text(statement, 5);
            _timeRecorded = (char *) synchronized_sqlite3_column_text(statement, 6);
            _local_id = (char *) synchronized_sqlite3_column_text(statement, 7);
            if(_latitude!=nil && strlen(_latitude))
            {
                latitude = [NSString stringWithFormat:@"%s",_latitude];
            }
            else
            {
                latitude = @"";
            }
            if(_longitude!=nil && strlen(_longitude))
            {
                longitude = [NSString stringWithFormat:@"%s",_longitude];
            }
            else
            {
                longitude = @"";
            }

            if(_status!=nil && strlen(_status))
            {
                status = [NSString stringWithFormat:@"%s",_status];
            }
            else
            {
                status = @"";
            }
            
            if(_user!=nil && strlen(_user))
            {
                user = [NSString stringWithFormat:@"%s",_user];
            }
            else
            {
                user = @"";
            }

            if(_deviceType!=nil && strlen(_deviceType))
            {
                deviceType = [NSString stringWithFormat:@"%s",_deviceType];
            }
            else
            {
                deviceType = @"";
            }

            if(_additional_info!=nil && strlen(_additional_info))
            {
                additional_info = [NSString stringWithFormat:@"%s",_additional_info];
            }
            else
            {
                additional_info = @"";
            }

            if(_timeRecorded!=nil && strlen(_timeRecorded))
            {
                timeRecorded = [NSString stringWithFormat:@"%s",_timeRecorded];
                timeRecorded = [timeRecorded stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                timeRecorded = [timeRecorded stringByReplacingOccurrencesOfString:@"Z" withString:@""];
            }
            else
            {
                timeRecorded = @"";
            }

            
            if(_local_id!=nil && strlen(_local_id))
            {
                localId = [NSString stringWithFormat:@"%s",_local_id];
            }
            else
            {
                continue;
            }
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:status forKey:@"SVMXC__Status__c"];
            [dict setObject:latitude forKey:@"SVMXC__Latitude__c"];
            [dict setObject:longitude forKey:@"SVMXC__Longitude__c"];
            [dict setObject:user forKey:@"SVMXC__User__c"];
            [dict setObject:deviceType forKey:@"SVMXC__Device_Type__c"];
            [dict setObject:additional_info forKey:@"SVMXC__Additional_Info__c"];
            [dict setObject:timeRecorded forKey:@"SVMXC__Time_Recorded__c"];
            [dict setObject:localId forKey:@"localId"];
            [resultArray addObject:dict];
            [dict release];
        }        
    }
    synchronized_sqlite3_finalize(statement);
    if (![appDelegate isInternetConnectionAvailable])
    {
        [resultArray release];
        return;
    }
	
	//OAuth.
	if ( ![[ZKServerSwitchboard switchboard] doCheckSessionForBackgroundCalls] )
		return;
		
    didUserGPSLocationUpdated=FALSE;
    SMLog(kLogLevelVerbose,@"Updating User GPS Location Table");
    SMXMonitor *monitor = [[SMXMonitor alloc] init];
    [monitor monitorSMMessageWithName:@"[DataBase updateUserGPSLocation]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Start"
                         timeInterval:10.0];

    [appDelegate.wsInterface dataSyncWithEventName:@"LOCATION_HISTORY" eventType:SYNC values:resultArray];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(kLogLevelVerbose,@"Datebase.m : updateUserGPSLocation: LocationHistory");
#endif
        
        if (didUserGPSLocationUpdated == TRUE)
            break;   
        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }
    }
    [monitor monitorSMMessageWithName:@"[DataBase updateUserGPSLocation]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Stop"
                         timeInterval:10.0];
    [resultArray release];
}
- (void)updateTechnicianLocation
{
    didTechnicianLocationUpdated=FALSE;//8760
    if(appDelegate == nil)
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    if(appDelegate.metaSyncRunning || appDelegate.isInitialMetaSyncInProgress)
    {
        didTechnicianLocationUpdated=TRUE;
        SMLog(kLogLevelVerbose,@"Sync is Running");
        return;
    }    
    NSMutableArray *location = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT SVMXC__Latitude__c,SVMXC__Longitude__c FROM SVMXC__User_GPS_Log__c  ORDER BY rowid desc limit 1";
    sqlite3_stmt *statement;
    char *longitude;
    char *latitude;
    BOOL isLatitudeNull = YES;
    BOOL isLongitudeNull = YES;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
        {
            latitude  = (char *) synchronized_sqlite3_column_text(statement, 0);
            longitude = (char *) synchronized_sqlite3_column_text(statement, 1);
            if(latitude!=nil && strlen(latitude))
            {
                [location addObject:[NSString stringWithFormat:@"%s",latitude]];
                isLatitudeNull = NO;
            }
            if(longitude!=nil && strlen(longitude))
            {
                [location addObject:[NSString stringWithFormat:@"%s",longitude]];
                isLongitudeNull = NO;
            }
        }        
        else
        {
            didTechnicianLocationUpdated=TRUE;
            SMLog(kLogLevelWarning,@"Records are not available. Not calling Tech Location Update");
            //return; vipin-db
        }
    }
    synchronized_sqlite3_finalize(statement);
    
    //vipin-db
    if (didTechnicianLocationUpdated)
    {
        // Vipin-memopt 9493
        [location  release];
        return;
    }
    
    if(isLatitudeNull || isLongitudeNull)
    {
        didTechnicianLocationUpdated=TRUE;
        SMLog(kLogLevelVerbose,@"Latitude or Longitude data is null");
        return;
    }
    if (![appDelegate isInternetConnectionAvailable])
    {
        didTechnicianLocationUpdated=TRUE;
        return;
    }
	
	//OAuth.
	if ( ![[ZKServerSwitchboard switchboard] doCheckSessionForBackgroundCalls] )
		return;
	
    didTechnicianLocationUpdated=FALSE;
    SMLog(kLogLevelVerbose,@"Updating Technician Location");
    SMXMonitor *monitor = [[[SMXMonitor alloc] init] autorelease];
    [monitor monitorSMMessageWithName:@"[DataBase updateTechnicianLocation]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Start"
                         timeInterval:10.0];

    [appDelegate.wsInterface dataSyncWithEventName:@"TECH_LOCATION_UPDATE" eventType:SYNC values:location];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(kLogLevelVerbose,@"Datebase.m : updateTechinicianLocation: TECH_LOCATION_UPDATE");
#endif
        if (didTechnicianLocationUpdated == TRUE)
            break;   
        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }
        
        SMLog(kLogLevelVerbose,@"Technician Location Updated");
    }
    [monitor monitorSMMessageWithName:@"[DataBase updateTechnicianLocation]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Stop"
                         timeInterval:10.0];
    [location release];
}

#pragma mark - Initial MetaSync
- (void) insertValuesInToOBjDefTableWithObject:(NSMutableArray *)object definition:(NSMutableArray *)objectDefinition
{

    // Vipin-db-optmz
    [self beginTransaction];
    
    //10346
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFObjectField ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0) ,'object_api_name' VARCHAR,'api_name' VARCHAR,'label' VARCHAR,'precision' DOUBLE, 'scale' DOUBLE,'length' INTEGER,'type' VARCHAR,'reference_to' VARCHAR,'nillable' BOOL,'unique' BOOL,'restricted_picklist' BOOL,'calculated' BOOL,'defaulted_on_create' BOOL,'name_field' BOOL, 'relationship_name' VARCHAR , 'dependent_picklist' BOOL ,'controler_field' VARCHAR)"]];
    
    if (result == YES)
    {
        
        int id_value = 1;
        
        NSMutableArray * objectArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        NSArray * fieldArray  = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        NSString * objectName = @"";
        
        NSString * emptyString = @"";
        
        //10346
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@','%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13, ?14, ?15)", SFOBJECTFIELD ,MOBJECT_API_NAME, MFIELD_API_NAME, MLENGTH, MTYPEM, MREFERENCE_TO, MRELATIONSHIP_NAME, MLABEL, MPRECISION, MSCALE, MNILLABLE, MRESTRICTED_PICKLIST, MCALCULATED, MDEFAULT_ON_CREATE, MNAME_FIELD, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        if (ret_value == SQLITE_OK)
        {
            for (int i = 0; i < [object count]; i++)
            {
                NSDictionary * dict = [object objectAtIndex:i];
                
                objectName = ([dict valueForKey:OBJECT] != nil)?[dict valueForKey:OBJECT]:@"";
           
                BOOL OBJFLAG = FALSE;
                
                for (NSDictionary * tempdict in objectDefinition)
                {
                    NSArray * tempKeys = [tempdict allKeys];
                    
                    for (int k = 0; k < [tempKeys count]; k++)
                    {
                        if ([objectName isEqualToString:[tempKeys objectAtIndex:k]])
                        {
                            objectArray = [tempdict objectForKey:[tempKeys objectAtIndex:k]];
                            OBJFLAG = TRUE;
                            break;
                        }
                    }
                    if (OBJFLAG)
                        break;
                    
                }

                
                for (int m = 0; m < [objectArray count]; m++)
                {
                    NSDictionary * dictionary = [objectArray objectAtIndex:m];
                    NSArray * keys = [dictionary allKeys];
                    for (int j = 0; j < [keys count]; j++)
                    {
                        if ( [[keys objectAtIndex:j] isEqualToString:MFIELDPROPERTY])
                        {
                            fieldArray = [dictionary objectForKey:MFIELDPROPERTY];
                            break;
                        }
                    }
                    
                }
                
                // Vipin-db-optmz
                [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFObjectField"
                                                                     andRecordCount:0];
                
                for (int m = 0; m < [fieldArray count]; m++)
                {
                    NSDictionary * dictionary = [fieldArray objectAtIndex:m];
                    
                    NSDictionary * obj = [dictionary objectForKey:FIELD];
                    
                    NSString * label = ([obj objectForKey:_LABEL] != nil)?[obj objectForKey:_LABEL]:@"";
                    if (![label isEqualToString:@""])
                    {
                        label = [label stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
                    }
                    
                    NSString * type = ([obj objectForKey:_TYPE] != nil)?[obj objectForKey:_TYPE]:@"";
                    type = [type lowercaseString];
                    
					char * _objectName = [appDelegate convertStringIntoChar:objectName];
					
                    sqlite3_bind_text(bulkStmt, 1, _objectName, strlen(_objectName), SQLITE_TRANSIENT);
					
					char * _field = [appDelegate convertStringIntoChar:([obj objectForKey:FIELD] != nil)?[obj objectForKey:FIELD]:@""];
                    
                    sqlite3_bind_text(bulkStmt, 2, _field, strlen(_field), SQLITE_TRANSIENT);
					
					char * _length = [appDelegate convertStringIntoChar:([obj objectForKey:_LENGTH] != nil)?[obj objectForKey:_LENGTH]:@""];
                    
                    sqlite3_bind_text(bulkStmt, 3, _length, strlen(_length), SQLITE_TRANSIENT);
					
					char * _type = [appDelegate convertStringIntoChar:type];
                    
                    sqlite3_bind_text(bulkStmt, 4, _type, strlen(_type), SQLITE_TRANSIENT);
					
					char * _reference_to = [appDelegate convertStringIntoChar:([obj objectForKey:_REFERENCETO] != nil)?[obj objectForKey:_REFERENCETO]:@""];
                    
                    sqlite3_bind_text(bulkStmt, 5, _reference_to, strlen(_reference_to), SQLITE_TRANSIENT);
					
					char * _relationshipName = [appDelegate convertStringIntoChar:([obj objectForKey:_RELATIONSHIPNAME] != nil)?[obj objectForKey:_RELATIONSHIPNAME]:@""];
                    
                    sqlite3_bind_text(bulkStmt, 6, _relationshipName, strlen(_relationshipName), SQLITE_TRANSIENT);
					
					char * _label = [appDelegate convertStringIntoChar:label];
                    
                    sqlite3_bind_text(bulkStmt, 7, _label, strlen(_label), SQLITE_TRANSIENT);
					
                    NSString * _precision  = ([obj objectForKey:_PRECISION] != nil)?[obj objectForKey:_PRECISION]:@"";
                    
                    int precisionValue = [_precision intValue];
                    
                    //10346
                    sqlite3_bind_int(bulkStmt, 8, precisionValue);
                    
                    NSString * _scale  = ([obj objectForKey:_SCALE] != nil)?[obj objectForKey:_SCALE]:@"";
                    
                    int scaleValue = [_scale intValue];
                    
                    //10346
                    sqlite3_bind_int(bulkStmt, 9, scaleValue);
                    
					char * _emptyString = [appDelegate convertStringIntoChar:emptyString];
                    
                    sqlite3_bind_text(bulkStmt, 10, _emptyString, strlen(_emptyString), SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 11, _emptyString, strlen(_emptyString), SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 12, _emptyString, strlen(_emptyString), SQLITE_TRANSIENT);
                    
                    sqlite3_bind_text(bulkStmt, 13, _emptyString, strlen(_emptyString), SQLITE_TRANSIENT);
					
					char * _nameField = [appDelegate convertStringIntoChar:([obj objectForKey:_NAMEFIELD] != nil)?[obj objectForKey:_NAMEFIELD]:@""];
                    
                    sqlite3_bind_text(bulkStmt, 14, _nameField, strlen(_nameField), SQLITE_TRANSIENT);
                    
                    sqlite3_bind_int(bulkStmt, 15, id_value++);
                    
                    if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                    {
                        SMLog(kLogLevelError,@"Commit Failed - SFObjectField!\n");
                    }
                    
                    sqlite3_clear_bindings(bulkStmt);
                    sqlite3_reset(bulkStmt);
                    
                }
                // Vipin-db-optmz
                [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"SFObjectField"
                                                                     andRecordCount:[fieldArray count]];
                
                [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[fieldArray count]];
                
            }
        }
         synchronized_sqlite3_finalize(bulkStmt);
    }
    
    // Vipin-db-optmz
    result = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS SFObjectFieldIndex ON SFObjectField (object_api_name, api_name, label)"]];
    
    result = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS SFObjectFieldIndex_2 ON SFObjectField (object_api_name, name_field)"]];
    
    // Vipin-db-optmz
    [self endTransaction];    
    [self insertValuesInToReferenceTable:object definition:objectDefinition];
}


- (void) insertValuesInToReferenceTable:(NSMutableArray *)object definition:(NSMutableArray *)objectDefinition
{
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFReferenceTo ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0) ,'object_api_name' VARCHAR,'field_api_name' VARCHAR,'reference_to' VARCHAR)"]];
    
    // Vipin-db-optmz
    [self beginTransaction];
    
    
    if (result == YES)
    {
        int id_Value = 1;
        
        NSString * objectName = @"";
        
                
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@') VALUES (?1,    ?2, ?3, ?4)", SFREFERENCETO, MOBJECT_API_NAME, _MFIELD_API_NAME, MREFERENCE_TO, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        

        
        for (int i = 0; i < [object count]; i++)
        {
            NSDictionary * dict = [object objectAtIndex:i];
            
            objectName = ([dict valueForKey:OBJECT] != nil)?[dict valueForKey:OBJECT]:@"";
              
			BOOL OBJFLAG = FALSE;
            
            NSArray * objectArray = [[[NSArray alloc] init] autorelease];
            for (NSDictionary * tempdict in objectDefinition)
            {
                NSArray * tempKeys = [tempdict allKeys];
                
                for (int k = 0; k < [tempKeys count]; k++)
                {
                    if ([objectName isEqualToString:[tempKeys objectAtIndex:k]])
                    {
                        objectArray = [tempdict objectForKey:[tempKeys objectAtIndex:k]];
                        OBJFLAG = TRUE;
                        break;
                    }
                }
                if (OBJFLAG)
                    break;
                
            }
            

            
            NSArray * fieldArray = [[[NSArray alloc] init] autorelease];
            for (int m = 0; m < [objectArray count]; m++)
            {
                NSDictionary * dictionary = [objectArray objectAtIndex:m];
                 NSArray * keys = [dictionary allKeys];
                for (int j = 0; j < [keys count]; j++)
                {
                    if ( [[keys objectAtIndex:j] isEqualToString:MFIELDPROPERTY])
                    {
                        fieldArray = [dictionary objectForKey:MFIELDPROPERTY];
                        break;
                    }
                }
                
            }
            
            
            if (ret_value == SQLITE_OK)
            {
                // Vipin-db-optmz
                
                [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFReferenceTo"
                                                                     andRecordCount:0];
                
                
                for (int m = 0; m < [fieldArray count]; m++)
                {
                    NSDictionary * dictionary = [fieldArray objectAtIndex:m];
                    NSDictionary  * obj = [dictionary objectForKey:FIELD];
                    
                    NSString * referenceName = [obj objectForKey:_REFERENCETO];
                    SMLog(kLogLevelVerbose,@"%@", referenceName);
                    if (!referenceName)
                        referenceName = @"";
                
                    if (!([referenceName isEqualToString:@""]))
                    {
						char * _objectName = [appDelegate convertStringIntoChar:objectName];
						
                        sqlite3_bind_text(bulkStmt, 1, _objectName, strlen(_objectName), SQLITE_TRANSIENT);
						
						char * _field = [appDelegate convertStringIntoChar:([obj objectForKey:FIELD] != nil)?[obj objectForKey:FIELD]:@""];
                        
                        sqlite3_bind_text(bulkStmt, 2, _field, strlen(_field), SQLITE_TRANSIENT);
						
						char * _reference_to = [appDelegate convertStringIntoChar:([obj objectForKey:_REFERENCETO] != nil)?[obj objectForKey:_REFERENCETO]:@""];
                        
                        sqlite3_bind_text(bulkStmt, 3, _reference_to, strlen(_reference_to), SQLITE_TRANSIENT);
                        
                        sqlite3_bind_int(bulkStmt, 4, id_Value++);
                        
                        int errorCodeX = synchronized_sqlite3_step(bulkStmt);
                        
                        if (errorCodeX != SQLITE_DONE)
                        {
                            SMLog(kLogLevelVerbose,@" Commit Failed! - SFReferenceTo : %d %@", errorCodeX, [NSString stringWithUTF8String:sqlite3_errmsg(appDelegate.db)]);
                            
                        }
                        
                        sqlite3_clear_bindings(bulkStmt);
                        sqlite3_reset(bulkStmt);
                    }
                }
                
                // Vipin-db-optmz
                [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFReferenceTo"
                                                                     andRecordCount:[fieldArray count]];
                
                [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[fieldArray count]];
                
            }
        }
        
        synchronized_sqlite3_finalize(bulkStmt);
    }
    
    // Vipin-db-optmz
    [self endTransaction];
    
    [self insertValuesInToRecordType:object defintion:objectDefinition];
    
}

- (void) insertValuesInToRecordType:(NSMutableArray *)object defintion:(NSMutableArray *)objectDefinition
{
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFRecordType ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0) ,'record_type_id' VARCHAR,'object_api_name' VARCHAR,'record_type' VARCHAR , 'recordtype_label' VARCHAR)"]];
    
    // Vipin-db-optmz
    [self beginTransaction];
    
    
    if (result == YES)
    {
        NSString * objectName = @"";
        int id_Value =  1;
                
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@') VALUES (?1, ?2,   ?3, ?4)", SFRECORDTYPE, MRECORD_TYPE_ID, MOBJECT_API_NAME, MRECORDTYPE_LABEL, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        for (int i = 0; i < [object count]; i++)
        {
            
            NSDictionary * dict = [object objectAtIndex:i];
            
            objectName = ([dict valueForKey:OBJECT] != nil)?[dict valueForKey:OBJECT]:@"";
            
					
            BOOL OBJFLAG = FALSE;
            
            NSArray * objectArray = [[[NSArray alloc] init] autorelease];
            for (NSDictionary * tempdict in objectDefinition)
            {
                NSArray * tempKeys = [tempdict allKeys];
                
                for (int k = 0; k < [tempKeys count]; k++)
                {
                    if ([objectName isEqualToString:[tempKeys objectAtIndex:k]])
                    {
                        objectArray = [tempdict objectForKey:[tempKeys objectAtIndex:k]];
                        OBJFLAG = TRUE;
                        break;
                    }
                }
                if (OBJFLAG)
                    break;
                
            }
            

            
            NSMutableArray * propertyArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
            for (int m = 0; m < [objectArray count]; m++)
            {
                NSDictionary * dictionary = [objectArray objectAtIndex:m];
                NSArray * keys = [dictionary allKeys];
                for (int j = 0; j < [keys count]; j++)
                {
                    if ( [[keys objectAtIndex:j] isEqualToString:MOBJECTPROPERTY])
                    {
                        propertyArray = [dictionary objectForKey:MOBJECTPROPERTY];
                        break;
                    }
                }
            }
            
            NSDictionary *  recordType = [[[NSDictionary alloc] init] autorelease];
            for (int m = 0; m < [propertyArray count]; m++)
            {
                
                NSDictionary * dict = [propertyArray objectAtIndex:m];
                NSArray * keys = [dict allKeys];
                for (int j = 0; j < [keys count]; j++)
                {
                    if ( [[keys objectAtIndex:j] isEqualToString:MRECORDTYPE])
                    {
                        recordType = [dict objectForKey:MRECORDTYPE];
                        break;
                    }
                }            
            }
            
            NSArray * recordKeys = [recordType allKeys];
            NSArray * recordValues = [recordType allValues];
            
            
            if (ret_value == SQLITE_OK)
            {
                // Vipin-db-optmz
                [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFRecordType"
                                                                     andRecordCount:0];
                
                for (int r = 0; r < [recordKeys count]; r++)
                {
                    if (![[recordKeys objectAtIndex:r] isEqualToString:MRECORDTYPE])
                    {
						char * _recordKeys = [appDelegate convertStringIntoChar:[recordKeys objectAtIndex:r]];
                        
                        sqlite3_bind_text(bulkStmt, 1, _recordKeys, strlen(_recordKeys), SQLITE_TRANSIENT);
						
						char * _objectName = [appDelegate convertStringIntoChar:objectName];
                        
                        sqlite3_bind_text(bulkStmt, 2, _objectName, strlen(_objectName), SQLITE_TRANSIENT);
						
						char * _recordValues = [appDelegate convertStringIntoChar:[recordValues objectAtIndex:r]];
                        
                        sqlite3_bind_text(bulkStmt, 3, _recordValues, strlen(_recordValues), SQLITE_TRANSIENT);
                        
                        sqlite3_bind_int(bulkStmt, 4, id_Value++);
                        
                        int errorCode = synchronized_sqlite3_step(bulkStmt);
                        
                        if ( errorCode != SQLITE_DONE)
                        {
                            SMLog(kLogLevelError,@" Commit Failed! - SFRecordType : %d %@", errorCode, [NSString stringWithUTF8String:sqlite3_errmsg(appDelegate.db)]);
                        }
                        
                        sqlite3_clear_bindings(bulkStmt);
                        sqlite3_reset(bulkStmt);
                    }
                }
                
                // Vipin-db-optmz
                [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFRecordType"
                                                                     andRecordCount:[recordKeys count]];
                
                [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[recordKeys count]];

            }
        }
        synchronized_sqlite3_finalize(bulkStmt);
    }
    // Vipin-db-optmz
    [self endTransaction];
    [self insertValuesInToObjectTable:object definition:objectDefinition];

}


- (void) insertValuesInToObjectTable:(NSMutableArray *)object definition:(NSMutableArray *)objectDefintion
{
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFObject ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0) ,'key_prefix' VARCHAR,'label' VARCHAR,'label_plural' VARCHAR,'api_name' VARCHAR)"]];
    
    // Vipin-db-optmz
    [self beginTransaction];
    
    
    if (result == YES)
    {
    
        NSString * objectName = @"";
        int id_Value = 0;
        
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5)", SFOBJECT, MKEY_PREFIX, MLABEL, MLABEL_PURAL, MFIELD_API_NAME, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);

        if (ret_value == SQLITE_OK)
        {
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFObject"
                                                                 andRecordCount:0];
            
            
            for (int i = 0; i < [object count]; i++)
            {
                
                NSDictionary * dict = [object objectAtIndex:i];
                objectName = ([dict valueForKey:OBJECT] != nil)?[dict valueForKey:OBJECT]:@"";
                
                BOOL OBJFLAG = FALSE;
                                
                NSArray * objectArray = [[[NSArray alloc] init] autorelease];
                for (NSDictionary * tempdict in objectDefintion)
                {
                    NSArray * tempKeys = [tempdict allKeys];
                    
                    for (int k = 0; k < [tempKeys count]; k++)
                    {
                        if ([objectName isEqualToString:[tempKeys objectAtIndex:k]])
                        {
                            objectArray = [tempdict objectForKey:[tempKeys objectAtIndex:k]];
                            OBJFLAG = TRUE;
                            break;
                        }
                    }
                    if (OBJFLAG)
                        break;
                    
                }

                NSMutableArray * propertyArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                
                for (int m = 0; m < [objectArray count]; m++)
                {
                    NSDictionary * dictionary = [objectArray objectAtIndex:m];
                    NSArray * keys = [dictionary allKeys];
                    for (int j = 0; j < [keys count]; j++)
                    {
                        if ( [[keys objectAtIndex:j] isEqualToString:MOBJECTPROPERTY])
                        {
                            propertyArray = [dictionary objectForKey:MOBJECTPROPERTY];
                            break;
                        }
                    }
                }
                NSDictionary *  objDef = [[[NSDictionary alloc] init] autorelease];
                for (int m = 0; m < [propertyArray count]; m++)
                {
                    
                    NSDictionary * dict = [propertyArray objectAtIndex:m];
                    NSArray * keys = [dict allKeys];
                    for (int j = 0; j < [keys count]; j++)
                    {
                        if ( [[keys objectAtIndex:j] isEqualToString:MOBJECTDEFINITION])
                        {
                            objDef = [dict objectForKey:MOBJECTDEFINITION];
                            break;
                        }
                    }            
                }
                
				char * _keyprefix = [appDelegate convertStringIntoChar:([objDef objectForKey:_MKEYPREFIX]!= nil)?[objDef objectForKey:_MKEYPREFIX]:@""];
				
                sqlite3_bind_text(bulkStmt, 1, _keyprefix, strlen(_keyprefix), SQLITE_TRANSIENT);
				
				char * _label = [appDelegate convertStringIntoChar:([objDef objectForKey:_LABEL]!= nil)?[objDef objectForKey:_LABEL]:@""];
                
                sqlite3_bind_text(bulkStmt, 2, _label, strlen(_label), SQLITE_TRANSIENT);
				
				char * _plurallabel = [appDelegate convertStringIntoChar:([objDef objectForKey:_MPLURALLABEL]!= nil)?[objDef objectForKey:_MPLURALLABEL]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _plurallabel, strlen(_plurallabel), SQLITE_TRANSIENT);
				
				char * _objectName = [appDelegate convertStringIntoChar:objectName];
                
                sqlite3_bind_text(bulkStmt, 4, _objectName, strlen(_objectName), SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 5, ++id_Value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed -  SFObject!\n");
                }
                
                sqlite3_clear_bindings(bulkStmt);
                sqlite3_reset(bulkStmt);
            }
            
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFObject"
                                                                 andRecordCount:[object count]];
            
            [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[object count]];
            
        }
        
        synchronized_sqlite3_finalize(bulkStmt);
    }
    
    // Vipin-db-optmz
    [self endTransaction];

    
    //Radha 9th jan
    [self insertValuesInToChildRelationshipTable:object definition:objectDefintion];
    
}

- (void) insertValuesInToChildRelationshipTable:(NSMutableArray *)object definition:(NSMutableArray *)objectDefinition
{
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFChildRelationship ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  DEFAULT 0,'object_api_name_parent' VARCHAR, 'object_api_name_child' VARCHAR, 'cascade_delete' BOOL, 'field_api_name' VARCHAR)"]];
    
    // Vipin-db-optmz
    [self beginTransaction];
    
    if (result == YES)
    {
        int id_value = 0;
        NSString * objectName = @"";
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5)", SFCHILDRELATIONSHIP, @"object_api_name_parent", @"object_api_name_child", @"cascade_delete", @"field_api_name", MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        NSString * emptyString = @"";
        
        if (ret_value == SQLITE_OK)
        {
            for (int i = 0; i < [object count]; i++)
            {
                NSDictionary * masterDetail;
                NSDictionary * dict = [object objectAtIndex:i];
                objectName = ([dict valueForKey:OBJECT] != nil)?[dict valueForKey:OBJECT]:@"";
                
                
				BOOL OBJFLAG = FALSE;
                
                NSArray * objectArray = [[[NSArray alloc] init] autorelease];
                for (NSDictionary * tempdict in objectDefinition)
                {
                    NSArray * tempKeys = [tempdict allKeys];
                    
                    for (int k = 0; k < [tempKeys count]; k++)
                    {
                        if ([objectName isEqualToString:[tempKeys objectAtIndex:k]])
                        {
                            objectArray = [tempdict objectForKey:[tempKeys objectAtIndex:k]];
                            OBJFLAG = TRUE;
                            break;
                        }
                    }
                    if (OBJFLAG)
                        break;
                    
                }
                
                NSMutableArray * propertyArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                for (int m = 0; m < [objectArray count]; m++)
                {
                    NSDictionary * dictionary = [objectArray objectAtIndex:m];
                    NSArray * keys = [dictionary allKeys];
                    for (int j = 0; j < [keys count]; j++)
                    {
                        if ( [[keys objectAtIndex:j] isEqualToString:MOBJECTPROPERTY])
                        {
                            propertyArray = [dictionary objectForKey:MOBJECTPROPERTY];
                            break;
                        }
                    }
                }
                NSDictionary *  objDef = [[[NSDictionary alloc] init] autorelease];;
                for (int m = 0; m < [propertyArray count]; m++)
                {
                    
                    NSDictionary * dict = [propertyArray objectAtIndex:m];
                    NSArray * keys = [dict allKeys];
                    for (int j = 0; j < [keys count]; j++)
                    {
                        if ( [[keys objectAtIndex:j] isEqualToString:MOBJECTDEFINITION])
                        {
                            objDef = [dict objectForKey:MOBJECTDEFINITION];
                            break;
                        }
                    }            
                }
                
                masterDetail = [objDef objectForKey:MASTERDETAILS];
                
                NSArray * masterDetailKeys = [masterDetail allKeys];
                NSArray * mastetDetaiValues = [masterDetail allValues];
                
                // Vipin-db-optmz
                [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFChildRelationship"
                                                                     andRecordCount:0];
                
                
                for (int val = 0; val < [masterDetailKeys count]; val++)
                {
					char * _objectName = [appDelegate convertStringIntoChar:objectName];
					
                    sqlite3_bind_text(bulkStmt, 1, _objectName, strlen(_objectName), SQLITE_TRANSIENT);
					
					char * _masterDetailKeys = [appDelegate convertStringIntoChar:[masterDetailKeys objectAtIndex:val]];
                    
                    sqlite3_bind_text(bulkStmt, 2, _masterDetailKeys, strlen(_masterDetailKeys), SQLITE_TRANSIENT);
					
					char * _emptyString = [appDelegate convertStringIntoChar:emptyString];
                    
                    sqlite3_bind_text(bulkStmt, 3, _emptyString, strlen(_emptyString), SQLITE_TRANSIENT);
					
					char * _mastetDetaiValues = [appDelegate convertStringIntoChar:[mastetDetaiValues objectAtIndex:val]];
                    
                    sqlite3_bind_text(bulkStmt, 4, _mastetDetaiValues, strlen(_mastetDetaiValues), SQLITE_TRANSIENT);
                    
                    sqlite3_bind_int(bulkStmt, 5, ++id_value);
                    
                    if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                    {
                        SMLog(kLogLevelError,@"Commit Failed - SFChildRelationship!\n");
                    }
                    
                    sqlite3_clear_bindings(bulkStmt);
                    sqlite3_reset(bulkStmt);
                }
                
                // Vipin-db-optmz
                [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFChildRelationship"
                                                                     andRecordCount:[masterDetailKeys count]];
                
                [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[masterDetailKeys count]];
                
            }
        }
        
        synchronized_sqlite3_finalize(bulkStmt);
    }
    
    // Vipin-db-optmz
    // isync-db-optmz: Introduced new  2 index
    result = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS SFChildRelationshipIndex_1 ON SFChildRelationship (object_api_name_child)"]];
    
    result = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS SFChildRelationshipIndex_2 ON SFChildRelationship (object_api_name_parent, object_api_name_child)"]];
    
    [appDelegate.databaseInterface clearChildInfoCacheDictionary];
    [self createObjectTable:object coulomns:objectDefinition];
    
    // Vipin-db-optmz
    [self endTransaction];

}

- (void) createObjectTable:(NSMutableArray *)object coulomns:(NSMutableArray *)columns
{
    NSMutableArray * objectArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];;
    NSString * objectName = @"";
    NSString * queryStatement;
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"createObjectTable"
                                                         andRecordCount:0];
    
    
    for (int i = 0; i < [object count]; i++)
    {
        NSDictionary * dict = [object objectAtIndex:i];
        
        objectName = ([dict valueForKey:OBJECT] != nil)?[dict valueForKey:OBJECT]:@"";
        
        BOOL OBJFLAG = FALSE;
        
        for (NSDictionary * tempdict in columns)
        {
            NSArray * tempKeys = [tempdict allKeys];
            
            for (int k = 0; k < [tempKeys count]; k++)
            {
                if ([objectName isEqualToString:[tempKeys objectAtIndex:k]])
                {
                    objectArray = [tempdict objectForKey:[tempKeys objectAtIndex:k]];
                    OBJFLAG = TRUE;
                    break;
                }
            }
            if (OBJFLAG)
                break;
            
        }
        
        NSMutableArray * fieldArray = [[[NSMutableArray alloc] init] autorelease];
        for (int m = 0; m < [objectArray count]; m++)
        {
            NSDictionary * dictionary = [objectArray objectAtIndex:m];
            NSArray * keys = [dictionary allKeys];
            for (int j = 0; j < [keys count]; j++)
            {
                if ( [[keys objectAtIndex:j] isEqualToString:MFIELDPROPERTY])
                {
                    fieldArray = [dictionary objectForKey:MFIELDPROPERTY];
                    break;
                }
            }
            
        }
        
        if ([objectName isEqualToString:@"Case"])
        {
            objectName = @"'Case'";
            SMLog(kLogLevelVerbose,@"%@", objectName);
        }
        char *err;
        queryStatement =[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@", objectName];
        if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            SMLog(kLogLevelError,@"Failed to drop");
            continue;
        }
        
        queryStatement = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ VARCHAR PRIMARY KEY  NOT NULL)", objectName, MLOCAL_ID];
        if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            SMLog(kLogLevelError,@"Failed to drop");
            continue;
        }
        
        [self insertColoumnsForTable:objectName columns:fieldArray];

    }
   
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"createObjectTable"
                                                         andRecordCount:[object count]];
    
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"createTableForSummaryAndTroubleShooting"
                                                         andRecordCount:0];
    
    [self createTableForSummaryAndTroubleShooting];
    
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"createTableForSummaryAndTroubleShooting"
                                                         andRecordCount:24];
    
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"createTableForCamera"
                                                         andRecordCount:0];
    [self createTableForCameraAttachments];
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"createTableForCamera"
                                                         andRecordCount:1];
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"createTableForAttachmentError"
                                                         andRecordCount:0];
    [self createTableForAttachmentErrors];
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"createTableForAttachmentError"
                                                         andRecordCount:1];
    
    appDelegate.wsInterface.didGetObjectDef = TRUE;
}


- (NSString *)columnType:(NSString *)type
{
    if ([type isEqualToString:BOOLEAN])
        return _BOOL;
    else if ([type isEqualToString:CURRENCY] || [type isEqualToString:DOUBLE] || [type isEqualToString:PERCENT])
        return DOUBLE;
    else if ([type isEqualToString:INTEGER])
        return INTEGER;
    else if ([type isEqualToString:DATE] || [type isEqualToString:DATETIME])
        return DATETIME;
    else if ([type isEqualToString:TEXTAREA])
        return VARCHAR;
    else
        return TEXT;
 }


// Vipin-db-optmz
- (void)doIndexCreationForTable:(NSString *)tableName
                     withFields:(NSArray *)fieldNames
                   andIndexName:(NSString *)indexName
{
    if (fieldNames == nil || ([fieldNames count] == 0)) {
        
        return;
    }
    
    NSMutableString *fields = [[NSMutableString alloc] init];
    
    int count = 0;
    
    for (NSString *fieldName in fieldNames)
    {
        [fields appendFormat:@" %@", fieldName];
        
        count++;
        if (count < [fieldNames count])
        {
            [fields appendString:@","];
        }
    }
    
    
    NSString *query = [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS %@ ON %@ (%@)", indexName, tableName, fields];
    
    [fields release];
    fields = nil;
    
    BOOL result = [self createTable:query];
    
    if (result)
    {
        SMLog(kLogLevelVerbose,@" [indx] success : index query \n %@ ", query);
    }else{
        SMLog(kLogLevelVerbose,@" [indx] failure : index query \n %@ ", query);
    }
    
    query = nil;
}


- (void) insertColoumnsForTable:(NSString *)tableName columns:(NSMutableArray *)columns
{
    NSString * queryStatement;
    
    BOOL shouldCreateIndexOnIDColumn = NO;
    
    NSMutableArray *fieldNames = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [columns count]; i++)
    {
        NSDictionary * dict = [columns objectAtIndex:i];
        
        NSString * type = [self columnType:[[dict objectForKey:FIELD] objectForKey:_TYPE]];
        
        
        // Vipin-db-optmz - New index creation
        NSString * fieldName = [[dict objectForKey:FIELD] objectForKey:FIELD];
        
        if ([fieldName isEqualToString:@"Id"])
        {
            //SMLog(kLogLevelVerbose,@"[Index] It has Id column \n for table : %@", tableName);
            [fieldNames addObject:fieldName];
            shouldCreateIndexOnIDColumn = YES;
        }
        
        fieldName = nil;
        
        
        queryStatement = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@", tableName, [[dict objectForKey:FIELD] objectForKey:FIELD], type];
        char * err;
        if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                [MyPopoverDelegate performSelector:@selector(throwException)];
        }
    
    }
    
    // Vipin-db-optmz
    NSString *indexName = [tableName stringByReplacingOccurrencesOfString:@"'"
                                                               withString:@""];
    indexName = [NSString stringWithFormat:@"%@_Indx_Id2", indexName];
    
    if (shouldCreateIndexOnIDColumn)
    {
        [self doIndexCreationForTable:tableName
                           withFields:fieldNames
                         andIndexName:indexName];
    }
    
    [fieldNames release];
    fieldNames = nil;
    
    
}
- (void) insertColoumn:(NSString *)columnName
              withType:(NSString *)columnType
               inTable:(NSString *)tableName
{
    NSString * queryStatement;
    char * err;
    queryStatement = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@", tableName, columnName, columnType];
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
    }
}
- (void) insertValuesToProcessTable:(NSMutableDictionary *)processDictionary
{
    int id_value = 0;
    NSArray * processArray = nil;
    processIdList = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    // Vipin-db-optmz
    [self beginTransaction];
    
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFProcess Segment"
                                                         andRecordCount:0];

    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFProcess ('local_id' INTEGER PRIMARY KEY  NOT NULL ,'process_id' VARCHAR,'object_api_name' VARCHAR,'process_type' VARCHAR,'process_name' VARCHAR,'process_description' VARCHAR, 'page_layout_id' VARCHAR, 'process_info' BLOB,'sfID' VARCHAR ,'doc_template_id' VARCHAR)"]]; // Damodar -OPDoc
    
    if (result == YES)
    {
        processArray = [processDictionary objectForKey:MSFMProcess];
        
        NSString * process_type = @"";
        
        // Vipin-db-optmz
        [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFProcess"
                                                             andRecordCount:0];
        
        
        for (int i = 0; i < [processArray count]; i++)
        {
            NSDictionary * dict = [processArray objectAtIndex:i];
            
            NSString * str = ([dict objectForKey:MPROCESS_DESCRIPTION] != nil)?[dict objectForKey:MPROCESS_DESCRIPTION]:@"";
            str = [str stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            process_type = ([dict objectForKey:MPROCESS_TYPE] != nil)?[dict objectForKey:MPROCESS_TYPE]:@"";
                        
            if ([process_type isEqualToString:SOURCE_TO_TARGET_ALL])
                process_type = SOURCETOTARGET;
            else if ([process_type isEqualToString:SOURCE_TO_TARGET_CHILD])
                process_type = SOURCETOTARGETONLYCHILDROWS;
            else if ([process_type isEqualToString:STANDALONE_EDIT])
                process_type = EDIT;
            else if ([process_type isEqualToString:STANDALONE_CREATE])
                process_type = STANDALONECREATE;
            else if ([process_type isEqualToString:VIEW_RECORD])
                process_type = VIEWRECORD;
                
            [processIdList addObject:([dict objectForKey:MPROCESS_UNIQUE_ID] != nil)?[dict objectForKey:MPROCESS_UNIQUE_ID]:@""];
            
            NSString * process_id = ( [dict objectForKey:MPROCESS_UNIQUE_ID] != nil)?[dict objectForKey:MPROCESS_UNIQUE_ID]:@"";
            process_id = [process_id stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString * process_SFID = ( [dict objectForKey:MPROCESS_ID] != nil)?[dict objectForKey:MPROCESS_ID]:@"";
            process_id = [process_id stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

            NSString * process_name =  ([dict objectForKey:MPROCESS_NAME] != nil)?[dict objectForKey:MPROCESS_NAME]:@"";
            process_name = [process_name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            NSString * template_id = ([dict objectForKey:doc_template_id] != nil) ? [dict objectForKey:doc_template_id]:@"";
            NSString * queryStatement = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@') VALUES ('%@', '%@', '%@', '%@', '%@', '%d','%@', '%@')", SFPROCESS, MPROCESS_ID, MPROCESS_TYPE, MPROCESS_NAME,
                                         MPROCESS_DESCRIPTION, @"page_layout_id", MLOCAL_ID,@"sfID", doc_template_id,
                                         process_id, 
                                         process_type, 
                                         process_name, 
                                         str, ([dict objectForKey:MPAGE_LAYOUT_ID] != nil)?[dict objectForKey:MPAGE_LAYOUT_ID]:@"", ++id_value,process_SFID,template_id]; // Damodar -OPDoc
            
            char * err;
            int ret = synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err);
            if (ret != SQLITE_OK)
            {
                if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                    [MyPopoverDelegate performSelector:@selector(throwException)];
				SMLog(kLogLevelError,@"METHOD:insertValuesToProcessTable");
				SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
                /*
				[appDelegate printIfError:nil ForQuery:queryStatement type:INSERTQUERY];
                 */
            }
            
            [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:1];
            
        }
        
        // Vipin-db-optmz
        [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFProcess"
                                                             andRecordCount:[processArray count]];
        
        
        process_type = @"";
    }
    
    // Vipin - db-opt
    [self endTransaction];
    
    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFProcess_test ('process_id' VARCHAR,'layout_id' VARCHAR,'object_name' VARCHAR,'expression_id' VARCHAR,'object_mapping_id' VARCHAR,'component_type' VARCHAR,'local_id' INTEGER PRIMARY KEY  NOT NULL , 'parent_column' VARCHAR, 'value_id' VARCHAR, 'parent_object' VARCHAR, 'Sorting_Order' VARCHAR, 'process_node_id' VARCHAR, 'doc_template_Detail_id' VARCHAR, 'target_object_label' VARCHAR, 'sfID' VARCHAR , 'enable_attachment' BOOLEAN)"]]; // Damodar -OPDoc
    
    if (result == YES)
    {
        // Vipin-db-optmz
        [self beginTransaction];
        
       NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@',  '%@', '%@', '%@', '%@', '%@','%@', '%@', '%@', '%@' ,'%@', '%@', '%@', '%@', '%@','%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10 ,?11, ?12, ?13, ?14, ?15, ?16)", @"SFProcess_test", MPROCESS_ID, @"layout_id", @"object_name", @"expression_id", @"object_mapping_id", @"component_type", @"parent_column", @"value_id", @"parent_object", MLOCAL_ID,SORTING_ORDER, process_node_id, MDOC_TEMPLATE_DETAIL_ID,@"target_object_label",@"sfID",@"enable_attachment"]; // Damodar -OPDoc
        
        sqlite3_stmt * bulkStmt = nil;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], -1, &bulkStmt, NULL);
        
        NSArray * sfProcess_comp = [processDictionary objectForKey:MSFProcess_component];
        id_value = 0;
        
        NSString * processId = @"";
        
        if (ret_value == SQLITE_OK)
        {
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFProcess_test"
                                                                 andRecordCount:0];
            
            for (int i = 0; i < [sfProcess_comp count]; i++)
            {
                NSDictionary * dict = [sfProcess_comp objectAtIndex:i];
                NSArray  * allkeys = [dict allKeys];
                NSString * processComp_Id = ([dict objectForKey:MPROCESS_ID] != nil)?[dict objectForKey:MPROCESS_ID]:@"";
                if(appDelegate.wsInterface.pageLayoutIDs == nil)
                    appDelegate.wsInterface.pageLayoutIDs = [[NSMutableArray alloc] init];
                [appDelegate.wsInterface.pageLayoutIDs addObject:processComp_Id];
                for (int j = 0; j < [processArray count]; j++)
                {
                    NSDictionary * sfdict = [processArray objectAtIndex:j];
                    
                    NSString * pId = ([sfdict objectForKey:MPROCESS_ID] != nil)?[sfdict objectForKey:MPROCESS_ID]:@"";
                    
                    if ([pId isEqualToString:processComp_Id])
                    {
                        processId = ([sfdict objectForKey:MPROCESS_UNIQUE_ID] != nil)?[sfdict objectForKey:MPROCESS_UNIQUE_ID]:@"";
                        break;
                    }
                }
                
                NSString * mapping_id = ([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@"";
                NSString * value = @"";
                if ([mapping_id isEqualToString:@""])
                {
                    value = ([dict objectForKey:@"value_mapping_id"] != nil)?[dict objectForKey:@"value_mapping_id"]:@"";
                }
                
				char * _processId = [appDelegate convertStringIntoChar:processId];
				
                sqlite3_bind_text(bulkStmt, 1, _processId, strlen(_processId), SQLITE_TRANSIENT);
				
				char * _layoutId = [appDelegate convertStringIntoChar:([dict objectForKey:MLAYOUT_ID] != nil)?[dict objectForKey:MLAYOUT_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 2, _layoutId, strlen(_layoutId), SQLITE_TRANSIENT);
				
				char * _object_name = [appDelegate convertStringIntoChar:([dict objectForKey:MOBJECT_NAME] != nil)?[dict objectForKey:MOBJECT_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _object_name, strlen(_object_name), SQLITE_TRANSIENT);
				
				char * _expressionId = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 4, _expressionId, strlen(_expressionId), SQLITE_TRANSIENT);
				
				char * _objectMappingId = [appDelegate convertStringIntoChar:([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 5, _objectMappingId, strlen(_objectMappingId), SQLITE_TRANSIENT);
				
				char * _componentType = [appDelegate convertStringIntoChar:([dict objectForKey:MCOMPONENT_TYPE] != nil)?[dict objectForKey:MCOMPONENT_TYPE]:@""];
                
                sqlite3_bind_text(bulkStmt, 6, _componentType, strlen(_componentType), SQLITE_TRANSIENT);
				
				char * _parentcolumn = [appDelegate convertStringIntoChar:([dict objectForKey:MPARENT_COLUMN] != nil)?[dict objectForKey:MPARENT_COLUMN]:@""];
                
                sqlite3_bind_text(bulkStmt, 7, _parentcolumn, strlen(_parentcolumn), SQLITE_TRANSIENT);
				
				char * _valueMappingId = [appDelegate convertStringIntoChar:([dict objectForKey:MVALUE_MAPPING_ID] != nil)?[dict objectForKey:MVALUE_MAPPING_ID]: @""];
                
                sqlite3_bind_text(bulkStmt, 8, _valueMappingId, strlen(_valueMappingId), SQLITE_TRANSIENT);
				
				char * _parentObject = [appDelegate convertStringIntoChar:([dict objectForKey:MPARENT_OBJECT] != nil)?[dict objectForKey:MPARENT_OBJECT]: @""];
                
                sqlite3_bind_text(bulkStmt, 9, _parentObject, strlen(_parentObject), SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 10, ++id_value);
                
                NSString * values_c = @"";
                if([allkeys containsObject:SORT_CRITERIA])
                {
                    values_c = [dict objectForKey:SORT_CRITERIA];
                }
                char * _sorting_order = [appDelegate convertStringIntoChar:(values_c != nil)?values_c:@""];
                sqlite3_bind_text(bulkStmt, 11, _sorting_order, strlen(_sorting_order), SQLITE_TRANSIENT);
                
                char * temp_process_node = [appDelegate convertStringIntoChar:([dict objectForKey:MLOCAL_ID] != nil)?[dict objectForKey:MLOCAL_ID]: @""];
                sqlite3_bind_text(bulkStmt, 12, temp_process_node, strlen(temp_process_node), SQLITE_TRANSIENT);
                
                 // Damodar -OPDoc
                char * _doc_template_detail_id = [appDelegate convertStringIntoChar:([dict objectForKey:MDOC_TEMPLATE_DETAIL_ID] != nil)?[dict objectForKey:MDOC_TEMPLATE_DETAIL_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 13, _doc_template_detail_id, strlen(_doc_template_detail_id), SQLITE_TRANSIENT);

                char * _targetObjectLabel = [appDelegate convertStringIntoChar:([dict objectForKey:@"target_object_label"] != nil)?[dict objectForKey:@"target_object_label"]: @""];
                
                sqlite3_bind_text(bulkStmt, 14, _targetObjectLabel, strlen(_targetObjectLabel), SQLITE_TRANSIENT);
                
                char * _sfID = [appDelegate convertStringIntoChar:([dict objectForKey:@"local_id"] != nil)?[dict objectForKey:@"local_id"]: @""];
                
                sqlite3_bind_text(bulkStmt, 15, _sfID, strlen(_sfID), SQLITE_TRANSIENT);

                NSString * enable_Attachment = @"";
                if([allkeys containsObject:@"enable_attachment"])
                {
                    enable_Attachment = [dict objectForKey:@"enable_attachment"];
                }
                char * _enableAttachment = [appDelegate convertStringIntoChar:(enable_Attachment != nil)?enable_Attachment:@""];
                sqlite3_bind_text(bulkStmt, 16, _enableAttachment, strlen(_enableAttachment), SQLITE_TRANSIENT);

                

                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed -  SFProcess_test!\n");
                }
                
                sqlite3_clear_bindings(bulkStmt);
                sqlite3_reset(bulkStmt);
            }
        }
        
        // Vipin-db-optmz
        [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFProcess_test"
                                                             andRecordCount:[sfProcess_comp count]];
        
        [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[sfProcess_comp count]];
        
        synchronized_sqlite3_finalize(bulkStmt);
        [self endTransaction];
    }
    
    // Vipin-db-optmz
    [self beginTransaction];
    
    
    NSMutableArray * process_comp_array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];

    for (int i = 0; i < [processIdList count]; i++)
    {        
        NSString * queryStatement = [NSString stringWithFormat:@"SELECT process_type FROM SFProcess WHERE process_id = '%@'", [processIdList objectAtIndex:i]];
        sqlite3_stmt * statement;
        NSString * processType = @"";
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                const char * _type = (char *)synchronized_sqlite3_column_text(statement, 0);
                if (strlen(_type))
                    processType = [NSString stringWithUTF8String:_type];
            }
        }
        
        synchronized_sqlite3_finalize(statement);
        
        NSArray * keys = [NSArray arrayWithObjects:MPROCESS_ID, MLAYOUT_ID, TARGET_OBJECT_NAME, SOURCE_OBJECT_NAME, EXPRESSION_ID, OBJECT_MAPPING_ID, MCOMPONENT_TYPE, MPARENT_COLUMN, MVALUE_MAPPING_ID,SORTING_ORDER, process_node_id, MDOC_TEMPLATE_DETAIL_ID,@"target_object_label",@"sfID",@"enable_attachment",nil]; // Damodar -OPDoc
        NSString * processId = @"", * layoutId = @"", * sourceName = @"", * expressionId = @"", * oMappingId = @"",* componentType = @"", * parentColumn = @"", * targetName = @"", * vMappingid = @"", * sorting_order_value = @"", * processnode_id = @"", *doc_temp_detail_id = @"",*targetObjectLabel = @"",*sfID = @"",*enable_attachment=@""; // Damodar -OPDoc
                                                    
        if ([processType isEqualToString:VIEWRECORD])
        {
            sqlite3_stmt * viewstatement;
            queryStatement = [NSString stringWithFormat:@"SELECT * FROM SFprocess_test WHERE process_id = '%@'", [processIdList objectAtIndex:i]];
            
            if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &viewstatement, NULL) == SQLITE_OK)
            {
                while (synchronized_sqlite3_step(viewstatement) == SQLITE_ROW)
                {
                    char * _processId = (char *) synchronized_sqlite3_column_text(viewstatement, COLUMNPROCESS_ID);
                    if ((_processId != nil) && strlen(_processId))
                        processId = [NSString stringWithUTF8String:_processId];
                    
                    char * _layoutId = (char *) synchronized_sqlite3_column_text(viewstatement, COLUMNLAYOUT_ID);
                    if ((_layoutId != nil) && strlen(_layoutId))
                        layoutId = [NSString stringWithUTF8String:_layoutId];
                    
                    char * _objectName = (char *) synchronized_sqlite3_column_text(viewstatement, COLUMNOBJECT_NAME);
                    if ((_objectName != nil) && strlen(_objectName))
                        sourceName = [NSString stringWithUTF8String:_objectName];
                    
                    char * _expressionId = (char *) synchronized_sqlite3_column_text(viewstatement, COLUMNEXPRESSION_ID);
                    if ((_expressionId != nil) && strlen(_expressionId))
                        expressionId = [NSString stringWithUTF8String:_expressionId];
                    
                    char * _mappingId = (char *) synchronized_sqlite3_column_text(viewstatement, COLUMNMAPPING_ID);
                    if ((_mappingId != nil) && strlen(_mappingId))
                        oMappingId = [NSString stringWithUTF8String:_mappingId];

                    char * _componentType = (char *) synchronized_sqlite3_column_text(viewstatement, COLUMNCOMP_TYPE);
                    if ((_componentType != nil) && strlen(_componentType))
                        componentType = [NSString stringWithUTF8String:_componentType];

                    char * _parentColumn = (char *) synchronized_sqlite3_column_text(viewstatement, COLUMNPARENT_COLUMN);
                    if ((_parentColumn != nil) && strlen(_parentColumn))
                        parentColumn = [NSString stringWithUTF8String:_parentColumn];
                    
                    char * _value_id = (char *) synchronized_sqlite3_column_text(viewstatement, COLUNMVALUEMAP);
                    if ((_value_id != nil) && strlen(_value_id))
                        vMappingid = [NSString stringWithUTF8String:_value_id];
                    
                    char * _sorting_order = (char *) synchronized_sqlite3_column_text(viewstatement, COLUMNSORTING_ORDER);
                    if ((_sorting_order != nil) && strlen(_sorting_order))
                        sorting_order_value = [NSString stringWithUTF8String:_sorting_order];
                    
                    // Damodar -OPDoc
                    char * _docTemplateDetail_id = (char *) synchronized_sqlite3_column_text(viewstatement, COLUMNDOCTEMP_DETAIL_ID);
                    if ((_docTemplateDetail_id != nil) && strlen(_docTemplateDetail_id))
                        doc_temp_detail_id = [NSString stringWithUTF8String:_docTemplateDetail_id];

                    if (![sourceName isEqualToString:@""])
                        targetName = sourceName;
                    
                    char * temp_process_node =  (char *) synchronized_sqlite3_column_text(viewstatement, COLUMNPROCESS_NODE);
                    if ((temp_process_node != nil) && strlen(temp_process_node))
                        processnode_id = [NSString stringWithUTF8String:temp_process_node];

                    char * _targetObjectLabel = (char *) synchronized_sqlite3_column_text(viewstatement, 13);
                    if ((_targetObjectLabel != nil) && strlen(_targetObjectLabel))
                        targetObjectLabel = [NSString stringWithUTF8String:_targetObjectLabel];
                    
                    char * _sfID = (char *) synchronized_sqlite3_column_text(viewstatement, 14);
                    if ((_sfID != nil) && strlen(_sfID))
                        sfID = [NSString stringWithUTF8String:_sfID];
                    
                    char * _enableAttachment = (char *) synchronized_sqlite3_column_text(viewstatement, 15);
                    if ((_enableAttachment != nil) && strlen(_enableAttachment))
                        enable_attachment = [NSString stringWithUTF8String:_enableAttachment];
    
                    NSArray * objects = [NSArray arrayWithObjects:processId, layoutId, targetName, sourceName, expressionId, oMappingId, componentType, parentColumn, vMappingid,sorting_order_value,processnode_id, doc_temp_detail_id, targetObjectLabel, sfID,enable_attachment, nil]; // Damodar -OPDoc
                    
                    NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    NSArray * arr = [NSArray arrayWithObject:dict];
                    [process_comp_array addObjectsFromArray:arr];
                    processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"" , sorting_order_value = @"", processnode_id = @"", doc_temp_detail_id = @"",targetObjectLabel = @"",sfID = @"",enable_attachment=@"";// Damodar OPdoc
                }
                
            }
            synchronized_sqlite3_finalize(viewstatement);
        }
        else if ([processType isEqualToString:EDIT])
        {
            sqlite3_stmt * editstatement;
            queryStatement = [NSString stringWithFormat:@"SELECT * FROM SFprocess_test WHERE process_id = '%@'", [processIdList objectAtIndex:i]];
            
            if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &editstatement, NULL) == SQLITE_OK)
            {
                while (synchronized_sqlite3_step(editstatement) == SQLITE_ROW)
                {
                    char * _processId = (char *) synchronized_sqlite3_column_text(editstatement, COLUMNPROCESS_ID);
                    if ((_processId != nil) && strlen(_processId))
                        processId = [NSString stringWithUTF8String:_processId];
                    
                    char * _layoutId = (char *) synchronized_sqlite3_column_text(editstatement, COLUMNLAYOUT_ID);
                    if ((_layoutId != nil) && strlen(_layoutId))
                        layoutId = [NSString stringWithUTF8String:_layoutId];
                    
                    char * _objectName = (char *) synchronized_sqlite3_column_text(editstatement, COLUMNOBJECT_NAME);
                    if ((_objectName != nil) && strlen(_objectName))
                        sourceName = [NSString stringWithUTF8String:_objectName];
                    
                    char * _expressionId = (char *) synchronized_sqlite3_column_text(editstatement, COLUMNEXPRESSION_ID);
                    if ((_expressionId != nil) && strlen(_expressionId))
                        expressionId = [NSString stringWithUTF8String:_expressionId];
                    
                    char * _mappingId = (char *) synchronized_sqlite3_column_text(editstatement, COLUMNMAPPING_ID);
                    if ((_mappingId != nil) && strlen(_mappingId))
                        oMappingId = [NSString stringWithUTF8String:_mappingId];
                    
                    char * _componentType = (char *) synchronized_sqlite3_column_text(editstatement, COLUMNCOMP_TYPE);
                    if ((_componentType != nil) && strlen(_componentType))
                        componentType = [NSString stringWithUTF8String:_componentType];
                    
                    char * _parentColumn = (char *) synchronized_sqlite3_column_text(editstatement, COLUMNPARENT_COLUMN);
                    if ((_parentColumn != nil) && strlen(_parentColumn))
                        parentColumn = [NSString stringWithUTF8String:_parentColumn];
                    
                    char * _value_id = (char *) synchronized_sqlite3_column_text(editstatement, COLUNMVALUEMAP);
                    if ((_value_id != nil) && strlen(_value_id))
                        vMappingid = [NSString stringWithUTF8String:_value_id];
                    
                    char * _sorting_order = (char *) synchronized_sqlite3_column_text(editstatement, COLUMNSORTING_ORDER);
                    if ((_sorting_order != nil) && strlen(_sorting_order))
                        sorting_order_value = [NSString stringWithUTF8String:_sorting_order];
                    
                    if (![sourceName isEqualToString:@""])
                        targetName = sourceName;
                    
                    char * temp_process_node =  (char *) synchronized_sqlite3_column_text(editstatement, COLUMNPROCESS_NODE);
                    if ((temp_process_node != nil) && strlen(temp_process_node))
                        processnode_id = [NSString stringWithUTF8String:temp_process_node];

                    // Damodar - OPDoc
                    char * _docTemplateDetail_id = (char *) synchronized_sqlite3_column_text(editstatement, COLUMNDOCTEMP_DETAIL_ID);
                    if ((_docTemplateDetail_id != nil) && strlen(_docTemplateDetail_id))
                        doc_temp_detail_id = [NSString stringWithUTF8String:_docTemplateDetail_id];

                    
                    char * _targetObjectLabel = (char *) synchronized_sqlite3_column_text(editstatement, 13);
                    if ((_targetObjectLabel != nil) && strlen(_targetObjectLabel))
                        targetObjectLabel = [NSString stringWithUTF8String:_targetObjectLabel];
                    
                    char * _sfID = (char *) synchronized_sqlite3_column_text(editstatement, 14);
                    if ((_sfID != nil) && strlen(_sfID))
                        sfID = [NSString stringWithUTF8String:_sfID];
                    
                    char * _enableAttachment = (char *) synchronized_sqlite3_column_text(editstatement, 15);
                    if ((_enableAttachment != nil) && strlen(_enableAttachment))
                        enable_attachment = [NSString stringWithUTF8String:_enableAttachment];

                    NSArray * objects = [NSArray arrayWithObjects:processId, layoutId, targetName, sourceName, expressionId, oMappingId, componentType, parentColumn,vMappingid, sorting_order_value, processnode_id, doc_temp_detail_id,targetObjectLabel,sfID,enable_attachment, nil]; // Damodar OPDoc
                    
                    NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    NSArray * arr = [NSArray arrayWithObject:dict];
                    [process_comp_array addObjectsFromArray:arr];
                    processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"", sorting_order_value = @"", processnode_id = @"", doc_temp_detail_id = @"",targetObjectLabel = @"",sfID = @"",enable_attachment=@""; // Damodar OPDoc
                }
               
            }
            synchronized_sqlite3_finalize(editstatement);
        }
        else if ([processType isEqualToString:STANDALONECREATE])
        {
            sqlite3_stmt * createstatement;
            queryStatement = [NSString stringWithFormat:@"SELECT * FROM SFprocess_test WHERE process_id = '%@'", [processIdList objectAtIndex:i]];
            
            if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &createstatement, NULL) == SQLITE_OK)
            {
                while (synchronized_sqlite3_step(createstatement) == SQLITE_ROW)
                {
                    char * _processId = (char *) synchronized_sqlite3_column_text(createstatement, COLUMNPROCESS_ID);
                    if ((_processId != nil) && strlen(_processId))
                        processId = [NSString stringWithUTF8String:_processId];
                    
                    char * _layoutId = (char *) synchronized_sqlite3_column_text(createstatement, COLUMNLAYOUT_ID);
                    if ((_layoutId != nil) && strlen(_layoutId))
                        layoutId = [NSString stringWithUTF8String:_layoutId];
                    
                    char * _objectName = (char *) synchronized_sqlite3_column_text(createstatement, COLUMNOBJECT_NAME);
                    if ((_objectName != nil) && strlen(_objectName))
                        sourceName = [NSString stringWithUTF8String:_objectName];
                    
                    char * _expressionId = (char *) synchronized_sqlite3_column_text(createstatement, COLUMNEXPRESSION_ID);
                    if ((_expressionId != nil) && strlen(_expressionId))
                        expressionId = [NSString stringWithUTF8String:_expressionId];
                    
                    char * _mappingId = (char *) synchronized_sqlite3_column_text(createstatement, COLUMNMAPPING_ID);
                    if ((_mappingId != nil) && strlen(_mappingId))
                        oMappingId = [NSString stringWithUTF8String:_mappingId];
                    
                    char * _componentType = (char *) synchronized_sqlite3_column_text(createstatement, COLUMNCOMP_TYPE);
                    if ((_componentType != nil) && strlen(_componentType))
                        componentType = [NSString stringWithUTF8String:_componentType];
                    
                    char * _parentColumn = (char *) synchronized_sqlite3_column_text(createstatement, COLUMNPARENT_COLUMN);
                    if ((_parentColumn != nil) && strlen(_parentColumn))
                        parentColumn = [NSString stringWithUTF8String:_parentColumn];
                    
                    char * _value_id = (char *) synchronized_sqlite3_column_text(createstatement, COLUNMVALUEMAP);
                    if ((_value_id != nil) && strlen(_value_id))
                        vMappingid = [NSString stringWithUTF8String:_value_id];
                    
                    char * _sorting_order = (char *) synchronized_sqlite3_column_text(createstatement, COLUMNSORTING_ORDER);
                    if ((_sorting_order != nil) && strlen(_sorting_order))
                        sorting_order_value = [NSString stringWithUTF8String:_sorting_order];
                    
                    if (![sourceName isEqualToString:@""])
                        targetName = sourceName;
                    
                    char * temp_process_node =  (char *) synchronized_sqlite3_column_text(createstatement, COLUMNPROCESS_NODE);
                    if ((temp_process_node != nil) && strlen(temp_process_node))
                        processnode_id = [NSString stringWithUTF8String:temp_process_node];

                    // Damodar OPDoc
                    char * _docTemplateDetail_id = (char *) synchronized_sqlite3_column_text(createstatement, COLUMNDOCTEMP_DETAIL_ID);
                    if ((_docTemplateDetail_id != nil) && strlen(_docTemplateDetail_id))
                        doc_temp_detail_id = [NSString stringWithUTF8String:_docTemplateDetail_id];

                    char * _targetObjectLabel = (char *) synchronized_sqlite3_column_text(createstatement, 13);
                    if ((_targetObjectLabel != nil) && strlen(_targetObjectLabel))
                        targetObjectLabel = [NSString stringWithUTF8String:_targetObjectLabel];
                    
                    char * _sfID = (char *) synchronized_sqlite3_column_text(createstatement, 14);
                    if ((_sfID != nil) && strlen(_sfID))
                        sfID = [NSString stringWithUTF8String:_sfID];
                    
                    char * _enableAttachment = (char *) synchronized_sqlite3_column_text(createstatement, 15);
                    if ((_enableAttachment != nil) && strlen(_enableAttachment))
                        enable_attachment = [NSString stringWithUTF8String:_enableAttachment];

                    NSArray * objects = [NSArray arrayWithObjects:processId, layoutId, targetName, sourceName, expressionId, oMappingId, componentType, parentColumn, vMappingid,sorting_order_value,processnode_id, doc_temp_detail_id,targetObjectLabel,sfID,enable_attachment, nil]; // Damodar OPDoc
                    
                    NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    NSArray * arr = [NSArray arrayWithObject:dict];
                    [process_comp_array addObjectsFromArray:arr];
                    processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"",sorting_order_value = @"", processnode_id = @"", doc_temp_detail_id = @"",targetObjectLabel = @"", sfID = @"",enable_attachment=@""; // Damodar OPDoc
                }
                
            }
            synchronized_sqlite3_finalize(createstatement);

        }
              
    }
    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFProcessComponent ('process_id' VARCHAR,'layout_id' VARCHAR,'target_object_name' VARCHAR,'source_object_name' VARCHAR,'expression_id' VARCHAR,'object_mapping_id' VARCHAR,'component_type' VARCHAR,'local_id' INTEGER PRIMARY KEY  NOT NULL ,'parent_column' VARCHAR, 'value_mapping_id' VARCHAR, 'source_child_parent_column' VARCHAR, 'Sorting_Order' VARCHAR, 'process_node_id' VARCHAR, 'doc_template_Detail_id' VARCHAR, 'target_object_label' VARCHAR, 'sfID' VARCHAR, 'enable_Attachment' BOOLEAN)"]]; // Damodar OPDoc
    
    if (result == YES)
    {
        
	NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@',  '%@', '%@', '%@', '%@','%@', '%@', '%@', '%@', '%@','%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6,?7, ?8, ?9, ?10, ?11,?12, ?13, ?14, ?15, ?16, ?17)", SFPROCESSCOMPONENT, MPROCESS_ID, MLAYOUT_ID, MTARGET_OBJECT_NAME, MSOURCE_OBJECT_NAME, MEXPRESSION_ID, MOBJECT_MAPPING_ID, MCOMPONENT_TYPE, MPARENT_COLUMN,MVALUE_MAPPING_ID,@"source_child_parent_column", MLOCAL_ID,SORTING_ORDER, process_node_id,MDOC_TEMPLATE_DETAIL_ID,@"target_object_label", @"sfID",@"enable_Attachment"]; // Damodar OPDoc
        
        sqlite3_stmt * bulkStmt;
        
        int ret_val = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]),  &bulkStmt, NULL);

        
        id_value = 0;
        NSString * emptyString = @"";
        
        if (ret_val == SQLITE_OK)
        {
            
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFProcessComponent"
                                                                 andRecordCount:0];
            
        
            for (int i = 0; i < [process_comp_array count]; i++)
            {
                NSDictionary * dict = [process_comp_array objectAtIndex:i];
                NSArray * allkeys = [dict allKeys];
                
				char * _processId = [appDelegate convertStringIntoChar:([dict objectForKey:MPROCESS_ID] != nil)?[dict objectForKey:MPROCESS_ID]:@""];
				
                sqlite3_bind_text(bulkStmt, 1, _processId, strlen(_processId), SQLITE_TRANSIENT);
				
				char * _layoutId = [appDelegate convertStringIntoChar:([dict objectForKey:MLAYOUT_ID] != nil)?[dict objectForKey:MLAYOUT_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 2, _layoutId, strlen(_layoutId), SQLITE_TRANSIENT);
				
				char * _targetObjectName = [appDelegate convertStringIntoChar:([dict objectForKey:MTARGET_OBJECT_NAME] != nil)?[dict objectForKey:MTARGET_OBJECT_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _targetObjectName, strlen(_targetObjectName), SQLITE_TRANSIENT);
				
				char * _sourceObjectName = [appDelegate convertStringIntoChar:([dict objectForKey:MSOURCE_OBJECT_NAME] != nil)?[dict objectForKey:MSOURCE_OBJECT_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 4, _sourceObjectName, strlen(_sourceObjectName), SQLITE_TRANSIENT);
				
                char * _expressionId = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 5, _expressionId, strlen(_expressionId), SQLITE_TRANSIENT);
				
				char * _objectMappingId = [appDelegate convertStringIntoChar:([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 6, _objectMappingId, strlen(_objectMappingId), SQLITE_TRANSIENT);
				
				char * _componentType = [appDelegate convertStringIntoChar:([dict objectForKey:MCOMPONENT_TYPE] != nil)?[dict objectForKey:MCOMPONENT_TYPE]:@""];
                
                sqlite3_bind_text(bulkStmt, 7, _componentType, strlen(_componentType), SQLITE_TRANSIENT);
				
				char * _parentColumn = [appDelegate convertStringIntoChar:([dict objectForKey:MPARENT_COLUMN] != nil)?[dict objectForKey:MPARENT_COLUMN]:@""];
                
                sqlite3_bind_text(bulkStmt, 8, _parentColumn, strlen(_parentColumn), SQLITE_TRANSIENT);
				
				char * _valueMappingId = [appDelegate convertStringIntoChar:([dict objectForKey:MVALUE_MAPPING_ID] != nil)?[dict objectForKey:MVALUE_MAPPING_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 9, _valueMappingId, strlen(_valueMappingId), SQLITE_TRANSIENT);
				
				char * _emptyString = [appDelegate convertStringIntoChar:emptyString];
                
                sqlite3_bind_text(bulkStmt, 10, _emptyString, strlen(_emptyString), SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 11, ++id_value);
                
                NSString * values_c = @"";
                if([allkeys containsObject:SORTING_ORDER])
                {
                    values_c = [dict objectForKey:SORTING_ORDER];
                }
                char * _sorting_order = [appDelegate convertStringIntoChar:(values_c != nil)?values_c:@""];
                sqlite3_bind_text(bulkStmt, 12, _sorting_order, strlen(_sorting_order), SQLITE_TRANSIENT);
                
                char * temp_process_node = [appDelegate convertStringIntoChar:([dict objectForKey:process_node_id] != nil)?[dict objectForKey:process_node_id]:@""];
                sqlite3_bind_text(bulkStmt, 13, temp_process_node, strlen(temp_process_node), SQLITE_TRANSIENT);
                
                //Damodar OPDoc
                char * _doc_template_detail_id = [appDelegate convertStringIntoChar:([dict objectForKey:MDOC_TEMPLATE_DETAIL_ID] != nil)?[dict objectForKey:MDOC_TEMPLATE_DETAIL_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 14, _doc_template_detail_id, strlen(_doc_template_detail_id), SQLITE_TRANSIENT);

                char * _targetObjectLabel = [appDelegate convertStringIntoChar:([dict objectForKey:@"target_object_label"] != nil)?[dict objectForKey:@"target_object_label"]:@""];
                
                sqlite3_bind_text(bulkStmt, 15, _targetObjectLabel, strlen(_targetObjectLabel), SQLITE_TRANSIENT);
                
                char * _sfID = [appDelegate convertStringIntoChar:([dict objectForKey:@"sfID"] != nil)?[dict objectForKey:@"sfID"]:@""];
                
                sqlite3_bind_text(bulkStmt, 16, _sfID, strlen(_sfID), SQLITE_TRANSIENT);
                
                NSString * enable_attachment = @"";
                if([allkeys containsObject:@"enable_attachment"])
                {
                    enable_attachment = [dict objectForKey:@"enable_attachment"];
                }
                char * _enableAttachment = [appDelegate convertStringIntoChar:(enable_attachment != nil)?enable_attachment:@""];
                sqlite3_bind_text(bulkStmt, 17, _enableAttachment, strlen(_enableAttachment), SQLITE_TRANSIENT);


                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed - SFProcessComponent!\n");
                }
                
                sqlite3_clear_bindings(bulkStmt);
                sqlite3_reset(bulkStmt);
                
            }
            
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFProcessComponent"
                                                                 andRecordCount:[process_comp_array count]];
            
            [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[process_comp_array count]];
            
        }
        
         synchronized_sqlite3_finalize(bulkStmt);
    }
    // Vipin-db-optmz
    [self endTransaction];

    
    [self insertValuesInToExpressionTables:processDictionary];
    [self insertValuesIntoLinkedSFMProcessTable:processDictionary];

    // SFM OP DOCS
    [self insertIntoDocTemplate:processDictionary];
    [self insertIntoDocTemplateDetails:processDictionary];
    [self insertIntoAttachment:processDictionary];
    [self requestForStaticResources];

    
    //Source object update
    [self insertIntoSourceUpdateTable:processDictionary];
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFProcess Segment"
                                                         andRecordCount:0];

    
}

/*
- (void) insertPageUIDetails:(NSArray *)pageUIHistory
{
    sqlite3_stmt * statement;
    
    // NSString *queryStatement = [NSString stringWithFormat:@"SELECT %@,%@ FROM SFProcess",MPAGE_LAYOUT_ID,MPROCESS_ID];
    
    NSString *queryStatement  = [[NSString alloc]initWithFormat:@"SELECT %@,%@ FROM SFProcess",MPAGE_LAYOUT_ID,MPROCESS_ID];//HS
    
    NSMutableArray *processArray = [[NSMutableArray alloc] init];
    
    NSString *pageLayoutID = nil;
    
    NSString *processID = nil;
    
    NSArray *processTableKeys = [NSArray arrayWithObjects:MPAGE_LAYOUT_ID,MPROCESS_ID, nil];
    
    int result = synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL);
    
    if ( result == SQLITE_OK)
        
    {
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW) //0.2 Mb
        {
            const char * _pageLayoutID = (char *)synchronized_sqlite3_column_text(statement, 0);
            
            if (strlen(_pageLayoutID))
            {
                //pageLayoutID = [NSString stringWithUTF8String:_pageLayoutID];
                pageLayoutID = [[NSString alloc]initWithUTF8String:_pageLayoutID];//HS
            }
            
            
            const char * _processID = (char *)synchronized_sqlite3_column_text(statement, 1);
            if (strlen(_processID))
            {
                //processID = [NSString stringWithUTF8String:_processID];
                processID = [[NSString alloc]initWithUTF8String:_processID];//HS
            }
            /*
             
             NSArray *valuesArray = [NSArray arrayWithObjects:pageLayoutID,processID, nil];
             
             NSDictionary *processDict = [NSDictionary dictionaryWithObjects:valuesArray forKeys:processTableKeys];
             
             [processArray addObject:processDict];
             
             *//*
            
            NSArray *valuesArray = [[NSArray alloc] initWithObjects:pageLayoutID,processID, nil];
            
            NSDictionary *processDict = [[NSDictionary alloc]initWithObjects: valuesArray forKeys:processTableKeys];//HS
            [processArray addObject:processDict];//HS
            [processDict release];//HS
            
            [valuesArray release];//HS
            
            [pageLayoutID release];//HS 17Jan
            
            [processID release];//HS 17Jan
            
            pageLayoutID = nil;//HS 17Jan
            
            processID =nil;//HS 17Jan
        }
    }
    
    [queryStatement release];//HS
    
    queryStatement = nil;//HS
    
    NSString *process_type = nil;
    
    for (int j = 0; j < [processArray count]; j++)
    {
        NSString * objectApiName = @"";
        NSData * data = nil;
        NSDictionary * dict = [processArray objectAtIndex:j];
        NSString * pageId = [dict objectForKey:MPAGE_LAYOUT_ID];
        
        NSString * process_id = [dict objectForKey:MPROCESS_ID];
        
        process_id = [process_id stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        for (int i = 0; i < [pageUIHistory count]; i++)
        {
            NSDictionary * page_dict = [pageUIHistory objectAtIndex:i];
            NSDictionary * headerDict = [page_dict objectForKey:MHEADER];
            NSString * page_layout_id = [headerDict objectForKey:MHEADER_LAYOUT_ID];
            
            if ([page_layout_id isEqualToString:pageId])
            {
                objectApiName = ([headerDict objectForKey:MHEADER_OBJECT_NAME] != nil)?[headerDict objectForKey:MHEADER_OBJECT_NAME]:@"";
                
                //Query to find the process_type
                sqlite3_stmt * statement;
                
                // NSString *queryStatement = [NSString stringWithFormat:@"SELECT process_type FROM SFProcess WHERE process_id = '%@'",process_id];
                
                NSString *queryStatement  = [[NSString alloc]initWithFormat:@"SELECT process_type FROM SFProcess WHERE process_id = '%@'",process_id];//HS
                
                if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
                {
                    if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
                    {
                        const char * _type = (char *)synchronized_sqlite3_column_text(statement, 0);
                        
                        if (strlen(_type))
                            //process_type = [NSString stringWithUTF8String:_type];
                            
                            process_type = [[NSString alloc]initWithUTF8String:_type];//HS
                    }
                }
                
                [queryStatement release];//HS
                queryStatement = nil;//HS
                [page_dict setValue:process_type forKey:MPROCESSTYPE]; //HS
                [process_type release];//HS
                
                NSError *err = NULL;
                // data = [NSPropertyListSerialization dataFromPropertyList:page_dict format:NSPropertyListXMLFormat_v1_0 errorDescription:&err]; //18126 bytes
                
                //dataWithPropertyList:format:options:error:
                
                data = [NSPropertyListSerialization dataWithPropertyList:page_dict format:NSPropertyListXMLFormat_v1_0 options:0 error:&err];//HS
                
                if (!data)
                {
                    err = NULL;
                }
                
                //HS 1 Jan
                
                synchronized_sqlite3_finalize(statement);
                break;
            }
        }
        
        // NSString * queryStatement = [NSString stringWithFormat:@"Update SFProcess Set %@ = '%@', %@ = '%@' Where %@ = '%@' AND %@ = '%@'", MOBJECT_API_NAME, objectApiName, MPROCESS_INFO, data, MPAGE_LAYOUT_ID, pageId, MPROCESS_ID, process_id];
        
        NSString *queryStatement = [[NSString alloc]initWithFormat:@"Update SFProcess Set %@ = '%@', %@ = '%@' Where %@ = '%@' AND %@ = '%@'", MOBJECT_API_NAME, objectApiName, MPROCESS_INFO, data, MPAGE_LAYOUT_ID, pageId, MPROCESS_ID, process_id]; //HS
        
        char * err;
        
        if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
            
        {
            
            if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                
                [MyPopoverDelegate performSelector:@selector(throwException)];
            
            SMLog(kLogLevelError,@"METHOD:insertValuesToProcessTable " );
            
            SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
        }
        
        
        //HS 1 Jan
        [queryStatement release];
        queryStatement = nil;
        data = nil;
        //HS 1 Jan
        
        [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:1];
    }
    
    [processArray release];

}
*/

- (void) insertPageUIDetails:(NSArray *)pageUIHistory
{
    sqlite3_stmt * statement;
    NSString *queryStatement = [NSString stringWithFormat:@"SELECT %@,%@ FROM SFProcess",MPAGE_LAYOUT_ID,MPROCESS_ID];
    
    NSMutableArray *processArray = [[NSMutableArray alloc] init];
    NSString *pageLayoutID = nil;
    NSString *processID = nil;
    NSArray *processTableKeys = [NSArray arrayWithObjects:MPAGE_LAYOUT_ID,MPROCESS_ID, nil];
    int result = synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL);
    if ( result == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            const char * _pageLayoutID = (char *)synchronized_sqlite3_column_text(statement, 0);
            if (strlen(_pageLayoutID))
                pageLayoutID = [NSString stringWithUTF8String:_pageLayoutID];
            const char * _processID = (char *)synchronized_sqlite3_column_text(statement, 1);
            if (strlen(_processID))
                processID = [NSString stringWithUTF8String:_processID];
            NSArray *valuesArray = [NSArray arrayWithObjects:pageLayoutID,processID, nil];
            NSDictionary *processDict = [NSDictionary dictionaryWithObjects:valuesArray forKeys:processTableKeys];
            [processArray addObject:processDict];
        }
    }

    NSString *process_type = nil;
     for (int j = 0; j < [processArray count]; j++)
     {
         //MEM-OPT
         @autoreleasepool {
         NSString * objectApiName = @"";
         
         NSData * data = nil;
         
         NSDictionary * dict = [processArray objectAtIndex:j];
         
         NSString * pageId = [dict objectForKey:MPAGE_LAYOUT_ID];
         NSString * process_id = [dict objectForKey:MPROCESS_ID];
         process_id = [process_id stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
         
         for (int i = 0; i < [pageUIHistory count]; i++)
         {
             NSDictionary * page_dict = [pageUIHistory objectAtIndex:i];
             
             NSDictionary * headerDict = [page_dict objectForKey:MHEADER];
             
             NSString * page_layout_id = [headerDict objectForKey:MHEADER_LAYOUT_ID];
         
             if ([page_layout_id isEqualToString:pageId])
             {
                 objectApiName = ([headerDict objectForKey:MHEADER_OBJECT_NAME] != nil)?[headerDict objectForKey:MHEADER_OBJECT_NAME]:@"";
                 
                 //Query to find the process_type
                 sqlite3_stmt * statement;
                 NSString *queryStatement = [NSString stringWithFormat:@"SELECT process_type FROM SFProcess WHERE process_id = '%@'",
                 process_id];
                 if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
                 {
                     if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
                     {
                         const char * _type = (char *)synchronized_sqlite3_column_text(statement, 0);
                         if (strlen(_type))
                         process_type = [NSString stringWithUTF8String:_type];
                     }
                 }
                 
                 [page_dict setValue:process_type forKey:MPROCESSTYPE];
                 
                 NSString * err;
                 data = [NSPropertyListSerialization dataFromPropertyList:page_dict format:NSPropertyListXMLFormat_v1_0 errorDescription:&err];
                 
                 synchronized_sqlite3_finalize(statement);
                 break;
            }
         }
         NSString * queryStatement = [NSString stringWithFormat:@"Update SFProcess Set %@ = '%@', %@ = '%@' Where %@ = '%@' AND %@ = '%@'", MOBJECT_API_NAME, objectApiName, MPROCESS_INFO, data, MPAGE_LAYOUT_ID, pageId, MPROCESS_ID, process_id];
         char * err;
         if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
         {
             if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
             [MyPopoverDelegate performSelector:@selector(throwException)];
             
             SMLog(kLogLevelError,@"METHOD:insertValuesToProcessTable " );
             SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
         }
         
         [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:1];
     }
     }
    [processArray release];
}

// START : SFM OP Docs


// Damodar - OPDocs - PDF download with html-ids and signature-ids
- (void)downloadPDFsForUploadedHtml
{
    // Select all ids from @"SFRequiredPdf", @"SFRequiredSignature" put them in separate arrays
    NSArray *requiredPdfArray = [self getAllRequiredPdf];
    NSArray *requiredSignatures = [self getAllRequiredSignature];
    
    if((requiredPdfArray == nil) || ([requiredPdfArray count] == 0))
        return;
    
    // send them to submitHTMLDocuments:(NSArray*)docs withSignatures:(NSArray*)signatures
    self.didSubmitHTML = -1;
    SMXMonitor *monitor = [[SMXMonitor alloc] init];
    [monitor monitorSMMessageWithName:@"[DataBase downloadPDFsForUploadedHtml:submit]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Start"
                         timeInterval:kWSExecutionDuration];

    [appDelegate.wsInterface submitHTMLDocuments:requiredPdfArray withSignatures:requiredSignatures];
    while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        if(self.didSubmitHTML != -1)
        {
            break;
        }
        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }
        
    }
    [monitor monitorSMMessageWithName:@"[DataBase downloadPDFsForUploadedHtml]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Stop"
                         timeInterval:kWSExecutionDuration];

    //defect : 8166
    if(self.didSubmitHTML <= 0) return;
    
    // In the response call generatePDFfor:(NSArray*)docs withSignatures:(NSArray*)signatures
    self.didGeneratePDF = -1;
    [monitor monitorSMMessageWithName:@"[DataBase downloadPDFsForUploadedHtml:generatePDF]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Start"
                         timeInterval:kWSExecutionDuration];
    //Get all non generated PDF;
    //RequiredPdf - Genrated Pdf
    NSMutableArray *filteredHtmlArray = [NSMutableArray array];
    NSMutableArray *duplicateIdArray = [NSMutableArray array];
    if ([self.requiredHtmlArray count] > 0) {
        
        for (NSString *reqHtmlId in self.requiredHtmlArray) {
            for (NSString *htmlID in requiredPdfArray) {
                
                if([reqHtmlId isEqualToString:htmlID]) {
                    //ids to be deleted locally
                    [duplicateIdArray addObject:htmlID];
                    
                }
                else {
                    //excluded ids from submit html response to be sent in generate pdf WS call
                    [filteredHtmlArray addObject:htmlID];
                }
            }
        }
        requiredPdfArray = filteredHtmlArray;
    }
    
    if ([self.requiredSignatureArray count] > 0) {
        //Back ward compatiiblity check, everything should work fine without server changes
        requiredSignatures = self.requiredSignatureArray;
    }
    else if(self.isResponseWithIds) {
        requiredSignatures = nil;
    }
    
    //Items needs to be deleted is depicted in this
    if(self.deletableRequiredPdfArray == nil) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        self.deletableRequiredPdfArray = arr;
        [arr release];
    }
    
    //deletable array
    if([duplicateIdArray count] > 0) {
    [self.deletableRequiredPdfArray addObjectsFromArray:duplicateIdArray];
    }
    
    //call Generate PDF with excluded array from submit document call
    [appDelegate.wsInterface generatePDFfor:requiredPdfArray withSignatures:requiredSignatures];
    while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        if(self.didGeneratePDF != -1)
        {
            break;
        }
        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }
        
    }
    [monitor monitorSMMessageWithName:@"[DataBase downloadPDFsForUploadedHtml:generatePDF]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Stop"
                         timeInterval:kWSExecutionDuration];

    //defect : 8166
    if(self.didGeneratePDF <= 0) return;
    
    // Remove signatures using att_id in SFRequiredSignatures
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *saveDirectory = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0];

    NSMutableArray *signaturesForDeletion = [self getAllRequiredSignatureNamesForDeletion];
    
    if ([self.requiredSignatureArray count] > 0 ) {
        //use signaturesFordeletion
        [self.signaturesNotInServer addObjectsFromArray:self.requiredSignatureArray];
        signaturesForDeletion = self.signaturesNotInServer;
    }
    else if(isResponseWithIds) {
        signaturesForDeletion = nil;
    }
    
    for (NSString *signId in signaturesForDeletion)
    {
        NSString *stringName = @"";
        if([self.requiredSignatureArray count] > 0) {
            //GetName for signature ID
            stringName = [self getRequiredSignatureForDeletionWithID:signId];
        }
        else {
            //back word compatiblity
            stringName = signId;
        }
        NSArray *itemsInDocDir = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:saveDirectory error:NULL];
        for (NSString *itm in itemsInDocDir)
        {
            if([Utility containsString:stringName inString:itm])
            {
                [[NSFileManager defaultManager] removeItemAtPath:[saveDirectory stringByAppendingPathComponent:itm] error:NULL];
                [self deleteRequiredSignatureFor:stringName];
            }
        }
    }
    if([self.requiredHtmlArray count] > 0) {
        [self.deletableRequiredPdfArray addObjectsFromArray:self.requiredHtmlArray];
    }
    else {
        //Backward compatiblity without server fix
        [self.deletableRequiredPdfArray addObjectsFromArray:requiredPdfArray];
    }
    // Once generate pdf returns success use zks calls to download pdf
    for (NSString *pdf_attchment_id in self.deletableRequiredPdfArray) {
        [self downloadPdfFor:pdf_attchment_id];
    }
}

- (void)downloadPdfFor:(NSString*)att_id
{
    didRcvAttachment = NO;
    NSString * _query = [NSString stringWithFormat:@"SELECT Name, Id FROM Attachment Where Id = '%@'", att_id]; /* Removed body from query as we dont need pdf now */
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetPDFAttachmentWithResult:error:context:) context:nil];
    SMXMonitor *monitor = [[SMXMonitor alloc] init];
    [monitor monitorSMMessageWithName:@"[DataBase downloadPdfFor]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Start"
                         timeInterval:kWSExecutionDuration];

    while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        if(didRcvAttachment)
        {
            break;
        }
        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }
        
    }
    [monitor monitorSMMessageWithName:@"[DataBase downloadPdfFor]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Stop"
                         timeInterval:kWSExecutionDuration];
    [monitor release];
    
}
// damodar OPDOCS
- (void) didGetPDFAttachmentWithResult:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    // Store the image in a appDelegate UIImage
    
    NSArray * array = [result records];
    
    if ([array count] > 0)
    {
        ZKSObject *obj = [array objectAtIndex:0];
        
        NSDictionary *dict = [obj fields];
        
//        NSString *bodyString = [dict objectForKey:@"Body"];/* Removed body  as we dont need pdf now */
        NSString * Id = [dict objectForKey:@"Id"];
        NSString *fileName = [dict objectForKey:@"Name"];
        
        if (fileName != nil && [fileName length] > 0)
        {
//            NSData * bodyData = [Base64 decode:bodyString];/* Removed body  as we dont need pdf now */
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *saveDirectory = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0];
            
            NSString *filePath = [saveDirectory stringByAppendingPathComponent:fileName];
            
            //             NSString *pathExtension = [filePath pathExtension];
            //             NSString *newFileName = [[[filePath stringByDeletingPathExtension] stringByAppendingFormat:@"_",Id] stringByAppendingPathExtension:pathExtension];
            NSString *newFileName = filePath;
            
            NSFileManager * fileManager = [NSFileManager defaultManager];
            
            if(![[newFileName pathExtension] isEqualToString:@"pdf"])
                newFileName = [[newFileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"pdf"];
            
//            [fileManager createFileAtPath:newFileName contents:bodyData attributes:nil];/* Removed body  as we dont need pdf now */
            
            
            
            // For each pdf downloaded remove the corresponding html from documents directory
            NSString *htmlFileName = [[newFileName lastPathComponent] stringByDeletingPathExtension];
            NSArray *itemsInDocDir = [fileManager contentsOfDirectoryAtPath:saveDirectory error:NULL];
            for (NSString *itm in itemsInDocDir)
            {
                if([Utility containsString:htmlFileName inString:itm] && (![[itm pathExtension] isEqualToString:@"pdf"]))
                {
                    [fileManager removeItemAtPath:[saveDirectory stringByAppendingPathComponent:itm] error:NULL];
                }
            }
            
            // Delete
            NSString *htmlFileNameExt = [[newFileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"html"];
            [fileManager removeItemAtPath:htmlFileNameExt error:NULL];
            
            // Delete the IDs from @"SFRequiredPdf" and html+signature images from documents directory
            [self deleteRequiredPdfForAttachement:Id];
            
            // Delete signature ids whose signid starts with processId_recordId
           // [self deleteRequiredSignatureFor:htmlFileName];
            
        }
        
    }
    didRcvAttachment = YES;
}

//krishna OPDOCS
- (void)insertIntoDocTemplate:(NSDictionary*)process_dict
{
    //defect:7609 krishna
    //added id as primary key
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  '%@' ('doc_template_name' text(100), Id text(18) PRIMARY KEY  NOT NULL ,doc_template_id text(40) , is_standard BOOLEAN , detail_object_count  INTEGER, media_resources TEXT)",SFDOC_TEMPLATE]];
    if (result)
    {
        [appDelegate.dataBase beginTransaction];
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@','%@', '%@') VALUES (?1, ?2,   ?3, ?4, ?5, ?6)", SFDOC_TEMPLATE,doc_template_name, DOC_Id,doc_template_id,Doc_is_standard,DOC_detail_object_count,MEDIA_RESOURCES];
        
        sqlite3_stmt * bulkStmt;
        
        NSArray * SF_DOC_template = [process_dict objectForKey:SFDOC_TEMPLATE];
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        if (ret_value == SQLITE_OK)
        {
            for(int i = 0;i<[SF_DOC_template count];i++)
            {
                NSDictionary * each_doc_record = [SF_DOC_template objectAtIndex:i];
                
                char * _doc_template_name = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:doc_template_name] != nil)?[each_doc_record objectForKey:doc_template_name]:@""];
                
                sqlite3_bind_text(bulkStmt, 1, _doc_template_name, strlen(_doc_template_name), SQLITE_TRANSIENT);
				
                char * _DOC_Id = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:DOC_Id] != nil)?[each_doc_record objectForKey:DOC_Id]:@""];
                
                sqlite3_bind_text(bulkStmt, 2, _DOC_Id, strlen(_DOC_Id), SQLITE_TRANSIENT);
                
                
                char * _doc_template_id = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:doc_template_id] != nil)?[each_doc_record objectForKey:doc_template_id]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _doc_template_id, strlen(_doc_template_id), SQLITE_TRANSIENT);
                
                char * _Doc_is_standard = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:Doc_is_standard] != nil)?[each_doc_record objectForKey:Doc_is_standard]:@""];
                
                sqlite3_bind_text(bulkStmt, 4, _Doc_is_standard, strlen(_Doc_is_standard), SQLITE_TRANSIENT);
                
                int   _DOC_detail_object_count = (int)[each_doc_record objectForKey:DOC_detail_object_count];
                
                sqlite3_bind_int(bulkStmt, 5, _DOC_detail_object_count);
                
                char * _media_resources = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:MEDIA_RESOURCES] != nil)?[each_doc_record objectForKey:MEDIA_RESOURCES]:@""];
                
                sqlite3_bind_text(bulkStmt, 6, _media_resources, strlen(_media_resources), SQLITE_TRANSIENT);
                
                if ( synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed  : insertIntoDocTemplate!\n");
                }
                
                sqlite3_reset(bulkStmt);
                
            }
            
        }
        synchronized_sqlite3_finalize(bulkStmt);
        [appDelegate.dataBase endTransaction];
    }
}
//krishna OPDOCS
- (void)insertIntoDocTemplateDetails:(NSDictionary*)process_dict
{
    //defect:7609 krishna
    //added id as primary key
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (doc_template VARCHAR ,doc_template_detail_id Text(255),header_ref_fld  Text(100)  ,alias Text(80), object_name Text(100) ,soql Text(32768) , doc_template_detail_unique_id  Text(40), fields Text(32768),type VARCHAR, Id VARCHAR PRIMARY KEY  NOT NULL)",SFDOC_TEMPLATE_DETAILS]];
    if(result)
    {
        [appDelegate.dataBase beginTransaction];
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@','%@','%@', '%@','%@','%@', '%@') VALUES (?1,?2,?3,?4,?5,?6,?7,?8,?9,?10)",SFDOC_TEMPLATE_DETAILS,doc_template,doc_template_detail_id, doc_header_ref_fld, DOC_alias,DOC_object_name,DOC_soql,doc_template_detail_unique_id,DOC_fields,DOC_type,DOC_Id];
        
        sqlite3_stmt * bulkStmt;
        
        NSArray * SF_DOC_template_details = [process_dict objectForKey:SFDOC_TEMPLATE_DETAILS];
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        if (ret_value == SQLITE_OK) {
            
            for(int i = 0;i<[SF_DOC_template_details count];i++)
            {
                NSDictionary *each_doc_record = [SF_DOC_template_details objectAtIndex:i];
                
                char * _doc_template = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:doc_template] != nil)?[each_doc_record objectForKey:doc_template]:@""];
                
                sqlite3_bind_text(bulkStmt, 1, _doc_template, strlen(_doc_template), SQLITE_TRANSIENT);
                
                char * _doc_template_detail_id = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:doc_template_detail_id] != nil)?[each_doc_record objectForKey:doc_template]:@""];
                
                sqlite3_bind_text(bulkStmt, 2, _doc_template_detail_id, strlen(_doc_template_detail_id), SQLITE_TRANSIENT);
                
                char * _doc_header_ref_fld = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:doc_header_ref_fld] != nil)?[each_doc_record objectForKey:doc_header_ref_fld]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _doc_header_ref_fld, strlen(_doc_header_ref_fld), SQLITE_TRANSIENT);
                
                char * _DOC_alias = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:DOC_alias] != nil)?[each_doc_record objectForKey:DOC_alias]:@""];
                
                sqlite3_bind_text(bulkStmt, 4, _DOC_alias, strlen(_DOC_alias), SQLITE_TRANSIENT);
                
                char * _DOC_object_name = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:DOC_object_name] != nil)?[each_doc_record objectForKey:DOC_object_name]:@""];
                
                sqlite3_bind_text(bulkStmt, 5, _DOC_object_name, strlen(_DOC_object_name), SQLITE_TRANSIENT);
                
                char * _DOC_soql = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:DOC_soql] != nil)?[each_doc_record objectForKey:DOC_soql]:@""];
                
                sqlite3_bind_text(bulkStmt, 6, _DOC_soql, strlen(_DOC_soql), SQLITE_TRANSIENT);
                
                char * _doc_template_detail_unique_id = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:doc_template_detail_unique_id] != nil)?[each_doc_record objectForKey:doc_template_detail_unique_id]:@""];
                
                sqlite3_bind_text(bulkStmt, 7, _doc_template_detail_unique_id, strlen(_doc_template_detail_unique_id), SQLITE_TRANSIENT);
                
                char * _DOC_fields = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:DOC_fields] != nil)?[each_doc_record objectForKey:DOC_fields]:@""];
                
                sqlite3_bind_text(bulkStmt, 8, _DOC_fields, strlen(_DOC_fields), SQLITE_TRANSIENT);
                
                char * _DOC_type = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:DOC_type] != nil)?[each_doc_record objectForKey:DOC_type]:@""];
                
                sqlite3_bind_text(bulkStmt, 9, _DOC_type, strlen(_DOC_type), SQLITE_TRANSIENT);
                
                char * _DOC_Id = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:DOC_Id] != nil)?[each_doc_record objectForKey:DOC_Id]:@""];
                
                sqlite3_bind_text(bulkStmt, 10, _DOC_Id, strlen(_DOC_Id), SQLITE_TRANSIENT);
                
                
                if ( synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed! insertIntoDocTemplateDetails\n");
                }
                sqlite3_reset(bulkStmt);
                
            }
            
        }
        synchronized_sqlite3_finalize(bulkStmt);
        [appDelegate.dataBase endTransaction];
    }
}
//Krishna OPDOCS requiredPdf
- (void) insertIntoRequiredPdf:(NSString *)recordId processId:(NSString *)processId andAttachmentId:(NSString *)attachmentId {
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('process_id' TEXT, 'record_id' TEXT, 'attachment_id' TEXT)",SFDOC_REQUIRED_PDF]];
    if (result)
    {
        [appDelegate.dataBase beginTransaction];
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('process_id', 'record_id', 'attachment_id') VALUES (?1, ?2, ?3)", SFDOC_REQUIRED_PDF];
        
        sqlite3_stmt * bulkStmt;
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        if (ret_value == SQLITE_OK)
        {
            
            char * _process_id = [appDelegate convertStringIntoChar:(processId != nil)?processId:@""];
            
            sqlite3_bind_text(bulkStmt, 1, _process_id, strlen(_process_id), SQLITE_TRANSIENT);
            
            char * _record_id = [appDelegate convertStringIntoChar:(recordId != nil)?recordId:@""];
            
            sqlite3_bind_text(bulkStmt, 2, _record_id, strlen(_record_id), SQLITE_TRANSIENT);

            
            char * _attachment_id = [appDelegate convertStringIntoChar:(attachmentId != nil)?attachmentId:@""];
            
            sqlite3_bind_text(bulkStmt, 3, _attachment_id, strlen(_attachment_id), SQLITE_TRANSIENT);
            int val =synchronized_sqlite3_step(bulkStmt);
            
            if ( val  != SQLITE_DONE)
            {
                SMLog(kLogLevelError,@"Commit Failed : insertIntoRequiredPdf!\n");
            }
            sqlite3_reset(bulkStmt);
            
        }
        synchronized_sqlite3_finalize(bulkStmt);
        [appDelegate.dataBase endTransaction];
    }
}

//Aparna: Source Update
#pragma mark -
#pragma mark Source Update
- (NSString *)evaluateLiteral:(NSString *)literal forControlType:(NSString *)controlType
{
    NSString *evaluatedLiteral = nil;
    if ([controlType isEqualToString:@"date"] || [controlType isEqualToString:@"datetime"])
    {
        BOOL isDateOnly = NO;
        if ([controlType isEqualToString:@"date"])
        {
            isDateOnly = YES;
        }
        if([literal caseInsensitiveCompare:MACRO_NOW]== NSOrderedSame)
        {
            evaluatedLiteral = [Utility today:0 andJusDate:isDateOnly];
        }
        else if([literal caseInsensitiveCompare:MACRO_TODAY]== NSOrderedSame)
        {
            evaluatedLiteral = [Utility today:0 andJusDate:YES];
        }
        else if([literal caseInsensitiveCompare:MACRO_TOMMOROW]== NSOrderedSame)
        {
            evaluatedLiteral = [Utility today:1 andJusDate:YES];
        }
        else if([literal caseInsensitiveCompare:MACRO_YESTERDAY]== NSOrderedSame)
        {
            evaluatedLiteral = [Utility today:-1 andJusDate:YES];
        }
        //9122 : date was showing up in wrong format when date time is populated in date field.
        //fix : if date time, convert it to only date and populate
        if ([controlType isEqualToString:@"date"]) {
            if ([evaluatedLiteral length] >= 10 ) {
                evaluatedLiteral = [evaluatedLiteral substringToIndex:10];
            }
        }
    }
    else if([controlType isEqualToString:@"boolean"]) //Fix for defect 8638:  Target object update with boolean value is not working in iPad for output docs
    {
        //defect : Shubha 11634
        if(([literal caseInsensitiveCompare:@"true"]== NSOrderedSame) || ([literal caseInsensitiveCompare:@"1"]== NSOrderedSame) || ([literal caseInsensitiveCompare:@"yes"]== NSOrderedSame))
            evaluatedLiteral = @"1";
        else
            evaluatedLiteral = @"0";
    }//End fix for defect 8638
    else
    {
        if(([literal caseInsensitiveCompare:SVMX_CURRENTUSER]== NSOrderedSame) || ([literal caseInsensitiveCompare:SVMX_OWNER]== NSOrderedSame))
        {
            evaluatedLiteral = [appDelegate.databaseInterface getUserNameofLoggedInUser];
        }
        else if(([literal caseInsensitiveCompare:CURRENTRECORD]== NSOrderedSame) || ([literal caseInsensitiveCompare:CURRENTRECORD_HEADER] == NSOrderedSame))//4850
        {
            evaluatedLiteral = [appDelegate.databaseInterface getLiteralValue:literal];
        }
        else if([literal caseInsensitiveCompare:SVMX_USER_TRUNK] == NSOrderedSame)
        {
            evaluatedLiteral = [appDelegate.dataBase getTechnicianLocation];
        }
    }
    return evaluatedLiteral;
}

- (NSString *)processIdForSfId:(NSString *)sfId
{
    NSString *processId = nil;
    sqlite3_stmt * stmt;
    
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT process_id From SFProcess WHERE sfID = '%@'",sfId];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            const char * _type = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if (strlen(_type))
                processId = [NSString stringWithUTF8String:_type];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return processId;
}


- (NSString *)sfIdForProcessId:(NSString *)processId
{
    NSString *sfId = nil;
    sqlite3_stmt * stmt;
    
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT sfID From SFProcess WHERE process_id = '%@'",processId];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            const char * _type = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if (strlen(_type))
                sfId = [NSString stringWithUTF8String:_type];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return sfId;
}

- (NSString *)sourceObjectNameForProcessId:(NSString *)processId
{
    NSString *sourceObjName = nil;
    sqlite3_stmt * stmt;
    
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT source_object_name From SFProcessComponent WHERE process_id = '%@' AND component_type = 'TARGET'",processId];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            const char * _type = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if (strlen(_type))
                sourceObjName = [NSString stringWithUTF8String:_type];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return sourceObjName;
}

- (NSString *)targetObjectNameForSettingId:(NSString *)settingId
{
    NSString *targetObjName = nil;
    sqlite3_stmt * stmt;
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT target_object_name From SFProcessComponent WHERE process_node_id = '%@'",settingId];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            const char * _type = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if (strlen(_type))
                targetObjName = [NSString stringWithUTF8String:_type];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    
    return targetObjName;
}


- (void)insertIntoSourceUpdateTable:(NSDictionary *)processDictionary
{
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' text(18), '%@' VARCHAR, '%@' VARCHAR, '%@' VARCHAR, '%@' VARCHAR, '%@' VARCHAR, '%@' VARCHAR, '%@' VARCHAR, '%@' VARCHAR, '%@' VARCHAR)",SOURCE_UPDATE,SOURCE_UPDATE_ID,SOURCE_UPDATE_ACTION,SOURCE_UPDATE_CONFIGURATION_TYPE,SOURCE_UPDATE_DISPLAY_VALUE,SOURCE_UPDATE_PROCESS,SOURCE_UPDATE_SETTING_ID,SOURCE_UPDATE_SOURCE_FIELD_NAME,SOURCE_UPDATE_TARGET_FIELD_NAME,SOURCE_UPDATE_SOURCE_OBJECT_NAME, SOURCE_UPDATE_TARGET_OBJECT_NAME]];
    if (result)
    {
        [appDelegate.dataBase beginTransaction];
            
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@','%@', '%@', '%@', '%@', '%@', %@) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10)",SOURCE_UPDATE, SOURCE_UPDATE_ID,SOURCE_UPDATE_ACTION,SOURCE_UPDATE_CONFIGURATION_TYPE,SOURCE_UPDATE_DISPLAY_VALUE,SOURCE_UPDATE_PROCESS,SOURCE_UPDATE_SETTING_ID,SOURCE_UPDATE_SOURCE_FIELD_NAME,SOURCE_UPDATE_TARGET_FIELD_NAME, SOURCE_UPDATE_SOURCE_OBJECT_NAME,SOURCE_UPDATE_TARGET_OBJECT_NAME];
            
        sqlite3_stmt * bulkStmt;
        NSArray * sourceUpdateArray = [processDictionary objectForKey:SOURCE_UPDATE];
            
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        if (ret_value == SQLITE_OK)
        {
            for(NSDictionary *sourceUpdateDict in sourceUpdateArray)
            {
                NSString *processId = [self processIdForSfId:[sourceUpdateDict valueForKey:SOURCE_UPDATE_PROCESS]];
                
                //4850
                //Shravya- Get source object name and target object name by process Id and setting id and insert to the table.
                NSString *processNodeId = [sourceUpdateDict objectForKey:SOURCE_UPDATE_SETTING_ID];
                NSString *sourceNodeId = @"";
                NSString *compType =  [self getComponentType:processNodeId];
                NSDictionary *srcTarDict = nil;
                if ([compType isEqualToString:@"TARGET"]) {
                    sourceNodeId = [self getSourceNodeNameForProcessId:processId];
                    if (![Utility isStringEmpty:sourceNodeId]) {
                        srcTarDict = [self sourceObjectNameForSettingId:sourceNodeId];
                    }
                    else{
                        srcTarDict = [self sourceObjectNameForSettingId:processNodeId];
                    }
                    
                }
                else{
                    srcTarDict = [self sourceObjectNameForSettingId:processNodeId];
                }
                
                NSString *sourceObjectName =  [srcTarDict objectForKey:@"source"];
                NSString *targetObjectName = [srcTarDict objectForKey:@"target"];
                
//                NSString *sourceObjectName = [self sourceObjectNameForProcessId:processId];
//                
//                //For OP docs target update feature target object name is not required. Hence we are not handling it now.
//                //Shravya-ST_UPDATE
//                NSString *targetObjectName = nil;
                char * sourceUpdateId = [appDelegate convertStringIntoChar:([sourceUpdateDict objectForKey:SOURCE_UPDATE_ID] != nil)?[sourceUpdateDict objectForKey:SOURCE_UPDATE_ID]:@""];
                sqlite3_bind_text(bulkStmt, 1, sourceUpdateId, strlen(sourceUpdateId), SQLITE_TRANSIENT);
                
                char * action = [appDelegate convertStringIntoChar:([sourceUpdateDict objectForKey:SOURCE_UPDATE_ACTION] != nil)?[sourceUpdateDict objectForKey:SOURCE_UPDATE_ACTION]:@""];
                sqlite3_bind_text(bulkStmt, 2, action, strlen(action), SQLITE_TRANSIENT);
                
                char * configType = [appDelegate convertStringIntoChar:([sourceUpdateDict objectForKey:SOURCE_UPDATE_CONFIGURATION_TYPE] != nil)?[sourceUpdateDict objectForKey:SOURCE_UPDATE_CONFIGURATION_TYPE]:@""];
                sqlite3_bind_text(bulkStmt, 3, configType, strlen(configType), SQLITE_TRANSIENT);
                
                
                char * displayValue = [appDelegate convertStringIntoChar:([sourceUpdateDict objectForKey:SOURCE_UPDATE_DISPLAY_VALUE] != nil)?[sourceUpdateDict objectForKey:SOURCE_UPDATE_DISPLAY_VALUE]:@""];
                sqlite3_bind_text(bulkStmt, 4, displayValue, strlen(displayValue), SQLITE_TRANSIENT);
                
                char * process = [appDelegate convertStringIntoChar:([sourceUpdateDict objectForKey:SOURCE_UPDATE_PROCESS] != nil)?[sourceUpdateDict objectForKey:SOURCE_UPDATE_PROCESS]:@""];
                sqlite3_bind_text(bulkStmt, 5, process, strlen(process), SQLITE_TRANSIENT);
                
                char * settingId = [appDelegate convertStringIntoChar:([sourceUpdateDict objectForKey:SOURCE_UPDATE_SETTING_ID] != nil)?[sourceUpdateDict objectForKey:SOURCE_UPDATE_SETTING_ID]:@""];
                sqlite3_bind_text(bulkStmt, 6, settingId, strlen(settingId), SQLITE_TRANSIENT);

                char * sourceFieldName = [appDelegate convertStringIntoChar:([sourceUpdateDict objectForKey:SOURCE_UPDATE_SOURCE_FIELD_NAME] != nil)?[sourceUpdateDict objectForKey:SOURCE_UPDATE_SOURCE_FIELD_NAME]:@""];
                sqlite3_bind_text(bulkStmt, 7, sourceFieldName, strlen(sourceFieldName), SQLITE_TRANSIENT);

                char * targetFieldtName = [appDelegate convertStringIntoChar:([sourceUpdateDict objectForKey:SOURCE_UPDATE_TARGET_FIELD_NAME] != nil)?[sourceUpdateDict objectForKey:SOURCE_UPDATE_TARGET_FIELD_NAME]:@""];
                sqlite3_bind_text(bulkStmt, 8, targetFieldtName, strlen(targetFieldtName), SQLITE_TRANSIENT);

                char * sourceObjName = [appDelegate convertStringIntoChar:sourceObjectName];
                sqlite3_bind_text(bulkStmt, 9, sourceObjName, strlen(sourceObjName), SQLITE_TRANSIENT);
                
                char * targetObjName = [appDelegate convertStringIntoChar:targetObjectName];
                sqlite3_bind_text(bulkStmt, 10, targetObjName, strlen(targetObjName), SQLITE_TRANSIENT);
                
                if ( synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed  : insertIntoDocTemplate!\n");
                }
                sqlite3_reset(bulkStmt);
            }
        }
        synchronized_sqlite3_finalize(bulkStmt);
        [appDelegate.dataBase endTransaction];
    }
}


- (NSArray *)sourceUpdatesForProcessId:(NSString *)processId
{
    NSMutableArray *sourceUpdatesArray = [[NSMutableArray alloc] init];
    sqlite3_stmt * stmt;
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT %@ , %@, %@, %@, %@ From %@ WHERE %@ = '%@'",SOURCE_UPDATE_ACTION, SOURCE_UPDATE_DISPLAY_VALUE, SOURCE_UPDATE_SOURCE_FIELD_NAME, SOURCE_UPDATE_TARGET_FIELD_NAME, SOURCE_UPDATE_SOURCE_OBJECT_NAME, SOURCE_UPDATE, SOURCE_UPDATE_PROCESS,processId];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            NSMutableDictionary *sourceUpdateDict = [[NSMutableDictionary alloc] init];
            char * action= (char *) synchronized_sqlite3_column_text(stmt, 0);
            if ((action != nil) && strlen(action))
            {
                NSString *actionObj = [NSString stringWithUTF8String:action];
                [sourceUpdateDict setValue:actionObj forKey:SOURCE_UPDATE_ACTION];
            }
            
            char * displayValue= (char *) synchronized_sqlite3_column_text(stmt, 1);
            if ((displayValue != nil) && strlen(displayValue))
            {
                NSString *displayValueObj = [NSString stringWithUTF8String:displayValue];
                [sourceUpdateDict setValue:displayValueObj forKey:SOURCE_UPDATE_DISPLAY_VALUE];
            }
            
            char * sourceFieldName = (char *) synchronized_sqlite3_column_text(stmt, 2);
            if ((sourceFieldName != nil) && strlen(sourceFieldName))
            {
                NSString *sourceFieldNameObj = [NSString stringWithUTF8String:sourceFieldName];
                [sourceUpdateDict setValue:sourceFieldNameObj forKey:SOURCE_UPDATE_SOURCE_FIELD_NAME];
            }
            
            char * targetFieldName = (char *) synchronized_sqlite3_column_text(stmt, 3);
            if ((targetFieldName != nil) && strlen(targetFieldName))
            {
                NSString *targetFieldNameObj = [NSString stringWithUTF8String:targetFieldName];
                [sourceUpdateDict setValue:targetFieldNameObj forKey:SOURCE_UPDATE_TARGET_FIELD_NAME];
            }
            
            char * sourceObjectName = (char *) synchronized_sqlite3_column_text(stmt, 4);
            if ((sourceObjectName != nil) && strlen(sourceObjectName))
            {
                NSString *sourceObjectNameObj = [NSString stringWithUTF8String:sourceObjectName];
                [sourceUpdateDict setValue:sourceObjectNameObj forKey:SOURCE_UPDATE_SOURCE_OBJECT_NAME];
            }
            [sourceUpdatesArray addObject:sourceUpdateDict];
            [sourceUpdateDict release];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return [sourceUpdatesArray autorelease];
}

- (void) updateSourceObjects:(NSArray *)sourceObjects forSFId:(NSString *)sfId andLocalId:(NSString *)inLocalID
{
    
    //First get the local id for recordId (in OP Doc recordId = sfId)
    
    NSString * sourceObjName = [[appDelegate.SFMPage objectForKey:gHEADER] objectForKey:gHEADER_OBJECT_NAME];
    NSString *localId;
    
    //9007 data sync goes in loop
    if([inLocalID isEqualToString:@""] || inLocalID == nil)
    {
        localId = [appDelegate.databaseInterface getLocalIdFromSFId:sfId tableName:sourceObjName];
    }
    else
    {
        localId = inLocalID;
    }

    
    
    
    for (NSDictionary *sourceUpdateDict in sourceObjects)
    {
        NSString *sourceObjName = [sourceUpdateDict valueForKey:SOURCE_UPDATE_SOURCE_OBJECT_NAME];
        NSString *action = [sourceUpdateDict valueForKey:SOURCE_UPDATE_ACTION];
        NSString *displayValue = [sourceUpdateDict valueForKey:SOURCE_UPDATE_DISPLAY_VALUE];
        NSString *fieldName = [sourceUpdateDict valueForKey:SOURCE_UPDATE_SOURCE_FIELD_NAME];
        
        NSString *newDisplayValue = nil;//[appDelegate.databaseInterface getValueForField:fieldName objectName:sourceObjName recordId:localId];

        if ([action isEqualToString:@"Set"])
        {
            NSString * data_type = [[appDelegate.databaseInterface getFieldDataType:sourceObjName filedName:fieldName] lowercaseString];

            newDisplayValue = [self evaluateLiteral:displayValue forControlType:data_type];
            if (nil == newDisplayValue)
            {
                newDisplayValue = [NSString stringWithString:displayValue];
            }
            
        }
        else if([action isEqualToString:@"Increase"])
        {
            newDisplayValue = [appDelegate.databaseInterface getValueForField:fieldName objectName:sourceObjName recordId:localId];
            float newValue = [newDisplayValue floatValue]+[displayValue floatValue];
            newDisplayValue = [NSString stringWithFormat:@"%f",newValue];
        }
        else if([action isEqualToString:@"Decrease"])
        {
            newDisplayValue = [appDelegate.databaseInterface getValueForField:fieldName objectName:sourceObjName recordId:localId];
            float newValue = [newDisplayValue floatValue]-[displayValue floatValue];
            newDisplayValue = [NSString stringWithFormat:@"%f",newValue];
        }
        //8791 escaping character for target object update.
        
        NSString *escapedValue = [newDisplayValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
       NSString *queryStatement =[NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE local_id = '%@'",sourceObjName,fieldName, escapedValue,localId];
        char *err;
        int ret = synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err);
        
        if (ret != SQLITE_OK)
        {
            SMLog(kLogLevelError,@"%@", queryStatement);
            SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
                [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:queryStatement type:INSERTQUERY];
        }
    
    }
    //9007: In CREATE, SFID is not available and if we try to UPDATE such a record, then sync goes into infinte loop. We avoid such
    // a scenario here
    if ([sfId length]>0) {
        BOOL does_exists = [appDelegate.databaseInterface DoesTrailerContainTheRecord:localId operation_type:UPDATE object_name:sourceObjName];
        if(!does_exists)
        {
            //Add the data to SFDataTrailer table to make sure that the record is sent for sync during next data sync
            [appDelegate.databaseInterface insertdataIntoTrailerTableForRecord:localId SF_id:sfId record_type:MASTER operation:UPDATE object_name:sourceObjName sync_flag:@"false" parentObjectName:@"" parent_loacl_id:localId webserviceName:@"" className:@"" synctype:AGRESSIVESYNC headerLocalId:localId requestData:nil finalEntry:false];
        }
    }
}

#pragma mark -
#pragma mark Output Doc

//Krishna defect 7713
- (NSString *) getProcessNameForProcesId:(NSString *)processId {
    
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT process_name FROM SFProcess WHERE process_id = '%@'", processId];
    sqlite3_stmt * statement;
    NSString * processName = @"";
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            const char * _type = (char *)synchronized_sqlite3_column_text(statement, 0);
            if (strlen(_type))
                processName = [NSString stringWithUTF8String:_type];
        }
    }
    synchronized_sqlite3_finalize(statement);
    return processName;
}


//Krishna OPDOCS requiredPdf
// Modified - Kri OPDOC-CR
- (NSMutableArray *) getAllRequiredPdf {
    
    sqlite3_stmt * stmt;
    NSString *attachmentId = @"";
    
    NSMutableArray *requiredPdfArray = [NSMutableArray array];
    
    NSString *selectQuery2 = [NSString stringWithFormat:@"SELECT attachment_id From %@",SFDOC_REQUIRED_PDF];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery2 UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        //kri OPDOC2
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            
            char *field2 = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if ( field2 != nil ) {
                attachmentId = [NSString stringWithUTF8String:field2];
                [requiredPdfArray addObject:attachmentId];
            }
            //kri OPDOC2
            attachmentId = @"";
        }
    }
    //kri OPDOC2
    synchronized_sqlite3_finalize(stmt);

    return requiredPdfArray;
    
}
//Krishna OPDOCS requiredPdf
- (void)deleteRequiredPdfForAttachement:(NSString *)attachementId {
    
    NSString * query = [NSString stringWithFormat:@"DELETE FROM %@ where attachment_id = '%@'", SFDOC_REQUIRED_PDF,attachementId];
	
    char * err;
	
	if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
	{
		SMLog(kLogLevelError,@"Failed to delete");
        SMLog(kLogLevelError,@"METHOD:deleteEventNotRelatedToLoggedInUser");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        //[appDelegate printIfError:nil ForQuery:query type:DELETEQUERY];
	}
    
}
//Krishna OPDOCS requiredPdf
//  Unused methods
//- (void)deleteRequiredPdfRecord:(NSString *)recordId forProcessId:(NSString *)processId {
//    
//    NSString * query = [NSString stringWithFormat:@"DELETE FROM %@ where process_id = '%@' AND record_id = '%@'", SFDOC_REQUIRED_PDF,processId, recordId];
//	
//    char * err;
//	
//	if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
//	{
//		SMLog(kLogLevelVerbose,@"Failed to delete");
//        SMLog(kLogLevelVerbose,@"METHOD:deleteEventNotRelatedToLoggedInUser");
//		SMLog(kLogLevelVerbose,@"ERROR IN DELETE %s", err);
//        //[appDelegate printIfError:nil ForQuery:query type:DELETEQUERY];
//	}
//    
//}
//Krishna OPDOCS requiredSignature
- (void) insertIntoRequiredSignature:(NSString *)attachmentId andSignatureId:(NSString*)signId {
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('sign_id' TEXT,'signature_id' TEXT)", SFDOC_REQUIRED_SIGNATURE]];
    if (result)
    {
        [appDelegate.dataBase beginTransaction];
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('sign_id','signature_id') VALUES (?1,?2)", SFDOC_REQUIRED_SIGNATURE];
        
        sqlite3_stmt * bulkStmt;
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        if (ret_value == SQLITE_OK)
        {
            char * _sign_id = [appDelegate convertStringIntoChar:(signId != nil)?signId:@""];
            
            sqlite3_bind_text(bulkStmt, 1, _sign_id, strlen(_sign_id), SQLITE_TRANSIENT);
            
            char * _signature_id = [appDelegate convertStringIntoChar:(attachmentId != nil)?attachmentId:@""];
            
            sqlite3_bind_text(bulkStmt, 2, _signature_id, strlen(_signature_id), SQLITE_TRANSIENT);
            
            int val =synchronized_sqlite3_step(bulkStmt);
            
            if ( val  != SQLITE_DONE)
            {
                SMLog(kLogLevelError,@"Commit Failed! insertIntoRequiredSignature\n");
            }
            sqlite3_reset(bulkStmt);
            
        }
        synchronized_sqlite3_finalize(bulkStmt);
        [appDelegate.dataBase endTransaction];
    }
    
}
// Dam - signature sum'13
- (NSArray *)getAllSignatureNames
{
    sqlite3_stmt * stmt;
    
    NSString *filename = @"";
    
    NSMutableArray *signatureNameArray = [NSMutableArray array];
    
    NSString *selectQuery2 = [NSString stringWithFormat:@"SELECT signature_name From SFSignatureData"];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery2 UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        //kri OPDOC2
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char *field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            //kri OPDOC2
            if ( field != nil ) {
                filename = [NSString stringWithUTF8String:field];
                [signatureNameArray addObject:filename];
            }
        }
    }
    //kri OPDOC2
    synchronized_sqlite3_finalize(stmt);
    return signatureNameArray;

}
// Dam - signature sum'13
- (void)removeSignatureNameFromFinalizedPlist:(NSString*)signName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0];
    NSString *filePath = [documentsDir stringByAppendingPathComponent:@"finalize.plist"];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSMutableArray *plistNames = [NSMutableArray array];
    if([fileManager fileExistsAtPath:filePath])
    {
        plistNames = [NSMutableArray arrayWithContentsOfFile:filePath];
        
        for (int i = 0; i < [plistNames count]; i++)
        {
            NSString *plistFile = [plistNames objectAtIndex:i];
            if([plistFile isEqualToString:signName])
            {
                [plistNames removeObjectAtIndex:i];
                [plistNames writeToFile:filePath atomically:NO];
            }
        }
    }
    else
    {
        return;
    }

}

- (void)finalizeSignatures
{
    NSArray *filenames = [self getAllSignatureNames];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0];
    NSString *filePath = [documentsDir stringByAppendingPathComponent:@"finalize.plist"];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSMutableArray *plistNames = [NSMutableArray array];
    if([fileManager fileExistsAtPath:filePath])
    {
        plistNames = [NSMutableArray arrayWithContentsOfFile:filePath];
    }

    for (NSString *file in filenames)
    {
        BOOL fileFound = NO;
        for (NSString *plistFile in plistNames) {
            if([plistFile isEqualToString:[file stringByAppendingPathExtension:@"png"]])
            {
                fileFound = YES;
                break;
            }
        }
        if(!fileFound)
        {
            [plistNames addObject:[file stringByAppendingPathExtension:@"png"]];
        }
    }
    
    [plistNames writeToFile:filePath atomically:NO];
}
// Dam - signature sum'13
- (BOOL)isSignatureFinalized:(NSString*)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0];
    NSString *filePath = [documentsDir stringByAppendingPathComponent:@"finalize.plist"];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSMutableArray *plistNames = [NSMutableArray array];
    if(![fileManager fileExistsAtPath:filePath])
    {
        return NO;
    }
    else
    {
        plistNames = [NSMutableArray arrayWithContentsOfFile:filePath];
    }
    
    BOOL fileFound = NO;
    for (NSString *plistFile in plistNames) {
        if([plistFile isEqualToString:fileName])
        {
            fileFound = YES;
            break;
        }
    }

    return fileFound;
}

//Krishna OPDOCS requiredSignature

- (NSString *) getRequiredSignatureForDeletionWithID:(NSString *)signatureId {
    
    sqlite3_stmt * stmt;
    
    NSString *filename = @"";
    NSString *selectQuery2 = @"";
    if([signatureId length] > 0) {
     selectQuery2 = [NSString stringWithFormat:@"SELECT sign_id From %@ Where signature_id = '%@'",SFDOC_REQUIRED_SIGNATURE, signatureId];
    }
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery2 UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        //kri OPDOC2
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char *field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            //kri OPDOC2
            if ( field != nil ) {
                filename = [NSString stringWithUTF8String:field];
            }
        }
    }
    //kri OPDOC2
    synchronized_sqlite3_finalize(stmt);
    return filename;
    
}
- (NSMutableArray *) getAllRequiredSignatureNamesForDeletion {
    
    sqlite3_stmt * stmt;
    
    NSString *filename = @"";
    
    NSMutableArray *requiredSignatureArray = [NSMutableArray array];
    
    NSString *selectQuery2 = [NSString stringWithFormat:@"SELECT sign_id From %@",SFDOC_REQUIRED_SIGNATURE];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery2 UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        //kri OPDOC2
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char *field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            //kri OPDOC2
            if ( field != nil ) {
                filename = [NSString stringWithUTF8String:field];
                [requiredSignatureArray addObject:filename];
            }
        }
    }
    //kri OPDOC2
    synchronized_sqlite3_finalize(stmt);
    return requiredSignatureArray;
    
}

- (NSMutableArray *) getAllRequiredSignature {
    
    sqlite3_stmt * stmt;
    
    NSString *attachmentId = @"";
    
    NSMutableArray *requiredSignatureArray = [NSMutableArray array];
    
    NSString *selectQuery2 = [NSString stringWithFormat:@"SELECT signature_id From %@",SFDOC_REQUIRED_SIGNATURE];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery2 UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        //kri OPDOC2
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char *field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            //kri OPDOC2
            if ( field != nil ) {
                attachmentId = [NSString stringWithUTF8String:field];
                [requiredSignatureArray addObject:attachmentId];
            }
        }
    }
    //kri OPDOC2
    synchronized_sqlite3_finalize(stmt);
    return requiredSignatureArray;
    
}
//Krishna OPDOCS requiredSignature

- (void)deleteRequiredSignatureFor:(NSString *)attachmentId {
    
    NSString * query = [NSString stringWithFormat:@"DELETE FROM %@ where sign_id Like '%@%%'", SFDOC_REQUIRED_SIGNATURE,attachmentId];
	
    char * err;
	
	if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
	{
		SMLog(kLogLevelError,@"Failed to delete");
        SMLog(kLogLevelError,@"METHOD:deleteEventNotRelatedToLoggedInUser");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        //[appDelegate printIfError:nil ForQuery:query type:DELETEQUERY];
	}
    
}

//krishna OPDOCS
-(void) insertIntoAttachment:(NSDictionary *)process_dict
{
    //defect:7609 krishna
    //added id as primary key
    
    NSMutableArray *idsList = [NSMutableArray arrayWithCapacity:0];
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (Id text(18) PRIMARY KEY  NOT NULL ,attachment_name text(255), parent_id  VARCHAR, body BLOB)",SFDOC_ATTACHMENT]];
    if (result)
    {
        [appDelegate.dataBase beginTransaction];
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, '')", SFDOC_ATTACHMENT,DOC_Id, DOC_name_attchment,DOC_ParentId, DOC_BODY];
        
        sqlite3_stmt * bulkStmt;
        
        NSArray * SF_DOC_template_attachment = [process_dict objectForKey:SFDOC_ATTACHMENT];
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        if (ret_value == SQLITE_OK)
        {
            
            for(int i = 0;i<[SF_DOC_template_attachment count];i++)
            {
                NSDictionary * each_doc_record = [SF_DOC_template_attachment objectAtIndex:i];
                
                char * _DOC_Id = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:DOC_Id] != nil)?[each_doc_record objectForKey:DOC_Id]:@""];
                
                sqlite3_bind_text(bulkStmt, 1, _DOC_Id, strlen(_DOC_Id), SQLITE_TRANSIENT);
                
                if ([each_doc_record objectForKey:DOC_Id] != nil && ![each_doc_record isEqual:@""]) {
                    [idsList addObject:[each_doc_record objectForKey:DOC_Id]];
                }
                
                char * _DOC_name_attchment = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:DOC_name_attchment] != nil)?[each_doc_record objectForKey:DOC_name_attchment]:@""];
                
                sqlite3_bind_text(bulkStmt, 2, _DOC_name_attchment, strlen(_DOC_name_attchment), SQLITE_TRANSIENT);
                
                char * _DOC_ParentId = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:DOC_ParentId] != nil)?[each_doc_record objectForKey:DOC_ParentId]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _DOC_ParentId, strlen(_DOC_ParentId), SQLITE_TRANSIENT);
                int val =synchronized_sqlite3_step(bulkStmt);
                
                if ( val  != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed! : insertIntoAttachment\n");
                }
                sqlite3_reset(bulkStmt);
                
            }
        }
        synchronized_sqlite3_finalize(bulkStmt);
        [appDelegate.dataBase endTransaction];
        
    }
    
    for(NSString * each_id in idsList)
    {
        [self getAttachmentForId:each_id];
    }
}

//krishna OPDOCS
-(void)getAttachmentForId:(NSString *)attachmentId
{
    didRcvAttachment = NO;
    NSString * _query = [NSString stringWithFormat:@"SELECT Body,Name, Id FROM Attachment Where Id = '%@'", attachmentId];
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetAttachmentWithResult:error:context:) context:nil];
    SMXMonitor *monitor = [[SMXMonitor alloc] init];
    [monitor monitorSMMessageWithName:@"[DataBase getAttachmentForId]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Start"
                         timeInterval:kWSExecutionDuration];
    while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        if(didRcvAttachment)
        {
            break;
        }
        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }
        
    }
    [monitor monitorSMMessageWithName:@"[DataBase getAttachmentForId]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Stop"
                         timeInterval:kWSExecutionDuration];
    [monitor release];
}
//krishna OPDOCS
- (void) didGetAttachmentWithResult:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    // Store the image in a appDelegate UIImage
    
    NSArray * array = [result records];
    
    if ([array count] > 0)
    {
        ZKSObject *obj = [array objectAtIndex:0];
        
        NSDictionary *dict = [obj fields];
        
        NSString *bodyString = [dict objectForKey:@"Body"];
        NSString * Id = [dict objectForKey:@"Id"];
        
        if (bodyString != nil && [bodyString length] > 0)
        {
            
            NSString *updateQuery = [NSString stringWithFormat:@"Update %@ Set body = '%@' Where Id = '%@'", SFDOC_ATTACHMENT, bodyString, Id];
            char *err;
            if (synchronized_sqlite3_exec(appDelegate.db, [updateQuery UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                SMLog(kLogLevelError,@" ************ Update Attachments query ************ %@", updateQuery);
                SMLog(kLogLevelError,@"METHOD: Update Attachments table with body of attachment" );
                SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
                [appDelegate printIfError:[NSString stringWithUTF8String:err] ForQuery:updateQuery type:UPDATEQUERY];
                //                return;
            }
            else
            {
                SMLog(kLogLevelVerbose,@" ************ Update Attachments query ************ %@ \n DIDNOT WORK!!!! ***************** ", updateQuery);
            }
        }
    }
    didRcvAttachment = YES;
}
//Krishna OPDocs
-(void)UpdateDocumentTemplateId:(NSString *)docTemplateId forProcessId:(NSString *)processId
{
    NSString * update_statement = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE process_id = '%@'",SFPROCESS ,DOCUMENT_TEMPLATE_ID,docTemplateId,processId];
    char * err;
    
    if(synchronized_sqlite3_exec(appDelegate.db, [update_statement UTF8String],NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", update_statement);
		SMLog(kLogLevelError,@"METHOD:UpdateDocumentTemplateId" );
		SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
		[appDelegate printIfError:nil ForQuery:update_statement type:UPDATEQUERY];
    }
}

//Krishna OPDocs
- (NSMutableArray *) getDocumentTemplatesForProcessId:(NSString *)processId {
    
    sqlite3_stmt * stmt;
    
    NSString *docTemplateName = @"";
    NSString *identifier = @"";
    
    NSMutableArray *docTemplateNameArray = [NSMutableArray array];
    
    NSString *selectQuery2 = [NSString stringWithFormat:@"SELECT doc_template_name,Id From DOC_TEMPLATE Where doc_template_id = '%@'",processId];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery2 UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
            
            char *field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if ( field != nil )
                docTemplateName = [NSString stringWithUTF8String:field];
            
            char *field1 = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_2);
            if ( field1 != nil )
                identifier = [NSString stringWithUTF8String:field1];
            
            [tempDict setValue:docTemplateName forKey:DOCUMENTS_NAME];
            [tempDict setValue:identifier forKey:DOCUMENTS_ID];
            [docTemplateNameArray addObject:tempDict];
            [tempDict release];
        }
        synchronized_sqlite3_finalize(stmt);
    }
    return docTemplateNameArray;
    
}
/*
 STATIC_RESOURCE
 
 STATIC_RESOURCE
 */

- (void)requestForStaticResources
{
    appDelegate.did_fetch_static_resource_ids = NO;
    SMXMonitor *monitor = [[[SMXMonitor alloc] init] autorelease];
    [monitor monitorSMMessageWithName:@"[DataBase requestForStaticResources]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Start"
                         timeInterval:kWSExecutionDuration];
    [appDelegate.wsInterface requestForStaticResources];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        SMLog(kLogLevelVerbose,@"Static resources library!!");
        if (appDelegate.did_fetch_static_resource_ids == YES)
        {
            SMLog(kLogLevelVerbose,@"Static resources - SUCCESS!!");
            break;
        }
        if (![appDelegate isInternetConnectionAvailable])
        {
            SMLog(kLogLevelError,@"Static resources - FAILED due to internet connection unavailability!!");
            [monitor monitorSMMessageWithName:@"[DataBase requestForStaticResources]"
                                 withUserName:appDelegate.currentUserName
                                     logLevel:kPerformanceLevelWarning
                                   logContext:@"Stop"
                                 timeInterval:kWSExecutionDuration];
            return;
        }
        if(appDelegate.connection_error)
        {
            SMLog(kLogLevelError,@"Static resources - FAILED due to conn error!!");
            [monitor monitorSMMessageWithName:@"[DataBase requestForStaticResources]"
                                 withUserName:appDelegate.currentUserName
                                     logLevel:kPerformanceLevelWarning
                                   logContext:@"Stop"
                                 timeInterval:kWSExecutionDuration];
            return;
        }
    }
    [monitor monitorSMMessageWithName:@"[DataBase requestForStaticResources]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Stop"
                         timeInterval:kWSExecutionDuration];
    
}


- (void)downloadResources:(NSDictionary*)resourceDict
{
    [self insertIntoStaticResource:resourceDict];
    [self retrieveImages:resourceDict];
    // Now Download images
}

- (void)retrieveImages:(NSDictionary*)resourceDict
{
    NSMutableArray *idsList = [NSMutableArray arrayWithCapacity:0];
    NSString *query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS Document ('local_id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE DEFAULT (0), 'AuthorId' VARCHAR, 'Body' VARCHAR, 'BodyLength' INTEGER, 'ContentType' VARCHAR, 'CreatedById' VARCHAR, 'Description' VARCHAR, 'DeveloperName' VARCHAR, 'FolderId' VARCHAR, 'Id' VARCHAR, 'IsBodySearchable' BOOL, 'IsDeleted' BOOL, 'IsInternalUseOnly' BOOL, 'IsPublic' BOOL, 'Keywords' TEXT, 'LastModifiedById' VARCHAR, 'LastModifiedDate' DATETIME, 'Name' VARCHAR, 'NamespacePrefix' VARCHAR, 'SystemModstamp' VARCHAR, 'Type' VARCHAR)"];
    BOOL result = [self createTable:query];
    
    if (result)
    {
        [appDelegate.dataBase beginTransaction];
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO Document ('DeveloperName', 'Name') VALUES (?1, ?2)"];
        
        sqlite3_stmt * bulkStmt;
        
        NSArray *staticResources = [resourceDict objectForKey:@"DOCUMENT"];
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        if (ret_value == SQLITE_OK)
        {
            
            for(int i = 0;i<[staticResources count];i++)
            {
                NSDictionary * each_doc_record = [staticResources objectAtIndex:i];
                
                char * DeveloperName = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:@"DeveloperName"] != nil)?[each_doc_record objectForKey:@"DeveloperName"]:@""];
                sqlite3_bind_text(bulkStmt, 1, DeveloperName, strlen(DeveloperName), SQLITE_TRANSIENT);
                
                if ([each_doc_record objectForKey:@"DeveloperName"] != nil && ![each_doc_record isEqual:@""]) {
                    [idsList addObject:[each_doc_record objectForKey:@"DeveloperName"]];
                }
                
                char * _DOC_name_attchment = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:@"Name"] != nil)?[each_doc_record objectForKey:@"Name"]:@""];
                sqlite3_bind_text(bulkStmt, 2, _DOC_name_attchment, strlen(_DOC_name_attchment), SQLITE_TRANSIENT);
                
                int val =synchronized_sqlite3_step(bulkStmt);
                
                if ( val  != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed!  retrieveImages\n");
                }
                sqlite3_reset(bulkStmt);
                
            }
        }
        synchronized_sqlite3_finalize(bulkStmt);
        [appDelegate.dataBase endTransaction];
        
    }
    
    for(NSString * devName in idsList)
    {
        [self retrieveImageDocumentFor:devName];
    }
    
}
- (void)retrieveImageDocumentFor:(NSString*)developerName
{
    didReceiveImageDocument = NO;
    
    NSString * _query = [NSString stringWithFormat:@"Select Type, NamespacePrefix, Name, Keywords, IsDeleted, Id, FolderId, DeveloperName, Description, ContentType, BodyLength, Body From Document where DeveloperName = '%@'", developerName];
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didRetrieveImageWithResult:error:context:) context:nil];
    SMXMonitor *monitor = [[SMXMonitor alloc] init];
    [monitor monitorSMMessageWithName:@"[DataBase getAttachmentForId]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Start"
                         timeInterval:kWSExecutionDuration];

    while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        if(didReceiveImageDocument)
        {
            break;
        }
        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }
        
    }
    [monitor monitorSMMessageWithName:@"[DataBase getAttachmentForId]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Stop"
                         timeInterval:kWSExecutionDuration];
    [monitor release];

}

- (void) didRetrieveImageWithResult:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    // Store the image in a appDelegate UIImage
    
    NSArray * array = [result records];
    
    if ([array count] > 0)
    {
        ZKSObject *obj = [array objectAtIndex:0];
        
        NSDictionary *dict = [obj fields];
        
        SMLog(kLogLevelVerbose,@"filename: %@ :: Type: %@",[dict objectForKey:@"Name"],[dict objectForKey:@"Type"]);
        
        NSString *Id                = [dict objectForKey:@"Id"];
        NSString *Type              = [dict objectForKey:@"Type"];
        NSString *NamespacePrefix   = [dict objectForKey:@"NamespacePrefix"];
        NSString *Name              = [dict objectForKey:@"Name"];
        NSString *Keywords          = [dict objectForKey:@"Keywords"];
        NSString *IsDeleted         = [dict objectForKey:@"IsDeleted"];
        NSString *FolderId          = [dict objectForKey:@"FolderId"];
        NSString *DeveloperName     = [dict objectForKey:@"DeveloperName"];
        NSString *Description       = [dict objectForKey:@"Description"];
        NSString *ContentType       = [dict objectForKey:@"ContentType"];
        NSString *BodyLength        = [dict objectForKey:@"BodyLength"];
        NSString *Body              = [dict objectForKey:@"Body"];
        
        NSString * query = [NSString stringWithFormat:@"UPDATE Document SET Type='%@', NamespacePrefix='%@', Name='%@', Keywords='%@', IsDeleted='%@', Id='%@', FolderId='%@', DeveloperName='%@', Description='%@', ContentType='%@', BodyLength='%@', Body='%@' WHERE DeveloperName='%@'",Type,NamespacePrefix,Name,Keywords,IsDeleted,Id,FolderId,DeveloperName,Description,ContentType,BodyLength,Body,DeveloperName];
        
        char *err;
        if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            SMLog(kLogLevelVerbose,@"Document Image data NOT updated to database %s",err);
        }
        
        NSString *bodyString = [dict objectForKey:@"Body"];
        NSString *fileName = [dict objectForKey:@"Name"];
        NSString *fileExtension = [dict objectForKey:@"Type"];
        
        if (bodyString != nil && [bodyString length] > 0)
        {
            NSData * bodyData = [Base64 decode:bodyString];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDir = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0];
            NSString *filePath = [[documentsDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:fileExtension];
            NSFileManager * fileManager = [NSFileManager defaultManager];
            
            BOOL success = [fileManager createFileAtPath:filePath contents:bodyData attributes:nil];
            
            if(success)
                SMLog(kLogLevelVerbose,@"stored : %@",filePath);
        }
    }
    didReceiveImageDocument = YES;
}


- (void)insertIntoStaticResource:(NSDictionary*)resourceDict
{
    /*
     
     STATIC RESOURCE (
     {
     Id = 081700000004LiMAAU;
     Name = "com_servicemax_client_mvc";
     },
     {
     Id = 081700000004LiNAAU;
     Name = "com_servicemax_client_runtime";
     },
     {
     Id = 081700000004LiQAAU;
     Name = "com_servicemax_client_sfmconsole";
     },
     {
     Id = 081700000004LiSAAU;
     Name = "com_servicemax_client_sfmopdocdelivery";
     },
     {
     Id = 081700000004LiTAAU;
     Name = "com_servicemax_client_sfmopdocdelivery_model";
     },
     {
     Id = 081700000004LiMAAU;
     Name = "com_servicemax_client_mvc";
     },
     {
     Id = 081700000004LiNAAU;
     Name = "com_servicemax_client_runtime";
     },
     {
     Id = 081700000004LiQAAU;
     Name = "com_servicemax_client_sfmconsole";
     },
     {
     Id = 081700000004LiSAAU;
     Name = "com_servicemax_client_sfmopdocdelivery";
     },
     {
     Id = 081700000004LiTAAU;
     Name = "com_servicemax_client_sfmopdocdelivery_model";
     },
     {
     Id = 081700000004LiMAAU;
     Name = "com_servicemax_client_mvc";
     },
     {
     Id = 081700000004LiNAAU;
     Name = "com_servicemax_client_runtime";
     },
     {
     Id = 081700000004LiQAAU;
     Name = "com_servicemax_client_sfmconsole";
     },
     {
     Id = 081700000004LiSAAU;
     Name = "com_servicemax_client_sfmopdocdelivery";
     },
     {
     Id = 081700000004LiTAAU;
     Name = "com_servicemax_client_sfmopdocdelivery_model";
     }
     )
     
     */
    
    NSMutableArray *idsList = [NSMutableArray arrayWithCapacity:0];
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (%@ text(18) ,%@ text(255))",STATIC_RESOURCE, STATIC_RES_ID, STATIC_RES_NAME]];
    if (result)
    {
        [appDelegate.dataBase beginTransaction];
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@') VALUES (?1, ?2)", STATIC_RESOURCE, STATIC_RES_ID, STATIC_RES_NAME];
        
        sqlite3_stmt * bulkStmt;
        
        NSArray *staticResources = [resourceDict objectForKey:STATIC_RESOURCE_KEY];
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        if (ret_value == SQLITE_OK)
        {
            
            for(int i = 0;i<[staticResources count];i++)
            {
                NSDictionary * each_doc_record = [staticResources objectAtIndex:i];
                
                char * _DOC_Id = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:STATIC_RES_ID] != nil)?[each_doc_record objectForKey:STATIC_RES_ID]:@""];
                sqlite3_bind_text(bulkStmt, 1, _DOC_Id, strlen(_DOC_Id), SQLITE_TRANSIENT);
                
                if ([each_doc_record objectForKey:STATIC_RES_ID] != nil && ![each_doc_record isEqual:@""]) {
                    [idsList addObject:[each_doc_record objectForKey:STATIC_RES_ID]];
                }
                
                char * _DOC_name_attchment = [appDelegate convertStringIntoChar:([each_doc_record objectForKey:STATIC_RES_NAME] != nil)?[each_doc_record objectForKey:STATIC_RES_NAME]:@""];
                sqlite3_bind_text(bulkStmt, 2, _DOC_name_attchment, strlen(_DOC_name_attchment), SQLITE_TRANSIENT);
                
                int val =synchronized_sqlite3_step(bulkStmt);
                
                if ( val  != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed!   insertIntoStaticResource\n");
                }
                sqlite3_reset(bulkStmt);
                
            }
        }
        synchronized_sqlite3_finalize(bulkStmt);
        [appDelegate.dataBase endTransaction];
        
    }
    [appDelegate installCoreLibrary];//damodar 30/aug/2013
    
    for(NSString * each_id in idsList)
    {
        [self retrieveStaticResourceFor:each_id];
    }
}

- (void)retrieveStaticResourceFor:(NSString*)resId
{
    //    return; // Temporary to avoid overwriting core library source code
    
    didRcvStaticresource = NO;
    NSString * _query = [NSString stringWithFormat:@"Select Name, Id, ContentType, Body From StaticResource where Id = '%@'", resId];
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didRetrieveStaticresourceWithResult:error:context:) context:nil];
    SMXMonitor *monitor = [[SMXMonitor alloc] init];
    [monitor monitorSMMessageWithName:@"[DataBase retrieveStaticResourceFor]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Start"
                         timeInterval:kWSExecutionDuration];

    while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        if(didRcvStaticresource)
        {
            break;
        }
        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }
        
    }
    [monitor monitorSMMessageWithName:@"[DataBase retrieveStaticResourceFor]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Stop"
                         timeInterval:kWSExecutionDuration];
    [monitor release];

    
}

- (void) didRetrieveStaticresourceWithResult:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    // Store the image in a appDelegate UIImage
    
    NSArray * array = [result records];
    
    if ([array count] > 0)
    {
        ZKSObject *obj = [array objectAtIndex:0];
        
        NSDictionary *dict = [obj fields];
        
        NSString *bodyString = [dict objectForKey:@"Body"];
        NSString *fileName = [dict objectForKey:@"Name"];
        NSString *fileExtension = ([[dict objectForKey:@"ContentType"] isEqualToString:@"application/x-zip-compressed"]) ? @"zip" : @"";
        
        if (bodyString != nil && [bodyString length] > 0)
        {
            NSData * bodyData = [Base64 decode:bodyString];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDir = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0];
            NSString *filePath = [[documentsDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:fileExtension];
            NSFileManager * fileManager = [NSFileManager defaultManager];
            
            BOOL success = [fileManager createFileAtPath:filePath contents:bodyData attributes:nil];
            if(success)
            {
                //                success = [self unzipAndViewFile:filePath andFolderName:nil deleteArchive:YES];
                success = [SSZipArchive unzipFileAtPath:filePath toDestination:documentsDir]; // ZipArchive doesn't unzip manifest folder inside root folder of each library, hence SSZipArchive is used
                if(!success)
                {
                    SMLog(kLogLevelError,@"!!!!!!! Unarchive failed for %@.%@ !!!!!!!!",fileName,fileExtension);
                }
                else
                {
                    NSFileManager * fm = [NSFileManager defaultManager];
                    [fm removeItemAtPath:filePath error:NULL];
                }
            }
            
        }
    }
    didRcvStaticresource = YES;
}

- (BOOL) unzipAndViewFile:(NSString *)_file andFolderName:(NSString *)folderPath deleteArchive:(BOOL)delete
{
    if (self.zipArchiver == nil)
    {
        ZipArchive *tempArchive = [[ZipArchive alloc] init];
        self.zipArchiver = tempArchive;
        [tempArchive release];
    }
    
    BOOL retVal = [self.zipArchiver UnzipOpenFile:_file];
    
    if (!retVal)
    {
        SMLog(kLogLevelError,@"UnzipOpenFile encountered an error.");
        return NO;
    }
    
    // Directory Path to unzip file to...
    NSString * docDir = [appDelegate getAppCustomSubDirectory]; // [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    // Create "dataName" directory in Documents
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error = nil;
    
    if(folderPath != nil)
    {
        [fm createDirectoryAtPath:folderPath
      withIntermediateDirectories:YES
                       attributes:(NSDictionary *)nil
                            error:&error];
        
    }
    
    NSString * unzipPath = [docDir stringByAppendingPathComponent:folderPath];
    
    retVal = [self.zipArchiver UnzipFileTo:unzipPath overWrite:YES];
    
    if (!retVal)
    {
        SMLog(kLogLevelError,@"Unzip encountered an error.");
        return NO;
    }
    else
    {
        [fm removeItemAtPath:_file error:NULL];
    }
    
    return YES;
}

// END : SFM OP Docs

-(void)insertValuesIntoLinkedSFMProcessTable:(NSMutableDictionary *)processDictionary
{
    int id_value = 0;
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS 'LINKED_SFMProcess' ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE, 'Id' VARCHAR,'source_header' VARCHAR,'source_detail' VARCHAR,'target_header' VARCHAR )"]];
    if(result)
    {

        int exec_value = [self beginTransaction];

        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5)", LINKED_SFMProcess, _ID, source_detail, source_header,target_header,MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        NSArray * linked_process = [processDictionary objectForKey:LINKED_SFMProcess];

        
        if (ret_value == SQLITE_OK)
        {
            
            for (int i = 0; i < [linked_process count]; i++)
            {
                NSDictionary * dict = [linked_process objectAtIndex:i];
				
				char * _linked_id = [appDelegate convertStringIntoChar:([dict objectForKey:_ID] != nil)?[dict objectForKey:_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 1, _linked_id, strlen(_linked_id), SQLITE_TRANSIENT);
				
				
                char * _source_detail = [appDelegate convertStringIntoChar:([dict objectForKey:source_detail] != nil)?[dict objectForKey:source_detail]:@""];
                
                sqlite3_bind_text(bulkStmt, 2, _source_detail, strlen(_source_detail), SQLITE_TRANSIENT);
				
				char * _source_header = [appDelegate convertStringIntoChar:([dict objectForKey:source_header] != nil)?[dict objectForKey:source_header]:@"" ];
                
                sqlite3_bind_text(bulkStmt, 3, _source_header, strlen(_source_header), SQLITE_TRANSIENT);
                
                char * _target_header = [appDelegate convertStringIntoChar:([dict objectForKey:target_header] != nil)?[dict objectForKey:target_header]:@"" ];
                
                sqlite3_bind_text(bulkStmt, 4, _target_header, strlen(_target_header), SQLITE_TRANSIENT);
                
                
                sqlite3_bind_int(bulkStmt, 5, ++id_value);
                
                if ( synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed!\n");
                }
                
                sqlite3_reset(bulkStmt);
            }
            
            sqlite3_finalize(bulkStmt);

        }
        

        exec_value = [self endTransaction];
    }
    
    
}

-(void) insertvaluesToPicklist:(NSMutableArray *)object fields:(NSMutableArray *)fields value:(NSMutableArray *)values
{
    SMLog(kLogLevelVerbose,@"  insertvaluesToPicklist Processing starts: %@", [NSDate date]);
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFPickList ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE, 'object_api_name' VARCHAR,'field_api_name' VARCHAR,'label' VARCHAR,'value' VARCHAR, 'defaultvalue'  VARCHAR , 'valid_for' VARCHAR , 'index_value' INTEGER)"]];
    
    if (result == YES)
    {
        NSString * pickValue = @"";
        NSString * pickLabel = @"";
        NSString * defautPickValue = @"";
        int id_value = 1;
        
        [self beginTransaction];
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6)", SFPICKLIST, MOBJECT_API_NAME, _MFIELD_API_NAME, LABEL, MVALUEM, MDEFAULTVALUE, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);

        

        if (ret_value == SQLITE_OK)
        {
            for (int i = 0; i < [object count]; i++)
            {
                NSString * objectName = [[object objectAtIndex:i] objectForKey:OBJECT];
				
				if ([objectName isEqualToString:@"SVMXC__Service_Order__c"])
				{
					SMLog(kLogLevelVerbose,@"SVMXC__Service_Order__c");
				}
                
                NSDictionary * fieldDict = [fields objectAtIndex:i];
                
                NSArray * fieldArray = [fieldDict objectForKey:objectName];
                        
                NSDictionary * valueDict = [values objectAtIndex:i];
                
                
                NSArray * picklistValues = [valueDict objectForKey:objectName];
                        
                for (int j = 0; j < [picklistValues count]; j++)
                {
                    NSDictionary * dict = [fieldArray objectAtIndex:j];
                    
                    NSArray * keys = [dict allValues];
                    
                    NSString * fieldName = [keys objectAtIndex:0];
                    
                    NSArray * values = [[picklistValues objectAtIndex:j] objectForKey:fieldName];
                    
                    
                    for (int m = 0; m < [values count]; m++)
                    {
                        NSArray * key = [values objectAtIndex:m];
                        NSArray * value = [values objectAtIndex:++m];
                        
                        int count = [key count];
                        
                        // Vipin-db-optmz
                        [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"insertvaluesToPicklist"
                                                                             andRecordCount:0];
                        
                        
                        for (int r = 0; r < count; ++r)
                        {
                            if ([[key objectAtIndex:r] isEqualToString:@"ISMULTIPICKLIST"])
                                continue;
                            
                            pickValue = [value objectAtIndex:r];
                            pickValue = [pickValue stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
                            pickLabel = [value objectAtIndex:++r];
                            pickLabel = [pickLabel stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
                            
                            if ( r < [key count] - 1)
                            {
                                if ([[key objectAtIndex:++r] isEqualToString:DEFAULTPICKLISTVALUE])
                                {
                                    defautPickValue = [value objectAtIndex:r];
                                    defautPickValue = [defautPickValue stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
                                }
                                else
                                {
                                    --r;
                                    defautPickValue = @"";
                                }
                            }
							
							char * _objectName = [appDelegate convertStringIntoChar:objectName];
							
                            sqlite3_bind_text(bulkStmt, 1, _objectName, strlen(_objectName), SQLITE_TRANSIENT);
							
							char * _fieldName = [appDelegate convertStringIntoChar:fieldName];
                            
                            sqlite3_bind_text(bulkStmt, 2, _fieldName, strlen(_fieldName), SQLITE_TRANSIENT);
							
							char * _pickLabel = [appDelegate convertStringIntoChar:pickLabel];
                            
                            sqlite3_bind_text(bulkStmt, 3, _pickLabel, strlen(_pickLabel), SQLITE_TRANSIENT);
							
							char * _pickValue = [appDelegate convertStringIntoChar:pickValue];
                            
                            sqlite3_bind_text(bulkStmt, 4, _pickValue, strlen(_pickValue), SQLITE_TRANSIENT);
							
							char * _defautPickValue = [appDelegate convertStringIntoChar:defautPickValue];
                            
                            sqlite3_bind_text(bulkStmt, 5, _defautPickValue, strlen(_defautPickValue), SQLITE_TRANSIENT);
                            
                            sqlite3_bind_int(bulkStmt, 6, id_value++);
                            
                            if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                            {
                                SMLog(kLogLevelError,@"Commit Failed - SFPICKLIST !\n");
                            }
                            sqlite3_clear_bindings(bulkStmt);
                            sqlite3_reset(bulkStmt);
                        }
                        
                        // Vipin-db-optmz
                        [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"insertvaluesToPicklist"
                                                                             andRecordCount:count];
                        
                        [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:count];
                        
                    }
                }
             }
        }
        
         synchronized_sqlite3_finalize(bulkStmt);
         [self endTransaction];
    }
  
    appDelegate.wsInterface.didGetPicklistValues = TRUE;
    SMLog(kLogLevelVerbose,@"  insertvaluesToPicklist Processing ends: %@", [NSDate date]);
}

- (void) insertValuesInToRTPicklistTableForObject:(id)objects Values:(NSMutableDictionary *)recordTypeDict
{
    int id_value = 0;
    
    SMLog(kLogLevelVerbose,@"  insertValuesInToRTPicklistTableForObject Processing starts: %@", [NSDate date]);
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFRTPicklist ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL, 'object_api_name' VARCHAR, 'recordtypename' VARCHAR, 'recordtypelayoutid' VARCHAR, 'recordtypeid' VARCHAR, 'field_api_name' VARCHAR, 'label' VARCHAR, 'value' VARCHAR, 'defaultlabel' VARCHAR, 'defaultvalue' VARCHAR)"]];
    
    
    if (result == YES)
    {
        result = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS RTIndex ON SFRTPicklist (object_api_name, field_api_name, recordtypename, defaultlabel, defaultvalue, label, value)"]];
        
        
        [self beginTransaction];
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ ( %@, %@, %@, %@, %@, %@, %@, %@, %@,%@ ) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10)", SFRTPICKLIST, MOBJECT_API_NAME, _MFIELD_API_NAME, MLABEL, MVALUEM, MDEFAULTVALUE, MDEFAULTLABEL, @"recordtypename", @"recordtypeid", @"recordtypelayoutid", MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);

        
        if (ret_value == SQLITE_OK)
        {
        
            for (NSString * objectName in objects)
            {
                NSMutableArray * RecordTypePickList = [recordTypeDict objectForKey:objectName];
                
                for (NSMutableDictionary * sub_dict in RecordTypePickList)
                {
                    NSString * recordTypeName = ([sub_dict objectForKey:@"RecorTypeName"] != nil)?[sub_dict objectForKey:@"RecorTypeName"]:@"";
                    NSString * recordTypeID = ([sub_dict objectForKey:@"RecorTypeId"] != nil)?[sub_dict objectForKey:@"RecorTypeId"]:@"";
                    NSString * recordTypeLayoutId = ([sub_dict objectForKey:@"RecorTypeLayoutId"] != nil)?[sub_dict objectForKey:@"RecorTypeLayoutId"]:@"";
                    
                    
                    NSArray * picklists = [sub_dict objectForKey:@"PickLists"];
                    NSString * defaultValue = @"";
                    NSString * defaultLabel = @"";
                    NSString * api_name = @"";
                    
                    for (NSDictionary * picklistValueDict in picklists)
                    {
                        defaultLabel = ([picklistValueDict objectForKey:@"PickListDefaultLabel"] != nil)?[picklistValueDict objectForKey:@"PickListDefaultLabel"]:@"";
                        defaultValue = ([picklistValueDict objectForKey:@"PickListDefaultValue"] != nil)?[picklistValueDict objectForKey:@"PickListDefaultValue"]:@"";
                        api_name = ([picklistValueDict objectForKey:@"PickListName"] != nil)?[picklistValueDict objectForKey: @"PickListName"]:@"";
                        NSArray * pickListValue = [picklistValueDict objectForKey:@"PickListValue"];
                        
                        // Vipin-db-optmz
                        [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFRTPicklist"
                                                                             andRecordCount:0];
                        
                        
                        for (NSDictionary * labelValueDict in pickListValue)
                        {                        
                            NSString * label = ([labelValueDict objectForKey:@"label"] != nil)?[labelValueDict objectForKey:@"label"]:@"";
                            NSString * value = ([labelValueDict objectForKey:@"value"] != nil)?[labelValueDict objectForKey:@"value"]:@"";
                            
                            label = [label stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
                            value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
                            
							char * _objectName = [appDelegate convertStringIntoChar:objectName];
							
                            sqlite3_bind_text(bulkStmt, 1, _objectName, strlen(_objectName), SQLITE_TRANSIENT);
							
							char * _api_name = [appDelegate convertStringIntoChar:api_name];
                            
                            sqlite3_bind_text(bulkStmt, 2, _api_name, strlen(_api_name), SQLITE_TRANSIENT);
							
							char * _label = [appDelegate convertStringIntoChar:label];
                            
                            sqlite3_bind_text(bulkStmt, 3, _label, strlen(_label), SQLITE_TRANSIENT);
							
							char * _value = [appDelegate convertStringIntoChar:value];
                            
                            sqlite3_bind_text(bulkStmt, 4, _value, strlen(_value), SQLITE_TRANSIENT);
							
							char * _defaultLabel = [appDelegate convertStringIntoChar:defaultLabel];
                            
                            sqlite3_bind_text(bulkStmt, 5, _defaultLabel, strlen(_defaultLabel), SQLITE_TRANSIENT);
							
							char * _defaultValue = [appDelegate convertStringIntoChar:defaultValue];
                            
                            sqlite3_bind_text(bulkStmt, 6, _defaultValue, strlen(_defaultValue), SQLITE_TRANSIENT);
							
							char * _recordTypeName = [appDelegate convertStringIntoChar:recordTypeName];
                            
                            sqlite3_bind_text(bulkStmt, 7, _recordTypeName, strlen(_recordTypeName), SQLITE_TRANSIENT);
							
							char * _recordTypeID = [appDelegate convertStringIntoChar:recordTypeID];
                            
                            sqlite3_bind_text(bulkStmt, 8, _recordTypeID, strlen(_recordTypeID), SQLITE_TRANSIENT);
							
							char * _recordTypeLayoutId = [appDelegate convertStringIntoChar:recordTypeLayoutId];
                            
                            sqlite3_bind_text(bulkStmt, 9, _recordTypeLayoutId, strlen(_recordTypeLayoutId), SQLITE_TRANSIENT);
                            
                            sqlite3_bind_int(bulkStmt, 10, ++id_value);
                            
                            if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                            {
                                SMLog(kLogLevelError,@"Commit Failed -  SFRTPicklist!\n");
                            }
                            
                            sqlite3_clear_bindings(bulkStmt);
                            sqlite3_reset(bulkStmt);
                        }
                        
                        // Vipin-db-optmz
                        [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFRTPicklist"
                                                                             andRecordCount:[pickListValue count]];
                        
                        [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[pickListValue count]];
                        
                    }
                }
            }
        
        }
        
        synchronized_sqlite3_finalize(bulkStmt);
        [self endTransaction];
    }
    
    // Vipin-db-optmz
    result = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS RTIndex ON SFRTPicklist (object_api_name, field_api_name, recordtypename, defaultlabel, defaultvalue, label, value)"]];
    
    
    SMLog(kLogLevelVerbose,@"  insertValuesInToRTPicklistTableForObject Processing starts: %@", [NSDate date]);
    
    appDelegate.initial_sync_status = SYNC_SFW_METADATA;
    appDelegate.Sync_check_in = FALSE;
    [appDelegate.wsInterface metaSyncWithEventName:SFW_METADATA eventType:SYNC values:nil];

}
- (void) insertValuesInToExpressionTables:(NSMutableDictionary *)processDictionary
{
    int id_value = 0;
    
    //8303 - Vipindas - Sep 4, 2013
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFExpression ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 'expression_id' VARCHAR, 'expression' VARCHAR, 'expression_name' VARCHAR, 'error_message' VARCHAR)"]];
    if (result == YES)
    {
         [self beginTransaction];
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2,   ?3, ?4, ?5)", SFEXPRESSION, MEXPRESSION_ID , MEXPRESSION_NAME, MEXPRESSION, MLOCAL_ID, MEXPRESSION_ERROR_MSG];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);

        
        NSArray * sfExpression = [processDictionary objectForKey:MSFExpression];
        
        if (ret_value == SQLITE_OK)
        {
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFExpression"
                                                                 andRecordCount:0];
            
        
            for (int i = 0; i < [sfExpression count]; i++)
            {
                NSDictionary * dict = [sfExpression objectAtIndex:i];
                
                SMLog(kLogLevelVerbose,@"  SFExpression  dict  :\n%@", dict);
				
				char * _expressionId = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 1, _expressionId, strlen(_expressionId), SQLITE_TRANSIENT);
				
				char * _expressionName = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_NAME] != nil)?[dict objectForKey:MEXPRESSION_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 2, _expressionName, strlen(_expressionName), SQLITE_TRANSIENT);
				
				char * _advanceExpression = [appDelegate convertStringIntoChar:([dict objectForKey:MADVANCE_EXPRESSION] != nil)?[dict objectForKey:MADVANCE_EXPRESSION]:@"" ];
                
                sqlite3_bind_text(bulkStmt, 3, _advanceExpression, strlen(_advanceExpression), SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 4, ++id_value);
                
                char * errorMessage = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_ERROR_MSG] != nil)?[dict objectForKey:MEXPRESSION_ERROR_MSG]:@""];
                
                sqlite3_bind_text(bulkStmt, 5, errorMessage, strlen(errorMessage), SQLITE_TRANSIENT);
                
                                
                if ( synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed - SFExpression!\n");
                }
                
                sqlite3_clear_bindings(bulkStmt);
                sqlite3_reset(bulkStmt);

            }
            
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFExpression"
                                                                 andRecordCount:[sfExpression count]];
            
            [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[sfExpression count]];
            
        }
        else
        {
            SMLog(kLogLevelError,@"Failed prepared statement - SFExpression! \n %d - %@", ret_value, [NSString stringWithUTF8String:sqlite3_errmsg(appDelegate.db)]);
            
            SMLog(kLogLevelError,@" SFExpression Prepared statement %@", bulkQueryStmt);
        }
        synchronized_sqlite3_finalize(bulkStmt);
        [self endTransaction];


    }
    id_value = 0;
    
    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFExpressionComponent ('local_id' INTEGER PRIMARY KEY  NOT NULL ,'expression_id' VARCHAR,'component_sequence_number' VARCHAR,'component_lhs' VARCHAR,'component_rhs' VARCHAR,'operator'CHAR,'field_type' TEXT,'expression_type' TEXT,'parameter_type' TEXT)"]];
    
    if (result == YES)
    {
        [self beginTransaction];
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9)", SFEXPRESSIONCOMPONENT, MEXPRESSION_ID, MCOMPONENT_SEQ_NUM, MCOMPONENT_LHS, MCOMPONENT_RHS, MOPERATOR, MLOCAL_ID,MEXPRESSION_TYPE,MPARAMETER_TYPE,MFIELD_TYPE];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);

        NSArray * sfExpression_com = [processDictionary objectForKey:MSFExpression_component];
        
        if (ret_value == SQLITE_OK)
        {
        
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFEXPRESSIONCOMPONENT"
                                                                 andRecordCount:0];
            
            for (int i = 0; i < [sfExpression_com count]; i++)
            {
                NSDictionary * dict = [sfExpression_com objectAtIndex:i];
				
				char * _expressionId = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 1, _expressionId, strlen(_expressionId), SQLITE_TRANSIENT);
				
				char * _sequence = [appDelegate convertStringIntoChar:([dict objectForKey:MSEQUENCE] != nil)?[dict objectForKey:MSEQUENCE]:@""];
                
                sqlite3_bind_text(bulkStmt, 2, _sequence, strlen(_sequence), SQLITE_TRANSIENT);
				
				char * _sourceFieldName = [appDelegate convertStringIntoChar:([dict objectForKey:MSOURCE_FIELD_NAME] != nil)?[dict objectForKey:MSOURCE_FIELD_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _sourceFieldName, strlen(_sourceFieldName), SQLITE_TRANSIENT);
				
				char * _value = [appDelegate convertStringIntoChar:([dict objectForKey:MVALUEM] != nil)?[dict objectForKey:MVALUEM]:@""];
                
                sqlite3_bind_text(bulkStmt, 4, _value, strlen(_value), SQLITE_TRANSIENT);
				
				char * _operator = [appDelegate convertStringIntoChar:([dict objectForKey:MOPERATOR] != nil)?[dict objectForKey:MOPERATOR]:@""];
                
                sqlite3_bind_text(bulkStmt, 5, _operator, strlen(_operator), SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 6, ++id_value);
                char * _expressionType = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_TYPE] != nil)?[dict objectForKey:MEXPRESSION_TYPE]:@""];
                
                sqlite3_bind_text(bulkStmt, 7, _expressionType, strlen(_expressionType), SQLITE_TRANSIENT);
                
                char * _parameterType = [appDelegate convertStringIntoChar:([dict objectForKey:MPARAMETER_TYPE] != nil)?[dict objectForKey:MPARAMETER_TYPE]:@""];
                sqlite3_bind_text(bulkStmt, 8, _parameterType, strlen(_parameterType), SQLITE_TRANSIENT);
                
                char * _fieldType = [appDelegate convertStringIntoChar:([dict objectForKey:MFIELD_TYPE] != nil)?[dict objectForKey:MFIELD_TYPE]:@""];
                
                sqlite3_bind_text(bulkStmt, 9, _fieldType, strlen(_fieldType), SQLITE_TRANSIENT);

                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed - SFEXPRESSIONCOMPONENT!\n");
                }
                
                sqlite3_clear_bindings(bulkStmt);
                sqlite3_reset(bulkStmt);
            }
            
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFEXPRESSIONCOMPONENT"
                                                                 andRecordCount:[sfExpression_com count]];
            
            [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[sfExpression_com count]];
            
        }
        
        synchronized_sqlite3_finalize(bulkStmt);
        [self endTransaction];

    }
    
    
    [self insertValuesInToObjectMappingTable:processDictionary];
}


- (void) insertValuesInToObjectMappingTable:(NSMutableDictionary *)processDictionary
{
    
    int id_value = 0;
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFObjectMapping ('local_id' INTEGER PRIMARY KEY  NOT NULL ,'object_mapping_id' VARCHAR , 'source_object_name' VARCHAR, 'target_object_name' VARCHAR)"]];
    if (result == YES)
    {
        
        [self beginTransaction];
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@') VALUES (?1, ?2,   ?3, ?4)", SFOBJECTMAPPING, MOBJECT_MAPPING_ID , MSOURCE_OBJECT_NAME, MTARGET_OBJECT_NAME, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);

        
        NSArray * sfobjectMap = [processDictionary objectForKey:MSFObject_mapping];
        
        if (ret_value == SQLITE_OK)
        {
        
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFObjectMapping"
                                                                 andRecordCount:0];
            
            
            for (int i = 0; i < [sfobjectMap count]; i++)
            {
                NSDictionary * dict = [sfobjectMap objectAtIndex:i];
				
				char * _objectMappingId = [appDelegate convertStringIntoChar:([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 1, _objectMappingId, strlen(_objectMappingId), SQLITE_TRANSIENT);
				
				char * _sourceObjectName = [appDelegate convertStringIntoChar:([dict objectForKey:MSOURCE_OBJECT_NAME] != nil)?[dict objectForKey:MSOURCE_OBJECT_NAME]:@""];

                
                sqlite3_bind_text(bulkStmt, 2, _sourceObjectName, strlen(_sourceObjectName), SQLITE_TRANSIENT);
				
				char * _targetObjectName = [appDelegate convertStringIntoChar:([dict objectForKey:MTARGET_OBJECT_NAME] != nil)?[dict objectForKey:MTARGET_OBJECT_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _targetObjectName, strlen(_targetObjectName), SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 4, ++id_value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed - SFObjectMapping!\n");
                }
                
                sqlite3_clear_bindings(bulkStmt);
                sqlite3_reset(bulkStmt);

            }
            
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFObjectMapping"
                                                                 andRecordCount:[sfobjectMap count]];
            
            [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[sfobjectMap count]];
            
        }
        synchronized_sqlite3_finalize(bulkStmt);
        [self endTransaction];
    }
    
    [self insertSourceToTargetInToSFProcessComponent];
    
    //Aparna: FORMFILL (ADDITIONAL MAPPING SUPPORT)
    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFObjectMappingComponent ('local_id' INTEGER PRIMARY KEY  NOT NULL ,'object_mapping_id' VARCHAR,'source_field_name' VARCHAR,'target_field_name' VARCHAR,'mapping_value' VARCHAR,'mapping_component_type' VARCHAR,'mapping_value_flag' BOOL, 'preference_2' VARCHAR, 'preference_3' VARCHAR)"]];
    
    if (result == YES)
    {
        NSArray * sfObject_com = [processDictionary objectForKey:MSFObject_mapping_component];
        
        NSString * flag = @"true";
        NSString * value = @"";
        id_value = 0;

        [self beginTransaction];
        NSString * bulkQueryStmt = @"";
        
        //Aparna: FORMFILL (ADDITIONAL MAPPING SUPPORT)
        bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9)", SFOBJECTMAPCOMPONENT, MOBJECT_MAPPING_ID , MSOURCE_FIELD_NAME, MTARGET_FIELD_NAME, MMAPPING_VALUE, MMAPPING_COMP_TYPE, MMAPPING_VALUE_FLAG, MLOCAL_ID, MMAPPING_PREFERENCE2, MMAPPING_PREFERENCE3];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        
        if (ret_value == SQLITE_OK)
        {
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFOBJECTMAPCOMPONENT"
                                                                 andRecordCount:0];

            
            for (int i = 0; i < [sfObject_com count]; i++)
            {
                NSDictionary * dict_ = [sfObject_com objectAtIndex:i];
                NSString * target_field_name = @"";
                NSString * mappingValue = @"";
                value = @"";
                
                target_field_name = ([dict_ objectForKey:@"target_field_name"] != nil)?[dict_ objectForKey:@"target_field_name"]:@"";
                mappingValue = ([dict_ objectForKey:@"mapping_value"] != nil)?[dict_ objectForKey:@"mapping_value"]:@"";
                
                if ([target_field_name isEqualToString:@""])
                {
                    value = MVALUEMAPPING;
                }
                if ((![target_field_name isEqualToString:@""]) && (![mappingValue isEqualToString:@""]))
                {
                    value = MVALUEMAPPING;
                }
                else
                {
                    value = MFIELDMAPPING;
                }
                
				
				char * _objectMappingid = [appDelegate convertStringIntoChar:([dict_ objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict_ objectForKey:MOBJECT_MAPPING_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 1, _objectMappingid, strlen(_objectMappingid), SQLITE_TRANSIENT);
				
				char * _sourceFieldName = [appDelegate convertStringIntoChar:([dict_ objectForKey:MSOURCE_FIELD_NAME] != nil)?[dict_ objectForKey:MSOURCE_FIELD_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 2, _sourceFieldName, strlen(_sourceFieldName), SQLITE_TRANSIENT);
				
				char * _targetFieldName = [appDelegate convertStringIntoChar:([dict_ objectForKey:MTARGET_FIELD_NAME] != nil)?[dict_ objectForKey:MTARGET_FIELD_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _targetFieldName, strlen(_targetFieldName), SQLITE_TRANSIENT);
				
				char * _mappingValue = [appDelegate convertStringIntoChar:([dict_ objectForKey:MMAPPING_VALUE] != nil)?[dict_ objectForKey:MMAPPING_VALUE]:@""];
				
                sqlite3_bind_text(bulkStmt, 4, _mappingValue, strlen(_mappingValue), SQLITE_TRANSIENT);
				
				char * _value = [appDelegate convertStringIntoChar:value];
                
                sqlite3_bind_text(bulkStmt, 5, _value, strlen(_value), SQLITE_TRANSIENT);
				
				char * _flag = [appDelegate convertStringIntoChar:flag];
                
                sqlite3_bind_text(bulkStmt, 6, _flag, strlen(_flag), SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 7, ++id_value);
                
                //Aparna: FORMFILL (ADDITIONAL MAPPING SUPPORT)
                char * _prefrence2 = [appDelegate convertStringIntoChar:([dict_ objectForKey:MMAPPING_PREFERENCE2] != nil)?[dict_ objectForKey:MMAPPING_PREFERENCE2]:@""];
                sqlite3_bind_text(bulkStmt, 8, _prefrence2, strlen(_prefrence2), SQLITE_TRANSIENT);
                
                char * _prefrence3 = [appDelegate convertStringIntoChar:([dict_ objectForKey:MMAPPING_PREFERENCE3] != nil)?[dict_ objectForKey:MMAPPING_PREFERENCE3]:@""];
                sqlite3_bind_text(bulkStmt, 9, _prefrence3, strlen(_prefrence3), SQLITE_TRANSIENT);

                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed - SFOBJECTMAPCOMPONENT!\n");
                }
                
                sqlite3_clear_bindings(bulkStmt);
                sqlite3_reset(bulkStmt);
                
            }
            
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFOBJECTMAPCOMPONENT"
                                                                 andRecordCount:[sfObject_com count]];
            [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[sfObject_com count]];

        }
        synchronized_sqlite3_finalize(bulkStmt);
        [self endTransaction];
    }
    
    [self insertValuesInToLookUpTable:processDictionary];
}


- (void) insertValuesInToLookUpTable:(NSMutableDictionary *)processDictionary
{
    int id_value = 0;
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFNamedSearch ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'default_lookup_column' VARCHAR, 'search_name' VARCHAR, 'object_name' VARCHAR, 'search_type' VARCHAR, 'named_search_id' VARCHAR, 'no_of_lookup_records' VARCHAR, 'is_default' VARCHAR, 'is_standard' VARCHAR, 'search_sfid' VARCHAR)"]];
    if (result == YES)
    {
        result = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS SFNamedSearchIndex ON SFNamedSearch (default_lookup_column, object_name, is_default,is_standard)"]];

        
        NSArray * sfNamedSearch = [processDictionary objectForKey:MSFNAMEDSEARCH];
        
        [self beginTransaction];
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@' ,'%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6,?7, ?8, ?9, ?10)", SFNAMEDSEARCH, MDEFAULT_LOOKUP_COLUMN, MOBJECT_NAME, MSEARCH_NAME, MSEARCH_TYPE, MNAMED_SEARCHID, MNO_OF_LOOKUP_RECORDS, MIS_DEFAULT, MIS_STANDARD, MSEARCH_ID,MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);

        if (ret_value == SQLITE_OK)
        {
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFNAMEDSEARCH"
                                                                 andRecordCount:0];

            
            for (int i = 0; i < [sfNamedSearch count]; i++)
            {
                NSDictionary * nameSearchDict = [sfNamedSearch objectAtIndex:i];
				
				char * _defaultLookupColumn = [appDelegate convertStringIntoChar:([nameSearchDict objectForKey:MDEFAULT_LOOKUP_COLUMN] != nil)?[nameSearchDict objectForKey:MDEFAULT_LOOKUP_COLUMN]:@""];
                
                sqlite3_bind_text(bulkStmt, 1, _defaultLookupColumn, strlen(_defaultLookupColumn), SQLITE_TRANSIENT);
				
				char * _objectName = [appDelegate convertStringIntoChar:([nameSearchDict objectForKey:MOBJECT_NAME] != nil)?[nameSearchDict objectForKey:MOBJECT_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 2, _objectName, strlen(_objectName), SQLITE_TRANSIENT);
				
				char * _searchName = [appDelegate convertStringIntoChar:([nameSearchDict objectForKey:MSEARCH_NAME] != nil)?[nameSearchDict objectForKey:MSEARCH_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _searchName, strlen(_searchName), SQLITE_TRANSIENT);
				
				
				char * _searchType = [appDelegate convertStringIntoChar:([nameSearchDict objectForKey:MSEARCH_TYPE] != nil)?[nameSearchDict objectForKey:MSEARCH_TYPE]:@""];
                
                sqlite3_bind_text(bulkStmt, 4, _searchType, strlen(_searchType), SQLITE_TRANSIENT);
				
				
				char * _nameSearchID = [appDelegate convertStringIntoChar:([nameSearchDict objectForKey:MNAMED_SEARCHID] != nil)?[nameSearchDict objectForKey:MNAMED_SEARCHID]:@""];
                
                sqlite3_bind_text(bulkStmt, 5, _nameSearchID, strlen(_nameSearchID), SQLITE_TRANSIENT);
				
				char * _lookupRecords = [appDelegate convertStringIntoChar:([nameSearchDict objectForKey:MNO_OF_LOOKUP_RECORDS] != nil)?[nameSearchDict objectForKey:MNO_OF_LOOKUP_RECORDS]:@""];
                
                sqlite3_bind_text(bulkStmt, 6, _lookupRecords, strlen(_lookupRecords), SQLITE_TRANSIENT);
				
				char * _misDefault = [appDelegate convertStringIntoChar:([nameSearchDict objectForKey:MIS_DEFAULT] != nil)?[nameSearchDict objectForKey:MIS_DEFAULT]:@""];
                
                sqlite3_bind_text(bulkStmt, 7, _misDefault, strlen(_misDefault), SQLITE_TRANSIENT);
				
				char * _misStandard = [appDelegate convertStringIntoChar:([nameSearchDict objectForKey:MIS_STANDARD] != nil)?[nameSearchDict objectForKey:MIS_STANDARD]:@""];
                
                sqlite3_bind_text(bulkStmt, 8, _misStandard, strlen(_misStandard), SQLITE_TRANSIENT);
                //Radha - Defect Fix 6483
				char * _tempsearch_id = [appDelegate convertStringIntoChar:([nameSearchDict objectForKey:MSEARCH_ID] != nil)?[nameSearchDict objectForKey:MSEARCH_ID]:@""];
				
				sqlite3_bind_text(bulkStmt, 9, _tempsearch_id, strlen(_tempsearch_id), SQLITE_TRANSIENT);

                sqlite3_bind_int(bulkStmt, 10, ++id_value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed - SFNAMEDSEARCH!\n");
                }
                
                sqlite3_clear_bindings(bulkStmt);
                sqlite3_reset(bulkStmt);
                
            }
            
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFNAMEDSEARCH"
                                                                 andRecordCount:[sfNamedSearch count]];
            
            [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[sfNamedSearch count]];

        }
        synchronized_sqlite3_finalize(bulkStmt);
        [self endTransaction];
    }
    
     /* Shra-lookup */
    NSArray *filtersArray = [processDictionary objectForKey:@"SFNAMEDSEARCH_CRITERIA"];
    if (filtersArray != nil && [filtersArray count] > 0) {
        [self insertCriteriaComponents:filtersArray];
    }
    /* Shra-lookup ends */
   
    // Vipin-db-optmz
    result = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS SFNamedSearchIndex ON SFNamedSearch (default_lookup_column, object_name, is_default,is_standard)"]];

    
    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFNamedSearchComponent ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'expression_type' VARCHAR, 'field_name' VARCHAR, 'named_search' VARCHAR, 'search_object_field_type' VARCHAR,  'field_type' VARCHAR, 'field_relationship_name' VARCHAR, 'sequence' VARCHAR)"]];
              
    id_value = 0;
    if (result == YES)
    {
        result = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS SFNamedSearchComponentIndex ON SFNamedSearchComponent (field_name, search_object_field_type, sequence,field_type,field_relationship_name )"]];

       /* Shra-lookup */
        NSMutableArray *filterComponentsArray = [[NSMutableArray alloc] init];
        /* Shra-lookup ends */
      

        NSArray * sfNameSearchComp = [processDictionary objectForKey:MSFNAMEDSEARCH_COMPONENT];
        
        [self beginTransaction];
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@' ) VALUES (?1, ?2, ?3, ?4, ?5, ?6,?7, ?8)", SFNAMEDSEACHCOMPONENT, MEXPRESSION_TYPE, MFIELD_NAME, MNAMED_SEARCH, MSEARCH_OBJECT_FIELD, MFIELD_TYPE, MFIELD_RELATIONSHIPNAME, MSEQUENCE, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        if (ret_value == SQLITE_OK)
        {
            
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFNAMEDSEACHCOMPONENT"
                                                                 andRecordCount:0];

            
            for (int i = 0; i < [sfNameSearchComp count]; i++)
            {
                NSDictionary * nameSearchComp = [sfNameSearchComp objectAtIndex:i];
                
                /* Shra-lookup */
                NSString *expType = [nameSearchComp objectForKey:MEXPRESSION_TYPE];
                if ([expType isEqualToString:@"LKUP_Prefilter_Criteria"] || [expType isEqualToString:@"LKUP_Criteria"]) {
                    [filterComponentsArray addObject:nameSearchComp];
                }
                /*Shra-lookup ends*/
                
                NSString * relationshipName = ([nameSearchComp objectForKey:MFIELD_RELATIONSHIPNAME] != nil)?[nameSearchComp objectForKey:MFIELD_RELATIONSHIPNAME]:@"";
                if (![relationshipName isEqualToString:@"LKUP_Criteria"])
                    relationshipName = [relationshipName stringByReplacingOccurrencesOfString:@"__r" withString:@"__c"];
				
				char * _expressionType = [appDelegate convertStringIntoChar:([nameSearchComp objectForKey:MEXPRESSION_TYPE] != nil)?[nameSearchComp objectForKey:MEXPRESSION_TYPE]:@""];
                
                sqlite3_bind_text(bulkStmt, 1, _expressionType, strlen(_expressionType), SQLITE_TRANSIENT);
				
				char * _fieldName = [appDelegate convertStringIntoChar:([nameSearchComp objectForKey:MFIELD_NAME] != nil)?[nameSearchComp objectForKey:MFIELD_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 2, _fieldName, strlen(_fieldName), SQLITE_TRANSIENT);
				
				char * _namedSearch = [appDelegate convertStringIntoChar:([nameSearchComp objectForKey:MNAMED_SEARCH] != nil)?[nameSearchComp objectForKey:MNAMED_SEARCH]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _namedSearch, strlen(_namedSearch), SQLITE_TRANSIENT);
				
				char * _searchObjectField = [appDelegate convertStringIntoChar:([nameSearchComp objectForKey:MSEARCH_OBJECT_FIELD] != nil)?[nameSearchComp objectForKey:MSEARCH_OBJECT_FIELD]:@""];
                
                sqlite3_bind_text(bulkStmt, 4, _searchObjectField, strlen(_searchObjectField), SQLITE_TRANSIENT);
				
				char * _fieldType = [appDelegate convertStringIntoChar:([nameSearchComp objectForKey:MFIELD_TYPE] != nil)?[nameSearchComp objectForKey:MFIELD_TYPE]:@""];
                
                sqlite3_bind_text(bulkStmt, 5, _fieldType, strlen(_fieldType), SQLITE_TRANSIENT);
																		
				char * _relationshipName = [appDelegate convertStringIntoChar:relationshipName];														
                sqlite3_bind_text(bulkStmt, 6, _relationshipName, strlen(_relationshipName), SQLITE_TRANSIENT);
				
				char * _sequence = [appDelegate convertStringIntoChar:([nameSearchComp objectForKey:MSEQUENCE] != nil)?[nameSearchComp objectForKey:MSEQUENCE]:@""];
																		
                sqlite3_bind_text(bulkStmt, 7, _sequence, strlen(_sequence), SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 8, ++id_value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed - SFNAMEDSEACHCOMPONENT!\n");
                }
                
                sqlite3_clear_bindings(bulkStmt);
                sqlite3_reset(bulkStmt);
            }
            
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFNAMEDSEACHCOMPONENT"
                                                                 andRecordCount:[sfNameSearchComp count]];
            
            [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[sfNameSearchComp count]];

        }
        synchronized_sqlite3_finalize(bulkStmt);
        [self endTransaction];
        
         /* Shra-lookup - inserting the filterComponent */
        if ([filterComponentsArray count] > 0) {
            [self insertFilterComponents:filterComponentsArray];
        }
        [filterComponentsArray release];
        filterComponentsArray = nil;

    }
    
    // Vipin-db-optmz
    result = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS SFNamedSearchComponentIndex ON SFNamedSearchComponent (field_name, search_object_field_type, sequence,field_type,field_relationship_name )"]];

    [self insertValuesIntoProcessBusinessRuleTable:processDictionary];
    [self insertValuesIntoBusinessRuleTable:processDictionary];
    appDelegate.wsInterface.didGetPageDataDb = TRUE;
}

- (void) insertValuesIntoProcessBusinessRuleTable:(NSDictionary *)processDictionary
{
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS ProcessBusinessRule ('Id' VARCHAR PRIMARY KEY NOT NULL  UNIQUE, 'business_rule' VARCHAR, 'error_msg' VARCHAR, 'name' VARCHAR,  'process_node_object' VARCHAR, 'sequence' VARCHAR, 'target_manager' VARCHAR)"]];
    
    if (result == YES)
    {
        result = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS ProcessBusinessRuleIndex ON ProcessBusinessRule (business_rule, error_msg, sequence,process_node_object,target_manager )"]];
        
        NSArray * processBusinessRules = [processDictionary objectForKey:SFM_PROCESS_BUSINESS_RULE];
        [self beginTransaction];
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6,?7)", SFPROCESSBUSINESSRULE, @"Id", @"business_rule", @"error_msg", @"name", @"process_node_object", @"sequence", @"target_manager"];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        if (ret_value == SQLITE_OK)
        {
            for (int i = 0; i < [processBusinessRules count]; i++)
            {
                NSDictionary * processBusinessRule = [processBusinessRules objectAtIndex:i];
                
                NSString * processBusinessRuleID = ([processBusinessRule objectForKey:@"Id"] != nil)?[processBusinessRule objectForKey:@"Id"]:@"";
				char * _ruleID = [appDelegate convertStringIntoChar:processBusinessRuleID];
                sqlite3_bind_text(bulkStmt, 1, _ruleID, strlen(_ruleID), SQLITE_TRANSIENT);
				
                NSString * businessRule = ([processBusinessRule objectForKey:@"business_rule"] != nil)?[processBusinessRule objectForKey:@"business_rule"]:@"";
				char * _businessRule = [appDelegate convertStringIntoChar:businessRule];
                sqlite3_bind_text(bulkStmt, 2, _businessRule, strlen(_businessRule), SQLITE_TRANSIENT);
                
				NSString * errorMessage = ([processBusinessRule objectForKey:@"error_msg"] != nil)?[processBusinessRule objectForKey:@"error_msg"]:@"";
				char * _errorMessage = [appDelegate convertStringIntoChar:errorMessage];
                sqlite3_bind_text(bulkStmt, 3, _errorMessage, strlen(_errorMessage), SQLITE_TRANSIENT);
                
				NSString * name = ([processBusinessRule objectForKey:@"name"] != nil)?[processBusinessRule objectForKey:@"name"]:@"";
				char * _name = [appDelegate convertStringIntoChar:name];
                sqlite3_bind_text(bulkStmt, 4, _name, strlen(_name), SQLITE_TRANSIENT);
                
				NSString * processNodeObject = ([processBusinessRule objectForKey:@"process_node_object"] != nil)?[processBusinessRule objectForKey:@"process_node_object"]:@"";
				char * _processNodeObject = [appDelegate convertStringIntoChar:processNodeObject];
                sqlite3_bind_text(bulkStmt, 5, _processNodeObject, strlen(_processNodeObject), SQLITE_TRANSIENT);
                
                NSString * sequence = ([processBusinessRule objectForKey:@"sequence"] != nil)?[processBusinessRule objectForKey:@"sequence"]:@"";
				char * _sequence = [appDelegate convertStringIntoChar:sequence];
                sqlite3_bind_text(bulkStmt, 6, _sequence, strlen(_sequence), SQLITE_TRANSIENT);
                
				NSString * targetManager = ([processBusinessRule objectForKey:@"target_manager"] != nil)?[processBusinessRule objectForKey:@"target_manager"]:@"";
				char * _targetManager = [appDelegate convertStringIntoChar:targetManager];
                sqlite3_bind_text(bulkStmt, 7, _targetManager, strlen(_targetManager), SQLITE_TRANSIENT);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed!\n");
                }
                sqlite3_clear_bindings(bulkStmt);
                sqlite3_reset(bulkStmt);
            }
        }
        synchronized_sqlite3_finalize(bulkStmt);
        [self endTransaction];
    }
}
- (void) insertValuesIntoBusinessRuleTable:(NSDictionary *)processDictionary
{
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS BusinessRule ('Id' VARCHAR PRIMARY KEY  NOT NULL  UNIQUE ,'advanced_expression' VARCHAR, 'description' VARCHAR, 'error_msg' VARCHAR, 'message_type' VARCHAR,  'name' VARCHAR, 'process_ID' VARCHAR, 'source_object_name' VARCHAR)"]];
    
    if (result == YES)
    {
        result = [self createTable:[NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS BusinessRuleIndex ON BusinessRule (Id, description, error_msg,message_type,name,process_ID,source_object_name )"]];
        
        NSArray * sfmBusinessRule = [processDictionary objectForKey:SFM_BUSINESS_RULE];
        
        [self beginTransaction];
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8)", SFBUSINESSRULE, @"Id", @"advanced_expression", @"description", @"error_msg", @"message_type", @"name", @"process_ID", @"source_object_name"];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        if (ret_value == SQLITE_OK)
        {
            for (int i = 0; i < [sfmBusinessRule count]; i++)
            {
                NSDictionary * businessRule = [sfmBusinessRule objectAtIndex:i];
                
                NSString * recordId = ([businessRule objectForKey:@"Id"] != nil)?[businessRule objectForKey:@"Id"]:@"";
				char * _recordId = [appDelegate convertStringIntoChar:recordId];
                sqlite3_bind_text(bulkStmt, 1, _recordId, strlen(_recordId), SQLITE_TRANSIENT);
				
                NSString *advExpression = ([businessRule objectForKey:@"advanced_expression"] != nil)?[businessRule objectForKey:@"advanced_expression"]:@"";
                
				char * _advExpression = [appDelegate convertStringIntoChar:advExpression];
                
                sqlite3_bind_text(bulkStmt, 2, _advExpression, strlen(_advExpression), SQLITE_TRANSIENT);
				
                NSString * description = ([businessRule objectForKey:@"description"] != nil)?[businessRule objectForKey:@"description"]:@"";
				char * _description = [appDelegate convertStringIntoChar:description];
                
                sqlite3_bind_text(bulkStmt, 3, _description, strlen(_description), SQLITE_TRANSIENT);
				
                
                NSString *errorMsg = ([businessRule objectForKey:@"error_msg"] != nil)?[businessRule objectForKey:@"error_msg"]:@"";
				char * _errorMsg = [appDelegate convertStringIntoChar:errorMsg];
                
                sqlite3_bind_text(bulkStmt, 4, _errorMsg, strlen(_errorMsg), SQLITE_TRANSIENT);
				
                NSString *messageType = ([businessRule objectForKey:@"message_type"] != nil)?[businessRule objectForKey:@"message_type"]:@"";
				char * _messageType = [appDelegate convertStringIntoChar:messageType];
                sqlite3_bind_text(bulkStmt, 5, _messageType, strlen(_messageType), SQLITE_TRANSIENT);
                
                NSString *name = ([businessRule objectForKey:@"name"] != nil)?[businessRule objectForKey:@"name"]:@"";
				char * _name = [appDelegate convertStringIntoChar:name];
                sqlite3_bind_text(bulkStmt, 6, _name, strlen(_name), SQLITE_TRANSIENT);
				
                NSString *processId = ([businessRule objectForKey:@"process_ID"] != nil)?[businessRule objectForKey:@"process_ID"]:@"";
				char * _processID = [appDelegate convertStringIntoChar:processId];
                sqlite3_bind_text(bulkStmt, 7, _processID, strlen(_processID), SQLITE_TRANSIENT);
                
                NSString *sourceObjectName = ([businessRule objectForKey:@"source_object_name"] != nil)?[businessRule objectForKey:@"source_object_name"]:@"";
				char * _sourceObjectName = [appDelegate convertStringIntoChar:sourceObjectName];
                sqlite3_bind_text(bulkStmt, 8, _sourceObjectName, strlen(_sourceObjectName), SQLITE_TRANSIENT);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed!\n");
                }
                sqlite3_clear_bindings(bulkStmt);
                sqlite3_reset(bulkStmt);
            }
        }
        synchronized_sqlite3_finalize(bulkStmt);
        [self endTransaction];
    }
}

- (void) insertValuesInToTagsTable:(NSMutableDictionary *)tagsDictionary
{
    
    SMLog(kLogLevelVerbose,@"  MetaSync insertValuesInToTagsTable starts: %@", [NSDate date]);
    int id_value = 0;
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS MobileDeviceTags ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'tag_id' VARCHAR, 'value' VARCHAR)"]];
    if (result == YES)
    {
    
        NSArray * keys = [tagsDictionary allKeys];
        NSArray * values = [tagsDictionary allValues];
        
        // Vipin-db-optmz
        [self beginTransaction];
        
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@' ) VALUES (?1, ?2, ?3)", MOBILEDEVICETAGS, MTAG_ID, MVALUEM, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);

        if (ret_value == SQLITE_OK)
        {
            
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"MobileDeviceTags"
                                                                 andRecordCount:0];

            
            for (int i = 0; i < [keys count]; i++)
            {
                NSString * value = ([values objectAtIndex:i] != nil)?[values objectAtIndex:i]:@"";
                value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
            
				char * _keys = [appDelegate convertStringIntoChar:[keys objectAtIndex:i]];
                
                sqlite3_bind_text(bulkStmt, 1, _keys, strlen(_keys),  SQLITE_TRANSIENT);
				
				char * _value = [appDelegate convertStringIntoChar:value];
                
                sqlite3_bind_text(bulkStmt, 2, _value, strlen(_value), SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 3, ++id_value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed - MobileDeviceTags!\n");
                }
                
                sqlite3_clear_bindings(bulkStmt);
                sqlite3_reset(bulkStmt);
            }
            
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"MobileDeviceTags"
                                                                 andRecordCount:[keys count]];
            
            [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[keys count]];

        }
        
        // Vipin-db-optmz
        synchronized_sqlite3_finalize(bulkStmt);
        [self endTransaction];

    }
    SMLog(kLogLevelVerbose,@"  MetaSync insertValuesInToTagsTable ends: %@", [NSDate date]);
    appDelegate.initial_sync_status =  SYNC_MOBILE_DEVICE_SETTINGS;
    appDelegate.Sync_check_in = FALSE;
    [appDelegate.wsInterface metaSyncWithEventName:MOBILE_DEVICE_SETTINGS eventType:SYNC values:nil];
}

- (void) insertValuesInToSettingsTable:(NSMutableDictionary *)settingsDictionary
{
    SMLog(kLogLevelVerbose,@"  MetaSync insertValuesInToSettingsTable processing starts: %@", [NSDate date]);
    int id_value = 0;
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS MobileDeviceSettings ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'setting_id' VARCHAR, 'value' VARCHAR)"]];
    
    // Vipin-db-optmz
    [self beginTransaction];
    
    
    if (result == YES)
    {
    
        NSArray * keys = [settingsDictionary allKeys];
        NSArray * values = [settingsDictionary allValues];
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@' ) VALUES (?1, ?2, ?3)", MOBILEDEVICESETTINGS, MSETTING_ID, MVALUEM, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        if (ret_value == SQLITE_OK)
        {
            
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"MobileDeviceSettings"
                                                                 andRecordCount:0];

            
            for (int i = 0; i < [keys count]; i++)
            {
				
				char * _keys = [appDelegate convertStringIntoChar:[keys objectAtIndex:i]];
                				
                sqlite3_bind_text(bulkStmt, 1, _keys, strlen(_keys),  SQLITE_TRANSIENT);
				
				char * _value = [appDelegate convertStringIntoChar:[values objectAtIndex:i]];
                
                sqlite3_bind_text(bulkStmt, 2, _value, strlen(_value), SQLITE_TRANSIENT);

				sqlite3_bind_int(bulkStmt, 3, ++id_value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed - MobileDeviceSettings!\n");
                }
                
                sqlite3_clear_bindings(bulkStmt);
                sqlite3_reset(bulkStmt);
            }
            
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"MobileDeviceSettings"
                                                                 andRecordCount:[keys count]];
            [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[keys count]];

        }
        
        synchronized_sqlite3_finalize(bulkStmt);
    }
    
    // Vipin-db-optmz
    [self endTransaction];
    
    
    SMLog(kLogLevelVerbose,@"  MetaSync insertValuesInToSettingsTable processing ends: %@", [NSDate date]);
    //Radha - 24/March
    appDelegate.settingsDict = [self getSettingsDictionary];

    
    [self generatePDFSettings];
    
}

- (void) insertValuesInToSFWizardsTable:(NSDictionary *)wizardDict
{
    SMLog(kLogLevelVerbose,@"  MetaSync insertValuesInToSFWizardsTable: processing starts: %@", [NSDate date]);
    int id_value = 0;
    
    // Vipin-db-optmz
    [self beginTransaction];
    
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFWizard ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 'object_name' VARCHAR, 'wizard_id' VARCHAR, 'expression_id' VARCHAR, 'wizard_description' VARCHAR, 'wizard_name' VARCHAR, 'wizard_layout_row' DOUBLE, 'wizard_layout_column' DOUBLE, 'wizard_layout_id' VARCHAR )"]];//9366 Defect Fix

    if (result == YES)
    {
        NSArray * sfWizard = [wizardDict objectForKey:MSFW_wizard];
        
        NSString * _objectName = @"";
        
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@' ) VALUES (?1, ?2, ?3, ?4, ?5, ?6)", SFWIZARD, MOBJECT_NAME, MWIZARD_ID, MEXPRESSION_ID, MWIZARD_DESCRIPTION,MWIZARD_NAME, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        if (ret_value == SQLITE_OK)
        {
            
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFWizard"
                                                                 andRecordCount:0];

        
            for (int i = 0; i < [sfWizard count]; i++)
            {
                NSDictionary * dict = [sfWizard objectAtIndex:i];
                
                _objectName = ([dict objectForKey:MOBJECT_NAME] != nil)?[dict objectForKey:MOBJECT_NAME]:@"";
				
				char * _objectName_temp = [appDelegate convertStringIntoChar:_objectName];
               
                sqlite3_bind_text(bulkStmt, 1, _objectName_temp, strlen(_objectName_temp), SQLITE_TRANSIENT);
				
				char * _WizardId = [appDelegate convertStringIntoChar:([dict objectForKey:MWIZARD_ID] != nil)?[dict objectForKey:MWIZARD_ID]:@""];
				
                sqlite3_bind_text(bulkStmt, 2, _WizardId, strlen(_WizardId), SQLITE_TRANSIENT);
				
				char * _expressionId = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _expressionId, strlen(_expressionId), SQLITE_TRANSIENT);
				
				char * _wizardDescription = [appDelegate convertStringIntoChar:([dict objectForKey:MWIZARD_DESCRIPTION] != nil)?[dict objectForKey:MWIZARD_DESCRIPTION]:@""];
                
                sqlite3_bind_text(bulkStmt, 4, _wizardDescription, strlen(_wizardDescription), SQLITE_TRANSIENT);
				
				
				char * _wizardName = [appDelegate convertStringIntoChar:([dict objectForKey:MWIZARD_NAME] != nil)?[dict objectForKey:MWIZARD_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 5, _wizardName, strlen(_wizardName), SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 6, ++id_value);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed - SFWizard!\n");
                }
                
                sqlite3_clear_bindings(bulkStmt);
                sqlite3_reset(bulkStmt);

            }
            
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFWizard"
                                                                 andRecordCount:[sfWizard count]];
            
            [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[sfWizard count]];

        }
        
         synchronized_sqlite3_finalize(bulkStmt);
        
        //9366 - Defect Fix
        [self updateWizardLayoutSequenceIntoWizardTable:[wizardDict objectForKey:MSFW_WIZARD_LAYOUT]];
    }
    
    
    //8890
    //Adding sequence column to wizard component table
    result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFWizardComponent ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 'wizard_id' VARCHAR, 'action_id' VARCHAR, 'action_description' VARCHAR, 'expression_id' VARCHAR, 'process_id' VARCHAR, 'action_type' VARCHAR, 'perform_sync' VARCHAR, 'class_name' VARCHAR, 'method_name' VARCHAR, 'wizard_step_id' VARCHAR,'sequence' DOUBLE)"]];
    if (result == YES)
    {
        //8890
        [Utility setSequenceColoumntrue];
        
        NSArray * sfWizComponent = [wizardDict objectForKey:MSFW_wizard_steps];
        NSArray *customActionsArray = [wizardDict objectForKey:SFW_Custom_Actions];
        
        id_value = 0;
        NSString * wProcessId = @"";
        
        NSString * emptyString = @"";
        
        //8890
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@','%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11,?12)", SFWIZARDCOMPONENT, MWIZARD_ID, MACTION_ID, MACTION_DESCRIPTION, MEXPRESSION_ID, MPROCESS_ID, MACTION_TYPE, MLOCAL_ID,MPERFORM_SYNC, @"class_name",@"method_name", MWIZARD_STEP_ID,@"sequence"];
        
        sqlite3_stmt * bulkStmt;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        if (ret_value == SQLITE_OK)
        {
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFWizardComponent"
                                                                 andRecordCount:0];

            
            for (int i = 0; i < [sfWizComponent count]; i++)
            {
                wProcessId = @"";
                
                NSDictionary * comp_dict = [sfWizComponent objectAtIndex:i];
                NSString * processId = [comp_dict objectForKey:@"process_id"]; 
                NSDictionary *customDict = nil;
                if(processId != nil)
                {
                    for(NSDictionary *dict in customActionsArray)
                    {
                        NSString *customProcessId = [dict objectForKey:@"Id"];
                        if([customProcessId isEqualToString:processId])
                        {
                            customDict = dict;
                            break;
                        }
                    }
                }
                NSString *className = nil; 
                NSString *methodName = nil;
                if(customDict != nil)
                {
                    className = [customDict objectForKey:@"class_name"];
                    methodName = [customDict objectForKey:@"method_name"];
                }
                BOOL isCustomAction = NO;
                if((className  != nil) || (methodName != nil))
                    isCustomAction = YES;
                className = (className != nil) ? className : @"";
                methodName = (methodName != nil) ? methodName : @"";
                
                NSString * wizard_processId = ([comp_dict objectForKey:MPROCESS_ID] != nil)?[comp_dict objectForKey:MPROCESS_ID]:@"";
                
                SMLog(kLogLevelVerbose,@"%@", wizard_processId);
                
                if ([wizard_processId length] > 0)
                {
                    //Added to support memory fix.
                    NSString *query = [NSString stringWithFormat:@"SELECT process_id from SFProcess where sfID = '%@'",wizard_processId];
                    sqlite3_stmt * statement;
                    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
                    {
                        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
                        {
                            char * value = (char *) synchronized_sqlite3_column_text(statement, 0);
                            if(value != nil)
                            {
                                NSString *columnValue = [NSString stringWithUTF8String:value];
                                if(columnValue != nil)
                                    wProcessId = columnValue;
                                
                            }
                            
                        }
                    }
                }
                NSString *performSync = [comp_dict objectForKey:MPERFORM_SYNC];
				
				
				char * _wizardId = [appDelegate convertStringIntoChar:([comp_dict objectForKey:MWIZARD_ID] != nil)?[comp_dict objectForKey:MWIZARD_ID]:@""];
				
                sqlite3_bind_text(bulkStmt, 1, _wizardId, strlen(_wizardId), SQLITE_TRANSIENT);
				
				char * _emptyString = [appDelegate convertStringIntoChar:emptyString];
                
                sqlite3_bind_text(bulkStmt, 2, _emptyString, strlen(_emptyString), SQLITE_TRANSIENT);
				
				char * _wizardStepName = [appDelegate convertStringIntoChar:([comp_dict objectForKey:MWIZARD_STEP_NAME]!= nil)?[comp_dict objectForKey:MWIZARD_STEP_NAME]:@""];
                
                sqlite3_bind_text(bulkStmt, 3, _wizardStepName, strlen(_wizardStepName), SQLITE_TRANSIENT);
				
				char * _expressionId = [appDelegate convertStringIntoChar:([comp_dict objectForKey:MEXPRESSION_ID] != nil)?[comp_dict objectForKey:MEXPRESSION_ID]:@""];
                
                sqlite3_bind_text(bulkStmt, 4, _expressionId, strlen(_expressionId), SQLITE_TRANSIENT);
				
				char * _wProcessId = [appDelegate convertStringIntoChar:wProcessId];
                
                sqlite3_bind_text(bulkStmt, 5, _wProcessId, strlen(_wProcessId), SQLITE_TRANSIENT);
                if(isCustomAction)
					
                    sqlite3_bind_text(bulkStmt, 6, [SFW_Custom_Actions UTF8String], [SFW_Custom_Actions length], SQLITE_TRANSIENT);
                else
                    sqlite3_bind_text(bulkStmt, 6, [SFM UTF8String], [SFM length], SQLITE_TRANSIENT);
                
                sqlite3_bind_int(bulkStmt, 7, ++id_value);
				char * _performSync = [appDelegate convertStringIntoChar:performSync];
                
                sqlite3_bind_text(bulkStmt, 8, _performSync, strlen(_performSync), SQLITE_TRANSIENT);
				
				char * _className = [appDelegate convertStringIntoChar:className];
				
                sqlite3_bind_text(bulkStmt, 9, _className, strlen(_className), SQLITE_TRANSIENT);
				
				char * _methodName = [appDelegate convertStringIntoChar:methodName];
				
                sqlite3_bind_text(bulkStmt, 10, _methodName, strlen(_methodName), SQLITE_TRANSIENT);
				
				char * step_id = [appDelegate convertStringIntoChar:([comp_dict objectForKey:MWIZARD_STEP_ID] != nil)?[comp_dict objectForKey:MWIZARD_STEP_ID]:@""];
				
				sqlite3_bind_text(bulkStmt, 11, step_id, strlen(step_id), SQLITE_TRANSIENT);
                
                //8890
                NSString *sequence = [comp_dict objectForKey:@"sequence"];
                if ([sequence length] <= 0) {
                    sequence = @"0";
                }
                double _sequence = [sequence doubleValue];
                sqlite3_bind_double(bulkStmt, 12, _sequence);
                
                if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
                {
                    SMLog(kLogLevelError,@"Commit Failed - SFWizardComponent!\n");
                }
                
                sqlite3_clear_bindings(bulkStmt);
                sqlite3_reset(bulkStmt);
                
            }
            
            synchronized_sqlite3_finalize(bulkStmt);
            // Vipin-db-optmz
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFWizardComponent"
                                                                 andRecordCount:[sfWizComponent count]];
            
            [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[sfWizComponent count]];

        
        }
		[self updateWebserviceNameInWizarsTable:[wizardDict objectForKey:SFW_Sync_Override]];
    }
    
    
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@'", MSFExpression];
    int count = 0;
    sqlite3_stmt * statement;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, nil) == SQLITE_OK  )
    {
        if(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(statement, 0);
        }
    }
    id_value = count;
    synchronized_sqlite3_finalize(statement);
    NSArray * sfExpression = [wizardDict objectForKey:MSFExpression];
    
    
    NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3,   ?4)", SFEXPRESSION, MEXPRESSION_ID , MEXPRESSION_NAME, MEXPRESSION, MLOCAL_ID];
    
    sqlite3_stmt * bulkStmt;
    
    int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
    
    if (ret_value == SQLITE_OK)
    {
        // Vipin-db-optmz
        [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFEXPRESSION"
                                                             andRecordCount:0];

        
        for (int i = 0; i < [sfExpression count]; i++)
        {
            NSDictionary * dict = [sfExpression objectAtIndex:i];
			
			
			char * _expressionId = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@""];
            
            sqlite3_bind_text(bulkStmt, 1, _expressionId, strlen(_expressionId), SQLITE_TRANSIENT);
			
			char * _expressionName = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_NAME] != nil)?[dict objectForKey:MEXPRESSION_NAME]:@""];
            
            sqlite3_bind_text(bulkStmt, 2, _expressionName, strlen(_expressionName), SQLITE_TRANSIENT);
			
			char * _advanceExpression = [appDelegate convertStringIntoChar:([dict objectForKey:MADVANCE_EXPRESSION] != nil)?[dict objectForKey:MADVANCE_EXPRESSION]:@""];
            
            sqlite3_bind_text(bulkStmt, 3, _advanceExpression, strlen(_advanceExpression), SQLITE_TRANSIENT);
            
            sqlite3_bind_int(bulkStmt, 4, ++id_value);
            
            if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
            {
                SMLog(kLogLevelError,@"Commit Failed - SFEXPRESSION!\n");
            }
            
            sqlite3_clear_bindings(bulkStmt);
            sqlite3_reset(bulkStmt);
        }
        
        // Vipin-db-optmz
        [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFEXPRESSION"
                                                             andRecordCount:[sfExpression count]];
        
        [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[sfExpression count]];

    }
    
    synchronized_sqlite3_finalize(bulkStmt);

    query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@'", SFEXPRESSION_COMPONENT];
    int count1 = 0;
    sqlite3_stmt * stmt;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        if(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            count1 = synchronized_sqlite3_column_int(stmt, 0);
        }
    }
    id_value = count1;
    synchronized_sqlite3_finalize(stmt);
    
    NSArray * sfExpression_com = [wizardDict objectForKey:MSFExpression_component];
    bulkQueryStmt = @"";
    
    bulkStmt=  nil;
    
    bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3,  ?4, ?5, ?6)", SFEXPRESSIONCOMPONENT, MEXPRESSION_ID, MCOMPONENT_SEQ_NUM, MCOMPONENT_LHS, MCOMPONENT_RHS, MOPERATOR, MLOCAL_ID];
    
    
    ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
    
    if (ret_value == SQLITE_OK)
    {
        // Vipin-db-optmz
        [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFEXPRESSIONCOMPONENT-2"
                                                             andRecordCount:0];

        
        for (int i = 0; i < [sfExpression_com count]; i++)
        {
            NSDictionary * dict = [sfExpression_com objectAtIndex:i];
			
			char * _expressionId = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@""];
        
            sqlite3_bind_text(bulkStmt, 1, _expressionId, strlen(_expressionId), SQLITE_TRANSIENT);
			
			char * _sequence = [appDelegate convertStringIntoChar:([dict objectForKey:MSEQUENCE] != nil)?[dict objectForKey:MSEQUENCE]:@""];
            
            sqlite3_bind_text(bulkStmt, 2, _sequence, strlen(_sequence), SQLITE_TRANSIENT);
			
			
			char * _sourceFieldName = [appDelegate convertStringIntoChar:([dict objectForKey:MSOURCE_FIELD_NAME] != nil)?[dict objectForKey:MSOURCE_FIELD_NAME]:@""];
            
            sqlite3_bind_text(bulkStmt, 3, _sourceFieldName, strlen(_sourceFieldName), SQLITE_TRANSIENT);
			
			char * _value = [appDelegate convertStringIntoChar:([dict objectForKey:MVALUEM] != nil)?[dict objectForKey:MVALUEM]:@""];
            
            sqlite3_bind_text(bulkStmt, 4, _value, strlen(_value), SQLITE_TRANSIENT);
			
			char * _operator = [appDelegate convertStringIntoChar:([dict objectForKey:MOPERATOR] != nil)?[dict objectForKey:MOPERATOR]:@""];
            
            sqlite3_bind_text(bulkStmt, 5, _operator, strlen(_operator), SQLITE_TRANSIENT);
            
            sqlite3_bind_int(bulkStmt, 6, ++id_value);
            
            if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
            {
                SMLog(kLogLevelError,@"Commit Failed - SFEXPRESSIONCOMPONENT!\n");
            }
            sqlite3_clear_bindings(bulkStmt);
            sqlite3_reset(bulkStmt);
        
        }
        
        // Vipin-db-optmz
        [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFEXPRESSIONCOMPONENT-2"
                                                             andRecordCount:[sfExpression_com count]];
        [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[sfExpression_com count]];

    }
    SMLog(kLogLevelVerbose,@"  MetaSync insertValuesInToSFWizardsTable: processing ends: %@", [NSDate date]);
    synchronized_sqlite3_finalize(bulkStmt);
    // Vipin-db-optmz
    [self endTransaction];
    
    appDelegate.initial_sync_status = SYNC_MOBILE_DEVICE_TAGS;
    appDelegate.Sync_check_in = FALSE;
    [appDelegate.wsInterface metaSyncWithEventName:MOBILE_DEVICE_TAGS eventType:SYNC values:nil];
}

//9366 Defect Fix - Updating layout configuration details
- (void) updateWizardLayoutSequenceIntoWizardTable:(NSArray *)wizardLayout
{
    [self beginTransaction];
	
	NSString * queryStatement = [NSString stringWithFormat:@"UPDATE %@ SET %@ = ?, %@ = ?, %@ = ? WHERE %@ = ?",SFWIZARD, @"wizard_layout_row", @"wizard_layout_column", @"wizard_layout_id", MWIZARD_ID];
    
	sqlite3_stmt * bulkStatement = nil;
	   
	if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &bulkStatement, NULL) == SQLITE_OK)
	{
		for (NSDictionary * layoutDict in wizardLayout)
		{
            NSString * row = [layoutDict objectForKey:@"wizard_layout_row"];
            if ([row length] <= 0) {
                row = @"0";
            }
            double wizardRow = [row doubleValue];
            sqlite3_bind_double(bulkStatement, 1, wizardRow);
            
            
            NSString * column = [layoutDict objectForKey:@"wizard_layout_column"];
            if ([column length] <= 0) {
                column = @"0";
            }
            double wizardcolunm = [column doubleValue];
            sqlite3_bind_double(bulkStatement, 2, wizardcolunm);
            
            NSString * layoutId = [layoutDict objectForKey:@"wizard_layout_id"];
            
			char * wizardLayoutId = [appDelegate convertStringIntoChar:layoutId];
            
			sqlite3_bind_text(bulkStatement, 3, wizardLayoutId, strlen(wizardLayoutId), SQLITE_TRANSIENT);
            
            NSString * Id = [layoutDict objectForKey:MWIZARD_ID];
            
			char * wizardId = [appDelegate convertStringIntoChar:Id];
            
			sqlite3_bind_text(bulkStatement, 4, wizardId, strlen(wizardId), SQLITE_TRANSIENT);
            
            if (synchronized_sqlite3_step(bulkStatement) != SQLITE_DONE)
			{
				printf("Commit Failed - SFWIZARDCOMPONENT-WS_name !\n");
			}
            sqlite3_clear_bindings(bulkStatement);
			sqlite3_reset(bulkStatement);
		}
        [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[wizardLayout count]];
	}
    synchronized_sqlite3_finalize(bulkStatement);
    [self endTransaction];

}

            /* Shra-lookup */
/* Inserting filters defined for look up */
- (void)insertCriteriaComponents:(NSArray *)filterArray {

       [self beginTransaction];
    
        /* Create table if not exist */
        BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFNamedSearchFilters ('local_id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'Id' TEXT, 'name' TEXT, 'named_search_id' VARCHAR, 'rule_type' VARCHAR,  'parent_object_criteria' VARCHAR,'source_object_name' VARCHAR , 'field_name' VARCHAR, 'sequence' VARCHAR, 'advanced_expression' VARCHAR, 'allow_override' BOOLEAN , 'default_on' BOOLEAN, 'description' TEXT)"]];
        if (result) {
            /*Insert values into table */
            NSString *queryStatement = [NSString stringWithFormat:@"INSERT INTO SFNamedSearchFilters ('Id','name','named_search_id','rule_type','parent_object_criteria','source_object_name','field_name','sequence','advanced_expression','allow_override','default_on') VALUES (?1,?2,?3,?4,?5,?6,?7,?8,?9,?10,?11)"];
            
            sqlite3_stmt *insertStatement = nil;
            NSInteger success = synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &insertStatement, NULL);
            if (success == SQLITE_OK) {
               
                for (int counter = 0; counter < [filterArray count]; counter++) {
                    NSDictionary *filterDictionary = [filterArray objectAtIndex:counter];
                    int i = 1;
                    NSString *someString = [filterDictionary objectForKey:@"id"];
                    someString = someString ? someString:@"";
                    if ([someString isEqualToString:@""]) {
                        
                    }
                    BOOL exists =  [self checkIfGivenSFMId:someString existInTable:@"SFNamedSearchFilters" andFieldName:@"Id"];
                    if (exists) {
                        continue;
                    }
                    /* Check if Id already exists */
                    if (someString != nil) {
                        sqlite3_bind_text(insertStatement, i, [someString UTF8String], someString.length, SQLITE_TRANSIENT);
                    }
                    
                    someString = nil;
                    i++;
                    someString = [filterDictionary objectForKey:@"name"];
                    someString = someString ? someString:@"";
                    if (someString != nil) {
                        sqlite3_bind_text(insertStatement, i, [someString UTF8String], someString.length, SQLITE_TRANSIENT);
                    }
                    
                    someString = nil;
                    i++;
                    someString = [filterDictionary objectForKey:@"module"];
                    someString = someString ? someString:@"";
                    if (someString != nil) {
                        sqlite3_bind_text(insertStatement, i, [someString UTF8String], someString.length, SQLITE_TRANSIENT);
                    }
                    
                    someString = nil;
                    i++;
                    someString = [filterDictionary objectForKey:@"rule_type"];
                    someString = someString ? someString:@"";
                    if (someString != nil) {
                        sqlite3_bind_text(insertStatement, i, [someString UTF8String], someString.length, SQLITE_TRANSIENT);
                    }
                    
                    someString = nil;
                    i++;
                    someString = [filterDictionary objectForKey:@"parent_object_criteria"];
                    someString = someString ? someString:@"";
                    if (someString != nil) {
                        sqlite3_bind_text(insertStatement, i, [someString UTF8String], someString.length, SQLITE_TRANSIENT);
                    }
                    
                    someString = nil;
                    i++;
                    someString = [filterDictionary objectForKey:@"source_object_name"];
                    someString = someString ? someString:@"";
                    if (someString != nil) {
                        sqlite3_bind_text(insertStatement, i, [someString UTF8String], someString.length, SQLITE_TRANSIENT);
                    }
                    
                    someString = nil;
                    i++;
                    someString = [filterDictionary objectForKey:@"field_name"];
                    someString = someString ? someString:@"";
                    if (someString != nil) {
                        sqlite3_bind_text(insertStatement, i, [someString UTF8String], someString.length, SQLITE_TRANSIENT);
                    }
                    
                    someString = nil;
                    i++;
                    someString = [filterDictionary objectForKey:@"sequence"];
                    someString = someString ? someString:@"";
                    if (someString != nil) {
                        sqlite3_bind_text(insertStatement, i, [someString UTF8String], someString.length, SQLITE_TRANSIENT);
                    }
                    
                    someString = nil;
                    i++;
                    someString = [filterDictionary objectForKey:@"advanced_exp"];
                    someString = someString ? someString:@"";
                    if (someString != nil) {
                        sqlite3_bind_text(insertStatement, i, [someString UTF8String], someString.length, SQLITE_TRANSIENT);
                    }
                    
                    someString = nil;
                    i++;
                    someString = [filterDictionary objectForKey:@"default_on"];
                    someString = someString ? someString:@"";
                    someString = [someString lowercaseString];
                    if (someString != nil) {
                        sqlite3_bind_text(insertStatement, i, [someString UTF8String], someString.length, SQLITE_TRANSIENT);
                    }
                    
                    someString = nil;
                    i++;
                    someString = [filterDictionary objectForKey:@"allow_override"];
                    someString = someString ? someString:@"";
                    someString = [someString lowercaseString];
                    if (someString != nil) {
                        sqlite3_bind_text(insertStatement, i, [someString UTF8String], someString.length, SQLITE_TRANSIENT);
                    }
                    
                    someString = nil;
                    i++;
                    someString = [filterDictionary objectForKey:@"description"];
                    someString = someString ? someString:@"";
                    someString = [someString lowercaseString];
                    if (someString != nil) {
                        sqlite3_bind_text(insertStatement, i, [someString UTF8String], someString.length, SQLITE_TRANSIENT);
                    }
                    
                   int success =  sqlite3_step(insertStatement);
                    if (success == SQLITE_DONE || success == SQLITE_OK) {
                        SMLog(kLogLevelVerbose,@"Successfully inserted the Filter ");
                    }
                    else {
                        SMLog(kLogLevelError,@"Error while inserting the Filter");
                    }
                    sqlite3_reset(insertStatement);
                }
            }
            synchronized_sqlite3_finalize(insertStatement);
        }

        [self endTransaction];
}

- (void)insertFilterComponents:(NSArray *)filterComponents {
   
    /* start transaction */
    
    [self beginTransaction];
    
    /* Insert filter components into SFEXpression table*/
    BOOL result = [self createTable:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFExpressionComponent ('local_id' INTEGER PRIMARY KEY  NOT NULL ,'expression_id' VARCHAR,'component_sequence_number' VARCHAR,'component_lhs' VARCHAR,'component_rhs' VARCHAR,'operator'CHAR)"]];
    
    if (result == YES)
    {
        NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6)", SFEXPRESSIONCOMPONENT, MEXPRESSION_ID, MCOMPONENT_SEQ_NUM, MCOMPONENT_LHS, MCOMPONENT_RHS, MOPERATOR, MLOCAL_ID];
        
        sqlite3_stmt * bulkStmt = nil;
        
        int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);
        
        if (ret_value == SQLITE_OK)
        {
            for (int i = 0; i < [filterComponents count]; i++)
            {
                NSDictionary *filterComponent = [filterComponents objectAtIndex:i];
                int k = 0;
                /*Bind the statements */
                
                NSString *someString = nil;
                k++;
                someString = [filterComponent objectForKey:@"exp_rule"];
                someString = someString ? someString:@"";
               
                if (someString != nil) {
                    sqlite3_bind_text(bulkStmt, k, [someString UTF8String], someString.length, SQLITE_TRANSIENT);
                }
                
                someString = nil;
                k++;
                someString = [filterComponent objectForKey:@"sequence"];
                someString = someString ? someString:@"";
                if (someString != nil) {
                    sqlite3_bind_text(bulkStmt, k, [someString UTF8String], someString.length, SQLITE_TRANSIENT);
                }
                
                someString = nil;
                k++;
                someString = [filterComponent objectForKey:@"field_name"];
                someString = someString ? someString:@"";
                if (someString != nil) {
                    sqlite3_bind_text(bulkStmt, k, [someString UTF8String], someString.length, SQLITE_TRANSIENT);
                }

                someString = nil;
                k++;
                someString = [filterComponent objectForKey:@"operand"];
                someString = someString ? someString:@"";
                if (someString != nil) {
                    sqlite3_bind_text(bulkStmt, k, [someString UTF8String], someString.length, SQLITE_TRANSIENT);
                }
                
                someString = nil;
                k++;
                someString = [filterComponent objectForKey:@"operator"];
                someString = someString ? someString:@"";
                if (someString != nil) {
                    sqlite3_bind_text(bulkStmt, k, [someString UTF8String], someString.length, SQLITE_TRANSIENT);
                }
                
                k++;
                sqlite3_bind_int(bulkStmt, k, i + 3000);
                
                /*Executing the query */
                int success =  synchronized_sqlite3_step(bulkStmt);
                if (success == SQLITE_DONE || success == SQLITE_OK)
                {
                    SMLog(kLogLevelVerbose,@"SFEXpressionComponent insertion successful");
                }
                else {
                    SMLog(kLogLevelError,@"SFEXpressionComponent insertion failed..");
                }
                sqlite3_reset(bulkStmt);
            }
        }
        synchronized_sqlite3_finalize(bulkStmt);
    }
    /* end transaction */
    
    [self  endTransaction];
}


- (BOOL)checkIfGivenSFMId:(NSString *)sfmId
             existInTable:(NSString *)tableName
             andFieldName:(NSString *)fieldName {
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ where %@ = '%@'",tableName, fieldName, sfmId];
    sqlite3_stmt * stmt;
    int count = 0;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0);
        }
    }
    synchronized_sqlite3_finalize(stmt);
    
    if (count > 0) {
        return YES;
    }
    return NO;
}

#pragma mark - SYNC OVERRIDE
- (void) updateWebserviceNameInWizarsTable:(NSArray *)customArray
{
    // Vipin-db-optmz
    [self beginTransaction];
	
	NSString * queryStatement = [NSString stringWithFormat:@"UPDATE %@ SET %@ = ?, %@ = ? WHERE %@ = ?",SFWIZARDCOMPONENT, @"class_name", @"method_name", MWIZARD_STEP_ID];

	sqlite3_stmt * bulkStatement = nil;
	
	if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &bulkStatement, NULL) == SQLITE_OK)
	{
		for (NSDictionary * customDict in customArray)
		{
			NSString * service_name = ([customDict objectForKey:SERVICENAME] != nil)?[customDict objectForKey:SERVICENAME]:@"";
			
			NSString * className = @"";
			NSString * webserviceName = @"";
			
			if ([service_name length] > 0)
			{
				NSArray * array = [service_name componentsSeparatedByString:@"."];
				
				className = [array objectAtIndex:0];
				webserviceName = [array objectAtIndex:1];
			}
			
			
			char * tempclassName = [appDelegate convertStringIntoChar:className];
		
			sqlite3_bind_text(bulkStatement, 1, tempclassName, strlen(tempclassName), SQLITE_TRANSIENT);
	
			char * temserviceName = [appDelegate convertStringIntoChar:webserviceName];
			
			sqlite3_bind_text(bulkStatement, 2, temserviceName, strlen(temserviceName), SQLITE_TRANSIENT);
	
			char * tempId = [appDelegate convertStringIntoChar:([customDict objectForKey:MWIZARD_STEP_ID] != nil)?[customDict objectForKey:MWIZARD_STEP_ID]:@""];
			
			sqlite3_bind_text(bulkStatement, 3, tempId, strlen(tempId), SQLITE_TRANSIENT);
			
			if (synchronized_sqlite3_step(bulkStatement) != SQLITE_DONE)
			{
				printf("Commit Failed - SFWIZARDCOMPONENT-WS_name !\n");
			}
            sqlite3_clear_bindings(bulkStatement);
			sqlite3_reset(bulkStatement);
		}
            // Vipin-db-optmz
        [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[customArray count]]; 
	}
    // Vipin-db-optmz
    synchronized_sqlite3_finalize(bulkStatement);
    [self endTransaction];
    
}

- (void) attachSiganture:(NSString *)operation_type
{
	NSString *selectQuery = [NSString stringWithFormat:@"SELECT DISTINCT record_Id, object_api_name From SFSignatureData Where sign_type = 'ViewWorkOrder' and operation_type = '%@'",operation_type];
	
	
    sqlite3_stmt * stmt;
    
    NSString  * recordId = @"";
    NSString * objectapiName = @"";
    
    NSMutableDictionary * signatureData = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char *field = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_1);
            if ( field != nil )
                recordId = [NSString stringWithUTF8String:field];
            
            char *field1 = (char *) synchronized_sqlite3_column_text(stmt, COLUMN_2);
            if ( field1 != nil )
                objectapiName = [NSString stringWithUTF8String:field1];
            
            [signatureData setValue:objectapiName forKey:recordId];
        }
		synchronized_sqlite3_finalize(stmt);
    }
    
    NSArray * allkeys = [signatureData allKeys];
    
    for (int i = 0; i < [allkeys count]; i++)
    {
        [appDelegate.calDataBase getSFIdForSignature:[allkeys objectAtIndex:i] objectName:[signatureData objectForKey:[allkeys objectAtIndex:i]] signatureTyprId:@"" andSignType:@"ViewWorkOrder"];
		[appDelegate.calDataBase deleteSignatureDataWRTId:[allkeys objectAtIndex:i] type:operation_type];
    }
    
    appDelegate.wsInterface.didWriteSignature = YES;
}

#pragma mark - END


#pragma mark - getTags
- (NSMutableDictionary *) getTagsDictionary
{
    sqlite3_stmt * statement;
    
    // Vipin - MemOpt
    NSMutableDictionary * tagDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    @autoreleasepool
    {
        NSString * queryStatement = [NSString stringWithFormat:@"SELECT * FROM %@", MOBILEDEVICETAGS];
        
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
            {
                NSString * key = [NSString string];
                NSString * value = @"";
                char * _key = (char *) synchronized_sqlite3_column_text(statement, 1);
               
                if((_key !=nil) && strlen(_key))
                {
                    key = [NSString stringWithUTF8String:_key];
                }
                
                char * _value = (char *) synchronized_sqlite3_column_text(statement, 2);
                if ((_value != nil) && strlen(_value))
                {
                   value = [NSString stringWithUTF8String:_value];
                }
                
        
                //Handling for tags having same key and value.
                if ([value isEqualToString:key])
                {
                    value = @"";
                }
                //OAuth
                else if ([value Contains:key])
                {
                    value = @"";
                }

                if (![key isEqualToString:@""])
                    [tagDict setValue:value forKey:key];
            }
        }
        
        synchronized_sqlite3_finalize(statement);
    }
    return [tagDict autorelease];
}
#pragma End



- (NSMutableDictionary *) getSettingsDictionary
{
    sqlite3_stmt * statement;
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT * FROM %@", MOBILEDEVICESETTINGS];
    
    NSMutableDictionary * SeetingsDict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
        {
            NSString * key = @"";
            NSString * value = @"";
            char * _key = (char *) synchronized_sqlite3_column_text(statement, 1);
            
            if((_key !=nil) && strlen(_key))
            {
                key = [NSString stringWithUTF8String:_key];
            }
            
            char * _value = (char *) synchronized_sqlite3_column_text(statement, 2);
            if ((_value != nil) && strlen(_value))
            {
                value = [NSString stringWithUTF8String:_value];
            }
            
            if (![key isEqualToString:@""])
                [SeetingsDict setValue:value forKey:key];
        }
    }
    synchronized_sqlite3_finalize(statement);
    return SeetingsDict;
}

//Temperory Method - Removed After Data Sync is completed.
- (void) insertUsernameToUserTable:(NSString *)UserName
{
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT Username FROM User"];
    sqlite3_stmt * stmt;
    
    BOOL flag = FALSE;
    
    NSString * name = @"";
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
        {
            char * _name = (char *) synchronized_sqlite3_column_text(stmt, 0);
            if ((_name != nil) && strlen(_name))
                name = [NSString stringWithUTF8String:_name];
            
            if ([name isEqualToString:UserName])
            {
                flag = TRUE;
                break;
            }
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    [self beginTransaction];
    
    if (!flag)
    {
        // Mem_leak_fix - Vipindas 9493 Jan 18
        NSString * local_id = [[AppDelegate GetUUID] retain];
        UserName=[UserName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        queryStatement = [NSString stringWithFormat:@"INSERT INTO User (local_id, 'Username') VALUES ('%@', '%@')", local_id, UserName];
        
        [local_id release];
        
        char * err;
        if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                [MyPopoverDelegate performSelector:@selector(throwException)];
			SMLog(kLogLevelError,@"%@", queryStatement);
			SMLog(kLogLevelError,@"METHOD: insertUsernameToUserTable");
			SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
			[appDelegate printIfError:nil ForQuery:queryStatement type:INSERTQUERY];
        }
    }
    [self endTransaction];
}

- (void) updateUserTable:(NSString *)UserId Name:(NSString*)name
{
    if(appDelegate == nil)
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT Name,Id FROM User Where Username='%@'",appDelegate.username];
    sqlite3_stmt * stmt;
    BOOL flag=FALSE;
	
	NSString * username = @"";
	
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * _name = (char *) synchronized_sqlite3_column_text(stmt, 0);
            if ((_name != nil) && strlen(_name))
            {
		username = [NSString stringWithUTF8String:_name];
                flag=TRUE;
            }
            
            char * _id = (char *) synchronized_sqlite3_column_text(stmt, 1);
            if ((_id != nil) && strlen(_id))
            {
                flag=TRUE;
                
            }
                

        }
    }
    synchronized_sqlite3_finalize(stmt);
	
	if (![username isEqualToString:name])
	{
		flag = FALSE;
	}
	
    
    [self beginTransaction];
    if(!flag)
    {
        name=[name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *userName=[appDelegate.username stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *queryStatementUpdate = [NSString stringWithFormat:@"update User SET Id='%@',Name='%@' Where Username='%@' ",UserId ,name,userName];
            
            char * err;
            if (synchronized_sqlite3_exec(appDelegate.db, [queryStatementUpdate UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                    [MyPopoverDelegate performSelector:@selector(throwException)];
                SMLog(kLogLevelError,@"%@", queryStatementUpdate);
			SMLog(kLogLevelError,@"METHOD:updateUserTable " );
			SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
			[appDelegate printIfError:nil ForQuery:queryStatementUpdate type:UPDATEQUERY];
            }
    }
    
     [self endTransaction];
}
#pragma HelpFiles
-(void)updateUserLanguage:(NSString*)language
{
    if(appDelegate == nil)
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    NSString *userName=[appDelegate.username stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT LanguageLocaleKey FROM User Where Username='%@'",userName];
    sqlite3_stmt * stmt;
    BOOL flag=FALSE;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * _lang = (char *) synchronized_sqlite3_column_text(stmt, 0);
            if ((_lang != nil) && strlen(_lang))
            {
                flag=TRUE;
            }
            
        }
    }
    synchronized_sqlite3_finalize(stmt);
    if(!flag)
    {
        [self beginTransaction];
        NSString *queryStatementUpdate = [NSString stringWithFormat:@"update User SET LanguageLocaleKey='%@'  where Username='%@'", language,userName];
        
        char * err;
        if (synchronized_sqlite3_exec(appDelegate.db, [queryStatementUpdate UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                [MyPopoverDelegate performSelector:@selector(throwException)];
            SMLog(kLogLevelError,@"%@", queryStatementUpdate);
			SMLog(kLogLevelError,@"METHOD:updateUserLanguage" );
			SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
			[appDelegate printIfError:nil ForQuery:queryStatementUpdate type:UPDATEQUERY];
        }
        
        [self endTransaction];
    }

}

-(NSString*)checkUserLanguage
{
    NSString *language=@"";
    if(![appDelegate.language length]>0)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([[userDefaults objectForKey:@"UserLanguage"] length]>0)
        {
            language = [userDefaults objectForKey:@"UserLanguage"];
            SMLog(kLogLevelVerbose,@"User Full Name  = %@",language);
        }
        else
        {
            language=[self getUserLanguage:appDelegate.username];
        }
    }
    else
    {
        language=appDelegate.language;
    }
    return language;
}
-(NSString*)getUserLanguage:(NSString*)userName
{
    NSMutableString * query = [NSMutableString stringWithFormat:@"SELECT LanguageLocaleKey FROM User WHERE Username = '%@'", userName];
    sqlite3_stmt * stmt;
    NSString * queryStatement = @"";
    const char * _query = [query UTF8String];
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query,-1, &stmt, nil) == SQLITE_OK )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char *field1 = (char *) synchronized_sqlite3_column_text(stmt,COLUMN_1);
            if ((field1 != nil) && strlen(field1))
            {
                NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
                queryStatement = [NSString stringWithFormat:@"%@",field1Str];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    
    return queryStatement;        
    
}

#pragma mark - Delete All Tables
- (void) clearDatabase
{
    sqlite3_stmt *stmt;
    NSMutableArray * tables = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSString * queryStatemnt = [NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE type = 'table'"];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatemnt UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
        {
            char * _table = (char *) synchronized_sqlite3_column_text(stmt, 1);
            
            if ((_table != nil) && strlen(_table))
            {
                NSString * table_name = [NSString stringWithUTF8String:_table];
                if ((![table_name isEqualToString:@"sqlite_sequence"]))
                    [tables addObject:table_name];
            }
            
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    
    char * err;
    
    for (int i = 0; i < [tables count]; i++)
        {
            queryStatemnt = [NSString stringWithFormat:@"DROP TABLE '%@'", [tables objectAtIndex:i]];
            if (synchronized_sqlite3_exec(appDelegate.db, [queryStatemnt UTF8String], NULL, NULL, &err) != SQLITE_OK)
            {
                if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                    [MyPopoverDelegate performSelector:@selector(throwException)];
                SMLog(kLogLevelError,@"Failed to drop");
              
            }
        }
}

#pragma mark - ADD Source to target
-(void) insertSourceToTargetInToSFProcessComponent
{
    NSMutableArray * process_info = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    for (int i = 0; i < [processIdList count]; i++)
    {        
        NSString * queryStatement = [NSString stringWithFormat:@"SELECT process_type FROM SFProcess WHERE process_id = '%@'", [processIdList objectAtIndex:i]];
        sqlite3_stmt * statement;
        NSString * processType = @"";
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                const char * _type = (char *)synchronized_sqlite3_column_text(statement, 0);
                if (strlen(_type))
                    processType = [NSString stringWithUTF8String:_type];
            }
        }
        synchronized_sqlite3_finalize(statement);
        NSArray * keys = [NSArray arrayWithObjects:MPROCESS_ID, MLAYOUT_ID, TARGET_OBJECT_NAME, SOURCE_OBJECT_NAME, EXPRESSION_ID, OBJECT_MAPPING_ID, MCOMPONENT_TYPE, MPARENT_COLUMN, MVALUE_MAPPING_ID, @"source_child_parent_column",SORTING_ORDER, process_node_id, MDOC_TEMPLATE_DETAIL_ID,@"target_object_label",@"sfID", nil];// Damodar OPDoc
        NSString * processId = @"", * layoutId = @"", * sourceName = @"", * expressionId = @"", * oMappingId = @"",* componentType = @"", * parentColumn = @"", * targetName = @"", * vMappingid = @"", * source_child_column = @"" , * sorting_order_value = @"",      * processnode_id = @"", * doc_temp_detail_id = @"",*targetObjectLabel = @"",*sfID = @"";// Damodar OPDoc
        NSArray * objects;
        
        NSString * query = @"";
        if ([processType isEqualToString:SOURCETOTARGET])
        {
             query = [NSString stringWithFormat:@"SELECT * FROM SFprocess_test WHERE process_id = '%@'  AND (component_type = 'TARGET' or component_type =  'SOURCE')", [processIdList objectAtIndex:i]];
            sqlite3_stmt * stmt;
            
            NSMutableArray * mappingArray = [[NSMutableArray alloc] initWithCapacity:0];
            
            if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
            {
                 while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
                 {
                     char * _processId = (char *) synchronized_sqlite3_column_text(stmt, COLUMNPROCESS_ID);
                     if ((_processId != nil) && strlen(_processId))
                         processId = [NSString stringWithUTF8String:_processId];
                     
                     char * _layoutId = (char *) synchronized_sqlite3_column_text(stmt, COLUMNLAYOUT_ID);
                     if ((_layoutId != nil) && strlen(_layoutId))
                         layoutId = [NSString stringWithUTF8String:_layoutId];
                     
                     char * _objectName = (char *) synchronized_sqlite3_column_text(stmt, COLUMNOBJECT_NAME);
                     if ((_objectName != nil) && strlen(_objectName))
                         sourceName = [NSString stringWithUTF8String:_objectName];
                     
                     char * _expressionId = (char *) synchronized_sqlite3_column_text(stmt, COLUMNEXPRESSION_ID);
                     if ((_expressionId != nil) && strlen(_expressionId))
                         expressionId = [NSString stringWithUTF8String:_expressionId];
                     
                     char * _mappingId = (char *) synchronized_sqlite3_column_text(stmt, COLUMNMAPPING_ID);
                     if ((_mappingId != nil) && strlen(_mappingId))
                         oMappingId = [NSString stringWithUTF8String:_mappingId];
                     
                     char * _componentType = (char *) synchronized_sqlite3_column_text(stmt, COLUMNCOMP_TYPE);
                     if ((_componentType != nil) && strlen(_componentType))
                         componentType = [NSString stringWithUTF8String:_componentType];
                     
                     char * _parentColumn = (char *) synchronized_sqlite3_column_text(stmt, COLUMNPARENT_COLUMN);
                     if ((_parentColumn != nil) && strlen(_parentColumn))
                         parentColumn = [NSString stringWithUTF8String:_parentColumn];
                     
                     char * _value_id = (char *) synchronized_sqlite3_column_text(stmt, COLUNMVALUEMAP);
                     if ((_value_id != nil) && strlen(_value_id))
                         vMappingid = [NSString stringWithUTF8String:_value_id];
                     
                     char * _sorting_order = (char *) synchronized_sqlite3_column_text(stmt, COLUMNSORTING_ORDER);
                     if ((_sorting_order != nil) && strlen(_sorting_order))
                         sorting_order_value = [NSString stringWithUTF8String:_sorting_order];
                     
                     char * temp_process_node = (char *) synchronized_sqlite3_column_text(stmt, COLUMNPROCESS_NODE);
                     if ((temp_process_node != nil) && strlen(temp_process_node))
                         processnode_id = [NSString stringWithUTF8String:temp_process_node];
                     
                     // Damodar OPDoc
                     char * _docTempDetail_id = (char *) synchronized_sqlite3_column_text(stmt, COLUMNDOCTEMP_DETAIL_ID);
                     if ((_docTempDetail_id != nil) && strlen(_docTempDetail_id))
                         doc_temp_detail_id = [NSString stringWithUTF8String:_docTempDetail_id];

                     char * _targetObjectLabel = (char *) synchronized_sqlite3_column_text(stmt, 13);
                     if ((_targetObjectLabel != nil) && strlen(_targetObjectLabel))
                         targetObjectLabel = [NSString stringWithUTF8String:_targetObjectLabel];
                     
                     char * _sfID = (char *) synchronized_sqlite3_column_text(stmt, 14);
                     if ((_sfID != nil) && strlen(_sfID))
                         sfID = [NSString stringWithUTF8String:_sfID];

                     objects = [NSArray arrayWithObjects:processId, layoutId, targetName, sourceName, expressionId, oMappingId, componentType, parentColumn, vMappingid, @"", sorting_order_value, processnode_id, doc_temp_detail_id,targetObjectLabel,sfID, nil];// Damodar OPDoc
                     
                     NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                     [mappingArray addObject:dict];
                     processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"", source_child_column = @"",sorting_order_value = @"", processnode_id = @"", doc_temp_detail_id = @"",targetObjectLabel = @"",sfID = @"";// Damodar OPDoc
                }
                if([mappingArray count]) // Damodar / Sahana : Defect fix 9133 : Application Error: No Such Table - Customer:Bay Air Systems
                {
                    
                    NSDictionary * source_dict = nil;
                    NSDictionary * target_dict = nil;
                    
                    NSArray * obj = [NSArray arrayWithObjects: processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"", source_child_column = @"",sorting_order_value = @"", processnode_id = @"", doc_temp_detail_id = @"",targetObjectLabel = @"",sfID = @"",nil]; // Damodar OPDoc
                    
                    source_dict = [mappingArray objectAtIndex:0];
                    if ([mappingArray count] == 2)
                    {
                        target_dict = [mappingArray objectAtIndex:1];
                        if (![[[mappingArray objectAtIndex:0]objectForKey:@"component_type"] isEqualToString:@"SOURCE"])
                        {
                            source_dict = [mappingArray objectAtIndex:1];
                            target_dict = [mappingArray objectAtIndex:0];
                        }
                    }
                    else
                    {
                        if ([[[mappingArray objectAtIndex:0]objectForKey:@"component_type"] isEqualToString:@"SOURCE"])
                        {
                            target_dict = [NSDictionary dictionaryWithObjects:obj forKeys:keys];
                        }
                        else
                        {
                            target_dict = [mappingArray objectAtIndex:0];
                            source_dict = [NSDictionary dictionaryWithObjects:obj forKeys:keys];
                        }
                    }
                    
                    // sorting Order starts
                    NSString * final_sorting_order = @"";
                    NSArray * source_dict_allkeys = nil, * target_dict_allkeys = nil;
                    
                    source_dict_allkeys = [source_dict allKeys];
                    target_dict_allkeys = [target_dict allKeys];
                    
                    
                    if(source_dict_allkeys != nil && [source_dict_allkeys containsObject:SORTING_ORDER])
                    {
                        final_sorting_order = [source_dict objectForKey:SORTING_ORDER];
                        if(final_sorting_order == nil )
                        {
                            final_sorting_order = @"";
                        }
                    }
                    
                    if(target_dict_allkeys != nil && [target_dict_allkeys containsObject:SORTING_ORDER])
                    {
                        NSString * temp_final_sorting_order = [target_dict objectForKey:SORTING_ORDER];
                        if([final_sorting_order length] == 0)
                        {
                            final_sorting_order = temp_final_sorting_order;
                        }
                    }
                    
                    
                    objects = [NSArray arrayWithObjects:
                               ([source_dict objectForKey:MPROCESS_ID]!=@"")?[source_dict objectForKey:MPROCESS_ID]:[target_dict  objectForKey:MPROCESS_ID],
                               ([source_dict objectForKey:MLAYOUT_ID]!=@"")?[source_dict objectForKey:MLAYOUT_ID]:[target_dict  objectForKey:MLAYOUT_ID],
                               ([target_dict  objectForKey:SOURCE_OBJECT_NAME]!=@"")?[target_dict  objectForKey:SOURCE_OBJECT_NAME]:@"",
                               ([source_dict objectForKey:SOURCE_OBJECT_NAME]!=@"")?[source_dict  objectForKey:SOURCE_OBJECT_NAME]:([target_dict  objectForKey:SOURCE_OBJECT_NAME]!=@"")?[target_dict  objectForKey:SOURCE_OBJECT_NAME]:@"",
                               ([source_dict objectForKey:EXPRESSION_ID]!=@"")?[source_dict objectForKey:EXPRESSION_ID]:[target_dict  objectForKey:EXPRESSION_ID],
                               ([source_dict objectForKey:OBJECT_MAPPING_ID]!=@"")?[source_dict objectForKey:OBJECT_MAPPING_ID]:[target_dict  objectForKey:OBJECT_MAPPING_ID],
                               ([target_dict objectForKey:MCOMPONENT_TYPE]!=@"")?[target_dict objectForKey:MCOMPONENT_TYPE]:@"",
                               ([source_dict objectForKey:MPARENT_COLUMN]!=@"")?[source_dict objectForKey:MPARENT_COLUMN]:[target_dict  objectForKey:MPARENT_COLUMN],
                               ([source_dict objectForKey:MVALUE_MAPPING_ID]!=@"")?[source_dict objectForKey:MVALUE_MAPPING_ID]:[target_dict  objectForKey:MVALUE_MAPPING_ID],
                               ([source_dict objectForKey:@"source_child_parent_column"]!=@"")?[source_dict objectForKey:@"source_child_parent_column"]:[target_dict  objectForKey:@"source_child_parent_column"],
                               (final_sorting_order!= nil)?final_sorting_order:@"",
                               ([source_dict objectForKey:process_node_id]!=@"")?[source_dict objectForKey:process_node_id]:[target_dict  objectForKey:process_node_id],
                               ([source_dict objectForKey:MDOC_TEMPLATE_DETAIL_ID]!=@"")?[source_dict objectForKey:MDOC_TEMPLATE_DETAIL_ID]:[target_dict  objectForKey:MDOC_TEMPLATE_DETAIL_ID],
                               (![[source_dict objectForKey:@"target_object_label"]isEqualToString:@""])?[source_dict objectForKey:@"target_object_label"]:[target_dict  objectForKey:@"target_object_label"],
                               (![[source_dict objectForKey:@"sfID"] isEqualToString:@""])?[source_dict objectForKey:@"sfID"]:[target_dict  objectForKey:@"sfID"], nil]
                    ; // Damodar OPDoc//4850
                    
                    NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    
                    [process_info addObject:dict];
                }
            }
             synchronized_sqlite3_finalize(stmt);
            
            [mappingArray release];
            processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"", source_child_column = @"" , sorting_order_value = @"", processnode_id = @"";
            query = @"", doc_temp_detail_id = @"",targetObjectLabel = @"",sfID = @""; // Damodar OPDoc
            sqlite3_stmt * childStmt;
            
            query = [NSString stringWithFormat:@"SELECT * FROM SFprocess_test WHERE process_id = '%@' AND (component_type =  'TARGETCHILD')", [processIdList objectAtIndex:i]];
            
            if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &childStmt, NULL) == SQLITE_OK)
            {
                while (synchronized_sqlite3_step(childStmt) == SQLITE_ROW)
                {
                    char * _processId = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNPROCESS_ID);
                    if ((_processId != nil) && strlen(_processId))
                        processId = [NSString stringWithUTF8String:_processId];
                    
                    char * _layoutId = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNLAYOUT_ID);
                    if ((_layoutId != nil) && strlen(_layoutId))
                        layoutId = [NSString stringWithUTF8String:_layoutId];
                    
                    char * _objectName = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNOBJECT_NAME);
                    if ((_objectName != nil) && strlen(_objectName))
                        sourceName = [NSString stringWithUTF8String:_objectName];
                    
                    char * _expressionId = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNEXPRESSION_ID);
                    if ((_expressionId != nil) && strlen(_expressionId))
                        expressionId = [NSString stringWithUTF8String:_expressionId];
                    
                    char * _mappingId = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNMAPPING_ID);
                    if ((_mappingId != nil) && strlen(_mappingId))
                        oMappingId = [NSString stringWithUTF8String:_mappingId];
                    
                    char * _componentType = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNCOMP_TYPE);
                    if ((_componentType != nil) && strlen(_componentType))
                        componentType = [NSString stringWithUTF8String:_componentType];
                    
                    char * _parentColumn = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNPARENT_COLUMN);
                    if ((_parentColumn != nil) && strlen(_parentColumn))
                        parentColumn = [NSString stringWithUTF8String:_parentColumn];
                    
                    char * _value_id = (char *) synchronized_sqlite3_column_text(childStmt, COLUNMVALUEMAP);
                    if ((_value_id != nil) && strlen(_value_id))
                        vMappingid = [NSString stringWithUTF8String:_value_id];
                    
                    char * _sorting_order = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNSORTING_ORDER);
                    if ((_sorting_order != nil) && strlen(_sorting_order))
                        sorting_order_value = [NSString stringWithUTF8String:_sorting_order];
                    
                    char * temp_process_node = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNPROCESS_NODE);
                    if ((temp_process_node != nil) && strlen(temp_process_node))
                        processnode_id = [NSString stringWithUTF8String:temp_process_node];

                    // Damodar OPDoc
                    char * _docTempDetail_id = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNDOCTEMP_DETAIL_ID);
                    if ((_docTempDetail_id != nil) && strlen(_docTempDetail_id))
                        doc_temp_detail_id = [NSString stringWithUTF8String:_docTempDetail_id];

                    char * _targetObjectLabel = (char *) synchronized_sqlite3_column_text(childStmt, 13);
                    if ((_targetObjectLabel != nil) && strlen(_targetObjectLabel))
                        targetObjectLabel = [NSString stringWithUTF8String:_targetObjectLabel];
                    
                    char * _sfID = (char *) synchronized_sqlite3_column_text(childStmt, 14);
                    if ((_sfID != nil) && strlen(_sfID))
                        sfID = [NSString stringWithUTF8String:_sfID];

                    NSString * source_objectName =  [self getObjectNameFromSFobjMapping:oMappingId];
                    
                    NSString * source_childName = [self getSourceChildNameFromProcessId:source_objectName processid:[processIdList objectAtIndex:i]];
                    
                    objects = [NSArray arrayWithObjects:processId, layoutId, sourceName, source_objectName, expressionId, oMappingId, componentType, parentColumn, vMappingid, source_childName, sorting_order_value,processnode_id, doc_temp_detail_id,targetObjectLabel,sfID, nil]; // Damodar OPDoc
                    
                    NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    
                    [process_info addObject:dict];
                    processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"", source_child_column = @"" , sorting_order_value = @"", processnode_id = @"", doc_temp_detail_id = @"",targetObjectLabel = @"",sfID = @""; // Damodar OPDoc
                }
                
            }
            synchronized_sqlite3_finalize(childStmt);
        }
        else if ([processType isEqualToString:SOURCETOTARGETONLYCHILDROWS] || [processType isEqualToString:OUTPUT_DOCUMENT]) // Damodar OPDoc
        {
            query = [NSString stringWithFormat:@"SELECT * FROM SFprocess_test WHERE process_id = '%@'  AND (component_type = 'SOURCE' or component_type =  'TARGET')", [processIdList objectAtIndex:i]];
            sqlite3_stmt * stmt;
            
            
            NSMutableArray * mappingArray = [[NSMutableArray alloc] initWithCapacity:0];
            
            if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
            {
                while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
                {
                    char * _processId = (char *) synchronized_sqlite3_column_text(stmt, COLUMNPROCESS_ID);
                    if ((_processId != nil) && strlen(_processId))
                        processId = [NSString stringWithUTF8String:_processId];
                    
                    char * _layoutId = (char *) synchronized_sqlite3_column_text(stmt, COLUMNLAYOUT_ID);
                    if ((_layoutId != nil) && strlen(_layoutId))
                        layoutId = [NSString stringWithUTF8String:_layoutId];
                    
                    char * _objectName = (char *) synchronized_sqlite3_column_text(stmt, COLUMNOBJECT_NAME);
                    if ((_objectName != nil) && strlen(_objectName))
                        sourceName = [NSString stringWithUTF8String:_objectName];
                    
                    char * _expressionId = (char *) synchronized_sqlite3_column_text(stmt, COLUMNEXPRESSION_ID);
                    if ((_expressionId != nil) && strlen(_expressionId))
                        expressionId = [NSString stringWithUTF8String:_expressionId];
                    
                    char * _mappingId = (char *) synchronized_sqlite3_column_text(stmt, COLUMNMAPPING_ID);
                    if ((_mappingId != nil) && strlen(_mappingId))
                        oMappingId = [NSString stringWithUTF8String:_mappingId];
                    
                    char * _componentType = (char *) synchronized_sqlite3_column_text(stmt, COLUMNCOMP_TYPE);
                    if ((_componentType != nil) && strlen(_componentType))
                        componentType = [NSString stringWithUTF8String:_componentType];
                    
                    char * _parentColumn = (char *) synchronized_sqlite3_column_text(stmt, COLUMNPARENT_COLUMN);
                    if ((_parentColumn != nil) && strlen(_parentColumn))
                        parentColumn = [NSString stringWithUTF8String:_parentColumn];
                    
                    char * _value_id = (char *) synchronized_sqlite3_column_text(stmt, COLUNMVALUEMAP);
                    if ((_value_id != nil) && strlen(_value_id))
                        vMappingid = [NSString stringWithUTF8String:_value_id];
                    
                    char * _sorting_order = (char *) synchronized_sqlite3_column_text(stmt, COLUMNSORTING_ORDER);
                    if ((_sorting_order != nil) && strlen(_sorting_order))
                        sorting_order_value = [NSString stringWithUTF8String:_sorting_order];
                    
                    char * temp_process_node = (char *) synchronized_sqlite3_column_text(stmt, COLUMNPROCESS_NODE);
                    if ((temp_process_node != nil) && strlen(temp_process_node))
                        processnode_id = [NSString stringWithUTF8String:temp_process_node];
                    
                    // Damodar OPDoc
                    char * _docTempDetail_id = (char *) synchronized_sqlite3_column_text(stmt, COLUMNDOCTEMP_DETAIL_ID);
                    if ((_docTempDetail_id != nil) && strlen(_docTempDetail_id))
                        doc_temp_detail_id = [NSString stringWithUTF8String:_docTempDetail_id];

                    char * _targetObjectLabel = (char *) synchronized_sqlite3_column_text(stmt, 13);
                    if ((_targetObjectLabel != nil) && strlen(_targetObjectLabel))
                        targetObjectLabel = [NSString stringWithUTF8String:_targetObjectLabel];
                    
                    char * _sfID = (char *) synchronized_sqlite3_column_text(stmt, 14);
                    if ((_sfID != nil) && strlen(_sfID))
                        sfID = [NSString stringWithUTF8String:_sfID];

                    objects = [NSArray arrayWithObjects:processId, layoutId, targetName, sourceName, expressionId, oMappingId, componentType, parentColumn, vMappingid, @"", sorting_order_value,processnode_id, doc_temp_detail_id,targetObjectLabel,sfID, nil]; // Damodar OPDoc
                    
                    NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    [mappingArray addObject:dict];
                    processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"", source_child_column = @"", sorting_order_value = @"", processnode_id = @"", doc_temp_detail_id = @"",targetObjectLabel = @"", sfID = @""; // Damodar OPDoc
                }
                if([mappingArray count]) // Damodar / Sahana : Defect fix 9133 : Application Error: No Such Table - Customer:Bay Air Systems
                {
                    NSDictionary * source_dict = nil;
                    NSDictionary * target_dict = nil;
                    //Sahana 31-May-2013
                    
                    NSArray * obj = [NSArray arrayWithObjects: processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"", source_child_column = @"",sorting_order_value = @"", processnode_id = @"", doc_temp_detail_id = @"",targetObjectLabel = @"", sfID = @"", nil]; // Damodar OPDoc
                    source_dict = [mappingArray objectAtIndex:0];
                    if ([mappingArray count] == 2)
                    {
                        target_dict = [mappingArray objectAtIndex:1];
                        if (![[[mappingArray objectAtIndex:0]objectForKey:@"component_type"] isEqualToString:@"SOURCE"])
                        {
                            source_dict = [mappingArray objectAtIndex:1];
                            target_dict = [mappingArray objectAtIndex:0];
                        }
                    }
                    else
                    {
                        if ([[[mappingArray objectAtIndex:0]objectForKey:@"component_type"] isEqualToString:@"SOURCE"])
                        {
                            target_dict = [NSDictionary dictionaryWithObjects:obj forKeys:keys];
                        }
                        else
                        {
                            target_dict = [mappingArray objectAtIndex:0];
                            source_dict = [NSDictionary dictionaryWithObjects:obj forKeys:keys];
                        }
                    }
                    
                    
                    NSString * final_sorting_order = @"";
                    NSArray * source_dict_allkeys = nil, * target_dict_allkeys = nil;
                    
                    source_dict_allkeys = [source_dict allKeys];
                    target_dict_allkeys = [target_dict allKeys];
                    
                    if(source_dict_allkeys != nil && [source_dict_allkeys containsObject:SORTING_ORDER])
                    {
                        final_sorting_order = [source_dict objectForKey:SORTING_ORDER];
                        if(final_sorting_order == nil )
                        {
                            final_sorting_order = @"";
                        }
                    }
                    
                    if(target_dict_allkeys != nil && [target_dict_allkeys containsObject:SORTING_ORDER])
                    {
                        NSString * temp_final_sorting_order = [target_dict objectForKey:SORTING_ORDER];
                        if([final_sorting_order length] == 0)
                        {
                            final_sorting_order = temp_final_sorting_order;
                        }
                    }
                    
                    objects = [NSArray arrayWithObjects:
                               ([source_dict objectForKey:MPROCESS_ID]!=@"")?[source_dict objectForKey:MPROCESS_ID]:[target_dict  objectForKey:MPROCESS_ID],
                               ([source_dict objectForKey:MLAYOUT_ID]!=@"")?[source_dict objectForKey:MLAYOUT_ID]:[target_dict  objectForKey:MLAYOUT_ID],
                               ([target_dict  objectForKey:SOURCE_OBJECT_NAME]!=@"")?[target_dict  objectForKey:SOURCE_OBJECT_NAME]:@"",
                               ([source_dict objectForKey:SOURCE_OBJECT_NAME]!=@"")?[source_dict  objectForKey:SOURCE_OBJECT_NAME]:([target_dict  objectForKey:SOURCE_OBJECT_NAME]!=@"")?[target_dict  objectForKey:SOURCE_OBJECT_NAME]:@"",
                               ([target_dict objectForKey:EXPRESSION_ID]!=@"")?[target_dict objectForKey:EXPRESSION_ID]:[source_dict  objectForKey:EXPRESSION_ID],
                               ([source_dict objectForKey:OBJECT_MAPPING_ID]!=@"")?[source_dict objectForKey:OBJECT_MAPPING_ID]:[target_dict  objectForKey:OBJECT_MAPPING_ID],
                               ([target_dict objectForKey:MCOMPONENT_TYPE]!=@"")?[target_dict objectForKey:MCOMPONENT_TYPE]:@"",
                               ([source_dict objectForKey:MPARENT_COLUMN]!=@"")?[source_dict objectForKey:MPARENT_COLUMN]:[target_dict  objectForKey:MPARENT_COLUMN],
                               ([source_dict objectForKey:MVALUE_MAPPING_ID]!=@"")?[source_dict objectForKey:MVALUE_MAPPING_ID]:[target_dict  objectForKey:MVALUE_MAPPING_ID],
                               ([source_dict objectForKey:@"source_child_parent_column"]!=@"")?[source_dict objectForKey:@"source_child_parent_column"]:[target_dict  objectForKey:@"source_child_parent_column"],(final_sorting_order!= nil)? final_sorting_order:@"",
                               ([source_dict objectForKey:process_node_id]!=@"")?[source_dict objectForKey:process_node_id]:[target_dict  objectForKey:process_node_id],
                               ([source_dict objectForKey:MDOC_TEMPLATE_DETAIL_ID]!=@"")?[source_dict objectForKey:MDOC_TEMPLATE_DETAIL_ID]:[target_dict  objectForKey:MDOC_TEMPLATE_DETAIL_ID],
                               (![[source_dict objectForKey:@"target_object_label"] isEqualToString:@""])?[source_dict objectForKey:@"target_object_label"]:[target_dict  objectForKey:@"target_object_label"],
                               (![[source_dict objectForKey:@"sfID"] isEqualToString:@""])?[source_dict objectForKey:@"sfID"]:[target_dict  objectForKey:@"sfID"], nil]; // Damodar OPDoc//4850
                    
                    
                    NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    
                    [process_info addObject:dict];
                }
            }
            synchronized_sqlite3_finalize(stmt);
            [mappingArray release];
            processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"", source_child_column = @"",sorting_order_value = @"", processnode_id = @"";
            query = @"", doc_temp_detail_id = @"",targetObjectLabel = @"", sfID = @"";// Damodar OPDoc
            sqlite3_stmt * childStmt;
            
            query = [NSString stringWithFormat:@"SELECT * FROM SFprocess_test WHERE process_id = '%@' AND (component_type =  'TARGETCHILD')", [processIdList objectAtIndex:i]];
            
            if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &childStmt, NULL) == SQLITE_OK)
            {
                while (synchronized_sqlite3_step(childStmt) == SQLITE_ROW)
                {
                    char * _processId = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNPROCESS_ID);
                    if ((_processId != nil) && strlen(_processId))
                        processId = [NSString stringWithUTF8String:_processId];
                    
                    char * _layoutId = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNLAYOUT_ID);
                    if ((_layoutId != nil) && strlen(_layoutId))
                        layoutId = [NSString stringWithUTF8String:_layoutId];
                    
                    char * _objectName = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNOBJECT_NAME);
                    if ((_objectName != nil) && strlen(_objectName))
                        sourceName = [NSString stringWithUTF8String:_objectName];
                    
                    char * _expressionId = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNEXPRESSION_ID);
                    if ((_expressionId != nil) && strlen(_expressionId))
                        expressionId = [NSString stringWithUTF8String:_expressionId];
                    
                    char * _mappingId = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNMAPPING_ID);
                    if ((_mappingId != nil) && strlen(_mappingId))
                        oMappingId = [NSString stringWithUTF8String:_mappingId];
                    
                    char * _componentType = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNCOMP_TYPE);
                    if ((_componentType != nil) && strlen(_componentType))
                        componentType = [NSString stringWithUTF8String:_componentType];
                    
                    char * _parentColumn = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNPARENT_COLUMN);
                    if ((_parentColumn != nil) && strlen(_parentColumn))
                        parentColumn = [NSString stringWithUTF8String:_parentColumn];
                    
                    char * _value_id = (char *) synchronized_sqlite3_column_text(childStmt, COLUNMVALUEMAP);
                    if ((_value_id != nil) && strlen(_value_id))
                        vMappingid = [NSString stringWithUTF8String:_value_id];
                    
                    
                    char * _sorting_order = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNSORTING_ORDER);
                    if ((_sorting_order != nil) && strlen(_sorting_order))
                        sorting_order_value = [NSString stringWithUTF8String:_sorting_order];
                    
                    char * temp_process_node = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNPROCESS_NODE);
                    if ((temp_process_node != nil) && strlen(temp_process_node))
                        processnode_id = [NSString stringWithUTF8String:temp_process_node];

                    // Damodar OPDoc
                    char * _docTempDetail_id = (char *) synchronized_sqlite3_column_text(childStmt, COLUMNDOCTEMP_DETAIL_ID);
                    if ((_docTempDetail_id != nil) && strlen(_docTempDetail_id))
                        doc_temp_detail_id = [NSString stringWithUTF8String:_docTempDetail_id];

                    char * _targetObjectLabel = (char *) synchronized_sqlite3_column_text(childStmt, 13);
                    if ((_targetObjectLabel != nil) && strlen(_targetObjectLabel))
                        targetObjectLabel = [NSString stringWithUTF8String:_targetObjectLabel];
                    
                    char * _sfID = (char *) synchronized_sqlite3_column_text(childStmt, 14);
                    if ((_sfID != nil) && strlen(_sfID))
                        sfID = [NSString stringWithUTF8String:_sfID];

                    NSString * source_objectName =  [self getObjectNameFromSFobjMapping:oMappingId];
                    
                    NSString * source_childName = [self getSourceChildNameFromProcessId:source_objectName processid:[processIdList objectAtIndex:i]];
                    
                    objects = [NSArray arrayWithObjects:processId, layoutId, sourceName, source_objectName, expressionId, oMappingId, componentType, parentColumn, vMappingid, source_childName,sorting_order_value, processnode_id, doc_temp_detail_id,targetObjectLabel,sfID, nil]; // Damodar OPDoc
                    
                    NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    
                    [process_info addObject:dict];
                    processId = @"", layoutId = @"", sourceName = @"", expressionId = @"", oMappingId = @"",componentType = @"",  parentColumn = @"", targetName = @"", vMappingid = @"", source_child_column = @"", sorting_order_value = @"", processnode_id = @"", doc_temp_detail_id = @"",targetObjectLabel = @"", sfID = @""; // Damodar OPDoc
                }
                
            }
            synchronized_sqlite3_finalize(childStmt);
        }
    }
    
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM SFProcessComponent"];
    sqlite3_stmt * stmt;
    int count = 0;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0);
        }
    }
    synchronized_sqlite3_finalize(stmt);
    int id_value = count;
    
    // Vipin-db-optmz
    [self beginTransaction];
    
    NSString * bulkQueryStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@',  '%@', '%@', '%@', '%@','%@', '%@', '%@' ,'%@', '%@') VALUES (?1, ?2, ?3, ?4, ?5, ?6,?7, ?8, ?9, ?10, ?11,?12, ?13, ?14, ?15, ?16)", SFPROCESSCOMPONENT, MPROCESS_ID, MLAYOUT_ID, MTARGET_OBJECT_NAME, MSOURCE_OBJECT_NAME, MEXPRESSION_ID, MOBJECT_MAPPING_ID, MCOMPONENT_TYPE, MPARENT_COLUMN,MVALUE_MAPPING_ID,@"source_child_parent_column", MLOCAL_ID,SORTING_ORDER, process_node_id, MDOC_TEMPLATE_DETAIL_ID,@"target_object_label",@"sfID"]; // Damodar OPDoc
    
    sqlite3_stmt * bulkStmt;
    
    int  ret_value = synchronized_sqlite3_prepare_v2(appDelegate.db, [bulkQueryStmt UTF8String], strlen([bulkQueryStmt UTF8String]), &bulkStmt, NULL);

    if (ret_value == SQLITE_OK)
    {
        // Vipin-db-optmz
        [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFPROCESSCOMPONENT"
                                                             andRecordCount:0];
        
        
        for (NSDictionary * dict in process_info)
        {
			NSArray * allkeys = [dict allKeys];
			char * _processId = [appDelegate convertStringIntoChar:([dict objectForKey:MPROCESS_ID] != nil)?[dict objectForKey:MPROCESS_ID]:@""];
			
            sqlite3_bind_text(bulkStmt, 1, _processId, strlen(_processId), SQLITE_TRANSIENT);
			
			
			char * _layoutId = [appDelegate convertStringIntoChar:([dict objectForKey:MLAYOUT_ID] != nil)?[dict objectForKey:MLAYOUT_ID]:@""];
            
            sqlite3_bind_text(bulkStmt, 2, _layoutId, strlen(_layoutId), SQLITE_TRANSIENT);
			
			char * _targetObjectName = [appDelegate convertStringIntoChar:([dict objectForKey:MTARGET_OBJECT_NAME] != nil)?[dict objectForKey:MTARGET_OBJECT_NAME]:@""];
            
            sqlite3_bind_text(bulkStmt, 3, _targetObjectName, strlen(_targetObjectName), SQLITE_TRANSIENT);
										
			char * _sourceObjectName = [appDelegate convertStringIntoChar:([dict objectForKey:MSOURCE_OBJECT_NAME] != nil)?[dict objectForKey:MSOURCE_OBJECT_NAME]:@""];
            
            sqlite3_bind_text(bulkStmt, 4, _sourceObjectName, strlen(_sourceObjectName), SQLITE_TRANSIENT);
										
			char * _expressionId = [appDelegate convertStringIntoChar:([dict objectForKey:MEXPRESSION_ID] != nil)?[dict objectForKey:MEXPRESSION_ID]:@""];
            
            sqlite3_bind_text(bulkStmt, 5, _expressionId, strlen(_expressionId), SQLITE_TRANSIENT);
										
			char * _objectmappingId = [appDelegate convertStringIntoChar:([dict objectForKey:MOBJECT_MAPPING_ID] != nil)?[dict objectForKey:MOBJECT_MAPPING_ID]:@""];
										
            sqlite3_bind_text(bulkStmt, 6, _objectmappingId, strlen(_objectmappingId), SQLITE_TRANSIENT);
										
			char * _componentType = [appDelegate convertStringIntoChar:([dict objectForKey:MCOMPONENT_TYPE] != nil)?[dict objectForKey:MCOMPONENT_TYPE]:@""];
										
            sqlite3_bind_text(bulkStmt, 7, _componentType, strlen(_componentType), SQLITE_TRANSIENT);
										
			char * _parentColumn = [appDelegate convertStringIntoChar:([dict objectForKey:MPARENT_COLUMN] != nil)?[dict objectForKey:MPARENT_COLUMN]:@""];
										
            sqlite3_bind_text(bulkStmt, 8, _parentColumn, strlen(_parentColumn), SQLITE_TRANSIENT);
			
            char * _valueMappingId = [appDelegate convertStringIntoChar:([dict objectForKey:MVALUE_MAPPING_ID] != nil)?[dict objectForKey:MVALUE_MAPPING_ID]:@""];
										
            sqlite3_bind_text(bulkStmt, 9, _valueMappingId, strlen(_valueMappingId), SQLITE_TRANSIENT);
										
			char * _sourceChildParentcolumn = [appDelegate convertStringIntoChar:([dict objectForKey:@"source_child_parent_column"] != nil)?[dict objectForKey:@"source_child_parent_column"]:@""];
            
            sqlite3_bind_text(bulkStmt,  10, _sourceChildParentcolumn, strlen(_sourceChildParentcolumn), SQLITE_TRANSIENT);
            
            sqlite3_bind_int(bulkStmt, 11, ++id_value);
            
            NSString * values_c = @"";
            if([allkeys containsObject:SORTING_ORDER])
            {
                values_c = [dict objectForKey:SORTING_ORDER];
            }
            
            char * _sorting_order = [appDelegate convertStringIntoChar:(values_c != nil)?values_c:@""];
            sqlite3_bind_text(bulkStmt, 12, _sorting_order, strlen(_sorting_order), SQLITE_TRANSIENT);
            
            char * temp_processnode = [appDelegate convertStringIntoChar:([dict objectForKey:process_node_id] != nil)?[dict objectForKey:process_node_id]:@""];
            
            sqlite3_bind_text(bulkStmt,  13, temp_processnode, strlen(temp_processnode), SQLITE_TRANSIENT);
            
            // Damodar OPDoc
            char * _docTempDetailId = [appDelegate convertStringIntoChar:([dict objectForKey:MDOC_TEMPLATE_DETAIL_ID] != nil)?[dict objectForKey:MDOC_TEMPLATE_DETAIL_ID]:@""];
            
            sqlite3_bind_text(bulkStmt, 14, _docTempDetailId, strlen(_docTempDetailId), SQLITE_TRANSIENT);

            char * _targetObjectLabel = [appDelegate convertStringIntoChar:([dict objectForKey:@"target_object_label"] != nil)?[dict objectForKey:@"target_object_label"]: @""];
            
            sqlite3_bind_text(bulkStmt, 15, _targetObjectLabel, strlen(_targetObjectLabel), SQLITE_TRANSIENT);
            
            char * _sfID = [appDelegate convertStringIntoChar:([dict objectForKey:@"sfID"] != nil)?[dict objectForKey:@"sfID"]: @""];
            
            sqlite3_bind_text(bulkStmt, 16, _sfID, strlen(_sfID), SQLITE_TRANSIENT);

            if (synchronized_sqlite3_step(bulkStmt) != SQLITE_DONE)
            {
                SMLog(kLogLevelError,@"Commit Failed - SFPROCESSCOMPONENT!\n");
            }
            
            sqlite3_clear_bindings(bulkStmt);
            sqlite3_reset(bulkStmt);
        }
        // Vipin-db-optmz
        [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"SFPROCESSCOMPONENT"
                                                             andRecordCount:[process_info count]];
        
        [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[process_info count]];
        
    }
    
    synchronized_sqlite3_finalize(bulkStmt);
    // Vipin-db-optmz
    [self endTransaction];

}
#pragma mark - END


- (NSString *) getObjectNameFromSFobjMapping:(NSString *)mappingId
{
    NSString * qurey = [NSString stringWithFormat:@"SELECT source_object_name FROM SFObjectMapping where object_mapping_id = '%@'", mappingId];
    
    sqlite3_stmt * stmt;
    
    NSString * objectName = @"";
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [qurey UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if  (synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
        {
            char * name = (char *) synchronized_sqlite3_column_text(stmt, 0);
            
            if ((name != nil) && strlen(name))
                objectName = [NSString stringWithUTF8String:name];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return objectName;
}


- (NSString *) getSourceChildNameFromProcessId:(NSString *)soureobjectName processid:(NSString *)processId
{
    NSString * qurey = [NSString stringWithFormat:@"SELECT parent_column FROM SFProcess_test WHERE process_id = '%@' AND object_name = '%@'", processId, soureobjectName];
    
    sqlite3_stmt * stmt;
    
    NSString * objectName = @"";
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [qurey UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if  (synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
        {
            char * name = (char *) synchronized_sqlite3_column_text(stmt, 0);
            
            if ((name != nil) && strlen(name))
                objectName = [NSString stringWithUTF8String:name];            
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return objectName;
}
 
#pragma mark - Create Extra Tables For TroubleShooting and Summary
- (void) createTableForSummaryAndTroubleShooting
{
    NSString * query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  ChatterPostDetails ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'ProductId' VARCHAR NOT NULL ,'Body' TEXT,'CreatedById' VARCHAR,'CreatedDate' VARCHAR,'Id' VARCHAR,'POSTTYPE' VARCHAR,'Username' VARCHAR,'Email' VARCHAR,'FeedPostId' VARCHAR,'FullPhotoUrl' VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS Document ('local_id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE DEFAULT (0), 'AuthorId' VARCHAR, 'Body' VARCHAR, 'BodyLength' INTEGER, 'ContentType' VARCHAR, 'CreatedById' VARCHAR, 'Description' VARCHAR, 'DeveloperName' VARCHAR, 'FolderId' VARCHAR, 'Id' VARCHAR, 'IsBodySearchable' BOOL, 'IsDeleted' BOOL, 'IsInternalUseOnly' BOOL, 'IsPublic' BOOL, 'Keywords' TEXT, 'LastModifiedById' VARCHAR, 'LastModifiedDate' DATETIME, 'Name' VARCHAR, 'NamespacePrefix' VARCHAR, 'SystemModstamp' VARCHAR, 'Type' VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  ProductImage ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'productId' VARCHAR, 'productImage' VARCHAR)"];
    [self createTable:query];
    
    //krishnasign
    //krishna opdoc added signName
    //signature name is the id with timestamp to get the latest updated signature
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  SFSignatureData ('record_Id' VARCHAR,'object_api_name' VARCHAR,'signature_data' TEXT,'sig_Id' TEXT ,'WorkOrderNumber' VARCHAR, 'sign_type' VARCHAR , 'operation_type' VARCHAR, 'signature_type_id' TEXT, 'signature_name' TEXT)"];
    [self createTable:query];
    
    //krishnaopdocs html data
     query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  SFOPDocHtmlData ('local_id' VARCHAR,'object_api_name' VARCHAR,'opdoc_data' TEXT,'sf_id' TEXT ,'WorkOrderNumber' VARCHAR, 'doc_name' TEXT, 'process_id' TEXT)"];
    [self createTable:query];
    
    //krishna Opdocs requested PDF
    //to store the data of pdf, which is requested for generation and yet not downloaded.
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFRequiredPdf ('process_id' TEXT, 'record_id' TEXT, 'attachment_id' TEXT)"];
    [self createTable:query];
    
    //krishna Opdocs requested Signature
    //to store the data of sign, which is requested for generation and yet not downloaded.
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFRequiredSignature ('sign_id' TEXT,'signature_id' TEXT)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS UserImages ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'username' VARCHAR,'userimage' BLOB)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  trobleshootdata ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0),'ProductId' VARCHAR, 'ProductName' VARCHAR, 'Product_Doc' BLOB, 'DocId' VARCHAR, 'prod_manual_Id' VARCHAR, 'prod_manual_name' VARCHAR, 'productmanbody' VARCHAR)"];
    [self createTable:query];
    
	//Sync_Override
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFDataTrailer ('timestamp' DATETIME, 'local_id' INTEGER,'sf_id' VARCHAR, 'record_type' VARCHAR, 'operation' VARCHAR, 'object_name' VARCHAR, 'sync_flag' BOOL , 'parent_object_name' VARCHAR ,'parent_local_id' VARCHAR , 'record_sent' VARCHAR ,'webservice_name' VARCHAR, 'class_name' VARCHAR , 'sync_type' VARCHAR, 'header_localId' VARCHAR,'request_data' VARCHAR ,'request_id' VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFDataTrailer_Temp ('timestamp' DATETIME, 'local_id' INTEGER,'sf_id' VARCHAR, 'record_type' VARCHAR, 'operation' VARCHAR, 'object_name' VARCHAR, 'sync_flag' BOOL , 'parent_object_name'  VARCHAR ,'parent_local_id'  VARCHAR , 'record_sent' VARCHAR ,'webservice_name' VARCHAR, 'class_name'  VARCHAR , 'sync_type' VARCHAR, 'header_localId' VARCHAR)"];
    [self createTable:query];
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SYNC_HISTORY ('last_sync_time' DATETIME , 'sync_type' VARCHAR , 'request_id' VARCHAR , 'SYNC_STATUS' BOOL )"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS sync_Records_Heap ('sf_id' VARCHAR, 'local_id' VARCHAR,'object_name' VARCHAR, 'sync_type' VARCHAR, 'json_record' VARCHAR , 'sync_flag' BOOL , 'record_type' VARCHAR)"];
    [self createTable:query];
    
    // Vipin-db-optmz
    SMLog(kLogLevelVerbose,@"sync_Record_Heap_Index Index creation skipping now..");
    //query = [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS sync_Record_Heap_Index ON sync_Records_Heap (sf_id ASC, local_id ASC, object_name ASC, sync_flag ASC)"];
    //[self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS LookUpFieldValue ('object_api_name' VARCHAR, 'Id' PRIMARY KEY  NOT NULL  UNIQUE, 'value' VARCHAR)"]; //10408 Defect fix - Removed the loacl_id column since the application is not using the column any where, Instead replace Id colunm as PRIMARY KEY so no duplicate entry of the same Id is not inserted in the table.
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE SettingsValue ('Id' VARCHAR, 'SVMXC__Active__c' BOOL, 'SVMXC__Display_Value__c' TEXT, 'SVMXC__Internal_Value__c' TEXT, 'SVMXC__IsDefault__c' BOOL, 'SVMXC__Setting_Configuration_Profile__c' TEXT, 'SVMXC__Setting_ID__c' TEXT)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE SettingsInfo ('Id' VARCHAR, 'SVMXC__Active__c' BOOL, 'SVMXC__Data_Type__c' TEXT, 'SVMXC__Default_Value__c' TEXT, 'SVMXC__Description__c' TEXT, 'SVMXC__IsPrivate__c' BOOL, 'SVMXC__IsStandard__c' BOOL, 'SVMXC__Search_Order__c' VARCHAR, 'SVMXC__SettingID__c' VARCHAR, 'SVMXC__Setting_Type__c' VARCHAR, 'SVMXC__Setting_Unique_ID__c' TEXT, 'SVMXC__Settings_Name__c' TEXT, 'SVMXC__SubmoduleID__c' TEXT, 'SVMXC__Submodule__c' TEXT, 'SVMXC__Values__c' TEXT)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS Summary_PDF ('record_Id' VARCHAR,'object_api_name' VARCHAR, 'PDF_data' TEXT, 'WorkOrderNumber' VARCHAR, 'PDF_Id' VARCHAR, 'sign_type' VARCHAR, 'pdf_name' VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS sync_error_conflict ('sf_id' VARCHAR, 'local_id' VARCHAR,'object_name' VARCHAR, 'record_type' VARCHAR ,'sync_type' VARCHAR ,'error_message' VARCHAR ,'operation_type' VARCHAR , 'error_type' VARCHAR , 'override_flag'  VARCHAR ,'class_name' VARCHAR ,'method_name' VARCHAR , 'custom_ws_error' VARCHAR , 'request_id' VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS contact_images ('contact_Id' VARCHAR, 'contact_Image' VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS internet_conflicts ('sync_type' VARCHAR, 'error_message' VARCHAR, 'operation_type' VARCHAR, 'error_type' VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS meta_sync_status ('sync_status' VARCHAR)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS meta_sync_due ('local_id' INTEGER PRIMARY KEY  NOT NULL UNIQUE, 'description' VARCHAR)"];
    [self createTable:query];
    
    query =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS on_demand_download ('object_name' VARCHAR , 'sf_id' VARCHAR PRIMARY KEY  NOT NULL UNIQUE, 'time_stamp' DATETIME ,'local_id' VARCHAR, 'record_type' VARCHAR, 'json_record' VARCHAR) "];
    [self createTable:query];

    query =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ('object_name' VARCHAR , 'sf_id' VARCHAR PRIMARY KEY  NOT NULL UNIQUE, 'time_stamp' DATETIME ,'local_id' VARCHAR ) ",User_created_events];
    [self createTable:query];
    
    query =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ('object_name' VARCHAR ,'local_id' VARCHAR ) ",Event_local_Ids];
    [self createTable:query];
    
    query =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ('object_name' VARCHAR ,'local_id' VARCHAR) ",LOCAL_EVENT_UPDATE];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS servicereprt_logo ('logo' VARCHAR)"];
    [self createTable:query];
    if([appDelegate enableGPS_SFMSearch])
        [self createUserGPSTable];
}

//9644
- (BOOL) executeQuery:(NSString *)statement
{
    char * err;
    BOOL isSuccess = YES;
    if (synchronized_sqlite3_exec(appDelegate.db, [statement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        isSuccess = NO;
        SMLog(kLogLevelError,@" ERROR IN execute Query statement: %@ \n %s", statement, err);
        SMLog(kLogLevelError,@" ERROR in detail  : %@",[NSString stringWithUTF8String:sqlite3_errmsg(appDelegate.db)]);
    }
    return isSuccess;
}
#pragma mark - Create All Tables
- (BOOL) createTable:(NSString *)statement
{
    char * err;
    BOOL isSuccess = YES;
    if (synchronized_sqlite3_exec(appDelegate.db, [statement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        isSuccess = NO;
        SMLog(kLogLevelError,@" ERROR IN createTable \n  stetement: %@ \n %s", statement, err);
        SMLog(kLogLevelError,@" ERROR in detail  : %@",[NSString stringWithUTF8String:sqlite3_errmsg(appDelegate.db)]);
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
        {
            [MyPopoverDelegate performSelector:@selector(throwException)];
        }
       
        /*
		[appDelegate printIfError:nil ForQuery:statement type:INSERTQUERY];
         */
        // Vipin 31-May-2013
        
    }
    return isSuccess;
}

#pragma mark - DataSync

- (void) insertDataInToTables:(NSMutableArray *)fieldValueArray
{
    NSArray * fields = [[[NSArray alloc] init] autorelease];
    NSArray * values = [[[NSArray alloc] init] autorelease];
    int lookUp_id = 1;
    
    // Vipin-db-optmz -rm
   // SMLog(kLogLevelVerbose,@" [OBS] insertDataInToTables  --- starting ...");
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance]  observePerformanceForContext:@"insertDataInToTables-OBs"
                                                          andRecordCount:0];
    
    
    [self beginTransaction];
    
    for (int i = 0; i < [fieldValueArray count]; i++)
    {
        NSDictionary * dict = [fieldValueArray objectAtIndex:i];
        
        NSArray * keys = [dict allKeys];
        
        for (int j = 0; j < [keys count]; j++)
        {
            NSString * objectName = [keys objectAtIndex:j];
            
            if ([objectName isEqualToString:@"Case"])
                objectName = @"'Case'";
            
            //int id_value = 1;
   //         NSString * id_value1  = @"";
            NSString * id_value  = [[NSString alloc] initWithString:@""];
            NSMutableArray * fieldArray = [dict objectForKey:[keys objectAtIndex:j]];
            
            for (int val = 0; val < [fieldArray count]; val++)
            {
                NSDictionary * fieldValues = [fieldArray objectAtIndex:val];
                // Mem_leak_fix - Vipindas 9493 Jan 18
                if (id_value!= nil)
                {
                    [id_value release];
                }
                
                id_value = [[AppDelegate GetUUID] retain];
                
                fields = [fieldValues allKeys];
                values = [fieldValues allValues];
                
                NSString * field_string = @"";
                NSString * value_string = @"";
                
                for (int f = 0; f < [fields count]; f++)
                {
                    NSMutableDictionary * lookUpDict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
                    
                    if ([[values objectAtIndex:f] isKindOfClass:[NSDictionary class]])
                    {
                        NSString * field = [fields objectAtIndex:f];
                        
                        NSRange range = [field rangeOfString:@"__r"];
                        
                        if (range.location != NSNotFound)
                        {
                            NSDictionary * attDict = [[values objectAtIndex:f] objectForKey:@"attributes"];
                            
                            [lookUpDict setValue:[[values objectAtIndex:f] objectForKey:@"Id"] forKey:@"Id"];
                            [lookUpDict setValue:[[values objectAtIndex:f] objectForKey:@"Name"] forKey:@"Name"];
                            [lookUpDict setValue:[attDict objectForKey:@"type"] forKey:@"type"];
                            
                            [self addvaluesToLookUpFieldTable:lookUpDict WithId:lookUp_id++];
                        }                        
                        
                    }
                    
                    if ([[fields objectAtIndex:f] isKindOfClass:[NSString class]] && (![[values objectAtIndex:f] isKindOfClass:[NSDictionary class]]))
                    {
                        NSString * value = [fieldValues objectForKey:[fields objectAtIndex:f]];
                        
                        if ([value isKindOfClass:[NSString class]])
                            value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        
                        if ([field_string length] > 0)
                        {
                            value_string = [value_string stringByAppendingString:@", "];
                            field_string = [field_string stringByAppendingString:@","];                        
                        }
                        
                        value_string = [value_string stringByAppendingString:[NSString stringWithFormat:@"'%@'", value]];
                        field_string = [field_string stringByAppendingString:[NSString stringWithFormat:@"%@", [fields objectAtIndex:f]]];
                    }
                }  
                
                BOOL retVal = [self checkForDuplicateId:objectName sfId:[fieldValues objectForKey:@"Id"]];
                
                NSString * query = @"";
                if (retVal)
                {
                     query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@, '%@') VALUES (%@, '%@')", objectName, field_string, MLOCAL_ID, value_string, id_value];
                
                    char * err;
                    if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
                    {  
                        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                            [MyPopoverDelegate performSelector:@selector(throwException)];
                        SMLog(kLogLevelError,@"%@", query);
						SMLog(kLogLevelError,@"METHOD: insertDataInToTables");
						SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
                        /*
						[appDelegate printIfError:nil ForQuery:query type:INSERTQUERY];
                         */
                    }
                }
            }
            [id_value release];
            id_value = nil;
        }        
    
    }
    
    [[PerformanceAnalytics sharedInstance]  completedPerformanceObservationForContext:@"insertDataInToTables-OBs"
                                                          andRecordCount:0];

    [self endTransaction];
    [self updateChildSfIdWithParentLocalId:appDelegate.wsInterface.childObject];
}

// Vipin-db-optmz
- (void)addValuesToLookUpFieldTable:(NSMutableArray *)values
{
    if ( (values == nil) || ([values count] == 0) )
    {
        // Not valid values
        return;
    }
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance]  observePerformanceForContext:@"addValuesToLookUpFieldTable"
                                                          andRecordCount:0];
    
    [self beginTransaction];
    
    NSString * query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO LookUpFieldValue ('%@', '%@', '%@') VALUES (?1, ?2, ?3)", MOBJECT_API_NAME, @"Id",
                        MVALUEM];
    
    sqlite3_stmt *bulkStmt;
    
    NSString * type = @"", * idValue = @"";
    
    int reult = synchronized_sqlite3_prepare_v2(appDelegate.db,
                                                [query UTF8String],
                                                strlen([query UTF8String]),
                                                &bulkStmt, NULL);
    for (NSDictionary *lookUpDict in values)
    {
        NSString * value = ([lookUpDict objectForKey:@"Name"] != nil)?[lookUpDict objectForKey:@"Name"]:@"";
        
        if (![value isEqualToString:@""])
        {
            value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
        }
        
        type = ([lookUpDict objectForKey:@"type"] != nil) ? [lookUpDict objectForKey:@"type"] : @"";
        
        
        idValue = ([lookUpDict objectForKey:@"Id"] != nil) ? [lookUpDict objectForKey:@"Id"] : @"";
        
        if (reult == SQLITE_OK)
        {
            char * _type = [appDelegate convertStringIntoChar:type];
            sqlite3_bind_text(bulkStmt, 1, _type, strlen(_type), SQLITE_TRANSIENT);
            
            char * _Id = [appDelegate convertStringIntoChar:idValue];
            sqlite3_bind_text(bulkStmt, 2, _Id, strlen(_Id), SQLITE_TRANSIENT);
            
            char * _value = [appDelegate convertStringIntoChar:value];
            sqlite3_bind_text(bulkStmt, 3, _value, strlen(_value), SQLITE_TRANSIENT);
            
            char * err = NULL;
            
            if (sqlite3_step(bulkStmt) != SQLITE_DONE)
            {
                SMLog(kLogLevelVerbose,@"insertRecordIdsIntosyncRecordHeap failed Query :%@ \n\n reason: \n %s", query, err);
                if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                    [MyPopoverDelegate performSelector:@selector(throwException)];
                SMLog(kLogLevelError,@"%@", query);
                SMLog(kLogLevelError,@"METHOD: addvaluesToLookUpFieldTable");
                SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
            }
            
            sqlite3_clear_bindings(bulkStmt);
            sqlite3_reset(bulkStmt);
            
        }
        
    }
    
    synchronized_sqlite3_finalize(bulkStmt);
    
    [self endTransaction];
    
    [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[values count]];
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance]  observePerformanceForContext:@"addValuesToLookUpFieldTable"
                                                          andRecordCount:[values count]];
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"addValuesToLookUpFieldTable"
                                                                      andRecordCount:0];
}

-(void) addvaluesToLookUpFieldTable:(NSDictionary *)lookUpDict WithId:(NSInteger)Id
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance]  observePerformanceForContext:@"addvaluesToLookUpFieldTable-x"
                                                          andRecordCount:0];
    
    [self beginTransaction];
    NSString * value = ([lookUpDict objectForKey:@"Name"] != nil)?[lookUpDict objectForKey:@"Name"]:@"";
    
    if (![value isEqualToString:@""])
    {
        value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
    }
    
    NSString * query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO LookUpFieldValue ('%@', '%@', '%@') VALUES (?1, ?2, ?3)", MOBJECT_API_NAME, @"Id",
                        MVALUEM];
    
    sqlite3_stmt *bulkStmt;
    
    NSString * type = @"", * idValue = @"";
    
    
    type = ([lookUpDict objectForKey:@"type"] != nil) ? [lookUpDict objectForKey:@"type"] : @"";
    
    
    idValue = ([lookUpDict objectForKey:@"Id"] != nil) ? [lookUpDict objectForKey:@"Id"] : @"";
    
    int reult = synchronized_sqlite3_prepare_v2(appDelegate.db,
                                                [query UTF8String],
                                                strlen([query UTF8String]),
                                                &bulkStmt, NULL);
    if (reult == SQLITE_OK)
    {
        char * _type = [appDelegate convertStringIntoChar:type];
        sqlite3_bind_text(bulkStmt, 1, _type, strlen(_type), SQLITE_TRANSIENT);
        
        char * _Id = [appDelegate convertStringIntoChar:idValue];
        sqlite3_bind_text(bulkStmt, 2, _Id, strlen(_Id), SQLITE_TRANSIENT);
        
        char * _value = [appDelegate convertStringIntoChar:value];
        sqlite3_bind_text(bulkStmt, 3, _value, strlen(_value), SQLITE_TRANSIENT);
        
        char * err = NULL;
        
        if (sqlite3_step(bulkStmt) != SQLITE_DONE)
        {
            SMLog(kLogLevelVerbose,@"addvaluesToLookUpFieldTable failed Query :%@ \n\n reason: \n %s", query, err);
            if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                [MyPopoverDelegate performSelector:@selector(throwException)];
            SMLog(kLogLevelError,@"%@", query);
            SMLog(kLogLevelError,@"METHOD: addvaluesToLookUpFieldTable");
            SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
        }
        
        sqlite3_clear_bindings(bulkStmt);
        sqlite3_reset(bulkStmt);
    }
    
    synchronized_sqlite3_finalize(bulkStmt);
    
    [self endTransaction];
    
    [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:1];
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance]  observePerformanceForContext:@"addvaluesToLookUpFieldTable-x"
                                                          andRecordCount:1];
    
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"addvaluesToLookUpFieldTable-x"
                                                                      andRecordCount:0];
    
    
}

-(void) updateChildSfIdWithParentLocalId:(NSArray *)childObject
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance]  observePerformanceForContext:@"updateChildSfIdWithParentLocalId"
                                                          andRecordCount:[childObject count]];
    
    
    for (NSString * objectName in childObject)
    {
        NSString * query = [NSString stringWithFormat:@"SELECT field_api_name, object_api_name_parent FROM SFChildRelationship where object_api_name_parent = (SELECT object_api_name_parent FROM SFChildRelationship WHERE object_api_name_child = '%@') and object_api_name_child = '%@'", objectName, objectName];
        
        sqlite3_stmt * statement;
        
        NSString * parentColumn = @""; 
        NSString * parent_object = @"";
        
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            if(synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                char * _field_api_name = (char *)synchronized_sqlite3_column_text(statement, 0);
                
                if ((_field_api_name != nil) && strlen(_field_api_name))
                    parentColumn = [NSString stringWithUTF8String:_field_api_name];
                
                char * _parent_object = (char *)synchronized_sqlite3_column_text(statement, 1);
                
                if ((_parent_object != nil) && strlen(_parent_object))
                    parent_object = [NSString stringWithUTF8String:_parent_object];
            }
        }
        
        synchronized_sqlite3_finalize(statement);
        
                
        
        sqlite3_stmt * stmt;
        NSString * queryStatement = [NSString stringWithFormat:@"SELECT %@ FROM %@", parentColumn, objectName];
        
        NSMutableArray * sfid_array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        NSString * check_id = @"";
        
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &stmt, NULL) == SQLITE_OK)
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                NSString * sf_Id = @"";
                char * _sfId = (char *) synchronized_sqlite3_column_text(stmt, 0);
                
                if ((_sfId != nil) && strlen(_sfId))
                    sf_Id = [NSString stringWithUTF8String:_sfId];
                
                if ([sfid_array count] > 0)
                {
                    if ([check_id isEqualToString:sf_Id])
                    {
                        
                    }
                    else
                    {
                        [sfid_array addObject:sf_Id];
                        check_id = sf_Id;
                    }
                }
                else
                {
                    [sfid_array addObject:sf_Id];
                    check_id = sf_Id;
                }
                
            }
        }
           
        synchronized_sqlite3_finalize(stmt);
        
         [self beginTransaction];
        
        for (NSString * id_ in sfid_array)
        {
                sqlite3_stmt * stmt_localId;
                NSString * queryStatement1 = [NSString stringWithFormat:@"SELECT local_id FROM %@ WHERE Id = '%@'", parent_object, id_];
                
                if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement1 UTF8String], -1, &stmt_localId, NULL) == SQLITE_OK)
                {
                    while (synchronized_sqlite3_step(stmt_localId) == SQLITE_ROW)
                    {
                        char * temp_localId = (char *)synchronized_sqlite3_column_text(stmt_localId, 0);
                        NSString * _localId = @"";
                        if(temp_localId != nil)
                            _localId = [NSString stringWithUTF8String:temp_localId];
                        
                        NSString * localId = [NSString stringWithFormat:@"%@", _localId];
                        
                        sqlite3_stmt * stmt_id;
                        NSString * queryStatement2 = [NSString stringWithFormat:@"SELECT Id FROM %@ WHERE %@ = '%@'", objectName, parentColumn, id_];
                        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement2 UTF8String], -1, &stmt_id, NULL) == SQLITE_OK)
                        {
                            while (synchronized_sqlite3_step(stmt_id) == SQLITE_ROW)
                            {
                                NSString * sfid = @"";
                                char * _sfid = (char *)synchronized_sqlite3_column_text(stmt_id, 0);
                                if(_sfid != nil)
                                    sfid = [NSString stringWithUTF8String:_sfid];
                                
                                NSString * queryStatement3 = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE Id = '%@'", objectName, parentColumn, localId, sfid];
                                
                                char * err;
                                if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement3 UTF8String], NULL, NULL, &err) != SQLITE_OK)
                                {
                                    if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                                        [MyPopoverDelegate performSelector:@selector(throwException)];
									
                                    SMLog(kLogLevelVerbose,@"%@", queryStatement3);
									SMLog(kLogLevelVerbose,@"METHOD:updateChildSfIdWithParentLocalId" );
									SMLog(kLogLevelVerbose,@"ERROR IN UPDATING %s", err);
                                    /*
									[appDelegate printIfError:nil ForQuery:queryStatement3 type:UPDATEQUERY];
                                     */
                                }
                                
                                [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:1];
                            }
                            
                          synchronized_sqlite3_finalize(stmt_id);
                        }
                    }
                    
                     synchronized_sqlite3_finalize(stmt_localId);
                }
            } 
            
         [self endTransaction];
    }
    appDelegate.wsInterface.didOpComplete = TRUE;
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"updateChildSfIdWithParentLocalId"
                                                                      andRecordCount:0];

    SMLog(kLogLevelVerbose,@"IComeOUTHere Databse");
}

-(BOOL) checkForDuplicateId:(NSString *)objectName sfId:(NSString *)sfId
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"checkForDuplicateId"
                                                         andRecordCount:1];
    
    
    int count = 0;
    
    if([objectName isEqualToString:@"Case"])
    {
        objectName = @"'Case'";
    }
    
    NSString * query = [[NSString alloc] initWithFormat:@"SELECT COUNT(*) FROM %@ WHERE Id = '%@'", objectName, sfId];
    
    sqlite3_stmt * stmt;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0); 
        }
    }
    synchronized_sqlite3_finalize(stmt);

    [query release];
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"checkForDuplicateId"
                                                                      andRecordCount:0];
    
    
    
    if (count > 0)
        return FALSE;
    else 
        return TRUE;

}

#pragma mark - PDF Settings
- (void) generatePDFSettings
{
    // Get details of the IPAD Module
    NSString * _query = @"SELECT Id, SVMXC__Name__c, SVMXC__Description__c, SVMXC__ModuleID__c, SVMXC__IsStandard__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__ModuleID__c = \'IPAD\' AND RecordType.Name = \'MODULE\'";
	SMLog(kLogLevelVerbose,@"GeneratePDfSeetings = %@", _query);
	
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetModuleInfo:error:context:) context:nil];
}

- (void) didGetModuleInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    // Get Submodules Info (query could return multiple rows)
    if ([[result records] count] > 0)
    {
        ZKSObject * obj = [[result records] objectAtIndex:0];
        NSString * moduleInfo = [[obj fields] objectForKey:@"Id"];
        NSString * _query = [NSString stringWithFormat:@"SELECT Id, SVMXC__ModuleID__c, SVMXC__SubmoduleID__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__IsStandard__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Module__c = \'%@\' AND RecordType.Name = \'SUBMODULE\'", moduleInfo];
		SMLog(kLogLevelVerbose,@"DidGetModuleInfo = %@", _query);
		
        [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetSubModuleInfo:error:context:) context:nil];
    }
    else
    {
        didGetPDF = YES;
    }
}

- (void) didGetSubModuleInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    // Get Settings Info(query could return multiple rows)
    if ([[result records] count] > 0)
    {
        NSString * _query = [NSString stringWithFormat:@"SELECT Id, SVMXC__SubmoduleID__c, SVMXC__SettingID__c, SVMXC__Setting_Unique_ID__c, SVMXC__Settings_Name__c, SVMXC__Data_Type__c, SVMXC__Values__c, SVMXC__Default_Value__c, SVMXC__Setting_Type__c, SVMXC__Search_Order__c, SVMXC__IsPrivate__c, SVMXC__Active__c, SVMXC__Description__c, SVMXC__IsStandard__c, SVMXC__Submodule__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__SubmoduleID__c = 'IPAD004' AND RecordType.Name = \'SETTINGS\' ORDER BY SVMXC__Setting_Unique_ID__c"];
		SMLog(kLogLevelVerbose,@"didGetSubModuleInfo = %@", _query);
        [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetSettingsInfo:error:context:) context:nil];
    }
    else
    {
        // Continue logging in
        didGetPDF = YES;
    }
}

- (void) didGetSettingsInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
     // Get the Active Global Profile
    if ([[result records] count] > 0)
    {
       settingInfoId = [[NSMutableString alloc] initWithCapacity:0];
       settingsInfoArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i = 0; i < [[result records] count]; i++)
        {
            ZKSObject * obj = [[result records] objectAtIndex:i];
            
            [settingsInfoArray addObject:[obj fields]];
            
            if ([settingInfoId length] == 0)
                [settingInfoId appendFormat:@"(\'%@\'", [[obj fields] objectForKey:@"Id"]];
            else
                [settingInfoId appendFormat:@", \'%@\'", [[obj fields] objectForKey:@"Id"]];
        }
        [settingInfoId appendString:@")"];
        
        NSString * _query = @"Select Id, SVMXC__Profile_Name__c, SVMXC__Active__c, SVMXC__IsDefault__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c=\'Configuration Profile\' and SVMXC__Configuration_Type__c = \'Global\' and SVMXC__Active__c = true";
		SMLog(kLogLevelVerbose,@"didGetSettingsInfo = %@", _query);
        [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetActiveGlobalProfile:error:context:) context:nil];
    }
    else
    {
        // Continue logging in
        didGetPDF = YES;
    }
}

- (void) didGetActiveGlobalProfile:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    // Get Settings value Info(query could return multiple rows)
    if ([[result records] count] > 0)
    {
        ZKSObject * obj = [[result records] objectAtIndex:0];
       NSString * ActiveGloProInfoId = [[[obj fields] objectForKey:@"Id"] retain];
        NSString * _query = nil;
        if ([settingInfoId length] != 0)
            _query = [NSString stringWithFormat:@"Select Id, SVMXC__Setting_Configuration_Profile__c, SVMXC__Setting_ID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Active__c, SVMXC__IsDefault__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Setting_Configuration_Profile__c = \'%@\' AND SVMXC__Setting_ID__c IN %@ AND RecordType.Name = \'SETTING VALUE\' ORDER BY SVMXC__Setting_Unique_ID__c", ActiveGloProInfoId, settingInfoId];
        else
            _query = [NSString stringWithFormat:@"SELECT Id, SVMXC__Setting_Configuration_Profile__c, SVMXC__Setting_ID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Active__c, SVMXC__IsDefault__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Setting_Configuration_Profile__c = \'%@' AND RecordType.Name = \'SETTING VALUE\' ORDER BY SVMXC__Setting_Unique_ID__c", ActiveGloProInfoId];
		
		SMLog(kLogLevelVerbose,@"didGetActiveGlobalProfile = %@", _query);
        [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetSettingsValue:error:context:) context:nil];
    }
    else
    {
        // Continue logging in
        didGetPDF = YES;
    }
}

- (void) didGetSettingsValue:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if ([[result records] count] > 0)
    {
        appDelegate.serviceReport = [[NSMutableDictionary alloc] initWithCapacity:0];
        appDelegate.addressType = [[NSMutableString alloc] initWithCapacity:0];
        
        settingsValueArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        for (int i = 0; i < [[result records] count]; i++)
        {
            ZKSObject * obj = [[result records] objectAtIndex:i];
            [settingsValueArray addObject:[obj fields]];
            
        }
    }
    [self insertSettingsIntoTable:settingsValueArray:@"SettingsValue"];
    [self insertSettingsIntoTable:settingsInfoArray:@"SettingsInfo"];
    
    NSString * version = [appDelegate serverPackageVersion];
	int _stringNumber = [version intValue];
    if(_stringNumber >=  (KMinPkgForScheduleEvents * 100000))
    {
        [self getCodeSnippetSetting];
    }
    
    [self getImageForServiceReportLogo];
    
    appDelegate.wsInterface.didOpComplete = TRUE;
    SMLog(kLogLevelVerbose,@"IComeOUTHere didgetsettings");

}
-(void)insertSettingsIntoTable:(NSMutableArray*)array:(NSString*)TableName
{
    SMLog(kLogLevelVerbose,@"  MetaSync insertSettingsIntoTable processing starts: %@", [NSDate date]);
    NSString * field_string = @"";
    NSString * field_value = @"";
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"insertSettingsIntoTable"
                                                         andRecordCount:0];
    [self beginTransaction];
    
    
    for (NSDictionary * dict in array) 
    {
        field_string = @"";
        field_value = @"";
        NSArray * allkeys = [dict allKeys];
        NSArray * allvalue = [dict allValues];
        
        for (int i = 0; i < [allkeys count]; i++)
        {
            NSString * str = [allkeys objectAtIndex:i];
            //Single Quote Fix
            if ([str isKindOfClass:[NSNull class]])
                str = @"";
            [str stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            
            NSString * value = [allvalue objectAtIndex:i];
            if ([value isKindOfClass:[NSNull class]])
                value = @"";
            value = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

            if (![str isEqualToString:nil])
            {
                if ([field_string length] > 0)
                {
                    field_string = [field_string stringByAppendingString:@", "];
                    field_value = [field_value stringByAppendingString:@", "];
                }
                field_string = [field_string stringByAppendingString:[NSString stringWithFormat:@"%@", str]];
                field_value = [field_value stringByAppendingString:[NSString stringWithFormat:@"'%@'", value]];
            }
        }
        
        NSString * query =[NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)",TableName, field_string, field_value];
        [self createTable:query];
        
       // SMLog(kLogLevelVerbose,@" [OBSERV] insertSettingsIntoTable :Query  => \n %@", query);
        
    }
    
    [self endTransaction];
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"insertSettingsIntoTable"
                                                         andRecordCount:[array count]];
    
    [[PerformanceAnalytics sharedInstance] addCreatedRecordsNumber:[array count]];
    
    
}

#pragma mark - update recents plist
- (void) updateRecentsPlist
{
    NSString *error;
    
    NSString *rootPath = [appDelegate getAppCustomSubDirectory]; // [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *plistPath = [rootPath stringByAppendingPathComponent:OBJECT_HISTORY_PLIST];
    
    NSData * plistData = [NSPropertyListSerialization dataFromPropertyList:plistPath format:NSPropertyListXMLFormat_v1_0
                                                          errorDescription:&error];
    
    NSMutableArray * array = nil;
    
    NSMutableArray * updated_array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    if(plistData)
    {
        array = [[[NSMutableArray alloc] initWithContentsOfFile:plistPath] autorelease];
    }
    
    for (NSDictionary * recentsDict in array)
    {        
        
        //7418: Removed condition to check if nameField isEqualToString:nil and inner condition
        
        NSString * headerObjectName = [recentsDict objectForKey:OBJ_NAME];
            
        NSString * name = [self getNameFieldForObject:headerObjectName WithRecordId:[recentsDict objectForKey:RESULTID]];
            
        [recentsDict setValue:name forKey:NAME_FIELD];
        
        //7221:
        NSString *objectLabel = [recentsDict valueForKey:OBJECT_LABEL];
        for (NSDictionary *labelDict in appDelegate.objectLabelName_array)
        {
            if ([[labelDict allKeys] containsObject:headerObjectName])
            {
                objectLabel = [labelDict valueForKey:headerObjectName];
                break;
            }
        }
        [recentsDict setValue:objectLabel forKey:OBJECT_LABEL];

        
        [updated_array addObject:recentsDict];
    }
    
    [updated_array writeToFile:plistPath atomically:YES];
    [appDelegate.recentObject removeAllObjects];    
}

-(NSMutableDictionary *)getNameFieldForRefrenceObject:(NSDictionary*)tableArray
{
    NSMutableString * queryStatement1 = [[NSMutableString alloc]initWithCapacity:0];
    NSMutableDictionary *NameFieldDict=[[NSMutableDictionary alloc]init];
    queryStatement1 = [NSMutableString stringWithFormat:@"SELECT type,reference_to FROM SFObjectField where object_api_name = '%@'and api_name='%@'",[appDelegate.dataBase getApiNameFromFieldLabel:[tableArray objectForKey:@"SVMXC__Object_Name2__c"]],[appDelegate.dataBase getApiNameFromFieldLabel:[tableArray objectForKey:@"SVMXC__Field_Name__c"]]];
    sqlite3_stmt * labelstmt;
    
    const char *selectStatement = [queryStatement1 UTF8String];
    char *type=nil,*refrence_to=nil,*name_field=nil;
    NSString *namefiled=@"";
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
        {
            type = (char *) synchronized_sqlite3_column_text(labelstmt,0);
            refrence_to = (char *) synchronized_sqlite3_column_text(labelstmt,1);
        }
    }
    
    synchronized_sqlite3_finalize(labelstmt);
    
    NSString *strType,*strRefrence_to;
    if((type != nil)&& strlen(type))
        strType=[NSString stringWithFormat:@"%s",type];
    else
        strType=@" ";
    if((refrence_to != nil)&& strlen(refrence_to))
        strRefrence_to=[NSString stringWithFormat:@"%s",refrence_to];
    else
        strRefrence_to=@" ";
    if([strType isEqualToString:@"reference"])
    {
        queryStatement1 = [NSMutableString stringWithFormat:@"SELECT api_name FROM SFObjectField where name_field='TRUE' and object_api_name='%@'",strRefrence_to];
        sqlite3_stmt * labelstmt;
        const char *selectStatement = [queryStatement1 UTF8String];
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
        {
            if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
            {
                name_field = (char *) synchronized_sqlite3_column_text(labelstmt,0);
                if ((name_field !=nil) && strlen(name_field))
                    namefiled=[NSString stringWithFormat:@"%s",name_field];
                [NameFieldDict setObject:namefiled forKey:@"namefiled"];
                [NameFieldDict setObject:strRefrence_to forKey:@"reference_to"];
            }
        }
        synchronized_sqlite3_finalize(labelstmt);
    }
    return NameFieldDict;
}
- (NSString *) getNameFieldForObject:(NSString *)headerObjectName WithRecordId:(NSString *)recordId
{
    NSString * queryStatement = @"";
    
    NSString * Name = [appDelegate.dataBase getApiNameForNameField:headerObjectName];
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:[NSString stringWithFormat:@"getNameFieldForObject :%@", headerObjectName]
                                                         andRecordCount:1];
    
    queryStatement = [NSString stringWithFormat:@"SELECT %@ From '%@' WHERE local_id = '%@'" , Name, headerObjectName, recordId];

    
    sqlite3_stmt * stmt;
    NSString * nameField = @"";
    
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            const char * name = (char *) synchronized_sqlite3_column_text(stmt, 0);
            if (name != nil && strlen(name))
                nameField = [NSString stringWithUTF8String:name];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:[NSString stringWithFormat:@"getNameFieldForObject :%@", headerObjectName]
                                                                      andRecordCount:0];
    
    
    return nameField;
}



-(void)StartIncrementalmetasync
{
	//appDelegate.syncTypeInProgress = METASYNC_INPROGRESS;
    SMLog(kLogLevelVerbose,@"  StartIncrementalmetasync  .... st");
    
    if (self.tempDb == nil)
    {
        [self openDB:TEMPDATABASENAME type:DATABASETYPE1 sqlite:nil];
    }
    
    //We are retriving the SFObjectField table here so that we can compare the fields of the tables of the two databases
    //not necessary
    // tableNames = [self retrieveQueryForTableName];
    // [self createTemporaryTable:tableNames];
    
    //all the tables which do not form in metasync are being created here in the backup
    
    if (object_names != nil)
    {
        object_names = nil;
    }
    object_names = [[NSMutableArray alloc] initWithCapacity:0];
    object_names = [self retreiveTableNamesFronDB:appDelegate.db];
    
    for (NSString * objectName in object_names)
    {
        NSString * query = [self retrieveQuery:objectName sqlite:appDelegate.db];
        [self createTemporaryTable:query];
    }
    
    //This method fills the backup DB with all the data
    
    [self createBackUpDb];
    [appDelegate startBackgroundThreadForLocationServiceSettings];
    appDelegate.didincrementalmetasyncdone = TRUE;
    
}

- (void) createBackUpDb
{  
    //NSString * query1 = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS sfm",self.dbFilePath];
    
    //SMLog(kLogLevelVerbose,@" [MON]  createBackUpDb : ATTACH DATABASE %@", query1);
    
    //[self createTemporaryTable:query1];
    SMLog(kLogLevelVerbose,@"  createBackUpDb  .... st");
    
    BOOL hasCreated = [self attachDatabase:self.tempDb byName:kAttachementNameSFM andPath:self.dbFilePath];
    
    if (! hasCreated)
    {
        SMLog(kLogLevelWarning,@" Unable to create attachment for db backup!");
        return;
    }

    NSString * query1 = nil;
    
    NSArray *tableNames = [NSArray arrayWithObjects:@"SVMXC__Code_Snippet__c",@"SVMXC__Code_Snippet_Manifest__c", nil ];

     [self beginTransaction];
    
    //Here we fill up the tables with data
    for (NSString * objectName in object_names)
    {
        if([tableNames containsObject:objectName])
            continue;
        if ([objectName isEqualToString:@"Case"])
            objectName = @"'Case'";
        
       // query1 = [NSString stringWithFormat:@"INSERT INTO %@ SELECT * FROM sfm.%@", objectName, objectName];
        query1 = [NSString stringWithFormat:@"INSERT INTO %@ SELECT * FROM %@.%@", objectName, kAttachementNameSFM, objectName];
        
        [self createTemporaryTable:query1];
    }
    
    [self endTransaction];

     SMLog(kLogLevelVerbose,@"  createBackUpDb  .... releasing main DB");
    // Vipind-db-optmz - 3
    [self closeDatabase:appDelegate.db];
    [appDelegate releaseMainDatabase];
    //Delete the old database after creating the backup
    [self deleteDatabase:DATABASENAME];
    
    // Dettach kAttachementNameSFM
    
    SMLog(kLogLevelVerbose,@"  createBackUpDb  .... dettaching  kAttachementNameSFM");
    
    [self detachDatabase:self.tempDb byName:kAttachementNameSFM];

    
   //we again start metasync here

   //if ([self closeDatabase:appDelegate.db])
   //{
     //  [appDelegate releaseMainDatabase];
   //}
   
    if (appDelegate.db == nil)
    {
        [appDelegate initWithDBName:DATABASENAME1 type:DATABASETYPE1];
    }
    SMXLogger *logger = [SMXLogger sharedInstance];
    logger.isLoggerTableCreated = FALSE;
    
    // Mem_leak_fix - Vipindas 9493 Jan 18
    @autoreleasepool
    {
         [self doMetaSync];
    }
}

- (void) doMetaSync
{
    @autoreleasepool
    {
        time_t t1;
        time(&t1);
        
        //RADHA 2012june12
        [appDelegate.dataBase removecache];
        
        appDelegate.wsInterface.didOpComplete = FALSE;
        appDelegate.connection_error = FALSE;
        
        [appDelegate updateInstalledPackageVersion];
        NSString * retVal = [self callMetaSync];
        
        // Uncomment this when SFM Search Module is Required
        //SFM Search
        if([appDelegate enableGPS_SFMSearch])
        {
            appDelegate.wsInterface.didOpSFMSearchComplete = FALSE;
            SMXMonitor *monitor = [[[SMXMonitor alloc] init] autorelease];
            [monitor monitorSMMessageWithName:@"[DataBase doMetaSync:SFM_SEARCH]"
                                 withUserName:appDelegate.currentUserName
                                     logLevel:kPerformanceLevelWarning
                                   logContext:@"Start"
                                 timeInterval:kWSExecutionDuration];
            @autoreleasepool
            {
                  [appDelegate.wsInterface metaSyncWithEventName:SFM_SEARCH eventType:SYNC values:nil];
            }
            
            
            // Mem_leak_fix - Vipindas 9493 Jan 18
            @autoreleasepool
            {
                while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
                {
#ifdef kPrintLogsDuringWebServiceCall
                SMLog(kLogLevelVerbose,@"Datebase.m : doMetaSync: SFM_SEARCH");
#endif
                //NSLog(@"---- doMetaSync: SFM_SEARCH");
                if (![appDelegate isInternetConnectionAvailable])
                {
                    if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
                        [MyPopoverDelegate performSelector:@selector(throwException)];
                    break;
                }
                if (appDelegate.wsInterface.didOpSFMSearchComplete == TRUE)
                    break;
                if (appDelegate.connection_error)
                {
                    break;
                }
                
            }
            }
            [monitor monitorSMMessageWithName:@"[DataBase doMetaSync:SFM_SEARCH]"
                                 withUserName:appDelegate.currentUserName
                                     logLevel:kPerformanceLevelWarning
                                   logContext:@"Stop"
                                 timeInterval:kWSExecutionDuration];
            SMLog(kLogLevelVerbose,@"MetaSync SFM Search End: %@", [NSDate date]);
            
            //SFM Search End
        }
        
        //	[appDelegate setCurrentSyncStatusProgress:METASYNC_SEARCH optimizedSynstate:0];
        if([appDelegate doesServerSupportsModule:kMinPkgForGetPriceModule])
        {
            appDelegate.initial_sync_status = SYNC_SFM_SEARCH;
            appDelegate.Sync_check_in = FALSE;
            
            appDelegate.wsInterface.didOpGetPriceComplete = FALSE;
            SMXMonitor *monitor = [[[SMXMonitor alloc] init] autorelease];
            [monitor monitorSMMessageWithName:@"[DataBase GET_PRICE_OBJECTS]"
                                 withUserName:appDelegate.currentUserName
                                     logLevel:kPerformanceLevelWarning
                                   logContext:@"Start"
                                 timeInterval:kWSExecutionDuration];
            @autoreleasepool
            {
                   [appDelegate.wsInterface metaSyncWithEventName:GET_PRICE_OBJECTS eventType:SYNC values:nil];
            }
            
            
            // Mem_leak_fix - Vipindas 9493 Jan 18
            @autoreleasepool
            {
                while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
                {
    #ifdef kPrintLogsDuringWebServiceCall
                    SMLog(kLogLevelVerbose,@"DataBase.m : doMetaSync: Get Price Objects");
    #endif
                    
                    //NSLog(@"---- doMetaSync: Get Price Objects");
                    if (![appDelegate isInternetConnectionAvailable])
                    {
                        appDelegate.initial_sync_succes_or_failed = META_SYNC_FAILED;
                        break;
                    }
                    if(appDelegate.initial_sync_succes_or_failed == META_SYNC_FAILED)
                    {
                        break;
                    }
                    if (appDelegate.connection_error)
                    {
                        break;
                    }
                    
                    if (appDelegate.wsInterface.didOpGetPriceComplete == TRUE)
                        break;
                }
            }
            [monitor monitorSMMessageWithName:@"[DataBase GET_PRICE_OBJECTS]"
                                 withUserName:appDelegate.currentUserName
                                     logLevel:kPerformanceLevelWarning
                                   logContext:@"Stop"
                                 timeInterval:kWSExecutionDuration];
            
            SMLog(kLogLevelVerbose,@"MetaSync Get Price PRICE_CALC_OBJECTS End: %@", [NSDate date]);
            
            if([[appDelegate.wsInterface getValueFromUserDefaultsForKey:@"doesGetPriceRequired"] boolValue])
            {
                appDelegate.initial_sync_status = SYNC_SFM_SEARCH;
                appDelegate.Sync_check_in = FALSE;
                
                appDelegate.wsInterface.didOpGetPriceComplete = FALSE;
                SMXMonitor *monitor = [[[SMXMonitor alloc] init] autorelease];
                [monitor monitorSMMessageWithName:@"[DataBase GET_PRICE_CODE_SNIPPET]"
                                     withUserName:appDelegate.currentUserName
                                         logLevel:kPerformanceLevelWarning
                                       logContext:@"Start"
                                     timeInterval:kWSExecutionDuration];
                @autoreleasepool
                {
                   [appDelegate.wsInterface metaSyncWithEventName:GET_PRICE_CODE_SNIPPET eventType:SYNC values:nil];
                }
                
                // Mem_leak_fix - Vipindas 9493 Jan 18
                @autoreleasepool
                {
                    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
                    {
#ifdef kPrintLogsDuringWebServiceCall
                    SMLog(kLogLevelVerbose,@"DataBase.m : doMetaSync: Get Price Code Snippet");
#endif
                    //NSLog(@"---- doMetaSync: Code Snippet");
                    
                    if (![appDelegate isInternetConnectionAvailable])
                    {
                        appDelegate.initial_sync_succes_or_failed = META_SYNC_FAILED;
                        break;
                    }
                    if(appDelegate.initial_sync_succes_or_failed == META_SYNC_FAILED)
                    {
                        break;
                    }
                    if (appDelegate.connection_error)
                    {
                        break;
                    }
                    
                    if (appDelegate.wsInterface.didOpGetPriceComplete == TRUE)
                        break;
                    }
                }
                [monitor monitorSMMessageWithName:@"[DataBase GET_PRICE_CODE_SNIPPET]"
                                     withUserName:appDelegate.currentUserName
                                         logLevel:kPerformanceLevelWarning
                                       logContext:@"Stop"
                                     timeInterval:kWSExecutionDuration];
                
                SMLog(kLogLevelVerbose,@"MetaSync Get Price PRICE_CALC_CODE_SNIPPET End: %@", [NSDate date]);
            }
        }
        //	[appDelegate setCurrentSyncStatusProgress:METASYNC_GETPRICE optimizedSynstate:0];
        
        // Mem_leak_fix - Vipindas 9493 Jan 18
        @autoreleasepool
        {
            if ([retVal isEqualToString:SUCCESS_])
            {
                [appDelegate getDPpicklistInfo];
                
                //		[appDelegate setCurrentSyncStatusProgress:METASYNC_DEPPICKLIST optimizedSynstate:0];
                SMLog(kLogLevelVerbose,@"META SYNC 1");
                
                time_t t2;
                time(&t2);
                double diff = difftime(t2,t1);
                SMLog(kLogLevelVerbose,@"time taken for meta and data sync = %f",diff);
                
                [self populateDatabaseFromBackUp];
                
                //Radha purging - 10/April/12
                NSMutableArray * recordId = [appDelegate.dataBase getAllTheRecordIdsFromEvent];
                
                appDelegate.initialEventMappinArray = [appDelegate.dataBase checkForTheObjectWithRecordId:recordId];
            }
        }
    }
    
    //Radha End
    //7221
    [[NSNotificationCenter defaultCenter] postNotificationName:CONFIGURATTON_SYNC_COMPLETED object:nil];

}



- (NSString *) callMetaSync
{
    appDelegate.wsInterface.didOpComplete = FALSE;
    appDelegate.connection_error = FALSE;
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {		
		//OAuth.
		[[ZKServerSwitchboard switchboard] doCheckSession];

        if(!appDelegate.connection_error)
        {
            break;
        }
        //Fix for Defect 007410
        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
    }
    SMXMonitor *monitor = [[[SMXMonitor alloc] init] autorelease];
    [monitor monitorSMMessageWithName:@"[DataBase callMetaSync]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Start"
                         timeInterval:10.0];

    [appDelegate.wsInterface metaSyncWithEventName:SFM_METADATA eventType:INITIAL_SYNC values:nil];
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(kLogLevelVerbose,@"Datebase.m : callMetaSync: SFM_METADATA");
#endif

        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
        
        if (appDelegate.wsInterface.didOpComplete == TRUE)
            break; 
        
        
        if (appDelegate.connection_error)
            break;
    }
    [monitor monitorSMMessageWithName:@"[DataBase callMetaSync]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Stop"
                         timeInterval:10.0];

    //RADHA - If connection error start meta sync again
    if (![appDelegate isInternetConnectionAvailable])
    {
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
            [MyPopoverDelegate performSelector:@selector(throwException)];
        return NOINTERNET;
    }
    
    if (appDelegate.connection_error && [appDelegate isInternetConnectionAvailable])
    {
        appDelegate.connection_error = FALSE;
        [self doMetaSync];
        return CONNECTIONERROR;
    }
    
    return SUCCESS_;
}

- (NSMutableArray *) retreiveTableNamesFronDB:(sqlite3 *)dbName
{
    NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    NSString * query = [NSString stringWithFormat:@"SELECT tbl_name FROM Sqlite_master where type = 'table'"];
    
    sqlite3_stmt * stmt;
    NSString * object_api_name = @"";
    if (synchronized_sqlite3_prepare_v2(dbName, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            const char * _object = (char *) synchronized_sqlite3_column_text(stmt, 0);
            
            if ((_object != nil) && strlen(_object))
            {
                object_api_name = [NSString stringWithUTF8String:_object];
                if ([object_api_name isEqualToString:@"sqlite_sequence"])
                    continue;
                [array addObject:object_api_name];
            }                   
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    return array;
}


- (void) copyTempsqlToSfm
{
    if (object_names == nil)
        object_names = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (self.tempDb == nil)
    {
        [self openDB:TEMPDATABASENAME type:DATABASETYPE1 sqlite:nil];
    }
    
    object_names = [self retreiveTableNamesFronDB:self.tempDb];
    
    [appDelegate.dataBase clearDatabase];
    
    for (NSString * objectName in object_names)
    {
        NSString * query = [self retrieveQuery:objectName sqlite:self.tempDb];
        
        [self createTable:query];
    }

    
    if (appDelegate.db == nil)
    {
        [appDelegate initWithDBName:DATABASENAME1 type:DATABASETYPE1];
    }
    
   // NSString * query1 = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS tempsfm",filepath];
   // [self createTable:query1];
    
    [self loadTempDatabaseFileFromPath];
    
    BOOL hasCreatedAttachment = [self attachDatabase:appDelegate.db byName:kAttachementNameTempSFM andPath:filepath];
    
    if ( ! hasCreatedAttachment)
    {
        SMLog(kLogLevelWarning,@"Unable to create attachment for copying temp sql to SFM");
        return;
    }
    
    NSString * query1 = nil;
    
     [self beginTransaction];
    //Here we fill up the tables with data  
    for (NSString * objectName in object_names)
    {
        if ([objectName isEqualToString:@"Case"])
            objectName = @"'Case'";
        
        query1 = [NSString stringWithFormat:@"INSERT INTO %@ SELECT * FROM tempsfm.%@", objectName, objectName];
        [self createTable:query1];
    }
    [self endTransaction];
    
    appDelegate.internetAlertFlag = TRUE;
    popOver_view.syncConfigurationFailed = TRUE;
	//Radha - Fix for the defect 5745
	[appDelegate.calDataBase insertMetaSyncStatus:@"Red" WithDB:appDelegate.db];
    [self settingAfterIncrementalMetaSync];
    
    // Dettach tempsfm
    [self detachDatabase:appDelegate.db byName:kAttachementNameTempSFM];

}

// Vipin-db-optmz
- (void)resetConfigurationForDataBase:(sqlite3 *)database
{
    if (self.dbTransactionCount > 0)
    {
        //NSLog(@"Skipping db configuration reset since %d live transaction exist", dbTransactionCount);
        return;
    }
    
    char * errMessageSynch;
    char * errMessageJournalMod;
    char * errMessagePageSize;
    
    int  pageSizeResult =  synchronized_sqlite3_exec(database, "PRAGMA page_size = 4096", NULL, NULL, &errMessagePageSize);
    int  syncResult     =  synchronized_sqlite3_exec(database, "PRAGMA synchronous = OFF", NULL, NULL, &errMessageSynch);
    int  journalResult  =  synchronized_sqlite3_exec(database, "PRAGMA journal_mode = MEMORY", NULL, NULL, &errMessageJournalMod);
    //int  journalResult  =  synchronized_sqlite3_exec(database, "PRAGMA journal_mode = WAL", NULL, NULL, &errMessageJournalMod);
    // Vipin: we are moving more safer journal mode to avoid database corruption
    
    if (pageSizeResult != SQLITE_OK)
    {
        //NSLog(@" ConfigDatabase Page Size : %d %@", pageSizeResult, [NSString stringWithUTF8String:errMessagePageSize]);
    }
    
    if (syncResult != SQLITE_OK)
    {
        //NSLog(@" ConfigDatabase Synchronous : %d %@", syncResult, [NSString stringWithUTF8String:errMessageSynch]);
    }
    
    if (journalResult != SQLITE_OK)
    {
        //NSLog(@" ConfigDatabase journal mod: %d %@", journalResult, [NSString stringWithUTF8String:errMessageJournalMod]);
    }
}


-(void)openDB:(NSString *)name type:(NSString *)type sqlite:(sqlite3 *)database
{

    [self loadTempDatabaseFileFromPath];
    
    NSError *error;
    
    if (tempDb != nil)
    {
        SMLog(kLogLevelVerbose,@"[DBOPX] temp database exist.. skipping initialisation of DB");
        return;
    }
    
    BOOL success=[[NSFileManager defaultManager] fileExistsAtPath:filepath];
    if ( success)
    { 
        SMLog(kLogLevelVerbose,@"\n db exist in the path");		
    }
    else    //didn't find db, need to copy
    {
        NSString *backupDbPath = [[NSBundle mainBundle] pathForResource:TEMPDATABASENAME ofType:DATABASETYPE1]; 
        if (backupDbPath == nil) 
        {
            SMLog(kLogLevelVerbose,@"\n db not able to create error");   
        }
        else 
        { 
            BOOL copiedBackupDb = [[NSFileManager defaultManager] copyItemAtPath:backupDbPath toPath:filepath error:&error]; 
            if (!copiedBackupDb) 
                NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        } 
    }
    
    // Vipind-db-optmz -
    // config sqlite to work with the same connection on multiple threads
    /*
    if (sqlite3_config(SQLITE_CONFIG_SERIALIZED) == SQLITE_OK)
    {
        SMLog(kLogLevelVerbose,@"[OPMX] Use sqlite on multiple threads, using the same connection");
    }
    else
    {
        SMLog(kLogLevelVerbose,@"[OPMX] Single connection single thread");
    }
     */
    
    if( sqlite3_open ([filepath UTF8String], &tempDb) != SQLITE_OK )
    { 
        //NSLog(@"couldn't open db:");
        NSAssert(0, @"Database failed to open.");		//throw another exception here
    }
    else
    {
        // Vipin-db-optmz
        SMLog(kLogLevelVerbose,@" Database : openDB : Reset DB Configuration - %@ - %@", TEMPDATABASENAME, name);
        
        [self resetConfigurationForDataBase:self.tempDb];
        [[PerformanceAnalytics sharedInstance] registerOperationCount:0 forDatabase:@"tempDB"];
    }
}


-(NSString *)retrieveQuery:(NSString *)tableName sqlite:(sqlite3 *)database
{
    NSMutableString * query = [NSMutableString stringWithFormat:@"SELECT sql FROM sqlite_master WHERE tbl_name = '%@' AND type = 'table'", tableName];
    
    sqlite3_stmt * stmt;
    
    NSString * queryStatement = @"";    
    const char * _query = [query UTF8String];
    
    if ( synchronized_sqlite3_prepare_v2(database, _query,-1, &stmt, nil) == SQLITE_OK )
    {
        while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char *field1 = (char *) synchronized_sqlite3_column_text(stmt,0);
            if ((field1 != nil) && strlen(field1))
            {
                NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
                queryStatement = [NSString stringWithFormat:@"%@",field1Str];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    
    return queryStatement;
}
- (BOOL) createTemporaryTable:(NSString *)statement
{
    char * err;
    /// Position pbserve
    if (synchronized_sqlite3_exec(self.tempDb, [statement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
            [MyPopoverDelegate performSelector:@selector(throwException)];
        //NSLog(@"%@", statement);
		//NSLog(@"METHOD: createTemporaryTable");
        //NSLog(@"ERROR IN INSERTING %s", err);
		[appDelegate printIfError:nil ForQuery:statement type:INSERTQUERY];
        return NO;
    }
    else
    {
        //NSLog(@"[MON] Created createTemporaryTable");
    }
    return YES;
}

- (NSArray *) createTempTableForSummaryAndTroubleShooting
{
    NSString * query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  ChatterPostDetails ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'ProductId' VARCHAR NOT NULL ,'Body' TEXT,'CreatedById' VARCHAR,'CreatedDate' VARCHAR,'Id' VARCHAR,'POSTTYPE' VARCHAR,'Username' VARCHAR,'Email' VARCHAR,'FeedPostId' VARCHAR,'FullPhotoUrl' VARCHAR)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS Document ('local_id' INTEGER PRIMARY KEY  NOT NULL UNIQUE DEFAULT (0), 'AuthorId' VARCHAR, 'Body' VARCHAR, 'BodyLength' INTEGER, 'ContentType' VARCHAR, 'CreatedById' VARCHAR, 'Description' VARCHAR, 'DeveloperName' VARCHAR, 'FolderId' VARCHAR, 'Id' VARCHAR, 'IsBodySearchable' BOOL, 'IsDeleted' BOOL, 'IsInternalUseOnly' BOOL, 'IsPublic' BOOL, 'Keywords' TEXT, 'LastModifiedById' VARCHAR, 'LastModifiedDate' DATETIME, 'Name' VARCHAR, 'NamespacePrefix' VARCHAR, 'SystemModstamp' VARCHAR, 'Type' VARCHAR)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  ProductImage ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'productId' VARCHAR, 'productImage' VARCHAR)"];
    [self createTemporaryTable:query];
    
    //krishna opdoc added signName
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  SFSignatureData ('record_Id' VARCHAR,'object_api_name' VARCHAR,'signature_data' TEXT,'sig_Id' TEXT ,'WorkOrderNumber' VARCHAR, 'sign_type' VARCHAR , 'operation_type' VARCHAR, 'signature_type_id' TEXT, 'signature_name' TEXT)"];
    [self createTemporaryTable:query];
    
    //Krishna OPDoc html data
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  SFOPDocHtmlData ('local_id' VARCHAR,'object_api_name' VARCHAR,'opdoc_data' TEXT,'sf_id' TEXT ,'WorkOrderNumber' VARCHAR, 'doc_name' TEXT, 'process_id' TEXT)"];
    [self createTemporaryTable:query];
    
    //krishna Opdocs requested PDF
    //to store the data of pdf, which is requested for generation and yet not downloaded.
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFRequiredPdf ('process_id' TEXT, 'record_id' TEXT, 'attachment_id' TEXT)"];
    [self createTemporaryTable:query];

    //krishna Opdocs requested Signature
    //to store the data of sign, which is requested for generation and yet not downloaded.
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFRequiredSignature ('sign_id' TEXT,'signature_id' TEXT)"];
    [self createTemporaryTable:query];

    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS UserImages ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0), 'username' VARCHAR,'userimage' BLOB)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS  trobleshootdata ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0),'ProductId' VARCHAR, 'ProductName' VARCHAR, 'Product_Doc' BLOB, 'DocId' VARCHAR, 'prod_manual_Id' VARCHAR, 'prod_manual_name' VARCHAR, 'productmanbody' VARCHAR)"];
    [self createTemporaryTable:query];
    
	//Sync_Override
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFDataTrailer ('timestamp' DATETIME, 'local_id' INTEGER,'sf_id' VARCHAR, 'record_type' VARCHAR, 'operation' VARCHAR, 'object_name' VARCHAR, 'sync_flag' BOOL , 'parent_object_name'  VARCHAR ,'parent_local_id'  VARCHAR , 'record_sent' VARCHAR ,'webservice_name' VARCHAR, 'class_name'  VARCHAR , 'sync_type' VARCHAR, 'header_localId' VARCHAR,'request_data' VARCHAR  ,'request_id' VARCHAR)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SFDataTrailer_Temp ('timestamp' DATETIME, 'local_id' INTEGER,'sf_id' VARCHAR, 'record_type' VARCHAR, 'operation' VARCHAR, 'object_name' VARCHAR, 'sync_flag' BOOL , 'parent_object_name'  VARCHAR ,'parent_local_id'  VARCHAR , 'record_sent' VARCHAR ,'webservice_name' VARCHAR, 'class_name'  VARCHAR , 'sync_type' VARCHAR, 'header_localId' VARCHAR)"];
    [self createTemporaryTable:query];
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SYNC_HISTORY ('last_sync_time' DATETIME , 'sync_type' VARCHAR , 'request_id' VARCHAR , 'SYNC_STATUS' BOOL )"];
    [self createTemporaryTable:query];
    
   
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS sync_Records_Heap ('sf_id' VARCHAR, 'local_id' VARCHAR,'object_name' VARCHAR, 'sync_type' VARCHAR, 'json_record' VARCHAR , 'sync_flag' BOOL , 'record_type' VARCHAR)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS sync_Record_Heap_Index ON sync_Records_Heap (sf_id ASC, local_id ASC, object_name ASC, sync_flag ASC)"];
    [self createTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS LookUpFieldValue ('object_api_name' VARCHAR, 'Id' PRIMARY KEY  NOT NULL  UNIQUE, 'value' VARCHAR)"]; //10408 Defect fix - Removed the loacl_id column since the application is not using the column any where, Instead replace Id colunm as PRIMARY KEY so no duplicate entry of the same Id is not inserted in the table.
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS Summary_PDF ('record_Id' VARCHAR,'object_api_name' VARCHAR, 'PDF_data' TEXT, 'WorkOrderNumber' VARCHAR, 'PDF_Id' VARCHAR, 'sign_type' VARCHAR, 'pdf_name' VARCHAR)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS sync_error_conflict ('sf_id' VARCHAR, 'local_id' VARCHAR,'object_name' VARCHAR, 'record_type' VARCHAR ,'sync_type' VARCHAR ,'error_message' VARCHAR ,'operation_type' VARCHAR , 'error_type' VARCHAR , 'override_flag'  VARCHAR ,'class_name' VARCHAR ,'method_name' VARCHAR ,'custom_ws_error' VARCHAR , 'request_id' VARCHAR )"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS contact_images ('contact_Id' VARCHAR, 'contact_Image' VARCHAR)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS internet_conflicts ('sync_type' VARCHAR, 'error_message' VARCHAR, 'operation_type' VARCHAR, 'error_type' VARCHAR)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS meta_sync_status ('sync_status' VARCHAR)"];  
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS meta_sync_due ('local_id' INTEGER PRIMARY KEY  NOT NULL  UNIQUE, 'description' VARCHAR)"];
    [self createTemporaryTable:query];
    
    query = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS servicereprt_logo ('logo' VARCHAR)"];
    [self createTemporaryTable:query];
    
    query =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS on_demand_download ('object_name' VARCHAR , 'sf_id' VARCHAR  PRIMARY KEY  NOT NULL UNIQUE, 'time_stamp' DATETIME ,'local_id' VARCHAR, 'record_type' VARCHAR, 'json_record' VARCHAR)"];
    [self createTemporaryTable:query];
    
    
    query =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ('object_name' VARCHAR , 'sf_id' VARCHAR PRIMARY KEY  NOT NULL UNIQUE, 'time_stamp' DATETIME ,'local_id' VARCHAR ) ",User_created_events];
    [self createTable:query];
    
    query =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ('object_name' VARCHAR ,'local_id' VARCHAR ) ",Event_local_Ids];
    [self createTable:query];
    
    query =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ('object_name' VARCHAR ,'local_id' VARCHAR) ",LOCAL_EVENT_UPDATE];
    [self createTable:query];
    
    [self createTemporaryTable:query];

    
    NSArray * tempTableArray = [NSArray arrayWithObjects:@"ChatterPostDetails",@"Document",@"ProductImage",@"SFSignatureData",@"UserImages",@"trobleshootdata",@"SFDataTrailer",@"SFDataTrailer_Temp",@"SYNC_HISTORY",@"sync_Records_Heap",@"LookUpFieldValue",@"Summary_PDF",@"sync_error_conflict", @"contact_images",@"internet_conflicts", @"meta_sync_status", @"meta_sync_due", @"SFOPDocHtmlData", @"SFRequiredPdf", @"SFRequiredSignature",@"on_demand_download", nil]; // Damodar - OPDocs
    
    return tempTableArray;
}
-(void)populateDatabaseFromBackUp
{
    SMLog(kLogLevelVerbose,@"  ----- populateDatabaseFromBackUp ----- ");
    
    if (appDelegate.db == nil)
    {
        [appDelegate initWithDBName:DATABASENAME1 type:DATABASETYPE1];
    }
    
    if (self.tempDb == nil)
    {
        [self openDB:TEMPDATABASENAME type:DATABASETYPE1 sqlite:nil];
    }

    [self loadTempDatabaseFileFromPath];
    
    //NSString * query1 = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS tempsfm",filepath];
    //[self createTable:query1];
    
    //SMLog(kLogLevelVerbose,@" [MON]  populateDatabaseFromBackUp : ATTACH DATABASE %@", query1);
    
    
    BOOL hasCreatedAttachment = [self attachDatabase:appDelegate.db
                                              byName:kAttachementNameTempSFM
                                             andPath:filepath];
    if (! hasCreatedAttachment)
    {
        SMLog(kLogLevelError,@"Unable to create attachment for populating database from backup");
        return;
    }
    
    NSMutableArray * objects = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT object_api_name FROM SFObjectField"];
    
    sqlite3_stmt * objectStatement;
    
    NSString * object_api_name = @"";
    
    if ( synchronized_sqlite3_prepare_v2(self.tempDb, [queryStatement UTF8String],-1, &objectStatement, nil) == SQLITE_OK )
    {
        while(synchronized_sqlite3_step(objectStatement) == SQLITE_ROW)
        {
			object_api_name = @"";
            char * field = (char *) synchronized_sqlite3_column_text(objectStatement,0);
            if ((field != nil) && strlen(field))
                object_api_name = [[NSString alloc] initWithUTF8String:field];
			if ([object_api_name length] > 0)
			{
				[objects  addObject:object_api_name];
			}
            
            
        }
    }
    
     synchronized_sqlite3_finalize(objectStatement);
    
	//Radha - Fix for the defect 5745
	objectStatement = nil;
	
	//Radha - Fix for defect 5745
	NSMutableArray * objects_sfmTable = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSString * queryStatement1 = [NSString stringWithFormat:@"SELECT DISTINCT object_api_name FROM SFObjectField"];
    
	object_api_name = @"";
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement1 UTF8String],-1, &objectStatement, nil) == SQLITE_OK )
    {
        while(synchronized_sqlite3_step(objectStatement) == SQLITE_ROW)
        {
			object_api_name = @"";
            char * field = (char *) synchronized_sqlite3_column_text(objectStatement,0);
            if ((field != nil) && strlen(field))
                object_api_name = [[NSString alloc] initWithUTF8String:field];
			if ([object_api_name length] > 0)
			{
				[objects_sfmTable  addObject:object_api_name];
			}
            
        }
    }
    //if srvr pkg grtr thn sum13 add log table
     synchronized_sqlite3_finalize(objectStatement);
    
    for (NSString * tableName in objects)
    {
		//Radha - Fix for the defect 5745
		if (![objects_sfmTable containsObject:tableName])
			continue;
		
        if ([tableName isEqualToString:@"Case"])
            tableName = @"'Case'";
        
        NSString * field_api = @"";
        NSString * field_type = @"";
        
        NSString * query_field = @"";
        
        NSMutableArray * old_fieldType = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray * new_fieldType = [[NSMutableArray alloc] initWithCapacity:0];
        
        sqlite3_stmt * stmt;
        
        NSString * query = [NSString stringWithFormat:@"PRAGMA table_info (%@)", tableName];
        
        
        if ( synchronized_sqlite3_prepare_v2(self.tempDb, [query UTF8String],-1, &stmt, nil) == SQLITE_OK )
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * field = (char *) synchronized_sqlite3_column_text(stmt,1);
                if ((field != nil) && strlen(field))
                    field_api = [[NSString alloc] initWithUTF8String:field];
                
                
                char * type = (char *) synchronized_sqlite3_column_text(stmt,2);
                if ((type != nil) && strlen(type))
                    field_type = [[NSString alloc] initWithUTF8String:type];
                
                NSDictionary * dict = [NSDictionary dictionaryWithObject:field_type forKey:field_api];
                NSDictionary * _dict = [NSDictionary dictionaryWithDictionary:dict];
                [old_fieldType addObject:_dict];
            }
        }
        synchronized_sqlite3_finalize(stmt);
        query = [NSString stringWithFormat:@"PRAGMA table_info (%@)", tableName];
        
        
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String],-1, &stmt, nil) == SQLITE_OK )
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * field = (char *) synchronized_sqlite3_column_text(stmt,1);
                if ((field != nil) && strlen(field))
                    field_api = [[NSString alloc] initWithUTF8String:field];
                
                
                char * type = (char *) synchronized_sqlite3_column_text(stmt,2);
                if ((type != nil) && strlen(type))
                    field_type = [[NSString alloc] initWithUTF8String:type];
                
                NSDictionary * dict = [NSDictionary dictionaryWithObject:field_type forKey:field_api];
                NSDictionary * _dict = [NSDictionary dictionaryWithDictionary:dict];
                [new_fieldType addObject:_dict];
            }
        }
        
        synchronized_sqlite3_finalize(stmt);
        
        for (NSDictionary * old_dict in old_fieldType)
        {
            NSArray * old_keys = [old_dict allKeys];
            NSString * old_value = [old_keys objectAtIndex:0];
            
            for (NSDictionary * new_dict in new_fieldType)
            {
                NSArray * new_keys = [new_dict allKeys];
                NSString * new_value = [new_keys objectAtIndex:0];
                
                if ([old_value isEqualToString:new_value])
                {
                    NSString * old_type = [old_dict objectForKey:old_value];
                    NSString * new_type = [new_dict objectForKey:new_value];
                    
                    if ([old_type isEqualToString:new_type])
                    {
                        if ([query_field length] > 0)
                        {
                            query_field = [query_field stringByAppendingString:@", "];
                        }
                        query_field = [query_field stringByAppendingString:old_value];
                    }
                    
                }
            }            
            
        }
        
         [self beginTransaction];
        NSString * finalQuery = [NSString stringWithFormat:@"INSERT INTO %@ (%@) SELECT %@ FROM tempsfm.%@",tableName,query_field,query_field,tableName];
        SMLog(kLogLevelVerbose,@"%@",finalQuery);
        [self createTable:finalQuery];
        [self endTransaction];
        SMLog(kLogLevelVerbose,@" Populate database  step 1 end"); 
        [field_type release];
        field_type=nil;
    }
    //Radha 2012june08
    
   
   SMLog(kLogLevelVerbose,@" Populate database  step 2 start");
   NSArray * tempArray = [self createTempTableForSummaryAndTroubleShooting];
   SMLog(kLogLevelVerbose,@" Populate database  step 2 end");
   SMLog(kLogLevelVerbose,@" Populate database  step 3 start");
   [self beginTransaction];
    
    for (NSString * table in tempArray)
    {  //008573
        if ([table isEqualToString:@"SFSignatureData"] && [self hasOldSchema:@"SFSignatureData"]) {
            
            SMLog(kLogLevelVerbose,@"FIRST TIME CONFIG SYNC AFTER UPGRADE FROM 11.1.0.0");
            NSString *queryFields = [NSString stringWithFormat:@"record_Id,object_api_name,signature_data,sig_Id, WorkOrderNumber,sign_type,operation_type"];
            NSString * temp_query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@) SELECT * FROM tempsfm.%@", table,queryFields, table];
            int success = [self createTable:temp_query];
        }
        //10534 - defect fix
        if ([table isEqualToString:@"LookUpFieldValue"] && [self hasSchemaChaged:@"LookUpFieldValue" column:@"local_id"])
        {
            NSString *queryFields = [NSString stringWithFormat:@"object_api_name, Id, value"];
            
            NSString * queryStatement = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@) SELECT %@ FROM tempsfm.%@ Where value != ''", table, queryFields, queryFields, table];
            [self createTable:queryStatement];
        }
        else {
            NSString * temp_query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ SELECT * FROM tempsfm.%@", table, table];
            int success = [self createTable:temp_query];
        }
   }
    
    [self endTransaction];
    
    SMLog(kLogLevelVerbose,@" Populate database  step 3 end");
    
    // Dettach - tempsfm;
    [self detachDatabase:appDelegate.db byName:kAttachementNameTempSFM];
    
    appDelegate.internetAlertFlag = TRUE;
    
    popOver_view.syncConfigurationFailed = FALSE;
//	[appDelegate setCurrentSyncStatusProgress:METASYNC_POPULATEDATA optimizedSynstate:0];
	
    [self settingAfterIncrementalMetaSync];
    
}

- (BOOL)hasOldSchema:(NSString *)tableName {
    
    NSString * query = [self retrieveQuery:tableName sqlite:self.tempDb];
    if ([Utility isStringEmpty:query]) {
        return NO;
    }
    if ([Utility containsString:@"signature_type_id" inString:query]) {
        return NO;
    }
    return YES;
}

//10534 - defect fix
-(BOOL)hasSchemaChaged:(NSString *)tableName column:(NSString *)columnName
{
    BOOL schemaChaged = NO;
    
    NSString * query = [self retrieveQuery:tableName sqlite:self.tempDb];
    if (![Utility isStringEmpty:query])
    {
        //If temp db contains the local_id column the check id sfm db contins the same
        if ([Utility containsString:columnName inString:query])
        {
            query = [self retrieveQuery:tableName sqlite:appDelegate.db];
            
            if ([Utility containsString:columnName inString:query])
            {
                schemaChaged = NO;
            }
            else
            {
                schemaChaged = YES;
            }
        }
    }
    return schemaChaged;
}

- (void)deleteDatabase:(NSString *)databaseName
{
    //NSLog(@" DEL deleteDatabase - %@",databaseName);//LOG_TEST
    
    NSError *error; 
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",databaseName,DATABASETYPE1]];
    
    [fileManager removeItemAtPath:fullPath error:&error];
    
    //NSLog(@"database removed");//LOG_TEST
}

- (void) removecache
{
    if ((appDelegate.wsInterface.processDictionary != nil) && [appDelegate.wsInterface.processDictionary count] > 0)
    {
        appDelegate.wsInterface.processDictionary = nil;
        appDelegate.wsInterface.processDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    if ((appDelegate.wsInterface.objectDefinitions != nil) && [appDelegate.wsInterface.objectDefinitions count] > 0)
    {
        appDelegate.wsInterface.objectDefinitions = nil;
        appDelegate.wsInterface.objectDefinitions = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if ((appDelegate.wsInterface.object != nil) && [appDelegate.wsInterface.object count] > 0)
    {
        appDelegate.wsInterface.object = nil;
        appDelegate.wsInterface.object = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if ((appDelegate.wsInterface.picklistObject != nil) && [appDelegate.wsInterface.picklistObject count] > 0)
    {
        appDelegate.wsInterface.picklistObject = nil;
        appDelegate.wsInterface.picklistObject = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if ((appDelegate.wsInterface.picklistField != nil) && [appDelegate.wsInterface.picklistField count] > 0)
    {
        appDelegate.wsInterface.picklistField = nil;
        appDelegate.wsInterface.picklistField = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if ((appDelegate.wsInterface.picklistValues != nil) && [appDelegate.wsInterface.picklistValues count] > 0)
    {
        appDelegate.wsInterface.picklistValues = nil;
        appDelegate.wsInterface.picklistValues = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if ((appDelegate.wsInterface.pageUiHistory != nil) && [appDelegate.wsInterface.pageUiHistory count] > 0)
    {
        appDelegate.wsInterface.pageUiHistory = nil;
        appDelegate.wsInterface.pageUiHistory = [[NSMutableArray alloc] initWithCapacity:0];
    }
}

#pragma mark - settingsAfterIncMetaSync
//Call Finaally Method
- (void) settingAfterIncrementalMetaSync
{
    appDelegate.settingsDict = [appDelegate.dataBase getSettingsDictionary];
    
    
    if (appDelegate.wsInterface.tagsDictionary != nil)
    {
        [appDelegate.wsInterface.tagsDictionary removeAllObjects];
    }

    // Vipin-memopt 12-1 9493
    [appDelegate.wsInterface reloadTagsDictionary];
    
//    appDelegate.wsInterface.tagsDictionary = [appDelegate.dataBase getTagsDictionary];
//    NSMutableDictionary * temp_dict = [appDelegate.wsInterface fillEmptyTags:appDelegate.wsInterface.tagsDictionary];
//    appDelegate.wsInterface.tagsDictionary = temp_dict;
//    
    // Vipind-db-optmz - 3
    [self closeDatabase:tempDb];
    self.tempDb = nil;
    [appDelegate.dataBase deleteDatabase:TEMPDATABASENAME];
    
    
    if(appDelegate.db == nil)
    {
        [appDelegate initWithDBName:DATABASENAME1 type:DATABASETYPE1];
    }
    
    if ([appDelegate.StandAloneCreateProcess count] > 0)
    {
        [appDelegate.StandAloneCreateProcess  removeAllObjects];
    }
    //sahana Aug16th
    // Vipin-memopt 17-1 9493
    NSMutableArray * createprocessArray = [[appDelegate.databaseInterface getAllTheProcesses:@"STANDALONECREATE"] retain];
    [appDelegate getCreateProcessArray:createprocessArray];
    [createprocessArray release];
    
    if ([appDelegate.view_layout_array count] > 0)
    {
        [appDelegate.view_layout_array removeAllObjects];
    }
    //sahana Aug16th
    appDelegate.view_layout_array = [appDelegate.databaseInterface getAllTheProcesses:@"VIEWRECORD"];

    
    if (appDelegate.soqlQuery != nil)
        appDelegate.soqlQuery = nil;
    
    [appDelegate.calDataBase startQueryConfiguration];

    appDelegate.isIncrementalMetaSyncInProgress = FALSE;
    
    [popOver_view syncSuccess];
    
    //7221:
    [self updateRecentsPlist ];

    
}

#pragma mark -END

#pragma Mark to get loggedInUserId

- (NSString *)getLoggedInUserId:(NSString *)username
{
    NSMutableString * query = [NSMutableString stringWithFormat:@"SELECT Id FROM User WHERE Username = '%@'", username];
    
    sqlite3_stmt * stmt;
    
    NSString * queryStatement = @"";    
    const char * _query = [query UTF8String];
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query,-1, &stmt, nil) == SQLITE_OK )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char *field1 = (char *) synchronized_sqlite3_column_text(stmt,COLUMN_1);
            if ((field1 != nil) && strlen(field1))
            {
                NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
                queryStatement = [NSString stringWithFormat:@"%@",field1Str];
                [field1Str release];
                field1Str = nil;
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    
    return queryStatement;
}
-(NSString*) getLoggedInUser:(NSString *)username
{
        NSMutableString * query = [NSMutableString stringWithFormat:@"SELECT Name FROM User WHERE Username = '%@'", username];
        
        sqlite3_stmt * stmt;
        
        NSString * queryStatement = @"";
        const char * _query = [query UTF8String];
        
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query,-1, &stmt, nil) == SQLITE_OK )
        {
            while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                char *field1 = (char *) synchronized_sqlite3_column_text(stmt,COLUMN_1);
                if ((field1 != nil) && strlen(field1))
                {
                    NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
                    queryStatement = [NSString stringWithFormat:@"%@",field1Str];
                }
            }
        }
        synchronized_sqlite3_finalize(stmt);
        
        return queryStatement;
}

# pragma end


-(NSString *)getValueForRecordtypeId:(NSString *)recordtypeId object_api_name:(NSString *)object_api_name
{
    NSMutableString * query = [NSMutableString stringWithFormat:@"SELECT recordtypename FROM SFRTPicklist where object_api_name = '%@' and recordtypeid = '%@'", object_api_name, recordtypeId];
    
    sqlite3_stmt * stmt;
    
    NSString * value = @"";    
    const char * _query = [query UTF8String];
    
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, _query,-1, &stmt, nil) == SQLITE_OK )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char *field1 = (char *) synchronized_sqlite3_column_text(stmt,COLUMN_1);
            if ((field1 != nil) && strlen(field1))
            {
                NSString *field1Str = [[NSString alloc] initWithUTF8String:field1];
                value = [NSString stringWithFormat:@"%@",field1Str];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    
    return value;
}

- (NSMutableArray *) getAllTheRecordIdsFromEvent
{
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT WhatId FROM Event"];
    
    NSMutableArray * recordId = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    NSString * whatId = @"";
    
    sqlite3_stmt * statement;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * _id = (char *) synchronized_sqlite3_column_text(statement,COLUMN_1);
            if ((_id != nil) && strlen(_id))
            {
                whatId = [NSString stringWithUTF8String:_id];
                [recordId addObject:whatId];
            }
        }
    }
    synchronized_sqlite3_finalize(statement);
    
    return recordId;
    
}

- (NSMutableArray *) checkForTheObjectWithRecordId:(NSMutableArray *)recordId
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"checkForTheObjectWithRecordId"
                                                         andRecordCount:[recordId count]];
    
    
    NSMutableArray * objectNames = [self retreiveObjectNames];
    
    NSMutableDictionary * detail_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSMutableArray * mappingArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString * name = @"";
    
    BOOL flag = FALSE;
    
    for (NSString * _id in recordId)
    {
        for (name in objectNames)
        {
            flag = [self doesObjectExistsForEventID:name _Id:_id];
            
            if (flag)
                break;
            else
                continue;
        }
        if ((name != nil) && (_id != nil))
            [detail_dict setObject:name forKey:_id];
    }
    
    NSArray * allVaues = [detail_dict allValues];
    
    
    NSString * str = @"";
    NSString * str1 = @"";
    for (int i = 0; i < [allVaues count];)
    {   
        str = [allVaues objectAtIndex:i];
        NSArray * array = [[NSArray alloc] init];
        NSDictionary * dict;
        
        if (i == 0)
        {
            array = [detail_dict allKeysForObject:str];
            dict = [NSDictionary dictionaryWithObject:array forKey:str];
            [mappingArray addObject:dict];
            [array release];
            [detail_dict removeObjectsForKeys:array];
            allVaues = [detail_dict allValues];
            str1 = str;
            i = 0;
        }
               
    }
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"checkForTheObjectWithRecordId"
                                                                      andRecordCount:0];
    
    
    return mappingArray;
}


- (NSMutableArray *) retreiveObjectNames
{
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT object_api_name FROM SFObjectField"];
    
    NSMutableArray * objectNames = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    sqlite3_stmt * statement;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
        {
            char * _name = (char *)synchronized_sqlite3_column_text(statement, 0);
            
            if ((_name != nil) && (strlen(_name)))
            {
                NSString * name = [NSString stringWithUTF8String:_name];
                [objectNames addObject:name];
            }
        }
    }
    synchronized_sqlite3_finalize(statement);
    
    return objectNames;
}

- (BOOL) doesObjectExistsForEventID:(NSString *)object _Id:(NSString *)recordId
{
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@' WHERE Id = '%@'", object, recordId];
    
    int count = 0;
    
    sqlite3_stmt * statement;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
        {
            count = synchronized_sqlite3_column_int(statement, 0);
        }
    }
    
    synchronized_sqlite3_finalize(statement);
    
    if (count)
        return TRUE;
    else
        return FALSE;
    
}


- (NSMutableArray *) getAllTheNewEventsFromSynCRecordHeap
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"getAllTheNewEventsFromSynCRecordHeap"
                                                         andRecordCount:0];
    
    
    NSMutableArray * recordIds = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSString * queryStatement = [NSString stringWithFormat:@"SELECT json_record FROM sync_Records_Heap where object_name = 'Event' and sync_flag = 'true'"];
    
    
    if (parser == nil)
        parser = [[SBJsonParser alloc] init];
    
    NSString * jsonRecord = @"";
    
    sqlite3_stmt * statement;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW) 
        {
            char * record = (char *) synchronized_sqlite3_column_text(statement, 0);
            
            if ((record != nil) && (strlen(record)))
            {
                jsonRecord = [NSString stringWithUTF8String:record];
                
                NSDictionary * dict = [parser objectWithString:jsonRecord];
                
                [recordIds addObject:([dict objectForKey:@"WhatId"] != nil)?[dict objectForKey:@"WhatId"]:@""];
            }
                
        }
    }
    
    synchronized_sqlite3_finalize(statement);
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"getAllTheNewEventsFromSynCRecordHeap"
                                                                      andRecordCount:1];
    
    
    return recordIds;
}


- (void) removeIdExistsInIntialEventMappingArray
{
    for (NSDictionary * dict in appDelegate.newEventMappinArray)
    {
        NSArray * allKeys = [dict allKeys];
        
        NSString * str = [allKeys objectAtIndex:0];
        
        NSArray * allValues = [dict allValues];
                
        for (NSDictionary * dict1 in appDelegate.initialEventMappinArray)
        {
            NSArray * allInitialKeys = [dict1 allKeys];
            
            NSString * value = [allInitialKeys objectAtIndex:0];
            
            if ([value isEqualToString:str])
            {                
                NSMutableArray * initialValues = (NSMutableArray *) [dict1 allValues];
                
                for (NSString * key in allValues) 
                {
                    if ([initialValues containsObject:key])
                    {
                        [initialValues removeObject:key];
                    }
                }
                break;
            }
            else
                continue;            
        }
    }

}

- (NSString *) getDateToDeleteEventsAndTaskOlder:(NSTimeInterval)Value
{
    NSDate * today = [NSDate date];

    //krishna 23-1 memory opt 9493
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
    
    
    NSDate * previousDate = [today dateByAddingTimeInterval:(-Value * 24 * 60 * 60)];
    
    NSString * currentDate = [formatter stringFromDate:previousDate];
    
    currentDate = [currentDate stringByReplacingCharactersInRange:NSMakeRange(11, 8) withString:@"00:00:00"];
    
    //krishna 23-1 memory opt 9493
    [formatter release];
    formatter = nil;
    
    return currentDate;
}

- (NSString *) getDateToDeleteEventsAndTaskForNext:(NSTimeInterval)Value
{
    NSDate * today = [NSDate date];
    
    //krishna 23-1 memory opt 9493
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
    
    
    NSDate * previousDate = [today dateByAddingTimeInterval:(+Value * 24 * 60 * 60)];
    
    NSString * currentDate = [formatter stringFromDate:previousDate];
    
    currentDate = [currentDate stringByReplacingCharactersInRange:NSMakeRange(11, 8) withString:@"00:00:00"];

    //krishna 23-1 memory opt 9493
    [formatter release];
    formatter = nil;
    
    return currentDate;
}


- (void) purgingDataOnSyncSettings:(NSString *)Date tableName:(NSString *)tableName 
                            Action:(NSString*)Action
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"purgingDataOnSyncSettings"
                                                         andRecordCount:1];
    
    
    NSString * column = @"";
    
    if ([tableName isEqualToString:@"Event"])
    {
        column = @"EndDateTime";
    }
    else
    {
        Date = [Date substringToIndex:10];
        column = @"ActivityDate";
    }

    NSString * queryStatement = @"";
    NSString * version = [appDelegate serverPackageVersion];
	int _stringNumber = [version intValue];
    
    if(_stringNumber >=  (KMinPkgForScheduleEvents * 100000))
    {
        if ([Action isEqualToString:@"LESSTHAN"])
        {
            queryStatement = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ < '%@' and Id not in (SELECT sf_id  FROM user_created_events) and Id != '' ", tableName, column, Date];   
        }
        else if([Action isEqualToString:NOT_OWNER_GREATERTHAN]) //sahana dec 14 2012
        {
            if(appDelegate.loggedInUserId == nil)
            {
                appDelegate.loggedInUserId=[self getLoggedInUserId:appDelegate.username];
            }
            queryStatement = [NSString stringWithFormat:@"DELETE FROM %@ WHERE  Id  in (SELECT sf_id  FROM user_created_events) and OwnerId != '%@'", tableName ,appDelegate.loggedInUserId];
            
        }
        else if([Action isEqualToString:NOT_OWNERLESSTHAN]) //sahana dec 14 2012
        {
            if(appDelegate.loggedInUserId == nil)
            {
                appDelegate.loggedInUserId=[self getLoggedInUserId:appDelegate.username];
            }
            queryStatement = [NSString stringWithFormat:@"DELETE FROM %@ WHERE  Id  in (SELECT sf_id  FROM user_created_events) and OwnerId != '%@'", tableName,appDelegate.loggedInUserId];
        }
        else
        {
              queryStatement = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ >= '%@' and Id not in (SELECT sf_id  FROM user_created_events) and Id != '' ", tableName, column, Date];  
        }
    }
    else if (!([Action isEqualToString:NOT_OWNERLESSTHAN] || [Action isEqualToString:NOT_OWNER_GREATERTHAN]))
    {
        if ([Action isEqualToString:@"LESSTHAN"])
        {
            queryStatement = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ < '%@'", tableName, column, Date];
        }
        else
        {
            queryStatement = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ > '%@'", tableName, column, Date];
        }
    }
    char * err;
    
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", queryStatement);
		SMLog(kLogLevelError,@"METHOD:purgingDataOnSyncSettings");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
		[appDelegate printIfError:nil ForQuery:queryStatement type:DELETEQUERY];
      
    }
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"purgingDataOnSyncSettings"
                                                                      andRecordCount:0];
    
    [[PerformanceAnalytics sharedInstance] addDeletedRecordsNumber:1];
    
    SMLog(kLogLevelVerbose,@" DEL purgingDataOnSyncSettings - %@",queryStatement);
}
#pragma mark -End


#pragma mark - FULL DATA SYNC
-(void)setSyncStatus
{
    [appDelegate setSyncStatus:SYNC_GREEN];
}

- (BOOL) startEventSync
{
    SMLog(kLogLevelVerbose,@"User location update starts");
    
    [appDelegate.refreshIcons RefreshIcons]; //20-June-2013. ---> Refreshing home incons when sync is running.
    [[ZKServerSwitchboard switchboard] doCheckSession];
    [appDelegate.wsInterface connectSVMX];
    /* Shravya - Advanced look up- User trunk location */
    [appDelegate.wsInterface getUserTrunkLocationRequest];
     SMLog(kLogLevelVerbose,@"User location update ends");
       
    NSString * event_sync = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_events];
    appDelegate.connection_error = FALSE;
    BOOL retVal = TRUE;
    SMLog(kLogLevelVerbose,@"  DataSync WS Start: %@", [NSDate date]);
    appDelegate.wsInterface.didOpComplete = FALSE;

    SMXMonitor *monitor = [[[SMXMonitor alloc] init] autorelease];
    [monitor monitorSMMessageWithName:@"[DataBase startEventSync]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Start"
                         timeInterval:10.0];

    [appDelegate.wsInterface dataSyncWithEventName:EVENT_SYNC eventType:SYNC requestId:@""];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(kLogLevelVerbose,@"Datebase.m : startEventSync: EVENT_SYNC");
#endif
        if (![appDelegate isInternetConnectionAvailable])
            break;
        
        if (appDelegate.wsInterface.didOpComplete == TRUE)
        {
            break; 
        }

        if(appDelegate.connection_error)
        {
			//Defect 6774
			[appDelegate checkifConflictExistsForConnectionError];
            [monitor monitorSMMessageWithName:@"[DataBase startEventSync]"
                                 withUserName:appDelegate.currentUserName
                                     logLevel:kPerformanceLevelWarning
                                   logContext:@"Stop"
                                 timeInterval:10.0];
            return FALSE;
        }
    }
    [monitor monitorSMMessageWithName:@"[DataBase startEventSync]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Stop"
                         timeInterval:10.0];
    if(retVal == NO)
    {
        
        [appDelegate setSyncStatus:SYNC_RED];
               
        [appDelegate.calDataBase insertIntoConflictInternetErrorWithSyncType:event_sync];
        appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflicts];
        [appDelegate.reloadTable ReloadSyncTable];
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
            [MyPopoverDelegate performSelector:@selector(throwException)];
        return FALSE;
    }

    
    if (![appDelegate isInternetConnectionAvailable])
    {
        
        [appDelegate setSyncStatus:SYNC_RED];
          
        [appDelegate.calDataBase insertIntoConflictInternetErrorWithSyncType:event_sync];
         appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflicts];
        [appDelegate.reloadTable ReloadSyncTable];
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
            [MyPopoverDelegate performSelector:@selector(throwException)];
        return FALSE;
    }
	
//	[appDelegate setCurrentSyncStatusProgress:eEVENTSYNC_GETID optimizedSynstate:0];
	
	appDelegate.Incremental_sync_status = INCR_STARTS;
    [monitor monitorSMMessageWithName:@"[DataBase TX_FETCH]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Start"
                         timeInterval:10.0];

    [appDelegate.wsInterface PutAllTheRecordsForIds];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(kLogLevelVerbose,@"Datebase.m : startEventSync: TX_FETCH");
#endif

        if (![appDelegate isInternetConnectionAvailable])
            break;
        
        if (appDelegate.Incremental_sync_status == PUT_RECORDS_DONE)
            break; 
        if(appDelegate.connection_error)
        {
            //Defect 6774
			[appDelegate checkifConflictExistsForConnectionError];
            [monitor monitorSMMessageWithName:@"[DataBase TX_FETCH]"
                                 withUserName:appDelegate.currentUserName
                                     logLevel:kPerformanceLevelWarning
                                   logContext:@"Stop"
                                 timeInterval:10.0];
             return FALSE;
        }
    }
    [monitor monitorSMMessageWithName:@"[DataBase TX_FETCH]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Stop"
                         timeInterval:10.0];

    if (![appDelegate isInternetConnectionAvailable])
    {
        
        [appDelegate setSyncStatus:SYNC_RED];
            
        [appDelegate.calDataBase insertIntoConflictInternetErrorWithSyncType:event_sync];
        
        appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflicts];
        [appDelegate.reloadTable ReloadSyncTable];
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
            [MyPopoverDelegate performSelector:@selector(throwException)];
        return FALSE;
    }
    if(retVal == NO)
    {
        //appDelegate.SyncStatus = SYNC_RED;
        [appDelegate.calDataBase insertIntoConflictInternetErrorWithSyncType:event_sync];
        
        [appDelegate setSyncStatus:SYNC_RED];
        //[appDelegate.wsInterface.refreshSyncButton showSyncStatusButton];
        //[appDelegate.wsInterface.refreshModalStatusButton showModalSyncStatus];
        //[appDelegate.wsInterface.refreshSyncStatusUIButton showSyncUIStatus];
        appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflicts];
        [appDelegate.reloadTable ReloadSyncTable];
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
            [MyPopoverDelegate performSelector:@selector(throwException)];
        return FALSE;
    }
//	[appDelegate setCurrentSyncStatusProgress:eEVENTSYNC_GETDATA optimizedSynstate:0];
	
	//Radha #6176
	NSMutableString * eventId = [self getAllEventRelatedIdFromSyncRecordHeap];
	[appDelegate.databaseInterface updateSyncRecordsIntoLocalDatabase];
	[self deleteEventNotRelatedToLoggedInUser:eventId tableName:@"Event"];
    
	
//	[appDelegate setCurrentSyncStatusProgress:eEVENTSYNC_PUTDATA optimizedSynstate:0];
	
    return TRUE;
}

- (void) copyMetaTableInToSfm:(NSMutableArray *)metaTable
{
    for (NSString * objectName in metaTable)
    {
        NSString * query = [self retrieveQuery:objectName sqlite:self.tempDb];
        [self createTable:query];
    }
    
    [self loadTempDatabaseFileFromPath];
    
   // NSString * query1 = [NSString stringWithFormat:@"ATTACH DATABASE '%@' AS tempSfm",filepath];
    //[self createTable:query1];
    
    BOOL hasCreatedAttachment = [self attachDatabase:appDelegate.db byName:@"tempSfm" andPath:filepath];
    
   // SMLog(kLogLevelVerbose,@" [MON]  copyMetaTableInToSfm : ATTACH DATABASE %@", query1);
    
    if (! hasCreatedAttachment)
    {
        SMLog(kLogLevelError,@"Unable to create attachment for copying meta table into SFM table");
        return;
    }
    
    NSString * query1 = nil;
    
    [self beginTransaction];
    //Here we fill up the tables with data  
    for (NSString * objectName in metaTable)
    {
        if ([objectName isEqualToString:@"Case"])
            objectName = @"'Case'";
        query1 = [NSString stringWithFormat:@"INSERT INTO %@ SELECT * FROM tempSfm.%@", objectName, objectName];
        [self createTable:query1];
    }
    [self endTransaction];
    
    // Dettach
    [self detachDatabase:appDelegate.db byName:@"tempSfm"];
}

//  Unused methods
//- (NSMutableArray *) retreiveDataObjectTable
//{
//    NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
//    NSString * queryStatement = [NSString stringWithFormat:@"SELECT DISTINCT object_api_name FROM SFObjectField"];
//
//    sqlite3_stmt * stmt;
//    
//    if (synchronized_sqlite3_prepare_v2(self.tempDb, [queryStatement UTF8String], -1, &stmt, NULL) == SQLITE_OK){
//        
//        while (synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
//        {
//            char * _object = (char *)sqlite3_column_text(stmt, 0);
//            
//            if (_object != nil && strlen(_object))
//                [array addObject:[NSString stringWithUTF8String:_object]];
//        }
//        
//    }
//    
//    synchronized_sqlite3_finalize(stmt);
//    
//    return array;
//    
//}

#pragma mark - END

#pragma mark - Incremental Meta And Event
//  Unused methods
//- (void) callIncrementalMetasync
//{
//    if (popOver_view == nil)
//        popOver_view = [[PopoverButtons alloc] init];
//    
//    [popOver_view startSyncConfiguration];
//
//}

- (void) scheduleEventSync
{
    if (popOver_view == nil)
        popOver_view = [[PopoverButtons alloc] init];
    appDelegate.isEventSyncTimerTriggered = YES;
    [popOver_view startSyncEvents];
    
}
#pragma mark - END
//  Unused methods
//- (void) clearTempDatabase
//{
//    if (self.tempDb == nil)
//    {
//        [self openDB:TEMPDATABASENAME type:DATABASETYPE1 sqlite:nil];
//    }
//
//    sqlite3_stmt *stmt;
//    NSMutableArray * tables = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
//    
//    NSString * queryStatemnt = [NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE type = 'table'"];
//    
//    if (synchronized_sqlite3_prepare_v2(self.tempDb, [queryStatemnt UTF8String], -1, &stmt, NULL) == SQLITE_OK)
//    {
//        while (synchronized_sqlite3_step(stmt) == SQLITE_ROW) 
//        {
//            char * _table = (char *) synchronized_sqlite3_column_text(stmt, 1);
//            
//            if ((_table != nil) && strlen(_table))
//            {
//                NSString * table_name = [NSString stringWithUTF8String:_table];
//                if ((![table_name isEqualToString:@"sqlite_sequence"]))
//                    [tables addObject:table_name];
//            }
//            
//        }
//    }
//    
//    synchronized_sqlite3_finalize(stmt);
//    
//    
//    char * err;
//    
//    for (int i = 0; i < [tables count]; i++)
//    {
//        queryStatemnt = [NSString stringWithFormat:@"DROP TABLE '%@'", [tables objectAtIndex:i]];
//        if (synchronized_sqlite3_exec(self.tempDb, [queryStatemnt UTF8String], NULL, NULL, &err) != SQLITE_OK)
//        {
//            if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
//                [MyPopoverDelegate performSelector:@selector(throwException)];
//            SMLog(kLogLevelVerbose,@"Failed to drop");
//            
//        }
//        
//    }    
//
//}


//RADHA 2012june08
#pragma mark - Check

- (BOOL) checkIfRecordExistForObject:(NSString *)tableName Id :(NSString *)Id
{
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@' WHERE Id = '%@'", tableName, Id];
    
    sqlite3_stmt * stmt;
    
    int count = 0;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0);
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    if (count > 0)
        return TRUE;
    else
        return FALSE;
}

- (BOOL) checkIfRecordExistForObjectWithRecordId:(NSString *)tableName Id :(NSString *)Id
{
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@' WHERE local_id = '%@'", tableName, Id];
    
    sqlite3_stmt * stmt;
    
    int count = 0;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0);
        }
        
        synchronized_sqlite3_finalize(stmt);
    }
    
    if (count > 0)
        return TRUE;
    else
        return FALSE;
}
#pragma mark - END

#pragma mark - MetaSyncDue
//Radha 2012june16
- (void) insertMetaSyncDue:(NSString *)description
{
    NSString * msg = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_metasync_due];
    
     [self beginTransaction];
    
    NSString * query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ ('description', 'local_id') VALUES ('%@', '1')",description,  msg];
    
    char * err; 
        
    if ([appDelegate.metaSyncThread isExecuting])
    {
        
    }
    else 
    {
        if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            SMLog(kLogLevelVerbose,@"%@", query);
			SMLog(kLogLevelVerbose,@"METHOD: insertMetaSyncDue");
			SMLog(kLogLevelVerbose,@"ERROR IN INSERTING %s", err);
			[appDelegate printIfError:nil ForQuery:query type:INSERTQUERY];
        }
    }
    
     [self endTransaction];
}

- (BOOL) checkIfSyncConfigDue
{
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@' WHERE local_id = '1'", METASYNCDUE];
    
    sqlite3_stmt * stmt;
    
    int count = 0;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0);
        }
        
         synchronized_sqlite3_finalize(stmt);
    }
    
    if (count > 0)
        return TRUE;
    else
        return FALSE;

}
 
#pragma mark - END

-(NSString *) getfieldTypeForApi:(NSString *)tableName fieldName:(NSString *)fieldName
{
    NSString * query = [NSString stringWithFormat:@"SELECT type from SFobjectField where object_api_name = '%@' and api_name = '%@'",[self getApiNameFromFieldLabel:tableName], fieldName];
    
    
    sqlite3_stmt * stmt;
    
    NSString * type = @"";
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * _type = (char *)synchronized_sqlite3_column_text(stmt, 0);
            
            if (_type != nil && strlen(_type))
            {
                type = [NSString stringWithUTF8String:_type];
            }
            
        }
        synchronized_sqlite3_finalize(stmt);
    }
    
    
    return type;

}
- (NSString *) getApiNameForNameField:(NSString *)headerObjectName
{
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance]  observePerformanceForContext:@"getApiNameForNameField"
                                                          andRecordCount:0];
    
    NSString * fieldName = @"";
    NSString * query = [NSString stringWithFormat:@"SELECT api_name FROM 'SFObjectField' where object_api_name = '%@' and name_field = 'TRUE'",headerObjectName];
    sqlite3_stmt * stmt ;
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_fieldName != nil)
            {
                fieldName = [NSString stringWithUTF8String:temp_fieldName];
            }
        }
    }
    synchronized_sqlite3_finalize(stmt);
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance]  observePerformanceForContext:@"getApiNameForNameField"
                                                          andRecordCount:1];
    
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"getApiNameForNameField"
                                                                      andRecordCount:0];
    
    return fieldName;
    
}


- (NSString *) getReferenceObjectNameForPdf:(NSString *)ObjectName Field:(NSString *)FieldName Id:(NSString *)Id
{
    NSString * query = [NSString stringWithFormat:@"SELECT %@ FROM '%@' where Id = '%@' ",FieldName, ObjectName, Id];
    
    NSString * name = @"";
    
    sqlite3_stmt * stmt;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_fieldName != nil)
            {
                name = [NSString stringWithUTF8String:temp_fieldName];
            }
        }

    }
    synchronized_sqlite3_finalize(stmt);
    return name;
    
}


#pragma mark - ServiceReportLogo
- (BOOL) getImageForServiceReportLogo
{
	didGetServiceReportLogo = FALSE;
	
    NSString * _query = [NSString stringWithFormat:@"SELECT Body FROM Document Where Name = 'ServiceMax_iPad_CompanyLogo'"];
	
	SMLog(kLogLevelVerbose,@"getImageForServiceReportLogo = %@", _query);
    SMXMonitor *monitor = [[[SMXMonitor alloc] init] autorelease];
    [monitor monitorSMMessageWithName:@"[Datebase getImageForServiceReportLogo]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Start"
                         timeInterval:kWSExecutionDuration];
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetServiceReportLogo:error:context:) context:nil];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, FALSE))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(kLogLevelVerbose,@"Datebase.m : getImageForServiceReportLogo: ZKs ServiceReportLogo");
#endif
        

        if (![appDelegate isInternetConnectionAvailable] || appDelegate.connection_error)
               break;
        if (didGetServiceReportLogo)
               break;
    }
    [monitor monitorSMMessageWithName:@"[Datebase getImageForServiceReportLogo]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Stop"
                         timeInterval:kWSExecutionDuration];

	if (didGetServiceReportLogo)
		return TRUE;
	else
		return FALSE;
}

- (void) didGetServiceReportLogo:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    // Store the image in a appDelegate UIImage
    
    NSArray * array = [result records];
    
    if ([array count] == 0)
    {
        didGetServiceReportLogo = YES;
        appDelegate.serviceReportLogo = nil;
        return;
    }
    
    NSString * dataString = [[[array objectAtIndex:0] fields] objectForKey:@"Body"];
    
   // NSData * data = [Base64 decode:dataString];
    
    [self beginTransaction];
    // Decode data from Base64
    if (dataString != nil && [dataString length] > 0)
    {        
        
        NSData * data = [Base64 decode:dataString];

        //appDelegate.serviceReportLogo = [[[UIImage alloc] initWithData:data]autorelease];
        appDelegate.serviceReportLogo = [UIImage imageWithData:data];

        // Save the image to the application bundle
//        NSFileManager * fileManager = [NSFileManager defaultManager];
//        
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *saveDirectory = [paths objectAtIndex:0];	
//        NSString * filePath = [saveDirectory stringByAppendingPathComponent:@"header_image.png"];
//        
//        [fileManager createFileAtPath:filePath contents:data attributes:nil];
        
        NSString * query = [NSString stringWithFormat:@"INSERT INTO servicereprt_logo VALUES ('%@')", dataString];
        
        char * err;
        if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            SMLog(kLogLevelError,@"%@", query);
			SMLog(kLogLevelError,@"METHOD: didGetServiceReportLogo");
			SMLog(kLogLevelError,@"ERROR IN INSERTING %s", err);
			[appDelegate printIfError:nil ForQuery:query type:INSERTQUERY];
        }
    }
    
    [self endTransaction];
        
    didGetServiceReportLogo = YES;
}



//RADHA
- (NSString *) getParentColumnValueFromchild:(NSString *)parentColumn childTable:(NSString *)objectName sfId:(NSString *)sf_id
{
    
    NSString * value = @"";
    
    sqlite3_stmt * stmt = nil;
    
    NSString * query = [NSString stringWithFormat:@"SELECT %@ FROM %@ Where Id = '%@'", parentColumn, objectName, sf_id];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_fieldName != nil)
            {
                value = [NSString stringWithUTF8String:temp_fieldName];
            }
        }
        
    }
    synchronized_sqlite3_finalize(stmt);
    
    
    return value;
}


- (NSString *) getParentlocalIdchild:(NSString *)parentColumn childTable:(NSString *)objectName local_id:(NSString *)local_id
{
    
    NSString * value = @"";
    
    sqlite3_stmt * stmt = nil;
    
    NSString * query = [NSString stringWithFormat:@"SELECT %@ FROM %@ Where local_id = '%@'", parentColumn, objectName, local_id];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_fieldName != nil)
            {
                value = [NSString stringWithUTF8String:temp_fieldName];
            }
        }
        
    }
    synchronized_sqlite3_finalize(stmt);
    
    
    return value;
}


#pragma mark - CONFLICT
- (BOOL) checkIfConflictsExistsForEvent:(NSString *)SF_Id objectName:(NSString *)objectName local_id:(NSString *)local_id
{
    
    int count = 0;
    
    sqlite3_stmt * stmt;
    
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT (*) FROM sync_error_conflict where object_name = '%@' and (sf_id = '%@' or local_id = '%@')", objectName, SF_Id, local_id];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0);
        }
        
    }
    synchronized_sqlite3_finalize(stmt);
    
    if (count > 0)
       return TRUE;
    else
        return FALSE;
    
    
    
}

- (BOOL) checkIfConflictsExistsForEventWithLocalId:(NSString *)local_id objectName:(NSString *)objectName
{
    int count = 0;
    
    sqlite3_stmt * stmt;
    
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT (*) FROM sync_error_conflict where object_name = '%@' and local_id = '%@'", objectName,local_id];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0);
        }
        
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    if (count > 0)
        return TRUE;
    else
        return FALSE;
    
}


- (BOOL) checkIfConflictsExistsForEventWithSFID:(NSString *)sfid objectName:(NSString *)objectName
{
    int count = 0;
    
    sqlite3_stmt * stmt;
    
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT (*) FROM sync_error_conflict where object_name = '%@' and sf_id = '%@'", objectName,sfid];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0);
        }
        
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    if (count > 0)
        return TRUE;
    else
        return FALSE;
    
}



- (BOOL) checkIfChildConflictexist:(NSString *)objectName sfId:(NSString *)SF_Id
{
    BOOL conflictExist = FALSE;
    
    NSString * child_column = [self getChildColumnForParent:objectName];
    
    NSString * localId = [appDelegate.databaseInterface getLocalIdFromSFId:SF_Id tableName:objectName];
	
	if ([localId length] == 0 || [localId isEqualToString:nil])
		localId = SF_Id;
    
    
   // NSString * Id = [self getchildSfIdOrLocalId:child_column Id:localId parentColumn:objectName Key:@"ID"];
    
    
    NSMutableArray * childId = [appDelegate.databaseInterface getChildLocalIdForParentId:localId childTableName:child_column sourceTableName:objectName];
    
    
    
    for (int i = 0; i < [childId count]; i++)
    {
        NSString * Id = @"";
        NSString * localId_ = [childId objectAtIndex:i];
    
        conflictExist = [self checkIfConflictsExistsForEventWithLocalId:localId_ objectName:child_column];
        
        if (conflictExist)
            break;
        else 
        {
            Id = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:child_column local_id:localId_];
            conflictExist = [self checkIfConflictsExistsForEventWithSFID:Id objectName:child_column];
            
            if (conflictExist)
                break;
        }
        
    }
             
    return conflictExist;
}


- (NSString *) getChildColumnForParent:(NSString *)objectName
{
    NSString * value = @"";
    
    sqlite3_stmt * stmt = nil;
    
    NSString * query = [NSString stringWithFormat:@"SELECT object_api_name_child FROM SFChildRelationship Where object_api_name_parent = '%@' and field_api_name = '%@'", objectName, objectName];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_fieldName != nil)
            {
                value = [NSString stringWithUTF8String:temp_fieldName];
            }
        }
        
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    return value;

}
- (NSMutableString *) getAllTheConflictRecordsForObject:(NSString *)ObjectName local_id:(NSString *)local_id
{
    
    NSString * value = @"";
    
    NSMutableString * conflictMessage = [[NSMutableString alloc] initWithCapacity:0];
    
    sqlite3_stmt * stmt = nil;
    
    NSString * sfid = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:ObjectName local_id:local_id];
    
    NSString * query = [NSString stringWithFormat:@"SELECT error_message FROM sync_error_conflict Where object_name = '%@' and (sf_id = '%@' or local_id = '%@')", ObjectName, sfid, local_id];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_fieldName != nil)
            {
                value = [NSString stringWithUTF8String:temp_fieldName];
            }
        }
        
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    if ([value length] > 0)
    {
        [conflictMessage appendString:[NSString stringWithFormat:@"%@", value]];
    }
    if(![appDelegate.From_SFM_Search isEqualToString:FROM_SFM_SEARCH])
    {
        NSString * childColumn = [self getChildColumnForParent:ObjectName];

        NSMutableArray * childId = [appDelegate.databaseInterface getChildLocalIdForParentId:local_id childTableName:childColumn sourceTableName:ObjectName];
        
        query = nil;
        sfid = nil;


        for (int i = 0; i < [childId count]; i++)
        {
            
            sfid = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:childColumn local_id:[childId objectAtIndex:i]];
            
            query = [NSString stringWithFormat:@"SELECT error_message FROM sync_error_conflict Where object_name = '%@' and (sf_id = '%@' or local_id = '%@')", childColumn, sfid, [childId objectAtIndex:i]];
            
            if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
            {
                while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
                {
                    char * temp_fieldName = (char *)synchronized_sqlite3_column_text(stmt, 0);
                    if(temp_fieldName != nil)
                    {
                        value = [NSString stringWithUTF8String:temp_fieldName];
                    }
                    if ([value length] > 0)
                    {
                        [conflictMessage appendString:[NSString stringWithFormat:@"\n%@", value]];
                    }
                }
            }
            
             synchronized_sqlite3_finalize(stmt);
        }
    }

    return conflictMessage;
    
}

-(int)checkIfObjectIsInConflict:(NSString *)objectName Id:(NSString *)local_id
{
    NSString *sfid = nil;
    int count_localORsfid = 0;
    count_localORsfid = [self countRecordsInSyncConflictWith:objectName Id:local_id];
    
    if(count_localORsfid == 0)
    {
        sfid = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:objectName local_id:local_id];
        count_localORsfid = [self countRecordsInSyncConflictWith:objectName Id:sfid];
    }
    
    return count_localORsfid;
}

- (int)countRecordsInSyncConflictWith:(NSString *)objectName Id:(NSString *)localORsfid
{
    NSString * query = [NSString stringWithFormat:@"SELECT COUNT(*) FROM sync_error_conflict Where object_name = '%@' and (local_id = '%@' OR sf_id = '%@')", objectName, localORsfid, localORsfid];
    sqlite3_stmt * stmt = nil;
    int count = 0;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(stmt, 0);
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    return count;
}


#pragma mark - END

//sahana Aug 16th ----------*********** start*************
-(void)getRecordTypeValuesForObject:(NSArray *)allObjects
{

    NSString * objectList = @"";
    
    for(int i = 0 ; i < [allObjects count];i++)
    {
       
        NSString * object_name = [allObjects objectAtIndex:i];
        if(i == 0)
        {
             objectList = [objectList stringByAppendingFormat:@" '%@' ",object_name];
        }
        else
        {
             objectList = [objectList stringByAppendingFormat:@", '%@' ",object_name];
        }
    }
    
     RecordTypeflag = FALSE;
    NSString * _query = [NSString stringWithFormat:@"SELECT Id, Name ,SobjectType FROM RecordType WHERE SobjectType in (%@) ",objectList];
	
	SMLog(kLogLevelVerbose,@"getRecordTypeValuesForObject = %@", _query);
    SMXMonitor *monitor = [[[SMXMonitor alloc] init] autorelease];
    [monitor monitorSMMessageWithName:@"[Datebase getRecordTypeValuesForObject]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Start"
                         timeInterval:kWSExecutionDuration];
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didgetRecordtypeInfo:error:context:) context:nil];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES)) 
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(kLogLevelVerbose,@"Datebase.m : getRecordTypeValuesForObject: ZKs get record type");
#endif

        if(RecordTypeflag)
        {
            break;
        }
        if (![appDelegate isInternetConnectionAvailable])
        {
            appDelegate.initial_sync_succes_or_failed = META_SYNC_FAILED;
            break;
        }
        if(appDelegate.initial_sync_succes_or_failed == META_SYNC_FAILED)
        {
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }
    }
    [monitor monitorSMMessageWithName:@"[Datebase getRecordTypeValuesForObject]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Stop"
                         timeInterval:kWSExecutionDuration];
    
}

//sahana RecordType fix  - Aug 16th 2012
- (void) didgetRecordtypeInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    //sahana RecordType fix  - Aug 16th 2012
    SMLog(kLogLevelVerbose,@"RecordTypeInfo");
       if ([[result records] count] > 0)
    {
        NSArray * resultArray = [result records];
        
        for(int i = 0 ; i< [resultArray count]; i++)
        {
            ZKSObject * sobj = [resultArray objectAtIndex:i];
            NSDictionary * fields = sobj.fields;
            NSArray * allkeys = [fields allKeys];
            if([allkeys containsObject:@"Id"] && [allkeys containsObject:@"Name"])
            {
                NSString * _id = [fields objectForKey:@"Id"];
                NSString * Name = [fields objectForKey:@"Name"];
                [self UpdateSFRecordTypeForId:_id value:Name];
            }
        }      
    }
    
    RecordTypeflag = TRUE;
    

}
#pragma mark - END



//Radha DefectFix - 5721
- (NSInteger) getTextareaLengthForFieldApiName:(NSString *)api_name objectName:(NSString *)objectName;
{
	NSInteger textLength = 0;
	
	NSString * query = [NSString stringWithFormat:@"SELECT length FROM SFobjectField WHERE api_name = '%@' and object_api_name = '%@'", api_name, objectName];
	
	
	sqlite3_stmt * stmt = nil;
	
	if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
	{
		if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
		{
			textLength = synchronized_sqlite3_column_int(stmt, 0);
		}
		
		synchronized_sqlite3_finalize(stmt);
	}

	return textLength;
}

//6176 Defect Fix - Radha
- (NSMutableString *) getAllEventRelatedIdFromSyncRecordHeap
{
	NSMutableString * Id = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
	
	NSString * query = [NSString stringWithFormat:@"SELECT sf_id from %@ WHERE object_name = 'Event'", SYNC_RECORD_HEAP];
	
	sqlite3_stmt * stmt = nil;
	
	if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
	{
		while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
		{
			char * eventId = (char *) synchronized_sqlite3_column_text(stmt, 0);
			
			if ([Id length] == 0)
			{
				[Id appendString:[NSMutableString stringWithFormat:@"'%@'", [NSMutableString stringWithUTF8String:eventId]]];
			}
			else
			{
				[Id appendString:[NSMutableString stringWithFormat:@" ,'%@'", [NSMutableString stringWithUTF8String:eventId]]];
			}
		}
		
		synchronized_sqlite3_finalize(stmt);
	}
	
	
	return Id;
	
	
}

//6176 Defect Fix - Radha
- (void) deleteEventNotRelatedToLoggedInUser:(NSMutableString *)Id tableName:(NSString *)tableName
{
	NSString * settingValue = [appDelegate.settingsDict objectForKey:@"Synchronization To Remove Events"];
    
    NSTimeInterval value = [settingValue integerValue];
	value = value;
    
    NSString * startDate = [self getDateToDeleteEventsAndTaskOlder:value];
	
	[self purgingDataOnSyncSettings:startDate tableName:@"Event" Action:@"LESSTHAN"];
	
	settingValue = @"";
    
    settingValue = [appDelegate.settingsDict objectForKey:@"Synchronization To Get Events"];
    
    value = [settingValue integerValue];
	value = value + 1;
    
    NSString * endDate = [appDelegate.dataBase getDateToDeleteEventsAndTaskForNext:value];
	
	[appDelegate.dataBase purgingDataOnSyncSettings:endDate tableName:@"Event" Action:@"GRETERTHAN"];

	
	NSString * query = [NSString stringWithFormat:@"DELETE FROM %@ where (( Id not in (%@)) AND (Id != ' ' AND ID NOT NULL AND Id != ''))", tableName, Id];
	
    char * err;
	
	if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
	{
		SMLog(kLogLevelError,@"Failed to delete");
        SMLog(kLogLevelError,@"METHOD:deleteEventNotRelatedToLoggedInUser");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        //[appDelegate printIfError:nil ForQuery:query type:DELETEQUERY];
	}
    
    [[PerformanceAnalytics sharedInstance] addDeletedRecordsNumber:1];
}


-(void)UpdateSFRecordTypeForId:(NSString *)_id value:(NSString *)valueField
{
    [self beginTransaction];
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"UpdateSFRecordTypeForId"
                                                         andRecordCount:1];
    
    
    //sahana RecordType fix  - Aug 16th 2012
    NSString * update_statement = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE record_type_id = '%@'",SFRecordType ,MRECORD_TYPE,valueField,_id];
    char * err;
    
    if(synchronized_sqlite3_exec(appDelegate.db, [update_statement UTF8String],NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", update_statement);
		SMLog(kLogLevelError,@"METHOD:UpdateSFRecordTypeForId" );
		SMLog(kLogLevelError,@"ERROR IN UPDATING %s", err);
		[appDelegate printIfError:nil ForQuery:update_statement type:UPDATEQUERY];
    }
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"UpdateSFRecordTypeForId"
                                                                      andRecordCount:0];
    
    
    [self endTransaction];
    
}
-(BOOL)isTabelExistInDB:(NSString*)tableName
{
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"isTabelExistInDB"
                                                         andRecordCount:1];
    
    BOOL isTabel=FALSE;
   NSMutableString * queryStatementIstable = [NSMutableString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@'",tableName];
    sqlite3_stmt * labelstmt;
    const char *selectStatement = [queryStatementIstable UTF8String];
    char *fieldIsTable=nil;
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, selectStatement,-1, &labelstmt, nil) == SQLITE_OK )
    {
        if(synchronized_sqlite3_step(labelstmt) == SQLITE_ROW)
        {
            fieldIsTable = (char *) synchronized_sqlite3_column_text(labelstmt,0);
            if ((fieldIsTable !=nil) && strlen(fieldIsTable))
            {
                isTabel=TRUE;
            }
        }
		synchronized_sqlite3_finalize(labelstmt);
    }
    
    // Vipin-db-optmz
    [[PerformanceAnalytics sharedInstance] completedPerformanceObservationForContext:@"isTabelExistInDB"
                                                                      andRecordCount:0];
    
    
    return isTabel;

}

-(BOOL)isHeaderRecord:(NSString*)objectName
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM SFChildRelationship where object_api_name_child='%@'",objectName];
    sqlite3_stmt *statement;
    int row_count;
    if(appDelegate == nil)
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            row_count = synchronized_sqlite3_column_int(statement, 0);
            SMLog(kLogLevelVerbose,@"No of location records in DB %d",row_count );
            
        }
        synchronized_sqlite3_finalize(statement);
    }
    if(row_count == 0)
        return TRUE;
    else
        return FALSE;
    
}
-(BOOL)isTableEmpty:(NSString*)tableName
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM '%@'",tableName];
    sqlite3_stmt *statement;
    int row_count;
    if(appDelegate == nil)
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            row_count = synchronized_sqlite3_column_int(statement, 0);
            SMLog(kLogLevelVerbose,@"No of location records in DB %d",row_count );
            
        }
        synchronized_sqlite3_finalize(statement);
    }
    if(row_count == 0)
        return FALSE;
    else
        return TRUE;
    
}

//sahana Aug 16th ----------*********** end *************
-(void)getCodeSnippetSetting
{
    appDelegate.get_trigger_code = FALSE;
    NSString * _query = @"SELECT SVMXC__Setting_Unique_ID__c, SVMXC__SubmoduleID__c, SVMXC__SettingID__c, SVMXC__Settings_Name__c, SVMXC__Data_Type__c, SVMXC__Values__c, SVMXC__Default_Value__c, SVMXC__Setting_Type__c, SVMXC__Search_Order__c, SVMXC__IsPrivate__c, SVMXC__Active__c, SVMXC__Description__c, SVMXC__IsStandard__c, SVMXC__Submodule__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__SubmoduleID__c = 'IPAD007' AND SVMXC__SettingID__c = 'SET005'";
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(getCodeSnippetInfo:error:context:) context:nil];
    SMXMonitor *monitor = [[SMXMonitor alloc] init];
    [monitor monitorSMMessageWithName:@"[DataBase retrieveStaticResourceFor]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Start"
                         timeInterval:kWSExecutionDuration];

    while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        if(appDelegate.get_trigger_code)
        {
           
            break;
        }
        if (![appDelegate isInternetConnectionAvailable])
        { 
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }
        
    }
    [monitor monitorSMMessageWithName:@"[DataBase retrieveStaticResourceFor]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Stop"
                         timeInterval:kWSExecutionDuration];
    [monitor release];
    appDelegate.get_trigger_code = FALSE;
    
}

- (void) getCodeSnippetInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if(error != nil)
    {
        appDelegate.get_trigger_code = TRUE;
    }
    NSMutableArray * settings_Array = [[NSMutableArray alloc] initWithCapacity:0];
    if ([[result records] count] > 0)
    {
        
        ZKSObject * obj = [[result records] objectAtIndex:0];
    
        NSDictionary * dict = [obj fields];
        
        NSArray * all_unique_keys = [dict allKeys];
        if([all_unique_keys containsObject:@"SVMXC__Values__c"])
        {
            NSString * value_string = [dict objectForKey:@"SVMXC__Values__c"];
           
            NSArray  *  comma_seperatedValues  =  [value_string componentsSeparatedByString:@","];
            appDelegate.code_snippet_ids = comma_seperatedValues;
        }
        
        [settings_Array addObject:dict];
        [self insertSettingsIntoTable:settings_Array:@"SettingsInfo"];
       
    }
    [settings_Array release];
    appDelegate.get_trigger_code = TRUE;
   
    
}
//  Unused methods
//-(NSString *)getSettingUniqueIdForSettingId:(NSString *)setting_id submodule_id:(NSString *)submodule_id
//{
//    sqlite3_stmt * statement;
//    NSString * Setting_Unique_ID__c = @"";
//    NSString  * select_stmt = [NSString stringWithFormat:@"SELECT SVMXC__Values__c FROM  SettingsInfo WHERE SVMXC__SettingID__c = '%@' AND SVMXC__SubmoduleID__c = '%@'",setting_id , submodule_id];
//    
//    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [select_stmt UTF8String], -1, &statement, NULL) == SQLITE_OK)
//    {
//        if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
//        {
//            char * temp_field_name_value = (char *) synchronized_sqlite3_column_text(statement, 0);
//            if(temp_field_name_value != nil)
//            {
//                Setting_Unique_ID__c = [NSString stringWithUTF8String:temp_field_name_value];
//            }
//        }
//    }
//     synchronized_sqlite3_finalize(statement);
//    return Setting_Unique_ID__c;
//}

-(void)createEventTrigger:(NSString *)code_snippet;
{

//    NSString * query = [NSString stringWithFormat:@"CREATE TRIGGER 'Event_trigger' BEFORE INSERT ON 'Event' FOR EACH ROW WHEN NEW.Id = '' AND              (SELECT NOT COUNT(*) FROm Event_local_Ids where local_id = NEW.local_id)  AND (SELECT  COUNT(*)  from  Event where(strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  (NEW.StartDatetime,'+0000','Z'))  <=  strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( StartDatetime, '+0000','Z') ) AND strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  (NEW.EndDateTime,'+0000','Z') )   > strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( StartDatetime, '+0000','Z') ) ) OR (strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  (NEW.StartDatetime,'+0000','Z') ) <  strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( EndDateTime, '+0000','Z') )   AND strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  (NEW.EndDateTime, '+0000','Z') ) >= strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( EndDateTime, '+0000','Z') ))  OR (strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  (NEW.StartDatetime, '+0000','Z') ) <= strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( StartDatetime, '+0000','Z') ) AND strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  (NEW.EndDateTime, '+0000','Z') ) >= strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( EndDateTime, '+0000','Z') )) OR (strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  (NEW.StartDatetime,'+0000','Z') ) >= strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  ( StartDatetime, '+0000','Z') )  and strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  (NEW.EndDateTime, '+0000','Z') ) <= strftime('%%Y-%%m-%%d %%H:%%M', REPLACE  (EndDateTime, '+0000','Z') ))) BEGIN  SELECT RAISE(ABORT,'StartDate Time and EndDate Time'); END"];
    
//    NSString * query = [NSString stringWithFormat:@"%@",code_snippet];
  
    [self createTable:code_snippet];
}
- (int) getRecordCountFromTable:(NSString *)tableName
{
    NSString *query = nil;
    query = [NSString stringWithFormat:@"SELECT count() FROM %@",tableName];
    
    sqlite3_stmt * statement;
    int count =0;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
           count = synchronized_sqlite3_column_int(statement, 0);
        }
    }
    synchronized_sqlite3_finalize(statement);
    return count;
}
- (void) deleteRecordFromTable:(NSString *)tableName
       numberOfRecordsToDelete:(int) recordCount
                  orderByField:(NSString *)fieldName
{
    NSString *query = nil;
    query = [NSString stringWithFormat:@"DELETE FROM %@ where %@ in (SELECT %@ FROM %@ ORDER BY local_id LIMIT %d)",tableName,fieldName,fieldName,tableName,recordCount];
    char * err;
	
	if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
		SMLog(kLogLevelError,@"Failed to delete records from table %@",tableName);
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
    }
}
- (NSArray *) getAllRecordsFromTable:(NSString *) tableName
                          forColumns:(NSArray *) columnsArray
                      filterCriteria:(NSString *) criteria
                               limit:(NSString *) limit
{
    NSString *columns = [columnsArray componentsJoinedByString:@","];
    
    NSString *query = nil;
    if(criteria == nil || [criteria isEqualToString:@""])
        query = [NSString stringWithFormat:@"SELECT %@ FROM %@",columns,tableName];
    else
        query = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@",columns,tableName,criteria];
    if(limit != nil && [limit length] > 0)
        query = [query stringByAppendingFormat:@" LIMIT %@",limit];
    
    sqlite3_stmt * statement;
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            NSMutableDictionary *recordDict = [[NSMutableDictionary alloc] init];
            
            for(int i=0; i<[columnsArray count]; i++)
            {
                char * value = (char *) synchronized_sqlite3_column_text(statement, i);
                if(value != nil)
                {
                    NSString *columnValue = [NSString stringWithUTF8String:value];
                    if(columnValue != nil)
                        [recordDict setObject:columnValue forKey:[columnsArray objectAtIndex:i]];
                    else
                        [recordDict setObject:@"" forKey:[columnsArray objectAtIndex:i]];
                }
                else
                {
                    [recordDict setObject:@"" forKey:[columnsArray objectAtIndex:i]];
                }
            }
            [result addObject:recordDict];
            [recordDict release];
            [pool drain];
        }
    }
    synchronized_sqlite3_finalize(statement);
    return [result autorelease];
}
- (NSArray *) getUniqueRecordsFromTable:(NSString *) tableName
                              forColumn:(NSString *) columnName
                         filterCriteria:(NSString *) criteria
{
    
    NSString *query = nil;
    if(criteria == nil || [criteria isEqualToString:@""])
        query = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM %@",columnName,tableName];
    else
        query = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM %@ WHERE %@",columnName,tableName,criteria];
    
    sqlite3_stmt * statement;
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            char * value = (char *) synchronized_sqlite3_column_text(statement, 0);
            if(value != nil)
            {
                NSString *columnValue = [NSString stringWithUTF8String:value];
                if(columnValue != nil)
                    [result addObject:columnValue];
            }
            [pool drain];
        }
        
        synchronized_sqlite3_finalize(statement);
    }
    return [result autorelease];
}

//Aparna
- (NSData *)serviceReportLogoInDB
{
    NSString * query = [NSString stringWithFormat:@"SELECT logo FROM servicereprt_logo"];
    
    sqlite3_stmt * stmt;
    
    NSData * data = nil;
    
    NSString * imageData = @"";
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * data = (char *)synchronized_sqlite3_column_text(stmt, 0);
            
            if ((data != nil) && strlen(data))
            {
                imageData = [NSString stringWithUTF8String:data];
            }
            
        }
    }
    
     synchronized_sqlite3_finalize(stmt);
    
    if ([imageData length] > 0)
    {
        data = [Base64 decode:imageData];
        
    }
    return data;
}

#pragma mark - GET/SET technician location - vipindas-lookup
- (void)storeTechnicianLocation:(NSString *)currentLocation
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:currentLocation forKey:TECHNICIAN_CURRENT_LOCATION];
    [userDefaults synchronize];
}

- (void)removeUserTechnicianLocation {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:TECHNICIAN_CURRENT_LOCATION];
    [userDefaults synchronize];
    
    [userDefaults removeObjectForKey:TECHNICIAN_CURRENT_LOCATION_ID];
    [userDefaults synchronize];
}

- (NSString *)getTechnicianLocation
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *location = [userDefaults objectForKey:TECHNICIAN_CURRENT_LOCATION];
    return location;
}

- (NSString *)getTechnicianLocationId
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *location = [userDefaults objectForKey:TECHNICIAN_CURRENT_LOCATION_ID];
    return location;
}

- (void)storeTechnicianLocationId:(NSString *)currentLocation
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:currentLocation forKey:TECHNICIAN_CURRENT_LOCATION_ID];
    [userDefaults synchronize];
}

//Shrinivas : OAuth.
- (NSString *)getLocalIdFromUserTable:(NSString *)userName
{
	NSString *query = nil;
	NSString *local_Id = nil;
   
	query = [NSString stringWithFormat:@"SELECT local_id From User where Username = '%@'", userName];
    
    sqlite3_stmt * statement;
	
	if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            const char * value = (char *) synchronized_sqlite3_column_text(statement, 0);
            if(value != nil)
            {
                local_Id = [NSString stringWithUTF8String:value];
				
			}
        
        }
		synchronized_sqlite3_finalize(statement);
    }

	if ( local_Id != nil )
		return local_Id;
	else
		return @"";

}


- (NSString *)getUserNameFromUserTable:(NSString *)local_Id
{
	NSString *query = nil;
	NSString *Name = nil;
	
	query = [NSString stringWithFormat:@"SELECT Username From User where local_id = '%@'", local_Id];
    
    sqlite3_stmt * statement;
	
	if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            const char * value = (char *) synchronized_sqlite3_column_text(statement, 0);
            if(value != nil)
            {
                Name = [NSString stringWithUTF8String:value];
			}
        }
		synchronized_sqlite3_finalize(statement);
    }
	
	if ( Name != nil )
		return Name;
	else
		return @"";

}

#pragma mark - Database Monitoring Management


- (int)totalNumberOfOperationCountForDatabase:(sqlite3 *)database
{
    int totalChanges = sqlite3_total_changes(database);
    
    SMLog(kLogLevelVerbose,@"[DBOPX] DB  totalChanges %d", totalChanges);
    
    return totalChanges;
}


- (NSNumber *)dbMemoryUsage
{
    long long int usedBytes = sqlite3_memory_used();
    
    long long int inKB = usedBytes / 1024;
    
    SMLog(kLogLevelVerbose,@"[DBOPX] DB usedBytes %lld", usedBytes);

    return [NSNumber numberWithLongLong:inKB];
}


- (NSString *)dbVersion
{
  return  [NSString stringWithUTF8String:sqlite3_libversion()];
}


- (int)releaseHeapMemoryForDatabase:(sqlite3*)database
{
    if (database != nil)
    {
        NSString *requiredFor_db_release_mem = @"6.0";
        NSString *thisiosVersion = [[UIDevice currentDevice] systemVersion];
        
        //1048576 - 1 MB
        int freedMemoryInbytes = sqlite3_release_memory(1048576); // Ask to release 1 MB
        int releasedMemoryInbytes = 0;
        if ([thisiosVersion compare:requiredFor_db_release_mem options:NSNumericSearch] != NSOrderedAscending)
            releasedMemoryInbytes = sqlite3_db_release_memory(database);
        SMLog(kLogLevelVerbose,@"[DB] db : freedMemoryInbytes    %d ", freedMemoryInbytes);
        SMLog(kLogLevelVerbose,@"[DB] db : releasedMemoryInbytes %d ", releasedMemoryInbytes);
    }
    else
    {
        SMLog(kLogLevelVerbose,@"[DB] releaseHeapMemoryForDatabase  - bad momery pointer");
    }
    return 1;
}


- (BOOL)attachDatabase:(sqlite3*)database byName:(NSString *)attachmentName andPath:(NSString *)path
{
    [path retain];
    [attachmentName  retain];
    SMLog(kLogLevelVerbose,@" Database ATTACH now ");
    BOOL isSuccess = YES;
    
    if (database == nil)
    {
        //Skipping database attachment operation since db is Null pointer
        SMLog(kLogLevelVerbose,@"[DB] Skipping database attachment operation since db is Null pointer!");
        isSuccess = NO;
    }      // Validating file path and attachment name 
    else if ( (! [Util isValidString:path]) || (! [Util isValidString:attachmentName]) )
    {
        //Skipping database attachment operation since invalid file path or database name
        SMLog(kLogLevelVerbose,@"[DB] Skipping database attachment operation since invalid file path or database name!");
        isSuccess = NO;
    }
    else
    {
        NSString * attachementQuery = [[NSString alloc] initWithFormat:@"ATTACH DATABASE '%@' AS %@", path, attachmentName];
        
        SMLog(kLogLevelVerbose,@" attachementQuery  : %@", attachementQuery);
        char * err;
        
        int result = synchronized_sqlite3_exec(database, [attachementQuery UTF8String], NULL, NULL, &err);
        
        if (result != SQLITE_OK)
        {
            isSuccess = NO;
            
            if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
            {
                [MyPopoverDelegate performSelector:@selector(throwException)];
            }
           
            // Vipin 29-July-2013
            SMLog(kLogLevelVerbose,@" ERROR IN ATTACH DATABASE \n error code : %d,  statement: %@ \n  error message : %s \n detail : %@",
                  result,
                  attachementQuery,
                  err,
                  [NSString stringWithUTF8String:sqlite3_errmsg(database)]);
        }
        
        [attachementQuery release];
    }
    
    [path release];
    [attachmentName  release];
    return isSuccess;
}


- (BOOL)detachDatabase:(sqlite3*)database byName:(NSString *)databaseName
{
    SMLog(kLogLevelVerbose,@" Database dettaching now ");
    if (database == nil)
    {
        //Skipping database detachment operation since db is Null pointer
        SMLog(kLogLevelVerbose,@"[DB] Skipping database detachment operation since db is Null pointer!");
        return NO;
    }
    
    NSString * detachQuery = [NSString stringWithFormat:@"DETACH DATABASE '%@'", databaseName];

    char * err;
    BOOL isSuccess = YES;
    
    int result = synchronized_sqlite3_exec(database, [detachQuery UTF8String], NULL, NULL, &err);
    
    if (result != SQLITE_OK)
    {
        isSuccess = NO;
        
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
        {
            [MyPopoverDelegate performSelector:@selector(throwException)];
        }
        
        // Vipin 22-July-2013
        SMLog(kLogLevelError,@" ERROR IN DETACH DATABASE error code : %d, \n  statement: %@ \n  error message : %s \n detail : %@",
              result,
              detachQuery,
              err,
              [NSString stringWithUTF8String:sqlite3_errmsg(database)]);
    }
    return isSuccess;
}


- (BOOL)closeDatabase:(sqlite3*)database
{
    int executionResult = sqlite3_close(database);
  
    BOOL isSuccessfull = YES;
    
    if (SQLITE_OK != executionResult)
    {
        isSuccessfull = NO;
        
        //NSLog(@" Could not able to close database connection - error code : %d,  message : %@", executionResult, [NSString stringWithUTF8String:sqlite3_errmsg(database)]);
    }
    
    return isSuccessfull;
}


- (sqlite3 *)getTempDatabase {
    
    if (tempDb == nil)
    {
        SMLog(kLogLevelVerbose,@"[DBOPX] Temp DB initialising...");
        [self openDB:TEMPDATABASENAME type:DATABASETYPE1 sqlite:nil];
    }
    
    return tempDb;
}
- (void) purgeEventsNotRelatedToLoggedInUser:(NSMutableString *)eventId
{
	NSString * queryStatement = nil;
	
	NSString * ownerId = [self getLoggedInUserId:appDelegate.currentUserName];
	
	//Fix Defect: 8418. Make sure that local created events will not get purged
    //8378 
	queryStatement = [NSString stringWithFormat:@"DELETE from Event WHERE OwnerId = '%@' AND Id NOT IN (%@) AND (Id != null OR Id != '') ", ownerId, eventId];
	
	char * err;
	
	if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
		SMLog(kLogLevelError,@"Failed to delete");
        SMLog(kLogLevelError,@"purgeEventsNotRelatedToLoggedInUser");
		SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
    }
	
}

//8386
-(NSString*)getOriginalValueForTags:(NSString*)value
{
    NSDictionary *dict = [appDelegate.wsInterface getDefaultTags];
    NSString * tagId = [self getTagFor:value];
    NSString *masterValue=[dict objectForKey:tagId];
    
    return masterValue;

}

//8386
-(NSString*)getTagFor:(NSString*)value
{
    NSString * query = [NSString stringWithFormat:@"SELECT tag_id FROM MobileDeviceTags where value = '%@'",value];
    
    sqlite3_stmt * stmt;
    
    NSString *  master_value= @"";
    
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * masterValue_ = (char *)synchronized_sqlite3_column_text(stmt, 0);
            
            if ((masterValue_ != nil) && strlen(masterValue_))
            {
                master_value = [NSString stringWithUTF8String:masterValue_];
            }
            
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    
    return master_value;

}

    //8303 - Vipindas - Sep 4, 2013
- (NSString *)expressionErrorMessageById:(NSString *)expressionId
{
    if (! [Util isValidString:expressionId])
    {
        return nil;
    }
    
    NSString * errorMessage = nil;

    NSString *queryString = [[NSString alloc] initWithFormat:@" SELECT %@ FROM %@ WHERE %@='%@'",
                             MEXPRESSION_ERROR_MSG,
                             SFEXPRESSION,
                             MEXPRESSION_ID,
                             expressionId];

    SMLog(kLogLevelError,@"  expressionErrorMessageById  Query : %@", queryString);

    sqlite3_stmt * stmt;

    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryString UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * message = (char *)synchronized_sqlite3_column_text(stmt, 0);
            
            if(message != nil)
            {
                errorMessage = [NSString stringWithUTF8String:message];
            }
        }
    }

    [queryString release];
    queryString = nil;

    return errorMessage;
}
#pragma mark - Camera Attachments Table
- (void) createTableForCameraAttachments
{
    NSString *query = [NSString stringWithFormat:@"CREATE TABLE SFAttachmentTrailer ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0) ,'priority' INTEGER,'attachment_id' VARCHAR,'objectName' VARCHAR,'parent_localid' VARCHAR,'parent_sfid' VARCHAR ,'file_name' VARCHAR,'type' VARCHAR,'size' INTEGER,'status' VARCHAR,'action' VARCHAR,'per_progress' FLOAT)"];

    [self createTable:query];
}
- (void) createTableForAttachmentErrors
{
    NSString *query = [NSString stringWithFormat:@"CREATE TABLE AttachmentError ('local_id' INTEGER PRIMARY KEY  NOT NULL  DEFAULT (0) ,'attachment_id' VARCHAR,'error_message' VARCHAR,'error_code' INTEGER,'file_name' VARCHAR,'Sync_Flag' VARCHAR ,'type' VARCHAR,'parent_localid' VARCHAR,'status' VARCHAR,'action' VARCHAR,'parent_sfid' VARCHAR)"];
    
    [self createTable:query];
}
- (NSData *) getAttachmentDataForFile:(NSString *)fileName
{
    NSString *query = [NSString stringWithFormat:@"select attachment_data from SFCameraAttachmentData where fileName = '%@'",fileName];
    
    sqlite3_stmt * statement;
    NSData * fileData = nil;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * _fileData = (char *)synchronized_sqlite3_column_text(statement, 0);
            
            if ((_fileData != nil) && strlen(_fileData))
            {
                NSString *fileDataString = [NSString stringWithUTF8String:_fileData];
                fileData = [Base64 decode:fileDataString];
            }
            
        }
    }
    else
    {
        SMLog(kLogLevelVerbose,@"Unable to execute the Statement = %@",query);
    }
    
    synchronized_sqlite3_finalize(statement);
    
    return fileData;
}

- (NSMutableArray *) getImagesForRecordId:(NSString *)recordId withFileType:(NSString *)fileType
{
    NSString *query = [NSString stringWithFormat:@"SELECT fileName,size from SFCameraAttachmentData where record_Id = '%@' and fileType = '%@'",recordId,fileType];
    
    sqlite3_stmt * statement;
    NSMutableArray *filesArray = [[NSMutableArray alloc] init];
    NSString * fileName = @"";
    NSString * fileSize = @"0";
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *fileDict = [[NSMutableDictionary alloc] init];
            char * _fileName = (char *)synchronized_sqlite3_column_text(statement, 0);
            if ((_fileName != nil) && strlen(_fileName))
            {
                fileName = [NSString stringWithUTF8String:_fileName];
                [fileDict setObject:fileName forKey:@"Name"];
            }
            char * _fileSize = (char *)synchronized_sqlite3_column_text(statement, 1);
            
            if ((_fileSize != nil) && strlen(_fileSize))
            {
                fileSize = [NSString stringWithUTF8String:_fileSize];
                [fileDict setObject:fileSize  forKey:@"Size"];
            }
            [filesArray addObject:fileDict];
        }
    }
    else
    {
        SMLog(kLogLevelVerbose,@"Unable to execute the Statement = %@",query);
    }
    
    synchronized_sqlite3_finalize(statement);
    
    return [filesArray autorelease];
}

- (BOOL) deleteAttachmentFromTableWithName:(NSString *)fileName withRecordId:(NSString *)recordId
{
    NSString *deleteQuery = [NSString stringWithFormat:@"Delete From SFCameraAttachmentData Where fileName = '%@' and record_Id = '%@'", fileName,recordId];
    sqlite3_stmt *statement;
    BOOL status = TRUE;
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, [deleteQuery UTF8String], -1, &statement, nil ) == SQLITE_OK )
    {
        if( synchronized_sqlite3_step(statement) != SQLITE_DONE )
        {
            status = FALSE;
            SMLog(kLogLevelVerbose,@"[Failed to delete the attachment");
        }
    }
    synchronized_sqlite3_finalize(statement);
    return status;
}
-(BOOL)getAttchmentValueforProcess:(NSString*)processId
{
    NSString *selectQuery=[NSString stringWithFormat:@"SELECT enable_Attachment FROM SFProcessComponent where process_id='%@' and component_type='TARGET'",processId];
    sqlite3_stmt *statement;
    char * _enableAttachment=nil;
    NSString *enableAttachment=@"";
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &statement, nil ) == SQLITE_OK )
    {
        if( synchronized_sqlite3_step(statement) != SQLITE_DONE )
        {
            _enableAttachment  = (char *)synchronized_sqlite3_column_text(statement, 0);
            if ((_enableAttachment !=nil) && strlen(_enableAttachment))
            {
                enableAttachment=[NSString stringWithUTF8String:_enableAttachment];
            }

        }
    }
    synchronized_sqlite3_finalize(statement);
     return [enableAttachment boolValue];
    
}
-(NSMutableDictionary*)getAttachmentDetailsforRecord:(NSString*)parentId
{

    NSString * sf_id = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:appDelegate.sfmPageController.objectName local_id:appDelegate.sfmPageController.recordId];

   /* if([sf_id length]>0)
        parentId=sf_id;*/
    
    
    NSString *selectQuery=[NSString stringWithFormat:@"SELECT local_id,Name,ContentType,BodyLength,Description,LastModifiedDate,Id FROM Attachment  where (ParentId='%@' or ParentId='%@') order  by LastModifiedDate DESC ",sf_id,parentId];
//    NSString *selectQuery=[NSString stringWithFormat:@"SELECT local_id,Name,ContentType,BodyLength,Description,LastModifiedDate FROM Attachment  where (ParentId='%@' or ParentId='%@') ",sf_id,parentId];

    sqlite3_stmt *statement;
    
    NSString *recordId=@"",* name=@"",* contentType=@"",* desc=@"",*status=@"",*action=@"",*parent_sfId=@"",*attacmentType=@"",*lastModifieddate=@"",* attachmentId=@"";
    
    float bodyLength=0.0,percentProgress = 0.0;
    int priority=0;
    NSMutableDictionary *dictAttachment=[[NSMutableDictionary alloc]initWithCapacity:0];
    NSMutableArray *attachemntArray=[[NSMutableArray alloc]init];
    NSMutableArray *documentArray=[[NSMutableArray alloc]init];
    NSMutableDictionary *attachmentDict=[[NSMutableDictionary alloc]init];
    NSMutableDictionary *documentDict=[[NSMutableDictionary alloc]init];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            NSMutableDictionary *AttachmentDict = [[NSMutableDictionary alloc] init];
            char * _recordId = (char *)synchronized_sqlite3_column_text(statement, 0);
            if ((_recordId != nil) && strlen(_recordId))
            {
                recordId = [NSString stringWithUTF8String:_recordId];
            }
            [AttachmentDict setObject:recordId forKey:@"AttachmentId"];

            char * _name = (char *)synchronized_sqlite3_column_text(statement, 1);
            if ((_name != nil) && strlen(_name))
            {
                name = [NSString stringWithUTF8String:_name];
            }
            [AttachmentDict setObject:name forKey:@"Name"];

            char * _contentType = (char *)synchronized_sqlite3_column_text(statement, 2);
            if ((_contentType != nil) && strlen(_contentType))
            {
                contentType = [NSString stringWithUTF8String:_contentType];
            }

            [AttachmentDict setObject:contentType forKey:@"ContentType"];

            int size = synchronized_sqlite3_column_int(statement, 3);
            
            if (size >0)
            {
                bodyLength = size;//9196
            }
            [AttachmentDict setObject:[NSString stringWithFormat:@"%f",bodyLength]  forKey:@"Size"];

            char * _desc = (char *)synchronized_sqlite3_column_text(statement, 4);
            if ((_desc != nil) && strlen(_desc))
            {
                desc = [NSString stringWithUTF8String:_desc];
            }
            [AttachmentDict setObject:desc forKey:@"Description"];
             char * _lastModifieddate = (char *)synchronized_sqlite3_column_text(statement, 5);
            if ((_lastModifieddate != nil) && strlen(_lastModifieddate))
            {
                lastModifieddate = [NSString stringWithUTF8String:_lastModifieddate];
            }
            [AttachmentDict setObject:lastModifieddate forKey:K_LASTMODIFIEDDATE];
            char * _attachmentId = (char *)synchronized_sqlite3_column_text(statement, 6);
            if ((_attachmentId != nil) && strlen(_attachmentId))
            {
                attachmentId = [NSString stringWithUTF8String:_attachmentId];
            }
            [AttachmentDict setObject:attachmentId forKey:K_ATTACHMENT_SFID];
            
            BOOL count=[self DoesAttachmentExistsInQueue:recordId];
            
            if(count)
            {
                NSDictionary *tempDict=[self getAttachmentsInActionDetails:recordId];
                [AttachmentDict setObject:[tempDict objectForKey:@"Status"] forKey:@"Status"];
                [AttachmentDict setObject:[tempDict objectForKey:@"Action"] forKey:@"Action"];
                [AttachmentDict setObject:[tempDict objectForKey:@"percentProgress"] forKey:@"percentProgress"];
                [AttachmentDict setObject:[tempDict objectForKey:@"Parent_sfId"] forKey:@"Parent_sfId"];
                [AttachmentDict setObject:[tempDict objectForKey:@"Priority"] forKey:@"Priority"];
                [AttachmentDict setObject:[tempDict objectForKey:@"parent_localid"] forKey:@"parent_localid"];
            }
            else
            {
                [AttachmentDict setObject:status forKey:@"Status"];
                [AttachmentDict setObject:action forKey:@"Action"];
                [AttachmentDict setObject:[NSString stringWithFormat:@"%f",percentProgress] forKey:@"percentProgress"];
                [AttachmentDict setObject:parent_sfId forKey:@"Parent_sfId"];
                [AttachmentDict setObject:[NSString stringWithFormat:@"%d",priority] forKey:@"Priority"];
                [AttachmentDict setObject:parent_sfId forKey:@"parent_localid"];
            }
            attacmentType = [name pathExtension];
            NSDictionary *fileType=[AttachmentUtility getAttachmentType:attacmentType];
            [AttachmentDict setObject:[fileType objectForKey:@"AttachmentType"] forKey:@"Section"];
            [AttachmentDict setObject:attacmentType forKey:@"Type"];
            if([[fileType objectForKey:@"AttachmentType"]integerValue] == 0)
            {
                [attachemntArray addObject:AttachmentDict];
            }
            else
            {
                [documentArray addObject:AttachmentDict];
            }
        }
    }
    synchronized_sqlite3_finalize(statement);
    [attachmentDict setObject:attachemntArray forKey:OBJECT_LIST];
    [documentDict setObject:documentArray forKey:OBJECT_LIST];
    [dictAttachment setObject:attachmentDict forKey:IMAGES_DICT];
    [dictAttachment setObject:documentDict forKey:DOCUMENT_DICT];
    [attachemntArray release];
    [documentArray release];
    [attachmentDict release];
    [documentDict release];
    attachemntArray=nil;
    documentArray=nil;
    attachmentDict=nil;
    documentDict =nil;
    
    return dictAttachment;
}
             
-(NSMutableDictionary*)getAttachmentsInActionDetails:(NSString*)attachmentId
{
    NSString *selectQuery=[NSString stringWithFormat:@"SELECT status,action,parent_sfid,priority,per_progress,parent_localid FROM SFAttachmentTrailer where attachment_id='%@'",attachmentId];
    
    sqlite3_stmt *statement;
    
    NSString *status = @"",* action = @"",* parentSfId = @"",* parentLocalId = @"";
    int priority = 0;
    double  per_progress = 0.0;
    NSMutableDictionary *AttachmentDict = [[NSMutableDictionary alloc] init];

    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * _status = (char *)synchronized_sqlite3_column_text(statement, 0);
            if ((_status != nil) && strlen(_status))
            {
                status = [NSString stringWithUTF8String:_status];
            }
            [AttachmentDict setObject:status forKey:@"Status"];
            
            char * _action = (char *)synchronized_sqlite3_column_text(statement, 1);
            if ((_action != nil) && strlen(_action))
            {
                action = [NSString stringWithUTF8String:_action];
            }
            [AttachmentDict setObject:action forKey:@"Action"];
            
            char * _parentSfId = (char *)synchronized_sqlite3_column_text(statement, 2);
            if ((_parentSfId != nil) && strlen(_parentSfId))
            {
                parentSfId = [NSString stringWithUTF8String:_parentSfId];
            }
            [AttachmentDict setObject:parentSfId forKey:@"Parent_sfId"];
            
            priority = synchronized_sqlite3_column_int(statement, 3);
            
            [AttachmentDict setObject:[NSString stringWithFormat:@"%d",priority]  forKey:@"Priority"];
            
            per_progress = synchronized_sqlite3_column_double(statement, 4);

            [AttachmentDict setObject:[NSString stringWithFormat:@"%f",per_progress] forKey:@"percentProgress"];
            char * _parentlocalId = (char *)synchronized_sqlite3_column_text(statement, 5);
            if ((_parentlocalId != nil) && strlen(_parentlocalId))
            {
                parentLocalId = [NSString stringWithUTF8String:_parentlocalId];
            }
            [AttachmentDict setObject:parentLocalId forKey:@"parent_localid"];
        }
    }
    synchronized_sqlite3_finalize(statement);
    
    return [AttachmentDict autorelease];
}

-(BOOL)DoesAttachmentExistsInQueue:(NSString*)attachmentId
{
    NSString *selectQuery=[NSString stringWithFormat:@"SELECT COUNT(*)FROM SFAttachmentTrailer where attachment_id='%@'",attachmentId];
    
    sqlite3_stmt *statement;
    
    int count=0;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(statement, 0);
            
        }
    }
    synchronized_sqlite3_finalize(statement);
    if(count > 0)
    {
        return YES;
    }
    
    return NO;
}

-(BOOL)ErrorInDownloadingAttachment:(NSString*)attachmentId
{
    NSString *selectQuery=[NSString stringWithFormat:@"SELECT COUNT(*) FROM AttachmentError where attachment_id='%@'",attachmentId];
    
    sqlite3_stmt *statement;
    
    int count=0;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(statement, 0);
            
        }
    }
    synchronized_sqlite3_finalize(statement);
    
    if(count > 0)
    {
        return YES;
    }
    
    return NO;

}
-(int)getPriorityOfAttachment
{
    NSString *selectQuery=[NSString stringWithFormat:@"SELECT COUNT(*)FROM SFAttachmentTrailer"];
    
    sqlite3_stmt *statement;
    
    int count=0;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        if(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            count = synchronized_sqlite3_column_int(statement, 0);
            
        }
    }
    synchronized_sqlite3_finalize(statement);
    
    return count+1;

}

-(void)deleteFromSFAttachmentTrailerTable:(NSString*)attid
{
    //9219
    NSString * queryStatement = [NSString stringWithFormat:@"DELETE FROM SFAttachmentTrailer where attachment_id='%@'",attid];
    char * err;
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelVerbose,@"%@", queryStatement);
        SMLog(kLogLevelVerbose,@"METHOD: deleteFromSFAttachmentTrailerTable");
        SMLog(kLogLevelVerbose,@"ERROR IN Delete %s", err);
    }
}


-(void)insertrecordintoAttachmentTable:(NSString*)tableName recordDict:(NSDictionary*)recordDetails
{
    NSString *queryFields=[self concatinateStringForInsertQuery:[recordDetails allKeys]];
    NSString *valueFields=[self concatinateStringForInsertQuery:[recordDetails allValues]];

    NSString  *queryStatement = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)",tableName,queryFields,valueFields ];
    char * err;
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        if ([MyPopoverDelegate respondsToSelector:@selector(throwException)])
            [MyPopoverDelegate performSelector:@selector(throwException)];
        SMLog(kLogLevelVerbose,@"%@", queryStatement);
        SMLog(kLogLevelVerbose,@"METHOD: insertValuesintoSFMProcessTable");
        SMLog(kLogLevelVerbose,@"ERROR IN INSERTING %s", err);
    }
    [valueFields release];
}

-(NSString *)getNameFor:(NSString *)object_name  local_id:(NSString *)local_id
{
    if(![object_name length]>0 && ![local_id length]>0)
        return @"";
    NSString * query = [NSString stringWithFormat:@"SELECT Name FROM '%@' WHERE local_id = '%@'" , object_name , local_id];
    sqlite3_stmt * stmt ;
    NSString * Name_ = @"";
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_id = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_id != nil)
            {
                Name_= [NSString stringWithUTF8String:temp_id];
            }
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    return Name_;
}
-(NSString*)concatinateStringForInsertQuery:(NSArray*)elements
{
    NSMutableString * concatinateString = [[NSMutableString alloc] init];
    for(int j=0;j<[elements count]; j++)
    {
        if(j)
            [concatinateString  appendString:@","];
        [concatinateString appendString:@"'"];
        NSString *element_ = [elements objectAtIndex:j];
        [concatinateString appendString:element_];
        [concatinateString appendString:@"'"];
    }
    return concatinateString;
}
-(NSDictionary*)getAttachmentLocalIdInfoFromDB:(NSString*)localId
{
    NSString * query = [NSString stringWithFormat:@"SELECT ParentId,Id FROM Attachment WHERE local_id = '%@'",localId];
    sqlite3_stmt * stmt ;
    NSString * ParentId = @"", * sf_Id = @"";
    
    if(synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK  )
    {
        while(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * temp_id = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if(temp_id != nil)
            {
                ParentId= [NSString stringWithUTF8String:temp_id];
            }
            char * sfid_ = (char *)synchronized_sqlite3_column_text(stmt, 1);
            if(sfid_ != nil)
            {
                sf_Id= [NSString stringWithUTF8String:sfid_];
            }
        }
    }
    
    synchronized_sqlite3_finalize(stmt);
    NSString * keyPrefix = @"";
    if([ParentId length]>0)
    {
       keyPrefix = [ParentId substringWithRange:NSMakeRange(0, 3)];
    }
    NSString * referencetoObject = [appDelegate.databaseInterface getTheObjectApiNameForThePrefix:keyPrefix tableName:SFOBJECT];
   NSString *parentLocalId= [appDelegate.databaseInterface getLocalIdFromSFId:ParentId tableName:referencetoObject];
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setObject:parentLocalId forKey:@"ParentId"];
    [dict setObject:referencetoObject forKey:@"ParentObjectName"];
    [dict setObject:sf_Id forKey:@"sf_id"];
    return dict;
}

- (void)updateStatusOfAttachmentId:(NSString *)attachmentlocalId andStatus:(ATTACHMENT_STATUS)attachmentStatus {
    
    NSString * updateQuery = [NSString stringWithFormat:@"UPDATE 'SFAttachmentTrailer' SET status = '%@' WHERE attachment_id = '%@'", [NSString stringWithFormat:@"%d",attachmentStatus],attachmentlocalId];
    
    sqlite3_stmt * updateStmt;
    
    int ret_val = synchronized_sqlite3_prepare_v2(appDelegate.db, [updateQuery UTF8String], strlen([updateQuery UTF8String]),  &updateStmt, NULL);
    
    if (ret_val == SQLITE_OK)
    {
        int success =  synchronized_sqlite3_step(updateStmt);
        if (success == SQLITE_OK || success == SQLITE_DONE) {
            SMLog(kLogLevelVerbose,@"Attachment download status updated successfully");
        }
        else{
            SMLog(kLogLevelVerbose,@"Attachment download status not updated");
        }
    }
    synchronized_sqlite3_finalize(updateStmt);
}

-(ATTACHMENT_STATUS )getAttachmentsStatus:(NSString*)attachmentId
{
    NSString *selectQuery=[NSString stringWithFormat:@"SELECT status FROM SFAttachmentTrailer where attachment_id='%@'",attachmentId];
    
    sqlite3_stmt *statement;
    
    NSString *status = @"";
    ATTACHMENT_STATUS attachmentStatus = ATTACHMENT_STATUS_UNKNOWN;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * _status = (char *)synchronized_sqlite3_column_text(statement, 0);
            if ((_status != nil) && strlen(_status))
            {
                status = [NSString stringWithUTF8String:_status];
                int someValue = [status intValue];
                attachmentStatus = [self getAttachmentTypeFromInteger:someValue];
            }
        }
    }
    synchronized_sqlite3_finalize(statement);
    
    return attachmentStatus;
}


- (ATTACHMENT_STATUS)getAttachmentTypeFromInteger:(int)someValue {
    ATTACHMENT_STATUS status;
    switch (someValue) {
        case ATTACHMENT_STATUS_EXISTS:
            status = ATTACHMENT_STATUS_EXISTS;
            break;
        case ATTACHMENT_STATUS_YET_TO_DOWNLOAD:
            status = ATTACHMENT_STATUS_YET_TO_DOWNLOAD;
            break;
        case ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS:
            status = ATTACHMENT_STATUS_DOWNLOAD_IN_PROGRESS;
            break;
        case ATTACHMENT_STATUS_ERROR_IN_DOWNLOAD:
            status = ATTACHMENT_STATUS_ERROR_IN_DOWNLOAD;
            break;
        case ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE:
            status = ATTACHMENT_STATUS_DOWNLOAD_IN_QUEUE;
            break;
        default:
            status = ATTACHMENT_STATUS_UNKNOWN;
            break;
    }
    return status;
}

#pragma mark - 4850
- (NSString *)getComponentType:(NSString *)settingId
{
    NSString *componentType = nil;
    sqlite3_stmt * stmt;
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT component_type FROM SFprocess_test WHERE sfID = '%@'",settingId];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            const char * _type = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if (strlen(_type))
                componentType = [NSString stringWithUTF8String:_type];
            
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return componentType;
}

- (NSDictionary *)sourceObjectNameForSettingId:(NSString *)settingId
{
    NSString *sourceObjName = nil,*targetObjectName = nil;
    sqlite3_stmt * stmt;
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT source_object_name, target_object_name From SFProcessComponent WHERE sfID = '%@'",settingId];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            const char * _type = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if (strlen(_type))
                sourceObjName = [NSString stringWithUTF8String:_type];
            
            const char * tarName = (char *)synchronized_sqlite3_column_text(stmt, 1);
            if (strlen(tarName))
                targetObjectName = [NSString stringWithUTF8String:tarName];
        }
    }
    
    if (sourceObjName == nil) {
        sourceObjName = @"";
    }
    if (targetObjectName == nil) {
        targetObjectName = @"";
    }
    
    synchronized_sqlite3_finalize(stmt);
    NSDictionary *someDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:sourceObjName,@"source",targetObjectName,@"target", nil];
    return [someDictionary autorelease];
}

- (NSString *)getSourceNodeNameForProcessId:(NSString *)processId
{
    NSString *sfid = nil;
    sqlite3_stmt * stmt;
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT sfID FROM SFprocess_test WHERE process_id = '%@' and component_type = 'SOURCE'",processId];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            const char * _type = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if (strlen(_type))
                sfid = [NSString stringWithUTF8String:_type];
            
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return sfid;
}

- (NSString *)getSFIDFromProcessId:(NSString *)processId andLayoutId:(NSString *)layoutId
{
    NSString *sfID = nil;
    sqlite3_stmt * stmt;
    
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT sfID From SFProcessComponent WHERE process_id = '%@' AND layout_id = '%@'",processId,layoutId];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            const char * _type = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if (strlen(_type))
                sfID = [NSString stringWithUTF8String:_type];
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return sfID;
}
- (NSString *)getTargetNodeNameForProcessId:(NSString *)processId
{
    NSString *sfid = nil;
    sqlite3_stmt * stmt;
    NSString *selectQuery = [NSString stringWithFormat:@"SELECT sfID FROM SFprocess_test WHERE process_id = '%@' and component_type = 'TARGET'",processId];
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [selectQuery UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if(synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            const char * _type = (char *)synchronized_sqlite3_column_text(stmt, 0);
            if (strlen(_type))
                sfid = [NSString stringWithUTF8String:_type];
            
        }
    }
    synchronized_sqlite3_finalize(stmt);
    return sfid;
}

//RADHA 10th April
#pragma mark - DATA PURGING

/*******************Data Purge **************************/

- (NSMutableDictionary *)getKeyPrefixWithObjectNameFromSFObjectTable
{
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSString * query = [[NSString alloc] initWithString:@"SELECT DISTINCT key_prefix, api_name FROM SFObject"];
    
    sqlite3_stmt * statement;
    
    NSString * keyPrefix = nil;
    NSString * objectName = nil;
    
    @autoreleasepool
    {
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                char * _keyPrefix = (char *)synchronized_sqlite3_column_text(statement, 0);
                if ((_keyPrefix != nil) && strlen(_keyPrefix))
                {
                    keyPrefix = [[NSString alloc] initWithUTF8String:_keyPrefix];
                }
                char * _name = (char *)synchronized_sqlite3_column_text(statement, 1);
                if ((_name != nil) && strlen(_name))
                {
                    objectName = [[NSString alloc] initWithUTF8String:_name];
                }
                
                if ([keyPrefix length] > 0 && [objectName length] > 0)
                {
                    [dict setValue:objectName forKey:keyPrefix];
                }
                
                [keyPrefix release];
                keyPrefix = nil;
                [objectName release];
                objectName = nil;
            }
        }
        synchronized_sqlite3_finalize(statement);
        
        [query release];
        query = nil;

    }
    
    return [dict autorelease];
    
}


- (NSString *)getObjectNameForWhatId:(NSString *)whatId
{
    NSString * objectName = nil;
    
    if ([whatId length] > 0)
    {
        NSString * keyPrefix = [whatId substringToIndex:3];
        
        NSString * query = [NSString stringWithFormat:@"SELECT DISTINCT api_name FROM SFObject WHERE key_prefix = '%@'", keyPrefix];
        
        sqlite3_stmt * statement;
        
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                char * _name = (char *)synchronized_sqlite3_column_text(statement, 0);
                if ((_name != nil) && strlen(_name))
                {
                    objectName = [[NSString alloc] initWithUTF8String:_name];
                }
            }
        }
        synchronized_sqlite3_finalize(statement);
    }
    
    return [objectName autorelease];
}

- (NSMutableArray *)getGraceOrNonGraceRecord:(NSString *)object
                              filterCriteria:(NSString *)criteria
                             trialerCriteria:(NSString *)trialerCriteria
{
    NSMutableArray * recordIds = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString * query = [[NSString alloc] initWithFormat:@"SELECT DISTINCT Id FROM '%@' WHERE %@", object, criteria];
   
    sqlite3_stmt * statement;
    
    @autoreleasepool
    {
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                char * _id = (char *)synchronized_sqlite3_column_text(statement, 0);
                if ((_id != nil) && strlen(_id))
                {
                    NSString * data = [[NSString alloc] initWithUTF8String:_id];
                    
                    [recordIds addObject:data];
                    
                    [data release];
                    data = nil;
                }
            }
        }
        synchronized_sqlite3_finalize(statement);
        
        NSMutableArray * trailerIds = [[self getRecordIdFromTrailerTable:object filterCriteria:trialerCriteria] retain];
        
        if (trailerIds != nil && [trailerIds count] > 0)
        {
            for (NSString * Id in trailerIds)
            {
                [recordIds addObject:Id];
            }
        }
    }
    
    [query release];
    return [recordIds autorelease];

}


- (NSMutableArray *)getNonGraceTrailerRecord:(NSString *)object trialerCriteria:(NSString *)trialerCriteria
{
    NSMutableArray * recordIds = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString * query = [[NSString alloc] initWithFormat:@"SELECT DISTINCT Id FROM '%@' WHERE %@", object, trialerCriteria];
    
    sqlite3_stmt * statement;
    
    @autoreleasepool
    {
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                char * _id = (char *)synchronized_sqlite3_column_text(statement, 0);
                if ((_id != nil) && strlen(_id))
                {
                    NSString * data = [[NSString alloc] initWithUTF8String:_id];
                    
                    [recordIds addObject:data];
                    
                    [data release];
                    data = nil;
                }
            }
        }
        synchronized_sqlite3_finalize(statement);
    }
    [query release];
    return [recordIds autorelease];
}


- (NSMutableArray *) getRecordIdFromTrailerTable:(NSString *)objectName filterCriteria:(NSString *)criteria
{
    NSMutableArray * recordIds = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString * query = [[NSString alloc] initWithFormat:@"SELECT sf_id FROM SFDataTrailer WHERE object_name = '%@' AND %@", objectName, criteria];
    
    sqlite3_stmt * statement;
    
    @autoreleasepool
    {
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                char * _id = (char *)synchronized_sqlite3_column_text(statement, 0);
                if ((_id != nil) && strlen(_id))
                {
                    NSString * data = [[NSString alloc] initWithUTF8String:_id];
                    
                    [recordIds addObject:data];
                    
                    [data release];
                    data = nil;
                }
            }
        }
        synchronized_sqlite3_finalize(statement);
        
    }
    
    [query release];
    
    return [recordIds autorelease];
}

- (NSMutableArray *)getGraceOrNonGraceDODRecord:(NSString *)criteria
{
    NSMutableArray * recordIds = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString * query = [[NSString alloc] initWithFormat:@"SELECT sf_id FROM on_demand_download WHERE %@", criteria];
    
    sqlite3_stmt * statement;
    
    @autoreleasepool
    {
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                char * _id = (char *)synchronized_sqlite3_column_text(statement, 0);
                if ((_id != nil) && strlen(_id))
                {
                    NSString * data = [[NSString alloc] initWithUTF8String:_id];
                    
                    [recordIds addObject:data];
                    
                    [data release];
                    data = nil;
                }
            }
        }
        synchronized_sqlite3_finalize(statement);
        
    }
    
    [query release];
    return [recordIds autorelease];
}

- (NSMutableArray *)getEventRelatedRecords
{
    NSMutableArray * eventRecord = [[NSMutableArray alloc] initWithCapacity:0];
    
    
    NSString * query = [[NSString alloc] initWithString:@"SELECT DISTINCT WhatId From Event"];
    
    sqlite3_stmt * statement;
    
    @autoreleasepool
    {
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                char * _id = (char *)synchronized_sqlite3_column_text(statement, 0);
                if ((_id != nil) && strlen(_id))
                {
                    NSString * whatId = [[NSString alloc] initWithUTF8String:_id];
                    
                    [eventRecord addObject:whatId];
                    
                    [whatId release];
                    whatId = nil;
                }
            }
        }
        synchronized_sqlite3_finalize(statement);

    }
    [query release];
    return [eventRecord autorelease];
}

//9990 defect fix :- Method prototype is changed
- (NSMutableArray *)getChildIdsRelatedToEventParentId:(NSArray *)childObjectData parentId:(NSString *)Ids
                                      parentName:(NSString *)parentObject
{
    
    NSMutableArray * childIds = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString * query = nil;
    
    
    if ([childObjectData count] == 2)
    {
        NSString * childObject = [childObjectData objectAtIndex:0];
        NSString * childFieldName = [childObjectData objectAtIndex:1];
        
        query = [[NSString alloc] initWithFormat:@"SELECT child.Id FROM '%@' child LEFT OUTER JOIN '%@' parent ON child.%@ = parent.Id OR child.%@ = parent.local_id WHERE parent.Id In (%@)", childObject, parentObject, childFieldName, childFieldName, Ids];
    }
    sqlite3_stmt * statement;
    
    @autoreleasepool
    {
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                char * _id = (char *)synchronized_sqlite3_column_text(statement, 0);
                if ((_id != nil) && strlen(_id))
                {
                    NSString  * recordId = [[NSString alloc] initWithUTF8String:_id];
                    
                    [childIds addObject:recordId];
                    
                    [recordId release];
                    recordId = nil;
                }
            }
        }
        synchronized_sqlite3_finalize(statement);
        
    }
    [query release];
    return [childIds autorelease];
}

- (NSSet *) getAllRecordsForObject:(NSString *)objectName
{
    NSMutableSet * ids = [[NSMutableSet alloc] initWithCapacity:0];
    
    NSString * query = [[NSString alloc] initWithString:[NSString stringWithFormat:@"SELECT DISTINCT Id From '%@'", objectName]];
                        
    sqlite3_stmt * statement;
    
    @autoreleasepool
    {
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                char * _id = (char *)synchronized_sqlite3_column_text(statement, 0);
                if ((_id != nil) && strlen(_id))
                {
                    NSString  * recordId = [[NSString alloc] initWithUTF8String:_id];
                    
                    [ids addObject:recordId];
                    
                    [recordId release];
                    recordId = nil;
                }
            }
        }
        synchronized_sqlite3_finalize(statement);
    }

    [query release];
    return [ids autorelease];
}


- (void) purgeRecordForObject:(NSString *)objectName data:(NSString *)ids
{
    NSString * queryStatement = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE Id IN (%@)" ,objectName, ids];
    
    SMLog(kLogLevelVerbose, @"%@ ", queryStatement);
    char * err;
    
    if (synchronized_sqlite3_exec(appDelegate.db, [queryStatement UTF8String], NULL, NULL, &err) != SQLITE_OK)
    {
        SMLog(kLogLevelError,@"%@", queryStatement);
        SMLog(kLogLevelError,@"METHOD:purgeRecordForObject");
        SMLog(kLogLevelError,@"ERROR IN DELETE %s", err);
        [appDelegate printIfError:nil ForQuery:queryStatement type:DELETEQUERY];
    }
}



- (NSSet *)getDistinctObjectApiNames
{
    NSSet *apiNameSet = nil;
    
    NSMutableArray * apiNames = [[NSMutableArray alloc] initWithCapacity:0];
    
    @autoreleasepool
    {
        sqlite3_stmt *statement;
        NSString  *queryString = [[NSString alloc] initWithString:@"SELECT DISTINCT object_api_name FROM SFObjectField"];
        
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, [queryString UTF8String],-1, &statement, nil) == SQLITE_OK )
        {
            while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                char * field = (char *) synchronized_sqlite3_column_text(statement,0);
                
                if ((field != nil) && strlen(field))
                {
                    NSString  *object_api_name = [[NSString alloc] initWithUTF8String:field];
                    
                    if ([object_api_name length] > 0)
                    {
                        [apiNames  addObject:object_api_name];
                    }
                    
                    [object_api_name release];
                    object_api_name = nil;
                }
            }
        }
        
        [queryString release];
        queryString = nil;
        synchronized_sqlite3_finalize(statement);
    }
	
    if ((apiNames != nil) && ([apiNames count] > 0))
    {
        apiNameSet = [[NSSet alloc] initWithArray:apiNames];
    }
    else
    {
        apiNameSet = [[NSSet alloc] init];
    }
    
    [apiNames release];
    return [apiNameSet autorelease];
}


- (NSArray*)getRelationshipForObject:(NSString *)parentName
{
    NSMutableArray * models = [[NSMutableArray alloc] initWithCapacity:0];
    
    @autoreleasepool
    {
        sqlite3_stmt *statement;
        NSString  *queryString = [[NSString alloc] initWithFormat:@"SELECT field_api_name, object_api_name_child FROM SFChildRelationship where object_api_name_parent = '%@'", parentName];
        
        SMLog(kLogLevelVerbose, @"  RelationshipForObject : queryString %@", queryString);
        
        if ( synchronized_sqlite3_prepare_v2(appDelegate.db, [queryString UTF8String],-1, &statement, nil) == SQLITE_OK )
        {
            while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                char * field = (char *) synchronized_sqlite3_column_text(statement,0);
                char * child = (char *) synchronized_sqlite3_column_text(statement,1);
                
                if ((child != nil) && strlen(child))
                {
                    if ((field != nil) && strlen(field))
                    {
                        NSString  *child_field_name = [[NSString alloc] initWithUTF8String:field];
                        NSString  *child_api_name = [[NSString alloc] initWithUTF8String:child];
                        
                        if ( ([child_field_name length] > 0) && ([child_api_name length] > 0))
                        {
                            SMObjectRelationModel *model = [[SMObjectRelationModel alloc] init];
                            model.parentName = parentName;
                            model.childFieldName = child_field_name;
                            model.childName = child_api_name;
                            
                            [models addObject:model];
                            [model release];
                            model = nil;
                        }
                        [child_field_name release]; child_field_name = nil;
                        [child_api_name release]; child_api_name = nil;
                    }
                }
            }
        }
        
        [queryString release];
        queryString = nil;
        synchronized_sqlite3_finalize(statement);
    }
    return [models autorelease];
}


- (NSMutableArray *)getAllLocalIdsForSfId:(NSString *)sfIds objectName:(NSString *)objectName
{
    NSMutableArray * localRecordIds = [[NSMutableArray alloc] initWithCapacity:0];
    
    @autoreleasepool
    {
        if (sfIds != nil)
        {
            sqlite3_stmt *statement;
            NSString  *queryString = [[NSString alloc] initWithFormat:@"SELECT local_id FROM '%@'  WHERE Id IN (%@)", objectName, sfIds];
            
            if (synchronized_sqlite3_prepare_v2(appDelegate.db, [queryString UTF8String],-1, &statement, nil) == SQLITE_OK )
            {
                while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
                {
                    char * _id = (char *) synchronized_sqlite3_column_text(statement,0);
                    if ((_id != nil) && strlen(_id))
                    {
                        NSString * localId = [[NSString alloc] initWithUTF8String:_id];
                        
                        if ((localId != nil) && ([localId length] > 0))
                        {
                            [localRecordIds addObject:localId];
                        }
                        [localId release];
                        localId = nil;
                    }
                }
            }
            [queryString release];
            queryString = nil;
            synchronized_sqlite3_finalize(statement);
        }
    }
    return [localRecordIds autorelease];
}


- (void)purgeRecordFromRealatedTables:(NSString *)tableName column:(NSString *)columnName data:(NSString *)ids
{
    NSString * query = [[NSString alloc] initWithFormat:@"DELETE FROM '%@' WHERE %@ IN (%@)",tableName, columnName, ids]; //9945 Defect Fix
	
    char * err;
	if (synchronized_sqlite3_exec(appDelegate.db, [query UTF8String], NULL, NULL, &err) != SQLITE_OK)
	{
		SMLog(kLogLevelVerbose,@"Failed to delete");
        SMLog(kLogLevelVerbose,@"deleteFromAttachmentTable");
		SMLog(kLogLevelVerbose,@"ERROR IN DELETE %s", err);
	}
    [query release];
}


- (NSMutableDictionary *)getConflictRecordMap
{
    NSMutableDictionary * conflictMap = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSString * query = [[NSString alloc] initWithFormat:@"SELECT DISTINCT sf_id, object_name FROM sync_error_conflict"];
    
    sqlite3_stmt *statement;
    
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String],-1, &statement, nil) == SQLITE_OK )
    {
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * sfid = (char *)synchronized_sqlite3_column_text(statement,0);
            char * name = (char *)synchronized_sqlite3_column_text(statement, 1);
            NSString * recordId = nil;
            NSString * objectName = nil;
            
            if ((sfid != nil) && strlen(sfid))
            {
                recordId = [[NSString alloc] initWithUTF8String:sfid];
            }
            if ((name != nil) && strlen(name))
            {
                objectName = [[NSString alloc] initWithUTF8String:name];
            }
            
            NSMutableArray * array = [conflictMap objectForKey:objectName];
            
            if ((array != nil) && [array count] > 0)
            {
                [array addObject:recordId];
            }
            else
            {
                array = [[NSMutableArray alloc] initWithCapacity:0];
                [array addObject:recordId];
                [conflictMap setObject:array forKey:objectName];
                [array release];
            }
            
        }
    }
    synchronized_sqlite3_finalize(statement);
    [query release];
    return [conflictMap autorelease];
}


- (NSMutableDictionary *)getRecordDictionaryForObjectRelationship:(SMObjectRelationModel *)model
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSString *queryString = [[NSString alloc] initWithFormat:@"SELECT tSource.id, tDestination.id FROM %@ tSource, %@ tDestination WHERE tDestination.%@ = tSource.local_id or tDestination.%@ = tSource.id", model.parentName, model.childName, model.childFieldName, model.childFieldName];

    sqlite3_stmt *statement;
   
    if ( synchronized_sqlite3_prepare_v2(appDelegate.db, [queryString UTF8String],-1, &statement, nil) == SQLITE_OK )
    {
        while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
        {
            char * _sourceId = (char *) synchronized_sqlite3_column_text(statement,0);
            char * _destId = (char *) synchronized_sqlite3_column_text(statement,1);
           
            if (   (_sourceId != nil) && strlen(_sourceId)
                && (_destId != nil) && strlen(_destId) )
            {
                NSString * sourceId = [[NSString alloc] initWithUTF8String:_sourceId];
                NSString * destId = [[NSString alloc] initWithUTF8String:_destId];
                
                if ((sourceId != nil) && ([sourceId length] > 0))
                {
                    //10181
                    NSMutableArray * array = [dictionary objectForKey:sourceId];
                    
                    if ((array != nil) && [array count] > 0)
                    {
                        [array addObject:destId];
                    }
                    else
                    {
                        array = [[NSMutableArray alloc] initWithCapacity:0];
                        [array addObject:destId];
                        [dictionary setObject:array forKey:sourceId];
                        [array release];
                    }
                }
                [sourceId release];
                [destId release];
                destId = nil;
                sourceId = nil;
            }
        }
    }
    [queryString release];
    queryString = nil;
    synchronized_sqlite3_finalize(statement);
    
   return [dictionary autorelease];

}


//9969 Defect Fix
- (NSMutableArray *)getAllRelatedChildIdsForParentIds:(NSString *)childObject parentId:(NSString *)Ids column:(NSString *)columnName
{
    NSMutableArray * ids = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString * query = [[NSString alloc] initWithString:[NSString stringWithFormat:@"SELECT Id From '%@' WHERE %@ In (%@)", childObject, columnName, Ids]];
    
    sqlite3_stmt * statement;
    
    @autoreleasepool
    {
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                char * _id = (char *)synchronized_sqlite3_column_text(statement, 0);
                if ((_id != nil) && strlen(_id))
                {
                    NSString  * recordId = [[NSString alloc] initWithUTF8String:_id];
                    
                    [ids addObject:recordId];
                    
                    [recordId release];
                    recordId = nil;
                }
            }
        }
        synchronized_sqlite3_finalize(statement);
    }
    [query release];
    return [ids autorelease];
}


//Product Manual - 10181
- (NSMutableArray *)getAllProductManualId:(NSString *)ids
{
    NSMutableArray * productManualIds = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSString * query = [[NSString alloc] initWithString:[NSString stringWithFormat:@"SELECT prod_manual_Id From 'trobleshootdata' WHERE ProductId In (%@)", ids]];
    
    sqlite3_stmt * statement;
    
    @autoreleasepool
    {
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            while(synchronized_sqlite3_step(statement) == SQLITE_ROW)
            {
                char * _id = (char *)synchronized_sqlite3_column_text(statement, 0);
                if ((_id != nil) && strlen(_id))
                {
                    NSString  * recordId = [[NSString alloc] initWithUTF8String:_id];
                    
                    [productManualIds addObject:recordId];
                    
                    [recordId release];
                    recordId = nil;
                }
            }
        }
        synchronized_sqlite3_finalize(statement);
    }
    [query release];
    return [productManualIds autorelease];
}

//10346
- (NSMutableDictionary *) getNumberFieldVadlidationData:(NSString *)api_name objectName:(NSString *)objectName validationField:(NSString *)field
{
	NSInteger value = 0;
    
    NSInteger scale = 0;
    
	
    NSMutableDictionary *  dict = [NSMutableDictionary dictionary];
    
    
	NSString * query = [NSString stringWithFormat:@"SELECT %@, %@ FROM SFObjectField WHERE api_name = '%@' and object_api_name = '%@'", field, MSCALE, api_name, objectName];
	
	
	sqlite3_stmt * stmt = nil;
	
	if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
	{
		while (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
		{
			value = synchronized_sqlite3_column_int(stmt, 0);
			scale = synchronized_sqlite3_column_int(stmt, 1);
		}
        if (scale >= 0 && value >= 0)
        {
            NSInteger length = value - scale;
            [dict setValue:[NSString stringWithFormat:@"%d", length] forKey:@"lenght"];
        }
        [dict setValue:[NSString stringWithFormat:@"%d", value] forKey:MPRECISION];
        
		synchronized_sqlite3_finalize(stmt);
	}
	return dict;
}

- (NSInteger) getScaleValueForNumberField:(NSString *)api_name objectName:(NSString *)objectName validationField:(NSString *)field
{
	NSInteger value = 0;
    
	NSString * query = [NSString stringWithFormat:@"SELECT %@ FROM SFObjectField WHERE api_name = '%@' and object_api_name = '%@'", field, api_name, objectName];
	
	
	sqlite3_stmt * stmt = nil;
	
	if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, nil) == SQLITE_OK)
	{
		if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
		{
			value = synchronized_sqlite3_column_int(stmt, 0);
		}
    }
    synchronized_sqlite3_finalize(stmt);
	return value;
}

@end