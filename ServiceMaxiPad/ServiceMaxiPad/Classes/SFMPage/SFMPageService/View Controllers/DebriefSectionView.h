//
//  DebriefSectionView.h
//  ServiceMaxMobile
//
//  Created by Sahana on 12/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DebriefSectionViewDelegate;


@interface DebriefSectionView : UITableViewHeaderFooterView

@property(nonatomic)NSInteger section;
@property(nonatomic, assign) id<DebriefSectionViewDelegate>  delegate;
@property (retain, nonatomic) UIImageView *expandImg;
@property (retain, nonatomic) UILabel *sectionLabel;
@property (nonatomic, assign)   UIView *topBorder;

-(void)setExpandImage:(BOOL)expand;
-(void)addGesture;


@end


@protocol DebriefSectionViewDelegate <NSObject>

@required
-(void)sectionTapped:(DebriefSectionView *)debriefView;

@end


#define BorderLeftGap  30