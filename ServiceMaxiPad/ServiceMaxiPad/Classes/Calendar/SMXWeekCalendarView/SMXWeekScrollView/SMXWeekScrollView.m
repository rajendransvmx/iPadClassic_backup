//
//  SMXWeekScrollView.m
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

#import "SMXWeekScrollView.h"

#import "SMXViewWithHourLines.h"
#import "SMXImportantFilesForCalendar.h"
#import "Utility.h"

@interface SMXWeekScrollView () <UIScrollViewDelegate>
@property (nonatomic, strong) SMXViewWithHourLines *viewWithHourLines;
@end

@implementation SMXWeekScrollView

#pragma mark - Synthesize

@synthesize dictEvents;
@synthesize labelWithActualHour;
@synthesize labelGrayWithActualHour;
@synthesize viewWithHourLines;
@synthesize collectionViewWeek;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if ([Utility isDeviceIOS8]) {
             [self setAutoresizingMask:AR_WIDTH_HEIGHT];
        }else{
            [self setAutoresizingMask:AR_WIDTH_HEIGHT];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetTheCurrentTimeLine) name:CURRENT_TIME_LINE_MOVE_WEEK object:nil];
    }
    return self;
}

- (void)setDictEvents:(NSMutableDictionary *)_dictEvents {
    
    dictEvents = _dictEvents;
    
    if (!viewWithHourLines) {
        
        viewWithHourLines = [[SMXViewWithHourLines alloc] initWithFrame:CGRectMake(0, 0, 90., self.frame.size.height)];
        [self addSubview:viewWithHourLines];
        
        collectionViewWeek = [[SMXWeekCollectionView alloc] initWithFrame:CGRectMake(viewWithHourLines.frame.size.width,viewWithHourLines.frame.origin.y,self.frame.size.width-viewWithHourLines.frame.size.width,viewWithHourLines.totalHeight+WEEK_HEIGHT_CELL_HOUR)collectionViewLayout:[UICollectionViewFlowLayout new]];
        [self scrollToPage:[NSDate componentsOfDate:[[SMXDateManager sharedManager] currentDate]].weekOfMonth+1];
        [self addSubview:collectionViewWeek];
        
        labelWithActualHour = [viewWithHourLines labelWithCurrentHourWithWidth:self.frame.size.width];
        [labelWithActualHour setFrame:CGRectMake(labelWithActualHour.frame.origin.x, labelWithActualHour.frame.origin.y+viewWithHourLines.frame.origin.y, labelWithActualHour.frame.size.width, labelWithActualHour.frame.size.height)];
        [self addSubview:labelWithActualHour];
        labelGrayWithActualHour = viewWithHourLines.labelWithSameYOfCurrentHour;
        [labelGrayWithActualHour setAlpha:0.];
        
        [self setContentSize:CGSizeMake(self.frame.size.width, collectionViewWeek.frame.origin.y+collectionViewWeek.frame.size.height-CELL_HEIGHT_MARGINE_BOTTOM)];
        [self scrollRectToVisible:CGRectMake(0., labelWithActualHour.frame.origin.y, self.frame.size.width, self.frame.size.height) animated:YES];
    }
    [collectionViewWeek setDictEvents:dictEvents];
    [collectionViewWeek reloadData];
}

-(void)resetTheCurrentTimeLine
{
    [viewWithHourLines labelWithCurrentHourWithWidth_refresh:self.frame.size.width];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)updateWithCurrentTime{
    
   // [viewWithHourLines updateTiming];
}
- (void)scrollToPage:(int)_intPage {
//    NSInteger intIndex = 7*_intPage-1;
//    [collectionViewWeek scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:intIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    [collectionViewWeek setContentOffset:CGPointMake((_intPage-1)*collectionViewWeek.frame.size.width, 0.)];
}

@end
