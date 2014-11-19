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
    _dateLabel.text = attachmentModel.displayDateString;
    _displayImageView.image = attachmentModel.thumbnailImage;
    _videoIconImageView.hidden = !attachmentModel.isVideo;
    if (!isEditEnabled)
    {
        _checkmarkImageView.hidden = YES;
        _checkmarkImageView.image = [UIImage imageNamed:@"Attachment-SelectionCheckempty"];
    }
    else
    {
        _checkmarkImageView.hidden = NO;
    }

}

@end
