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
#define ResultTableViewCellHeight 45
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
@synthesize activity;
@synthesize searchCriteriaLabel;
@synthesize includeOnlineResultLabel;
@synthesize inputAccessoryView;
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([textField tag] == 0)
    {
        SearchCriteriaViewController *searchPicker = [[SearchCriteriaViewController alloc] init];
        searchPicker.pickerData = pickerData ;
        UIPopoverController *pop = [[UIPopoverController alloc] initWithContentViewController:searchPicker];
        searchPicker.pickerDelegate = self;
        CGRect frame = [textField frame];
        frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [pop setPopoverContentSize:searchPicker.view.frame.size];
        [pop presentPopoverFromRect:frame inView:searchCriteria permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        NSInteger indexOfText = [searchPicker.pickerData indexOfObject:textField.text];
        [searchPicker.picker selectRow:indexOfText inComponent:0 animated:YES];
        
        [searchPicker release];
        
        return NO;
    }
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = NSLocalizedString(@"Result Master", @"Result Master");
        if(appDelegate == nil)
            appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *contains = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_CONTAINS];
        NSString *exact_match = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_EXTACT_MATCH];
        NSString *ends_with = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_ENDS_WITH];
        NSString *starts_with = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_STARTS_WITH];
        pickerData = [[NSArray alloc] initWithObjects:contains,exact_match,ends_with,starts_with, nil];
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
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];

    [activity setHidden:TRUE];
    [actionButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Done-Back-Button.png"] forState:UIControlStateNormal];
    [actionButton setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_SRCH_SEARCH] forState:UIControlStateNormal];

    searchString.text = searchData;
    searchCriteria.text = searchCriteriaString;
    
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
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_left_panel_bg_main_top.png"]];
    searchMasterTable.backgroundView = bgImage;
    searchMasterTable.backgroundColor = [UIColor clearColor];       
    searchString.placeholder = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_SRCH_ENTER_TEXT];
    searchCriteriaLabel.text = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_SRCH_Criteria];
    includeOnlineResultLabel.text = [appDelegate.wsInterface.tagsDictionary objectForKey:INCLUDE_ONLINE_RESULTS];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reachabilityChanged:) 
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [activity startAnimating];
    activity.hidesWhenStopped=YES;
    if([appDelegate isCameraAvailable])
    {
        UIView *barCodeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 46)];
        barCodeView.backgroundColor=[UIColor clearColor];
        barCodeView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"accessoryView_bg.png"]];
        UIButton *barCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(676, 4, 72, 37)];
        [barCodeButton setBackgroundImage:[UIImage imageNamed:@"BarCodeButton.png"] forState:UIControlStateNormal];
        barCodeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [barCodeButton addTarget:self 
                          action:@selector(launchBarcodeScanner:) 
                forControlEvents:UIControlEventTouchUpInside];
        [barCodeView addSubview:barCodeButton];
        self.inputAccessoryView = barCodeView;
    }
}
- (IBAction) launchBarcodeScanner:(id)sender
{
    
    [self resignFirstResponder];
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self presentModalViewController: reader animated: YES];
    [reader release];
    NSLog(@"Launch Bar Code Scanner");
}

#pragma mark - ZBar Delegate Methods

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =[info objectForKey: ZBarReaderControllerResults];
    NSLog(@"result=%@",results);
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    
    searchString.text = symbol.data;    
    NSLog(@"symbol.data=%@",symbol.data);    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissModalViewControllerAnimated: YES];
    [self performSelector:@selector(refineSearch:)];
}
- (void) reloadTableData
{
   [activity setHidden:FALSE];
    [activity startAnimating];
    if([tableArray count] > 0)
    {
        [self didSelectHeader:nil];
    }
    [activity stopAnimating];
    [activity setHidden:TRUE];

}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.activity =nil;
    self.searchCriteriaLabel = nil;
    self.includeOnlineResultLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
- (void) dealloc
{
    [includeOnlineResultLabel release];
    [searchCriteriaLabel release];
    [activity release];
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
     static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    else
    {
        NSArray * subViews = [cell.contentView subviews];
        for (int i = 0; i < [subViews count]; i++)
        {
            [[subViews objectAtIndex:i] removeFromSuperview];
        }
        cell.backgroundView = nil;
    }
    
    UILabel * cellLabel = [[[UILabel alloc] init] autorelease];
    cellLabel.backgroundColor = [UIColor clearColor];
    cellLabel.frame = CGRectMake(10, 0, 270, 44);
    
    UIView * bgView = nil;
    UIImageView * bgImage = nil;
    UIImage * image = nil;
    
    bgView = [[[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, ResultTableViewCellHeight)] autorelease];
    cellLabel.text = [[tableArray objectAtIndex:indexPath.row] objectForKey:@"ObjectName"];
    if ([indexPath isEqual:lastSelectedIndexPath])
    {
        image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
        cellLabel.textColor = [UIColor whiteColor];
    }
    else
    {
        image = [UIImage imageNamed:@"SFM_left_button_UP.png"];
        cellLabel.textColor = [UIColor blackColor];
    }
    image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
    bgImage = [[[UIImageView alloc] initWithImage:image] autorelease];

    [bgImage setContentMode:UIViewContentModeScaleToFill];
    
    if ([cellLabel.text length] > 0)
    {
        bgImage.frame = CGRectMake(0, 0, 300, ResultTableViewCellHeight);
        [bgView addSubview:bgImage];
        bgImage.tag = BGIMAGETAG;
        cellLabel.center = bgView.center;
        cellLabel.tag = CELLLABELTAG;
        [bgView addSubview:cellLabel];
        [cell.contentView addSubview:bgView];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ResultTableViewCellHeight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [searchString resignFirstResponder];
    NSLog(@"Last Selected Index Path Row = %d",lastSelectedIndexPath.row);
    [tableView deselectRowAtIndexPath:lastSelectedIndexPath animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];    
    UIImage * image = nil;
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];    
    
    if (lastSelectedIndexPath == indexPath)
    {
        UITableViewCell * selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        UIView * cellBackgroundView = selectedCell.contentView;
        UIImageView * bgImage = (UIImageView *)[cellBackgroundView viewWithTag:BGIMAGETAG];
        image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
        image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
        [bgImage setImage:image];
        [bgImage setContentMode:UIViewContentModeScaleToFill];
        UILabel * selectedCellLabel = (UILabel *)[cellBackgroundView viewWithTag:CELLLABELTAG];
        selectedCellLabel.textColor = [UIColor whiteColor]; 
    }
    else
    {
        
        UITableViewCell * lastSelectedCell = [tableView cellForRowAtIndexPath:lastSelectedIndexPath];
        UIView * lastSelectedCellBackgroundView = lastSelectedCell.contentView;
        UIImageView * lastSelectedCellBGImage = (UIImageView *)[lastSelectedCellBackgroundView viewWithTag:BGIMAGETAG];
        image = [UIImage imageNamed:@"SFM_left_button_UP.png"];
        image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
        [lastSelectedCellBGImage setImage:image];
        [lastSelectedCellBGImage setContentMode:UIViewContentModeScaleToFill];
        UILabel * lastSelectedCellLabel = (UILabel *)[lastSelectedCellBackgroundView viewWithTag:CELLLABELTAG];
        lastSelectedCellLabel.textColor = [UIColor blackColor];
    }
    
    UITableViewCell * selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    UIView * cellBackgroundView = selectedCell.contentView;
    UIImageView * bgImage = (UIImageView *)[cellBackgroundView viewWithTag:BGIMAGETAG];
    image = [UIImage imageNamed:@"SFM_left_button_selected.png"];
    image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
    [bgImage setImage:image];
    [bgImage setContentMode:UIViewContentModeScaleToFill];
    UILabel * selectedCellLabel = (UILabel *)[cellBackgroundView viewWithTag:CELLLABELTAG];
    selectedCellLabel.textColor = [UIColor whiteColor];
    
    lastSelectedIndexPath = [indexPath retain];
    [resultDetailView setSfmConfigName:tableHeader];
    [resultDetailView showObjects:[NSArray arrayWithObject:[tableArray objectAtIndex:indexPath.row]] forAllObjects:NO];
    [searchMasterTable reloadData];
}

- (UIView *) tableView:(UITableView *)_tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView * view = nil;
    NSString * sectionTitle = nil;

    sectionTitle = tableHeader;
    // Create label with section title
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 8, 280, 30)] autorelease];//y was  6
    
    label.backgroundColor = [UIColor clearColor];
   label.textColor = [UIColor whiteColor];
    
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    
    // Create header view and add label as a subview
    view  = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, ResultTableViewCellHeight)] autorelease];
    
    view.image = [UIImage imageNamed:@"SFM-View-line-header-bg.png"];
    [view addSubview:label];
    
    UIButton * header_button = [[[UIButton alloc] initWithFrame:CGRectMake(290, 7, 28, 28)] autorelease];
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
    [searchString resignFirstResponder];
    UIImage *image =nil;
    UITableViewCell * lastSelectedCell = [searchMasterTable cellForRowAtIndexPath:lastSelectedIndexPath];
    UIView * lastSelectedCellBackgroundView = lastSelectedCell.contentView;
    UIImageView * lastSelectedCellBGImage = (UIImageView *)[lastSelectedCellBackgroundView viewWithTag:BGIMAGETAG];
    image = [UIImage imageNamed:@"SFM_left_button_UP.png"];
    image = [image stretchableImageWithLeftCapWidth:11 topCapHeight:8];
    [lastSelectedCellBGImage setImage:image];
    [lastSelectedCellBGImage setContentMode:UIViewContentModeScaleToFill];
    UILabel * lastSelectedCellLabel = (UILabel *)[lastSelectedCellBackgroundView viewWithTag:CELLLABELTAG];
    lastSelectedCellLabel.textColor = [UIColor blackColor];
    
    lastSelectedIndexPath = nil;

    [resultDetailView setSfmConfigName:tableHeader];
    [resultDetailView showObjects:tableArray forAllObjects:YES];
}
- (IBAction)refineSearch:(id)sender
{
    [searchString resignFirstResponder];
    [activity setHidden:FALSE];
    [activity startAnimating];
    [searchFilterSwitch setEnabled:FALSE];
    [self performSelector:@selector(didSelectHeader:)];
    if(appDelegate.isInternetConnectionAvailable)
    {
        [searchFilterSwitch setEnabled:TRUE];
    }
    [activity stopAnimating];
    [activity setHidden:TRUE];
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
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, YES))
    {                
        if (appDelegate.wsInterface.didOpComplete == TRUE)
            break;   
        NSLog(@"Retreiving Online Reccords");
    }

    [searchResultData release];
    NSLog(@"Online Records = %@",appDelegate.onlineDataArray);
     */
}
- (IBAction) backgroundSelected:(id)sender
{
    [searchString resignFirstResponder];
}
#pragma mark - PopOver Delegate Methods
-(void) setTextField :(NSString *)str
{
    searchCriteria.text = str;
}
@end
