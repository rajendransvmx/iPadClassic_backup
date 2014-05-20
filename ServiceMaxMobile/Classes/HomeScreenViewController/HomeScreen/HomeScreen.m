//
//  HomeScreen.m
//  ServiceMaxMobile
//
//  Created by AnilKumar on 4/17/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import "HomeScreen.h"
//#import "iPadScrollerViewController.h"
#import "AppDelegate.h"
#import "ModalViewController.h"
#import "FirstDetailViewController.h"
//#import "RecentsViewController.h"
#import "CreateObject.h"
//#import "SearchViewController.h"
//#import "CalendarController.h"
#import "ManualDataSync.h"
#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Item.h"
#import "GridViewCell.h"
#import "Utility.h"
#import "SMXMonitor.h"
#import "PerformanceAnalytics.h"
#import "SMAttachmentRequestManager.h"
//#import "SMDataPurgeManager.h"  //Data Purge
//#import "SMDataPurgeHelper.h"


#define GRID_COLUMN_COUNT 3
#define kMaximumNumberOFRecords   @"2500"


@interface HomeScreen ()

@end

void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);


AppDelegate *appDelegate;



@implementation HomeScreen

@synthesize Sync_status;
@synthesize internet_alertView;
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
@synthesize menuTableView;
@synthesize accessIdentifiersHomeScreen;

@synthesize locationManager;

const NSUInteger kNumImages = 7;




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void) showTasks
{
   
}

- (void) showCreateObject
{
}

- (void) showSearch
{
  
}

- (void) showCalendar
{
   
}

- (void) showMap
{
  }

- (void) showRecents
{
  
}

- (void) showHelp
{
   
}

-(void)logout
{
	//Fix for multiple taps on logout.
	NSArray *homeIcons = [self.menuTableView visibleCells];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:@"checkSessionTimeStamp"];
    
	ItemView *itemView = nil;
	for (GridViewCell *cell in homeIcons)
	{
		NSArray *itemViews = [cell subviews];
        
        for(int i=0;i<[itemViews count];i++)
        {
            NSArray *itemViewArray= [[itemViews objectAtIndex:i] subviews];
            for (int i=0;i<[itemViewArray count];i++)
            {
                if([ [itemViewArray objectAtIndex:i] isKindOfClass:[ItemView class]])
                {
                    SMLog(kLogLevelVerbose,@"itemView.titleLable.text :%@ ",[[itemViewArray objectAtIndex:i] titleLabel].text);
                    if ([[[itemViewArray objectAtIndex:i] titleLabel].text isEqualToString:[appDelegate.wsInterface.tagsDictionary valueForKey:ipad_logout_label]])
                    {
                        [[itemViewArray objectAtIndex:i] setUserInteractionEnabled:FALSE] ;
                        break;
                    }
                }
            }
        }
    }
    //    }
    
	
    if ( [appDelegate showloginScreen] )
	{
		
		appDelegate.refreshHomeIcons = FALSE;
		
		
        if (self.locationManager != nil)
        {
            [self.locationManager stopUpdatingLocation];
            [self.locationManager setDelegate:nil];
        }
        
		
		[self dismissViewControllerAnimated:YES completion:nil];
		
		[appDelegate.oauthClient.webview removeFromSuperview];
		[appDelegate.oauthClient updateWithClientID:CLIENT_ID secret:CLIENT_SECRET redirectURL:REDIRECT_URL];
		[appDelegate.oauthClient userAuthorizationRequestWithParameters:nil];
		[appDelegate._OAuthController.view addSubview:appDelegate.oauthClient.webview];
		
		itemView.userInteractionEnabled = TRUE;
        
	}
	else
	{
		itemView.userInteractionEnabled = TRUE;
		return;
	}
}

-(void)sync
{
  
}

#pragma mark - View lifecycle

 - (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if( ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) )
    {
        
        if(appDelegate.IsLogedIn == ISLOGEDIN_TRUE)
        {
            if(appDelegate.do_meta_data_sync != ALLOW_META_AND_DATA_SYNC)
            {
                
                [appDelegate.wsInterface reloadTagsDictionary];
                
                
            }
        }
        [self refreshArray];
        
        menuTableView = [[UITableView alloc]initWithFrame:CGRectZero];
        [menuTableView setDataSource:self];
        [menuTableView setDelegate:self];
        menuTableView.allowsSelection = NO;
        [self.view addSubview:menuTableView];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
   
	appDelegate.logoutFlag = FALSE;
    if(appDelegate.IsLogedIn == ISLOGEDIN_TRUE)
    {
        if(appDelegate.do_meta_data_sync != ALLOW_META_AND_DATA_SYNC)
        {
            [appDelegate.wsInterface reloadTagsDictionary];
        }
    }
    
    animateImage.image = [UIImage imageNamed:@"logo.png"];
   
    animateImage.isAccessibilityElement = YES;
    [animateImage setAccessibilityIdentifier:@"servicemaxlogo.png"];
    animateImage.alpha = 0.0;
    
    [self.menuTableView setBackgroundColor:[UIColor clearColor]];
    self.menuTableView.scrollEnabled = NO;
    
    
    CGRect menuTableViewFrame;
    
    menuTableViewFrame.origin.x = 20;
    menuTableViewFrame.origin.y = CGRectGetMaxY(animateImage.frame);
    menuTableViewFrame.size.width = self.view.frame.size.width-40;
    menuTableViewFrame.size.height = self.view.frame.size.width-52;
    self.menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [menuTableView setFrame:menuTableViewFrame];
    [customerLogoImageView setImage:appDelegate.serviceReportLogo];
    [customerLogoImageView setAlpha:0.0];
    [self performSelector:@selector(fadeInLogoWithImageView:) withObject:customerLogoImageView afterDelay:1];
    [self performSelector:@selector(fadeInLogo) withObject:nil afterDelay:1];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [self refreshArray];
    [self.menuTableView reloadData];
    [super viewWillAppear:animated];
    
    
    if (appDelegate.serviceReportLogo){
        [customerLogoImageView setIsAccessibilityElement:TRUE];
        [customerLogoImageView setAccessibilityIdentifier:@"customer_logo"];
    }
    else{
        [customerLogoImageView setAccessibilityIdentifier:@""];
    }
    
    [customerLogoImageView setImage:appDelegate.serviceReportLogo];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    [[PerformanceAnalytics sharedInstance] stopPerformAnalysis];
    
    [[PerformanceAnalytics sharedInstance] startAnalyticsWithCode:@"PA-IN-015"
                                                   andDescription:@"Initial Sync - Stage 3 : DB Mem "];
    
  //  [[PerformanceAnalytics sharedInstance] recordDBMemoryUsage:[appDelegate.dataBase dbMemoryUsage]
                                                   // perContext:@"Initial Sync"];
   // [[PerformanceAnalytics sharedInstance] setDbVersion:[appDelegate.dataBase dbVersion]];
    
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"Initial Sync"
                                                         andRecordCount:0];
    
	[menuTableView reloadData];
    
    /*
    
    if(appDelegate.IsLogedIn == ISLOGEDIN_TRUE)
    {
        [self disableControls];
       
     //   BOOL serverSupportPurge = [appDelegate doesServerSupportsModule:kMinPkgForDataPurge];
        
        if(appDelegate.do_meta_data_sync == ALLOW_META_AND_DATA_SYNC)
        {
            
      //      if (serverSupportPurge)
       //     {
       //         [[SMDataPurgeManager sharedInstance] clearPurgeDefaultValues];
        //    }
            [self createUserInfoPlist];
            
            appDelegate.wsInterface.refreshProgressBarUIDelegate = self;
            Total_calls = 17;
            appDelegate.connection_error = FALSE;
            ProgressView.layer.cornerRadius = 5;
            ProgressView.frame = CGRectMake(300, CGRectGetMinY(self.menuTableView.frame)+20, 474, 200);
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
          //  self.progressTitle.text =  [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_title];
            
            //@"  Initial Setup : Preparing application for the first time use  ";
            progressTitle.backgroundColor = [UIColor clearColor];
            progressTitle.layer.cornerRadius = 8;
            titleBackground.layer.cornerRadius=5;
            progressBar.progress = 0.0;
            total_progress = 0.0;
			display_pecentage.text = @"0%";
            
            temp_percentage = 0;
            appDelegate.isInitialMetaSyncInProgress = TRUE;
            if(initial_sync_timer == nil)
                initial_sync_timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
            
            appDelegate.initial_sync_succes_or_failed = INITIAL_SYNC_SUCCESS;
            
            SMLog(kLogLevelVerbose,@" ------- doMetaSync  Started -----");
            
          //  int c1 = [appDelegate.dataBase totalNumberOfOperationCountForDatabase:appDelegate.db];
            
            
           // [[PerformanceAnalytics sharedInstance] registerOperationCount:c1
                                              //                forDatabase:@"DB"];
            
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"doMetaSync"
                                                                 andRecordCount:0];
            
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"doMetaSync-VP"
                                                                 andRecordCount:1];
            
            
            [self doMetaSync];
            
           // [appDelegate.dataBase cleanupDatabase];
            
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"doMetaSync-VP"
                                                                 andRecordCount:0];
            
            
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"doMetaSync"
                                                                 andRecordCount:0];
            
            SMLog(kLogLevelVerbose,@" ------- doMetaSync  Finished -----");
            
            if(appDelegate.initial_sync_succes_or_failed == META_SYNC_FAILED && ![appDelegate isInternetConnectionAvailable])
            {
                [initial_sync_timer invalidate];
                initial_sync_timer = nil;
                
                return;
            }
			else if (appDelegate.initial_sync_succes_or_failed == META_SYNC_FAILED || appDelegate.connection_error == TRUE || appDelegate.isUserInactive) //Check weather user is inactive.
			{
				[initial_sync_timer invalidate];
                initial_sync_timer = nil;
				appDelegate.isUserInactive = FALSE;
                return;
				
			}
            else if (appDelegate.initial_sync_succes_or_failed == META_SYNC_FAILED || appDelegate.connection_error == TRUE)
            {
                SMLog(kLogLevelVerbose,@"I dont come here -Control");
                [initial_sync_timer invalidate];                    initial_sync_timer = nil;
                [self continueMetaAndDataSync];
                return;
            }
            
            SMLog(kLogLevelVerbose,@" ------- doDataSync  Started -----");
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"doDataSync"
                                                                 andRecordCount:0];
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"doDataSync-VP"
                                                                 andRecordCount:1];
            
            // Drop All Data sync
            SMLog(kLogLevelVerbose,@" ------- doDataSync Started -  removing all indexes -----");
            [appDelegate.dataBase dropAllExistingTableIndex];
            
            @autoreleasepool
            {
                [self doDataSync];
                
                [appDelegate.dataBase cleanupDatabase];
            }
            
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"doDataSync"
                                                                 andRecordCount:0];
            
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"doDataSync-VP"
                                                                 andRecordCount:0];
            
            SMLog(kLogLevelVerbose,@" ------- doDataSync  Finished -----");
            
            
            if(appDelegate.initial_sync_succes_or_failed == DATA_SYNC_FAILED && ![appDelegate isInternetConnectionAvailable])
            {
                [initial_sync_timer invalidate];    //invalidate the timer
                initial_sync_timer = nil;
                return;
            }
            else if (appDelegate.initial_sync_succes_or_failed == DATA_SYNC_FAILED || appDelegate.connection_error == TRUE || appDelegate.isUserInactive)
			{
				[initial_sync_timer invalidate];
                initial_sync_timer = nil;
				appDelegate.isUserInactive = FALSE;
                return;
				
			}
            else if (appDelegate.initial_sync_succes_or_failed == DATA_SYNC_FAILED || appDelegate.connection_error == TRUE)
            {
                
                [initial_sync_timer invalidate];
                initial_sync_timer = nil;
                
                [self continueMetaAndDataSync];
                return;
            }
            [appDelegate.wsInterface doGetPrice];
            
            SMLog(kLogLevelVerbose,@" ------- Adv Download Criteria Started -----");
            
            [appDelegate.wsInterface doAdvanceDownloadCriteria];
            
            
            
            
			SMLog(kLogLevelVerbose,@" ------- Adv Download Criteria End -----");
			SMLog(kLogLevelVerbose,@" ------- doTxFetch  Started -----");
            SMLog(kLogLevelVerbose,@" ------- doTxFetch Started -  creating indexes now -----");
            [appDelegate.dataBase doTableIndexCreation];
            
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"doTxFetch"
                                                                 andRecordCount:0];
            
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"doTxFetch-VP"
                                                                 andRecordCount:1];
            
            [appDelegate.dataBase cleanupDatabase];
            [self doTxFetch];
            //[appDelegate.dataBase cleanupDatabase];
            
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"doTxFetch-VP"
                                                                 andRecordCount:0];
            
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"doTxFetch"
                                                                 andRecordCount:0];
            
            SMLog(kLogLevelVerbose,@" ------- doTxFetch  Finished -----");
            
            if(appDelegate.initial_sync_succes_or_failed == TX_FETCH_FAILED && ![appDelegate isInternetConnectionAvailable])
            {
                [initial_sync_timer invalidate];
                initial_sync_timer = nil;
                return;
            }
			else if (appDelegate.initial_sync_succes_or_failed == TX_FETCH_FAILED || appDelegate.connection_error == TRUE || appDelegate.isUserInactive)
			{
				[initial_sync_timer invalidate];
                initial_sync_timer = nil;
				appDelegate.isUserInactive = FALSE;
                return;
                
			}
            else if(appDelegate.initial_sync_succes_or_failed == TX_FETCH_FAILED || appDelegate.connection_error == TRUE)
            {
                [initial_sync_timer invalidate];
                initial_sync_timer = nil;
                [self continueMetaAndDataSync];
                return;
            }
            
            SMLog(kLogLevelVerbose,@" ------- doAfterSyncSetttings  Started -----");
            
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"doAfterSyncSetttings"
                                                                 andRecordCount:0];
            
            [self doAfterSyncSetttings];
            
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"doAfterSyncSetttings"
                                                                 andRecordCount:0];
            SMLog(kLogLevelVerbose,@" ------- doAfterSyncSetttings  Finished -----");
            
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"InitsyncSetting"
                                                                 andRecordCount:0];
            
            [self InitsyncSetting];
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"InitsyncSetting"
                                                                 andRecordCount:0];
        //    if (serverSupportPurge)
        //    {
                // - Data purge
          //      [self initiateDataPurgeTimer];
         //   }
            
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"initialDataSetUpAfterSyncOrLogin"
                                                                 andRecordCount:0];
            
            [self initialDataSetUpAfterSyncOrLogin];
			//One Call sync
			[appDelegate overrideOptimizeSyncSettingsFromRooTPlist];
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"initialDataSetUpAfterSyncOrLogin"
                                                                 andRecordCount:0];
            
            appDelegate.isInitialMetaSyncInProgress = FALSE;
            [ProgressView removeFromSuperview];
            [transparent_layer removeFromSuperview];
            
            
            [customerLogoImageView setImage:appDelegate.serviceReportLogo];
            
            [self refreshViewAfterMetaSync];
            
        }
        else
        {
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"InitsyncSetting"
                                                                 andRecordCount:0];
            
            [self InitsyncSetting];
            [self initialDataSetUpAfterSyncOrLogin];
			
            [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"InitsyncSetting"
                                                                 andRecordCount:0];
            
          //  if (serverSupportPurge)
       //     {
                //Radha - Data purge
//                [self updateDataPurgeTimer];
           // }
			NSFileManager * fileManager = [NSFileManager defaultManager];
			
			NSString * flag = @"";
			
			//create SYNC_HISTORY PLIST
			NSString * rootpath_SYNHIST = [appDelegate getAppCustomSubDirectory]; //
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
				
				appDelegate.IsSynctriggeredAtLaunch = NO;
				BOOL ConflictExists = [appDelegate.databaseInterface getConflictsStatus];
				if (!ConflictExists && [appDelegate isInternetConnectionAvailable])
				{
					
					appDelegate.IsSynctriggeredAtLaunch = YES;
					appDelegate.shouldScheduleTimer = YES;
					[appDelegate callDataSync];
				}
				
			}
            
        }
        appDelegate.connection_error = FALSE;
        appDelegate.do_meta_data_sync = DONT_ALLOW_META_DATA_SYNC;
        appDelegate.IsLogedIn = ISLOGEDIN_FALSE;
        if(appDelegate == nil)
            appDelegate = (AppDelegate *)[[ UIApplication sharedApplication] delegate];
        NSString *UserFullName=@"",*language=@"";
		
		
        if(![appDelegate.userDisplayFullName length] > 0 )
        {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if (userDefaults)
            {
                UserFullName = [userDefaults objectForKey:USERFULLNAME];
                SMLog(kLogLevelVerbose,@"User Full Name  = %@",UserFullName);
            }
            
        }
        else
        {
            UserFullName=appDelegate.userDisplayFullName;
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
                SMLog(kLogLevelVerbose,@"User Language  = %@",language);
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
        [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"scheduleLocationPingService"
                                                             andRecordCount:0];
        
        
        [self scheduleLocationPingService];
        [appDelegate startBackgroundThreadForLocationServiceSettings];
        
        [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"scheduleLocationPingService"
                                                             andRecordCount:0];
        
    
     }
    [appDelegate excludeDocumentsDirFilesFromBackup];
	
	appDelegate.refreshHomeIcons = TRUE;
	
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"Initial Sync"
                                                         andRecordCount:0];
    
    int c1 = [appDelegate.dataBase totalNumberOfOperationCountForDatabase:appDelegate.db];
    
    [[PerformanceAnalytics sharedInstance] registerOperationCount:c1
                                                      forDatabase:@"DB"];
    
    if ( (appDelegate.dataBase != nil) && (appDelegate.dataBase.tempDb != nil) )
    {
        int c2 = [appDelegate.dataBase totalNumberOfOperationCountForDatabase:appDelegate.dataBase.tempDb];
        
        [[PerformanceAnalytics sharedInstance] registerOperationCount:c2
                                                          forDatabase:@"tempDB"];
        
        [[PerformanceAnalytics sharedInstance] recordDBMemoryUsage:[appDelegate.dataBase dbMemoryUsage]
                                                        perContext:@"Current-insyc-before-tmp"];
        [appDelegate.dataBase releaseHeapMemoryForDatabase:appDelegate.dataBase.tempDb];
        [[PerformanceAnalytics sharedInstance] recordDBMemoryUsage:[appDelegate.dataBase dbMemoryUsage]
                                                        perContext:@"Current-insyc-after-tmp"];
        
    }
    
    
    [[PerformanceAnalytics sharedInstance] recordDBMemoryUsage:[appDelegate.dataBase dbMemoryUsage]
                                                    perContext:@"Current-insyc-before"];
    [appDelegate.dataBase releaseHeapMemoryForDatabase:appDelegate.db];
    
    [[PerformanceAnalytics sharedInstance] recordDBMemoryUsage:[appDelegate.dataBase dbMemoryUsage]
                                                    perContext:@"Current-insyc-after"];
    
    [[PerformanceAnalytics sharedInstance] recordDBMemoryUsage:[appDelegate.dataBase dbMemoryUsage]
                                                    perContext:@"Current"];
    [[PerformanceAnalytics sharedInstance] displayCurrentStatics];
    
    
    [appDelegate checkBackUpAttributeForItemAtURL:[NSURL fileURLWithPath:[appDelegate getAppCustomSubDirectory]]];
     
     */
}

-(void)refreshViewAfterMetaSync;
{
   // [self refreshArray];
   // [self.menuTableView reloadData];
}
-(void)createUserInfoPlist
{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:appDelegate.username,@"false", nil] forKeys:[NSArray arrayWithObjects:USER_NAME_AUTHANTICATED,INITIAL_SYNC_LOGIN_SATUS, nil]];
    NSString * rootpath_SYNHIST = [appDelegate getAppCustomSubDirectory]; //
    NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:USER_INFO_PLIST];
    [dict writeToFile:plistPath_SYNHIST atomically:YES];
    [dict release];
}
-(void)clearuserinfoPlist
{
	@try{
        NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"",@"", nil] forKeys:[NSArray arrayWithObjects:USER_NAME_AUTHANTICATED,INITIAL_SYNC_LOGIN_SATUS, nil]];
        NSString * rootpath_SYNHIST = [appDelegate getAppCustomSubDirectory]; //
        NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:USER_INFO_PLIST];
        [dict writeToFile:plistPath_SYNHIST atomically:YES];
        [dict release];
	}@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name iPadScrollerViewController :clearuserinfoPlist %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason iPadScrollerViewController :clearuserinfoPlist %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    
}
- (void) didInternetConnectionChange:(NSNotification *)notification
{
    
    NSNumber * currentReach = (NSNumber *) notification.object;
    BOOL isReachable = [currentReach boolValue];
    if (isReachable)
    {
        isInternetAvailable = YES;
    }
    else
    {
        isInternetAvailable = NO;
        
    }
}

- (void) fadeInLogoWithImageView:(UIImageView *)imageView
{
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:2];
    imageView.alpha = 1.0;
    [UIView commitAnimations];
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


#pragma mark -
#pragma mark - TapImage Delegate Method
- (void) tappedImageWithIndex:(int)index
{
    
        SMLog(kLogLevelVerbose,@"%@", [itemArray objectAtIndex:index]);
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
    
    [self setDownload_desc_label:nil];
    [self setDescription_label:nil];
    [transparent_layer release];
    transparent_layer = nil;
    [display_pecentage release];
    display_pecentage = nil;
    [super viewDidUnload];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        return YES;
    }
   
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

-(void)InitsyncSetting
{
    NSDate * current_dateTime = [NSDate date];
    
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    NSString * current_gmt_time = @"";
	
	NSString * current_gmt_timedispalyed = @"";
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSString * rootpath_SYNHIST = [appDelegate getAppCustomSubDirectory];
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
		
		current_gmt_timedispalyed = [dateFormatter stringFromDate:current_dateTime];
        //One Call sync
        NSArray * sync_hist_keys = [NSArray arrayWithObjects:LAST_INITIAL_SYNC_IME, REQUEST_ID, LAST_INSERT_REQUEST_TIME,LAST_INSERT_RESONSE_TIME,LAST_UPDATE_REQUEST_TIME,LAST_UPDATE_RESONSE_TIME, LAST_DELETE_REQUEST_TIME, LAST_DELETE_RESPONSE_TIME,INSERT_SUCCESS,UPDATE_SUCCESS,DELETE_SUCCESS, LAST_INITIAL_META_SYNC_TIME, SYNC_FAILED, META_SYNC_STATUS,NEXT_META_SYNC_TIME,LAST_DC_INSERT_RESPONSE_TIME,LAST_DC_UPDATE_RESPONSE_TIME,LAST_DC_DELETE_RESPONSE_TIME, DATASYNC_TIME_TOBE_DISPLAYED, NEXT_DATA_SYNC_TIME_DISPLAYED, LAST_OSC_TIMESTAMP,PUSH_LOG_LABEL,PUSH_LOG_LABEL_COLOR, nil];
        NSMutableDictionary * sync_info = [[[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:current_gmt_time,@"",current_gmt_time,current_gmt_time,current_gmt_time,current_gmt_time,current_gmt_time,current_gmt_time,@"true",@"",@"", current_gmt_timedispalyed, @"false", [appDelegate.wsInterface.tagsDictionary objectForKey:sync_succeeded],@"",current_gmt_time,current_gmt_time,current_gmt_time,current_gmt_timedispalyed, @"", current_gmt_time,@"",@"", nil] forKeys:sync_hist_keys] autorelease];
        [sync_info writeToFile:plistPath_SYNHIST atomically:YES];
    }
    else
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath_SYNHIST];
        NSArray * keys = [dict allKeys];
        if(![keys containsObject:LAST_DC_INSERT_RESPONSE_TIME] || ![keys containsObject:LAST_DC_DELETE_RESPONSE_TIME] || ![keys containsObject:LAST_DC_UPDATE_RESPONSE_TIME] || ![keys containsObject:DATASYNC_TIME_TOBE_DISPLAYED] || ![keys containsObject:LAST_OSC_TIMESTAMP]||![keys containsObject:PUSH_LOG_LABEL]) //One Call sync
        {
            if(![keys containsObject:PUSH_LOG_LABEL])
            {
                [dict setObject:@"" forKey:PUSH_LOG_LABEL];
                [dict writeToFile:plistPath_SYNHIST atomically:YES];
            }
            if(![keys containsObject:PUSH_LOG_LABEL_COLOR])
            {
                [dict setObject:@"" forKey:PUSH_LOG_LABEL_COLOR];
                [dict writeToFile:plistPath_SYNHIST atomically:YES];
            }
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
            
			
            if(![keys containsObject:DATASYNC_TIME_TOBE_DISPLAYED])
            {
                NSString * initialSyncTime = [dict objectForKey:LAST_INITIAL_SYNC_IME];
                
                if(initialSyncTime != nil || [initialSyncTime length] > 0)
                {
                    [dict setObject:initialSyncTime forKey:DATASYNC_TIME_TOBE_DISPLAYED];
                }
            }
            
          
            if (![keys containsObject:LAST_OSC_TIMESTAMP])
            {
                NSString * last_delete_time =[dict objectForKey:LAST_DELETE_RESPONSE_TIME];
                
                [dict setObject:last_delete_time forKey:LAST_OSC_TIMESTAMP];
                
            }
            [dict writeToFile:plistPath_SYNHIST atomically:YES];
		}
    }
	
	
	appDelegate.settingsDict = [appDelegate.dataBase getSettingsDictionary];
	
	[appDelegate  ScheduleIncrementalDatasyncTimer];
	
	[appDelegate ScheduleIncrementalMetaSyncTimer];
	
	[appDelegate ScheduleTimerForEventSync];
    
	
	[appDelegate updateMetasyncTimeinSynchistory:current_dateTime];
    
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
		SMLog(kLogLevelVerbose,@"%d", check);
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
        int check_for_SFMSearch_sorting = (kMinSFMSearchSorting * 100000);
        if(_stringNumber >= check_for_SFMSearch_sorting)
        {
            appDelegate.isSfmSearchSortingAvailable=TRUE;
        }
        [appDelegate.databaseInterface deleteRecordsFromEventLocalIdsFromTable:Event_local_Ids];
        [appDelegate.databaseInterface deleteRecordsFromEventLocalIdsFromTable:LOCAL_EVENT_UPDATE];
    }
    
    
    
}
-(void)initialDataSetUpAfterSyncOrLogin
{
    
    NSMutableArray * createprocessArray;
    
    {
        
  
        
        
        [appDelegate.wsInterface reloadTagsDictionary];
        
       
        
		
        appDelegate.wsInterface.createProcessArray =  [appDelegate.calDataBase getProcessFromDatabase];
        
        appDelegate.isWorkinginOffline = TRUE;
       
        createprocessArray = [[appDelegate.databaseInterface getAllTheProcesses:@"STANDALONECREATE"] retain];
        
       
        appDelegate.view_layout_array = [appDelegate.databaseInterface getAllTheProcesses:@"VIEWRECORD"];
        
        [appDelegate getCreateProcessArray:createprocessArray];
        [createprocessArray release];
        
        NSDate *date =  [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter  setDateFormat:@"yyyy-MM-dd"];
        NSString * dateString = [dateFormatter stringFromDate:date];
        
        [appDelegate.calDataBase startQueryConfiguration];
        NSMutableArray * currentDateRange = [[appDelegate getWeekdates:dateString] retain];
        
      
        NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
        appDelegate.wsInterface.eventArray = [appDelegate.calDataBase GetEventsFromDBWithStartDate:[currentDateRange objectAtIndex:0]  endDate:[currentDateRange objectAtIndex:1]];
        [aPool drain];
        
        [dateFormatter release];
		[currentDateRange release];
    }
}
- (void)continueMetaAndDataSync
{
    SMLog(kLogLevelVerbose,@"I will come here first");
    
    
    if(appDelegate.initial_sync_succes_or_failed == META_SYNC_FAILED || appDelegate.connection_error == TRUE)
    {
        appDelegate.connection_error = FALSE;
        [appDelegate.dataBase clearDatabase];
        appDelegate.isForeGround = FALSE;
        SMLog(kLogLevelVerbose,@"I will come here first");
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
		else if (appDelegate.initial_sync_succes_or_failed == META_SYNC_FAILED || appDelegate.connection_error == TRUE || appDelegate.isUserInactive)
		{
			[initial_sync_timer invalidate];    //invalidate the timer
			initial_sync_timer = nil;
			appDelegate.isUserInactive = FALSE;
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
		else if (appDelegate.initial_sync_succes_or_failed == DATA_SYNC_FAILED || appDelegate.connection_error == TRUE || appDelegate.isUserInactive) //
		{
			[initial_sync_timer invalidate];    //invalidate the timer
			initial_sync_timer = nil;
			appDelegate.isUserInactive = FALSE;
			return;
			
		}
        else if (appDelegate.initial_sync_succes_or_failed == DATA_SYNC_FAILED || appDelegate.connection_error == TRUE )
        {
            [initial_sync_timer invalidate];    //invalidate the timer
            initial_sync_timer = nil;
            [self continueMetaAndDataSync];
            return;
        }
        [appDelegate.wsInterface doGetPrice];
        [appDelegate.wsInterface doAdvanceDownloadCriteria];
        [self doTxFetch];
        if (appDelegate.initial_sync_succes_or_failed == TX_FETCH_FAILED && ![appDelegate isInternetConnectionAvailable])
        {
            [initial_sync_timer invalidate];
            initial_sync_timer = nil;
            return;
        }
		else if (appDelegate.initial_sync_succes_or_failed == TX_FETCH_FAILED || appDelegate.connection_error == TRUE || appDelegate.isUserInactive) //
		{
			[initial_sync_timer invalidate];    //invalidate the timer
			initial_sync_timer = nil;
			appDelegate.isUserInactive = FALSE;
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
        [appDelegate.wsInterface doGetPrice];
        [appDelegate.wsInterface doAdvanceDownloadCriteria];
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
        [appDelegate.wsInterface doGetPrice];
        [appDelegate.wsInterface doAdvanceDownloadCriteria];
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
  
    [customerLogoImageView setImage:appDelegate.serviceReportLogo];
    
    
    appDelegate.do_meta_data_sync = DONT_ALLOW_META_DATA_SYNC;
    appDelegate.IsLogedIn = ISLOGEDIN_FALSE;
    [self enableControls];
   
    
}
-(void)disableControls
{
  
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
        SMLog(kLogLevelVerbose,@"Meta Sync is Running");
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
        
        if (self.locationManager == nil)
        {
            CLLocationManager *locationMgr = [[CLLocationManager alloc] init];
            self.locationManager = locationMgr;
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.distanceFilter = kCLDistanceFilterNone;
            [locationMgr release];
        }
        else
        {
            self.locationManager.delegate = self;
        }
        
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
    
    
    
    if(appDelegate.initial_sync_status == INITIAL_SYNC_SFM_METADATA && appDelegate.Sync_check_in == FALSE)
    {
        current_num_of_call = 1;
        appDelegate.Sync_check_in = TRUE;
        download_desc_label.text =  [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_metadata];
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_metadata_desc];
        
        
        SMLog(kLogLevelVerbose,@"1");
        
    }
    else if(appDelegate.initial_sync_status == SYNC_SFM_METADATA  && appDelegate.Sync_check_in == FALSE)
    {
        current_num_of_call =  2;
        temp_percentage = percentage_ ;
        appDelegate.Sync_check_in = TRUE;
        total_progress =  progress_ ;
        progressBar.progress = total_progress;
        
        download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_metadata];//@"Downloading SFM MetaData";
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_metadata_desc];
       
        
        SMLog(kLogLevelVerbose,@"Downloading SFM MetaData2");
    }
    else if(appDelegate.initial_sync_status == SYNC_SFM_PAGEDATA  && appDelegate.Sync_check_in == FALSE)
    {
        current_num_of_call =  3;
        temp_percentage = percentage_ * 2;
        appDelegate.Sync_check_in = TRUE;
        total_progress = progress_ * 2;
        progressBar.progress = total_progress;
        download_desc_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_pagedata];
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress_pagedata_desc];
       
        
        SMLog(kLogLevelVerbose,@"3");
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
        
        SMLog(kLogLevelVerbose,@"4");
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
        SMLog(kLogLevelVerbose,@"5");
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
        SMLog(kLogLevelVerbose,@"6");
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
        SMLog(kLogLevelVerbose,@"7");
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
        SMLog(kLogLevelVerbose,@"8");
    }
    else if(appDelegate.initial_sync_status == SYNC_MOBILE_DEVICE_TAGS  && appDelegate.Sync_check_in == FALSE)
    {
        SMLog(kLogLevelVerbose,@"9");
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
        SMLog(kLogLevelVerbose,@"10");
    }
    else if(appDelegate.initial_sync_status == SYNC_SFM_SEARCH  && appDelegate.Sync_check_in == FALSE)
    {
        SMLog(kLogLevelVerbose,@"11");
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
        SMLog(kLogLevelVerbose,@"12");
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
        SMLog(kLogLevelVerbose,@"13");
        
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
        SMLog(kLogLevelVerbose,@"14");
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
        SMLog(kLogLevelVerbose,@"15");
        
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
        SMLog(kLogLevelVerbose,@"16");
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
    
    // SMLog(kLogLevelVerbose,@"2nd-later will come to showalertview");
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
    BOOL serverSupportPurge = NO;
    // Mem_leak_fix -
    @autoreleasepool
    {
        //Data Purge
        serverSupportPurge = [appDelegate doesServerSupportsModule:kMinPkgForDataPurge];
        
        @try{
            
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
            {
                //OAuth.
                [[ZKServerSwitchboard switchboard] doCheckSession];
                if(!appDelegate.connection_error)
                {
                    break;
                }
            }
            SMXMonitor *monitor = [[[SMXMonitor alloc] init] autorelease];
            appDelegate.initial_sync_status = INITIAL_SYNC_SFM_METADATA;
            appDelegate.Sync_check_in = FALSE;
            
        //    if (serverSupportPurge)
         //   {
               //---- Data Purge - Radha
          //      [SMDataPurgeHelper startedConfigSyncTime];
          //  }
            
            appDelegate.wsInterface.didOpComplete = FALSE;
            [monitor monitorSMMessageWithName:@"[iPadScrollerViewController.m doMetaSync]"
                                 withUserName:appDelegate.currentUserName
                                     logLevel:kPerformanceLevelWarning
                                   logContext:@"Start"
                                 timeInterval:10.0];
            
            @autoreleasepool
            {
                [appDelegate.wsInterface metaSyncWithEventName:SFM_METADATA eventType:INITIAL_SYNC values:nil];
            }
            
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
            {
#ifdef kPrintLogsDuringWebServiceCall
                SMLog(kLogLevelVerbose,@"iPadScrollerViewController.m : doMetaSync: Inital Sync");
#endif
                // Mem_leak_fix
                @autoreleasepool
                {
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
                        [monitor monitorSMMessageWithName:@"[iPadScrollerViewController.m doMetaSync]"
                                             withUserName:appDelegate.currentUserName
                                                 logLevel:kPerformanceLevelWarning
                                               logContext:@"Stop"
                                             timeInterval:10.0];
                        return;
                    }
                    
                }
                
            }
            [monitor monitorSMMessageWithName:@"[iPadScrollerViewController.m doMetaSync]"
                                 withUserName:appDelegate.currentUserName
                                     logLevel:kPerformanceLevelWarning
                                   logContext:@"Stop"
                                 timeInterval:10.0];
            
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
                [monitor monitorSMMessageWithName:@"[iPadScrollerViewController.m SFM_SEARCH]"
                                     withUserName:appDelegate.currentUserName
                                         logLevel:kPerformanceLevelWarning
                                       logContext:@"Stop"
                                     timeInterval:10.0];
                @autoreleasepool
                {
                    [appDelegate.wsInterface metaSyncWithEventName:SFM_SEARCH eventType:SYNC values:nil];
                }
                
                while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
                {
#ifdef kPrintLogsDuringWebServiceCall
                    SMLog(kLogLevelVerbose,@"iPadScrollerViewController.m : doMetaSync: Sfm Search");
#endif
                    // Mem_leak_fix - Vipindas 9493 Jan 18
                    @autoreleasepool
                    {
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
                }
                [monitor monitorSMMessageWithName:@"[iPadScrollerViewController.m SFM_SEARCH]"
                                     withUserName:appDelegate.currentUserName
                                         logLevel:kPerformanceLevelWarning
                                       logContext:@"Stop"
                                     timeInterval:10.0];
                
                SMLog(kLogLevelVerbose,@"  MetaSync SFM Search End: %@", [NSDate date]);
            }
            if([appDelegate doesServerSupportsModule:kMinPkgForGetPriceModule])
            {
                appDelegate.initial_sync_status = SYNC_SFM_SEARCH;
                appDelegate.Sync_check_in = FALSE;
                
                appDelegate.wsInterface.didOpGetPriceComplete = FALSE;
                [monitor monitorSMMessageWithName:@"[iPadScrollerViewController.m GET_PRICE_OBJECTS]"
                                     withUserName:appDelegate.currentUserName
                                         logLevel:kPerformanceLevelWarning
                                       logContext:@"Start"
                                     timeInterval:10.0];
                
                @autoreleasepool
                {
                    [appDelegate.wsInterface metaSyncWithEventName:GET_PRICE_OBJECTS eventType:SYNC values:nil];
                }
                
                while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
                {
#ifdef kPrintLogsDuringWebServiceCall
                    SMLog(kLogLevelVerbose,@"iPadScrollerViewController.m : doMetaSync: Get Price Objects");
#endif
                    // Mem_leak_fix - Vipindas 9493 Jan 18
                    @autoreleasepool
                    {
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
                        
                        if (appDelegate.wsInterface.didOpGetPriceComplete == TRUE)
                            break;
                        
                    }
                }
                SMLog(kLogLevelVerbose,@"MetaSync Get Price PRICE_CALC_OBJECTS End: %@", [NSDate date]);
                [monitor monitorSMMessageWithName:@"[iPadScrollerViewController.m GET_PRICE_OBJECTS]"
                                     withUserName:appDelegate.currentUserName
                                         logLevel:kPerformanceLevelWarning
                                       logContext:@"Stop"
                                     timeInterval:10.0];
                
                if([[appDelegate.wsInterface getValueFromUserDefaultsForKey:@"doesGetPriceRequired"] boolValue])
                {
                    appDelegate.initial_sync_status = SYNC_SFM_SEARCH;
                    appDelegate.Sync_check_in = FALSE;
                    
                    appDelegate.wsInterface.didOpGetPriceComplete = FALSE;
                    [monitor monitorSMMessageWithName:@"[iPadScrollerViewController.m GET_PRICE_CODE_SNIPPET]"
                                         withUserName:appDelegate.currentUserName
                                             logLevel:kPerformanceLevelWarning
                                           logContext:@"Start"
                                         timeInterval:10.0];
                    
                    [appDelegate.wsInterface metaSyncWithEventName:GET_PRICE_CODE_SNIPPET eventType:SYNC values:nil];
                    
                    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
                    {
#ifdef kPrintLogsDuringWebServiceCall
                        SMLog(kLogLevelVerbose,@"iPadScrollerViewController.m : doMetaSync: Get Price Code Snippet");
#endif
                        // Mem_leak_fix - Vipindas 9493 Jan 18
                        @autoreleasepool
                        {
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
                            
                            if (appDelegate.wsInterface.didOpGetPriceComplete == TRUE)
                                break;
                        }
                    }
                    [monitor monitorSMMessageWithName:@"[iPadScrollerViewController.m GET_PRICE_CODE_SNIPPET]"
                                         withUserName:appDelegate.currentUserName
                                             logLevel:kPerformanceLevelWarning
                                           logContext:@"Stop"
                                         timeInterval:10.0];
                    SMLog(kLogLevelVerbose,@"MetaSync Get Price PRICE_CALC_CODE_SNIPPET End: %@", [NSDate date]);
                }
            }
            
            if (![appDelegate isInternetConnectionAvailable])
            {
                [self RefreshProgressBarNativeMethod:META_SYNC_];
                [self showAlertForInternetUnAvailability];
                return;
            }
            //SFM Search End
            
            
            SMLog(kLogLevelVerbose,@"  MetaSync WS End: %@", [NSDate date]);
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
            SMLog(kLogLevelVerbose,@"META SYNC 1");
            
            if (appDelegate.didFinishWithError == TRUE)
            {
                appDelegate.didFinishWithError = FALSE;
               
                return;
            }
            
        }@catch (NSException *exp) {
            SMLog(kLogLevelVerbose,@"testing for exception thrown :%@",exp);
            [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
        }
    }
  //  if (serverSupportPurge)
  //  {
        //------- Data Purge - Radha 
   //     [SMDataPurgeHelper saveConfigSyncTimeSinceSyncCompleted];
  //  }
    
}

-(void)doDataSync
{
    
    @autoreleasepool
    {
        //----- Shravya - Advanced look up- User trunk location
        SMLog(kLogLevelVerbose,@"User location update starts");
        [appDelegate.wsInterface getUserTrunkLocationRequest];
        SMLog(kLogLevelVerbose,@"User location update ends");
        
        
        SMLog(kLogLevelVerbose,@"  DataSync WS Start: %@", [NSDate date]);
        appDelegate.wsInterface.didOpComplete = FALSE;
        
        appDelegate.initial_sync_status = SYNC_EVENT_SYNC;
        appDelegate.Sync_check_in = FALSE;
        SMXMonitor *monitor = [[[SMXMonitor alloc] init] autorelease];
        [monitor monitorSMMessageWithName:@"[iPadScrollerViewController EventSync]"
                             withUserName:appDelegate.currentUserName
                                 logLevel:kPerformanceLevelWarning
                               logContext:@"Start"
                             timeInterval:kWSExecutionDuration];
        @autoreleasepool
        {
            [appDelegate.wsInterface dataSyncWithEventName:EVENT_SYNC eventType:SYNC requestId:@""];
        }
        
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(kLogLevelVerbose,@"iPadScrollerViewController.m : doDataSync: EventSync");
#endif
            
            // Mem_leak_fix - Vipindas 9493 Jan 18
            @autoreleasepool
            {
                //shrinivas
                if (appDelegate.initial_sync_succes_or_failed == DATA_SYNC_FAILED)
                {
                    appDelegate.didFinishWithError = FALSE;
                    appDelegate.initial_sync_succes_or_failed = DATA_SYNC_FAILED;
                   
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
        }
        [monitor monitorSMMessageWithName:@"[iPadScrollerViewController EventSync]"
                             withUserName:appDelegate.currentUserName
                                 logLevel:kPerformanceLevelWarning
                               logContext:@"Stop"
                             timeInterval:kWSExecutionDuration];
        
        if (![appDelegate isInternetConnectionAvailable])
        {
            [self RefreshProgressBarNativeMethod:DATA_SYNC_];
            [self showAlertForInternetUnAvailability];
            return;
        }
        
        appDelegate.initial_sync_status = SYNC_DOWNLOAD_CRITERIA_SYNC;
        appDelegate.Sync_check_in = FALSE;
        
        appDelegate.wsInterface.didOpComplete = FALSE;
        
        appDelegate.initial_dataSync_reqid = [AppDelegate GetUUID];
        
        SMLog(kLogLevelVerbose,@"reqId%@" , appDelegate.initial_dataSync_reqid);
        [monitor monitorSMMessageWithName:@"[iPadScrollerViewController DOWNLOAD_CREITERIA_SYNC]"
                             withUserName:appDelegate.currentUserName
                                 logLevel:kPerformanceLevelWarning
                               logContext:@"Start"
                             timeInterval:10.0];
        
        @autoreleasepool
        {
            [appDelegate.wsInterface dataSyncWithEventName:DOWNLOAD_CREITERIA_SYNC eventType:SYNC requestId:appDelegate.initial_dataSync_reqid];
        }
        
        SMLog(kLogLevelVerbose,@"DC Check1");
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(kLogLevelVerbose,@"iPadScrollerViewController.m : doDataSync: Download Criteria Sync");
#endif
            
            @autoreleasepool
            {
                
                if (appDelegate.initial_sync_succes_or_failed == DATA_SYNC_FAILED)
                {
                    
                    appDelegate.initial_sync_succes_or_failed = DATA_SYNC_FAILED;
                    break;
                   
                    return;
                }
                
                if (appDelegate.wsInterface.didOpComplete == TRUE)
                {
                    SMLog(kLogLevelVerbose,@"DC Check1 ComeOut");
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
            }
            
            if (![appDelegate isInternetConnectionAvailable] && appDelegate.data_sync_chunking == REQUEST_SENT)
            {
                while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
                {
                    @autoreleasepool
                    {
                        SMLog(kLogLevelVerbose,@"DC Check2");
                       
                        if (appDelegate.initial_sync_succes_or_failed == DATA_SYNC_FAILED)
                        {
                           
                            appDelegate.initial_sync_succes_or_failed = DATA_SYNC_FAILED;
                            break;
                            
                        }
                        if ([appDelegate isInternetConnectionAvailable])
                        {
                           
                            [[ZKServerSwitchboard switchboard] doCheckSession];
                            
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
        }
        [monitor monitorSMMessageWithName:@"[iPadScrollerViewController DOWNLOAD_CREITERIA_SYNC]"
                             withUserName:appDelegate.currentUserName
                                 logLevel:kPerformanceLevelWarning
                               logContext:@"Stop"
                             timeInterval:10.0];
        SMLog(kLogLevelVerbose,@"  DataSync WS End: %@", [NSDate date]);
        SMLog(kLogLevelVerbose,@"  Incremental DataSync WS Start: %@", [NSDate date]);
    }
}

-(void)doTxFetch
{
    appDelegate.initial_sync_status = SYNC_CLEANUP_SELECT;
    appDelegate.Sync_check_in = FALSE;
    SMXMonitor *monitor = [[[SMXMonitor alloc] init] autorelease];
    [monitor monitorSMMessageWithName:@"[iPadScrollerViewController CLEAN_UP_SELECT]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Start"
                         timeInterval:10.0];
    
    @autoreleasepool
    {
        [appDelegate.wsInterface cleanUpForRequestId:appDelegate.initial_dataSync_reqid forEventName:@"CLEAN_UP_SELECT"];
    }
    
    while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(kLogLevelVerbose,@"iPadScrollerViewController.m : doTxFetch: Cleanup Select");
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
    [monitor monitorSMMessageWithName:@"[iPadScrollerViewController CLEAN_UP_SELECT]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Stop"
                         timeInterval:10.0];
    
    if (![appDelegate isInternetConnectionAvailable])
    {
        [self showAlertForInternetUnAvailability];
        return;
    }
    
    appDelegate.initial_sync_status = SYNC_TX_FETCH;
    appDelegate.Sync_check_in = FALSE;
    
    
    appDelegate.Incremental_sync_status = INCR_STARTS;
    /*Mem Opt*/
    NSAutoreleasePool * tx_fetch_pool = [[NSAutoreleasePool alloc] init];
    [monitor monitorSMMessageWithName:@"[iPadScrollerViewController TX_FETCH]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Start"
                         timeInterval:10.0];
    
    [appDelegate.wsInterface PutAllTheRecordsForIds];
    /*Mem Opt*/
    [tx_fetch_pool drain];
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(kLogLevelVerbose,@"iPadScrollerViewController.m : doTxFetch: Put Tx Fetch");
#endif
        
        if (appDelegate.initial_sync_succes_or_failed == TX_FETCH_FAILED)
        {
            SMLog(kLogLevelVerbose,@"Break TxFetch");
            appDelegate.initial_sync_succes_or_failed = TX_FETCH_FAILED;
            break;
        }
        if (![appDelegate isInternetConnectionAvailable])
        {
            SMLog(kLogLevelVerbose,@"Break TxFetch");
            appDelegate.initial_sync_succes_or_failed = TX_FETCH_FAILED;
            break;
        }
        
        if (appDelegate.Incremental_sync_status == PUT_RECORDS_DONE)
        {
            SMLog(kLogLevelVerbose,@"Break TxFetch");
            break;
        }
        if(appDelegate.connection_error)
        {
            return;
        }
    }
    [monitor monitorSMMessageWithName:@"[iPadScrollerViewController TX_FETCH]"
                         withUserName:appDelegate.currentUserName
                             logLevel:kPerformanceLevelWarning
                           logContext:@"Stop"
                         timeInterval:10.0];
    
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
        SMLog(kLogLevelVerbose,@"iPadScrollerViewController.m : doTxFetch: Unknown Check");
#endif
        
        if( appDelegate.Sync_check_in == TRUE)
        {
            break;
        }
    }
    SMLog(kLogLevelVerbose,@"  Incremental DataSync WS End: %@", [NSDate date]);
    
    SMLog(kLogLevelVerbose,@"  Update Sync Records Start: %@", [NSDate date]);
    
    
    //---- Releasing the memory allocated : InitialSync-shr
    appDelegate.databaseInterface.objectFieldDictionary  = nil;
    appDelegate.wsInterface.jsonParserForDataSync = nil;
    
    
    
    SMLog(kLogLevelVerbose,@"-------  updatesfmIdsOfMasterToLocalIds  started -------");
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"updatesfmIdsOfMasterToLocalIds"
                                                         andRecordCount:0];
    
    [appDelegate.databaseInterface updatesfmIdsOfMasterToLocalIds];
    
    [[PerformanceAnalytics sharedInstance] observePerformanceForContext:@"updatesfmIdsOfMasterToLocalIds"
                                                         andRecordCount:0];
    SMLog(kLogLevelVerbose,@"-------  updatesfmIdsOfMasterToLocalIds  Finished -------");
    
    
    appDelegate.initial_sync_status = INITIAL_SYNC_COMPLETED;
    appDelegate.Sync_check_in = FALSE;
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
#ifdef kPrintLogsDuringWebServiceCall
        SMLog(kLogLevelVerbose,@"iPadScrollerViewController.m : doTxFetch: Unknow Check 2");
#endif
        
        if( appDelegate.Sync_check_in == TRUE)
        {
            break;
        }
    }
    
}
-(void)doAfterSyncSetttings
{
    
    [self clearuserinfoPlist];
    
    
    NSMutableArray * recordId = [appDelegate.dataBase getAllTheRecordIdsFromEvent];
    
    appDelegate.initialEventMappinArray = [appDelegate.dataBase checkForTheObjectWithRecordId:recordId];
   
    
    
    SMLog(kLogLevelVerbose,@"  Update Sync Records End: %@", [NSDate date]);
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * rootPath = [appDelegate getAppCustomSubDirectory];     NSString * plistPath = [rootPath stringByAppendingPathComponent:OBJECT_HISTORY_PLIST];
    NSError *delete_error;
    if ([fileManager fileExistsAtPath:plistPath] == YES)
    {
        [fileManager removeItemAtPath:plistPath error:&delete_error];
    }
    
    
    [appDelegate.dataBase insertUsernameToUserTable:appDelegate.username];
	
	
	[self UpdateUserDefaults];
	
}


- (void) UpdateUserDefaults
{
	NSString *localId = nil;
	
	localId = [appDelegate.dataBase getLocalIdFromUserTable:appDelegate.username];
	
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
	
	[userDefaults setObject:localId forKey:LOCAL_ID];
    [userDefaults synchronize];
    
}



- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    if(buttonIndex == 0)
    {
        SMLog(kLogLevelVerbose,@"index 0");
        
        SMLog(kLogLevelVerbose,@"index 1");
        if(![appDelegate isInternetConnectionAvailable])
        {
            [self showAlertForInternetUnAvailability];
        }
        else
        {
			
			[[ZKServerSwitchboard switchboard] doCheckSession];
            
            [self continueMetaAndDataSync];
        }
    }
    else if(buttonIndex == 1)
    {
        if(initial_sync_timer != nil)
        {
            [initial_sync_timer invalidate];
            initial_sync_timer = nil;
            appDelegate.initial_sync_succes_or_failed = INITIAL_SYNC_SUCCESS;
        }
		
		
		if ( [appDelegate isInternetConnectionAvailable] )
		{
			[self logout];
		}
		else
		{
			[self showAlertForInternetUnAvailability];
		}
        
        SMLog(kLogLevelVerbose,@"index 1");
    }
}
-(void)RefreshProgressBarNativeMethod:(NSString *)sync
{
    if([sync isEqualToString:META_SYNC_])
    {
        
        progressBar.progress = 0.0;
                temp_percentage = 0;
       
        display_pecentage.text = @"0%";
        
    }
    else if([sync isEqualToString:DATA_SYNC_])
    {
        
        temp_percentage = percentage_ * 9;
        total_progress = progress_ * 9;
    }
    else if([sync isEqualToString:TX_FETCH_])
    {
        
        temp_percentage = percentage_ * 11;
        total_progress = progress_ * 11;
    }
}
-(void)RefreshProgressBar:(NSString *)sync
{
    if([sync isEqualToString:META_SYNC_])
    {
       
        progressBar.progress = 0.0;
       
        current_num_of_call = 0;
        temp_percentage = 0;
    }
    else if([sync isEqualToString:DATA_SYNC_])
    {
        
        temp_percentage = percentage_ * 9;
        total_progress = progress_ * 9;
    }
    else if([sync isEqualToString:TX_FETCH_])
    {
        
        temp_percentage = percentage_ * 11;
        total_progress = progress_ * 11;
    }
}
#pragma mark - CLLocation Delegate Implementation
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    SMLog(kLogLevelVerbose,@"Error =%@",[error userInfo]);
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
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if(appDelegate.metaSyncRunning||appDelegate.dataSyncRunning )
    {
        SMLog(kLogLevelVerbose,@"Sync is Running");
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
                // Performance_issue_fix - Vipindas 9085 Feb 12
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [appDelegate didUpdateToLocation:newLocation];
                });
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
    
    itemArray = [[NSMutableArray arrayWithObjects:
                  [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_CALENDAR],
                  [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_Search],
                  [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_CREATENEW],
                  [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_MAP],
                  [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_RECENTS],
                  [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_TASKS],
                  [appDelegate.wsInterface.tagsDictionary objectForKey:ipad_sync_label],
                  [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_HELP],
                  [appDelegate.wsInterface.tagsDictionary objectForKey:ipad_logout_label],
                  nil] retain];
    
    descriptionArray = [[NSMutableArray arrayWithObjects:
                         [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_CALENDAR_TEXT],
                         [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_Search_Description],
                         [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_CREATENEW_TEXT],
                         
                         [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_MAP_TEXT],
                         [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_RECENTS_TEXT],
                         [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_TASKS_TEXT],
                         [appDelegate.wsInterface.tagsDictionary objectForKey:ipad_sync_text],
                         [appDelegate.wsInterface.tagsDictionary objectForKey:HOME_HELP_TEXT],
                         
                         [appDelegate.wsInterface.tagsDictionary objectForKey:ipad_logout_text],
                         nil] retain];
    
    
    //----UIAutomation-Shra
    NSArray *arrayTemp = [[NSArray alloc] initWithObjects:@"HomeCalendar",@"HomeSFMSearch",@"HomeCreateNew",@"HomeMap",@"HomeRecents",@"HomeTasks",@"HomeSync",@"HomeHelp",@"HomeLogout", nil];
    self.accessIdentifiersHomeScreen = arrayTemp;
    [arrayTemp release];
    arrayTemp = nil;
    
   
    {
        [appDelegate.dataBase createUserGPSTable];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = self.menuTableView.bounds.size.height/5.00;
    
    return rowHeight;
}


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = [itemArray count]/GRID_COLUMN_COUNT;
    
    if (([itemArray count]%GRID_COLUMN_COUNT)!=0)
    {
        rowCount++;
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    GridViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell Identifier"];
    if(nil == cell)
    {
        cell = [[[GridViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell Identifier"] autorelease];
        cell.columnCount = (itemArray.count-(indexPath.row*GRID_COLUMN_COUNT))>=GRID_COLUMN_COUNT?GRID_COLUMN_COUNT:(itemArray.count-(indexPath.row*GRID_COLUMN_COUNT))%GRID_COLUMN_COUNT;
        
        for (int i =0; i<cell.columnCount; i++)
        {
            [[cell itemViewAtColumn:i] setDelegate:self];
        }
        
    }
    NSInteger itemIndex = (indexPath.row*GRID_COLUMN_COUNT);
    NSArray *imageArray = [self getScrollViewNames];
    for (int i = 0; i<cell.columnCount; i++)
    {
        int columnIndex = itemIndex+i;
        
        ItemView *itemView = [cell itemViewAtColumn:i];
        itemView.index = columnIndex;
        itemView.titleLabel.text = [itemArray objectAtIndex:columnIndex];
        itemView.descriptionLabel.text = [descriptionArray objectAtIndex:columnIndex];
        
        [itemView.descriptionLabel setIsAccessibilityElement:YES];
        [itemView.descriptionLabel setAccessibilityIdentifier:[descriptionArray objectAtIndex:columnIndex]];
        
        itemView.iconImageView.image = [UIImage imageNamed:[imageArray objectAtIndex:columnIndex]];
        
        //----UIAutomation-Shra
        [itemView setIsAccessibilityElement:YES];
        NSString *accIndentifier = [self getAccessibilityForItemAtIndex:columnIndex];
        if (accIndentifier != nil) {
            [itemView setAccessibilityIdentifier:accIndentifier];
            
            //----- For Automation : Setting acceesibility to customer logo
            [itemView setAccessibilityValue:[descriptionArray objectAtIndex:columnIndex]];
        }
        
        if((columnIndex == 1) && (i == 1))
        {
            if(![appDelegate enableGPS_SFMSearch])
            {
                CALayer *layer = [itemView layer];
                layer.borderColor = [UIColor clearColor].CGColor;
                itemView.titleLabel.text = nil;
                itemView.descriptionLabel.text = nil;
                itemView.iconImageView.image = nil;
                itemView.index = -1;
                
            }else
            {
                
                CALayer *layer = [itemView layer];
                layer.borderColor = [UIColor lightGrayColor].CGColor;
            }
            
        }
        
		
		NSString *logoutLab = [appDelegate.wsInterface.tagsDictionary objectForKey:ipad_logout_label];
        if ( [itemView.titleLabel.text isEqualToString:logoutLab])
		{
			if (![appDelegate isInternetConnectionAvailable] || [appDelegate.syncThread isExecuting] || appDelegate.eventSyncRunning)
			{
				itemView.alpha = 0.5;
				itemView.userInteractionEnabled = FALSE;
			}
			else
			{
				itemView.alpha = 1.0;
				itemView.userInteractionEnabled = TRUE;
			}
		}
    }
    cell.backgroundColor=[UIColor clearColor];
    return cell;
}

#pragma mark -
#pragma mark ItemViewDelegate Method
- (void)tappedOnViewAtIndex:(int)index
{
    if (index>=0)
    {
        SMLog(kLogLevelVerbose,@"%@", [itemArray objectAtIndex:index]);
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
        {
            if([appDelegate enableGPS_SFMSearch])
            {
                [self showSearch];
            }
        }
        else if ([itemSelected isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:ipad_logout_label]])
            [self logout];
        
    }
    
}


- (void) RefreshIcons
{
	if ( appDelegate.refreshHomeIcons )
	{
      
        SMLog(kLogLevelVerbose,@"Reloading Main Menu table");
        [self performSelectorOnMainThread:@selector(reloadMenuTable) withObject:nil waitUntilDone:NO];
        
		
	}
}

- (void)reloadMenuTable {
    [self.menuTableView reloadData];
}


#pragma mark -
#pragma mark

- (NSString *)getAccessibilityForItemAtIndex:(NSInteger)index {
    if ([self.accessIdentifiersHomeScreen count] > index) {
        return [self.accessIdentifiersHomeScreen objectAtIndex:index];
    }
    return nil;
}

@end









