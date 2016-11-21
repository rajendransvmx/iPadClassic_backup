//
//  SLAClockViewController.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 06/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SLAClockViewController.h"
#import "SLATimerView.h"
#import "StyleManager.h"
#import "StyleGuideConstants.h"
#import "TagManager.h"
#import "SFMPageViewModel.h"

@interface SLAClockViewController ()

@property(nonatomic, strong)SLATimerView *resolutionTimer;
@property(nonatomic, strong)SLATimerView *restorationTimer;

@end

@implementation SLAClockViewController

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
    
    CGFloat borderWidth = 1.0f;    
    slaView.layer.borderColor = [UIColor getUIColorFromHexValue:kSeperatorLineColor].CGColor;
    slaView.layer.borderWidth = borderWidth;
    slaView.layer.cornerRadius = 5.00;
    
    // Do any additional setup after loading the view from its nib.
    [self addResolutionAndResolutionTimerView];
    [self initializeLabels];
    [self updateSlAClockData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshData];
}

- (void)refreshData
{
    [self invalidateAllTimer];
    
    [self updateResolutionTimer];
    [self updateRetorationTimer];
    
    if ([self.slaClock shouldStartResolutionTimer]) {
        [self.resolutionTimer startTimer];
    }
    
    if ([self.slaClock shouldStartResotorationTimer]) {
        [self.restorationTimer startTimer];
    }
}

- (void)invalidateAllTimer
{
    [self.resolutionTimer invalidateTimer];
    [self.restorationTimer invalidateTimer];
}

- (void)addResolutionAndResolutionTimerView
{
    CGRect frame;
    frame.size.width = 339;
    frame.origin.y = 22;
    frame.size.height = 58;
    
    if (self.resolutionTimer == nil) {
        self.resolutionTimer = [[[NSBundle mainBundle] loadNibNamed:@"SLATimerView" owner:self options:nil]objectAtIndex:0];
        frame.origin.x = 10;
        self.resolutionTimer.frame = frame;
        self.resolutionTimer.autoresizingMask = UIViewAutoresizingNone;
        self.restorationTimer.backgroundColor = [UIColor clearColor];
        [slaView addSubview:self.resolutionTimer];
    }
    
    if (self.restorationTimer == nil) {
        self.restorationTimer = [[[NSBundle mainBundle] loadNibNamed:@"SLATimerView" owner:self options:nil]objectAtIndex:0];
        frame.origin.x = 350;
        self.restorationTimer.frame = frame;
        self.restorationTimer.autoresizingMask = UIViewAutoresizingNone;
        self.restorationTimer.backgroundColor = [UIColor clearColor];
        [slaView addSubview:self.restorationTimer];
    }

}

- (void)initializeLabels
{
    slaLabel.text = [[TagManager sharedInstance]tagByName:kTagSLAClocks];
    
    [self.resolutionTimer.timeLabel setText:[[TagManager sharedInstance]tagByName:kTag_ResolutionAt]];
    [self.restorationTimer.timeLabel setText:[[TagManager sharedInstance]tagByName:kTag_RestorationAt]];
}

- (void)updateSlAClockData
{    
    [self.resolutionTimer updateSLATimeValue:[self.slaClock getResolutionTime]
                                  timeFormat:[self.slaClock getResolutionTimeFormat]];
    [self.restorationTimer updateSLATimeValue:[self.slaClock getRestorationTime]
                                   timeFormat:[self.slaClock getRestorationTimeFormat]];
    
}

- (void)updateResolutionTimer
{
    NSDateComponents *components = [self.slaClock getResolutionTimerValue];
    [self updateTimer:self.resolutionTimer component:components];
}

- (void)updateRetorationTimer
{
    NSDateComponents *components = [self.slaClock getRestorationTimerValue];
    [self updateTimer:self.restorationTimer component:components];
}


- (void)updateTimer:(SLATimerView *)timerView component:(NSDateComponents *)components
{
    timerView.days = [components day];
    timerView.hours = [components hour];
    timerView.minutes = [components minute];
    timerView.second = [components second];
    
    [timerView updateTimerLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    if ([self.slaClock shouldStartResolutionTimer]) {
        [self.resolutionTimer invalidateTimer];
    }

    if ([self.slaClock shouldStartResotorationTimer]) {
        [self.restorationTimer invalidateTimer];
    }
}

- (CGFloat) contentViewHeight
{
    return 110;//CGRectGetHeight(self.view.bounds);
}


- (void)resetViewPage:(SFMPageViewModel*)sfmViewPageModel
{
    if (self.slaClock) {
        self.slaClock = nil;
    }
    self.slaClock = sfmViewPageModel.slaClock;
    [self updateSlAClockData];
    [self refreshData];
}

@end
