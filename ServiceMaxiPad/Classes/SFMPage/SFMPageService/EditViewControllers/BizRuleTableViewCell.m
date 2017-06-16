//
//  BizRuleCellTableViewCell.m
//  ServiceMaxiPad
//
//  Created by Sahana on 10/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "BizRuleTableViewCell.h"
#import "StyleManager.h"
#import "StyleGuideConstants.h"
#import "TagManager.h"
#import "NonTagConstant.h"

@interface BizRuleTableViewCell()
@property(nonatomic, strong) IBOutlet UIButton *checkBox;
@property(nonatomic, strong) IBOutlet UILabel  * resolveLabel;
@property(nonatomic, strong) IBOutlet UILabel  * descriptionLabel;
@property(nonatomic) cellType cellType;

@property (nonatomic) BOOL checked;
@end

@implementation BizRuleTableViewCell


- (void)awakeFromNib
{
    // Initialization code
    [self setUpUI];
}

- (void)setUpUI {
    
    self.descriptionLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize16];
   
    self.resolveLabel.hidden = NO;
    self.checkBox.hidden = NO;
    self.imageView.image = [UIImage imageNamed:@"bizInfo.png"];
    [self.checkBox setImage:[UIImage imageNamed:@"checkbox-active-unchecked.png"] forState:UIControlStateNormal];
    [self.checkBox setImage:[UIImage imageNamed:@"checkbox-active-checked.png"] forState:UIControlStateSelected];
    [self.checkBox addTarget:self action:@selector(checkboxBtnChecked:) forControlEvents:UIControlEventTouchUpInside];
    [self.checkBox setAccessibilityLabel:kVBizRuleCheckBoxBtn];//Verifaya Label for Checkbox
    
    
    self.resolveLabel.textColor =  [UIColor getUIColorFromHexValue:kOrangeColor];
    self.resolveLabel.text = [[TagManager sharedInstance]tagByName:kTag_Confirm];

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


-(void)checkboxBtnChecked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = ![button isSelected]; // Important line
    
    if([self.delegate conformsToProtocol:@protocol(BizRuleCellDelegate) ]){
        [self.delegate cellTappedAtIndexPath:self.indexPath selectedValue:button.selected];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
}

-(void)setTitleDescription:(NSString *)titleDescription{
    self.descriptionLabel.text = titleDescription;

}
-(void)setsubTitleDescription:(NSString *)detailDescription
{
}

-(void)setCheckBoxselected:(BOOL)checkBoxselected
{
    self.checkBox.selected = checkBoxselected;
}
@end
