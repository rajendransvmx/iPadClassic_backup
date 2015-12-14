//
//  ProductManualDetail.m
//  ServiceMaxiPad
//
//  Created by Chinnababu on 06/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ProductManualDetail.h"
#import "FileManager.h"
#import "TagManager.h"
#import "MBProgressHUD.h"
#import "TaskGenerator.h"
#import "TaskModel.h"
#import "TaskManager.h"
#import "WebserviceResponseStatus.h"
#import "AlertMessageHandler.h"
#import "StyleGuideConstants.h"
#import "ProductManualDataLoader.h"
#import "Reachability.h"
#import "SNetworkReachabilityManager.h"
#import "AlertViewHandler.h"

@interface ProductManualDetail ()
{
    UILabel *titleLabel;
}
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, copy) NSString *productManualID;
@property (nonatomic, strong) SMSplitPopover *masterPopoverController;

@end

@implementation ProductManualDetail

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    titleLabel = [UILabel new];

    self.webView.delegate = self;
    self.webView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadWebViewForTheProductName:(NSString *)productName
                  AndProductManualID:(NSString *)ProductManualId
{
    NSString *title = [[productName lastPathComponent] stringByDeletingPathExtension];
    
    [titleLabel setText:title];
    titleLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:20.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    CGRect frame = self.view.bounds;
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    frame.size.height = 25;
    frame.origin.x += 10;
    frame.size.width -= 20;
    titleLabel.frame = frame;
    [self.view addSubview:titleLabel];
    self.productName = productName;
    self.productManualID = ProductManualId;
    [self addActivityAndLoadingLabel];
    
    NSString *fileName = [self.productManualID stringByAppendingString:@".pdf"];
    NSString *documentsDirectoryPath = [FileManager getProductManualSubDirectoryPath];
    NSString *folderPath = [documentsDirectoryPath stringByAppendingPathComponent:fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:folderPath])
    {
        if ([[[productName lastPathComponent] pathExtension] isEqualToString:@"pdf" ]) {
            
            if ( [[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
            {
                if ([[AppManager sharedInstance] hasTokenRevoked])
                {
                    
                    [[AlertMessageHandler sharedInstance] showAlertMessageWithType:AlertMessageTypeAccessTokenExpired
                                                                           message:nil
                                                                       andDelegate:nil];
                    
                    [self removeActivityAndLoadingLabel];
                }
                else
                {
                    [ProductManualDataLoader makingRequestForProductManualBodyWithTheDelegate:self
                                                                           andProductManualId:(NSString *)ProductManualId];
                }
                
            }
            else
            {
                [self removeActivityAndLoadingLabel];
//                UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:title message:@"The Product Manual not found " delegate:self cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles:nil, nil];
//                
//                [alertview show];
                
                
                AlertViewHandler *alert = [[AlertViewHandler alloc] init];
                [alert showAlertViewWithTitle:title Message:@"The Product Manual not found "
                                     Delegate:self
                                 cancelButton:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk ]
                               andOtherButton:nil];
            }
        }
        else {
            
            self.webView.hidden = YES;
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[self.productName lastPathComponent] stringByDeletingPathExtension]
//                                                                message:@"Product Manual file format is not supported"
//                                                               delegate:self
//                                                      cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
//                                                      otherButtonTitles:nil, nil];
//            
//            [alertView show];
            
            
            AlertViewHandler *alert = [[AlertViewHandler alloc] init];
            [alert showAlertViewWithTitle:[[self.productName lastPathComponent] stringByDeletingPathExtension]
                                  Message:@"Product Manual file format is not supported"
                                 Delegate:self
                             cancelButton:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk ]
                           andOtherButton:nil];

            [self removeActivityAndLoadingLabel];
        }
    }
    else
    {
        [self loadWebView];
    }
}

- (void)loadWebView
{
    NSString *fileName = self.productName;
    NSString *fileNameTODisplay = [fileName stringByDeletingPathExtension];
    NSString *fileType  = [[fileName lastPathComponent] pathExtension ];
    if([fileType isEqualToString:@"pdf" ])
    {
        self.webView.hidden = NO;
        NSString * documentsDirectoryPath = [FileManager getProductManualSubDirectoryPath];
        NSString * folderPath = [documentsDirectoryPath stringByAppendingPathComponent:[self.productManualID stringByAppendingString:@".pdf"]];
        NSURL *url = [NSURL fileURLWithPath:folderPath];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
        
    }
    else
    {
        self.webView.hidden = YES;
       //[self.webView stringByEvaluatingJavaScriptFromString:@"document.open();document.close()"];
      [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:fileNameTODisplay message:@"Product Manual file format is not supported" delegate:self cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles:nil, nil];
//        [alertView show];
        
        AlertViewHandler *alert = [[AlertViewHandler alloc] init];
        [alert showAlertViewWithTitle:fileNameTODisplay
                              Message:@"Product Manual file format is not supported"
                             Delegate:self
                         cancelButton:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk ]
                       andOtherButton:nil];

        [self removeActivityAndLoadingLabel];
    }
  }

- (void)addActivityAndLoadingLabel
{
    if (!self.HUD) {
        self.HUD = [[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.HUD];
        self.HUD.mode = MBProgressHUDModeIndeterminate;
        self.HUD.labelText = [[TagManager sharedInstance]tagByName:kTagLoading];
        [self.HUD show:YES];
       
    }
}

- (void)removeActivityAndLoadingLabel;
{
    if (self.HUD) {
        [self.HUD hide:YES];
        self.HUD = nil;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self removeActivityAndLoadingLabel];
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0){
        
    }
    else{
        [self performSelector:@selector(clearBackground) withObject:nil afterDelay:0.1];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self removeActivityAndLoadingLabel];
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0){
        
    }
    else{
        [self performSelector:@selector(clearBackground) withObject:nil afterDelay:0.1];
    }
}

- (void)flowStatus:(id)status
{
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *st = (WebserviceResponseStatus*)status;
        switch (st.category)
        {
                case CategoryTypeProductManualDownlaod:
                {
                    if(st.syncStatus == SyncStatusSuccess)
                    {
                        [self loadWebView];
                    }
                    else if(st.syncStatus == SyncStatusFailed)
                    {
                        [self removeActivityAndLoadingLabel];
                        [[AlertMessageHandler sharedInstance] showCustomMessage:[st.syncError errorEndUserMessage] withDelegate:nil title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage] cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] andOtherButtonTitles:nil];
                    }
                }
                break;
            default:
                break;
        }
    }
}

- (void)splitViewController:(SMSplitViewController *)splitViewController
      didHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
                    popover:(SMSplitPopover *)popover
{
    self.masterViewButton.hidden = NO;
    titleLabel.hidden = YES;
    
    [self.masterViewButton addTarget:barButtonItem.target action:barButtonItem.action forControlEvents:UIControlEventTouchUpInside];
    
    self.masterPopoverController = popover;
}

- (void)splitViewController:(SMSplitViewController *)splitViewController didShowViewController:(UIViewController *)aViewController barButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.masterViewButton.hidden = YES;
    titleLabel.hidden = NO;
    self.masterPopoverController = nil;
}

- (void)setContentWithItem:(id)item
{
    [self.masterViewButton setTitle:[NSString stringWithFormat:@"  %@",[item description]] forState:UIControlStateNormal];
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)clearBackground {
    UIView *view = self.webView;
    while (view) {
       view = [view.subviews firstObject];
        
        if ([NSStringFromClass([view  class]) isEqualToString:@"UIWebPDFView"]) {
            [view setBackgroundColor:[UIColor whiteColor]];
                      [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.webView .alpha = 1.0;
                             }
                             completion:nil];
            return;
        }
    }
}

@end
