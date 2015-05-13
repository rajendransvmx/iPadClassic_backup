//
//  PageEditChildListCellTableViewCell.m
//  ServiceMaxiPad
//
//  Created by Shubha S on 13/05/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "PageEditChildListCell.h"
#import "StyleManager.h"

@implementation PageEditChildListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self configureCell];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCell
{
    self.tittleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.tittleLabel.textColor =  [UIColor colorWithHexString:kEditableTextFieldColor];//[UIColor blackColor];
    self.tittleLabel.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize18];
    
    //self.multiPageFieldView = [[MultiPageFieldView alloc]initWithFrame:CGRectZero];
    

}

- (void)layoutSubviews
{
    self.tittleLabel.frame = CGRectMake(0, 10, self.frame.size.width, 20);

}

@end
