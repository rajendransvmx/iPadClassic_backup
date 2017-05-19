//
//  SignOutDetailViewController.m
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 03/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SignOutDetailViewController.h"
#import "OAuthService.h"
#import "AppManager.h"
#import "SVMXSystemUtility.h"
#import "CacheManager.h"
#import "SNetworkReachabilityManager.h"
#import "LocationPingManager.h"
#import "TagManager.h"
#import "MBProgressHUD.h"
#import "SyncManager.h"

@interface SignOutDetailViewController ()

@property(nonatomic) BOOL                       isLogoutInProgress;
@property(nonatomic, strong) SMRegularAlertView *regularAlertView;
@property(nonatomic, strong) MBProgressHUD      *HUD;
@end


@implementation SignOutDetailViewController

@synthesize isLogoutInProgress;

@synthesize regularAlertView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - Network Reachability Management

/**
 * @name   registerNetworkChangeNotification
 *
 * @author Vipindas Palli
 *
 * @brief  Register for network change observation
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return void
 *
 */

- (void)registerNetworkChangeNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(makeActionAccordingToNetworkChangeNotification:)
                                                 name:kNetworkConnectionChanged
                                               object:nil];
    
}

/**
 * @name   registerNetworkChangeNotification
 *
 * @author Vipindas Palli
 *
 * @brief  Deregister for network change observation
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return void
 *
 */


- (void)deregisterNetworkChangeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNetworkConnectionChanged object:nil];
}
- (void) registerDataSyncCompleteNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataSyncCompletedNotification:)
                                                 name:kDataSyncStatusNotification
                                               object:nil];
}
- (void)deregisterDataSyncCompleteNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDataSyncStatusNotification object:nil];
}

- (void)loadSignoutButton
{
    BOOL isSyncInProgress = [self syncInProgress];
    [signOutBtn setTitle:[[TagManager sharedInstance]tagByName:kTagSignOut] forState:UIControlStateNormal];
    //signOutLabel.text = @"Sign out ends your session with ServiceMax Mobile. You will need to sign in again to regain access.";
    signOutLabel.text = [[TagManager sharedInstance]tagByName:kTagsessionExpiredMsg];
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable] && !isSyncInProgress)
     {
         signOutBtn.userInteractionEnabled = YES;
         signOutBtn.layer.borderColor = [UIColor orangeColor].CGColor;
         [signOutBtn setBackgroundColor:[UIColor getUIColorFromHexValue:@"#FF6633"]];
         [signOutBtn setTitleColor:[UIColor getUIColorFromHexValue:@"#FFFFFF"] forState:UIControlStateNormal];
     }
     else
     {
        signOutBtn.userInteractionEnabled = NO;
        signOutBtn.layer.borderColor =[UIColor getUIColorFromHexValue:@"#AEAEAE"].CGColor;
        [signOutBtn setBackgroundColor:[UIColor getUIColorFromHexValue:@"#AEAEAE"]];
        [signOutBtn setTitleColor:[UIColor getUIColorFromHexValue:@"#FFFFFF"] forState:UIControlStateNormal];
     }
}

- (void)viewDidAppear:(BOOL)animated
{
    signOutTitle.text = [[TagManager sharedInstance]tagByName:kTagSignOut];
    [super viewDidAppear:animated];
        //code to be executed on the main queue after delay
    
    [self loadSignoutButton];
}

- (BOOL)syncInProgress {
    
    BOOL isSyncInProgress = NO;
    if ([[SyncManager sharedInstance] syncInProgress]) {
        //check for sync in progress.
        isSyncInProgress = YES;
    }
    return isSyncInProgress;
}

- (void)makeActionAccordingToNetworkChangeNotification:(NSNotification *)notification
{
    if ([notification isKindOfClass:[NSNotification class]])
    {
//        SXLogInfo(@" notification - %@", [notification description]);
    }
    
    // PCRD-73 #82
    // update 'Sign Out' button status when there is change in network connectivity status.
    double updateWithDelayTime = 1.0;
    dispatch_time_t updateWithDelayDispatchTime = dispatch_time(DISPATCH_TIME_NOW, updateWithDelayTime * NSEC_PER_SEC);
    dispatch_after(updateWithDelayDispatchTime, dispatch_get_main_queue(), ^(void){
        // call method update the button status
        [self loadSignoutButton];
    });
}
- (void)dataSyncCompletedNotification:(NSNotification *)notification {
 
    [self loadSignoutButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.smSplitViewController.navigationItem.titleView = [UILabel navBarTitleLabel:[[TagManager sharedInstance]tagByName:kTagSignOut]];
    signOutBtn.layer.borderColor = [UIColor orangeColor].CGColor;
    signOutBtn.layer.borderWidth = 0.8;
    signOutBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [signOutBtn setTitle:[[TagManager sharedInstance]tagByName:kTagSignOut] forState:UIControlStateNormal];
    [self.smPopover dismissPopoverAnimated:YES];
    CGRect theFrame = self.view.bounds;

    theFrame.origin.x = theFrame.origin.x/2 - 164/2;
    theFrame.origin.y = 138;
    theFrame.size.width = 164;
    theFrame.size.height = 141;
    //signOutBtn.frame = theFrame;
    //signOutBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    seperatorLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self registerNetworkChangeNotification];
    [self registerDataSyncCompleteNotification];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self deregisterNetworkChangeNotification];
    [self deregisterDataSyncCompleteNotification];
}

/**
 * @name   signOutClicked:
 *
 * @author Vipindas Palli
 *
 * @brief  Logging in progress
 *
 * \par
 *  <Longer description starts here>
 *
 * @return String value
 *
 */

- (IBAction)signOutClicked:(id)sender
{
    SXLogDebug(@"Pressed  logout ");
    
    if (self.isLogoutInProgress)
    {
        SXLogDebug(@"Pressed logout Go BACK !!!");
        return;
    }
    else
    {
        isLogoutInProgress = YES;
        
        [self performSelectorInBackground:@selector(performLoggout) withObject:self];
    }
}

- (void)performLoggout
{
    [[SVMXSystemUtility sharedInstance] startNetworkActivity];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAnimator];
    });
    
    @synchronized([self class])
    {
        // SECSCAN-260
        
        OauthConnectionHandler *service =[[OauthConnectionHandler alloc] init];
        [service revokeAccessTokenWithCompletion:^(BOOL isSuccess, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideAnimator];
                //[[CacheManager sharedInstance] clearCache];
                //[OAuthService clearOAuthErrorMessage];
                
                [[SyncManager sharedInstance] invalidateScheduleSync];
                /*
                 * Since timers are gettings invalidated.
                 */
                [[SyncManager sharedInstance] removeConfigSyncLocalNotification];
                [self performResetContentOnLogout];
                [self showConfirmLogoutMessage];
                
            });
            
            isLogoutInProgress = NO;
            [[SVMXSystemUtility sharedInstance] stopNetworkActivity];
        }];
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
    //btn.frame =CGRectInset(btn.frame, -borderWidth, -borderWidth);
    btn.layer.borderColor =[UIColor getUIColorFromHexValue:@"#E15001"].CGColor;
    btn.layer.borderWidth = borderWidth;
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn setTitleColor:[UIColor getUIColorFromHexValue:@"#E15001"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(setBgColorForSelectBtn:) forControlEvents:UIControlEventTouchDown];
}


- (void)showConfirmLogoutMessage
{
    NSString *tittle   = [[TagManager sharedInstance]tagByName:kTag_SignedOut];
    NSString *message1 = [[TagManager sharedInstance]tagByName:kTag_YouHaveSignedOut];
    NSString *message2 = [[TagManager sharedInstance]tagByName:kTag_ThanksForUsingServiceMax];
    
    NSString *titleCancel = nil;
    NSString *otherButtonTittle = [[TagManager sharedInstance]tagByName:kSignIn];
    
    NSArray *messages = [NSArray arrayWithObjects:message1, message2, nil];
    
    SMRegularAlertView *alertView = [[SMRegularAlertView alloc] initWithTitle:tittle
                                                                            delegate:self
                                                                            messages:messages
                                                                        cancelButton:titleCancel
                                                                         otherButton:otherButtonTittle];
    self.regularAlertView = alertView;
    
    alertView = nil;

}


-(void)performResetContentOnLogout {
    [[LocationPingManager sharedInstance] stopLocationPing];
    [[SyncManager sharedInstance] enableAllParallelSync:NO];
    [[CacheManager sharedInstance] clearCache];
    [OAuthService clearOAuthErrorMessage];
    [[AppManager sharedInstance] completedLogoutProcess];
}

- (void)smAlertView:(SMAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView removeFromSuperview];
    self.regularAlertView = nil;
    
    // Selected 'Sign In' Option. Lets proceed it.
    if (buttonIndex != 0)
    {
        [[AppManager sharedInstance] loadScreen];
    }
    //else meant; Cancelled the Sync option. Nothing to worry here.
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
        self.HUD.labelText = [[TagManager sharedInstance]tagByName:kTag_LoggingOut];
        [self.HUD show:YES];
    }
}

@end
