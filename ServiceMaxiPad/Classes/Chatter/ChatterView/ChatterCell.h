//
//  ChatterCell.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 16/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatterFeedComments.h"
#import "ChatterFeedPost.h"
#import "ImageView.h"


@interface ChatterCell : UITableViewCell

@property(nonatomic, strong)NSString *userId;
@property(nonatomic, strong)NSString *photoUrl;
@property(nonatomic, strong)NSIndexPath *path;

@property (weak, nonatomic) IBOutlet UILabel *chatText;
@property (weak, nonatomic) IBOutlet ImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *time;


- (void)updateCellView:(ChatterFeedComments *)comments;
- (void)updateUserImage;

@end
