//
//  SFMPageUrlFieldCollectionViewCell.h
//  ServiceMaxiPad
//
//  Created by Apple on 03/07/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditMenuLabel.h"

@interface SFMPageUrlFieldCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong) UILabel *fieldName;
@property(nonatomic, strong) EditMenuLabel *fieldValue;
@property(nonatomic, strong) UIButton *moreButton;
@property(nonatomic, strong) UIImageView *fadeOutImageView;
@property(nonatomic, strong) NSString *fieldApiName;
@property(nonatomic)BOOL isShowMoreButton;
@property(nonatomic,strong) UIButton *hyperLinkButton;

-(void)resetLayout;
@end
