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

@interface databaseIntefaceSfm : NSObject
{
    sqlite3 * db;
   
}

-(NSString *) filePath:(NSString *)dataBaseName;
-(void)openDB:(NSString *)dataBaseName;

//method to  get the processInfo ( page layout information) 
-(NSMutableDictionary *)queryProcessInfo:(NSString * )Process_id  object_name:(NSString *)object_name;

//method to get the header data from the header Object name table
-(NSMutableDictionary *)queryTheObjectInfoTable:(NSMutableArray *)api_names tableName:(NSString *)tableName object_name:(NSString * ) objectName;

-(NSMutableDictionary *)queryDataFromObjectTable:(NSMutableArray *)api_names tableName:(NSString *)tableName record_id:(NSString *) recordId expression:(NSString *)expression;
//method to get the line data from lines table
-(NSMutableArray *)queryLinesInfo:(NSMutableArray *)apiNames  detailObjectName:(NSString *)detailObjectName headerObjectName:(NSString *)headerObjectName detailaliasName:(NSString *)detailsAliasName headerRecordId:(NSString *)record_id expressionId:(NSString *)expression_id;

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

-(NSMutableDictionary *)getValueMappingForlayoutId:(NSString *)layoutId process_id:(NSString *)processId objectName:(NSString *)objectName;

-(NSMutableDictionary *)getObjectMappingForMappingId:(NSMutableDictionary *)process_components mappingType:(NSString *)mapping_type;

-(NSMutableDictionary *)getAllObjectFields:(NSString *)objectName tableName:(NSString *)tableName;

-(BOOL)insertdataIntoTable:(NSString *)tableName data:(NSMutableDictionary *)valuesDict;

-(NSString *)getTheRecordIdOfnewlyInsertedRecord:(NSString *)tableName;

-(NSMutableDictionary *)getDataForMultiAdd:(NSString *)object_name searchField:(NSString *)search_field;

//get the lookup information from database 
- (NSDictionary *) getLookupDataFromDBWith:(NSString *)lookupID referenceTo:(NSString *)object;

-(NSString *)queryForExpression:(NSString *)expression_id;
-(NSString *) queryForExpressionComponent:(NSString *)expression expression_id:(NSString *)expression_id;

-(NSString *)getTheDefaultDisplayColumnForLookUpId:(NSString *)lookup_id;

//Action Buttons Information - SFW
-(NSMutableArray *)getButtonsForWizardInformation:(NSMutableArray *)wizard_ids_array  record_id:(NSString *)record_id  object_name:(NSString *)objectName;
-(NSMutableDictionary *) getWizardInformationForObjectname : (NSString *) objectName  record_id:(NSString *)record_id;

#define SFPicklist                          @"SFPicklist"
#define SFOBJECTFIELD                       @"SFObject_Field"
#define SF_REFERENCE_TO                     @"sf_reference_to"
#define SFPROCESS                           @"SFProcess"
#define SFOBJECT                            @"SFObject"
#define SFOBJECTFIELD                       @"SFObject_Field"
#define SFChildRelationShip                 @"SFChildRelationship"
#define SFRecordType                        @"SFRecordType"
#define SFEXPRESSION                        @"SFExpression"
#define SFEXPRESSION_COMPONENT              @"SFExpression_component"
#define SFCONFIG_DATA_TABLE                 @"Config_data_table"


#define SFWIZARD                            @"SFWizard"
#define SFWizard_COMPONENT                  @"SFWizard_component"

#define SFW_WIZARD_ID                       @"wizard_id"
#define SFW_ACTION_ID                       @"action_id"
#define SFW_EXPRESSION_ID                   @"expression_id"
#define SFW_PROCESS_ID                      @"process_id"
#define SFW_ACTION_TYPE                     @"action_type"
#define SFW_ACTION_DESCRIPTION              @"action_description"
#define SFW_ENABLE_ACTION_BUTTON            @"enable_action_button"

#define SFW_WIZARD_INFO                     @"sfw_wizard_info"
#define SFW_WIZARD_BUTTONS                  @"sfw_wizard_button"

@end
