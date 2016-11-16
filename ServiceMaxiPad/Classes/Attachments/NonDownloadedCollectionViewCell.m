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
    self.fileNameLabel.text = attachmentModel.name;
    NSString *fileSizeInUnits = [NSString stringWithFormat:@"%.2f %@",
                                 [AttachmentUtility getFileSizeInSizeUnit:(unsigned long long)attachmentModel.bodyLength],
                                 [AttachmentUtility getFileSizeUnit:(unsigned long long)attachmentModel.bodyLength]];
    self.fileSizeLabel.text = fileSizeInUnits;
    NSDictionary *downloadInfo = [[AttachmentsDownloadManager sharedManager].downloadingDictionary objectForKey:attachmentModel.localId];
    self.progressView.hidden = ![downloadInfo allKeys];
    
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable] && !isEditEnabled)
    {
        [self configureNonDownloadedOnline:attachmentModel];
    }
    else
    {
        [self configureNonDownloadedOffline:attachmentModel];
    }

    if (!self.progressView.hidden) {
        [self.progressView setProgress:[[downloadInfo valueForKey:kDocumentsDownloadKeyProgress] floatValue] animated:YES];
        self.fileSizeLabel.text = [downloadInfo valueForKey:kDocumentsDownloadKeyDetails];
    }
}

- (void)configureNonDownloadedOffline:(AttachmentTXModel *)attachmentTXModel
{
    self.cloudImageView.image = [UIImage imageNamed:@"Attachment-DownloadFileOffline"];
    [self.fileNameLabel setTextColor:[UIColor colorFromHexString:@"#9A9A9B"]];
    [self.fileSizeLabel setTextColor:[UIColor colorFromHexString:@"#9A9A9B"]];
    [self.progressView setHidden:YES];
}

- (void)configureNonDownloadedOnline:(AttachmentTXModel *)attachmentTXModel
{
    self.cloudImageView.image = [UIImage imageNamed:@"Attachment-FileinCloud"];
    [self.fileNameLabel setTextColor:[UIColor colorFromHexString:@"#157DFB"]];
    [self.fileSizeLabel setTextColor:[UIColor colorFromHexString:@"#157DFB"]];
    [self.progressView setProgressTintColor:[UIColor colorFromHexString:@"#FF6633"]];// Anoop: SPR 15SP
}

@end
