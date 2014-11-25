//
//  TextField.m
//  ServiceMaxMobile
//
//  Created by Damodar on 10/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "TextField.h"
#import <QuartzCore/QuartzCore.h>
#import "TextFieldHelperDelegate.h"
#import "StringUtil.h"
#import "StyleManager.h"
#import "Utility.h"

@interface TextField ()

@property (nonatomic, assign) TextFieldType myType;
@property (nonatomic, strong) TextFieldHelperDelegate *helper;

@end

@implementation TextField

- (id)initWithFrame:(CGRect)frame forType:(TextFieldType)type andDelegate:(id<TextFieldDelegate>)delegate
{
    
    self = [super initWithFrame:CGRectMake(0, 0, (frame.size.width - 16), 35)];
    if (self) {
        // Initialization code
        
        self.layer.cornerRadius = 5.0f;
        self.borderStyle = UITextBorderStyleRoundedRect;
        self.helper = [[TextFieldHelperDelegate alloc] init];
        self.helper.containerTextField = self;
        self.delegate = self.helper;
        
        self.textFieldDelegate = delegate;
        
        [self initializeForType:type];
       
        
    }
    return self;
}


- (void)setOrigin:(CGPoint)origin
{
    CGRect fr = self.frame;
    fr.origin.x = origin.x;
    fr.origin.y = origin.y;
    self.frame = fr;
}

- (void)initializeForType:(TextFieldType)type
{
    switch (type) {
        default:
        case TextFieldTypeNonEditable:
            [self setToNonEditable];
            break;
        case TextFieldTypeEditable:
            [self setToEditable];
            break;
        case TextFieldTypePicklist:
            [self setToPicklist];
            break;
        case TextFieldTypeDateField:
            [self setToDateField];
            break;
        case TextFieldTypeLookUp:
            [self setToLookUp];
            break;
    }
}

- (void)setToNonEditable
{
    self.myType = TextFieldTypeNonEditable;
    self.backgroundColor = [UIColor lightGrayColor];
    self.textColor = [UIColor darkGrayColor];
    self.userInteractionEnabled = NO;
}

- (void)setToEditable
{
    self.myType = TextFieldTypeEditable;
    self.backgroundColor = [UIColor whiteColor];
    self.userInteractionEnabled = YES;
    self.inputAccessoryView = [self barcodeView];
}

- (void)setToPicklist
{
    self.myType = TextFieldTypePicklist;
    self.backgroundColor = [UIColor whiteColor];
    self.userInteractionEnabled = YES;
    [self addRightImage:self.myType];
}

- (void)setToDateField
{
    self.myType = TextFieldTypeDateField;
    self.backgroundColor = [UIColor whiteColor];
    self.userInteractionEnabled = YES;
    [self addRightImage:self.myType];
}

- (void)setToLookUp
{
    self.myType = TextFieldTypeLookUp;
    self.backgroundColor = [UIColor whiteColor];
    self.userInteractionEnabled = YES;
    [self addRightImage:self.myType];
}

- (void)addRightImage:(TextFieldType)type
{
    NSString *imageName = @"";
    
    switch (type) {
        case TextFieldTypePicklist:
            imageName = @"triangle-down.png";
            break;
        case TextFieldTypeDateField:
            if (![StringUtil isStringEmpty:self.text]) {
                imageName = @"clear.png";
            } else {
                imageName = @"triangle-down.png";
            }
            break;
        case TextFieldTypeLookUp:
            imageName = @"clear.png";
            break;
        default:
            break;
    }
    
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imgVw = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imgVw.tag = 111;
    NSLog(@"%@",NSStringFromCGRect(imgVw.frame));
    
    if (type == TextFieldTypeLookUp) {
        UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clearButtonTapped:)];
        imgVw.userInteractionEnabled = YES;
        [imgVw addGestureRecognizer:tapgesture];
        
        //to get tappable more area
        UIButton *invisibleButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - imgVw.frame.size.width, 0, image.size.width, self.frame.size.height)];
        [self addSubview:invisibleButton];
        invisibleButton.backgroundColor = [UIColor clearColor];
        [invisibleButton addTarget:self action:@selector(clearButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    CGRect imgFr = imgVw.frame;
    imgFr.origin.x = self.frame.size.width - image.size.width - 10;
    imgFr.origin.y = (self.frame.size.height - image.size.height) / 2;
    imgVw.frame = imgFr;
    imgVw.contentMode = UIViewContentModeScaleAspectFit;
  //  NSLog(@"%@",NSStringFromCGRect(imgVw.frame));
   // [self addSubview:imgVw];
    self.innerImageView = imgVw;
    
    //UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - imgVw.frame.size.width, 0, self.frame.size.height, image.size.width)];
    self.rightView = self.innerImageView;
    self.rightViewMode = UITextFieldViewModeAlways;
    self.innerImageView = imgVw;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect innerImageFrame = self.innerImageView.frame;
    innerImageFrame.origin.x = self.frame.size.width - self.innerImageView.frame.size.width - 8;
    self.innerImageView.frame = innerImageFrame;
    
}
- (BOOL)customTextFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL returnVal = NO;
    switch (self.myType) {
        case TextFieldTypeNonEditable:
            returnVal = NO;
            break;
        case TextFieldTypePicklist:
        case TextFieldTypeDateField:
        case TextFieldTypeLookUp:
            [self customTextFieldDidTap:self];
            returnVal = NO;
            break;
        default:
        case TextFieldTypeEditable:
            returnVal = YES;
            if (self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textFieldDidBegin:)])
            {
                [self.textFieldDelegate textFieldDidBegin:self];
            }
            break;
    }
    
    return returnVal;
}

- (void)customTextFieldDidEndEditing:(UITextField *)textField
{
    if (self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textFieldDidChange:)])
    {
        [self.textFieldDelegate textFieldDidChange:self];
    }
}

- (void)customTextFieldDidTap:(TextField*)textField
{
    if (self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textFieldDidTap:)])
    {
        [self.textFieldDelegate textFieldDidTap:self];
    }
}

- (BOOL)CustomTextField:(TextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
    {
      return [self.textFieldDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    
    return NO;
}
- (void)clearButtonTapped:(id)sender
{
    self.text = @"";
    [self.textFieldDelegate clearButtonTapped:(id)sender];
}

- (UIView *)barcodeView
{
    if ([Utility isCameraAvailable]) {
        UIView *barCodeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, 46)];
        barCodeView.backgroundColor = [UIColor colorWithHexString:@"B5B7BE"];
        
        CGRect buttonFrame = CGRectMake(0, 6, 72, 32);
        
        UIButton *barCodeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [barCodeButton setBackgroundImage:[UIImage imageNamed:@"barcode.png"] forState:UIControlStateNormal];
        
        CGFloat xPosition = CGRectGetWidth(barCodeView.frame) - 90;
        buttonFrame.origin.x = xPosition;
        
        barCodeButton.frame = buttonFrame;
        
        barCodeButton.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [barCodeButton addTarget:self
                          action:@selector(lauchBarCode)
                forControlEvents:UIControlEventTouchUpInside];
        [barCodeView addSubview:barCodeButton];
        
        return barCodeView;
    }
    return nil;
    
}

- (void)lauchBarCode
{
    if (self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(didTapBarcodeButton)]) {
        [self.textFieldDelegate didTapBarcodeButton];
    }
}



@end

