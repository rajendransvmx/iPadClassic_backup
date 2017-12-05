//
//  ResetAppDetailViewController.m
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 03/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "ResetAppDetailViewController.h"
#import "SNetworkReachabilityManager.h"
#import "SMRegularAlertView.h"
#import "SMProgressAlertView.h"
#import "AlertMessageHandler.h"
#import "AppManager.h"
#import "SyncManager.h"
#import "SyncProgressDetailModel.h"
#import "StringUtil.h"
#import "SMAppDelegate.h"
#import "TagManager.h"
#import "DatabaseConfigurationManager.h"
#import "Reachability.h"
#import "AutoLockManager.h"


@interface ResetAppDetailViewController ()

@property (nonatomic, strong) SMRegularAlertView *confirmAlertView;
@property (nonatomic, strong) SMProgressAlertView *progressAlertView;

- (void)showResetApplicationRetryConfirmationMessageProfileFailed:(BOOL)profileFailed;

@end


@implementation ResetAppDetailViewController

@synthesize progressAlertView;
@synthesize confirmAlertView;

- (void)registerNetworkChangeNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(makeActionAccordingToNetworkChangeNotification:)
                                                 name:kNetworkConnectionChanged
                                               object:nil];
}

- (void)deregisterNetworkChangeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNetworkConnectionChanged object:nil];
}


- (void)makeActionAccordingToNetworkChangeNotification:(NSNotification *)notification
{
    if ([notification isKindOfClass:[NSNotification class]])
    {
        SXLogInfo(@" notification - %@", [notification description]);
    }

    // PCRD-73 #82
    // update 'Reset App' button status when there is change in network connectivity status.
    double updateWithDelayTime = 1.0;
    dispatch_time_t updateWithDelayDispatchTime = dispatch_time(DISPATCH_TIME_NOW, updateWithDelayTime*NSEC_PER_SEC);
    dispatch_after(updateWithDelayDispatchTime, dispatch_get_main_queue(), ^(void){
        // call method update the button status
        [self loadResetAppButton];
    });
}

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
    resetAppBtn.layer.borderColor = [UIColor orangeColor].CGColor;
    //self.smSplitViewController.navigationItem.titleView = [UILabel navBarTitleLabel:[[TagManager sharedInstance]tagByName:kTagResetApp]];
    resetAppBtn.layer.borderWidth = 0.8;
    [resetAppBtn setTitle:[[TagManager sharedInstance]tagByName:kTagResetApp] forState:UIControlStateNormal];
    [self.smPopover dismissPopoverAnimated:YES];
    resetAppBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self registerNetworkChangeNotification];
    [self loadResetAppButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    resetAppLabel.text = [NSString stringWithFormat:@"%@ \n%@",[[TagManager sharedInstance]tagByName:kTag_ResettingAppRemoveLocalData],[[TagManager sharedInstance]tagByName:kTag_InternetRequiredToResetApp]];
    resetAppTitle.text = [[TagManager sharedInstance]tagByName:kTagResetApp];
    [resetAppBtn setTitle:[[TagManager sharedInstance]tagByName:kTagResetApp] forState:UIControlStateNormal];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self removeNotificationForResetApp];
    [self deregisterNetworkChangeNotification];
}

- (IBAction)resetAppClicked:(id)sender
{
    if ( [[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
    {
        if ([[AppManager sharedInstance] hasTokenRevoked])
        {
            [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeAccessTokenExpired
                                                                   message:nil
                                                               andDelegate:nil];
        }
        else
        {
            [self showResetApplicationConfirmationMessage];
        }
    }
}

-(void)setBgColorForSelectBtn:(id)inSender
{
    UIButton *btn = (UIButton *)inSender;
    btn.backgroundColor = [UIColor getUIColorFromHexValue:@"E15001"];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}

-(void)setDefaultBgForBtn:(id)inBtnSender
{
    UIButton *btn = (UIButton *)inBtnSender;
    CGFloat borderWidth = 1.0f;
    btn.layer.borderColor =[UIColor getUIColorFromHexValue:@"#E15001"].CGColor;
    btn.layer.borderWidth = borderWidth;
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn setTitleColor:[UIColor getUIColorFromHexValue:@"#E15001"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(setBgColorForSelectBtn:) forControlEvents:UIControlEventTouchDown];
}

- (void)loadResetAppButton
{
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
    {
        resetAppBtn.userInteractionEnabled = YES;
        resetAppBtn.layer.borderColor = [UIColor orangeColor].CGColor;
        [resetAppBtn setBackgroundColor:[UIColor getUIColorFromHexValue:@"#FF6633"]];
        [resetAppBtn setTitleColor:[UIColor getUIColorFromHexValue:@"#FFFFFF"] forState:UIControlStateNormal];
    }
    else
    {
        resetAppBtn.userInteractionEnabled = NO;
        resetAppBtn.layer.borderColor =[UIColor getUIColorFromHexValue:@"#AEAEAE"].CGColor;
        [resetAppBtn setBackgroundColor:[UIColor getUIColorFromHexValue:@"#AEAEAE"]];
        [resetAppBtn setTitleColor:[UIColor getUIColorFromHexValue:@"#FFFFFF"] forState:UIControlStateNormal];
    }
}

- (void)showResetApplicationConfirmationMessage
{
    NSString *tittle = [[TagManager sharedInstance]tagByName:kTag_ConfirmAppReset];
   // NSString *message1 = [[TagManager sharedInstance]tagByName:kTag_ThisWillRemoveData];This will remove all ServiceMax data stored on this iPad and re-synchronize with the server.
    //NSString *message2 = [[TagManager sharedInstance]tagByName:kTag_ProcessTakeSeveralMinutes];
    //NSString *message1 = @"This will remove all ServiceMax data stored on this iPad and re-synchronize with the server.";//Need a new tag as per defect
   // NSString *message2 = @"This process can take several minutes. You will be unable to use the ServiceMax iPad app during app reset.";//Need new tag
    
    
    
    
    

    
    NSString *titleCancel = [[TagManager sharedInstance]tagByName:kTagCancelButton];
    NSString *otherButtonTittle = [[TagManager sharedInstance]tagByName:kTagResetApp];
    

   
    //HS 9 Jan commented
    /*
     NSArray *messages = [NSArray arrayWithObjects:message1, message2, nil];

     */
    
    NSArray *messages = [NSArray arrayWithObjects:[[TagManager sharedInstance]tagByName:kTag_RemoveDataAlertMsg], nil];

    SMRegularAlertView *alertView  = [[SMRegularAlertView alloc] initWithTitle:tittle
                                                                      delegate:self
                                                                      messages:messages
                                                                  cancelButton:titleCancel
                                                                   otherButton:otherButtonTittle];

    
    self.confirmAlertView = alertView;
    alertView = nil;
}

- (void)showResetApplicationProgressStatusMessage
{
    NSString *tittle   = [[TagManager sharedInstance]tagByName:kTag_AppResetInProgress];
    NSString *message1 = [[TagManager sharedInstance]tagByName:kTag_PleaseDoNotSwitchApp];
    NSString *message2 = [[TagManager sharedInstance]tagByName:kTag_DoingCancelReset];
    NSArray *messages = [NSArray arrayWithObjects:message1, message2, nil];
    
    
    SMProgressAlertView *alertView  = [[SMProgressAlertView alloc] initWithTitle:tittle
                                                                        delegate:self
                                                                        messages:messages
                                                                    cancelButton:nil
                                                                     otherButton:nil];
    self.progressAlertView = alertView;
    
    [progressAlertView updateProgressBarWithValue:0.001
                                       andMessage:[[TagManager sharedInstance]tagByName:kTag_ResetingApplicationContents]];
    alertView = nil;
}

//Adding alert for Validation Profile
- (void)showValidatingProfileStatusMessage
{
    NSString *tittle   = [[TagManager sharedInstance]tagByName:kTag_ProfileValidationInProgress];
    NSString *message1 = [[TagManager sharedInstance]tagByName:kTag_PleaseDoNotSwitchApp];

    /*
    NSString *message2 = [[TagManager sharedInstance]tagByName:kTag_DoingWillCancelProfileValidation];
     */
    
    NSString *message2 = [[TagManager sharedInstance]tagByName:kTag_DoingWillCancelProfileValidation];//@"Doing so will cancel or interrupt profile validation.";
    NSArray *messages = [NSArray arrayWithObjects:message1, message2, nil];
    
    
    SMProgressAlertView *alertView  = [[SMProgressAlertView alloc] initWithTitle:tittle
                                                                        delegate:self
                                                                        messages:messages
                                                                    cancelButton:nil
                                                                     otherButton:nil];
    self.progressAlertView = alertView;
    
    /*[progressAlertView updateProgressBarWithValue:0.4
                                       andMessage:[[TagManager sharedInstance]tagByName:kTag_ValidatingProfile]]; */
   
    [progressAlertView updateProgressBarWithValue:0.4
                                       andMessage:[[TagManager sharedInstance]tagByName:kTag_ValidatingProfile]];
   
    alertView = nil;
}

- (void)smAlertView:(SMAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    SXLogInfo(@" smAlertView Selcted at button Index :%ld", (long)buttonIndex);
    [alertView removeFromSuperview];
    self.confirmAlertView = nil;
    
    // Selected 'Reset App' Option. Lets proceed it.
    if (buttonIndex != 0)
    {
        if ( [[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
        {
            [self startResetApplication];
        }
        else
        {
             [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeInternetNotReachable];
        }
    }
    //else meant; Cancelled the Sync option. Nothing to worry here.
}

- (void)startResetApplication
{
    [self addNotificationForProfileValidation];
    [self showValidatingProfileStatusMessage];
    
    SyncManager *syncManager = [SyncManager sharedInstance];
    [syncManager performSyncWithType:SyncTypeValidateProfile];
}


- (void)syncStatusUpdated:(NSNotification*)aNotif
{
    if(aNotif.name == kInitialSyncStatusNotification)
    {
        SyncProgressDetailModel *object = [aNotif.userInfo objectForKey:@"syncstatus"];
        [self updateUserInterface:object];
    }
    
    if(aNotif.name == kProfileValidationStatusNotification)
    {
        SyncProgressDetailModel *object = [aNotif.userInfo objectForKey:@"syncstatus"];
        [self updateValidateProfileUI:object];
    }
}

-(void)updateValidateProfileUI:(SyncProgressDetailModel *)progressObject
{
    [progressAlertView updateProgressBarWithValue:1.0
                                       andMessage:[[TagManager sharedInstance]tagByName:kTag_ValidatingProfile]];
    [self.progressAlertView removeFromSuperview];
    [self removeNotificationForProfileValidation];
    
    if (progressObject.syncStatus == SyncStatusSuccess)
    {
        SXLogDebug(@"Validation profile Succeded");
        
        [[AutoLockManager sharedManager] disableAutoLockSettingFor:resetAppAL];

        
        [self addNotificationForResetApp];
        [self showResetApplicationProgressStatusMessage];
        
        SyncManager *syncManager = [SyncManager sharedInstance];
        if([syncManager isDataSyncInProgress])
        {
            [syncManager enqueueSyncQueue:SyncTypeInitial];
        }
        else
        {
            [[AppManager sharedInstance] resetApplicationContents];
            [syncManager pushSyncProfileInfoToUserDefaultsWithValue:kSPSyncTypeResetApp forKey:kSyncProfileSyncType]; // SP sync type
            [syncManager performSyncWithType:SyncTypeInitial];
        }
    }
    else
    {
        SXLogWarning(@"Validation profile Failed");
    }
}

- (void)updateUserInterface:(SyncProgressDetailModel*)progressObject
{
    NSString *message = nil;
    
    if (![StringUtil isStringEmpty:progressObject.message])
    {
        message = [NSString stringWithFormat:@"%@ %@ %@ %@ - %@",[[TagManager sharedInstance]tagByName:kTagSyncProgressStep], progressObject.currentStep,[[TagManager sharedInstance]tagByName:kTagSyncProgressOf],progressObject.numberOfSteps,progressObject.message];
    }
    
    float progress = 1.0;
    
    if (![StringUtil isStringEmpty:progressObject.progress])
    {
        progress = [progressObject.progress floatValue];
    }
    
    if (message != nil)
    {
        [self.progressAlertView updateProgressBarWithValue:progress/100.0f andMessage:message];
    }

    if (progressObject.syncStatus == SyncStatusSuccess)
    {
        if ([progressObject.progress integerValue] == 100)
        {
            [self.progressAlertView removeFromSuperview];
            self.progressAlertView = nil;
            [self removeNotificationForResetApp];
            
            [[AppManager sharedInstance] loadHomeScreen];
            
            [[AutoLockManager sharedManager] enableAutoLockSettingFor:resetAppAL];

        }
    }
    else if (progressObject.syncStatus == SyncStatusFailed)
    {
        // reset progress to 0
        [self.progressAlertView updateProgressBarWithValue:0 andMessage:[[TagManager sharedInstance]tagByName:kTag_Retrying]];
        
        [[AutoLockManager sharedManager] enableAutoLockSettingFor:resetAppAL];

    }
}


// not used currently..
- (void)showResetApplicationRetryConfirmationMessageProfileFailed:(BOOL)profileFailed
{
    NSString *tittle   = [[TagManager sharedInstance]tagByName:kTag_SyncFailed];
    
    if (profileFailed)
    {
        tittle = [[TagManager sharedInstance]tagByName:kTag_ProfileValidationfailed];
    }
    
    NSString *message1 =[[TagManager sharedInstance]tagByName:kTag_WouldRetryResetApplicationNow];

    NSString *titleCancel = [[TagManager sharedInstance]tagByName:kTagSyncProgressIWillTry];
    NSString *otherButtonTittle = [[TagManager sharedInstance]tagByName:kTagSyncProgressRetry];
    
    [[AlertMessageHandler sharedInstance]showCustomMessage:message1
                                              withDelegate:self
                                                       tag:200
                                                     title:tittle
                                         cancelButtonTitle:titleCancel
                                      andOtherButtonTitles:@[otherButtonTittle]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // Yoo initial sync failed!! Lets remove incompleted data
        
        [[AppManager sharedInstance] setApplicationFailedStatus:ApplicationStatusInitialSyncFailed];
        [[DatabaseConfigurationManager sharedInstance] performDatabaseConfigurationForSwitchUser];
        [[AppManager sharedInstance] setApplicationFailedStatus:ApplicationStatusInAuthenticationPage];
        [[AppManager sharedInstance] loadScreen];
    }
    else
    {
        if ( [[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
        {
            [self startResetApplication];
        }
        else
        {
            [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeInternetNotReachable];
        }
    }
}


#pragma mark - validation profile notification 

-(void)addNotificationForProfileValidation {
    SyncManager *syncMgr = [SyncManager sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncStatusUpdated:) name:kProfileValidationStatusNotification object:syncMgr];
}


-(void)removeNotificationForProfileValidation {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProfileValidationStatusNotification object:nil];
}

#pragma mark - reset app notification

-(void)addNotificationForResetApp {
    SyncManager *syncManager = [SyncManager sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncStatusUpdated:) name:kInitialSyncStatusNotification object:syncManager];
}

-(void)removeNotificationForResetApp {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInitialSyncStatusNotification object:nil];
}

@end
