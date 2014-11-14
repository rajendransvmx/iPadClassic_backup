//
//  SFMPageViewSection.h
//  ServiceMaxMobile
//
//  Created by Aparna on 02/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFMPageHeaderSectionViewDelegate <NSObject>

- (void) tappedOnButton:(id)sender withIndex:(NSUInteger)index;

@end


@interface SFMPageHeaderSectionView : UITableViewHeaderFooterView

@property(nonatomic, strong) UIButton *rightButton;
@property(nonatomic, strong) UILabel *sectionTitle;
@property(nonatomic, assign) NSUInteger index;
@property(nonatomic, assign) id<SFMPageHeaderSectionViewDelegate> delegate;


@end
