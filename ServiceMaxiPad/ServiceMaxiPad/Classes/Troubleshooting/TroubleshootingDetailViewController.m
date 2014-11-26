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

@interface TroubleshootingDetailViewController()
{
     UILabel *titleLabel;
}

@property(nonatomic, strong) MBProgressHUD *HUD;
@property(nonatomic, strong) NSString * folderNameToCreate;
@property(nonatomic, strong) NSString *docId;
@property(nonatomic, strong) NSString *docName;
@property(nonatomic, strong) SMSplitPopover *masterPopoverController;
@property(nonatomic, strong) ZipArchive * zip;

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
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(200 , 02, 300, 25)];
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
        [self.view addSubview:titleLabel];
        self.docId = docId;
        self.docName = docName;
        [self addActivityAndLoadingLabel];
        if([Reachability connectivityStatus])
        {
            [TroubleshootingDataLoader makingRequestForBodyByDocID:docId andCallerDelegate:self];
        }
        else
        {
            [self getBodyFromApplicationAndLoadWebView];
            
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
    
    [self unzipAndViewFile:[folderPath stringByAppendingString:@".zip"]];
    
    NSString * actualFilePath = [documentsDirectoryPath stringByAppendingPathComponent:self.docName];
    actualFilePath = [actualFilePath stringByAppendingPathComponent:@"index.html"];
    
    
     NSURL * baseURL = [NSURL fileURLWithPath:[documentsDirectoryPath stringByAppendingPathComponent:self.docName]];
    NSError * error;
    
    NSString * fileContents = [NSString stringWithContentsOfFile:actualFilePath encoding:NSUTF8StringEncoding error:&error];
    
    if(error == nil)
    {
        if (fileContents == nil)
        {
            NSString * filePath = [documentsDirectoryPath stringByAppendingPathComponent:
                                   [NSString stringWithFormat:@"%@%@", self.docId, @".zip"]];
            [self unzipAndViewFile:filePath];
            fileContents = [NSString stringWithContentsOfFile:actualFilePath encoding:NSUTF8StringEncoding error:&error];
        }
        if( fileContents != nil)
        {
            [self.webView loadHTMLString:fileContents baseURL:baseURL];
        }
        else
        {
            
        }
    }
    else
    {
        [self.webView loadHTMLString:fileContents baseURL:baseURL];
        [self removeActivityAndLoadingLabel];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Data Corrupted" message:@"The file has  not been uploaded properly" delegate:nil cancelButtonTitle:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk] otherButtonTitles:nil, nil];
        [alertView show];
        
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
