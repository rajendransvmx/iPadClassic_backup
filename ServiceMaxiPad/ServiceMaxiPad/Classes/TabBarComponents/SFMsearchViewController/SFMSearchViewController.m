//
//  SearchViewController.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 07/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SFMSearchViewController.h"
#import "StringUtil.h"
#import "StyleGuideConstants.h"
#import "SMNavigationTitleView.h"
#import "StyleManager.h"
#import "SearchDetailViewController.h"
#import "SearchMasterViewController.h"
#import "TagManager.h"

@interface SFMSearchViewController ()

@end

@implementation SFMSearchViewController

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
    [self loadChildViewControllers];
    [self loadData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Loading child view Controllers
- (void)loadChildViewControllers {
    
    SearchMasterViewController *searchMasterVC = [[SearchMasterViewController alloc] initWithNibName:@"SearchMasterViewController" bundle:nil];
    searchMasterVC.containerViewControlerDelegate = self;
    self.navigationController.navigationBar.barTintColor = [UIColor navBarBG]; //ios 7.0 +
    self.navigationController.navigationBar.translucent = NO;
    
    
    SearchDetailViewController *searchDetailVC = [[SearchDetailViewController alloc] initWithNibName:@"SearchDetailViewController" bundle:nil];
    searchDetailVC.containerViewControlerDelegate = self;
    self.viewControllers = @[searchMasterVC, searchDetailVC];
    self.delegate = searchDetailVC;
}

#pragma mark - Loading Data

- (void)loadData {
    /* Start activity indicator */
    
    /*Reload both master and child data*/
    [self performSelectorOnMainThread:@selector(refreshAllViews) withObject:nil waitUntilDone:NO];
    
    /* Stop activity indicator */
    
}
#pragma mark -View Set up
- (void)setNavigationPropertiesAndButtons
{
    NSString *titleValue = [[TagManager sharedInstance]tagByName:kTagExplore]; //TODO : need to change
    self.navigationItem.titleView = [UILabel navBarTitleLabel:titleValue];
}

#pragma mark - Refresh views

- (void)refreshAllViews {
    [self setNavigationPropertiesAndButtons];
    [self refreshMasterAndDetailViews:NO];
}
- (void)refreshMasterAndDetailViews:(BOOL)isDetailOnly {
   
    if ([self.childViewControllers count] < 2) {
        return;
    }
    
    if (!isDetailOnly) {
        SearchMasterViewController *masterViewController = [self.childViewControllers objectAtIndex:0];
        //masterViewController.sfmPage = self.sfmPage;
        if ([masterViewController conformsToProtocol:@protocol(SearchViewControllerDelegate)]) {
            [masterViewController reloadData];
        }
        
    }
    SearchDetailViewController *detailViewController = [self.childViewControllers objectAtIndex:1];
//    detailViewController.sfmPage = self.sfmPage;
    if ([detailViewController conformsToProtocol:@protocol(SearchViewControllerDelegate)]) {
        [detailViewController reloadData];
    }
    
}


@end
