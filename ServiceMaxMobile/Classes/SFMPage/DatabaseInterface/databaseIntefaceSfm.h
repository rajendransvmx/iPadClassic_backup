//
//  databaseIntefaceSfm.h
//  iService
//
//  Created by Pavamanaprasad Athani on 03/11/11.
//  Copyright (c) 2011 Bit Order Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "offlineGlobles.h"
#import "iOSInterfaceObject.h"
#import "JSON.h"
#import "SBJsonParser.h"
#import "SuccessiveSyncModel.h"
#import "SVMXLookupFilter.h"
@protocol databaseInterfaceProtocol;
@class AppDelegate;
@class SBJsonParser;
@interface databaseIntefaceSfm : NSObject
{
    //RADHA
    id MyPopoverDelegate;
    
    //sqlite3 * db;
    AppDelegate * appDelegate;
    id <databaseInterfaceProtocol> databaseInterfaceDelegate;
    
    // Vipind-db-optmz
    NSMutableDictionary  *fieldDataTypeDict;
    NSMutableDictionary   *childInfoDict;
    NSMutableDictionary   *childInfoCacheDictionary;

}

@property (nonatomic , assign)  id  <databaseInterfaceProtocol> databaseInterfaceDelegate;
@property (nonatomic, retain) id MyPopoverDelegate;

@property (nonatomic, retain) NSMutableDictionary  *successiveSyncRecords;
@property (nonatomic, retain) NSMutableArray * modifiedLineRecords;

//sahana 16th Jan for alerting overlapping events fix
-(NSString *)getNameForSFId:(NSString *)sfId;
-(NSString *)getallOverLappingEventsForStartDateTime:(NSString *)startDateTime EndDateTime:(NSString *)endDateTime local_id:(NSString *)local_id;
//Sahana Dec 7th 2012
-(void)InsertInto_User_created_event_for_local_id:(NSString *)local_id sf_id:(NSString *)sf_id;
-(void)insertIntoEventsLocal_ids:(NSString *)local_id  fromEvent_temp_table:(NSString *)event_temp_table;
-(NSString *)getLocal_idFrom_Event_local_id:(NSString *)event_temp_table;
-(void)deleteRecordsFromEventLocalIdsFromTable:(NSString *)event_temp_table;

-(void)updateChildParentColumnNameForParentObject:(NSString *)master_object masterLocalId:(NSString *)masterLocal_id child_info:(NSMutableDictionary *)child_info;
-(void)insertOndemandRecords:(NSMutableDictionary *)record_dict;
-(void)insertrecordintoOnDemandTableForId:(NSString *)sf_id recordType:(NSString *)RecordType local_id:(NSString *)local_id json_record:(NSString *)json_record object_name:(NSString *)object_name;

//sahana 15th sep
-(void)updatedataTrailerTAbleForLocal_id:(NSString *)local_id  sf_id:(NSString *)sf_id;

-(NSString *) filePath:(NSString *)dataBaseName;

//method to  get the processInfo ( page layout information) 
-(NSMutableDictionary *)queryProcessInfo:(NSString * )Process_id  object_name:(NSString *)object_name;

//method to get the header data from the header Object name table
-(NSMutableDictionary *)queryTheObjectInfoTable:(NSMutableArray *)api_names tableName:(NSString *)tableName object_name:(NSString * ) objectName;

-(NSMutableDictionary *)queryDataFromObjectTable:(NSMutableArray *)api_names tableName:(NSString *)tableName record_id:(NSString *) recordId expression:(NSString *)expression;
//method to get the line data from lines table
-(NSMutableArray *)queryLinesInfo:(NSMutableArray *)apiNames  detailObjectName:(NSString *)detailObjectName headerObjectName:(NSString *)headerObjectName detailaliasName:(NSString *)detailsAliasName headerRecordId:(NSString *)record_id expressionId:(NSString *)expression_id parent_column_name:(NSString *)parent_column sorting_order:(NSString *) sorting_order_string;
/// Sahana for sorting
-(BOOL)checkColumnExists:(NSString *)columnname tableName:(NSString *)tableName;

//method to  get the processInfo ( page layout information) 
-(NSMutableArray *) selectProcessFromDB:(NSString *)currentObject;

// method to get Picklist values for a filed 
-(NSMutableDictionary *)getPicklistValuesForTheFiled:(NSString *)fieldname  tableName:(NSString *)tablename objectName:(NSString *)objectName;

//method to get the field data type of the field
-(NSString *)getFieldDataType:(NSString *)objectName filedName:(NSString *)fieldName ;


//methods to query for Reference field

-(NSString *)getTheObjectApiNameForThePrefix:(NSString *)keyPrefix  tableName:(NSString *)tableName;

-(NSMutableArray *)getReferenceToForField:(NSString *)field_apiname  objectapiName:(NSString *)objectApiName tableName:(NSString *)tableName ;
// query from  SFReference_to   table
-(NSString *)getFieldNameForReferenceTable:(NSString *)referedToTableName  tableName:(NSString *)tableName;//query from SFObjectField table rest depends on look up config

-(NSString *)getReferenceValueFromReferenceToTable:(NSString *)tableName field_name:(NSString *) filed_name record_id:(NSString *)record_id ;//query from ReferedTo table

-(BOOL)checkForTheTableInTheDataBase:(NSString *)tableName;

//methods to get title for the object
-(NSString *) getObjectLabel:(NSString *)tableName objectApi_name:(NSString *)objectApiName;
-(NSString *) getObjectName: (NSString *) tablename recordId:(NSString *)recordId;

//method to get the parent column in the childRelationship table 
-(NSString *)getParentColumnNameFormChildInfoTable:(NSString *)tableName  childApiName:(NSString *)objectApiNameChild parentApiName:(NSString *)objectApiNameParent;

//method to get the record type of the record
//-(NSString *)findTheTypeofTheRecordFromRecordTypeIdTable:(NSString *)tableName record_typeId:(NSString *)record_type_id objectOrLineApiName:(NSString *)apiName;//  Unused Methods

//method to fetch the restorationtime and resolvedTime for the SLA clock
-(NSMutableDictionary *)getRestorationAndResolutionTimeForWorkOrder:(NSString *)record_id  tableName:(NSString *)tableName;


//Aditional Info Account History and Product History

-(NSMutableArray *)getProductHistoryForanWorkOrder:(NSString *)record_id  filedName:(NSString *)fieldName tableName:(NSString *)tablename  fieldValue:(NSString *)fieldValue;

-(NSMutableArray *)getAccountHistoryForanWorkOrder:(NSString *)record_id  account_id:(NSString *)account_id tableName:(NSString *)tablename ;

-(NSMutableDictionary *)gettheAdditionalInfoForForaWorkOrder:(NSString *)record_id tableName:(NSString *)tablename;


//method to retrieve the local id for the  sf id

-(NSString *)getLocalIdFromSFId:(NSString *)recordId  tableName:(NSString *)tableName;


-(NSMutableDictionary *)queryForMapWorkOrderInfo:(NSString *)record_id tableName:(NSString *)tableName;

//get the create process array
-(NSMutableArray *)getAllTheProcesses:(NSString *)processType;

//-(NSMutableDictionary *)getValueMappingForlayoutId:(NSString *)layoutId process_id:(NSString *)processId objectName:(NSString *)objectName;

-(NSMutableDictionary *)getObjectMappingForMappingId:(NSMutableDictionary *)process_components mappingType:(NSString *)mapping_type ;

-(NSMutableDictionary *)getAllObjectFields:(NSString *)objectName tableName:(NSString *)tableName;

-(BOOL)insertdataIntoTable:(NSString *)tableName data:(NSMutableDictionary *)valuesDict;

-(NSString *)getTheRecordIdOfnewlyInsertedRecord:(NSString *)tableName;

-(NSMutableDictionary *)getDataForMultiAdd:(NSString *)object_name searchField:(NSString *)search_field lookUpSearchId:(NSString *)searchId;

//get the lookup information from database 
//- (NSDictionary *) getLookupDataFromDBWith:(NSString *)lookupID referenceTo:(NSString *)object searchFor:(NSString *)searchForString;

//Krishna CONTEXTFILTER
- (NSDictionary *) getLookupDataFromDBWith:(NSString *)lookupID
                               referenceTo:(NSString *)object
                                 searchFor:(NSString *)searchForString
                            withPreFilters:(NSArray *)preFilters
                                andFilters:(NSArray *)advancedFilters
                       lookupContextFilter:(SVMXLookupFilter *)contextLookupFilter;
- (NSDictionary *)getValueForFieldName:(NSString *)fieldName andLiteralValue:(NSString *)headerValue;

-(NSString *)queryForExpression:(NSString *)expression_id forObject:(NSString *)object_name;
-(NSString *) queryForExpressionComponent:(NSString *)expression expression_id:(NSString *)expression_id object_name:(NSString *) object_name;

//-(NSString *)getTheDefaultDisplayColumnForLookUpId:(NSString *)lookup_id;//  Unused Methods

//Action Buttons Information - SFW
-(NSMutableArray *)getButtonsForWizardInformation:(NSMutableArray *)wizard_ids_array  record_id:(NSString *)record_id  object_name:(NSString *)objectName;
-(NSMutableDictionary *) getWizardInformationForObjectname : (NSString *) objectName  record_id:(NSString *)record_id;

-(NSMutableArray *)getObjectMappingForMappingId:(NSMutableDictionary *)process_components  source_record_id:(NSString *)source_record_id field_name:(NSString *)field_name;

-(NSMutableArray *)getChildLocalIdForParentId:(NSString *)parent_id childTableName:(NSString *)childObjectName sourceTableName:(NSString *)sourceObjectName;
 
-(NSMutableDictionary *)getProcessComponentsForComponentType:(NSString *)componentType process_id:(NSString *)processId  layoutId:(NSString *)layoutId  objectName:(NSString *)objectName ; 

-(NSString *)getprocessTypeForProcessId:(NSString *)process_id;
-(BOOL)UpdateTableforId:(NSString *)local_id  forObject:(NSString *)objectName  data:(NSDictionary *)dict;

-(BOOL)EntryCriteriaForRecordFortableName:(NSString *)tableName record_id:(NSString *) recordId  expression:(NSString *)expression;

-(NSString *)getLookUpNameForId:(NSString *)id_;

-(NSString * )checkforSalesForceIdForlocalId:(NSString *)objectName local_id:(NSString *)local_id;

//sahana incremental Data Sync
-(NSMutableDictionary *) getAllRecordsFromRecordsHeap;

-(void)updateAllRecordsToSyncRecordsHeap:(NSMutableDictionary *)sync_data;
-(void)insertRecordIdsIntosyncRecordHeap:(NSMutableDictionary *)sync_data;

-(NSMutableArray *) getAllInsertRecords:(NSString *)operation_type;

-(NSArray *)getAllObjectsForRecordType:(NSString *)record_type  forOperation:(NSString *)operation_type;

-(NSMutableDictionary *)getRecordsForRecordId:(NSString *)record_id ForObjectName:(NSString *)object_name fields:(NSString *)fields;

-(void)updateDataTrailer_RecordSentForlocalId:(NSString *)local_id operation_type:(NSString *)operationType;

//Sync_Overide :- Adding the new parameters to the existing method (webservice_name, class_name, synctype)

-(void) insertdataIntoTrailerTableForRecord:(NSString *)local_id SF_id:(NSString *)sf_id record_type:(NSString *)record_type operation:(NSString *)operation object_name:(NSString *)object_name  sync_flag:(NSString *)sync parentObjectName:(NSString *)parentObjectName parent_loacl_id:(NSString *)parent_local_id webserviceName:(NSString *)webservice_name className:(NSString *)class_name synctype:(NSString *)sync_type headerLocalId:(NSString *)header_localId requestData:(NSMutableDictionary *) request_data  finalEntry:(BOOL)isFinalCustomEntry;

-(void)copyTrailerTableToTempTrailerForOperationType:(NSString *)operation_type;
-(void)cleartable:(NSString *)table_name;
-(NSMutableArray *) getAllSyncRecordsFromSYNCHeap;
-(void)updateSyncRecordsIntoLocalDatabase;
-(BOOL)DeleteDataTrailerTableAfterSync:(NSString *)local_id forObject:(NSString *)object  sync_type:(NSString *)sync_type;
-(NSMutableDictionary *)getDictForJsonString:(NSString *)json_record;
-(BOOL)UpdateTableforSFId:(NSString *)sf_id  forObject:(NSString *)objectName  data:(NSDictionary *)dict;
-(NSString *) getchildInfoFromChildRelationShip:(NSString * )tableName  ForChild:(NSString *)child_table  field_name:(NSString *)field_name;
-(NSString *)getParentLocalIdForChildSFID:(NSString *)childSF_Id parentObject_name:(NSString *)parentObjectName parent_column_name:(NSString *)parent_column_name child_object_name:(NSString *)child_obj_name;
-(void)updateParentColumnNameInChildTableWithParentLocalId:(NSString *)child_objectName parent_column_name:(NSString *)parent_column_name   parent_local_id:(NSString *)parent_local_id  child_sf_id:(NSString *)child_sfId;
-(NSString *)getSfid_For_LocalId_From_Object_table:(NSString *)object_name  local_id:(NSString *)local_id;
-(NSString *)getSfid_For_LocalId_FROM_SfHeapTable:(NSString *)local_id ;
-(BOOL)IsChildObject:(NSString *)object_name;
-(BOOL)DeleterecordFromTable:(NSString *)object_name Forlocal_id:(NSString *)local_id;
-(void)insertSyncConflictsIntoSYNC_CONFLICT:(NSMutableDictionary *)conflictDict;
-(BOOL)DoesTrailerContainTheRecord:(NSString *)local_id  operation_type:(NSString *)operation_type  object_name:(NSString *)object_name;

//Shrinivas
-(NSString *) selectLocalIdFrom:(NSString *)tablename WithId:(NSString *)SFId andParentColumnName:(NSString *)parent_column_name andSyncType:(NSString *)syncType;

-(NSMutableArray *)getAllRecordsFromConflictTableForOperationType:(NSString *)operation_type  overrideFlag:(NSString *)override_flag_value;

-(NSString *) getParentIdFrom:(NSString *)tablename WithId:(NSString *)Id_ andParentColumnName:(NSString *)parent_column_name id_type:(NSString *)id_type;

-(void)PutconflictRecordsIntoHeapFor:(NSString *)sync_type override_flag:(NSString *)override_flag_value;

-(NSString *)getSfid_For_LocalId_From_TrailerForlocal_id:(NSString *)local_id;
-(NSMutableArray *)getAllRecordsFromConflictTableForOperationType:(NSString *)operation_type ;
- (void) deleteAllrecordsWithSF_ID:(NSMutableDictionary *)delete_list;
-(void) DeleterecordFromTableWithSf_Id:(NSString *)object_name sf_id:(NSString *)sf_id withColumn:(NSString *)columnName;

-(void) deleteAll_GET_DELETES_And_PUT_DELETE_From_HeapAndObject_tables:(NSString *)sync_type ;
-(void)deleteAllConflictedRecordsFrom:(NSString *)tableName;

-(BOOL)getConflictsStatus;
-(void)deleterecordsFromConflictTableForOperationType:(NSString *)opeation_type overrideFlag:(NSString *)override_flag  table_name:(NSString *)table_name   id_value:(NSString *)id_   field_name:(NSString *)field_name;

//-(BOOL)DoesConflictContainTheRecord:(NSString *)local_id  operation_type:(NSString *)operation_type  object_name:(NSString *)object_name;//  Unused Methods

-(NSMutableDictionary *)getValidForDictForObject:(NSString *)object_name  field_api_name:(NSString *)field_api_name;

-(NSString *)getPicklistINfo_isdependentOrControllername_For_field_name:(NSString *)field_name  field_api_name:(NSString *)field_api_name   object_name:(NSString *)object_name;


-(NSMutableArray *)getAllobjectsApiNameFromSFObjectField;
-(void)fillDependencyPickListInfo;


-(BOOL)UpdateSFObjectField_For_Picklist_TypeObject:(NSString *)object_api_name field_api_name:(NSString *)field_api_name  dependent_picklist:(NSString *)dependent_value  controler_field_name:(NSString *)controler_field;

-(BOOL)UpdateSFPicklist_validFor_For_Oject_Name:(NSString *)object_name  field_api_name:(NSString *)field_api_name value:(NSString *)value  valid_for_value:(NSString *)valid_for_value  index:(int )index_value;

-(int)getIndexOfPicklistValueForOject_Name:(NSString *)object_name  field_api_name:(NSString *)field_api_name value:(NSString *)value;

-(NSMutableArray *)getAllDependentPicklistSWhenControllerValueChanged:(NSString *)object_name controller_name:(NSString*)controllername;

-(NSMutableArray *)getRecordTypeValuesForObjectName:(NSString *)object_name;

-(BOOL)checkForRTPicklistForFieldApiName:(NSString *)fieldApiName  objectApiname:(NSString *)objectApiName  recordTypeId:(NSString *)recordTypeId;

-(NSMutableArray *)getRTPicklistValuesForFieldApiName:(NSString *)field_api_name  objectApiName:(NSString *)objectApiName  recordTypeId:(NSString *)recordTypeId;
-(NSString *)getRecordTypeIdForRecordTypename:(NSString *)recorTypeName objectApi_name:(NSString *)objectApiName;

-(NSMutableArray *)getRtDependentPicklistsForObject:(NSString *)objectName recordtypeName:(NSString *)recordtypeName;
-(NSString *)getDefaultValueForRTPicklist:(NSString *)objectName recordtypeName:(NSString *)recordtypeName  field_api_name:(NSString *)field_api_name  type:(NSString *)returnField;

//Shrinivas - 02/04/2012
//Method to get the default value of RTPicklistDependency
- (NSString *) getDefaultValueForRTPicklistDependency:(NSString *)objectName recordtypeId:(NSString *)recordtypeId field_api_name:(NSString *)field_api_name;


-(NSArray *)getAllIdsFromDatabase:(NSString *)sync_type  forObjectName:(NSString *)object_name;
-(void)deleteDownloadCriteriaObjects:(NSArray *)deleted_objects;
-(NSMutableDictionary *)getAllFieldsAndItsDataTypesForObject:(NSString *)object_api_name tableName:(NSString *)tableName;

 //sahana 16th June 2012
-(NSString *) getRefernceToFieldnameForObjct:(NSString *) object_name reference_table:(NSString *)reference_table table_name:(NSString *)table_name;
//sahana
-(NSArray *) getAllObjectsFromHeap;

- (BOOL) ContinueIncrementalDataSync;
//On Demand Data
- (BOOL) checkOndemandRecord:(NSString *)local_id;
- (void) deleteAllOndemandRecordsPartOfDownloadCriteriaForSfId:(NSString *)sync_type;
//- (NSArray *) getAllIdsFromDatabaseForSyncType:(NSString *)sync_type;//  Unused Methods
- (void) updateOndemandRecordForId:(NSString *)record_id;
- (NSString *) getTimeLastModifiedTimeOfTheRecordForRecordId:(NSString *)record_id;
-(NSDictionary *)getAllChildRelationShipForObject:(NSString *)object_name;
-(BOOL)isSFObject:(NSString*)objectName;

//Update null vaue
- (NSMutableDictionary *) updateEmptyFieldValuesForDict:(NSDictionary *)dict objectName:(NSString *)objectName;
-(NSString *)getRecordTypeNameForObject:(NSString *)object_name forId:(NSString *)recordTYpeId;

//Shrinivas : method for multiselect
-(void) UpdateSFPicklistForMultiSelect_IndexValue_For_Oject_Name:(NSString *)object_name  field_api_name:(NSString *)field_api_name value:(NSString *)value  index:(int)index_value;

-(NSArray *)getEventProcessIdForProcessType:(NSString *)process_type SourceObject:(NSString *)sourceobjectName;


/* Shravya-InitialSync :InitialSync-shr */
@property(nonatomic,retain)NSMutableDictionary *objectFieldDictionary;

/* vipindas Palli*/

// Vipind-db-optmz
@property(nonatomic,retain)NSMutableDictionary *apiNameToInsertionQueryDictionary
;
@property (nonatomic, retain) NSMutableDictionary   *fieldDataTypeDictionary;
@property (nonatomic, retain) NSMutableDictionary   *childInfoDictionary;
@property (nonatomic, retain, getter = getChildObjectRegisteredDictionary) NSMutableDictionary   *childInfoCacheDictionary;


/* this is not used as of now*/
@property(nonatomic,retain)NSMutableDictionary *localIdOfFutureMasterRecords;
@property(nonatomic,retain)NSMutableDictionary *parentobjectDictionary;
@property(nonatomic,retain)NSMutableDictionary *parentColumnDictionary;

/* Shravya-InitialSync :InitialSync-shr */
- (void)insertAllRecordsToRespectiveTables:(NSMutableDictionary *)syncedData andParser:(SBJsonParser *)jsonParser;
- (void)updateTheStatusOfSynRecordsToTrue:(NSMutableDictionary *)sync_data;
- (void)updatesfmIdsOfMasterToLocalIds ;

/* Shravya-get price */
- (void)insertGetPriceRecordsToRespectiveTables:(NSMutableDictionary *)gpData andParser:(SBJsonParser *)jsonParser;
- (BOOL)updateGPTableforSFId:(NSString *)sfId  forObject:(NSString *)objectName  data:(NSDictionary *)dictionaryValue;
- (NSMutableDictionary *)getRecordsGPForRecordId:(NSString *)record_id ForObjectName:(NSString *)object_name fields:(NSString *)fields;

//Sahana Custom Aggressive Sync
//- (BOOL)ShouldTriggerCustomAggressive;//  Unused Methods
- (void)fillSyncRecordDictForRecordType:(NSString *)record_type SF_Id:(NSString *)SF_id local_id:(NSString *)local_id  operation_type:(NSString *)operation_type  final_dictionary:(NSMutableDictionary *)sync_record_dict  object_naem:(NSString *)object_name parent_object_name:(NSString *)parent_object_name parent_local_id:(NSString *)parent_local_id;
- (NSMutableDictionary * )getCustomAggressiveSyncRecordsForHearedRecord:(NSString *)header_reco_id;
- (NSArray *)getallmasterRecordsForCustomAggressiveSync;
- (BOOL)ColumnExists:(NSString *)columnname tableName:(NSString *)tableName;
- (NSMutableDictionary *)getClassNameMethodnameForHeaderLocalId:(NSString *)header_lcal_id;
-(void)insertCustomWebserviceResponse:(NSMutableArray *)records_array class_name:(NSString *)class_name method_name:(NSString *)method_name related_record_error:(BOOL)related_record_error request_id:(NSString *)request_id;
-(void)insertCustomWebserviceResponsewithError:(NSMutableArray *)error_list class_name:(NSString *)class_name method_name:(NSString *)method_name related_record_error:(BOOL)related_record_error request_id:(NSString *)request_id;
-(void)deletecustomWebservicefrom_detailTrailer_for_request_id:(NSString *)request_id table_name:(NSString *)table_name;
-(void)insertIntoConflictTable_forlocal_id:(NSString *)local_id sf_id:(NSString *)sf_id class_name:(NSString *)class_name method_name:(NSString *)method_name   error_type:(NSString *)error_type error_message:(NSString *)error_msg custom_service:(NSString *)custom_wsservice request_id:(NSString *)request_id record_type:(NSString *)record_type object_name:(NSString *)object_name operation_type:(NSString *)operation_type;
-(NSArray *)getallmasterRecordsForCustomAggressiveSyncFrom_SyncErrorTable;
-(NSMutableArray *)getAllrequestIdsWithFlag:(NSString *)flag;
-(void)deleteAllRecordsWithIgnoreTagFromConflictTable;
-(void)deleteallRecordsForRequest_ids:(NSString *)table_name request_ids:(NSString *)request_id_str;
-(NSString *)errorTypeOfrRequestId:(NSString *)request_id;
-(BOOL)doesRequestIdExistsintable:(NSString *)table_name request_id:(NSString *)request_id error_type:(NSString *)error_type;
-(BOOL)ContinueIncrementalDataSync_forNoncustomRecords;

-(BOOL)DoesTrailerContainTheRecordForSf_id:(NSString *)sf_id  operation_type:(NSString *)operation_type  object_name:(NSString *)object_name;
-(void)deleteCustomWebserviceEntriesFromSyncHeap:(NSMutableArray *)custom_entries;


//Sync_Override : Radha
- (BOOL) checkIfCustomEntryExistsInTrailerTable:(NSString *)parentLocalId;
-(BOOL)doesIdexistsinSyncrecord:(NSDictionary *)sync_record new_local_id:(NSString *)new_id idType:(NSString *)id_type;

// Vipind-db-optmz
- (void)deleteRecordFromTable:(NSString *)tableName byCollectionsOfId:(NSArray *)ids forColumn:(NSString *)columnName;
- (void)clearChildInfoCacheDictionary;

//sahana child sfm
-(NSString *)getProcessSfIdForProcess_uniqueName:(NSString *)process_id;
//-(NSString *)getProcessNameForProcessSfId:(NSString *)process_sf_id;//  Unused Methods
-(NSString *)getProcessNodeIdForLayoutId:(NSString *)layout_id process_id:(NSString *)preocess_unique_id;
-(NSArray *)getLinkedProcessIdsForProcess_node_id:(NSString *)Processnode_id  process_sf_id:(NSString *)process_sf_id;
-(NSArray *)getAllProcessId_forProcess_sf_id:(NSArray *)process_sf_id;
-(NSString *)getObjectNameForProcessId:(NSString *)process_id;

/*Shra-lookup starts*/
- (NSMutableArray *)getAllSearchCriteriaForId:(NSString *)namedSearchId andFilterType:(NSString *)filterType;
- (NSArray *)getLookupfiltersForNamedSearchId:(NSString *)namedSearchId andfilterType:(NSString *)filterType;
- (NSArray *)getFilterStringArrayForAdvancedFilters:(NSArray *)filters;
//- (NSArray *)getIdsFromObjectName:(NSString *)objectName withCriteria:(NSString *)criteria andFieldName:(NSString *)fieldName;//  Unused Methods
- (NSString *)queryForExpressionComponent:(NSString *)expression expressionId:(NSString *)expression_id object_name:(NSString *)object_name;
- (NSString *)getAdvanceExpressionComponentExpressionId:(NSString *)expressionId ;
- (NSString *)getPreFilters:(NSArray *)preFilters;
- (NSString *)getUserNameofLoggedInUser;
- (NSString*)getNameFieldForObject:(NSString*)objectName;
- (NSInteger)getFieldCountForObject:(NSString*)objectName ;
- (NSString *)getValueForField:(NSString *)fieldName
                    objectName:(NSString *)objectName
                      recordId:(NSString *)localId
                 andWhereField:(NSString *)whereField;
- (NSString *)getFieldValueForFieldName:(NSString *)fieldName
                     fromHeaderSections:(NSDictionary *)headerDictionary
                            andRecordId:(NSString *)recordId;
- (NSString *)getFieldValueForFieldName:(NSString *)fieldName fromDetailsDictionary:(NSDictionary *)detailDictionary andRecordId:(NSInteger )recordIndex;
- (NSString *)getLiteralValue:(NSString *)literalValue;

//Sahana - CURRENTRECORD literal support
-(void)replaceCurrentRecordOrheaderLiteral:(NSMutableDictionary * )RecordDict headerRecordId:(NSString *)headerRecordId headerObjectName:(NSString *)headerObjectNAme currentRecordId:(NSString *)currentRecordId currentObjectName:(NSString *)currentObjectName;
-(NSString *)getValueForField:(NSString *)fieldName objectName:(NSString *)objectName recordId:(NSString *)localId;

//Sahana - ChildSfm
-(NSMutableDictionary *)getReferenceToForObjectapiName:(NSString *)objectApiName;
- (BOOL)checkRecordExistForObject:(NSString *)tableName LocalId:(NSString *)LocalId;
-(BOOL)checkSentFlagForReferenceId:(NSString *)loalId forOperation:(NSString *)OperationType;
-(void)deleteRecordFromConflictTableForRecord:(NSString *)local_id operation:(NSString *)operationType;
-(BOOL)DeleterecordFromDataTrailerTableForlocal_id:(NSString *)local_id;
//-(BOOL)DoesEntryExistsForInsertOperationForLocalId:(NSString *)localId;//  Unused Methods
-(BOOL)DeleteEntryFromDataTrailerTableFor:(NSString *)Id forObject:(NSString *)object  sync_type:(NSString *)sync_type fieldName:(NSString *)fieldName;
-(void)replaceCURRENTRECORDLiteral:(NSMutableDictionary *)detailDict sourceDict:(NSDictionary *)sourceDict;
-(BOOL)findLiteral:(NSString *)FieldValue literal:(NSString *)literal;
-(NSString *)getFieldApiNameFromString:(NSString *)valueString forLiteral:(NSString *)literal;

//Aparna: FORMFILL
- (NSArray *)objectMappingComponentInfoForMappingId:(NSString *)mappingId;
- (NSDictionary *)recordsToUpdateForObjectId:(NSString *)objectId
                                   mappingId:(NSString *)mappingId
                                  objectName:(NSString *)objName;

//OUTPUT docs Entry criteria : 8166
- (NSArray *) getExpressionIdsForOPDocForProcessId:(NSString *)processId;


/*Shra-lookup*/

//Changes for optimized sync - One Call sync
- (NSInteger) getCountOfRecordsFromSyncRecordsHeap;
//8282
- (NSMutableDictionary *)getRecordForSfId:(NSString *)sfId andTableName:(NSString *)tableName;
- (void)reInsertDeletedRecordsOnConflict;


//Shravya-attachements
- (NSMutableArray *) getAllOPDocsHtmlFiles;



- (NSString *)getRecordFromDataTrailerTableForSFId:(NSString *)sfid
                                       withLocalId:(NSString *)localId
                                     andObjectName:(NSString *)objectName;
- (void)insertRecordToRespectiveTableWithSfid:(NSString *)sfid
                           withDataDictionary:(NSDictionary *)dataDictionary
                               withObjectName:(NSString *) objectApiName;
-(BOOL)updateExistingRecordforSFId:(NSString *)sfId
                         forObject:(NSString *)objectName
                              data:(NSDictionary *)dataDictionary
                andFieldDictionary:(NSDictionary *)fieldDictionary;


//4850
- (NSArray *)sourceUpdatesConfigurationForProcessId:(NSString *)processId andSettingId:(NSString*)settingId;
- (void)updateRecord:(NSString *)localId ofObject:(NSString *)objectName andFieldDictionary:(NSDictionary *)fieldDictionary;


//SUCCESSIVE_SYNC
-(BOOL)ShouldRecordRespectSuccessiveSync:(NSString *)TargetId objectName:(NSString *)objectName headerRecordId:(NSString *)headerRecordId operationType:(NSString *)operationType;
- (void)updateSuccessiveSyncRecordsAfterTxFetch;
- (void)overrideResponseData:(NSMutableDictionary*)responseDictionary ForsfId:(NSString *)sfId ObjectName:(NSString *)objectname;
- (BOOL)removeSuccessiveSyncModelForLocalId:(NSString*)localId;
- (SuccessiveSyncModel*)getSuccessiveSyncModelForLocalId:(NSString*)localId;
- (void)addSuccessiveSyncModel:(SuccessiveSyncModel*)inSuccSyncObj forLocalId:(NSString*)localId;
-(void)successiveSyncEntryForLocalId:(NSString *)localId sfId:(NSString *)sfId operation:(NSString *)operation recordType:(NSString *)recordType  objName:(NSString *)objectName_ parentObjName:(NSString *)parentObjName parentLocalId:(NSString *)parentlocalId headerLocalId:(NSString *)headerLocalId syncType:(NSString *)syncType_ dataDict:(NSMutableDictionary *)dataDict syncFlag:(NSString *)syncFlag valuemapping:(BOOL)mappingCount
;
-(SuccessiveSyncModel *)makeSuccessiveSyncObjectWithLocalId:(NSString *)localId sfId:(NSString *)sfId operation:(NSString *)operation recordType:(NSString *)recordType  objName:(NSString *)objectName_ parentObjName:(NSString *)parentObjName parentLocalId:(NSString *)parentlocalId headerLocalId:(NSString *)headerLocalId syncType:(NSString *)syncType_ dataDict:(NSMutableDictionary *)dataDict syncFlag:(NSString *)syncFlag;

//9778
-(NSMutableArray *)getSortedRTPicklistValues:(NSArray *)picklistValues fieldApiName:(NSString *)field_api_name  objectApiName:(NSString *)objectApiName;

//10900
-(BOOL)DeleteUpdateRecordFromTable:(NSString *)object_name Forlocal_id:(NSString *)local_id;

#define CURRENTRECORD                       @"SVMX.CURRENTRECORD"
#define CURRENTRECORD_HEADER                @"SVMX.CURRENTRECORDHEADER"
#define SVMX_USER_TRUNK                     @"SVMX.USERTRUNK"

//Krishna CONTEXTFILTER
#define CURRENTRECORD_CONTEXTFILTER         @"CURRENT_RECORD"

#define SERVER_OVERRIDE                     @"Server_Override"
#define CLIENT_OVERRIDE                     @"Client_Override"
#define UNDO                                @"Undo"
#define NONE                                @"None"
#define RETRY								@"retry"

#define SYNC_ERROR_CONFLICT                 @"sync_error_conflict"
#define SFDATATRAILER_TEMP                  @"SFDataTrailer_Temp"
#define SFDATATRAILER                       @"SFDataTrailer"
#define SYNC_RECORD_HEAP                    @"sync_Records_Heap"
#define SFPicklist                          @"SFPickList"
#define SFOBJECTFIELD                       @"SFObjectField"
#define SF_REFERENCE_TO                     @"SFReferenceTo"
#define SFPROCESS                           @"SFProcess"
#define SFOBJECT                            @"SFObject"
#define SFOBJECTFIELD                       @"SFObjectField"
#define SFChildRelationShip                 @"SFChildRelationship"
#define SFRecordType                        @"SFRecordType"
#define SFEXPRESSION                        @"SFExpression"
#define SFEXPRESSION_COMPONENT              @"SFExpressionComponent"
#define SFCONFIG_DATA_TABLE                 @"Config_data_table"


#define SFWIZARD                            @"SFWizard"
#define SFWizard_COMPONENT                  @"SFWizardComponent"

#define SFW_WIZARD_ID                       @"wizard_id"
#define SFW_ACTION_ID                       @"action_id"
#define SFW_EXPRESSION_ID                   @"expression_id"
#define SFW_PROCESS_ID                      @"process_id"
#define SFW_ACTION_TYPE                     @"action_type"
#define SFW_ACTION_DESCRIPTION              @"action_description"
#define SFW_ENABLE_ACTION_BUTTON            @"enable_action_button"

//three more buttons added
#define PERFORM_SYNC                        @"perform_sync"
#define CLASS_NAME                          @"class_name"
#define METHOD_NAME                         @"method_name"

#define SFW_WIZARD_INFO                     @"sfw_wizard_info"
#define SFW_WIZARD_BUTTONS                  @"sfw_wizard_button"

#define SFOBJMAPPING_SOURCE_FIELD          @"SOURCE_FIELD_NAME"
#define SFOBJMAPPING_TARGET_FIELD          @"TARGET_FIELD_NAME"
#define SFOBJMAPPING_MAPPINGVALUE_FLAG     @"MAPPING_VALUE_FLAG"
#define SFOBJMAPPING_MAPPING_VALUE         @"MAPPING_VALUE"
#define SFOBJMAPPING_COMPONENT_TYPE        @"MAPPING_COMPONENT_TYPE"
#define SOURCE_LOCAL_ID                    @"source_local_id"



//from Ofline Globles

#define PROCESS_COMPONENT           @"SFProcessComponent"
#define OBJECT_MAPPING              @"SFObjectMapping"
#define OBJECT_MAPPING_COMPONENT    @"SFObjectMappingComponent"


#define SOURCE_CHILD_PARENT_COLUMN   @"source_child_parent_column"
#define EXPRESSION_ID               @"expression_id"
#define OBJECT_MAPPING_ID           @"object_mapping_id"
#define SOURCE_OBJECT_NAME          @"source_object_name"
#define TARGET_OBJECT_NAME          @"target_object_name"
#define PARENT_COLUMN_NAME          @"parent_column"
#define VALUE_MAPPING_ID            @"value_mapping_id"
#define PROCESS_COMPONENT_SFID      @"sfID"

#define VALUE_MAPPING                @"VALUEMAPPING"
#define FIELD_MAPPING                @"FIELDMAPPING"


#define TODAY_DATE                   @"TODAY"
#define TOMOROW_DATE                 @"TOMORROW"
#define YESTERDAY_DATE               @"YESTERDAY"


#define WIZARD_ID                    @"wizard_id"
#define EXPRESSION_ID                @"expression_id"
#define WIZARD_DESCRIPTION           @"wizard_description"
//RADHA
#define WIZARD_TITLE                 @"wizard_name"
#define WIZARD_SEQUENCE              @"wizard_row_column" //9366 - Defect Fix

#define TARGET                        @"TARGET"
#define TARGETCHILD                   @"TARGETCHILD"

#define SFNAMEDSEARCH                 @"SFNamedSearch"
#define SFNAMEDSEARCHCOMPONENT        @"SFNamedSearchComponent"

#define LOOK_UP_FIELDNAME             @"field_name"
#define LOOK_UP_SEARCH_ID             @"named_search"
#define SEARCH_OBJECT_FIELD_TYPE      @"search_object_field_type"
#define LOOK_UP_SEQUENCE              @"sequence"
#define LOOK_UP_FIELD_TYPE            @"field_type"
#define LU_FIELD_RELATED_TO           @"field_relationship_name"
#define LOOKUP_DEFAULT_LOOK_UP_CLMN   @"default_lookup_column"
#define LOOKUP_OBJECT_NAME            @"object_name"
#define LOOkUP_IS_DEFAULT             @"is_default"
#define LOOKUP_IS_STANDARD            @"is_standard"
#define LOOKUP_RECORDS_LIMIT          50            //6533 TEMPORARY FIX FOR CUSTOM/STANDARD LOOKUP QUERY LIMIT


//VALUE MAPPING THINGS 
#define MACRO_TODAY                  @"Today"      //@"TODAY"
#define MACRO_TOMMOROW               @"Tomorrow"   //@"TOMMOrROW"
#define MACRO_YESTERDAY              @"Yesterday"  //@"YESTERDAY"

#define MACRO_NOW                    @"Now"        //@"NOW"
#define MACRO_CURRENTUSER            @"CURRENTUSER" // @"CURRENTUSER"
#define MACRO_RECORDOWNER            @"RECORDOWNER"

#define MASTER                       @"MASTER"
#define DETAIL                       @"DETAIL"
#define INSERT                       @"INSERT"
#define UPDATE                       @"UPDATE"
#define DELETE                       @"DELETE"

#define PUT_INSERT                   @"PUT_INSERT"
#define GET_INSERT                   @"GET_INSERT"
#define PUT_UPDATE                   @"PUT_UPDATE"
#define GET_UPDATE                   @"GET_UPDATE"
#define PUT_DELETE                   @"PUT_DELETE"
#define GET_DELETE                   @"GET_DELETE"


//sahana dowload citeria 
#define GET_INSERT_DOWNLOAD_CRITERIA  @"GET_INSERT_DOWNLOAD_CRITERIA"
#define GET_UPDATE_DOWNLOAD_CRITERIA  @"GET_UPDATE_DOWNLOAD_CRITERIA"
#define GET_DELETE_DOWNLOAD_CRITERIA  @"GET_DELETE_DOWNLOAD_CRITERIA"

//Radha - //Changes for optimized sync - One Call sync
#define GET_DELETE_DC_OPTIMZED		  @"GET_DELETE_DC_OPTIMZED"
#define GET_INSERT_DC_OPTIMZED		  @"GET_INSERT_DC_OPTIMZED"
#define GET_UPDATE_DC_OPTIMZED		  @"GET_UPDATE_DC_OPTIMZED"



#define DEPENDENT_PICKLIST       @"dependent_picklist"
#define CONTROLLER_FIRLD         @"controler_field"
#define VALID_FOR                @"valid_for"


#define INSERTION_TYPE           @"insertion_type"
#define LOCAL_UPDATE_TYPE        @"local_update_type"
#define ONLINE_UPDATE_TYPE       @"online_upadte_type"



#define cw_local_id              @"LOCAL_ID"
#define cw_json_record           @"JSON_RECORD"
#define cw_sf_id                 @"SF_ID"
#define cw_operation_type        @"OPERATION_TYPE"
#define cw_record_type           @"RECORD_TYPE"
#define cw_object_name           @"OBJECT_NAME"
#define cw_custom_error_type     @"custom_error_type"
#define cw_parent_colmn_name     @"PARENT_COLUMN_NAME"
#define cw_header_obj_name       @"HEADER_OBJECT_NAME"
#define cw_error_mesg            @"ERROR_MSG"
#define cw_error_type            @"ERROR_TYPE"


#define CHILD_SFM                @"CHILD_SFM"

#define EVENT_REFERENCE_PLIST    @"EVENT_REFERENCE_PLIST.plist"

//Aparna: Source Update
#define SVMX_CURRENTUSER               @"SVMX.CURRENTUSER"
#define SVMX_OWNER                     @"SVMX.OWNER"


@end

@protocol databaseInterfaceProtocol <NSObject>

@optional
-(void)displayALertViewinSFMDetailview:(NSString *)excp_message;

@end
