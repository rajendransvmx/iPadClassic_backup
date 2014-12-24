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

@interface ChatterCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *chatText;
@property (weak, nonatomic) IBOutlet UILabel *time;


@end

@implementation ChatterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}

- (void)initialSetUp
{
    self.userName.textColor = [UIColor colorWithHexString:kEditableTextFieldColor];
    self.chatText.textColor = [UIColor colorWithHexString:kTextFieldFontColor];
    self.time.textColor = [UIColor colorWithHexString:kTextFieldFontColor];
        
    //self.contentView.backgroundColor = [UIColor orangeColor];
    //colorWithHexString:kActionBgColor
    
    CGFloat height = self.userImageView.frame.size.height;
    self.userImageView.layer.cornerRadius = height/2;
    self.userImageView.backgroundColor = [UIColor redColor];
}

- (void)awakeFromNib {
    // Initialization code
    [self initialSetUp];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
