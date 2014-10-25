//
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


@interface LaunchViewController ()

@property(nonatomic, strong) UIImageView *backgroundImageView;
@property(nonatomic, strong) UIButton *signInButton;

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

- (CGFloat)buttonHeight
{
    return 118.0f;
}

- (CGFloat)buttonWidth
{
    return 400.0f;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    backgroundImageView  = [[UIImageView alloc] initWithFrame:self.view.frame];
    
    backgroundImageView.frame = self.view.bounds;
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    CGSize size;
    size.height = [self buttonHeight];
    size.width  = [self buttonWidth];
    
    CGPoint point;
    
    if(   (self.interfaceOrientation == UIDeviceOrientationLandscapeLeft)
       || (self.interfaceOrientation == UIDeviceOrientationLandscapeRight))
    {
        backgroundImageView.image = [UIImage imageNamed:@"Default-Landscape.png"];
        point.x = (self.view.frame.size.height  / 2.0) - (size.width / 2.0);
        point.y = ((self.view.frame.size.width * 2.0) / 3.0 ) - size.height;
        
    } else  if(   (self.interfaceOrientation == UIDeviceOrientationPortrait)
               || (self.interfaceOrientation == UIDeviceOrientationPortraitUpsideDown))
    {
        backgroundImageView.image = [UIImage imageNamed:@"Default-Portrait.png"];
        point.x = (self.view.frame.size.width  / 2.0) - (size.width / 2.0);
        point.y = ((self.view.frame.size.height * 2.0) / 3.0 ) - size.height;
    }
    
    NSLog(@"Init Width %f - x %f ", self.view.frame.size.width, point.x);
    NSLog(@"Init height %f - y %f ", self.view.frame.size.height, point.y);
    
    
    [self.view  addSubview:backgroundImageView];
    
    CGRect frame = CGRectMake(point.x, point.y, size.width, size.height);
    
    signInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    signInButton.frame = frame;
    
    [signInButton titleLabel].font = [UIFont fontWithName:kHelveticaNeueRegular
                                                     size:kFontSize16];
    
    //signInButton.layer.borderColor = [UIColor orangeColor].CGColor;
   // signInButton.layer.borderWidth = 0.8;
    
    [signInButton addTarget:self action:@selector(signInButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    //[signInButton setTitle:@"Sign In" forState:UIControlStateNormal];
    //[signInButton setTitle:@"Sign In" forState:UIControlStateSelected];
    [signInButton setImage:[UIImage imageNamed:@"splashsigninbutton.png"] forState:UIControlStateNormal];
    [signInButton setImage:[UIImage imageNamed:@"splashsigninbutton.png"] forState:UIControlStateSelected];

    //[signInButton setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    //[signInButton setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateSelected];
    
    //[signInButton setBackgroundColor:[UIColor colorWithHexString:@"#FF6633"]];
    
    [self.view  addSubview:signInButton];
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGSize size;
    size.height = [self buttonHeight];
    size.width  = [self buttonWidth];
    
    CGPoint point;
    
    if(   (self.interfaceOrientation == UIDeviceOrientationLandscapeLeft)
       || (self.interfaceOrientation == UIDeviceOrientationLandscapeRight))
    {
        backgroundImageView.image = [UIImage imageNamed:@"Default-Portrait.png"];
        
        point.x = (self.view.frame.size.width  / 2.0) - (size.width / 2.0);
        point.y = ((self.view.frame.size.height * 2.0) / 3.0 ) - size.height;
        
        
    } else  if(   (self.interfaceOrientation == UIDeviceOrientationPortrait)
               || (self.interfaceOrientation == UIDeviceOrientationPortraitUpsideDown))
    {
        backgroundImageView.image = [UIImage imageNamed:@"Default-Landscape.png"];
        
        point.x = (self.view.frame.size.height  / 2.0) - (size.width / 2.0);
        point.y = ((self.view.frame.size.width * 2.0) / 3.0 ) - size.height;
    }
    
    CGRect frame = CGRectMake(point.x, point.y, size.width, size.height);
    signInButton.frame = frame;
    NSLog(@"Width %f - x %f ", self.view.frame.size.width, point.x);
    NSLog(@"height %f - y %f ", self.view.frame.size.height, point.y);
    
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
        //signInButton.userInteractionEnabled = YES;
        signInButton.enabled = YES;
        //signInButton.layer.borderColor = [UIColor orangeColor].CGColor;
        //[signInButton setBackgroundColor:[UIColor colorWithHexString:@"#FF6633"]];
        //[signInButton setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    }
    else
    {
        //signInButton.userInteractionEnabled = NO;
        signInButton.enabled = NO;
        //signInButton.layer.borderColor =[UIColor colorWithHexString:@"#AEAEAE"].CGColor;
        //[signInButton setBackgroundColor:[UIColor colorWithHexString:@"#AEAEAE"]];
        //[signInButton setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    }
}


- (void)viewDidAppear:(BOOL)animated
{
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
    [self deregisterNetworkChangeNotification];
}

- (void)changeSignInButtonVisibilityAccordingToNetworkChangeNotification:(NSNotification *)notification
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
        [self reloadSignInButton];
    });
}


@end
