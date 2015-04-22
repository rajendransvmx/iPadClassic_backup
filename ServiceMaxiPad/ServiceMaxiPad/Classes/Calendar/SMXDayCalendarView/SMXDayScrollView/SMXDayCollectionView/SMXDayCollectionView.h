//
//  SMXDayCollectionView.h
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

#import "SMXDayCell.h"

@protocol SMXDayCollectionViewProtocol <NSObject>
- (void)updateHeader;
@end

@interface SMXDayCollectionView : UICollectionView

@property (nonatomic, strong) id<SMXDayCollectionViewProtocol> protocol;
@property (nonatomic, strong) NSMutableDictionary *dictEvents;

@end
