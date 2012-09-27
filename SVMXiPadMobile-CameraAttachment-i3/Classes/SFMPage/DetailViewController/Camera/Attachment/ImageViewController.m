//
//  ImageViewController.m
//  Navigation
//
//  Created by Siva Manne on 09/06/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import "ImageViewController.h"
#import "iServiceAppDelegate.h"
@interface ImageViewController ()

@end

@implementation ImageViewController
@synthesize imageView;
@synthesize imageName;
@synthesize displayCloseButton;
@synthesize closeButtonView;

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
    [self.imageView setUserInteractionEnabled:YES];
    //[self.imageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
    iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIImage *image = [[UIImage alloc] initWithData:[appDelegate.dataBase getAttachmentDataForFile:imageName]];
    [self.imageView setImage:image];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.imageView = nil;
    self.imageName = nil;
    self.closeButtonView = nil;
}

- (void)dealloc
{
    [super dealloc];
    [imageView release];
    [imageName release];
    [closeButtonView release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
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
            [closeButtonView setBackgroundColor:[UIColor blackColor]];
            /*[closeButtonView setImage:[UIImage imageNamed:@"SFM-Screen-Done-Back-Button.png"] 
                                                 forState:UIControlStateNormal];*/
            iServiceAppDelegate *appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
            NSString *closeView = [appDelegate.wsInterface.tagsDictionary objectForKey:CAM_Close_ImageView];
            [closeButtonView setTitle:closeView forState:UIControlStateNormal];
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
