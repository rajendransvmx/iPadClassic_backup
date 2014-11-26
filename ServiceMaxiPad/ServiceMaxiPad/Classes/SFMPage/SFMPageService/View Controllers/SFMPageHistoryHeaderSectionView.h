//
//  SFMPageHistoryHeaderView.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 16/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFMPageHistoryHeaderSectionView : UIView

@property(nonatomic,strong) UILabel *leftTitle;
@property(nonatomic,strong) UILabel *rightTitle;

- (void)setTitleTextForLabel;

@end
