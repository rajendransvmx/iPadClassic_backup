//
//  SignUpController.m
//  iService
//
//  Created by Samman Banerjee on 02/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SignUpController.h"


@implementation SignUpController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    int majorVersion = 0;
    NSString * _version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSArray * versionComponents = [_version componentsSeparatedByString:@"."];
    NSString * version = [versionComponents objectAtIndex:0];
    majorVersion = [version intValue];

    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.servicemax.com/ServiceMaxiPadTrialSignup%d.html", majorVersion]]]];

    [activity stopAnimating];
}

- (IBAction) Close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
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

#pragma mark -
#pragma mark UIWebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webViewer
{
    [activity stopAnimating];
}

- (void)webViewDidStartLoad:(UIWebView *)webViewer
{
    [activity startAnimating];
}

- (IBAction) goBack
{
    if (![webView canGoBack])
    {
        // Load the first page
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *bundlePath = [bundle bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:bundlePath];
        
        NSString *htmlfilepath = [bundle pathForResource:@"sign-up copy" ofType:@"html"];
        NSError *error;
        NSString *htmlContent = [NSString stringWithContentsOfFile:htmlfilepath encoding:NSUTF8StringEncoding error:&error];
        
        [webView loadHTMLString:htmlContent baseURL:baseURL];
    }
    else
    {
        [webView goBack];
    }

}

- (IBAction) goForward
{
    
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}


@end
