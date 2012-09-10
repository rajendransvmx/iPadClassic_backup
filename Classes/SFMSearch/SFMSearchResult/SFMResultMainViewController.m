//
//  SFMResultMainViewController.m
//  SFMSearch
//
//  Created by Siva Manne on 11/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import "SFMResultMainViewController.h"
#import "SFMResultDetailViewController.h"
#import "SFMResultMasterViewController.h"
@interface SFMResultMainViewController ()

@end

@implementation SFMResultMainViewController
@synthesize filterString,sfmConfiguration,processId;
@synthesize resultmasterView;
@synthesize resultdetailView;
@synthesize masterTableData;
@synthesize searchCriteriaString;
@synthesize searchCriteriaLimitString;
@synthesize masterTableHeader;
@synthesize switchStatus;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        resultmasterView = [[SFMResultMasterViewController alloc] 
                      initWithNibName:@"SFMResultMasterViewController" bundle:nil];
        resultdetailView = [[SFMResultDetailViewController alloc] 
                      initWithNibName:@"SFMResultDetailViewController" bundle:nil];
        resultmasterView.resultDetailView = resultdetailView;

    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    // Do any additional setup after loading the view from its nib.
    UINavigationController * masterNav = [[[UINavigationController alloc] initWithRootViewController:resultmasterView] autorelease];
    
    resultdetailView.splitViewDelegate = self;
    UINavigationController * detailNav = [[[UINavigationController alloc] initWithRootViewController:resultdetailView] autorelease];
  
    resultdetailView.masterView = resultmasterView;
    resultdetailView.mainView = self;
    UISplitViewController * splitView = [[UISplitViewController alloc] init];
    splitView.viewControllers = [NSArray arrayWithObjects:masterNav, detailNav, nil];
    splitView.delegate = self;
    
    self.view = splitView.view;
    [resultmasterView setSearchData:filterString];
    [resultmasterView setSearchCriteriaString:searchCriteriaString];
    [resultmasterView setSearchCriteriaLimitString:searchCriteriaLimitString];
    [resultmasterView setTableHeader:masterTableHeader];
    [resultmasterView setTableArray:masterTableData];
    [resultmasterView setProcessId:processId];
    //resultmasterView.searchFilterSwitch.on = switchStatus;
    [resultmasterView setSwitchStatus:switchStatus];

    [resultdetailView setSfmConfigName:masterTableHeader];

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [resultmasterView reloadTableData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return YES;
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void) dealloc
{
    [searchCriteriaLimitString release];
    [searchCriteriaString release];
    [masterTableData release];
    [masterTableHeader release];
    [resultmasterView release];
    [resultdetailView release];
    [filterString release];
    [sfmConfiguration release];
    [super dealloc];
}

#pragma mark - SFMResultDetailViewController Delegate
- (void) DismissSplitViewController
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
