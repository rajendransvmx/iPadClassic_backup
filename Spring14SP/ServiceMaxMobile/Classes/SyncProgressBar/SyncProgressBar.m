//
//  SyncProgressBar.m
//  iService
//
//  Created by Radha Sathyamurthy on 07/04/13.
//
//

#import "SyncProgressBar.h"

@implementation SyncProgressBar

@synthesize delegate;
@synthesize currentState;
@synthesize currentPriority;

@synthesize progressIndicator;
@synthesize percentage;

@synthesize syncProgressState;
@synthesize optimizedSyncProgress;
@synthesize eventsyncProgressState;
@synthesize metasyncProgressState;
@synthesize conflictSyncProgressState;
@synthesize customSyncProgressState;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        progressIndicator = [[UIImageView alloc] initWithFrame:frame];
        progressIndicator.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:progressIndicator];
        
        percentage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 21, 21)];
        percentage.backgroundColor = [UIColor clearColor];
        percentage.textColor = [UIColor whiteColor];
        percentage.font = [UIFont boldSystemFontOfSize:12.0f];
        percentage.textAlignment = NSTextAlignmentCenter;
        percentage.center = progressIndicator.center;
        [self addSubview:percentage];
        
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

static SyncProgressBar *singleInstance = NULL;
//  Unused Methods
//+ (SyncProgressBar*)getInstance
//{
//    if(singleInstance == NULL)
//    {
//        singleInstance = [[SyncProgressBar alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
//    }
//    
//    return singleInstance;
//}
//  Unused Methods
//- (BOOL)startWithPriority:(Priority)priority forObject:(id)sender withTextHidden:(BOOL)hideText
//{
//    BOOL didStart = NO;
//    
//    if(sender == nil) return didStart;
//    
//    [progressIndicator stopAnimating];
////    [delegate progressBarDidStopUpdating:self];//  Unused Methods
//    delegate = sender;
//    
//    currentPriority = priority;
//    
//    if(priority == eHigh)
//    {
//        [self setPercentageTextHidden:YES];
//        [progressIndicator setImage:[UIImage imageNamed:@"sync-orange.jpg"]];
//        
//        // set animation image and start animating
//        NSMutableArray *animArray = [NSMutableArray array];
//        for (int i = 1; i <= 26; i++) {
//            [animArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"ani%d.png",i]]];
//        }
//        progressIndicator.animationImages = animArray;
//        [progressIndicator startAnimating];
//        
//    }
//    
//    if(priority == eMedium)
//    {
//        [self setPercentageTextHidden:hideText];
//        [self setProgressBarState:eStart forObject:sender forProgress:0];
//        didStart = YES;
//    }
//    
//    return didStart;
//}

- (void)stopProgressBarAnimation
{
    if(progressIndicator.isAnimating)
    {
        [progressIndicator stopAnimating];
    }
}

//  Unused Methods
//- (void)setProgressBarState:(ProgressBarState)state forObject:(id)sender forProgress:(NSUInteger)percent
//{
//    if(sender != delegate) return;
//    
//    switch (state) {
//        case eStart:
//            currentState = eStart;
//            [self updateProgress:percent forObject:sender];
//            break;
//        case ePause:
//            currentState = ePause;
//            currentPriority = eLow;
//            [self stopProgressBarAnimation];
//            [self.progressIndicator setImage:[UIImage imageNamed:@"sync-orange.jpg"]];
//            break;
//        case eResume:
//            currentState = eResume;
//            [self updateProgress:percent forObject:sender];
//            break;
//        case eStop:
//            currentState = eStop;
//            currentPriority = eLow;
//            [self stopProgressBarAnimation];
//            [self.progressIndicator setImage:[UIImage imageNamed:@"sync-green.jpg"]];
//            break;
//        case eRunning:
//            currentState = eRunning;
//            break;
//        case eCompleted:
//            currentState = eCompleted;
//            currentPriority = eLow;
//            [self stopProgressBarAnimation];
//            [self.progressIndicator setImage:[UIImage imageNamed:@"sync-green.jpg"]];
//            break;
//        case eFailed:
//            currentState = eFailed;
//            currentPriority = eLow;
//            [self stopProgressBarAnimation];
//            [self.progressIndicator setImage:[UIImage imageNamed:@"sync-red.jpg"]];
//            break;
//        default:
//            break;
//    }
//    
//    currentState = state;
//}

//  Unused Methods
//- (ProgressBarState)progressBarState
//{
//    return currentState;
//}

//  Unused Methods
//- (void)setPercentageTextHidden:(BOOL)hidden
//{
//    percentage.hidden = hidden;
//}

//  Unused Methods
//- (BOOL)isPercentageTextHidden
//{
//    return percentage.hidden;
//}

- (void)updateProgress:(NSInteger)percent forObject:(id)sender
{
	self.percentage.text = [NSString stringWithFormat:@"%d",percent];
}

@end
