//
//  ProductIQCustomActionViewController.m
//  ServiceMaxiPad
//
//  Created by Rahman Sab C on 01/12/15.
//  Copyright © 2015 ServiceMax Inc. All rights reserved.
//

#import "ProductIQCustomActionViewController.h"
#import "TagManager.h"

@interface ProductIQCustomActionViewController () {
    
}
@property (strong, nonatomic) UIWebView *webview;

@end

@implementation ProductIQCustomActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self populateNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self createWebView];
    [self loadCustomURL];

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
    [self.view addSubview:self.webview];
    
}

- (void)loadCustomURL {
    
}

- (void)backView
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
