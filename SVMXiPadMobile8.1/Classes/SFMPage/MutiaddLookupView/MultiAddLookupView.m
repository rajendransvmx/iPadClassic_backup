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

@synthesize mapping_dict;
@synthesize delegate;
@synthesize popOver;
@synthesize  searchBar;
@synthesize lookupData;
@synthesize objectName, searchKey;
@synthesize lField;
@synthesize objectSelected, selectedObjDetails;
@synthesize index;
@synthesize search_field;

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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


#pragma mark - search bar  delegate method

- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
    if ([_searchBar.text length] == 0)
        _searchBar.text = @" ";
}
- (void)viewDidUnload
{
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
        NSMutableDictionary * dict = [appDelegate.databaseInterface getDataForMultiAdd:objectName searchField:search_field];
        [self setLookupData:dict];
        
    }
    else
    {
        [appDelegate.wsInterface getLookUpFieldsWithKeyword:keyword forObject:self.objectName returnTo:self setting:FALSE overrideRelatedLookup:0 lookupContext:nil lookupQuery:nil];
        [activity startAnimating];
    }
    
    
}

- (void) setLookupData:(NSDictionary *)lookupDictionary
{
    
    [activity stopAnimating];
    if(appDelegate.isWorkinginOffline)
    {
        lookupData = [lookupDictionary retain];
        
        mapping_dict = [[NSMutableDictionary alloc] initWithCapacity:0];
        for (int i = 0; i < [[lookupData objectForKey:@"DATA"] count]; i++)
        {
           NSArray * eachLookUp = [[lookupData objectForKey:@"DATA"] objectAtIndex:i];
            for(int j = 0; j< [eachLookUp count];j++)
            {
                NSDictionary * dict = [eachLookUp objectAtIndex:j];
                
                NSArray * allkeys = [dict allKeys];
                NSString * value = @"";
                for(NSString *  str in allkeys)
                {
                    NSString * key = [dict objectForKey:@"key"];
                   
                    if ([key isEqualToString:@"Name"])
                    {
                        value = [dict objectForKey:@"value"];
                        break;
                    }
                }
                
                [mapping_dict setValue:@"false" forKey:value];
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
   /* NSArray * array = [lookupData objectForKey:@"DATA"];
    for (int i = 0; i < [array count]; i++)
    {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell * cell = [_tableView cellForRowAtIndexPath:indexPath];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            NSArray * _array = [[lookupData objectForKey:@"DATA"] objectAtIndex:i];
            [selectedObjDetails addObjectsFromArray:_array];
            
            [self selectObjectValue:_array];
        }
    }*/
    
    
    NSArray * array = [lookupData objectForKey:@"DATA"];
    
    NSArray * mapping_value_keys = [mapping_dict allKeys];
        
    for (int j = 0; j < [array count]; j++)
    {
        NSArray * subarray = [array objectAtIndex:j];
        
        NSString * dict_value = @"" , * dict_key = @"";
        
        for(int k = 0; k< [subarray count]; k++)
        {
            NSDictionary * dict = [subarray objectAtIndex:k];
            NSString * _key = [dict objectForKey:@"key"];
            if([_key isEqualToString:@"Id"])
            {
                dict_key = [dict objectForKey:@"value"];
            }
            else if ([_key isEqualToString:@"Name"])
            {
                dict_value = [dict objectForKey:@"value"];
            }
            
        }
        for(int i = 0; i< [mapping_value_keys count]; i++)
        {
            NSString * MApping_value = [mapping_value_keys objectAtIndex:i];
            NSString * mapping_flag  = [mapping_dict  objectForKey:MApping_value];
            if([MApping_value isEqualToString:dict_value])
            {
                if([mapping_flag isEqualToString:CHECK])
                {
                    [objectSelected  setObject:dict_value forKey:dict_key];
                }
                break;
            }
        }
    }
    
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
    
    NSArray * array = [[lookupData objectForKey:@"DATA"] objectAtIndex:indexPath.row];
    
    NSString * name = nil;
    
    for (int i = 0; i < [array count]; i++)
    {
        NSDictionary * dict = [array objectAtIndex:i];
        NSString * keyValue = [dict objectForKey:@"key"];
        if ([keyValue isEqualToString:@"Name"])
        {
            name = [dict objectForKey:@"value"];
            break;
        }
    }  
    
    NSArray * mapping_keys = [mapping_dict  allKeys];
    for(NSString * mapKey in mapping_keys)
    {
        if([mapKey isEqualToString:name])
        {
            NSString * mapvalue = [mapping_dict objectForKey:mapKey];
            if(mapvalue == CHECK)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }
    
    cell.textLabel.text = name;
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
        [mapping_dict setValue:CHECK forKey:cellText];
        NSLog(@"%@", objectSelected);
    }
	else
    {
		cell.accessoryType = UITableViewCellAccessoryNone;
        [mapping_dict setValue:NOTCHECK forKey:cellText];
    }
    
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

