//
//  SFMResultMasterViewController.m
//  SFMSearch
//
//  Created by Siva Manne on 11/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import "SFMResultMasterViewController.h"
#import "SFMResultDetailViewController.h"
#import "iServiceAppDelegate.h"
#define ResultTableViewCellHeight 50
@interface SFMResultMasterViewController ()

@end

@implementation SFMResultMasterViewController
@synthesize searchString,searchCriteria,searchFilterSwitch;
@synthesize tableHeader;
@synthesize tableArray;
@synthesize searchData;
@synthesize searchMasterTable;
@synthesize resultDetailView;
@synthesize pickerData;
@synthesize searchCriteriaString;
@synthesize switchStatus;
@synthesize actionButton;
@synthesize processId;
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    SearchCriteriaViewController *searchPicker = [[SearchCriteriaViewController alloc] init];
    searchPicker.pickerData = pickerData ;
    UIPopoverController *pop = [[UIPopoverController alloc] initWithContentViewController:searchPicker];
    searchPicker.pickerDelegate = self;
    [pop presentPopoverFromRect:[textField frame] inView:searchCriteria permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    [pop setPopoverContentSize:CGSizeMake(320, 216)];
    NSInteger indexOfText = [searchPicker.pickerData indexOfObject:textField.text];
    [searchPicker.picker selectRow:indexOfText inComponent:0 animated:YES];
    
    [searchPicker release];
    
    return NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Result Master", @"Result Master");
        pickerData = [[NSArray alloc] initWithObjects:@"Contains",@"Exact Match",@"Ends With",@"Starts With", nil];
    }
    return self;
}
- (void) reachabilityChanged: (NSNotification* )notification 
{
    NSLog(@"Notification :-%@",[notification name]);
    if(appDelegate.isInternetConnectionAvailable)
    {
        NSLog(@"Internet is Available");
        searchFilterSwitch.enabled=TRUE;
    }
    else
    {
        NSLog(@"Internet is Not Available");
        [searchFilterSwitch setOn:NO];
        searchFilterSwitch.enabled=FALSE;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"Data = %@",searchData);
    [actionButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Done-Back-Button.png"] forState:UIControlStateNormal];
    searchString.text = searchData;
    searchCriteria.text = searchCriteriaString;
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.isInternetConnectionAvailable)
    {
        searchFilterSwitch.enabled=TRUE;
         [searchFilterSwitch setOn:switchStatus];
    }
    else
    {       
        [searchFilterSwitch setOn:NO];
        searchFilterSwitch.enabled=FALSE;
    }
    if([tableArray count] > 0)
    {
       
        [self didSelectHeader:nil];
        UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_left_panel_bg_main_top.png"]];
        searchMasterTable.backgroundView = bgImage;
        searchMasterTable.backgroundColor = [UIColor clearColor];       
    }
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reachabilityChanged:) 
                                                 name:kReachabilityChangedNotification
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
- (void) dealloc
{
    [processId release];
    [pickerData release];
    [resultDetailView release];
    [searchData release];
    [tableArray release];
    [tableHeader release];
    [searchString release];
    [searchCriteria release];
    [searchFilterSwitch release];
    [searchCriteriaString release];
    [super dealloc];
}
#pragma mark - table view delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableArray count];
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return tableHeader;
}
 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return ResultTableViewCellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage * image = nil;
    NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [[tableArray objectAtIndex:indexPath.row] objectForKey:@"ObjectName"];
     cell.backgroundColor = [UIColor clearColor];  
    UIImageView * bgImage = nil;
        
    image = [UIImage imageNamed:@"SFM_left_button_UP.png"];
    image = [image stretchableImageWithLeftCapWidth:8 topCapHeight:8];
    bgImage = [[UIImageView alloc] initWithImage:image];
    [bgImage setContentMode:UIViewContentModeScaleToFill];
    
    cell.backgroundView = bgImage;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
    cell.textLabel.textColor =[appDelegate colorForHex:@"2d5d83"];
        
    [bgImage release];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ResultTableViewCellHeight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:lastSelectedIndexPath animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];    
    UIImage * image = nil;
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];    
    
    UITableViewCell * selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
    image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:image];
    [bgImage setContentMode:UIViewContentModeScaleToFill];
    selectedCell.backgroundView = bgImage;
    selectedCell.textLabel.font = [UIFont boldSystemFontOfSize:18];
    selectedCell.textLabel.textColor = [UIColor whiteColor];
    [bgImage release];
    
    
    UITableViewCell * lastSelectedCell = [tableView cellForRowAtIndexPath:lastSelectedIndexPath];
    image = [UIImage imageNamed:@"SFM_left_button_UP.png"];
    image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
    UIImageView * lastSelectedCellBGImage = [[UIImageView alloc] initWithImage:image];
    [lastSelectedCellBGImage setContentMode:UIViewContentModeScaleToFill];
    lastSelectedCell.backgroundView = lastSelectedCellBGImage;
    lastSelectedCell.textLabel.font = [UIFont boldSystemFontOfSize:18];    
    lastSelectedCell.textLabel.textColor = [appDelegate colorForHex:@"2d5d83"];    
    [lastSelectedCellBGImage release];
    
    lastSelectedIndexPath = [indexPath retain];

    [resultDetailView setSfmConfigName:tableHeader];
    [resultDetailView showObjects:[NSArray arrayWithObject:[tableArray objectAtIndex:indexPath.row]]];
}

- (UIView *) tableView:(UITableView *)_tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView * view = nil;
    NSString * sectionTitle = nil;

    sectionTitle = tableHeader;
    // Create label with section title
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 8, 170, 30)] autorelease];//y was  6
    
    label.backgroundColor = [UIColor clearColor];
   label.textColor = [UIColor whiteColor];
    
    label.font = [UIFont boldSystemFontOfSize:18];
    label.text = sectionTitle;
    
    // Create header view and add label as a subview
    view  = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, ResultTableViewCellHeight)] autorelease];
    
    view.image = [UIImage imageNamed:@"SFM-View-line-header-bg.png"];
    [view addSubview:label];
    
    UIButton * header_button = [[[UIButton alloc] initWithFrame:CGRectMake(270, 7, 28, 28)] autorelease];
    header_button.tag = section;
    [header_button  setBackgroundImage:[UIImage imageNamed:@"SFM-View-showall-icon_mod.png"] forState:UIControlStateNormal];
    [header_button addTarget:self action:@selector(didSelectHeader:) forControlEvents:UIControlEventTouchUpInside];
    
    view.tag = section;
    
    UIView * lView = [[[UIView alloc] initWithFrame:view.frame] autorelease];
    [lView addSubview:view];
    [lView addSubview:header_button];
    return lView;
}
-(void) didSelectHeader:(id)sender
{    
    UIImage *image =nil;
    UITableViewCell * lastSelectedCell = [searchMasterTable cellForRowAtIndexPath:lastSelectedIndexPath];
    image = [UIImage imageNamed:@"SFM_left_button_UP.png"];
    image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
    UIImageView * lastSelectedCellBGImage = [[UIImageView alloc] initWithImage:image];
    [lastSelectedCellBGImage setContentMode:UIViewContentModeScaleToFill];
    lastSelectedCell.backgroundView = lastSelectedCellBGImage;
    lastSelectedCell.textLabel.font = [UIFont boldSystemFontOfSize:18];    
    lastSelectedCell.textLabel.textColor = [appDelegate colorForHex:@"2d5d83"];    
    [lastSelectedCellBGImage release];
    
    lastSelectedIndexPath = 0;

    [resultDetailView setSfmConfigName:tableHeader];
    [resultDetailView showObjects:tableArray];
}
- (IBAction)refineSearch:(id)sender
{
    [self performSelector:@selector(didSelectHeader:)];
    /*
    NSMutableArray *searchResultData = [[NSMutableArray alloc] init];
    NSString *processID = @"a0a70000000fsduAAA";

    NSArray  *objectList = [NSArray arrayWithObjects:@"a0a70000000fse8",@"a0a70000000fse9",@"a0a70000000fseB", nil];
    NSArray  *subResultList1 = [NSArray arrayWithObjects:@"a0s70000001H8hk", nil];
    NSArray  *subResultList3 = [NSArray arrayWithObjects:@"5007000000Ly2Tz", nil];
    NSArray  *subResultList4 = [NSArray arrayWithObjects:@"", nil];
    NSArray  *resultList = [NSArray arrayWithObjects:subResultList1,subResultList3,subResultList4, nil];
    
    NSString *criteria = @"Contains";
    NSString *userFilterString = @"acc";
    [ searchResultData addObject:processID];
    [ searchResultData addObject:objectList];
    [ searchResultData addObject:resultList];
    [ searchResultData addObject:criteria];
    [ searchResultData addObject:userFilterString];
    [appDelegate.wsInterface dataSyncWithEventName:@"SFM_SEARCH" eventType:@"SEARCH_RESULTS" values:searchResultData]; 
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, NO))
    {                
        if (appDelegate.wsInterface.didOpComplete == TRUE)
            break;   
        NSLog(@"Retreiving Online Reccords");
    }

    [searchResultData release];
    NSLog(@"Online Records = %@",appDelegate.onlineDataArray);
     */
}
#pragma mark - PopOver Delegate Methods
-(void) setTextField :(NSString *)str
{
    searchCriteria.text = str;
}
@end
