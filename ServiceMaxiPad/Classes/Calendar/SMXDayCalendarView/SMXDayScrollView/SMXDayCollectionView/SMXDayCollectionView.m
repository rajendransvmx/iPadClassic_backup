//
//  SMXDayCollectionView.m
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


#import "SMXDayCollectionView.h"

#import "SMXDayCollectionViewFlowLayout.h"
#import "SMXImportantFilesForCalendar.h"
#import "SMXBlueButton.h"
#import "CalenderHelper.h"

@interface SMXDayCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic) CGFloat lastContentOffset;
@property (nonatomic) BOOL boolGoPrevious;
@property (nonatomic) BOOL boolGoNext;
@property (nonatomic, strong) NSDate *cDate;
@property (nonatomic, strong) NSIndexPath *cLatestCellDataDownloadedIndexpath;
@property (nonatomic, strong) SMXEvent *lRefEvent;
@end

@implementation SMXDayCollectionView

@synthesize protocol;
@synthesize dictEvents;
@synthesize lastContentOffset;
@synthesize boolGoPrevious;
@synthesize boolGoNext;
@synthesize cDate;
@synthesize prioritySLADBInProgressDict;
@synthesize cLatestCellDataDownloadedIndexpath;
@synthesize lRefEvent;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    
    self = [super initWithFrame:frame collectionViewLayout:[SMXDayCollectionViewFlowLayout new]];
    
    if (self) {
        // Initialization code
        
        [self setDataSource:self];
        [self setDelegate:self];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        
        [self registerClass:[SMXDayCell class] forCellWithReuseIdentifier:REUSE_IDENTIFIER_MONTH_CELL];
        
        [self setScrollEnabled:YES];
        [self setPagingEnabled:YES];
        
        boolGoNext = NO;
        boolGoPrevious = NO;
        
//        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
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

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
//    int intDay = [[[DateManager sharedManager] currentDate] numberOfDaysInMonthCount];
    int intDay = (int)(7*([[[SMXDateManager sharedManager] currentDate] numberOfWeekInMonthCount]+2));
    return intDay;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDateComponents *comp = [NSDate componentsOfDate:[[SMXDateManager sharedManager] currentDate]];
    SMXDayCell *cell = (SMXDayCell *)[collectionView dequeueReusableCellWithReuseIdentifier:REUSE_IDENTIFIER_MONTH_CELL forIndexPath:indexPath];
    cell.cellIndex=(int)[indexPath row];
    [cell setProtocol:(id)self.superview.superview];
    [cell setCollectionViewDelegate:self];
    [cell setDate:[NSDate dateWithYear:comp.year month:comp.month day:1+indexPath.row-7]];
    if ( [cDate compare:cell.date]!=NSOrderedSame) {
        [[SMXDateManager sharedManager] setSelectedEvent:nil];
    }
    cell.cSelectedEventButton = nil;

    //[cell showEvents:[dictEvents objectForKey:cell.date]];
    
    NSArray *lEventArray = [self getEventsFromDictinory:[[SMXDateManager sharedManager] getdictEvents] withKey:cell.date];
    if (lEventArray.count) {
        SMXEvent *lEvent = [lEventArray objectAtIndex:0];
        if (!lEvent.newData) {
            [self getSLAAndPriorityDataFromDB:lEventArray forCellDate:cell.date withIndex:indexPath];
        }
    }
    
    [cell showEvents:lEventArray];
    cDate = cell.date;

    return cell;
}

#pragma mark - UICollectionView Delegate FlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake((self.frame.size.width-1), self.frame.size.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}
-(void)refreshCell:(int )fromCell Tocell:(int )toCell forEvent:(SMXEvent *)event{
    if (toCell>=0) {
        
        [self reloadData];

        NSIndexPath *indexPathToRefresh = [NSIndexPath indexPathForRow:fromCell inSection:0];
        SMXDayCell *refreshedCell = (SMXDayCell *)[self cellForItemAtIndexPath:indexPathToRefresh];
        [refreshedCell cellRefreshedChangeSelectedButtontoHighlight:event];

    }
    [[SMXDateManager sharedManager] setCollectiondelegate:nil];
}
-(NSArray *)getEventsFromDictinory:(NSMutableDictionary *)eventList withKey:(NSDate *)key{
    return [eventList objectForKey:key];
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
        }];
        [lCalendarHelper performSelectorInBackground:@selector(getSLAPriorityForEventArray:) withObject:lEventArray];

        [self.prioritySLADBInProgressDict setObject:lCalendarHelper forKey:date];
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (!boolGoPrevious && scrollView.contentOffset.x < 0) {
        boolGoPrevious = YES;
    }
    
    if (!boolGoNext && scrollView.contentOffset.x > 7*([[[SMXDateManager sharedManager] currentDate] numberOfWeekInMonthCount]+2-1)*scrollView.frame.size.width) {
        boolGoNext = YES;
        
    }

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    lRefEvent = [[SMXDateManager sharedManager] selectedEvent];  // Its a reference. If the collection doesnt traverse to next cell or the user drags the collection cell around but comes back to the same cell. Then, the highlighted Event should be re-highlighted cause, the reload of cell cause the highlighted event losses its highlighted color. :)

    lastContentOffset = scrollView.contentOffset.x;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView; // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
{
    NSArray *lVisibleCellIndexpath = [self indexPathsForVisibleItems];
    if ([lVisibleCellIndexpath containsObject: cLatestCellDataDownloadedIndexpath]) {
        cLatestCellDataDownloadedIndexpath = nil;
//        [self reloadItemsAtIndexPaths:lVisibleCellIndexpath];
        [self reloadData];


    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSDateComponents *comp = [NSDate componentsOfDate:[[SMXDateManager sharedManager] currentDate]];
    
    ScrollDirection scrollDirection;
    if (lastContentOffset > scrollView.contentOffset.x || boolGoPrevious) {
        scrollDirection = ScrollDirectionRight;
        comp.day -= 1;
    } else if (lastContentOffset < scrollView.contentOffset.x || boolGoNext) {
        scrollDirection = ScrollDirectionLeft;
        comp.day += 1;
    } else {
        scrollDirection = ScrollDirectionNone;
    }
    
    NSArray *lVisibleCellIndexpath = [self indexPathsForVisibleItems];

    if (protocol != nil && [protocol respondsToSelector:@selector(updateHeader)] && scrollDirection !=ScrollDirectionNone) {
        [[SMXDateManager sharedManager] setCurrentDate:[NSDate dateWithYear:comp.year month:comp.month day:comp.day]];
        [protocol updateHeader];
    }
    else
    {
        [[SMXDateManager sharedManager] setSelectedEvent: lRefEvent];

        if (scrollDirection == ScrollDirectionNone) {
            SMXDayCell *theCell = nil;
            for (NSIndexPath *indexPath in lVisibleCellIndexpath) {
                
                theCell = (SMXDayCell *)[self cellForItemAtIndexPath:indexPath];

                if ([theCell.date compare:[NSDate dateWithYear:comp.year month:comp.month day:comp.day]] == NSOrderedSame) {
                   
                    cDate = theCell.date; //If the cell has not been changed, assign the cDate to the value of the cell date.
                    
                    [theCell methodForChangeTheSelectedButtonColor:lRefEvent];  // Highlight the event button which has lost its color due to reload of cell.

                }
            }

        }
        
    }
    if ([lVisibleCellIndexpath containsObject: cLatestCellDataDownloadedIndexpath]) {
        [self reloadData];
    }
    
    cLatestCellDataDownloadedIndexpath = nil;
    boolGoPrevious = NO;
    boolGoNext = NO;
}

@end
