//
//  ProductIQHomeViewController.m
//  ServiceMaxiPad
//
//  Created by Admin on 25/08/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "ProductIQHomeViewController.h"
#import "CustomerOrgInfo.h"
#import "DBManager.h"
#import "FileManager.h"
#import "TagManager.h"

@interface ProductIQHomeViewController ()

@end

@implementation ProductIQHomeViewController


static  ProductIQHomeViewController *instance;

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    DBManager *manager = [DBManager getSharedInstance];
    
//    ProductIQDataLoader *dataLoader = [[ProductIQDataLoader alloc] init];
//    [dataLoader insertDataIntoProductIQTables];
    
    instance = self;
    
    bridge = [[Bridge alloc]init];
//    webview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 20, 1024,748)];
    [self createWebView];
    
    nativeCallUrl = @"native-call://";
    clientId = @"3MVG9VmVOCGHKYBRKMhA_p09I93C_GY2N1wz8gvNtsZnJ0SE4cNbqfNLqBV5vFIT8E.Exhq8e0qBlRE3zezAb";
    callbackUrl = @"SVMX://";
    loginUrl = @"https://test.salesforce.com/services/oauth2/authorize?response_type=token&client_id=%@&redirect_uri=%@&display=touch&login_hint=shivaranjini@qa7.com.cfg2";
    
    /*
    NSString *url = [NSString stringWithFormat:loginUrl, clientId, callbackUrl];
    //NSString *url=@"https://www.google.com";
    
    
     NSURL *nsurl=[NSURL URLWithString:url];
     NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
     [webview loadRequest:nsrequest];
     [self.view addSubview:webview];
     */

    [self populateNavigationBar];
    [self testLoadProductIQ];
    [self debugButtonForProductIQ];
    
}
- (void)createWebView {
    webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webview.delegate = self;
    webview.scalesPageToFit = YES;
    [self.view addSubview:webview];

}


/** Populating navigation bar **/
- (void)populateNavigationBar
{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // Left bar button
    //    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithTitle:self.opdocTitleString style:UIBarButtonItemStylePlain target:self action:@selector(popNavigationController:)];
    //    self.navigationItem.leftBarButtonItem = customBarItem;
    
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

- (void)backView
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}

-(void)debugButtonForProductIQ
{
    
    UILabel *TestLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 180, 35)];
    TestLabel.text = @"TapToDebug";
    TestLabel.font = [UIFont systemFontOfSize:17];
    TestLabel.textColor = [UIColor whiteColor];
    TestLabel.backgroundColor = [UIColor clearColor];
    TestLabel.textAlignment = NSTextAlignmentLeft;
    TestLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    UIView *backView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 300, (30 + TestLabel.frame.size.width), 35)];
    backView1.backgroundColor = [UIColor clearColor];
    [backView1 addSubview:TestLabel];
    backView1.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(testButton)];
    [backView1 addGestureRecognizer:tap1];
    
    UIBarButtonItem *barBtn1 = [[UIBarButtonItem alloc] initWithCustomView:backView1];
    self.navigationItem.rightBarButtonItem = barBtn1;
    
    
}
-(void)testButton
{
    [self testLoadProductIQ];
}

+(ProductIQHomeViewController *)getInstance {
    return instance;
}

-(UIWebView *) getBrowser {
    return webview;
}

-(NSString *) getAccessToken {
    return [[CustomerOrgInfo sharedInstance] accessToken];
//    return accessToken;
}

-(NSString *) getInstanceUrl {
    return [[CustomerOrgInfo sharedInstance] instanceURL];
//    return instanceUrl;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// START - webview events
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *url = request.URL.absoluteString;
    
    // Testing purposes
    NSLog(@"Loading URL :%@",url);
    
    
    // if this is a native call
    BOOL isNativeCall = [url hasPrefix:nativeCallUrl];
    if(isNativeCall){
        [self handleNativeCall:url];
        return NO;
    }
    
    // if user is already athenticated
    if(authenticated) return YES;
    
    BOOL isSuccess = [url hasPrefix:[callbackUrl lowercaseString]];
    
    NSLog(@"Checking for the callback prefix :%d", isSuccess);
    
    if(isSuccess == false){
        return YES;
    }
    
    authenticated = true;
    
    // user was successfully authenticated, load the app.
    [self startApplicationload:url];
    return NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Failed to load with error :%@",[error debugDescription]);
    
}
// END - webview events

- (void)startApplicationload:(NSString *)successUrl {

    NSURL *url = [NSURL fileURLWithPath:[self htmlPath]];

//    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"installigence-index" ofType:@"html" inDirectory:@"www"]];
    
    NSURL *u = [[NSURL alloc]initWithString:successUrl];
    NSString *f = u.fragment;
    NSArray *p = [f componentsSeparatedByString:@"&"];
    NSString *item;
    for (item in p) {
        NSArray *itemData = [item componentsSeparatedByString:@"="];
        if([itemData[0] isEqualToString:@"access_token"]){
            accessToken = itemData[1];
        }else if([itemData[0] isEqualToString:@"instance_url"]){
            instanceUrl = itemData[1];
        }
    }
    
    [webview loadRequest:[NSURLRequest requestWithURL:url]];
}

-(void)testLoadProductIQ
{
    accessToken = [[CustomerOrgInfo sharedInstance] accessToken];
    instanceUrl = [[CustomerOrgInfo sharedInstance] instanceURL];

    NSURL *url = [NSURL fileURLWithPath:[self htmlPath]];
    [webview loadRequest:[NSURLRequest requestWithURL:url]];
}

-(NSString *)htmlPath
{
    NSString *rootDir = [FileManager getRootPath];
    NSString *htmlfilepath = [rootDir stringByAppendingPathComponent:@"installigence-embedded-index.html"];
    return htmlfilepath;
}

- (void)handleNativeCall:(NSString *)url {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [bridge invoke: url];
    });
}

@end
