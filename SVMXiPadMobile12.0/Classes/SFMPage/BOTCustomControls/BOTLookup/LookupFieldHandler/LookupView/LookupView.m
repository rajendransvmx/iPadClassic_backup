//
//  LookupView.m
//  SVNTest
//
//  Created by Samman on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LookupView.h"
#import "WSInterface.h"
#import "iServiceAppDelegate.h"

/* Vipin start Advanced Lookup*/
#import "SVMXLookupFilter.h"
#define kFlipAnimationSpeed 0.5
#define kTableviewTag       1022
#define kFilterNameLabelTag 1801
#define kkFilterSwitchTag   1802
/* Vipin ends */

static NSString *const kCellBackgroundColorForDisableState = @"f4f3f1";


extern void SVMXLog(NSString *format, ...);

//Vipin - Advanced Lookup
@interface LookupView (hidden)
- (void)loadLookupFilters;
@end


@implementation LookupView

@synthesize delegate;
@synthesize lookupData, popover;
@synthesize objectName, searchKey,searchId;
@synthesize history;
@synthesize label_key;

//Vipin - Advanced Lookup
@synthesize preFilters,advancedFilters;
@synthesize advancedFilterView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [describeObject release];
    [lookupData release];
    [popover release];
    [preFilters release];
    [advancedFilters release];
    [advancedFilterView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction) segmentChanged:(id)sender;
{    
    if ([segmentControl selectedSegmentIndex] == 1)
    {
        // Clear History
    }
}
 -(void) updateTxtField: (NSString *) barCodeData
{
        //  get the subView which is text field
        // update the txt field text with barCodeData
        // call the delegate method to start searching
    if(appDelegate==nil)
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];

    if([appDelegate isCameraAvailable])
    {
        for (UIView *subview in searchBar.subviews)
        {
            if ([subview conformsToProtocol:@protocol(UITextInputTraits)])
            {                
                txtField = (UITextField *)subview;
                txtField.text=barCodeData;
                //[self reloadInputViews];
               // txtField.inputAccessoryView = barCodeView;
                
            }
            
        }
        
    }

}

#pragma mark - Flip View Management

- (void)advanceFilterSelectionDoneButtonClicked:(id)sender {
     [delegate getSearchIdandObjectName:searchBar.text];
    
    [UIView transitionFromView:self.advancedFilterView
                        toView:self.view
                      duration:kFlipAnimationSpeed
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    completion:^(BOOL finished) {
                        
                        
                        UIBarButtonItem *someItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter-icon.png"]
                                                                                     style:UIBarButtonItemStyleDone
                                                                                    target:self
                                                                                    action:@selector(advancedFilterButtonClicked:)];
                        
                        self.navigationItem.rightBarButtonItem = someItem;
                        
                    }];
    

      
}


- (void)advancedFilterButtonClicked:(id)sender {
    
  
    [searchBar resignFirstResponder];
    [self.popover setPopoverContentSize:CGSizeMake(320, 1100) animated:YES];
    self.contentSizeForViewInPopover = CGSizeMake(320, 1100);
    

    if (advancedFilterView == nil) {
        
        UIView *filterView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                            0,
                                                                            self.view.frame.size.width,
                                                                            self.view.frame.size.height)];
        self.advancedFilterView = filterView;
        [filterView release];
        
        [self.view addSubview:advancedFilterView];
        advancedFilterView.backgroundColor = [UIColor whiteColor];
        [self.view sendSubviewToBack:advancedFilterView];
        
        // Create TableView to display Advanced filter items
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                               0,
                                                                               advancedFilterView.frame.size.width,
                                                                               advancedFilterView.frame.size.height + 100)];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.tag = kTableviewTag;
        [advancedFilterView addSubview:tableView];
        [tableView  release];
        tableView = nil;
    }
    
    self.advancedFilterView.frame = CGRectMake(0,
                                               0,
                                               self.view.frame.size.width,
                                               self.view.frame.size.height);
    
    [UIView transitionFromView:self.view
                        toView:advancedFilterView
                      duration:kFlipAnimationSpeed
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:^(BOOL finished) {
                        // animation completed
                        UIBarButtonItem *someItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                                  target:self
                                                                                                  action:@selector(advanceFilterSelectionDoneButtonClicked:)];
                        self.navigationItem.rightBarButtonItem = someItem;
                        
                    }];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [searchBar becomeFirstResponder];
    // Do any additional setup after loading the view from its nib.
    // [delegate searchObject:@"" withObjectName:objectName];
    if (history)
        [segmentControl setSelectedSegmentIndex:0];
    else
        [segmentControl setSelectedSegmentIndex:1];
    
    if([appDelegate isCameraAvailable])
    {
        for (UIView *subview in searchBar.subviews)
        {
            if ([subview conformsToProtocol:@protocol(UITextInputTraits)])
            {                
                //[ setClearButtonMode:UITextFieldViewModeWhileEditing];
                
                UIView *barCodeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 46)];
                barCodeView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"accessoryView_bg.png"]];
                UIButton *barCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(676, 4, 72, 37)];
                [barCodeButton setBackgroundImage:[UIImage imageNamed:@"BarCodeButton.png"] forState:UIControlStateNormal];
                barCodeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;               
                [barCodeButton addTarget:self 
                                  action:@selector(DismissPopover) 
                               forControlEvents:UIControlEventTouchUpInside];
                [barCodeView addSubview:barCodeButton];
                txtField = (UITextField *)subview;
                txtField.inputAccessoryView = barCodeView;
                
            }
            
        }
        
    }
    
    //Vipin - Advanced Lookup
    [self loadLookupFilters];
    
    // Add filter icon on navigation bar
    UIBarButtonItem *filterButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter-icon.png"]
                                                                         style:UIBarButtonItemStyleDone
                                                                        target:self
                                                                        action:@selector(advancedFilterButtonClicked:)];
    
    if ( (self.advancedFilters != nil) &&  ([self.advancedFilters count] > 0) )
    {
        filterButtonItem.enabled = YES;
    }else
    {
        filterButtonItem.enabled = NO;
    }
    
    self.navigationItem.rightBarButtonItem = filterButtonItem;
    [filterButtonItem release];
}

-(void)DismissPopover
{
    [delegate DismissLookupFieldPopover];
}


#pragma mark - search bar  delegate method

- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
    if ([_searchBar.text length] == 0)
        _searchBar.text = @" ";
}

- (void)viewWillAppear:(BOOL)animated
{    
    [super viewWillAppear:animated];
}

- (void) reloadData
{
    [_tableView reloadData];
    [activity stopAnimating];
}

#pragma mark - UISearchBar Delegate Method
- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    /*if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    }*/
    
    if ( !appDelegate.isWorkinginOffline ) {
        if([searchId isEqualToString:@""])
        {
            idAvailable = FALSE; 
            [delegate searchObject:_searchBar.text withObjectName:objectName returnTo:self setting:idAvailable];
        }
        else
        {
            idAvailable = TRUE;
            [delegate searchObject:_searchBar.text withObjectName:searchId returnTo:self setting:idAvailable];
        }
        
        [activity startAnimating];
    }
    
    else {
        //call the delegate here
        [delegate getSearchIdandObjectName:_searchBar.text];
        
    }

    [activity startAnimating];
}
- (void)searchBarCodeScannerData:(NSString *)_searchBartext
{
    /*if (![appDelegate isInternetConnectionAvailable])
     {
     [activity stopAnimating];
     [appDelegate displayNoInternetAvailable];
     return;
     }*/
    
    if ( !appDelegate.isWorkinginOffline ) {
        if([searchId isEqualToString:@""])
        {
            idAvailable = FALSE; 
            [delegate searchObject:_searchBartext withObjectName:objectName returnTo:self setting:idAvailable];
        }
        else
        {
            idAvailable = TRUE;
            [delegate searchObject:_searchBartext withObjectName:searchId returnTo:self setting:idAvailable];
        }
        
        [activity startAnimating];
    }
    
    else {
        //call the delegate here
        [delegate getSearchIdandObjectName:_searchBartext];
        
    }
    
    [activity startAnimating];
}





- (void) setLookupData:(NSDictionary *)lookupDictionary
{
	@try{
    if(appDelegate.isWorkinginOffline)
    {
        lookupData = [lookupDictionary retain];
        
        NSArray * sequenceArray  = [lookupData objectForKey:@"SEQUENCE"];
        NSMutableArray * allkeys = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (int i = 0; i < [sequenceArray count]; i++)
        {
            NSDictionary * dict = [sequenceArray objectAtIndex:i];
            NSArray * keys = [dict allKeys];
            for(int j = 0 ; j < [keys count]; j++)
            {
                [allkeys addObject:[keys objectAtIndex:j]];
            }
        }
        
        label_key = [appDelegate.databaseInterface queryTheObjectInfoTable:allkeys tableName:SFOBJECTFIELD object_name:objectName];
    }else {
        
        NSDictionary * _lookupDetails = [lookupDictionary objectForKey:gLOOKUP_DETAILS];
        describeObject = [[lookupDictionary objectForKey:gLOOKUP_DESCRIBEOBJECT] retain];
        lookupData = _lookupDetails;
    }
   }@catch (NSException *exp) {
        SMLog(@"Exception Name LookupView :setLookupData %@",exp.name);
        SMLog(@"Exception Reason LookupView :setLookupData %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    [self reloadData];
    
    [activity stopAnimating];
    activity = nil;
    [searchBar resignFirstResponder];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == kTableviewTag )
    {
        return ;
    }
    else
    {
        NSArray * array = [[lookupData objectForKey:@"DATA"] objectAtIndex:indexPath.row];
        NSString * defaultLookupColumn = @"";
        defaultLookupColumn = [lookupData objectForKey:DEFAULT_LOOKUP_COLUMN];
        [delegate didSelectObject:array defaultDisplayColumn:defaultLookupColumn];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{    
    NSArray * array = [[lookupData objectForKey:@"DATA"] objectAtIndex:indexPath.row];
    NSDictionary * rowDict = nil; // [array objectAtIndex:indexPath.row];
    NSMutableArray * _array = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray * sequenceArray = [lookupData objectForKey:@"SEQUENCE"];
    @try{
    for (int i = 0; i < [sequenceArray count]; i++)
    {
        NSDictionary * dict = [sequenceArray objectAtIndex:i];
        NSString * field = [[dict allValues] objectAtIndex:0]; // for e.g. field is Name
        NSString * fieldLabel = @"";
        
       if(appDelegate.isWorkinginOffline){
           
           fieldLabel = [appDelegate.dataBase getLabelFromApiName:field objectName:objectName];
           if ([fieldLabel length] == 0)
           {
               fieldLabel = field;
           }
           
       }else{
            fieldLabel = [[describeObject fieldWithName:field] label];
       }
        
		//RADHA check for duplicates
		NSMutableArray * array2=[[NSMutableArray alloc]init];
		for (NSDictionary * obj in array)
		{
			if (![array2 containsObject:obj])
			{
				[array2 addObject:obj];
			}
		}
        
       for (int j = 0; j < [array2 count]; j++)
       {
            rowDict = [array2 objectAtIndex:j];
            if ([[rowDict objectForKey:@"key"] isEqualToString:field])
            {
                NSString * fieldValue = [rowDict objectForKey:@"value"];
                NSArray * keys = [NSArray arrayWithObjects:gLOOKUP_FIELD_LABEL, gLOOKUP_FIELD_VALUE, nil];
                NSArray * objects = [NSArray arrayWithObjects:fieldLabel, fieldValue, nil];
                NSDictionary * fieldDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                [_array addObject:fieldDictionary];
            }
        }
    }
	 }@catch (NSException *exp) {
        SMLog(@"Exception Name LookupView :accessoryButtonTappedForRowWithIndexPath %@",exp.name);
        SMLog(@"Exception Reason LookupView :accessoryButtonTappedForRowWithIndexPath %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    lookupDetails = [[LookupDetails alloc] initWithNibName:@"LookupDetails" bundle:nil];
    lookupDetails.delegate = self;
    lookupDetails.indexPath = indexPath;
    lookupDetails.lookupDetailsArray = _array;
    [self.navigationController pushViewController:lookupDetails animated:YES];
    [lookupDetails release];
    [_array release];
}

- (void)switchValueChanged:(id)sender
{
    if ([sender isKindOfClass:[UISwitch class]])
    {
        UISwitch *filterSwitch = (UISwitch *) sender;
        
        //int switchTag = kkFilterSwitchTag + indexPath.row;
        NSInteger  switchRow =  filterSwitch.tag - kkFilterSwitchTag;
        
        NSLog(@" filterSwitch  switchRow  : %d ->  %@", switchRow, (filterSwitch.on) ? @"ON" : @"OFF");
        
        if ([self.advancedFilters count] > switchRow)
        {
            SVMXLookupFilter *lookupfilter = [self.advancedFilters objectAtIndex:switchRow];
            lookupfilter.isDefaultOn = filterSwitch.on;
            [self reloadData];
        }
    }
}



#pragma mark - UILookupDetail Delegate Method
- (void) didSelectDetailAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * array = [[lookupData objectForKey:@"DATA"] objectAtIndex:indexPath.row];
     NSString * defaultLookupColumn = @"";
     defaultLookupColumn = [lookupData objectForKey:DEFAULT_LOOKUP_COLUMN];
    [delegate didSelectObject:array defaultDisplayColumn:defaultLookupColumn];
}

#pragma mark - UITAbleView Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == kTableviewTag ) {
        
        return ([[self advancedFilters] count] == 0) ? 0 : [[self advancedFilters] count];
    }
    NSArray * array = [lookupData objectForKey:@"DATA"];
    return [array count];
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
   
    if (tableView.tag == kTableviewTag)
    {
        return cell;
    }
    
    
	@try{
    NSArray * super_array = [lookupData objectForKey:@"DATA"];
    NSArray * array = [super_array objectAtIndex:indexPath.row];
    NSString * defaultLookupColumn = [lookupData objectForKey:DEFAULT_LOOKUP_COLUMN];
    
    NSString * name = @"";
    
    BOOL flag = FALSE;

    // Sahana modified code sahana  
    // 1. Get the Default Lookup field value
    for (NSDictionary * dict in array)
    {
        if (![dict isKindOfClass:[NSDictionary class]])
            continue;
        name = [dict objectForKey:@"key"];
        if ([defaultLookupColumn isEqualToString:name])
        {
            name = [dict objectForKey:@"value"];
            if (![name isKindOfClass:[NSString class]])
                continue;
            flag = TRUE;
            break;
        }
    }
    
    if([defaultLookupColumn length] == 0 || flag == FALSE)
    {
        NSDictionary * dict = [array objectAtIndex:0];
        name = [dict objectForKey:@"value"];
        if (![name isKindOfClass:[NSString class]])
            name = @"";
    }
    if ([name length] == 0)
		return cell;
    cell.textLabel.text = name;
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }@catch (NSException *exp) {
        SMLog(@"Exception Name LookupView :cellForRowAtIndexPath %@",exp.name);
        SMLog(@"Exception Reason LookupView :cellForRowAtIndexPath %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    return cell;
}

- (void)tableView: (UITableView*)tableView
  willDisplayCell: (UITableViewCell*)cell
forRowAtIndexPath: (NSIndexPath*)indexPath
{
    if (tableView.tag == kTableviewTag)
    {
        if ( (self.advancedFilters == nil) || ([self.advancedFilters count] < 1))
        {
            // no valid data array
            return;
        }
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        SVMXLookupFilter *lookupfilter = [self.advancedFilters objectAtIndex:indexPath.row];
        
        
        UILabel *filterName = (UILabel *)[cell.contentView viewWithTag:kFilterNameLabelTag];
        
        CGRect cellFrame  = cell.contentView.frame;
        
        float textX = 10.0f;
        float textHeight = 30.0f;
        float textWidth = cellFrame.size.width - 100.0;
        float textY = (cellFrame.size.height / 2.0) - (textHeight / 2.0f);
        
        float buttonX = textWidth + 10.0;
        
        if (filterName == nil)
        {
            CGRect labelFrame = CGRectMake(textX, textY, textWidth, textHeight);
            filterName = [[UILabel alloc] initWithFrame:labelFrame];
            filterName.backgroundColor = [UIColor clearColor];
            filterName.font = [UIFont boldSystemFontOfSize:14.0f];
            filterName.textAlignment = UITextAlignmentLeft;
            filterName.textColor = [UIColor blackColor];
            filterName.backgroundColor = [UIColor clearColor];
            filterName.tag = kFilterNameLabelTag;
            filterName.text = lookupfilter.name;
            [cell.contentView addSubview:filterName];
            [filterName release];
            filterName = nil;
        }else
        {
            filterName.text = lookupfilter.name;
        }
        
        int switchTag = kkFilterSwitchTag + indexPath.row;
        
        UISwitch *filterSwitch = (UISwitch *) cell.accessoryView;
        
        cell.backgroundColor = [UIColor clearColor];
        
        if (filterSwitch == nil)
        {
            CGRect switchFrame = CGRectMake(buttonX, 8.0f, 0.0f, 0.0f);
            filterSwitch = [[UISwitch alloc] initWithFrame:switchFrame];
            filterSwitch.tag = switchTag;
            [filterSwitch setBackgroundColor:[UIColor clearColor]];
            
            if (lookupfilter.objectPermission)
            {
                // set value to UISwitch
                [filterSwitch setOn:lookupfilter.isDefaultOn animated:YES];
                
                if (lookupfilter.allowOverride)
                {
                    cell.userInteractionEnabled = YES;
                }else
                {
                    cell.userInteractionEnabled = NO;
                    cell.backgroundColor = [appDelegate colorForHex:kCellBackgroundColorForDisableState];
                }
            }
            else
            {
                // set value to UISwitch to NO
                [filterSwitch setOn:NO  animated:YES];
                cell.userInteractionEnabled = NO;
                cell.backgroundColor = [appDelegate colorForHex:kCellBackgroundColorForDisableState];
            }
            
            [filterSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
            // [cell.contentView addSubview:filterSwitch];
            cell.accessoryView = filterSwitch;
            [filterSwitch release];
            filterSwitch = nil;
            
        } else
        {
            if (lookupfilter.objectPermission)
            {
                // set value to UISwitch
                [filterSwitch setOn:lookupfilter.isDefaultOn animated:YES];
                
                if (lookupfilter.allowOverride)
                {
                    cell.userInteractionEnabled = YES;
                }else{
                    cell.userInteractionEnabled = NO;
                    cell.backgroundColor = [appDelegate colorForHex:kCellBackgroundColorForDisableState];
                }
            } else{
                // set value to UISwitch to NO
                [filterSwitch setOn:NO  animated:YES];
                cell.userInteractionEnabled = NO;
                cell.backgroundColor = [appDelegate colorForHex:kCellBackgroundColorForDisableState];
            }
        }
    }
}

#pragma mark -
#pragma mark Advanced look up filers
- (void)loadLookupFilters {
   
    if (![self isCriteriaSupportedOnLookup]) {
        return;
    }
    
    NSArray *advancedlookupFilters =  [appDelegate.databaseInterface  getLookupfiltersForNamedSearchId:self.searchId andfilterType:kLOOKUP_ADVANCED_FILTER];
    if ([advancedlookupFilters count] > 0) {
        self.advancedFilters = advancedlookupFilters;
    }
    
    NSArray *prelookupFilters =  [appDelegate.databaseInterface  getLookupfiltersForNamedSearchId:self.searchId andfilterType:kLOOKUP_PRE_FILTER];
    if ([prelookupFilters count] > 0) {
        self.preFilters = prelookupFilters;
    }
}

- (BOOL)isCriteriaSupportedOnLookup {
    NSString *currentServerPkgVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kPkgVersionCheckForGPS_AND_SFM_SEARCH];
    NSInteger package = [currentServerPkgVersion intValue];
    double minVersion =  kMinPkgForLookupFilters * 100000;
    if (package <  minVersion) {
        SMLog(@"Lookup filters is not supported in %@",currentServerPkgVersion);
        return NO;
    }
    SMLog(@"Lookup filters is supported %@",currentServerPkgVersion);
    return YES;
}

@end
