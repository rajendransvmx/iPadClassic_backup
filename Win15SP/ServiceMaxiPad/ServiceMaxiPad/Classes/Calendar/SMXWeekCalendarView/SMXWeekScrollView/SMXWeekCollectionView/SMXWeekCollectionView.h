//
//  SMXWeekCollectionView.h
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

@protocol SMXWeekCollectionViewProtocol <NSObject>
@required
- (void)collectionViewDidScroll;
- (void)showHourLine:(BOOL)show;
- (void)setNewDictionary:(NSDictionary *)dict;
@end

@interface SMXWeekCollectionView : UICollectionView

@property (nonatomic, assign) id<SMXWeekCollectionViewProtocol> protocol;
@property (nonatomic, strong) NSMutableDictionary *dictEvents;

@end
