//
//  SFMPageController.m
//  iService
//
//  Created by Developer on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SFMPageController.h"
#import "iServiceAppDelegate.h"

@implementation SFMPageController

@synthesize delegate, rootView, detailView;
@synthesize processId, recordId, objectName, activityDate, accountId, topLevelId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mode:(BOOL)viewMode
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _viewMode = viewMode;
        // Custom initialization
        rootView = [[[RootViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_left_panel_bg_main_2.png"]];
        rootView.tableView.backgroundView = bgImage;
        [bgImage release];
        masterView = [[[UINavigationController alloc] initWithRootViewController:rootView] autorelease];
        
        detailView = [[[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil] autorelease];
        detailView.delegate = self;
        detailView.isInViewMode = viewMode;
        
        detailViewController = [[[UINavigationController alloc] initWithRootViewController:detailView] autorelease];
        
        splitView = [[UISplitViewController alloc] init];
        splitView.viewControllers = [NSArray arrayWithObjects:masterView, detailViewController, nil];
        splitView.view.frame = self.view.frame;
        splitView.delegate = detailView;

        [self.view addSubview:splitView.view];
        
        barButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:detailView action:@selector(splitViewController:popoverController:willPresentViewController:)];
        
//        popover = [[UIPopoverController alloc] initWithContentViewController:rootView];
    }
    return self;
}

- (void) setObjectName:(NSString *)_objectName
{
    objectName = _objectName;
    detailView.objectAPIName = _objectName;
}

- (void)dealloc
{
    [splitView release];
    [popover release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.didSFMUnload = YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.didSFMUnload)
    {
        appDelegate.didSFMUnload = NO;
        
        // Custom initialization
        rootView = [[[RootViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_left_panel_bg_main_2.png"]];
        rootView.tableView.backgroundView = bgImage;
        [bgImage release];
        masterView = [[[UINavigationController alloc] initWithRootViewController:rootView] autorelease];
        
        detailView = [[[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil] autorelease];
        detailView.delegate = self;
        detailView.isInViewMode = _viewMode;
        
        detailViewController = [[[UINavigationController alloc] initWithRootViewController:detailView] autorelease];
        
        splitView = [[UISplitViewController alloc] init];
        splitView.view.frame = self.view.frame;
        splitView.delegate = detailView;
        splitView.viewControllers = [NSArray arrayWithObjects:masterView, detailViewController, nil];

        [self.view addSubview:splitView.view];
        
        barButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:detailView action:@selector(splitViewController:popoverController:willPresentViewController:)];
        
//        popover = [[UIPopoverController alloc] initWithContentViewController:rootView];
    }

    self.recordId = appDelegate.sfmPageController.recordId;
    detailView.currentProcessId = self.processId;
    detailView.currentRecordId = self.recordId;
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];

}

- (void) viewDidAppear:(BOOL)animated
{
    
}

- (void)viewDidUnload
{
    [barButton release];
    barButton = nil;
    [popover release];
    popover = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
    {
        // Do something
        detailView.view.frame = self.view.frame;
        [detailView splitViewController:splitView willHideViewController:masterView withBarButtonItem:barButton forPopoverController:popover];
    }
    
    if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
    {
        // Do something
        [detailView splitViewController:splitView willShowViewController:masterView invalidatingBarButtonItem:barButton];
    }
	return YES;
}

#pragma mark - DetailViewController Delegate Method
- (void) Back:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
-(void) BackOnSave
{
    [self dismissModalViewControllerAnimated:YES];
    
}

@end
