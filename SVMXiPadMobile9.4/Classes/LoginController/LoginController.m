    //
//  LoginController.m
//  iService
//
//  Created by Samman Banerjee on 28/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoginController.h"
#import "ModalViewController.h"
#import "ZKSforce.h"
#import "ZKLoginResult.h"
#import "SignUpController.h"
#import "iOSInterfaceObject.h"
#import "LocalizationGlobals.h"
#import "SFHFKeychainUtils.h"
#import "Reachability.h"

#define degreesToRadian(x) (M_PI * x / 180.0)
#define KEYCHAIN_SERVICE_NAME               @"ServiceMaxEnterprise"
extern void SVMXLog(NSString *format, ...);

@implementation LoginController

@synthesize didEnterAlertView;
@synthesize checkIn;
@synthesize eventInfoarray;

@synthesize txtUsernamePortrait;
@synthesize txtPasswordPortrait;
@synthesize txtUsernameLandscape;
@synthesize txtPasswordLandscape;

@synthesize activity;

@synthesize startDateForResponse, endDateForResponse;
//Abinash
@synthesize _username;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInternetConnectionChange:) name:kInternetConnectionChanged object:nil];
    }
    
    return self;
}

- (IBAction) signup:(id)sender
{
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }

    SignUpController * signUp = [[SignUpController alloc] initWithNibName:@"SignUpController" bundle:nil];
    signUp.modalPresentationStyle = UIModalPresentationFullScreen;
    signUp.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:signUp animated:YES completion:nil];
    [signUp release];
}

- (void) enableControls
{
    [login setEnabled:YES];
    [newloginButton setUserInteractionEnabled:YES];
    [sampleDataButton setUserInteractionEnabled:YES];
    [txtUsernameLandscape setUserInteractionEnabled:YES];
    [txtPasswordLandscape setUserInteractionEnabled:YES];
}

- (void) disableControls
{
    [login setEnabled:NO];
    [newloginButton setUserInteractionEnabled:NO];
    [sampleDataButton setUserInteractionEnabled:NO];
    [txtUsernameLandscape setUserInteractionEnabled:NO];
    [txtPasswordLandscape setUserInteractionEnabled:NO];
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
        continueFalg = TRUE;
    else
        continueFalg = FALSE;
}

- (void) alertViewCancel:(UIAlertView *)alertView
{
    continueFalg = FALSE;
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    didDismissalertview = TRUE;
}

-(IBAction)callLogin:(id)sender
{	
    appDelegate.IsSSL_error = FALSE;
	 appDelegate.IsLogedIn = ISLOGEDIN_TRUE;
    appDelegate.wsInterface.didOpComplete = FALSE;
    //shrinivas
    if (appDelegate.isBackground == TRUE)
        appDelegate.isBackground = FALSE;
    
    if (appDelegate.isForeGround == TRUE)
        appDelegate.isForeGround = FALSE;
    
    [self disableControls];
    
    didRunProcess = YES;
    didEnterAlertView = FALSE;
    
    [txtUsernameLandscape resignFirstResponder];
    [txtPasswordLandscape resignFirstResponder];

    appDelegate.username = txtUsernameLandscape.text;
    appDelegate.password = txtPasswordLandscape.text;
    
    [activity startAnimating];
           
    appDelegate.last_initial_data_sync_time = nil;
    appDelegate.do_meta_data_sync = DONT_ALLOW_META_DATA_SYNC;
    
//    [self loginWithUsernamePassword];
//    [appDelegate.wsInterface getOnDemandRecords:@"SVMXC__Service_Order__c" record_id:@"a1E70000000gtbiEAA"];
    
    BOOL ContinueLogin = [self CheckForUserNamePassword];  //SYNC_HISTORY PLIST  check should be done before calling to the
    if(ContinueLogin)
    {
        [self showHomeScreenviewController];
    }
    else
    {
        return;
    }
                 
    return;
}


- (BOOL) CheckForUserNamePassword
{
    if (!_username && !_password)                    //if key chain is nill - 
    {        
        [self loginWithUsernamePassword];
        if (appDelegate.wsInterface.didOpComplete == FALSE)
        {
            [appDelegate.dataBase clearDatabase];
        }
        if(![appDelegate isInternetConnectionAvailable])
        {
            return FALSE;
        }
        
        if (appDelegate.loginResult == nil) //RADHA 21/05/2011
            return FALSE;
        
        appDelegate.do_meta_data_sync = ALLOW_META_AND_DATA_SYNC;      //sahana9May
        return TRUE;                                                                                //sahana9May
    }
    
    
    else if (([txtPasswordLandscape.text isEqualToString:_password]) && ([txtUsernameLandscape.text isEqualToString:_username]) )   // if the user is already exists
    {
        BOOL retVal = [appDelegate.calDataBase isUsernameValid:txtUsernameLandscape.text];
        
        if (retVal == FALSE)
        {
            [self loginWithUsernamePassword];
            
            if (appDelegate.wsInterface.didOpComplete == FALSE)
            {
                [appDelegate.dataBase clearDatabase];
            }
            
            if(![appDelegate isInternetConnectionAvailable])
            {
                return FALSE;
            }
            if (appDelegate.loginResult == nil) //RADHA 21/05/2011
                return FALSE;
            
            appDelegate.do_meta_data_sync = ALLOW_META_AND_DATA_SYNC;    //sahana9May
            
        }
        else {
            [appDelegate updateInterfaceWithReachability:appDelegate.hostReach];	
            [appDelegate updateInterfaceWithReachability:appDelegate.internetReach];
        }
        if (homeScreenView)
            homeScreenView = nil;
        
		//Refresh the current server URl
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		appDelegate.currentServerUrl = [userDefaults objectForKey:SERVERURL];
		
        return TRUE;
    }
    
    //RADHA login without awitch user
    else if ([txtUsernameLandscape.text isEqualToString:_username] && (![txtPasswordLandscape.text isEqualToString:_password] && (![_password isEqualToString:nil]) && (![_password isEqualToString:@""])))
    {
        [self loginWithUsernamePassword];
        
        if (appDelegate.loginResult == nil) //RADHA 21/05/2011
            return FALSE;
        
        if (![appDelegate isInternetConnectionAvailable])
            return FALSE;
        
        if (homeScreenView)
            homeScreenView = nil;
        
        return TRUE;

        
    }
             
    
    else if ((![txtUsernameLandscape.text isEqualToString:_username] && (![_username isEqualToString:nil]) && (![_username isEqualToString:@""])) || (![txtPasswordLandscape.text isEqualToString:_password] && (![_password isEqualToString:nil]) && (![_password isEqualToString:@""])) ) //switch user
    {
               
        NSString * description = [appDelegate.wsInterface.tagsDictionary objectForKey:login_switch_user];
        NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_switch_user];
        NSString * Ok = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE];
        NSString * continue_ = [appDelegate.wsInterface.tagsDictionary objectForKey:login_continue];
        		
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:description delegate:self cancelButtonTitle:continue_ otherButtonTitles:Ok, nil];
        [alert show];
        [alert release];
        
       
        didEnterAlertView = TRUE;
        
        if (homeScreenView)
            homeScreenView = nil;
        
    }
    
    didDismissalertview = FALSE;
    if (didEnterAlertView)
    {
        while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, FALSE))
        {
            SMLog(@"alert for switch user");
            if (didDismissalertview == TRUE)
            {
                didDismissalertview = FALSE;
                break;
            }
        }
    }
    
    if (didEnterAlertView && continueFalg)
    {
        [self loginWithUsernamePassword];
        
        if (appDelegate.loginResult == nil) //RADHA 21/05/2011
            return FALSE;
        
        [appDelegate.dataBase deleteDatabase:DATABASENAME1];
        [appDelegate initWithDBName:DATABASENAME1 type:DATABASETYPE1];

      
        if(![appDelegate isInternetConnectionAvailable])
        {
            return FALSE;
        }
        
        if (appDelegate.isForeGround == FALSE && ![appDelegate isInternetConnectionAvailable])
            [self readUsernameAndPasswordFromKeychain];
        
        didEnterAlertView = FALSE;
        
        appDelegate.do_meta_data_sync = ALLOW_META_AND_DATA_SYNC;            //sahana9May
		
		[appDelegate updateSyncFailedFlag:SFALSE];
        
        return TRUE;                                                                                    //sahana9May
        
    }
    
    else if ((didEnterAlertView) && (continueFalg == FALSE))
    {
        [self enableControls];
        [activity stopAnimating];
        return FALSE;
    }
    
    return FALSE;
}

- (void) loginWithUsernamePassword
{
    //Siva Manne #3547
    if (![appDelegate isInternetConnectionAvailable])
    {
        [appDelegate updateInterfaceWithReachability:appDelegate.hostReach];	
        [appDelegate updateInterfaceWithReachability:appDelegate.internetReach];
    }
    
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        appDelegate.shouldShowConnectivityStatus = YES;
        [appDelegate displayNoInternetAvailable];
        [self enableControls];
        return;
    } 
    
    appDelegate.loginResult = nil;
    appDelegate.currentServerUrl = nil;
    
    [ZKServerSwitchboard switchboard].logXMLInOut = YES;
    [[ZKServerSwitchboard switchboard] loginWithUsername:txtUsernameLandscape.text password:txtPasswordLandscape.text target:self selector:@selector(didLogin:error:context:)];
    
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        appDelegate.shouldShowConnectivityStatus = YES;
        [appDelegate displayNoInternetAvailable];
        [self enableControls];
        return;
    } 
    
    didLoginCompleted = FALSE;
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        if (didLoginCompleted == TRUE)
            break;
        //shrinivas  ---- 02/05/2012
        if (appDelegate.isForeGround == TRUE)
        {
            appDelegate.didFinishWithError = FALSE;
            [activity stopAnimating];
            [self enableControls];
            return;
        }
        if (![appDelegate isInternetConnectionAvailable])
        {
            appDelegate.shouldShowConnectivityStatus = YES;
            [appDelegate displayNoInternetAvailable];
            [self enableControls];
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }

    }
    
}


- (void) doMetaAndDataSync
{
    SMLog(@"SAMMAN MetaSync WS Start: %@", [NSDate date]);
    
    time_t t1;
    time(&t1);
    
    NSString* txnstmt = @"BEGIN TRANSACTION";
    char * err ;
    int retval = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);    
    
    
    appDelegate.wsInterface.didOpComplete = FALSE;
    [appDelegate.wsInterface metaSyncWithEventName:SFM_METADATA eventType:INITIAL_SYNC values:nil];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        //shrinivas
        if (appDelegate.isForeGround == TRUE)
        {
            appDelegate.didFinishWithError = FALSE;
            [activity stopAnimating];
            [self enableControls];
            return;
        }   

        if (appDelegate.wsInterface.didOpComplete == TRUE)
            break; 
        
        if (![appDelegate isInternetConnectionAvailable])
            break;
        
    }
    
    SMLog(@"SAMMAN MetaSync WS End: %@", [NSDate date]);
    if([appDelegate enableGPS_SFMSearch])
    {
        //SFM Search 
        
        appDelegate.wsInterface.didOpSFMSearchComplete = FALSE;
        [appDelegate.wsInterface metaSyncWithEventName:SFM_SEARCH eventType:SYNC values:nil];
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
            if (![appDelegate isInternetConnectionAvailable])
                break;

            if (appDelegate.wsInterface.didOpSFMSearchComplete == TRUE)
                break; 
        }
        SMLog(@"SAMMAN MetaSync SFM Search End: %@", [NSDate date]);
        
        //SFM Search End
    }    
    [appDelegate getDPpicklistInfo];
    SMLog(@"META SYNC 1");
    
    if (appDelegate.didFinishWithError == TRUE)
    {
        appDelegate.didFinishWithError = FALSE;
        [activity stopAnimating];
        [self enableControls];
        return;
    }
    
    SMLog(@"SAMMAN DataSync WS Start: %@", [NSDate date]);
    appDelegate.wsInterface.didOpComplete = FALSE;
  
    //sahaan generate client req id for initital data sync                                                                                                                                                                                                                                                                     
   
    [appDelegate.wsInterface dataSyncWithEventName:EVENT_SYNC eventType:SYNC requestId:@""];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        //shrinivas
        if (appDelegate.isForeGround == TRUE)
        {
            appDelegate.didFinishWithError = FALSE;
            [activity stopAnimating];
            [self enableControls];
            return;
        }   
        
        if (![appDelegate isInternetConnectionAvailable])
            break;
        

        if (appDelegate.wsInterface.didOpComplete == TRUE)
        {
            break; 
        }
    }
 
    
    appDelegate.wsInterface.didOpComplete = FALSE;
    
    appDelegate.initial_dataSync_reqid = [iServiceAppDelegate GetUUID];
    
    SMLog(@"reqId%@" , appDelegate.initial_dataSync_reqid);
    [appDelegate.wsInterface dataSyncWithEventName:DOWNLOAD_CREITERIA_SYNC eventType:SYNC requestId:appDelegate.initial_dataSync_reqid];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        //shrinivas
        if (appDelegate.isForeGround == TRUE)
        {
            appDelegate.didFinishWithError = FALSE;
            [activity stopAnimating];
            [self enableControls];
            return;
        }   
        

        if (appDelegate.wsInterface.didOpComplete == TRUE)
        {
            break; 
        }
        if (![appDelegate isInternetConnectionAvailable] && appDelegate.data_sync_chunking == REQUEST_SENT)
        {
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
            {
                //shrinivas
                if (appDelegate.isForeGround == TRUE)
                {
                    appDelegate.didFinishWithError = FALSE;
                    [activity stopAnimating];
                    [self enableControls];
                    return;
                }  
                if ([appDelegate isInternetConnectionAvailable])
                {
                    [appDelegate goOnlineIfRequired];
                    [appDelegate.wsInterface dataSyncWithEventName:DOWNLOAD_CREITERIA_SYNC eventType:SYNC requestId:appDelegate.initial_dataSync_reqid];
                    break;
                }
            }
        }
    }
    SMLog(@"SAMMAN DataSync WS End: %@", [NSDate date]);
    SMLog(@"SAMMAN Incremental DataSync WS Start: %@", [NSDate date]);
    
    [appDelegate.wsInterface cleanUpForRequestId:appDelegate.initial_dataSync_reqid forEventName:@"CLEAN_UP_SELECT"];
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
        //shrinivas
        if (appDelegate.isForeGround == TRUE)
        {
            appDelegate.didFinishWithError = FALSE;
            [activity stopAnimating];
            [self enableControls];
            return;
        }  
        if (![appDelegate isInternetConnectionAvailable])
            break;
        
        if(appDelegate.Incremental_sync_status == CLEANUP_DONE)
            break;
    }
    appDelegate.Incremental_sync_status = INCR_STARTS;
    
    [appDelegate.wsInterface PutAllTheRecordsForIds];
      while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        //shrinivas
        if (appDelegate.isForeGround == TRUE)
        {
            appDelegate.didFinishWithError = FALSE;
            [activity stopAnimating];
            [self enableControls];
            return;
        }  
        if (![appDelegate isInternetConnectionAvailable])
            break;

        if (appDelegate.Incremental_sync_status == PUT_RECORDS_DONE)
            break; 
    }
    
            
    SMLog(@"SAMMAN Incremental DataSync WS End: %@", [NSDate date]);
    
    SMLog(@"SAMMAN Update Sync Records Start: %@", [NSDate date]);

    if (appDelegate.isForeGround == FALSE)
        [appDelegate.databaseInterface updateSyncRecordsIntoLocalDatabase];

    //Radha purging - 10/April/12
    NSMutableArray * recordId = [appDelegate.dataBase getAllTheRecordIdsFromEvent];
    
     appDelegate.initialEventMappinArray = [appDelegate.dataBase checkForTheObjectWithRecordId:recordId];
    //Radha End

    
    SMLog(@"SAMMAN Update Sync Records End: %@", [NSDate date]);
    //remove recents
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath = [rootPath stringByAppendingPathComponent:OBJECT_HISTORY_PLIST];
    NSError *delete_error;
    if ([fileManager fileExistsAtPath:plistPath] == YES)
    {
        [fileManager removeItemAtPath:plistPath error:&delete_error];		
    }
    
    //Temperory Method - Removed after DataSync is implemented completly
    [appDelegate.dataBase insertUsernameToUserTable:txtUsernameLandscape.text];

    txnstmt = @"END TRANSACTION";
    retval = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);    
    
    time_t t2;
    time(&t2);
    double diff = difftime(t2,t1);
    SMLog(@"time taken for meta and data sync = %f",diff);
    
}

- (void) didLogin:(ZKLoginResult *)lr error:(NSError *)error context:(id)context
{
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        [self enableControls];
        return;
    }
    

    // Radha 28th April 2011 
    // Assign the Session id to the loginResult
    
    appDelegate.loginResult = lr;
   
    NSString * serverUrl = [lr serverUrl];
    NSArray * array = [serverUrl pathComponents];
    NSString * server = [NSString stringWithFormat:@"%@//%@", [array objectAtIndex:0], [array objectAtIndex:1]];
    
    if (appDelegate.currentServerUrl != nil)
    {
        appDelegate.currentServerUrl = nil;
    }
    appDelegate.currentServerUrl = [[NSString stringWithFormat:@"%@", server] retain];
    
   // [appDelegate.currentServerUrl retain];
    
    ZKUserInfo * userInfo = [lr userInfo];
    if (appDelegate.current_userId != nil)
    {
        appDelegate.current_userId = nil;
    }
    
    appDelegate.current_userId = [NSString stringWithFormat:@"%@", userInfo.userId];
    SMLog(@"usetId = %@", appDelegate.current_userId);
	
    if (appDelegate.currentUserName != nil)
    {
        appDelegate.currentUserName = nil;
    }
    appDelegate.currentUserName = [[userInfo fullName] mutableCopy];
	
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults)
    {
        [userDefaults setObject:appDelegate.currentUserName forKey:@"UserFullName"];
        [userDefaults setObject:appDelegate.currentServerUrl forKey:@"serverurl"];
    }
    else
    {
        SMLog(@"Failed to get the User Defaults");
        return;
    }
    NSDictionary * defaultTags = [appDelegate.wsInterface getDefaultTags];
    
   // NSString * serviceMax = [defaultTags objectForKey:ALERT_ERROR_TITLE];
    NSString * alert_ok = [defaultTags objectForKey:ALERT_ERROR_OK];
    NSString * description = @"";
    if ([error userInfo] == nil)
        description = [appDelegate.wsInterface.tagsDictionary objectForKey:login_connection_error]; 
    else
        description = [[error userInfo] objectForKey:@"faultstring"];
    
    //create SYNC_HISTORY PLIST 
  
    
  
    if (lr == nil)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:alert_authentication_error_] message:description delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
        [alert show];
        [alert release];
        [activity stopAnimating];
        
        appDelegate.wsInterface.didOpComplete = TRUE;
        SMLog(@"IComeOUTHere login");
        didLoginCompleted  = TRUE;
        appDelegate.didLoginAgain = TRUE;
        
        [self enableControls];
        
        return;
    }
    // before anything else, check for correct version
    BOOL isVersionCorrect = [self checkVersion];
    
    if (!isVersionCorrect)
    {
        [[ZKServerSwitchboard switchboard] setApiUrl:nil];
        
        [self enableControls];
        
        return;
    }

    appDelegate.didCheckProfile = FALSE;
    appDelegate.userProfileId = @"";
    
    //Dont remove the code in the comments below
    [appDelegate.wsInterface checkIfProfileExistsWithEventName:VALIDATE_PROFILE type:GROUP_PROFILE];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        if (![appDelegate isInternetConnectionAvailable])
        {
            appDelegate.shouldShowConnectivityStatus = YES;
            [appDelegate displayNoInternetAvailable];
            [self enableControls];
            return;
        }
        
        if (appDelegate.didCheckProfile)
        {
            break;
        }
        if (appDelegate.connection_error)
        {
            break;
        }
    }    

    if ([appDelegate.userProfileId length] == 0)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_TITLE] message:[appDelegate.wsInterface.tagsDictionary objectForKey:profile_error] delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
        [alert show];
        [alert release];
        [activity stopAnimating];
        [self enableControls];
        
        return;
    }
    

    [self getTagsForTheFirstTime];
    
    didLoginCompleted = TRUE;
    appDelegate.didLoginAgain = TRUE;
    
   // [self checkFavoritesUser]; //PLEASE USE FINGERS AS WELL AS BRAIN WHILE CODING - pavaman

    [self storeLoginDetails];
    
    appDelegate.loggedInUserId = [[lr userId] retain];
}

-(void)getTagsForTheFirstTime
{
    appDelegate.download_tags_done = FALSE;
    appDelegate.firstTimeCallForTags = TRUE;
    [appDelegate.wsInterface metaSyncWithEventName:MOBILE_DEVICE_TAGS eventType:SYNC values:nil];
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
        if(appDelegate.download_tags_done)
            break;
    }
    appDelegate.firstTimeCallForTags= FALSE;
}

- (void) checkFavoritesUser
{
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        [self enableControls];
        return;
    }
    
    NSDictionary * dict = [appDelegate.savedReference objectAtIndex:0];
    NSString * savedUsername = [dict objectForKey:@"username"];
    
    NSError * error = nil;
    if (savedUsername == nil)
        savedUsername = [SFHFKeychainUtils getPasswordForUsername:@"username" andServiceName:KEYCHAIN_SERVICE_NAME error:&error];
    
    if (![appDelegate.username isEqualToString:savedUsername])
    {
        [self deleteFavoritesCache];
    }
}

- (void) deleteFavoritesCache
{
    // Delete all contents present in the Documents folder
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        [self enableControls];
        return;
    }
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectoryPath = [paths objectAtIndex:0];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError * error;
    NSArray *array = [fileManager contentsOfDirectoryAtPath:documentsDirectoryPath error:&error];
    
    if (array != nil)
    {
        for (int i = 0; i < [array count]; i++)
        {
            NSString * path = [documentsDirectoryPath stringByAppendingPathComponent:[array objectAtIndex:i]];
            [fileManager removeItemAtPath:path error:&error];
        }
    }
}

#pragma mark - Service Report Logo

- (void) getServiceReportLogo
{
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        [self enableControls];
        return;
    }

    NSString * _query = [NSString stringWithFormat:@"SELECT Body FROM Document Where Name = 'ServiceMax_iPad_CompanyLogo'"];
    
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetServiceReportLogo:error:context:) context:nil];
}

- (void) didGetServiceReportLogo:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    // Store the image in a appDelegate UIImage
    
    NSArray * array = [result records];
    
    if ([array count] == 0)
    {
        didGetServiceReportLogo = YES;
        return;
    }
    
    NSString * dataString = [[[array objectAtIndex:0] fields] objectForKey:@"Body"];
    
    NSData * data = [Base64 decode:dataString];
    
    // Decode data from Base64
    if (data != nil)
    {
        appDelegate.serviceReportLogo = [[UIImage alloc] initWithData:data];
        
        // Save the image to the application bundle
        NSFileManager * fileManager = [NSFileManager defaultManager];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *saveDirectory = [paths objectAtIndex:0];	
        NSString * filePath = [saveDirectory stringByAppendingPathComponent:@"header_image.png"];
        
        [fileManager createFileAtPath:filePath contents:data attributes:nil];
    }
    else
        appDelegate.serviceReportLogo = [UIImage imageNamed:@"header_image.png"];
    
    didGetServiceReportLogo = YES;
}

- (void) initDebriefData:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [self enableControls];
        return;
    }
    
    NSArray * array = [result records];
    if ([array count] == 0)
    {
        if (!isSampleDataButtonChecked)
        {
            [self createSampleData];
        }
    }
    else
    {
        if (isSampleDataButtonChecked)
        {
            didCreateSampleData = NO;
            [self createSampleData];
        }
    }
    
    for (int i = 0; i < [array count]; i++)
	{
		ZKSObject * obj = [array objectAtIndex:i];
        
        SMLog(@"SVMXC__Service_Group__c = %@", [[obj fields] objectForKey:@"SVMXC__Service_Group__c"]);
        if (appDelegate.appServiceTeamId != nil)
        {
            appDelegate.appServiceTeamId = nil;
        }
		appDelegate.appServiceTeamId = [[[obj fields] objectForKey:@"SVMXC__Service_Group__c"] retain];
        
        if (appDelegate.appTechnicianId != nil)
        {
            appDelegate.appTechnicianId = nil;
        }
        appDelegate.appTechnicianId = [[[obj fields] objectForKey:@"Id"] retain];
	}

    NSString * _query = [NSString stringWithFormat:@"Select SVMXC__Street__c, SVMXC__City__c, SVMXC__State__c, SVMXC__Zip__c, SVMXC__Country__c FROM SVMXC__Service_Group_Members__c WHERE Id = '%@'", appDelegate.appTechnicianId];
    
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didQueryTechnician:error:context:) context:nil];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        SMLog(@"LoginViewController initDebrief in while loop");
        if (![appDelegate isInternetConnectionAvailable])
        {
            [activity stopAnimating];
            break;
        }
        if (isSampleDataButtonChecked)
        {
            if (didQueryTechnician && didCreateSampleData)
                break;
        }
        if (appDelegate.connection_error)
        {
            [activity stopAnimating];
            break;
        }
        else
        {
            if (didQueryTechnician)
                break;
        }
        SMLog(@"3");
    }

    if (isSampleDataButtonChecked)
    {
        isSampleDataButtonChecked = NO;
    }

    didDebriefData = YES;
    return;
}
- (void) didQueryTechnician:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    NSArray * array = [result records];
    
    if ([array count] > 0)
    {
        ZKSObject * obj = [array objectAtIndex:0];
        NSDictionary * dict = [obj fields];

        NSMutableString * address = nil;
        address = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
        
        NSString * woStreet = [[dict objectForKey:@"SVMXC__Street__c"] isKindOfClass:[NSString class]]?[dict objectForKey:@"SVMXC__Street__c"]:@"";
        NSString * woCity = [[dict objectForKey:@"SVMXC__City__c"] isKindOfClass:[NSString class]]?[dict objectForKey:@"SVMXC__City__c"]:@"";
        NSString * woState = [[dict objectForKey:@"SVMXC__State__c"] isKindOfClass:[NSString class]]?[dict objectForKey:@"SVMXC__State__c"]:@"";
        NSString * woZip = [[dict objectForKey:@"SVMXC__Zip__c"] isKindOfClass:[NSString class]]?[dict objectForKey:@"SVMXC__Zip__c"]:@"";
        NSString * woCountry = [[dict objectForKey:@"SVMXC__Country__c"] isKindOfClass:[NSString class]]?[dict objectForKey:@"SVMXC__Country__c"]:@"";

        if ([woStreet length] > 0)
            [address appendString:woStreet];

        if ([woCity length] > 0)
        {
            if ([address length] > 0)
                [address appendString:[NSString stringWithFormat:@", %@", woCity]];
            else
                [address appendString:[NSString stringWithFormat:@"%@", woCity]];
        }

        if ([woState length] > 0)
        {
            if ([address length] > 0)
                [address appendString:[NSString stringWithFormat:@", %@", woState]];
            else
                [address appendString:[NSString stringWithFormat:@"%@", woState]];
        }

        if ([woZip length] > 0)
        {
            if ([address length] > 0)
                [address appendString:[NSString stringWithFormat:@", %@", woZip]];
            else
                [address appendString:[NSString stringWithFormat:@"%@", woZip]];
        }

        if ([woCountry length] > 0)
        {
            if ([address length] > 0)
                [address appendString:[NSString stringWithFormat:@", %@", woCountry]];
            else
                [address appendString:[NSString stringWithFormat:@"%@", woCountry]];
        }
        
        appDelegate.technicianAddress = address;
        
        SMLog(@"Technician Address = %@", appDelegate.technicianAddress);
    }
    else
        appDelegate.technicianAddress = @"";  
    
    didQueryTechnician = YES;
}

- (void) showModalViewController
{
    didRunProcess = NO;
    
    /*if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        [self enableControls];
        return;
    }*/

    [appDelegate.wsInterface getTags];
}

- (BOOL) checkVersion
{
        
    appDelegate.didGetVersion = FALSE;
    [appDelegate.wsInterface getSvmxVersion];
    
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
        //shrinivas
        if (appDelegate.isForeGround == TRUE)
        {
            appDelegate.didFinishWithError = FALSE;
            [activity stopAnimating];
            [self enableControls];
            return NO;
        }

        if (![appDelegate isInternetConnectionAvailable])
            return NO;
        SMLog(@"LoginViewController checkVersion in while loop");
        if (appDelegate.didGetVersion)
            break;
        SMLog(@"4");
    }
    
    NSString * stringNumber = [appDelegate.SVMX_Version stringByReplacingOccurrencesOfString:@"." withString:@""];
    int _stringNumber = [stringNumber intValue];
    int version = (APPVERSION * 100000);
    if(_stringNumber >= version)
    {
        SMLog(@"greater than %f", APPVERSION);
        appDelegate.wsInterface.isLoggedIn = YES;
        SMLog(@"Installed Package Version = %@",stringNumber);
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if (userDefaults) 
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
        
        NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:login_incorrect_version];
        NSString * ipad_version = [appDelegate.wsInterface.tagsDictionary objectForKey:login_ipad_app_version];
        NSString * servicemax_version = [appDelegate.wsInterface.tagsDictionary objectForKey:login_serivcemax_version];
        
      //  NSString * version = [dict objectForKey:ABOUT_VERSION_TITLE];
        // Read version info from plist
        NSString * version_app  = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
        
        NSString * message  = [NSString stringWithFormat:@"%@ %@  %@ %.5f .",ipad_version, version_app , servicemax_version,APPVERSION];
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message  delegate:self cancelButtonTitle:ALERT_ERROR_OK_DEFAULT otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        SMLog(@"lesser than %f", APPVERSION);
        [activity stopAnimating];
        
        [UIView beginAnimations:@"showProgress" context:nil];
        [UIView setAnimationDuration:0.75];
        progressTitle.alpha = 0.0;
        progressBar.alpha = 0.0;
        [UIView commitAnimations];
            
        return NO;
    }
    
    return NO;
}



- (void) showHomeScreenviewController
{
    didRunProcess = NO;  //Shrinivas -----> BUG #4090
    if (appDelegate.didFinishWithError == TRUE)
    {
        return;
    }
    if (homeScreenView == nil)
    {
        homeScreenView = [[iPadScrollerViewController alloc] initWithNibName:@"iPadScrollerViewController" bundle:nil];
        homeScreenView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        homeScreenView.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:homeScreenView animated:YES completion:nil];
        [homeScreenView release];
    }
    else
    {
        [appDelegate.modalCalendar reloadCalendar];
    }
}

-(void)hadLoginError:(ZKSoapException *)e
{
	[appDelegate popupActionSheet:[e reason]];
}

- (NSString *) getUserId
{
    return userId;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //sahana initial sync crash fix
    checkIn = TRUE;
    
    didRunProcess = NO;
    
    appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    NSString * kRestoreLocationKey = [NSString stringWithFormat:@"RestoreLocation"];
    NSMutableArray * temp = [[NSUserDefaults standardUserDefaults] objectForKey:kRestoreLocationKey];
    SMLog(@"%@", temp);
    
    appDelegate.priceBookName = @"Standard Price Book";
    
    NSError * error = nil;
    _username = [SFHFKeychainUtils getPasswordForUsername:@"username" andServiceName:KEYCHAIN_SERVICE_NAME error:&error];
    SMLog(@"%@", _username);
    if ((_username == nil) && (temp != nil))
    {
        _username = [[temp objectAtIndex:0] objectForKey:@"username"];
    }
    txtUsernameLandscape.text = _username;
    
    // Retrieve password from keychain
    
    _password = [SFHFKeychainUtils getPasswordForUsername:@"password" andServiceName:KEYCHAIN_SERVICE_NAME error:&error];
    SMLog(@"%@", _password);
    if ((_password == nil) && (appDelegate.savedReference != nil))
    {
        _password = [[appDelegate.savedReference objectAtIndex:0] objectForKey:@"password"];
    }
    txtPasswordLandscape.text = _password;
    
    [createSampleLabel setText:SAMPLEDATA];
    
    //Radha
    [checkBoxTitle setText:@"Initial Meta Sync"];
    isinitialSyncButtonChecked = FALSE;
    
    //Abinash
    [incrementalMetasync setText:@"Do incremental MetaSync"];
    isincrementalMetaSyncButtonChecked = FALSE;
    
    didDebriefData = FALSE;
    didQueryTechnician = FALSE;
    didEnterAlertView = FALSE;  

    
}

- (void) didInternetConnectionChange:(NSNotification *)notification
{
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber * currentReach = (NSNumber *) notification.object;
    BOOL isReachable = [currentReach boolValue];
    if (isReachable)
    {
        SMLog(@"Re-enabling Login controls");
        [self enableControls];
    }
    else
    {
        [activity stopAnimating];
        didCancelURL = NO;
        
        [UIView beginAnimations:@"showProgress" context:nil];
        [UIView setAnimationDuration:0.75];
        progressTitle.alpha = 0.0;
        progressBar.alpha = 0.0;
        [UIView commitAnimations];
        
        if (didRunProcess)
        {
            didRunProcess = NO;
            [appDelegate displayNoInternetAvailable];
            return;
        }
    }
    
    if (didCancelURL && isShowingLogin)
    {
        didCancelURL = NO;
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"ServiceMax" message:@"No Internet Connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}
- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
    }
    else
        if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
        }
        else
            return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait)
    {
        // SMLog(@"Portrait");
        // LoginController * selfView = [self getViewForOrientation:@"Portrait"];
        self.view = portrait;
        self.view.transform = CGAffineTransformIdentity; 
        self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(0)); 
        self.view.bounds = CGRectMake(0.0, 0.0, 768, 1024.0);
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        // SMLog(@"Portrait");
        // LoginController * selfView = [self getViewForOrientation:@"Portrait"];
        self.view = portrait;
        self.view.transform = CGAffineTransformIdentity; 
        self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(180)); 
        self.view.bounds = CGRectMake(0.0, 0.0, 768, 1024.0);
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        // SMLog(@"Landscape");
        // LoginController * selfView = [self getViewForOrientation:@"Landscape"];
        self.view = landscape;
        self.view.transform = CGAffineTransformIdentity; 
        self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(-90));
        self.view.bounds = CGRectMake(0.0, 0.0, 1024.0, 748.0);
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        self.view = landscape;
        self.view.transform = CGAffineTransformIdentity; 
        self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(90));
        self.view.bounds = CGRectMake(0.0, 0.0, 1024.0, 748.0);
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

- (LoginController *) getViewForOrientation:(NSString *)toOrientation
{
	NSArray * nibContents = [[NSBundle mainBundle] loadNibNamed:@"LoginController" owner:self options:nil];
	NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
	LoginController * customView = nil;
	
    NSObject* nibItem = nil;
	
    while ( (nibItem = [nibEnumerator nextObject]) != nil)
	{
		if ( [nibItem isKindOfClass: [UIView class]])
		{
			customView = (LoginController *) nibItem;
        
			if ([[customView description] isEqualToString:toOrientation])
				break; // OneTeamUS We have a winner
			else
				customView = nil;
		}
	}
	return customView;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload
{
    [login release];
    login = nil;
    [createSampleLabel release];
    createSampleLabel = nil;
    [newloginButton release];
    newloginButton = nil;
    [IncrementalMetasync release];
    IncrementalMetasync = nil;
    [incrementalMetasync release];
    incrementalMetasync = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [login release];
    [createSampleLabel release];
    [newloginButton release];
    [IncrementalMetasync release];
    [incrementalMetasync release];
    [super dealloc];
}

- (IBAction) clickSampleDataButton
{
    isSampleDataButtonChecked = !isSampleDataButtonChecked;
    // manipulate image of button accordingly
    if (isSampleDataButtonChecked)
    {
        [sampleDataButton setBackgroundImage:[UIImage imageNamed:@"login-checkbox-selected.png"] forState:UIControlStateNormal];
        [sampleDataButton setBackgroundImage:[UIImage imageNamed:@"login-checkbox-selected.png"] forState:UIControlStateHighlighted];
    }
    else 
    {
        [sampleDataButton setBackgroundImage:[UIImage imageNamed:@"login-checkbox-nonselected.png"] forState:UIControlStateNormal];
        [sampleDataButton setBackgroundImage:[UIImage imageNamed:@"login-checkbox-nonselected.png"] forState:UIControlStateNormal];
    }

}

- (void) checkSampleDataCreation
{
    if (isSampleDataButtonChecked)
        [self createSampleData];
}

- (void) createSampleData;
{
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [self enableControls];
        return;
    }
    
    NSArray * _array = [NSTimeZone knownTimeZoneNames];
    SMLog(@"%@", _array);
    // <timezone>current string that you are putting</timezone><GMTOffset>+05:30</GMTOffset>//
    NSTimeZone * _timeZone = [NSTimeZone defaultTimeZone];
    NSInteger secondsFromGMT = [_timeZone secondsFromGMT];
    
    NSString * dateStr = nil;
    
    float _minutes = secondsFromGMT / 60;
    int hours = _minutes / 60;
    float _hours = _minutes / 60;
    int minutes = (_hours - hours) * 60;
    
    if (hours < 10)
    {
        if (minutes < 10)
            dateStr = [NSString stringWithFormat:@"0%d:0%d", hours, minutes];
        else
            dateStr = [NSString stringWithFormat:@"0%d:%d", hours, minutes];
    }
    else
    {
        if (minutes < 10)
            dateStr = [NSString stringWithFormat:@"%d:0%d", hours, minutes];
        else
            dateStr = [NSString stringWithFormat:@"%d:%d", hours, minutes];
    }
    
    if (secondsFromGMT > 0)
        dateStr = [NSString stringWithFormat:@"+%@", dateStr];
    else
        dateStr = [NSString stringWithFormat:@"-%@", dateStr];

    NSString * timeZone = [NSString stringWithFormat:@"<timezone>%@</timezone><GMTOffset>%@</GMTOffset>", [[NSTimeZone defaultTimeZone] name], dateStr];
    // Insert a dummy record in SVMXC__ServiceMax_List__c
    ZKSObject * obj = [[ZKSObject alloc] initWithType:@"SVMXC__ServiceMax_List__c"];
    [obj setFieldValue:timeZone field:@"SVMXC__Additional_Information__c"];
    NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:0];
    [array addObject:obj];
    
    [[ZKServerSwitchboard switchboard] create:array target:self selector:@selector(didCreateDummyRecord:error:context:) context:nil];

    // Analyser
    [obj release];
    [array release];
}

- (void) didCreateDummyRecord:(NSArray *)result error:(NSError *)error context:(id)context;
{
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [self enableControls];
        return;
    }
    
    [UIView beginAnimations:@"showProgress" context:nil];
    [UIView setAnimationDuration:0.75];
    progressTitle.alpha = 0.0;
    progressBar.alpha = 0.0;
    [UIView commitAnimations];

    if ([result count] > 0)
    {
        // Start getting sample data creation progress
        ZKSaveResult * obj = [result objectAtIndex:0];
        [self getSampleDataCreationProgressForServiceMax_List_Id:[obj description]];
        dummyId = [[obj description] retain];
    }
    else
    {
        didCreateSampleData = YES;
    }
}

- (void) getSampleDataCreationProgressForServiceMax_List_Id:(NSString *)Id;
{
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [self enableControls];
        return;
    }
    
    if (![Id isKindOfClass:[NSString class]])
        Id = dummyId;
    NSString * _query = [NSString stringWithFormat:@"SELECT SVMXC__Discount__c From SVMXC__ServiceMax_List__c WHERE Id = '%@'", Id];
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetProgress:error:context:) context:Id];
}

- (void) didGetProgress:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [self enableControls];
        return;
    }
    
    NSArray * array = [result records];
    if ([array count] > 0)
    {
        ZKSObject * obj = [array objectAtIndex:0];
        NSString * discountValue = [[obj fields] objectForKey:@"SVMXC__Discount__c"];
        if (![discountValue isKindOfClass:[NSString class]])
        {
            // Call Login
            [activity stopAnimating];
            didCreateSampleData = YES;
            return;
        }
        
        float discount = [discountValue floatValue];
        progressBar.progress = discount/100;
        
        if (discount == 100.0)
        {
            // Call Login
            [activity stopAnimating];
            didCreateSampleData = YES;
        }
        else
        {
            [self getSampleDataCreationProgressForServiceMax_List_Id:nil];
        }

    }
    else
    {
        if (![appDelegate isInternetConnectionAvailable])
        {
            [activity stopAnimating];
            [self enableControls];
            return;
        }

        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(getSampleDataCreationProgressForServiceMax_List_Id:) userInfo:context repeats:NO];
    }
}


- (void) storeLoginDetails
{
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.savedReference removeAllObjects];

    NSString * kRestoreLocationKey = [NSString stringWithFormat:@"RestoreLocation"];
    NSMutableArray * savedReference = [[NSUserDefaults standardUserDefaults] objectForKey:kRestoreLocationKey];

    if (savedReference != nil)
    {
        [savedReference removeAllObjects];
        [[NSUserDefaults standardUserDefaults] setObject:appDelegate.savedReference forKey:kRestoreLocationKey];
    }
    else
    {
        // Do nothing
    }
    
    NSError * error = nil;
    [SFHFKeychainUtils storeUsername:@"username" andPassword:appDelegate.username forServiceName:KEYCHAIN_SERVICE_NAME updateExisting:YES error:&error];
    SMLog(@"%@", error.description);
    [SFHFKeychainUtils storeUsername:@"password" andPassword:appDelegate.password forServiceName:KEYCHAIN_SERVICE_NAME updateExisting:YES error:&error];
    SMLog(@"%@", error.description);
}

- (void) updateSampleDataCreationProgress;
{
}

// #################################################################################################
#pragma mark -
#pragma mark Settings Info
- (void) startQueryConfiguration
{
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [self enableControls];
        return;
    }
    // Get details of the IPAD Module
    NSString * _query = @"SELECT Id, SVMXC__Name__c, SVMXC__Description__c, SVMXC__ModuleID__c, SVMXC__IsStandard__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__ModuleID__c = \'IPAD\' AND RecordType.Name = \'MODULE\'";
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetModuleInfo:error:context:) context:nil];
}

- (void) didGetModuleInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [self enableControls];
        return;
    }

    // Get Submodules Info (query could return multiple rows)
    if ([[result records] count] > 0)
    {
        ZKSObject * obj = [[result records] objectAtIndex:0];
        NSString * moduleInfo = [[obj fields] objectForKey:@"Id"];
        NSString * _query = [NSString stringWithFormat:@"SELECT Id, SVMXC__ModuleID__c, SVMXC__SubmoduleID__c, SVMXC__Name__c, SVMXC__Description__c, SVMXC__IsStandard__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__Module__c = \'%@\' AND RecordType.Name = \'SUBMODULE\'", moduleInfo];
        [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetSubModuleInfo:error:context:) context:nil];
    }
    else
    {
        // Continue logging in
        didRetrieveReportSettings = YES;
    }
}

- (void) didGetSubModuleInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [self enableControls];
        return;
    }

    // Get Settings Info(query could return multiple rows)
    if ([[result records] count] > 0)
    {
        NSString * _query = [NSString stringWithFormat:@"SELECT Id, SVMXC__SubmoduleID__c, SVMXC__SettingID__c, SVMXC__Setting_Unique_ID__c, SVMXC__Settings_Name__c, SVMXC__Data_Type__c, SVMXC__Values__c, SVMXC__Default_Value__c, SVMXC__Setting_Type__c, SVMXC__Search_Order__c, SVMXC__IsPrivate__c, SVMXC__Active__c, SVMXC__Description__c, SVMXC__IsStandard__c, SVMXC__Submodule__c FROM SVMXC__ServiceMax_Processes__c WHERE SVMXC__SubmoduleID__c = 'IPAD004' AND RecordType.Name = \'SETTINGS\' ORDER BY SVMXC__Setting_Unique_ID__c"];
        [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetSettingsInfo:error:context:) context:nil];
    }
    else
    {
        // Continue logging in
        didRetrieveReportSettings = YES;
    }
}

- (void) didGetSettingsInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [self enableControls];
        return;
    }

    // Get the Active Global Profile
    if ([[result records] count] > 0)
    {
        settingInfoId = [[NSMutableString alloc] initWithCapacity:0];
        settingsInfoArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i = 0; i < [[result records] count]; i++)
        {
            ZKSObject * obj = [[result records] objectAtIndex:i];
            
            [settingsInfoArray addObject:[obj fields]];
            
            if ([settingInfoId length] == 0)
                [settingInfoId appendFormat:@"(\'%@\'", [[obj fields] objectForKey:@"Id"]];
            else
                [settingInfoId appendFormat:@", \'%@\'", [[obj fields] objectForKey:@"Id"]];
        }
        [settingInfoId appendString:@")"];
        
        NSString * _query = @"Select Id, SVMXC__Profile_Name__c, SVMXC__Active__c, SVMXC__IsDefault__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__RecordType_Name__c=\'Configuration Profile\' and SVMXC__Configuration_Type__c = \'Global\' and SVMXC__Active__c = true";
        [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetActiveGlobalProfile:error:context:) context:nil];
    }
    else
    {
        // Continue logging in
        didRetrieveReportSettings = YES;
    }
}

- (void) didGetActiveGlobalProfile:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [self enableControls];
        return;
    }
    
    // Get Settings value Info(query could return multiple rows)
    if ([[result records] count] > 0)
    {
        ZKSObject * obj = [[result records] objectAtIndex:0];
        ActiveGloProInfoId = [[[obj fields] objectForKey:@"Id"] retain];
        NSString * _query = nil;
        if ([settingInfoId length] != 0)
            _query = [NSString stringWithFormat:@"Select Id, SVMXC__Setting_Configuration_Profile__c, SVMXC__Setting_ID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Active__c, SVMXC__IsDefault__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Setting_Configuration_Profile__c = \'%@\' AND SVMXC__Setting_ID__c IN %@ AND RecordType.Name = \'SETTING VALUE\' ORDER BY SVMXC__Setting_Unique_ID__c", ActiveGloProInfoId, settingInfoId];
        else
            _query = [NSString stringWithFormat:@"SELECT Id, SVMXC__Setting_Configuration_Profile__c, SVMXC__Setting_ID__c, SVMXC__Internal_Value__c, SVMXC__Display_Value__c, SVMXC__Active__c, SVMXC__IsDefault__c FROM SVMXC__ServiceMax_Config_Data__c WHERE SVMXC__Setting_Configuration_Profile__c = \'%@' AND RecordType.Name = \'SETTING VALUE\' ORDER BY SVMXC__Setting_Unique_ID__c", ActiveGloProInfoId];
        [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetSettingsValue:error:context:) context:nil];
    }
    else
    {
        // Continue logging in
        didRetrieveReportSettings = YES;
    }
}

- (void) didGetSettingsValue:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [self enableControls];
        return;
    }
    
    if ([[result records] count] > 0)
    {
        appDelegate.serviceReport = [[NSMutableDictionary alloc] initWithCapacity:0];
        appDelegate.addressType = [[NSMutableString alloc] initWithCapacity:0];
        
        settingsValueArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        for (int i = 0; i < [[result records] count]; i++)
        {
            ZKSObject * obj = [[result records] objectAtIndex:i];
            [settingsValueArray addObject:[obj fields]];
            
            // settingsValueArray
            if (appDelegate.serviceReportValueMapping == nil)
                appDelegate.serviceReportValueMapping = [[NSMutableArray alloc] initWithCapacity:0];
            else
            {
                NSDictionary * dict = [NSDictionary dictionaryWithObject:[[obj fields] objectForKey:@"SVMXC__Internal_Value__c"] forKey:[[obj fields] objectForKey:@"SVMXC__Display_Value__c"]];
                [appDelegate.serviceReportValueMapping addObject:dict];
            }
        }
        
        for (int i = 0; i < [settingsInfoArray count]; i++)
        {
            for (int j = 0; j < [settingsValueArray count]; j++)
            {
                NSString * settingsInfoSettingId = [[settingsInfoArray objectAtIndex:i] objectForKey:@"Id"];
                NSString * settingsValueSettingId = [[settingsValueArray objectAtIndex:j] objectForKey:@"SVMXC__Setting_ID__c"];
                if ([settingsValueSettingId isEqualToString:settingsInfoSettingId])
                {
                    if (appDelegate.soqlQuery == nil)
                        appDelegate.soqlQuery = [[NSMutableString alloc] initWithCapacity:0];
                    if ([[[settingsInfoArray objectAtIndex:i] objectForKey:@"SVMXC__Setting_Unique_ID__c"] Contains:@"IPAD004"])
                    {
                        NSString * subModuleSettingKey = [[settingsInfoArray objectAtIndex:i] objectForKey:@"SVMXC__Setting_Unique_ID__c"];
                        
                        NSString * keyNumVal = [subModuleSettingKey stringByReplacingOccurrencesOfString:@"IPAD004_SET" withString:@""];
                        
                        NSInteger intNumVal = [keyNumVal intValue];
                        
                        if (intNumVal >= 11 && intNumVal <= 20)
                        {
                            NSString * queryField = [[settingsValueArray objectAtIndex:j] objectForKey:@"SVMXC__Internal_Value__c"];
                            if ([queryField isKindOfClass:[NSNull class]])
                                continue;
                            [appDelegate.soqlQuery appendString:@","];
                            [appDelegate.soqlQuery appendString:queryField];
                        }
                        
                        if (intNumVal == 23)
                        {
                            appDelegate.signatureCaptureUpload = [[[settingsValueArray objectAtIndex:j] objectForKey:@"SVMXC__Internal_Value__c"] boolValue];
                        }
                    }
                    // appDelegate.addressType = @"";
                    if ([[[settingsInfoArray objectAtIndex:i] objectForKey:@"SVMXC__Settings_Name__c"] Contains:@"Address Type"])
                    {
                        NSString * queryField = [[settingsValueArray objectAtIndex:j] objectForKey:@"SVMXC__Internal_Value__c"];
                        if ([queryField isKindOfClass:[NSNull class]])
                        {
                            [appDelegate.soqlQuery appendFormat:@",%@", @"SVMXC__Company__r.BillingCountry,SVMXC__Company__r.BillingPostalCode, SVMXC__Company__r.BillingState, SVMXC__Company__r.BillingCity, SVMXC__Company__r.BillingStreet"];
                            continue;
                        }
                        else if ([queryField isEqualToString:@"Account Bill To"]) // SVMXC__Company__r
                            [appDelegate.soqlQuery appendFormat:@",%@", @"SVMXC__Company__r.BillingCountry,SVMXC__Company__r.BillingPostalCode,SVMXC__Company__r.BillingState,SVMXC__Company__r.BillingCity,SVMXC__Company__r.BillingStreet"];
                        else if ([queryField isEqualToString:@"Account Ship To"]) // SVMXC__Company__r
                            [appDelegate.soqlQuery appendFormat:@",%@", @"SVMXC__Company__r.ShippingCountry,SVMXC__Company__r.ShippingPostalCode,SVMXC__Company__r.ShippingState,SVMXC__Company__r.ShippingCity,SVMXC__Company__r.ShippingStreet"];
                        else if ([queryField isEqualToString:@"Service Location"]) // SVMXC__Service_Order__c
                            [appDelegate.soqlQuery appendFormat:@",%@", @"SVMXC__Street__c,SVMXC__City__c,SVMXC__State__c,SVMXC__Zip__c,SVMXC__Country__c"];
                        else if ([queryField isEqualToString:@"Contact Address"]) // SVMXC__Contact__c
                            [appDelegate.soqlQuery appendFormat:@",%@", @"SVMXC__Contact__r.MailingStreet,SVMXC__Contact__r.MailingState,SVMXC__Contact__r.MailingPostalCode,SVMXC__Contact__r.MailingCountry,SVMXC__Contact__r.MailingCity"];
                        if (appDelegate.addressType != nil)
							appDelegate.addressType = nil;
                        appDelegate.addressType = [queryField retain];
                    }
                }
                // IPAD004 only
                NSDictionary * keyDictionary = [settingsInfoArray objectAtIndex:i]; // Id
                NSDictionary * valueDictionary = [settingsValueArray objectAtIndex:j]; // SVMXC__Setting_ID__c
                
                NSString * Id = [keyDictionary objectForKey:@"Id"];
                NSString * settingId = [valueDictionary objectForKey:@"SVMXC__Setting_ID__c"];
                
                NSSet * boolFieldArray = [NSSet setWithObjects:
                                          @"IPAD004_SET003",
                                          @"IPAD004_SET004",
                                          @"IPAD004_SET005",
                                          @"IPAD004_SET006",
                                          @"IPAD004_SET007",
                                          @"IPAD004_SET008",
                                          @"IPAD004_SET009",
                                          @"IPAD004_SET010",
                                          nil];
                
                NSString * object = [valueDictionary objectForKey:@"SVMXC__Display_Value__c"];
                NSString * key = [keyDictionary objectForKey:@"SVMXC__Setting_Unique_ID__c"];
                
                if ([boolFieldArray containsObject:key])
                {
                    if ((object != nil) && (![object isKindOfClass:[NSNull class]]))
                        object = [object lowercaseString];
                }
                
                if ([[valueDictionary objectForKey:@"SVMXC__Display_Value__c"] isKindOfClass:[NSNull class]])
                    continue;
                if ([[keyDictionary objectForKey:@"SVMXC__Setting_Unique_ID__c"] isKindOfClass:[NSNull class]])
                    continue;
                
                NSDictionary * dict = [NSDictionary dictionaryWithObject:[valueDictionary objectForKey:@"SVMXC__Display_Value__c"] forKey:[keyDictionary objectForKey:@"SVMXC__Setting_Unique_ID__c"]];
                // Time and Material
                if ([Id isEqualToString:settingId] && [[keyDictionary objectForKey:@"SVMXC__SubmoduleID__c"] isEqualToString:@"IPAD002"])
                {
                    [appDelegate.timeAndMaterial addObject:dict];
                    continue;
                }

                // Filter Service Report using IPAD004
                if ([Id isEqualToString:settingId] && [[keyDictionary objectForKey:@"SVMXC__SubmoduleID__c"] isEqualToString:@"IPAD004"])
                {
                    [appDelegate.serviceReport addObject:object forKey:key];
                    continue;
                }
            }
        }
    }
    
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [self enableControls];
        return;
    }

    [[ZKServerSwitchboard switchboard] describeSObject:@"SVMXC__Service_Order__c" target:self selector:@selector(didDescribeSObject:error:context:) context:nil];
}

- (void) didDescribeSObject:(ZKDescribeSObject *)result error:(NSError *)error context:(id)context
{
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        //[appDelegate displayNoInternetAvailable];
        [self enableControls];
        return;
    }
    
    SMLog(@"%@", [result fields]);
    appDelegate.workOrderDescription = [result retain];
//    for (int i = 0; i < [[result fields] count]; i++)
//    {
//        ZKDescribeField * field = [[appDelegate.workOrderDescription fields] objectAtIndex:i];
//        SMLog(@"%@", [field type]);
//        SMLog(@"%@", [field name]);
//        SMLog(@"%@", [field description]);
//        SMLog(@"%@", [field relationshipName]);
//        
//        NSArray * keys = [NSArray arrayWithObjects:FIELDNAME, TYPE, nil];
//        NSArray * objects = [NSArray arrayWithObjects:[field name], [field type], nil];
//        NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
//    }
    didRetrieveReportSettings = YES;
}
-(void)viewDidAppear:(BOOL)animated
{
    if(checkIn)
    {
        [self autologin];
    }
}
-(void)autologin
{
    checkIn = FALSE;
    NSString * plist_user_name = [self getUSerInfoForKey:USER_NAME_AUTHANTICATED];
    NSString * status = [self getUSerInfoForKey:INITIAL_SYNC_LOGIN_SATUS];
    if([_username isEqualToString:plist_user_name] && [status isEqualToString:@"false"])
    {
        [self doinitialSettings];
    }
}

-(void) doinitialSettings
{
    [self disableControls];
    
    appDelegate.IsSSL_error = FALSE;
    appDelegate.IsLogedIn = ISLOGEDIN_TRUE;
    appDelegate.wsInterface.didOpComplete = FALSE;
    //shrinivas
    if (appDelegate.isBackground == TRUE)
        appDelegate.isBackground = FALSE;
    
    if (appDelegate.isForeGround == TRUE)
        appDelegate.isForeGround = FALSE;
    
    [self disableControls];
    
    didRunProcess = YES;
    didEnterAlertView = FALSE;
    
    [txtUsernameLandscape resignFirstResponder];
    [txtPasswordLandscape resignFirstResponder];
    
    appDelegate.username = txtUsernameLandscape.text;
    appDelegate.password = txtPasswordLandscape.text;
    
    [activity startAnimating];
    
    appDelegate.last_initial_data_sync_time = nil;
    appDelegate.do_meta_data_sync = DONT_ALLOW_META_DATA_SYNC;
    [self loginWithUsernamePassword];
    
    BOOL ContinueLogin = [self CheckForUserNamePassword];  //SYNC_HISTORY PLIST  check should be done before calling to the
    if(ContinueLogin)
    {
        [self showHomeScreenviewController];
    }
    else
    {
        [self enableControls];
        return;
    }

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

- (void) readUsernameAndPasswordFromKeychain
{
    NSString * kRestoreLocationKey = [NSString stringWithFormat:@"RestoreLocation"];
    NSMutableArray * temp = [[NSUserDefaults standardUserDefaults] objectForKey:kRestoreLocationKey];
    SMLog(@"%@", temp);
    
    appDelegate.priceBookName = @"Standard Price Book";
    
    NSError * error = nil;
    _username = [SFHFKeychainUtils getPasswordForUsername:@"username" andServiceName:KEYCHAIN_SERVICE_NAME error:&error];
    SMLog(@"%@", _username);
    if ((_username == nil) && (temp != nil))
    {
        _username = [[temp objectAtIndex:0] objectForKey:@"username"];
    }
    txtUsernameLandscape.text = _username;
    
    // Retrieve password from keychain
    
    _password = [SFHFKeychainUtils getPasswordForUsername:@"password" andServiceName:KEYCHAIN_SERVICE_NAME error:&error];
    SMLog(@"%@", _password);
    if ((_password == nil) && (appDelegate.savedReference != nil))
    {
        _password = [[appDelegate.savedReference objectAtIndex:0] objectForKey:@"password"];
    }
    txtPasswordLandscape.text = _password;
    
}

#pragma mark - Initial Meta Sync

- (IBAction)clickInitialMetaSync:(id)sender
{
    isinitialSyncButtonChecked = !isinitialSyncButtonChecked;

    if (isinitialSyncButtonChecked)
    {
        [initialMetaSync setBackgroundImage:[UIImage imageNamed:@"login-checkbox-selected.png"] forState:UIControlStateNormal];
        [initialMetaSync setBackgroundImage:[UIImage imageNamed:@"login-checkbox-selected.png"] forState:UIControlStateHighlighted];
    }
    else 
    {
        [initialMetaSync setBackgroundImage:[UIImage imageNamed:@"login-checkbox-nonselected.png"] forState:UIControlStateNormal];
        [initialMetaSync setBackgroundImage:[UIImage imageNamed:@"login-checkbox-nonselected.png"] forState:UIControlStateNormal];
    }

}

- (IBAction)doIncrementalMetasync:(id)sender
{
    isincrementalMetaSyncButtonChecked = !isincrementalMetaSyncButtonChecked;
    
    if (isincrementalMetaSyncButtonChecked)
    {
        [IncrementalMetasync setBackgroundImage:[UIImage imageNamed:@"login-checkbox-selected.png"] forState:UIControlStateNormal];
        [IncrementalMetasync setBackgroundImage:[UIImage imageNamed:@"login-checkbox-selected.png"] forState:UIControlStateHighlighted];
    }
    else
    {
        [IncrementalMetasync setBackgroundImage:[UIImage imageNamed:@"login-checkbox-nonselected.png"] forState:UIControlStateNormal];
        [IncrementalMetasync setBackgroundImage:[UIImage imageNamed:@"login-checkbox-nonselected.png"] forState:UIControlStateNormal];
    }
    
}
-(void)scheduleLocationPing
{
    [homeScreenView scheduleLocationPingService];
}


@end
