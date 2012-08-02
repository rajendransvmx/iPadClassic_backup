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
#import "iServiceAppDelegate.h"

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
    
    DetailViewControllerForSFM * detailView = [[[DetailViewControllerForSFM alloc] initWithNibName:@"DetailViewControllerForSFM" bundle:nil] autorelease];
    detailView.splitViewDelegate = self;
    detailView.mainView = self;
    UINavigationController * detailNav = [[[UINavigationController alloc] initWithRootViewController:detailView] autorelease];
    detailView.masterView = masterView;
    
    UISplitViewController * splitView = [[UISplitViewController alloc] init];
    splitView.viewControllers = [NSArray arrayWithObjects:masterNav, detailNav, nil];
    splitView.delegate = self;
    
    self.view = splitView.view;

}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(appDelegate.isInternetConnectionAvailable && [appDelegate pingServer])
    {
        masterView.searchFilterSwitch.enabled=TRUE;
    }
    else
    {
        [masterView.searchFilterSwitch setOn:NO];
        masterView.searchFilterSwitch.enabled=FALSE;
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
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if (deviceOrientation == UIInterfaceOrientationPortrait || deviceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        return YES;
    return NO;
}
#pragma mark - DetailViewControllerForSFM Delegate
- (void) DismissSplitViewController
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
