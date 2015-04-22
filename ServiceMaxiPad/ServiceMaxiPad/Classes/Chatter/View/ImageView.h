//
//  ImageView.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 30/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageView : UIImageView

@property(nonatomic, strong)NSString *userId;
@property(nonatomic, strong)NSString *photoUrl;
@property(nonatomic, strong)NSIndexPath *path;

- (void)loadImage;

@end
