//
//  InitialSyncViewController.m
//  ServiceMaxMobile
//
//  Created by Damodar on 23/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "InitialSyncViewController.h"
#import "SyncProgressDetailModel.h"
#import "SyncManager.h"
#import "StringUtil.h"
#import "SMAppDelegate.h"
#import "StyleManager.h"
#import "PageViewController.h"
#import "AppManager.h"
#import "TagManager.h"
#import "AutoLockManager.h"

@interface InitialSyncViewController ()

@end

@implementation InitialSyncViewController

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
    
    self.navigationController.navigationBar.barTintColor = [UIColor getUIColorFromHexValue:@"#E15001"];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.title = [[TagManager sharedInstance]tagByName:kTag_Initial_Sync];
    

    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor getUIColorFromHexValue:@"#E15001"];
    pageControl.backgroundColor = [UIColor whiteColor];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.progressIndicator.progress = 0.0f;
    self.progressMessage.text = [[TagManager sharedInstance]tagByName:kTag_Initiating_Sync];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.progressIndicator.progress = 0.0f;
    self.progressMessage.text = [[TagManager sharedInstance]tagByName:kTag_Initiating_Sync];
    self.initialSyncTitleLabel.text = [[TagManager sharedInstance]tagByName:kTag_WelcomeToServiceMaxMobile];
    
    self.detailLabel.text = [[TagManager sharedInstance]tagByName:kTag_WeAreDownloadingLatestWorkOrder];
    self.detailLabel2.text = [[TagManager sharedInstance]tagByName:kTag_WhileYouWaitTakeLook];
    
    SyncManager *syncMgr = [SyncManager sharedInstance];
    [syncMgr pushSyncProfileInfoToUserDefaultsWithValue:kSPSyncTypeInitialSync forKey:kSyncProfileSyncType]; // SP sync type
    [syncMgr performSyncWithType:SyncTypeInitial];
    
    [[AutoLockManager sharedManager] disableAutoLockSettingFor:initialSyncAL]; // Disable the user controlled device Autolock. 26-May-2015 BSP

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncStatusUpdated:)
                                                 name:kInitialSyncStatusNotification
                                               object:syncMgr];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   // [super dealloc];
}

- (IBAction)pageIndicatorTapped:(id)sender
{
    
}

- (void)syncStatusUpdated:(NSNotification*)aNotif
{
    if(aNotif.name == kInitialSyncStatusNotification)
    {
        SyncProgressDetailModel *object = [aNotif.userInfo objectForKey:@"syncstatus"];
        [self updateUserInterface:object];
    }
}

- (void)updateUserInterface:(SyncProgressDetailModel*)progressObject
{
    if(![StringUtil isStringEmpty:progressObject.progress])
    {
        float progress = [progressObject.progress floatValue];
        self.progressIndicator.progress = progress/100.0f;
    }
    if(![StringUtil isStringEmpty:progressObject.message])
    {
        self.progressMessage.text = [NSString stringWithFormat:@"%@ %@ %@ %@ - %@",[[TagManager sharedInstance]tagByName:kTagSyncProgressStep], progressObject.currentStep,[[TagManager sharedInstance]tagByName:kTagSyncProgressOf],progressObject.numberOfSteps,progressObject.message];
    }
    if([progressObject.progress integerValue] == 100)
    {
        [[AppManager sharedInstance] setApplicationStatus:ApplicationStatusInitialSyncCompleted];
        [[AppManager sharedInstance] loadScreen];
        
        [[AutoLockManager sharedManager] enableAutoLockSettingFor:initialSyncAL]; // Enable the user controlled device lock. 26-May-2015 BSP
        //[(SMAppDelegate*)[[UIApplication sharedApplication] delegate] loadHomeScreen];
    }
}

@end
