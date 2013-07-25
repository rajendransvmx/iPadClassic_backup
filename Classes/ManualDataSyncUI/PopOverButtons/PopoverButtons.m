//
//  PopoverButtons.m
//  ManualDataSyncUI
//
//  Created by Parashuram on 12/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PopoverButtons.h"
#import "ManualDataSyncDetail.h"
#import "WSInterface.h"
extern void SVMXLog(NSString *format, ...);

PopoverButtons *popOver_view;

@implementation PopoverButtons

@synthesize syncConfigurationFailed;

@synthesize button, button1, button2, button3;

@synthesize objectsArray;
@synthesize objectsDict;
@synthesize objectDetailsArray;
@synthesize delegate;
@synthesize popover;
@synthesize refreshMetaSyncDelegate;

@synthesize manualEventThread;  //10-June-2013

- (id) init
{
    if( ( self = [super init] ) )
    {
        //some initialization to do here
    }
    popOver_view = [self retain];
    return self;
}

- (void)loadView
{
    appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    detail = [[ManualDataSyncDetail alloc] init];
    
    [super loadView];
    self.view.frame = CGRectMake(0, 0, 100, 100);
    UIImageView * bgImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_right_panel_bg_main.png"]] autorelease];
    
    //Label
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(12, 0, 200, 50)] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_data_sync];
    [label setTextColor:[UIColor blackColor]];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 5, 214, 50);
    [button addSubview:label];
    
    UIImage *buttonBkground;
    buttonBkground = [UIImage imageNamed:@"SFM-View-button-up.png"];
    [button addTarget:self action:@selector(Syncronise)forControlEvents:UIControlEventTouchUpInside];
    [button setImage:buttonBkground forState:UIControlStateNormal];
    
    //Label1
    UILabel *label1 = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 50)] autorelease];
    label1.backgroundColor = [UIColor clearColor];
    label1.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_meta_data_configuration];
    button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = CGRectMake(0, 115, 214, 59);
    [button1 addSubview:label1];
    [button1 setImage:buttonBkground forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(synchronizeConfiguration)forControlEvents:UIControlEventTouchUpInside];
 
    
    //Label2
    UILabel *label2 = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 50)] autorelease];
    label2.backgroundColor = [UIColor clearColor];
    //label2.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_full_data_synchronize];
    label2.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_events];
    button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(0, 56, 214, 59);
    [button2 addSubview:label2];
    [button2 setImage:buttonBkground forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(synchronizeEvents)forControlEvents:UIControlEventTouchUpInside];

    
	
	//label3
	UILabel *label3 = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 50)] autorelease];
    label3.backgroundColor = [UIColor clearColor];
	
	NSString *str37 = [appDelegate.wsInterface.tagsDictionary objectForKey:conflict_retry];
	NSString *str34 = [appDelegate.wsInterface.tagsDictionary objectForKey:SYNC_RESETAPPLICATION];
 	
	if ([str37 isEqualToString:str34])
	{
		label3.text = @"Reset Application";
	}
	else
	{
		label3.text =  [appDelegate.wsInterface.tagsDictionary objectForKey:SYNC_RESETAPPLICATION];

	}
	
	button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.frame = CGRectMake(0, 175, 214, 59);
    [button3 addSubview:label3];
    [button3 setImage:buttonBkground forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(resetApplication)forControlEvents:UIControlEventTouchUpInside];
	
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgImage];
    
    [self.view addSubview:button];
    [self.view addSubview:button2];
    [self.view addSubview:button1];
	[self.view addSubview:button3];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}


- (void)viewDidUnload
{
    
}
-(void)resetApplication
{
	[delegate dismisspopover];
	if (![appDelegate isInternetConnectionAvailable])
    {
        [delegate dismisspopover];
        appDelegate.shouldShowConnectivityStatus = TRUE;
        [appDelegate displayNoInternetAvailable];
        return;
    }

	//OAuth
	BOOL retVal = [[ZKServerSwitchboard switchboard] doCheckSession];
	if ( retVal == NO )
		return;

	[delegate dismissSyncScreen];
}
- (void) Syncronise
{
    //sync_override
//    appDelegate.data_sync_type = NORMAL_DATA_SYNC;
    
	BOOL retVal;
    [delegate dismisspopover];
	
	
    appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if (![appDelegate isInternetConnectionAvailable])
    {
        appDelegate.shouldShowConnectivityStatus = TRUE;
        [appDelegate displayNoInternetAvailable];
        return;
    }
	else
	{
		if ([appDelegate.internet_Conflicts count] == 1)
		{
			[appDelegate.calDataBase removeInternetConflicts];
			[appDelegate.internet_Conflicts removeAllObjects];
			[appDelegate.reloadTable ReloadSyncTable];
		}
	}
    

//	//OAuth.
//    retVal = [[ZKServerSwitchboard switchboard] doCheckSession];
//    
//    if(retVal == NO)
//    {
//        return;
//    }
    
     NSString * data_sync = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_data_sync];
	
	retVal = [appDelegate.calDataBase selectCountFromSync_Conflicts];
	
    if(retVal == FALSE)
    {        
        if (appDelegate.eventSyncRunning)
            return;
        
        if (appDelegate.dataSyncRunning)
        {
            return;
        }
        
        if (![appDelegate isInternetConnectionAvailable])
        {
            
            [appDelegate setSyncStatus:SYNC_RED];
            [appDelegate.calDataBase insertIntoConflictInternetErrorWithSyncType:data_sync];
            appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflicts];
            [appDelegate.reloadTable ReloadSyncTable];
            return;
        }
        [appDelegate setSyncStatus:SYNC_ORANGE];
        appDelegate.dataSyncRunning = YES;
        
        if ([appDelegate.metaSyncThread isExecuting])
        {
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
            {
#ifdef kPrintLogsDuringWebServiceCall
                SMLog(@"popoverButtons.m : synchronise: check for meta sync thread");
#endif

                if (![appDelegate isInternetConnectionAvailable])
                {
                    break;
                }
                if ([appDelegate.metaSyncThread isFinished])
                {
                    break;
                }
            }
        }
        
        if ([appDelegate.event_thread isExecuting])
        {
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
            {
#ifdef kPrintLogsDuringWebServiceCall
                SMLog(@"popoverButtons.m : synchronise: check for event sync thread");
#endif

                if (![appDelegate isInternetConnectionAvailable])
                {
                    break;
                }
                
                if ([appDelegate.event_thread isFinished])
                {
                    break;
                }
            }
        }
		//#6974
		if ([manualEventThread isExecuting])
		{
			while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
            {
#ifdef kPrintLogsDuringWebServiceCall
                SMLog(@"popoverButtons.m : synchronise: check for Event sync thread 2");
#endif
				
                if (![appDelegate isInternetConnectionAvailable])
                {
                    break;
                }
                
                if ([manualEventThread isFinished])
                {
                    break;
                }
            }
			
		}
		
		[delegate activityStart];
		//RADHA Defect Fix 5542
		appDelegate.shouldScheduleTimer = YES;
        [appDelegate callDataSync];
		[delegate activityStop];
        appDelegate.dataSyncRunning = NO;
    }
    
    else 
    {        
        [appDelegate.calDataBase selectUndoneRecords];
        [appDelegate.databaseInterface deleteAllRecordsWithIgnoreTagFromConflictTable];
        		
        if([appDelegate.syncThread isExecuting])
        {
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
            {
#ifdef kPrintLogsDuringWebServiceCall
                SMLog(@"popoverButtons.m : synchronise: check for data sync thread");
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
        if ([appDelegate.metaSyncThread isExecuting])
        {
            
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
            {
#ifdef kPrintLogsDuringWebServiceCall
                SMLog(@"popoverButtons.m : synchronise: check for meta sync thread 2");
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
        
        if ([appDelegate.event_thread isExecuting])
        {
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
            {
#ifdef kPrintLogsDuringWebServiceCall
                SMLog(@"popoverButtons.m : synchronise: check for Event sync thread 2");
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
		//#6974
		if ([manualEventThread isExecuting])
		{
			while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
            {
#ifdef kPrintLogsDuringWebServiceCall
                SMLog(@"popoverButtons.m : synchronise: check for Event sync thread 2");
#endif
				
                if (![appDelegate isInternetConnectionAvailable])
                {
                    break;
                }
                
                if ([manualEventThread isFinished])
                {
                    break;
                }
            }

		}
        appDelegate.isSpecialSyncDone = FALSE;
		
		//appDelegate.syncTypeInProgress = CONFLICTSYNC_INPROGRESS;
		
		[appDelegate setCurrentSyncStatusProgress:cSYNC_STARTS optimizedSynstate:0];
		
		[delegate activityStart];
        [appDelegate callSpecialIncrementalSync];
        
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"popoverButtons.m : synchronise: check for special inc sync");
#endif

            if(appDelegate.isSpecialSyncDone)
                break;
            
            if (![appDelegate isInternetConnectionAvailable])
                break;
            
            if (appDelegate.connection_error)
            {
                break;
            }
        }
		//Radha Progress Bar
		//appDelegate.syncTypeInProgress = NO_SYNCINPROGRESS;
        retVal = [appDelegate.calDataBase selectCountFromSync_Conflicts];
        if (retVal == FALSE)
        {
			//RADHA Defect Fix 5542
			appDelegate.shouldScheduleTimer = YES;
            [appDelegate callDataSync];
        }
    }
    
	[delegate activityStop];
    [appDelegate.reloadTable ReloadSyncTable];
}

- (void) synchronizeConfiguration
{
    [delegate dismisspopover];
    
    if (![appDelegate isInternetConnectionAvailable])
    {
        [delegate dismisspopover];
        appDelegate.shouldShowConnectivityStatus = TRUE;
        [appDelegate displayNoInternetAvailable];
        return;
    }
    
    NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_TITLE];
    NSString * cancel = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE];
    NSString * continue_ = [appDelegate.wsInterface.tagsDictionary objectForKey:login_continue];
    NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:syncconfig_confirm];

    
    UIAlertView * syncConfigAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:continue_ otherButtonTitles:cancel, nil];
    
    [syncConfigAlert show];
    [syncConfigAlert release];
    
    didDismissAlertView = FALSE;
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        if (didDismissAlertView)
            break;        
    }
    
    
    if (continueFalg && didDismissAlertView)
    {
        if ([appDelegate.metaSyncThread isExecuting])
        {
            SMLog(@"Meta sync executing");
            return;
        }
        
        else 
        {
            SMLog(@"Finished");
        }
		
		appDelegate.metaSyncThread = nil;
        appDelegate.metaSyncThread = [[NSThread alloc] initWithTarget:self selector:@selector(startSyncConfiguration) object:nil];
        [appDelegate.metaSyncThread start];
    }
    else 
    {
        return;
    }
}


- (void) synchronizeEvents
{
    [delegate dismisspopover];
    if (![appDelegate isInternetConnectionAvailable])
    {
        [delegate dismisspopover];
        appDelegate.shouldShowConnectivityStatus = TRUE;
        [appDelegate displayNoInternetAvailable];
        return;
    }

    
    if ([manualEventThread isExecuting])
    {
        SMLog(@"Manual event sync executing");
    }
    
    else 
    {
        SMLog(@"Finished");
    }
	
    [manualEventThread release];
    manualEventThread = [[NSThread alloc] initWithTarget:self selector:@selector(startSyncEvents) object:nil];
    [manualEventThread start];
                         
}

- (void) startSyncConfiguration
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	    
    appDelegate.internetAlertFlag = FALSE;
    appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
        
    if (![appDelegate isInternetConnectionAvailable])
    {
        appDelegate.shouldShowConnectivityStatus = TRUE;
        [appDelegate displayNoInternetAvailable];
        return;
    }
    
   
	//new code to handle meta sync whenever the application is logged of the authentication module.
	//OAuth.
	BOOL retVal = [[ZKServerSwitchboard switchboard] doCheckSession];;
	
	if ([appDelegate.currentServerUrl Contains:@"null"] || [appDelegate.currentServerUrl length] == 0 || appDelegate.currentServerUrl == nil)
	{
		NSUserDefaults * userdefaults = [NSUserDefaults standardUserDefaults];
		
		appDelegate.currentServerUrl = [userdefaults objectForKey:SERVERURL];
	}
	
    
    if(retVal == NO || [appDelegate.currentServerUrl Contains:@"null"])
    {
		[delegate dismisspopover];
        [appDelegate setSyncStatus:SYNC_GREEN];
        return;
    }

    if (appDelegate.metaSyncRunning) 
    {
        [delegate dismisspopover];
        [appDelegate setSyncStatus:SYNC_GREEN];
        return;
    }
     [delegate disableControls];
    
    //RADHA AUG 30/2012
    [appDelegate.dataBase deleteDatabase:TEMPDATABASENAME];    
    appDelegate.metaSyncRunning = YES;
    
    syncConfigurationFailed = FALSE;
    appDelegate.isIncrementalMetaSyncInProgress = FALSE;
    
    @try {
        
        if (![appDelegate isInternetConnectionAvailable])
        {
            return;
        }
        appDelegate.isIncrementalMetaSyncInProgress = TRUE;
        
        [appDelegate.calDataBase insertMetaSyncStatus:@"Green" WithDB:appDelegate.db];
        appDelegate.dataBase.MyPopoverDelegate = delegate;
        appDelegate.databaseInterface.MyPopoverDelegate = delegate;
        appDelegate.wsInterface.MyPopoverDelegate = delegate;
        
        [delegate activityStart];
        
        if([appDelegate.syncThread isExecuting])
        {
           while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
            {
#ifdef kPrintLogsDuringWebServiceCall
                SMLog(@"popoverButtons.m : startSyncConfiguration: check for Data sync thread");
#endif

                if ([appDelegate.syncThread isFinished])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.datasync_timer];
                    break;
                }
            }
        }
        else
        {
            if ([appDelegate.datasync_timer isValid])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.datasync_timer];
            }            
        }   
        
    
        if ([appDelegate.event_thread isExecuting])
        {
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
            {
#ifdef kPrintLogsDuringWebServiceCall
                SMLog(@"popoverButtons.m : startSyncConfiguration: check for Event sync thread");
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
        
        

        [refreshMetaSyncDelegate refreshMetaSyncStatus];
        //appDelegate.syncTypeInProgress = METASYNC_INPROGRESS;

        [appDelegate setCurrentSyncStatusProgress:METASYNC_STARTS optimizedSynstate:0];
      
       //OAuth.
		[[ZKServerSwitchboard switchboard] doCheckSession];
        [appDelegate.dataBase removecache];
        appDelegate.didincrementalmetasyncdone = FALSE;
        
        [appDelegate.dataBase StartIncrementalmetasync];        
        
    }
    @catch (NSException * exception) {
        
		appDelegate.metaSyncRunning = NO;
        exception = [NSException exceptionWithName:@"Error" reason:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_failed_try_again] userInfo: nil];
        syncConfigurationFailed = TRUE;
            
        
        [delegate enableControls];
        
		//Radha - Commented the below since the table will not be created.
		//		[appDelegate.calDataBase insertMetaSyncStatus:@"Red" WithDB:appDelegate.db];
        if (![appDelegate isInternetConnectionAvailable])
        {
            appDelegate.internetAlertFlag = TRUE;
         
        }
        else
        {
            appDelegate.dataBase.MyPopoverDelegate = nil;
            appDelegate.databaseInterface.MyPopoverDelegate = nil;
            appDelegate.wsInterface.MyPopoverDelegate = nil;
            
            
            [self performSelectorOnMainThread:@selector(setSyncStatus) withObject:nil waitUntilDone:NO];
 
            [appDelegate.dataBase copyTempsqlToSfm];
            
        }
        
    }
    @finally {
        
        if(appDelegate.internetAlertFlag == TRUE && (![appDelegate isInternetConnectionAvailable]))
        {
            appDelegate.internetAlertFlag = FALSE;
            [delegate showInternetAletView];
            return;
        }
    }
 
   
    appDelegate.metaSyncCompleted = YES;
    appDelegate.metaSyncRunning = NO;
    [pool release];
    
}

- (void) syncSuccess
{
    appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    
//	[appDelegate setCurrentSyncStatusProgress:METSSYNC_END optimizedSynstate:0];

    [delegate activityStop];
    [delegate enableControls];
    
    if (syncConfigurationFailed == TRUE)
    {
        [appDelegate setSyncStatus:SYNC_GREEN];
        
		[appDelegate.wsInterface.updateSyncStatus refreshMetaSyncStatus];
		[self updateMetsSyncStatus:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_failed]];
    }
    else
    {
		//Get the User Language After Incremental meta synchronization :
		//Shrinivas : OAuth :
		[[ZKServerSwitchboard switchboard] doCheckSession];
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[appDelegate.oauthClient setUserLanguage:[userDefaults valueForKey:IDENTITY_URL]];

        appDelegate.SyncStatus = SYNC_GREEN;
        BOOL conflict_exists = [appDelegate.databaseInterface getConflictsStatus];
        if(conflict_exists)
        {
            appDelegate.SyncStatus = SYNC_RED;
        }
        else
        {
            appDelegate.SyncStatus = SYNC_GREEN;
        }
        if ([appDelegate.dataBase checkIfSyncConfigDue])
        {
            [delegate resetTableview];
            [appDelegate.databaseInterface cleartable:@"meta_sync_due"];
        }
		
		[self refreshMetaSyncTimeStamp];
		[appDelegate.wsInterface.updateSyncStatus refreshMetaSyncStatus];
		[self updateMetsSyncStatus:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_succeeded]];


    }
    //Radha Progress Bar
	//appDelegate.syncTypeInProgress = NO_SYNCINPROGRESS;
	
    appDelegate.dataBase.MyPopoverDelegate = nil;
    appDelegate.databaseInterface.MyPopoverDelegate = nil;
    appDelegate.wsInterface.MyPopoverDelegate = nil;
    
    
    if (appDelegate.event_thread != nil)
    {
		appDelegate.event_thread = nil;
    }
    appDelegate.wsInterface.tagsDictionary = [appDelegate.dataBase getTagsDictionary];
    NSMutableDictionary * temp_dict = [appDelegate.wsInterface fillEmptyTags:appDelegate.wsInterface.tagsDictionary];
    appDelegate.wsInterface.tagsDictionary = temp_dict;
	//7444
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.metasync_timer];
    [self performSelectorOnMainThread:@selector(scheduletimer) withObject:nil waitUntilDone:NO];
    
}

//Update meta sync status
- (void) updateMetsSyncStatus:(NSString*)Status
{
	@try{
    //create SYNC_HISTORY PLIST
    NSString * rootpath_SYNHIST = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:SYNC_HISTORY];
	
	NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath_SYNHIST];
    NSArray * allkeys= [dict allKeys];
    
	
    for(NSString *  str in allkeys)
    {
        if([str isEqualToString:META_SYNC_STATUS])
        {
			[dict  setObject:Status forKey:META_SYNC_STATUS];
			break;
        }
    }
    [dict writeToFile:plistPath_SYNHIST atomically:YES];
	}@catch (NSException *exp) {
	SMLog(@"Exception Name PopoverButtons :updateMetsSyncStatus %@",exp.name);
	SMLog(@"Exception Reason PopoverButtons :updateMetsSyncStatus %@",exp.reason);
    }

}


- (void) scheduletimer
{
    [appDelegate ScheduleIncrementalDatasyncTimer];
    [appDelegate ScheduleIncrementalMetaSyncTimer];
    [appDelegate ScheduleTimerForEventSync];
	//Radha Defect Fix 5542
	[appDelegate updateNextDataSyncTimeToBeDisplayed:[NSDate date]];
	//7444
	[appDelegate updateMetasyncTimeinSynchistory:[NSDate date]];

}

//EVENT SYNC METHOD
- (void) startSyncEvents
{
    if (appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];

	if (![appDelegate isInternetConnectionAvailable])
    {
        return;
    }
	else
	{
		if ([appDelegate.internet_Conflicts count] == 1)
		{
			[appDelegate.calDataBase removeInternetConflicts];
			[appDelegate.internet_Conflicts removeAllObjects];
			[appDelegate.reloadTable ReloadSyncTable];
		}
	}
    
	//OAuth.
	BOOL retVal_ = [[ZKServerSwitchboard switchboard] doCheckSession];
	
	if ([appDelegate.currentServerUrl Contains:@"null"] || [appDelegate.currentServerUrl length] == 0 || appDelegate.currentServerUrl == nil)
	{
		NSUserDefaults * userdefaults = [NSUserDefaults standardUserDefaults];
		
		appDelegate.currentServerUrl = [userdefaults objectForKey:SERVERURL];
	}
    if(retVal_ == NO || [appDelegate.currentServerUrl Contains:@"null"] )
    {
        [delegate dismisspopover];
        appDelegate.SyncStatus = SYNC_GREEN;
        [appDelegate setSyncStatus:SYNC_GREEN];
		
        return;
    }

    if(appDelegate.eventSyncRunning ) 
    {
        [delegate dismisspopover];
        return;
    }
    
    
    if( appDelegate.dataSyncRunning )
    {
        appDelegate.eventSyncRunning = NO;
        //exit data sync and queue it right after this method
        appDelegate.queue_object = appDelegate;
        appDelegate.queue_selector = @selector(callEventSyncTimer);
        [delegate dismisspopover];
        return;
    }
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
       NSString * event_sync = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_events];
    BOOL retVal;
    
    fullDataSyncFailed = FALSE;
    @try {
        
        [delegate dismisspopover];
       
        
        
        appDelegate.dataBase.MyPopoverDelegate = delegate;
        appDelegate.databaseInterface.MyPopoverDelegate = delegate;
        appDelegate.wsInterface.MyPopoverDelegate = delegate;
        
        if([appDelegate.syncThread isExecuting])
        {
            return;
        }
         
        if (![appDelegate isInternetConnectionAvailable])
        {
            [refreshMetaSyncDelegate refreshMetaSyncStatus];
            
            [appDelegate setSyncStatus:SYNC_RED];
            
            
            [appDelegate.calDataBase insertIntoConflictInternetErrorWithSyncType:event_sync];     
            appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflicts];
            
            [appDelegate.reloadTable ReloadSyncTable];
        }

        
        if ([appDelegate.metaSyncThread isExecuting])
        {
            
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
            {
#ifdef kPrintLogsDuringWebServiceCall
                SMLog(@"popoverButtons.m : startSyncEvents: check for Meta sync thread");
#endif

                if (![appDelegate isInternetConnectionAvailable])
                {
                    break;
                }
                
                if ([appDelegate.metaSyncThread isFinished])
                {
                //    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.metasync_timer];
                    break;
                }
            }
        }
                
        //RADHA 2012june12
        if (appDelegate.metaSyncRunning)
        {
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
            {
                if (![appDelegate isInternetConnectionAvailable])
                {
                    break;
                }
                
                if (!appDelegate.metaSyncRunning)
                {
                    break;
                }
            }
        }
		//appDelegate.syncTypeInProgress = EVENTSYNC_INPROGRESS;
        [appDelegate setCurrentSyncStatusProgress:eEVENTSYNC_STARTS optimizedSynstate:0];
               
        	//OAuth.
		[[ZKServerSwitchboard switchboard] doCheckSession];

        [appDelegate.databaseInterface cleartable:SYNC_RECORD_HEAP];
        appDelegate.eventSyncRunning = YES;
        retVal = [appDelegate.dataBase startEventSync];
        
        
    }
    @catch (NSException *exception) { 
        
	[appDelegate.refreshIcons RefreshIcons]; //20-June-2013. ---> Refreshing home incons when sync is running.
        fullDataSyncFailed = TRUE;
        appDelegate.dataBase.MyPopoverDelegate = nil;
        appDelegate.databaseInterface.MyPopoverDelegate = nil;
        appDelegate.wsInterface.MyPopoverDelegate = nil;
        
        if ([appDelegate.event_thread isExecuting])
        {
            
        }
        else if ([appDelegate isInternetConnectionAvailable] )
        {
			//OAuth.
            BOOL value = [[ZKServerSwitchboard switchboard] doCheckSession];
            
            if (value == NO)
				[appDelegate setSyncStatus:SYNC_RED];
            else          
                [appDelegate setSyncStatus:SYNC_GREEN];
        }
    }
    @finally {

	[appDelegate.refreshIcons RefreshIcons]; //20-June-2013. ---> Refreshing home incons when sync is running.
        appDelegate.eventSyncRunning = NO;
         if([appDelegate.syncThread isExecuting] || [appDelegate.metaSyncThread isExecuting] )
         {
            if( appDelegate.queue_object == nil )
            {
                appDelegate.queue_object = [self retain];
                appDelegate.queue_selector = @selector(startSyncEvents);
                return;
            }
         }
                
        appDelegate.dataBase.MyPopoverDelegate = nil;
        appDelegate.databaseInterface.MyPopoverDelegate = nil;
        appDelegate.wsInterface.MyPopoverDelegate = nil;
        
    }
    if (fullDataSyncFailed == FALSE)
    {
        
//		[appDelegate setCurrentSyncStatusProgress:eEVENTSYNC_END optimizedSynstate:0];

        BOOL conflict_exists = [appDelegate.databaseInterface getConflictsStatus];
        if(conflict_exists)
        {
            appDelegate.SyncStatus = SYNC_RED;
        }
        else
        {
            appDelegate.SyncStatus = SYNC_GREEN;
        }
        
		[appDelegate.wsInterface.updateSyncStatus refreshSyncStatus];
    }
    
    
    [pool release];
	
	//Radha Progress Bar
	//appDelegate.syncTypeInProgress = NO_SYNCINPROGRESS;
    
    if( appDelegate.queue_object != nil )
    {
        appDelegate.eventSyncRunning = NO;
        [appDelegate.queue_object performSelectorOnMainThread:appDelegate.queue_selector withObject:nil waitUntilDone:NO];
    }
    
    if( appDelegate.queue_object != nil )
    {
        appDelegate.queue_object = nil;
    }
    appDelegate.eventSyncRunning = NO;
	
	//fire a notification here to all subscribed objects about the completion of event-task sync
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EVENT_DATA_SYNC object:nil];
}

- (void) setSyncStatus
{
    appDelegate.SyncStatus = SYNC_RED;
}


//Radha 28/Sep/2012
- (void) refreshMetaSyncTimeStamp
{
	NSString * rootpath_SYNHIST = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath_SYNHIST = [rootpath_SYNHIST stringByAppendingPathComponent:SYNC_HISTORY];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath_SYNHIST];
    NSArray * allkeys= [dict allKeys];
    
    NSDate * current_dateTime = [NSDate date];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]]; //Change for Time Stamp
    
	for(NSString *  str in allkeys)
    {
        if([str isEqualToString:LAST_INITIAL_META_SYNC_TIME])
        {
            NSString * last_sync_time = [dateFormatter stringFromDate:current_dateTime];
            [dict  setObject:last_sync_time forKey:LAST_INITIAL_META_SYNC_TIME];
        }
    }
    [dict writeToFile:plistPath_SYNHIST atomically:YES];

}


#pragma mark - AlertView Delegate Methods
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        continueFalg = TRUE;
    }
    
    else if (buttonIndex == 1)
    {
        continueFalg = FALSE;
    }
}

- (void) alertViewCancel:(UIAlertView *)alertView
{
     continueFalg = FALSE;
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    didDismissAlertView = TRUE;
}

@end


