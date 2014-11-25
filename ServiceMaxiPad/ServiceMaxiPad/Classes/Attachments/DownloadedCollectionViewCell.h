//
//  DownloadedCollectionViewCell.h
//  ServiceMaxiPad
//
//  Created by Niraj Kumar on 11/6/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttachmentTXModel.h"

@interface DownloadedCollectionViewCell : UICollectionViewCell

@property(nonatomic, weak)IBOutlet UILabel *dateLabel;
@property(nonatomic, weak)IBOutlet UIImageView *displayImageView;
@property(nonatomic, weak)IBOutlet UIImageView *videoIconImageView;
@property(nonatomic, weak)IBOutlet UIImageView *bottomBarImageView;
@property(nonatomic, weak)IBOutlet UIImageView *checkmarkImageView;

- (void)configureDownloadedCell:(AttachmentTXModel*)attachmentModel
                     isEditMode:(BOOL)isEditEnabled;

@end
