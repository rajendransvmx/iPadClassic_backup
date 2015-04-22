//
//  ChatterSectionView.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 16/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatterTextFieldDelegate.h"

@interface ChatterSectionView : UIView <UITextFieldDelegate>

@property (nonatomic, weak) id <ChatterTextFieldDelegate> sectionTextFieldDelegate;

- (id)initWithFrame:(CGRect)frame;

@end
