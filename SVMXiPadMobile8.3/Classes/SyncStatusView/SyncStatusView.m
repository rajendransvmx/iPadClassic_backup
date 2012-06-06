//
//  SyncStatusView.m
//  iService
//
//  Created by Parashuram on 19/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncStatusView.h"
#import "iServiceAppDelegate.h"

@implementation SyncStatusView

@synthesize lastSyncTime;
@synthesize nextSyncTime;
@synthesize syncStatus;
@synthesize popOver;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

# pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.wsInterface.updateSyncStatus = self;
    popOverButtons.refreshMetaSyncDelegate = self;

    UIView * view = nil;
    
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_right_panel_bg_main.png"]];
    
    [self.view addSubview:bgImage];
    [bgImage release];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss a"];
    [formatter1 setTimeZone:[NSTimeZone defaultTimeZone]];
    //[formatter1 setTimeStyle:NSDateFormatterMediumStyle];
    //[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    //Read from the plist
    NSArray  * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsPath = [paths objectAtIndex:0];
    
    NSString * fooPath = [documentsPath stringByAppendingPathComponent:@"SYNC_HISTORY.plist"];
    NSDictionary * dictionary = [[NSDictionary alloc] initWithContentsOfFile:fooPath];
    NSLog(@"%@", dictionary);
    
    lastSyncTime = @"";
    lastSyncTime = [dictionary objectForKey:@"last_initial_sync_time"];
    
    NSDate * _gmtDate = [formatter dateFromString:lastSyncTime];
    
    lastSyncTime = [formatter1 stringFromDate:_gmtDate];
    
    NSLog(@"%@", lastSyncTime);;
    
    NSString * str1 = nil;
    NSString * str2 = nil;
    NSString * str3 = nil;
    if ( [lastSyncTime length] > 17)
        str1 = [lastSyncTime substringFromIndex:17];
    if ( [str1 length] > 2)
        str2 = [str1 substringToIndex:2];
    
    int i;
    i = [str2 intValue];
    if (i > 12)
    {
        i = i - 12;
    }
    str3 = [NSString stringWithFormat:@"%d", i];
    NSLog(@"%@", str3);
    NSRange range = NSMakeRange(17,2);
    NSLog(@"%@", [lastSyncTime stringByReplacingCharactersInRange:range withString:str3]);
    lastSyncTime = [lastSyncTime stringByReplacingCharactersInRange:range withString:str3];
    
    //Header Label 1
    UILabel * _label1 = [[UILabel alloc] init];
    _label1.frame = CGRectMake(10, 6, 580, 30);
    _label1.backgroundColor = [UIColor clearColor];
    _label1.textColor = [appDelegate colorForHex:@"2d5d83"];
    _label1.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_data_synchronization];
    _label1.font = [UIFont boldSystemFontOfSize:16];
    
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 31)];
    UIImageView * imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_section_header_bg.png"]];
    imageView1.frame = CGRectMake(10, 0, 580, 31);
    [view addSubview:imageView1];
    [view addSubview:_label1];
    [self.view addSubview:view]; 
    
    [imageView1 release];
    [_label1 release];
    
    //Header Label 2
    UILabel * label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, 84, 580, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [appDelegate colorForHex:@"2d5d83"];
    label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_configuration];
    label.font = [UIFont boldSystemFontOfSize:16];
    
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 84, 300, 31)];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_section_header_bg.png"]];
    imageView.frame = CGRectMake(10, 84, 580, 31);
    [view addSubview:imageView];
    [view addSubview:label];
    [self.view addSubview:view]; 
    
    [imageView release];
    [label release];
    
    
    //Set1
    UILabel * label1;
    label1 = [[UILabel alloc] initWithFrame:CGRectMake(35, 32, 550, 45)];
    label1.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_last_time];
    UIImageView * bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wou-row1-textfield-bg.png"]];
    bgView.frame = CGRectMake(0, 0, 550, 45);
    label1.backgroundColor = [UIColor clearColor];
    [label1 addSubview:bgView];
    [self.view addSubview:label1];
    
    lastSync = [[UILabel alloc] initWithFrame:CGRectMake(300, 28, 450, 45)];
    [lastSync setBackgroundColor:[UIColor clearColor]];
    lastSync.text = lastSyncTime;
    [self.view addSubview:lastSync];
    
    [lastSync release];
    [label1 release];
    
    UILabel *label2;
    label2 = [[UILabel alloc] initWithFrame:CGRectMake(35, 75, 550, 45)];
    UIImageView * bgView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wou-row1-textfield-bg.png"]];
    bgView1.frame = CGRectMake(0, 0, 550, 45);
    label2.backgroundColor = [UIColor clearColor];
    label2.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_next_time];
    [label2 addSubview:bgView1];
    [self.view addSubview:label2];
    
    
    NSDateFormatter * format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *str = [dictionary objectForKey:@"last_initial_sync_time"];
    NSDate * gmtDate = [format dateFromString:str];
    [format release];
    
    NSDateFormatter * formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss a"];
    
    
    NSString * timerValue = ([appDelegate.settingsDict objectForKey:@"Frequency of Master Data"]) != nil?[appDelegate.settingsDict objectForKey:@"Frequency of Master Data"]:@"";
    
    NSTimeInterval scheduledTimer = 0;
    
    if (![timerValue isEqualToString:@""])  
    {
        double timeInterval = [timerValue doubleValue];
        
        scheduledTimer = timeInterval * 60;
    }
    else
        scheduledTimer = 600;

    
    
    NSDate *dateTwoMinsAhead = [gmtDate dateByAddingTimeInterval:scheduledTimer];
    nextSyncTime = @"";
    nextSyncTime = [formatter2 stringFromDate:dateTwoMinsAhead];
    [formatter2 release];
    
    NSString * _str1 = nil;
    NSString * _str2 = nil;
    NSString * _str3 = nil;
    if ( [nextSyncTime length] > 17)
        _str1 = [nextSyncTime substringFromIndex:17];
    if ( [_str1 length] > 2)
        _str2 = [_str1 substringToIndex:2];
    
    int j;
    j = [_str2 intValue];
    if (j > 12)
    {
        j = j - 12;
    }
    _str3 = [NSString stringWithFormat:@"%d", j];
    NSLog(@"%@", _str3);
    NSRange _range = NSMakeRange(17,2);
    NSLog(@"%@", [lastSyncTime stringByReplacingCharactersInRange:_range withString:_str3]);
    nextSyncTime = [nextSyncTime stringByReplacingCharactersInRange:_range withString:_str3];
    
    nextSync = [[UILabel alloc] initWithFrame:CGRectMake(300, 76, 450, 45)];
    [nextSync setBackgroundColor:[UIColor clearColor]];
    nextSync.text = nextSyncTime;
    [self.view addSubview:nextSync];
    
    [label2 release];
    [nextSync release];
    [formatter release];
    
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(35, 120, 550, 45)];
    UIImageView * bgView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wou-row1-textfield-bg.png"]];
    bgView3.frame = CGRectMake(0, 0, 550, 45);
    label3.backgroundColor = [UIColor clearColor];
    label3.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_last_status];
    [label3 addSubview:bgView3];
    [self.view addSubview:label3];
    
    _status = [[UILabel alloc] initWithFrame:CGRectMake(300, 124, 450, 45)];
    _status.backgroundColor = [UIColor clearColor];
    _status.text = [self getSyncronisationStatus];
    [self.view addSubview:_status];
    
    [label3 release];
    
    //Set 2
    UILabel *label4;
    label4 = [[UILabel alloc] initWithFrame:CGRectMake(35, 196, 550, 45)];
    UIImageView * bgView4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wou-row1-textfield-bg.png"]];
    bgView4.frame = CGRectMake(0, 0, 550, 45);
    label4.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_last_time];
    label4.backgroundColor = [UIColor clearColor];
    [label4 addSubview:bgView4];
    [self.view addSubview:label4];
    
    /*################################## Time Stamp For Meta Sync ################################*/
    
    NSDateFormatter * formatter3 = [[NSDateFormatter alloc] init];
    NSDateFormatter * formatter4 = [[NSDateFormatter alloc] init];
    
    [formatter4 setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss a"];
    [formatter4 setTimeZone:[NSTimeZone defaultTimeZone]];

    [formatter3 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSLog(@"%@",[dictionary objectForKey:LAST_INITIAL_META_SYNC_TIME]);
    
    lastSyncTime = @"";
    lastSyncTime = [dictionary objectForKey:LAST_INITIAL_META_SYNC_TIME];
    
    NSDate * _gmtDate3 = [formatter3 dateFromString:lastSyncTime];
    
    lastSyncTime = [formatter4 stringFromDate:_gmtDate3];
    
    NSLog(@"%@", lastSyncTime);;
    
    NSString * str4 = nil;
    NSString * str5 = nil;
    NSString * str6 = nil;
    
    if ( [lastSyncTime length] > 17)
        str4 = [lastSyncTime substringFromIndex:17];
    if ( [str4 length] > 2)
        str5 = [str4 substringToIndex:2];
    
    int k;
    k = [str5 intValue];
    if (k > 12)
    {
        k = k - 12;
    }
    
    str6 = [NSString stringWithFormat:@"%d", k];
    NSLog(@"%@", str6);
    NSRange range1 = NSMakeRange(17,2);
    NSLog(@"%@", [lastSyncTime stringByReplacingCharactersInRange:range1 withString:str6]);
    lastSyncTime = [lastSyncTime stringByReplacingCharactersInRange:range1 withString:str6];

    lastSync = [[UILabel alloc] initWithFrame:CGRectMake(300, 192, 450, 45)];
    [lastSync setBackgroundColor:[UIColor clearColor]];
    lastSync.text = lastSyncTime;
    [self.view addSubview:lastSync];
    
    [lastSync release];
    [label4 release];
    
    UILabel *label5;
    label5 = [[UILabel alloc] initWithFrame:CGRectMake(35, 241, 550, 45)];
    UIImageView * bgView5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wou-row1-textfield-bg.png"]];
    bgView5.frame = CGRectMake(0, 0, 550, 45);
    label5.backgroundColor = [UIColor clearColor];
    label5.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_next_time];
    [label5 addSubview:bgView5];
    [self.view addSubview:label5];
    
    /*############################### Next Sync Time for Meta Sync ########################*/
    
    NSDateFormatter * format_MS = [[NSDateFormatter alloc] init];
    [format_MS setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * _str = [dictionary objectForKey:LAST_INITIAL_META_SYNC_TIME];
    NSDate * gmtDate_ = [format_MS dateFromString:_str];
    [format_MS release];
    
    NSDateFormatter * formatter2_MS = [[NSDateFormatter alloc] init];
    [formatter2_MS setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss a"];
    
    
    NSString *  timerValue_MS = ([appDelegate.settingsDict objectForKey:@"Frequency of Application Changes"]) != nil?[appDelegate.settingsDict objectForKey:@"Frequency of Application Changes"]:@"";
    
    NSTimeInterval scheduledTimer_MS = 0;
    
    if (![timerValue_MS isEqualToString:@""])  
    {
        double timeInterval = [timerValue_MS doubleValue];
        scheduledTimer_MS = timeInterval * 60;
    }
    else
        scheduledTimer_MS = 600;
    
    NSDate * dateAhead_MS = [gmtDate_ dateByAddingTimeInterval:scheduledTimer_MS];
    nextSyncTime = @"";
    nextSyncTime = [formatter2_MS stringFromDate:dateAhead_MS];
    [formatter2_MS release];
    
    NSString * _str4 = nil;
    NSString * _str5 = nil;
    NSString * _str6 = nil;
    if ( [nextSyncTime length] > 17)
        _str4 = [nextSyncTime substringFromIndex:17];
    if ( [_str4 length] > 2)
        _str5 = [_str1 substringToIndex:2];
    
    int p;
    p = [_str5 intValue];
    if (p > 12)
    {
        p = p - 12;
    }
    
    _str6 = [NSString stringWithFormat:@"%d", p];
    NSLog(@"%@", _str6);
    NSRange range_MS = NSMakeRange(17,2);
    NSLog(@"%@", [lastSyncTime stringByReplacingCharactersInRange:range_MS withString:_str6]);
    nextSyncTime = [nextSyncTime stringByReplacingCharactersInRange:range_MS withString:_str6];
    
    nextSync = [[UILabel alloc] initWithFrame:CGRectMake(300, 238, 450, 45)];
    [nextSync setBackgroundColor:[UIColor clearColor]];
    nextSync.text = nextSyncTime;
    [self.view addSubview:nextSync];
    
    [label5 release];
    [nextSync release];
    
    
    UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(35, 286, 550, 45)];
    UIImageView * bgView6 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wou-row1-textfield-bg.png"]];
    bgView6.frame = CGRectMake(0, 0, 550, 45);
    label6.backgroundColor = [UIColor clearColor];
    label6.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_last_status];
    [label6 addSubview:bgView6];
    [self.view addSubview:label6];
    
    
    _statusForMetaSync = [[UILabel alloc] initWithFrame:CGRectMake(300, 286, 450, 45)];
    _statusForMetaSync.backgroundColor = [UIColor clearColor];

   
    NSString * Status = @"";
    Status = [appDelegate.calDataBase retrieveMetaSyncStatus];
    
    if ([Status isEqualToString:@"Green"])
        _statusForMetaSync.text = syncStatus = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_succeeded];
    else if ([Status isEqualToString:@"Red"])
        _statusForMetaSync.text = syncStatus = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_failed];
    
    
    [self.view addSubview:_statusForMetaSync];

    
    [label6 release];
    [view release];
}

-(void)refreshSyncStatus
{
    NSLog(@"Synchronization ..");
    NSLog(@"%d", appDelegate.SyncStatus);
    
    _status.text = [self getSyncronisationStatus];
} 

-(void)refreshMetaSyncStatus
{
    _statusForMetaSync.text = [self getSyncronisationStatus];
}

-(NSString *)getSyncronisationStatus  
{
    if(appDelegate.SyncStatus == SYNC_RED){
       syncStatus = @"";
       syncStatus =[appDelegate.wsInterface.tagsDictionary objectForKey:sync_failed];
    }else if (appDelegate.SyncStatus == SYNC_GREEN){
       syncStatus = @"";
        syncStatus = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_succeeded];
    }else if (appDelegate.SyncStatus == SYNC_ORANGE){
       syncStatus = @"";
       syncStatus = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_progress];
    }
    return syncStatus; 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
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
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if (deviceOrientation == UIInterfaceOrientationPortrait || deviceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        return YES;
    return NO;
}

- (void)dealloc
{
    [_status release];
    [_statusForMetaSync release];
    [super dealloc];
}


@end
