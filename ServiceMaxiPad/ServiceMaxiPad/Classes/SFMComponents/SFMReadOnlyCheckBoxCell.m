//
//  SFMReadOnlyCheckBoxCell.m
//  ServiceMaxiPad
//
//  Created by Shubha S on 21/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SFMReadOnlyCheckBoxCell.h"
#import "CheckBox.h"

@interface SFMReadOnlyCheckBoxCell (Private)

@property (nonatomic, strong) CheckBox *valueField;

@end

@implementation SFMReadOnlyCheckBoxCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = CellTypeCheckBox;
        
        self.valueField = [[CheckBox alloc] initWithFrame:CGRectMake(8,30, 30, 30)];
        self.valueField.userInteractionEnabled = NO;
        self.valueField.tag = 101;
        
        [self.valueField setImage:[UIImage imageNamed:@"checkbox-disabled-unchecked.png"] forState:UIControlStateNormal];
        [self.valueField setImage:[UIImage imageNamed:@"checkbox-disabled-checked.png"] forState:UIControlStateSelected];
        [self addSubview:self.valueField];
    }
    return self;
}

- (id)value
{
    return (self.valueField.isChecked ? @"1" : @"0");
}

- (void)setValue:(id)value
{
    if([(NSString*)value isEqualToString:@"1"])
        [self.valueField defaultValueForCheckbox:YES];
    else
        [self.valueField defaultValueForCheckbox:NO];
}


//- (void)didSelectedCheckBox:(CheckBox *)checkbox checked:(BOOL)isChecked
//{
//    if(self.delegate && [self.delegate respondsToSelector:@selector(cellValue:didChangeForIndexpath:)])
//    {
//        [self.delegate cellValue:self.value didChangeForIndexpath:self.indexPath];
//    }
//}


@end
