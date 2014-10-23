//
//  SMXDayScrollView.h
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

#import "SMXDayCollectionView.h"

@interface SMXDayScrollView : UIScrollView 

@property (nonatomic, strong) NSMutableDictionary *dictEvents;
@property (nonatomic, strong) SMXDayCollectionView *collectionViewDay;
@property (nonatomic, strong) UILabel *labelWithActualHour;

@end
