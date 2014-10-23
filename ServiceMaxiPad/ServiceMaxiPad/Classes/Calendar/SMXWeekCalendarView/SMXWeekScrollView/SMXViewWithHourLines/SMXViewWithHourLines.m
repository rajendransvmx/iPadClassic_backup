//
//  SMXViewWithHourLines.m
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

#import "SMXViewWithHourLines.h"

#import "SMXHourAndMinLabel.h"
#import "SMXImportantFilesForCalendar.h"
#import "StyleManager.h"

@interface SMXViewWithHourLines ()
@property (nonatomic, strong) NSMutableArray *arrayLabelsHourAndMin;
@property (nonatomic) CGFloat yCurrent;
@end

@implementation SMXViewWithHourLines

#pragma mark - Synthesize

@synthesize arrayLabelsHourAndMin;
@synthesize yCurrent;
@synthesize totalHeight;
@synthesize labelWithSameYOfCurrentHour;
static UIImage *lineImage;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    lineImage=[UIImage imageNamed:@"dotted_line"];
    if (self) {
        // Initialization code
        
        [self setAutoresizingMask:AR_WIDTH_HEIGHT];
        
        CGFloat y = -25;
        
        NSDateComponents *compNow = [NSDate componentsOfCurrentDate];
        
        for (int hour=0; hour<=23; hour++) {
            
            for (int min=0; min<=45; min=min+MINUTES_PER_LABEL) {
                
                SMXHourAndMinLabel *labelHourMin = [[SMXHourAndMinLabel alloc] initWithFrame:CGRectMake(0, y, self.frame.size.width-0, HEIGHT_CELL_MIN) date:[NSDate dateWithHour:hour min:min]];
                labelHourMin.topInset=-5.0f;
                labelHourMin.leftInset=18.0f;
                labelHourMin.font=[UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0f];;
                [labelHourMin setTextColor:[UIColor colorWithHexString:@"434343"]];
                if (min == 0) {
                    [labelHourMin showText];
                    CGFloat width = [labelHourMin widthThatWouldFit];
                    
                    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(labelHourMin.frame.origin.x+50, 25., self.frame.size.width-labelHourMin.frame.origin.x-width, 1.)];
                    [view.layer setBorderWidth:5.0];
                    [view.layer setBorderColor:[[UIColor colorWithPatternImage:lineImage] CGColor]];
                    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                    [labelHourMin setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                    [labelHourMin addSubview:view];
                }
                [self addSubview:labelHourMin];
                [arrayLabelsHourAndMin addObject:labelHourMin];
                
                NSDateComponents *compLabel = [NSDate componentsWithHour:hour min:min];
                if (compLabel.hour == compNow.hour && min <= compNow.minute && compNow.minute < min+MINUTES_PER_LABEL) {
                    yCurrent = y;
                    [labelHourMin setAlpha:0];
                    labelWithSameYOfCurrentHour = labelHourMin;
                }
                //[labelHourMin setAttributedText:[self getString:labelHourMin.text]];
                y += HEIGHT_CELL_MIN;
            }
        }
        
        totalHeight = y;
    }
    return self;
}

//- (UILabel *)labelWithCurrentHourWithWidth:(CGFloat)_width {
//    
//    SMXHourAndMinLabel *label = [[SMXHourAndMinLabel alloc] initWithFrame:CGRectMake(10, yCurrent, _width-10, HEIGHT_CELL_MIN) date:[NSDate date]];
//    NSDateComponents *comp =  [NSDate componentsOfDate:[NSDate date]];
//    int lHour = comp.hour;
//    NSString *lAmPm = @"AM";
//    if (lHour>=12) {
//        lAmPm = @"PM";
//    }
//    lHour = (lHour>12? lHour - 12 : lHour); //converting to 0-12 hrs standard
//    [label setText:[NSString stringWithFormat:@"%02d:%02d %@", lHour, comp.minute, lAmPm]];
//    [label setTextColor:[UIColor colorWithHexString:@"e15001"]];
//    CGFloat width = [label widthThatWouldFit];
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(label.frame.origin.x+width, HEIGHT_CELL_MIN/2., _width-label.frame.origin.x-width, 1.)];
//    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//    [view setBackgroundColor:[UIColor orangeColor]];
//    [label addSubview:view];
//
//    return label;
//}
- (UILabel *)labelWithCurrentHourWithWidth:(CGFloat)_width {
    
    SMXHourAndMinLabel *label = [[SMXHourAndMinLabel alloc] initWithFrame:CGRectMake(10, yCurrent, _width-10, HEIGHT_CELL_MIN) date:[NSDate date]];
    NSDateComponents *comp =  [NSDate componentsOfDate:[NSDate date]];
    int lHour = comp.hour;
    NSString *lAmPm = @"AM";
    if (lHour>=12) {
        lAmPm = @"PM";
    }
    lHour = (lHour>12? lHour - 12 : lHour); //converting to 0-12 hrs standard
    [label setText:[NSString stringWithFormat:@"%02d:%02d %@", lHour, comp.minute, lAmPm]];
    [label setTextColor:[UIColor colorWithHexString:@"e15001"]];
    label.font = [UIFont fontWithName:kHelveticaNeueRegular size:11.0];
    CGFloat width = [label widthThatWouldFit];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(label.frame.origin.x+width, HEIGHT_CELL_MIN/2., _width-label.frame.origin.x-width, 1.)];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [view setBackgroundColor:[UIColor orangeColor]];
    [label addSubview:view];
    
    return label;
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
