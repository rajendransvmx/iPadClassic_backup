//
//  MainViewController.m
//  SFMSearch
//
//  Created by Siva Manne on 11/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import "MainViewController.h"
#import "DetailViewControllerForSFM.h"
#import "MasterViewController.h"
#import "AppDelegate.h"
#import "Utility.h"

void SMXLog(const char *methodContext,NSString *message);

#define DOD         9.3

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    masterView = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    UINavigationController * masterNav = [[[UINavigationController alloc] initWithRootViewController:masterView] autorelease];
    /*ios7_support shravya-navbar*/
    if (![Utility notIOS7]) {
        UIImage *navImage = [Utility getLeftNavigationBarImage];
        [masterNav.navigationBar setBackgroundImage:navImage forBarMetrics:UIBarMetricsDefault];
        masterView.extendedLayoutIncludesOpaqueBars = YES;
        masterView.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    DetailViewControllerForSFM * detailView = [[[DetailViewControllerForSFM alloc] initWithNibName:@"DetailViewControllerForSFM" bundle:nil] autorelease];
    
    /*ios7_support shravya-navbar*/
    if (![Utility notIOS7]) {
        UIImage *navImage = [Utility getRightNavigationBarImage];
        // Need to look into this issue.
        //[detailNav.navigationBar setBackgroundImage:navImage forBarMetrics:UIBarMetricsDefault];
        detailView.extendedLayoutIncludesOpaqueBars = YES;
        detailView.edgesForExtendedLayout = UIRectEdgeNone;
        
    }
    detailView.splitViewDelegate = self;
    detailView.mainView = self;
    masterView.detailView = detailView;
    UINavigationController * detailNav = [[[UINavigationController alloc] initWithRootViewController:detailView] autorelease];
    detailView.masterView = masterView;
    UISplitViewController * splitView = [[UISplitViewController alloc] init];
    splitView.viewControllers = [NSArray arrayWithObjects:masterNav, detailNav, nil];
    splitView.delegate = self;
    
	splitView.view.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:splitView.view];
	splitView.view.frame = self.view.frame;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *packgeVersion;
    if (userDefaults)
    {
        packgeVersion = [userDefaults objectForKey:kPkgVersionCheckForGPS_AND_SFM_SEARCH];
        int _stringNumber = [packgeVersion intValue];
		int check = (DOD * 100000);
		SMLog(@"%d", check);
        if(_stringNumber >= check)
		{
			NSString * query =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS on_demand_download ('object_name' VARCHAR , 'sf_id' VARCHAR PRIMARY KEY  NOT NULL UNIQUE, 'time_stamp' DATETIME ,'local_id' VARCHAR, 'record_type' VARCHAR, 'json_record' VARCHAR) "];
			[appDelegate.dataBase createTable:query];
		}
		
    }
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

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - SplitViewController Delegate

// Called when a button should be added to a toolbar for a hidden view controller
- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc
{
    
}

// Called when the view is shown again in the split view, invalidating the button and popover controller
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    
}

// Called when the view controller is shown in a popover so the delegate can take action like hiding other popovers.
- (void)splitViewController: (UISplitViewController*)svc popoverController: (UIPopoverController*)pc willPresentViewController:(UIViewController *)aViewController
{
    
}

// Returns YES if a view controller should be hidden by the split view controller in a given orientation.
// (This method is only called on the leftmost view controller and only discriminates portrait from landscape.)
- (BOOL)splitViewController: (UISplitViewController*)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}
#pragma mark - DetailViewControllerForSFM Delegate
- (void) DismissSplitViewController
{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}
@end
