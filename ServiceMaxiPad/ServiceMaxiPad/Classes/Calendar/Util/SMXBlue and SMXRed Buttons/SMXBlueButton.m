//
//  BlueButton.m
/**
 *  @file   FILE_NAME.m
 *  @class  CLASS_NAME
 *
 *  @brief  This class will provide .....
 *
 *
 *
 *  @author  AUTHOR_NAME
 *
 *  @bug     No known bugs
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "SMXBlueButton.h"

@implementation SMXBlueButton

#pragma mark - Synthesize

@synthesize event;
@synthesize eventAddress, eventName, borderView;
@synthesize _IsWeekEvent;
@synthesize cuncurrentIndex;
@synthesize firstImageView;
@synthesize secondImageView;
@synthesize thirdImageView;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        eventName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width - 10,42)];
        eventAddress = [[UILabel alloc] initWithFrame:CGRectMake(10,eventName.frame.origin.y + eventName.frame.size.height, eventName.frame.size.width,30)];
        
        eventAddress.textAlignment=NSTextAlignmentLeft;
        borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, frame.size.height)];
        borderView.backgroundColor = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];

        UIImage *lImage = [UIImage imageNamed:@"sync_Error.png"];
 
        thirdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - lImage.size.width/2 - 5, 10, lImage.size.width/2, lImage.size.height/2)];
        
        secondImageView = [[UIImageView alloc] initWithFrame:CGRectMake(thirdImageView.frame.origin.x - thirdImageView.frame.size.width - 5, 10, thirdImageView.frame.size.width, thirdImageView.frame.size.height)];
        
        firstImageView = [[UIImageView alloc] initWithFrame:CGRectMake(secondImageView.frame.origin.x - secondImageView.frame.size.width - 5, 10, secondImageView.frame.size.width, secondImageView.frame.size.height)];

        [self addSubview:thirdImageView];
        [self addSubview:secondImageView];
        [self addSubview:firstImageView];
        [self addSubview:eventName];
        [self addSubview:eventAddress];
        [self addSubview:borderView];



        eventName.textColor = [UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1.0];
        eventName.numberOfLines=2;
        eventAddress.textColor = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];
        eventAddress.numberOfLines=2;
        
        eventName.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size: 16.0];
        eventAddress.font = [UIFont fontWithName:@"HelveticaNeue-Light" size: 16.0];

        [self setBackgroundColor:[UIColor colorWithRed:228.0/255. green:228.0/255. blue:228.0/255. alpha:1.0]];
        
        // gesture will recognize the selection of a particular event
        UITapGestureRecognizer *lTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openingEvent:)];
        [self addGestureRecognizer:lTapGesture];

//        [eventAddress sizeToFit];
        

    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{

}



/*
 Method Name - openingEvent:
 Argument: gesture
 Description: It will get triggered when a user taps on an event in the left panel for Calender>Day
 */
-(void)openingEvent:(UITapGestureRecognizer *)gesture
{
    if (_IsWeekEvent) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CLICKED_WEEK object:event];  // gets defined in SMXCalendarViewController class
    }else{
        //Selected event change
        self.backgroundColor = [UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1.0];
        borderView.backgroundColor=[UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1.0];
        self.eventName.textColor = [UIColor whiteColor];
        self.eventAddress.textColor = [UIColor whiteColor];
        //[[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CLICKED object:self];  // gets defined in SMXDayCell class
//        [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CLICKED object:event];  // gets defined in SMXDayCell class//HS 20 Oct ========> Commented on 24 Oct -BSP

        [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CLICKED object:self];  // gets defined in SMXDayCell class// need  self to returned 24 Oct -BSP

    }
}

#pragma mark AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_CLICKED object:self];  // gets defined in SMXDayCell class

}
-(void)restContentFrames:(CGFloat )wirdth{
    eventName.frame=CGRectMake(eventName.frame.origin.x,eventName.frame.origin.y,wirdth,eventName.frame.size.height);
    eventAddress.frame=CGRectMake(eventAddress.frame.origin.x,eventAddress.frame.origin.y,wirdth,eventAddress.frame.size.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
