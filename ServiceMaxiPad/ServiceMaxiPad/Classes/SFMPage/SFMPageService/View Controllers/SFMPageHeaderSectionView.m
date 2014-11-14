//
//  SFMPageViewSection.m
//  ServiceMaxMobile
//
//  Created by Aparna on 02/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageHeaderSectionView.h"

@interface SFMPageHeaderSectionView ()

@property(nonatomic, retain) UIImageView *lineSeparator;

@end

@implementation SFMPageHeaderSectionView

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self initializeSubViews];
//    }
//    return self;
//}
//

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self= [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeSubViews];
    }
    return self;
}


- (void) initializeSubViews
{
    _rightButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_rightButton addTarget:self action:@selector(tappedOnButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_rightButton];
    _sectionTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_sectionTitle];
    _rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    _lineSeparator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timing-line.png"]];
    [self.contentView addSubview:_lineSeparator];

}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect containerFrame = self.contentView.frame;
    self.sectionTitle.frame = CGRectMake(15, containerFrame.origin.y, containerFrame.size.width/2+15, containerFrame.size.height);
    self.rightButton.frame = CGRectMake(CGRectGetMidX(self.bounds)+30, containerFrame.origin.y, containerFrame.size.width/2-40, containerFrame.size.height);
    
    self.lineSeparator.frame = CGRectMake(0, CGRectGetMaxY(self.bounds)-1, containerFrame.size.width, 1);
    self.sectionTitle.backgroundColor = [UIColor clearColor];
    self.rightButton.backgroundColor = [UIColor clearColor];

}


- (void) tappedOnButton:(id) sender
{
    if ([self.delegate respondsToSelector:@selector(tappedOnButton:withIndex:)]) {
        [self.delegate tappedOnButton:sender withIndex:self.index];
    }
}
@end

