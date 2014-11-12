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
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#E15001"];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    self.title = @"Initial Sync";
    

    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"#E15001"];
    pageControl.backgroundColor = [UIColor whiteColor];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.progressIndicator.progress = 0.0f;
    self.progressMessage.text = @"Initiating Sync...";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.progressIndicator.progress = 0.0f;
    self.progressMessage.text = @"Initiating Sync...";
    
    SyncManager *syncMgr = [SyncManager sharedInstance];
    [syncMgr performSyncWithType:SyncTypeInitial];
    
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
    [super dealloc];
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
        self.progressMessage.text = [NSString stringWithFormat:@"%@ %@ %@ %@ - %@",[[TagManager sharedInstance]tagByName:kTagSyncProgressStep], progressObject.currentStep,[[TagManager sharedInstance]tagByName:kTagSyncProgressOf],progressObject.numberOfSteps,progressObject.message];
    
    if([progressObject.progress integerValue] == 100)
    {
        [[AppManager sharedInstance] setApplicationStatus:ApplicationStatusInitialSyncCompleted];
        [(SMAppDelegate*)[[UIApplication sharedApplication] delegate] loadHomeScreen];
    }
}


@end



