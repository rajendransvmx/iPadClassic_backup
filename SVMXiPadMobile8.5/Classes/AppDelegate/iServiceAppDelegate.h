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

#define TableViewCellHeight 40
#define kLastLocationUpdateTimestamp @"LastLocationUpdateTimestamp"
#define kLastLocationSettingUpdateTimestamp @"LastLocationSettingUpdateTimestamp"
@class iServiceViewController;
@class LoginController;
@class JobViewController;
@class ModalViewController;
@class processInfo;
@class ZKLoginResult;
@class ManualDataSync;    //btn merge
@class DetailViewController;       ///can remove
@class CLLocation;

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
    PUT_RECORDS_DONE = 7,
    GET_INSERT_DC_DONE = 8,
    GET_UPDATE_DC_DONE = 9,
    GET_DELETE_DC_DONE = 10,
    CLEANUP_DONE = 11
    } INCREMENTAL_SYNC;

typedef enum INITIAL_SYNC_SUCCES_OR_FAILED
{
    INITIAL_SYNC_SUCCESS = 1,
    META_SYNC_FAILED = 2,
    DATA_SYNC_FAILED = 3,
    TX_FETCH_FAILED = 4
} INIITIAL_SYNC_SUCCES_OR_FAILED;

typedef enum DO_INITIAL_META_DATA_SYNC
{
    DONT_ALLOW_META_DATA_SYNC = 0,
    ALLOW_META_AND_DATA_SYNC = 1
    
}DO_INITIAL_META_DATA_SYNC;

typedef enum ISLOGEDIN
{
    ISLOGEDIN_FALSE = 0,
    ISLOGEDIN_TRUE = 1
}ISLOGEDIN;


typedef enum DATASYNC_CHUNCKING
{
    REQUEST_SENT      = 0,
    RESPONSE_RECIEVED = 1
} DATASYNC_CHUNCKING;

typedef enum INITIAL_SYNC_STATUS
{
    INITIAL_SYNC_STARTS = 0,
    INITIAL_SYNC_SFM_METADATA = 1,
    INITIAL_SYNC_SFM_METADATA_DONE = 2,
    SYNC_SFM_METADATA = 3,
    SYNC_SFM_METADATA_DONE = 4,
    SYNC_SFM_PAGEDATA = 5,
    SYNC_SFM_PAGEDATA_DONE = 6,
    SYNC_SFMOBJECT_DEFINITIONS = 7,
    SYNC_SFMOBJECT_DEFINITIONS_DONE = 8,
    SYNC_SFM_BATCH_OBJECT_DEFINITIONS = 9,
    SYNC_SFM_BATCH_OBJECT_DEFINITIONS_DONE = 10,
    SYNC_SFM_PICKLIST_DEFINITIONS = 11,
    SYNC_SFM_PICKLIST_DEFINITIONS_DONE = 12,
    SYNC_SFW_METADATA = 13,
    SYNC_SFW_METADATA_DONE = 14,
    SYNC_MOBILE_DEVICE_TAGS = 15,
    SYNC_MOBILE_DEVICE_TAGS_DONE = 16,
    SYNC_MOBILE_DEVICE_SETTINGS = 17,
    SYNC_MOBILE_DEVICE_SETTINGS_DONE = 18,
    SYNC_SFM_SEARCH = 19,
    SYNC_SFM_SEARCH_DONE = 20,
    SYNC_RT_DP_PICKLIST_INFO = 21,
    SYNC_RT_DP_PICKLIST_INFO_DONE = 22,
    SYNC_DP_PICKLIST_INFO = 23,
    SYNC_DP_PICKLIST_INFO_DONE = 24,
    SYNC_EVENT_SYNC = 25,
    SYNC_EVENT_SYNC_DONE = 26,
    SYNC_DOWNLOAD_CRITERIA_SYNC = 27, 
    SYNC_DOWNLOAD_CRITERIA_SYNC_DONE = 28,
    SYNC_CLEANUP_SELECT = 29,
    SYNC_CLEANUP_SELECT_DONE =  30,
    SYNC_TX_FETCH = 31, 
    SYNC_TX_FETCH_DONE = 32,
    SYNC_INSERTING_RECORDS_TO_LOCAL_DATABASE = 33,
    INITIAL_SYNC_COMPLETED = 34
}INITIAL_SYNC_STATUS;


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

///can remove 
@protocol ReloadSyncTable <NSObject>

- (void) ReloadSyncTable;

@end



@interface iServiceAppDelegate : NSObject
<UIApplicationDelegate, UIActionSheetDelegate, WSInterfaceDelegate>
{
	///can remove
    id <ReloadSyncTable> reloadTable;

	NSString * current_userId; 
    BOOL connection_error;
    BOOL download_tags_done;
    BOOL firstTimeCallForTags;
    BOOL IsSSL_error;
    
    BOOL Sync_check_in;
    
    NSThread * special_incremental_thread;
    
    BOOL incrementalSync_Failed ;
    
    BOOL speacialSyncIsGoingOn;
    //Event anf task fiels array
    NSArray * TasksArray;
    NSArray * EventsArray;
    
    //sahana incremental Sync 
    SYNC_STATUS _SyncStatus;
    NSTimer * datasync_timer;
    INCREMENTAL_SYNC  Incremental_sync_status ;
    DATASYNC_CHUNCKING data_sync_chunking;
    DO_INITIAL_META_DATA_SYNC  do_meta_data_sync;
    ISLOGEDIN IsLogedIn;
    INITIAL_SYNC_STATUS initial_sync_status;
    INIITIAL_SYNC_SUCCES_OR_FAILED initial_sync_succes_or_failed;
    
    BOOL Incremental_sync;
    BOOL temp_incremental_sync;
    
    //sahana
    NSString * initial_dataSync_reqid;
    
    
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
    
 //sahana 
    NSString * initial_Sync_last_index , * initital_sync_object_name;
    
    //Radha Purging
    NSMutableArray * initialEventMappinArray;
    NSMutableArray * newEventMappinArray;
    
    
    //Radha
  //  NSTimer * metaSyncTimer;
    NSThread * metaSyncThread;
    NSTimer * metasync_timer;
    
    //logout
    BOOL logoutFlag;

  //Application in the Background
    BOOL isBackground;
    BOOL isForeGround;
    
    //Possible solution for Abrupt Internet Connectivity Problem.
    BOOL shouldShowConnectivityStatus;
    
    NSMutableDictionary * afterSavePageLevelEvents;
    NSMutableDictionary * afterSavePageEventsBinging;
	
	 //Shrinivas 
    BOOL _pingServer;
    BOOL isServerInValid;
    
    //Shrinivas -- Internet Conflicts
    NSMutableArray * internet_Conflicts;
    BOOL internetConflictExists;
    
    //Radha - To Handle Internet Connectivity and Exception
    BOOL isIncrementalMetaSyncInProgress;
    BOOL isMetaSyncExceptionCalled;
    
    //RADHA 
    BOOL isSpecialSyncDone;
    
    //RADHA - EventSync
    NSTimer * event_timer;
    NSThread * event_thread;
    
    
    //Check For Profile
    NSString * userProfileId;
    BOOL didCheckProfile;
    
    //internet alert for  incremental meta sync
    BOOL internetAlertFlag;
    
    
    //Service Report
    NSMutableDictionary * serviceReportReference;
}
@property (nonatomic, retain) NSMutableDictionary * serviceReportReference;

@property (nonatomic, retain) NSString * current_userId;
@property (nonatomic) BOOL internetAlertFlag;

@property (nonatomic) BOOL connection_error;
@property (nonatomic) BOOL didCheckProfile;
@property (nonatomic, retain) NSString * userProfileId;

@property (nonatomic) BOOL isSpecialSyncDone;

@property (nonatomic , retain)  NSMutableDictionary * afterSavePageEventsBinging;
@property (nonatomic, retain) NSMutableDictionary * afterSavePageLevelEvents;
@property (nonatomic) BOOL _pingServer;
@property (nonatomic) BOOL isServerInValid;
@property (nonatomic) BOOL internetConflictExists;
@property (nonatomic, retain) NSMutableArray * internet_Conflicts;

///can remove
@property (nonatomic, assign) id <ReloadSyncTable> reloadTable;
@property (nonatomic) BOOL isIncrementalMetaSyncInProgress;
@property (nonatomic) BOOL isMetaSyncExceptionCalled;

@property (nonatomic) BOOL IsSSL_error;
@property (nonatomic) BOOL firstTimeCallForTags;;
@property (nonatomic) BOOL download_tags_done;
@property (nonatomic) BOOL Sync_check_in;
@property (nonatomic)  INITIAL_SYNC_STATUS initial_sync_status;
@property (nonatomic) ISLOGEDIN IsLogedIn;
@property (nonatomic) INIITIAL_SYNC_SUCCES_OR_FAILED initial_sync_succes_or_failed;
@property (nonatomic) DO_INITIAL_META_DATA_SYNC  do_meta_data_sync;

@property (nonatomic) BOOL shouldShowConnectivityStatus;
@property (nonatomic) DATASYNC_CHUNCKING data_sync_chunking;
@property (nonatomic, retain) NSThread * metaSyncThread;
@property (nonatomic, retain) NSTimer * metasync_timer;

@property (nonatomic, retain) NSMutableArray * onlineDataArray;
@property (nonatomic , retain) NSString * initial_dataSync_reqid;
@property (nonatomic , retain)  NSString * initial_Sync_last_index;
@property (nonatomic , retain) NSString * initital_sync_object_name;
@property (nonatomic , retain) NSArray * sfmSearchTableArray;


@property (nonatomic, retain) NSMutableArray * initialEventMappinArray, * newEventMappinArray;

@property (nonatomic) BOOL didFinishWithError;
@property (nonatomic) BOOL logoutFlag;
@property (nonatomic) BOOL isBackground;
@property (nonatomic) BOOL isForeGround;

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
@property (nonatomic, assign) ModalViewController * modalCalendar;

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

//RADHA
@property (nonatomic, retain) NSTimer * event_timer;
@property (nonatomic, retain) NSThread * event_thread;

@property (nonatomic, assign) BOOL eventSyncRunning, metaSyncRunning, dataSyncRunning;
@property (nonatomic, retain) id queue_object;
@property (nonatomic, assign) SEL queue_selector;

@property (nonatomic, retain) UIImageView *animatedImageView;
@property (nonatomic, assign) BOOL enableLocationService;
@property (nonatomic,retain) NSString * frequencyLocationService;
@property (nonatomic,retain) NSTimer * locationPingSettingTimer;
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
- (BOOL) pingServer;

// Get Color from HEX
- (UIColor *) colorForHex:(NSString *)hexColor;

-(void)popupActionSheet:(NSString *)message;

//Test
- (void) showloginScreen;

- (void)registerDefaultsFromSettingsBundle;


//sahana
-(processInfo *) getViewProcessForObject:(NSString *)object_name record_id:(NSString *)recordId processId:(NSString *)LastprocessId_  isswitchProcess:(BOOL)isSwitchProcess;
-(void) getDPpicklistInfo;


-(void) getCreateProcessArray:(NSMutableArray *)processes_array;


//Radha - IncrementalMetasync
- (void) ScheduleIncrementalMetaSyncTimer;
- (void) metaSyncTimer;
- (void) callMetaSyncTimer;

//Radha - 21 March
//- (void) throwException;

//RADHA - Sync events, task and related data
- (void) ScheduleTimerForEventSync;
- (void) eventSyncTimer;
- (void) callEventSyncTimer;

//Location Ping
-(void)didUpdateToLocation:(CLLocation*)location;
- (void) startBackgroundThreadForLocationServiceSettings;
- (void) checkLocationServiceSetting;
//Bar Code
- (BOOL) isCameraAvailable;


//Timer invalide handler
- (void) timerHandler:(NSNotification *)notification;

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
