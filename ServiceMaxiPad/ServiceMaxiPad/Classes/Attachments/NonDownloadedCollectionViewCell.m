//
//  NonDownloadedCollectionViewCell.m
//  ServiceMaxiPad
//
//  Created by Niraj Kumar on 11/6/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "NonDownloadedCollectionViewCell.h"
#import "StyleManager.h"
#import "SNetworkReachabilityManager.h"
#import "AttachmentUtility.h"
#import "AttachmentsDownloadManager.h"

@implementation NonDownloadedCollectionViewCell

- (void)configureNonDownloadedCell:(AttachmentTXModel*)attachmentModel
                        isEditMode:(BOOL)isEditEnabled
{
    _fileNameLabel.text = attachmentModel.name;
    NSString *fileSizeInUnits = [NSString stringWithFormat:@"%.2f %@",
                                 [AttachmentUtility calculateFileSizeInUnit:(unsigned long long)attachmentModel.bodyLength],
                                 [AttachmentUtility calculateUnit:(unsigned long long)attachmentModel.bodyLength]];
    _fileSizeLabel.text = fileSizeInUnits;
    NSDictionary *downloadInfo = [[AttachmentsDownloadManager sharedManager].downloadingDictionary objectForKey:attachmentModel.localId];
    _progressView.hidden = ![downloadInfo allKeys];
    
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable] && !isEditEnabled)
    {
        [self configureNonDownloadedOnline:attachmentModel];
    }
    else
    {
        [self configureNonDownloadedOffline:attachmentModel];
    }

    if (!_progressView.hidden) {
        [_progressView setProgress:[[downloadInfo valueForKey:kDocumentsDownloadKeyProgress] floatValue] animated:YES];
        _fileSizeLabel.text = [downloadInfo valueForKey:kDocumentsDownloadKeyDetails];
    }
}

- (void)configureNonDownloadedOffline:(AttachmentTXModel *)attachmentTXModel
{
    _cloudImageView.image = [UIImage imageNamed:@"Attachment-DownloadFileOffline"];
    [_fileNameLabel setTextColor:[UIColor colorWithHexString:@"#9A9A9B"]];
    [_fileSizeLabel setTextColor:[UIColor colorWithHexString:@"#9A9A9B"]];
    [_progressView setHidden:YES];
}

- (void)configureNonDownloadedOnline:(AttachmentTXModel *)attachmentTXModel
{
    _cloudImageView.image = [UIImage imageNamed:@"Attachment-FileinCloud"];
    [_fileNameLabel setTextColor:[UIColor colorWithHexString:@"#157DFB"]];
    [_fileSizeLabel setTextColor:[UIColor colorWithHexString:@"#157DFB"]];
    [_progressView setProgressTintColor:[UIColor colorWithHexString:@"#157DFB"]];
}

@end
