//
//  WSInterface.h
//  project
//
//  Created by Developer on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZKSforce.h"
#import "ZKLoginResult.h"
#import "INTF_WebServicesDefServiceSvc.h"
#import "WSIntfGlobals.h"
#import "LocalizationGlobals.h"
#import "QuartzCore/QuartzCore.h"
#import "DataBaseGlobals.h"
#import "SBJsonParser.h"
#import "SBJsonWriter.h"
#import "ZKDescribeLayoutResult.h"
#import "ZKRecordTypeMapping.h"
#import "ZKPicklistEntry.h"

//radha 18th August 2011


@class iServiceAppDelegate;
@class LookupView;

@protocol RefrehManualDataSyncUI;
@protocol WSInterfaceDelegate;
@protocol WSInterFaceDelegateForDetailView;
@protocol RefreshSyncStatus;
@protocol RefreshSyncStatusButton;
@protocol RefreshModalSyncStatusButton;


@interface WSInterface : NSObject
<INTF_WebServicesDefBindingResponseDelegate>
{
    
    //RADHA
    id MyPopoverDelegate;
    
    NSString * request_time;
    id <WSInterfaceDelegate> delegate;
    id <WSInterFaceDelegateForDetailView> detailDelegate;
    
    id <RefrehManualDataSyncUI> manualDataSyncUIDelegate;
    id <RefreshSyncStatus> updateSyncStatus;
    id <RefreshSyncStatusButton> refreshSyncButton;
    id <RefreshModalSyncStatusButton> refreshModalStatusButton;
    iServiceAppDelegate * appDelegate;
    
    NSMutableArray * processArray;
    
    //Radha 20st April 2011
    //Dictionary declaration for localizing 
    NSMutableDictionary * tagsDictionary;
    NSMutableDictionary * tempTagsDictionary;
    NSUInteger responseError;
    
    //Radha 9th May 2011
    NSString * startDate;
    NSString * endDate;
    NSMutableArray * currentDateRange;
    
    NSMutableArray * eventArray;
    NSDictionary * viewDictionary;
    NSArray * createProcessArray;
    NSArray * viewLayoutsArray;
    NSMutableArray * productHistory, * accountHistory;
    NSMutableDictionary * detail_addRecordItems;
    NSMutableArray * tasks;
    NSMutableArray * section_for_createObjects;
    id lookupCaller;
    
    BOOL didGetObjectName;
    //Radha 4th June
    BOOL didGetProductHistory;
    BOOL didGetAccountHistory;
    BOOL add_WS;
    BOOL SFM_SAVE;
    
    BOOL didGetNameField;
    BOOL errorLoadingSFM;
    BOOL sfm_response;
    NSMutableArray * objectNames_array;
    
    NSArray * obj_array;
    //sahana
    BOOL getPrice;
    
    NSString * rescheduleEvent;
    BOOL didRescheduleEvent;
    
    //Mapview
    BOOL didGetWorkOder;
    
    //RecordTypeId
    BOOL didGetRecordTypeId;
    //sahana 16th sept 2011
    BOOL didGetProcessId;
    BOOL isLoggedIn;
    
    
    
    
    //Radha META_SYNC
    //Radha Information about the objects and its definitions
    NSMutableArray * objectDefinitions;
    NSMutableArray * object;
    //PicklistValues
    NSMutableArray * picklistObject;
    NSMutableArray * picklistField;
    NSMutableArray * picklistValues;
        //Pagelayout Info
    NSMutableArray * pageUiHistory;
    //Radha - Flags to maintain synchronization
    BOOL didGetAllMetadata;
    BOOL didGetPicklistValues;
    BOOL didGetPageData;
    BOOL didGetObjectDef;
    BOOL didGetWizards;
    BOOL didOpComplete;
    BOOL didOpSFMSearchComplete;
    BOOL didGetAddtionalObjDef;
    
    
    //FOR DATABASE
    BOOL didGetPageDataDb;
    BOOL didGetPicklistValueDb;
    
    NSMutableArray * expressionArray;
    NSMutableDictionary * wizardDictionary;
    
    //MetaData Info
    NSMutableDictionary * processDictionary;
    
    //Tags and settings
    NSMutableDictionary * mobileDeviceTagsDict;
    NSMutableDictionary * mobileDeviceSettingsDict;
    
    //keep Track of process_type for page_id
    NSMutableDictionary * processType_dict;
    
    
    //Radha DataSync
    SBJsonParser * jsonParser ;
    SBJsonWriter * jsonWriter;
   // SBJsonWriter * jsonWriter;
    NSMutableArray * childObject;
    
    //sahana Data SYnc 
    NSString * Insert_requestId ;
    NSString * insert_last_sync_time;
    NSString * update_last_sync_time;
    NSString * delete_last_sync_time;
    
    //sahana downloadcriteria sync 
    NSString * get_dc_records_request_id;
    NSString * insert_dc_last_sync_time;
    NSString * update_dc_last_sync_time;
    NSString * delete_dc_last_sync_time;
    
    //shrinivas
    BOOL  didWriteSignature;
    BOOL  didWritePDF;

 //RT Dependent Picklist
    BOOL didDescribeLayoutReceived;
    NSString *recordTypeID_Value;
    NSMutableDictionary *recordTypeDict;
    NSString *recordTypeObjName;
    NSMutableArray * RecordTypePickList;
    
    //sahana
    NSMutableDictionary * dcobjects_incrementalSync;

}

@property (nonatomic , retain) NSMutableDictionary * dcobjects_incrementalSync;
@property (nonatomic , retain) NSString * get_dc_records_request_id;

//RADHA
@property (nonatomic, retain) id MyPopoverDelegate;

@property (nonatomic , retain)  NSString * request_time;
@property (nonatomic , retain) NSString * update_last_sync_time ;
@property (nonatomic , retain) NSString * insert_last_sync_time;
@property (nonatomic , retain) NSString * delete_last_sync_time;
@property (nonatomic , retain)    NSString * insert_dc_last_sync_time , *update_dc_last_sync_time, * delete_dc_last_sync_time;

@property (nonatomic) BOOL  didWriteSignature;
@property (nonatomic) BOOL  didWritePDF;
@property (nonatomic) BOOL didGetProductHistory;
@property (nonatomic) BOOL didGetAccountHistory;
@property (nonatomic)  BOOL didGetProcessId;
@property (nonatomic) BOOL getPrice;
@property (nonatomic)BOOL didGetObjectName;
@property (nonatomic , retain) NSArray * obj_array;
@property (nonatomic , retain) NSMutableArray * objectNames_array;
@property (nonatomic , retain) NSMutableArray * section_for_createObjects;
@property (nonatomic) BOOL sfm_response;
@property (nonatomic) BOOL errorLoadingSFM;
@property (nonatomic) BOOL SFM_SAVE;
@property (nonatomic ) BOOL add_WS;
@property (nonatomic , retain) NSMutableDictionary * detail_addRecordItems;
@property (nonatomic, assign) id <WSInterfaceDelegate> delegate;
@property (nonatomic , assign)id<WSInterFaceDelegateForDetailView> detailDelegate;
@property (nonatomic , assign) id <RefrehManualDataSyncUI> manualDataSyncUIDelegate;
@property (nonatomic, assign) id <RefreshSyncStatus> updateSyncStatus;
@property (nonatomic, assign) id <RefreshSyncStatusButton> refreshSyncButton;
@property (nonatomic, assign) id <RefreshModalSyncStatusButton> refreshModalStatusButton;
@property (nonatomic, retain) NSMutableArray * processArray;

@property (nonatomic, retain) NSMutableDictionary * tagsDictionary;
@property (nonatomic, assign) NSUInteger responseError;

@property (nonatomic, retain) NSString * startDate, * endDate;
@property (nonatomic, retain) NSMutableArray * currentDateRange;
@property (nonatomic, retain) NSMutableArray * eventArray;
@property (nonatomic, retain) NSDictionary * viewDictionary;
@property (nonatomic, retain) NSArray * createProcessArray;
@property (nonatomic, retain) NSArray * viewLayoutsArray;
@property (nonatomic, retain) NSArray * productHistory;

@property (nonatomic, retain) NSMutableArray * tasks;
@property (nonatomic, retain) NSString * rescheduleEvent;
@property (nonatomic, assign) BOOL didRescheduleEvent;
@property (nonatomic, retain) NSMutableArray * accountHistory;

//Mapview
@property (nonatomic, assign) BOOL didGetWorkOder;

@property (nonatomic, assign) BOOL didGetRecordTypeId;

@property BOOL isLoggedIn;


//Radha - MetaDat

@property BOOL didGetAllMetaData;
@property BOOL didGetPicklistValues;
@property BOOL didGetPageData;
@property BOOL didGetObjectDef;
@property (assign) BOOL didOpComplete;
@property (assign) BOOL didOpSFMSearchComplete;
@property BOOL didGetWizards;
@property BOOL didGetPageDataDb;
@property BOOL didGetPicklistValueDb;

@property (nonatomic, retain) NSMutableArray * objectDefinitions;
@property (nonatomic, retain) NSMutableArray * object;
@property (nonatomic, retain) NSMutableArray * picklistValues;
@property (nonatomic, retain) NSMutableDictionary * processDictionary;

@property (nonatomic, retain) NSMutableArray  * picklistObject; 
@property (nonatomic, retain) NSMutableArray * picklistField;
@property (nonatomic, retain) NSMutableArray * pageUiHistory;
//Radha DataSync
@property (nonatomic, retain) NSMutableArray * childObject;


-(NSString *)requestSnapShot;
- (void) getSvmxVersion;
// Web Service Caller Methods
- (void) getUpdateEventsForStartDate:(NSString *)_startDate EndDate:(NSString *)_endDate  recordID:(NSString *)what_id;
- (void) getTags;
- (NSMutableDictionary *) fillEmptyTags:(NSMutableDictionary *)_tagsDictionary;
- (void) getCreateProcesses;
- (void) getEventsForStartDate:(NSString *)startDate EndDate:(NSString *)endDate;
- (void) getPageLayoutWithProcessId:(NSString *)processId RecordId:(NSString *)recordId;
- (void) savePageLayout;
- (void) saveSwitchView:(NSString *)currentProcessId forObject:(NSString *)objectAPIName;
- (void) getLookUpFieldsWithKeyword:(NSString *)keyword forObject:(NSString *)objectName returnTo:(id)caller setting:(BOOL)idAvailable overrideRelatedLookup:(NSNumber *)Override_Related_Lookup lookupContext:(NSString *)Lookup_Context lookupQuery:(NSString *)Lookup_Query_Field;
- (void) getAccountHistoryForWorkOrderId:(NSString *)woId;
- (void) getProductHistoryForWorkOrderId:(NSString *)woId;
- (void) saveTargetRecords:(id)sender;
- (void) getViewLayouts;
- (void) getTasksForStartDate:(NSString *)startDate EndDate:(NSString *)endDate;
- (void) getWorkOrderMapViewForWorkOrderId:(NSString *)workOrderId;

// Wrapper Layer to extract REQUIRED data from response received from Web Service 

- (void) getWrapperDictionary:(NSMutableDictionary *)bodyParts;

// Describe Object(s)
- (void) describeObjectFromResponse:(INTF_WebServicesDefBindingResponse *)response;
- (void) didDescribeSObject:(ZKDescribeSObject *)describeObject error:(NSError *)error context:(id)context;
- (NSMutableDictionary *) getDescribeObjects:(NSMutableDictionary *)bodyParts;
- (void) didDescribeSObjects:(NSMutableArray *)result error:(NSError *)error context:(id)context;

- (void) getDictionaryFromPageLayout:(NSMutableDictionary *)bodyParts withDescribedObjects:(NSMutableArray *)describeObjects;
- (NSMutableDictionary *) GetHeaderSectionForSequenceNumber: (NSInteger)sequence;

- (NSMutableDictionary *) getTagsdisplay:(INTF_WebServicesDefBindingResponse *)response;
- (NSMutableArray *) getEventdisplay:(INTF_WebServicesDefBindingResponse *)response;
- (NSMutableDictionary *) getDefaultTags;
- (NSArray *) getCreateProcessesDictionaryArray:(INTF_WebServicesDefBindingResponse *)response;
- (NSMutableArray *) getProductHistoryFromResponse:(INTF_WebServicesDefBindingResponse *)response;
- (NSMutableArray *) getAccountHistoryFromResponse:(INTF_WebServicesDefBindingResponse *)response;
- (NSMutableDictionary *) getLookUpFromResponse:(INTF_WebServicesDefBindingResponse *)response;
- (NSArray *) getViewLayoutArray:(INTF_WebServicesDefBindingResponse *)response;
// addRecord  response 
- (NSMutableDictionary *)getAddRecordsFields:(INTF_WebServicesDefBindingResponse *)response;
- (NSMutableArray *) getTasksFromResponse:(INTF_WebServicesDefBindingResponse *)response;
- (NSMutableDictionary *) getWorkOrderDetails:(INTF_WebServicesDefBindingResponse *)response;

//pavaman
-(void) SaveSFMData:(NSDictionary *)sfmpage;
-(void) AddRecordForLines:(NSString*) process_id ForDetailLayoutId:(NSString*) layout_id;

// Samman - special method to extract data from sfmPage
- (INTF_WebServicesDefServiceSvc_INTF_TargetRecord *) getTargetRecordsFromSFMPage:(NSDictionary *)sfmpage;

// Thoons method
- (void) callSFMEvent:(NSDictionary *)dictionary;

-(NSString *) getAllFieldsForObjectName:(NSString *)hdr_object_name;

// Misc Methods

// Radha  Save create object methods
- (void) saveDictionaryToPList:(NSMutableDictionary *) dictionary;
-(void) getNameFieldForCreateProcess:(NSString *)ID;
- (void) didGetNameField:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) getWeekdates:(NSString *)date;
- (void) didFinishGetEventsWithFault:(SOAPFault *)fault;

-(NSMutableDictionary *) getSaveTargetRecords:(INTF_WebServicesDefBindingResponse *)response;

- (BOOL) checkValidStartDate:(NSString *)_startDate EndDate:(NSString *)_endDate;

//Radha Meta Sync 
- (void) metaSyncWithEventName:(NSString *)eventName eventType:(NSString *)eventType values:(NSMutableArray *)values;

//Radha datasync
- (void) dataSyncWithEventName:(NSString *)eventName eventType:(NSString *)eventType requestId:(NSString *)requestId;
- (void) dataSyncWithEventName:(NSString *)eventName eventType:(NSString *)eventType values:(NSMutableArray *)values;


//Radha temperory check for the picklist values
- (NSMutableArray *) collectPickListObject;

//Radha
- (NSMutableArray *) getAllPageLauoutId;
- (void) getAdditionalObjectdefinition;

//RADHA 12/04/12
- (NSMutableArray *) getAllProcessId;

//Radha - RecordTypeDependentPicklist
- (void) getRecordTypeDictForObjects:(NSArray *)objects;
- (void) didDescribeSObjectLayoutForObject:(ZKDescribeLayoutResult *)result error:(NSError *)error context:(id)context;

//sahana Initial Data SYnc 
-(NSMutableArray *)getIdsFromJsonString:(NSString *)jsonstrings;

//sahana incremental datasync
-(void)GETDownloadCriteriaRecordsFor:(NSString *)event_name;
-(void)cleanUpForRequestId:(NSString *)requestId  forEventName:(NSString *)eventName;

-(void) PutAllTheRecordsForIds;
-(void)getAllRecordsForOperationType:(NSString *)OpearationType;
-(void) Put:(NSString *)event_name;
-(void)copyTrailertoTempTrailer:(NSString *)operation_type;
-(void)GetInsert;
-(void)GetUpdate;
-(void)GetDelete;
-(void)setLastSyncTime;
-(void)DoIncrementalDataSync;
-(NSString *)getSyncTimeStampWithTheIntervalof15days:(NSString *)time;
-(NSString *)get_SYNCHISTORYTime_ForKey:(NSString *)forkey;
-(void)setsyncHistoryForSyncType:(NSString *)sync_type requestOrResponse:(NSString *)operation_type  request_id:(NSString *)request_id 
last_sync_time:(NSString *)last_sync_time;
#define CHUNCKING_LIMIT  150
-(NSString *)escapeSIngleQute:(NSString *)jsonString;
-(void)getAllRecordsForOperationTypeFromSYNCCONFLICT:(NSString *)operationType OverRideFlag:(NSString *)overrideFlag;
//-(void)LoadHeapTableFromConflictTable;
-(void)DoSpecialIncrementalSync;
-(NSString *)requestSnapShot;
-(void)setSyncReqId:(NSString *)req_id;
-(BOOL)getSyncStatusForRequestId;
-(void)setLastSyncOccured;
-(void)generateRequestId;
-(void)resetSyncLastindexAndObjectName;
-(NSString *)getIdFromJsonString:(NSString *)jsonString;

-(void)downloadcriteriaplist:(NSDictionary *)dict;
-(NSDictionary *)getdownloadCriteriaObjects;
-(void)checkdownloadcriteria;


- (NSString *) getGmtDateAndTime:(NSDate *)localTime;
@end

@protocol RefrehManualDataSyncUI <NSObject>

@optional
-(void)refreshdataSyncUI;

@end

@protocol RefreshSyncStatus <NSObject>

@optional
-(void) refreshSyncStatus;

@end

@protocol RefreshSyncStatusButton <NSObject>

@optional
-(void) showSyncStatusButton;

@end

@protocol RefreshModalSyncStatusButton <NSObject>

@optional
-(void) showModalSyncStatus;

@end



@protocol WSInterFaceDelegateForDetailView <NSObject>

@optional
-(void) didFinshSave:(NSString *) responseMsg;
-(void) didFinishWithSuccess:(NSString *) response_msg;
@end

@protocol WSInterfaceDelegate <NSObject>
@optional
- (void) didFinishWithError:(SOAPFault *)sFault;
- (void) didFinishGetEvents;

- (void) didReceivePageLayout:(NSMutableDictionary *)pageLayout withDescribeObjects:(NSMutableArray *)describeObjects;

@end

@interface NSString (Helper)
- (BOOL) Contains:(NSString *)string;
@end


@interface ZKServerSwitchboard (Private1)
- (void)doCheckSession;
- (void)sessionDidResume:(ZKLoginResult *)loginResult error:(NSError *)error;
@end
