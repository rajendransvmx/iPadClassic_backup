//
//  CalendarDatabase.h
//  iService
//
//  Created by Pavamanaprasad Athani on 06/12/11.
//  Copyright (c) 2011 Bit Order Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sqlite3.h>

@class iServiceAppDelegate;
@interface CalendarDatabase : NSObject
{
    NSString *dbFilePath;
    NSMutableArray *resultArray;
 
    NSDictionary * ExpensesDictionary;
    NSMutableArray * Parts, * Expenses, * Labor, * reportEssentials;
    NSMutableString * settingInfoId;
    NSMutableArray * settingsInfoArray, * settingsValueArray;
    NSString * ActiveGloProInfoId;
    NSString *rate;
    NSString * objectApiName;
    
    iServiceAppDelegate * appDelegate;
    
    BOOL groupCostsPresent;
    BOOL calculateLaborPrice;
    BOOL settingsPresent;
    
}

@property (nonatomic, retain) NSString *dbFilePath;
//@property (nonatomic, retain) NSString *whatId1;
//@property (nonatomic, retain) NSString *subject;

- (NSString *) getNameFieldForEventLocal_id:(NSString *)eventId;
- initWithDBName;
//- (BOOL) isUsernamePresent:(NSString *)username password:(NSString *)passWord;

//sahana  SIgnature change
-(NSString *)getRecordoperationTypeforSignaturewithRecordId:(NSString *)recordId  objectApiNAme:(NSString *)apiname;
-(NSString *)getOperationTypeForSignature:(NSString *)recordId  forObject:(NSString *)object_name;


- (NSMutableArray*) getProcessFromDatabase;
//- (NSMutableArray*) getViewLayoutsFromDB;
- (NSMutableArray*) GetEventsFromDBWithStartDate:(NSString*)startdate endDate:(NSString*)endDate;
- (NSMutableArray*) didGetTaskFromDB:(NSString *)_date;
- (BOOL) insertTasksIntoDB:(NSArray *)_tasks WithDate:(NSString*)_date local_id:(NSString *)local_id;
- (void) updateMovedEventWithStartTime:(NSString *)_startDT EndDate:(NSString *)_endDT RecordID:(NSString *)_recordId event_localId:(NSString *)event_LocalId;
//- (BOOL) isWorkOrder:(NSString *)__whatId;
- (NSString *)getColorCodeForPriority:(NSString *)whatId objectname:(NSString *)objectName;
- (void)deleteTaskFromDB:(NSString *)taskId;
- (NSString *)getTableName:(NSString *)key;
- (NSString *) retreiveCurrentTaskIdCreated;

//28/Sep/2012 - ADD objectname
- (NSString *) getPriorityForWhatId:(NSString *)whatId  objectname:(NSString *)objectName;

//radha and abinash
//- (BOOL) isCase:(NSString *)whatId;

//28/Sep/2012
- (BOOL) isWorkOrderOrCase:(NSString *)whatId objectName:(NSString *)_ObjectName;


- (NSString *) getTableNameForWhatId:(NSString *)whatId;
//ServiceReportEssentialMethods
//Abinash
- (NSString *) getNameFieldForTableName:(NSString *)tableName;
- (NSString *) getNameFieldForEvent:(NSString *)eventId;



- (NSMutableArray *)getreferncetableFieldsForReportEsentials:(NSMutableArray *)array;
- (NSMutableArray *)getReportEssentials:(NSString *) record_id;
- (NSMutableString *) removeDuplicatesFromSOQL:(NSString *)soql withString:(NSString *)_query;
- (void) getAllReferenceFields:(NSArray *)fields_array;
- (NSString *)getNameField:(NSString *)SVMXC__Product__c;
- (NSMutableArray *) queryForParts:(NSString *)currentRecordId;
- (NSMutableArray *) queryForExpenses:(NSString *)currentRecordId;
- (NSMutableArray *) queryForLabor:(NSString *)currentRecordId;
- (void) startQueryConfiguration;
- (NSString *) getNameFieldForCreateProcessFromDB:(NSString *)ID;


//Shrinivas - TroubleShooting
- (NSData *) selectTroubleShootingDataFromDBwithID:(NSString *)docID andName:(NSString *)name;
- (void) insertTroubleShootDataInDB:(NSData *)troubleShootData WithId:(NSString *)docID  andName:(NSString *)productName andProductId:(NSString *)productId;
- (NSString *) getProductNameFromDbWithID:(NSString *)productId;
- (void) insertProductName:(NSMutableArray *)productInfo WithId:(NSString *)productId;
- (NSMutableArray *)getTroubleShootingForProductName:(NSString *)productString;

//Latest Troubleshooting methods
- (void) updateProductTableWithProductName:(NSString *)Name WithId:(NSString *)productId;
- (void) insertTroubleshootingIntoDB:(NSMutableArray *)troubleshooting;
- (void) insertTroubleShoot:(NSMutableArray *)troubleshooting Body:(NSString *)Body;

//Shrinivas - Chatter
- (void) insertChatterDetailsIntoDBForWithId:(NSString *)productId andChatterDetails:(NSMutableArray *)chatterDetails;
- (void) insertImageDataInChatterDetailsForUserName:(NSString *)UserName WithData:(NSData *)imageData;;
- (NSMutableArray *) retrieveChatterPostsFromDBForId:(NSString *)productId;
- (NSData *) getImageDataForUserName:(NSString *)userName;
- (void) insertProductPicture:(NSString *)pictureData ForId:(NSString *)productId;
- (NSData *) getProductPictureForProductId:(NSString *)productId;

//Shrinivas - ProductManual
- (void) insertProductManualNameInDB:(NSDictionary *)manualInfo WithID:(NSString *)productID;
- (void) insertProductManualBody:(NSString *)manualBody WithId:(NSString *)ManId WithName:(NSString *)ManName;
- (NSMutableArray *) retrieveManualsForProductWithId:(NSString *)productId;
- (NSData *) retrieveProductManualWithManID:(NSString *)Id andManName:(NSString *)ManName;


//radha - Signature Controller
- (void) insertSignatureData:(NSData *)signatureData WithId:(NSString *)signatureId RecordId:(NSString *)recordId                  apiName:(NSString *)oApiName WONumber:(NSString *)WONumber flag:(NSString *)sign_type;
- (NSData *) retreiveSignatureimage:(NSString *)WONumber recordId:(NSString *)recordId;
- (void) deleteSignature:(NSString *)WONumber;
- (void) deleteAllSignatureData:(NSString *) operationType;
//shrinivas
- (void) getSFIdForSignature:(NSString *)localId objectName:(NSString *)objectName;   //Method to be called only after Data Sync 
- (void) retrieveSignatureFromSFDC:(NSString *)ID;
- (void) writeSignatureToSFDC:(NSString *)SFId;
- (void) getAllLocalIdsForSignature:(NSString *)operation_type;

- (void) deletePDFF;

- (NSString *) getProductIdForName:(NSString *)productName;
- (NSString *) getNameForSignature:(NSString *)objectName andId:(NSString *)recordId;
- (NSString *) getObjectLabel:(NSString *)objectName;


//Shrinivas PDF - SFDC
- (void) insertPDFintoDB:(NSString *)pdf WithrecordId:(NSString *)record_Id apiName:(NSString *)apiname WOnumber:(NSString *)WO_number;
- (void) getAllLocalIdsForPDF;
- (void) getSFIdForPDF:(NSString *)localId objectName:(NSString *)objectName;
- (void) writePDFToSFDC:(NSString *)SFId;
- (NSString *) getSFIdForlocalId:(NSString *)localId;
- (void) deletePDFFromDBWithId;
- (BOOL) isSignatureExists:(NSString *)local_id type:(NSString *)sign_type tableName:(NSString *)tableName;

//Radha Tuesday 27th December
- (BOOL) isUsernameValid:(NSString *)userName;


//Shrinivas - Data Sync UI methods
- (NSMutableArray *) getConflictObjects;
- (NSMutableArray *) getrecordIdsForObject:(NSString *)objectName;
- (void) updateOverrideFlagWithObjectName:(NSString *)objectName andSFId:(NSString *)SFId WithStatus:(NSString *)status;
- (NSString *) getLabelForObject:(NSString *)objectName;
- (void) selectUndoneRecords;
- (void) deleteUndonerecordsWithId:(NSString *)ID andObjectName:(NSString *)objectname forField:(NSString *)field_name;
- (NSString *)getnameFieldForObject:(NSString *)objectName WithId:(NSString *)SFId WithApiName:(NSString *)api_name;
- (NSString *)getOverrideFlagStatusForId:(NSString *)Id;


//Shrinivas - Contact Image offline Methods
- (void)insertContactImageIntoDatabase:(NSString *)contactId andContactImageData:(NSString *)imageData;

- (NSString *)retrieveContactImageDataFromDb:(NSString *)contactId;
- (NSString *)getFieldValueFromTable:(NSString *)field_name;
- (NSString *)getValueFromLookupwithId:(NSString *)Id;


//Radha
- (NSData *) retrievePdfData:(NSString *)Id;


//Shrinivas -- Sync conflict Internet handler
- (void) insertIntoConflictInternetErrorWithSyncType:(NSString *)sync_type;
- (void) insertIntoConflictInternetErrorForMetaSync:(NSString *)sync_type WithDB:(sqlite3 *)db;
- (NSMutableArray *) getInternetConflicts;
//- (NSMutableArray *) getInternetConflictsForMetaSyncWithDB:(sqlite3 *)db;
- (void) removeInternetConflicts;


//Shrinivas --- Status for Meta Sync
-(void) insertMetaSyncStatus:(NSString *)status WithDB:(sqlite3 *)db;
-(NSString *) retrieveMetaSyncStatus;


//Shrinivas 
- (NSString *) getApi_NameWithReference:(NSString *)reference_to;
- (BOOL) selectCountFromSync_Conflicts;


//Sorting the PickList Array using indexes.
-(NSArray *) sortPickListUsingIndexes:(NSArray *)pickListArray WithfieldAPIName:(NSString *)fieldAPIName tableName:(NSString *)_SFPicklist objectName:(NSString *)headerObjName;

/* GET_PRICE_JS-shr*/
- (NSArray *)getPriceBook:(NSDictionary *)currentContext;
- (void)fillUpContractInformationInTheTargetArray:(NSMutableArray *)priceBookArray
                                    andContractId:(NSString *)SVMXC__Service_Contract__c
                                      andCurrency:(NSString *)currencyCode
                          andNamedExpressionArray:(NSMutableArray *)namedExpressionArray
                                    andIdOffering:(NSString *) idOfServiceOffering
                                       andCovered:(NSString *)idServiceCovered;
- (NSString *)getPricebookInformationForSettingId:(NSString *)settingId ;
- (NSDictionary *)getRecordTypeIdsForRecordType:(NSArray *)recordTypes;
- (NSDictionary *)getEntitlementHistoryForWorkorder:(NSString *)workOrderId;
- (NSString *)getConcatenatedStringFromArray:(NSArray *)arayOfString withSingleQuotesAndBraces:(BOOL)isRequired ;
- (NSDictionary *)getAllFieldsOfTable:(NSString *)tableName;
- (NSDictionary *)preparePBForSettings:(NSString *)estimateValue andUsageValue:(NSString *)usageValue andKey:(NSString *)key andRecordTypeId:(NSDictionary *)recordTypeIds;
- (NSMutableDictionary *)getRecordForSfId:(NSString *)sfId andTableName:(NSString *)tableName;
- (NSArray *)getRecordWhereColumnNamesAndValues:(NSDictionary *)columnKeyAndValue  andTableName:(NSString *)tableName;


- (NSArray *)getProductRecords:(NSArray *)productIdentifiers;
- (NSArray *)getPriceBookObjectsForPriceBookIds:(NSArray *)priceBookIds OrPriceBookNames:(NSArray *)priceBookNames;
- (NSDictionary *)preparePBEstimateId:(NSString *)estimateValue andUsageValue:(NSString *)usageValue andKey:(NSString *)key andRecordTypeId:(NSDictionary *)recordTypeIds ;
- (void)addNamedExpressionsFrom:(NSArray *)dataArray ToArray:(NSMutableArray *)namedExpressionArray;
- (NSArray *)getNamedExpressionsForIds:(NSArray *)namedExpressionArray;
- (NSDictionary *)getAllAdvancedExpressionForIds:(NSArray *)expressionIds;

- (NSArray *)getLookUpDefinition:(NSDictionary *)workOrderData;
- (NSDictionary *)getLookUpFor:(NSString *)parentColumnName andFieldDictionary:(NSDictionary *)parentColumnDictionary andTableName:(NSString *)tableName;
- (NSString *)getTheReferenceValueForId:(NSString*)idValueOfTheField andTableName:(NSString *)tableName;
- (NSDictionary *)getParentSFIDAForLocalId:(NSString *)localId andTableName:(NSString*)tableName;
- (NSDictionary *)getPriceBookDictionaryWithProductArray:(NSArray *)productsArray andPriceBookNames:(NSArray *)partsPriceBookNames andPartsPriceBookIds:(NSArray *)partsPriceBookIdsArray andCurrency:(NSString *)currencyIsoCode;

- (NSArray*)getPriceBookEntryRecordsFor:(NSArray *)priceBookIds andProductArray:(NSArray *)productsArray andTableName:(NSString *)tableName andCurrency:(NSString *)currency;
- (NSDictionary *)getPriceBookForLabourParts:(NSArray *)labourArray andLabourPbNames:(NSArray *)labourPbNames andLabourPbIds:(NSArray *)labourPbIds andCurrency:(NSString *)currency;
- (NSArray *)getPriceBookEntryForLabourArray:(NSArray *)labourArray andPriceBookIds:(NSArray *)priceBookIds andCurrency:(NSString *)currency;

- (NSArray *)getValidLabourPriceBookNames:(NSArray *)labourPbNames andLabourIdArray:(NSArray *)labourIdArray andCurrency:(NSString *)currency;
- (NSString *)getValueFOrKey:(NSString *)key FromArray:(NSArray *)array;
- (NSArray *) getExpressionComponentsForExpressionId:(NSString *)expressionId andExpression:(NSString *)expressionName;
- (NSDictionary *)getexpressionDictionaryForExpressionId:(NSString *)expressionId ;
- (NSString *)changeTheBooleanValue:(NSString *)someString;
- (NSMutableDictionary *)getAllObjectFields:(NSString *)objectName tableName:(NSString *)tableName;
- (NSString *)getGetPriceCodeSnippet:(NSString *)codeSnippetName ;
- (NSDictionary *)getCodeSnippetForId:(NSString *)codeSnippetId;
- (NSDictionary *)getCodeSnippetForName:(NSString *)codeSnippetName ;
- (NSString *)getCodeSnippetRefererenceForId:(NSString *)codeSnippetReference;
- (NSDictionary *)getAllBooleanFieldsForTable:(NSString *)tablenName;
- (NSArray *)getPriceBookObjectsForLabourPriceBookIds:(NSArray *)priceBookIds OrPriceBookNames:(NSArray *)priceBookNames ;
- (NSDictionary *)preparePBForLabourSettings:(NSString *)estimateValue andUsageValue:(NSString *)usageValue andKey:(NSString *)key andRecordTypeId:(NSDictionary *)recordTypeIds;
- (NSDictionary *)preparePBLaourEstimateId:(NSString *)estimateValue andUsageValue:(NSString *)usageValue andKey:(NSString *)key andRecordTypeId:(NSDictionary *)recordTypeIds;
- (NSArray *)getAllMessagesForTagsArray:(NSArray *)tags;
- (NSArray *) getExpressionComponentsForExpressionId:(NSString *)expressionId andExpression:(NSString *)expressionName andRecordId:(NSString *)recordTypeId;
- (NSString *)getEntitlementStatus:(NSString *)recordIdentfier recordIdFromTable:(NSString *)tableName;
- (BOOL)doesAllRecordsForGetPriceCalculationExist:(NSString *)recordId;
- (NSInteger)getRecordCountForSfId:(NSString *)sfId andTableName:(NSString *)tableName;
- (NSString *)getSFIdForlocalId:(NSString *)workOrderLocalId andTableName:(NSString *)tableName;

/* End GET_PRICE_JS-shr*/

#define DATABASENAME   @"sfm"
#define DATABASETYPE   @"sqlite"
//Abinash
//Summary
#define DATABASENAME   @"sfm"
#define DATABASETYPE   @"sqlite"
#define _ID                                       @"Id"
#define SVMXC__PRODUCT__C                         @"SVMXC__Product__c"
#define SVMXC__ACTUAL_QUANTITY2__C                @"SVMXC__Actual_Quantity2__c"
#define SVMXC__ACTUAL_PRICE2__C                   @"SVMXC__Actual_Price2__c"
#define SVMXC__WORK_DESCRIPTION__C                @"SVMXC__Work_Description__c"
#define SVMXC__DISCOUNT__C                        @"SVMXC__Discount__c"
#define SVMXC__PRODUCT2__NAME                     @"SVMXC__Product2__Name"
#define SVMXC__ACTIVITY_TYPE__C                   @"SVMXC__Activity_Type__c"
#define SVMXC__EXPENSE_TYPE__C                    @"SVMXC__Expense_Type__c"
#define CALIBRATION                               @"Calibration"
#define CLEANUP                                   @"Cleanup"
#define INSTALLATION                              @"Installation"
#define REPAIR                                    @"Repair"
#define SERVICE                                   @"Service"

#define RATE_CALIBRATION                          @"Rate_Calibration"
#define RATE_CLEANUP                              @"Rate_Cleanup"
#define RATE_INSTALLATION                         @"Rate_Installation"
#define RATE_REPAIR                               @"Rate_Repair"
#define RATE_SERVICE                              @"Rate_Service"

#define QTY_CALIBRATION                           @"QTY_Calibration"
#define QTY_CLEANUP                               @"QTY_Cleanup"
#define QTY_INSTALLATION                          @"QTY_Installation"
#define QTY_REPAIR                                @"QTY_Repair"
#define QTY_SERVICE                               @"QTY_Service"
//Service Report
#define SVMXC__NAME__C                           @"SVMXC__Name__c"
#define SVMXC__DESCRIPTION__C                    @"SVMXC__Description__c"
#define SVMXC__MODULEID__C                       @"SVMXC__ModuleID__c" 
#define SVMXC__ISSTANDARD__C                     @"SVMXC__IsStandard__c"
#define SVMXC__SUBMODULEID__C                    @"SVMXC__SubmoduleID__c"
#define SVMXC__SETTINGID__C                      @"SVMXC__SettingID__c"
#define SVMXC__SETTING_UNIQUE_ID__C              @"SVMXC__Setting_Unique_ID__c"
#define SVMXC__SETTINGS_NAME__C                  @"SVMXC__Settings_Name__c"
#define SVMXC__DATA_TYPE__C                      @"SVMXC__Data_Type__c"
#define SVMXC__VALUES__C                         @"SVMXC__Values__c"
#define SVMXC__DEFAULT_VALUE__C                  @"SVMXC__Default_Value__c"
#define SVMXC__SETTING_TYPE__C                   @"SVMXC__Setting_Type__c"
#define SVMXC__SEARCH_ORDER__C                   @"SVMXC__Search_Order__c"
#define SVMXC__ISPRIVATE__C                      @"SVMXC__IsPrivate__c"
#define SVMXC__ACTIVE__C                         @"SVMXC__Active__c"
#define SVMXC__PROFILE_NAME__C                   @"SVMXC__Profile_Name__c"
#define SVMXC__ISDEFAULT__C                      @"SVMXC__IsDefault__c"
#define SVMXC__SETTING_CONFIGURATION_PROFILE__C  @"SVMXC__Setting_Configuration_Profile__c"
#define SVMXC__SETTING_ID__C                     @"SVMXC__Setting_ID__c"
#define SVMXC__INTERNAL_VALUE__C                 @"SVMXC__Internal_Value__c"
#define SVMXC__DISPLAY_VALUE__C                  @"SVMXC__Display_Value__c"
#define SVMXC__SUBMODULE__C                      @"SVMXC__Submodule__c"
#define API_NAME                                 @"api_name"
#define TYPE                                     @"type"
#define LABEL                                    @"label"
#define SVMXC__BILLABLE_COST2__C                 @"SVMXC__Billable_Cost2__c"

//DATABASE COLUMNS
#define COLUMN_1                0
#define COLUMN_2                1
#define COLUMN_3                2
#define COLUMN_4                3
#define COLUMN_5                4
#define COLUMN_6                5
#define COLUMN_7                6
#define COLUMN_8                7
#define COLUMN_9                8

//OFFLIINE CHATTER MACROS
#define PRODUCTID               @"ProductId"
#define BODY                    @"Body"
#define CREATEDBYID             @"CreatedById"
#define CREATEDDATE             @"CreatedDate"
#define _USERID                  @"Id"
#define POSTTYPE                @"POSTTYPE"
#define USERNAME                @"Username"
#define EMAIL                   @"Email"
#define FEEDPOSTID              @"FeedPostId"
#define FULLPHOTOURL            @"FullPhotoUrl"

//Offline Troubleshooting Macros
#define DOCUMENTS_ID                       @"DocId"
#define DOCUMENTS_NAME                     @"Name"
#define DOCUMENTS_KEYWORDS                 @"Keywords"


@end
