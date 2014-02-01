//
//  SFMResultMainViewController.m
//  SFMSearch
//
//  Created by Siva Manne on 11/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import "SFMResultMainViewController.h"
#import "SFMResultDetailViewController.h"
#import "SFMResultMasterViewController.h"
#import "Utility.h"
#import "SMXMonitor.h"

void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);
@interface SFMResultMainViewController ()

@end

@implementation SFMResultMainViewController
@synthesize progressView;
@synthesize progressTitle;
@synthesize display_percentage;
@synthesize download_desc_label;
@synthesize description_label;
@synthesize ProgressBar;
@synthesize ProgressBarViewController;
@synthesize titleBackground;
@synthesize filterString,sfmConfiguration,processId;
@synthesize resultmasterView;
@synthesize resultdetailView;
@synthesize masterTableData;
@synthesize searchCriteriaString;
@synthesize searchCriteriaLimitString;
@synthesize masterTableHeader;
@synthesize switchStatus;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        resultmasterView = [[SFMResultMasterViewController alloc] 
                      initWithNibName:@"SFMResultMasterViewController" bundle:nil];
        resultdetailView = [[SFMResultDetailViewController alloc] 
                      initWithNibName:@"SFMResultDetailViewController" bundle:nil];
        resultmasterView.resultDetailView = resultdetailView;

    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // Do any additional setup after loading the view from its nib.
    UINavigationController * masterNav = [[[UINavigationController alloc] initWithRootViewController:resultmasterView] autorelease];
    
    resultdetailView.splitViewDelegate = self;
    UINavigationController * detailNav = [[[UINavigationController alloc] initWithRootViewController:resultdetailView] autorelease];
  
    resultdetailView.masterView = resultmasterView;
    resultdetailView.mainView = self;
    
    /*ios7_support shravya-navbar*/
    if (![Utility notIOS7]) {
        UIImage *navImage = [Utility getLeftNavigationBarImage];
        [masterNav.navigationBar setBackgroundImage:navImage forBarMetrics:UIBarMetricsDefault];
        resultmasterView.extendedLayoutIncludesOpaqueBars = YES;
        resultmasterView.edgesForExtendedLayout = UIRectEdgeNone;
        
        
    }
    /*ios7_support shravya-navbar*/
    if (![Utility notIOS7]) {
        UIImage *navImage = [Utility getRightNavigationBarImage];
        [detailNav.navigationBar setBackgroundImage:navImage forBarMetrics:UIBarMetricsDefault];
        resultdetailView.extendedLayoutIncludesOpaqueBars = YES;
        resultdetailView.edgesForExtendedLayout = UIRectEdgeNone;
        
    }
    

    UISplitViewController * splitView = [[UISplitViewController alloc] init];
    splitView.viewControllers = [NSArray arrayWithObjects:masterNav, detailNav, nil];
    splitView.delegate = self;
    
    splitView.view.autoresizingMask = UIViewAutoresizingNone;
	[self.view addSubview:splitView.view];
	splitView.view.frame = self.view.frame;
	
    [resultmasterView setSearchData:filterString];
    [resultmasterView setSearchCriteriaString:searchCriteriaString];
    [resultmasterView setSearchCriteriaLimitString:searchCriteriaLimitString];
    [resultmasterView setTableHeader:masterTableHeader];
    [resultmasterView setTableArray:masterTableData];
    [resultmasterView setProcessId:processId];
    //resultmasterView.searchFilterSwitch.on = switchStatus;
    [resultmasterView setSwitchStatus:switchStatus];

    [resultdetailView setSfmConfigName:masterTableHeader];
    
    /*ios view getting truncated */
    if (![Utility notIOS7]) {
        
         CGRect someFrame =  splitView.view.frame;
         someFrame.size.height = someFrame.size.height + 20;
         splitView.view.frame = someFrame;
    }
   

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [resultmasterView reloadTableData];
}

- (void)viewDidUnload
{
    [self setProgressBarViewController:nil];
    [self setProgressBar:nil];
    [self setDescription_label:nil];
    [self setDownload_desc_label:nil];
    [self setDisplay_percentage:nil];
    [self setProgressTitle:nil];
    [self setProgressView:nil];
    [self setTitleBackground:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return YES;
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}
- (void) dealloc
{
    [searchCriteriaLimitString release];
    [searchCriteriaString release];
    [masterTableData release];
    [masterTableHeader release];
    [resultmasterView release];
    [resultdetailView release];
    [filterString release];
    [sfmConfiguration release];
    [ProgressBarViewController release];
    [ProgressBar release];
    [description_label release];
    [download_desc_label release];
    [display_percentage release];
    [progressTitle release];
    [progressView release];
    [titleBackground release];
    [super dealloc];
}

#pragma mark - SFMResultDetailViewController Delegate
- (void) DismissSplitViewController
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}
//  Unused Methods
//-(void)dismissProgressBar
//{
//    
//}
-(void)presentProgressBar:(NSString *)object_name sf_id:(NSString *)sf_id  reocrd_name:(NSString *)record_name
{

    if (![appDelegate isInternetConnectionAvailable])
    {
            /* Bug fixed 5606 */
            appDelegate.shouldShowConnectivityStatus = TRUE;
            [appDelegate displayNoInternetAvailable];
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
    NSString * download_string = [NSString stringWithFormat:@" %@ %@ ",[appDelegate.wsInterface.tagsDictionary objectForKey:Downloading],record_name];
    download_desc_label.text = download_string;
    ProgressBarViewController.backgroundColor = [UIColor clearColor];
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
    //total_progress = 0.0;
    display_percentage.text = @"0%";
    
    if(initial_sync_timer == nil)
        initial_sync_timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgressBar:) userInfo:nil repeats:YES];
  
	//OAuth.
    BOOL flag = [[ZKServerSwitchboard switchboard] doCheckSession];
    
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
        SMXMonitor *monitor = [[[SMXMonitor alloc] init] autorelease];
        [monitor monitorSMMessageWithName:@"[SFMResultMainViewController presentProgress]"
                             withUserName:appDelegate.currentUserName
                                 logLevel:kPerformanceLevelWarning
                               logContext:@"Start"
                             timeInterval:kWSExecutionDuration];
        while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, NO)) 
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(kLogLevelVerbose,@"SFMResultMainViewController.m : presentProgressBar: DOD");
#endif

            if( appDelegate.dod_req_response_ststus == DOD_RESPONSE_RECIEVED || appDelegate.connection_error)
            {
                break;
            }
            
            if(![appDelegate isInternetConnectionAvailable]) {
                /* DOD Request fails , then show the message Defect num:005606*/
                appDelegate.shouldShowConnectivityStatus = TRUE;
                [appDelegate displayNoInternetAvailable];
                break;
            }
        }
        [monitor monitorSMMessageWithName:@"[SFMResultMainViewController presentProgress]"
                             withUserName:appDelegate.currentUserName
                                 logLevel:kPerformanceLevelWarning
                               logContext:@"Stop"
                             timeInterval:kWSExecutionDuration];
    }
    else {
        /* Bug fixed 5606 */
         appDelegate.shouldShowConnectivityStatus = TRUE;
        [appDelegate displayNoInternetAvailable];
    }
    
    [initial_sync_timer invalidate];
    initial_sync_timer = nil;
    [ProgressBarViewController removeFromSuperview];
    
    [appDelegate ScheduleIncrementalDatasyncTimer];
    [appDelegate ScheduleIncrementalMetaSyncTimer];
    [appDelegate ScheduleTimerForEventSync];
    [appDelegate scheduleLocationPingTimer];
	
	//Radha Defect Fix 5542
	[appDelegate updateNextDataSyncTimeToBeDisplayed:[NSDate date]];

    
}
const int percentage_SFMSearch = 30;
const float progress_SFMSearch = 0.33;
#pragma mark - timer method to update progressbar
-(void)updateProgressBar:(id)sender
{
   
    if(appDelegate.dod_status == CONNECTING_TO_SALESFORCE && appDelegate.Sync_check_in == FALSE)
    {
        temp_percentage = percentage_SFMSearch;
        appDelegate.Sync_check_in = TRUE;
        total_progress =  progress_SFMSearch ; 
        ProgressBar.progress = 0.33;
       // download_desc_label.text = @"";//
        description_label.text =[appDelegate.wsInterface.tagsDictionary objectForKey:CONNECTING_TO_SALESFORCE_TAG];// @"Connecting to Salesforce...";
    }
    else if(appDelegate.dod_status == RETRIEVING_DATA  && appDelegate.Sync_check_in == FALSE)
    {
        temp_percentage = percentage_SFMSearch * 2  ;
        appDelegate.Sync_check_in = TRUE;
        total_progress =  progress_SFMSearch * 2;  
        ProgressBar.progress = 0.66 ;
        //download_desc_label.text = @"";
        description_label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:Retrieving_Data];//@"Retrieving data from Salesforce...";
    }
    else if(appDelegate.dod_status == SAVING_DATA  && appDelegate.Sync_check_in == FALSE)
    {
        temp_percentage = percentage_SFMSearch *3 + 10 ; 
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

// Returns YES if a view controller should be hidden by the split view controller in a given orientation.
// (This method is only called on the leftmost view controller and only discriminates portrait from landscape.)
- (BOOL)splitViewController: (UISplitViewController*)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

@end
