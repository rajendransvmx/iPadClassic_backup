//
//  PopoverButtons.m
//  ManualDataSyncUI
//
//  Created by Parashuram on 12/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PopoverButtons.h"
#import "ManualDataSyncDetail.h"


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
 //   button1.enabled = NO;
    
        
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgImage];
    
    [self.view addSubview:button];
    [self.view addSubview:button1];
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
    [button release]; 
    [button1 release];
}

- (void) Syncronise
{
    
    [delegate dismisspopover];
    appDelegate = (iServiceAppDelegate *) [[UIApplication sharedApplication] delegate];
    if(appDelegate.SyncStatus != SYNC_RED)
    {
        [detail.activity stopAnimating];
        return;
    
    }
    
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
        }
    }
    else
    {
        if (appDelegate.datasync_timer)
        {
           
        }
        
    }    
    [appDelegate callSpecialIncrementalSync];
}

- (void) synchronizeConfiguration
{
    syncConfigurationFailed = FALSE;

    
    @try {
        
        [delegate dismisspopover];

        
        if (appDelegate.SyncStatus == SYNC_RED)
            return;
        
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
            if (appDelegate.didincrementalmetasyncdone == TRUE)
                break; 
        }

    }
    @catch (NSException * exception) {
        exception = [NSException exceptionWithName:@"Error" reason:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_failed_try_again] userInfo: nil];
        syncConfigurationFailed = TRUE;
        [appDelegate.dataBase copyTempsqlToSfm];
        
        NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_status_button1];
        NSString * cancel = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];

        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:[NSString stringWithFormat:@"%@",exception.description] delegate:self cancelButtonTitle:cancel otherButtonTitles: nil];
        [alert show];
        [alert release];
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
        
        appDelegate.dataBase.MyPopoverDelegate = nil;
        appDelegate.databaseInterface.MyPopoverDelegate = nil;
        appDelegate.wsInterface.MyPopoverDelegate = nil;
        [delegate activityStop];
    }
    
    if (syncConfigurationFailed == FALSE)
    {
        NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_status_button1];
        NSString * cancel = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
        
        UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:title message:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_completed] delegate:self cancelButtonTitle:cancel otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    else
    {
        
    }
    [detail.activity stopAnimating];
    
}

@end
