//
//  MoviePlayer.m
//  iService
//
//  Created by Samman Banerjee on 28/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MoviePlayer.h"


@implementation MoviePlayer

@synthesize movieController;
@synthesize movieURL;

- (id) init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame]))
    {
        // Initialization code
        movieFrame = frame;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (NSURL *) localMovieURL
{
    // movieURL = [NSURL URLWithString:@"http://www.youtube.com/watch?v=WZfxANvK1Zg"];
    if (movieURL == nil)
    {
        NSBundle *bundle = [NSBundle mainBundle];
        if (bundle) 
        {
            NSString *moviePath = [bundle pathForResource:@"Movie" ofType:@"mp4"];
            if (moviePath)
            {
                movieURL = [NSURL fileURLWithPath:moviePath];
            }
        }
    }
    
    return movieURL;
}

- (MPMoviePlayerController *) initMovie
{
    // NSURL* videoURL = [NSURL URLWithString:url];
    movieController = [[MPMoviePlayerController alloc] initWithContentURL:[self localMovieURL]];
    [movieController prepareToPlay];
    // [movieController play];
    //For viewing partially.....
    [movieController.view setFrame:movieFrame];
    movieController.view.backgroundColor = [UIColor grayColor]; 
    // [self.view addSubview:movieController.view];
    
    return movieController;
}

- (void) playMovie
{
    [movieController play];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    /*     
     < add your code here >
     
     MPMoviePlayerController* moviePlayerObj=[notification object];
     etc.
     */
}

//  Notification called when the movie scaling mode has changed.
- (void) movieScalingModeDidChange:(NSNotification*)notification
{
    /* 
     < add your code here >
     
     MPMoviePlayerController* moviePlayerObj=[notification object];
     etc.
     */
}

- (void)dealloc {
    [super dealloc];
}


@end
