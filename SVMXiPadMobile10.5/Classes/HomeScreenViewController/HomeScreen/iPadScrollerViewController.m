//
//  iPadScrollerViewController.m
//  iPadScroller
//
//  Created by Samman on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iPadScrollerViewController.h"
#import "TapImage.h"
#import "iServiceAppDelegate.h"
#import "ModalViewController.h"
#import "FirstDetailViewController.h"
#import "RecentsViewController.h"
#import "CreateObject.h"
#import "SearchViewController.h"
#import "CalendarController.h"
#import "ManualDataSync.h"
#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>
extern void SVMXLog(NSString *format, ...);

iServiceAppDelegate *appDelegate;

@implementation iPadScrollerViewController
@synthesize Sync_status;
@synthesize internet_alertView;
@synthesize scrollPages;
@synthesize progressBar;
@synthesize initial_sync_timer;
@synthesize progressTitle;
@synthesize description_label;
@synthesize download_desc_label;
//@synthesize StepLabel;
@synthesize total_progress;
@synthesize current_num_of_call;
@synthesize Total_calls;
@synthesize transparent_layer;
@synthesize display_pecentage;
@synthesize temp_percentage;
@synthesize titleBackground;
const NSUInteger kNumImages = 7;

- (void)dealloc
{
	[scrollPages release];
    [ProgressView release];
    [progressTitle release];
    [progressBar release];
    [progressBar release];
    [progressTitle release];
    //[StepLabel release];
    [download_desc_label release];
    [description_label release];
   
    
    [transparent_layer release];
    [display_pecentage release];    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - 
- (void) showTasks
{
//    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.modalCalendar = [[[ModalViewController alloc] initWithNibName:@"ModalViewController" bundle:nil] autorelease];
    appDelegate.modalCalendar.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal; //UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:appDelegate.modalCalendar animated:YES completion:nil];
   // [appDelegate.modalCalendar release];
}
- (void) showCreateObject
{
    CreateObject * createObj = [[CreateObject alloc] initWithNibName:@"CreateObject" bundle:nil];
    createObj.modalPresentationStyle = UIModalPresentationFullScreen;
    createObj.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:createObj animated:YES completion:nil];
    [createObj release];
}

- (void) showSearch
{
    MainViewController *mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    mainViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    mainViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:mainViewController animated:YES completion:nil];
    [mainViewController release]; 
}

- (void) showCalendar
{
  /*if (![appDelegate isInternetConnectionAvailable])
    {
        [appDelegate displayNoInternetAvailable];
        return;
    }*/

//    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.modalCalendar = [[[ModalViewController alloc] initWithNibName:@"ModalViewController" bundle:nil] autorelease];
    appDelegate.modalCalendar.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:appDelegate.modalCalendar animated:YES completion:nil];
  //  [appDelegate.modalCalendar release];
}
- (void) showChatter
{
    
}
- (void) showMap
{
    NSString * noEvents = [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_NO_EVENTS];
    NSString * serviceMax = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_TITLE];
    NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    if (calendar == nil)
    {   
        calendar = [[CalendarController alloc] initWithNibName:@"CalendarController" bundle:nil];
        [calendar view];
    }
    
//    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ( appDelegate.wsInterface.eventArray == nil || [appDelegate.wsInterface.eventArray count] == 0 )
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:serviceMax message:noEvents delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    
    if (appDelegate.workOrderEventArray && [appDelegate.workOrderEventArray count] > 0)
    {
        [appDelegate.workOrderEventArray removeAllObjects];
    }
    
    NSDate * today = [NSDate date];
    NSDateFormatter * df = [[[NSDateFormatter alloc] init] autorelease];
    [df setDateFormat:@"yyyy-MM-dd"];
    appDelegate.dateClicked = [df stringFromDate:today];
    
    // Add events to workOrderEventArray based on today
    @try{
    for (int i = 0; i < [appDelegate.wsInterface.eventArray count]; i++)
    {
        NSDictionary * dict = [appDelegate.wsInterface.eventArray objectAtIndex:i];
        
        NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString * activityDate = [dateFormatter stringFromDate:[dict objectForKey:STARTDATETIME]];
        NSString * apiName = [dict objectForKey:OBJECTAPINAME];

        if ([appDelegate.dateClicked isEqualToString:activityDate])
        {
            if ([apiName isEqualToString:WORKORDER])
            {
                [appDelegate.workOrderEventArray addObject:dict];
            }
        }
    }
    
    // Sort workOrderEventArray
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    for (int i = 0; i < [appDelegate.workOrderEventArray count]; i++)
    {
        for (int j = i+1; j < [appDelegate.workOrderEventArray count]; j++)
        {
            NSDictionary * obji = [appDelegate.workOrderEventArray objectAtIndex:i];
            NSDictionary * objj = [appDelegate.workOrderEventArray objectAtIndex:j];
            
            NSString * objiDate = [dateFormatter stringFromDate:[obji objectForKey:STARTDATETIME]];
            NSString * objjDate = [dateFormatter stringFromDate:[objj objectForKey:STARTDATETIME]];
            
            NSString * iDateStr = [objiDate isKindOfClass:[NSString class]]?objiDate:@"1970-01-01T00:00:00Z";
            NSString * jDateStr = [objjDate isKindOfClass:[NSString class]]?objjDate:@"1970-01-01T00:00:00Z";
            
            iDateStr = [iOSInterfaceObject getLocalTimeFromGMT:iDateStr];
            iDateStr = [iDateStr stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            iDateStr = [iDateStr stringByReplacingOccurrencesOfString:@"Z" withString:@""];
            
            jDateStr = [iOSInterfaceObject getLocalTimeFromGMT:jDateStr];
            jDateStr = [jDateStr stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            jDateStr = [jDateStr stringByReplacingOccurrencesOfString:@"Z" withString:@""];
            
            NSDate * iDate = [dateFormatter dateFromString:iDateStr];
            NSDate * jDate = [dateFormatter dateFromString:jDateStr];
            
            // Compare the dates, if iDate > jDate interchange
            if ([iDate timeIntervalSince1970] > [jDate timeIntervalSince1970])
            {
                [appDelegate.workOrderEventArray exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
    
    for ( int i=0; i<[appDelegate.workOrderEventArray count];i++ )
    {
        for (int j= i + 1; j<=[appDelegate.workOrderEventArray count]-1;j++) 
        {
            NSDate * iobjDate = [[appDelegate.workOrderEventArray objectAtIndex:i] objectForKey:STARTDATETIME];
            NSString * istartDate = [self dateStringConversion:iobjDate];
            NSDate * jobjDate = [[appDelegate.workOrderEventArray objectAtIndex:j] objectForKey:STARTDATETIME];
            NSString * jstartDate = [self dateStringConversion:jobjDate];
            
            if ([istartDate isEqualToString:jstartDate])
            {
                NSString * iWhatId = [[appDelegate.workOrderEventArray objectAtIndex:i] objectForKey:WHATID];
                NSString * jWhatId = [[appDelegate.workOrderEventArray objectAtIndex:j] objectForKey:WHATID];
				
				NSString * iObjectName = [[appDelegate.workOrderEventArray objectAtIndex:i] objectForKey:OBJECTAPINAME];
				NSString * jObjectname = [[appDelegate.workOrderEventArray objectAtIndex:j] objectForKey:OBJECTAPINAME];
                
                NSString * iPriority = [appDelegate.calDataBase getPriorityForWhatId:iWhatId objectname:iObjectName];
                NSString * jPriority = [appDelegate.calDataBase getPriorityForWhatId:jWhatId objectname:jObjectname];
                
                if ([iPriority isEqualToString:@"High"] && ([jPriority isEqualToString:@"Medium"]||[jPriority isEqualToString:@"Low"]))
                {
                    [appDelegate.workOrderEventArray removeObjectAtIndex:j];
                }
                else if([iPriority isEqualToString:@"Medium"] && [jPriority isEqualToString:@"Low"])
                {
                    [appDelegate.workOrderEventArray removeObjectAtIndex:j];
                }
                else if([iPriority isEqualToString:@"Low"]&&([jPriority isEqualToString:@"High"]||[jPriority isEqualToString:@"Medium"]))
                {
                    [appDelegate.workOrderEventArray removeObjectAtIndex:j];
                }
                else if([iPriority isEqualToString:jPriority])
                {
                    if (strcmp((const char*)iWhatId, (const char *)jWhatId) > 0)
                    {
                        [appDelegate.workOrderEventArray removeObjectAtIndex:i];
                    }
                    else
                    {
                        [appDelegate.workOrderEventArray removeObjectAtIndex:j];
                    }
                }
                
            }
        }
        
    }
    
    if ([appDelegate.workOrderEventArray count] == 0)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:serviceMax message:noEvents delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        return;
    }
    else
    {
        if (appDelegate.workOrderInfo)
        {
            appDelegate.workOrderInfo = nil;
            appDelegate.workOrderInfo = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        }
        
        BOOL status;
        status = [Reachability connectivityStatus];
                   //write a query to retrieve the work order info 
        for (int i = 0; i < [appDelegate.workOrderEventArray count]; i++)
        {
            
            NSDictionary * dict = [appDelegate.workOrderEventArray objectAtIndex:i];
            NSString * local_id = [appDelegate.databaseInterface getLocalIdFromSFId:[dict objectForKey:WHATID] tableName:[dict objectForKey:OBJECTAPINAME]];
            NSMutableDictionary *  infoDict  = [appDelegate.databaseInterface queryForMapWorkOrderInfo:local_id tableName:[dict objectForKey:OBJECTAPINAME]];
            [appDelegate.workOrderInfo addObject:infoDict];
        }
            
        FirstDetailViewController * mapView = [[FirstDetailViewController alloc] initWithNibName:@"FirstDetailView" bundle:nil];
        mapView.currentDate = [calendar getTodayString];
        mapView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        mapView.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:mapView animated:YES completion:nil];
        [mapView release];
    }
    }@catch (NSException *exp) {
        SMLog(@"Exception Name iPadScrollerViewController :showMap %@",exp.name);
        SMLog(@"Exception Reason iPadScrollerViewController :showMap %@",exp.reason);
         [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
}
- (void) showRecents
{
    RecentsViewController * recents = [[RecentsViewController alloc] initWithNibName:@"RecentsViewController" bundle:nil];
    recents.modalPresentationStyle = UIModalPresentationFullScreen;
    recents.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:recents animated:YES completion:nil];
    [recents release];
}
- (void) showHelp
{
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    NSString *lang=[appDelegate.dataBase checkUserLanguage];

    NSString *isfileExists = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"home_%@",lang] ofType:@"html"];
    if((isfileExists == NULL) || [lang isEqualToString:@"en_US"] ||  !([lang length]>0))
    {
        help.helpString=@"home.html";
    }
    else
    {
        help.helpString = [NSString stringWithFormat:@"home_%@.html",lang];
    }
    [self presentViewController:help animated:YES completion:nil];
    [help release];
}
//Abinash
-(void)logout
{
    [locationManager stopUpdatingLocation];
    [appDelegate showloginScreen];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)sync
{
    ManualDataSync *manualDataSync = [[ManualDataSync alloc] initWithNibName:@"ManualDataSync" bundle:nil];
    
    manualDataSync.modalPresentationStyle = UIModalPresentationFullScreen;
    manualDataSync.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    appDelegate.wsInterface.manualDataSyncUIDelegate = manualDataSync;
    
    [self presentViewController:manualDataSync animated:YES completion:nil];
}


#pragma mark - View lifecycle

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if( ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) )
    {
        //initialize everything here if you please
        if(appDelegate.IsLogedIn == ISLOGEDIN_TRUE)
        {
            if(appDelegate.do_meta_data_sync != ALLOW_META_AND_DATA_SYNC)
            {
                appDelegate.wsInterface.tagsDictionary = [appDelegate.dataBase getTagsDictionary];
                NSMutableDictionary * temp_dict = [appDelegate.wsInterface fillEmptyTags:appDelegate.wsInterface.tagsDictionary];
                appDelegate.wsInterface.tagsDictionary = [temp_dict retain];
            }
        }
        [self refreshArray];
        self.scrollPages = [self getScrollViewNames];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [scrollViewPreview setBackgroundColor:[UIColor clearColor]];
    scrollViewPreview.pageSize = CGSizeMake(269, 299);
    scrollViewPreview.delegate = self;
    
//    [self refreshArray];
//    self.scrollPages = [self getScrollViewNames];
//    [scrollViewPreview setBackgroundColor:[UIColor clearColor]];
//	scrollViewPreview.pageSize = CGSizeMake(269, 299);
//	// Important to listen to the delegate methods.
//	scrollViewPreview.delegate = self;
    
//    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(appDelegate.IsLogedIn == ISLOGEDIN_TRUE)
    {
        if(appDelegate.do_meta_data_sync != ALLOW_META_AND_DATA_SYNC)
        {
            appDelegate.wsInterface.tagsDictionary = [appDelegate.dataBase getTagsDictionary];
            NSMutableDictionary * temp_dict = [appDelegate.wsInterface fillEmptyTags:appDelegate.wsInterface.tagsDictionary];
            appDelegate.wsInterface.tagsDictionary = [temp_dict retain];
        }
    }
    
    animateImage.image = [UIImage imageNamed:@"logo.png"];
    animateImage.alpha = 0.0;

    [self performSelector:@selector(fadeInLogo) withObject:nil afterDelay:1];
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [self refreshArray];
    [scrollViewPreview layoutSubviews];
    
    if(appDelegate.IsLogedIn == ISLOGEDIN_TRUE)
    {
        [self disableControls];
        
        if(appDelegate.do_meta_data_sync == ALLOW_META_AND_DATA_SYNC)
        {
            
            [self createUserInfoPlist];
            
            appDelegate.wsInterface.refreshProgressBarUIDelegate = self;
            Total_calls = 17;
            appDelegate.connection_error = FALSE;
            ProgressView.layer.cornerRadius = 5;
            ProgressView.frame = CGRectMake(300, 15, 474, 200);
            [self.view addSubview:transparent_layer];
            [self.view addSubview:ProgressView];
            
            description_label.numberOfLines = 3;
            description_label.font =  [UIFont systemFontOfSize:14.0];
            description_label.textAlignment = UITextAlignmentCenter;
            
            download_desc_label.font =  [UIFont systemFontOfSize:16.0];
            download_desc_label.textAlignment = UITextAlignmentCenter;
            
            ProgressView.backgroundColor = [UIColor clearColor];
            ProgressView.layer.borderColor = [UIColor blackColor].CGColor;
            ProgressView.layer.borderWidth = 1.0f;
            [ProgressView bringSubviewToFront:progressBar];
            [ProgressView bringSubviewToFront:progressTitle];
            self.progressTitle.text =  [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_title];//@"  Initial Setup : Preparing application for the first time use  ";
            progressTitle.backgroundColor = [UIColor clearColor];
            progressTitle.layer.cornerRadius = 8;
            titleBackground.layer.cornerRadius=5;
            progressBar.progress = 0.0;
            total_progress = 0.0;
			display_pecentage.text = @"0%";
            appDelegate.isInitialMetaSyncInProgress = TRUE;
            if(initial_sync_timer == nil)
                initial_sync_timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
            
            appDelegate.initial_sync_succes_or_failed = INITIAL_SYNC_SUCCESS;
            [self doMetaSync];
            
            if(appDelegate.initial_sync_succes_or_failed == META_SYNC_FAILED && ![appDelegate isInternetConnectionAvailable])
            {
                [initial_sync_timer invalidate];    //invalidate the timer
                initial_sync_timer = nil;
                
                return;
            }
            else if (appDelegate.initial_sync_succes_or_failed == META_SYNC_FAILED || appDelegate.connection_error == TRUE)
            {
                SMLog(@"I dont come here -Control");
                [initial_sync_timer invalidate];    //invalidate the timer
                initial_sync_timer = nil;
                [self continueMetaAndDataSync];
                return;
            }
            
            [self doDataSync];
            
            if(appDelegate.initial_sync_succes_or_failed == DATA_SYNC_FAILED && ![appDelegate isInternetConnectionAvailable])
            {
                [initial_sync_timer invalidate];    //invalidate the timer
                initial_sync_timer = nil;
                return;
            }
            
            else if (appDelegate.initial_sync_succes_or_failed == DATA_SYNC_FAILED || appDelegate.connection_error == TRUE)
            {
                
                [initial_sync_timer invalidate];    //invalidate the timer
                initial_sync_timer = nil;
                //[self showAlertViewForAppwasinBackground];
                [self continueMetaAndDataSync];
                return;
            }
            
            [self doTxFetch];
            
            if(appDelegate.initial_sync_succes_or_failed == TX_FETCH_FAILED && ![appDelegate isInternetConnectionAvailable])
            {
                [initial_sync_timer invalidate];    //invalidate the timer
                initial_sync_timer = nil;
                return;
            }
            else if(appDelegate.initial_sync_succes_or_failed == TX_FETCH_FAILED || appDelegate.connection_error == TRUE)
            {
                [initial_sync_timer invalidate];    //invalidate the timer
                initial_sync_timer = nil;
                [self continueMetaAndDataSync];
                return;
            }
            
            [self doAfterSyncSetttings];
            
            [self InitsyncSetting];
            [self initialDataSetUpAfterSyncOrLogin];
            appDelegate.isInitialMetaSyncInProgress = FALSE;
            [ProgressView removeFromSuperview];
            [transparent_layer removeFromSuperview];
        }
        else
        {
            [self InitsyncSetting];
            [self initialDataSetUpAfterSyncOrLogin];
			
			NSFileManager * fileManager = [NSFileManager defaultManager];
			
			NSString * flag = @"";
			
			//create SYNC_HISTORY PLIST
			NSString * rootpath_SYNHIST = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
			NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:SYNC_HISTORY];
			
			NSMutableDictionary * plistdict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath_SYNHIST];
			NSArray * allkeys= [plistdict allKeys];
			
			if ([fileManager fileExistsAtPath:plistPath_SYNHIST])
			{
				for(NSString * str in allkeys)
				{
					
					if([str isEqualToString:SYNC_FAILED])
					{
						flag = [plistdict objectForKey:SYNC_FAILED];
						break;
						
					}
				}
			}
			if ([flag isEqualToString:STRUE])
			{
				BOOL ConflictExists = [appDelegate.databaseInterface getConflictsStatus];
				if (!ConflictExists && [appDelegate isInternetConnectionAvailable])
				{
					[appDelegate callDataSync];
				}
				
			}
            
        }
        appDelegate.connection_error = FALSE;
        appDelegate.do_meta_data_sync = DONT_ALLOW_META_DATA_SYNC;
        appDelegate.IsLogedIn = ISLOGEDIN_FALSE;
        if(appDelegate == nil)
            appDelegate = (iServiceAppDelegate *)[[ UIApplication sharedApplication] delegate];
        NSString *UserFullName=@"",*language=@"";
        if(![appDelegate.currentUserName length]>0)
        {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if (userDefaults)
            {
                UserFullName = [userDefaults objectForKey:@"UserFullName"];
                SMLog(@"User Full Name  = %@",UserFullName);
            }
            
        }
        else
        {
            UserFullName=appDelegate.currentUserName;
        }
        if(appDelegate.loggedInUserId != nil && UserFullName!=nil)
        {
            [appDelegate.dataBase updateUserTable:appDelegate.loggedInUserId Name:UserFullName];
        }
        if(![appDelegate.language length]>0)
        {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if (userDefaults)
            {
                language = [userDefaults objectForKey:@"UserLanguage"];
                SMLog(@"User Language  = %@",language);
            }
            
        }
        else
        {
            language=appDelegate.language;
        }
        
        if(language !=nil)
        {
            [appDelegate.dataBase updateUserLanguage:language];
        }
        [self enableControls];
        [self scheduleLocationPingService];
        [appDelegate startBackgroundThreadForLocationServiceSettings];
    }
}
-(void)createUserInfoPlist
{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:appDelegate.username,@"false", nil] forKeys:[NSArray arrayWithObjects:USER_NAME_AUTHANTICATED,INITIAL_SYNC_LOGIN_SATUS, nil]];
    NSString * rootpath_SYNHIST = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:USER_INFO_PLIST];
    [dict writeToFile:plistPath_SYNHIST atomically:YES];
}
-(void)clearuserinfoPlist
{
	@try{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"",@"", nil] forKeys:[NSArray arrayWithObjects:USER_NAME_AUTHANTICATED,INITIAL_SYNC_LOGIN_SATUS, nil]];
    NSString * rootpath_SYNHIST = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:USER_INFO_PLIST];
    [dict writeToFile:plistPath_SYNHIST atomically:YES];
	}@catch (NSException *exp) {
	SMLog(@"Exception Name iPadScrollerViewController :clearuserinfoPlist %@",exp.name);
	SMLog(@"Exception Reason iPadScrollerViewController :clearuserinfoPlist %@",exp.reason);
	[appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

}
- (void) didInternetConnectionChange:(NSNotification *)notification
{
//    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber * currentReach = (NSNumber *) notification.object;
    BOOL isReachable = [currentReach boolValue];
    if (isReachable)
    {
        isInternetAvailable = YES;
    }
    else
    {
        isInternetAvailable = NO;
        //[appDelegate displayNoInternetAvailable];  ---- Shrinivas Commented on 4/04/2012
    }
}

- (void) fadeInLogo
{
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:2];
    animateImage.alpha = 1.0;
    [UIView commitAnimations];
}

- (void) animationDidStop:(NSString *)id finished:(NSNumber *)finished context:(id)context
{
}

- (NSMutableArray *) getScrollViewNames
{
    NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    for (int i = 0; i < [itemArray count]; i++)
    {
        NSString * imageName = [NSString stringWithFormat:@"%d.png", i];
        [array addObject:imageName];
    }
    
    return array;
}

- (NSMutableArray *) getScrollViews
{
    NSMutableArray * array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    for (int i = 0; i < [itemArray count]; i++)
    {
        NSString * imageName = [NSString stringWithFormat:@"%d.png", i];
        TapImage * imageView = [[[TapImage alloc] initWithImage:[UIImage imageNamed:imageName]] autorelease];
        [array addObject:imageView];
    }
    
    return array;
}

#pragma mark -
#pragma mark BSPreviewScrollViewDelegate methods
-(UIView*)viewForItemAtIndex:(BSPreviewScrollView*)scrollView index:(int)index
{
    if(![appDelegate enableGPS_SFMSearch] && (index == 7))
        index = 8; // Disable Location Ping and SFM Search
    
	// Note that the images are actually smaller than the image view frame, each image
	// is 210x280. Images are centered and because they are smaller than the actual 
	// view it creates a padding between each image. 
	CGRect imageViewFrame = CGRectMake(0.0f, 0.0f, 269, 299);
	
	// TapImage is a subclassed UIImageView that catch touch/tap events 
	TapImage *imageView = [[[TapImage alloc] initWithFrame:imageViewFrame] autorelease];
    imageView.delegate = self;
    imageView.index = index;
	imageView.userInteractionEnabled = YES;
	imageView.image = [UIImage imageNamed:[self.scrollPages objectAtIndex:index]];
	imageView.contentMode = UIViewContentModeCenter;
    
    UIImageView * seperator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dashboard-box-dividers.png"]];
    [imageView addSubview:seperator];
    [seperator release];
    seperator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dashboard-box-dividers.png"]];
    seperator.frame = CGRectMake(269, 0, seperator.frame.size.width, seperator.frame.size.height);
    [imageView addSubview:seperator];
    [seperator release];


    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 269, 31)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.text = [itemArray objectAtIndex:index];
    [imageView addSubview:label];
    [label release];
    
    UILabel * bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 259, 99)];
    bottomLabel.backgroundColor = [UIColor clearColor];
    bottomLabel.textColor = [UIColor blackColor];
    bottomLabel.textAlignment = UITextAlignmentCenter;
    bottomLabel.numberOfLines = 20;
    bottomLabel.lineBreakMode = UILineBreakModeWordWrap;
    bottomLabel.text = [descriptionArray objectAtIndex:index];
    [imageView addSubview:bottomLabel];
    [bottomLabel release];
	
	return imageView;
}

-(int)itemCount:(BSPreviewScrollView*)scrollView
{
	// Return the number of pages we intend to display
    int count = [self.scrollPages count];
    if(![appDelegate enableGPS_SFMSearch])
        count = count -1;
    return count;
}

#pragma mark - TapImage Delegate Method
- (void) tappedImageWithIndex:(int)index
{
    if(![appDelegate enableGPS_SFMSearch] && (index == 7))
    {
        index = 8;
    }
    SMLog(@"%@", [itemArray objectAtIndex:index]);
    NSString * itemSelected = [itemArray objectAtIndex:index];
    if ([itemSelected isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:HOME_CALENDAR]])
        [self showCalendar];
    else if ([itemSelected isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:HOME_MAP]])
        [self showMap];
    else if ([itemSelected isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:HOME_CREATENEW]])
        [self showCreateObject];
    else if ([itemSelected isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:HOME_RECENTS]])
        [self showRecents];
    else if ([itemSelected isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:HOME_TASKS]])
        [self showTasks];
    else if ([itemSelected isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:HOME_HELP]])
        [self showHelp];
    else if ([itemSelected isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:ipad_sync_label]]) 
        [self sync];
    else if ([itemSelected isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_Search]])
        [self showSearch];
    else if ([itemSelected isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:ipad_logout_label]])
        [self logout];

}


- (NSString *)dateStringConversion:(NSDate*)date 
{
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSString * dateString = [dateFormatter stringFromDate:date];
    return  dateString;
}

- (void)viewDidUnload
{
    [scrollViewPreview release];
    scrollViewPreview = nil;
    [animateImage release];
    animateImage = nil;
    [refFrame release];
    refFrame = nil;
    [lastFrame release];
    lastFrame = nil;
    
    [ProgressView release];
    ProgressView = nil;
    [progressTitle release];
    progressTitle = nil;
    [self setProgressBar:nil];
    [self setProgressBar:nil];
    [progressTitle release];
    progressTitle = nil;
   // [self setStepLabel:nil];
    [self setDownload_desc_label:nil];
    [self setDescription_label:nil];
    [transparent_layer release];
    transparent_layer = nil;
    [display_pecentage release];
    display_pecentage = nil;
     [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        return YES;
    }
    // Return YES for supported orientations
    return NO;
}

-(void)InitsyncSetting
{
    NSDate * current_dateTime = [NSDate date];
    
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    NSString * current_gmt_time = @"";
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    //create SYNC_HISTORY PLIST 
    NSString * rootpath_SYNHIST = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:SYNC_HISTORY];
    
    if (![fileManager fileExistsAtPath:plistPath_SYNHIST])
    {
        if( appDelegate.last_initial_data_sync_time != nil)
        {
            current_gmt_time = appDelegate.last_initial_data_sync_time;
        }
        else
        {
            current_gmt_time = [dateFormatter stringFromDate:current_dateTime];
        }
        
        NSArray * sync_hist_keys = [NSArray arrayWithObjects:LAST_INITIAL_SYNC_IME, REQUEST_ID, LAST_INSERT_REQUEST_TIME,LAST_INSERT_RESONSE_TIME,LAST_UPDATE_REQUEST_TIME,LAST_UPDATE_RESONSE_TIME, LAST_DELETE_REQUEST_TIME, LAST_DELETE_RESPONSE_TIME,INSERT_SUCCESS,UPDATE_SUCCESS,DELETE_SUCCESS, LAST_INITIAL_META_SYNC_TIME, SYNC_FAILED, META_SYNC_STATUS,NEXT_META_SYNC_TIME,LAST_DC_INSERT_RESPONSE_TIME,LAST_DC_UPDATE_RESPONSE_TIME,LAST_DC_DELETE_RESPONSE_TIME, nil];
        NSMutableDictionary * sync_info = [[[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:current_gmt_time,@"",current_gmt_time,current_gmt_time,current_gmt_time,current_gmt_time,current_gmt_time,current_gmt_time,@"true",@"",@"", current_gmt_time, @"false", [appDelegate.wsInterface.tagsDictionary objectForKey:sync_succeeded],@"",current_gmt_time,current_gmt_time,current_gmt_time, nil] forKeys:sync_hist_keys] autorelease];
        [sync_info writeToFile:plistPath_SYNHIST atomically:YES];
    }
    else
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath_SYNHIST];
        NSArray * keys = [dict allKeys];
         if(![keys containsObject:LAST_DC_INSERT_RESPONSE_TIME] || ![keys containsObject:LAST_DC_DELETE_RESPONSE_TIME] || ![keys containsObject:LAST_DC_UPDATE_RESPONSE_TIME] )
         {
            if(![keys containsObject:LAST_DC_INSERT_RESPONSE_TIME])
            {
                NSString * last_insert_response_time = [dict objectForKey:LAST_INSERT_RESONSE_TIME];
                if(last_insert_response_time != nil)
                {
                   [dict setObject:last_insert_response_time forKey:LAST_DC_INSERT_RESPONSE_TIME];
                }
            }
            if(![keys containsObject:LAST_DC_DELETE_RESPONSE_TIME])
            {
                NSString * last_delete_response_time = [dict objectForKey:LAST_DELETE_RESPONSE_TIME];
                if(last_delete_response_time != nil)
                {
                  [dict setObject:last_delete_response_time forKey:LAST_DC_DELETE_RESPONSE_TIME];
                }
            }
            if(![keys containsObject:LAST_DC_UPDATE_RESPONSE_TIME])
            {
                NSString * last_update_response_time = [dict objectForKey:LAST_UPDATE_RESONSE_TIME];
                if(last_update_response_time != nil)
                {
                    [dict setObject:last_update_response_time forKey:LAST_DC_UPDATE_RESPONSE_TIME];
                }
            }
            
            [dict writeToFile:plistPath_SYNHIST atomically:YES];
         }
    }
   
    
	
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
	
	appDelegate.currentServerUrl = [userDefaults objectForKey:SERVERURL];
		
    BOOL conflict_exists = [appDelegate.databaseInterface getConflictsStatus];
    if(conflict_exists)
    {
        appDelegate.SyncStatus = SYNC_RED;
    }
    else
    {
        appDelegate.SyncStatus = SYNC_GREEN;
    }
    NSString *packgeVersion;
    if (userDefaults)
    {
        packgeVersion = [userDefaults objectForKey:kPkgVersionCheckForGPS_AND_SFM_SEARCH];
        int _stringNumber = [packgeVersion intValue];
		int check = (DOD * 100000);
		SMLog(@"%d", check);
        if(_stringNumber >= check)
		{
			NSString * query =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS on_demand_download ('object_name' VARCHAR , 'sf_id' VARCHAR PRIMARY KEY  NOT NULL UNIQUE, 'time_stamp' DATETIME ,'local_id' VARCHAR, 'record_type' VARCHAR, 'json_record' VARCHAR) "];
			[appDelegate.dataBase createTable:query];
		}
        
        int check_for_local_event_table = (KMinPkgForLocalUpdateEventCreation *100000);
        if( _stringNumber >= check_for_local_event_table)
        {
            NSString *  query =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ('object_name' VARCHAR ,'local_id' VARCHAR) ",LOCAL_EVENT_UPDATE];
            [appDelegate.dataBase createTable:query];
        }
        [appDelegate.databaseInterface deleteRecordsFromEventLocalIdsFromTable:Event_local_Ids];
        [appDelegate.databaseInterface deleteRecordsFromEventLocalIdsFromTable:LOCAL_EVENT_UPDATE];
    }
    
    
    
}
-(void)initialDataSetUpAfterSyncOrLogin
{
    //BOOL retVal = [appDelegate.calDataBase isUsernameValid:txtUsernameLandscape.text];
    NSMutableArray * createprocessArray;
    //if ( retVal == YES )
    {
        appDelegate.settingsDict = [appDelegate.dataBase getSettingsDictionary];
        
        [appDelegate  ScheduleIncrementalDatasyncTimer];      
        
        [appDelegate ScheduleIncrementalMetaSyncTimer];
        
        [appDelegate ScheduleTimerForEventSync];
        
       /* if(appDelegate.IsLogedIn == ISLOGEDIN_TRUE)
        {
            if(appDelegate.do_meta_data_sync == ALLOW_META_AND_DATA_SYNC)
            {
                appDelegate.wsInterface.tagsDictionary = [appDelegate.dataBase getTagsDictionary];
                NSMutableDictionary * temp_dict = [appDelegate.wsInterface fillEmptyTags:appDelegate.wsInterface.tagsDictionary];
                appDelegate.wsInterface.tagsDictionary = [temp_dict retain];
            }
        }*/
        
        appDelegate.wsInterface.createProcessArray =  [appDelegate.calDataBase getProcessFromDatabase];
        
        appDelegate.isWorkinginOffline = TRUE;
        //for create process 
        createprocessArray = [appDelegate.databaseInterface getAllTheProcesses:@"STANDALONECREATE"];
        
        //for view process
        appDelegate.view_layout_array = [appDelegate.databaseInterface getAllTheProcesses:@"VIEWRECORD"];        
        
        [appDelegate getCreateProcessArray:createprocessArray];
        
        NSDate *date =  [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter  setDateFormat:@"yyyy-MM-dd"];
        NSString * dateString = [dateFormatter stringFromDate:date];
        
        [appDelegate.calDataBase startQueryConfiguration];
        NSMutableArray * currentDateRange = [[appDelegate getWeekdates:dateString] retain];
        
        appDelegate.wsInterface.eventArray = [appDelegate.calDataBase GetEventsFromDBWithStartDate:[currentDateRange objectAtIndex:0]  endDate:[currentDateRange objectAtIndex:1]];
        [dateFormatter release];
		[currentDateRange release];
    }

    
    //sahana dec 4th2012
	[appDelegate updateMetasyncTimeinSynchistory];
}
- (void)continueMetaAndDataSync
{
    SMLog(@"I will come here first");
   
    //again inititate
    if(appDelegate.initial_sync_succes_or_failed == META_SYNC_FAILED || appDelegate.connection_error == TRUE)
    {
        appDelegate.connection_error = FALSE;
        [appDelegate.dataBase clearDatabase];
        appDelegate.isForeGround = FALSE;
        SMLog(@"I will come here first");
        appDelegate.isBackground = FALSE;
        
        appDelegate.initial_sync_succes_or_failed = INITIAL_SYNC_SUCCESS;
        appDelegate.initial_sync_status = INITIAL_SYNC_STARTS;
        
        
        if(initial_sync_timer == nil)
        {
            appDelegate.initial_sync_status = INITIAL_SYNC_STARTS;
            initial_sync_timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
        }
        
        [appDelegate.dataBase removecache];
        [self doMetaSync];
        if (appDelegate.initial_sync_succes_or_failed == META_SYNC_FAILED && ![appDelegate isInternetConnectionAvailable])
        {
            [initial_sync_timer invalidate];
            initial_sync_timer = nil;
            return;
        }
        else if (appDelegate.initial_sync_succes_or_failed == META_SYNC_FAILED || appDelegate.connection_error == TRUE)
        {
            [initial_sync_timer invalidate];    //invalidate the timer
            initial_sync_timer = nil;
            [self continueMetaAndDataSync];
            return;
        }
        
        [self doDataSync];
        if (appDelegate.initial_sync_succes_or_failed == DATA_SYNC_FAILED && ![appDelegate isInternetConnectionAvailable])
        {
            [initial_sync_timer invalidate];
            initial_sync_timer = nil;
            return;
        }
        else if (appDelegate.initial_sync_succes_or_failed == DATA_SYNC_FAILED || appDelegate.connection_error == TRUE )
        {
            [initial_sync_timer invalidate];    //invalidate the timer
            initial_sync_timer = nil;
            [self continueMetaAndDataSync];
            return;
        }
        [self doTxFetch];
        if (appDelegate.initial_sync_succes_or_failed == TX_FETCH_FAILED && ![appDelegate isInternetConnectionAvailable])
        {
            [initial_sync_timer invalidate];
            initial_sync_timer = nil;
            return;
        }
        else if (appDelegate.initial_sync_succes_or_failed == TX_FETCH_FAILED || appDelegate.connection_error == TRUE)
        {
            [initial_sync_timer invalidate];    //invalidate the timer
            initial_sync_timer = nil;
            [self continueMetaAndDataSync];
            return;
        }
    }
    else if(appDelegate.initial_sync_succes_or_failed == DATA_SYNC_FAILED)
    {
        appDelegate.connection_error = FALSE;
        [appDelegate.databaseInterface cleartable:SYNC_RECORD_HEAP];
        appDelegate.isForeGround = FALSE;
        appDelegate.isBackground = FALSE;
        
        
        appDelegate.initial_sync_succes_or_failed = INITIAL_SYNC_SUCCESS;
        if(initial_sync_timer == nil)
        {
            appDelegate.initial_sync_status = INITIAL_SYNC_STARTS;
            initial_sync_timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
            
        }
        
        [self doDataSync];
        if (appDelegate.initial_sync_succes_or_failed == DATA_SYNC_FAILED && ![appDelegate isInternetConnectionAvailable])
        {
            [initial_sync_timer invalidate];
            initial_sync_timer = nil;
            return;
        }
        else if (appDelegate.initial_sync_succes_or_failed == DATA_SYNC_FAILED || appDelegate.connection_error == TRUE)
        {
            [initial_sync_timer invalidate];    //invalidate the timer
            initial_sync_timer = nil;
            [self continueMetaAndDataSync];
            return;
        }
        
        [self doTxFetch];
        if (appDelegate.initial_sync_succes_or_failed == TX_FETCH_FAILED && ![appDelegate isInternetConnectionAvailable])
        {
            [initial_sync_timer invalidate];
            initial_sync_timer = nil;
            return;
        }
        else if (appDelegate.initial_sync_succes_or_failed == TX_FETCH_FAILED || appDelegate.connection_error == TRUE)
        {
            [initial_sync_timer invalidate];    //invalidate the timer
            initial_sync_timer = nil;
            [self continueMetaAndDataSync];
            return;
        }
    }
    else if(appDelegate.initial_sync_succes_or_failed == TX_FETCH_FAILED)
    {
        appDelegate.connection_error = FALSE;
        appDelegate.isForeGround = FALSE;
        appDelegate.isBackground = FALSE;
        
        appDelegate.initial_sync_succes_or_failed = INITIAL_SYNC_SUCCESS;
        if(initial_sync_timer == nil)
        {
            appDelegate.initial_sync_status = INITIAL_SYNC_STARTS;
            initial_sync_timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
            
        }
        [self doTxFetch];
        if (appDelegate.initial_sync_succes_or_failed == TX_FETCH_FAILED && ![appDelegate isInternetConnectionAvailable])
        {
            [initial_sync_timer invalidate];
            initial_sync_timer = nil;
            return;
        }
        else if (appDelegate.initial_sync_succes_or_failed == TX_FETCH_FAILED  || appDelegate.connection_error == TRUE)
        {
            [initial_sync_timer invalidate];    //invalidate the timer
            initial_sync_timer = nil;
            [self continueMetaAndDataSync];
            return;
        }
    }
    
    
    
    [self doAfterSyncSetttings];
    
    [self InitsyncSetting];
    [self initialDataSetUpAfterSyncOrLogin];
    
    [ProgressView removeFromSuperview];
    [transparent_layer removeFromSuperview];

    appDelegate.do_meta_data_sync = DONT_ALLOW_META_DATA_SYNC;
    appDelegate.IsLogedIn = ISLOGEDIN_FALSE;
    [self enableControls];
    
    
}
-(void)disableControls
{
    //scrollViewPreview.userInteractionEnabled = FALSE;
    //sahana for diable all the controlls
    self.view.userInteractionEnabled = FALSE;
  
}
-(void)enableControls
{
     self.view.userInteractionEnabled = TRUE;
}
- (void) scheduleLocationPingService
{
    if(![appDelegate enableGPS_SFMSearch])
        return;
    
	if(appDelegate.metaSyncRunning )
    {
        SMLog(@"Meta Sync is Running");
        return;
    }
    NSString *enableLocationService = [appDelegate.settingsDict objectForKey:ENABLE_LOCATION_UPDATE];
    enableLocationService = (enableLocationService != nil) ? enableLocationService : @"True";
    if([enableLocationService boolValue])
    {
        NSDate *timeStamp = [NSDate date];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if (userDefaults) 
        {            
            [userDefaults setObject:timeStamp forKey:kLastLocationUpdateTimestamp];
        }
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone; //500 meters
        
        [locationManager startUpdatingLocation];
    }
}
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController;
{
    return FALSE;
}
const int percentage_ = 6; 
const float progress_ = 0.07;
#pragma mark - timer method to update progressbar
-(void)updateProgressBar:(id)sender
{
   //sahana i have to remove harcoding and make it configurable
    
    //SMLog(@"timer");
    if(appDelegate.initial_sync_status == INITIAL_SYNC_SFM_METADATA && appDelegate.Sync_check_in == FALSE)
    {
        current_num_of_call = 1;
        appDelegate.Sync_check_in = TRUE;
        download_desc_label.text =  [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_metadata];//@"Downloading SFM MetaData";
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_metadata_desc];
       
        //Downloading SFM MetaData
        SMLog(@"1");
      
    }
    else if(appDelegate.initial_sync_status == SYNC_SFM_METADATA  && appDelegate.Sync_check_in == FALSE)
    {
        current_num_of_call =  2;//current_num_of_call + 1;
        temp_percentage = percentage_ ;//temp_percentage + 5.8;
        appDelegate.Sync_check_in = TRUE;
        total_progress =  progress_ ;  //total_progress + 0.058;
        progressBar.progress = total_progress;
        //Downloading SFM PageData
        download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_metadata];//@"Downloading SFM MetaData";
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_metadata_desc];
       // [description_label sizeToFit];
       
        SMLog(@"Downloading SFM MetaData2");
    }
    else if(appDelegate.initial_sync_status == SYNC_SFM_PAGEDATA  && appDelegate.Sync_check_in == FALSE)
    {
        current_num_of_call =  3;//current_num_of_call + 1;
        temp_percentage = percentage_ * 2; //temp_percentage + 5.8;
        appDelegate.Sync_check_in = TRUE;
        total_progress = progress_ * 2;//total_progress + 0.058;
        progressBar.progress = total_progress;
        download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_pagedata];//@"Downloading SFM PageData";
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_pagedata_desc];
       // [description_label sizeToFit];
        
        SMLog(@"3");
        //Downloading SFM Object Definitions
    }
    else if(appDelegate.initial_sync_status == SYNC_SFMOBJECT_DEFINITIONS  && appDelegate.Sync_check_in == FALSE)
    {
        current_num_of_call = 4;//current_num_of_call + 1;
        temp_percentage =  percentage_ * 3;//temp_percentage + 5.8;
        appDelegate.Sync_check_in = TRUE;
        total_progress = progress_ * 3 ;//total_progress + 0.058;
        progressBar.progress = total_progress;
        //Downloading SFM batch Object Definitions
        download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_obj_definition];//@"Downloading SFM Object Definitions";
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_obj_definition_desc];
        //[description_label sizeToFit];
     
         SMLog(@"4");
    }
    else if(appDelegate.initial_sync_status == SYNC_SFM_BATCH_OBJECT_DEFINITIONS  && appDelegate.Sync_check_in == FALSE)
    {
        current_num_of_call = 5;//current_num_of_call + 1;
        temp_percentage = percentage_ * 4; //temp_percentage + 5.8;
        appDelegate.Sync_check_in = TRUE;
        total_progress = progress_ * 4;//total_progress + 0.058;
        progressBar.progress = total_progress;
        //Downloading SFM Picklist DEfinition
        download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_batch_definition];//@"Downloading SFM batch Object Definitions";
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_batch_definition_desc];
        
       // [description_label sizeToFit];
         SMLog(@"5");
    }
    else if(appDelegate.initial_sync_status == SYNC_SFM_PICKLIST_DEFINITIONS  && appDelegate.Sync_check_in == FALSE)
    {
        current_num_of_call = 6;//current_num_of_call + 1;
        temp_percentage = percentage_ * 5; //temp_percentage + 5.8;
        appDelegate.Sync_check_in = TRUE;
        total_progress = progress_ * 5;//total_progress + 0.058;
        progressBar.progress = total_progress;
        //Downloading SFW Metadata
        download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_picklist_definition];//@"Downloading SFM Picklist Definitions";
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_picklist_definition_desc];
        
       // [description_label sizeToFit];
        SMLog(@"6");
    }
    else if(appDelegate.initial_sync_status == SYNC_RT_DP_PICKLIST_INFO  && appDelegate.Sync_check_in == FALSE)
    {
        current_num_of_call = 7;//current_num_of_call + 1;
        temp_percentage =  percentage_ * 6;//temp_percentage + 5.8;
        appDelegate.Sync_check_in = TRUE;
        total_progress = progress_ * 6;//total_progress + 0.058;
        progressBar.progress = total_progress;
        //Downloading Dependent Picklist 
        download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_RT_picklist];//@"Downloading RecordType Dependent Pikclist ";
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_RT_picklist_desc];
        
       // [description_label sizeToFit];
        SMLog(@"7");
    }
    else if (appDelegate.initial_sync_status == SYNC_SFW_METADATA  && appDelegate.Sync_check_in == FALSE)
    {
        current_num_of_call = 8;//current_num_of_call + 1;
        temp_percentage = percentage_ * 7;//temp_percentage + 5.8;
        appDelegate.Sync_check_in = TRUE;
        total_progress = progress_ * 7;//total_progress + 0.058;                               ;
        progressBar.progress = total_progress;
        //Downloading mobile device tags 
        download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_SFW_metadata];//@"Downloading SFW Metadata ";
        description_label.text =  [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_SFW_metadata_desc];
       // [description_label sizeToFit];
        SMLog(@"8");
    }
    else if(appDelegate.initial_sync_status == SYNC_MOBILE_DEVICE_TAGS  && appDelegate.Sync_check_in == FALSE)
    {
         SMLog(@"9");
    }
    else if(appDelegate.initial_sync_status == SYNC_MOBILE_DEVICE_SETTINGS  && appDelegate.Sync_check_in == FALSE)
    {
        current_num_of_call = 9;//current_num_of_call + 1;
        temp_percentage = percentage_ * 8;//temp_percentage + 5.8;
        appDelegate.Sync_check_in = TRUE;
        total_progress = progress_ * 8;//total_progress + 0.058;
        progressBar.progress = total_progress;
        //downloading SFM Search data 
        download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_mob_settings];// @"Downloading Mobile Device Settings";
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_mob_settings_desc];
        // [description_label sizeToFit];
         SMLog(@"10");
    }
    else if(appDelegate.initial_sync_status == SYNC_SFM_SEARCH  && appDelegate.Sync_check_in == FALSE)
    {
         SMLog(@"11");
    }
   
    else if(appDelegate.initial_sync_status == SYNC_DP_PICKLIST_INFO  && appDelegate.Sync_check_in == FALSE)
    {
        current_num_of_call = 10;//current_num_of_call + 1;
        temp_percentage = percentage_ * 9; //temp_percentage + 5.8;
        appDelegate.Sync_check_in = TRUE;
        total_progress = progress_ * 9;//total_progress + 0.058;
        progressBar.progress = total_progress;
        //Downloading Event and task data
        download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_dp_picklist];//@"Downloading Dependent Picklist ";
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_dp_picklist_desc]; 
        // [description_label sizeToFit];
         SMLog(@"12");
    }
    else if(appDelegate.initial_sync_status == SYNC_EVENT_SYNC  && appDelegate.Sync_check_in == FALSE)
    {
        current_num_of_call = 11;//current_num_of_call + 1;
        temp_percentage = percentage_ * 10;//temp_percentage + 5.8;
        appDelegate.Sync_check_in = TRUE;
        total_progress = progress_ * 10;//total_progress + 0.058;
        progressBar.progress = total_progress;
        //Downloading download criteria sync data
        download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_event_sync];//@"Downloading Event and task related record id's";
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_event_sync_desc];
       // [description_label sizeToFit];
        SMLog(@"13");
     
    }
    else if(appDelegate.initial_sync_status == SYNC_DOWNLOAD_CRITERIA_SYNC  && appDelegate.Sync_check_in == FALSE)
    {
        temp_percentage = percentage_ * 11;//temp_percentage + 5.8;
        appDelegate.Sync_check_in = TRUE;
        total_progress = progress_ * 11;//total_progress + 0.058;
        progressBar.progress = total_progress;
        //Cleaning Up Data 
        download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_dc_sync];//@"Downloading download criteria Objects record id's";
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_dc_sync_desc];
       //  [description_label sizeToFit];
         SMLog(@"14");
    }
    else if(appDelegate.initial_sync_status == SYNC_CLEANUP_SELECT  && appDelegate.Sync_check_in == FALSE)
    {
        temp_percentage = percentage_ * 12; //temp_percentage + 5.8;
        appDelegate.Sync_check_in = TRUE;
        total_progress = progress_ * 12;//total_progress + 0.058;
        progressBar.progress = total_progress;
        //Downloading Events , Tasks and associated information
        download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_cleanup];//@"Clean up call";
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_cleanup_desc];
       //  [description_label sizeToFit];
         SMLog(@"15");
        
    }
    else if(appDelegate.initial_sync_status == SYNC_TX_FETCH  && appDelegate.Sync_check_in == FALSE)
    {
        current_num_of_call = 14;//current_num_of_call + 1;
        temp_percentage = percentage_ * 13 +10;//temp_percentage + 5.8;
        appDelegate.Sync_check_in = TRUE;
        total_progress = progress_ * 13;//total_progress + 0.058;
        progressBar.progress = total_progress;
        download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_tx_fetch];//@"Downloading Events , Tasks and Download criteria records";
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_tx_fetch_desc];
       //  [description_label sizeToFit];
        SMLog(@"16");
    }
    else if(appDelegate.initial_sync_status == SYNC_INSERTING_RECORDS_TO_LOCAL_DATABASE  && appDelegate.Sync_check_in == FALSE)
    {
        current_num_of_call =  15;  //current_num_of_call + 1;
        temp_percentage = percentage_ * 14+6;//temp_percentage + 8;
        appDelegate.Sync_check_in = TRUE;
        total_progress = progress_ * 14;//total_progress + 0.058; //total_progress + 0.06;
        progressBar.progress = total_progress;
        download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_localdb];//@"Inserting Downloaded records into local DataBase";
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_localdb_desc];
         //[description_label sizeToFit];
       // [initial_sync_timer invalidate];
    }
    else if(appDelegate.initial_sync_status == INITIAL_SYNC_COMPLETED && appDelegate.Sync_check_in == FALSE)
    {
        temp_percentage = 100;
        total_progress = 1.0;
        progressBar.progress = total_progress;
       // download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_sync_complete];//@"Initial Sync Completed";
       // download_desc_label.text =  [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_sync_complete_desc];
        // [description_label sizeToFit];
        appDelegate.Sync_check_in = TRUE;
        [initial_sync_timer invalidate];
         initial_sync_timer = nil;
        
    }
    //else if ()
      [self fillNumberOfStepsCompletedLabel];
}

-(void)fillNumberOfStepsCompletedLabel
{
  /*  NSString * step = [appDelegate.wsInterface.tagsDictionary  objectForKey:sync_progress_step];
    NSString * of = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_of];
    NSString * temp_value = [[NSString alloc] initWithFormat:@"%@ %d %@ %d :",step,current_num_of_call,of,Total_calls];
    StepLabel.text = temp_value;
    [temp_value release];*/
    
    NSString * _percentage = [[NSString alloc] initWithFormat:@"%d%%", temp_percentage];
    display_pecentage.text = _percentage;
    [_percentage release];
}
-(void)showAlertForInternetUnAvailability
{
     NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
     NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_INTERNET_NOT_AVAILABLE];
    NSString *  retry = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_retry];
    NSString * ll_try_later = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_i_ll_try];

    // SMLog(@"2nd-later will come to showalertview");
    if(internet_alertView == nil)
    {
        internet_alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:retry otherButtonTitles:ll_try_later, nil];
        [internet_alertView show];
        [internet_alertView release];
        internet_alertView = nil;
    }
}


-(void)doMetaSync
{
	@try{
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
		[appDelegate goOnlineIfRequired];
        if(!appDelegate.connection_error)
        {
            break;
        }
    }
    
    NSString* txnstmt = @"BEGIN TRANSACTION";
    char * err ;
    int retval = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);    
    
    
    appDelegate.initial_sync_status = INITIAL_SYNC_SFM_METADATA;
    appDelegate.Sync_check_in = FALSE;
    
    appDelegate.wsInterface.didOpComplete = FALSE;
    [appDelegate.wsInterface metaSyncWithEventName:SFM_METADATA eventType:INITIAL_SYNC values:nil];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"iPadScrollerViewController.m : doMetaSync: Inital Sync");
#endif

        //shrinivas
        if (appDelegate.initial_sync_succes_or_failed == META_SYNC_FAILED )
        {
            appDelegate.initial_sync_succes_or_failed = META_SYNC_FAILED;
            break;
            return;
        }   
        
        if (appDelegate.wsInterface.didOpComplete == TRUE)
            break; 
        
        if (![appDelegate isInternetConnectionAvailable])
        {
            appDelegate.initial_sync_succes_or_failed = META_SYNC_FAILED;
            break;
        }
        if(appDelegate.connection_error)
        {
            return;
        }
        
    }
    
    if (![appDelegate isInternetConnectionAvailable])
    {
        [self RefreshProgressBarNativeMethod:META_SYNC_];
        [self showAlertForInternetUnAvailability];
        return;
    }
    //SFM Search 
    if([appDelegate enableGPS_SFMSearch])
    {
        appDelegate.initial_sync_status = SYNC_SFM_SEARCH;
        appDelegate.Sync_check_in = FALSE;
        
        appDelegate.wsInterface.didOpSFMSearchComplete = FALSE;
        [appDelegate.wsInterface metaSyncWithEventName:SFM_SEARCH eventType:SYNC values:nil];
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"iPadScrollerViewController.m : doMetaSync: Sfm Search");
#endif

            if (![appDelegate isInternetConnectionAvailable])
            {
                appDelegate.initial_sync_succes_or_failed = META_SYNC_FAILED;
                break;
            }
            if(appDelegate.initial_sync_succes_or_failed == META_SYNC_FAILED)
            {
                break;
            }
            if (appDelegate.connection_error)
            {
                break;
            }
            
            if (appDelegate.wsInterface.didOpSFMSearchComplete == TRUE)
                break; 
        }
        SMLog(@"SAMMAN MetaSync SFM Search End: %@", [NSDate date]);
    }
    if (![appDelegate isInternetConnectionAvailable])
    {
        [self RefreshProgressBarNativeMethod:META_SYNC_];
        [self showAlertForInternetUnAvailability];
        return;
    }
       //SFM Search End
    
    
    SMLog(@"SAMMAN MetaSync WS End: %@", [NSDate date]);
    appDelegate.initial_sync_status = SYNC_DP_PICKLIST_INFO;
    appDelegate.Sync_check_in = FALSE;
    [appDelegate getDPpicklistInfo];
    
    if(appDelegate.connection_error)
    {
        return;
    }

    if (![appDelegate isInternetConnectionAvailable])
    {
        [self RefreshProgressBarNativeMethod:META_SYNC_];
        [self showAlertForInternetUnAvailability];
        return;
    }
      SMLog(@"META SYNC 1");
    
    if (appDelegate.didFinishWithError == TRUE)
    {
        appDelegate.didFinishWithError = FALSE;
        //[activity stopAnimating];
       // [self enableControls];
        return;
    }
    
    txnstmt = @"END TRANSACTION";
    retval = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err); 
	}@catch (NSException *exp) {
	NSLog(@"testing for exception thrown :%@",exp);
	 [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
	}
}

-(void)doDataSync
{
    NSString* txnstmt = @"BEGIN TRANSACTION";
    char * err ;
    int retval = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err);   
    
    SMLog(@"SAMMAN DataSync WS Start: %@", [NSDate date]);
    appDelegate.wsInterface.didOpComplete = FALSE;
    
    appDelegate.initial_sync_status = SYNC_EVENT_SYNC;
    appDelegate.Sync_check_in = FALSE;                                                                                                                                                                                                                                                        
    
    [appDelegate.wsInterface dataSyncWithEventName:EVENT_SYNC eventType:SYNC requestId:@""];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"iPadScrollerViewController.m : doDataSync: EventSync");
#endif

        //shrinivas
        if (appDelegate.initial_sync_succes_or_failed == DATA_SYNC_FAILED)
        {
            appDelegate.didFinishWithError = FALSE;
            appDelegate.initial_sync_succes_or_failed = DATA_SYNC_FAILED;
            // [activity stopAnimating];
           // [self enableControls];
            return;
        }   
        
        if (![appDelegate isInternetConnectionAvailable])
        {
            appDelegate.initial_sync_succes_or_failed = DATA_SYNC_FAILED;
            break;
        }
        
        if (appDelegate.wsInterface.didOpComplete == TRUE)
        {
            break; 
        }
        if(appDelegate.connection_error)
        {
            return;
        }

    }
    
    if (![appDelegate isInternetConnectionAvailable])
    {
        [self RefreshProgressBarNativeMethod:DATA_SYNC_];
        [self showAlertForInternetUnAvailability];
        return;
    }
      
    appDelegate.initial_sync_status = SYNC_DOWNLOAD_CRITERIA_SYNC;
    appDelegate.Sync_check_in = FALSE;
    
    appDelegate.wsInterface.didOpComplete = FALSE;
    
    appDelegate.initial_dataSync_reqid = [iServiceAppDelegate GetUUID];
    
    SMLog(@"reqId%@" , appDelegate.initial_dataSync_reqid);
    [appDelegate.wsInterface dataSyncWithEventName:DOWNLOAD_CREITERIA_SYNC eventType:SYNC requestId:appDelegate.initial_dataSync_reqid];
    SMLog(@"DC Check1");
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"iPadScrollerViewController.m : doDataSync: Download Criteria Sync");
#endif

        //shrinivas
        if (appDelegate.initial_sync_succes_or_failed == DATA_SYNC_FAILED)
        {
           // appDelegate.didFinishWithError = FALSE;
            appDelegate.initial_sync_succes_or_failed = DATA_SYNC_FAILED;
            break;
            // [activity stopAnimating];
           // [self enableControls];
            return;
        }   
        
        if (appDelegate.wsInterface.didOpComplete == TRUE)
        {
            SMLog(@"DC Check1 ComeOut");
            break; 
        }
        if (![appDelegate isInternetConnectionAvailable])
        {
            break;
        }
        if(appDelegate.connection_error)
        {
            return;
        }
        if (![appDelegate isInternetConnectionAvailable] && appDelegate.data_sync_chunking == REQUEST_SENT)
        {
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
            {
                SMLog(@"DC Check2");
                //shrinivas
                if (appDelegate.initial_sync_succes_or_failed == DATA_SYNC_FAILED)
                {
                   // appDelegate.didFinishWithError = FALSE;
                    //  [activity stopAnimating];
                   // [self enableControls];
                    appDelegate.initial_sync_succes_or_failed = DATA_SYNC_FAILED;
                    break;
                    //return;
                }  
                if ([appDelegate isInternetConnectionAvailable])
                {
                    [appDelegate goOnlineIfRequired];
                    [appDelegate.wsInterface dataSyncWithEventName:DOWNLOAD_CREITERIA_SYNC eventType:SYNC requestId:appDelegate.initial_dataSync_reqid];
                    break;
                }
                if(appDelegate.connection_error)
                {
                    return;
                }
            }
        }
    }
      SMLog(@"SAMMAN DataSync WS End: %@", [NSDate date]);
    SMLog(@"SAMMAN Incremental DataSync WS Start: %@", [NSDate date]);

    txnstmt = @"END TRANSACTION";
    retval = synchronized_sqlite3_exec(appDelegate.db, [txnstmt UTF8String], NULL, NULL, &err); 
}

-(void)doTxFetch
{
    appDelegate.initial_sync_status = SYNC_CLEANUP_SELECT;
    appDelegate.Sync_check_in = FALSE;
    
    [appDelegate.wsInterface cleanUpForRequestId:appDelegate.initial_dataSync_reqid forEventName:@"CLEAN_UP_SELECT"];
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"iPadScrollerViewController.m : doTxFetch: Cleanup Select");
#endif

        if (![appDelegate isInternetConnectionAvailable])
        {
            appDelegate.initial_sync_succes_or_failed = TX_FETCH_FAILED;
            break;
        }
        
        if(appDelegate.Incremental_sync_status == CLEANUP_DONE)
            break;
        if(appDelegate.connection_error)
        {
            return;
        }
    }
    
    if (![appDelegate isInternetConnectionAvailable])
    {
        [self showAlertForInternetUnAvailability];
        return;
    }
    
    appDelegate.initial_sync_status = SYNC_TX_FETCH;
    appDelegate.Sync_check_in = FALSE;
    
    
    appDelegate.Incremental_sync_status = INCR_STARTS;
    
    NSAutoreleasePool * tx_fetch_pool = [[NSAutoreleasePool alloc] init];
    
    [appDelegate.wsInterface PutAllTheRecordsForIds];
    
    [tx_fetch_pool drain];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"iPadScrollerViewController.m : doTxFetch: Put Tx Fetch");
#endif

        if (appDelegate.initial_sync_succes_or_failed == TX_FETCH_FAILED)
        {
            SMLog(@"Break TxFetch");
            appDelegate.initial_sync_succes_or_failed = TX_FETCH_FAILED;
            break;
        }  
        if (![appDelegate isInternetConnectionAvailable])
        {  
            SMLog(@"Break TxFetch");
            appDelegate.initial_sync_succes_or_failed = TX_FETCH_FAILED;
            break;
        }
        
        if (appDelegate.Incremental_sync_status == PUT_RECORDS_DONE)
        {
            SMLog(@"Break TxFetch");
            break; 
        }
        if(appDelegate.connection_error)
        {
            return;
        }
    }
    
    if (![appDelegate isInternetConnectionAvailable])
    {
        [self showAlertForInternetUnAvailability];
        return;
    }  
     
    appDelegate.initial_sync_status = SYNC_INSERTING_RECORDS_TO_LOCAL_DATABASE;
    appDelegate.Sync_check_in = FALSE;
    
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"iPadScrollerViewController.m : doTxFetch: Unknown Check");
#endif

        if( appDelegate.Sync_check_in == TRUE)
        {
            break;
        }
    }
    SMLog(@"SAMMAN Incremental DataSync WS End: %@", [NSDate date]);
    
    SMLog(@"SAMMAN Update Sync Records Start: %@", [NSDate date]);
    
    //[appDelegate.databaseInterface updateSyncRecordsIntoLocalDatabase];
    
    /* Releasing the memory allocated : InitialSync-shr*/
    appDelegate.databaseInterface.objectFieldDictionary  = nil;
    appDelegate.wsInterface.jsonParserForDataSync = nil;
    [appDelegate.databaseInterface updatesfmIdsOfMasterToLocalIds];

    
    appDelegate.initial_sync_status = INITIAL_SYNC_COMPLETED;
    appDelegate.Sync_check_in = FALSE;
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(@"iPadScrollerViewController.m : doTxFetch: Unknow Check 2");
#endif

        if( appDelegate.Sync_check_in == TRUE)
        {
            break;
        }
    }

}
-(void)doAfterSyncSetttings
{
    //sahana once sync is done succesfully reset the USERINFO plist
    [self clearuserinfoPlist];
    
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
    [appDelegate.dataBase insertUsernameToUserTable:appDelegate.username];

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    if(buttonIndex == 0)
    {
       SMLog(@"index 0");
        
        SMLog(@"index 1");
        if(![appDelegate isInternetConnectionAvailable])
        {
            [self showAlertForInternetUnAvailability];
        }
        else
        {
            [appDelegate goOnlineIfRequired];
            [self continueMetaAndDataSync];
        }
    }
    else if(buttonIndex == 1)
    {
        if(initial_sync_timer != nil)
        {
            [initial_sync_timer invalidate];    //invalidate the timer
            initial_sync_timer = nil;
            appDelegate.initial_sync_succes_or_failed = INITIAL_SYNC_SUCCESS;
        }
        [self logout];
        SMLog(@"index 1");
    }
}
-(void)RefreshProgressBarNativeMethod:(NSString *)sync
{
    if([sync isEqualToString:META_SYNC_])
    {
       // download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_start];//@"Initiating Sync From the Beginning";
        progressBar.progress = 0.0;
        //StepLabel.text = @"Step 0 of 17";
        temp_percentage = 0;
    }
    else if([sync isEqualToString:DATA_SYNC_])
    {
        //download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_data];//@"Initiating Sync From the Beginning";
        temp_percentage = percentage_ * 9; //temp_percentage + 5.8;
        total_progress = progress_ * 9;//total_progress + 0.058;
    }
    else if([sync isEqualToString:TX_FETCH_])
    {
        //download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_data];//@"Initiating Sync From the Beginning";
        temp_percentage = percentage_ * 11; //temp_percentage + 5.8;
        total_progress = progress_ * 11;//total_progress + 0.058;
    }
}
-(void)RefreshProgressBar:(NSString *)sync
{
    if([sync isEqualToString:META_SYNC_])
    {
       // download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_start];//@"Initiating Sync From the Beginning";
        progressBar.progress = 0.0;
        //StepLabel.text = @"Step 0 of 17";
        current_num_of_call = 0;
        temp_percentage = 0;
    }
    else if([sync isEqualToString:DATA_SYNC_])
    {
        //download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_data];//@"Initiating Sync From the Beginning";
        temp_percentage = percentage_ * 9; //temp_percentage + 5.8;
        total_progress = progress_ * 9;//total_progress + 0.058;
    }
    else if([sync isEqualToString:TX_FETCH_])
    {
        //download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_data];//@"Initiating Sync From the Beginning";
        temp_percentage = percentage_ * 11; //temp_percentage + 5.8;
        total_progress = progress_ * 11;//total_progress + 0.058;
    }
}
#pragma mark - CLLocation Delegate Implementation
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    SMLog(@"Error =%@",[error userInfo]);
    NSDate *newLocationTimestamp = [NSDate date];
    NSDate *lastLocationUpdateTiemstamp;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults) 
    {
        
        lastLocationUpdateTiemstamp = [userDefaults objectForKey:kLastLocationUpdateTimestamp];
        NSString *enableLocationService = [appDelegate.settingsDict objectForKey:ENABLE_LOCATION_UPDATE];
        enableLocationService = (enableLocationService != nil)?enableLocationService:@"True";
        if([enableLocationService boolValue])
        {
            //call db to store the data            
            NSString *frequencyLocationService = [appDelegate.settingsDict objectForKey:FREQ_LOCATION_TRACKING];
            frequencyLocationService = (frequencyLocationService != nil)?frequencyLocationService:@"10";
            if (!([newLocationTimestamp timeIntervalSinceDate:lastLocationUpdateTiemstamp] < ([frequencyLocationService intValue] * 60))) 
            {
                [appDelegate didUpdateToLocation:nil];
                [userDefaults setObject:newLocationTimestamp forKey:kLastLocationUpdateTimestamp];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if(appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];  
    
    if(appDelegate.metaSyncRunning||appDelegate.dataSyncRunning )
    {
        SMLog(@"Sync is Running");
        return;
    }

    NSDate *newLocationTimestamp = newLocation.timestamp;
    NSDate *lastLocationUpdateTiemstamp;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults) {
        
        lastLocationUpdateTiemstamp = [userDefaults objectForKey:kLastLocationUpdateTimestamp];
        NSString *enableLocationService = [appDelegate.settingsDict objectForKey:ENABLE_LOCATION_UPDATE];
        enableLocationService = (enableLocationService != nil)?enableLocationService:@"True";
        if([enableLocationService boolValue])
        {
            NSString *frequencyLocationService = [appDelegate.settingsDict objectForKey:FREQ_LOCATION_TRACKING];
            frequencyLocationService = (frequencyLocationService != nil)?frequencyLocationService:@"10";
            if (!([newLocationTimestamp timeIntervalSinceDate:lastLocationUpdateTiemstamp] < ([frequencyLocationService intValue] * 60))) {
                [appDelegate didUpdateToLocation:newLocation];
                [userDefaults setObject:newLocationTimestamp forKey:kLastLocationUpdateTimestamp];
            }
        }
    }
}
- (void) refreshArray
{
    if (itemArray != nil)
        [itemArray release];
    
    if (descriptionArray != nil)
        [descriptionArray release];

    itemArray = [[NSArray arrayWithObjects:
                  [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_CALENDAR],
                  [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_MAP],
                  [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_CREATENEW],
                  [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_RECENTS],
                  [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_TASKS],
                  [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_HELP],
                  [appDelegate.wsInterface.tagsDictionary objectForKey:ipad_sync_label], 
                  [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_Search],
                  [appDelegate.wsInterface.tagsDictionary objectForKey:ipad_logout_label], 
                  nil] retain];
    
    descriptionArray = [[NSArray arrayWithObjects:
                         [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_CALENDAR_TEXT],
                         [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_MAP_TEXT],
                         [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_CREATENEW_TEXT],
                         [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_RECENTS_TEXT],
                         [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_TASKS_TEXT],
                         [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_HELP_TEXT],
                         [appDelegate.wsInterface.tagsDictionary objectForKey:ipad_sync_text], 
                         [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_Search_Description],
                         [appDelegate.wsInterface.tagsDictionary objectForKey:ipad_logout_text],
                         nil] retain];

}

@end
