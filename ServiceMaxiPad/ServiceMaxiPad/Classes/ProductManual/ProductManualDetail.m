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

@interface ProductManualDetail ()
{
    UILabel *titleLabel;
}
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) SMSplitPopover *masterPopoverController;

@end

@implementation ProductManualDetail

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.webView.delegate = self;
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(200 , 02, 300, 25)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadWebViewForTheProductName:(NSString *)productName
{
    NSString *title = [productName substringToIndex:[productName length] - 4];
    
    [titleLabel setText:title];
    titleLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:20.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:titleLabel];
    self.productName = productName;
    [self addActivityAndLoadingLabel];
  
    NSString *fileName = productName;
    NSString *documentsDirectoryPath = [FileManager getProductManualSubDirectoryPath];
    NSString *folderPath = [documentsDirectoryPath stringByAppendingPathComponent:fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if(![fm fileExistsAtPath:folderPath])
    {
         if ([Reachability connectivityStatus])
         {
            [ProductManualDataLoader makingRequestForProductManualBodyWithTheDelegate:self];
             
         }
        else
        {
            
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
    NSString * documentsDirectoryPath = [FileManager getProductManualSubDirectoryPath];
    NSString * folderPath = [documentsDirectoryPath stringByAppendingPathComponent:fileName];
    NSURL *url = [NSURL fileURLWithPath:folderPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
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
