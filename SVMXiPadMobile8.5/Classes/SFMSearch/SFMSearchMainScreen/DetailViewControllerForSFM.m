//
//  DetailViewControllerForSFM.m
//  SFMSearchTemplate
//
//  Created by Siva Manne on 10/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import "DetailViewControllerForSFM.h"
#import "MasterViewController.h"
#import "SFMResultMainViewController.h"
#import "iPadScrollerViewController.h"
#import "iServiceAppDelegate.h"

@interface DetailViewControllerForSFM ()
@property(retain, nonatomic) UIPopoverController *masterPopoverController;
@property(retain, nonatomic) NSMutableDictionary *dictionaries;
@property(retain, nonatomic) NSMutableArray *sfmArray;
- (void) readPlist;
@end

@implementation DetailViewControllerForSFM
@synthesize detailItem = _detailItem;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize dictionaries = _dictionaries;
@synthesize detailTable = _detailTable;
@synthesize sfmArray = _sfmArray;
@synthesize masterView;
@synthesize splitViewDelegate;
@synthesize mainView;
- (void)dealloc
{
    [masterView release];
    [_detailItem release];
    [_masterPopoverController release];
    [_dictionaries release];
    [_detailTable release];
    [_sfmArray release];
    [super dealloc];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release];
        _detailItem = [newDetailItem retain];

        // Update the view.
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void) showHelp
{
    /*
    UIAlertView *helpAlert = [[UIAlertView alloc] initWithTitle:@"Help" message:@"Display Help Topics for SFM Search Module" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [helpAlert show];
    [helpAlert release];
     */
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    help.helpString = @"home.html";  
    [self presentModalViewController:help animated:YES];
    [help release];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //[self readPlist];
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    _sfmArray = [[appDelegate.dataBase getSFMSearchConfigurationSettings] retain];
    
    //Back Button
    UIButton * backButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 35)] autorelease];
    [backButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Back-Arrow-Button"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(DismissViewController:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem * backBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    //Help Button
    UIButton * helpButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 35)] autorelease];
    [helpButton setBackgroundImage:[UIImage imageNamed:@"iService-Screen-Help"] forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    [helpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem * addButton = [[[UIBarButtonItem alloc] initWithCustomView:helpButton] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
    UILabel * titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)] autorelease];
    titleLabel.textAlignment = UITextAlignmentCenter;
    
    titleLabel.text = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_Search];
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    titleLabel.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = titleLabel;
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_right_panel_bg_main_top.png"]];
    // UIView * bgImageView = [[UIView alloc] initWithFrame:bgImage.frame];
    bgImage.frame = CGRectMake(0, -12, bgImage.frame.size.width, bgImage.frame.size.height+12);
    [self.view addSubview:bgImage];
    self.detailTable.backgroundView = bgImage;
    [bgImage release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//    return YES;
   return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}
							
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}
#pragma mark - Custom Methods
- (void) getConfigurationSettings
{
    
}
- (void) readPlist
{
    NSBundle *MainBundle = [NSBundle mainBundle];    
    NSString *dataBundlePath = [MainBundle pathForResource:@"DataBase" ofType:@"plist"];
    _dictionaries =  [[NSMutableDictionary alloc] initWithContentsOfFile:dataBundlePath];
    _sfmArray = [_dictionaries objectForKey:@"SFM Search"];
}
- (void) DismissViewController: (id) sender
{
//    NSLog(@"Dismiss Detail View Controller");
    [splitViewDelegate DismissSplitViewController];
}
#pragma mark - table view delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_sfmArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.textLabel.text = [[_sfmArray objectAtIndex:indexPath.row] objectForKey:@"SVMXC__Name__c"];
    NSString *DescriptionText=[[_sfmArray objectAtIndex:indexPath.row] objectForKey:@"SVMXC__Description__c"];
    if(![DescriptionText isEqualToString:@"(null)"])
        cell.detailTextLabel.text =DescriptionText;
    else
        cell.detailTextLabel.text =@"";
    //UIButton * button = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 21)] autorelease];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 20, 21)];
    [button setTitle:@"Search" forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Disclosure-Button.png"] 
                      forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button addTarget:self action:@selector(searchButtonTapped:withEvent:)  forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;
    //[button release];
     
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]];
    bgImage.frame = cell.frame;
    cell.backgroundView = bgImage;
    [bgImage release];

    return cell;
}
- (void) searchButtonTapped:(id)sender withEvent:(UIEvent *) event
{
    
//    NSLog(@"Button Tapped");
    UIButton *button = sender;
     /*
    CGPoint correctedPoint = [button convertPoint:button.bounds.origin toView:self.detailTable]; 
    NSIndexPath *indexPath = [self.detailTable indexPathForRowAtPoint:correctedPoint]; 
    NSLog(@"Button tapped in row %d", indexPath.row);
    */
    NSIndexPath * indexPath = [self.detailTable indexPathForRowAtPoint: [[[event touchesForView:button] anyObject] locationInView: self.detailTable]];
    if ( indexPath == nil )
        return;
    [self  tableView:self.detailTable didSelectRowAtIndexPath:indexPath];
    //[self.tableView.delegate tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.masterView.searchString resignFirstResponder];
    NSDictionary *processDict = [_sfmArray objectAtIndex:indexPath.row];
    
    NSString *processName = [processDict objectForKey:@"Name"];
    NSArray *objects = [appDelegate.dataBase getConfigurationForProcess:processName];
    NSString *processId = [processDict objectForKey:@"Id"];
    
   // NSLog(@"User Search Data = %@",self.masterViewController.searchString.text);
    SFMResultMainViewController *resultViewController = [[SFMResultMainViewController alloc] initWithNibName:@"SFMResultMainViewController" bundle:nil];
    resultViewController.filterString = self.masterView.searchString.text;
    resultViewController.processId = processId;
    NSLog(@"Process ID = %@",processId);
    resultViewController.searchCriteriaString = self.masterView.searchCriteria.text;
    resultViewController.searchCriteriaLimitString = self.masterView.searchLimitString.text;
    resultViewController.masterTableData = objects;
    resultViewController.masterTableHeader = [processDict objectForKey:@"SVMXC__Name__c"];
    //NSLog(@"Master Table Header Value = %@",resultViewController.masterTableHeader);
    resultViewController.switchStatus = self.masterView.searchFilterSwitch.on;
    //NSLog(@"Switch Value = %d",resultViewController.switchStatus);
    //[tableData release];
    resultViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    resultViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.mainView presentModalViewController:resultViewController animated:YES];
    [resultViewController release];
}

@end
