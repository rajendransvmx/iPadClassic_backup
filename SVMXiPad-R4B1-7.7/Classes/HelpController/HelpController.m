    //
//  HelpController.m
//  iService
//
//  Created by Samman Banerjee on 02/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HelpController.h"
#import "iServiceAppDelegate.h"
extern void SVMXLog(NSString *format, ...);
@implementation HelpController

@synthesize helpString;
@synthesize isPortrait;

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
    [super viewDidLoad];
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];

//    NSString * url = [NSString stringWithFormat:@"http://www.ServiceMax.com/Help/iPad"];
//    NSString * url = [NSString stringWithFormat:@"http://www.servicemax.com/Help/iPad/Winter11/en_us/"];
//    NSString * url = [NSString stringWithFormat:@"http://www.servicemax.com/Help/iPad/Summer11/en_us/home.html"];

    NSString * url = [NSString stringWithFormat:@"http://www.servicemax.com/Help/iPad/Summer11/en_us"];

	url = [url stringByAppendingPathComponent:helpString];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [webView loadRequest:urlRequest];
}

- (void) didInternetConnectionChange:(NSNotification *)notification
{
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber * currentReach = (NSNumber *) notification.object;
    BOOL isReachable = [currentReach boolValue];
    if (isReachable)
    {
        NSLog(@"ModalViewController Internet Reachable");
    }
    else
    {
        NSLog(@"ModalViewController Internet Not Reachable");
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
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
    [self dismissModalViewControllerAnimated:YES];
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


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload
{
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
    [super dealloc];
}


@end
