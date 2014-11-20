//
//  NonDownloadedCollectionViewCell.h
//  ServiceMaxiPad
//
//  Created by Anoop on 11/6/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttachmentTXModel.h"

@interface ErrorDownloadedCollectionViewCell : UICollectionViewCell

@property(nonatomic,weak)IBOutlet UILabel *errorLabel;
@property(nonatomic,weak)IBOutlet UILabel *fileNameLabel;
@property(nonatomic,weak)IBOutlet UILabel *fileSizeLabel;
@property(nonatomic,weak)IBOutlet UIImageView *cloudImageView;

-(void)configureErrorCell:(AttachmentTXModel*)attachmentModel
               isEditMode:(BOOL)isEditEnabled;

@end
