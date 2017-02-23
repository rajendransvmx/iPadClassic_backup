//
//  TroubleShootDetailViewController.m
//  ServiceMaxMobile
//
//  Created by Chinnababu on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "TroubleshootingDetailViewController.h"
#import "ZipArchive.h"
#import "FileManager.h"
#import "FlowNode.h"
#import "SyncConstants.h"
#import "WebserviceResponseStatus.h"
#import "MBProgressHUD.h"
#import "AlertMessageHandler.h"
#import "TroubleshootingDataLoader.h"
#import "Reachability.h"
#import "StyleGuideConstants.h"
#import "TagManager.h"
#import "SNetworkReachabilityManager.h"
#import "AlertViewHandler.h"


@interface TroubleshootingDetailViewController()
{
    UILabel *titleLabel;
}

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) NSString * folderNameToCreate;
@property (nonatomic, strong) NSString *docId;
@property (nonatomic, strong) NSString *docName;
@property (nonatomic, strong) SMSplitPopover *masterPopoverController;
@property (nonatomic, strong) ZipArchive * zip;

@end

@implementation TroubleshootingDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    titleLabel = [UILabel new];
    self.view.backgroundColor = [UIColor whiteColor];
    _webView.backgroundColor = [UIColor whiteColor];
    
}

- (void)loadWebViewForThedocId:(NSString *)docId
                 andThedocName:(NSString *)docName;
{
    if((([docId length]) > 0) &&(([docName length])> 0))
    {
        [titleLabel setText:docName];
        titleLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:20.0f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        CGRect frame = self.view.bounds;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        frame.size.height = 25;
        frame.origin.x += 10;
        frame.size.width -= 20;
        titleLabel.frame = frame;
        [self.view addSubview:titleLabel];
        self.docId = docId;
        self.docName = docName;
        [self addActivityAndLoadingLabel];
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
                [TroubleshootingDataLoader makingRequestForBodyByDocID:docId andCallerDelegate:self];
                
            }
        }
        else
        {
            [self getBodyFromApplicationAndLoadWebView];
            [self removeActivityAndLoadingLabel];
            
            
        }
    }
    else
    {
        [self.webView loadHTMLString:@"" baseURL:nil];
        
    }
}

- (void)getBodyFromApplicationAndLoadWebView
{
    NSString * documentsDirectoryPath = [FileManager getTroubleshootingSubDirectoryPath];
    
    NSString * folderPath = [documentsDirectoryPath stringByAppendingPathComponent:self.docId];
    self.folderNameToCreate = self.docId;
    
    [self unzipAndViewFile:[folderPath stringByAppendingString:@".zip"]];
    
    BOOL folderExists = [[NSFileManager defaultManager] fileExistsAtPath:[folderPath stringByAppendingString:@".zip"]];
    
    if(folderExists)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[folderPath stringByAppendingString:@".zip"] error:nil];
    }
    
    
    NSString * actualFilePath = [documentsDirectoryPath stringByAppendingPathComponent:self.docId];
    
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:folderPath];
    NSError *error = nil;
    
    if(isFileExist)
    {
        actualFilePath = [actualFilePath stringByAppendingPathComponent:self.docName];
        actualFilePath = [actualFilePath stringByAppendingPathComponent:@"index.html"];
        
        NSURL * baseURL = [NSURL fileURLWithPath:actualFilePath];
        NSString * fileContents = [NSString stringWithContentsOfFile:actualFilePath encoding:NSUTF8StringEncoding error:&error];

        if(fileContents!= nil)
        {
            [self.webView loadHTMLString:@"" baseURL:nil];
            [self.webView loadHTMLString:[NSString stringWithContentsOfFile:actualFilePath encoding:NSUTF8StringEncoding error:&error] baseURL:baseURL];
        }
        else
        {
            [self removeActivityAndLoadingLabel];
            AlertViewHandler *alert = [[AlertViewHandler alloc] init];
            [alert showAlertViewWithTitle:[[TagManager sharedInstance]tagByName:kTagAlertTitleError] Message:@"File format is incorrect"  Delegate:self cancelButton:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk ] andOtherButton:nil];
            
        } 
    }
    else
    {
        [self.webView loadHTMLString:@"" baseURL:nil];
        AlertViewHandler *alert = [[AlertViewHandler alloc] init];
        [alert showAlertViewWithTitle:[[TagManager sharedInstance]tagByName:kTagAlertTitleError] Message:@"File format is incorrect"  Delegate:self cancelButton:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk ] andOtherButton:nil];
    }
    
    
}

- (BOOL) unzipAndViewFile:(NSString *)_file
{
    if (self.zip == nil)
        self.zip = [[ZipArchive alloc] init];
    
    BOOL retVal = [self.zip UnzipOpenFile:_file];
    
    if (!retVal){
        return NO;
    }
    // Directory Path to unzip file to...
    NSString * docDir = [FileManager getTroubleshootingSubDirectoryPath];
    // Create "dataName" directory in Documents
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error = nil;
    [fm createDirectoryAtPath:[docDir stringByAppendingPathComponent:self.folderNameToCreate]
  withIntermediateDirectories:YES
                   attributes:(NSDictionary *)nil
                        error:(NSError **)&error];
    
    NSString * unzipPath = [docDir stringByAppendingPathComponent:self.folderNameToCreate];
    
    retVal = [self.zip UnzipFileTo:unzipPath overWrite:YES];
    
    if (!retVal)
    {
        return NO;
    }
    
    return YES;
}

- (void)splitViewController:(SMSplitViewController *)splitViewController didHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem popover:(SMSplitPopover *)popover
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -Flow node delegate method

- (void)flowStatus:(id)status
{
    if([status isKindOfClass:[WebserviceResponseStatus class]])
    {
        WebserviceResponseStatus *st = (WebserviceResponseStatus*)status;
        switch (st.category)
        {
            case CategoryTypeTroubleShootingDataDownload:
            {
                if  (st.syncStatus == SyncStatusSuccess)
                {
                    [self getBodyFromApplicationAndLoadWebView];
                }
                
                else if (st.syncStatus == SyncStatusFailed)
                {
                    [self removeActivityAndLoadingLabel];
                    [[AlertMessageHandler sharedInstance] showCustomMessage:[st.syncError errorEndUserMessage] withDelegate:nil title:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage] cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] andOtherButtonTitles:nil];
                    
                }
                break;
            }
                
            default:
                break;
        }
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

- (void)setContentWithItem:(id)item
{
    [self.masterViewButton setTitle:[NSString stringWithFormat:@"  %@",[item description]] forState:UIControlStateNormal];
    [titleLabel setText:[NSString stringWithFormat:@"  %@",[item description]]];
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)dealloc {
    _webView = nil;
    //[super dealloc];
}

#pragma mark -webview methods

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self removeActivityAndLoadingLabel];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self removeActivityAndLoadingLabel];
}
@end
