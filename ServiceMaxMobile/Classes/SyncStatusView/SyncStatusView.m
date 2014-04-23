


//  SyncStatusView.m
//  iService
//
//  Created by Parashuram on 19/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncStatusView.h"
#import "AppDelegate.h"
#import "Utility.h" /*Radha - Data Purge*/

/*Accessibilty Changes*/
#import "AccessibilitySyncStatusConstants.h"

void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);
/*Radha - Data Purge*/
@interface SyncStatusView()

- (NSString *)getLocalizedText:(NSString *)label;
- (NSString *)upadteLastDPTime;
- (NSString *)updateNextDPTime;
- (NSString *)updateLastDPStatus;

@end;

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
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.wsInterface.updateSyncStatus = self;
    popOverButtons.refreshMetaSyncDelegate = self;

    view = nil;
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_right_panel_bg_main.png"]];
    
    [self.view addSubview:bgImage];
    [bgImage release];

    //Read from the plist
    @try{
    
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
    label.frame = CGRectMake(10, 134, 580, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [appDelegate colorForHex:@"2d5d83"];
    label.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_configuration];
    label.font = [UIFont boldSystemFontOfSize:16];
    
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 84, 300, 31)];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_section_header_bg.png"]];
    imageView.frame = CGRectMake(10, 134, 580, 31);
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
    
    /*Accessibilty Changes*/
    label1.isAccessibilityElement = YES;
    [label1 setAccessibilityIdentifier:kAccLastDataSyncTimeLabel];
    
    [label1 addSubview:bgView];
    [self.view addSubview:label1];
	
	//7444
	NSString * lastDataSyncTime = [self updateLastDataSynctime];
    
    lastSync = [[UILabel alloc] initWithFrame:CGRectMake(320, 28, 450, 45)];
    [lastSync setBackgroundColor:[UIColor clearColor]];
    lastSync.text = lastDataSyncTime;
      
    /*Accessibilty Changes*/
    lastSync.isAccessibilityElement = YES;
    [lastSync setAccessibilityIdentifier:kAccLastDataSync];
        
    [self.view addSubview:lastSync];
	[label1 release];
    
	 /*################################## Time Stamp For Next Data Sync ################################*/
		
    UILabel *label2;
    label2 = [[UILabel alloc] initWithFrame:CGRectMake(35, 75, 550, 45)];
    UIImageView * bgView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wou-row1-textfield-bg.png"]];
    bgView1.frame = CGRectMake(0, 0, 550, 45);
    label2.backgroundColor = [UIColor clearColor];
    label2.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_next_time];
    
    /*Accessibilty Changes*/
    label2.isAccessibilityElement = YES;
    [label2 setAccessibilityIdentifier:kAccNextDataSyncTimeLabel];

    
    [label2 addSubview:bgView1];
    [self.view addSubview:label2];
	[label2 release];
		
	//7444	
	NSString * nextDataSyncTime = [self updateNextDataSyncTime];
	
	nextSync = [[UILabel alloc] initWithFrame:CGRectMake(320, 76, 450, 45)];
	[nextSync setBackgroundColor:[UIColor clearColor]];
	nextSync.text = nextDataSyncTime;
        
    /*Accessibilty Changes*/
    nextSync.isAccessibilityElement = YES;
    [nextSync setAccessibilityIdentifier:kAccNextDataSync];
    
	[self.view addSubview:nextSync];	

    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(35, 120, 550, 45)];
    UIImageView * bgView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wou-row1-textfield-bg.png"]];
    bgView3.frame = CGRectMake(0, 0, 550, 45);
    label3.backgroundColor = [UIColor clearColor];
    label3.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_last_status];
        
    /*Accessibilty Changes*/
    label3.isAccessibilityElement = YES;
    [label3 setAccessibilityIdentifier:kAccLastDataPurgeStatusLabel];
    
	[label3 addSubview:bgView3];
    [self.view addSubview:label3];
   
	    
    _status = [[UILabel alloc] initWithFrame:CGRectMake(320, 124, 450, 45)]; /*UIAutomation-Shra*/
    _status.backgroundColor = [UIColor clearColor];
	_status.lineBreakMode = UILineBreakModeMiddleTruncation;
	_status.clipsToBounds = NO;
	_status.text = [self getSyncronisationStatus];
        
    /*Accessibilty Changes*/
    _status.isAccessibilityElement = YES;
    [_status setAccessibilityIdentifier:kAccLastDataPurgeStatus];
	
	[self.view addSubview:_status]; /*UIAutomation-Shra*/
    [label3 release];

     //Push Logs
    UILabel *pushLogLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 170, 550, 45)];
    UIImageView * pushLogbgView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wou-row1-textfield-bg.png"]];
    pushLogbgView3.frame = CGRectMake(0, 0, 550, 45);
    pushLogLabel.backgroundColor = [UIColor clearColor];
    pushLogLabel.text = [appDelegate.wsInterface.tagsDictionary objectForKey:Push_Log_Status];
    [pushLogLabel addSubview:pushLogbgView3];
        
    /*Accessibilty Changes*/
    pushLogLabel.isAccessibilityElement = YES;
    [pushLogLabel setAccessibilityIdentifier:kAccPushLogStatusLabel];

    [self.view addSubview:pushLogLabel];
    [pushLogLabel release];
    
    UILabel *pushLogStatus = [[UILabel alloc] initWithFrame:CGRectMake(320, 174, 450, 45)]; /*UIAutomation-Shra*/
    pushLogStatus.backgroundColor = [UIColor clearColor];
    pushLogStatus.lineBreakMode = NSLineBreakByTruncatingMiddle;
    pushLogStatus.clipsToBounds = NO;
    NSDictionary * plistDict = [self getRootPlistDictionary];
    pushLogStatus.text = [plistDict objectForKey:PUSH_LOG_LABEL];
    NSString *pushLogStatusColor = [plistDict objectForKey:PUSH_LOG_LABEL_COLOR];
    pushLogStatus.textColor = [UIColor blackColor];
    if([pushLogStatusColor caseInsensitiveCompare:@"red"] == NSOrderedSame)
    {
        pushLogStatus.textColor = [UIColor redColor];
    }
    else if([pushLogStatusColor caseInsensitiveCompare:@"green"] == NSOrderedSame)
    {
        pushLogStatus.textColor = [UIColor greenColor];
    }
        
    /*Accessibilty Changes*/
    pushLogStatus.isAccessibilityElement = YES;
    [pushLogStatus setAccessibilityIdentifier:kAccPushLogStatus];
    
    [self.view addSubview:pushLogStatus]; /*UIAutomation-Shra*/
    

		
	/*################################## Time Stamp For Meta Sync ################################*/
    //Set 2
    UILabel *label4;
    label4 = [[UILabel alloc] initWithFrame:CGRectMake(35, 250, 550, 45)];
    UIImageView * bgView4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wou-row1-textfield-bg.png"]];
    bgView4.frame = CGRectMake(0, 0, 550, 45);
    label4.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_last_time];
    label4.backgroundColor = [UIColor clearColor];
    [label4 addSubview:bgView4];
        
    /*Accessibilty Changes*/
    label4.isAccessibilityElement = YES;
    [label4 setAccessibilityIdentifier:kAccLastConfigSyncStatusLabel];
    
    [self.view addSubview:label4];
    
	//7444
	NSString * lastMetaSyncTime =  [self updateLastConfigsyncTime];

    lastConfigTime = [[UILabel alloc] initWithFrame:CGRectMake(320, 250, 450, 45)];
    [lastConfigTime setBackgroundColor:[UIColor clearColor]];
    lastConfigTime.text = lastMetaSyncTime;
        
    /*Accessibilty Changes*/
    lastConfigTime.isAccessibilityElement = YES;
    [lastConfigTime setAccessibilityIdentifier:kAccLastConfigSync];
    
    [self.view addSubview:lastConfigTime];
    [label4 release];
    
    UILabel *label5;
    label5 = [[UILabel alloc] initWithFrame:CGRectMake(35, 298, 550, 45)];
    UIImageView * bgView5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wou-row1-textfield-bg.png"]];
    bgView5.frame = CGRectMake(0, 0, 550, 45);
    label5.backgroundColor = [UIColor clearColor];
    label5.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_next_time];
    [label5 addSubview:bgView5];
        
    /*Accessibilty Changes*/
    label5.isAccessibilityElement = YES;
    [label5 setAccessibilityIdentifier:kAccNextConfigSyncTimeLabel];

    [self.view addSubview:label5];
    

		
    /*############################### Next Sync Time for Meta Sync ########################*/
    
	//7444
	NSString * nextMetaSyncTime = [self updateNextConfigsyncTime];
	    
    nextConfigTime = [[UILabel alloc] initWithFrame:CGRectMake(320, 298, 450, 45)];
    [nextConfigTime setBackgroundColor:[UIColor clearColor]];
    nextConfigTime.text = nextMetaSyncTime;
        
    /*Accessibilty Changes*/
    nextConfigTime.isAccessibilityElement = YES;
    [nextConfigTime setAccessibilityIdentifier:kAccNextConfigSync];
    
    [self.view addSubview:nextConfigTime];
    
    [label5 release];    
    
    UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(35, 346, 550, 45)];
    UIImageView * bgView6 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wou-row1-textfield-bg.png"]];
    bgView6.frame = CGRectMake(0, 0, 550, 45);
    label6.backgroundColor = [UIColor clearColor];
    label6.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_last_status];
    [label6 addSubview:bgView6];
        
    /*Accessibilty Changes*/
    label6.isAccessibilityElement = YES;
    [label6 setAccessibilityIdentifier:kAccLastConfigSyncStatusLabel];
    
    [self.view addSubview:label6];
    
    
    _statusForMetaSync = [[UILabel alloc] initWithFrame:CGRectMake(320, 346, 450, 45)];
    _statusForMetaSync.backgroundColor = [UIColor clearColor];

   
    NSString * Status = @"";
    Status = [appDelegate.calDataBase retrieveMetaSyncStatus];
		
	NSDictionary * dictionary = [self getRootPlistDictionary];
    
    _statusForMetaSync.text = [dictionary objectForKey:META_SYNC_STATUS];
        
    /*Accessibilty Changes*/
    _statusForMetaSync.isAccessibilityElement = YES;
    [_statusForMetaSync setAccessibilityIdentifier:kAccLastConfigSyncStatus];
    
    [self.view addSubview:_statusForMetaSync];

    
    [label6 release];
    /*Radha - Data Purge*/
    if ([appDelegate doesServerSupportsModule:kMinPkgForDataPurge])
    {
        [self addDataPurgeDetails];
    }

    [view release];
	} @catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name SyncStatusView :viewDidLoad %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason SyncStatusView :viewDidLoad %@",exp.reason);
    }

}

-(void)refreshSyncStatus
{
    SMLog(kLogLevelVerbose,@"Synchronization ..");
    SMLog(kLogLevelVerbose,@"%d", appDelegate.SyncStatus);
    
	[_status performSelectorOnMainThread:@selector(setText:) withObject:[self getSyncronisationStatus] waitUntilDone:NO];
} 

-(void)refreshMetaSyncStatus
{
	@try{
	NSArray  * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsPath = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0];
    
    NSString * fooPath = [documentsPath stringByAppendingPathComponent:@"SYNC_HISTORY.plist"];
    NSDictionary * dictionary = [[NSDictionary alloc] initWithContentsOfFile:fooPath];

	 _statusForMetaSync.text = [dictionary objectForKey:META_SYNC_STATUS];
	 }@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name SyncStatusView :refreshMetaSyncStatus %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason SyncStatusView :refreshMetaSyncStatus %@",exp.reason);
    }

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

//7444
- (NSDateComponents *) getTodatDateComponents
{
	NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSTimeZoneCalendarUnit;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents * todayDateComponents = [gregorian components:unitFlags fromDate:[NSDate date]];
	
	return todayDateComponents;
}

- (NSDictionary *) getRootPlistDictionary
{
	NSString * documentsPath = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0];
	
	NSString * fooPath = [documentsPath stringByAppendingPathComponent:@"SYNC_HISTORY.plist"];
	NSDictionary * dictionary = [[NSDictionary alloc] initWithContentsOfFile:fooPath];
	
	return dictionary;
}


- (NSString *) updateLastDataSynctime
{
	
	NSDateComponents * todayDateComponents = [self getTodatDateComponents];
	
	NSDictionary * dictionary = [self getRootPlistDictionary];
	
    //Radha - defect Fix - 5542
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
	[formatter setTimeZone:[todayDateComponents timeZone]];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		
	lastSyncTime = @"";
	//Radha - defect Fix - 5542
	lastSyncTime = [dictionary objectForKey:DATASYNC_TIME_TOBE_DISPLAYED];
	
	NSDate * _gmtDate = [formatter dateFromString:lastSyncTime];
	NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT];
	NSTimeInterval gmtTimeInterval = [_gmtDate timeIntervalSinceReferenceDate] + timeZoneOffset;
	
	NSDate * localDate = [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];
	   
    lastSyncTime = [Utility getUserReableStringFromDate:localDate]; //Defect Fix 9126
	
	SMLog(kLogLevelVerbose,@"%@", lastSyncTime);;
	
    // Commented the below code to support both 12 hr and 24 hr time format. As part of defect 9126
	/*NSString * str1 = nil;
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
	SMLog(kLogLevelVerbose,@"%@", str3);
	NSRange range = NSMakeRange(17,2);
	SMLog(kLogLevelVerbose,@"%@", [lastSyncTime stringByReplacingCharactersInRange:range withString:str3]);
	lastSyncTime = [lastSyncTime stringByReplacingCharactersInRange:range withString:str3];*/
    
	[formatter release]; //Defect Fix 9126
    
	return lastSyncTime;

}

-(NSString *) updateNextDataSyncTime
{
		
	//7444
	NSString * timerValue = ([appDelegate.settingsDict objectForKey:@"Frequency of Master Data"] != nil)?[appDelegate.settingsDict objectForKey:@"Frequency of Master Data"]:@"";
	
	int value = [timerValue intValue];
	
	if (value == 0)
	{
		nextSyncTime = @"Not Scheduled";
	}
	else
	{
		nextSyncTime = @"";
		//If data sync is failed just update the next sync time
        
        NSDateComponents * todayDateComponents = [self getTodatDateComponents];
        
        NSDictionary * dictionary = [self getRootPlistDictionary];
		
		NSDateFormatter * format = [[NSDateFormatter alloc] init];
		[format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		[format setTimeZone:[todayDateComponents timeZone]];
		
		nextSyncTime = [dictionary objectForKey:NEXT_DATA_SYNC_TIME_DISPLAYED];
        
        NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT];
		NSDate * gmtDate = [format dateFromString:nextSyncTime];
		NSTimeInterval NDS_gmtTimeInterval = [gmtDate timeIntervalSinceReferenceDate] + timeZoneOffset;
		NSDate * NSDlocalDate = [NSDate dateWithTimeIntervalSinceReferenceDate:NDS_gmtTimeInterval];
		      
        nextSyncTime = [Utility getUserReableStringFromDate:NSDlocalDate]; //Defect Fix 9126
				
        // Commented the below code to support both 12 hr and 24 hr time format. As part of defect 9126
        
		/*NSString * _str1 = nil;
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
		SMLog(kLogLevelVerbose,@"%@", _str3);
		NSRange _range = NSMakeRange(17,2);
		SMLog(kLogLevelVerbose,@"%@", [lastSyncTime stringByReplacingCharactersInRange:_range withString:_str3]);
		nextSyncTime = [nextSyncTime stringByReplacingCharactersInRange:_range withString:_str3]; */
		
		[format release];
	}
    return nextSyncTime;
    
}

- (NSString *) updateLastConfigsyncTime
{
	NSDateComponents * todayDateComponents = [self getTodatDateComponents];
	
	NSDictionary * dictionary = [self getRootPlistDictionary];
	
	NSDateFormatter * formatter3 = [[NSDateFormatter alloc] init];
    [formatter3 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[formatter3 setTimeZone:[todayDateComponents timeZone]];
	
	NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT];
    
    SMLog(kLogLevelVerbose,@"%@",[dictionary objectForKey:LAST_INITIAL_META_SYNC_TIME]);
    
    lastSyncTime = @"";
    lastSyncTime = [dictionary objectForKey:LAST_INITIAL_META_SYNC_TIME];
		
	NSDate * _gmtDate3 = [formatter3 dateFromString:lastSyncTime];
	NSTimeInterval NMSgmtTimeInterval = [_gmtDate3 timeIntervalSinceReferenceDate] + timeZoneOffset;
	NSDate * NMSlocalDate = [NSDate dateWithTimeIntervalSinceReferenceDate:NMSgmtTimeInterval];
    
    lastSyncTime = [Utility getUserReableStringFromDate:NMSlocalDate]; //Defect Fix 9126
    
    // Commented the below code to support both 12 hr and 24 hr time format. As part of defect 9126
    
  /*  NSString * str4 = nil;
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
    SMLog(kLogLevelVerbose,@"%@", str6);
    NSRange range1 = NSMakeRange(17,2);
    SMLog(kLogLevelVerbose,@"%@", [lastSyncTime stringByReplacingCharactersInRange:range1 withString:str6]);
    lastSyncTime = [lastSyncTime stringByReplacingCharactersInRange:range1 withString:str6]; */
	
	
	[formatter3 release];
	
	return lastSyncTime;
}

- (NSString *) updateNextConfigsyncTime
{
    NSString * mataSyncTimerValue = ([appDelegate.settingsDict objectForKey:@"Frequency of Application Changes"] != nil)?[appDelegate.settingsDict objectForKey:@"Frequency of Application Changes"]:@"";
	
	NSInteger value = [mataSyncTimerValue intValue];
	
	if (value == 0)
	{
		nextSyncTime = @"Not Scheduled";
	}
	else
	{
		nextSyncTime = @"";
        
        NSDateComponents * todayDateComponents = [self getTodatDateComponents];
        
        NSDictionary * dictionary = [self getRootPlistDictionary];
		
		NSDateFormatter * format_MS = [[NSDateFormatter alloc] init];
		[format_MS setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
		[format_MS setTimeZone:[todayDateComponents timeZone]];
		NSString * _str = [dictionary objectForKey:NEXT_META_SYNC_TIME];
		
		NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT];
        
        NSDate * gmtDate_ = [format_MS dateFromString:_str];
		NSTimeInterval MSgmtTimeInterval = [gmtDate_ timeIntervalSinceReferenceDate] + timeZoneOffset;
		NSDate * MSlocalDate = [NSDate dateWithTimeIntervalSinceReferenceDate:MSgmtTimeInterval];
		[format_MS release];

		nextSyncTime = @"";
        
        nextSyncTime = [Utility getUserReableStringFromDate:MSlocalDate]; //Defect Fix 9126
		
        // Commented the below code to support both 12 hr and 24 hr time format. As part of defect 9126
        
		/*NSString * _str4 = nil;
		NSString * _str5 = nil;
		NSString * _str6 = nil;
		if ( [nextSyncTime length] > 17)
			_str4 = [nextSyncTime substringFromIndex:17];
		if ( [_str4 length] > 2)
			_str5 = [_str4 substringToIndex:2];
		
		int p;
		p = [_str5 intValue];
		if (p > 12)
		{
			p = p - 12;
		}
		
		_str6 = [NSString stringWithFormat:@"%d", p];
		SMLog(kLogLevelVerbose,@"%@", _str6);
		NSRange range_MS = NSMakeRange(17,2);
		SMLog(kLogLevelVerbose,@"%@", [lastSyncTime stringByReplacingCharactersInRange:range_MS withString:_str6]);
		nextSyncTime = [nextSyncTime stringByReplacingCharactersInRange:range_MS withString:_str6]; */
	}
	return nextSyncTime;

}


- (void) refreshSyncTime
{
	NSString * lastDataSyncTime =  [self updateLastDataSynctime];
	lastSync.text = lastDataSyncTime;
	
	NSString * nextDataSyncTime = [self updateNextDataSyncTime];
	nextSync.text = nextDataSyncTime;
	
}

- (void) refreshConfigSyncTime
{
	NSString * lastConfigSyncTime =  [self updateLastConfigsyncTime];
	lastConfigTime.text = lastConfigSyncTime;
	
	NSString * nextConfigSyncTime = [self updateNextConfigsyncTime];
	nextConfigTime.text = nextConfigSyncTime;
}


#pragma mark - Data Purge
- (NSString *)getLocalizedText:(NSString *)label
{
    return [Utility getValueForTagFromTagDict:label];
}

/*Radha - Data Purge*/
-(void) addDataPurgeDetails
{
    //Add header label
    UIImageView * imageView = nil;
    
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 132, 300, 31)];
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_section_header_bg.png"]];
    imageView.frame = CGRectMake(10, 262, 580, 31);
    [view addSubview:imageView];
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 262, 580, 30)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [appDelegate colorForHex:@"2d5d83"];
    headerLabel.text = [self getLocalizedText:Data_Purge];
    headerLabel.font = [UIFont boldSystemFontOfSize:16];
    [view addSubview:headerLabel];
    [self.view addSubview:view];
    
    [imageView release];
    [headerLabel release];
    
    //last data purge time
    UILabel * lastDPlabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 425, 550, 45)];
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wou-row1-textfield-bg.png"]];
    imageView.frame = CGRectMake(0, 0, 550, 45);
    lastDPlabel.text = [self getLocalizedText:Last_Data_Purge];
    lastDPlabel.backgroundColor = [UIColor clearColor];
    [lastDPlabel addSubview:imageView];
    [self.view addSubview:lastDPlabel];
    
    
    lastDataPurge = [[UILabel alloc] initWithFrame:CGRectMake(320, 425, 450, 45)];
    [lastDataPurge setBackgroundColor:[UIColor clearColor]];
    lastDataPurge.text = [self upadteLastDPTime];
    [self.view addSubview:lastDataPurge];
    
    [lastDPlabel release];
    [imageView release];
    
    
    //next data purge time
    UILabel * nextDPlabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 472, 550, 45)];
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wou-row1-textfield-bg.png"]];
    imageView.frame = CGRectMake(0, 0, 550, 45);
    nextDPlabel.text =  [self getLocalizedText:Next_Data_Purge];
    nextDPlabel.backgroundColor = [UIColor clearColor];
    [nextDPlabel addSubview:imageView];
    [self.view addSubview:nextDPlabel];
    
    
    nextDataPurge = [[UILabel alloc] initWithFrame:CGRectMake(320, 472, 450, 45)];
    [nextDataPurge setBackgroundColor:[UIColor clearColor]];
    nextDataPurge.text = [self updateNextDPTime];
    [self.view addSubview:nextDataPurge];
    
    [nextDPlabel release];
    [imageView release];
    
    //data purge status
    UILabel * statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 519, 550, 45)];
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wou-row1-textfield-bg.png"]];
    imageView.frame = CGRectMake(0, 0, 550, 45);
    statusLabel.text =  [self getLocalizedText:Data_Purge_Status];
    statusLabel.backgroundColor = [UIColor clearColor];
    [statusLabel addSubview:imageView];
    [self.view addSubview:statusLabel];
    
    
    dataPurgeStatus = [[UILabel alloc] initWithFrame:CGRectMake(320, 519, 450, 45)];
    [dataPurgeStatus setBackgroundColor:[UIColor clearColor]];
    dataPurgeStatus.text = [self updateLastDPStatus];
    [self.view addSubview:dataPurgeStatus];
    
    [statusLabel release];
    [imageView release];
    
    /*Accessibilty Changes*/
    lastDPlabel.isAccessibilityElement = YES;
    [lastDPlabel setAccessibilityIdentifier:kAccLastDataPurgeTimeLabel];
    
    nextDPlabel.isAccessibilityElement = YES;
    [nextDPlabel setAccessibilityIdentifier:kAccNextDataPurgeTimeLabel];
    
    statusLabel.isAccessibilityElement = YES;
    [statusLabel setAccessibilityIdentifier:kAccLastDataPurgeStatusLabel];
    
    lastDataPurge.isAccessibilityElement = YES;
    [lastDataPurge setAccessibilityIdentifier:kAccLastDataPurge];
    
    nextDataPurge.isAccessibilityElement = YES;
    [nextDataPurge setAccessibilityIdentifier:kAccNextDataPurge];
    
    dataPurgeStatus.isAccessibilityElement = YES;
    [dataPurgeStatus setAccessibilityIdentifier:kAccLastDataPurgeStatus];
}

- (NSString *)upadteLastDPTime
{
    NSString * lastDP = [[SMDataPurgeManager sharedInstance] getLastDataPurgeTime];
    if (lastDP != nil && [lastDP length] > 0)
        return lastDP;
    
    return @"";
    
}
- (NSString *)updateNextDPTime
{
    NSString * nextDP =[[SMDataPurgeManager sharedInstance] getNextDataPurgeTime];
    if (nextDP != nil && [nextDP length] > 0)
        return nextDP;
    
    return @"";
}
- (NSString *)updateLastDPStatus
{
    NSString * purgeStatus = [[SMDataPurgeManager sharedInstance] getLastDataPurgeStatus];
    if (purgeStatus != nil && [purgeStatus length] > 0)
        return purgeStatus;
    
    return @"";
}



#pragma End - Data purge

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
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
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
	[lastSync release];
	[nextSync release];
	[lastConfigTime release];
	[nextConfigTime release];
    [_statusForMetaSync release];
    [lastDataPurge release];
    [nextDataPurge release];
    [dataPurgeStatus release];
    [super dealloc];
}


@end
