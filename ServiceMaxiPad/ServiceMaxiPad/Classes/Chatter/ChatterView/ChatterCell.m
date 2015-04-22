//
//  ChatterCell.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 16/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ChatterCell.h"
#import "StyleManager.h"
#import "StyleGuideConstants.h"
#import "ChatterHelper.h"
#import "NonTagConstant.h"

@interface ChatterCell ()

@property (weak, nonatomic) IBOutlet ImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *chatText;
@property (weak, nonatomic) IBOutlet UILabel *time;


@end

@implementation ChatterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)initialSetUp
{
    self.userName.textColor = [UIColor colorWithHexString:kEditableTextFieldColor];
    self.chatText.textColor = [UIColor colorWithHexString:kTextFieldFontColor];
    self.time.textColor = [UIColor colorWithHexString:kTextFieldFontColor];

    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2;
    self.userImageView.clipsToBounds = YES;
}

- (void)awakeFromNib {
    // Initialization code
    [self initialSetUp];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    self.userName.text = @"";
    self.chatText.text = @"";
    self.time.text = @"";
    //self.userImageView.image = nil;
}

- (void)updateCellView:(ChatterFeedComments *)comments
{
    self.userName.text = comments.name;
    self.chatText.text = comments.commentBody;
    self.time.text = comments.createdDateString;
    
    self.userId = comments.createdById;
    self.photoUrl = comments.fullPhotoUrl;
}

- (void)updateUserImage
{
    self.userImageView.userId = self.userId;
    self.userImageView.path = self.path;
    self.userImageView.photoUrl = self.photoUrl;
    
    [self.userImageView loadImage];
}


@end
