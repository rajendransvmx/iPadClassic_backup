//
//  SFMPageController.m
//  iService
//
//  Created by Developer on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SFMPageController.h"
#import "iServiceAppDelegate.h"
extern void SVMXLog(NSString *format, ...);
@implementation SFMPageController
@synthesize sourceProcessId,sourceRecordId;
@synthesize delegate, rootView, detailView;
@synthesize processId, recordId, objectName, activityDate, accountId, topLevelId;

@synthesize conflictExists;
@synthesize progressView;
@synthesize progressTitle;
@synthesize display_percentage;
@synthesize download_desc_label;
@synthesize description_label;
@synthesize ProgressBar;
@synthesize ProgressBarViewController;
@synthesize titleBackground;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mode:(BOOL)viewMode
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _viewMode = viewMode;
        // Custom initialization
        rootView = [[[RootViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_left_panel_bg_main_2.png"]];
        rootView.tableView.backgroundView = bgImage;
        [bgImage release];
        masterView = [[[UINavigationController alloc] initWithRootViewController:rootView] autorelease];
        
        detailView = [[[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil] autorelease];
        detailView.delegate = self;
        detailView.isInViewMode = viewMode;
        
        detailViewController = [[[UINavigationController alloc] initWithRootViewController:detailView] autorelease];
        
        splitView = [[UISplitViewController alloc] init];
        splitView.viewControllers = [NSArray arrayWithObjects:masterView, detailViewController, nil];
        splitView.view.frame = self.view.frame;
        splitView.delegate = detailView;

		splitView.view.autoresizingMask = UIViewAutoresizingNone;
        [self.view addSubview:splitView.view];
		splitView.view.frame = self.view.frame;
        
        barButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:detailView action:@selector(splitViewController:popoverController:willPresentViewController:)];
        
//        popover = [[UIPopoverController alloc] initWithContentViewController:rootView];
    }
    return self;
}

- (void) setObjectName:(NSString *)_objectName
{
    if( objectName != nil )
    {
        [objectName release];
    }
    objectName = [_objectName copy];
    detailView.objectAPIName = _objectName;
}

- (void)dealloc
{
    [objectName release];
    [splitView release];
    [popover release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.didSFMUnload = YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.didSFMUnload)
    {
        appDelegate.didSFMUnload = NO;
        
        // Custom initialization
        rootView = [[[RootViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_left_panel_bg_main_2.png"]];
        rootView.tableView.backgroundView = bgImage;
        [bgImage release];
        masterView = [[[UINavigationController alloc] initWithRootViewController:rootView] autorelease];
        
        detailView = [[[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil] autorelease];
        detailView.delegate = self;
        detailView.isInViewMode = _viewMode;
        
        detailViewController = [[[UINavigationController alloc] initWithRootViewController:detailView] autorelease];
        
        splitView = [[UISplitViewController alloc] init];
        splitView.view.frame = self.view.frame;
        splitView.delegate = detailView;
        splitView.viewControllers = [NSArray arrayWithObjects:masterView, detailViewController, nil];

        splitView.view.autoresizingMask = UIViewAutoresizingNone;
        [self.view addSubview:splitView.view];
		splitView.view.frame = self.view.frame;
        
        barButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:detailView action:@selector(splitViewController:popoverController:willPresentViewController:)];
        
//        popover = [[UIPopoverController alloc] initWithContentViewController:rootView];
    }

    self.recordId = appDelegate.sfmPageController.recordId;
    detailView.currentProcessId = self.processId;
    detailView.currentRecordId = self.recordId;
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated
{

}

- (void) viewDidAppear:(BOOL)animated
{
    
}

- (void)viewDidUnload
{
    [barButton release];
    barButton = nil;
    [popover release];
    popover = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
    {
        // Do something
        detailView.view.frame = self.view.frame;
        [detailView splitViewController:splitView willHideViewController:masterView withBarButtonItem:barButton forPopoverController:popover];
    }
    
    if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
    {
        // Do something
        [detailView splitViewController:splitView willShowViewController:masterView invalidatingBarButtonItem:barButton];
    }
	return YES;
}

#pragma mark - DetailViewController Delegate Method
- (void) Back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
	[delegate Back:nil];
}
-(void) BackOnSave
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
    [delegate Back:nil];
}
#pragma progress bar
-(void)presentProgressBar:(NSString *)object_name sf_id:(NSString *)sf_id  reocrd_name:(NSString *)record_name
{
    [detailView disableSFMUI];
    if (![appDelegate isInternetConnectionAvailable])
    {
        
        return;
    }
    
    [appDelegate invalidateAllTimers];
    
    Total_calls = 3;
    appDelegate.connection_error = FALSE;
    ProgressBarViewController.layer.cornerRadius = 5;
    ProgressBarViewController.frame = CGRectMake(300,100, 474, 200);
    [self.view addSubview:ProgressBarViewController];
    
    description_label.numberOfLines = 3;
    description_label.font =  [UIFont systemFontOfSize:14.0];
    description_label.textAlignment = UITextAlignmentCenter;
    
    download_desc_label.font =  [UIFont systemFontOfSize:16.0];
    download_desc_label.textAlignment = UITextAlignmentCenter;
    NSString * download_string =[NSString stringWithFormat:@" %@ %@ ",[appDelegate.wsInterface.tagsDictionary objectForKey:Downloading],record_name];
    download_desc_label.text = download_string;
    ProgressBarViewController.backgroundColor = [appDelegate colorForHex:@"E0FFFF"];;//[UIColor clearColor];
    ProgressBarViewController.layer.borderColor = [UIColor blackColor].CGColor;
    ProgressBarViewController.layer.borderWidth = 1.0f;
    [ProgressBarViewController bringSubviewToFront:ProgressBar];
    [ProgressBarViewController bringSubviewToFront:progressTitle];
    self.progressTitle.text =  [appDelegate.wsInterface.tagsDictionary objectForKey:Data_On_Demand];//@"Data On Demand (DOD): Preparing for DOD download";
    progressTitle.backgroundColor = [UIColor clearColor];
    progressTitle.layer.cornerRadius = 8;
    titleBackground.layer.cornerRadius=5;
    ProgressBar.progress = 0.0;
    temp_percentage = 0;
    total_progress = 0.0;
    display_percentage.text = @"0%";
    
    if(initial_sync_timer == nil)
        initial_sync_timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
    
    BOOL flag = [appDelegate goOnlineIfRequired];
    if ([appDelegate.currentServerUrl Contains:@"null"] || [appDelegate.currentServerUrl length] == 0 || appDelegate.currentServerUrl == nil)
    {
        NSUserDefaults * userdefaults = [NSUserDefaults standardUserDefaults];
        
        appDelegate.currentServerUrl = [userdefaults objectForKey:SERVERURL];
    }

    if(flag)
    {
        appDelegate.dod_req_response_ststus = DOD_REQUEST_SENT;
        appDelegate.Sync_check_in = FALSE;
        appDelegate.dod_status = CONNECTING_TO_SALESFORCE;
        [appDelegate.wsInterface getOnDemandRecords:object_name record_id:sf_id];
        
        while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO)) 
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"SFMPageController.m : presentProgressBar: DOD");
#endif

            if( appDelegate.dod_req_response_ststus == DOD_RESPONSE_RECIEVED || appDelegate.connection_error || ![appDelegate isInternetConnectionAvailable])
            {
                break;
            }
        }
    }
    
    [initial_sync_timer invalidate];
    initial_sync_timer = nil;
    [ProgressBarViewController removeFromSuperview];
    
    
    [appDelegate ScheduleIncrementalDatasyncTimer];
    [appDelegate ScheduleIncrementalMetaSyncTimer];
    [appDelegate ScheduleTimerForEventSync];
    [appDelegate scheduleLocationPingTimer];
    
}
const int percentage_SFM = 30;
const float progress_SFM = 0.33;
#pragma mark - timer method to update progressbar
-(void)updateProgressBar:(id)sender
{
    
    if(appDelegate.dod_status == CONNECTING_TO_SALESFORCE && appDelegate.Sync_check_in == FALSE)
    {
        temp_percentage = percentage_SFM;
        appDelegate.Sync_check_in = TRUE;
        total_progress =  progress_SFM ; 
        ProgressBar.progress = 0.33;
        // download_desc_label.text = @"";//
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:CONNECTING_TO_SALESFORCE_TAG];//@"Connecting to Salesforce...";
    }
    else if(appDelegate.dod_status == RETRIEVING_DATA  && appDelegate.Sync_check_in == FALSE)
    {
        temp_percentage = percentage_SFM * 2  ;
        appDelegate.Sync_check_in = TRUE;
        total_progress =  progress_SFM * 2;  
        ProgressBar.progress = 0.66 ;
        //download_desc_label.text = @"";
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:Retrieving_Data];//@"Retrieving data from Salesforce...";
    }
    else if(appDelegate.dod_status == SAVING_DATA  && appDelegate.Sync_check_in == FALSE)
    {
        temp_percentage = percentage_SFM *3 + 10 ; 
        appDelegate.Sync_check_in = TRUE;
        total_progress = 1.0;
        ProgressBar.progress = total_progress ;
        //download_desc_label.text = @"";
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:Saving_Data_offline]; //@"Saving data for offline use....";
    }
    
    [self fillNumberOfStepsCompletedLabel];
}

-(void)fillNumberOfStepsCompletedLabel
{
    
    NSString * _percentagetext = [[NSString alloc] initWithFormat:@"%d%%", temp_percentage];
    display_percentage.text = _percentagetext;
    [_percentagetext release];
}

@end
