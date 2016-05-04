  //
//  SMXWeekCollectionView.m
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

#import "SMXWeekCollectionView.h"

#import "SMXWeekCell.h"
#import "SMXWeekCollectionViewFlowLayout.h"
#import "SMXImportantFilesForCalendar.h"
#import "SMXDateManager.h"
#import "CalenderHelper.h"
#import "SMXCalendarViewController.h"

@interface SMXWeekCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SMXWeekCellProtocol>
@property (nonatomic) CGFloat lastContentOffset;
@property (nonatomic) BOOL boolGoNext;
@property (nonatomic) BOOL boolGoPrevious;
@property (nonatomic, strong) NSMutableDictionary *prioritySLADBInProgressDict;
@property (nonatomic, strong) NSIndexPath *cLatestCellDataDownloadedIndexpath;
@property (nonatomic, assign) BOOL shouldReload;
@end

@implementation SMXWeekCollectionView

@synthesize protocol;
@synthesize lastContentOffset;
@synthesize dictEvents;
@synthesize boolGoNext;
@synthesize boolGoPrevious;
@synthesize prioritySLADBInProgressDict;
@synthesize cLatestCellDataDownloadedIndexpath;
@synthesize shouldReload;
@synthesize weekCalendarDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    
    self = [super initWithFrame:frame collectionViewLayout:[SMXWeekCollectionViewFlowLayout new]];
    
    if (self) {
        // Initialization code
        
        [self setDataSource:self];
        [self setDelegate:self];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        [self registerClass:[SMXWeekCell class] forCellWithReuseIdentifier:REUSE_IDENTIFIER_MONTH_CELL];
        
        [self setScrollEnabled:YES];
        [self setPagingEnabled:YES];
        
        boolGoPrevious = NO;
        boolGoNext = NO;

        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    }
    //self.backgroundColor=[UIColor yellowColor];
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

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    int intDay = 7*(int)([[[SMXDateManager sharedManager] currentDate] numberOfWeekInMonthCount]+2);
    
    return intDay;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDateComponents *comp = [NSDate componentsOfDate:[[SMXDateManager sharedManager] currentDate]];
    NSDate *dateFirstDayOfMonth = [NSDate dateWithYear:comp.year month:comp.month day:1];
    NSDateComponents *componentsFirstDayOfMonth = [NSDate componentsOfDate:dateFirstDayOfMonth];

    SMXWeekCell *cell = (SMXWeekCell *)[collectionView dequeueReusableCellWithReuseIdentifier:REUSE_IDENTIFIER_MONTH_CELL forIndexPath:indexPath];
    cell.weekCalendarDelegate=weekCalendarDelegate;
    cell.cellIndex=(int)[indexPath row];
    [cell clean];
    [cell setProtocol:self];
    [cell setCollectionViewDelegate:self];
    [cell setDate:[NSDate dateWithYear:comp.year month:comp.month day:1+indexPath.row-(componentsFirstDayOfMonth.weekday-1)-7]];
    //[cell showEvents:[dictEvents objectForKey:cell.date]];
    
    NSArray *lEventArray = [self getEventsFromDictinory:[[SMXDateManager sharedManager] getdictEvents] withKey:cell.date];
    if (lEventArray.count) {
        SMXEvent *lEvent = [lEventArray objectAtIndex:0];
        if (!lEvent.newData) {
            shouldReload = YES;
            [self getSLAAndPriorityDataFromDB:lEventArray forCellDate:cell.date withIndex:indexPath];
        }
    }

    if (!collectionView.isDragging)
    {
        [cell showEvents:[self getEventsFromDictinory:[[SMXDateManager sharedManager] getdictEvents] withKey:cell.date]];
    }
    if ([NSDate isTheSameDateTheCompA:cell.date.componentsOfDate compB:[NSDate componentsOfCurrentDate]] && protocol != nil && [protocol respondsToSelector:@selector(showHourLine:)]) {
        [protocol showHourLine:YES];
    }
    
    return cell;
}

#pragma mark - UICollectionView Delegate FlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake((self.frame.size.width-7*SPACE_COLLECTIONVIEW_CELL)/7, self.frame.size.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return SPACE_COLLECTIONVIEW_CELL;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return SPACE_COLLECTIONVIEW_CELL;
}

-(void)getSLAAndPriorityDataFromDB:(NSArray *)lEventArray forCellDate:(NSDate *)date withIndex:(NSIndexPath *)indexpath
{
    
    CalenderHelper *lCalendarHelper = self.prioritySLADBInProgressDict[date];
    if (lCalendarHelper == nil)
    {
        cLatestCellDataDownloadedIndexpath = indexpath;
        
        lCalendarHelper = [CalenderHelper new];
        
        [lCalendarHelper setCompletionHandler:^(NSArray *eventArray){
            
            NSMutableDictionary*lEventDict = [[SMXDateManager sharedManager] dictEvents];
            
            [lEventDict setObject:eventArray forKey:date];
            [[SMXDateManager sharedManager] setDictEvents:lEventDict];
            
            [self.prioritySLADBInProgressDict removeObjectForKey:date];
            //          [self reloadItemsAtIndexPaths:[NSArray arrayWithObjects:indexpath, nil]];
            
            //            [self performSelectorOnMainThread:@selector(reloadItemsAtIndexPaths:) withObject:[NSArray arrayWithObjects:indexpath, nil] waitUntilDone:NO];
            
            
        }];
        [lCalendarHelper performSelectorInBackground:@selector(getSLAPriorityForEventArray:) withObject:lEventArray];
        
        [self.prioritySLADBInProgressDict setObject:lCalendarHelper forKey:date];
    }
}

-(void)reloadIfNeeded
{
    if (shouldReload) {
        [self reloadData];
        shouldReload = NO;
    }
}
#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (protocol != nil && [protocol respondsToSelector:@selector(collectionViewDidScroll)]) {
        [protocol collectionViewDidScroll];
    }
    
    if (!boolGoPrevious && scrollView.contentOffset.x < 0) {
        boolGoPrevious = YES;
    }
    
    if (!boolGoNext && scrollView.contentOffset.x >  ([[[SMXDateManager sharedManager] currentDate] numberOfWeekInMonthCount]-1)*scrollView.frame.size.width) {
        boolGoNext = YES;
    }
    
    if (protocol != nil && [protocol respondsToSelector:@selector(showHourLine:)]) {
        [protocol showHourLine:NO];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    lastContentOffset = scrollView.contentOffset.x;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
/* in this method we are facing performance problem, when we was scrolling its was jerking,
 */
//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{

    NSDateComponents *comp = [NSDate componentsOfDate:[[SMXDateManager sharedManager] currentDate]];
    
    ScrollDirection scrollDirection;
    if (lastContentOffset > scrollView.contentOffset.x || boolGoPrevious) {
        scrollDirection = ScrollDirectionRight;
        comp.day -= 7;
    } else if (lastContentOffset < scrollView.contentOffset.x || boolGoNext) {
        scrollDirection = ScrollDirectionLeft;
        comp.day += 7;
    } else {
        scrollDirection = ScrollDirectionNone;
    }
    
    [[SMXDateManager sharedManager] setCurrentDate:[NSDate dateWithYear:comp.year month:comp.month day:comp.day]];
    //[[NSNotificationCenter defaultCenter] postNotificationName:DATE_MONTH_TEXT_NOTIFICATION object:[[SMXDateManager sharedManager] currentDate]];
    [[SMXCalendarViewController sharedInstance] leftButtonTextChangeOnDateChange:[[SMXDateManager sharedManager] currentDate]];
    
    NSArray *visibleIndexPath = [self indexPathsForVisibleItems];
    if([visibleIndexPath containsObject:cLatestCellDataDownloadedIndexpath])
    {
        cLatestCellDataDownloadedIndexpath = nil;
        [self reloadItemsAtIndexPaths:[self indexPathsForVisibleItems]];
    }
    
    boolGoPrevious = NO;
    boolGoNext = NO;
}

#pragma mark - SMXWeekCell Protocol

- (void)saveEditedEvent:(SMXEvent *)eventNew ofCell:(UICollectionViewCell *)cell atIndex:(NSInteger)intIndex {
    
    NSDate *dateNew = eventNew.ActivityDateDay;
        
    NSMutableArray *arrayNew = [dictEvents objectForKey:dateNew];
    if (!arrayNew) {
        arrayNew = [NSMutableArray new];
        [dictEvents setObject:arrayNew forKey:dateNew];
    }
    [arrayNew addObject:eventNew];
    
    if (protocol != nil && [protocol respondsToSelector:@selector(setNewDictionary:)]) {
        [protocol setNewDictionary:dictEvents];
    } else {
        [self reloadData];
    }
}

- (void)deleteEventOfCell:(UICollectionViewCell *)cell atIndex:(NSInteger)intIndex {
    
    SMXWeekCell *cellWeek = (SMXWeekCell *)cell;
    
    NSDate *date = cellWeek.date;
    NSMutableArray *array = [dictEvents objectForKey:date];
    [array removeObjectAtIndex:intIndex];
    if (array.count == 0) {
        [dictEvents removeObjectForKey:date];
    }
    
    if (protocol != nil && [protocol respondsToSelector:@selector(setNewDictionary:)]) {
        [protocol setNewDictionary:dictEvents];
    } else {
        [self reloadData];
    }
}

- (void)addReshudlingWindow:(SMXEvent *)event_Loc{
    
}

-(NSArray *)getEventsFromDictinory:(NSMutableDictionary *)eventList withKey:(NSDate *)key{
    return [eventList objectForKey:key];
}
-(void)refreshCell:(int )fromCell Tocell:(int )toCell forEvent:(SMXEvent *)event{
    if (fromCell==toCell) {
        if (fromCell>=0) {
            NSIndexPath *indexPathToRefresh = [NSIndexPath indexPathForRow:fromCell inSection:0];
            [self reloadItemsAtIndexPaths:[NSArray arrayWithObjects:indexPathToRefresh, nil]];
        }
    }else{
        if (toCell>=0 && fromCell>=0) {
            NSIndexPath *indexPathToRefresh = [NSIndexPath indexPathForRow:fromCell inSection:0];
            NSIndexPath *indexPathToRefresh1 = [NSIndexPath indexPathForRow:toCell inSection:0];
            [self reloadItemsAtIndexPaths:[NSArray arrayWithObjects:indexPathToRefresh,indexPathToRefresh1, nil]];
        }
    }
    [[SMXDateManager sharedManager] setCollectiondelegate:nil];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
