//
//  SMProgressBar.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 20/01/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "SMProgressBar.h"
#import "Utility.h"
#import "LocalizationGlobals.h"

@interface SMProgressBar ()
- (void) initializeProgressLabel;

@end


@implementation SMProgressBar

@synthesize mainTitleBackground;
@synthesize mainTitle;
@synthesize subTitle;
@synthesize progressTitle;
@synthesize progressBar;
@synthesize percentage;
@synthesize cancel;
@synthesize progressBarDelegate;

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
    
    [self initializeProgressLabel];
    // Do any additional setup after loading the view from its nib.
}
- (void) initializeProgressLabel
{
    NSString * title = [Utility getValueForTagFromTagDict:CANCEL_BUTTON];
    
    [cancel setTitle:title forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancel.titleLabel setFont:[UIFont boldSystemFontOfSize:19.0]];
    cancel.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    cancel.userInteractionEnabled = YES;
    
    [self.view bringSubviewToFront:self.mainTitle];
    [self.view bringSubviewToFront:self.progressBar];
    
    self.view.layer.cornerRadius = 5;
    self.view.backgroundColor = [UIColor clearColor];
    self.view.layer.borderColor = [UIColor blackColor].CGColor;
    self.view.layer.borderWidth = 1.0f;
    
    self.mainTitleBackground.layer.cornerRadius = 5;
    self.mainTitle.backgroundColor = [UIColor clearColor];
    self.mainTitle.layer.cornerRadius = 8;
    self.mainTitle.textAlignment = NSTextAlignmentCenter;
    self.mainTitle.numberOfLines = 0;
    self.mainTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    self.mainTitle.text = [Utility getValueForTagFromTagDict:Data_Purge];
    
    self.subTitle.font = [UIFont systemFontOfSize:16.0];
    self.subTitle.textAlignment = NSTextAlignmentCenter;
    self.subTitle.text = [Utility getValueForTagFromTagDict:DP_Progress_Config_WS];
    
    self.progressTitle.numberOfLines = 4;
    self.progressTitle.font = [UIFont systemFontOfSize:14.0];
    self.progressTitle.textAlignment = NSTextAlignmentCenter;
    self.progressTitle.lineBreakMode = NSLineBreakByWordWrapping;
    self.progressTitle.text = [Utility getValueForTagFromTagDict:DP_Progress_Config_Data];
    
    self.progressBar.progress = 0.0;
    
    self.percentage.text = @"0%";

}
- (void) updateProgressBarAndpercentage:(NSMutableDictionary *)dict
{
    
    if (dict != nil && [dict count] > 0)
    {
        self.subTitle.text = [dict objectForKey:@"subtitle"];
        self.progressTitle.text = [dict objectForKey:@"subtitle1"];
        
        self.progressBar.progress = [[dict objectForKey:@"progress"] floatValue];
        
        self.percentage.text = [dict objectForKey:@"percentage"];
    }
    
}

- (IBAction)cancelProgress:(id)sender
{
    if ( (self.progressBarDelegate != nil)
        && ([self.progressBarDelegate conformsToProtocol:@protocol(SMProgressBarDelegate)]))
    {
        [self.progressBarDelegate cancelDataPurge];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [mainTitle release];
    [mainTitleBackground release];
    [subTitle release];
    [progressBar release];
    [progressTitle release];
    [percentage release];
    [cancel release];
    [super dealloc];
}
@end
