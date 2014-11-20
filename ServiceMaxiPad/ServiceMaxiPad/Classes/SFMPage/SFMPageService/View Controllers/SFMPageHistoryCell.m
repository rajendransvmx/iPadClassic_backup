//
//  SFMPageHistoryCell.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 16/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageHistoryCell.h"

@implementation SFMPageHistoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self addLabelsToView];
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

-(void)addLabelsToView
{
    self.descriptionTitle =[[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.descriptionTitle];
    
    self.descriptionData =[[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.descriptionData];
    
    [self addBorderToCell];
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.contentView.frame;
    
    
    CGRect descriptionFrame = CGRectMake(frame.origin.x + 10, frame.origin.y + 8, frame.size.width, frame.size.height/2);
   
    self.descriptionTitle.frame = descriptionFrame;
    self.descriptionTitle.backgroundColor = [UIColor clearColor];
    self.descriptionTitle.textColor = [UIColor blackColor];
    
    CGRect dateFrame = CGRectMake(frame.origin.x + 10, CGRectGetMaxY(self.descriptionTitle.bounds) -3, frame.size.width,
                                  frame.size.height/2);
  
    self.descriptionData.frame = dateFrame;
    self.descriptionData.backgroundColor = [UIColor clearColor];
    self.descriptionData.textColor = [UIColor grayColor];
    self.bottomBorder.hidden = NO;

    
    self.bottomBorder.frame = CGRectMake(10.0, CGRectGetMaxY(frame) - 1, frame.size.width, 1.0);

    
}

- (void)addBorderToCell
{
    self.bottomBorder = [[UIView alloc] init];
    self.bottomBorder.frame = CGRectZero;
    self.bottomBorder.backgroundColor = [UIColor lightGrayColor];
    self.bottomBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
    [self.contentView addSubview:self.bottomBorder];
}

@end
