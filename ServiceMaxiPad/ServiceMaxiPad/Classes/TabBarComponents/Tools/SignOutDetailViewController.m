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


@interface SignOutDetailViewController ()

@property(nonatomic) BOOL                       isLogoutInProgress;
@property(nonatomic, strong) SMRegularAlertView *regularAlertView;

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


- (void)loadSignoutButton
{
     if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
     {
         signOutBtn.userInteractionEnabled = YES;
         signOutBtn.layer.borderColor = [UIColor orangeColor].CGColor;
         [signOutBtn setBackgroundColor:[UIColor colorWithHexString:@"#FF6633"]];
         [signOutBtn setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
     }
     else
     {
        signOutBtn.userInteractionEnabled = NO;
        signOutBtn.layer.borderColor =[UIColor colorWithHexString:@"#AEAEAE"].CGColor;
        [signOutBtn setBackgroundColor:[UIColor colorWithHexString:@"#AEAEAE"]];
        [signOutBtn setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
     }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
        //code to be executed on the main queue after delay
        [self loadSignoutButton];
}


- (void)makeActionAccordingToNetworkChangeNotification:(NSNotification *)notification
{
    if ([notification isKindOfClass:[NSNotification class]])
    {
        NSLog(@" notification - %@", [notification description]);
        
        NSNumber *number = (NSNumber *) [notification object];
        
        NSLog(@" notification value - %d", [number intValue]);
    }
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [self loadSignoutButton];
    });
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.smSplitViewController.navigationItem.titleView = [UILabel navBarTitleLabel:@"Sign Out"];
    signOutBtn.layer.borderColor = [UIColor orangeColor].CGColor;
    signOutBtn.layer.borderWidth = 0.8;
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
    SXLogDebug(@" pressed  logout ");
    
    
    if (self.isLogoutInProgress)
    {
        SXLogDebug(@" pressed  logout Go BACK !!!");
        return;
    }
    else
    {
        isLogoutInProgress = YES;
        
        [self performSelectorOnMainThread:@selector(performLoggout) withObject:nil waitUntilDone:NO];
    }
}

- (void)performLoggout
{
    [[SVMXSystemUtility sharedInstance] startNetworkActivity];
    
    @synchronized([self class])
    {
        BOOL isRevoked = YES; //[OAuthService revokeAccessToken];
        
        if (isRevoked)
        {
            //[[CacheManager sharedInstance] clearCache];
            //[OAuthService clearOAuthErrorMessage];
            [self showConfirmLogoutMessage];
        }
        else
        {
            // VIPIN : TODO
        }
    }
    
    isLogoutInProgress = NO;
    
    [[SVMXSystemUtility sharedInstance] stopNetworkActivity];
    
}

//

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
    //btn.frame =CGRectInset(btn.frame, -borderWidth, -borderWidth);
    btn.layer.borderColor =[UIColor colorWithHexString:@"#E15001"].CGColor;
    btn.layer.borderWidth = borderWidth;
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn setTitleColor:[UIColor colorWithHexString:@"#E15001"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(setBgColorForSelectBtn:) forControlEvents:UIControlEventTouchDown];
}


- (void)showConfirmLogoutMessage
{
    NSString *tittle   = @"Signed Out";
    NSString *message1 = @"You have been signed out.";
    NSString *message2 = @"Thanks for using ServiceMax Mobile!";
    
    NSString *titleCancel = nil;
    NSString *otherButtonTittle = @"Sign In";
    
    NSArray *messages = [NSArray arrayWithObjects:message1, message2, nil];
    
    SMRegularAlertView *alertView = [[SMRegularAlertView alloc] initWithTitle:tittle
                                                                            delegate:self
                                                                            messages:messages
                                                                        cancelButton:titleCancel
                                                                         otherButton:otherButtonTittle];
    self.regularAlertView = alertView;
    
    alertView = nil;

}

- (void)smAlertView:(SMAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@" smAlertView Selcted at button Index :%d", buttonIndex);
    [alertView removeFromSuperview];
    self.regularAlertView = nil;
    
    // Selected 'Sign In' Option. Lets proceed it.
    if (buttonIndex != 0)
    {
        [[CacheManager sharedInstance] clearCache];
        [OAuthService clearOAuthErrorMessage];
        [[AppManager sharedInstance] completedLogoutProcess];
    }
    //else meant; Cancelled the Sync option. Nothing to worry here.
}

@end
