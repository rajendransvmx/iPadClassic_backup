//n
//  LaunchViewController.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 21/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "LaunchViewController.h"
#import "SNetworkReachabilityManager.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "AppManager.h"
#import "NonTagConstant.h"

@interface LaunchViewController ()

@property(nonatomic, strong) IBOutlet UIImageView *backgroundImageView;
@property(nonatomic, strong) IBOutlet UIButton *signInButton;

@end


@implementation LaunchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

@synthesize signInButton;
@synthesize backgroundImageView;


- (void)signInButtonClicked
{
    AppManager *appManager = [AppManager sharedInstance];
    [appManager setApplicationStatus:ApplicationStatusInAuthenticationPage];
    [appManager loadScreen];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // IPAD-4541 - Verifaya
    [signInButton setAccessibilityLabel:kVSignInBtn];
    
    [signInButton addTarget:self action:@selector(signInButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    if(UIDeviceOrientationIsPortrait(self.interfaceOrientation))
    {
        backgroundImageView.image = [UIImage imageNamed:@"LaunchImagePortrait"];
        [signInButton setImage:[UIImage imageNamed:@"Sigin-Portrait"] forState:UIControlStateNormal];
    } else
    {
        backgroundImageView.image = [UIImage imageNamed:@"LaunchImageLandscape"];
        [signInButton setImage:[UIImage imageNamed:@"SignIn-LandScape"] forState:UIControlStateNormal];

    }

}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    if(UIDeviceOrientationIsPortrait(toInterfaceOrientation))
    {
        backgroundImageView.image = [UIImage imageNamed:@"LaunchImagePortrait"];
        [signInButton setImage:[UIImage imageNamed:@"Sigin-Portrait"] forState:UIControlStateNormal];

    } else
    {
        backgroundImageView.image = [UIImage imageNamed:@"LaunchImageLandscape"];
        [signInButton setImage:[UIImage imageNamed:@"SignIn-LandScape"] forState:UIControlStateNormal];

    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                                             selector:@selector(changeSignInButtonVisibilityAccordingToNetworkChangeNotification:)
                                                 name:kNetworkConnectionChanged
                                               object:nil];
    
}

/**
 * @name   deregisterNetworkChangeNotification
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


- (void)reloadSignInButton
{
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
    {
        signInButton.enabled = YES;
    }
    else
    {
        signInButton.enabled = NO;
    }
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self registerNetworkChangeNotification];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [self reloadSignInButton];
    });
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self deregisterNetworkChangeNotification];
}

- (void)changeSignInButtonVisibilityAccordingToNetworkChangeNotification:(NSNotification *)notification
{
    if ([notification isKindOfClass:[NSNotification class]])
    {
        //NSNumber *number = (NSNumber *) [notification object];
    }
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [self reloadSignInButton];
    });
}


@end
