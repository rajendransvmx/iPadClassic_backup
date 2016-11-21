//
//  SFMLookUpFilterCell.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 04/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SFMLookUpFilterCell.h"
#import "StyleManager.h"

@interface SFMLookUpFilterCell ()

@property (weak, nonatomic) IBOutlet UIButton *checkBoxButton;
@property (weak, nonatomic) IBOutlet UILabel *filterName;

@end

@implementation SFMLookUpFilterCell

- (void)awakeFromNib
{
    // Initialization code
    self.checkBoxButton.layer.cornerRadius = 5;
    self.checkBoxButton.clipsToBounds = YES;
    self.checkBoxButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.checkBoxButton.layer.borderWidth = 0.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    
}

- (void)setFilterNameForLabel:(NSString *)name
{
    self.filterName.text = name;
}

- (void)setCheckboxImageForType:(CheckBoxStateType)type
{
    switch (type) {
        case CheckBoxStateTypeChecked:
            [self.checkBoxButton setBackgroundImage:[UIImage imageNamed:@"checkbox-active-checked.png"]
                                 forState:UIControlStateNormal];
            [self highlightTextColour];
            break;
        case CheckBoxStateTypeUnchecked:
            [self.checkBoxButton setBackgroundImage:[UIImage imageNamed:@"checkbox-active-unchecked.png"]
                                 forState:UIControlStateNormal];
            
            [self highlightTextColour];
            break;
        case CheckBoxStateTypeCheckedDisabled:
            [self.checkBoxButton setBackgroundImage:[UIImage imageNamed:@"checkbox-disabled-checked.png"]
                                 forState:UIControlStateNormal];
            [self grayOutTextColour];
            break;
        case CheckBoxStateTypeUncheckedDisabled:
            [self.checkBoxButton setBackgroundImage:[UIImage imageNamed:@"checkbox-disabled-unchecked.png"]
                                 forState:UIControlStateNormal];
            [self grayOutTextColour];
            break;
        default:
            //Reset the button image for reuse - Please dont comment
            [self.checkBoxButton setTitle:@"" forState:UIControlStateNormal];
            [self.checkBoxButton setTitle:@"" forState:UIControlStateSelected];
            [self setFilterNameForLabel:@""];
            break;
    }
}

- (void)highlightTextColour
{
    self.filterName.textColor = [UIColor getUIColorFromHexValue:@"#434343"];
}

- (void)grayOutTextColour
{
    self.filterName.textColor = [UIColor getUIColorFromHexValue:@"#A1A1A1"];
}

- (void)setValueForCheckBox:(BOOL)value
{
    //self.checkBoxButton.selected = value;
    self.checkBoxChecked = value;
}

- (IBAction)buttonTapped:(id)sender {
    
    BOOL checkBoxState = (!self.checkBoxChecked);
    
    [self setValueForCheckBox:checkBoxState];
    [self updateCheckBoxStateOnChange:checkBoxState];
    
    if ([self.delegate conformsToProtocol:@protocol(FilterDelegate)]) {
        [self.delegate filterValueChanged:checkBoxState forInexpath:self.indexPath];
    }
}

- (void)updateCheckBoxStateOnChange:(BOOL)state
{
    if(state) {
        [self setCheckboxImageForType:CheckBoxStateTypeChecked];
    }
    else {
        [self setCheckboxImageForType:CheckBoxStateTypeUnchecked];
    }
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.userInteractionEnabled = YES;
    self.checkBoxType = CheckBoxStateTypeNone;
    [self setCheckboxImageForType:self.checkBoxType];
}
@end
