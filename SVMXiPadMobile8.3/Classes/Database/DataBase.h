//
//  DataBase.h
//  iService
//
//  Created by Developer on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sqlite3.h>
#include "ZKSforce.h"
#import "DataBaseGlobals.h"

#import "SBJsonParser.h"

@class iServiceAppDelegate;
@class PopoverButtons;

@interface DataBase : NSObject 
{
    //RADHA
    id MyPopoverDelegate;
    
    NSString *dbFilePath;
	//sqlite3  *db;
    
    //Abinash
    sqlite3 * tempDb;
    NSString * filepath;
    NSMutableArray * object_names;
    
    

    BOOL didInsertTable;
    
    iServiceAppDelegate * appDelegate;
    
    BOOL didGetPDF;
    BOOL didAddValues;
    NSMutableArray * processIdList;
    
    //Abinash
    NSString * currentRecordId;
    NSArray * serviceReportSettings;
    NSMutableString * settingInfoId;
    NSMutableArray * settingsInfoArray;
    NSMutableArray * settingsValueArray;
    NSMutableArray * reportEssentials;
    BOOL didGetReportEssentials;
   // int i;
    
    SBJsonParser * parser;
    
    PopoverButtons * metaSyncPopover;
    
}

//RADHA

@property (nonatomic, retain) id MyPopoverDelegate;

@property (nonatomic, retain) NSString *dbFilePath;
//@property (nonatomic) sqlite3  *db;

@property BOOL didInsertTable;

//- initWithDBName:(NSString *)name type:(NSString *)type sqlite:(sqlite3 *)db;

//Insert InTo Table Methods
- (void) insertValuesInToOBjDefTableWithObject:(NSMutableArray *)object definition:(NSMutableArray *)objectDefinition;
- (void) insertValuesInToReferenceTable:(NSMutableArray *)object definition:(NSMutableArray *)objectDefinition;
- (void) insertValuesInToObjectTable:(NSMutableArray *)object definition:(NSMutableArray *)objectDefintion;
- (void) insertValuesInToRecordType:(NSMutableArray *)object defintion:(NSMutableArray *)objectDefinition;
- (void) insertValuesInToChildRelationshipTable:(NSMutableArray *)object definition:(NSMutableArray *)objectDefinition;

- (void) insertSourceToTargetInToSFProcessComponent;

//Expressions 
- (void) insertValuesInToExpressionTables:(NSMutableDictionary *)processDictionary;

//Objectmapping
- (void) insertValuesInToObjectMappingTable:(NSMutableDictionary *)processDictionary;

// Insert values into picklist table
- (void) insertvaluesToPicklist:(NSMutableArray *)object fields:(NSMutableArray *)fields value:(NSMutableArray *)values;

//SFProcess
- (void) insertValuesToProcessTable:(NSMutableDictionary *)processDictionary page:(NSMutableArray *)pageHistory;

//Create Table with coloumns
- (void) createObjectTable:(NSMutableArray *)object coulomns:(NSMutableArray *)columns;
- (void) insertColoumnsForTable:(NSString *)tableName columns:(NSMutableArray *)columns;


//column type
- (NSString *) columnType:(NSString *)type;

//tags and settings
- (void) insertValuesInToTagsTable:(NSMutableDictionary *)tagsDictionary;
- (void) insertValuesInToSettingsTable:(NSMutableDictionary *)settingsDictionary;

//Wizards and Wizard_component
- (void) insertValuesInToSFWizardsTable:(NSDictionary *)wizardDict;

//Lookuptable
- (void) insertValuesInToLookUpTable:(NSMutableDictionary *)processDictionary;
//Test
//-(void)openDB:(NSString *)name type:(NSString *)type sqlite:(sqlite3 *)database;

- (NSString *) getObjectNameFromSFobjMapping:(NSString *)mappingId;
- (NSString *) getSourceChildNameFromProcessId:(NSString *)soureobjectName processid:(NSString *)processId;
   
//Clear Database
- (void) clearDatabase;
- (BOOL) createTable:(NSString *)statement;

//Retreive All Tags
- (NSMutableDictionary *) getTagsDictionary;

//Add username to the user table.
- (void) insertUsernameToUserTable:(NSString *)UserName;

//RTDependentPicklist
- (void) insertValuesInToRTPicklistTableForObject:objects Values:(NSMutableDictionary *)recordTypeDict;

//- (NSMutableArray *) collectAllPicklistField;

//Method to create extra table for trouble shooting and summary
- (void) createTableForSummaryAndTroubleShooting;

//SFM Search
- (void) createTablesForSFMSearch;
- (void) insertValuesintoSFMProcessTable:(NSMutableArray *) processData;
- (void) insertValuesintoSFMObjectTable:(NSMutableArray *) processData;
- (NSMutableArray *) getSFMSearchConfigurationSettings;
- (NSMutableArray *) getSearchableFieldsForObject:(NSString *)objectName;
- (NSMutableArray *) getDisplayFieldsForObject:(NSString *)objectName;
- (NSMutableArray *) getSearchCriteriaForObject:(NSString *)objectId;
- (NSMutableArray *) getResults:(NSString *)object withConfigData:(NSDictionary *)dataForObject;
//DataSync Methods
- (void) insertDataInToTables:(NSMutableArray *)fieldValueArray;

- (void) updateChildSfIdWithParentLocalId:(NSArray *)childObject;

- (void) addvaluesToLookUpFieldTable:(NSDictionary *)lookUpDict WithId:(NSInteger)Id;

- (BOOL) checkForDuplicateId:(NSString *)objectName sfId:(NSString *)sfId;

- (NSString *) getNameFieldForObject:(NSString *)headerObjectName WithRecordId:(NSString *)recordId;


//generate PDF Settings
//Abinash
- (void) generatePDFSettings;

- (void) didGetModuleInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) didGetSubModuleInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) didGetSettingsInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) didGetActiveGlobalProfile:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) didGetSettingsValue:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void)insertSettingsIntoTable:(NSMutableArray*)array:(NSString*)TableName;

//Abinash
- (void)openDB:(NSString *)name type:(NSString *)type sqlite:(sqlite3 *)database;
- (NSString *)retrieveQuery:(NSString *)tableName sqlite:(sqlite3 *)database;
- (BOOL) createTemporaryTable:(NSString *)statement;
- (void)StartIncrementalmetasync;
- (void) createBackUpDb;
- (NSArray *) createTempTableForSummaryAndTroubleShooting;
- (void) populateDatabaseFromBackUp;
- (void)deleteDatabase:(NSString *)databaseName;

- (void) removecache;


//update plist
- (void) updateRecentsPlist;

- (NSString *)getLoggedInUserId:(NSString *)username;

//Value for recordtype
- (NSString *)getValueForRecordtypeId:(NSString *)recordtypeId object_api_name:(NSString *)object_api_name;

- (NSMutableDictionary *) getSettingsDictionary;

//RADHA - 21 MARCH
- (NSMutableArray *) retreiveTableNamesFronDB:(sqlite3 *)dbName;
- (void) copyTempsqlToSfm;


//-RADHA - 10th April
- (NSMutableArray *) getAllTheRecordIdsFromEvent;
- (NSMutableArray *) checkForTheObjectWithRecordId:(NSMutableArray *)recordId;
- (NSMutableArray *) retreiveObjectNames;
- (BOOL) doesObjectExistsForEventID:(NSString *)object _Id:(NSString *)recordId;

- (NSMutableArray *) getAllTheNewEventsFromSynCRecordHeap;

- (void) removeIdExistsInIntialEventMappingArray;

- (NSString *) getDateToDeleteEventsAndTask:(NSTimeInterval)Value;

- (void) purgingDataOnSyncSettings:(NSString *)Date tableName:(NSString *)tableName;


- (void) callIncrementalMetasync;

- (void) clearTempDatabase;

//DATA SYNC
- (void) startFullDataSync;
- (void) copyMetaSyncDataInToSfm;
- (NSMutableArray *) retreiveDataObjectTable;
- (void) copyMetaTableInToSfm:(NSMutableArray *)metaTable;
- (void) startDataSync;
@end
