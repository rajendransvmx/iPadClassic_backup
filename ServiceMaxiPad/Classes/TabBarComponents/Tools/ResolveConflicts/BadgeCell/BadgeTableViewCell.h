//
//  BadgeTableViewCell.h
//
//  Created by Pushpak on 28/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BadgeLabel.h"

@interface BadgeTableViewCell : UITableViewCell

@property (strong, nonatomic) BadgeLabel *badge;
@property (nonatomic) NSInteger badgeNumber;

@end
