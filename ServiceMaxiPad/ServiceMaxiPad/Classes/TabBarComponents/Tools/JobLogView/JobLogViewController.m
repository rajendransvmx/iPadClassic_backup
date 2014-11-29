//
//  JobLogViewController.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 14/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "JobLogViewController.h"
#import "TaskManager.h"
#import "TaskModel.h"
#import "TaskGenerator.h"
#import "FlowDelegate.h"
#import "MBProgressHUD.h"
#import "AlertMessageHandler.h"
#import "FactoryDAO.h"
#import "JobLogDAO.h"
#import "PlistManager.h"
#import "DateUtil.h"
#import "WebserviceResponseStatus.h"
#import "TagManager.h"
#import "SNetworkReachabilityManager.h"
#import "TagConstant.h"


@interface JobLogViewController ()<FlowDelegate>
@property (nonatomic, strong)MBProgressHUD *HUD;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastSyncLabel;

@end

@implementation JobLogViewController

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
    //self.smSplitViewController.navigationItem.titleView = [UILabel navBarTitleLabel:[[TagManager sharedInstance]tagByName:kTagPushLogs]];
    [self.smPopover dismissPopoverAnimated:YES];
    [self updateLastPushLogTimeAndStatusUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushLogClicked:(UIButton *)sender {
    
    //Check the application level log settings, if off then we return with alert.
    if (![self isLogSettingsON]) {
        
        [[AlertMessageHandler sharedInstance] showCustomMessage:@"Application Level Log Setting is OFF." withDelegate:nil tag:89 title:@"ServiceMax" cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] andOtherButtonTitles:nil];
        return;
    }
    //Check DB whether there are any logs pending to be synced. if no then we show alert and return.
    
    [self showAnimator];
    if ([self isLogsAvailable]) {
        
        //Check internet availability if no then we show alert and return.
        if (![[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
        {
            [self hideAnimator];
            [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeInternetNotReachable];
            return;
        }

        
        TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeJobLog
                                                 requestParam:nil
                                               callerDelegate:self];
        [[TaskManager sharedInstance] addTask:taskModel];
    }
    else
    {
        [self hideAnimator];
        ///show alert that there are no logs to send.
        [[AlertMessageHandler sharedInstance] showCustomMessage:@"No logs to push." withDelegate:nil tag:89 title:@"ServiceMax" cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] andOtherButtonTitles:nil];
        SXLogError(@"Error: No logs to push");
    }
   
}

- (BOOL)isLogSettingsON {
    BOOL status = NO;
    NSInteger applicationLogSettingValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"application_level"];
    if (applicationLogSettingValue != ApplicationLogLevelOff) {
        status = YES;
    }
    return status;
}
- (BOOL)isLogsAvailable
{
    BOOL status = NO;
    id jobLogService = [FactoryDAO serviceByServiceType:ServiceTypeJobLog];
    
    if ([jobLogService conformsToProtocol:@protocol(JobLogDAO)]) {
        NSInteger count = [jobLogService getNumberOfRecordsFromObject:kJobLogsTableName
                                                       withDbCriteria:nil
                                                andAdvancedExpression:nil];
        if (count > 0) {
            status = YES;
        }
    }
    return status;
}

- (void)updateLastPushLogTimeAndStatusUI
{
    NSString *status = [PlistManager getLastPushLogStatus];
    NSString *lastTime = [PlistManager getLastPushLogGMTTime];
    if (status && lastTime) {
        
        self.statusLabel.text = status;
        self.lastSyncLabel.text = [DateUtil getLiteralSupportedDateStringForDate:[DateUtil getDateFromDatabaseString:lastTime]];
        
    } else {
        //Not even triggered once.
        self.statusLabel.text = @"- - - -";
        self.lastSyncLabel.text = @"- - - -";
    }
    
}

- (void)hideAnimator {
    
    if (self.HUD) {
        [self.HUD hide:YES];
        self.HUD = nil;
    }
}

- (void)showAnimator {
    if (!self.HUD) {
        self.HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
        [self.view.window addSubview:self.HUD];
        // Set determinate mode
        self.HUD.mode = MBProgressHUDModeIndeterminate;
        self.HUD.labelText = @"Uploading...";
        [self.HUD show:YES];
    }
}
#pragma mark - Flow delegates
- (void)flowStatus:(id)status
{
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *st = (WebserviceResponseStatus*)status;
        if (st.syncStatus == SyncStatusSuccess) {
            [PlistManager storeLastPushLogStatus:[[TagManager sharedInstance] tagByName:kTagPushLogStatusSuccess]];
            [PlistManager storeLastPushLogGMTTime:[DateUtil getDatabaseStringForDate:[NSDate date]]];
            [self updateLastPushLogTimeAndStatusUI];
            [self hideAnimator];
        } else if (st.syncStatus == SyncStatusFailed)
        {
            [PlistManager storeLastPushLogStatus:[[TagManager sharedInstance] tagByName:kTagPushLogStatusFailed]];
            [PlistManager storeLastPushLogGMTTime:[DateUtil getDatabaseStringForDate:[NSDate date]]];
            [self updateLastPushLogTimeAndStatusUI];
            [self hideAnimator];
        }
    }
}
@end