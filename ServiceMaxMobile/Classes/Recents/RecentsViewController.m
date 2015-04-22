//
//  RecentsViewController.m
//  iService
//
//  Created by Samman on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RecentsViewController.h"
#import "About.h"
#import "Utility.h"

@implementation RecentsViewController

@synthesize array;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction) displayUser:(id)sender
{
    UIButton * button = (UIButton *)sender;
    About * about = [[[About alloc] initWithNibName:@"About" bundle:nil] autorelease];
    UIPopoverController * popover = [[UIPopoverController alloc] initWithContentViewController:about];
    [popover setContentViewController:about animated:YES];
    [popover setPopoverContentSize:about.view.frame.size];
    popover.delegate = self;
    // [[[popover contentViewController] view] setAlpha:0.0f];
    [popover presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (IBAction) back
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Load appDelegate.recentObject from the plist
    [appDelegate.recentObject removeAllObjects];
    
	rootView = [[RecentObjectRoot alloc] initWithNibName:@"RecentObjectRoot" bundle:nil];
    UIImageView * bgImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_left_panel_bg_main_2.png"]] autorelease];
    rootView.tableView.backgroundView = bgImage;
    UINavigationController * master = [[[UINavigationController alloc] initWithRootViewController:rootView] autorelease];
    /*ios7_support shravya-navbar*/
    if (![Utility notIOS7]) {
        UIImage *navImage = [Utility getLeftNavigationBarImage];
        [master.navigationBar setBackgroundImage:navImage forBarMetrics:UIBarMetricsDefault];
        master.extendedLayoutIncludesOpaqueBars = YES;
        master.edgesForExtendedLayout = UIRectEdgeNone;
        
    }
    
    detailView = [[RecentObjectDetail alloc] initWithNibName:@"RecentObjectDetail" bundle:nil];
    detailView.delegate = self;
    UINavigationController * detail = [[[UINavigationController alloc] initWithRootViewController:detailView] autorelease];
    /*ios7_support shravya-navbar*/
    if (![Utility notIOS7]) {
        UIImage *navImage = [Utility getRightNavigationBarImage];
        [detail.navigationBar setBackgroundImage:navImage forBarMetrics:UIBarMetricsDefault];
        detail.extendedLayoutIncludesOpaqueBars = YES;
        detail.edgesForExtendedLayout = UIRectEdgeNone;
    }
    rootView.delegate = detailView;
    
    UISplitViewController * splitView = [[UISplitViewController alloc] init];
    splitView.viewControllers = [NSArray arrayWithObjects:master, detail, nil];
    splitView.delegate = self;

	splitView.view.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:splitView.view];
	splitView.view.frame = self.view.frame;
}

- (void)viewWillAppear:(BOOL)animated
{
    //7418:
    [super viewWillAppear:animated];
    NSMutableArray * recentObjectsArray = [self getRecentsArrayFromObjectHistoryPlist];
	
	rootView.recentObjectsArray = recentObjectsArray;
	detailView.recentObjectsArray = recentObjectsArray;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //6347:
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleIncrementalDataSyncNotification:) name:kIncrementalDataSyncDone object:nil];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //6347:
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kIncrementalDataSyncDone object:nil];
}

- (void)viewDidUnload
{
    [mTable release];
    mTable = nil;
    [activity release];
    activity = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        return YES;
    
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void) showSFMWithProcessId:(NSString *)processId recordId:(NSString *)recordId objectName:(NSString *)objectName
{
    [activity startAnimating];
    appDelegate.sfmPageController = [[SFMPageController alloc] initWithNibName:@"SFMPageController" bundle:nil mode:TRUE];
    
    //Radha 25th feb 
    NSString * _processId =  [appDelegate.switchViewLayouts objectForKey:objectName];
    appDelegate.sfmPageController.processId = (_processId != nil)?_processId:processId;
    
    NSString * activityDate = @"";
    NSDate * date = nil;
    
    id value;
    
    @try{
    for (NSDictionary * recentDict in appDelegate.recentObject)
    {
        NSString * Id = [recentDict objectForKey:@"resultIds"];
        
        if ([Id isEqualToString:recordId])
        {
            value = [recentDict objectForKey:@"todays_date"];
            break;
        }
        
    }
    
   // 10312
    if ([value isKindOfClass:[NSString class]])
    {
        activityDate = value;
        date  = [Utility getDateFromStringFromPlist:activityDate userRedable:YES];;
    }
    else
    {
        date = value;
    }
    
   /* NSDateFormatter * format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"EEE, dd MMM yyyy hh:mm:ss a"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [format setTimeZone:gmt];
    
    NSDate * date = [format dateFromString:activityDate];
    
    [format release];*/
	
	appDelegate.From_SFM_Search = @"";
	
	NSString * sfid = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:objectName local_id:recordId];
	
	BOOL conflict = [appDelegate.dataBase checkIfConflictsExistsForEvent:sfid objectName:objectName local_id:recordId];
	
	if (!conflict)
	{
		conflict = [appDelegate.dataBase checkIfChildConflictexist:objectName sfId:sfid];
	}
    appDelegate.sfmPageController.conflictExists = conflict;
    appDelegate.sfmPageController.activityDate = (NSString *)date;
    appDelegate.sfmPageController.recordId = recordId;
    appDelegate.sfmPageController.objectName = [NSString stringWithFormat:@"%@",objectName];
    
    if ([appDelegate.SFMPage retainCount] > 0)
    {
        appDelegate.SFMPage = nil;
    }
    
    [appDelegate.sfmPageController setModalPresentationStyle:UIModalPresentationFullScreen];
    [appDelegate.sfmPageController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    
    processInfo * pinfo =  [appDelegate getViewProcessForObject:objectName record_id:recordId processId:appDelegate.sfmPageController.processId isswitchProcess:FALSE];
    BOOL process_exists = pinfo.process_exists;
       
    if(process_exists)
    {
        appDelegate.sfmPageController.processId =  pinfo.process_id;
        [appDelegate.sfmPageController.detailView view];
        [self presentViewController:appDelegate.sfmPageController animated:YES completion:^(void){}];
        [appDelegate.sfmPageController.detailView didReceivePageLayoutOffline];
    }
    else
    {
        UIAlertView * enty_criteris = [[UIAlertView alloc] initWithTitle:@"" message:@" Record does Not match  an Entry Criteria" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [enty_criteris show];
        [enty_criteris release];
        return;
    }
	}@catch (NSException *exp)
    {
        SMLog(kLogLevelError,@"Exception Name RecentsViewController :showSFMWithProcessId %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason RecentsViewController :showSFMWithProcessId %@",exp.reason);
    }

    [activity stopAnimating];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
	
	if (appDelegate.recentObject != nil && [appDelegate.recentObject count] > 0)
		count = [appDelegate.recentObject count];
	
    @try{
    for (int i = 0; i < [appDelegate.recentObject count]; i++)
    {
        BOOL shouldShowObject = NO;
        NSDictionary * recentObjectDict = [appDelegate.recentObject objectAtIndex:i];
        NSString * objectName = [recentObjectDict objectForKey:OBJECT_NAME];
        for (int j = 0; j < [appDelegate.wsInterface.viewLayoutsArray count]; j++)
        {
            NSDictionary * viewLayoutDict = [appDelegate.wsInterface.viewLayoutsArray objectAtIndex:j];
            NSString * objName = [viewLayoutDict objectForKey:VIEW_OBJECTNAME];
            if ([objName isEqualToString:objectName])
            {
                shouldShowObject = YES;
                break;
            }
        }
        if (!shouldShowObject)
            count--;
    }
	}@catch (NSException *exp)
    {
        SMLog(kLogLevelError,@"Exception Name RecentViewController :numberOfRowsInSection %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason RecentViewController :numberOfRowsInSection %@",exp.reason);
    }

    return count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"cellIdentifier";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
    }

    NSDictionary * dict = nil;
	@try{
    for (int i = 0; i < [appDelegate.recentObject count]; i++)
    {
        BOOL shouldShowObject = NO;
        NSDictionary * recentObjectDict = [appDelegate.recentObject objectAtIndex:i];
        NSString * objectName = [recentObjectDict objectForKey:OBJECT_NAME];
        for (int j = 0; j < [appDelegate.wsInterface.viewLayoutsArray count]; j++)
        {
            NSDictionary * viewLayoutDict = [appDelegate.wsInterface.viewLayoutsArray objectAtIndex:j];
            NSString * objName = [viewLayoutDict objectForKey:VIEW_OBJECTNAME];
            if ([objName isEqualToString:objectName])
            {
                shouldShowObject = YES;
                //sahana
                dict = [appDelegate.recentObject objectAtIndex:[appDelegate.recentObject count]-1-indexPath.row];
                break;
            }
        }

        if (shouldShowObject)
            break;
    }
    [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    if([dict count] > 5 )
    {
        NSString * date = [dict objectForKey:gDATE_TODAY];
         cell.textLabel.text = [NSString stringWithFormat:@"%@ %@  %@", [dict objectForKey:OBJECT_LABEL], [dict objectForKey:NAME_FIELD],date];
        return cell;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [dict objectForKey:OBJECT_LABEL], [dict objectForKey:NAME_FIELD]];
   }@catch (NSException *exp)
    {
        SMLog(kLogLevelError,@"Exception Name RecentsViewController :cellForRowAtIndexPath %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason RecentsViewController :cellForRowAtIndexPath %@",exp.reason);
    }

    return cell;
}

- (void) dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

#pragma mark - UITableViewDelegate Methods
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	@try{
    NSDictionary * dict = [appDelegate.recentObject objectAtIndex:indexPath.row];    
    
    [self showSFMWithProcessId:[dict objectForKey:PROCESSID] recordId:[dict objectForKey:RESULTID]];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	}@catch (NSException *exp)
    {
        SMLog(kLogLevelError,@"Exception Name RecentsViewController :didSelectRowAtIndexPath %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason RecentsViewController :didSelectRowAtIndexPath %@",exp.reason);
    }

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	@try{
    NSDictionary * dict = [appDelegate.recentObject objectAtIndex:indexPath.row];    
    
    [self showSFMWithProcessId:[dict objectForKey:PROCESSID] recordId:[dict objectForKey:RESULTID]];
	}@catch (NSException *exp)
    {
        SMLog(kLogLevelError,@"Exception Name RecentsViewController :accessoryButtonTappedForRowWithIndexPath %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason RecentsViewController :accessoryButtonTappedForRowWithIndexPath %@",exp.reason);
    }

}
#pragma mark - Refresh
- (NSMutableArray *) getRecentsArrayFromObjectHistoryPlist
{
	// Load appDelegate.recentObject from the plist
	//8418 
	if (appDelegate.recentObject != nil && [appDelegate.recentObject count] > 0)
		[appDelegate.recentObject removeAllObjects];
    
    NSString *rootPath = [appDelegate getAppCustomSubDirectory]; // [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:OBJECT_HISTORY_PLIST];
    appDelegate.recentObject = [NSArray arrayWithContentsOfFile:plistPath];
	
	NSMutableArray * recentObjectsArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSMutableArray * countArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    @try
	{
		for (int rec = 0; rec < [appDelegate.recentObject count]; rec++)
		{
			NSDictionary * recentDict = [appDelegate.recentObject objectAtIndex:rec];
			
			NSString * object = [recentDict objectForKey:@"OBJECT_NAME"];
			NSString * recordID = [recentDict objectForKey:@"resultIds"];
			
			BOOL result = [appDelegate.dataBase checkIfRecordExistForObjectWithRecordId:object Id:recordID];
			
			if (result == FALSE)
			{
				[countArray addObject:[NSString stringWithFormat:@"%d", rec]];
			}
		}
		
		//Remove deleted record from recentObject
		NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
		for (int del = 0; del < [countArray count]; del++)
		{
			int value = [[countArray objectAtIndex:del] intValue];
			[indexSet addIndex:value];
			//        [appDelegate.recentObject removeObjectAtIndex:value];
		}
		[appDelegate.recentObject removeObjectsAtIndexes:indexSet];
		
	
		for (int i = 0; i < [appDelegate.recentObject count]; i++)
		{
			NSDictionary * dict = [appDelegate.recentObject objectAtIndex:i];
			NSString * recentObjectLabel = [dict objectForKey:OBJECT_LABEL];
			
			// run a loop thru the recentObjectsArray
			// find out key of dictionary for each loop
			// check if any key == recentObject
			// if yes then add object_name
			// if no key == recentObject then
			// add key + object_name to dictionary
			// add dictionary to recentObjectsArray
			
			BOOL flag = NO;
			
			for (int j = 0; j < [recentObjectsArray count]; j++)
			{
				NSMutableDictionary * recentObjectDictionary = [recentObjectsArray objectAtIndex:j];
				NSString * key = [[recentObjectDictionary allKeys] objectAtIndex:0];
				
				if ([key isEqualToString:recentObjectLabel])
				{
					// NSMutableArray * objectArray = [dict objectForKey:key];
					NSMutableArray * objectArray = [recentObjectDictionary objectForKey:key];
					[objectArray addObject:dict];
					flag = YES;
				}
			}
			
			if (!flag)
			{
				NSMutableDictionary * newDictionary = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
				NSMutableArray * newArray = [[[NSMutableArray alloc] initWithObjects:dict, nil] autorelease];
				[newDictionary setObject:newArray forKey:recentObjectLabel];
				[recentObjectsArray addObject:newDictionary];
			}
		}
		
		// Sort recentObjectsArray before displaying
		//Abinash Fixed
		for (int i = 0; i < [recentObjectsArray count]; i++)
		{
			NSDictionary * dict1 = [recentObjectsArray objectAtIndex:i];
			NSString * key1 = [[dict1 allKeys] objectAtIndex:0];
			for (int j = i + 1; j < [recentObjectsArray count]; j++)
			{
				NSDictionary * dict2 = [recentObjectsArray objectAtIndex:j];
				NSString * key2 = [[dict2 allKeys] objectAtIndex:0];
				
				int result = strcmp([key1 UTF8String], [key2 UTF8String]);
				
				if (result > 0 )
				{
					// perform swap
					[recentObjectsArray exchangeObjectAtIndex:i withObjectAtIndex:j];
					key1 = key2;
				}
			}
		}
	}
	@catch (NSException *exp)
    {
        SMLog(kLogLevelError,@"Exception Name RecentViewController :getRecentsArrayFromObjectHistoryPlist %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason RecentViewController :getRecentsArrayFromObjectHistoryPlist %@",exp.reason);
    }
	return recentObjectsArray;
}


#pragma mark - SplitViewController Delegate

// Called when a button should be added to a toolbar for a hidden view controller
- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc
{
    
}

// Called when the view is shown again in the split view, invalidating the button and popover controller
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    
}

// Called when the view controller is shown in a popover so the delegate can take action like hiding other popovers.
- (void)splitViewController: (UISplitViewController*)svc popoverController: (UIPopoverController*)pc willPresentViewController:(UIViewController *)aViewController
{
    
}

// Returns YES if a view controller should be hidden by the split view controller in a given orientation.
// (This method is only called on the leftmost view controller and only discriminates portrait from landscape.)
- (BOOL)splitViewController: (UISplitViewController*)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}


#pragma mark -
#pragma mark Incremental Data Sync Notification Handler
//6347:
- (void) handleIncrementalDataSyncNotification:(NSNotification *)notification
{
	//8418 
    [self performSelectorOnMainThread:@selector(refreshRecents) withObject:nil waitUntilDone:YES];
}
	
//6347:
- (void) refreshRecents
{
    NSMutableArray * recentObjectsArray = [self getRecentsArrayFromObjectHistoryPlist];
	
	rootView.recentObjectsArray = recentObjectsArray;
	detailView.recentObjectsArray = recentObjectsArray;
	[detailView.tableView reloadData];

}

@end