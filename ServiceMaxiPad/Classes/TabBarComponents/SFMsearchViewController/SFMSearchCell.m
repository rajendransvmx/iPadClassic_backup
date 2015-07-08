//
//  SFMSearchCell.m
//  ServiceMaxiPad
//
//  Created by Shubha S on 05/05/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "SFMSearchCell.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "SFMSearchCell.h"
#import "SFObjectFieldDAO.h"
#import "SFMOnlineSearchManager.h"

@implementation SFMSearchCell

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
  
    
    //CGFloat width = self.frame.size.width;
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];

    self.fieldLabelOne = [[UILabel alloc]initWithFrame:CGRectZero];
   // width = self.fieldLabelOne.frame.size.width;
    self.fieldValueOne = [[UILabel alloc]initWithFrame:CGRectZero];
    self.fieldLabelTwo = [[UILabel alloc]initWithFrame:CGRectZero];
    self.fieldLabelTwo.backgroundColor = [UIColor clearColor];
    self.fieldValueTwo = [[UILabel alloc]initWithFrame:CGRectZero];
    self.fieldValueTwo.backgroundColor = [UIColor clearColor];
   self.accessoryImgView= [[UIImageView alloc]init];


    
    self.titleLabel.textColor =  [UIColor colorWithHexString:kEditableTextFieldColor];//[UIColor blackColor];
    self.titleLabel.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize18];
    
    self.fieldLabelOne.textColor = [UIColor colorWithHexString:kTextFieldFontColor];
    self.fieldLabelOne.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize14];
    
    self.fieldValueOne.textColor = [UIColor colorWithHexString:kEditableTextFieldColor];
    self.fieldValueOne.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize16];
    
    self.fieldLabelTwo.textColor = [UIColor colorWithHexString:kTextFieldFontColor];
    self.fieldLabelTwo.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize14];
    
    self.fieldValueTwo.textColor = [UIColor colorWithHexString:kEditableTextFieldColor];
    self.fieldValueTwo.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize16];
    
    
    
    

    [self addSubview:self.titleLabel];
    [self addSubview:self.fieldLabelOne];
    [self addSubview:self.fieldLabelTwo];
    [self addSubview:self.fieldValueOne];
    [self addSubview:self.fieldValueTwo];
    [self addSubview:self.accessoryImgView];
    
   // self.backgroundColor = [UIColor blueColor];

}

- (void)layoutSubviews
{
    CGFloat width = self.frame.size.width / 2;
    
    self.titleLabel.frame = CGRectMake(20, 10,width*2-52, 20);
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.fieldLabelOne.frame = CGRectMake(20, 30,width-20, 20);
    width = self.fieldLabelOne.frame.size.width;
    self.fieldValueOne.frame = CGRectMake(20, 50,width-20, 20);
    self.fieldLabelTwo.frame = CGRectMake(width+10, 30,width-20, 20);
    self.fieldValueTwo.frame = CGRectMake(width+10, 50,width-20, 20);
    CGRect theFrame = self.fieldLabelTwo.frame;
    theFrame.origin.x = theFrame.origin.x + theFrame.size.width +5;
    theFrame.origin.y = 30;
    theFrame.size.width = 30;
    theFrame.size.height = 31;
    
    
    self.accessoryImgView.frame = theFrame;
   
}

-(void)cleanUP
{
    _fieldLabelOne.text = @"";
    _fieldValueOne.text = @"";
    _fieldLabelTwo.text = @"";
    _fieldValueTwo.text = @"";
}

@end
