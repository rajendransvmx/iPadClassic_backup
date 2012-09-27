//
//  PDFViewController.m
//  Navigation
//
//  Created by Siva Manne on 10/06/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import "PDFViewController.h"

@interface PDFViewController ()

@end

@implementation PDFViewController
@synthesize pdfView;
@synthesize pdfPath;
@synthesize displayCloseButton;
@synthesize closeButtonView;
@synthesize pdfActivityIndicator;

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
    // Do any additional setup after loading the view from its nib.
    [self.pdfView setUserInteractionEnabled:YES];
    //[self.imageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
    NSURL * _url = [NSURL fileURLWithPath:pdfPath];
    NSURLRequest * requestObj = [NSURLRequest requestWithURL:_url];
    [pdfActivityIndicator setHidden:NO];
    [pdfActivityIndicator startAnimating];
    pdfView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,768,1004)];
    [self.pdfView loadRequest:requestObj];
    [self.view addSubview:pdfView];
    [pdfActivityIndicator stopAnimating];
    [pdfActivityIndicator setHidden:YES];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.pdfView = nil;
    self.pdfPath = nil;
    self.closeButtonView = nil;
    self.pdfActivityIndicator  = nil;
}

- (void)dealloc
{
    [super dealloc];
    [pdfView release];
    [pdfPath release];
    [closeButtonView release];
    [pdfActivityIndicator release];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation ==UIDeviceOrientationPortrait ||
            interfaceOrientation ==UIDeviceOrientationPortraitUpsideDown );
}

#pragma mark - Touches Delegate
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    if([[touch view] class] == [UIImageView class])
    {
        if(displayCloseButton)
        {
            displayCloseButton = NO;
            [closeButtonView removeFromSuperview];
        }
        else 
        {
            displayCloseButton = YES;
            closeButtonView = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
            [closeButtonView setTitle:@"Close" forState:UIControlStateNormal];
            //[closeButtonView setImage:[UIImage imageNamed:@"SFM-Screen-Done-Back-Button.png"] 
            //forState:UIControlStateNormal];
            [closeButtonView addTarget:self 
                                action:@selector(dismissModalView) 
                      forControlEvents:UIControlEventTouchUpInside];
            
            [self.view addSubview:closeButtonView];
            
        }
    }
}

- (void) dismissModalView
{
    [closeButtonView removeFromSuperview];
    [self dismissModalViewControllerAnimated:YES];
}

@end
