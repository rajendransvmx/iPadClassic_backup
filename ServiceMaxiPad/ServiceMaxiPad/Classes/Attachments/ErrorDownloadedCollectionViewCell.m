//
//  NonDownloadedCollectionViewCell.m
//  ServiceMaxiPad
//
//  Created by Anoop on 11/6/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ErrorDownloadedCollectionViewCell.h"
#import "StyleManager.h"
#import "SNetworkReachabilityManager.h"
#import "SVMXSystemConstant.h"
#import "AttachmentUtility.h"

@implementation ErrorDownloadedCollectionViewCell

- (void)configureErrorCell:(AttachmentTXModel*)attachmentModel
                isEditMode:(BOOL)isEditEnabled
{
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable] && !isEditEnabled)
    {
        [self configureErrorOnline:attachmentModel];
    }
    else
    {
        [self configureErrorOffline:attachmentModel];
    }
    self.fileNameLabel.text = attachmentModel.nameWithoutExtension;
    self.errorLabel.text = [SVMXSystemConstant restAPIErrorMessageByErrorCode:(int)attachmentModel.errorCode];
    NSString *fileSizeInUnits = [NSString stringWithFormat:@"%.2f %@",
                                 [AttachmentUtility calculateFileSizeInUnit:(unsigned long long)attachmentModel.bodyLength],
                                 [AttachmentUtility calculateUnit:(unsigned long long)attachmentModel.bodyLength]];
    self.fileSizeLabel.text = fileSizeInUnits;
}

- (void)configureErrorOffline:(AttachmentTXModel *)attachmentTXModel
{
    self.cloudImageView.image = [UIImage imageNamed:@"Attachment-File-Missing"];
    [self.fileNameLabel setTextColor:[UIColor colorWithHexString:@"#9A9A9B"]];
    [self.fileSizeLabel setTextColor:[UIColor colorWithHexString:@"#9A9A9B"]];
    [self.errorLabel setTextColor:[UIColor colorWithHexString:@"#9A9A9B"]];
}

- (void)configureErrorOnline:(AttachmentTXModel *)attachmentTXModel
{
    self.cloudImageView.image = [UIImage imageNamed:@"Attachment-File-Missing"];
    [self.fileNameLabel setTextColor:[UIColor colorWithHexString:@"#157DFB"]];
    [self.fileSizeLabel setTextColor:[UIColor colorWithHexString:@"#157DFB"]];
    [self.errorLabel setTextColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:1]];
}

@end
