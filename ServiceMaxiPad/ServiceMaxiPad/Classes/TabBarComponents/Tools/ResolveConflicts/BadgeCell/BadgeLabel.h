//
//  BadgeLabel.h
//
//  Created by Pushpak on 28/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface BadgeLabel : UILabel
/*
 * Just in case if they change design to incorporate border.
 */
@property (nonatomic) BOOL hasBorder;
/*
 * Just in case if they change design to incorporate shadow.
 */
@property (nonatomic) BOOL hasShadow;
/*
 * Just in case if they change design to incorporate gloss.
 */
@property (nonatomic) BOOL hasGloss;
/*
 * Minimum.
 */
@property (nonatomic) CGFloat minWidth;

@end
