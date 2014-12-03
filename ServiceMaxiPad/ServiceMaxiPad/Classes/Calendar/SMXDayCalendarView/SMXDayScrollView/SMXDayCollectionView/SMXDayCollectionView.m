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

@interface SMXDayCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic) CGFloat lastContentOffset;
@property (nonatomic) BOOL boolGoPrevious;
@property (nonatomic) BOOL boolGoNext;
@property (nonatomic, retain) NSDate *cDate;
@end

@implementation SMXDayCollectionView

@synthesize protocol;
@synthesize dictEvents;
@synthesize lastContentOffset;
@synthesize boolGoPrevious;
@synthesize boolGoNext;
@synthesize cDate;

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
    int intDay = 7*([[[SMXDateManager sharedManager] currentDate] numberOfWeekInMonthCount]+2);
    
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
    [cell showEvents:[self getEventsFromDictinory:[[SMXDateManager sharedManager] getdictEvents] withKey:cell.date]];
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
        NSIndexPath *indexPathToRefresh = [NSIndexPath indexPathForRow:fromCell inSection:0];
        [self reloadItemsAtIndexPaths:[NSArray arrayWithObjects:indexPathToRefresh, nil]];
        SMXDayCell *refreshedCell = (SMXDayCell *)[self cellForItemAtIndexPath:indexPathToRefresh];
        [refreshedCell cellRefreshedChangeSelectedButtontoHighlight:event];
    }
}
-(NSArray *)getEventsFromDictinory:(NSMutableDictionary *)eventList withKey:(NSDate *)key{
    return [eventList objectForKey:key];
}
#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (!boolGoPrevious && scrollView.contentOffset.x < 0) {
        boolGoPrevious = YES;
    }
    
    if (!boolGoNext && scrollView.contentOffset.x > 7*([[[SMXDateManager sharedManager] currentDate] numberOfWeekInMonthCount]+2-1)*scrollView.frame.size.width) {
        boolGoNext = YES;
        
        NSLog(@"%f", scrollView.contentOffset.x);
         NSLog(@"%f", 7*([[[SMXDateManager sharedManager] currentDate] numberOfWeekInMonthCount]+2-1)*scrollView.frame.size.width);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    lastContentOffset = scrollView.contentOffset.x;
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
    
    
    if (protocol != nil && [protocol respondsToSelector:@selector(updateHeader)] && scrollDirection !=ScrollDirectionNone) {
        [[SMXDateManager sharedManager] setCurrentDate:[NSDate dateWithYear:comp.year month:comp.month day:comp.day]];
        [protocol updateHeader];

    }
    
    boolGoPrevious = NO;
    boolGoNext = NO;
}








@end
