//
//  SMXMonthCell.m
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

#import "SMXMonthCell.h"

#import "SMXButtonWithEditAndDetailPopoversForMonthCell.h"
#import "SMXImportantFilesForCalendar.h"
#import "StyleManager.h"
#import "SMXCalendarViewController.h"
#import "StyleManager.h"
#import "SMXMonthCellEvent.h"

@interface SMXMonthCell () <SMXButtonWithEditAndDetailPopoversForMonthCellProtocol>
@property (nonatomic, strong) NSMutableArray *arrayButtons;
@end

@implementation SMXMonthCell

#pragma mark - Synthesize

@synthesize protocol;
@synthesize arrayButtons;
@synthesize arrayEvents;
@synthesize labelDay;
@synthesize imageViewCircle;
@synthesize cellButton;
@synthesize cellDate;
@synthesize isFirstDayOfTheMonth;
static NSMutableDictionary *eventPlace;
#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setButton:frame];
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

- (void)initLayout {
    
    if (!imageViewCircle) {
        imageViewCircle = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-36,3., 30., 25.)];
        [imageViewCircle setAutoresizingMask:AR_LEFT_BOTTOM];
        [self addSubview:imageViewCircle];
        
        labelDay = [[UILabel alloc] initWithFrame:CGRectMake((imageViewCircle.frame.size.width-30.)/2., (imageViewCircle.frame.size.height-25.)/2., 30., 25.)];
        [labelDay setAutoresizingMask:AR_LEFT_BOTTOM];
        [labelDay setTextAlignment:NSTextAlignmentRight];
        [imageViewCircle addSubview:labelDay];
    }
    cellButton.userInteractionEnabled=NO;
    cellButton.frame=CGRectZero;
    [self setBackgroundColor:[UIColor whiteColor]];
    [self.labelDay setText:@""];
    [self.labelDay setTextColor:[UIColor blackColor]];
    [self.imageViewCircle setImage:nil];
    
    for (UIButton *button in arrayButtons) {
        [button removeFromSuperview];
    }
}
-(void)setButton:(CGRect )frame{
    cellButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width,frame.size.height)];
    [cellButton addTarget:self action:@selector(showDayEvent:) forControlEvents:UIControlEventTouchUpInside];
    cellButton.userInteractionEnabled=NO;
    [self addSubview:cellButton];
}

-(void)enableJumpToday:(CGRect )frame{
    cellButton.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
    cellButton.userInteractionEnabled=YES;
}
-(void)showDayEvent:(id)sender{
    [[SMXDateManager sharedManager] setCurrentDate:cellDate];
    [[SMXCalendarViewController sharedInstance] showDayCalender];
    //[[NSNotificationCenter defaultCenter] postNotificationName:SHOW_DAY_CALENDAR object:[[SMXDateManager sharedManager] currentDate]];
}
#pragma mark - Custom Layouts

- (void)markAsWeekend {
    
    [self setBackgroundColor:[UIColor lighterGrayCustom]];
    [self.labelDay setTextColor:[UIColor grayColor]];
}

- (void)markAsCurrentDay {
    
    [self.labelDay setTextColor:[UIColor smxOrangeColor]];
}

#pragma mark - Showing Events

- (void)setArrayEvents:(NSMutableArray *)_array {
    //multiday event
    NSSortDescriptor *eventStartDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateTimeBegin_multi"
                                                                                   ascending:YES];
    arrayEvents = (NSMutableArray *)[_array sortedArrayUsingDescriptors:[NSArray arrayWithObjects:eventStartDateSortDescriptor, nil]];
    /*Here we are shorting with startDate Of the event*/
    eventStartDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"isMultidayEvent" ascending:NO];
    arrayEvents = (NSMutableArray *)[arrayEvents sortedArrayUsingDescriptors:[NSArray arrayWithObjects:eventStartDateSortDescriptor, nil]];
    
    //NSLog(@"arrayEvents count: %lu withDate: %@",(unsigned long)[arrayEvents count],cellDate);
    //mutiday event
    //arrayEvents = _array;
   // NSLog(@"number of event %lu on %@",(unsigned long)arrayEvents.count,cellDate);
    arrayButtons = [NSMutableArray new];
    
    if ([arrayEvents count] > 0) {
        
        int maxNumOfButtons = numberOfButton;
        CGFloat yFirstButton = 26;//imageViewCircle.frame.origin.y+imageViewCircle.frame.size.height;
        CGFloat height = ((self.frame.size.height-yFirstButton)/maxNumOfButtons)-ButtonPadding;
        
        int buttonOfNumber = 0;
        //int numberOfDrawButton=0;
        for (int i = 0; i < [arrayEvents count] ; i++) {
            SMXButtonWithEditAndDetailPopoversForMonthCell *button = [[SMXButtonWithEditAndDetailPopoversForMonthCell alloc] initWithFrame:CGRectMake(0, yFirstButton+(buttonOfNumber)*height+(buttonOfNumber)*ButtonPadding, self.frame.size.width, height)];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [button setAutoresizingMask:AR_TOP_BOTTOM | UIViewAutoresizingFlexibleWidth];
            button.userInteractionEnabled=NO;//its disable for now
            [self addSubview:button];
            [arrayButtons addObject:button];
            
            if ((((buttonOfNumber+1) >= maxNumOfButtons) && ([arrayEvents count] -i) >1)) {
                [button setTitle:[NSString stringWithFormat:@"  (and %i more)", (int)[arrayEvents count] - (i)] forState:UIControlStateNormal];
                [button.titleLabel setTextColor:[UIColor colorWithHexString:@"797979"]];
                [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
                break;
            } else {
                SMXEvent *event = [arrayEvents objectAtIndex:i];
                NSString *eventSubject = nil;
                if (event.isWorkOrder) {
                    WorkOrderSummaryModel *model = [[SMXCalendarViewController sharedInstance].cWODetailsDict objectForKey:event.whatId];
                    eventSubject = (model.companyName.length ? model.companyName : (event.subject?event.subject:@""));
                }
                else{
                    eventSubject = (event.subject?event.subject:@"");
                }
                /*Here we are checking if EventSubject is giving null then we have to show @"no subject"*/
                eventSubject = [eventSubject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if (eventSubject==nil || eventSubject.length==0) {
                    eventSubject=@"no subject";
                }
                [button setTitle:[NSString stringWithFormat:@" • %@",eventSubject] forState:UIControlStateNormal];
                [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
                [button setEvent:event];
                [button setProtocol:self];
                [button setTitleColor:[UIColor colorWithHexString:@"434343"] forState:UIControlStateNormal];
                if (event.isMultidayEvent) {
                    int eventPoint=[SMXMonthCellEvent getValueForKey:event.localID];
                    if (event.eventIndex!=0) {
                        if (!isFirstDayOfTheMonth)
                            [button setTitle:[NSString stringWithFormat:@"  "] forState:UIControlStateNormal];
                    }
                    if ((eventPoint==numberOfButton) && ([arrayEvents count]-i)>1) {
                        [button setTitle:[NSString stringWithFormat:@"  (and %i more)", (int)[arrayEvents count] - (i)] forState:UIControlStateNormal];
                        [button setTitleColor:[UIColor colorWithHexString:@"797979"] forState:UIControlStateNormal];
                        [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
                        CGRect rect=button.frame;
                        rect.origin.y =yFirstButton+(eventPoint-1)*height+(eventPoint-1)*ButtonPadding;
                         button.frame=rect;
                        [SMXMonthCellEvent removeInfoForKey:event.localID];
                        break;
                    }else if (eventPoint>0) {
                        CGRect rect=button.frame;
                        rect.origin.y =yFirstButton+(eventPoint-1)*height+(eventPoint-1)*ButtonPadding;
                        buttonOfNumber=eventPoint-1;
                        if (event.eventIndex+1==(event.numberOfDays)) {
                            [SMXMonthCellEvent removeInfoForKey:event.localID];
                            rect.size.width=rect.size.width-2.;
                        }
                        button.frame=rect;
                    }else{
                        
                        /*Before rendring multiday button, i am checking if this is the last event with last position or not. If this is not last event of the day and rendring in last position, then count will come no need to render event*/
                        //24 march 2015
                        if(([arrayEvents count]-i)>1 && buttonOfNumber+1>=numberOfButton){
                            [button setTitle:[NSString stringWithFormat:@"  (and %i more)", (int)[arrayEvents count] - (i)] forState:UIControlStateNormal];
                            [button setTitleColor:[UIColor colorWithHexString:@"797979"] forState:UIControlStateNormal];
                            [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
                            break;
                        }else{
                            [SMXMonthCellEvent setEventPlace:event.localID value:[NSString stringWithFormat:@"%d",(buttonOfNumber+1)]];
                            [button setTitle:[NSString stringWithFormat:@" • %@ ",eventSubject] forState:UIControlStateNormal];
                            CGRect rect=button.frame;
                            if (event.eventIndex+1==(event.numberOfDays)) {
                                [SMXMonthCellEvent removeInfoForKey:event.localID];
                                rect.size.width=rect.size.width-2.;
                            }
                            button.frame=rect;
                        }
                    }
                    button.backgroundColor=[UIColor colorWithHexString:@"D7D7D7"];
                }else{
                    /*  non multiday events */
                }
            }
            buttonOfNumber++;
        }
    }
}
-(NSString *)stringCustomerNameNullChecking:(NSString *)string{
    return string==nil?@"no subject":string;
}
#pragma mark - SMXButtonWithEditAndDetailPopoversForMonthCell Protocol

- (void)saveEditedEvent:(SMXEvent *)eventNew ofButton:(UIButton *)button {
    
    int i = (int)[arrayButtons indexOfObject:button];
    
    if (protocol != nil && [protocol respondsToSelector:@selector(saveEditedEvent:ofCell:atIndex:)]) {
        [protocol saveEditedEvent:eventNew ofCell:self atIndex:i];
    }
}

- (void)deleteEventOfButton:(UIButton *)button {
    
    int i = (int)[arrayButtons indexOfObject:button];
    
    if (protocol != nil && [protocol respondsToSelector:@selector(deleteEventOfCell:atIndex:)]) {
        [protocol deleteEventOfCell:self atIndex:i];
    }
}
-(void)setFont:(UIFont *)font{
    labelDay.font=font;//[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
}
-(void)firstDayOfTheMonth{
    imageViewCircle.frame=CGRectMake(self.frame.size.width-136,1., 130., 25.);
    labelDay.frame=CGRectMake((imageViewCircle.frame.size.width-130.)/2., (imageViewCircle.frame.size.height-25.)/2., 130., 25.);
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
