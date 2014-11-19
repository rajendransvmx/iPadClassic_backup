//
//  StandAloneCreateHomeController.m
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "StandAloneCreateHomeController.h"
#import "StandAloneCreateMasterController.h"
#import "StandAloneCreateDetailController.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "TagManager.h"


@interface StandAloneCreateHomeController ()

@end

@implementation StandAloneCreateHomeController

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
    self.view.backgroundColor = [UIColor redColor];
    self.navigationItem.titleView = [UILabel navBarTitleLabel:[[TagManager sharedInstance]tagByName:kTagNewItem]];
    
    self.navigationController.navigationBar.barTintColor = [UIColor navBarBG]; //Only for iOS7.0 and more than 7.0
    self.navigationController.navigationBar.translucent = NO;
    
    StandAloneCreateMasterController *masterViewController = [[StandAloneCreateMasterController alloc]initWithStyle:UITableViewStylePlain];
    masterViewController.smSplitViewController = self;
    
    StandAloneCreateDetailController *detailViewController = [[StandAloneCreateDetailController alloc] initWithNibName:nil bundle:nil];
    detailViewController.smSplitViewController = self;
    
    UINavigationController *detailNavController = [[UINavigationController alloc]initWithRootViewController:detailViewController];
    detailNavController.navigationBar.hidden = YES;
    //detailNavController.navigationBar.translucent = NO;
    self.delegate = detailViewController;
    self.viewControllers = @[masterViewController,detailViewController];
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
