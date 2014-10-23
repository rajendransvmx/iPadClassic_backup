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

- (void)clearButtonTapped:(id)sender;

@end

@interface TextField : UITextField <UITextFieldDelegate>

@property (assign) id<TextFieldDelegate> textFieldDelegate;

- (id)initWithFrame:(CGRect)frame forType:(TextFieldType)type andDelegate:(id<TextFieldDelegate>)delegate;
- (void)setOrigin:(CGPoint)origin;

- (BOOL)customTextFieldShouldBeginEditing:(UITextField *)textField;
- (void)customTextFieldDidEndEditing:(UITextField *)textField;
- (void)customTextFieldDidTap:(TextField*)textField;


@end
