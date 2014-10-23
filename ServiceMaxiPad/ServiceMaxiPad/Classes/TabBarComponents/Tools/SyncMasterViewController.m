//
//  SyncMasterViewController.m
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 02/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SyncMasterViewController.h"
#import "SyncStatusDetailViewController.h"
#import "PurgeDataDetailViewController.h"
#import "ResetAppDetailViewController.h"
#import "SignOutDetailViewController.h"
#import "AboutViewController.h"
#import "ResolveConflictsDetailViewController.h"
#import "TextSizeDetailViewController.h"
#import "NotificationHistoryDetailViewController.h"
#import "StyleManager.h"
#import "JobLogViewController.h"
#import "ViewControllerFactory.h"

@interface SyncMasterViewController ()

@end

@implementation SyncMasterViewController

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
    //self.view.backgroundColor = [UIColor colorWithRed:0.9529 green:0.9529 blue:0.9529 alpha:1.0];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftPanelBG.png"]];

    
    [syncStatusBtn setTitle:@"Status and Manual Sync" forState:UIControlStateNormal];
    [syncStatusBtn setExclusiveTouch:YES];
    
    [self setBgColorForSelectBtn:syncStatusBtn]; //marking Status button selected
    selectedButton = syncStatusBtn;//marking Status button selected
    
    
    [resolveBtn setTitle:@"Resolve Conflicts" forState:UIControlStateNormal];
    [resolveBtn setExclusiveTouch:YES];

    [self setDefaultBgForBtn:resolveBtn];
    
    [purgeDataBtn setTitle:@"Purge Data" forState:UIControlStateNormal];
    [purgeDataBtn setExclusiveTouch:YES];

    [self setDefaultBgForBtn:purgeDataBtn];
    
    [pushLogBtn setTitle:@"Push Logs" forState:UIControlStateNormal];
    [pushLogBtn setExclusiveTouch:YES];
    
    [self setDefaultBgForBtn:pushLogBtn];
    
    [notificationHistoryBtn setTitle:@"Notification History" forState:UIControlStateNormal];
    [notificationHistoryBtn setExclusiveTouch:YES];

    [self setDefaultBgForBtn:notificationHistoryBtn];
    
    [textSizeBtn setTitle:@"Text Size" forState:UIControlStateNormal];
    [textSizeBtn setExclusiveTouch:YES];

    [self setDefaultBgForBtn:textSizeBtn];
    
    [aboutBtn setTitle:@"About" forState:UIControlStateNormal];
    [aboutBtn setExclusiveTouch:YES];

    [self setDefaultBgForBtn:aboutBtn];
    
    [resetAppBtn setTitle:@"Reset App" forState:UIControlStateNormal];
    [resetAppBtn setExclusiveTouch:YES];

    [self setDefaultBgForBtn:resetAppBtn];
    
    [signOutBtn setTitle:@"Sign Out" forState:UIControlStateNormal];
    [signOutBtn setExclusiveTouch:YES];

    [self setDefaultBgForBtn:signOutBtn];
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {

}

- (IBAction)syncStatusClicked:(id)sender {
    selectedButton = sender;

    SyncStatusDetailViewController *syncStatusVC = [[SyncStatusDetailViewController alloc]initWithNibName:@"SyncStatusDetailViewController" bundle:nil];
    syncStatusVC.smSplitViewController = self.smSplitViewController;
    UINavigationController *navController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    syncStatusVC.smPopover = ((DetailParentViewController *)[navController.viewControllers lastObject]).smPopover;
    navController.viewControllers = @[syncStatusVC];
    self.smSplitViewController.delegate = syncStatusVC;
}


- (IBAction)resolveConflictsClicked:(id)sender {
    selectedButton = sender;
    
    ResolveConflictsDetailViewController *resolveConflictVC = [[ResolveConflictsDetailViewController alloc]initWithNibName:@"ResolveConflictsDetailViewController" bundle:nil];
    resolveConflictVC.smSplitViewController = self.smSplitViewController;
    UINavigationController *navController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    self.smSplitViewController.delegate = resolveConflictVC;
    resolveConflictVC.smPopover = ((DetailParentViewController *)[navController.viewControllers lastObject]).smPopover;
    navController.viewControllers = @[resolveConflictVC];
    self.smSplitViewController.delegate = resolveConflictVC;
    
}


- (IBAction)purgeDataClicked:(id)sender {
    
    selectedButton = sender;

       PurgeDataDetailViewController *purgeDataVC = [[PurgeDataDetailViewController alloc]initWithNibName:@"PurgeDataDetailViewController" bundle:nil];
    purgeDataVC.smSplitViewController = self.smSplitViewController;
    UINavigationController *navController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    self.smSplitViewController.delegate = purgeDataVC;
    purgeDataVC.smPopover = ((DetailParentViewController *)[navController.viewControllers lastObject]).smPopover;
    navController.viewControllers = @[purgeDataVC];
    self.smSplitViewController.delegate = purgeDataVC;
    
}
- (IBAction)pushLogClicked:(id)sender {
    selectedButton = sender;
    JobLogViewController *jobLogVC = [ViewControllerFactory createViewControllerByContext:ViewControllerJobLog];
    jobLogVC.smSplitViewController = self.smSplitViewController;
    UINavigationController *navController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    self.smSplitViewController.delegate = jobLogVC;
    jobLogVC.smPopover = ((DetailParentViewController *)[navController.viewControllers lastObject]).smPopover;
    navController.viewControllers = @[jobLogVC];
    self.smSplitViewController.delegate = jobLogVC;
}

- (IBAction)notificationHistoryClicked:(id)sender {
    selectedButton = sender;
    
    NotificationHistoryDetailViewController *notificationVC = [[NotificationHistoryDetailViewController alloc]initWithNibName:@"NotificationHistoryDetailViewController" bundle:nil];
    notificationVC.smSplitViewController = self.smSplitViewController;
    UINavigationController *navController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    self.smSplitViewController.delegate = notificationVC;
    notificationVC.smPopover = ((DetailParentViewController *)[navController.viewControllers lastObject]).smPopover;
    navController.viewControllers = @[notificationVC];
    self.smSplitViewController.delegate = notificationVC;

}

- (IBAction)textSizeClicked:(id)sender {
    selectedButton = sender;
    
    TextSizeDetailViewController *textSizeVC = [[TextSizeDetailViewController alloc]initWithNibName:@"TextSizeDetailViewController" bundle:nil];
    textSizeVC.smSplitViewController = self.smSplitViewController;
    UINavigationController *navController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    self.smSplitViewController.delegate = textSizeVC;
    textSizeVC.smPopover = ((DetailParentViewController *)[navController.viewControllers lastObject]).smPopover;
    navController.viewControllers = @[textSizeVC];
    self.smSplitViewController.delegate = textSizeVC;
 
}

- (IBAction)aboutClicked:(id)sender {
    selectedButton = sender;

    AboutViewController *aboutAppVC = [[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil];
    aboutAppVC.smSplitViewController = self.smSplitViewController;
    UINavigationController *navController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    aboutAppVC.smPopover = ((DetailParentViewController *)[navController.viewControllers lastObject]).smPopover;
    navController.viewControllers = @[aboutAppVC];
    self.smSplitViewController.delegate = aboutAppVC;

}

- (IBAction)resetAppClicked:(id)sender {
    
    selectedButton = sender;

    ResetAppDetailViewController *resetAppVC = [[ResetAppDetailViewController alloc]initWithNibName:@"ResetAppDetailViewController" bundle:nil];
    resetAppVC.smSplitViewController = self.smSplitViewController;
    UINavigationController *navController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    resetAppVC.smPopover = ((DetailParentViewController *)[navController.viewControllers lastObject]).smPopover;
    navController.viewControllers = @[resetAppVC];
    self.smSplitViewController.delegate = resetAppVC;
    
  
}


- (IBAction)signOutClicked:(id)sender {
    
    selectedButton = sender;

    SignOutDetailViewController *signOutVC = [[SignOutDetailViewController alloc]initWithNibName:@"SignOutDetailViewController" bundle:nil];
    signOutVC.smSplitViewController = self.smSplitViewController;
    UINavigationController *navController = [self.smSplitViewController.viewControllers objectAtIndex:1];
    signOutVC.smPopover = ((DetailParentViewController *)[navController.viewControllers lastObject]).smPopover;
    navController.viewControllers = @[signOutVC];
    self.smSplitViewController.delegate = signOutVC;
}


-(void)setBgColorForSelectBtn:(id)inSender
{
    if (selectedButton)
    {
        NSLog(@"selcted button is %@",selectedButton);
        [self setDefaultBgForBtn:selectedButton];
    }
    
    UIButton *btn = (UIButton *)inSender;
    //btn.backgroundColor = [UIColor colorWithHexString:@"#333333"];
    //[btn setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateHighlighted];
    
    
    btn.backgroundColor = [UIColor colorWithHexString:@"#A8A8A8"];
    btn.opaque = 0.4;
    [btn setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    selectedButton = inSender;

}


-(void)setDefaultBgForBtn:(id)inBtnSender
{
    UIButton *btn = (UIButton *)inBtnSender;
    //btn.frame =CGRectInset(btn.frame, -borderWidth, -borderWidth);
   
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn setTitleColor:[UIColor colorWithHexString:@"#E15001"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(setBgColorForSelectBtn:) forControlEvents:UIControlEventTouchDown];
}



@end
