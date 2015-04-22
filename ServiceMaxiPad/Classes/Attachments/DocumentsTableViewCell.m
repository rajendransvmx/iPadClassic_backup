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

@property(nonatomic, weak) AttachmentTXModel *attachmentModel;

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


-(void) layoutSubviews {

    if(self.isEditing) {
        
        if (self.attachmentModel.isDownloaded && !self.attachmentModel.isOutputdoc)
        {
            [self configureDocumentsOnline:self.attachmentModel];
        }
        else
        {
            [self configureDocumentsOffline:self.attachmentModel];
        }
    
    }
    [super layoutSubviews];
}


- (void)awakeFromNib {

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

- (void)configureDocuments:(AttachmentTXModel*)attachmentTXModel {
    
    self.attachmentModel = attachmentTXModel;
    NSDictionary *downloadInfo = [[AttachmentsDownloadManager sharedManager].downloadingDictionary objectForKey:attachmentTXModel.localId];
    self.titleLabel.text = attachmentTXModel.nameWithoutExtension;
    self.dateLabel.text = attachmentTXModel.displayDateString;
    NSString *fileSizeInUnits = [NSString stringWithFormat:@"%.2f %@",
                                 [AttachmentUtility calculateFileSizeInUnit:(unsigned long long)attachmentTXModel.bodyLength],
                                 [AttachmentUtility calculateUnit:(unsigned long long)attachmentTXModel.bodyLength]];
    self.sizeLabel.text = fileSizeInUnits;
    self.downloadProgressView.hidden = ![downloadInfo allKeys];
    
    if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable]) {

        [self configureDocumentsOnline:attachmentTXModel];
    }
    else
    {
        [self configureDocumentsOffline:attachmentTXModel];
    }
    if (!self.downloadProgressView.hidden) {
        [self.downloadProgressView setProgress:[[downloadInfo valueForKey:kDocumentsDownloadKeyProgress] floatValue] animated:YES];
        self.sizeLabel.text = [downloadInfo valueForKey:kDocumentsDownloadKeyDetails];
    }
}

- (void)configureDocumentsOffline:(AttachmentTXModel *)attachmentTXModel
{
    if (attachmentTXModel.isDownloaded)
    {
        if(self.isEditing && attachmentTXModel.isOutputdoc)
        {
            [self offlineLayout];
        }
        else
        {
            [self configureDocumentsOnline:attachmentTXModel];
        }
    }
    else
    {
        [self offlineLayout];
    }
}

- (void)offlineLayout
{
    self.iconImgView.image = [UIImage imageNamed:@"Attachment-DownloadFileOffline"];
    [self.titleLabel setTextColor:[UIColor colorWithHexString:@"#9A9A9B"]];
    [self.dateLabel setTextColor:[UIColor colorWithHexString:@"#9A9A9B"]];
    [self.sizeLabel setTextColor:[UIColor colorWithHexString:@"#9A9A9B"]];
    self.downloadProgressView.hidden = YES;
}

- (void)configureDocumentsOnline:(AttachmentTXModel *)attachmentTXModel
{
    NSDictionary *doctDict = [AttachmentUtility documentTypesDict];
    if (attachmentTXModel.isDownloaded)
    {
        if ([doctDict valueForKey:attachmentTXModel.extensionName])
        {
            self.iconImgView.image = [UIImage imageNamed:[doctDict valueForKey:attachmentTXModel.extensionName]];
        }
        else
        {
            self.iconImgView.image = [UIImage imageNamed:@"Attachment-Unknown"];
        }
    }
    else
    {
        self.iconImgView.image = [UIImage imageNamed:@"Attachment-FileinCloud"];
    }
    [self.titleLabel setTextColor:[UIColor colorWithHexString:@"#434343"]];
    [self.dateLabel setTextColor:[UIColor colorWithHexString:@"#797979"]];
    [self.sizeLabel setTextColor:[UIColor colorWithHexString:@"#797979"]];
    [self.downloadProgressView setProgressTintColor:[UIColor colorWithHexString:@"#157DFB"]];
}


@end
