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
@class iServiceAppDelegate;
@interface databaseIntefaceSfm : NSObject
{
    //RADHA
    id MyPopoverDelegate;
    
    //sqlite3 * db;
    iServiceAppDelegate * appDelegate;
}

@property (nonatomic, retain) id MyPopoverDelegate;

-(NSString *) filePath:(NSString *)dataBaseName;

//method to  get the processInfo ( page layout information) 
-(NSMutableDictionary *)queryProcessInfo:(NSString * )Process_id  object_name:(NSString *)object_name;

//method to get the header data from the header Object name table
-(NSMutableDictionary *)queryTheObjectInfoTable:(NSMutableArray *)api_names tableName:(NSString *)tableName object_name:(NSString * ) objectName;

-(NSMutableDictionary *)queryDataFromObjectTable:(NSMutableArray *)api_names tableName:(NSString *)tableName record_id:(NSString *) recordId expression:(NSString *)expression;
//method to get the line data from lines table
-(NSMutableArray *)queryLinesInfo:(NSMutableArray *)apiNames  detailObjectName:(NSString *)detailObjectName headerObjectName:(NSString *)headerObjectName detailaliasName:(NSString *)detailsAliasName headerRecordId:(NSString *)record_id expressionId:(NSString *)expression_id parent_column_name:(NSString *)parent_column;

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
-(NSString *)findTheTypeofTheRecordFromRecordTypeIdTable:(NSString *)tableName record_typeId:(NSString *)record_type_id objectOrLineApiName:(NSString *)apiName;

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

-(NSMutableDictionary *)getDataForMultiAdd:(NSString *)object_name searchField:(NSString *)search_field;

//get the lookup information from database 
- (NSDictionary *) getLookupDataFromDBWith:(NSString *)lookupID referenceTo:(NSString *)object searchFor:(NSString *)searchForString;

-(NSString *)queryForExpression:(NSString *)expression_id;
-(NSString *) queryForExpressionComponent:(NSString *)expression expression_id:(NSString *)expression_id;

-(NSString *)getTheDefaultDisplayColumnForLookUpId:(NSString *)lookup_id;

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

-(void) insertdataIntoTrailerTableForRecord:(NSString *)local_id SF_id:(NSString *)sf_id record_type:(NSString *)record_type operation:(NSString *)operation object_name:(NSString *)object_name  sync_flag:(NSString *)sync parentObjectName:(NSString *)parentObjectName parent_loacl_id:(NSString *)parent_local_id ;
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

//-(BOOL)DoesConflictContainTheRecord:(NSString *)local_id  operation_type:(NSString *)operation_type  object_name:(NSString *)object_name;

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


#define SERVER_OVERRIDE                     @"Server_Override"
#define CLIENT_OVERRIDE                     @"Client_Override"
#define UNDO                                @"Undo"
#define NONE                                @"None"

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

#define VALUE_MAPPING                @"VALUEMAPPING"
#define FIELD_MAPPING                @"FIELDMAPPING"


#define TODAY_DATE                   @"TODAY"
#define TOMOROW_DATE                 @"TOMORROW"
#define YESTERDAY_DATE               @"YESTERDAY"


#define WIZARD_ID                    @"wizard_id"
#define EXPRESSION_ID                @"expression_id"
#define WIZARD_DESCRIPTION           @"wizard_description"

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


//VALUE MAPPING THINGS 
#define MACRO_TODAY                  @"TODAY"      //@"TODAY"
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


#define DEPENDENT_PICKLIST       @"dependent_picklist"
#define CONTROLLER_FIRLD         @"controler_field"
#define VALID_FOR                @"valid_for"

@end
