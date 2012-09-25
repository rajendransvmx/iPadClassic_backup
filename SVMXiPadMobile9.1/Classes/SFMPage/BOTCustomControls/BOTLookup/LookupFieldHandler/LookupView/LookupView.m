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

@implementation LookupView

@synthesize delegate;
@synthesize lookupData, popover;
@synthesize objectName, searchKey,searchId;
@synthesize history;
@synthesize label_key;

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
    /*if (!appDelegate.isInternetConnectionAvailable)
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
    /*if (!appDelegate.isInternetConnectionAvailable)
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
    NSLog(@"%@", lookupDictionary);
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
    NSArray * array = [[lookupData objectForKey:@"DATA"] objectAtIndex:indexPath.row];
    NSString * defaultLookupColumn = @"";
    defaultLookupColumn = [lookupData objectForKey:DEFAULT_LOOKUP_COLUMN];
    [delegate didSelectObject:array defaultDisplayColumn:defaultLookupColumn];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{    
    NSArray * array = [[lookupData objectForKey:@"DATA"] objectAtIndex:indexPath.row];
    NSDictionary * rowDict = nil; // [array objectAtIndex:indexPath.row];
    NSMutableArray * _array = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray * sequenceArray = [lookupData objectForKey:@"SEQUENCE"];
    
    for (int i = 0; i < [sequenceArray count]; i++)
    {
        NSDictionary * dict = [sequenceArray objectAtIndex:i];
        NSString * field = [[dict allValues] objectAtIndex:0]; // for e.g. field is Name
        NSString * fieldLabel = @"";
        
       if(appDelegate.isWorkinginOffline){
           
           fieldLabel = field;
       }else{
            fieldLabel = [[describeObject fieldWithName:field] label];
       }
        
       for (int j = 0; j < [array count]; j++)
       {
            rowDict = [array objectAtIndex:j];
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

    lookupDetails = [[LookupDetails alloc] initWithNibName:@"LookupDetails" bundle:nil];
    lookupDetails.delegate = self;
    lookupDetails.indexPath = indexPath;
    lookupDetails.lookupDetailsArray = _array;
    [self.navigationController pushViewController:lookupDetails animated:YES];
    [lookupDetails release];
    [_array release];
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

    cell.textLabel.text = name;
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
}

@end
