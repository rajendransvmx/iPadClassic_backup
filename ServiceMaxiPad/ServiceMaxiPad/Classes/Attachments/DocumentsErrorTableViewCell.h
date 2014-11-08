//
//  DocumentsTableViewCell.h
//  ServiceMaxiPad
//
//  Created by Anoop on 10/27/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AttachmentTXModel;

@interface DocumentsErrorTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *documentsCellView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

- (void)configureErrorDocuments:(AttachmentTXModel*)attachmentTXModel;

@end
