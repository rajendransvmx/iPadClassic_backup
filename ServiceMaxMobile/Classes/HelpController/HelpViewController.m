//
//  NewHelpViewController.m
//  ServiceMaxMobile
//
//  Created by Naveen Vasu on 07/05/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import "HelpViewController.h"
#import "AppDelegate.h"
#import "Utility.h"
#import "HomeViewController.h"

@interface HelpViewController()

@end

@implementation HelpViewController

#pragma mark - Life Cycle Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    @autoreleasepool
    {
        if (![Utility notIOS7])
        {
            [self setUIForiOS7];
        }
        
        NSString *htmlFileNameWithoutExtension;
        NSString *language = [appDelegate.dataBase checkUserLanguage];
        
        switch (selectedHelpPage)
        {
            
            case HelpPageNameHome:
                {
                    htmlFileNameWithoutExtension = [self setHelpFileName:@"home" withLanguage:language];
                }
                break;
                
            case HelpPageNameSFMSearch:
                {
                    htmlFileNameWithoutExtension = [self setHelpFileName:@"sfm-search" withLanguage:language];
                }
                break;
            
            case HelpPageNameChatter:
                {
                    htmlFileNameWithoutExtension = [self setHelpFileName:@"chatter" withLanguage:language];
                }
                break;
            
            case HelpPageNameCreateNew:
                {
                    htmlFileNameWithoutExtension = [self setHelpFileName:@"create-new" withLanguage:language];
                }
                break;
            
            case HelpPageNameViewRecord:
                {
                    htmlFileNameWithoutExtension = [self setHelpFileName:@"view-record" withLanguage:language];
                }
                break;
            
            case HelpPageNameCreateEditRecord:
                {
                    htmlFileNameWithoutExtension = [self setHelpFileName:@"create-edit-record" withLanguage:language];
                }
                break;
           
            case HelpPageNameMapView:
                {
                    htmlFileNameWithoutExtension = [self setHelpFileName:@"map-view" withLanguage:language];
                }
                break;
          
            case HelpPageNameSync:
                {
                    htmlFileNameWithoutExtension = [self setHelpFileName:@"sync" withLanguage:language];
                }
                break;
                
            case HelpPageNameDayView:
                {
                    htmlFileNameWithoutExtension = [self setHelpFileName:@"day-view" withLanguage:language];
                }
                break;
                
            case HelpPageNameWeekView:
                {
                    htmlFileNameWithoutExtension = [self setHelpFileName:@"week-view" withLanguage:language];
                }
                break;
                
            case HelpPageNameSummary:
                {
                    htmlFileNameWithoutExtension = [self setHelpFileName:@"summary" withLanguage:language];
                }
                break;
                
            case HelpPageNameServiceReport:
                {
                    htmlFileNameWithoutExtension = [self setHelpFileName:@"service-report" withLanguage:language];
                }
                break;
                
            case HelpPageNameProductManualHelp:
                {
                    htmlFileNameWithoutExtension = [self setHelpFileName:@"Product Manual Help" withLanguage:language];
                }
                break;
                
            case HelpPageNameRecents:
                {
                    htmlFileNameWithoutExtension = [self setHelpFileName:@"recents" withLanguage:language];
                }
                break;
                
            case HelpPageNameTroubleshooting:
                {
                    htmlFileNameWithoutExtension = [self setHelpFileName:@"troubleshooting" withLanguage:language];
                }
                break;
                
            default:
                {
                    htmlFileNameWithoutExtension = @"home";
                }
                break;
        }
        
        NSLog(@"File Name without Extension %@", htmlFileNameWithoutExtension);
        
        NSString *HTMLFilePath = [[NSBundle mainBundle] pathForResource:htmlFileNameWithoutExtension
                                                                ofType:@"html"];
        NSString *HTMLFileContent = [NSString stringWithContentsOfFile:HTMLFilePath
                                                              encoding:NSUTF8StringEncoding error:NULL];
        
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSURL *pathURL = [NSURL fileURLWithPath:bundlePath];
        [helpWebView loadHTMLString:HTMLFileContent baseURL:pathURL];
    }
     
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [helpWebView stopLoading];
    [helpWebView setDelegate:nil];
    helpWebView = nil;
}

- (void)dealloc
{
    [self clearWebviewCacheAndContents];
    [super dealloc];
}

#pragma mark - Web View Delegate Methods
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [webView stopLoading];
}

- (void)webViewDidStartLoad:(UIWebView *)webView;
{
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)reques navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [webView stopLoading];
}

#pragma mark - Memory Management
/**
 * @name  clearWebviewCacheAndContents
 *
 * @author Naveen Vasu
 *
 * @brief Free the memory not to be used after the Help exits
 *
 * @return void
 *
 */
- (void)clearWebviewCacheAndContents
{
    [helpWebView loadHTMLString:@"" baseURL:nil];
    [helpWebView stopLoading];
    [helpWebView setDelegate:nil];
    [helpWebView removeFromSuperview];
    helpWebView = nil;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
}

#pragma mark - Orientation Method
/**
 * @name  supportedInterfaceOrientations
 *
 * @author Naveen Vasu
 *
 * @brief Set the UI for the Landscape orientation even if the device orientation changes
 *
 * @return NSUInteger
 *
 */
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - UI population Methods
/**
 * @name  setUIForiOS7
 *
 * @author Naveen Vasu
 *
 * @brief To set the UI for the iOS 7
 *
 * @return void
 *
 */
- (void)setUIForiOS7
{
    int statusBarHeight = 20;
    
    CGRect someFrame = navigationBarImgView.frame;
    someFrame.origin.y = statusBarHeight;
    navigationBarImgView.frame = someFrame;
    
    someFrame = helpWebView.frame;
    someFrame.origin.y = 53 + statusBarHeight;
    someFrame.size.height = someFrame.size.height - statusBarHeight;
    helpWebView.frame = someFrame;
    
    someFrame = backButton.frame;
    someFrame.origin.y =   someFrame.origin.y + statusBarHeight;
    backButton.frame = someFrame;
    
    someFrame = logoImageView.frame;
    someFrame.origin.y =   someFrame.origin.y + statusBarHeight;
    logoImageView.frame = someFrame;
    
    someFrame = backgroundImageView.frame;
    someFrame.origin.y =   someFrame.origin.y + statusBarHeight;
    someFrame.size.height = someFrame.size.height - statusBarHeight;
    backgroundImageView.frame = someFrame;
    
    self.view.backgroundColor = [UIColor colorWithRed:243.0/255 green:244/255.0 blue:247/255.0 alpha:1];
}

#pragma mark - Setting Help Page to Show
- (void)setHelpPageName:(NSUInteger)helpPageNumber
{
    selectedHelpPage = helpPageNumber;
}

#pragma mark - Loading the Help File for User Language
- (NSString *)setHelpFileName:(NSString *)fileName withLanguage:(NSString*)language
{
    NSString* htmlFileNameWithoutExtension;
    NSString* fileNameWithLanguage = [NSString stringWithFormat:@"%@_%@", fileName, language];
    NSString* isFileExistWithLanguage = [[NSBundle mainBundle] pathForResource:fileNameWithLanguage
                                                                   ofType:@"html"];
    
    if ((isFileExistWithLanguage == NULL) || [language isEqualToString:@"en_US"] || !([language length]>0))
    {
        htmlFileNameWithoutExtension = [NSString stringWithFormat:@"%@", fileName];
    }
    else
    {
        htmlFileNameWithoutExtension = fileNameWithLanguage;
    }
    
    return htmlFileNameWithoutExtension;
}

#pragma mark - Event Driven Methods
- (IBAction)exitHelp
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
