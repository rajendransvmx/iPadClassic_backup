//
//  BadgeTableViewCell.h
//
//  Created by Pushpak on 28/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeLabel.h"
#import "NoDynamicTypeTableViewCell.h"

@interface BadgeTableViewCell : NoDynamicTypeTableViewCell

@property (strong, nonatomic) BadgeLabel *badge;
@property (nonatomic) NSInteger badgeNumber;

@end
