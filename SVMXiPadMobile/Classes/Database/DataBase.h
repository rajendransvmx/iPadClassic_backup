//
//  DataBase.h
//  iService
//
//  Created by Developer on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSInterface.h"
#include <sqlite3.h>
#include "ZKSforce.h"

@class iServiceAppDelegate;
@interface DataBase : NSObject 
{
    NSString *dbFilePath;
	sqlite3  *db;
    NSMutableArray *resultArray;
    NSString *whatId1;
    NSString *subject;
    NSString *additonalInfo;
    
    sqlite3_stmt *statement;
 //Abinash
    NSDictionary * ExpensesDictionary;
    NSMutableArray * Parts, * Expenses, * Labor, * reportEssentials;
    NSMutableString * settingInfoId;
    NSMutableArray * settingsInfoArray, * settingsValueArray;
    NSString * ActiveGloProInfoId;
    
    iServiceAppDelegate * appDelegate;
    
    NSString * objectApiName;
}

@property (nonatomic, retain) NSString *dbFilePath;
@property (nonatomic, retain) NSString *whatId1;
@property (nonatomic, retain) NSString *subject;

- initWithDBName;
- (void) insertIntoDBResponse:(NSMutableArray *)result;
- (void) getPageLayoutDataFromDatabase:(NSMutableDictionary*)pageLayout;
- (void) standAloneEdit:(NSMutableDictionary*)pageLayout;
- (void) sourceToTarget:(NSMutableDictionary*)pageLayout;
- (BOOL) isUsernamePresent:(NSString *)username password:(NSString *)passWord;
- (NSMutableArray*) getProcessFromDatabase;
- (NSMutableArray*) getViewLayoutsFromDB;
- (NSMutableArray*) GetEventsFromDBWithStartDate:(NSString*)startdate endDate:(NSString*)endDate;
- (NSMutableArray*) didGetTaskFromDB:(NSString *)_date;
- (void) insertTasksIntoDB:(NSArray *)_tasks WithDate:(NSString*)_date;
- (void) updateMovedEventWithStartTime:(NSString *)_startDT EndDate:(NSString *)_endDT RecordID:(NSString *)_recordId;
- (BOOL) isWorkOrder:(NSString *)__whatId;
- (NSString *)getColorCodeForPriority:(NSString *)whatId;
- (void)deleteTaskFromDB:(NSString *)taskId;

- (NSString *) retreiveCurrentTaskIdCreated;

//radha and abinash
- (BOOL) isCase:(NSString *)whatId;

- (NSString *) getTableNameForWhatId:(NSString *)whatId;
- (NSString *) getNameFieldForTableName:(NSString *)tableName;



-(NSMutableArray *)getreferncetableFieldsForReportEsentials:(NSMutableArray *)array;
-(NSMutableArray *)getReportEssentials:(NSString *) record_id;
- (NSMutableString *) removeDuplicatesFromSOQL:(NSString *)soql withString:(NSString *)_query;
-(void) getAllReferenceFields:(NSArray *)fields_array;
- (void)startSummaryFetchFromDB:(NSString*)currentRecordId;
- (NSString *)getNameField:(NSString *)SVMXC__Product__c;
- (NSMutableArray *) queryForParts:(NSString *)currentRecordId;
- (NSMutableArray *) queryForExpenses:(NSString *)currentRecordId;
- (NSMutableDictionary *) queryForLabor:(NSString *)currentRecordId;
- (NSMutableArray *) queryForServiceReportEssentials:(NSString *)currentRecordId;
-(void) startQueryConfiguration;


#define DATABASENAME   @"sfm"
#define DATABASETYPE   @"sqlite"
//Abinash
//Summary
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



@end
