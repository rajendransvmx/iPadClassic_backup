//
//  SFMCollectionViewCell.m
//  CollectionSample
//
//  Created by Damodar on 29/09/14.
//  Copyright (c) 2014 itsdamslife. All rights reserved.
//

#import "SFMCollectionViewCell.h"
#import "StyleManager.h"
#import "StyleGuideConstants.h"
#import <CoreText/CTStringAttributes.h>
#import "StringUtil.h"

static NSString *asterik = @"*";


@interface SFMCollectionViewCell (Private)

@end

@implementation SFMCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.type = CellTypeNonEditableTextField;
        
        CGSize sz = frame.size;
        self.nameField = [[EditMenuLabel alloc] initWithFrame:CGRectMake(8, 8, (sz.width - 16.0f), 21)];
        self.nameField.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize14];
        self.nameField.tag = 100;
        self.nameField.text = @"";
        self.nameField.textColor = [UIColor colorWithHexString:kTextFieldFontColor];
        [self addSubview:self.nameField];
    }
    return self;
}

- (id)name
{
    return self.nameField.text;
}

- (void)setName:(id)name
{
   
    self.nameField.attributedText =  [self getAttributedString:name];
}

- (id)value
{
    return @"";
}

- (void)setValue:(id)value
{
    
}


- (void)setFieldNameForeText:(NSString *)fieldName
{
    // IPAD-4541 - Verifaya
    if (![StringUtil isStringEmpty:fieldName])
    {
        [self.valueField setAccessibilityLabel:fieldName];
    }
}

- (void)loadCell:(CellType)type
{
    self.backgroundColor = [UIColor whiteColor];
    if(!self.nameField)
    {
        CGSize sz = self.bounds.size;
        self.nameField = [[EditMenuLabel alloc] initWithFrame:CGRectMake(8, 8, (sz.width - 16.0f), 21)];
        self.nameField.font = [UIFont systemFontOfSize:14.0f];
        self.nameField.tag = 100;
        self.nameField.text = @"";
        self.nameField.textColor = [UIColor grayColor];
        [self addSubview:self.nameField];
    }
    else
    {
        self.nameField.text = @"";
    }

    
    switch (type) {
        default:
        case CellTypeNonEditableTextField:
            [self addTextField:NO];
            break;
        case CellTypeEditableTextField:
            [self addTextField:YES];
            break;
        case CellTypeDateField:
            
            break;
        case CellTypePicklist:
            
            break;
        case CellTypeTextArea:
            
            break;
        case CellTypeCheckBox:
            
            break;
        case CellTypeSwitch:
            
            break;
        case CellTypeLookUp:
            
            break;
    }
}

- (void)addTextField:(BOOL)isEditable
{
    if(!self.valueField)
    {
        CGSize sz = self.bounds.size;
        UITextField *vf = [[UITextField alloc] initWithFrame:CGRectMake(8, 30, (sz.width - 16.0f), 38)];
        vf.userInteractionEnabled = YES;
        vf.backgroundColor = [UIColor whiteColor];
        vf.borderStyle = UITextBorderStyleRoundedRect | UITextBorderStyleLine;
        vf.tag = 101;
        vf.text = @"";
        vf.font = [UIFont systemFontOfSize:19];
        
        self.valueField = vf;
        
        [self addSubview:self.valueField];
    }
    else
    {
        [self.valueField setText:@""];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self resetFrame];
    
}
- (void)resetFrame {
    CGRect frame =  self.nameField.frame ;
    frame.size.width = self.frame.size.width - 16.0;
    self.nameField.frame = frame;
    
}

- (void)setTextFieldDataType:(NSString*)dataType
{
    
}
-(void)setPrecision:(double)precision scale:(double)scale;
{
    
}

- (void)setLengthVariable:(NSInteger)lenght
{
    
}

- (void)showSuperScript:(BOOL)shouldShow {
    _shouldShowAsteric = shouldShow;
}

- (NSAttributedString *)getAttributedString:(NSString *)stringValue {

    NSMutableAttributedString *attributedFieldName = nil;
    if ([stringValue length] > 0) {
        UIFont *aFont =  [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize14];
        NSDictionary *attributeDictionary = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:kTextFieldFontColor],NSFontAttributeName:aFont};
        attributedFieldName = [[NSMutableAttributedString alloc] initWithString:stringValue attributes:attributeDictionary];
        if (_shouldShowAsteric) {
            
            NSDictionary *attributeDictionary2 = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:kOrangeColor]};
            NSAttributedString *astericString = [[NSAttributedString alloc] initWithString:asterik attributes:attributeDictionary2];
            [attributedFieldName appendAttributedString:astericString];
        }
    }
    return attributedFieldName;
}

@end
