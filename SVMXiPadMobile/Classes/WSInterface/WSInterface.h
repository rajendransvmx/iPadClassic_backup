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
//radha 18th August 2011


@class iServiceAppDelegate;
@class LookupView;

@protocol WSInterfaceDelegate;
@protocol WSInterFaceDelegateForDetailView;

@interface WSInterface : NSObject
<INTF_WebServicesDefBindingResponseDelegate>
{
    id <WSInterfaceDelegate> delegate;
    id <WSInterFaceDelegateForDetailView> detailDelegate;
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
}
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

//Mapview
@property (nonatomic, assign) BOOL didGetWorkOder;

@property (nonatomic, assign) BOOL didGetRecordTypeId;

@property BOOL isLoggedIn;

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

// Misc Methods

// Radha  Save create object methods
- (void) saveDictionaryToPList:(NSMutableDictionary *) dictionary;
-(void) getNameFieldForCreateProcess:(NSString *)ID;
- (void) didGetNameField:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) getWeekdates:(NSString *)date;
- (void) didFinishGetEventsWithFault:(SOAPFault *)fault;

-(NSMutableDictionary *) getSaveTargetRecords:(INTF_WebServicesDefBindingResponse *)response;

- (BOOL) checkValidStartDate:(NSString *)_startDate EndDate:(NSString *)_endDate;

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
