//
//  SMXDayCollectionViewFlowLayout.m
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


#import "SMXDayCollectionViewFlowLayout.h"

#import "SMXImportantFilesForCalendar.h"

@implementation SMXDayCollectionViewFlowLayout

- (id)init {
    
    self = [super init];
    
    if (self) {
        [self setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    }
    return self;
}


- (CGSize)collectionViewContentSize {
    
    return CGSizeMake(7*([[[SMXDateManager sharedManager] currentDate] numberOfWeekInMonthCount]+2)*self.collectionView.frame.size.width, self.collectionView.frame.size.height);
}

@end
