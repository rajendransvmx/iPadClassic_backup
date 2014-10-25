//
//  SMXDayScrollView.m
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


#import "SMXDayScrollView.h"

#import "SMXViewWithHourLines.h"
#import "SMXImportantFilesForCalendar.h"

@interface SMXDayScrollView ()
@end

@implementation SMXDayScrollView

#pragma mark - Synthesize

@synthesize dictEvents;
@synthesize collectionViewDay;
@synthesize labelWithActualHour;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
//        [self setAutoresizingMask:AR_WIDTH_HEIGHT | UIViewAutoresizingFlexibleRightMargin];
        
        [self setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
//        self.layer.zPosition = 1.0;

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
    
    if (!collectionViewDay) {
        
        SMXViewWithHourLines *viewWithHourLines = [[SMXViewWithHourLines alloc] initWithFrame:CGRectZero];
        
        collectionViewDay = [[SMXDayCollectionView alloc] initWithFrame:CGRectMake(10.,0.,self.frame.size.width-10,viewWithHourLines.totalHeight+HEIGHT_CELL_HOUR)collectionViewLayout:[UICollectionViewFlowLayout new]];
        [collectionViewDay scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[NSDate componentsOfDate:[[SMXDateManager sharedManager] currentDate]].day-1+7 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        [self addSubview:collectionViewDay];
        
        labelWithActualHour = [viewWithHourLines labelWithCurrentHourWithWidth:self.frame.size.width];
        [labelWithActualHour setFrame:CGRectMake(labelWithActualHour.frame.origin.x, labelWithActualHour.frame.origin.y+viewWithHourLines.frame.origin.y, labelWithActualHour.frame.size.width, labelWithActualHour.frame.size.height)];
        
        [self setContentSize:CGSizeMake(self.frame.size.width, collectionViewDay.frame.origin.y+collectionViewDay.frame.size.height + 10)];
        [self scrollRectToVisible:CGRectMake(0, labelWithActualHour.frame.origin.y, self.frame.size.width, self.frame.size.height) animated:NO];
    }
    
    [collectionViewDay setDictEvents:dictEvents];
    [collectionViewDay reloadData];
}

@end
