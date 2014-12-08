//
//  DownloadedCollectionViewCell.m
//  ServiceMaxiPad
//
//  Created by Niraj Kumar on 11/6/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "DownloadedCollectionViewCell.h"
#import "StyleManager.h"

@implementation DownloadedCollectionViewCell

- (void)configureDownloadedCell:(AttachmentTXModel*)attachmentModel
                     isEditMode:(BOOL)isEditEnabled
{
    self.dateLabel.text = attachmentModel.displayDateString;
    self.displayImageView.image = attachmentModel.thumbnailImage;
    self.videoIconImageView.hidden = !attachmentModel.isVideo;
    if (!isEditEnabled)
    {
        self.checkmarkImageView.hidden = YES;
        self.checkmarkImageView.image = [UIImage imageNamed:@"Attachment-SelectionCheckempty"];
    }
    else
    {
        if (attachmentModel.isSelected)
        {
          self.checkmarkImageView.image = [UIImage imageNamed:@"Attachment-SelectionCheckfilled"];
            
        }
        else
        {
          self.checkmarkImageView.image = [UIImage imageNamed:@"Attachment-SelectionCheckempty"];
        }
        self.checkmarkImageView.hidden = NO;
    }

}

@end
