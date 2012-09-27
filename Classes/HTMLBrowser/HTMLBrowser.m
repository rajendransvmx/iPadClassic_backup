    //
//  SignUpController.m
//  iService
//
//  Created by Samman Banerjee on 02/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HTMLBrowser.h"


@implementation HTMLBrowser

@synthesize url;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (id) initWithURLString:(NSString *)_url
{
    if ((self = [super init]))
    {
        url = _url;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
    NSBundle *bundle = [NSBundle mainBundle];
	NSString *htmlfilepath = [bundle pathForResource:@"sign-up copy" ofType:@"html"];    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlfilepath]]];
    */
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    
    [activity stopAnimating];
}

- (IBAction) Close
{
    [self dismissModalViewControllerAnimated:YES];
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
    [webView goBack];
}

- (IBAction) goForward
{
    [webView goForward];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [webView release];
    webView = nil;
    [activity release];
    activity = nil;
    [back release];
    back = nil;
    [forward release];
    forward = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [webView stopLoading];
    [webView release];
    [activity release];
    [back release];
    [forward release];
    [url release];
    
    [super dealloc];
}


@end
