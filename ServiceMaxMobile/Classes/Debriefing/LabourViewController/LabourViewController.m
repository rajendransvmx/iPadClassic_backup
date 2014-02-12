//
//  LabourViewController.m
//  Debriefing
//
//  Created by Sanchay on 9/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LabourViewController.h"
void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);

@implementation LabourViewController

@synthesize parent;

@synthesize willRecoverFromMemoryError;

/*
// The designated initializer. Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableDictionary *Dictionaries = appDelegate.Dictionaries;
    
    calculateLaborPrice = laborPriceEditable = YES;
    @try{
    if ([appDelegate.timeAndMaterial count] > 0)
    {
        // Settings are present
        settingsPresent = YES;
        for (int i = 0; i < [appDelegate.timeAndMaterial count]; i++)
        {
            NSDictionary * dict = [appDelegate.timeAndMaterial objectAtIndex:i];
            NSString * key = [[dict allKeys] objectAtIndex:0];
            // if ([key isEqualToString:@"Calculate Labor Price"])
            if ([key isEqualToString:@"IPAD002_SET002"])
            {
                NSString * calculateLaborPriceStr = [dict objectForKey:key];
                if ([calculateLaborPriceStr isEqualToString:@"true"])
                    calculateLaborPrice = YES;
                else
                    calculateLaborPrice = NO;
            }
            // if ([key isEqualToString:@"User Can Change Labor Price"])
            if ([key isEqualToString:@"IPAD002_SET003"])
            {
                NSString * laborPriceEditableStr = [dict objectForKey:key];
                if ([laborPriceEditableStr isEqualToString:@"true"])
                    laborPriceEditable = YES;
                else
                    laborPriceEditable = NO;
            }
        }
    }
    else
    {   // Settings not present
        settingsPresent = NO;
        calculateLaborPrice = YES;
        laborPriceEditable = YES;
    }
    
    // If Settings are present
        // If UserCanChangelaborPrice
            // Make Labor Price editable
        // else
            // Labor Price NOT editable
    // else
        // Labor Price editable
    if (laborPriceEditable)
    {
        rateCalibration.enabled = rateCleanup.enabled = rateInstallation.enabled = rateRepair.enabled = rateService.enabled = YES;
    }
    else
    {
        rateCalibration.enabled = rateCleanup.enabled = rateInstallation.enabled = rateRepair.enabled = rateService.enabled = NO;
    }
	
	if( Dictionaries == nil )
	{
		NSBundle *MainBundle = [NSBundle mainBundle];
		
		NSString *SettingsBundlePath = [MainBundle pathForResource:@"Settings" ofType:@"bundle"];
		NSBundle *SettingsBundle = [NSBundle bundleWithPath:SettingsBundlePath];
		NSString *RootPlistPath = [SettingsBundle pathForResource:@"Root" ofType:@"plist"];
		Dictionaries = appDelegate.Dictionaries = [[NSMutableDictionary alloc] initWithContentsOfFile:RootPlistPath];
	}
	
	//load LabourValuesDictionary
	LabourValuesDictionary = [(NSDictionary *)[(NSDictionary *)[Dictionaries valueForKey:@"Dictionaries"] valueForKey:@"Labour"] retain];
	LabourLabelDictionary = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:LblCalibration, LblCleanup, LblInstallation, LblRepair, LblService, nil]  
															 forKeys:[NSArray arrayWithObjects:CALIBRATION, CLEANUP, INSTALLATION, REPAIR, SERVICE, nil]];
	LabourSliderDictionary = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:Calibration, Cleanup, Installation, Repair, Service, nil]  
														   forKeys:[NSArray arrayWithObjects:CALIBRATION, CLEANUP, INSTALLATION, REPAIR, SERVICE, nil]]; 

	dataloaded = NO;

    {
        [self InitLaborData];
		while (!dataloaded) {
			CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, TRUE);
		}
    }
	
	[Calibration setValue:[[LabourValuesDictionary valueForKey:CALIBRATION] floatValue]*2 animated:YES];
	[Cleanup setValue:[[LabourValuesDictionary valueForKey:CLEANUP] floatValue]*2 animated:YES];
	[Installation setValue:[[LabourValuesDictionary valueForKey:INSTALLATION] floatValue]*2 animated:YES];
	[Repair setValue:[[LabourValuesDictionary valueForKey:REPAIR] floatValue]*2 animated:YES];
	[Service setValue:[[LabourValuesDictionary valueForKey:SERVICE] floatValue]*2 animated:YES];
	[self SliderValueChanged:Calibration], [self SliderValueChanged:Cleanup], [self SliderValueChanged:Installation], [self SliderValueChanged:Repair], [self SliderValueChanged:Service];
	
	[Calibration setThumbImage:[UIImage imageNamed:@"slider-iService-Debriefing-Labor.png"] forState:UIControlStateNormal];
	[Calibration setThumbImage:[UIImage imageNamed:@"slider-iService-Debriefing-Labor.png"] forState:UIControlStateHighlighted];
	
	[Cleanup setThumbImage:[UIImage imageNamed:@"slider-iService-Debriefing-Labor.png"] forState:UIControlStateNormal];
	[Cleanup setThumbImage:[UIImage imageNamed:@"slider-iService-Debriefing-Labor.png"] forState:UIControlStateHighlighted];
	
	[Installation setThumbImage:[UIImage imageNamed:@"slider-iService-Debriefing-Labor.png"] forState:UIControlStateNormal];
	[Installation setThumbImage:[UIImage imageNamed:@"slider-iService-Debriefing-Labor.png"] forState:UIControlStateHighlighted];
	
	[Repair setThumbImage:[UIImage imageNamed:@"slider-iService-Debriefing-Labor.png"] forState:UIControlStateNormal];
	[Repair setThumbImage:[UIImage imageNamed:@"slider-iService-Debriefing-Labor.png"] forState:UIControlStateHighlighted];
	
	[Service setThumbImage:[UIImage imageNamed:@"slider-iService-Debriefing-Labor.png"] forState:UIControlStateNormal];
	[Service setThumbImage:[UIImage imageNamed:@"slider-iService-Debriefing-Labor.png"] forState:UIControlStateHighlighted];

    // if (calculateLaborPrice)
    {
        rateCalibration.text = [LabourValuesDictionary valueForKey:RATE_CALIBRATION];
        rateCleanup.text = [LabourValuesDictionary valueForKey:RATE_CLEANUP];
        rateInstallation.text = [LabourValuesDictionary valueForKey:RATE_INSTALLATION];
        rateRepair.text = [LabourValuesDictionary valueForKey:RATE_REPAIR];
        rateService.text = [LabourValuesDictionary valueForKey:RATE_SERVICE];        
    }
    /*
    else
    {
        rateCalibration.text = @"0.0";
        rateCleanup.text = @"0.0";
        rateInstallation.text = @"0.0";
        rateRepair.text = @"0.0";
        rateService.text = @"0.0";
    }
    */

    rateCalibration.delegate = rateCleanup.delegate = rateInstallation.delegate = rateRepair.delegate = rateService.delegate = self;
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name LabourViewController :viewDidLoad %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason LabourViewController :viewDidLoad %@",exp.reason);
	[appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	keyboard = [[PopOverKeyboard alloc] initWithNibName:[PopOverKeyboard description] bundle:nil];
	[keyboard.view becomeFirstResponder];
	keyboard.parent = self;
    keyboard.delegate = self;

	return NO;
}

- (void)keyboardWillShow:(id)sender
{
	NSNotification *not = (NSNotification *)sender;
	UITextField *txtFld = (UITextField *)[not object];
	[txtFld resignFirstResponder];
}

- (IBAction) SliderValueChanged:(id)sender
{
	UISlider *slider = (UISlider *)sender;
	float val = slider.value;
	int roundedval = roundf(val);
	SMLog(kLogLevelVerbose,@"%d", roundedval);
	[slider setValue:roundedval];
	
	//get key for selected slider
	NSString *key = [(NSArray *)[LabourSliderDictionary allKeysForObject:slider] objectAtIndex:0];
	
	UILabel *lbl = [LabourLabelDictionary valueForKey:key];
	NSString *strval = [NSString stringWithFormat:@"%0.1f", ((float)roundedval/2)];
	lbl.text = [NSString stringWithFormat:@"%@ Hrs", strval];
	
	[LabourValuesDictionary setValue:strval forKey:key];
	
	NSBundle *MainBundle = [NSBundle mainBundle];
	NSString *SettingsBundlePath = [MainBundle pathForResource:@"Settings" ofType:@"bundle"];
	NSBundle *SettingsBundle = [NSBundle bundleWithPath:SettingsBundlePath];
	NSString *RootPlistPath = [SettingsBundle pathForResource:@"Root" ofType:@"plist"];

	BOOL retVal = NO;
    retVal = [appDelegate.Dictionaries writeToFile:RootPlistPath atomically:YES];
    
    if (!retVal)
    {
        // Do something
    }
	
	if( [parent respondsToSelector:@selector(PopulateData)] )
	{
		[parent performSelector:@selector(PopulateData)];
	}
}

#pragma mark -
#pragma mark PopOverKeyboard delegate
- (void) didKeyboardEditOccur
{
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    if (!appDelegate.didDebriefUnload)
    {
        [LabourValuesDictionary release];
        [LabourLabelDictionary release];
        [LabourSliderDictionary release];
        [Calibration release], [Cleanup release], [Installation release], [Repair release], [Service release];
        [LblCalibration release], [LblCleanup release], [LblInstallation release], [LblRepair release], [LblService release];
    }

    [super dealloc];
}

- (void) InitLaborData
{    
	// NSString *query = [NSString stringWithFormat:@"SELECT Id, SPR14__Activity_Type__c, SPR14__Actual_Quantity2__c, SPR14__Actual_Price2__c, SPR14__Work_Description__c FROM SPR14__Service_Order_Line__c WHERE SPR14__Line_Type__c = 'Labor' AND SPR14__Service_Order__c = '%@' AND RecordTypeId = '%@' AND SPR14__Actual_Quantity2__c > 0 AND SPR14__Actual_Price2__c > 0", AppDelegate.currentWorkOrderId, AppDelegate.usageConsumptionRecordId]; // a0oA0000000UXEsIAO
    
    //pavaman 1st Jan 2011 - We are not saving Actual Price. So why are we filtering on non-zero Actual Price?
	//samman's version: //NSString *query = [NSString stringWithFormat:@"SELECT Id, SPR14__Activity_Type__c, SPR14__Actual_Quantity2__c, SPR14__Actual_Price2__c, SPR14__Work_Description__c FROM SPR14__Service_Order_Line__c WHERE SPR14__Line_Type__c = 'Labor' AND SPR14__Service_Order__c = '%@' AND RecordTypeId = '%@' AND SPR14__Actual_Quantity2__c > 0 AND SPR14__Actual_Price2__c > 0", AppDelegate.currentWorkOrderId, AppDelegate.usageConsumptionRecordId]; // a0oA0000000UXEsIAO
	NSString * query = [NSString stringWithFormat:@"SELECT Id, SPR14__Activity_Type__c, SPR14__Actual_Quantity2__c, SPR14__Actual_Price2__c, SPR14__Work_Description__c FROM SPR14__Service_Order_Line__c WHERE SPR14__Line_Type__c = 'Labor' AND SPR14__Service_Order__c = '%@' AND RecordTypeId = '%@' AND SPR14__Actual_Quantity2__c > 0 AND SPR14__Actual_Price2__c >= 0", appDelegate.currentWorkOrderId, appDelegate.usageConsumptionRecordId]; // a0oA0000000UXEsIAO
	[[ZKServerSwitchboard switchboard] query:query target:self selector:@selector(getExistingLabor:error:context:) context:nil];
}

- (void) getExistingLabor:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
	@try{
	NSArray * array = [result records];
    appDelegate.laborZKSArray = [array retain];

	NSMutableDictionary *md = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    linePriceItems = [[NSMutableArray alloc] initWithCapacity:0];
	
	for (int i = 0; i < [array count]; i++)
	{        
		ZKSObject * obj = [array objectAtIndex:i];
        
        NSString *key, *value;
		key = [[obj fields] objectForKey:@"SPR14__Activity_Type__c"];
        
        [linePriceItems addObject:key];
        
        BOOL isKeyDuplicate = NO;
        for (int j = 0; j < [[md allKeys] count]; j++)
        {
            if ([key isEqualToString:[[md allKeys] objectAtIndex:j]])
            {
                isKeyDuplicate = YES;
                break;
            }
        }
        
        if (isKeyDuplicate)
            continue;
		
		// Check the query. use dictionary value extraction technique, for e.g.
		SMLog(kLogLevelVerbose,@"%@", [[obj fields] objectForKey:@"SPR14__Activity_Type__c"]);
		[md setValue:[[obj fields] objectForKey:@"SPR14__Actual_Quantity2__c"] forKey:[[obj fields] objectForKey:@"SPR14__Activity_Type__c"]];
        
		value = [[[obj fields] objectForKey:@"SPR14__Work_Description__c"] isKindOfClass:[NSString class]]?[[obj fields] objectForKey:@"SPR14__Work_Description__c"]:@"";
		if ( key != nil )
			[md setValue:value forKey:[NSString stringWithFormat:@"%@_%@", key, DESCRIPTION ]];
		else
			[md setValue:value forKey:[NSString stringWithFormat:@"%@_%@", @"", DESCRIPTION ]];

		value = [[[obj fields] objectForKey:@"SPR14__Actual_Price2__c"] isKindOfClass:[NSString class]]?[[obj fields] objectForKey:@"SPR14__Actual_Price2__c"]:@"";
		if ( key != nil )
			[md setValue:value forKey:[NSString stringWithFormat:@"%@_%@",  @"Rate" ,key]];
		else
			[md setValue:value forKey:[NSString stringWithFormat:@"%@_%@",  @"Rate" , @"" ]];
		
	}

	NSArray *keys = [md allKeys];
	
	
//pavaman 21st Jan 2011 - Always clear the LabourValuesDictionary so that old ones are completely removed
	[LabourValuesDictionary setValue:@"0" forKey:CALIBRATION];
	[LabourValuesDictionary setValue:@"0" forKey:CLEANUP];
	[LabourValuesDictionary setValue:@"0" forKey:INSTALLATION];
	[LabourValuesDictionary setValue:@"0" forKey:REPAIR];
	[LabourValuesDictionary setValue:@"0" forKey:SERVICE];
	
	[LabourValuesDictionary setValue:@"" forKey:[NSString stringWithFormat:@"%@_%@", CALIBRATION, DESCRIPTION]];
	[LabourValuesDictionary setValue:@"" forKey:[NSString stringWithFormat:@"%@_%@", CLEANUP, DESCRIPTION]];
	[LabourValuesDictionary setValue:@"" forKey:[NSString stringWithFormat:@"%@_%@", INSTALLATION, DESCRIPTION]];
	[LabourValuesDictionary setValue:@"" forKey:[NSString stringWithFormat:@"%@_%@", REPAIR, DESCRIPTION]];
	[LabourValuesDictionary setValue:@"" forKey:[NSString stringWithFormat:@"%@_%@", SERVICE, DESCRIPTION]];
	
	[LabourValuesDictionary setValue:@"0" forKey:[NSString stringWithFormat:@"%@_%@", CALIBRATION, MODIFY]];
	[LabourValuesDictionary setValue:@"0" forKey:[NSString stringWithFormat:@"%@_%@", CLEANUP, MODIFY]];
	[LabourValuesDictionary setValue:@"0" forKey:[NSString stringWithFormat:@"%@_%@", INSTALLATION, MODIFY]];
	[LabourValuesDictionary setValue:@"0" forKey:[NSString stringWithFormat:@"%@_%@", REPAIR, MODIFY]];
	[LabourValuesDictionary setValue:@"0" forKey:[NSString stringWithFormat:@"%@_%@", SERVICE, MODIFY]];

	[LabourValuesDictionary setValue:@"0.0" forKey:RATE_CALIBRATION];
	[LabourValuesDictionary setValue:@"0.0" forKey:RATE_CLEANUP];
	[LabourValuesDictionary setValue:@"0.0" forKey:RATE_INSTALLATION];
	[LabourValuesDictionary setValue:@"0.0" forKey:RATE_REPAIR];
	[LabourValuesDictionary setValue:@"0.0" forKey:RATE_SERVICE];
    
    for (int j = 0; j < [array count]; j++)
    {
        ZKSObject * obj = [array objectAtIndex:j];
        if ([[[obj fields] objectForKey:@"SPR14__Activity_Type__c"] isEqualToString:CALIBRATION])
            [LabourValuesDictionary setValue:[[obj fields] objectForKey:@"SPR14__Actual_Price2__c"] forKey:RATE_CALIBRATION];
        if ([[[obj fields] objectForKey:@"SPR14__Activity_Type__c"] isEqualToString:CLEANUP])
            [LabourValuesDictionary setValue:[[obj fields] objectForKey:@"SPR14__Actual_Price2__c"] forKey:RATE_CLEANUP];
        if ([[[obj fields] objectForKey:@"SPR14__Activity_Type__c"] isEqualToString:INSTALLATION])
            [LabourValuesDictionary setValue:[[obj fields] objectForKey:@"SPR14__Actual_Price2__c"] forKey:RATE_INSTALLATION];
        if ([[[obj fields] objectForKey:@"SPR14__Activity_Type__c"] isEqualToString:REPAIR])
            [LabourValuesDictionary setValue:[[obj fields] objectForKey:@"SPR14__Actual_Price2__c"] forKey:RATE_REPAIR];
        if ([[[obj fields] objectForKey:@"SPR14__Activity_Type__c"] isEqualToString:SERVICE])
            [LabourValuesDictionary setValue:[[obj fields] objectForKey:@"SPR14__Actual_Price2__c"] forKey:RATE_SERVICE];
    }
	
	
	for( int i = 0; i < [keys count]; i++ )
	{
		[LabourValuesDictionary setValue:[md valueForKey:[keys objectAtIndex:i]] forKey:[keys objectAtIndex:i]];
        if (![[keys objectAtIndex:i] Contains:DESCRIPTION])
            [LabourValuesDictionary setValue:@"1" forKey:[NSString stringWithFormat:@"%@_%@", [keys objectAtIndex:i], MODIFY]];
	}
    
    // Analyser
    [md release];
	
	if( ![array count] )
	{
		[LabourValuesDictionary setValue:@"0" forKey:CALIBRATION];
		[LabourValuesDictionary setValue:@"0" forKey:CLEANUP];
		[LabourValuesDictionary setValue:@"0" forKey:INSTALLATION];
		[LabourValuesDictionary setValue:@"0" forKey:REPAIR];
		[LabourValuesDictionary setValue:@"0" forKey:SERVICE];
		
		[LabourValuesDictionary setValue:@"" forKey:[NSString stringWithFormat:@"%@_%@", CALIBRATION, DESCRIPTION]];
		[LabourValuesDictionary setValue:@"" forKey:[NSString stringWithFormat:@"%@_%@", CLEANUP, DESCRIPTION]];
		[LabourValuesDictionary setValue:@"" forKey:[NSString stringWithFormat:@"%@_%@", INSTALLATION, DESCRIPTION]];
		[LabourValuesDictionary setValue:@"" forKey:[NSString stringWithFormat:@"%@_%@", REPAIR, DESCRIPTION]];
		[LabourValuesDictionary setValue:@"" forKey:[NSString stringWithFormat:@"%@_%@", SERVICE, DESCRIPTION]];

        [LabourValuesDictionary setValue:@"0" forKey:[NSString stringWithFormat:@"%@_%@", CALIBRATION, MODIFY]];
		[LabourValuesDictionary setValue:@"0" forKey:[NSString stringWithFormat:@"%@_%@", CLEANUP, MODIFY]];
		[LabourValuesDictionary setValue:@"0" forKey:[NSString stringWithFormat:@"%@_%@", INSTALLATION, MODIFY]];
		[LabourValuesDictionary setValue:@"0" forKey:[NSString stringWithFormat:@"%@_%@", REPAIR, MODIFY]];
		[LabourValuesDictionary setValue:@"0" forKey:[NSString stringWithFormat:@"%@_%@", SERVICE, MODIFY]];
	}
	
    //LabourValuesDictionary = md;
	
	NSBundle *MainBundle = [NSBundle mainBundle];
	NSString *SettingsBundlePath = [MainBundle pathForResource:@"Settings" ofType:@"bundle"];
	NSBundle *SettingsBundle = [NSBundle bundleWithPath:SettingsBundlePath];
	NSString *RootPlistPath = [SettingsBundle pathForResource:@"Root" ofType:@"plist"];
	[appDelegate.Dictionaries writeToFile:RootPlistPath atomically:YES];
	/*
	if( [parent respondsToSelector:@selector(PopulateData)] )
	{
		[parent performSelector:@selector(PopulateData)];
	}
	*/
	appDelegate.Labour = [LabourValuesDictionary retain];

	NSString * query;
    NSString * workOrderCurrency = [appDelegate.workOrderCurrency stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![appDelegate.workOrderCurrency isEqualToString:@""])
        query = [NSString stringWithFormat:@"SELECT SPR14__Billable_Cost2__c FROM SPR14__Service_Group_Costs__c	WHERE SPR14__Group_Member__c = '%@' AND SPR14__Cost_Category__c = 'Straight' AND CurrencyIsoCode = '%@' LIMIT 1", appDelegate.appTechnicianId, workOrderCurrency];
    else
        query = [NSString stringWithFormat:@"SELECT SPR14__Billable_Cost2__c FROM SPR14__Service_Group_Costs__c	WHERE SPR14__Group_Member__c = '%@' AND SPR14__Cost_Category__c = 'Straight' LIMIT 1", appDelegate.appTechnicianId]; // a0oA0000000UXEsIAO
    
    [[ZKServerSwitchboard switchboard] query:query target:self selector:@selector(getPriceForLabor:error:context:) context:nil];
	 }@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name LabourViewController :getExistingLabor %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason LabourViewController :getExistingLabor %@",exp.reason);
	 [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

}

- (void) getPriceForLabor:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
	NSArray * array = [result records];
    @try{
    if ((array == nil) || ([array count] == 0))
        groupCostsPresent = NO;
    else
        groupCostsPresent = YES;
	
	for (int i = 0; i < [array count]; i++)
	{
		ZKSObject * obj = [array objectAtIndex:i];
		
		// Check the query. use dictionary value extraction technique, for e.g.
		SMLog(kLogLevelVerbose,@"%@", [[obj fields] objectForKey:@"SPR14__Billable_Cost2__c"]);
		// [md setValue:[[obj fields] objectForKey:@"SPR14__Actual_Quantity2__c"] forKey:[[obj fields] objectForKey:@"SPR14__Activity_Type__c"]];
	}
	
	if( array != nil && ![array count] )
	{
		//25th jan 2011 pavaman - multicurrency handling
		NSString *query;
        NSString * workOrderCurrency = [appDelegate.workOrderCurrency stringByReplacingOccurrencesOfString:@" " withString:@""];
		if (![appDelegate.workOrderCurrency isEqualToString:@""])
			query = [NSString stringWithFormat:@"SELECT SPR14__Billable_Cost2__c FROM SPR14__Service_Group_Costs__c WHERE SPR14__Service_Group__c = '%@' AND SPR14__Cost_Category__c = 'Straight' AND CurrencyIsoCode = '%@' LIMIT 1", appDelegate.appServiceTeamId, workOrderCurrency];
		else
			query = [NSString stringWithFormat:@"SELECT SPR14__Billable_Cost2__c FROM SPR14__Service_Group_Costs__c WHERE SPR14__Service_Group__c = '%@' AND SPR14__Cost_Category__c = 'Straight' LIMIT 1", appDelegate.appServiceTeamId];
		[[ZKServerSwitchboard switchboard] query:query target:self selector:@selector(getPriceForServiceTeam:error:context:) context:nil];
	}
	else
	{
        ZKSObject * obj = [array objectAtIndex:0];
        rate = [[[obj fields] objectForKey:@"SPR14__Billable_Cost2__c"] retain];
		
		if (rate == nil || [rate isKindOfClass:[NSNull class]])
			rate = @"0.0";
        
		NSArray *keys = [LabourValuesDictionary allKeys];
        for( int i = 0; i < [keys count]; i++ )
        {
            NSRange range = [(NSString *)[keys objectAtIndex:i] rangeOfString:@"Rate_"];
            if( !NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) )
            {
                if (calculateLaborPrice)
                    if ([[LabourValuesDictionary valueForKey:[keys objectAtIndex:i]]isEqualToString:@"0.0"])
                        [LabourValuesDictionary setValue:rate forKey:[keys objectAtIndex:i]];
            }
        }
		
        /*
		if ( ![keys count] )
		{
			[LabourValuesDictionary setValue:@"0" forKey:RATE_CALIBRATION];
			[LabourValuesDictionary setValue:@"0" forKey:RATE_CLEANUP];
			[LabourValuesDictionary setValue:@"0" forKey:RATE_INSTALLATION];
			[LabourValuesDictionary setValue:@"0" forKey:RATE_REPAIR];
			[LabourValuesDictionary setValue:@"0" forKey:RATE_SERVICE];
		}
        */
        
        NSBundle *MainBundle = [NSBundle mainBundle];
        NSString *SettingsBundlePath = [MainBundle pathForResource:@"Settings" ofType:@"bundle"];
        NSBundle *SettingsBundle = [NSBundle bundleWithPath:SettingsBundlePath];
        NSString *RootPlistPath = [SettingsBundle pathForResource:@"Root" ofType:@"plist"];
        [appDelegate.Dictionaries writeToFile:RootPlistPath atomically:YES];
        
        dataloaded = YES;
	}
	}@catch (NSException *exp) {
	SMLog(kLogLevelError,@"Exception Name LabourViewController :getPriceForLabor %@",exp.name);
	SMLog(kLogLevelError,@"Exception Reason LabourViewController :getPriceForLabor %@",exp.reason);
	  [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

}

- (void) getPriceForServiceTeam:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
@try{
	NSArray * array = [result records];
    
    if ((array == nil) || ([array count] == 0))
        groupCostsPresent = NO;
    else
        groupCostsPresent = YES;
	
	for (int i = 0; i < [array count]; i++)
	{
		ZKSObject * obj = [array objectAtIndex:i];
		
		// Check the query. use dictionary value extraction technique, for e.g.
		SMLog(kLogLevelVerbose,@"%@", [[obj fields] objectForKey:@"SPR14__Billable_Cost2__c"]);
		//[md setValue:[[obj fields] objectForKey:@"SPR14__Actual_Quantity2__c"] forKey:[[obj fields] objectForKey:@"SPR14__Activity_Type__c"]];
		rate = [[[obj fields] objectForKey:@"SPR14__Billable_Cost2__c"] retain];
        if (rate == nil || [rate isKindOfClass:[NSNull class]])
			rate = @"0.0";
	}
    
    // If Settings are present
        // If Group Costs are present
            // If CalculateLaborPrice
                // use GroupCosts
            // else i.e. timeAndMaterial count == 0
                // use 0 values
        // else
            // use 0 values
    // else
        // use GroupCosts
	
	NSArray *keys = [LabourValuesDictionary allKeys];
    if (settingsPresent)
    {
        if (groupCostsPresent)
        {
            if (calculateLaborPrice)
            {
                for( int i = 0; i < [keys count]; i++ )
                {
                    NSRange range = [(NSString *)[keys objectAtIndex:i] rangeOfString:@"Rate_"];
                    if( !NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) )
                    {
                        BOOL flag = NO;
                        for (int j = 0; j < [linePriceItems count]; j++)
                        {
                            NSString * str = [NSString stringWithFormat:@"Rate_%@", [linePriceItems objectAtIndex:j]];
                            if ([[keys objectAtIndex:i] isEqualToString:str])
                            {
                                flag = YES;
                                break;
                            }
                        }
                        if (!flag)
                            [LabourValuesDictionary setValue:rate forKey:[keys objectAtIndex:i]];
                    }
                }
            }
            /*
            else
            {
                if ([[LabourValuesDictionary objectForKey:RATE_CALIBRATION] floatValue] == 0)
                    [LabourValuesDictionary setValue:@"0" forKey:RATE_CALIBRATION];
                if ([[LabourValuesDictionary objectForKey:RATE_CLEANUP] floatValue] == 0)
                    [LabourValuesDictionary setValue:@"0" forKey:RATE_CLEANUP];
                if ([[LabourValuesDictionary objectForKey:RATE_INSTALLATION] floatValue] == 0)
                    [LabourValuesDictionary setValue:@"0" forKey:RATE_INSTALLATION];
                if ([[LabourValuesDictionary objectForKey:RATE_REPAIR] floatValue] == 0)
                    [LabourValuesDictionary setValue:@"0" forKey:RATE_REPAIR];
                if ([[LabourValuesDictionary objectForKey:RATE_SERVICE] floatValue] == 0)
                    [LabourValuesDictionary setValue:@"0" forKey:RATE_SERVICE];
            }
            */
        }
        /*
        else
        {
            [LabourValuesDictionary setValue:@"0" forKey:RATE_CALIBRATION];
            [LabourValuesDictionary setValue:@"0" forKey:RATE_CLEANUP];
            [LabourValuesDictionary setValue:@"0" forKey:RATE_INSTALLATION];
            [LabourValuesDictionary setValue:@"0" forKey:RATE_REPAIR];
            [LabourValuesDictionary setValue:@"0" forKey:RATE_SERVICE];
        }*/
    }
    else
    {
        if (groupCostsPresent)
        {
            for( int i = 0; i < [keys count]; i++ )
            {
                NSRange range = [(NSString *)[keys objectAtIndex:i] rangeOfString:@"Rate_"];
                if( !NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) )
                {
                    // Overwrite only if Rate value = 0
                    float _rate = [[LabourValuesDictionary objectForKey:[keys objectAtIndex:i]] floatValue];
                    if (_rate == 0.0 && calculateLaborPrice)
                        [LabourValuesDictionary setValue:rate forKey:[keys objectAtIndex:i]];
                }
            }
        }
    }

    /*
    if (calculateLaborPrice)
    {
        for( int i = 0; i < [keys count]; i++ )
        {
            NSRange range = [(NSString *)[keys objectAtIndex:i] rangeOfString:@"Rate_"];
            if( !NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) )
            {
                [LabourValuesDictionary setValue:rate forKey:[keys objectAtIndex:i]];
            }
        }
    }
    */
	
    /*
	if (!settingsPresent && ![array count])
	{
		[LabourValuesDictionary setValue:@"0" forKey:RATE_CALIBRATION];
		[LabourValuesDictionary setValue:@"0" forKey:RATE_CLEANUP];
		[LabourValuesDictionary setValue:@"0" forKey:RATE_INSTALLATION];
		[LabourValuesDictionary setValue:@"0" forKey:RATE_REPAIR];
		[LabourValuesDictionary setValue:@"0" forKey:RATE_SERVICE];
	}
    */
	
	NSBundle *MainBundle = [NSBundle mainBundle];
	NSString *SettingsBundlePath = [MainBundle pathForResource:@"Settings" ofType:@"bundle"];
	NSBundle *SettingsBundle = [NSBundle bundleWithPath:SettingsBundlePath];
	NSString *RootPlistPath = [SettingsBundle pathForResource:@"Root" ofType:@"plist"];
	[appDelegate.Dictionaries writeToFile:RootPlistPath atomically:YES];
	
	dataloaded = YES;
	}@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name LabourViewController :getPriceForServiceTeam %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason LabourViewController :getPriceForServiceTeam %@",exp.reason);
       [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
}

//  Unused methods
//- (NSString *) GetLaborRate
//{
//	return rate;
//}

- (IBAction) ShowDesc:(NSString *)sender
{
}

@end
