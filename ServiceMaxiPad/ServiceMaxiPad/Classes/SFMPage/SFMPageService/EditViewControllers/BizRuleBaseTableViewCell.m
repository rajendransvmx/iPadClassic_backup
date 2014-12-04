//
//  BizRuleBaseTableViewCell.m
//  ServiceMaxiPad
//
//  Created by Sahana on 12/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "BizRuleBaseTableViewCell.h"
#import "StyleGuideConstants.h"

@implementation BizRuleBaseTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.imageView.image = [UIImage imageNamed:@"bizExclamation"];
        
        self.textLabel.numberOfLines = 2;
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        self.textLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize16];
        self.detailTextLabel.font = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize14];

    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setTitleDescription:(NSString *)titleDescription{
    self.textLabel.text = titleDescription;
}

-(void)setSubTitleDescription:(NSString *)subTitleDescription
{
    self.detailTextLabel.text = subTitleDescription;
}


@end
