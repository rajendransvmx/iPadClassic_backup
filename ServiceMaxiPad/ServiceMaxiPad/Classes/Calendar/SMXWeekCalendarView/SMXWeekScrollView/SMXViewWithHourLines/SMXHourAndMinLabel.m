//
//  SMXHourAndMinLabel.m
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

#import "SMXHourAndMinLabel.h"

#import "SMXImportantFilesForCalendar.h"
#import "StyleManager.h"

@implementation SMXHourAndMinLabel

#pragma mark - Synthesize

@synthesize dateHourAndMin;
@synthesize topInset;
@synthesize leftInset;
@synthesize isAttributedString;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

    }
    return self;
}



- (id)initWithFrame:(CGRect)frame date:(NSDate *)date {
    
    self = [self initWithFrame:frame];
    
    if (self) {
        
        dateHourAndMin = date;

    }
    return self;
}

- (void)showText {
    
    NSDateComponents *comp =  [NSDate componentsOfDate:dateHourAndMin];
    
    int lHour = comp.hour;
    NSString *lAmPm = @"a";
    

     if (lHour>=12) {
        lAmPm = @"p";
    }
    if (comp.minute == 30) {
        lAmPm = @"";
    }
    
    lHour = (lHour>12? lHour - 12 : lHour); //converting to 0-12 hrs standard
    
    if (lHour%4 != 0) {
        
        lAmPm = @"";   // display am/pm every 4 hrs. other times nothing.
    }
     [self setAttributedText:[self getString:[NSString stringWithFormat:@"%02d:%02d", lHour, comp.minute] year:lAmPm]];
    //[self setText:[NSString stringWithFormat:@"%02d:%02d %@", lHour, comp.minute, lAmPm]];
}

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {self.topInset, self.leftInset, 0, 0};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}
-(void)showAttributedText{
    NSDateComponents *comp =  [NSDate componentsOfDate:dateHourAndMin];
    
    int lHour = comp.hour;
    NSString *lAmPm = @"a";
    
    
    if (lHour>=12) {
        lAmPm = @"p";
    }
    if (comp.minute == 30) {
        lAmPm = @"";
    }
    
    lHour = (lHour>12? lHour - 12 : lHour); //converting to 0-12 hrs standard
    
    if (lHour%4 != 0) {
        
        lAmPm = @"";   // display am/pm every 4 hrs. other times nothing.
    }
    //[self setText:[NSString stringWithFormat:@"%02d:%02d %@", lHour, comp.minute, lAmPm]];
    [self setAttributedText:[self getString:[NSString stringWithFormat:@"%02d:%02d", lHour, comp.minute] year:lAmPm]];
}
-(NSAttributedString *)getString:(NSString *)time year:(NSString *)hour{
    if (time==nil && hour==nil) {
        return [[NSAttributedString alloc] init];
    }
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",time,hour]];
    NSDictionary *attrDict = @{
                               NSForegroundColorAttributeName : [UIColor colorWithHexString:@"797979"]
                               };
    [attString addAttributes:attrDict range:NSMakeRange([attString length]-1,1)];
    return attString;
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
