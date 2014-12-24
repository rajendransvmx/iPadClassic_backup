//
//  SMXDayHeaderCollectionView.m
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


#import "SMXDayHeaderCollectionView.h"

#import "SMXDayHeaderCell.h"
#import "SMXWeekCollectionViewFlowLayout.h"
#import "SMXImportantFilesForCalendar.h"
#import "DateUtil.h"

#define QNT_BY_PAGING 7

@interface SMXDayHeaderCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic) CGFloat lastContentOffset;
@property (nonatomic) BOOL boolGoPrevious;
@property (nonatomic) BOOL boolGoNext;
@end

@implementation SMXDayHeaderCollectionView

@synthesize lastContentOffset;
@synthesize protocol;
@synthesize boolGoPrevious;
@synthesize boolGoNext;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    
    self = [super initWithFrame:frame collectionViewLayout:[SMXWeekCollectionViewFlowLayout new]];
    
    if (self) {
        // Initialization code
        
        [self setDataSource:self];
        [self setDelegate:self];
        
//        [self setBackgroundColor:[UIColor lighterGrayColor]];
        [self setBackgroundColor:[UIColor whiteColor]];
        
        [self registerClass:[SMXDayHeaderCell class] forCellWithReuseIdentifier:REUSE_IDENTIFIER_MONTH_CELL];
        
        [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
        
        
        [self setScrollEnabled:YES];
        [self setPagingEnabled:YES];
//        self.layer.zPosition = 1.0;

        boolGoNext = NO;
        boolGoPrevious = NO;
        
//        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin]; // mine

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
    
    int intDay = 7*([[[SMXDateManager sharedManager] currentDate] numberOfWeekInMonthCount]+2);
    
    return intDay;

}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDateComponents *comp = [NSDate componentsOfDate:[[SMXDateManager sharedManager] currentDate]];
    NSDate *dateFirstDayOfMonth = [NSDate dateWithYear:comp.year month:comp.month day:1];
    NSDateComponents *componentsFirstDayOfMonth = [NSDate componentsOfDate:dateFirstDayOfMonth];
    
    NSDate *dateOfLabel = [NSDate dateWithYear:comp.year month:comp.month day:1+indexPath.row-(componentsFirstDayOfMonth.weekday-1)-7];
    NSDateComponents *compDateOfLabel = [NSDate componentsOfDate:dateOfLabel];
    
    SMXDayHeaderCell *cell = (SMXDayHeaderCell *)[collectionView dequeueReusableCellWithReuseIdentifier:REUSE_IDENTIFIER_MONTH_CELL forIndexPath:indexPath];
    [cell.button addTarget:self action:@selector(dayButton:) forControlEvents:UIControlEventTouchUpInside];
    cell.date = dateOfLabel;
    [cell.button setTitle:[NSString stringWithFormat:@"%i", compDateOfLabel.day] forState:UIControlStateNormal];//anish todo
    [cell.dayLabel setText:[NSString stringWithFormat:@"%@", [arrayWeekAbrev objectAtIndex:compDateOfLabel.weekday-1]]];
    [cell.button setSelected:([NSDate isTheSameDateTheCompA:compDateOfLabel compB:[[SMXDateManager sharedManager] currentDate].componentsOfDate])];
    cell.button.tag = indexPath.row;
    
    if (cell.isSelected && protocol && [protocol respondsToSelector:@selector(daySelected:)]) {
        [protocol daySelected:cell.date];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    

    if (section == 0) {
        return CGSizeMake(320, 0);
    }
    
    return CGSizeZero;
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CGSize footerSize = CGSizeMake(320, 0);
    return footerSize;
}

#pragma mark - Button Action

- (void)dayButton:(SMXDayHeaderButton *)button {
    
    if (protocol && [protocol respondsToSelector:@selector(daySelected:)]) {
        [protocol daySelected:button.date];
    }
    
    [[SMXDateManager sharedManager] setCurrentDate:[button.date dateByAddingTimeInterval:[DateUtil toLocalTime:button.date]]];
    //[[NSNotificationCenter defaultCenter] postNotificationName:DATE_MONTH_TEXT_NOTIFICATION object:button.date];
    [self reloadData];
}

#pragma mark - Scroll to Date

- (void)scrollToDate:(NSDate *)date {
    
    NSDateComponents *comp = [NSDate componentsOfDate:[[SMXDateManager sharedManager] currentDate]];
    NSDate *dateFirstDayOfMonth = [NSDate dateWithYear:comp.year month:comp.month day:1];
    NSDateComponents *componentsFirstDayOfMonth = [NSDate componentsOfDate:dateFirstDayOfMonth];
    
    int x = 0;
    for (int i=1-(componentsFirstDayOfMonth.weekday-1),j=7*[[[SMXDateManager sharedManager] currentDate] numberOfWeekInMonthCount]-(componentsFirstDayOfMonth.weekday-1); i<=j; i++) {
        NSDate *datea = [NSDate dateWithYear:comp.year month:comp.month day:i];
        
        if ([NSDate isTheSameDateTheCompA:date.componentsOfDate compB:datea.componentsOfDate]) {
            break;
        }
        x++;
    }
    
    [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:x+(7-comp.weekday)+7 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
}

#pragma mark - UICollectionView Delegate FlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake((self.frame.size.width)/7, self.frame.size.height);
    
//        return CGSizeMake(320./7, self.frame.size.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - UIScrollView Delegate

/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (!boolGoPrevious && scrollView.contentOffset.x < 0) {
        boolGoPrevious = YES;
    }
    
    if (!boolGoNext && scrollView.contentOffset.x >  ([[[SMXDateManager sharedManager] currentDate] numberOfWeekInMonthCount]-1)*scrollView.frame.size.width) {
        boolGoNext = YES;
    }
    
}
*/

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    lastContentOffset = scrollView.contentOffset.x;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSDateComponents *comp = [[[SMXDateManager sharedManager] currentDate] componentsOfDate];
    
    ScrollDirection scrollDirection;
    if (lastContentOffset > scrollView.contentOffset.x || boolGoPrevious) {
        scrollDirection = ScrollDirectionRight;
        comp.day -=QNT_BY_PAGING;
    } else if (lastContentOffset < scrollView.contentOffset.x || boolGoNext) {
        scrollDirection = ScrollDirectionLeft;
        comp.day +=QNT_BY_PAGING;
    } else {
        scrollDirection = ScrollDirectionNone;
    }
    
    if (protocol && [protocol respondsToSelector:@selector(daySelected:)]) {
        [protocol daySelected:[[SMXDateManager sharedManager] currentDate]];
    }
    
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comp];
    [[SMXDateManager sharedManager] setCurrentDate:[date dateByAddingTimeInterval:[DateUtil toLocalTime:date]]];
    //[[NSNotificationCenter defaultCenter] postNotificationName:DATE_MONTH_TEXT_NOTIFICATION object:date];
    boolGoPrevious = NO;
    boolGoNext = NO;
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
