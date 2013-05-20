//
//  iServiceAppDelegate.m
//  iService
//
//  Created by Samman Banerjee on 27/08/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "iServiceAppDelegate.h"
#import "LoginController.h" 
#import "LocalizationGlobals.h"
#import "ManualDataSync.h"
#import "SummaryViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>

//OAuth:
#import "iPadScrollerViewController.h"

#import "SFHFKeychainUtils.h"
#import <sys/utsname.h>

extern void SVMXLog(NSString *format, ...);

//OAuth.
static const int MAX_SESSION_AGE = 10 * 60;
//krishna client info
const NSString *deviceType = @"type";//@"iPad";
const NSString *osVersion = @"iOSVersion";
const NSString *applicationVersion = @"appVersion";
const NSString *devVersion = @"deviceVersion";


iServiceAppDelegate *appDelegate;

#pragma mark - SYNCHRONIZATION METHODS
NSString * syncString = @"synchronized";
int synchronized_sqlite3_prepare_v2(
                                    sqlite3 *db,            /* Database handle */
                                    const char *zSql,       /* SQL statement, UTF-8 encoded */
                                    int nByte,              /* Maximum length of zSql in bytes. */
                                    sqlite3_stmt **ppStmt,  /* OUT: Statement handle */
                                    const char **pzTail     /* OUT: Pointer to unused portion of zSql */
                                    )
{
    int retVal = 0;
    @synchronized(syncString)
    {
        retVal = sqlite3_prepare_v2(db, zSql, nByte, ppStmt, pzTail);
    }
    return retVal;
}

int synchronized_sqlite3_exec(
                              sqlite3 *db,                               /* An open database */
                              const char *sql,                           /* SQL to be evaluated */
                              int (*callback)(void*,int,char**,char**),  /* Callback function */
                              void *arg,                                    /* 1st argument to callback */
                              char **errmsg                              /* Error msg written here */
                              )
{
    int retVal = 0;
    @synchronized(syncString)
    {
        retVal = sqlite3_exec(db, sql, callback, arg, errmsg);
    }
    return retVal;
}

int synchronized_sqlite3_step(sqlite3_stmt *pStmt)
{
    int retVal = 0;
    @synchronized(syncString)
    {
        retVal = sqlite3_step(pStmt);
    }
    return retVal;
}

const unsigned char * synchronized_sqlite3_column_text(sqlite3_stmt *pStmt, int iCol)
{
    const unsigned char * retVal = 0;
    @synchronized(syncString)
    {
        retVal = sqlite3_column_text(pStmt, iCol);
    }
    return retVal;
}

int synchronized_sqlite3_column_int(sqlite3_stmt *pStmt, int iCol)
{
    int retVal = 0;
    @synchronized(syncString)
    {
        retVal = sqlite3_column_int(pStmt, iCol);
    }
    return retVal;
}

double synchronized_sqlite3_column_double(sqlite3_stmt *pStmt, int iCol)
{
    double retVal = 0.0;
    @synchronized(syncString)
    {
        retVal = sqlite3_column_double(pStmt, iCol);
    }
    return retVal;
}

const void * synchronized_sqlite3_column_blob(sqlite3_stmt *pStmt, int iCol)
{
    const void * retVal = 0;
    @synchronized(syncString)
    {
        retVal = sqlite3_column_blob(pStmt, iCol);
    }
    return retVal;
}

int synchronized_sqlite3_column_bytes(sqlite3_stmt *pStmt, int iCol)
{
    int retVal = 0;
    @synchronized(syncString)
    {
        retVal = sqlite3_column_bytes(pStmt, iCol);
    }
    return retVal;
}

int synchronized_sqlite3_finalize(sqlite3_stmt *pStmt)
{
    int retVal = 0;
    @synchronized(syncString)
    {
        retVal = sqlite3_finalize(pStmt);
    }
    return retVal;
}
#pragma mark -

//rotation code for summary view controller to portrait mode only
//Sanchay - 201210041615
@implementation UINavigationController (IOS6Rotation)

-(BOOL)shouldAutorotate
{
	id obj = self.viewControllers.lastObject;
    return [obj shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
	id obj = self.viewControllers.lastObject;
    return [obj supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	id obj = self.viewControllers.lastObject;
    /* Added PDF Create for issue 05776 */
	if( [obj isKindOfClass:[SummaryViewController class]] || [obj isKindOfClass:[PDFCreator class]] )
	{
		[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
		return UIInterfaceOrientationPortrait;
	}
	UIInterfaceOrientation orient = [obj preferredInterfaceOrientationForPresentation];
	return orient;
}

@end
//================================================================

@implementation iServiceAppDelegate
//RADHA Defect Fix 5542
@synthesize shouldScheduleTimer;
@synthesize isDataSyncTimerTriggered;

//Radha Sync ProgressBar
@synthesize SyncProgress;
@synthesize syncTypeInProgress = _syncTypeInProgress;

@synthesize data_sync_type;
@synthesize Enable_aggresssiveSync;
@synthesize code_snippet_ids;
@synthesize get_trigger_code;
@synthesize dod_status,dod_req_response_ststus;
@synthesize serviceReportReference;
@synthesize allpagelevelEventsWithTimestamp;
@synthesize internetAlertFlag;
@synthesize current_userId;
@synthesize connection_error;
@synthesize userProfileId;
@synthesize didCheckProfile;

@synthesize isSpecialSyncDone;

@synthesize reloadTable;
@synthesize internetConflictExists;
@synthesize internet_Conflicts;


///can remove
@synthesize isServerInValid;


@synthesize _pingServer;

@synthesize dataBase;
@synthesize isIncrementalMetaSyncInProgress;
@synthesize isInitialMetaSyncInProgress;
@synthesize isMetaSyncExceptionCalled;
@synthesize firstTimeCallForTags;
@synthesize afterSavePageEventsBinging;
@synthesize afterSavePageLevelEvents;
@synthesize IsSSL_error;
@synthesize Sync_check_in;
@synthesize initial_sync_status;
@synthesize IsLogedIn;
@synthesize data_sync_chunking;
@synthesize do_meta_data_sync;
@synthesize isForeGround;
@synthesize isBackground;
@synthesize logoutFlag;
@synthesize didFinishWithError;
@synthesize initital_sync_object_name;
@synthesize initial_dataSync_reqid;
@synthesize initial_Sync_last_index;
@synthesize initial_sync_succes_or_failed;
@synthesize download_tags_done;
@synthesize metaSyncThread;
@synthesize metasync_timer;
@synthesize sfmSearchTableArray;
@synthesize initialEventMappinArray, newEventMappinArray;

@synthesize exception;
@synthesize _manualDataSync;
@synthesize last_initial_data_sync_time;
@synthesize settingsDict;
@synthesize syncThread;
@synthesize showUI;   //btn merge
@synthesize dPicklist_retrieval_complete;
@synthesize special_incremental_thread;
@synthesize didincrementalmetasyncdone;
@synthesize incrementalSync_Failed;
@synthesize datasync_timer;
@synthesize Incremental_sync_status;
@synthesize SyncStatus = _SyncStatus;
@synthesize Incremental_sync,temp_incremental_sync;
@synthesize dataSync_dict;
@synthesize view_layout_array;
@synthesize sourceRecordId;
@synthesize sourceProcessId;
@synthesize databaseInterface;
@synthesize SFMoffline;
@synthesize isWorkinginOffline;
@synthesize didsubmitModelView;
@synthesize WorkDescription;
@synthesize reference_field_names;
@synthesize didProcessWorkOrderData;
@synthesize fieldNameTypeArray;
@synthesize workOrderUpdateData;
@synthesize workOrderData;
@synthesize offline;
@synthesize currentProcessID;
@synthesize SVMX_Version;
@synthesize didGetVersion;
//for Localization
@synthesize newProcessIdForEdit,newRecordIdForEdit;
@synthesize loginResult;
@synthesize createProcess;
@synthesize window;
@synthesize viewController;
@synthesize loggedInUserId;
@synthesize _iOSObject;
@synthesize deleted_detail_Fields;
@synthesize username, password, savedReference, kRestoreLocationKey;
@synthesize sfmSave;
@synthesize cancel_save;
@synthesize locationid, currentWorkOrderId;
// @synthesize technicianid, serviceTeamId;
@synthesize appTechnicianId, appServiceTeamId;
@synthesize objectNames_array,StandAloneCreateProcess;
@synthesize tempSummary;

@synthesize isSFMReloading;
@synthesize technicianAddress;
@synthesize oldProcessId,oldRecordId;

@synthesize didDayViewUnload, didMapViewUnload, didJobViewUnload, didTroubleshootingUnload, didProductManualUnload, didChatterUnload, didDebriefUnload, didSFMUnload;
@synthesize lastSelectedDate, troubleshootProductName;

// Service Report Logo
@synthesize serviceReportLogo;

// Refresh Calendar;
@synthesize refreshCalendar, modalCalendar, dateClicked;

// SFM Page properties
@synthesize sfmPageController;
@synthesize wsInterface, dict, headerArray, linesArray;
@synthesize SFMPage;
@synthesize describeObjectsArray;

// Lookup History
@synthesize lookupHistory;

@synthesize lookupData;

//MulitiAdd Rows
@synthesize objectName;

// Standalone Create
@synthesize  didCreateStandalone;

// Sahana
@synthesize sfmSaveError;
@synthesize additionalInfo;
//radha save object
@synthesize recentObject;
@synthesize createObjectContext;

@synthesize objectLabelName_array;
@synthesize objectLabel_array;
// Debriefing
@synthesize Dictionaries, timeAndMaterial, usageConsumptionRecordId;
@synthesize partsZKSArray, laborZKSArray, expensesZKSArray;
@synthesize workOrderCurrency;
@synthesize Parts, Labour, Expenses;
@synthesize priceBookName;
@synthesize productIdList;
@synthesize addressType;
@synthesize serviceReportValueMapping;
@synthesize workOrderDescription;
@synthesize serviceReport;
@synthesize currentUserName, loggedInOrg;
@synthesize cur_nameField,cur_Field_label;

@synthesize currentServerUrl;
@synthesize newRecordId,newProcessId;

// For Service Report
@synthesize soqlQuery;

//Mapview
@synthesize workOrderEventArray;
@synthesize workOrderInfo;

@synthesize firstUsername;

// DORMA
@synthesize signatureCaptureUpload;

// Switch View Layouts
@synthesize switchViewLayouts;

@synthesize userNameImageList;

@synthesize isDetailActive;

@synthesize connectionAvailable;

@synthesize allURLConnectionsArray;
@synthesize db;
//Database
@synthesize calDataBase;
//@synthesize dataBase;

//shrinivas
@synthesize isConnectedOnline;
@synthesize didLoginAgain;
@synthesize didBackUpDatabase;
@synthesize shouldShowConnectivityStatus;

@synthesize EventsArray, TasksArray;
@synthesize speacialSyncIsGoingOn;

//Radha - Siva
@synthesize hostReach;
@synthesize internetReach;
@synthesize onlineDataArray;

@synthesize event_timer;
@synthesize event_thread;

@synthesize eventSyncRunning, metaSyncRunning, dataSyncRunning;
@synthesize queue_object, queue_selector;

@synthesize animatedImageView;
@synthesize enableLocationService;
@synthesize frequencyLocationService;
@synthesize metaSyncCompleted;
@synthesize From_SFM_Search;
@synthesize errorDescription;
@synthesize language;
@synthesize isSfmSearchSortingAvailable;
//Shrinivas : OAuth.
@synthesize oauthClient;
@synthesize session_Id;
@synthesize apiURl;
@synthesize refresh_token;
@synthesize organization_Id;
@synthesize sessionExpiry;
@synthesize OAuthController;
@synthesize htmlString;
@synthesize refreshHomeIcons;
@synthesize refreshIcons;
@synthesize userOrg;
@synthesize isUserOnAuthenticationPage;
@synthesize customURLValue;


-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskLandscapeRight || UIInterfaceOrientationMaskLandscapeLeft);
}

-(NSString *)getUSerInfoForKey:(NSString *)key
{
    NSString * rootpath_SYNHIST = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:USER_INFO_PLIST];
    NSDictionary * dict = [[[NSDictionary alloc] initWithContentsOfFile:plistPath_SYNHIST] autorelease];
    NSArray * allkeys = [dict allKeys];
    for(NSString * str in allkeys)
    {
        SMLog(@"str-%@",str);
    }
    NSString * value = [[dict objectForKey:key] retain];
    return value;
}

//Changed krishna.
#pragma mark - Client info param
//Request paremeters for client Info

NSString* machineName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}
- (NSString *) getDeviceVersion {
    
    
    NSString *myIpad = machineName();
    return myIpad;
}
- (NSDictionary *)getClientInfoDict {
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    NSString *type = [currentDevice model];
    
    NSString *systemOSVersion = [currentDevice systemVersion];
    
    NSString *appVersion = [[NSBundle mainBundle]
                            objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    NSString *deviceVersion = [self getDeviceVersion];
    
    NSLog(@"model : %@ systemVersion : %@ appversion %@",type,systemOSVersion,appVersion);
    
    
    NSString *str = [NSString stringWithFormat:@"model : %@ systemVersion : %@ appversion %@ iPadVersion %@",type,systemOSVersion,appVersion,deviceVersion];
    
    NSLog(@"string %@",str);
    
    NSMutableDictionary *clientInfodict = [NSMutableDictionary dictionary];
    [clientInfodict setObject:type forKey:deviceType];
    [clientInfodict setObject:systemOSVersion forKey:osVersion];
    [clientInfodict setObject:appVersion forKey:applicationVersion];
    [clientInfodict setObject:deviceVersion forKey:devVersion];
    return clientInfodict;
}
//create new object
- (INTF_WebServicesDefServiceSvc_SVMXClient  *) getSVMXClientObject
{
    //ADD SVMXClient
    return svmxc_client;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//RADHA Defect Fix 5542
	self.shouldScheduleTimer = NO;
	self.isDataSyncTimerTriggered = NO;
	
    Enable_aggresssiveSync = FALSE;
    appDelegate = self;
    appDelegate.code_snippet_ids = nil;
    self.isBackground = FALSE;
    errorDescription=@"";
    // Check for internet connection here
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    /////////////////////////////////////////////////////////////////
    //////////// REGISTER FOR REACHABILITY NOTIFICATIONS ////////////
    /////////////////////////////////////////////////////////////////
    
    self.logoutFlag = FALSE;
    // Check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reachabilityChanged:) 
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    hostReach = [[Reachability reachabilityWithHostName: @"www.salesforce.com"] retain];
	[hostReach startNotifier];
	[self updateInterfaceWithReachability:hostReach];
	
    internetReach = [[Reachability reachabilityForInternetConnection] retain];
	[internetReach startNotifier];
	[self updateInterfaceWithReachability:internetReach];
    
    //    wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
    //	[wifiReach startNotifier];
    //	[self updateInterfaceWithReachability:wifiReach];
    [self registerDefaultsFromSettingsBundle]; //Siva Manne
    didFinishWithError = FALSE;
    
    signatureCaptureUpload = YES;
    workOrderEventArray = [[NSMutableArray alloc] initWithCapacity:0];
    workOrderInfo = [[NSMutableArray alloc] initWithCapacity:0];
    self.firstUsername = nil;
    
    self.wsInterface = [[WSInterface alloc] init];
    wsInterface.delegate = self;
    
    dataBase = [[DataBase alloc] init];
    calDataBase = [[CalendarDatabase alloc] init];

    wsInterface.tagsDictionary = [wsInterface getDefaultTags];
    if (settingsDict == nil)
        settingsDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    
    if (initialEventMappinArray == nil)
        initialEventMappinArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (newEventMappinArray == nil)
        newEventMappinArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (reference_field_names == nil)
        reference_field_names = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    isInitialMetaSyncInProgress = FALSE;
    isIncrementalMetaSyncInProgress = FALSE;
    isMetaSyncExceptionCalled = FALSE;
    isSpecialSyncDone = FALSE;
    metaSyncRunning = NO;
    self.From_SFM_Search = @"";
    
    self.didCheckProfile = FALSE;
    
	//Radha Progress Bar
	self.syncTypeInProgress = NO_SYNCINPROGRESS;
	
	
    [self initWithDBName:DATABASENAME1 type:DATABASETYPE1];
        
    //sahana
    databaseInterface  = [[databaseIntefaceSfm alloc] init];
    
       
    // Override point for customization after app launch    
    //[window addSubview:viewController.view];
    
    
    // Load recently created objects
    NSString * rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath = [rootPath stringByAppendingPathComponent:OBJECT_HISTORY_PLIST];
    recentObject = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    
    // Load Switch View Layouts cache
    plistPath = [rootPath stringByAppendingPathComponent:SWITCH_VIEW_LAYOUTS_PLIST];
    switchViewLayouts = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];

    
    _iOSObject = [[iOSInterfaceObject alloc] init];
    
    // Restore operation for memory warnings
    if (lastSelectedDate == nil)
        lastSelectedDate = [[NSMutableArray alloc] initWithCapacity:0];
   
    refreshCalendar = NO;
    
    allURLConnectionsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    //sahana  - Data Sync
    syncThread = nil;
    
    special_incremental_thread = nil;
    
    metaSyncThread = nil;
    
    _manualDataSync = [[ManualDataSync alloc] init];   //btn merge
    
    self.internet_Conflicts = [self.calDataBase getInternetConflicts];
    SMLog(@"%@", self.internet_Conflicts);
    
    if ([self.internet_Conflicts count] > 0 )
    {
        [self.calDataBase removeInternetConflicts];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerHandler:) name:NOTIFICATION_TIMER_INVALIDATE object:nil];
    
    //Changed krishna.
    //set client info at the begining of the app
    
    svmxc_client = [[INTF_WebServicesDefServiceSvc_SVMXClient alloc] init];

    NSDictionary *clientInfoDict = [self getClientInfoDict];
    svmxc_client.clientType = [clientInfoDict objectForKey:deviceType];//@"iPad";
    [svmxc_client.clientInfo addObject:[clientInfoDict objectForKey:osVersion]];
    [svmxc_client.clientInfo addObject:[clientInfoDict objectForKey:applicationVersion]];
    [svmxc_client.clientInfo addObject:[clientInfoDict objectForKey:devVersion]];

	//Shrinivas : OAuth.
	self.isUserOnAuthenticationPage = FALSE;
	self.refreshHomeIcons = NO;
	
	oauthClient = [[OAuthClientInterface alloc] init];
	OAuthController = [[UIViewController alloc] init];
	
	//Auto Login incase user has already authorized.
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSString *accessToken  = [userDefaults valueForKey:ACCESS_TOKEN];
	NSString *refreshToken = [SFHFKeychainUtils getValueForIdentifier:KEYCHAIN_SERVICE];
	NSString *preference = [userDefaults valueForKey:@"preference_identifier"];
	
	userOrg = [userDefaults valueForKey:USER_ORG]; //Read the user org here to check for correct org :
	
	NSMutableDictionary * temp_dict = [self.wsInterface getDefaultTags];
	self.wsInterface.tagsDictionary = temp_dict;

	//Auto Login
	if ( accessToken != nil )
	{
		//[self addBackgroundImageAndLogo]; 16/May/2013 : To remove the background image.
		NSString *local_Id = [userDefaults valueForKey:LOCAL_ID];
		NSString *userName = [appDelegate.dataBase getUserNameFromUserTable:local_Id];
		
		//Fix for defect #7078
		if ( userName == nil || [userName isEqualToString:@""])
		{
			userName = [userDefaults valueForKey:@"UserFullName"];
		}

		//Initializing the varibales for Auto Login:
		self.language         = [userDefaults valueForKey:@"UserLanguage"];
		self.apiURl           = [userDefaults valueForKey:API_URL];
		self.currentServerUrl = [userDefaults valueForKey:SERVERURL];
		self.current_userId   = [userDefaults valueForKey:CURRENT_USER_ID];
		self.organization_Id  = [userDefaults valueForKey:ORGANIZATION_ID];
		self.currentUserName  = [userDefaults valueForKey:@"UserFullName"];
		self.loggedInUserId   = [userDefaults valueForKey:CURRENT_USER_ID];		
		self.refresh_token    = refreshToken;
		self.session_Id       = accessToken;
		self.username         = [userDefaults valueForKey:@"UserFullName"];
		
		//Re-write the users org incase he has changed it accidently : 
		if ( ![userOrg isEqualToString:preference] )
		{
			[userDefaults setValue:userOrg forKey:@"preference_identifier"];
		}
		
		[oauthClient refreshAccessToken:refreshToken];
		
		BOOL retVal = [appDelegate.calDataBase isUsernameValid:userName];
        
        if ( retVal == FALSE )
		{
			[appDelegate.dataBase deleteDatabase:DATABASENAME1];
			[appDelegate initWithDBName:DATABASENAME1 type:DATABASETYPE1];
			[self removeSyncHistoryPlist];
			[self updateSyncFailedFlag:SFALSE];

			self.do_meta_data_sync = ALLOW_META_AND_DATA_SYNC;
			
			[self performInitialSynchronization];

		}

		self.IsLogedIn = ISLOGEDIN_TRUE;
		
		ZKServerSwitchboard *switchBoard = [[ZKServerSwitchboard switchboard] init];
		switchBoard.logXMLInOut = TRUE;
		
		homeScreenView = nil;
		//Changed 
		self.serviceReportLogo = [[[UIImage alloc] initWithData:[self.dataBase serviceReportLogoInDB]]autorelease];
		
		if ( homeScreenView == nil )
		{
			[window setRootViewController:OAuthController];
			[window makeKeyAndVisible];
			
			homeScreenView = [[iPadScrollerViewController alloc] initWithNibName:@"iPadScrollerViewController" bundle:nil];
			homeScreenView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
			homeScreenView.modalPresentationStyle = UIModalPresentationFullScreen;
			[OAuthController presentViewController:homeScreenView animated:YES completion:nil];
			refreshIcons = homeScreenView;
			[homeScreenView release];
			
			//[self removeBackgroundImageAndLogo];
			return TRUE;
		}
		
	}

	[oauthClient initWithClientID:CLIENT_ID secret:CLIENT_SECRET redirectURL:REDIRECT_URL];
	[self performAuthorization];
	
	return YES;
}


#pragma mark - Open Authorization Methods :
- (void) performAuthorization
{
	[oauthClient userAuthorizationRequestWithParameters:nil];
	[self showScreen];
	
}

//OAuth
-(void)showScreen
{
	//[self addBackgroundImageAndLogo];
	[OAuthController.view addSubview:oauthClient.view];
	
	[window setRootViewController:OAuthController];
	[window makeKeyAndVisible];
	
}

//OAuth
-(void)showSalesforcePage
{	
	//Revoke the Tokens in Case user decides to cancel switching to a new user OR Incase user denies Access.
	[oauthClient deleteAllCookies];
	if ( appDelegate.refresh_token )
	{
		[appDelegate.oauthClient revokeExistingToken:appDelegate.refresh_token];
	}
	
	[self.oauthClient.view removeFromSuperview];
	//[self addBackgroundImageAndLogo];
	[self.oauthClient initWithClientID:CLIENT_ID secret:CLIENT_SECRET redirectURL:REDIRECT_URL];
	[self.oauthClient userAuthorizationRequestWithParameters:nil];
	
	[self.OAuthController.view addSubview:self.oauthClient.view];
}

//OAuth
-(void)didLoginWithOAuth
{
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
	
	[userDefaults setObject:self.currentServerUrl forKey:SERVERURL];
	[userDefaults setObject:self.currentUserName forKey:@"UserFullName"];
    [userDefaults setObject:self.language forKey:@"UserLanguage"];
	[userDefaults setObject:self.session_Id forKey:ACCESS_TOKEN];
	[userDefaults setObject:self.current_userId forKey:CURRENT_USER_ID];
	[userDefaults setObject:self.organization_Id forKey:ORGANIZATION_ID];
	[userDefaults setObject:self.apiURl forKey:API_URL];
	[userDefaults setObject:self.userOrg forKey:USER_ORG];
	[userDefaults setObject:oauthClient.identityURL forKey:IDENTITY_URL];
    [userDefaults synchronize];
	
	[SFHFKeychainUtils deleteKeychainValue:KEYCHAIN_SERVICE];
	[SFHFKeychainUtils createKeychainValue:self.refresh_token forIdentifier:KEYCHAIN_SERVICE];
	
	self.refresh_token = [SFHFKeychainUtils getValueForIdentifier:KEYCHAIN_SERVICE];
	SMLog(@"Refresh Token : %@", self.refresh_token);
	
    self.didLoginAgain = TRUE;
	
	[self.oauthClient.view removeFromSuperview];
	[self.oauthClient.view release];
	self.oauthClient.view = nil;
	
	[self performInitialLogin];	
}

//OAuth
-(void)performInitialLogin
{
	if ( homeScreenView )
	{
		homeScreenView = nil;
	}
	
	self.IsSSL_error = FALSE;
	self.IsLogedIn = ISLOGEDIN_TRUE;
	
    self.wsInterface.didOpComplete = FALSE;
	
	self.connection_error = FALSE; //CHANGED FOR DEFECT #5786 --> 29/JAN/2013
	
    if (self.isBackground == TRUE)
        self.isBackground = FALSE;
    
    if (self.isForeGround == TRUE)
        self.isForeGround = FALSE;
		
    self.last_initial_data_sync_time = nil;
	
	
	_continueFalg = TRUE;
    BOOL ContinueLogin = [self checkSwitchUser];
	
	if ( _continueFalg == FALSE  )
	{
		self.do_meta_data_sync = DONT_ALLOW_META_DATA_SYNC;
		
		[self showSalesforcePage];
		
		return;
	}
		
	if ( ContinueLogin )
	{
		[self.dataBase deleteDatabase:DATABASENAME1];
		[self removeSyncHistoryPlist];
		[self initWithDBName:DATABASENAME1 type:DATABASETYPE1];
		[self updateSyncFailedFlag:SFALSE];

		self.do_meta_data_sync = ALLOW_META_AND_DATA_SYNC;
				
		//GET VERSION :
		BOOL checkVersion = [self checkVersion];
		
		if ( checkVersion == NO )
		{
			return;
		}
		
		//GET PROFILE : 
		self.didCheckProfile = FALSE;
		self.userProfileId = @"";
		
		//Dont remove the code in the comments below
		[self.wsInterface checkIfProfileExistsWithEventName:VALIDATE_PROFILE type:GROUP_PROFILE];
		
		while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
		{
			if (![self isInternetConnectionAvailable])
			{
				self.shouldShowConnectivityStatus = YES;
				[self displayNoInternetAvailable];
				return;
			}
			
			if (self.didCheckProfile)
			{
				break;
			}
			if (self.connection_error)
			{
				break;
			}
		}
		
		if ([self.userProfileId length] == 0)
		{
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
				
			//Removed the code for profile error : Defect #7086
			
			[userDefaults removeObjectForKey:ACCESS_TOKEN];
			[userDefaults removeObjectForKey:SERVERURL];
			[userDefaults removeObjectForKey:ORGANIZATION_ID];
			[userDefaults removeObjectForKey:API_URL];
			[userDefaults removeObjectForKey:USER_ORG];
			[userDefaults removeObjectForKey:IDENTITY_URL];
			[userDefaults synchronize];
			[self.oauthClient deleteAllCookies];
			[self showSalesforcePage];

			
			return;
		}
		
		//GET TAGS :
		[self getTagsForTheFirstTime];
		
		[self.dataBase getImageForServiceReportLogo]; //Get logo only for Initial sync.
		
	}
	else
	{
		self.do_meta_data_sync = DONT_ALLOW_META_DATA_SYNC;
		
		self.serviceReportLogo = [[[UIImage alloc] initWithData:[self.dataBase serviceReportLogoInDB]] autorelease]; //Get logo from DB if no Initial sync is performed.
	}
		
	ZKServerSwitchboard *switchBoard = [[ZKServerSwitchboard switchboard] init];
	switchBoard.logXMLInOut = TRUE;
	
	//[self.dataBase getImageForServiceReportLogo]; //Commenting the code 20/May/2013.
	
	if ( homeScreenView == nil )
    {
        homeScreenView = [[iPadScrollerViewController alloc] initWithNibName:@"iPadScrollerViewController" bundle:nil];
        homeScreenView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        homeScreenView.modalPresentationStyle = UIModalPresentationFullScreen;
        [OAuthController presentViewController:homeScreenView animated:YES completion:nil];
		refreshIcons = homeScreenView;
        [homeScreenView release];
		
		//[self removeBackgroundImageAndLogo];
		
    }
	
}

//SHRINVIAS : OAuth :
-(void)performInitialSynchronization
{	
	//GET VERSION : 
	BOOL checkVersion = [self checkVersion];
	
	if ( checkVersion == NO )
	{
		return;
	}
	
	// GET PROFILE : 
	self.didCheckProfile = FALSE;
	self.userProfileId = @"";
	
	//Dont remove the code in the comments below
	[self.wsInterface checkIfProfileExistsWithEventName:VALIDATE_PROFILE type:GROUP_PROFILE];
	
	while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
	{
		if (![self isInternetConnectionAvailable])
		{
			self.shouldShowConnectivityStatus = YES;
			[self displayNoInternetAvailable];
			return;
		}
		
		if (self.didCheckProfile)
		{
			break;
		}
		if (self.connection_error)
		{
			break;
		}
	}
	
	if ([self.userProfileId length] == 0)
	{
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		
		//Fix for defect #7086
		/*
		UIAlertView * _alert = [[UIAlertView alloc] initWithTitle:[self.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_TITLE] message:[self.wsInterface.tagsDictionary objectForKey:profile_error] delegate:nil cancelButtonTitle:ALERT_ERROR_OK_DEFAULT otherButtonTitles:nil];
		
		[_alert show];
		[_alert release];
		 */
		
		[userDefaults removeObjectForKey:ACCESS_TOKEN];
		[userDefaults removeObjectForKey:SERVERURL];
		[userDefaults removeObjectForKey:ORGANIZATION_ID];
		[userDefaults removeObjectForKey:API_URL];
		[userDefaults removeObjectForKey:USER_ORG];
		[userDefaults removeObjectForKey:IDENTITY_URL];
		[userDefaults synchronize];
		[self.oauthClient deleteAllCookies];
		[self showSalesforcePage];

		
		return;
	}
	
	//GET TAGS FOR FIRST TIME :
	[self getTagsForTheFirstTime];

}

-(void)getTagsForTheFirstTime
{
	self.download_tags_done = FALSE;
    self.firstTimeCallForTags = TRUE;
    [self.wsInterface metaSyncWithEventName:MOBILE_DEVICE_TAGS eventType:SYNC values:nil];
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
        if(self.download_tags_done)
            break;
    }
    self.firstTimeCallForTags= FALSE;

}


//Shrinivas : OAuth
- (BOOL)checkSwitchUser
{
	//Shrinivas : OAuth.
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSString *local_Id = [userDefaults valueForKey:LOCAL_ID];
	NSString *userName = [self.dataBase getUserNameFromUserTable:local_Id];
	
	//Fix for Defect #:7076 - 15/May/2013
	if ( userName == nil || [userName isEqualToString:@""])
	{
		//Reading the previous user's username if exists in the keychain.
		NSError * error = nil;
		previousUser = [SFHFKeychainUtils getPasswordForUsername:@"username"
										  andServiceName:KEYCHAIN_SERVICE_NAME error:&error];
		
		userName = previousUser;
		
		//Defect #:7129
		BOOL retVal = [self.calDataBase isUsernameValid:userName];
        
        	if ( retVal == FALSE )
		{
			NSError *error;
			[SFHFKeychainUtils deleteItemForUsername:@"username" andServiceName:KEYCHAIN_SERVICE_NAME error:&error];
			[SFHFKeychainUtils deleteItemForUsername:@"password" andServiceName:KEYCHAIN_SERVICE_NAME error:&error];
			
			return TRUE;
			
		}


	}
	
	if ( ![userName isEqualToString:@""] )
	{
		if ( ![self.currentUserName isEqualToString:userName] )
		{
			if ( [self handleSwitchUser] )
			{
				//Since User has allowed Switching : Deleting the database and continuing with new User.				
				if( ![self isInternetConnectionAvailable] )
				{
					[self displayNoInternetAvailable];
					return FALSE;
				}
												
				self.do_meta_data_sync = ALLOW_META_AND_DATA_SYNC;
				
				return TRUE;
			}
			else
			{
				return FALSE;
			}
		}
	}
	else
	{
		BOOL retVal = [self.calDataBase isUsernameValid:self.currentUserName];
        
        if ( retVal == FALSE )
		{
			return TRUE;
		}
			
	}
	
	return FALSE;
}

//Shrinivas : OAuth.
- (BOOL) handleSwitchUser
{
	switchUser = TRUE;
	NSString * description = [self.wsInterface.tagsDictionary objectForKey:login_switch_user];
	NSString * title = [self.wsInterface.tagsDictionary objectForKey:alert_switch_user];
	NSString * Ok = [self.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE];
	NSString * continue_ = [self.wsInterface.tagsDictionary objectForKey:login_continue];
	
	UIAlertView * _alert = [[UIAlertView alloc] initWithTitle:title message:description delegate:self cancelButtonTitle:continue_ otherButtonTitles:Ok, nil];
	
	[_alert show];
	[_alert release];
	
	
	_didEnterAlertView = TRUE;
	
	_didDismissalertview = FALSE;
	
    if ( _didEnterAlertView )
    {
        while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, FALSE))
        {
            SMLog(@"alert for switch user");
            if ( _didDismissalertview == TRUE )
            {
                _didDismissalertview = FALSE;
                break;
            }
        }
    }
	
	if ( _didEnterAlertView && _continueFalg )
	{
		return TRUE;
	}
	else if ( _continueFalg == FALSE )
		return FALSE;
	
	return FALSE;

}

//Shrinivas : OAuth.
-(void)removeSyncHistoryPlist
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath = [rootPath stringByAppendingPathComponent:SYNC_HISTORY];
    NSError  * delete_error;
	
    if ([fileManager fileExistsAtPath:plistPath] == YES)
    {
        [fileManager removeItemAtPath:plistPath error:&delete_error];
    }
    
}


//Shrinivas : OAuth
-(BOOL)checkVersion
{
	self.didGetVersion = FALSE;
	
    [self.wsInterface getSvmxVersion];
	
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
        //shrinivas
        if (self.isForeGround == TRUE)
        {
            self.didFinishWithError = FALSE;
            return NO;
        }
		
        if ( ![self isInternetConnectionAvailable] )
            return NO;
		
        SMLog (@"LoginViewController checkVersion in while loop");
		
        if ( self.didGetVersion )
            break;
		
        SMLog ( @"4" );
    }
    
    NSString * stringNumber = [self.SVMX_Version stringByReplacingOccurrencesOfString:@"." withString:@""];
	
    int _stringNumber = [stringNumber intValue];
    int version = (APPVERSION * 100000);
	
    if( _stringNumber >= version )
    {
        SMLog(@"greater than %f", APPVERSION);
		
        self.wsInterface.isLoggedIn = YES;
		
        SMLog(@"Installed Package Version = %@",stringNumber);
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		
        if ( userDefaults )
        {
            [userDefaults setObject:stringNumber forKey:kPkgVersionCheckForGPS_AND_SFM_SEARCH];
            SMLog(@"Installed Package Version = %@",stringNumber);
        }
        else
        {
            SMLog(@"Getting User Defaults Failed");
        }
		
        return YES;
    }
    else
    {
        NSString * title = [self.wsInterface.tagsDictionary objectForKey:login_incorrect_version];
        NSString * ipad_version = [self.wsInterface.tagsDictionary objectForKey:login_ipad_app_version];
        NSString * servicemax_version = [self.wsInterface.tagsDictionary objectForKey:login_serivcemax_version];
        
        // Read version info from plist
        NSString * version_app  = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
        
        NSString * message  = [NSString stringWithFormat:@"%@ %@  %@ %.5f .",ipad_version, version_app , servicemax_version,APPVERSION];
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message  delegate:self cancelButtonTitle:ALERT_ERROR_OK_DEFAULT otherButtonTitles:nil, nil];
		
        [alertView show];
        [alertView release];
		
        SMLog(@"lesser than %f", APPVERSION);
		
        return NO;
    }
    
    return NO;
}

-(void)addBackgroundImageAndLogo
{
	if (backGround != nil)
	{
		[servicemaxLogo setImage:[UIImage imageNamed:@"logo.png"]];
		[backGround setImage:[UIImage imageNamed:@"dashboard-main-app-cloud-bg.png"]];
	}
	else
	{
		backGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dashboard-main-app-cloud-bg.png"]];
		backGround.transform = CGAffineTransformMakeRotation(3.14/2);
		backGround.frame = CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height);
		
		CGRect servicemaxLogoFrame = CGRectMake(432, 20, 441, 96);
		
		servicemaxLogo = [[UIImageView alloc] initWithFrame:servicemaxLogoFrame];
		servicemaxLogo.contentMode = UIViewContentModeScaleAspectFit;
		servicemaxLogo.image = [UIImage imageNamed:@"logo.png"];
		[backGround addSubview:servicemaxLogo];
		
		[self.window addSubview:backGround];

	}
	
}

-(void)removeBackgroundImageAndLogo
{
	[servicemaxLogo setImage:nil];
	[backGround setImage:nil];
}

#pragma mark - END


//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability:curReach];
}

- (BOOL) isReachable:(Reachability *)curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
//    NSString* statusString= @"";
    switch (netStatus)
    {
        case NotReachable:
        {
//            statusString = @"Access Not Available";
            return NO;
        }
        case ReachableViaWWAN:
        {
//            statusString = @"Reachable WWAN";
            return YES;
        }
        case ReachableViaWiFi:
        {
//            statusString = @"Reachable WiFi";
            return YES;
        }
    }

    return NO;
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    NSString* statusString= @"";
    switch (netStatus)
    {
        case NotReachable:
        {
            statusString = @"Access Not Available";
            //isInternetConnectionAvailable = NO;
            [self PostInternetNotificationUnavailable];
            break;
        }
        case ReachableViaWWAN:
            statusString = @"Reachable WWAN";
        case ReachableViaWiFi:
            statusString = @"Reachable WiFi";
            //isInternetConnectionAvailable = YES;
            [self PostInternetNotificationAvailable];
            break;
    }
}

- (void) PostInternetNotificationUnavailable
{
    self.internet_Conflicts = [self.calDataBase getInternetConflicts];
	
	//OAuth.
	if ( homeScreenView != nil && self.refreshHomeIcons )
	{
		if ( [refreshIcons respondsToSelector:@selector(RefreshIcons)])
		{
			[refreshIcons RefreshIcons];
		}

	}
	
    [[NSNotificationCenter defaultCenter] postNotificationName:kInternetConnectionChanged object:[NSNumber numberWithInt:0] userInfo:nil];
}

- (void) PostInternetNotificationAvailable
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kInternetConnectionChanged object:[NSNumber numberWithInt:1] userInfo:nil];
    
    if ([self.internet_Conflicts count] > 0)
    {
        [self.calDataBase removeInternetConflicts];
        [self.internet_Conflicts removeAllObjects];
        
        //self.SyncStatus = SYNC_GREEN;
        
        [self.reloadTable ReloadSyncTable];
        [self setSyncStatus:SYNC_GREEN];
        //[self.wsInterface.refreshSyncButton showSyncStatusButton]; 
        //[self.wsInterface.refreshModalStatusButton showModalSyncStatus];
        //[self.wsInterface.refreshSyncStatusUIButton showSyncUIStatus];
    }
//OAuth.
	if ( homeScreenView != nil && self.refreshHomeIcons )
	{
		if ( [refreshIcons respondsToSelector:@selector(RefreshIcons)])
		{
			[refreshIcons RefreshIcons];
		}
		
	}

    
}

- (void) didFinishGetEvents
{
    [loginController showHomeScreenviewController];
}

- (void) applicationWillResignActive:(UIApplication *)application
{
    // Save Lookup History Cache 
}

- (void) applicationDidEnterBackground:(UIApplication *)application
{
   // [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    NSError * error = nil;
    for (NSString * userName in userNameImageList)
    {
        // delete the image file if it already exists
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectoryPath = [paths objectAtIndex:0];
        NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", userName, @".png"]];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filePath error:&error];
    }
    
    [userNameImageList removeAllObjects];
    
    //shrinivas
    self.isBackground = TRUE;
    self.wsInterface.didOpComplete = FALSE;
    loginController.didEnterAlertView = FALSE;
}

- (void) applicationWillEnterForeground:(UIApplication *)application
{
    [loginController.activity stopAnimating];
    //shrinivas
	
    self.isForeGround = TRUE;
	//Shrinivas : OAuth
	[self performSelector:@selector(handleChangedConnection) withObject:nil afterDelay:0.1];
}

//Shrinivas : OAuth
-(void)handleChangedConnection
{
	//Shrinivas : OAuth :
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	if ( self.logoutFlag == TRUE || self.isUserOnAuthenticationPage == TRUE )
	{
		NSString * preference = [userDefaults valueForKey:@"preference_identifier"];
		
		if ( ![userOrg isEqualToString:preference] )
		{
			[oauthClient.view removeFromSuperview];
			[oauthClient deleteAllCookies];
			[oauthClient userAuthorizationRequestWithParameters:nil];
			[OAuthController.view addSubview:oauthClient.view];
		}
		else if ( [userOrg isEqualToString:@"Custom"] )
		{
			//For Defect #7085
			NSString *_baseURL = [ZKServerSwitchboard baseURL] ;
			if ( [appDelegate.customURLValue isEqualToString:_baseURL] )
			{
				//Do nothing
			}
			else
			{
				[oauthClient.view removeFromSuperview];
				[oauthClient deleteAllCookies];
				[oauthClient userAuthorizationRequestWithParameters:nil];
				[OAuthController.view addSubview:oauthClient.view];

			}
		}
		
		
	}
	else
	{
		NSString * preference = [userDefaults valueForKey:@"preference_identifier"];
		
		if ( [userOrg isEqualToString:preference] )
		{
			
		}
		else
		{
			//Rewrite the user's actual org to settings :
			[userDefaults setValue:userOrg forKey:@"preference_identifier"];
		}
	}

}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)registerDefaultsFromSettingsBundle 
{
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) 
    {
        //SMLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) 
    {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) 
        {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    [defaultsToRegister release];
}
- (BOOL) isInternetConnectionAvailable
{
    NSDate *date = [NSDate date];
    BOOL status = [Reachability connectivityStatus];
    if(!status)
    {
        NSURL *url = [NSURL URLWithString:@"http://www.salesforce.com"];
        NSURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSHTTPURLResponse *response = nil;
        [NSURLConnection sendSynchronousRequest:request
                              returningResponse:&response error:NULL];
        if(response != nil)
            status = TRUE;
    }
    NSString *internetStatus = status?@"Internet is reachable":@"Internet is not reachable";
    SMLog(@"[%f] %@",[[NSDate date] timeIntervalSinceDate:date],internetStatus);
    return status;
}

#pragma mark - wsInterface Delegate Methods
- (void) didFinishWithError:(SOAPFault *)sFault
{
    NSString *   soap_fault =  sFault.faultstring;
//    if([soap_fault Contains:@"System.LimitException"])
//    {
//        soap_fault = @"Meta Sync Failed Due To Too Many Script. Please contact your System Administrator.";
//       // self.didFinishWithError = TRUE;
//    }
    NSString * response_error = [self.wsInterface.tagsDictionary objectForKey:ALERT_RESPONSE_ERROR];
    NSString * alert_ok = [self.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    UIAlertView * _alert = [[UIAlertView alloc] initWithTitle:response_error message:soap_fault delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
    [_alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    [_alert release];
}

-(void)popupActionSheet:(NSString *)message
{
    alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)dealloc
{
    if(loginController) [loginController release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_TIMER_INVALIDATE object:nil];
    [animatedImageView release];
    [sfmSearchTableArray release];
	[onlineDataArray release];
    [wsInterface release];
    [viewController release];
    [window release];
    [_manualDataSync release];
    [frequencyLocationService release];
    [locationPingSettingTimer invalidate];
    [svmxc_client release];
	[organization_Id release];
	[refresh_token release];
	[apiURl release];
	[session_Id release];
	[oauthClient release];
	[OAuthController release];
	[sessionExpiry release];
	[htmlString release];
	[userOrg release];
	[customURLValue release];
    [super dealloc];
}


- (UIColor *) colorForHex:(NSString *)hexColor
{
    // remove any ocurences of a leading # from hexColor
    hexColor = [hexColor stringByReplacingOccurrencesOfString:@"#" withString:@""];
	hexColor = [[hexColor stringByTrimmingCharactersInSet:
				 [NSCharacterSet whitespaceAndNewlineCharacterSet]
				 ] uppercaseString];  
	
    // String should be 6 or 7 characters if it includes '#'  
    if ([hexColor length] > 6) 
		return [UIColor whiteColor];  
	
	// if the value isn't 6 characters at this point return 
    // the color black	
    if ([hexColor length] != 6) 
		return [UIColor whiteColor];  
	
    // Separate into r, g, b substrings  
    NSRange range;  
    range.location = 0;  
    range.length = 2; 
	
    NSString *rString = [hexColor substringWithRange:range];  
	
    range.location = 2;  
    NSString *gString = [hexColor substringWithRange:range];  
	
    range.location = 4;  
    NSString *bString = [hexColor substringWithRange:range];  
	
    // Scan values  
    unsigned int r, g, b;  
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
	
    UIColor * color = [UIColor colorWithRed:((float) r / 255.0f)  
                                       green:((float) g / 255.0f)  
                                        blue:((float) b / 255.0f)  
                                       alpha:1.0f];
    return color;
}

- (void) displayNoInternetAvailable
{
    NSString * message = [wsInterface.tagsDictionary objectForKey:ALERT_INTERNET_NOT_AVAILABLE];
    NSString * cancelButtonTitle = [wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    NSString * title = [wsInterface.tagsDictionary objectForKey:alert_ipad_error];
    
    NSMutableDictionary * dictionary = [wsInterface getDefaultTags];
    
    if (message == nil)
    {
        message = [dictionary objectForKey:ALERT_INTERNET_NOT_AVAILABLE];
    }
    
    if (cancelButtonTitle == nil)
    {
        cancelButtonTitle = [dictionary objectForKey:ALERT_ERROR_OK];
    }
    
    //Probable solution for internet connectivity.
    if (self.shouldShowConnectivityStatus == TRUE)
    {
        UIAlertView * _alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
        [_alert show];
        [_alert release];
        
        self.shouldShowConnectivityStatus = FALSE;
    }
    
}

-(void)initWithDBName:(NSString *)name type:(NSString *)type 
{    
    NSError *error; 
    NSArray *searchPaths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolderPath = [searchPaths objectAtIndex: 0];
    dataBase.dbFilePath = @"";  
    dataBase.dbFilePath = [documentFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", DATABASENAME1, DATABASETYPE1]];
    
    BOOL success=[[NSFileManager defaultManager] fileExistsAtPath:dataBase.dbFilePath];
    if ( success)
    { 
        didBackUpDatabase = FALSE;
        SMLog(@"\n db exist in the path");		
    }
    else    //didn't find db, need to copy
    {
    
        NSString *backupDbPath = [[NSBundle mainBundle] pathForResource:DATABASENAME1 ofType:DATABASETYPE1]; 
        if (backupDbPath == nil) 
        {
            SMLog(@"\n db not able to create error");   
        }
        else 
        { 
            BOOL copiedBackupDb = [[NSFileManager defaultManager] copyItemAtPath:backupDbPath toPath:dataBase.dbFilePath error:&error]; 
            if (!copiedBackupDb) 
            {
                SMLog(@"Failed to create writable database");
                NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
            }
            else
            {
                SMLog(@"DATABASE IS SUCCESSUFULLY CREATED");
            }
        } 
        didBackUpDatabase = TRUE;
    }
    
    int ret = sqlite3_open ([dataBase.dbFilePath UTF8String],&db);
    if( ret != SQLITE_OK)
    { 
        SMLog (@"couldn't open db:");
        NSAssert(0, @"Database failed to open.");		//throw another exception here
        return;
    }
    return;
}

-(processInfo *) getViewProcessForObject:(NSString *)object_name record_id:(NSString *)recordId processId:(NSString *)LastprocessId_  isswitchProcess:(BOOL)isSwitchProcess
{
    
    NSString * process_id = @"";
    NSMutableArray * process_id_array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    if([LastprocessId_ isEqualToString:@""] || [LastprocessId_ length] == 0)
    {
        
    }
    else
        [process_id_array  insertObject:LastprocessId_ atIndex:0];
    processInfo * pinfo = [[[processInfo alloc] init] autorelease];
    BOOL  process_exists = FALSE;
    @try{
    for (NSDictionary * dict_ in self.view_layout_array)
    {
        NSString * process_id_temp = @"";
        NSString * viewLayoutObjectName = [dict_ objectForKey:SVMXC_OBJECT_NAME];
        if ([viewLayoutObjectName isEqualToString:object_name])
        {
            process_id_temp = [dict_ objectForKey:SVMXC_ProcessID];
            if(![LastprocessId_ isEqualToString:process_id_temp])
            {
                [process_id_array addObject:process_id_temp];
            }
        }
    }
    
    NSString * final_process_id = @"";
    for(int i = 0 ; i< [process_id_array count]; i++)
    {
        process_id = [process_id_array objectAtIndex:i];
        
        //get the page layout
        NSMutableDictionary * page_layoutInfo = [self.databaseInterface  queryProcessInfo:process_id object_name:object_name];
        
        //Radha
        if (page_layoutInfo == nil) 
        {
            /*
            process_exists = FALSE;
            final_process_id = process_id;
            break;
             */
            continue;
        }
        NSMutableDictionary * _header =  [page_layoutInfo objectForKey:@"header"];
        
        NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];
        
        NSString * layout_id = [_header objectForKey:gHEADER_HEADER_LAYOUT_ID];
        
        
        NSMutableDictionary * process_components = [self.databaseInterface getProcessComponentsForComponentType:TARGET process_id:process_id layoutId:layout_id objectName:headerObjName];
        
        NSString * expression_id = [process_components objectForKey:EXPRESSION_ID];
        

        BOOL flag = [self.databaseInterface EntryCriteriaForRecordFortableName:object_name record_id:recordId expression:expression_id];
        
        if(flag)
        {
            process_exists = TRUE;
            final_process_id = process_id;
            break;
        }
        
        
        if(isSwitchProcess && i == 0)
        {
            break;
        }

    }
  
    if(process_exists)
    {
        pinfo.process_exists = TRUE;
        pinfo.process_id = final_process_id; 
    }
    else
    {
        pinfo.process_exists = FALSE;
        pinfo.process_id = @"";
    }
    }@catch (NSException *exp) {
        SMLog(@"Exception Name iServiceAppDelegate :insertvaluesToPicklist %@",exp.name);
        SMLog(@"Exception Reason iServiceAppDelegate :insertvaluesToPicklist %@",exp.reason);
        [self CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    return pinfo;

}
+ (NSString *)GetUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return ( NSString *)string;
}

NSString * GO_Online = @"GO_Online";
- (BOOL) goOnlineIfRequired
{
	@synchronized(GO_Online)
	{
		_pingServer = TRUE;
		self.isServerInValid = FALSE;
		if (![appDelegate isInternetConnectionAvailable])
		{
			return FALSE;
		}
		else
		{
			[[ZKServerSwitchboard switchboard] doCheckSession];
			if (isSessionInavalid == YES)
			{
				didLoginAgain = NO;
                [ZKServerSwitchboard switchboard].logXMLInOut = NO;
				[[ZKServerSwitchboard switchboard] loginWithUsername:self.username password:self.password target:self selector:@selector(didLoginForServer:error:context:)];
				
				while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, FALSE))
				{
	#ifdef kPrintLogsDuringWebServiceCall
					SMLog(@"iServiceAppDelegate.m : doOnlineIfRequired: ZKS Check For Session");
	#endif

					if (![appDelegate isInternetConnectionAvailable])
					{
						break;
					}
					if(appDelegate.connection_error)
						break;
					SMLog(@"ReLogin");
					if (didLoginAgain)
						break;
					
					if (self.isServerInValid == TRUE)
					{
						break;
					}
				}
				[ZKServerSwitchboard switchboard].logXMLInOut = YES;
				
			}
			if (isServerInValid)
				return FALSE;
			else 
				return TRUE;
		   
		}
	}
}

- (BOOL) pingServer
{
    _pingServer = TRUE;
     
    didLoginAgain = NO;
    [ZKServerSwitchboard switchboard].logXMLInOut = NO;
    [[ZKServerSwitchboard switchboard] loginWithUsername:self.username password:self.password target:self selector:@selector(didLoginForServer:error:context:)];
    
    self.isServerInValid = FALSE;
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"iServiceAppDelegate.m : pingServer: ZKS Check For Session");
#endif

        if (![appDelegate isInternetConnectionAvailable ])
        {
            break;
        }  
        
        if (self.isServerInValid == TRUE)
        {
            break;
        }
        if(appDelegate.connection_error)
            break;
        if (didLoginAgain)
            break;
    }
    [ZKServerSwitchboard switchboard].logXMLInOut = YES;
    if (isServerInValid == TRUE)
    {
        self.isServerInValid = FALSE;
        return NO;
    }
    else
    {
        //isInternetConnectionAvailable = YES;
        return YES;
    }
}

- (void) didLoginForServer:(ZKLoginResult *)lr error:(NSError *)error context:(id)context
{
    if(error!=nil)
    {
        NSString * faultstring = [[error userInfo] objectForKey:@"faultstring"];
        NSString * faultcode = [[error userInfo] objectForKey:@"faultcode"];
        if(faultstring == nil && faultcode == nil)
        {
            NSString *errorDomain =	[error domain];
            NSInteger errorCode = [error code];
            if((errorCode == 0) && ([errorDomain caseInsensitiveCompare:@"APIError"] == NSOrderedSame))
            {
                faultstring = [error localizedDescription];
                faultcode = errorDomain;
            }
        }
        NSMutableDictionary *Errordict=[[NSMutableDictionary alloc]init];
        [Errordict setObject:faultcode forKey:@"ExpName"];
        [Errordict setObject:faultstring forKey:@"ExpReason"];
        NSMutableDictionary *dicttemp=[[NSMutableDictionary alloc]init];
        [dicttemp setObject:@"" forKey:@"userInfo"];
        [Errordict setObject:dicttemp forKey:@"userInfo"];
        [appDelegate CustomizeAletView:nil alertType:SOAP_ERROR Dict:Errordict exception:nil];
        [dicttemp release];
        [Errordict release];
        self._pingServer = FALSE;
        self.isServerInValid = TRUE;
        self.didLoginAgain = TRUE;
        connection_error = TRUE;
        return;
        
    }
    if (lr != nil)
    {
        self.loginResult = lr;
        NSString * serverUrl = [lr serverUrl];
        NSArray  * array = [serverUrl pathComponents];
        NSString * server = [NSString stringWithFormat:@"%@//%@", [array objectAtIndex:0], [array objectAtIndex:1]];
		
		self.currentServerUrl = @"";
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

		if( ![server Contains:@"null"] )
		{
			self.currentServerUrl = [NSString stringWithFormat:@"%@", server];
			[userDefaults setObject:self.currentServerUrl forKey:SERVERURL];
			[userDefaults synchronize];
		}
		
        ZKUserInfo * userInfo = [lr userInfo];
		
		if(userInfo)
		{
			self.current_userId = [NSString stringWithFormat:@"%@", userInfo.userId];
			self.currentUserName = [[userInfo fullName] mutableCopy];
            self.language=[userInfo language];
			[userDefaults setObject:appDelegate.currentUserName forKey:@"UserFullName"];
            [userDefaults setObject:appDelegate.language forKey:@"UserLanguage"];
        }
		connection_error = FALSE;
    }
    
	
	NSString * description = [[error userInfo] objectForKey:@"faultstring"];
	NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];

    //Shrinivas -- code for firewall
    if (lr == nil && self._pingServer == TRUE)
    {
		if ([description Contains:@"INVALID_LOGIN"])
		{
			UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:alert_authentication_error_] message:description delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
			[alertView show];
			[alertView release];
		}
		
        self._pingServer = FALSE;
        self.isServerInValid = TRUE;
        self.didLoginAgain = TRUE;
        connection_error = TRUE;
        return;
    }
	
	if ([self.internet_Conflicts count] > 0)
	{
		[self.internet_Conflicts removeAllObjects];
		[self.calDataBase removeInternetConflicts];
		[self.reloadTable ReloadSyncTable];
	}
    connection_error = FALSE;
    self._pingServer = FALSE;
    self.didLoginAgain = TRUE;
}



# pragma mark - Logout
- (void)setLoginAsRootFrom:(UIViewController*)controller
{
    loginController.modalPresentationStyle = UIModalPresentationFullScreen;
    loginController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [controller presentViewController:loginController animated:YES completion:^{
        [self.window setRootViewController:loginController];
    }];
}

- (void) showloginScreen
{
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    self.logoutFlag = TRUE;
    
    if([appDelegate.syncThread isExecuting])
    {
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"iServiceAppDelegate.m : showLoginScreen: Check For Data Sync Thread Status");
#endif

            if ([appDelegate.syncThread isFinished])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.datasync_timer];
                break;
            }
            if (![appDelegate isInternetConnectionAvailable])
                break;
        }
        
    }
    else
    {
        if ([appDelegate.datasync_timer isValid])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.datasync_timer];
        }
        
    }
    
    if ([appDelegate.metaSyncThread isExecuting])
    {
        
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"iServiceAppDelegate.m : showLoginScreen: Check For Meta Sync Thread Status");
#endif

            if (![appDelegate isInternetConnectionAvailable])
            {
                break;
            }
            
            if ([appDelegate.metaSyncThread isFinished])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.metasync_timer];
                break;
            }
        }
    }
    else
    {
        if ([appDelegate.metasync_timer isValid])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.metasync_timer];
        }            
    }   
    
    if ([appDelegate.event_thread isExecuting])
    {
        
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"iServiceAppDelegate.m : showLoginScreen: Check For Event Sync Thread Status");
#endif

            if (![appDelegate isInternetConnectionAvailable])
            {
                break;
            }
            
            if ([appDelegate.event_thread isFinished])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.event_timer];
                break;
            }
        }
    }
    else
    {
        if ([appDelegate.event_timer isValid])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.event_timer];
        }            
    }   
    
    if (metaSyncRunning)
    {
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"iServiceAppDelegate.m : showLoginScreen: Check For Meta Sync Thread Status2");
#endif

            if (![appDelegate isInternetConnectionAvailable])
            {
                break;
            }
            
            if (!metaSyncRunning)
            {
                break;
            }
            if (appDelegate.connection_error)
            {
                break;
            }
        }

    }
    
	if (appDelegate.eventSyncRunning)
	{
		
		while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
		{
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"iServiceAppDelegate.m : showLoginScreen: Check For Event Sync Thread Status2");
#endif

			if (![appDelegate isInternetConnectionAvailable])
			{
				break;
			}
			
			if (!appDelegate.eventSyncRunning)
			{
				break;
			}
            if (appDelegate.connection_error)
            {
                break;
            }
		}
	}
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:locationPingSettingTimer];

    
    sqlite3_close(self.db);
	
    [self.dataBase removecache];
    self.wsInterface.didOpComplete = FALSE;
    loginController.didEnterAlertView = FALSE;
    self.isMetaSyncExceptionCalled = FALSE;
    self.isIncrementalMetaSyncInProgress = FALSE;
    self.isInitialMetaSyncInProgress = FALSE; 
    self.isSpecialSyncDone = FALSE;
    metaSyncRunning = NO;
	eventSyncRunning = NO;
	
	//Shrinivas : OAuth.
	[self.oauthClient revokeExistingToken:self.refresh_token];

	/*COMMENTING THE CODE SINCE LOGIN CONTROLLER IS NOT USED FOR OAUTH*/
	
	/*
    [loginController readUsernameAndPasswordFromKeychain];
    if(!appDelegate.IsLogedIn == ISLOGEDIN_TRUE)
    {
         loginController.txtPasswordLandscape.text = @"";
    }
    [loginController.activity stopAnimating];
    [loginController enableControls];
	 */
}

#pragma mark - END



-(void)callDataSync
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    SMLog(@"Return No Datasync triggred");
	
    [self performSelectorInBackground:@selector(goOnlineIfRequired) withObject:nil];

	BOOL retVal = [self.calDataBase selectCountFromSync_Conflicts];
	
    if(retVal == TRUE)
    {
		//Radha Defect Fix 5542
		if (self.isDataSyncTimerTriggered)
		{
			[self updateNextSyncTimeIfSyncFails];
			isDataSyncTimerTriggered = NO;
			
		}
		SMLog(@"Return No Datasync triggred");
        return;
    }
    
    if (![appDelegate isInternetConnectionAvailable])
    {
		//Radha Defect Fix 5542
		if (self.isDataSyncTimerTriggered)
		{
			[self updateNextSyncTimeIfSyncFails];
			isDataSyncTimerTriggered = NO;
			
		}
		SMLog(@"Return No Datasync triggred");
        return;
    }
    
    if (syncThread != nil)
    {
        if ([syncThread isFinished] == YES)
        {
            SMLog(@"thread finished its work");
        }
        else
        {
            Enable_aggresssiveSync = FALSE;
            SMLog(@"thread is not finished its work");
			SMLog(@"Return No Datasync triggred");
            return; //Please don't comment return
        }
        
    }
    
    [syncThread release];
	
	//appDelegate.syncTypeInProgress = DATASYNC_INPROGRESS;
//	[appDelegate setCurrentSyncStatusProgress:SYNC_NONE optimizedSynstate:oSYNC_NONE];
	
    syncThread = [[NSThread alloc] initWithTarget:self.wsInterface selector:@selector(DoIncrementalDataSync) object:nil];
    [syncThread start];
    
    [pool release];
   
}
-(void)ScheduleIncrementalDatasyncTimer
{
    NSString * timerValue = ([self.settingsDict objectForKey:@"Frequency of Master Data"] != nil)?[self.settingsDict objectForKey:@"Frequency of Master Data"]:@"";
    
    int value = [timerValue intValue];
    
    if (value == 0)
        return;
    NSTimeInterval scheduledTimer = 0;
    
    if (![timerValue isEqualToString:@""] && ([timerValue length] > 0) )  
    {
        double timeInterval = [timerValue doubleValue];
        
        scheduledTimer = timeInterval * 60;
    }
    else
        return;
    
    if( ![self.datasync_timer isValid] )
    {
		//Radha Defect Fix 5542
        self.datasync_timer =  [NSTimer scheduledTimerWithTimeInterval:scheduledTimer
                                         target:self
                                        selector:@selector(MethodForTimer:)
                                       userInfo:nil
                                        repeats:YES];
    }
}

-(void)MethodForTimer:(NSTimer *)timer
{
	//Radha Defect Fix 5542
	self.isDataSyncTimerTriggered = YES;
    appDelegate.data_sync_type = NORMAL_DATA_SYNC;
    [self performSelectorOnMainThread:@selector(callDataSync) withObject:nil waitUntilDone:NO];
}

- (NSMutableArray *) getWeekdates:(NSString *)date
{
	NSDate *todayDate = [NSDate date];//temporary date from system to get timezone
	//calendar parameters
	NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSTimeZoneCalendarUnit;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    const int firstDayOfWeek = 2;
    [gregorian setFirstWeekday:firstDayOfWeek];
	//today's date components
	NSDateComponents *todayDateComponents = [gregorian components:unitFlags fromDate:todayDate];
	
	//argument date string converted to date using specified calendar and timezone
	NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"yyyy-MM-dd"];
	[formatter1 setTimeZone:[todayDateComponents timeZone]];
	NSDate *today = [formatter1 dateFromString:date];
	[formatter1 release];
	formatter1 = nil;
	
    NSDateComponents *weekdayComponents = [gregorian components:unitFlags fromDate:today];
    
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
	
	
	
	int diff = ([weekdayComponents weekday] - firstDayOfWeek);
	if(diff == -1) 
		diff = 6;
	[componentsToSubtract setDay:( 0 - diff)];
	
    NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:today options:0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd 00:00:00"];
    [formatter setTimeZone:[weekdayComponents timeZone]];
    
    NSString *start = [formatter stringFromDate:beginningOfWeek];
    
    NSDate *endOfWeek = [beginningOfWeek dateByAddingTimeInterval:86400*6];
    NSString *end = [formatter stringFromDate:endOfWeek];
	
	[gregorian release];
	gregorian = nil;
	[formatter release];
	formatter = nil;
	
	return [NSMutableArray arrayWithObjects:start, end, nil];
}

-(void)callSpecialIncrementalSync
{
    Enable_aggresssiveSync = FALSE;
    if (special_incremental_thread != nil)
    {
        if ([special_incremental_thread isFinished] == YES)
        {
            SMLog(@"Specialthread  finished its work");
            appDelegate.Enable_aggresssiveSync = FALSE;
        }
        else
        {
            SMLog(@"Specialthread is not finished its work");
           // return;
        }
        
    }
    
    [special_incremental_thread release];     
    
    special_incremental_thread = [[NSThread alloc] initWithTarget:self.wsInterface selector:@selector(DoSpecialIncrementalSync) object:nil];
    [special_incremental_thread start];

}

-(void)getDPpicklistInfo
{
    self.dPicklist_retrieval_complete = FALSE;
    [self.databaseInterface fillDependencyPickListInfo];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        //shrinivas -- 02/05/2012
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"iServiceAppDelegate.m : getDPpicklistInfo: Dependent Picklist");
#endif

        if(self.dPicklist_retrieval_complete)
        {
            self.dPicklist_retrieval_complete = FALSE;
            break;
        }
        
        if (![appDelegate isInternetConnectionAvailable])
        {
            if(IsLogedIn == ISLOGEDIN_TRUE)
            {
               initial_sync_succes_or_failed = META_SYNC_FAILED;
            }
            break;
        }
        if(connection_error)
        {
            return;
        }
    }
    
    NSString * version = [appDelegate serverPackageVersion];
	int _stringNumber = [version intValue];
    if(_stringNumber >=  (KMinPkgForScheduleEvents * 100000))
    {
        [self getTriggerCode];
    }
}

-(void)getTriggerCode
{
    appDelegate.get_trigger_code = FALSE;
    [appDelegate.wsInterface metaSyncWithEventName:@"CODE_SNIPPET" eventType:@"SYNC" values:nil];
    while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        if(appDelegate.get_trigger_code)
        {
            break;
        }
        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }
        
    }
    appDelegate.get_trigger_code = FALSE;

}

-(void) getCreateProcessArray:(NSMutableArray *)processes_array
{
    if (self.objectLabelName_array)
    {
        self.objectLabelName_array = nil;
    }
    
    NSMutableArray * _objectNames_array;
    //collect all the object names in an array arrange it in the alpha order 
    _objectNames_array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    @try{
    for(int i = 0 ;i<[processes_array count]; i++)
    {
        NSDictionary * dictionary = [processes_array objectAtIndex:i];
        NSString * str = [dictionary objectForKey:SVMXC_OBJECT_NAME];  
        
        if(i  == 0)
        {
            [_objectNames_array  addObject:str];
            continue;
        }
        NSInteger count=0;
        for(int j = 0; j < [_objectNames_array count];j++)
        {
            if([str isEqualToString:[_objectNames_array objectAtIndex:j]])
            {
                count ++;
            }
        }
        if(count == 0)
        {
            [_objectNames_array  addObject:str];
        }
        
    }
    
    NSMutableArray * section_for_createObjects = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i=0 ;i< [_objectNames_array count]; i++)
    {
        NSString * _objectName = [_objectNames_array objectAtIndex:i];
        NSMutableArray * createobjects = [[NSMutableArray alloc] initWithCapacity:0];
        for(int j=0;j<[processes_array count];j++)
        {
            NSDictionary * _dict = [processes_array objectAtIndex:j];
            NSString * str = [_dict objectForKey:SVMXC_OBJECT_NAME];
            if([str isEqualToString:_objectName])
            {
                [createobjects addObject:_dict];
            }
        }
        
        [section_for_createObjects addObject:createobjects];
        [createobjects release];
    }
    //create a
    self.StandAloneCreateProcess = section_for_createObjects;
    self.objectNames_array = _objectNames_array;
    
    //write a method to get all the labels for the  object
    NSMutableArray * objectNames = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    for(int k = 0; k < [self.objectNames_array count];k++ )
    {
        NSString * label = [self.databaseInterface getObjectLabel:@"SFObject" objectApi_name:[self.objectNames_array objectAtIndex:k]];
        if(label != nil)
        {
            [objectNames addObject:label];
        }
        else
        {
            [objectNames addObject:@""];
        }
        
    }
    
    self.objectLabel_array = objectNames;
    
    if (self.objectLabelName_array == nil)
        self.objectLabelName_array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    
    NSMutableDictionary * _dict = nil;
    for (int i = 0; i < [self.objectNames_array count]; i++)
    {
        if (_dict == nil)
            _dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
        
        [_dict setValue:[self.objectLabel_array objectAtIndex:i] forKey:[self.objectNames_array objectAtIndex:i]];
        [self.objectLabelName_array addObject:_dict];
        _dict = nil;
    }
    
    SMLog(@"%@", self.objectLabelName_array);
    
    if ( [self.objectLabelName_array count] > 1 )
    {
        int i = 0;
        for (i = 0; i < [self.objectLabelName_array count] - 1; i++)
        {
            
            for (int j = 0; j < ([self.objectLabelName_array count] - (i +1)); j++)
            {
                NSDictionary * dict_ = [self.objectLabelName_array objectAtIndex:j];
                NSArray * arr = [dict_ allValues];
                NSString * label = [arr objectAtIndex:0];
                NSString * label1;
                NSDictionary * _dict = [self.objectLabelName_array objectAtIndex:j+1];
                NSArray * arr1 = [_dict allValues];
                label1 = [arr1 objectAtIndex:0];
                if (strcmp([label UTF8String], [label1 UTF8String]) > 0)
                {
                    [self.objectLabelName_array exchangeObjectAtIndex:j withObjectAtIndex:j+1];
                }
            }
        }
    }
    
    [section_for_createObjects release];
    section_for_createObjects = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    for(int i=0 ;i< [_objectNames_array count]; i++)
    {
        
        NSDictionary * dict_ =  [self.objectLabelName_array objectAtIndex:i];
        NSString * _objectName = [[dict_ allKeys] objectAtIndex:0];
        NSMutableArray * createobjects = [[NSMutableArray alloc] initWithCapacity:0];
        for(int j=0;j<[processes_array count];j++)
        {
            NSDictionary * _dict = [processes_array objectAtIndex:j];
            NSString * str = [_dict objectForKey:SVMXC_OBJECT_NAME];
            if([str isEqualToString:_objectName])
            {
                [createobjects addObject:_dict];
            }
        }
        
        //Radha
        for (int k = 0; k <[createobjects count]; k++)
        {
            NSDictionary * dict1 = [createobjects objectAtIndex:k];
            NSString * key1 = [dict1 objectForKey:@"SVMXC__Name__c"];
            for (int r = k + 1; r < [createobjects count]; r++)
            {
                NSDictionary * dict2 = [createobjects objectAtIndex:r];
                NSString * key2 = [dict2 objectForKey:@"SVMXC__Name__c"];
                
                key1 = [key1 uppercaseString];
                key2 = [key2 uppercaseString];
                int result = strcmp([key1 UTF8String], [key2 UTF8String]);
                
                if (result > 0 )
                {
                    // perform swap
                    [createobjects exchangeObjectAtIndex:k withObjectAtIndex:r];
                    key1 = key2;
                }
            }
            
        }
        
        [section_for_createObjects addObject:createobjects];
        [createobjects release];
    }
    self.StandAloneCreateProcess = section_for_createObjects;
	}@catch (NSException *exp) {
	SMLog(@"Exception Name iServiceAppDelegate :getCreateProcessArray %@",exp.name);
	SMLog(@"Exception Reason iServiceAppDelegate :getCreateProcessArray %@",exp.reason);
	[appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

}

#pragma mark - Schedule IncrementalMetaSync

- (void) ScheduleIncrementalMetaSyncTimer
{
    NSString * timerInterval = ([self.settingsDict objectForKey:@"Frequency of Application Changes"] != nil)?[self.settingsDict objectForKey:@"Frequency of Application Changes"]:@"";
    
    int value = [timerInterval intValue];
    
    if (value == 0)
        return;
    
    NSTimeInterval  metaSyncTimeInterval = 0;
    
    if (![timerInterval isEqualToString:@""] && ([timerInterval length] > 0))
    {
        double interval = [timerInterval doubleValue];
        
        metaSyncTimeInterval = interval * 60;
    }
    
    else
        return;
    
    if( ![self.metasync_timer isValid] )
    {
        self.metasync_timer = [NSTimer scheduledTimerWithTimeInterval:metaSyncTimeInterval 
                                                         target:self 
                                                       selector:@selector(metaSyncTimer) 
                                                       userInfo:nil 
                                                        repeats:YES];
    }
}

- (void) metaSyncTimer
{
    [self performSelectorOnMainThread:@selector(callMetaSyncTimer) withObject:nil waitUntilDone:NO];
}

- (void) callMetaSyncTimer
{
    //Radha 2012june16
    
    [dataBase insertMetaSyncDue:METASYNCDUE];
    [self updateMetasyncTimeinSynchistory];
//    if (metaSyncThread != nil)
//    {
//        if ([metaSyncThread isFinished] == YES)
//        {
//            SMLog(@"Meta Sync");
//        }
//        else
//        {
//            SMLog(@"Meta Sync");
//            return;
//        }
//        
//        
//    }
//    
//    [metaSyncThread release]; 
//    metaSyncThread = [[NSThread alloc] initWithTarget:self.dataBase selector:@selector(callIncrementalMetasync) object:nil];
//    [metaSyncThread start];

}
-(void)updateMetasyncTimeinSynchistory
{
    NSString * timerInterval = ([self.settingsDict objectForKey:@"Frequency of Application Changes"] != nil)?[self.settingsDict objectForKey:@"Frequency of Application Changes"]:@"";
    
    int value = [timerInterval intValue];
    
    if (value == 0)
        return;
    
    NSTimeInterval  metaSyncTimeInterval = 0;
    
    if (![timerInterval isEqualToString:@""] && ([timerInterval length] > 0))
    {
        double interval = [timerInterval doubleValue];
        
        metaSyncTimeInterval = interval * 60;
    }
    
    
//    refreshMetaSyncTimeStamp
   
    NSString * rootpath_SYNHIST = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:SYNC_HISTORY];

    NSMutableDictionary * dict_temp = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath_SYNHIST];

    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]]; //Change for Time Stamp	

    NSDate * current_date = [NSDate date];

    NSDate * next_sync_dateTime = [NSDate dateWithTimeInterval:metaSyncTimeInterval sinceDate:current_date];
    NSString * next_sync = [dateFormatter stringFromDate:next_sync_dateTime];
    [dict_temp  setObject:next_sync forKey:NEXT_META_SYNC_TIME];
    
    
    [dict_temp writeToFile:plistPath_SYNHIST atomically:YES];
    [dict_temp release];

}

#pragma mark - End


#pragma mark - EventSync
- (void) ScheduleTimerForEventSync
{
    
    NSString * timerInterval = ([self.settingsDict objectForKey:@"Dataset Synchronization"] != nil)?[self.settingsDict objectForKey:@"Dataset Synchronization"]:@"";
    
    
    int value = [timerInterval intValue];
    
    if (value == 0)
        return;
    
    NSTimeInterval  eventTimeInterval = 0;
    
    if (![timerInterval isEqualToString:@""] && ([timerInterval length] > 0))
    {
        double value = [timerInterval doubleValue];
        
        eventTimeInterval = value * 60;
    }
    else 
        return;
    
    if( ![self.event_timer isValid] )
    {
        self.event_timer = [NSTimer scheduledTimerWithTimeInterval:eventTimeInterval 
                                                       target:self 
                                                     selector:@selector(callEventSyncTimer) 
                                                     userInfo:nil 
                                                      repeats:YES];
    }
    SMLog(@"%d", event_timer.retainCount);
}

- (void) eventSyncTimer
{
    [self performSelectorOnMainThread:@selector(callEventSyncTimer) withObject:nil waitUntilDone:NO];
}

- (void) callEventSyncTimer
{
    
    if (![appDelegate isInternetConnectionAvailable])
    {
        return;
    }

    if (event_thread != nil)
    {
        if ([event_thread isExecuting])
        {
            SMLog(@"Executing");
            return;            
        }
        else 
        {
            SMLog(@"finished");
                
        }
    }
    self.syncTypeInProgress = EVENTSYNC_INPROGRESS;
	
//	[self setCurrentSyncStatusProgress:eEVENTSYNC_NONE optimizedSynstate:0];
	
	[event_thread release];
    event_thread = [[NSThread alloc] initWithTarget:self.dataBase selector:@selector(scheduleEventSync) object:nil];
    [event_thread start];
    
}


//Radha Sync ProgressBar :
int percent = 0;
- (void) setSyncStatus2
{
	UIImage *img;
	
    if( SyncProgress == nil )
    {
        CGRect frame = CGRectMake(0, 0, 35, 35);
        SyncProgress = [[SyncProgressBar alloc]initWithFrame:frame];
    }
    
    if (_SyncStatus == SYNC_RED)
    {
		NSString * statusImage = @"red.png";
		[SyncProgress.progressIndicator stopAnimating];
        SyncProgress.progressIndicator.image = [UIImage imageNamed:statusImage];
		SyncProgress.percentage.hidden = YES;
        img = [UIImage imageNamed:statusImage];
        [img stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    }
    else if (_SyncStatus == SYNC_GREEN)
    {
        NSString * statusImage = @"green.png";
        [SyncProgress.progressIndicator stopAnimating];
        SyncProgress.progressIndicator.image = [UIImage imageNamed:statusImage];
		SyncProgress.percentage.hidden = YES;
        img = [UIImage imageNamed:statusImage];
        [img stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    }
	else if (_SyncStatus == SYNC_ORANGE)
	{
		SyncProgress.progressIndicator.animationImages = nil;
        NSMutableArray * imgArr = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        for ( int i = 1; i < 26; i++)
        {
            [imgArr addObject:[UIImage imageNamed:[NSString stringWithFormat:@"ani%d.png", i]]];
        }
        SyncProgress.progressIndicator.animationImages = [NSArray arrayWithArray:imgArr];
        SyncProgress.progressIndicator.animationDuration = 1.0f;
        SyncProgress.progressIndicator.animationRepeatCount = 0;
        [SyncProgress.progressIndicator startAnimating];

	}
	
//    else if (_SyncStatus == SYNC_ORANGE)
//    {
//		int numOfCalls = 0, syncProgressState = 0;
//		switch (self.syncTypeInProgress) {
//			case DATASYNC_INPROGRESS:
//				if (self.Enable_aggresssiveSync)
//				{
//					numOfCalls = 9;
//					syncProgressState = SyncProgress.optimizedSyncProgress;
//				}
//				else
//				{
//					numOfCalls = 12;
//					syncProgressState = SyncProgress.syncProgressState;
//				}
//				break;
//				
//			case EVENTSYNC_INPROGRESS:
//				numOfCalls = 12;
//				syncProgressState = SyncProgress.eventsyncProgressState;
//				break;
//				
//			case METASYNC_INPROGRESS:
//				numOfCalls = 12;
//				syncProgressState = SyncProgress.metasyncProgressState;
//				break;
//				
//			case CONFLICTSYNC_INPROGRESS:
//				numOfCalls = 10;
//				syncProgressState = SyncProgress.conflictSyncProgressState;
//				break;
//				
//			case CUSTOMSYNC_INPROGRESS:
//				iscustomSync = YES;
//				syncProgressState = SyncProgress.customSyncProgressState;
//				numOfCalls = 2;
//				break;
//				
//			default:
//				break;
//		}
//		 percent  = 0;
//		if (numOfCalls > 0)
//		{
//			percent = ( 100/ numOfCalls) * syncProgressState;
//			if (numOfCalls == syncProgressState)
//			{
//				percent = 100;
//				syncProgressState = 12;
//			}
//			
//		}
//		
//		
//		NSString * statusImage = @"";
//		if (iscustomSync)
//		{
//			statusImage = [self getStatusImageForCustomSync];
//		}
//		else
//		{
//			statusImage  = [NSString stringWithFormat:@"sync%d.png", syncProgressState];
//		}
//		
//       
//        SyncProgress.progressIndicator.image = [UIImage imageNamed:statusImage];
//		[SyncProgress updateProgress:percent forObject:self];
//        img = [UIImage imageNamed:statusImage];
//        [img stretchableImageWithLeftCapWidth:10 topCapHeight:10];
//    }
}

//upon changing the sync status, the animated image view has to change state automatically
- (void) setSyncStatus:(SYNC_STATUS)_SyncStatus_
{
	_SyncStatus = _SyncStatus_;
	[self performSelectorOnMainThread:@selector(setSyncStatus2) withObject:nil waitUntilDone:NO];
}


//Radha
#pragma mark -   Progress Bar
- (void) setSyncTypeInProgress:(SYNC_TYPE_INPROGRESS)syncTypeInProgress
{
	_syncTypeInProgress = syncTypeInProgress;
}

- (void) setCurrentSyncStatusProgress:(int)syncState optimizedSynstate:(int)oSyncState
{
//	switch (self.syncTypeInProgress) {
//		case DATASYNC_INPROGRESS:
//			if (Enable_aggresssiveSync)
//			{
//				self.SyncProgress.optimizedSyncProgress = oSyncState;
//			}
//			else
//			{
//				self.SyncProgress.syncProgressState = syncState;
//			}
//			break;
//			
//		case EVENTSYNC_INPROGRESS:
//			self.SyncProgress.eventsyncProgressState = syncState;
//			break;
//			
//		case METASYNC_INPROGRESS:
//			self.SyncProgress.metasyncProgressState = syncState;
//			break;
//			
//		case CONFLICTSYNC_INPROGRESS:
//			self.SyncProgress.conflictSyncProgressState = syncState;
//			break;
//		
//		case CUSTOMSYNC_INPROGRESS:
//			self.SyncProgress.customSyncProgressState = syncState;
//			break;
//			
//		default:
//			break;
//	}
	
	[self setSyncStatus:SYNC_ORANGE];
}

- (NSString *) getStatusImageForCustomSync
{
	NSString * statusImage = @"";
	percent = 0;
	
	
	switch (appDelegate.SyncProgress.customSyncProgressState) {
		case CUSTOMSYNC_REQDATA:
			statusImage = [NSString stringWithFormat:@"sync3.png"];
			percent = 25;
			break;
			
		case CUSTOMSYNC_GETDATA:
			statusImage = [NSString stringWithFormat:@"sync6.png"];
			percent = 50;
			break;
			
		case CUSTOMSYNC_PUTDATA:
			statusImage = [NSString stringWithFormat:@"sync9.png"];
			percent = 75;
			break;
			
		case CUSTOMSYNC_END:
			statusImage = [NSString stringWithFormat:@"sync12.png"];
			percent = 100;
			break;
			
		default:
			statusImage = [NSString stringWithFormat:@"sync0.png"];
			break;
	}

	
	return statusImage;
}

#pragma mark - End

#pragma mark - Location Ping
-(void)didUpdateToLocation:(CLLocation*)location
{
    if(![appDelegate enableGPS_SFMSearch])
        return;
    //call db to store the data
    NSMutableDictionary *locationInfo = [[NSMutableDictionary alloc] init];
    NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
    [frm setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * timeStamp = [frm stringFromDate:[NSDate date]];    
    timeStamp = [iOSInterfaceObject getGMTFromLocalTime:timeStamp];
    [locationInfo setObject:[NSString stringWithFormat:@"%@",timeStamp] forKey:@"timestamp"];

    if(location != nil)
    {
        SMLog(@"Latitude = %lf and Longitude = %lf",location.coordinate.latitude,location.coordinate.longitude );
        [locationInfo setObject:[NSString stringWithFormat:@"%lf",location.coordinate.latitude] forKey:@"latitude"];
        [locationInfo setObject:[NSString stringWithFormat:@"%lf",location.coordinate.longitude] forKey:@"longitude"];
        [locationInfo setObject:[NSString stringWithFormat:@" "] forKey:@"additionalInfo"];
        [locationInfo setObject:Location_Success forKey:@"status"];
    }
    else 
    {
        [locationInfo setObject:[NSString stringWithFormat:@""] forKey:@"latitude"];
        [locationInfo setObject:[NSString stringWithFormat:@""] forKey:@"longitude"];
        [locationInfo setObject:Failed_to_Get_Location forKey:@"additionalInfo"];
        [locationInfo setObject:Failure forKey:@"status"];
    }
    [self.dataBase insertrecordIntoUserGPSLog:locationInfo];
    [locationInfo release];
}
#pragma mark - RunBackground Thread for Location Service Settings
- (void) startBackgroundThreadForLocationServiceSettings
{
    if(![appDelegate enableGPS_SFMSearch])
        return;
     if(metaSyncRunning )
    {
        SMLog(@"Meta Sync is Running");
        return;
    }
    NSString *enableLocationServiceStatus = [self.settingsDict objectForKey:ENABLE_LOCATION_UPDATE];
    enableLocationService = (enableLocationServiceStatus != nil)?[enableLocationServiceStatus boolValue]:TRUE;
    frequencyLocationService = [[self.settingsDict objectForKey:FREQ_LOCATION_TRACKING] retain]; 
    frequencyLocationService = (frequencyLocationService != nil)?frequencyLocationService:@"10";
    if(enableLocationService)
    {
        if(frequencyLocationService == nil)
            frequencyLocationService = @"10";
        NSTimeInterval scheduledTimer = 0;
        scheduledTimer = [frequencyLocationService doubleValue] * 60;
        if( [locationPingSettingTimer isValid] )
        {    
            [locationPingSettingTimer invalidate];
            locationPingSettingTimer = nil;
        }
        locationPingSettingTimer = [NSTimer scheduledTimerWithTimeInterval:scheduledTimer
                                                                        target:self
                                                                      selector:@selector(checkLocationServiceSetting)
                                                                      userInfo:nil
                                                                       repeats:YES];
    }
}

- (void) checkLocationServiceSettingBackground
{
    NSAutoreleasePool *thepool = [[NSAutoreleasePool alloc] init];
    NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
    [frm setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * newTimestamp = [frm stringFromDate:[NSDate date]];
    newTimestamp = [iOSInterfaceObject getGMTFromLocalTime:newTimestamp];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults)
    {
        NSDate *lastLocationSettingUpdateTiemstamp = [userDefaults objectForKey:kLastLocationSettingUpdateTimestamp];
        SMLog(@"Last Location Update From Thread  = %@",lastLocationSettingUpdateTiemstamp);
    }
    else
    {
        SMLog(@"Failed to get the User Defaults");
        return;
    }
    if(metaSyncRunning||dataSyncRunning)
    {
        SMLog(@"Sync is Running");
        return;
    }
    SMLog(@"Location Update");
    if(![CLLocationManager locationServicesEnabled])
    {
        NSMutableDictionary *locationInfo = [[NSMutableDictionary alloc] init];
        [locationInfo setObject:[NSString stringWithFormat:@""] forKey:@"latitude"];
        [locationInfo setObject:[NSString stringWithFormat:@""] forKey:@"longitude"];
        [locationInfo setObject:Location_Setting_Disable forKey:@"additionalInfo"];
        [locationInfo setObject:[NSString stringWithFormat:@"%@",newTimestamp ] forKey:@"timestamp"];
        [locationInfo setObject:[NSString stringWithFormat:@"Failure"] forKey:@"status"];
        SMLog(@"Location = %@",locationInfo);
        [self.dataBase insertrecordIntoUserGPSLog:locationInfo];
        [locationInfo release];
    }
    else if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized)
    {
        NSMutableDictionary *locationInfo = [[NSMutableDictionary alloc] init];
        [locationInfo setObject:[NSString stringWithFormat:@""] forKey:@"latitude"];
        [locationInfo setObject:[NSString stringWithFormat:@""] forKey:@"longitude"];
        [locationInfo setObject:App_Location_Setting_Disable forKey:@"additionalInfo"];
        [locationInfo setObject:[NSString stringWithFormat:@"%@",newTimestamp] forKey:@"timestamp"];
        [locationInfo setObject:[NSString stringWithFormat:@"Failure"] forKey:@"status"];
        SMLog(@"Location = %@",locationInfo);
        [self.dataBase insertrecordIntoUserGPSLog:locationInfo];
        [locationInfo release];
    }
    [userDefaults setObject:newTimestamp forKey:kLastLocationSettingUpdateTimestamp];
    [thepool drain];
}

- (void) checkLocationServiceSetting
{
    [self performSelectorInBackground:@selector(checkLocationServiceSettingBackground) withObject:nil];
}


- (void) timerHandler:(NSNotification *)notification
{
    NSTimer *timerObject = (NSTimer *)[notification object];
    
    if( [timerObject isEqual:event_timer] )
    {
        SMLog(@"Invalidating EVENT TIMER");
		if ([self.event_timer isValid])
		{
			[self.event_timer invalidate];
			event_timer = nil;
		}
    }
    if( [timerObject isEqual:datasync_timer] )
    {
        SMLog(@"Invalidating DATASYNC TIMER");
		if ([self.datasync_timer isValid])
		{
			[self.datasync_timer invalidate];
			datasync_timer = nil;
		}
    }
    if( [timerObject isEqual:metasync_timer] )
    {
        SMLog(@"Invalidating METASYNC TIMER");
		if ([self.metasync_timer isValid])
		{
			[self.metasync_timer invalidate];
			metasync_timer = nil;
		}
    }
    if( [timerObject isEqual:locationPingSettingTimer] && [locationPingSettingTimer isValid] )
    {
        SMLog(@"Invalidating LocationPing TIMER");
        [locationPingSettingTimer invalidate];
        locationPingSettingTimer = nil;
    }

}
- (BOOL) isCameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) enableGPS_SFMSearch
{
    BOOL status = NO;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *packgeVersion;
    if (userDefaults) 
    {            
        packgeVersion = [userDefaults objectForKey:kPkgVersionCheckForGPS_AND_SFM_SEARCH];
        SMLog(@"Pkg Version = %@",packgeVersion);
        int _stringNumber = [packgeVersion intValue];
        if(_stringNumber >= (kMinPkgForGPS_AND_SFMSEARCH * 100000))
            status = YES;

    }
    return status;
}
- (NSString *) serverPackageVersion
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *packageVersion = nil;
    if (userDefaults)
    {
        packageVersion = [userDefaults objectForKey:kPkgVersionCheckForGPS_AND_SFM_SEARCH];
        SMLog(@"Pkg Version = %@",packageVersion);
    }
    return packageVersion;
}

- (BOOL) doesServerSupportsModule:(NSString *)minimumServerPackage
{
    enum  {
        ServerSupports = YES,
        ServerDoesNotSupport = NO
    };
    BOOL status = ServerDoesNotSupport;
    NSString *serverPackage = [self serverPackageVersion];
    int _stringNumber = [serverPackage intValue];
    if(_stringNumber >=  ([minimumServerPackage floatValue] * 100000))
        status = ServerSupports;
    return status;
}
- (void) updateInstalledPackageVersion
{
    didGetVersion = FALSE;
    [self.wsInterface getSvmxVersion];
    
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"iServiceAppDelegate.m : updateInstalledPackageVersion: Check for installed pkg version ");
#endif

        if (![appDelegate isInternetConnectionAvailable])
            break;
        if (self.didGetVersion)
            break;
        if(connection_error)
            break;
    }
    
    NSString * stringNumber = [self.SVMX_Version stringByReplacingOccurrencesOfString:@"." withString:@""];
    SMLog(@"Latest Installed Package = %@",stringNumber);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults) 
    {            
        [userDefaults setObject:stringNumber forKey:kPkgVersionCheckForGPS_AND_SFM_SEARCH];
    }
}

-(void)invalidateAllTimers
{
    if([appDelegate.syncThread isExecuting])
    {
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"iServiceAppDelegate.m : invalidateAllTimers: Data Sync thread status");
#endif

            if ([appDelegate.syncThread isFinished])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.datasync_timer];
                break;
            }
            if (![appDelegate isInternetConnectionAvailable])
                break;
        }
		
    }
    else
    {
        if ([appDelegate.datasync_timer isValid])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.datasync_timer];
        }
		
    }
	
    if ([appDelegate.metaSyncThread isExecuting])
    {
		
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"iServiceAppDelegate.m : invalidateAllTimers: Meta Sync thread status");
#endif

            if (![appDelegate isInternetConnectionAvailable])
            {
                break;
            }
			
            if ([appDelegate.metaSyncThread isFinished])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.metasync_timer];
                break;
            }
        }
    }
    else
    {
        if ([appDelegate.metasync_timer isValid])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.metasync_timer];
        }
    }
	
    if ([appDelegate.event_thread isExecuting])
    {
		
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"iServiceAppDelegate.m : invalidateAllTimers: Event Sync thread status");
#endif

            if (![appDelegate isInternetConnectionAvailable])
            {
                break;
            }
			
            if ([appDelegate.event_thread isFinished])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.event_timer];
                break;
            }
        }
    }
    else
    {
        if ([appDelegate.event_timer isValid])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.event_timer];
        }
    }
	
    if (metaSyncRunning)
    {
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"iServiceAppDelegate.m : invalidateAllTimers: Meta Sync thread status 2");
#endif

            if (![appDelegate isInternetConnectionAvailable])
            {
                break;
            }
			
            if (!metaSyncRunning)
            {
                break;
            }
            if (appDelegate.connection_error)
            {
                break;
            }
        }
		
    }
	
    if (appDelegate.eventSyncRunning)
    {
		
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"iServiceAppDelegate.m : invalidateAllTimers: Event Sync thread status2");
#endif

            if (![appDelegate isInternetConnectionAvailable])
            {
                break;
            }
			
            if (!appDelegate.eventSyncRunning)
            {
                break;
            }
            if (appDelegate.connection_error)
            {
                break;
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:locationPingSettingTimer];
	
}

-(void)scheduleLocationPingTimer
{
    [loginController scheduleLocationPing];
    
}
#pragma mark - GETCONFLICTRECORD

-(NSMutableString*)isConflictInEvent:(NSString*)objName local_id:(NSString *)local_id
{
    
    NSMutableString * conflictMessage =  [appDelegate.dataBase getAllTheConflictRecordsForObject:objName local_id:local_id];
    
    return conflictMessage;
    
}

//Radha - Auto Data sync
- (void) updateSyncFailedFlag:(NSString *)flag
{
	NSString * rootpath_SYNHIST = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:SYNC_HISTORY];
    
    NSMutableDictionary * plistdict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath_SYNHIST];
    NSArray * allkeys= [plistdict allKeys];
	
	for(NSString * str in allkeys)
    {
        if([str isEqualToString:SYNC_FAILED])
        {
            [plistdict setObject:flag forKey:SYNC_FAILED];
        }
    }
    [plistdict writeToFile:plistPath_SYNHIST atomically:YES];

}
//RADHA  26/Nov/2012
- (char *) convertStringIntoChar:(NSString *)data
{
	char * _data = (char *) [data UTF8String];
	
	if (_data == nil)
		_data = "";
	
	return _data;
}


//Radha DefectFix - 5542
- (void) updateNextDataSyncTimeToBeDisplayed:(NSDate *)CureentDateTime
{
	self.settingsDict = [dataBase getSettingsDictionary];
	
	NSString * timeInterval = ([self.settingsDict objectForKey:@"Frequency of Master Data"] != nil)?[self.settingsDict objectForKey:@"Frequency of Master Data"]:@"";
	
	int value = [timeInterval intValue];
	
	if (value == 0)
		return;
	
	NSTimeInterval scheduleTimeInterval;
	
	if (![timeInterval isEqualToString:@""])
	{
		double interval = [timeInterval doubleValue];
		
		scheduleTimeInterval = interval * 60;
	}
	
	
	NSString * rootpath_SYNHIST = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:SYNC_HISTORY];
	
    NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath_SYNHIST];
	
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]]; //Change for Time Stamp
		
    NSDate * nextSync = [NSDate dateWithTimeInterval:scheduleTimeInterval sinceDate:CureentDateTime];
    NSString * nextSyncTime = [dateFormatter stringFromDate:nextSync];
    [tempDict setObject:nextSyncTime forKey:NEXT_DATA_SYNC_TIME_DISPLAYED];
    
    [tempDict writeToFile:plistPath_SYNHIST atomically:YES];
    [tempDict release];

}

//RADHA Defect Fix 5542
- (NSDate *) getGMTTimeForNextDataSyncFromPList
{
	NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	
	NSString * rootpath_SYNHIST = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:SYNC_HISTORY];
	
    NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath_SYNHIST];
	
	NSArray * keys = [tempDict allKeys];
	
	NSString * nextSyncTime = @"";

	for (NSString * value in keys)
	{
		if ([value isEqualToString:NEXT_DATA_SYNC_TIME_DISPLAYED])
		{
			nextSyncTime = [tempDict objectForKey:NEXT_DATA_SYNC_TIME_DISPLAYED];
			break;
		}
	}
	
	NSDate * currentDateTime = [formatter dateFromString:nextSyncTime];
	
	return currentDateTime;
}

//RADHA Defect Fix 5542
- (void) updateNextSyncTimeIfSyncFails
{
	NSDate * nextSyncTime = [self getGMTTimeForNextDataSyncFromPList];
	[self updateNextDataSyncTimeToBeDisplayed:nextSyncTime];
}

//PRINTING ERROR MESSEGES:
- (void) printIfError:(NSString *)err ForQuery:(NSString *)query type:(SQL_QUERY)type
{
    @try
    {
        if(err ==nil)
        {
            return;
        }
        SMLog(@"%@ :", query);
        SMLog(@"ERROR :%@", err);
        NSMutableDictionary *errorDict=[[NSMutableDictionary alloc]init];
        if([err length]>0)
        {
            [errorDict setObject:err forKey:@"ExpReason"];
            [errorDict setObject:query forKey:@"userInfo"];
        }
        switch (type)
        {
            case SELECTQUERY:
                SMLog(@"Select Query");
//            if(!([err Contains:@"unknown error"]))
//                [self CustomizeAletView:nil alertType:DATABASE_ERROR Dict:errorDict exception:nil];
                break;
            case UPDATEQUERY:
                SMLog(@"Error in Database update query");
                [errorDict setObject:@"Error in Update" forKey:@"ExpName"];
                break;
            case INSERTQUERY:
                SMLog(@"Error in Database insert query");
                [errorDict setObject:@"Error in Insert" forKey:@"ExpName"];
                break;
            case DELETEQUERY:
                SMLog(@"Error in Database delete query");
                [errorDict setObject:@"Error in Delete" forKey:@"ExpName"];
                break;
            default:
                break;
                
        }
        [self CustomizeAletView:nil alertType:DATABASE_ERROR Dict:errorDict exception:nil];

    }@catch (NSException *exp)
    {
        SMLog(@"Exception Name iServiceAppDelegate :printIfError %@",exp.name);
        SMLog(@"Exception Reason iServiceAppDelegate :printIfError %@",exp.reason);
        [self CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

}

-(void)CustomizeAletView:(NSError*)error alertType:(ALERT_VIEW_ERROR)type Dict:(NSMutableDictionary*)errorDict exception:(NSException *)exp
{
    @try
    {

        NSString * CopytoClipboard = [appDelegate.wsInterface.tagsDictionary objectForKey:Copy_to_Clipboard];
        NSString * eMail = [appDelegate.wsInterface.tagsDictionary objectForKey:PDF_EMAIL];
        NSString * Ok= [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
        NSString * tag1 = [appDelegate.wsInterface.tagsDictionary objectForKey:Type_of_Error];
        NSString * tag2 = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_error_message];
        NSString * errorMessage=@"",* errorType=@"",* detail_desc=@"",*title=@"";
        errorDescription=@"";
        switch (type)
        {
                
            case DATABASE_ERROR:
                SMLog(@"DATABASE_ERROR");
                errorType =[errorDict objectForKey:@"ExpName"];
                
                errorMessage = [errorDict objectForKey:@"ExpReason"];
                
                detail_desc=[errorDict objectForKey:@"userInfo"];
                title=[appDelegate.wsInterface.tagsDictionary objectForKey:alert_application_error];
                break;
                
            case RES_ERROR:
                SMLog(@"Response Error");
                
                errorType =[errorDict objectForKey:@"ExpName"];
                
                errorMessage = [errorDict objectForKey:@"ExpReason"];
                
                detail_desc=[[errorDict objectForKey:@"userInfo"]objectForKey:@"userInfo"];
                
                title=[appDelegate.wsInterface.tagsDictionary objectForKey:Functional_Error];
                break;
                
            case SOAP_ERROR:
                SMLog(@"Soap Error");
                if(error!=nil)
                {
                    NSDictionary * user_info_error = [error userInfo];
                    errorType = [user_info_error objectForKey:@"faultcode"];
                    errorMessage = [user_info_error objectForKey:@"faultstring"];
                }
                else
                {
                    errorType =[errorDict objectForKey:@"ExpName"];
                    errorMessage = [errorDict objectForKey:@"ExpReason"];
                    detail_desc=[[errorDict objectForKey:@"userInfo"]objectForKey:@"userInfo"];
                }
                title=[appDelegate.wsInterface.tagsDictionary objectForKey:System_Error];
                break;
            case APPLICATION_ERROR:
                SMLog(@"Application Error");
                errorType=[exp name];
                errorMessage=[exp description];
                title=[appDelegate.wsInterface.tagsDictionary objectForKey:alert_application_error];
                break;
                
        }
        
        NSMutableString *message = [NSString stringWithFormat:@"%@:\t%@\n\n%@:\t%@\n",tag1,errorType,tag2,errorMessage];
        UIAlertView * customize_alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:Ok otherButtonTitles:eMail,CopytoClipboard, nil];
        errorDescription=detail_desc;
        NSArray *subViewArray = customize_alert.subviews;
        
        for(int x=0;x<[subViewArray count];x++)
        {
            if([[[subViewArray objectAtIndex:x] class] isSubclassOfClass:[UILabel class]] && x > 0)
                
            {
                UILabel *label = [subViewArray objectAtIndex:x];
                label.textAlignment = UITextAlignmentLeft;
            }
        }
        [customize_alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        
        [customize_alert release];
    } @catch (NSException *exp)
    {
        SMLog(@"Exception Name iServiceAppDelegate :CustomizeAletView %@",exp.name);
        SMLog(@"Exception Reason iServiceAppDelegate :CustomizeAletView %@",exp.reason);
    }
}

#pragma mark - END

#pragma CustomizeAlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation
{
	if ( switchUser )
	{
		_didDismissalertview = TRUE;
		switchUser = FALSE;
		
		if ( buttonIndex == 0 )
		{
			_continueFalg = TRUE;
			
			if (previousUser)
			{
				NSError *error;
				[SFHFKeychainUtils deleteItemForUsername:@"username" andServiceName:KEYCHAIN_SERVICE_NAME error:&error];
				[SFHFKeychainUtils deleteItemForUsername:@"password" andServiceName:KEYCHAIN_SERVICE_NAME error:&error];
				
			}
		}
		else
			_continueFalg = FALSE;

	}
	
	else
	{
		if( buttonIndex == 1 )
		{
			SMLog(@"Copy To clipBoard");
			
			[self sendingEmail:alertView];
			
		}
		else if ( buttonIndex == 2 )
		{
			SMLog(@"Email");
			[self copyToClipboard:alertView];
		}

	}
}

-(void) sendingEmail:(UIAlertView*)alertview
{
    @try
    {
        BOOL canSendMail = [MFMailComposeViewController canSendMail];
        if (canSendMail)
        {
            MFMailComposeViewController * mailComposer = [[MFMailComposeViewController alloc] init];
            mailComposer.mailComposeDelegate = self;
            NSString *errType=@"",*errMessage=@"";
            [mailComposer setSubject:[NSString stringWithFormat:@"Error Report"]];
            NSRange range=[alertview.message rangeOfString:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_error_message] options:NSCaseInsensitiveSearch];
            if(range.location != NSNotFound)
            {
                errType=[alertview.message substringToIndex:range.location];
                errMessage=[alertview.message substringFromIndex:range.location];
            }
            if(self.errorDescription ==nil)
                self.errorDescription=@"";
            NSMutableString *emailBody = [NSString stringWithFormat: @"<Head> %@ </Head><br/>================\n<br/> %@ <br/> <br/> %@ <br/><br/> %@<br/>",alertview.title,errType,errMessage,self.errorDescription];
            [mailComposer setMessageBody:emailBody isHTML:YES];
            [mailComposer.view sizeToFit];
            
            UIViewController *someViewController =  [[[[UIApplication sharedApplication] delegate]window]rootViewController];
           
            UIViewController  *focusedViewController = someViewController;
            int count = 10;
            while(focusedViewController.presentedViewController != nil && count > 0){
              
                focusedViewController = focusedViewController.presentedViewController;
                count--;
            }
            [focusedViewController presentModalViewController:mailComposer animated:YES];
        }
        else
        {
            UIAlertView * alertForMail = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:SERVICE_REPORT_EMAIL_ERROR] message:[appDelegate.wsInterface.tagsDictionary objectForKey:SERVICE_REPORT_PLEASE_SET_UP_EMAIL_FIRST] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertForMail show];
            [alertForMail release];
        }
    } @catch (NSException *exp)
    {
        SMLog(@"Exception Name iServiceAppDelegate :sendingEmail %@",exp.name);
        SMLog(@"Exception Reason iServiceAppDelegate :sendingEmail %@",exp.reason);
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    [controller dismissViewControllerAnimated:YES completion:nil];

    
}
-(NSArray*)stringConversion:(NSString*)errorDes
{
//    char *buffer = errorDescription;
//    NSString *str = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    NSArray *arr = [errorDes componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    SMLog(@"arr: %@", arr);
    return arr;

}

-(void)copyToClipboard:(UIAlertView*)alertview
{
    @try
    {
        NSString *errType=@"",*errMessage=@"";
        NSRange range=[alertview.message rangeOfString:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_error_message] options:NSCaseInsensitiveSearch];
        if(range.location != NSNotFound)
        {
            errType=[alertview.message substringToIndex:range.location];
            errMessage=[alertview.message substringFromIndex:range.location];
        }
        if(self.errorDescription ==nil)
            self.errorDescription=@"";
        NSString *emailBody = [NSString stringWithFormat: @"\n %@ \n ================ \n%@\n%@ \n%@",alertview.title,errType,errMessage,errorDescription];

        SMLog(@"Copy to clipboard %@",emailBody);
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = emailBody;
    } @catch (NSException *exp)
    {
        SMLog(@"Exception Name iServiceAppDelegate :copyToClipboard %@",exp.name);
        SMLog(@"Exception Reason iServiceAppDelegate :copyToClipboard %@",exp.reason);
    }
}

-(void)setAgrressiveSync_flag
{
    appDelegate.data_sync_type = NORMAL_DATA_SYNC;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL USDefault_aggressiveSync = [defaults boolForKey:@"USDefault_Aggressive_flag"];
    
    
    if (syncThread != nil)
    {
        if ([syncThread isFinished] == YES)
        {
            SMLog(@"setAgrressiveSync_flag:thread finished its work");
            if(USDefault_aggressiveSync)
            {
                Enable_aggresssiveSync = TRUE;
            }
            else
            {
                Enable_aggresssiveSync = FALSE;
            }
        }
        else
        {

            Enable_aggresssiveSync = FALSE;
            SMLog(@"setAgrressiveSync_flag:thread is not finished its work");
        }
        
    }
    else
    {
        if(USDefault_aggressiveSync)
        {
            Enable_aggresssiveSync = TRUE;
        }
    }
    if (special_incremental_thread != nil)
    {
        if ([special_incremental_thread isFinished] == NO)
        {
            Enable_aggresssiveSync = FALSE;
        }
    }
    
}


//Defect 6774
- (void) checkifConflictExistsForConnectionError
{
	if ( [self.calDataBase selectCountFromSync_Conflicts])
	{
		[self  setSyncStatus:SYNC_RED];
	}
	else
	{
		[self  setSyncStatus:SYNC_GREEN];
	}
}

@end

@implementation processInfo

@synthesize process_exists, process_id;

@end
