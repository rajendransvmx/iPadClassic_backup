/**
 *  @file   SMXWeekCalendarView.m
 *  @class  SMXWeekCalendarView
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

#import "SMXWeekCalendarView.h"

#import "SMXWeekHeaderCollectionView.h"
#import "SMXWeekScrollView.h"
#import "SMXImportantFilesForCalendar.h"
#import "StyleManager.h"

@interface SMXWeekCalendarView () <SMXWeekCollectionViewProtocol, SMXWeekHeaderCollectionViewProtocol>
@property (nonatomic, strong) SMXWeekHeaderCollectionView *scrollViewHeaderWeek;
@property (nonatomic, strong) SMXWeekScrollView *weekContainerScroll;
@end

@implementation SMXWeekCalendarView

#pragma mark - Synthesize

@synthesize dictEvents;
@synthesize scrollViewHeaderWeek;
@synthesize weekContainerScroll;
@synthesize protocol;
@synthesize grayBorder;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dateChanged:) name:DATE_MANAGER_DATE_CHANGED object:nil];
        [self setBackgroundColor:[UIColor whiteColor]];
        
        [self setAutoresizingMask: AR_WIDTH_HEIGHT];
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

- (void)setDictEvents:(NSMutableDictionary *)_dictEvents {
    
    dictEvents = _dictEvents;
    
    if (!scrollViewHeaderWeek) {
        UIView *viewLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90., HEADER_HEIGHT_SCROLL_WEEK)];
        [viewLeft setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:viewLeft];
        
        scrollViewHeaderWeek = [[SMXWeekHeaderCollectionView alloc] initWithFrame:CGRectMake(viewLeft.frame.size.width, 0, self.frame.size.width-viewLeft.frame.size.width, HEADER_HEIGHT_SCROLL_WEEK)];
        [scrollViewHeaderWeek setProtocol:self];
        [self scrollToPage:[NSDate componentsOfDate:[[SMXDateManager sharedManager] currentDate]].weekOfMonth+1];
        [self addSubview:scrollViewHeaderWeek];
        
        weekContainerScroll = [[SMXWeekScrollView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT_SCROLL_WEEK, self.frame.size.width-0, self.frame.size.height-HEADER_HEIGHT_SCROLL_WEEK)];
       // weekContainerScroll.backgroundColor=[UIColor redColor];
        [self addSubview:weekContainerScroll];
    }
    [weekContainerScroll setDictEvents:dictEvents];
    [weekContainerScroll.collectionViewWeek setProtocol:self];
    [self addSubview:[self grayLine:CGRectMake(50,40, self.frame.size.width-50, 1)]];
   // [self addSubview:[self borderView:CGRectMake(self.frame.origin.x+77,40, self.frame.size.width-77,self.frame.size.height)]];
}
-(UIImageView *)borderView:(CGRect)rect{
    UIImageView *grayLine=[[UIImageView alloc] initWithFrame:rect];
    grayLine.layer.borderColor=[UIColor colorWithHexString:@"D7D7D7"].CGColor;
    grayLine.layer.borderWidth=1.0f;
    return grayLine;
}
-(UIImageView *)grayLine:(CGRect )rect{
    grayBorder=[[UIImageView alloc] initWithFrame:rect];
    grayBorder.backgroundColor=[UIColor colorWithHexString:@"D7D7D7"];
    return grayBorder;
}
- (void)scrollToPage:(int)_intPage {
    NSInteger intIndex = 7*_intPage-1;
    [scrollViewHeaderWeek scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:intIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
}

#pragma mark - Invalidate Layout

- (void)invalidateLayout {
    
    [scrollViewHeaderWeek.collectionViewLayout invalidateLayout];
    [weekContainerScroll.collectionViewWeek.collectionViewLayout invalidateLayout];
    [self dateChanged:nil];
    grayBorder.frame=CGRectMake(50,40, self.frame.size.width-50, 1);
    [self refreshTimig];
    ///[self addSubview:[self grayLine:CGRectMake(65,40, self.frame.size.width-65, 1)]];
}

#pragma mark - SMXDateManager Notification

- (void)dateChanged:(NSNotification *)not {
    
    [scrollViewHeaderWeek reloadData];
    [self scrollToPage:[NSDate componentsOfDate:[[SMXDateManager sharedManager] currentDate]].weekOfMonth+1];
    
    [weekContainerScroll.collectionViewWeek reloadData];
}

#pragma mark - SMXWeekCollectionView Protocol

- (void)collectionViewDidScroll {
    
    CGPoint offset = scrollViewHeaderWeek.contentOffset;
    offset.x = weekContainerScroll.collectionViewWeek.contentOffset.x;
    [scrollViewHeaderWeek setContentOffset:offset];
    grayBorder.frame=CGRectMake(50,40, self.frame.size.width-50, 1);
}

- (void)showHourLine:(BOOL)show {
    
    [weekContainerScroll.labelWithActualHour setAlpha:show];
    [weekContainerScroll.labelGrayWithActualHour setAlpha:!show];
    
    if (show) {
        [weekContainerScroll scrollRectToVisible:CGRectMake(weekContainerScroll.frame.origin.x, weekContainerScroll.labelWithActualHour.frame.origin.y, weekContainerScroll.frame.size.width, weekContainerScroll.frame.size.height) animated:YES];
    }
}

- (void)setNewDictionary:(NSDictionary *)dict {
    
    if (protocol != nil && [protocol respondsToSelector:@selector(setNewDictionary:)]) {
        [protocol setNewDictionary:dictEvents];
    }
}

#pragma mark - SMXWeekHeaderCollectionView Protocol

- (void)headerDidScroll {
    
    CGPoint offset = weekContainerScroll.collectionViewWeek.contentOffset;
    offset.x = scrollViewHeaderWeek.contentOffset.x;
    [weekContainerScroll.collectionViewWeek setContentOffset:offset];
}
-(void)reloadWeekcalendar{
    [weekContainerScroll.collectionViewWeek reloadData];
}
-(void)refreshTimig{
   // [weekContainerScroll updateWithCurrentTime];
}
@end
