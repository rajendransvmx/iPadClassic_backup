//
//  SMXWeekHeaderCollectionView.h
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

@protocol SMXWeekHeaderCollectionViewProtocol <NSObject>
@required
- (void)headerDidScroll;
- (void)showHourLine:(BOOL)show;
@end

@interface SMXWeekHeaderCollectionView : UICollectionView

@property id<SMXWeekHeaderCollectionViewProtocol> protocol;

@end
