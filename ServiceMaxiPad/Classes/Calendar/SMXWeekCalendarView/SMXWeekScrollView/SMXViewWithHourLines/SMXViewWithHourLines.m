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
#import "Utility.h"
#import "CalendarPopupContent.h"

@interface SMXViewWithHourLines ()
@property (nonatomic, strong) NSMutableArray *arrayLabelsHourAndMin;
@property (nonatomic) CGFloat yCurrent;
@property (nonatomic) SMXHourAndMinLabel *label;
@property (nonatomic) UIView *view;

@end

@implementation SMXViewWithHourLines

#pragma mark - Synthesize

@synthesize arrayLabelsHourAndMin;
@synthesize yCurrent;
@synthesize totalHeight;
@synthesize labelWithSameYOfCurrentHour;
@synthesize label;
@synthesize view;
@synthesize currentTimeLayer;
static UIImage *lineImage;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    //lineImage=[UIImage imageNamed:@"dotted_line"];
    if (self) {
        // Initialization code
        if ([Utility isDeviceIOS8]) {
            
        }else{
//             [self setAutoresizingMask:AR_WIDTH_HEIGHT]; commented this on 25/nov/2014 BSP. The issue of re-setting the contentsize started appearing in ios7 once day/week/month started to get initalized only after the segementcontrol is pressed.
        }
        CGFloat y = -25;
        
        NSDateComponents *compNow = [NSDate componentsOfCurrentDate];
        
        for (int hour=0; hour<=23; hour++) {
            
            for (int min=0; min<=45; min=min+MINUTES_PER_LABEL) {
                
                SMXHourAndMinLabel *labelHourMin = [[SMXHourAndMinLabel alloc] initWithFrame:CGRectMake(0, y, self.frame.size.width-0, HEIGHT_CELL_MIN) date:[NSDate dateWithHour:hour min:min]];
                labelHourMin.topInset=-5.0f;
                labelHourMin.leftInset=18.0f;
                labelHourMin.font=[UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0f];
                [labelHourMin setTextColor:[UIColor colorFromHexString:@"434343"]];
                if (min == 0) {
                    [labelHourMin showText];
                    CGFloat width = [labelHourMin widthThatWouldFit];
                    
                    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(labelHourMin.frame.origin.x+50, 25., self.frame.size.width-labelHourMin.frame.origin.x-width+20, 1.)];
                    view1.backgroundColor=[UIColor colorFromHexString:@"D7D7D7"];
                    [view1 setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                    [labelHourMin setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
                    [labelHourMin addSubview:view1];
                }
                [self addSubview:labelHourMin];
                [arrayLabelsHourAndMin addObject:labelHourMin];
                {
                    NSDateComponents *compLabel = [NSDate componentsWithHour:hour min:min];
                    if (compLabel.hour == compNow.hour && min <= compNow.minute && compNow.minute < min+MINUTES_PER_LABEL) {
                        yCurrent = y;
                        [labelHourMin setAlpha:1.0];
                        //([CalendarPopupContent getDayPopup])?[labelHourMin setAlpha:1.0]:nil;
                        //([CalendarPopupContent getDayPopup])?labelWithSameYOfCurrentHour = labelHourMin:nil;
                    }
                }
                y += HEIGHT_CELL_MIN;
            }
        }
        
        totalHeight = y;
    }
    return self;
}

- (UILabel *)labelWithCurrentHourWithWidth:(CGFloat)_width {
    
    label = [[SMXHourAndMinLabel alloc] initWithFrame:CGRectMake(10, yCurrent+25, _width-10, HEIGHT_CELL_MIN) date:[NSDate date]];
    NSDateComponents *comp =  [NSDate componentsOfDate:[NSDate date]];
    int lHour = (int)comp.hour;
    NSString *lAmPm = [[TagManager sharedInstance]tagByName:kTag_AM];
    if (lHour>=12) {
        lAmPm = [[TagManager sharedInstance]tagByName:kTag_PM];
    }
    lHour = (lHour>12? lHour - 12 : lHour); //converting to 0-12 hrs standard
    [label setText:[NSString stringWithFormat:@"%02d:%02ld %@", lHour, (long)comp.minute, lAmPm]];
    [label setTextColor:[UIColor colorFromHexString:@"e15001"]];
    label.font = [UIFont fontWithName:kHelveticaNeueRegular size:12.0];
    CGFloat width = [label widthThatWouldFit];
    view = [[UIView alloc] initWithFrame:CGRectMake(label.frame.origin.x+width, HEIGHT_CELL_MIN/2., _width-label.frame.origin.x-width, 1.)];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [view setBackgroundColor:[UIColor colorFromHexString:kOrangeColor]];
    [label addSubview:view];
    
    currentTimeLayer=[[UIImageView alloc] initWithFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y,160,25.)];
    currentTimeLayer.backgroundColor=[UIColor lighterGrayColor];
    currentTimeLayer.alpha=1.0f;
    [self refreshButton:label.frame.origin.y];
    [self currentTimeLayerOpacity:currentTimeLayer];
    return label;
}
-(void)currentTimeLayerOpacity:(UIImageView *)imageView{
    imageView.layer.shadowOpacity=10.0f;
    imageView.layer.shadowColor=[UIColor whiteColor].CGColor;
    imageView.layer.shadowOffset = CGSizeMake(0.0f,0.0f);
    imageView.layer.shadowRadius=7.0f;
}
-(void)labelWithCurrentHourWithWidth_refresh:(CGFloat)_width
{
    NSDateComponents *comp =  [NSDate componentsOfDate:[NSDate date]];
    float lHourHeight = comp.hour * HEIGHT_CELL_HOUR;
    float lMinuteHeight =  (float)((comp.minute)/60.0) * HEIGHT_CELL_HOUR;
    int lHour = (int)comp.hour;
    NSString *lAmPm = [[TagManager sharedInstance]tagByName:kTag_AM];
    if (lHour>=12) {
        lAmPm = [[TagManager sharedInstance]tagByName:kTag_PM];
    }
    lHour = (lHour>12? lHour - 12 : lHour); //converting to 0-12 hrs standard
    [label setText:[NSString stringWithFormat:@"%02d:%02ld %@", lHour, (long)comp.minute, lAmPm]];
    CGRect lFrame = label.frame;
    lFrame.origin.y = (lHourHeight + lMinuteHeight)-17.;
    label.frame = lFrame;
    currentTimeLayer.center=CGPointMake(0, label.center.y);
    [self refreshButton:label.center.y];
}

-(void)refreshButton:(int)LineCellY{
    int cellHight=HEIGHT_CELL_HOUR;
    int cellY=LineCellY;
    cellY=cellY%cellHight;
    if (cellY<=10) {
        currentTimeLayer.backgroundColor=[UIColor whiteColor];
        currentTimeLayer.frame=CGRectMake(currentTimeLayer.frame.origin.x, LineCellY-(cellY+35.), currentTimeLayer.frame.size.width,35.);
    } else if(cellY>=45 && cellY<=70){
        currentTimeLayer.backgroundColor=[UIColor whiteColor];
        currentTimeLayer.frame=CGRectMake(currentTimeLayer.frame.origin.x, LineCellY+(35.-cellY), currentTimeLayer.frame.size.width,35.);
    } else{
        currentTimeLayer.backgroundColor=[UIColor clearColor];
        currentTimeLayer.frame=CGRectMake(currentTimeLayer.frame.origin.x, currentTimeLayer.frame.origin.y,currentTimeLayer.frame.size.width,25.);
    }
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
