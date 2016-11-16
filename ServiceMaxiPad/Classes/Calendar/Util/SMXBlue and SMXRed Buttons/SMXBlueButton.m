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
#import "SMXCalendarViewController.h"
#import "CalenderHelper.h"
#import "StyleManager.h"
#import "CaseObjectModel.h"

@interface SMXBlueButton ()

@property(nonatomic, strong) CALayer *cTopButtonBorder;
@property(nonatomic, strong) CALayer *cLeftButtonBorder;
@property(nonatomic, strong) CALayer *cBottomButtonBorder;
@end

@implementation SMXBlueButton

#pragma mark - Synthesize

@synthesize event;
@synthesize eventAddress, eventName, borderView;
@synthesize _IsWeekEvent;
@synthesize cuncurrentIndex;
@synthesize firstImageView;
@synthesize secondImageView;
@synthesize thirdImageView;
@synthesize buttonProtocol;
@synthesize cTopBorder;
@synthesize isMultiDayEvent;
@synthesize cTopButtonBorder;
@synthesize cLeftButtonBorder;
@synthesize cBottomButtonBorder;
@synthesize eventIndex;
//====== overlapingEvent======
@synthesize xPosition;
@synthesize wDivision;
@synthesize intOverLapWith;

@synthesize eventSubject; //Single Label For All. TODO:Check if the implementation is correct or else remove.

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //====== overlapingEvent======
        self.xPosition = 1;
        self.wDivision = 1;
        self.intOverLapWith= -1;
        
        // Initialization code
        
        [self setBackgroundColor:[UIColor colorWithRed:228.0/255. green:228.0/255. blue:228.0/255. alpha:1.0]];

        eventName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width - 10,42)];

//        eventAddress = [[UILabel alloc] initWithFrame:CGRectMake(10,eventName.frame.origin.y + eventName.frame.size.height, eventName.frame.size.width,30)];
//        
//        eventAddress.textAlignment=NSTextAlignmentLeft;
        
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
//        [self addSubview:eventAddress];
        [self addSubview:borderView];

//        eventName.textColor = [UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1.0];
        eventName.numberOfLines=0;
//        eventAddress.textColor = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];
//        eventAddress.numberOfLines=2;
        
//        eventName.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size: 16.0];
//        eventAddress.font = [UIFont fontWithName:@"HelveticaNeue-Light" size: 16.0];

        
        // gesture will recognize the selection of a particular event
        UITapGestureRecognizer *lTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openingEvent:)];
        [self addGestureRecognizer:lTapGesture];

//        [eventAddress sizeToFit];
        
        cTopBorder = [CALayer layer];
        cTopBorder.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 1.0f);
        cTopBorder.backgroundColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:cTopBorder];
        
//        CALayer *bottomBorder = [CALayer layer];
//        bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height-1, self.frame.size.width, 1.0f);
//        bottomBorder.backgroundColor = [UIColor whiteColor].CGColor;
//        [self.layer addSublayer:bottomBorder];
    }
    return self;
}


-(void)setThreeSideLayerForSmallerEvent
{
    float borderWidth = 5.0f;
    
    if (!cTopButtonBorder) {
        cTopButtonBorder = [CALayer layer];
        
    }
    cTopButtonBorder.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, borderWidth);
    cTopButtonBorder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:cTopButtonBorder];
    
    if (!cLeftButtonBorder) {
        cLeftButtonBorder = [CALayer layer];
        
    }
    cLeftButtonBorder.frame = CGRectMake(0.0f, 0.0f, borderWidth, self.frame.size.height);
    cLeftButtonBorder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:cLeftButtonBorder];
    
    if (!cBottomButtonBorder) {
        cBottomButtonBorder = [CALayer layer];

    }
    
    cBottomButtonBorder.frame = CGRectMake(0.0f, self.frame.size.height - borderWidth, self.frame.size.width, borderWidth);
    cBottomButtonBorder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:cBottomButtonBorder];
    
    CGRect lFrame = cTopBorder.frame;
    
    lFrame.size.width = self.frame.size.width;
    cTopBorder.frame = lFrame;
    
    lFrame = self.borderView.frame;
    lFrame.origin.x = 5;
    self.borderView.frame = lFrame;
    
    lFrame = self.eventName.frame;
    lFrame.origin.x = borderView.frame.origin.x + borderView.frame.size.width +3;
    lFrame.size.width = self.frame.size.width - 15;
    lFrame.origin.y += 10;
    lFrame.size.height = self.frame.size.height - 15;
    
    self.eventName.frame = lFrame;
    
//    lFrame = self.eventAddress.frame;
//    lFrame.size.width = self.frame.size.width - 10;
//    self.eventAddress.frame = lFrame
    
    self.firstImageView.hidden = YES;
    self.secondImageView.hidden = YES;
    self.thirdImageView.hidden = YES;
    
}

-(void)removeBorderLayersFromButton
{
    [cTopButtonBorder removeFromSuperlayer];
    cTopButtonBorder = nil;
    [cLeftButtonBorder removeFromSuperlayer];
    cLeftButtonBorder = nil;
    [cBottomButtonBorder removeFromSuperlayer];
    cBottomButtonBorder = nil;
    
    CGRect lFrame = self.cTopBorder.frame;
    lFrame.size.width = self.frame.size.width;
    self.cTopBorder.frame = lFrame;
    
    lFrame = self.borderView.frame;
    lFrame.origin.x = 0.;
    lFrame.size.width = 5.0;
    lFrame.size.height = self.frame.size.height;
    self.borderView.frame = lFrame;
    
    lFrame = self.eventName.frame;
    lFrame.origin.x = borderView.frame.origin.x + borderView.frame.size.width +3;
    lFrame.origin.y = 5;
    lFrame.size.width = self.frame.size.width - 10;
    self.eventName.frame = lFrame;
    
//    lFrame = self.eventAddress.frame;
//    lFrame.size.width = self.frame.size.width - 10;
//    self.eventAddress.frame = lFrame;
    
    //borderView.backgroundColor = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];

    self.firstImageView.hidden = YES;
    self.secondImageView.hidden = YES;
    self.thirdImageView.hidden = YES;
    
}

-(BOOL)doesHaveBorder
{
    if (cTopButtonBorder) {
        return YES;
    }
    return NO;
}

/*
 Method Name - openingEvent:
 Argument: gesture
 Description: It will get triggered when a user taps on an event in the left panel for Calender>Day
 */
-(void)openingEvent:(UITapGestureRecognizer *)gesture
{
    if (_IsWeekEvent) {
        /*Here we are removing notification "EVENT_CLICKED_WEEK"*/
        [[SMXCalendarViewController sharedInstance] eventSelectedShare:event userInfor:nil];

    }else{
        //Selected event change

        if (buttonProtocol && [buttonProtocol respondsToSelector:@selector(dayEventSelected:)]) {
            [buttonProtocol dayEventSelected:self];
        }
    }
}

-(void)restContentFrames:(CGFloat )wirdth{
    eventName.frame=CGRectMake(eventName.frame.origin.x,eventName.frame.origin.y,wirdth,eventName.frame.size.height);
    eventAddress.frame=CGRectMake(eventAddress.frame.origin.x,eventAddress.frame.origin.y,wirdth,eventAddress.frame.size.height);
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark BUSINESS HOURS 

-(void)setEventSubjectLabelPosition
{
    NSString *thebusinesshours = [[SMXDateManager sharedManager] businessHours];
    thebusinesshours=[self checkingCorrectTimeFormate:thebusinesshours];
    NSRange startRange = [thebusinesshours rangeOfString:@":"];
    
    long hour = [[thebusinesshours substringToIndex:startRange.location] doubleValue];
    long minutes = [[thebusinesshours substringFromIndex:startRange.location+1] doubleValue];

    float businessHourLocation  = (hour * 60 + minutes ) * 70/60  ; // 1 pixel = 2 min.
    
    float difference = self.frame.origin.y - businessHourLocation;
    
    CGRect frame = self.eventName.frame;

    if (difference>0) {
        //The business hours is before the start of the event.
        
        frame.origin.y = 0;
        
    }
    else
    {
        /*
        //Business hours is after the event's start time
            Two cases:
         1) Business hours is coming after the event has finished.
         2) Business hours is between the event start and end time
         
         */
        

        if ((self.frame.origin.y + self.frame.size.height) < businessHourLocation) {
            
            // First set the EventName Label's height. then place it at the bottom of the button.
            [self.eventName sizeToFit];

            frame.origin.y =  self.frame.origin.y + self.frame.size.height - self.eventName.frame.size.height -5;
            if (frame.origin.y<0) {
                frame.origin.y = 0;
            }

        }
        else
        {
            frame.origin.y =  frame.origin.y - difference;
            frame.size.height = self.frame.size.height - frame.origin.y;
        }
        
    }
    
    frame.origin.y += 5;

    self.eventName.frame = frame;

    
    [self.eventName sizeToFit];
    [self checkIfSubjectIsInsidetheButton];
    
    frame = self.firstImageView.frame;
    frame.origin.y =  self.eventName.frame.origin.y + 5;
    self.firstImageView.frame = frame;
    
    frame = self.secondImageView.frame;
    frame.origin.y =  self.firstImageView.frame.origin.y;
    self.secondImageView.frame = frame;
    
    frame = self.thirdImageView.frame;
    frame.origin.y =  self.firstImageView.frame.origin.y;
    self.thirdImageView.frame = frame;

//    self.backgroundColor = [UIColor clearColor];

}
-(NSString *)checkingCorrectTimeFormate:(NSString *)time{
    if(!time){
        return @"08:00"; //Default. IF nothing is received from the Db, set 8 Am as the business hrs.
    }else{
        NSRange startRange = [time rangeOfString:@":"];
        if (startRange.length==0) {
            //if time formate is creating problem
        }else{
            int hour = [[time substringToIndex:startRange.location] intValue];
            int minutes = [[time substringFromIndex:startRange.location+1] intValue];
            //checking time whether time is proper or not
            if ((hour>=0 && hour<24) && (minutes>=0 && minutes<60)) {
                //this is the correct time formate
                return time;
            }
        }
    }
    return @"08:00"; //Default. if time formate is not proper
}
-(void)checkIfSubjectIsInsidetheButton
{
    
    if ((self.frame.origin.y + self.frame.size.height)< (self.frame.origin.y + self.eventName.frame.origin.y + self.eventName.frame.size.height)) {
        float theovershoot = (self.frame.origin.y + self.eventName.frame.origin.y + self.eventName.frame.size.height) - (self.frame.origin.y + self.frame.size.height);
        
        CGRect frame = self.eventName.frame;
        if (theovershoot <= self.eventName.frame.origin.y) {
            frame.origin.y -= theovershoot;
        }
        else{
            frame.origin.y = 0;
            frame.size.height -= (theovershoot -  self.eventName.frame.origin.y);
        }
        self.eventName.frame = frame;
    }
}

-(void)setTheButtonForNormalState
{
    [self setBackgroundColor:[UIColor colorWithRed:228.0/255. green:228.0/255. blue:228.0/255. alpha:1.0]];
    [self setTheEventTitleForNormalState];
}
-(void)setTheButtonForSelectedState
{
    self.backgroundColor = [UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1.0];
    self.eventName.textColor = [UIColor whiteColor];
}

-(void)setTheButtonForDraggingState
{
    self.eventName.textColor = [UIColor whiteColor];
    [self setBackgroundColor:[UIColor colorWithRed:255.0/255. green:102.0/255. blue:51.0/255. alpha:1.0]];
}

-(void)setTheEventTitleForNormalState
{
    //adding 1 with index, event starting with 0 like normal array
    NSString *dayIndexString = (self.event.isMultidayEvent? [@(self.eventIndex+1) stringValue] : @"");
    NSString *lEventTitle;
    NSString *lLocation;
    NSString *priorityString = nil;

    if (self.event.isWorkOrder) {
        WorkOrderSummaryModel *model = [[SMXCalendarViewController sharedInstance].cWODetailsDict objectForKey:self.event.whatId];
        lLocation = [CalenderHelper getServiceLocation:self.event.whatId];

        lEventTitle = (model.companyName.length ? model.companyName : self.event.subject);
        priorityString = model.priorityString;
        
    } else if (self.event.isCaseEvent){
        
        CaseObjectModel *model = [[SMXCalendarViewController sharedInstance].cCaseDetailsDict objectForKey:self.event.whatId];
        priorityString = model.priorityString;
        lEventTitle = (self.event.subject?self.event.subject:@"");

    }
    else
    {
        lEventTitle = (self.event.subject?self.event.subject:@"");

    }
    if(self.event.isEventTitleSettingDriven)
        lEventTitle = self.event.title;
        

    lEventTitle = [lEventTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (!lEventTitle) {
        lEventTitle = @"";
    }
    if (!lLocation) {
        lLocation = @"";
    }
    
    NSString *text;
    
    if (self.event.isMultidayEvent) {
        dayIndexString = [NSString stringWithFormat:@"day %@",dayIndexString];
        if (!self.event.isEventTitleSettingDriven) {
            
              text = [NSString stringWithFormat:@"%@\n%@\n%@", dayIndexString, lEventTitle, lLocation];
        }
        else
            text = [NSString stringWithFormat:@"%@\n%@", dayIndexString, lEventTitle];

    }
    else
    {
        if (!self.event.isEventTitleSettingDriven) {
            text = [NSString stringWithFormat:@"%@\n%@", lEventTitle, lLocation];
        }
        else
            text = [NSString stringWithFormat:@"%@", lEventTitle];
    }
    
    // If attributed text is supported (iOS6+)
    if ([self.eventName respondsToSelector:@selector(setAttributedText:)]) {
        
        // Define general attributes for the entire text
        NSDictionary *attribs = @{
                                  NSForegroundColorAttributeName: [UIColor blackColor],
                                  NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size: 16.0]
                                  };
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:text
                                               attributes:attribs];
        
        if (self.event.isMultidayEvent) {
            
            
            // Red text attributes
            UIColor *lDayIndexColor = [UIColor whiteColor];
            UIColor *lDayIndexBackgroundColor = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];
            
            NSRange lDayIndexTextRange = [text rangeOfString:dayIndexString];
            [attributedText setAttributes:@{NSForegroundColorAttributeName:lDayIndexColor, NSBackgroundColorAttributeName:lDayIndexBackgroundColor,NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size: 16.0]}
                                    range:lDayIndexTextRange];
        }
        
        if (lEventTitle.length) {
            // Green text attributes
            UIColor *lEventTitleColor = [UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1.0];
            NSRange lEventTitleTextRange = [text rangeOfString:lEventTitle];
            [attributedText setAttributes:@{NSForegroundColorAttributeName:lEventTitleColor}
                                    range:lEventTitleTextRange];
        }
        
        if (lLocation.length && !self.event.isEventTitleSettingDriven)
        {
        
        // Purple and bold text attributes
        UIColor *lLocationColor = [UIColor colorWithRed:121.0/255.0 green:121.0/255.0 blue:121.0/255.0 alpha:1.0];
        UIFont *lLocationFont = [UIFont fontWithName:@"HelveticaNeue-Light" size: 16.0];;
        NSRange lLocationTextRange = [text rangeOfString:lLocation];
        [attributedText setAttributes:@{NSForegroundColorAttributeName:lLocationColor,
                                        NSFontAttributeName:lLocationFont}
                                range:lLocationTextRange];
        }
        
        self.eventName.attributedText = attributedText;
    }
    // If attributed text is NOT supported (iOS5-)
    else {
        self.eventName.text = text;
    }

    [self setFlagColor:priorityString];

}
-(void)setFlagColor:(NSString *)priorityString{
    
    UIColor *borderColor;
    NSString *colorString;
    if ([priorityString isEqualToString:@"High"]) {
        
        colorString = [CalenderHelper getTheHexaCodeForTheSettingId:@"IPAD006_SET001"];
        self.thirdImageView.image = [UIImage imageNamed:@"priority_Flag.png"];
    }
    else     if ([priorityString isEqualToString:@"Medium"]) {
        colorString = [CalenderHelper getTheHexaCodeForTheSettingId:@"IPAD006_SET002"];
        self.thirdImageView.image = nil;
        
    }
    else     if ([priorityString isEqualToString:@"Low"]) {
        colorString = [CalenderHelper getTheHexaCodeForTheSettingId:@"IPAD006_SET003"];
        self.thirdImageView.image = nil;
    }
    else
    {
        colorString = [CalenderHelper getTheHexaCodeForTheSettingId:@"IPAD006_SET004"];
        self.thirdImageView.image = nil;
    }
    borderColor = [UIColor colorFromHexString:colorString];
    
    self.borderView.backgroundColor = borderColor;//[UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1.0];
}

-(void)setSubViewFramw
{
    /* Here reducing width of the Line, equal to event size */
    CGRect rect = cTopBorder.frame;
    rect.size.width = self.frame.size.width;
    cTopBorder.frame = rect;
    
    /* Here reducing width of the label, equal to event size */
    CGRect rectLabel = eventName.frame;
    rectLabel.size.width = self.frame.size.width;
    rectLabel.size.width = self.frame.size.width - eventName.frame.origin.x;
    eventName.frame = rectLabel;
    
    /* For concurrent event, We are not showing the any flag */
    if (wDivision>1)
        self.thirdImageView.hidden = YES;
    else
        self.thirdImageView.hidden = NO;
}
@end
