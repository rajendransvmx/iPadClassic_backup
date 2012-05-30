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

@implementation PopoverButtons

@synthesize button, button1, button2;

@synthesize objectsArray;
@synthesize objectsDict;
@synthesize objectDetailsArray;
@synthesize delegate;
@synthesize popover;


- (void)loadView
{
    appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    detail = [[ManualDataSyncDetail alloc] init];
    
    [super loadView];
    self.view.frame = CGRectMake(0, 0, 100, 100);
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_right_panel_bg_main.png"]];
    
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
    [delegate dismisspopover];
    appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    [delegate activityStart];
    if(appDelegate.SyncStatus != SYNC_RED)
    {        
        if([appDelegate.syncThread isExecuting])
        {
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, NO))
            {
                if ([appDelegate.syncThread isFinished])
                {
                    [appDelegate.datasync_timer invalidate];
                    break;
                }
                if (!appDelegate.isInternetConnectionAvailable)
                    break;
            }
        }
        else
        {
            if (appDelegate.datasync_timer)
            {
                [appDelegate.datasync_timer invalidate];
            }
            
        }    
        
        if ([appDelegate.metaSyncThread isExecuting])
        {
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, NO))
            {
                if (!appDelegate.isInternetConnectionAvailable)
                {
                    break;
                }
                if ([appDelegate.metaSyncThread isFinished])
                {
                    [appDelegate.metasync_timer invalidate];
                    break;
                }
            }
        }
        else
        {
            if (appDelegate.metasync_timer)		
            {
                [appDelegate.metasync_timer invalidate];
            }            
        }       

        
        if (!appDelegate.isInternetConnectionAvailable)
        {
            appDelegate.SyncStatus = SYNC_RED;
            [appDelegate.wsInterface.refreshSyncButton showSyncStatusButton];
            [appDelegate.wsInterface.refreshModalStatusButton showModalSyncStatus];
            [appDelegate.wsInterface.refreshSyncStatusUIButton showSyncUIStatus];
            [appDelegate.calDataBase insertIntoConflictInternetErrorWithSyncType:@"Data Sync"];
            appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflictsForMetaSyncWithDB:appDelegate.dataBase.tempDb];
            [appDelegate.reloadTable ReloadSyncTable];
            return;
        }
        
        [appDelegate callDataSync];
        
    }
    
    else 
    {        
        [appDelegate.calDataBase selectUndoneRecords];
        
        if([appDelegate.syncThread isExecuting])
        {
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, NO))
            {
                if ([appDelegate.syncThread isFinished])
                {
                    [appDelegate.datasync_timer invalidate];
                    break;
                }
                if (!appDelegate.isInternetConnectionAvailable)
                    break;
            }
        }
        else
        {
            if (appDelegate.datasync_timer)
            {
               [appDelegate.datasync_timer invalidate];
            }
            
        }    
        
        if ([appDelegate.metaSyncThread isExecuting])
        {
            
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, NO))
            {
                if (!appDelegate.isInternetConnectionAvailable)
                {
                    break;
                }
                
                if ([appDelegate.metaSyncThread isFinished])
                {
                    [appDelegate.metasync_timer invalidate];
                    break;
                }
            }
        }
        else
        {
            if (appDelegate.metasync_timer)		
            {
                [appDelegate.metasync_timer invalidate];
            }            
        }       
        appDelegate.isSpecialSyncDone = FALSE;
        [appDelegate callSpecialIncrementalSync];
        
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, NO))
        {
            if(appDelegate.isSpecialSyncDone)
                break;
            
            if (!appDelegate.isInternetConnectionAvailable)
                break;
        }

        
        
        if (appDelegate.SyncStatus != SYNC_RED)
        {
            [appDelegate callDataSync];
        }
    }
    [delegate activityStop];
    [appDelegate ScheduleIncrementalMetaSyncTimer];
    [appDelegate ScheduleIncrementalDatasyncTimer];
}

- (void) synchronizeConfiguration
{
    
    syncConfigurationFailed = FALSE;
    appDelegate.isIncrementalMetaSyncInProgress = FALSE;
    
    @try {
        
        [delegate dismisspopover];
        
        
        if (!appDelegate.isInternetConnectionAvailable)
        {
            return;
        }
        
        appDelegate.dataBase.MyPopoverDelegate = delegate;
        appDelegate.databaseInterface.MyPopoverDelegate = delegate;
        appDelegate.wsInterface.MyPopoverDelegate = delegate;
        
        [delegate activityStart];
        [delegate disableControls];
        
        
        appDelegate.SyncStatus = SYNC_ORANGE;
        
        [appDelegate.wsInterface.refreshSyncButton showSyncStatusButton];
        [appDelegate.wsInterface.refreshModalStatusButton showModalSyncStatus];
        [appDelegate.wsInterface.refreshSyncStatusUIButton showSyncUIStatus];
        appDelegate.isIncrementalMetaSyncInProgress = TRUE;
       
        
        if([appDelegate.syncThread isExecuting])
        {
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, YES))
            {
                if ([appDelegate.syncThread isFinished])
                {
                    [appDelegate.datasync_timer invalidate];
                    break;
                }
            }
        }
        else
        {
            if (appDelegate.datasync_timer)
            {
                [appDelegate.datasync_timer invalidate];
            }            
        }   
        
        
        
        if ([appDelegate.metaSyncThread isExecuting])
        {
            
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, YES))
            {
                if (!appDelegate.isInternetConnectionAvailable)
                {
                    break;
                }
                
                if ([appDelegate.metaSyncThread isFinished])
                {
                    [appDelegate.metasync_timer invalidate];
                    break;
                }
            }
        }
        else
        {
            if (appDelegate.metasync_timer)
            {
                [appDelegate.metasync_timer invalidate];
            }            
        }   
        
        if (!appDelegate.isInternetConnectionAvailable)
        {
            appDelegate.SyncStatus = SYNC_RED;
            
            [appDelegate.wsInterface.refreshSyncButton showSyncStatusButton];
            [appDelegate.wsInterface.refreshModalStatusButton showModalSyncStatus];
            [appDelegate.wsInterface.refreshSyncStatusUIButton showSyncUIStatus];
            [appDelegate.calDataBase insertIntoConflictInternetErrorForMetaSync:@"META SYNC" WithDB:appDelegate.dataBase.tempDb];
            appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflictsForMetaSyncWithDB:appDelegate.dataBase.tempDb];
            [appDelegate.reloadTable ReloadSyncTable];
        }
        
        [appDelegate goOnlineIfRequired];
        [appDelegate.dataBase removecache];
        appDelegate.didincrementalmetasyncdone = FALSE;
        
        [appDelegate.dataBase StartIncrementalmetasync];
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, YES))
        {
            if (!appDelegate.isInternetConnectionAvailable)
            {
                break;
            }
            if (appDelegate.didincrementalmetasyncdone == TRUE)
                break; 
        }
        if (!appDelegate.isInternetConnectionAvailable)
        {
            appDelegate.SyncStatus = SYNC_RED;
            
            [appDelegate.wsInterface.refreshSyncButton showSyncStatusButton];
            [appDelegate.wsInterface.refreshModalStatusButton showModalSyncStatus];
            [appDelegate.wsInterface.refreshSyncStatusUIButton showSyncUIStatus];
            //[appDelegate.reloadTable ReloadSyncTable];
            [appDelegate.calDataBase insertIntoConflictInternetErrorForMetaSync:@"META SYNC" WithDB:appDelegate.dataBase.tempDb];     
            appDelegate.internet_Conflicts = [appDelegate.calDataBase getInternetConflictsForMetaSyncWithDB:appDelegate.dataBase.tempDb];
            [appDelegate.reloadTable ReloadSyncTable];
        }


    }
    @catch (NSException * exception) {
        
       exception = [NSException exceptionWithName:@"Error" reason:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_failed_try_again] userInfo: nil];
        syncConfigurationFailed = TRUE;
        appDelegate.dataBase.MyPopoverDelegate = nil;
        appDelegate.databaseInterface.MyPopoverDelegate = nil;
        appDelegate.wsInterface.MyPopoverDelegate = nil;
        
        [appDelegate.dataBase copyTempsqlToSfm];
    
        [delegate enableControls];
        NSString * title  = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_status_button1];
       NSString * cancel = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:[NSString stringWithFormat:@"%@",exception.description] delegate:self cancelButtonTitle:cancel otherButtonTitles: nil];
        [alert show];
        [alert release];
        
    }
    @finally {
        [appDelegate ScheduleIncrementalDatasyncTimer];
        [appDelegate ScheduleIncrementalMetaSyncTimer];
        [appDelegate.dataBase deleteDatabase:TEMPDATABASENAME];
        [appDelegate initWithDBName:DATABASENAME1 type:DATABASETYPE1];
        
       if ([appDelegate.StandAloneCreateProcess count] > 0)
        {
            [appDelegate.StandAloneCreateProcess  removeAllObjects];
            NSMutableArray * createprocessArray = [appDelegate.databaseInterface getAllTheProcesses:@"STANDALONECREATE"];
            [appDelegate getCreateProcessArray:createprocessArray];
        }
             
        if ([appDelegate.view_layout_array count] > 0)
        {
            [appDelegate.view_layout_array removeAllObjects];
            appDelegate.view_layout_array = [appDelegate.databaseInterface getAllTheProcesses:@"VIEWRECORD"]; 
        }
        
        appDelegate.dataBase.MyPopoverDelegate = nil;
        appDelegate.databaseInterface.MyPopoverDelegate = nil;
        appDelegate.wsInterface.MyPopoverDelegate = nil;
        [delegate activityStop];
        
        appDelegate.isIncrementalMetaSyncInProgress = FALSE;
        
    }
    
    if (syncConfigurationFailed == FALSE)
    {
        [delegate enableControls];
        
        NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_status_button1];
        NSString * cancel = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
        
        UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:title message:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_completed] delegate:self cancelButtonTitle:cancel otherButtonTitles: nil];
        
        appDelegate.SyncStatus = SYNC_GREEN;
        
        [appDelegate.wsInterface.refreshSyncButton showSyncStatusButton];
        [appDelegate.wsInterface.refreshModalStatusButton showModalSyncStatus];
        [appDelegate.wsInterface.refreshSyncStatusUIButton showSyncUIStatus];
        [alert show];
        [alert release];
    }
    else
    {
        
    }
    
}


- (void) synchronizeEvents
{
    [self startSyncEvents];
}

- (void) schdulesynchronizeConfiguration
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    if (appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    syncConfigurationFailed = FALSE;
    
    @try {
        
        if (appDelegate.SyncStatus == SYNC_RED)
            return;
        
        appDelegate.dataBase.MyPopoverDelegate = delegate;
        appDelegate.databaseInterface.MyPopoverDelegate = delegate;
        appDelegate.wsInterface.MyPopoverDelegate = delegate;
               
        if([appDelegate.syncThread isExecuting])
        {
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, NO))
            {
                if (!appDelegate.isInternetConnectionAvailable)
                {
                    break;
                }
                
                if ([appDelegate.syncThread isFinished])
                {
                    [appDelegate.datasync_timer invalidate];
                    break;
                }
            }
        }
        else
        {
            if (appDelegate.datasync_timer)
            {
                [appDelegate.datasync_timer invalidate];
            }            
        }   
        
        [appDelegate goOnlineIfRequired];
        [appDelegate.dataBase removecache];     
        appDelegate.didincrementalmetasyncdone = FALSE;
        
        [appDelegate.dataBase StartIncrementalmetasync];
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, NO))
        {
            if (!appDelegate.isInternetConnectionAvailable)
                break;
            
            if (appDelegate.didincrementalmetasyncdone == TRUE)
                break; 
        }
        
    }
    @catch (NSException * exception) {
        exception = [NSException exceptionWithName:@"Error" reason:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_failed_try_again] userInfo: nil];
        syncConfigurationFailed = TRUE;
        [appDelegate.dataBase copyTempsqlToSfm];

    }
    @finally {
        [appDelegate ScheduleIncrementalDatasyncTimer];
        [appDelegate.dataBase deleteDatabase:TEMPDATABASENAME];
        [appDelegate initWithDBName:DATABASENAME1 type:DATABASETYPE1];
        
        if ([appDelegate.StandAloneCreateProcess count] > 0)
        {
            [appDelegate.StandAloneCreateProcess  removeAllObjects];
            NSMutableArray * createprocessArray = [appDelegate.databaseInterface getAllTheProcesses:@"STANDALONECREATE"];
            [appDelegate getCreateProcessArray:createprocessArray];
        }
        
        if ([appDelegate.view_layout_array count] > 0)
        {
            [appDelegate.view_layout_array removeAllObjects];
            appDelegate.view_layout_array = [appDelegate.databaseInterface getAllTheProcesses:@"VIEWRECORD"]; 
        }
        
        if ([appDelegate.wsInterface.tagsDictionary count] > 0)
        {
            [appDelegate.wsInterface.tagsDictionary removeAllObjects];
            NSMutableDictionary * dict = [appDelegate.dataBase getTagsDictionary];
            appDelegate.wsInterface.tagsDictionary = [appDelegate.wsInterface fillEmptyTags:dict];
        }
        
        appDelegate.dataBase.MyPopoverDelegate = nil;
        appDelegate.databaseInterface.MyPopoverDelegate = nil;
        appDelegate.wsInterface.MyPopoverDelegate = nil;
    }
    
    [pool release];
}



- (void) startSyncEvents
{
    NSAutoreleasePool * popl = [[NSAutoreleasePool alloc] init];
    
    if (appDelegate == nil)
        appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    fullDataSyncFailed = FALSE;
    @try {
        
        [delegate dismisspopover];
       
        BOOL retVal;
        
        appDelegate.dataBase.MyPopoverDelegate = delegate;
        appDelegate.databaseInterface.MyPopoverDelegate = delegate;
        appDelegate.wsInterface.MyPopoverDelegate = delegate;
        
        [delegate activityStart];
        if([appDelegate.syncThread isExecuting])
        {
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, NO))
            {
                if (!appDelegate.isInternetConnectionAvailable)
                {
                    break;
                }
                
                if ([appDelegate.syncThread isFinished])
                {
                    [appDelegate.datasync_timer invalidate];
                    break;
                }
            }
        }
        else{
            if (appDelegate.datasync_timer){
                [appDelegate.datasync_timer invalidate];
            }            
        } 
        
        
        if ([appDelegate.metaSyncThread isExecuting])
        {
            
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, NO))
            {
                if (!appDelegate.isInternetConnectionAvailable)
                {
                    break;
                }
                
                if ([appDelegate.metaSyncThread isFinished])
                {
                    [appDelegate.metasync_timer invalidate];
                    break;
                }
            }
        }
        else
        {
            if (appDelegate.metasync_timer)
            {
                [appDelegate.metasync_timer invalidate];
            }            
        }   
        appDelegate.SyncStatus = SYNC_ORANGE;
        
        [appDelegate.wsInterface.refreshSyncButton showSyncStatusButton];
        [appDelegate.wsInterface.refreshModalStatusButton showModalSyncStatus];
        [appDelegate.wsInterface.refreshSyncStatusUIButton showSyncUIStatus];
        
        [appDelegate goOnlineIfRequired];
        
        [appDelegate.databaseInterface cleartable:SYNC_RECORD_HEAP];
        
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
        else 
        {
            NSString * title  = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_status_button1];
            NSString * cancel = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:[NSString stringWithFormat:@"%@", exception.description] delegate:self cancelButtonTitle:cancel otherButtonTitles: nil];
            
            [alert show];
            [alert release];
        }
        appDelegate.SyncStatus = SYNC_GREEN;
        
        [appDelegate.wsInterface.refreshSyncButton showSyncStatusButton];
        [appDelegate.wsInterface.refreshModalStatusButton showModalSyncStatus];
        [appDelegate.wsInterface.refreshSyncStatusUIButton showSyncUIStatus];
    }
    @finally {
        
        [appDelegate ScheduleIncrementalDatasyncTimer];
        [appDelegate ScheduleIncrementalMetaSyncTimer];
        
        appDelegate.dataBase.MyPopoverDelegate = nil;
        appDelegate.databaseInterface.MyPopoverDelegate = nil;
        appDelegate.wsInterface.MyPopoverDelegate = nil;
        
        [delegate activityStop];
        
    }
    if (fullDataSyncFailed == FALSE)
    {
        if ([appDelegate.event_thread isExecuting])
        {
            
        }
        else
        {
        
            NSString * title  = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_status_button1];
            NSString * cancel = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
            
            UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:title message:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_completed] delegate:self cancelButtonTitle:cancel otherButtonTitles: nil];
            
            [alert show];
            [alert release];
        }
        appDelegate.SyncStatus = SYNC_GREEN;
        
        [appDelegate.wsInterface.refreshSyncButton showSyncStatusButton];
        [appDelegate.wsInterface.refreshModalStatusButton showModalSyncStatus];
        [appDelegate.wsInterface.refreshSyncStatusUIButton showSyncUIStatus];
    }
    
    [delegate activityStop];
    
    [popl release];
}

@end


