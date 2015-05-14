//
//  PurgeDataDetailViewController.m
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 03/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "PurgeDataDetailViewController.h"
#import "SNetworkReachabilityManager.h"
#import "TagManager.h"
#import "Reachability.h"
#import "FileManager.h"
#import "SyncManager.h"
#import "SMDataPurgeManager.h"
#import "SVMXSystemConstant.h"
#import "SMProgressAlertView.h"
#import "NSNotificationCenter+UniqueNotif.h"
#import "AppManager.h"
#import "AlertMessageHandler.h"

@interface PurgeDataDetailViewController ()
@property (nonatomic, strong)SMProgressAlertView *progressAlertView;

@property (weak, nonatomic) IBOutlet UILabel *purgeDataMainTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *purgeDataDescriptionLabel;


@property (weak, nonatomic) IBOutlet UILabel *purgeDataStatusTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastPurgeDataTimeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastPurgeDataTimeLabel;


@property (weak, nonatomic) IBOutlet UILabel *lastPurgeDataStatusTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *purgeDataStatusLabel;

@property (weak, nonatomic) IBOutlet UILabel *nextPurgeDataTimeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextPurgeDataTimeLabel;

@property (weak, nonatomic) IBOutlet UIButton *purgeDataNowButton;

- (IBAction)purgeDataClicked:(id)sender;

@end

@implementation PurgeDataDetailViewController

- (void)registerNetworkChangeNotification
{
    [[NSNotificationCenter defaultCenter] addUniqueObserver:self
                                                   selector:@selector(makeActionAccordingToNetworkChangeNotification:)
                                                       name:kNetworkConnectionChanged
                                                     object:nil];
    //16806 : Update the time text on changing the timezone and entering foreground
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(
                                                                              handleAppEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
}

- (void)deregisterNetworkChangeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNetworkConnectionChanged object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}
- (void) handleAppEnterForeground {
    [self updateLastPurgeDataTimeAndStatusUI];
    [self updateNextPurgeDataTimeUI];
}

- (void)makeActionAccordingToNetworkChangeNotification:(NSNotification *)notification
{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [self loadPurgeButton];
    });
}

- (void)loadPurgeButton
{
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
    {
        self.purgeDataNowButton.userInteractionEnabled = YES;
        self.purgeDataNowButton.layer.borderColor      = [UIColor orangeColor].CGColor;
        [self.purgeDataNowButton setBackgroundColor:[UIColor colorWithHexString:@"#FF6633"]];
        [self.purgeDataNowButton setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    }
    else
    {
        self.purgeDataNowButton.userInteractionEnabled = NO;
        self.purgeDataNowButton.layer.borderColor      =[UIColor colorWithHexString:@"#AEAEAE"].CGColor;
        [self.purgeDataNowButton setBackgroundColor:[UIColor colorWithHexString:@"#AEAEAE"]];
        [self.purgeDataNowButton setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    }
}

- (void)setupUIElements {
    
    
    
    self.purgeDataNowButton.layer.borderColor = [UIColor orangeColor].CGColor;
    self.purgeDataNowButton.layer.borderWidth = 0.8;
    
    self.purgeDataMainTitleLabel.text         = [[TagManager sharedInstance]tagByName:kTagPurgeData];
    self.purgeDataDescriptionLabel.text       = [NSString stringWithFormat:@"%@ \n%@",[[TagManager sharedInstance]tagByName:kTag_PurgingDataRemovesOldAppmt],[[TagManager sharedInstance]tagByName:kTag_InternetRequiredToPurgeData]];
   
    
    self.purgeDataStatusTitleLabel.text       = @"Purge Data Status";
    self.lastPurgeDataTimeTitleLabel.text     = @"last purge";
        self.nextPurgeDataTimeTitleLabel.text = @"next purge";
    self.lastPurgeDataStatusTitleLabel.text   = [[TagManager sharedInstance]tagByName:kTag_status];
    
    [self.purgeDataNowButton setTitle:@"Purge Data Now" forState:UIControlStateNormal];
    [self updateLastPurgeDataTimeAndStatusUI];
    [self updateNextPurgeDataTimeUI];
}

- (void)updateLastPurgeDataTimeAndStatusUI
{
    NSString *status = [[SMDataPurgeManager sharedInstance] getLastDataPurgeStatus];
    NSString *lastTime = [[SMDataPurgeManager sharedInstance] getLastDataPurgeTime];
    if (status && lastTime) {
        
        self.purgeDataStatusLabel.text   = status;
        self.lastPurgeDataTimeLabel.text = lastTime;
        
    } else {
        //Not even triggered once.
        self.purgeDataStatusLabel.text = @"- - - -";
        self.lastPurgeDataTimeLabel.text = @"- - - -";
    }
}

- (void)updateNextPurgeDataTimeUI
{
    NSString *nextPurgeTime = [[SMDataPurgeManager sharedInstance] getNextDataPurgeTime];
    if (nextPurgeTime) {
        self.nextPurgeDataTimeLabel.text = nextPurgeTime;
        
    } else {
        //Not even triggered once.
        self.nextPurgeDataTimeLabel.text = @"- - - -";
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.smSplitViewController.navigationItem.titleView = [UILabel navBarTitleLabel:[[TagManager sharedInstance]tagByName:kTagPurgeData]];
    [self setupUIElements];
    [self.smPopover dismissPopoverAnimated:YES];
    [self registerNetworkChangeNotification];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadPurgeButton];
    [self registerForServiceMaxDataPurgeProgressNotification];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self deregisterForServiceMaxDataPurgeProgressNotification];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self deregisterNetworkChangeNotification];
}

- (IBAction)purgeDataClicked:(id)sender
{
    if ([[AppManager sharedInstance] hasTokenRevoked])
    {
        [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeAccessTokenExpired
                                                               message:nil
                                                           andDelegate:nil];
    }
    else
    {
        [self displayDataPurgeProgressView];
        [[SMDataPurgeManager sharedInstance] startMannualPurging];
    }

  
}

- (void)displayDataPurgeProgressView
{
    NSString *title    = @"Purge Data Progress";
    NSString *message1 = @"Purge in Progress. Please wait for this action to complete.";
    NSString *message2 = @"Do not press the home button during this action or the purge will be cancelled.";
    
    NSString *titleCancel = [[TagManager sharedInstance]tagByName:kTagCancelButton];
    
    NSArray *messages = [NSArray arrayWithObjects:message1, message2, nil];
    
    SMProgressAlertView *alertView = [[SMProgressAlertView alloc] initWithTitle:title
                                                                       delegate:self
                                                                       messages:messages
                                                                   cancelButton:titleCancel
                                                                    otherButton:nil];
    self.progressAlertView = alertView;
    [self.progressAlertView updateProgressBarWithValue:0.001
                                            andMessage:[[TagManager sharedInstance]tagByName:kTag_ResetingApplicationContents]];

}

-(void)setBgColorForSelectBtn:(id)inSender
{
    UIButton *btn = (UIButton *)inSender;
    btn.backgroundColor = [UIColor colorWithHexString:@"E15001"];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
}

-(void)setDefaultBgForBtn:(id)inBtnSender
{
    UIButton *btn = (UIButton *)inBtnSender;
    CGFloat borderWidth = 1.0f;
    btn.layer.borderColor =[UIColor colorWithHexString:@"#E15001"].CGColor;
    btn.layer.borderWidth = borderWidth;
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn setTitleColor:[UIColor colorWithHexString:@"#E15001"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(setBgColorForSelectBtn:) forControlEvents:UIControlEventTouchDown];
}

- (void)registerForServiceMaxDataPurgeProgressNotification
{
    
    [[NSNotificationCenter defaultCenter] addUniqueObserver:self
                                                   selector:@selector(updateProgessOnMainThread)
                                                       name:kNotificationDataPurgeProgressBar
                                                     object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addUniqueObserver:self
                                                   selector:@selector(removeProgresBarOnMainThread)
                                                       name:kNotificationDataPurgeCompletedOrFailed
                                                     object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addUniqueObserver:self
                                                   selector:@selector(disableProgressBarCancelButton)
                                                       name:kNotificationDataPurgeDisableCancelButton
                                                     object:nil];
    
}
- (void)deregisterForServiceMaxDataPurgeProgressNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationDataPurgeProgressBar
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationDataPurgeCompletedOrFailed
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kNotificationDataPurgeDisableCancelButton
                                                  object:nil];
    
}

- (void)updateProgessOnMainThread
{
    [self performSelectorOnMainThread:@selector(updateDatapurgeProgressBar) withObject:nil waitUntilDone:YES];
}

-(void)removeProgresBarOnMainThread
{
    [self performSelectorOnMainThread:@selector(removeProgresBar) withObject:nil waitUntilDone:YES];
}

- (void)updateDatapurgeProgressBar
{
    NSMutableDictionary * dict = [[SMDataPurgeManager sharedInstance] getProgressBarDetails];
    [self updateProgressBarAndpercentage:dict];
}

- (void)updateProgressBarAndpercentage:(NSMutableDictionary *)dict
{
    if (dict != nil && [dict count] > 0)
    {
        [self.progressAlertView updateProgressBarWithValue:[[dict objectForKey:@"progress"] floatValue]
                                                andMessage:[dict objectForKey:@"subtitle1"]];
    }
}

-(void)removeProgresBar
{
    [self updateLastPurgeDataTimeAndStatusUI];
    [self updateNextPurgeDataTimeUI];
    if (self.progressAlertView)
    {
        self.progressAlertView.alertDelegate = nil;
        [self.progressAlertView removeFromSuperview];
    }
}

-(void)cancelDataPurge
{
    [self disableProgressBarCancelButton];
    [[SMDataPurgeManager sharedInstance] stopDataPurge];
    [self removeProgresBar];
}

-(void)disableProgressBarCancelButton
{
    self.progressAlertView.cancelButton.enabled = NO;
}

- (void)smAlertView:(SMAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self cancelDataPurge];
}

@end