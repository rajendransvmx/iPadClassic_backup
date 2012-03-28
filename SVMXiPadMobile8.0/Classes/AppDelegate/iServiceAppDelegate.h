//
//  iServiceAppDelegate.h
//  iService
//
//  Created by Samman Banerjee on 27/08/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "zkSforce.h"
#import "WSInterface.h"
#import "iOSInterfaceObject.h"
#import "HelpController.h"
#import "ZKLoginResult.h"
#import "SFMPageController.h"
#import "Reachability.h"
#import "CalendarDatabase.h"
#import "databaseIntefaceSfm.h"
#include  <sqlite3.h>
//Radha
#import "DataBase.h"

@class iServiceViewController;
@class LoginController;
@class JobViewController;
@class ModalViewController;
@class processInfo;
@class ZKLoginResult;
@class ManualDataSync;    //btn merge

BOOL didSessionResume;

typedef enum SYNC_STATUS {
    SYNC_GREEN = 0,
    SYNC_ORANGE = 1,
    SYNC_RED = 2
    } SYNC_STATUS;
typedef enum  INCREMENTAL_SYNC{
    INCR_STARTS     = 0, 
    PUT_INSERT_DONE = 1,
    GET_INSERT_DONE = 2,
    PUT_UPDATE_DONE = 3,
    GET_UPDATE_DONE = 4,
    PUT_DELETE_DONE = 5,
    GET_DELETE_DONE = 6,
    PUT_RECORDS_DONE = 7
    } INCREMENTAL_SYNC;

BOOL isSessionInavalid;
#define kInternetConnectionChanged          @"kInternetConnectionChanged"

#pragma mark - SYNCHRONIZATION METHODS
extern NSString * syncString;
int synchronized_sqlite3_prepare_v2(
                                    sqlite3 *db,            /* Database handle */
                                    const char *zSql,       /* SQL statement, UTF-8 encoded */
                                    int nByte,              /* Maximum length of zSql in bytes. */
                                    sqlite3_stmt **ppStmt,  /* OUT: Statement handle */
                                    const char **pzTail     /* OUT: Pointer to unused portion of zSql */
                                    );
int synchronized_sqlite3_exec(
                              sqlite3*,                                  /* An open database */
                              const char *sql,                           /* SQL to be evaluated */
                              int (*callback)(void*,int,char**,char**),  /* Callback function */
                              void *,                                    /* 1st argument to callback */
                              char **errmsg                              /* Error msg written here */
                              );
int synchronized_sqlite3_step(sqlite3_stmt *pStmt);
const unsigned char * synchronized_sqlite3_column_text(sqlite3_stmt*, int iCol);
int synchronized_sqlite3_column_int(sqlite3_stmt*, int iCol);
double synchronized_sqlite3_column_double(sqlite3_stmt*, int iCol);
const void * synchronized_sqlite3_column_blob(sqlite3_stmt*, int iCol);
int synchronized_sqlite3_column_bytes(sqlite3_stmt*, int iCol);
int synchronized_sqlite3_finalize(sqlite3_stmt *pStmt);
#pragma mark -


@interface iServiceAppDelegate : NSObject
<UIApplicationDelegate, UIActionSheetDelegate, WSInterfaceDelegate>
{
    NSThread * special_incremental_thread;
    
    BOOL incrementalSync_Failed ;
    
    BOOL speacialSyncIsGoingOn;
    //Event anf task fiels array
    NSArray * TasksArray;
    NSArray * EventsArray;
    
    //sahana incremental Sync 
    SYNC_STATUS SyncStatus;
    NSTimer * datasync_timer;
    INCREMENTAL_SYNC  Incremental_sync_status ;
    BOOL Incremental_sync;
    BOOL temp_incremental_sync;
    
    
    NSString * sourceProcessId;
    NSString * sourceRecordId;
    
    //Abinash  offline summury
    NSMutableDictionary * reference_field_names;
    NSMutableArray * WorkDescription;
    sqlite3  *db;
    UIWindow *window;
    LoginController * loginController;
    
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
    
    BOOL didsubmitModelView;
    
    // Alert View for displaying login error result
    UIAlertView * alert;
    // Login user id to be used across the entire app
    NSString * loggedInUserId;
    
    iOSInterfaceObject * _iOSObject;
    
    // Persistence
    NSString * username, * password;
    NSMutableArray * savedReference;
    NSString * kRestoreLocationKey; // preference key to obtain our restore location

    //locationid
	NSString *locationid, *currentWorkOrderId;
    // NSString *technicianid, *serviceTeamId;
    NSString * appTechnicianId, * appServiceTeamId;
    
    // Technician Address
    NSString * technicianAddress;
    
    // Restore Operatives
    BOOL didDayViewUnload, didMapViewUnload, didJobViewUnload, didTroubleshootingUnload, didProductManualUnload, didChatterUnload, didDebriefUnload, didSFMUnload;
    NSMutableArray * lastSelectedDate;
    NSString * troubleshootProductName;

    // Chatter Feed / Product2Feed
    BOOL chatterFeedPresent;

    // Service Report Customization - sr = service report
    NSMutableDictionary * serviceReport;
    NSMutableString * addressType;

    // Service Report Logo
    UIImage * serviceReportLogo;
       
    // Refresh Calendar
    BOOL refreshCalendar;

    //radha 26th April 2011
    ZKLoginResult * loginResult;
    
    // Modal View Controller
    ModalViewController * modalCalendar;
    
    NSString * dateClicked;
    
    // SFM Page instance members
    SFMPageController * sfmPageController;
    NSDictionary * dict;
    NSMutableArray * headerArray, *linesArray;
    NSDictionary * SFMPage;
    NSArray * describeObjectsArray;
    WSInterface * wsInterface;
    
    // Lookup History
    NSMutableDictionary * lookupHistory;
    NSDictionary * lookupData;
    
    //MulitiAdd Rows
    NSString * objectName;
    
    // Standalone Create
    BOOL didCreateStandalone;
    BOOL createProcess;
    BOOL sfmSave;
    BOOL cancel_save;
    BOOL sfmSaveError;
    
	NSArray * additionalInfo;

    // Debriefing
    NSMutableDictionary *Dictionaries;
    // Time and Material
    NSMutableArray * timeAndMaterial;
    // Usage/Consumption
    NSString * usageConsumptionRecordId;
    NSArray * partsZKSArray, * laborZKSArray, * expensesZKSArray;
    NSString * workOrderCurrency;
    NSMutableArray * Parts, * Labour, * Expenses;
    NSString * priceBookName;
    NSMutableArray * productIdList;
    NSMutableArray * serviceReportValueMapping;
    ZKDescribeSObject * workOrderDescription;
    NSMutableString * currentUserName, * loggedInOrg;

    //Radha Save Create Object
    NSMutableDictionary * createObjectContext; //contains object api name, label, name field, record id. This is for storing create object history
    NSMutableArray * recentObject;
    NSString * cur_nameField;
    NSString * cur_Field_label;
    
    //sahana
    NSString * oldProcessId;
    NSString * oldRecordId;
    NSString * newProcessId;
    NSString * newRecordId;
    NSString * newProcessIdForEdit;
    NSString * newRecordIdForEdit;
    
    NSMutableArray * objectNames_array;
    NSMutableArray * StandAloneCreateProcess;
    NSMutableArray * objectLabel_array;
    NSMutableArray * objectLabelName_array;
    BOOL isSFMReloading;
    NSString * currentServerUrl;
    
    // For Service Report by Settings
    NSMutableString * soqlQuery;
    BOOL didProcessWorkOrderData;
    NSMutableArray * workOrderData;
    NSMutableArray * workOrderUpdateData;
    NSMutableArray * fieldNameTypeArray;    
    //MapView
    NSMutableArray * workOrderEventArray;
    NSMutableArray * workOrderInfo;
    
    NSString * firstUsername;
    
    // DORMA
    BOOL signatureCaptureUpload;
    
    // Switch View Layouts
    NSMutableDictionary * switchViewLayouts;
    
    NSMutableArray * userNameImageList;
    
    BOOL isDetailActive;
    //sahana 25th August
    NSString * SVMX_Version;
    BOOL didGetVersion;
    
    BOOL connectionAvailable;
    
    //Radha
    CalendarDatabase * calDataBase;
    
    BOOL isInternetConnectionAvailable;
    NSMutableArray * allURLConnectionsArray;
    
    
    NSMutableDictionary * SFMoffline;
    BOOL offline;
    BOOL isWorkinginOffline;
    databaseIntefaceSfm * databaseInterface;
    
    NSMutableArray * view_layout_array;

    //Radha
    DataBase * dataBase;
    
    BOOL didincrementalmetasyncdone;
    
    //sahana
    NSMutableDictionary * dataSync_dict;
    NSThread *syncThread;
   

    BOOL dPicklist_retrieval_complete;

    //Shrinivas
    NSString *isConnectedOnline;
    BOOL didBackUpDatabase;

	ManualDataSync * _manualDataSync;   //btn merge
    
    BOOL showUI;//btn merge
    
    NSMutableDictionary * settingsDict;
    
    //TO HANDLE ERROR IN INCREMENTAL META SYNC
    NSException * exception;
    
    NSString * last_initial_data_sync_time;
    
    //Radha
    BOOL didFinishWithError;
    
    
}
@property (nonatomic) BOOL didFinishWithError;

@property (nonatomic , retain)  NSString * last_initial_data_sync_time;;
@property (nonatomic, retain) NSException * exception;

@property (nonatomic, retain) NSMutableDictionary * settingsDict;
//Radha - Siva
@property (nonatomic, retain) Reachability* hostReach;
@property (nonatomic, retain) Reachability* internetReach;
@property (nonatomic) BOOL showUI; //btn merge
@property (nonatomic)  BOOL dPicklist_retrieval_complete;
@property (nonatomic , retain) NSThread * special_incremental_thread;
@property (nonatomic , retain)  NSThread *syncThread;
@property (nonatomic ) BOOL incrementalSync_Failed ;
@property (nonatomic)  BOOL speacialSyncIsGoingOn;
@property (nonatomic )BOOL  didincrementalmetasyncdone;

@property (nonatomic , retain) NSTimer * datasync_timer;
@property (nonatomic ) SYNC_STATUS SyncStatus;
@property (nonatomic)  INCREMENTAL_SYNC  Incremental_sync_status ;
@property (nonatomic) BOOL Incremental_sync;
@property (nonatomic) BOOL temp_incremental_sync;
   
@property (nonatomic , retain) NSMutableDictionary * dataSync_dict;

@property BOOL didLoginAgain;
@property BOOL didBackUpDatabase;
@property (nonatomic) sqlite3 * db;
@property (nonatomic , retain) NSMutableArray * view_layout_array;
@property (nonatomic , retain) NSString * sourceProcessId;
@property (nonatomic , retain) NSString * sourceRecordId;
@property (nonatomic , retain) databaseIntefaceSfm * databaseInterface;
@property (nonatomic) BOOL isWorkinginOffline;
@property(nonatomic , retain) NSMutableDictionary * SFMoffline;
@property(nonatomic) BOOL didsubmitModelView;
@property (nonatomic) BOOL offline;
@property (nonatomic,retain)NSMutableArray * WorkDescription;
@property (nonatomic , retain)NSMutableDictionary * reference_field_names;
@property BOOL didProcessWorkOrderData;
@property (nonatomic, retain) NSMutableArray * fieldNameTypeArray;
@property (nonatomic, retain) NSMutableArray * workOrderUpdateData;
@property (nonatomic, retain) NSMutableArray * workOrderData;@property (nonatomic) BOOL didGetVersion;
@property (nonatomic , retain) NSString * SVMX_Version;
@property (nonatomic , retain)  NSString * newProcessId;
@property (nonatomic , retain) NSString * newRecordId;
@property (nonatomic , retain)  NSString * newProcessIdForEdit;
@property (nonatomic , retain) NSString * newRecordIdForEdit;
@property (nonatomic)  BOOL isSFMReloading;
@property (nonatomic , retain)  NSMutableArray * objectLabel_array;
@property (nonatomic , retain) NSMutableArray * objectNames_array;
@property (nonatomic , retain)  NSMutableArray * StandAloneCreateProcess;
@property(nonatomic , retain)  NSString * oldProcessId;
@property(nonatomic , retain)   NSString * oldRecordId;
@property(nonatomic , retain) NSString * cur_nameField;
@property(nonatomic , retain)  NSString * cur_Field_label;
@property (nonatomic , retain) NSArray  * additionalInfo;
@property(nonatomic)  BOOL sfmSaveError;
@property (nonatomic) BOOL cancel_save;
//@property (nonatomic) BOOL sfmSaveCancelled;
@property (nonatomic )BOOL sfmSave; 
@property (nonatomic, retain) NSString * currentProcessID;
@property (nonatomic) BOOL createProcess;
//For Localization
//RADHA 20th April 2011
@property (nonatomic, retain) ZKLoginResult * loginResult;
@property (nonatomic , retain) NSMutableArray * deleted_detail_Fields;
@property (nonatomic, retain) NSString * dateClicked;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet LoginController * viewController;
@property (nonatomic, retain) NSString * loggedInUserId;
@property (nonatomic, retain) iOSInterfaceObject * _iOSObject;

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSMutableArray * savedReference;
@property (nonatomic, retain) NSString * kRestoreLocationKey;

@property (nonatomic, copy) NSString *locationid, *currentWorkOrderId;
@property (nonatomic, retain) NSString * appTechnicianId, * appServiceTeamId;

@property (nonatomic, retain) NSDictionary * tempSummary;

@property (nonatomic, retain) NSString * technicianAddress;

// Restore Operatives
@property BOOL didDayViewUnload, didMapViewUnload, didJobViewUnload, didTroubleshootingUnload, didProductManualUnload, didChatterUnload, didDebriefUnload, didSFMUnload;
@property (nonatomic, retain) NSMutableArray * lastSelectedDate;
@property (nonatomic, retain) NSString * troubleshootProductName;

// Service Report Logo
@property (nonatomic, retain) UIImage * serviceReportLogo;

// Refresh Calendar
@property BOOL refreshCalendar;
@property (nonatomic, retain) ModalViewController * modalCalendar;

// SFM Page
@property (nonatomic, retain) SFMPageController * sfmPageController;
@property (nonatomic, retain) WSInterface * wsInterface;
@property (nonatomic, retain) NSDictionary * dict;
@property (nonatomic, retain) NSMutableArray *headerArray,*linesArray;
@property (nonatomic, retain) NSDictionary * SFMPage;
@property (nonatomic, retain) NSArray * describeObjectsArray;

// Lookup History
@property (nonatomic, retain) NSMutableDictionary * lookupHistory;

@property (nonatomic, retain) NSDictionary * lookupData;

//MulitiAdd Rows
@property (nonatomic, retain) NSString * objectName;

//Standalone
@property (nonatomic, assign) BOOL didCreateStandalone;

// Debriefing
@property (nonatomic, retain) NSMutableDictionary * Dictionaries;
// Time and Material
@property (nonatomic, retain) NSMutableArray * timeAndMaterial;
// Usage/Consumption
@property (nonatomic, retain) NSString * usageConsumptionRecordId;
@property (nonatomic, retain) NSArray * partsZKSArray, * laborZKSArray, * expensesZKSArray;
@property (nonatomic, retain) NSString * workOrderCurrency;
@property (nonatomic, retain) NSMutableArray * Parts, * Labour, * Expenses;
@property (nonatomic, retain) NSString * priceBookName;
@property (nonatomic, retain) NSMutableArray * productIdList;
@property (nonatomic, retain) NSMutableString * addressType;
@property (nonatomic, retain) NSMutableArray * serviceReportValueMapping;
@property (nonatomic, retain) ZKDescribeSObject * workOrderDescription;
@property (nonatomic, retain) NSMutableDictionary * serviceReport;
@property (nonatomic, retain) NSMutableString * currentUserName, * loggedInOrg;

//Radha save create object
@property (nonatomic, retain) NSMutableDictionary * createObjectContext;
@property (nonatomic, retain) NSMutableArray * recentObject;
@property (nonatomic, retain) NSMutableArray * objectLabelName_array;

@property (nonatomic, retain) NSString * currentServerUrl;

// Service Report
@property (nonatomic, retain) NSMutableString * soqlQuery;

//Mapview
@property (nonatomic, retain) NSMutableArray * workOrderEventArray;
@property (nonatomic, retain) NSMutableArray * workOrderInfo;

@property (nonatomic, retain) NSString * firstUsername;

// DORMA
@property BOOL signatureCaptureUpload;

// Switch View Layouts
@property (nonatomic, retain) NSMutableDictionary * switchViewLayouts;

@property (nonatomic, retain) NSMutableArray * userNameImageList;

@property BOOL isDetailActive;

@property BOOL connectionAvailable;

@property BOOL isInternetConnectionAvailable;

@property (nonatomic, retain) NSMutableArray * allURLConnectionsArray;

//databse
@property (nonatomic, retain) CalendarDatabase * calDataBase;

@property (nonatomic, retain) DataBase * dataBase;

@property (nonatomic,retain) NSString *isConnectedOnline;

@property (nonatomic, retain) NSArray * TasksArray, * EventsArray;

//Shrinivas
@property (nonatomic, retain) ManualDataSync * _manualDataSync;   //btn merge


// get GUID 
+ (NSString *)GetUUID;

-(NSMutableArray *) getWeekdates:(NSString *)date;

-(void)initWithDBName:(NSString *)name type:(NSString *)type ;
// Reachability
- (BOOL) isReachable:(Reachability *)curReach;
- (void) updateInterfaceWithReachability:(Reachability*)curReach;
- (void) PostInternetNotificationUnavailable;
- (void) PostInternetNotificationAvailable;
- (void) displayNoInternetAvailable;

//sahana Data Sync
-(void)ScheduleIncrementalDatasyncTimer;

-(void)callDataSync;
-(void)callSpecialIncrementalSync;

//Shrinivas
- (void) goOnlineIfRequired;

// Get Color from HEX
- (UIColor *) colorForHex:(NSString *)hexColor;

-(void)popupActionSheet:(NSString *)message;

//Test
- (void) showloginScreen;

- (void)registerDefaultsFromSettingsBundle;


//sahana
-(processInfo *) getViewProcessForObject:(NSString *)object_name record_id:(NSString *)recordId processId:(NSString *)LastprocessId_  isswitchProcess:(BOOL)isSwitchProcess;
-(void) getDPpicklistInfo;



//Radha - 21 March
- (void) throwException;

@end

@interface processInfo : NSObject {

    BOOL process_exists;
    NSString * process_id;
}
@property BOOL process_exists;
@property (nonatomic , retain) NSString * process_id;

@end
// ALog always displays output regardless of the DEBUG setting
// #define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
