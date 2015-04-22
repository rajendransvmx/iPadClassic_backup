//
//  SMXWeekScrollView.h
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

#import <UIKit/UIKit.h>

#import "SMXWeekCollectionView.h"

@interface SMXWeekScrollView : UIScrollView

@property (nonatomic, strong) NSMutableDictionary *dictEvents;
@property (nonatomic, strong) SMXWeekCollectionView *collectionViewWeek;
@property (nonatomic, strong) UILabel *labelWithActualHour;
@property (nonatomic, strong) UILabel *labelGrayWithActualHour;
@property (nonatomic, strong) UIImageView *currentPatch;
@property (nonatomic, assign) id weekCalendarDelegate;
-(void)updateWithCurrentTime;

@end
