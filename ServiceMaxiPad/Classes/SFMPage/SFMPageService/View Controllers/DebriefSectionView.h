//
//  DebriefSectionView.h
//  ServiceMaxMobile
//
//  Created by Sahana on 12/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiPageFieldView.h"

@protocol DebriefSectionViewDelegate;


@interface DebriefSectionView : UITableViewHeaderFooterView

@property(nonatomic)NSInteger section;
@property(nonatomic, assign) id<DebriefSectionViewDelegate>  delegate;
@property (strong, nonatomic) UIImageView *expandImg;
@property (strong, nonatomic) UILabel *sectionLabel;
@property (nonatomic, assign)   UIView *topBorder;

@property(nonatomic, strong) UIView *detailView;
@property (nonatomic,strong) MultiPageFieldView *pageFieldView;
@property(nonatomic)BOOL isExpanded;

@property(nonatomic)NSInteger sectionRecords;

-(void)setExpandImage:(BOOL)expand;
-(void)addGesture;

- (void)setDetailLabelText;

- (void)setNoDataLabelText:(NSString *)lineItem;

@end

@protocol DebriefSectionViewDelegate <NSObject>

@required
-(void)sectionTapped:(DebriefSectionView *)debriefView;
-(void)detailTapped:(DebriefSectionView *)dbriefView;

@end


#define BorderLeftGap  30