//
//  SMXDayHeaderCollectionView.h
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

@protocol SMXDayHeaderCollectionViewProtocol <NSObject>
@required
- (void)daySelected:(NSDate *)date;
@end

@interface SMXDayHeaderCollectionView : UICollectionView

@property (nonatomic, assign) id<SMXDayHeaderCollectionViewProtocol> protocol;

- (void)scrollToDate:(NSDate *)date;

@end
