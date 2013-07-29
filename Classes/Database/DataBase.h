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
#import "ZipArchive.h"
#import "SBJsonParser.h"

# define SUCCESS_           @"SUCCESS_"
# define NOINTERNET         @"NOINTERNET"
# define CONNECTIONERROR    @"CONNECTIONERROR"
#define OBJECT_ID                                       @"Id"
#define FIELD_NAME                                      @"SVMXC__Field_Name__c"
#define OBJECT_NAME2                                    @"SVMXC__Object_Name2__c"
#define LOOKUP_FIELD_API_NAME                           @"SVMXC__Lookup_Field_API_Name__c"
#define FIELD_RELATIONSHIP_NAME                         @"SVMXC__Field_Relationship_Name__c"
#define OBJECT_FIELD_NAME                               @"SVMXC__Object_Name__c"
#define DISPLAY_TYPE                                    @"SVMXC__Display_Type__c"
#define OPERAND                                         @"SVMXC__Operand__c"
#define OPERATOR                                        @"SVMXC__Operator__c"
// SFM Search
#define SKIP_DISPLAY_FIELD                              @"skipped_Field"

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
    
    // Vipindas Palli - Optimization
    int dbTransactionCount;
    
    //Keerti - 7275
    BOOL isSortingDone;
    NSMutableArray *arrayofAlias;
    //krishna
    BOOL didRcvAttachment;
    BOOL didRcvStaticresource;
    BOOL didReceiveImageDocument;
}

// Damodar
@property (nonatomic, retain) ZipArchive *zipArchiver;
@property (assign) int didSubmitHTML;
@property (assign) int didGeneratePDF;


//RADHA

@property (nonatomic,assign) sqlite3 * tempDb;
@property (nonatomic, retain) id MyPopoverDelegate;

@property (nonatomic, retain) NSString *dbFilePath;
//@property (nonatomic) sqlite3  *db;

@property BOOL didInsertTable;
@property(nonatomic,assign) BOOL didTechnicianLocationUpdated;
@property(nonatomic,assign) BOOL didUserGPSLocationUpdated;

// Vipindas Palli - Optimization
@property(assign) int dbTransactionCount;

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

//Linked SFMProcess
-(void)insertValuesIntoLinkedSFMProcessTable:(NSMutableDictionary *)processDictionary;

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

/*Shra-lookup*/
- (void)insertFilterComponents:(NSArray *)filterComponents;
- (void)insertCriteriaComponents:(NSArray *)filterArray;
- (BOOL)checkIfGivenSFMId:(NSString *)sfmId
             existInTable:(NSString *)tableName
             andFieldName:(NSString *)fieldName;

- (void)storeTechnicianLocation:(NSString *)currentLocation;
- (NSString *)getTechnicianLocation;
- (void)removeUserTechnicianLocation;
- (NSString *)getTechnicianLocationId;
- (void)storeTechnicianLocationId:(NSString *)currentLocation;
/*Shra-lookup ends*/


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
- (BOOL) getImageForServiceReportLogo;
- (void) didGetServiceReportLogo:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
//Aparna
- (NSData *)serviceReportLogoInDB;


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

//Sync Override : Radha
- (void) updateWebserviceNameInWizarsTable:(NSArray *)customArray;
- (void) attachSiganture:(NSString *)operation_type;
// SFM Search Alias implementation

//Keerti - 7275
-(NSString *) CreateRandomString:(NSString*)objectName;
-(NSString*)random;
-(NSString*)getapiNameforObject:(NSString*)objectName RelationshipName:(NSString*)relName;
-(NSMutableArray*)parsingExpression:(NSString*)Expression;
-(BOOL)isColumnPresentInTable:(NSString*)TableName columnName:(NSString*)colName;
-(NSMutableArray*)getSortObjects:(NSString *)objectId;

// SFM Search Result methods for Alias implementation
- (NSMutableArray *) getResultsForSFM:(NSString *)object withConfigData:(NSDictionary *)dataForObject;
-(NSMutableString*)getJoinFieldsForSFM:(NSDictionary*)dict;
-(NSMutableDictionary*) getupdatedTokenForSFM:(NSMutableDictionary*)dictforparsing;

//Shrinivas : OAuth.
- (NSString *)getLocalIdFromUserTable:(NSString *)userName;
- (NSString *)getUserNameFromUserTable:(NSString *)local_Id;

//PB Sync Conflict - Check if object is in conflict
-(int)checkIfObjectIsInConflict:(NSString *)objectName Id:(NSString *)local_id;
- (int)countRecordsInSyncConflictWith:(NSString *)objectName Id:(NSString *)localORsfid;

// Vipin-db-optmz
/* Database - Configuration management */
- (void)resetConfigurationForDataBase:(sqlite3 *)database;
- (void)cleanupDatabase;

/* Index creation - Sync Record Heap table */
- (void)doTableIndexCreation;
- (void)dropAllExistingTableIndex;

/* Database Transaction management */
- (int)beginTransaction;
- (int)endTransaction;

// Vipin-db-optmz
- (void)addValuesToLookUpFieldTable:(NSMutableArray *)values;

//Krishna OPDocs
- (void) insertIntoRequiredPdf:(NSString *)recordId processId:(NSString *)processId andAttachmentId:(NSString *)attachmentId;
- (void)deleteRequiredPdfRecord:(NSString *)recordId forProcessId:(NSString *)processId;
- (NSMutableArray *) getAllRequiredPdf;
- (void)deleteRequiredPdfForAttachement:(NSString *)attachementId;
- (void) insertIntoRequiredSignature:(NSString *)attachmentId andSignatureId:(NSString*)signId;
- (NSMutableArray *) getAllRequiredSignature;
- (void)deleteRequiredSignatureFor:(NSString *)attachmentId;

- (void)insertIntoDocTemplate:(NSDictionary*)process_dict;
- (void)insertIntoDocTemplateDetails:(NSDictionary*)process_dict;
- (void)insertIntoAttachment:(NSDictionary*)process_dict;
- (void)downloadResources:(NSDictionary*)resourceDict;
- (void)retrieveImages:(NSDictionary*)resourceDict;
- (void)retrieveImageDocumentFor:(NSString*)docId;
- (void)insertIntoStaticResource:(NSDictionary*)resourceDict;
- (void)retrieveStaticResourceFor:(NSString*)resId;
- (void)getAttachmentForId:(NSString *)attachmentId;
- (void)requestForStaticResources;
- (void)downloadPDFsForUploadedHtml;
- (void)downloadPdfFor:(NSString*)att_id;


- (NSMutableArray *) getDocumentTemplatesForProcessId:(NSString *)processId ;
-(void)UpdateDocumentTemplateId:(NSString *)docTemplateId forProcessId:(NSString *)processId;

// SFM Biz Rules
- (void) insertValuesIntoProcessBusinessRuleTable:(NSDictionary *)processDictionary;
- (void) insertValuesIntoBusinessRuleTable:(NSDictionary *)processDictionary;

//Aparna: Source Update
- (NSArray *)sourceUpdatesForProcessId:(NSString *)processId;
- (void) updateSourceObjects:(NSArray *)sourceObjects forSFId:(NSString *)recordId;
- (NSString *)sfIdForProcessId:(NSString *)processId;


@end
