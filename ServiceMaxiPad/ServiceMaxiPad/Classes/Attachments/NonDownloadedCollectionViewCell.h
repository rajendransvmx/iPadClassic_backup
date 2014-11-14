//
//  NonDownloadedCollectionViewCell.h
//  ServiceMaxiPad
//
//  Created by Niraj Kumar on 11/6/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttachmentTXModel.h"

@interface NonDownloadedCollectionViewCell : UICollectionViewCell

@property(nonatomic,strong)IBOutlet UILabel *fileNameLabel;
@property(nonatomic,strong)IBOutlet UILabel *fileSizeLabel;
@property(nonatomic,strong)IBOutlet UIImageView *cloudImageView;
@property(nonatomic,strong)IBOutlet UIProgressView *progressView;

- (void)configureNonDownloadedCell:(AttachmentTXModel*)attachmentModel
                        isEditMode:(BOOL)isEditEnabled;

@end
