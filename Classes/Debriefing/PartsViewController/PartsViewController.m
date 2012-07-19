    //
//  PartsViewController.m
//  Debriefing
//
//  Created by Sanchay on 9/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PartsViewController.h"

@implementation PartsViewController

@synthesize parent, PartsTable;

@synthesize willRecoverFromMemoryError;

@synthesize didSelectPartsSearch;

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
	
	appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableDictionary *Dictionaries = appDelegate.Dictionaries;
    
    // Set Default Value
    userCanChangePartsPrice = YES;
    
    if ([appDelegate.timeAndMaterial count] > 0)
    {
        for (int i = 0; i < [appDelegate.timeAndMaterial count]; i++)
        {
            NSDictionary * dict = [appDelegate.timeAndMaterial objectAtIndex:i];
            NSString * key = [[dict allKeys] objectAtIndex:0];
            // if ([key isEqualToString:@"User Can Change Parts Price"])
            if ([key isEqualToString:@"IPAD002_SET001"])
            {
                NSString * userCanChangePartsPriceStr = [dict objectForKey:key];
                if ([userCanChangePartsPriceStr isEqualToString:@"true"])
                    userCanChangePartsPrice = YES;
                else
                    userCanChangePartsPrice = NO;
            }
        }
    }
	
	if(Dictionaries == nil)
	{
		NSBundle *MainBundle = [NSBundle mainBundle];
		//Dictionaries = [[MainBundle objectForInfoDictionaryKey:@"Dictionaries"] retain];
		
		NSString *SettingsBundlePath = [MainBundle pathForResource:@"Settings" ofType:@"bundle"];
		NSBundle *SettingsBundle = [NSBundle bundleWithPath:SettingsBundlePath];
		NSString *RootPlistPath = [SettingsBundle pathForResource:@"Root" ofType:@"plist"];
		Dictionaries = appDelegate.Dictionaries = [[NSMutableDictionary alloc] initWithContentsOfFile:RootPlistPath];
	}

    if (willRecoverFromMemoryError)
    {
        Parts = [(NSMutableArray *)[(NSDictionary *)[Dictionaries valueForKey:@"Dictionaries"] valueForKey:@"Parts"]retain];
        [PartsTable reloadData];
        [activity stopAnimating];
        willRecoverFromMemoryError = NO;
        return;
    }
	
	//load Parts
	//Parts = [(NSMutableArray *)[Dictionaries valueForKey:@"Parts"] retain];
    Parts = [(NSMutableArray *)[(NSDictionary *)[Dictionaries valueForKey:@"Dictionaries"] valueForKey:@"Parts"]retain];
    [Parts removeAllObjects];
	
	AllParts = [[NSMutableArray alloc] initWithCapacity:0];
	int AllPartsIndex = 0;
	for( int i = 0; i < [Parts count]; i++ )
	{
		NSArray *RowParts = [Parts objectAtIndex:i];
		for (int j = 0; j < [RowParts count]; j++)
		{
			NSDictionary *Part = (NSDictionary *)[RowParts objectAtIndex:j];
			[AllParts insertObject:Part atIndex:AllPartsIndex];
			AllPartsIndex++;
		}
	}

	[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(run) userInfo:nil repeats:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
}

-(void)run
{
	dataloaded = NO;
	[self initDebriefData];
	
//	while( CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE) && !dataloaded);
	while (!dataloaded) {
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE);
	}

	// Before loading PartsTable make sure there are no NSNull entries
    for (int i = 0; i < [Parts count]; i++)
    {
        if ([[Parts objectAtIndex:i] isKindOfClass:[NSNull class]])
            [Parts removeObjectAtIndex:i];
    }

	[PartsTable reloadData];
    [activity stopAnimating];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)didReceiveMemoryWarning
{
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
        [Parts release];
    [super dealloc];
}

// initDebrief Callback Method
- (void) initDebriefData
{
//pavaman 26th Feb 2011 - adding discount field to the query string
	NSString *query = [NSString stringWithFormat:@"SELECT Id, SVMXC__Product__c, SVMXC__Product__r.Name, SVMXC__Actual_Quantity2__c, SVMXC__Actual_Price2__c, SVMXC__Work_Description__c, SVMXC__Discount__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Line_Type__c = 'Parts' AND SVMXC__Service_Order__c = '%@' AND RecordTypeId = '%@' AND SVMXC__Actual_Quantity2__c > 0 AND SVMXC__Actual_Price2__c >= 0", appDelegate.currentWorkOrderId, appDelegate.usageConsumptionRecordId]; // a0oA0000000UXEsIAO
	[[ZKServerSwitchboard switchboard] query:query target:self selector:@selector(getParts:error:context:) context:nil];
}

- (void) getParts:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
	NSArray * array = [result records];
    appDelegate.partsZKSArray = [array retain];
	for (int i = 0; i < [array count]; i++)
	{
		ZKSObject * obj = [array objectAtIndex:i];
		NSDictionary * dict = [obj fields];
		// Check the query. use dictionary value extraction technique, for e.g.
		//NSLog(@"SVMXC__Product__r.Name = %@", [[[[obj fields] objectForKey:@"SVMXC__Product__r"] fields] objectForKey:@"Name"] );
		NSLog(@"SVMXC__Product__c = %@", [[obj fields] objectForKey:@"SVMXC__Product__c"] );
        NSMutableDictionary *Part = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
        
        ZKSObject * obj2 = [[obj fields] objectForKey:@"SVMXC__Product__r"];
        NSDictionary * SVMXC__Product__r = [obj2 isKindOfClass:[NSNull class]]?nil:[obj2 fields];
        if (SVMXC__Product__r != nil)
        {
            NSString * partName = [[SVMXC__Product__r objectForKey:@"Name"] isKindOfClass:[NSString class]]?[SVMXC__Product__r objectForKey:@"Name"]:@"";
            [Part setObject:partName forKey:@"Name"];
        }
        
        NSString * numPartsUsed = [dict objectForKey:@"SVMXC__Actual_Quantity2__c"];
        if ([numPartsUsed isKindOfClass:[NSString class]])
            [Part setObject:[NSString stringWithFormat:@"%d", [numPartsUsed intValue]] forKey:@"PartsUsed"];

        NSString * description = [dict objectForKey:@"SVMXC__Work_Description__c"];
        if ([description isKindOfClass:[NSString class]])
            [Part setObject:[NSString stringWithFormat:@"%@", description] forKey:KEY_PARTDESCRIPTION];

        [Part setObject:obj forKey:CONSUMEDPARTS];
        
        if ([Part objectForKey:KEY_COSTPERPART] == nil)
            [Part setObject:[[obj fields] objectForKey:@"SVMXC__Actual_Price2__c"] forKey:KEY_COSTPERPART];
        
        if ([Part objectForKey:KEY_PRODUCTID] == nil)
            [Part setObject:[[obj fields] objectForKey:@"SVMXC__Product__c"] forKey:KEY_PRODUCTID];
		
		//pavaman 26th Feb 2011 - adding discount field
        NSString * discount = [dict objectForKey:@"SVMXC__Discount__c"];
        if ([discount isKindOfClass:[NSString class]])
            [Part setObject:[NSString stringWithFormat:@"%@", discount] forKey:KEY_DISCOUNT];
		
        
        [Parts addObject:Part];
	}
    
    if (appDelegate.Parts != nil)
    {
        [appDelegate.Parts release];
        appDelegate.Parts = nil;
    }
    appDelegate.Parts = [Parts retain];
    
    if ([parent respondsToSelector:@selector(PopulateData)])
        [parent performSelector:@selector(PopulateData)];
    
    dataloaded = YES;
}

#pragma mark UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return PARTS_TABLEVIEW_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView reloadData];
    if([self.parent respondsToSelector:@selector(PopulateData)])
	{
		[self.parent performSelector:@selector(PopulateData)];
	}
}

#pragma mark UITableViewDataSource methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *CellIdentifier = [NSString stringWithFormat:@"%@-%d", PARTS_TABLEVIEW_CELL_IDENTIFIER, indexPath.row];
	PartsTableViewCell *Cell = (PartsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if( Cell == nil )
	{
		PartsTableViewCell *PTVCObj = [[PartsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
		NSArray *Objs = [[NSBundle mainBundle] loadNibNamed:@"PartsTableViewCell" owner:PTVCObj options:nil];
        
        // Analyser
        [PTVCObj release];
        
		for( id Obj in Objs )
		{
			if( [Obj isKindOfClass:[UITableViewCell class]] )
			{
				Cell = (PartsTableViewCell *)Obj;
				break;
			}
		}
	}

	Cell.selectionStyle = UITableViewCellSelectionStyleNone;
	Cell.opaque = NO;
	Cell.backgroundColor = [UIColor clearColor];
	
	return Cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [Parts count];
}

// PriceBook data retrieve

- (void) getPriceBook
{
    //get pricebook settings
	NSString *query = [NSString stringWithFormat:@"SELECT Id FROM Pricebook2 WHERE Name='%@'", appDelegate.priceBookName];
	[[ZKServerSwitchboard switchboard] query:query target:self selector:@selector(getPriceBookId:error:context:) context:nil];
}

- (void) getPriceBookId:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    NSString * pricebookId = @"";
	NSArray * array = [result records];
	for (int i = 0; i < [array count]; i++)
	{
		ZKSObject * obj = [array objectAtIndex:i];

		// Check the query. use dictionary value extraction technique, for e.g.
		NSLog(@"Pricebook Id = %@", [[obj fields] objectForKey:@"Id"]);
		pricebookId = [[obj fields] objectForKey:@"Id"];
	}	

//pavaman 25th Jan 2011 - multicurrency handling
	
	NSString *query;
	NSString * workOrderCurrency = [appDelegate.workOrderCurrency stringByReplacingOccurrencesOfString:@" " withString:@""];	
	if (![appDelegate.workOrderCurrency isEqualToString:@""])
		query = [NSString stringWithFormat:@"SELECT Name, Product2Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = '%@' AND CurrencyIsoCode = '%@' AND Product2Id IN %@", pricebookId, workOrderCurrency, appDelegate.productIdList];	
	else	
		query = [NSString stringWithFormat:@"SELECT Name, Product2Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = '%@' AND Product2Id IN %@", pricebookId, appDelegate.productIdList];	
	
	[[ZKServerSwitchboard switchboard] query:query target:self selector:@selector(getProductPrices:error:context:) context:nil];
	
}

- (void) getProductPrices:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    // samman 06 Mar 2011 - add parts even if product does not have price book entry
    NSString * _query = [NSString stringWithFormat:@"SELECT Id, Name, ProductCode, Family, SVMXC__Product_Line__c FROM Product2 WHERE Id IN %@", appDelegate.productIdList];
    // NSString * _query = [NSString stringWithFormat:@"SELECT ", appDelegate.productIdList];
    [[ZKServerSwitchboard switchboard] query:_query target:self selector:@selector(didGetProductDetails:error:context:) context:result];
    
//	NSArray * array = [result records];
    
}

- (void) didGetProductDetails:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    NSArray * partsArray = [result records];
    
    ZKQueryResult * productPrices = (ZKQueryResult *)context;
    NSArray * productPriceArray = [productPrices records];
    
    for (int i = 0; i < [partsArray count]; i++)
    {
        NSDictionary * partsDict = [[partsArray objectAtIndex:i] fields];
        NSDictionary * priceDict = nil;
        for (int j = 0; j < [productPriceArray count]; j++)
        {
            priceDict = [[productPriceArray objectAtIndex:j] fields];
            if ([[priceDict objectForKey:@"Product2Id"] isEqualToString:[partsDict objectForKey:@"Id"]])
                break;
            else
                priceDict = nil;
        }

        NSMutableDictionary *Part = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
        
        if (priceDict != nil)
        {
            [Part setObject:[priceDict objectForKey:@"Name"] forKey:KEY_NAME];
            [Part setObject:[NSString stringWithFormat:@"%d", 1] forKey:KEY_PARTSUSED]; // Obtain from pricebook (context)
            [Part setObject:[priceDict objectForKey:@"UnitPrice"] forKey:KEY_COSTPERPART];   // Obtain from pricebook (context)
            [Part setObject:[priceDict objectForKey:@"Product2Id"] forKey:KEY_PRODUCTID];    // Obtain from pricebook (context)
            [Part setObject:@"true" forKey:KEY_USEPRICEBOOK];
        }
        else
        {
            [Part setObject:[partsDict objectForKey:@"Name"] forKey:KEY_NAME];
            [Part setObject:@"1" forKey:KEY_PARTSUSED];
            [Part setObject:@"0.0" forKey:KEY_COSTPERPART];
            [Part setObject:[partsDict objectForKey:@"Id"] forKey:KEY_PRODUCTID];
            [Part setObject:@"false" forKey:KEY_USEPRICEBOOK];
        }
        
        [Part setObject:[NSNull null] forKey:CONSUMEDPARTS];
		
		[Part setObject:@"0.0" forKey:KEY_DISCOUNT];                                // Obtain from pricebook (context)
        
        [Parts addObject:Part];
    }
    appDelegate.Parts = [Parts retain];
    [PartsTable reloadData];
    [activity stopAnimating];
    
    if([self.parent respondsToSelector:@selector(PopulateData)])
	{
		[self.parent performSelector:@selector(PopulateData)];
	}
}

@end
