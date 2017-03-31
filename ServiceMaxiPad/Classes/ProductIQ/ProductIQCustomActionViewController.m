//
//  ProductIQCustomActionViewController.m
//  ServiceMaxiPad
//
//  Created by Rahman Sab C on 01/12/15.
//  Copyright © 2015 ServiceMax Inc. All rights reserved.
//

#import "ProductIQCustomActionViewController.h"
#import "TagManager.h"
#import "MBProgressHUD.h"
#import "SNetworkReachabilityManager.h"
#import "AlertMessageHandler.h"
#import "ProductIQManager.h"

#define kInvalidUrlAlert 10000
#define kNoInternetAlert 10001

@implementation NSURLRequest (NSURLRequestWithIgnoreSSL)

@end


@interface ProductIQCustomActionViewController () {
    
}
@property (strong, nonatomic) UIWebView *webview;
@property (strong, nonatomic) MBProgressHUD *hudView;

@end

@implementation ProductIQCustomActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self populateNavigationBar];
    [self createWebView];
    [self showAnimator];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]) {
        [self loadCustomURL];
    } else {
        [self showAlertView];
    }

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** Populating navigation bar **/
- (void)populateNavigationBar
{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OPDocBackArrow.png"]];
    
    UILabel *backLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 180, arrow.frame.size.height)];
    backLabel.text = [[TagManager sharedInstance]tagByName:kTagtBackButtonTitle];
    backLabel.font = [UIFont systemFontOfSize:17];
    backLabel.textColor = [UIColor whiteColor];
    backLabel.backgroundColor = [UIColor clearColor];
    backLabel.textAlignment = NSTextAlignmentLeft;
    backLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (arrow.frame.size.width + backLabel.frame.size.width), arrow.frame.size.height)];
    backView.backgroundColor = [UIColor clearColor];
    [backView addSubview:arrow];
    [backView addSubview:backLabel];
    backView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backView)];
    [backView addGestureRecognizer:tap];
    
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:backView];
    self.navigationItem.leftBarButtonItem = barBtn;
    
    /*
     // Title
     UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 24)];
     titleLabel.text = @"ProductIQ";
     titleLabel.font = [UIFont boldSystemFontOfSize:21];
     titleLabel.textColor = [UIColor whiteColor];
     titleLabel.backgroundColor = [UIColor clearColor];
     titleLabel.textAlignment = NSTextAlignmentCenter;
     self.navigationItem.titleView = titleLabel;
     */
    
}

- (void)createWebView {
    self.webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webview.scalesPageToFit = YES;
    self.webview.delegate = self;
    [self.view addSubview:self.webview];
    
}

- (void)hideAnimator
{
    if (self.hudView) {
        [self.hudView hide:YES];
        self.hudView = nil;
    }
}

- (void)showAnimator
{
    if (!self.hudView) {
        self.hudView = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.hudView];
        self.hudView.mode = MBProgressHUDModeIndeterminate;
        self.hudView.labelText = [[TagManager sharedInstance]tagByName:kTagLoading];
        [self.hudView show:YES];
    }
}

- (void)loadCustomURL {
    NSURL *url = [NSURL URLWithString:self.urlString];
    
    BOOL isValidUrl = [[ProductIQManager sharedInstance] validateCustomUrl:url];
    if(!isValidUrl){
        
        [self hideAnimator];
        [[AlertMessageHandler sharedInstance] showCustomMessage:@"Invalid URL"//TODO: As we do not have custom-label for Invalid URL,hard codedi the message.
         
                                                   withDelegate:self
                                                            tag:kInvalidUrlAlert
                                                          title:@"Custom Action"
                                              cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
                                           andOtherButtonTitles:nil];
        
    }else{
       [self.webview loadRequest:[NSURLRequest requestWithURL:url]];
    }
    
}

- (void)backView
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void) showAlertView{
    
    [self hideAnimator];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage] message:[[TagManager sharedInstance]tagByName:kTag_InternetConnectionOffline] delegate:self cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles:nil];
    alertView.tag = kNoInternetAlert;
    [alertView show];
}
#pragma mark - Rotation methods

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}


#pragma mark - UIWebViewDelegate Methods
// START - webview events
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideAnimator];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self hideAnimator];
    if ( [error code] != NSURLErrorCancelled ){
        [self showAlertView];
    }
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark- UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kInvalidUrlAlert || alertView.tag == kNoInternetAlert){
        
        if (buttonIndex==0) {
            [self backView];
        }
        
        
    }
}

@end
