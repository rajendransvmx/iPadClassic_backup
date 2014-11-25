//
//  SMXMonthCollectionView.m
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

#import "SMXMonthCollectionView.h"

#import "SMXMonthCollectionViewFlowLayout.h"
#import "SMXEvent.h"
#import "SMXMonthCell.h"
#import "SMXImportantFilesForCalendar.h"
#import "StyleManager.h"
#import "DateUtil.h"

@interface SMXMonthCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SMXMonthCellProtocol>
@property (nonatomic) CGFloat lastContentOffset;
@property (nonatomic, strong) NSMutableArray *arraySizeOfCells;
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSMutableArray *arrayWithFirstDay;
@end

@implementation SMXMonthCollectionView

#pragma mark - Synthesize

@synthesize arraySizeOfCells;
@synthesize arrayWithFirstDay;
@synthesize lastContentOffset;
@synthesize array;
@synthesize dictEvents;
@synthesize protocol;

#pragma mark - Lyfecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {

    self = [super initWithFrame:frame collectionViewLayout:[SMXMonthCollectionViewFlowLayout new]];

    if (self) {
        // Initialization code

        [self setDataSource:self];
        [self setDelegate:self];

        [self setBackgroundColor:[UIColor lightGrayCustom]];

        [self registerClass:[SMXMonthCell class] forCellWithReuseIdentifier:REUSE_IDENTIFIER_MONTH_CELL];
        
        [self setScrollEnabled:YES];
        [self setPagingEnabled:YES];
        
        [self setShowsVerticalScrollIndicator:NO];
        
        array = @[[NSMutableArray new], [NSMutableArray new], [NSMutableArray new]];
        arraySizeOfCells = [[NSMutableArray alloc] initWithObjects:[NSValue valueWithCGSize:CGSizeZero], [NSValue valueWithCGSize:CGSizeZero], [NSValue valueWithCGSize:CGSizeZero], nil];
        arrayWithFirstDay = [[NSMutableArray alloc] initWithObjects:[NSDate new], [NSDate new], [NSDate new], nil];
    }
    self.bounces=NO;
    return self;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSMutableArray *arrayDates = [array objectAtIndex:section];
    [arrayDates removeAllObjects];
    
    NSDateComponents *compDateManeger = [NSDate componentsOfDate:[[SMXDateManager sharedManager] currentDate]];
    compDateManeger.month += (section-1);
    NSDate *dateFirstDayOfMonth = [NSDate dateWithYear:compDateManeger.year month:compDateManeger.month day:1];
    [arrayWithFirstDay replaceObjectAtIndex:section withObject:dateFirstDayOfMonth];
    NSDateComponents *componentsFirstDayOfMonth = [NSDate componentsOfDate:dateFirstDayOfMonth];
    
//    NSLog(@"Weekday:%i", componentsFirstDayOfMonth.weekday);
    
    int lastDayMonth = [dateFirstDayOfMonth numberOfDaysInMonthCount];
    int numOfCellsInCollection = [dateFirstDayOfMonth numberOfWeekInMonthCount]*7;
    
    for (int i=1-(componentsFirstDayOfMonth.weekday-1),j=numOfCellsInCollection-(componentsFirstDayOfMonth.weekday-1); i<=j; i++) {
        
        if (i >= 1 && i <= lastDayMonth){
            [arrayDates addObject:[NSDate dateWithYear:compDateManeger.year month:compDateManeger.month day:i]];
        } else {
            [arrayDates addObject:[NSNull null]];
        }
    }
    CGSize sizeOfCells;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        if ([dateFirstDayOfMonth numberOfWeekInMonthCount]==6) {
            sizeOfCells =  CGSizeMake((self.frame.size.width-7*SPACE_COLLECTIONVIEW_CELL)/7,
                                      (self.frame.size.height-([dateFirstDayOfMonth numberOfWeekInMonthCount]-.2)*SPACE_COLLECTIONVIEW_CELL)/[dateFirstDayOfMonth numberOfWeekInMonthCount]);
        }else if ([dateFirstDayOfMonth numberOfWeekInMonthCount]==5) {
            sizeOfCells =  CGSizeMake((self.frame.size.width-7*SPACE_COLLECTIONVIEW_CELL)/7,
                                      (self.frame.size.height-([dateFirstDayOfMonth numberOfWeekInMonthCount]-.2)*SPACE_COLLECTIONVIEW_CELL)/[dateFirstDayOfMonth numberOfWeekInMonthCount]);
            //1 pixel extra is coming for in between cell, so i am reducing pixel from cell
            //self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height-1.0f);
        }else{
            sizeOfCells =  CGSizeMake((self.frame.size.width-7*SPACE_COLLECTIONVIEW_CELL)/7,
                                      (self.frame.size.height-([dateFirstDayOfMonth numberOfWeekInMonthCount]-1)*SPACE_COLLECTIONVIEW_CELL)/[dateFirstDayOfMonth numberOfWeekInMonthCount]);
        }
    }else{
        if ([dateFirstDayOfMonth numberOfWeekInMonthCount]==6) {
            sizeOfCells =  CGSizeMake((self.frame.size.width-6*SPACE_COLLECTIONVIEW_CELL)/7,109.);
        }else{
            sizeOfCells =  CGSizeMake((self.frame.size.width-6*SPACE_COLLECTIONVIEW_CELL)/7,
                                      (self.frame.size.height-([dateFirstDayOfMonth numberOfWeekInMonthCount]-1)*SPACE_COLLECTIONVIEW_CELL)/[dateFirstDayOfMonth numberOfWeekInMonthCount]);
        }
    }
    
    [arraySizeOfCells replaceObjectAtIndex:section withObject:[NSValue valueWithCGSize:sizeOfCells]];
    
    return [arrayDates count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray *arrayDates = [array objectAtIndex:indexPath.section];
    
    SMXMonthCell *cell = (SMXMonthCell *)[collectionView dequeueReusableCellWithReuseIdentifier:REUSE_IDENTIFIER_MONTH_CELL forIndexPath:indexPath];
    [cell initLayout];
    [cell setProtocol:self];
    
    if (indexPath.row % 7 == 0 || (indexPath.row + 1) % 7 == 0) {
        //[cell markAsWeekend];
    }
    
    id obj = [arrayDates objectAtIndex:indexPath.row];
    if (obj != [NSNull null]) {
        
        NSDate *date = (NSDate *)obj;
        NSDateComponents *components = [NSDate componentsOfDate:date];
        cell.cellDate=date;
        [cell setArrayEvents:[dictEvents objectForKey:date]];
        if (indexPath.row % 7 == 0 || (indexPath.row + 1) % 7 == 0) {
            [cell.labelDay setTextColor:[UIColor colorWithHexString:@"797979"]];
        }
        if ([components day]==1) {
            [cell.labelDay setTextColor:[UIColor colorWithHexString:@"434343"]];
            [cell firstDayOfTheMonth];
            [cell.labelDay setText:[NSString stringWithFormat:@"%@ %i",[arrayMonthNameAbrev objectAtIndex:[components month]-1], [components day]]];
            [cell setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0f]];
        }else{
            [cell.labelDay setText:[NSString stringWithFormat:@"%i", [components day]]];
            [cell setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f]];
        }
        if ([NSDate isTheSameDateTheCompA:components compB:[NSDate componentsOfCurrentDate]]) {
            [cell markAsCurrentDay];
        }
        [cell enableJumpToday:cell.frame];
        //cell.cellButton.userInteractionEnabled=YES;
        //cell.cellButton.backgroundColor=[UIColor yellowColor];
    }
    return cell;
}
- (NSString *) leftButtonTextChangeWith:(NSDate *) date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMdd";
    dateFormatter.dateFormat=@"MMMM";
   // NSString * monthString = [[dateFormatter stringFromDate:date] capitalizedString];
    return  [[dateFormatter stringFromDate:date] capitalizedString];
}
#pragma mark - UICollectionView Delegate FlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [[arraySizeOfCells objectAtIndex:indexPath.section] CGSizeValue];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    CGSize headerViewSize = CGSizeMake(self.frame.size.width, SPACE_COLLECTIONVIEW_CELL);
    
    return headerViewSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return SPACE_COLLECTIONVIEW_CELL;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return SPACE_COLLECTIONVIEW_CELL;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    lastContentOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    ScrollDirection scrollDirection;
    if (lastContentOffset > scrollView.contentOffset.y) {
        [self changeYearDirectionIsUp:NO];
    } else if (lastContentOffset < scrollView.contentOffset.y) {
        [self changeYearDirectionIsUp:YES];
    } else {
        scrollDirection = ScrollDirectionNone;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DATE_MONTH_TEXT_NOTIFICATION object:[[SMXDateManager sharedManager] currentDate]];
}

#pragma mark - Other Methods

- (void)changeYearDirectionIsUp:(BOOL)isUp {
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:isUp?1:-1];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:[arrayWithFirstDay objectAtIndex:1] options:0];
    //here we are facing time zone problem, so i am starting with secont day of the month, so first i am finding difference
    [[SMXDateManager sharedManager] setCurrentDate:[newDate dateByAddingTimeInterval:[DateUtil toLocalTime:newDate]]];
}

#pragma mark - SMXMonthCell Protocol

- (void)saveEditedEvent:(SMXEvent *)eventNew ofCell:(UICollectionViewCell *)cell atIndex:(NSInteger)intIndex {
    
    NSDate *dateNew = eventNew.ActivityDateDay;
    
    NSMutableArray *arrayNew = [dictEvents objectForKey:dateNew];
    if (!arrayNew) {
        arrayNew = [NSMutableArray new];
        [dictEvents setObject:arrayNew forKey:dateNew];
    }
    [arrayNew addObject:eventNew];
}

- (void)deleteEventOfCell:(UICollectionViewCell *)cell atIndex:(NSInteger)intIndex {
    
    NSMutableArray *arrayDates = [array objectAtIndex:[self indexPathForCell:cell].section];
    
    NSIndexPath *index = [self indexPathForCell:cell];
    NSDate *date = [arrayDates objectAtIndex:index.row];
    NSMutableArray *arrayDict = [dictEvents objectForKey:date];
    [arrayDict removeObjectAtIndex:intIndex];
    if (arrayDict.count == 0) {
        [dictEvents removeObjectForKey:date];
    }
    
    if (protocol != nil && [protocol respondsToSelector:@selector(setNewDictionary:)]) {
        [protocol setNewDictionary:dictEvents];
    } else {
        [self reloadData];
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
