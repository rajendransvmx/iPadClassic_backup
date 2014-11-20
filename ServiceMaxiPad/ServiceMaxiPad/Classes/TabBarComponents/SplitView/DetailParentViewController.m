//
//  DetailParentViewController.m
//  FloatingTabTest
//
//  Created by Himanshi Sharma on 02/09/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "DetailParentViewController.h"
#import "TagManager.h"

@interface DetailParentViewController ()

@end

@implementation DetailParentViewController
@synthesize smPopover;

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
    // Do any additional setup after loading the view.
}

#pragma mark - SMSplitViewControllerDelegate
- (void)splitViewController:(SMSplitViewController *)splitViewController willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem popover:(SMSplitPopover *)popover
{
    barButtonItem.title = [[TagManager sharedInstance]tagByName:kTagTools];

   //
    //
    //splitViewController.navigationItem.rightBarButtonItem = barButtonItem;
    splitViewController.navigationItem.leftBarButtonItem = barButtonItem;
    
    self.smPopover = popover;
}

- (void)splitViewController:(SMSplitViewController *)splitViewController willShowViewController:(UIViewController *)aViewController barButtonItem:(UIBarButtonItem *)barButtonItem
{
    //splitViewController.navigationItem.rightBarButtonItem = nil;
    splitViewController.navigationItem.leftBarButtonItem = nil;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
