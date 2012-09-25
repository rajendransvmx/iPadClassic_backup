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

PopoverButtons *popOver_view;

@implementation PopoverButtons

@synthesize syncConfigurationFailed;

@synthesize button, button1, button2;

@synthesize objectsArray;
@synthesize objectsDict;
@synthesize objectDetailsArray;
@synthesize delegate;
@synthesize popover;
@synthesize refreshMetaSyncDelegate;

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
    button1.frame = CGRectMake(0, 56, 214, 59);
    [button1 addSubview:label1];
    [button1 setImage:buttonBkground forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(synchronizeConfiguration)forControlEvents:UIControlEventTouchUpInside];
 
    
    //Label2
    UILabel *label2 = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 50)] autorelease];
    label2.backgroundColor = [UIColor clearColor];
    //label2.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_full_data_synchronize];
    label2.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_events];
    button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(0, 115, 214, 59);
    [button2 addSubview:label2];
    [button2 setImage:buttonBkground forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(synchronizeEvents)forControlEvents:UIControlEventTouchUpInside];

    
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgImage];
    
    [self.view addSubview:button];
    [self.view addSubview:button1];
    [self.view addSubview:button2];
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

- (void) Syncronise
{
	BOOL retVal;
    [delegate dismisspopover];
    appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.isInternetConnectionAvailable)
    {
        appDelegate.shouldShowConnectivityStatus = TRUE;
        [appDelegate displayNoInternetAvailable];
        return;
    }
    
    retVal = [appDelegate pingServer];
    
    if(retVal == NO)
    {
        return;
    }
    
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
        
        if (!appDelegate.isInternetConnectionAvailable)
        {
            
            [appDelegate setSyncStatus:SYNC_RED];
            [appDelegate.calDataBase insertIntoConflictInternetErrorWithSyncType:data_sync];
            appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflicts];
            [appDelegate.reloadTable ReloadSyncTable];
            return;
        }
        
        appDelegate.dataSyncRunning = YES;
        
        if ([appDelegate.metaSyncThread isExecuting])
        {
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES))
            {
                if (!appDelegate.isInternetConnectionAvailable)
                {
                    break;
                }
                if ([appDelegate.metaSyncThread isFinished])
                {
                 //   [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.metasync_timer];
                    break;
                }
            }
        }
//        else
//        {
//            if ([appDelegate.metasync_timer isValid])	
//            {
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.metasync_timer];
//            }            
//        }       
//
        
        if ([appDelegate.event_thread isExecuting])
        {
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES))
            {
                if (!appDelegate.isInternetConnectionAvailable)
                {
                    break;
                }
                
                if ([appDelegate.event_thread isFinished])
                {
                 //   [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.event_timer];
                    break;
                }
            }
        }
//        else
//        {
//            if ([appDelegate.event_timer isValid])
//            {
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.event_timer];
//            }            
//        }   

        if ([appDelegate.metasync_timer isValid])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.metasync_timer];
        }      
        
		[delegate activityStart];
        [appDelegate callDataSync];
		[delegate activityStop];
        appDelegate.dataSyncRunning = NO;
}
    
    else 
    {        
        [appDelegate.calDataBase selectUndoneRecords];
        
        appDelegate.SyncStatus = SYNC_ORANGE;
        
        if([appDelegate.syncThread isExecuting])
        {
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES))
            {
                if ([appDelegate.syncThread isFinished])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.datasync_timer];
                    break;
                }
                if (!appDelegate.isInternetConnectionAvailable)
                    break;
            }
        }
//        else
//        {
//            if ([appDelegate.datasync_timer isValid])
//            {
//               [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.datasync_timer];
//            }
//            
//        }    
        
        if ([appDelegate.metaSyncThread isExecuting])
        {
            
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES))
            {
                if (!appDelegate.isInternetConnectionAvailable)
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
//        else
//        {
//            if ([appDelegate.metasync_timer isValid])		
//            {
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.metasync_timer];
//            }            
//        }       
        
        if ([appDelegate.event_thread isExecuting])
        {
            
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES))
            {
                if (!appDelegate.isInternetConnectionAvailable)
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
//        else
//        {
//            if ([appDelegate.event_timer isValid])
//            {
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.event_timer];
//            }            
//        }   

        appDelegate.isSpecialSyncDone = FALSE;
		
		[delegate activityStart];
        [appDelegate callSpecialIncrementalSync];
        
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES))
        {
            if(appDelegate.isSpecialSyncDone)
                break;
            
            if (!appDelegate.isInternetConnectionAvailable)
                break;
            
            if (appDelegate.connection_error)
            {
                break;
            }
        }
		
        retVal = [appDelegate.calDataBase selectCountFromSync_Conflicts];
        if (retVal == FALSE)
        {
            [appDelegate callDataSync];
        }
    }
//    [appDelegate ScheduleIncrementalMetaSyncTimer];
//    [appDelegate ScheduleIncrementalDatasyncTimer];
//    [appDelegate ScheduleTimerForEventSync];    
    
	[delegate activityStop];
    [appDelegate.reloadTable ReloadSyncTable];
}

- (void) synchronizeConfiguration
{
    if ([appDelegate.metaSyncThread isExecuting])
    {
        NSLog(@"Meta sync executing");
    }
    
    else 
    {
        NSLog(@"Finished");
    }
    
    [appDelegate.metaSyncThread release];
    appDelegate.metaSyncThread = [[NSThread alloc] initWithTarget:self selector:@selector(startSyncConfiguration) object:nil];
    [appDelegate.metaSyncThread start];
}


- (void) synchronizeEvents
{
    if (!appDelegate.isInternetConnectionAvailable)
    {
        [delegate dismisspopover];
        appDelegate.shouldShowConnectivityStatus = TRUE;
        [appDelegate displayNoInternetAvailable];
        return;
    }

    
    if ([manualEventThread isExecuting])
    {
        NSLog(@"Manual event sync executing");
    }
    
    else 
    {
        NSLog(@"Finished");
    }
    
    [manualEventThread release];
    manualEventThread = [[NSThread alloc] initWithTarget:self selector:@selector(startSyncEvents) object:nil];
    [manualEventThread start];
                         
}

- (void) startSyncConfiguration
{
    appDelegate.internetAlertFlag = FALSE;
    appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    [delegate dismisspopover];
    
    if (!appDelegate.isInternetConnectionAvailable)
    {
        appDelegate.shouldShowConnectivityStatus = TRUE;
        [appDelegate displayNoInternetAvailable];
        return;
    }
    
   
    	//new code to handle meta sync whenever the application is logged of the authentication module.
	BOOL retVal = [appDelegate pingServer];
    
    if(retVal == NO)
    {
		[delegate dismisspopover];
        return;
    }

    if (appDelegate.metaSyncRunning) 
    {
        [delegate dismisspopover];
        return;
    }
    [appDelegate.dataBase clearTempDatabase];
    appDelegate.metaSyncRunning = YES;
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    syncConfigurationFailed = FALSE;
    appDelegate.isIncrementalMetaSyncInProgress = FALSE;
    
    @try {
        
        if (!appDelegate.isInternetConnectionAvailable)
        {
            return;
        }
        appDelegate.isIncrementalMetaSyncInProgress = TRUE;
        
        [appDelegate.calDataBase insertMetaSyncStatus:@"Green" WithDB:appDelegate.db];
        appDelegate.dataBase.MyPopoverDelegate = delegate;
        appDelegate.databaseInterface.MyPopoverDelegate = delegate;
        appDelegate.wsInterface.MyPopoverDelegate = delegate;
        
        [delegate activityStart];
        [delegate disableControls];
        
        
        if([appDelegate.syncThread isExecuting])
        {
           while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES))
            {
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
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES))
            {
                if (!appDelegate.isInternetConnectionAvailable)
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
        
		if ([manualEventThread isExecuting])
		{
			while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES))
			{
				if (!appDelegate.isInternetConnectionAvailable)
				{
					break;
				}
				
				if ([manualEventThread isFinished])
				{
					break;
				}
			}
		}
		
        if (!appDelegate.isInternetConnectionAvailable)
        {
            appDelegate.SyncStatus = SYNC_GREEN;
            [appDelegate setSyncStatus:SYNC_GREEN];
            return;
	
        }
        

        [refreshMetaSyncDelegate refreshMetaSyncStatus];
        
        [appDelegate setSyncStatus:SYNC_ORANGE];
      
        [appDelegate goOnlineIfRequired];
        [appDelegate.dataBase removecache];
        appDelegate.didincrementalmetasyncdone = FALSE;
        
        [appDelegate.dataBase StartIncrementalmetasync];
//        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES))
//        {
//            if (!appDelegate.isInternetConnectionAvailable)
//            {
//                break;
//            }
//            if (appDelegate.didincrementalmetasyncdone == TRUE)
//                break; 
//        }
//        if (!appDelegate.isInternetConnectionAvailable)
//        {
//           
//        }
        
        
    }
    @catch (NSException * exception) {
        
		appDelegate.metaSyncRunning = NO;
        exception = [NSException exceptionWithName:@"Error" reason:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_failed_try_again] userInfo: nil];
        syncConfigurationFailed = TRUE;
            
        
        [delegate enableControls];
        
		[appDelegate.calDataBase insertMetaSyncStatus:@"Red" WithDB:appDelegate.db];
        if (!appDelegate.isInternetConnectionAvailable)
        {
            appDelegate.internetAlertFlag = TRUE;
         
        }
        else
        {
            NSString * title  = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_status_button1];
            NSString * cancel = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_meta_sync_failed] delegate:self cancelButtonTitle:cancel otherButtonTitles: nil];
			
			
            [alert show];
            [alert release];
            [appDelegate.dataBase copyTempsqlToSfm];
            
            
        }
        
        
    }
    @finally {
        
        if(appDelegate.internetAlertFlag == TRUE && (!appDelegate.isInternetConnectionAvailable))
        {
            appDelegate.internetAlertFlag = FALSE;
            [delegate showInternetAletView];
            return;
        }
    }
 
    [pool release];
    appDelegate.metaSyncCompleted = YES;
    appDelegate.metaSyncRunning = NO;
    
}

- (void) syncSuccess
{
    appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
        
    [delegate activityStop];
    [delegate enableControls];
    
    if (syncConfigurationFailed == FALSE)
    {
        NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_status_button1];
        NSString * cancel = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
        
        UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:title message:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_completed] delegate:self cancelButtonTitle:cancel otherButtonTitles: nil];
        
        [appDelegate.calDataBase insertMetaSyncStatus:@"Green" WithDB:appDelegate.db];
        
        [alert show];
        [alert release];
        
        if ([appDelegate.dataBase checkIfSyncConfigDue])
        {
            [delegate resetTableview];
            [appDelegate.databaseInterface cleartable:@"meta_sync_due"];
        }
        
    }
    else
    {
        NSString * title  = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_status_button1];
        NSString * cancel = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_meta_sync_failed] delegate:self cancelButtonTitle:cancel otherButtonTitles: nil];
        
        
        [alert show];
        [alert release];
    }
    
    BOOL conflict_exists = [appDelegate.databaseInterface getConflictsStatus];
    if(conflict_exists)
    {
        appDelegate.SyncStatus = SYNC_RED;
    }
    else
    {
        appDelegate.SyncStatus = SYNC_GREEN;
    }
    appDelegate.dataBase.MyPopoverDelegate = nil;
    appDelegate.databaseInterface.MyPopoverDelegate = nil;
    appDelegate.wsInterface.MyPopoverDelegate = nil;
    appDelegate.metaSyncRunning = NO;
    
    
    if (appDelegate.event_thread != nil)
    {
        [appDelegate.event_thread release];
    }

    [self performSelectorOnMainThread:@selector(scheduletimer) withObject:nil waitUntilDone:NO];
    
}

- (void) scheduletimer
{
    [appDelegate ScheduleIncrementalDatasyncTimer];
    [appDelegate ScheduleIncrementalMetaSyncTimer];
    [appDelegate ScheduleTimerForEventSync];
}

//EVENT SYNC METHOD
- (void) startSyncEvents
{
    if (appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];

	if (!appDelegate.isInternetConnectionAvailable)
    {
        return;
    }
    
	BOOL retVal_ = [appDelegate pingServer];
    if(retVal_ == NO)
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
         
        if (!appDelegate.isInternetConnectionAvailable)
        {
            [refreshMetaSyncDelegate refreshMetaSyncStatus];
            
            [appDelegate setSyncStatus:SYNC_RED];
            
            
            [appDelegate.calDataBase insertIntoConflictInternetErrorWithSyncType:event_sync];     
            appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflicts];
            
            [appDelegate.reloadTable ReloadSyncTable];
        }

        
        if ([appDelegate.metaSyncThread isExecuting])
        {
            
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES))
            {
                if (!appDelegate.isInternetConnectionAvailable)
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
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES))
            {
                if (!appDelegate.isInternetConnectionAvailable)
                {
                    break;
                }
                
                if (!appDelegate.metaSyncRunning)
                {
                    break;
                }
            }
        }
      
        [appDelegate setSyncStatus:SYNC_ORANGE];
               
        [appDelegate goOnlineIfRequired];
        [appDelegate.databaseInterface cleartable:SYNC_RECORD_HEAP];
        appDelegate.eventSyncRunning = YES;
        retVal = [appDelegate.dataBase startEventSync];
        
        
    }
    @catch (NSException *exception) { 
        
        exception = [NSException exceptionWithName:@"Error" reason:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_failed_try_again] userInfo: nil];
        fullDataSyncFailed = TRUE;
        appDelegate.dataBase.MyPopoverDelegate = nil;
        appDelegate.databaseInterface.MyPopoverDelegate = nil;
        appDelegate.wsInterface.MyPopoverDelegate = nil;
        
        if ([appDelegate.event_thread isExecuting])
        {
            
        }
        else if (appDelegate.isInternetConnectionAvailable )
        {
            BOOL value = [appDelegate pingServer];
            
            NSString * title  = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_status_button1];
            NSString * cancel = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:[NSString stringWithFormat:@"%@", exception.description] delegate:self cancelButtonTitle:cancel otherButtonTitles: nil];
            if (value == NO)
				[appDelegate setSyncStatus:SYNC_RED];
            else          
                [appDelegate setSyncStatus:SYNC_GREEN];
            [alert show];
            [alert release];
        }
    }
    @finally {

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
        
//        [appDelegate ScheduleIncrementalDatasyncTimer];
//        [appDelegate ScheduleIncrementalMetaSyncTimer];
//        [appDelegate ScheduleTimerForEventSync];
        
        appDelegate.dataBase.MyPopoverDelegate = nil;
        appDelegate.databaseInterface.MyPopoverDelegate = nil;
        appDelegate.wsInterface.MyPopoverDelegate = nil;
        
    }
    if (fullDataSyncFailed == FALSE)
    {
//        if ([appDelegate.event_thread isExecuting])
//        {
//            
//        }
//        else
        {
        
            NSString * title  = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_status_button1];
            NSString * cancel = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
            
            UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:title message:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_completed] delegate:self cancelButtonTitle:cancel otherButtonTitles: nil];
            
            [alert show];
            [alert release];
        }
        
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
    
    if( appDelegate.queue_object != nil )
    {
        appDelegate.eventSyncRunning = NO;
        [appDelegate.queue_object performSelectorOnMainThread:appDelegate.queue_selector withObject:nil waitUntilDone:NO];
    }
    
    if( appDelegate.queue_object != nil )
    {
        [appDelegate.queue_object release];
        appDelegate.queue_object = nil;
    }
    appDelegate.eventSyncRunning = NO;
	
	//fire a notification here to all subscribed objects about the completion of event-task sync
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EVENT_DATA_SYNC object:nil];
}

@end


