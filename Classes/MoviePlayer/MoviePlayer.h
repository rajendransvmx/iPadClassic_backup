//
//  MoviePlayer.h
//  iService
//
//  Created by Samman Banerjee on 28/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaPlayer/MPMoviePlayerController.h"

@interface MoviePlayer : UIView
{
    MPMoviePlayerController * movieController;
    NSURL * movieURL;
    CGRect movieFrame;
}

@property (nonatomic, retain) MPMoviePlayerController * movieController;
@property (nonatomic, retain) NSURL * movieURL;

- (void) playMovie;
- (NSURL *) localMovieURL;

- (MPMoviePlayerController *) initMovie;

@end
