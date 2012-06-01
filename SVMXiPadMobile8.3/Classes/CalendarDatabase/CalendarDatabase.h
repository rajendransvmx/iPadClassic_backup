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

- initWithDBName;
//- (BOOL) isUsernamePresent:(NSString *)username password:(NSString *)passWord;

- (NSMutableArray*) getProcessFromDatabase;
//- (NSMutableArray*) getViewLayoutsFromDB;
- (NSMutableArray*) GetEventsFromDBWithStartDate:(NSString*)startdate endDate:(NSString*)endDate;
- (NSMutableArray*) didGetTaskFromDB:(NSString *)_date;
- (BOOL) insertTasksIntoDB:(NSArray *)_tasks WithDate:(NSString*)_date local_id:(NSString *)local_id;
- (void) updateMovedEventWithStartTime:(NSString *)_startDT EndDate:(NSString *)_endDT RecordID:(NSString *)_recordId;
- (BOOL) isWorkOrder:(NSString *)__whatId;
- (NSString *)getColorCodeForPriority:(NSString *)whatId;
- (void)deleteTaskFromDB:(NSString *)taskId;
- (NSString *)getTableName:(NSString *)key;
- (NSString *) retreiveCurrentTaskIdCreated;
- (NSString *) getPriorityForWhatId:(NSString *)whatId;

//radha and abinash
- (BOOL) isCase:(NSString *)whatId;

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
- (NSMutableDictionary *) queryForLabor:(NSString *)currentRecordId;
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
- (void) deleteAllSignatureData;
//shrinivas
- (void) getSFIdForSignature:(NSString *)localId objectName:(NSString *)objectName;   //Method to be called only after Data Sync 
- (void) retrieveSignatureFromSFDC:(NSString *)ID;
- (void) writeSignatureToSFDC:(NSString *)SFId;
- (void) getAllLocalIdsForSignature;

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


//Radha
- (NSData *) retrievePdfData:(NSString *)Id;


//Shrinivas -- Sync conflict Internet handler
- (void) insertIntoConflictInternetErrorWithSyncType:(NSString *)sync_type;
- (void) insertIntoConflictInternetErrorForMetaSync:(NSString *)sync_type WithDB:(sqlite3 *)db;
- (NSMutableArray *) getInternetConflicts;
- (NSMutableArray *) getInternetConflictsForMetaSyncWithDB:(sqlite3 *)db;
- (void) removeInternetConflicts;


//Shrinivas --- Status for Meta Sync
-(void) insertMetaSyncStatus:(NSString *)status WithDB:(sqlite3 *)db;
-(NSString *) retrieveMetaSyncStatus;


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
