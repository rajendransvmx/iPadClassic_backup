//
//  DocumentsTableViewCell.m
//  ServiceMaxiPad
//
//  Created by Anoop on 10/27/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "DocumentsTableViewCell.h"
#import "AttachmentTXModel.h"
#import "AttachmentUtility.h"
#import "AttachmentsDownloadManager.h"
#import "SNetworkReachabilityManager.h"
#import "StyleManager.h"

@interface DocumentsTableViewCell ()

@end

@implementation DocumentsTableViewCell

/*
static NSInteger offset = 32;

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self=[super initWithCoder:aDecoder];
    
    if(self){
        _checkButton=[[UIButton alloc] initWithFrame:CGRectMake(-(offset/2.0)-(25.0/2.0),  (self.contentView.frame.size.height/2.0)-(25/2.0), 25 , 25)];
        
        [_checkButton setImage:[UIImage imageNamed:@"Attachment-SelectionCheckempty-Small@2x"] forState:UIControlStateNormal];
        [_checkButton setImage:[UIImage imageNamed:@"Attachment-SelectionCheckfilled-Small@2x"] forState:UIControlStateSelected];
        [_checkButton addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_checkButton setAdjustsImageWhenHighlighted:NO];
        [self addSubview:_checkButton];
    }
    return self;
}

-(void) layoutSubviews {
    // Initialization code
    if(self.isEditing){
        _checkButton.frame=CGRectMake((offset/2.0)-(25.0/2.0),  (self.contentView.frame.size.height/2.0)-(25/2.0), 25  , 25);
        
    }else{
        _checkButton.frame=CGRectMake(-(offset/2.0)-(25/2.0),  (self.contentView.frame.size.height/2.0)-(25/2.0), 25  , 25);
        
    }
    [super layoutSubviews];
}

-(void) buttonSelected:(UIButton*) sender{
    [sender setSelected:!sender.isSelected];
}
*/

- (void)awakeFromNib {

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

- (void)configureDocuments:(AttachmentTXModel*)attachmentTXModel {
    
    NSDictionary *downloadInfo = [[AttachmentsDownloadManager sharedManager].downloadingDictionary objectForKey:attachmentTXModel.localId];
    _titleLabel.text = attachmentTXModel.nameWithoutExtension;
    _dateLabel.text = attachmentTXModel.displayDateString;
    NSString *fileSizeInUnits = [NSString stringWithFormat:@"%.2f %@",
                                 [AttachmentUtility calculateFileSizeInUnit:(unsigned long long)[attachmentTXModel.bodyLength intValue]],
                                 [AttachmentUtility calculateUnit:(unsigned long long)[attachmentTXModel.bodyLength intValue]]];
    _sizeLabel.text = fileSizeInUnits;
    _downloadProgressView.hidden = ![downloadInfo allKeys];
    
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]) {
        [self configureDocumentsOnline:attachmentTXModel];
    }
    else {
        [self configureDocumentsOffline:attachmentTXModel];
    }
    if (!_downloadProgressView.hidden) {
        [_downloadProgressView setProgress:[[downloadInfo valueForKey:kDocumentsDownloadKeyProgress] floatValue] animated:YES];
        _sizeLabel.text = [downloadInfo valueForKey:kDocumentsDownloadKeyDetails];
    }
}

- (void)configureDocumentsOffline:(AttachmentTXModel *)attachmentTXModel
{
    
    if (attachmentTXModel.isDownloaded)
    {
        [self configureDocumentsOnline:attachmentTXModel];
    }
    else
    {
    _iconImgView.image = [UIImage imageNamed:@"Attachment-DownloadFileOffline"];
    [_titleLabel setTextColor:[UIColor colorWithHexString:@"#9A9A9B"]];
    [_dateLabel setTextColor:[UIColor colorWithHexString:@"#9A9A9B"]];
    [_sizeLabel setTextColor:[UIColor colorWithHexString:@"#9A9A9B"]];
    _downloadProgressView.hidden = YES;
    }
}

- (void)configureDocumentsOnline:(AttachmentTXModel *)attachmentTXModel
{
    NSDictionary *doctDict = [AttachmentUtility documentTypesDict];
    if (attachmentTXModel.isDownloaded)
    {
        if ([doctDict valueForKey:attachmentTXModel.extensionName])
        {
            _iconImgView.image = [UIImage imageNamed:[doctDict valueForKey:attachmentTXModel.extensionName]];
        }
        else
        {
            _iconImgView.image = [UIImage imageNamed:@"Attachment-Unknown"];
        }
    }
    else
    {
        _iconImgView.image = [UIImage imageNamed:@"Attachment-FileinCloud"];
    }
    [_titleLabel setTextColor:[UIColor colorWithHexString:@"#434343"]];
    [_dateLabel setTextColor:[UIColor colorWithHexString:@"#797979"]];
    [_sizeLabel setTextColor:[UIColor colorWithHexString:@"#797979"]];
    [_downloadProgressView setProgressTintColor:[UIColor colorWithHexString:@"#157DFB"]];
}


@end
