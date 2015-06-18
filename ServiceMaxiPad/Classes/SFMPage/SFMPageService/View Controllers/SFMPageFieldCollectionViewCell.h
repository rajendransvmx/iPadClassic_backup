//
//  SFMPageFieldCell.h
//  ServiceMaxMobile
//
//  Created by Aparna on 10/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditMenuLabel.h"

@interface SFMPageFieldCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong) UILabel *fieldName;

/* Updated _fieldValue UIlabel to fix defect 014039 */
@property(nonatomic, strong) EditMenuLabel *fieldValue;

@property(nonatomic, strong) UIButton *moreButton;
@property(nonatomic, strong) UIImageView *fadeOutImageView;
@property(nonatomic, strong) NSString *fieldApiName;
@property(nonatomic)BOOL isShowMoreButton;

-(void)resetLayout;

@end
