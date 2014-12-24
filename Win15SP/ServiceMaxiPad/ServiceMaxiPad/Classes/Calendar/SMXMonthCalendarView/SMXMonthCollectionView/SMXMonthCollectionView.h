//
//  SMXMonthCollectionView.h
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

@protocol SMXMonthCollectionViewProtocol <NSObject>
@required
- (void)setNewDictionary:(NSDictionary *)dict;
@end

@interface SMXMonthCollectionView : UICollectionView

@property (nonatomic, assign) id<SMXMonthCollectionViewProtocol>protocol;
@property (nonatomic, strong) NSMutableDictionary *dictEvents;
@property (nonatomic) CGFloat lastContentOffset;

@end
