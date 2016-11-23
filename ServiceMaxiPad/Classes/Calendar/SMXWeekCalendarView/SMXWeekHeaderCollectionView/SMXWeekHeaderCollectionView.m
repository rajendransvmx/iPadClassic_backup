//
//  SMXWeekHeaderCollectionView.m
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

#import "SMXWeekHeaderCollectionView.h"

#import "SMXWeekHeaderCell.h"
#import "SMXWeekCollectionViewFlowLayout.h"
#import "SMXImportantFilesForCalendar.h"
#import "StyleManager.h"
#import "SMXCalendarViewController.h"

@interface SMXWeekHeaderCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic) CGFloat lastContentOffset;
@property (nonatomic) BOOL boolGoPrevious;
@property (nonatomic) BOOL boolGoNext;
@end

@implementation SMXWeekHeaderCollectionView

@synthesize lastContentOffset;
@synthesize protocol;
@synthesize boolGoPrevious;
@synthesize boolGoNext;
static int firstdayOfTheWeek;

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
        [self setBackgroundColor:[UIColor whiteColor]];
        [self registerClass:[SMXWeekHeaderCell class] forCellWithReuseIdentifier:REUSE_IDENTIFIER_MONTH_CELL];
        [self setScrollEnabled:YES];
        [self setPagingEnabled:YES];
        boolGoNext = NO;
        boolGoPrevious = NO;
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    }
    return self;
}
-(UIImageView *)grayLine:(CGRect )rect{
    UIImageView *grayLine=[[UIImageView alloc] initWithFrame:rect];
    grayLine.backgroundColor=[UIColor grayColor];
    return grayLine;
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
    
    int intDay = (int)(7*([[[SMXDateManager sharedManager] currentDate] numberOfWeekInMonthCount]+2));
    
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
    
    SMXWeekHeaderCell *cell = (SMXWeekHeaderCell *)[collectionView dequeueReusableCellWithReuseIdentifier:REUSE_IDENTIFIER_MONTH_CELL forIndexPath:indexPath];
    [cell cleanCell];
    cell.date = dateOfLabel;
    cell.label.font=[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
    [cell.label setTextColor:[UIColor getUIColorFromHexValue:@"434343"]];
    [cell.label setText:[NSString stringWithFormat:@"%@", [arrayWeekAbrevWithThreeChars objectAtIndex:compDateOfLabel.weekday-1]]];
    
    [cell.label setAttributedText:[self getStringHighlighted:[NSString stringWithFormat:@"%@", [arrayWeekAbrevWithThreeChars objectAtIndex:compDateOfLabel.weekday-1]] date:[NSString stringWithFormat:@"%li",(long)compDateOfLabel.day]]];
   // [cell.dateLabel setText:[NSString stringWithFormat:@"%i",compDateOfLabel.day]];
    
    if (compDateOfLabel.weekday == 1) {
        [cell.label setTextColor:[UIColor getUIColorFromHexValue:@"797979"]];
        firstdayOfTheWeek=(int)compDateOfLabel.day;
    }else if(compDateOfLabel.weekday == 7){
        [cell.label setTextColor:[UIColor getUIColorFromHexValue:@"797979"]];
    }
    
    if ([NSDate isTheSameDateTheCompA:compDateOfLabel compB:[NSDate componentsOfCurrentDate]]) {
        [cell.label setTextColor:[UIColor getUIColorFromHexValue:@"e15001"]];
        //[cell.dateLabel setTextColor:[UIColor smxOrangeColor]];
    }
    return cell;
}
-(NSAttributedString *)getStringHighlighted:(NSString *)month date:(NSString *)date{
    if (month==nil && date==nil) {
        return [[NSAttributedString alloc] init];
    }
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",month,date]];
    NSInteger _stringLength=[month length];
    NSDictionary *attrDict = @{
                               NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:30.0],
                               };
    [attString addAttributes:attrDict range:NSMakeRange(_stringLength+1,[date length])];
    NSDictionary *attrDict1 = @{
                               NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0],
                               };
    [attString addAttributes:attrDict1 range:NSMakeRange(_stringLength,1)];
    return attString;
}
#pragma mark - UICollectionView Delegate FlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake((self.frame.size.width)/7, self.frame.size.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (protocol != nil && [protocol respondsToSelector:@selector(headerDidScroll)]) {
        [protocol headerDidScroll];
    }
    
    if (!boolGoPrevious && scrollView.contentOffset.x < 0) {
        boolGoPrevious = YES;
    }
    
    if (!boolGoNext && scrollView.contentOffset.x >  ([[[SMXDateManager sharedManager] currentDate] numberOfWeekInMonthCount]-1)*scrollView.frame.size.width) {
        boolGoNext = YES;
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
    boolGoPrevious = NO;
    boolGoNext = NO;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//-(void)scrollViewd
@end
