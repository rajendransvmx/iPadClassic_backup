//
//  SFMEditableCell.m
//  CollectionSample
//
//  Created by Damodar on 30/09/14.
//  Copyright (c) 2014 itsdamslife. All rights reserved.
//

#import "SFMEditableCell.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "NumberUtility.h"
#import "EditableDataValidator.h"
#import "SMXiPad_Utility.h"

@interface SFMEditableCell (Private)
@property (nonatomic, strong) TextField *valueField;

//@property (nonatomic, weak) double
@end

@implementation SFMEditableCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = CellTypeEditableTextField;
        
         
        self.valueField = [[TextField alloc]  initWithFrame:frame forType:TextFieldTypeEditable andDelegate:self];
        CGRect fr = self.valueField.frame;
        fr.origin.x = 8;
        fr.origin.y = 30;
        self.valueField.frame = fr;

        self.valueField.userInteractionEnabled = YES;
        self.valueField.backgroundColor = [UIColor colorWithHexString:kWhiteColor];
        self.valueField.borderStyle = UITextBorderStyleRoundedRect | UITextBorderStyleLine;
        self.valueField.tag = 101;
        self.valueField.text = @"";
        self.valueField.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize18];
        self.valueField.textColor = [UIColor colorWithHexString:kEditableTextFieldColor];
        [self addSubview:self.valueField];

    }
    return self;
}

- (id)value
{
    return self.valueField.text;
}

- (void)setValue:(id)value
{
    self.valueField.text = (NSString*)value;
}

- (void)textFieldDidChange:(TextField *)textField
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellValue:didChangeForIndexpath:)])
    {
        [self.delegate cellValue:self.value didChangeForIndexpath:self.indexPath];
    }
}

- (void)textFieldDidBegin:(TextField *)textField {
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellEditingBegan:andSender:)])
    {
        [self.delegate cellEditingBegan:self.indexPath andSender:self];
    }
}

/**
 * - (BOOL)textField:(TextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
 * @author Shubha
 * @brief   To restrict the text
 *
 * @param
 * @param
 *
 * @return BOOL 
 *
 */

- (BOOL)textField:(TextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL isTextAllowed =  [EditableDataValidator validateNumberString:string inParentString:textField.text withRange:range andDataType:self.dataType];
    if(isTextAllowed){
        return  [EditableDataValidator precisionHandlingNumberString:string inParentString:textField.text withRange:range andDataType:self.dataType precision:self.precision scale:self.scale];
    }
  return isTextAllowed;
}

- (void)didTapBarcodeButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(launchBarcodeScannerForIndexPath:)]) {
        [self.delegate launchBarcodeScannerForIndexPath:self.indexPath];
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    [self resetFrame];
    
}
- (void)resetFrame {
    CGRect frame =  self.valueField.frame ;
    frame.size.width = self.frame.size.width - 16;
    self.valueField.frame = frame;
    [self.valueField setNeedsLayout];
}

- (void)setTextFieldDataType:(NSString*)dataType
{
    self.valueField.keyboardType = [SMXiPad_Utility getKeyBoardTypeForDataType:dataType];
    self.dataType = dataType;
}

-(void)setPrecision:(double)precision_ scale:(double)scale_;
{
   self.precision = precision_;
   self.scale = scale_;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
