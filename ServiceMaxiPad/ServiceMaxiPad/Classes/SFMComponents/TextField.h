//
//  TextField.h
//  ServiceMaxMobile
//
//  Created by Damodar on 10/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    TextFieldTypeNonEditable,
    TextFieldTypeEditable,
    TextFieldTypePicklist,
    TextFieldTypeDateField,
    TextFieldTypeLookUp
} TextFieldType;

@class  TextField;

@protocol TextFieldDelegate <NSObject>

@optional
- (void)textFieldDidChange:(TextField *)textField;
- (void)textFieldDidTap:(TextField *)textField;
- (void)textFieldDidBegin:(TextField *)textField;
- (BOOL)textField:(TextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (void)didTapBarcodeButton;


- (void)clearButtonTapped:(id)sender;

@end

@interface TextField : UITextField <UITextFieldDelegate>

@property (assign) id<TextFieldDelegate> textFieldDelegate;
@property (nonatomic, strong) UIImageView *innerImageView;

- (id)initWithFrame:(CGRect)frame forType:(TextFieldType)type andDelegate:(id<TextFieldDelegate>)delegate;
- (void)setOrigin:(CGPoint)origin;

- (BOOL)customTextFieldShouldBeginEditing:(UITextField *)textField;
- (void)customTextFieldDidEndEditing:(UITextField *)textField;
- (void)customTextFieldDidTap:(TextField*)textField;
- (BOOL)CustomTextField:(TextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;


@end
