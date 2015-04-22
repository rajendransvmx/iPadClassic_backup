//
//  SFMPageFieldCell.h
//  ServiceMaxMobile
//
//  Created by Aparna on 10/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFMPageFieldCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong) UILabel *fieldName;
@property(nonatomic, strong) UILabel *fieldValue;
@property(nonatomic, strong) UIButton *moreButton;
@property(nonatomic, strong) UIImageView *fadeOutImageView;
@property(nonatomic, strong) NSString *fieldApiName;
@property(nonatomic)BOOL isShowMoreButton;

-(void)resetLayout;

@end
