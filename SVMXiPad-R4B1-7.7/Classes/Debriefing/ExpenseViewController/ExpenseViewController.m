//
//  ExpenseViewController.m
//  Debriefing
//
//  Created by Sanchay on 9/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ExpenseViewController.h"

extern void SVMXLog(NSString *format, ...);
@implementation ExpenseViewController

@synthesize parent;

@synthesize willRecoverFromMemoryError;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
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
	
	AppDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableDictionary *Dictionaries = AppDelegate.Dictionaries;
	
	if( Dictionaries == nil )
	{
		NSBundle *MainBundle = [NSBundle mainBundle];
		
		NSString *SettingsBundlePath = [MainBundle pathForResource:@"Settings" ofType:@"bundle"];
		NSBundle *SettingsBundle = [NSBundle bundleWithPath:SettingsBundlePath];
		NSString *RootPlistPath = [SettingsBundle pathForResource:@"Root" ofType:@"plist"];
		Dictionaries = AppDelegate.Dictionaries = [[NSMutableDictionary alloc] initWithContentsOfFile:RootPlistPath];
	}
	
	ExpenseDictionary = [(NSDictionary *)[(NSDictionary *)[Dictionaries valueForKey:@"Dictionaries"] valueForKey:@"Expenses"] retain];
	
	dataloaded = NO;
	
    {
        [self InitExpenseData];
		while (!dataloaded)
        {
			CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE);
		}
    }
	
	Airfare.text = [[ExpenseDictionary valueForKey:AIRFARE] isKindOfClass:[NSString class]]?[ExpenseDictionary valueForKey:AIRFARE]:@"";
	Breakfast.text = [[ExpenseDictionary valueForKey:BREAKFAST] isKindOfClass:[NSString class]]?[ExpenseDictionary valueForKey:BREAKFAST]:@"";
	Dinner.text = [[ExpenseDictionary valueForKey:DINNER] isKindOfClass:[NSString class]]?[ExpenseDictionary valueForKey:DINNER]:@"";
	Lodging.text = [[ExpenseDictionary valueForKey:LODGING] isKindOfClass:[NSString class]]?[ExpenseDictionary valueForKey:LODGING]:@"";
	Parking.text = [[ExpenseDictionary valueForKey:PARKING] isKindOfClass:[NSString class]]?[ExpenseDictionary valueForKey:PARKING]:@"";
	Entertainment.text = [[ExpenseDictionary valueForKey:ENTERTAINMENT] isKindOfClass:[NSString class]]?[ExpenseDictionary valueForKey:ENTERTAINMENT]:@"";
	Lunch.text = [[ExpenseDictionary valueForKey:LUNCH] isKindOfClass:[NSString class]]?[ExpenseDictionary valueForKey:LUNCH]:@"";
	Gas.text = [[ExpenseDictionary valueForKey:GAS] isKindOfClass:[NSString class]]?[ExpenseDictionary valueForKey:GAS]:@"";
	Mileage.text = [[ExpenseDictionary valueForKey:MILEAGE] isKindOfClass:[NSString class]]?[ExpenseDictionary valueForKey:MILEAGE]:@"";
	Parts.text = [[ExpenseDictionary valueForKey:PARTS] isKindOfClass:[NSString class]]?[ExpenseDictionary valueForKey:PARTS]:@"";
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[self SaveData];
}

- (void)SaveData
{	
	[ExpenseDictionary setValue:Airfare.text forKey:AIRFARE];
	[ExpenseDictionary setValue:Breakfast.text forKey:BREAKFAST];
	[ExpenseDictionary setValue:Dinner.text forKey:DINNER];
	[ExpenseDictionary setValue:Lodging.text forKey:LODGING];
	[ExpenseDictionary setValue:Parking.text forKey:PARKING];
	[ExpenseDictionary setValue:Entertainment.text forKey:ENTERTAINMENT];
	[ExpenseDictionary setValue:Lunch.text forKey:LUNCH];
	[ExpenseDictionary setValue:Gas.text forKey:GAS];
	[ExpenseDictionary setValue:Mileage.text forKey:MILEAGE];
	[ExpenseDictionary setValue:Parts.text forKey:PARTS];

	NSBundle *MainBundle = [NSBundle mainBundle];
	NSString *SettingsBundlePath = [MainBundle pathForResource:@"Settings" ofType:@"bundle"];
	NSBundle *SettingsBundle = [NSBundle bundleWithPath:SettingsBundlePath];
	NSString *RootPlistPath = [SettingsBundle pathForResource:@"Root" ofType:@"plist"];
	
	AppDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
	[AppDelegate.Dictionaries writeToFile:RootPlistPath atomically:YES];

	[popover release];
	popover = nil;
	[keyboard release];
	keyboard = nil;
	
	if( [parent respondsToSelector:@selector(PopulateData)] )
	{
		[parent performSelector:@selector(PopulateData)];
	}
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	keyboard = [[PopOverKeyboard alloc] initWithNibName:[PopOverKeyboard description] bundle:nil];
	[keyboard.view becomeFirstResponder];
	keyboard.parent = self;
	
	popover = [[UIPopoverController alloc] initWithContentViewController:keyboard];
	[popover setContentViewController:keyboard];
	[popover setPopoverContentSize:keyboard.view.frame.size];
	
	keyboard.txtField = textField;
	
	popover.delegate = self;
	
	if( textField.tag == 0 )
	{
		[popover presentPopoverFromRect:textField.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
	}
	else
	{
		[popover presentPopoverFromRect:textField.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
	}
	return NO;
}

- (void)keyboardWillShow:(id)sender
{
	NSNotification *not = (NSNotification *)sender;
	UITextField *txtFld = (UITextField *)[not object];
	[txtFld resignFirstResponder];
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
    [super dealloc];
}

- (void) InitExpenseData
{
	NSString *query = [NSString stringWithFormat:@"SELECT Id, SVMXC__Expense_Type__c, SVMXC__Actual_Price2__c, SVMXC__Work_Description__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Line_Type__c = 'Expenses' AND SVMXC__Service_Order__c = '%@' AND RecordTypeId = '%@'", AppDelegate.currentWorkOrderId, AppDelegate.usageConsumptionRecordId]; // a0oA0000000UXEsIAO
	[[ZKServerSwitchboard switchboard] query:query target:self selector:@selector(getExpenses:error:context:) context:nil];
}

- (void) getExpenses:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
	NSArray * array = [result records];
    
    AppDelegate.expensesZKSArray = [array retain];
	
	NSMutableDictionary *md = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	for (int i = 0; i < [array count]; i++)
	{
		ZKSObject * obj = [array objectAtIndex:i];
		
		// Check the query. use dictionary value extraction technique, for e.g.
		NSLog(@"%@", [[obj fields] objectForKey:@"SVMXC__Expense_Type__c"]);
		[md setValue:[[obj fields] objectForKey:@"SVMXC__Actual_Price2__c"] forKey:[[obj fields] objectForKey:@"SVMXC__Expense_Type__c"]];
		NSString *key, *value;
		key = [[obj fields] objectForKey:@"SVMXC__Expense_Type__c"];
		value = [[obj fields] objectForKey:@"SVMXC__Work_Description__c"];
		if ( key != nil )
			[md setValue:value forKey:[NSString stringWithFormat:@"%@_%@", key, DESCRIPTION ]];
	}

	NSArray *keys = [md allKeys];
    
    //pavaman 1st Jan 2011
	NSArray *dict_keys = [ExpenseDictionary allKeys];
	for (int i =0; i < [dict_keys count];i++)
	{
		NSLog(@"%@",[dict_keys objectAtIndex:i]); 
		NSString *value;
		value = [md valueForKey:[dict_keys objectAtIndex:i]];
		if (value == nil)
			value = @"";
		[ExpenseDictionary setValue:value forKey:[dict_keys objectAtIndex:i]];
	}
	
	//pavaman 1st Jan 2011 - above loop should ideally replace the below. However, DESCRIPTION fields are not by default present in the ExpenseDictionary and below takes care of it. But, there is some redundancy
    
	for( int i = 0; i < [keys count]; i++ )
	{
		[ExpenseDictionary setValue:[md valueForKey:[keys objectAtIndex:i]] forKey:[keys objectAtIndex:i]];
	}

    // Analyser
    [md release];

	AppDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];

	NSBundle *MainBundle = [NSBundle mainBundle];
	NSString *SettingsBundlePath = [MainBundle pathForResource:@"Settings" ofType:@"bundle"];
	NSBundle *SettingsBundle = [NSBundle bundleWithPath:SettingsBundlePath];
	NSString *RootPlistPath = [SettingsBundle pathForResource:@"Root" ofType:@"plist"];
	[AppDelegate.Dictionaries writeToFile:RootPlistPath atomically:YES];

	AppDelegate.Expenses = [ExpenseDictionary retain];

	dataloaded = YES;
}

- (IBAction) ShowDesc:(id)sender
{
	
}

@end
