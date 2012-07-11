//
//  MultiAddLookupView.m
//  iService
//
//  Created by Pavamanaprasad Athani on 08/06/11.
//  Copyright 2011 Bit Order Technologies. All rights reserved.
//

#import "MultiAddLookupView.h"
#import "iServiceAppDelegate.h"
#import "DetailViewController.h"

@implementation MultiAddLookupView

@synthesize delegate;
@synthesize popOver;
@synthesize  searchBar;
@synthesize lookupData;
@synthesize objectName, searchKey;
@synthesize lField;
@synthesize objectSelected, selectedObjDetails;
@synthesize index;
@synthesize search_field;
@synthesize mappingArray;
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
    [mappingArray release];
    [searchBar release];
    [_tableView release];
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
    UIImage * img = [UIImage imageNamed:@"SFM-Screen-Action-Popover-Button.png"];
    img = [img stretchableImageWithLeftCapWidth:11 topCapHeight:8];
    [multiAddButton setBackgroundImage:img forState:UIControlStateNormal];
    
    [searchBar becomeFirstResponder];
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    objectSelected = [[NSMutableDictionary alloc] initWithCapacity:0];
    selectedObjDetails = [[NSMutableArray alloc] initWithCapacity:0];
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
                                  action:@selector(DismissMultiAddView) 
                        forControlEvents:UIControlEventTouchUpInside];
                [barCodeView addSubview:barCodeButton];
                
                txtField = (UITextField *)subview;
                txtField.inputAccessoryView = barCodeView;
                
            }
            
        }
        
    }

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void) updateTxtField: (NSString *) barCodeData
{
    //  get the subView which is text field
    // update the txt field text with barCodeData
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
            }
            
        }
        
    }
    
}

-(void) DismissMultiAddView 
{
    [delegate dismissMultiaddLookup];
}

#pragma mark - search bar  delegate method

- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
    if ([_searchBar.text length] == 0)
        _searchBar.text = @" ";
}
- (void)viewDidUnload
{
    mappingArray = nil;
    [searchBar release];
    searchBar = nil;
    [_tableView release];
    _tableView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    //call the delegate method
    NSString * keyword = [_searchBar.text stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    if(appDelegate.isWorkinginOffline)
    {
        NSMutableDictionary * dict = [appDelegate.databaseInterface getDataForMultiAdd:objectName searchField:keyword];
        [self setLookupData:dict];
        
    }
    else
    {
        [appDelegate.wsInterface getLookUpFieldsWithKeyword:keyword forObject:self.objectName returnTo:self setting:FALSE overrideRelatedLookup:0 lookupContext:nil lookupQuery:nil];
        [activity startAnimating];
    }
    
    
}
-(void) searchBarcodeResult:(NSString *) searchText
{
    if(appDelegate.isWorkinginOffline)
    {
        NSMutableDictionary * dict = [appDelegate.databaseInterface getDataForMultiAdd:objectName searchField:searchText];
        [self setLookupData:dict];
        
    }
    else
    {
        [appDelegate.wsInterface getLookUpFieldsWithKeyword:searchText forObject:self.objectName returnTo:self setting:FALSE overrideRelatedLookup:0 lookupContext:nil lookupQuery:nil];
        [activity startAnimating];
    }

}

- (void) setLookupData:(NSDictionary *)lookupDictionary
{
    
    [activity stopAnimating];
    if(appDelegate.isWorkinginOffline)
    {
        lookupData = [lookupDictionary retain];
        mappingArray = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [[lookupData objectForKey:@"DATA"] count]; i++)
        {
            NSArray * eachLookUp = [[lookupData objectForKey:@"DATA"] objectAtIndex:i];
            NSLog(@"lookup = %@",eachLookUp);
            NSString *Id = @"";
            NSString *name = @"";
            for(NSDictionary *dict in eachLookUp)
            {
                if([[dict objectForKey:@"key"] isEqualToString:@"Id"])
                {
                    Id = [dict objectForKey:@"value"];
                }
                else
                if([[dict objectForKey:@"key"] isEqualToString:@"Name"])
                {
                    name = [dict objectForKey:@"value"];
                }

            }
            if(![Id isEqualToString:@""])
            {
                NSMutableDictionary *subDict  = [[NSMutableDictionary alloc] init];
                [subDict setObject:name forKey:@"Name"];
                [subDict setObject:Id forKey:@"Id"];
                [subDict setObject:@"false" forKey:@"Value"];
                [mappingArray addObject:subDict];
                [subDict release];
            }
        }

    }
    else
    {
        NSDictionary * _lookupDetails = [lookupDictionary objectForKey:gLOOKUP_DETAILS];
        describeObject = [[lookupDictionary objectForKey:gLOOKUP_DESCRIBEOBJECT] retain];
            lookupData = _lookupDetails;
    }
    
    [self reloadData];
    [searchBar resignFirstResponder];
}

- (void) reloadData
{
    //[activity stopAnimating];
    [_tableView reloadData];
    [activity stopAnimating];
}

- (IBAction)doneButtonClicked:(id)sender 
{
    NSLog(@"Mutable Array = %@",mappingArray);
    for(NSDictionary *dict in mappingArray)
    {
        if([[dict objectForKey:@"Value"] isEqualToString:CHECK])
        {
            [objectSelected  setObject:[dict objectForKey:@"Name"] forKey:[dict objectForKey:@"Id"]];
        }
    }
    NSLog(@"Objects Selected  = %@",objectSelected);
    [delegate addMultiChildRows:objectSelected forIndex:index];
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
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    NSDictionary *dict = [mappingArray objectAtIndex:indexPath.row];
    if([[dict objectForKey:@"Value"] isEqualToString:CHECK])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else 
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = [dict objectForKey:@"Name"];
    return cell;
}

#pragma mark - UITAbleView Delegate Methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView cellForRowAtIndexPath:indexPath];
    NSString * cellText = cell.textLabel.text ;
   
	if (cell.accessoryType == UITableViewCellAccessoryNone)
    {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
        NSMutableDictionary *dict = [mappingArray objectAtIndex:indexPath.row];
        [dict setObject:CHECK forKey:@"Value"];
                              
    }
	else
    {
		cell.accessoryType = UITableViewCellAccessoryNone;
        NSMutableDictionary *dict = [mappingArray objectAtIndex:indexPath.row];
        [dict setObject:NOTCHECK forKey:@"Value"];
    }
    NSLog(@"Mapping Array = %@",mappingArray);
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Multilookup Methods
- (void) selectObjectValue:(NSArray *)objectHistory
{
    NSString * value = nil;
    NSString * id_value = nil;
    for (int i = 0; i < [objectHistory count]; i++)
    {
        NSDictionary * dict = [objectHistory objectAtIndex:i];
       
        NSString * key = [dict objectForKey:@"key"];
        if ([key isEqualToString:@"Id"])
        {
            id_value = [dict objectForKey:@"value"];
            break;
        }
    }
    for (int i = 0; i < [objectHistory count]; i++)
    {
        NSDictionary * dict = [objectHistory objectAtIndex:i];
        NSString * key = [dict objectForKey:@"key"];
        
        if ([key isEqualToString:@"Name"])
        {
            value = [dict objectForKey:@"value"];
            break;
        }
    }
    
    [objectSelected  setObject:value forKey:id_value];
}

@end

