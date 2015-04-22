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
#import "AppDelegate.h"
#import "Utility.h"
#import "CustomToolBar.h"

/*Accessibility changes*/
#import "AccessibilityGlobalConstants.h"

void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);


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
    NSString *lang=[appDelegate.dataBase checkUserLanguage];
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    NSString *isfileExists = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"sfm-search_%@",lang] ofType:@"html"];
    if((isfileExists == NULL) || [lang isEqualToString:@"en_US"] || !([lang length]>0))
    {
        help.helpString=@"sfm-search.html";
    }
    else
    {
        help.helpString = [NSString stringWithFormat:@"sfm-search_%@.html",lang];
    }
    [self.mainView presentViewController:help animated:YES completion:^(void){}];
    [help release];

}

- (void) Layout
{
	CGRect rect = self.view.frame;
    /*ios7_support shravya-navbar*/
    if ([Utility notIOS7]) {
        self.navigationController.navigationBar.frame = CGRectMake(0, 0, rect.size.width, self.navigationController.navigationBar.frame.size.height);
    }
	
	// Do any additional setup after loading the view, typically from a nib.
    //[self readPlist];
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _sfmArray = [[appDelegate.dataBase getSFMSearchConfigurationSettings] retain];
    
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_right_panel_bg_main_top.png"]];
	bgImage.frame = CGRectMake(0, -12, bgImage.frame.size.width, bgImage.frame.size.height+12);
	//	[self.view addSubview:bgImage];
	[bgImage release];
	
	UIImage *image = [UIImage imageNamed:@"SFM-Screen-Back-Arrow-Button"];
	UIButton * backButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)] autorelease];
	[backButton setBackgroundImage:image forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(DismissViewController:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem * backBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
	self.navigationItem.leftBarButtonItem = backBarButtonItem;
	
	UILabel * titleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.text = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_Search];
	titleLabel.font = [UIFont boldSystemFontOfSize:15];
	titleLabel.backgroundColor = [UIColor clearColor];
	[titleLabel sizeToFit];
	self.navigationItem.titleView = titleLabel;
	
	NSMutableArray *arrayForRightBarButton = [[NSMutableArray alloc] initWithCapacity:0];
	
	NSInteger toolBarWidth = 0;
	const int SPACE_BUFFER = 4;
	
	UIBarButtonItem *activityButton = [[[UIBarButtonItem alloc] initWithCustomView:appDelegate.SyncProgress] autorelease];
	[arrayForRightBarButton addObject:activityButton];
	toolBarWidth += appDelegate.SyncProgress.frame.size.width + SPACE_BUFFER;
	
	UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
	helpButton.backgroundColor = [UIColor clearColor];
	[helpButton setBackgroundImage:[UIImage imageNamed:@"iService-Screen-Help"] forState:UIControlStateNormal];
	[helpButton addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
	[helpButton sizeToFit];
	toolBarWidth += helpButton.frame.size.width + SPACE_BUFFER;
	UIBarButtonItem * helpBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:helpButton] autorelease];
	[arrayForRightBarButton addObject:helpBarButtonItem];
	
    /*ios7_support shravya-custom toolbar*/
	CustomToolBar *myToolBar = [[CustomToolBar alloc] initWithFrame:CGRectMake(0, 0, toolBarWidth + 30, 44)];
    myToolBar.backgroundColor = [UIColor clearColor];
    [myToolBar setItems:arrayForRightBarButton];
	UIView *view = myToolBar;
	SMLog(kLogLevelVerbose,@"%f %f", view.frame.size.width, view.frame.size.height);
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:myToolBar] autorelease];
    [myToolBar release];
	
	[arrayForRightBarButton release];
	arrayForRightBarButton = nil;
    
    /*Accessibility changes*/
    helpButton.isAccessibilityElement = YES;
    [helpButton setAccessibilityIdentifier:kAccHelpButton];
    
    backButton.isAccessibilityElement = YES;
    [backButton setAccessibilityIdentifier:kAccBackButton];
    
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self Layout];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
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
//    SMLog(kLogLevelVerbose,@"Dismiss Detail View Controller");
    [splitViewDelegate DismissSplitViewController];
}

#pragma mark - table view delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	//Fix for avoiding crash
	NSUInteger rowCount = 0;
	
	if (_sfmArray != nil && [_sfmArray count] > 0)
	{
		rowCount = [_sfmArray count];
	}
    return rowCount;
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
	cell.textLabel.backgroundColor = [UIColor clearColor];
	cell.detailTextLabel.backgroundColor = [UIColor clearColor];
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
    bgImage.backgroundColor=[UIColor clearColor];
    bgImage.frame = cell.frame;
    cell.backgroundView = bgImage;
    [bgImage release];

    return cell;
}
- (void) searchButtonTapped:(id)sender withEvent:(UIEvent *) event
{
    
//    SMLog(kLogLevelVerbose,@"Button Tapped");
    UIButton *button = sender;
     /*
    CGPoint correctedPoint = [button convertPoint:button.bounds.origin toView:self.detailTable]; 
    NSIndexPath *indexPath = [self.detailTable indexPathForRowAtPoint:correctedPoint]; 
    SMLog(kLogLevelVerbose,@"Button tapped in row %d", indexPath.row);
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
	@try{
    [self.masterView.searchString resignFirstResponder];
    NSDictionary *processDict = [_sfmArray objectAtIndex:indexPath.row];
    
    NSString *processName = [processDict objectForKey:@"Name"];
    NSArray *objects = [appDelegate.dataBase getConfigurationForProcess:processName];
    NSString *processId = [processDict objectForKey:@"Id"];
    
   // SMLog(kLogLevelVerbose,@"User Search Data = %@",self.masterViewController.searchString.text);
    SFMResultMainViewController *resultViewController = [[SFMResultMainViewController alloc] initWithNibName:@"SFMResultMainViewController" bundle:nil];
    resultViewController.filterString = self.masterView.searchString.text;
    resultViewController.processId = processId;
    SMLog(kLogLevelVerbose,@"Process ID = %@",processId);
    resultViewController.searchCriteriaString = self.masterView.searchCriteria.text;
    resultViewController.searchCriteriaLimitString = self.masterView.searchLimitString.text;
    resultViewController.masterTableData = objects;
    resultViewController.masterTableHeader = [processDict objectForKey:@"SVMXC__Name__c"];
    //SMLog(kLogLevelVerbose,@"Master Table Header Value = %@",resultViewController.masterTableHeader);
    resultViewController.switchStatus = self.masterView.searchFilterSwitch.on;
    //SMLog(kLogLevelVerbose,@"Switch Value = %d",resultViewController.switchStatus);
    //[tableData release];
    resultViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    resultViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.mainView presentViewController:resultViewController animated:YES completion:^(void){}];
    //[resultViewController release];
	}@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name DetailViewControllerForSFM :didSelectRowAtIndexPath %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason DetailViewControllerForSFM :didSelectRowAtIndexPath %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

}

@end
