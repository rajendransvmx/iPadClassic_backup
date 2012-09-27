//
//  VideoPlayerViewController.h
//  iService
//
//  Created by Siva Manne on 28/06/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
@interface VideoPlayerViewController : UIViewController
@property (nonatomic, retain)           UIButton    *closeButtonView;
@property (nonatomic, retain)           NSString    *fileName;
@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;
- (IBAction)dismissModalView:(id)sender;
- (void)loadVideoAtPath:(NSString *) videoFileName;
@end
