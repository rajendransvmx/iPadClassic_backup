//
//  DocumentsTableViewCell.m
//  ServiceMaxiPad
//
//  Created by Anoop on 10/27/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "DocumentsErrorTableViewCell.h"
#import "AttachmentTXModel.h"
#import "AttachmentUtility.h"
#import "SNetworkReachabilityManager.h"
#import "StyleManager.h"
#import "SVMXSystemConstant.h"

@implementation DocumentsErrorTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureErrorDocuments:(AttachmentTXModel*)attachmentTXModel {
    
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]) {
        [self configureDocumentsOnline:attachmentTXModel];
    }
    else {
        [self configureDocumentsOffline:attachmentTXModel];
    }
    _titleLabel.text = attachmentTXModel.nameWithoutExtension;
    _errorLabel.text = [SVMXSystemConstant restAPIErrorMessageByErrorCode:(int)attachmentTXModel.errorCode];
    _descriptionLabel.text = attachmentTXModel.errorMessage;
    
    
}

- (void)configureDocumentsOffline:(AttachmentTXModel *)attachmentTXModel
{
    _iconImgView.image = [UIImage imageNamed:@"Attachment-File-Missing"];
    [_titleLabel setTextColor:[UIColor colorWithHexString:@"#9A9A9B"]];
    [_descriptionLabel setTextColor:[UIColor colorWithHexString:@"#9A9A9B"]];
    [_errorLabel setTextColor:[UIColor colorWithHexString:@"#9A9A9B"]];
}

- (void)configureDocumentsOnline:(AttachmentTXModel *)attachmentTXModel
{
    _iconImgView.image = [UIImage imageNamed:@"Attachment-File-Missing"];
    [_titleLabel setTextColor:[UIColor colorWithHexString:@"#434343"]];
    [_descriptionLabel setTextColor:[UIColor colorWithHexString:@"#434343"]];
    [_errorLabel setTextColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:1]];
}


@end
