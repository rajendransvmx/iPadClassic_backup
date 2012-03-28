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
extern void SVMXLog(NSString *format, ...);
@implementation iServiceAppDelegate
@synthesize recordtypeId_webservice_called;
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

@dynamic isInternetConnectionAvailable;

@synthesize allURLConnectionsArray;

@synthesize isInternetPresentAfterWake, didAppBecomeActive, didUserInteract, internetConnectionStatus;

//Reachability
@synthesize hostReach;
@synthesize internetReach;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Check for internet connection here
    
    /////////////////////////////////////////////////////////////////
    //////////// REGISTER FOR REACHABILITY NOTIFICATIONS ////////////
    /////////////////////////////////////////////////////////////////
    
    // Check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reachabilityChanged:) 
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    hostReach = [[Reachability reachabilityWithHostName: @"www.salesforce.com"] retain];
	[hostReach startNotifier];
//	[self updateInterfaceWithReachability:hostReach];
	
//    internetReach = [[Reachability reachabilityForInternetConnection] retain];
//	[internetReach startNotifier];
//	[self updateInterfaceWithReachability:internetReach];
    
    //    wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
    //	[wifiReach startNotifier];
    //	[self updateInterfaceWithReachability:wifiReach];
    [self registerDefaultsFromSettingsBundle];
    signatureCaptureUpload = YES;
    workOrderEventArray = [[NSMutableArray alloc] initWithCapacity:0];
    workOrderInfo = [[NSMutableArray alloc] initWithCapacity:0];
    self.firstUsername = nil;
    
    wsInterface = [[WSInterface alloc] init];
    wsInterface.delegate = self;
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
    
    // Load recently created objects
    NSString * rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath = [rootPath stringByAppendingPathComponent:OBJECT_HISTORY_PLIST];
    recentObject = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    
    // Load Switch View Layouts cache
    plistPath = [rootPath stringByAppendingPathComponent:SWITCH_VIEW_LAYOUTS_PLIST];
    switchViewLayouts = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];

    loginController = [[LoginController alloc] initWithNibName:@"LoginController" bundle:nil];
    
    loginController.modalPresentationStyle = UIModalPresentationFullScreen;
    loginController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.viewController presentModalViewController:loginController animated:YES];
    [loginController release];
    
    _iOSObject = [[iOSInterfaceObject alloc] init];
    
    // Restore operation for memory warnings
    if (lastSelectedDate == nil)
        lastSelectedDate = [[NSMutableArray alloc] initWithCapacity:0];
    
    refreshCalendar = NO;
    
    allURLConnectionsArray = [[NSMutableArray alloc] initWithCapacity:0];

	return YES;
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability:curReach];
}

- (void) updateInterfaceWithReachability: (Reachability*)curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    BOOL isReallyReachable = NO;
    switch (netStatus)
    {
        case NotReachable:
            isReallyReachable = [curReach isReachable];
            if (isReallyReachable)
            {
                isInternetConnectionAvailable = YES;
                internetConnectionStatus = YES;
                [self PostInternetNotificationAvailable];
                NSLog(@"Really Reachable 1");
                break;
            }
            netStatus = [curReach currentReachabilityStatus];
            if (netStatus != kNotReachable)
            {
                isInternetConnectionAvailable = YES;
                internetConnectionStatus = YES;
                [self PostInternetNotificationAvailable];
                NSLog(@"Really Reachable 2");
                break;
            }
            else
            {
                isInternetConnectionAvailable = NO;
                internetConnectionStatus = NO;
                if (!didAppBecomeActive)
                {
                    [self PostInternetNotificationUnavailable];
                    NSLog(@"Really Not Reachable");
                }
            }
            break;
        case ReachableViaWWAN:
        case ReachableViaWiFi:
            isInternetConnectionAvailable = YES;
            internetConnectionStatus = YES;
            [self PostInternetNotificationAvailable];
            NSLog(@"WiFi WWAN Reachable");
            break;
        default:
            isInternetConnectionAvailable = YES;
            internetConnectionStatus = YES;
            [self PostInternetNotificationAvailable];
            NSLog(@"Default Reachable");
    }
}

- (void) PostInternetNotificationUnavailable
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kInternetConnectionChanged object:[NSNumber numberWithInt:0] userInfo:nil];
}

- (void) PostInternetNotificationAvailable
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kInternetConnectionChanged object:[NSNumber numberWithInt:1] userInfo:nil];
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
//    // 19 Dec, 2011, Samman - stop hostReach from polling for internet connection while the app is in the background
//    [hostReach stopNotifier];
//    [internetReach stopNotifier];
    
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
}

- (void) applicationWillEnterForeground:(UIApplication *)application
{
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
//    // 19 Dec, 2011 - Samman - Resume hostReach notification once the app becomes active again
//    [hostReach startNotifier];
//    [self updateInterfaceWithReachability:hostReach];
//    [internetReach startNotifier];
//    [self updateInterfaceWithReachability:internetReach];

//    [hostReach performSelector:@selector(startNotifier) withObject:nil afterDelay:10];
//    [self updateInterfaceWithReachability:hostReach];
//    [internetReach performSelector:@selector(startNotifier) withObject:nil afterDelay:10];
//    [self updateInterfaceWithReachability:internetReach];
    
    didAppBecomeActive = YES;
    didUserInteract = NO;
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)registerDefaultsFromSettingsBundle 
{
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) 
    {
        //NSLog(@"Could not find Settings.bundle");
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

#pragma mark - wsInterface Delegate Methods
- (void) didFinishWithError:(SOAPFault *)sFault
{
    UIAlertView * _alert = [[UIAlertView alloc] initWithTitle:@"Response Error" message:sFault.faultstring delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [_alert show];
    [_alert release];
}

-(void)popupActionSheet:(NSString *)message
{
    alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
	actionSheet.frame = CGRectMake(50, 50, 600.0, 600.0 ); 
}
- (void)willPresentAlertView:(UIAlertView *)alertView {
    alertView.frame = CGRectMake(50, 50, 600.0, 600.0 );
}
- (void)didPresentAlertView:(UIAlertView *)alertView {
    alertView.frame = CGRectMake(50, 50, 600.0, 600.0 );
}

- (void)dealloc
{
    [hostReach release];
    [internetReach release];
    [wsInterface release];
    [viewController release];
    [window release];
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
    if (!didUserInteract)
        return;
    
    NSString * message = [wsInterface.tagsDictionary objectForKey:ALERT_INTERNET_NOT_AVAILABLE];
    NSString * cancelButtonTitle = [wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    
    NSMutableDictionary * dictionary = [wsInterface getDefaultTags];
    
    if (message == nil)
    {
        message = [dictionary objectForKey:ALERT_INTERNET_NOT_AVAILABLE];
    }
    
    if (cancelButtonTitle == nil)
    {
        cancelButtonTitle = [dictionary objectForKey:ALERT_ERROR_OK];
    }
    
    UIAlertView * _alert = [[UIAlertView alloc] initWithTitle:@"ServiceMax" message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    [_alert show];
    [_alert release];
}

// isInternetConnectionAvailable getter & setter methods

- (void) setIsInternetConnectionAvailable:(BOOL)isInternetConnectionAvailable
{
    
}

- (BOOL) isInternetConnectionAvailable
{
    if (didUserInteract && didAppBecomeActive)
    {
        didAppBecomeActive = NO;
        
        if (!isInternetConnectionAvailable)
        {
            [Reachability reachabilityWithHostName:@"www.salesforce.com"];
            
            int maxCount = 0;
            
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 2, FALSE))
            {
                maxCount++;
                if (maxCount == 10)
                    break;
                
                if (internetConnectionStatus)
                    break;
            }
        }
        
        return internetConnectionStatus;
    }

    if (!isInternetConnectionAvailable)
        [self PostInternetNotificationUnavailable];
    return isInternetConnectionAvailable;
}

@end

