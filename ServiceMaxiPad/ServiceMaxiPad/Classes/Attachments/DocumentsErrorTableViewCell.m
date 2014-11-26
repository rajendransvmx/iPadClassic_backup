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

@interface DocumentsErrorTableViewCell ()

@property(nonatomic, weak) AttachmentTXModel *attachmentModel;

@end

@implementation DocumentsErrorTableViewCell

-(void) layoutSubviews {
    
    if(self.isEditing) {
        
        [self configureDocumentsOffline:self.attachmentModel];
    }
    [super layoutSubviews];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureErrorDocuments:(AttachmentTXModel*)attachmentTXModel {
    
    self.attachmentModel = attachmentTXModel;
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]) {
        [self configureDocumentsOnline:attachmentTXModel];
    }
    else {
        [self configureDocumentsOffline:attachmentTXModel];
    }
    self.titleLabel.text = attachmentTXModel.nameWithoutExtension;
    self.errorLabel.text = [SVMXSystemConstant restAPIErrorMessageByErrorCode:(int)attachmentTXModel.errorCode];
    self.descriptionLabel.text = attachmentTXModel.errorMessage;
    
    
}

- (void)configureDocumentsOffline:(AttachmentTXModel *)attachmentTXModel
{
    self.iconImgView.image = [UIImage imageNamed:@"Attachment-File-Missing"];
    [self.titleLabel setTextColor:[UIColor colorWithHexString:@"#9A9A9B"]];
    [self.descriptionLabel setTextColor:[UIColor colorWithHexString:@"#9A9A9B"]];
    [self.errorLabel setTextColor:[UIColor colorWithHexString:@"#9A9A9B"]];
}

- (void)configureDocumentsOnline:(AttachmentTXModel *)attachmentTXModel
{
    self.iconImgView.image = [UIImage imageNamed:@"Attachment-File-Missing"];
    [self.titleLabel setTextColor:[UIColor colorWithHexString:@"#434343"]];
    [self.descriptionLabel setTextColor:[UIColor colorWithHexString:@"#434343"]];
    [self.errorLabel setTextColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:1]];
}


@end
