//
//  TextFieldHelperDelegate.m
//  ServiceMaxiPad
//
//  Created by shravya on 14/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "TextFieldHelperDelegate.h"

@implementation TextFieldHelperDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return [self.containerTextField customTextFieldShouldBeginEditing:textField];
   
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    return [self.containerTextField customTextFieldDidEndEditing:textField];
    
}

- (void)textFieldDidTap:(TextField*)textField
{
    return [self.containerTextField customTextFieldDidTap:textField];
}

- (BOOL)textField:(TextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [self.containerTextField CustomTextField:textField shouldChangeCharactersInRange:range replacementString:string];
}

@end
