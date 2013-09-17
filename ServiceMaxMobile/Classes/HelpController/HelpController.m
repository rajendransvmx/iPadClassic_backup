    //
//  HelpController.m
//  iService
//
//  Created by Samman Banerjee on 02/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HelpController.h"
#import "AppDelegate.h"
#import "Utility.h"

//extern void NSLog(NSString *format, ...);

@implementation HelpController

@synthesize helpString;
@synthesize isPortrait;
@synthesize navigationBarImgView;
@synthesize logoImageView;
@synthesize backButton;
@synthesize backGroundImageView;


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInternetConnectionChange:) name:kInternetConnectionChanged object:nil];
    }
    
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    /*ios7_support shravya*/
    if (![Utility notIOS7]) {
        
        CGRect someFrame = self.navigationBarImgView.frame;
        someFrame.origin.y = 20;
        self.navigationBarImgView.frame = someFrame;
        
        someFrame = webView.frame;
        someFrame.origin.y = 53+20;
        someFrame.size.height =  someFrame.size.height  - 20;
        webView.frame = someFrame;
        
        someFrame = self.backButton.frame;
        someFrame.origin.y =   someFrame.origin.y + 20;
        self.backButton.frame = someFrame;
        
        someFrame = self.logoImageView.frame;
        someFrame.origin.y =   someFrame.origin.y + 20;
        self.logoImageView.frame = someFrame;
        
        someFrame = self.backGroundImageView.frame;
        someFrame.origin.y =   someFrame.origin.y + 20;
        self.backGroundImageView.frame = someFrame;
        
        
        self.view.backgroundColor = [UIColor colorWithRed:243.0/255 green:244/255.0 blue:247/255.0 alpha:1];
    }
    
    NSMutableString *mutable_helpFile = [[NSMutableString alloc] init];
    [mutable_helpFile setString:helpString];
    [mutable_helpFile replaceOccurrencesOfString:@".html" 
                                      withString:@"" 
                                         options:NSCaseInsensitiveSearch 
                                           range:NSMakeRange(0, [mutable_helpFile length])];
    
    NSString* helpFilePath = [[NSBundle mainBundle] pathForResource:mutable_helpFile
                                                             ofType:@"html"];
    
    NSString* htmlFile = [NSString stringWithContentsOfFile:helpFilePath
                                                   encoding:NSUTF8StringEncoding
                                                      error:NULL];
    NSString *bundle_path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:bundle_path];
    [webView loadHTMLString:htmlFile baseURL:baseURL];  
    //Code Ends Here
    
    //krishna map fix
    [mutable_helpFile release];
    [super viewDidLoad];
    

    }

- (void) didInternetConnectionChange:(NSNotification *)notification
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber * currentReach = (NSNumber *) notification.object;
    BOOL isReachable = [currentReach boolValue];
    if (isReachable)
    {
        NSLog(@"HelpController Internet Reachable");
    }
    else
    {
        NSLog(@"HelpController Internet Not Reachable");
        [activity stopAnimating];
        //[appDelegate displayNoInternetAvailable];
    }
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [activity startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activity stopAnimating];
}

- (IBAction) Done
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (isPortrait == YES)
    {
        UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
        switch (deviceOrientation)
        {
            case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
                return (interfaceOrientation == UIInterfaceOrientationPortrait);
            case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
                return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
            default:
                break;
        }
        return NO;
    }
    if (isPortrait == NO)
    {
        if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        {
            return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
        }
        else
            if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
            {
                return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
                
            }
            else
                return NO;        
    }
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload
{
    //krishna map fix    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInternetConnectionChanged object:nil];
    
    [webView release];
    webView = nil;
    [activity release];
    activity = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    webView.delegate = nil;
    [activity release];
    [navigationBarImgView release];
    [logoImageView release];
    [backButton release];
    [backGroundImageView release];
    [super dealloc];
}


@end
