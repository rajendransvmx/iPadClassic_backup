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

# define SUCCESS_           @"SUCCESS_"
# define NOINTERNET         @"NOINTERNET"
# define CONNECTIONERROR    @"CONNECTIONERROR"

@class iServiceAppDelegate;
@class PopoverButtons;

PopoverButtons *popOver_view;

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
    
    //Location Ping
    NSMutableString * settingInfoIdForLocationPing;
    NSMutableArray  * settingsInfoArrayForLocationPing;
    NSMutableArray  * settingsValueArrayForLocationPing;
    BOOL didTechnicianLocationUpdated;
    BOOL didGetReportEssentials;
   // int i;
    
    SBJsonParser * parser;
    
    PopoverButtons * metaSyncPopover;
    
    BOOL didGetServiceReportLogo;
    BOOL RecordTypeflag;
    
}

//RADHA

@property (nonatomic,assign) sqlite3 * tempDb;
@property (nonatomic, retain) id MyPopoverDelegate;

@property (nonatomic, retain) NSString *dbFilePath;
//@property (nonatomic) sqlite3  *db;

@property BOOL didInsertTable;
@property(nonatomic,assign) BOOL didTechnicianLocationUpdated;
@property(nonatomic,assign) BOOL didUserGPSLocationUpdated;

//- initWithDBName:(NSString *)name type:(NSString *)type sqlite:(sqlite3 *)db;

//sahana
-(NSString *)getSettingUniqueIdForSettingId:(NSString *)setting_id submodule_id:(NSString *)submodule_id;
-(void)getCodeSnippetSetting;
-(void)createEventTrigger:(NSString *)code_snippet;
-(BOOL)isHeaderRecord:(NSString*)objectName;
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
- (void) insertColoumn:(NSString *)columnName
              withType:(NSString *)columnType
               inTable:(NSString *)tableName;

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
- (NSString *) getFieldLabelForApiName:(NSString *)apiName;
- (NSString *) getApiNameFromFieldLabel:(NSString *)apiName;
- (NSString*) getLabelFromApiName:(NSString*)api_name objectName:(NSString*) objectName;
- (NSString *) getSearchQueryPartFromArray:(NSArray *)objectsArray withSearchString:(NSString *)searchString withUserData:(NSString *)criteriaString;
- (NSString *) getSearchCriteriaStringFromUserData:(NSString *)criteriaString withSearchString:searchString;
- (NSArray *) getConfigurationForProcess:(NSString *) processName ;
-(NSString*) getRefrenceToField:(NSString*)objectName relationship:(NSString*) relationship_name;
-(NSString*) getNameFiled:(NSString*)obejctName;
-(BOOL)isTableEmpty:(NSString*)tableName;

// Location Ping
- (void) createUserGPSTable;
- (NSString *) getSettingValueWithName:(NSString *)settingName;
- (void) deleteSequenceofTable;
- (void) insertrecordIntoUserGPSLog:(NSDictionary *)locationInfo;
- (void) purgeLocationPingTable;
- (void) deleteSequenceofTable:(NSString *)tableName;
- (void) updateTechnicianLocation;
- (void) updateUserGPSLocation;
- (void) deleteRecordFromUserGPSTable:(NSString *) localId;
-(NSString*) getLoggedInUser:(NSString *)username;
-(NSString*)getReferencetoFiledForObject:(NSString*)objectName api_Name:(NSString*)api_name;

//DataSync Methods
- (void) insertDataInToTables:(NSMutableArray *)fieldValueArray;

- (void) updateChildSfIdWithParentLocalId:(NSArray *)childObject;

- (void) addvaluesToLookUpFieldTable:(NSDictionary *)lookUpDict WithId:(NSInteger)Id;

- (BOOL) checkForDuplicateId:(NSString *)objectName sfId:(NSString *)sfId;

- (NSString *) getNameFieldForObject:(NSString *)headerObjectName WithRecordId:(NSString *)recordId;

- (NSString *) getApiNameForNameField:(NSString *)headerObjectName;

- (NSString *) getReferenceObjectNameForPdf:(NSString *)ObjectName Field:(NSString *)FieldName Id:(NSString *)Id;
- (NSMutableString *) getJoinFields:(NSDictionary*)dict;
- (NSMutableDictionary *) getNameFieldForRefrenceObject:(NSDictionary*)tableArray;

//generate PDF Settings
//Abinash
- (void) generatePDFSettings;

- (void) didGetModuleInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) didGetSubModuleInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) didGetSettingsInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) didGetActiveGlobalProfile:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) didGetSettingsValue:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void)insertSettingsIntoTable:(NSMutableArray*)array:(NSString*)TableName;

//Radha - Incremental MetaSync
- (void)openDB:(NSString *)name type:(NSString *)type sqlite:(sqlite3 *)database;
- (NSString *)retrieveQuery:(NSString *)tableName sqlite:(sqlite3 *)database;
- (BOOL) createTemporaryTable:(NSString *)statement;
- (void)StartIncrementalmetasync;
- (void) createBackUpDb;
- (NSArray *) createTempTableForSummaryAndTroubleShooting;
- (void) populateDatabaseFromBackUp;
- (void)deleteDatabase:(NSString *)databaseName;

- (void) removecache;

//May-24-2011
//- (void) startMetaSync;

- (NSString *) getDataTypeFor:(NSString *)objectName inArray:(NSArray *)dataArray;


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

- (NSString *) getDateToDeleteEventsAndTaskOlder:(NSTimeInterval)Value;

//july 3
- (NSString *) getDateToDeleteEventsAndTaskForNext:(NSTimeInterval)Value;

- (void) purgingDataOnSyncSettings:(NSString *)Date tableName:(NSString *)tableName Action:(NSString*)Action;


- (void) callIncrementalMetasync;

- (void) clearTempDatabase;

//DATA SYNC
//- (void) startFullDataSync;
//- (void) copyMetaSyncDataInToSfm;
- (NSMutableArray *) retreiveDataObjectTable;
- (void) copyMetaTableInToSfm:(NSMutableArray *)metaTable;
//- (void) startDataSync;

//RADHA only event sync
- (BOOL) startEventSync;
- (void) scheduleEventSync;

//RADHA 2012june08
- (BOOL) checkIfRecordExistForObject:(NSString *)tableName Id :(NSString *)Id;

//Radha 2012june16
- (void) insertMetaSyncDue:(NSString *)tableName;

- (BOOL) checkIfSyncConfigDue;
- (BOOL) checkIfRecordExistForObjectWithRecordId:(NSString *)tableName Id :(NSString *)Id;

//ServiceReportLogo
- (void) getImageForServiceReportLogo;
- (void) didGetServiceReportLogo:(ZKQueryResult *)result error:(NSError *)error context:(id)context;


- (NSString *) callMetaSync;

- (void) doMetaSync;

- (void) settingAfterIncrementalMetaSync;
- (void) updateUserTable:(NSString *)UserId Name:(NSString*)name;
- (NSString *) getValueFromLookupwithId:(NSString *)Id;
- (NSString *) getvalueforReference:(NSDictionary*) tableArray value:(NSString*)value;
-(NSMutableDictionary*) getupdatedToken:(NSMutableDictionary*)dictforparsing;

//Checkbox
-(NSString *) getfieldTypeForApi:(NSString *)tableName fieldName:(NSString *)fieldName;
-(NSMutableDictionary*) occurenceOfBraces:(NSString*)token;
- (NSString *) getSearchCriteriaStringFromUserData:(NSString *)criteriaString withSearchString:searchString;

//sahana Aug 16th
-(void)getRecordTypeValuesForObject:(NSArray *)allObjects;
-(void)UpdateSFRecordTypeForId:(NSString *)_id value:(NSString *)valueField;


- (NSString *) getParentColumnValueFromchild:(NSString *)parentColumn childTable:(NSString *)objectName sfId:(NSString *)sf_id;
- (NSString *) getParentlocalIdchild:(NSString *)parentColumn childTable:(NSString *)objectName local_id:(NSString *)local_id;


//Conflicts for event
- (BOOL) checkIfConflictsExistsForEvent:(NSString *)SF_Id objectName:(NSString *)objectName local_id:(NSString *)local_id;
- (BOOL) checkIfChildConflictexist:(NSString *)objectName sfId:(NSString *)SF_Id;
- (NSString *) getChildColumnForParent:(NSString *)objectName;
- (NSString *) getchildSfIdOrLocalId:(NSString *)tablename Id:(NSString *)Id  parentColumn:(NSString *)parentColumn  Key:(NSString *)key;
- (BOOL) checkIfConflictsExistsForEventWithLocalId:(NSString *)local_id objectName:(NSString *)objectName;
- (NSMutableString *) getAllTheConflictRecordsForObject:(NSString *)ObjectName local_id:(NSString *)local_id;
- (BOOL) checkIfConflictsExistsForEventWithSFID:(NSString *)sfid objectName:(NSString *)objectName;
-(BOOL)isTabelExistInDB:(NSString*)tableName;

//Radha DefectFix - 5721
- (NSInteger) getTextareaLengthForFieldApiName:(NSString *)api_name objectName:(NSString *)objectName;

//Radha #6176
- (NSMutableString *) getAllEventRelatedIdFromSyncRecordHeap;
- (void) deleteEventNotRelatedToLoggedInUser:(NSMutableString *)Id tableName:(NSString *)tableName;

//Help Files
-(void)updateUserLanguage:(NSString*)language;
-(NSString*)getUserLanguage:(NSString*)userName;
-(NSString*)checkUserLanguage;
- (NSArray *) getAllRecordsFromTable:(NSString *) tableName
                          forColumns:(NSArray *) columnsArray
                      filterCriteria:(NSString *) criteria
                               limit:(NSString *) limit;
- (NSArray *) getUniqueRecordsFromTable:(NSString *) tableName
                              forColumn:(NSString *) columnName
                         filterCriteria:(NSString *) criteria;

@end
