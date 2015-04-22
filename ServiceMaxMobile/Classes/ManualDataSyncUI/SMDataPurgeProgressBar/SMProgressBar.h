//
//  SMProgressBar.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 20/01/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SMProgressBarDelegate;

@interface SMProgressBar : UIViewController
{
    
}
@property (retain, nonatomic) IBOutlet UIProgressView *progressBar;
@property (retain, nonatomic) IBOutlet UILabel *percentage;

@property (retain, nonatomic) IBOutlet UIView *mainTitleBackground;
@property (retain, nonatomic) IBOutlet UILabel *mainTitle;

@property (retain, nonatomic) IBOutlet UILabel *subTitle;
@property (retain, nonatomic) IBOutlet UILabel *progressTitle;

@property (retain, nonatomic) IBOutlet UIButton *cancel;

@property (nonatomic, assign) id <SMProgressBarDelegate> progressBarDelegate;


- (void) updateProgressBarAndpercentage:(NSMutableDictionary *)dict;
- (IBAction)cancelProgress:(id)sender;

@end

@protocol SMProgressBarDelegate <NSObject>

- (void) cancelDataPurge;

@end