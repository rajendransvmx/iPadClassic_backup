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
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_DAY_CALENDAR object:[[SMXDateManager sharedManager] currentDate]];
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
    
    arrayEvents = _array;
    arrayButtons = [NSMutableArray new];
    
    if ([arrayEvents count] > 0) {
        
        int maxNumOfButtons = 5;
        CGFloat yFirstButton = imageViewCircle.frame.origin.y+imageViewCircle.frame.size.height;
        CGFloat height = (self.frame.size.height-yFirstButton)/maxNumOfButtons;
        
        int buttonOfNumber = 0;
        for (int i = 0; i < [arrayEvents count] ; i++) {
            
            buttonOfNumber++;
            SMXButtonWithEditAndDetailPopoversForMonthCell *button = [[SMXButtonWithEditAndDetailPopoversForMonthCell alloc] initWithFrame:CGRectMake(3, yFirstButton+(buttonOfNumber-1)*height, self.frame.size.width-3, height)];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [button setAutoresizingMask:AR_TOP_BOTTOM | UIViewAutoresizingFlexibleWidth];
            button.userInteractionEnabled=NO;//its disable for now
            [self addSubview:button];
            [arrayButtons addObject:button];
            
            if ((buttonOfNumber == maxNumOfButtons) && ([arrayEvents count] - maxNumOfButtons > 0)) {
                [button setTitle:[NSString stringWithFormat:@"  (and %i more)", (int)[arrayEvents count] - maxNumOfButtons + 1] forState:UIControlStateNormal];
                [button.titleLabel setTextColor:[UIColor colorWithHexString:@"797979"]];
                [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
                break;
            } else {
                SMXEvent *event = [arrayEvents objectAtIndex:i];
                NSString *eventSubject = (event.cWorkOrderSummaryModel ? (event.cWorkOrderSummaryModel.companyName.length ? [self stringCustomerNameNullChecking:event.cWorkOrderSummaryModel.companyName] : [self stringCustomerNameNullChecking:event.stringCustomerName]) :[self stringCustomerNameNullChecking:event.stringCustomerName]);
                eventSubject = [eventSubject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                [button setTitle:[NSString stringWithFormat:@"• %@",eventSubject] forState:UIControlStateNormal];
                [button.titleLabel setTextColor:[UIColor colorWithHexString:@"434343"]];
                [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
                [button setEvent:event];
                [button setProtocol:self];
            }
        }
    }
}
-(NSString *)stringCustomerNameNullChecking:(NSString *)string{
    return string==nil?@"--":string;
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
@end
