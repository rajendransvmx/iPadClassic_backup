//
//  SFMCheckBoxCell.m
//  CollectionSample
//
//  Created by Damodar on 30/09/14.
//  Copyright (c) 2014 itsdamslife. All rights reserved.
//

#import "SFMCheckBoxCell.h"

@interface SFMCheckBoxCell (Private)
@property (nonatomic, strong) CheckBox *valueField;
@end

@implementation SFMCheckBoxCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = CellTypeCheckBox;
        
        self.valueField = [[CheckBox alloc] initWithFrame:CGRectMake(8,30, 30, 30)];
        self.valueField.delegate = self;
        self.valueField.userInteractionEnabled = YES;
        self.valueField.tag = 101;
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


- (void)didSelectedCheckBox:(CheckBox *)checkbox checked:(BOOL)isChecked
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellValue:didChangeForIndexpath:)])
    {
        [self.delegate cellValue:self.value didChangeForIndexpath:self.indexPath];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
