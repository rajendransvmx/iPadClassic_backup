//
//  VideoPlayerViewController.m
//  iService
//
//  Created by Siva Manne on 28/06/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import "VideoPlayerViewController.h"

@interface VideoPlayerViewController ()

@end

@implementation VideoPlayerViewController
@synthesize closeButtonView;
@synthesize fileName;
@synthesize moviePlayer;

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
    [self loadVideoAtPath:fileName];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) ||
            (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

- (void)dealloc
{
    [fileName release];
    [moviePlayer release];
    [closeButtonView release];
    [super dealloc];
}
#pragma mark -
#pragma mark - Custom Methods
- (void)loadVideoAtPath:(NSString *) videoFileName
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *destinationVideoPath = [documentsDirectory stringByAppendingFormat:@"/videos/%@",videoFileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:destinationVideoPath])
    {
        UIAlertView *SMalert = [[UIAlertView alloc] 
                                initWithTitle:@"File Not Found" 
                                message:@"Selected File not available in Data Base" 
                                delegate:nil 
                                cancelButtonTitle:@"OK" 
                                otherButtonTitles:nil];
        [SMalert show];
        [SMalert release];

        return;
    }
    NSURL *movieURL;
    if (destinationVideoPath) 
    {
        movieURL = [NSURL fileURLWithPath:destinationVideoPath];
        if(moviePlayer)
            [moviePlayer release];
        moviePlayer = [[MPMoviePlayerController alloc]
                       initWithContentURL:movieURL];
    }

    [[self view] addSubview:[moviePlayer view]];

    CGRect frame = CGRectMake(20, 20, 1000, 740);
    [[moviePlayer view] setFrame:frame];
    [moviePlayer play];
}
- (IBAction)dismissModalView:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
