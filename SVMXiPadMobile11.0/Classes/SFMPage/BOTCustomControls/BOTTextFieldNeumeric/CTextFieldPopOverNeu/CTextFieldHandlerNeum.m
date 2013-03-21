//
//  CTextFieldHandlerNeum.m
//  CustomClassesipad
//
//  Created by Developer on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CTextFieldHandlerNeum.h"
#import "CTextField.h"

@implementation CTextFieldHandlerNum

@synthesize delegate;
@synthesize POC;
@synthesize rect;
@synthesize PopOverView;
@synthesize lableValue;
@synthesize control_type;
@synthesize percent_count;
@synthesize countflag;

-(id)init
{
    self.percent_count = 0;
    return self;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSScanner * scanner = [NSScanner scannerWithString:string];
    int val;
    //7int Dotcount =0;
    BOOL isInt = [scanner scanInt:&val] && [scanner isAtEnd];
    if([self.control_type isEqualToString:@"percent"])
    {   
        if([string isEqualToString: @"."])
        {
            NSString * substring = [textField.text substringFromIndex:0];
            NSRange range = [substring rangeOfString:@"."];
            if(range.location == NSNotFound)
            {
                countflag = TRUE;
                //samman sir code begins
                NSString * text = textField.text;
                if ([string length] != 0)
                    text = [NSString stringWithFormat:@"%@%@", text, string];
                else
                    text = [text substringToIndex:[text length]-1];
                [delegate didChangeText:text];
                //code ends
                return TRUE;
            }
            
            return FALSE;
        }
        
        if (!isInt && (![string length] == 0))
            return  NO;
        if(countflag == TRUE)
        {
            NSString * substring = [textField.text substringFromIndex:0];
            NSRange range = [substring rangeOfString:@"."];
            NSInteger textlength = [textField.text length];
            NSUInteger rangeLength = range.location;
            NSInteger forceLength = textlength - rangeLength;
          
            if(forceLength > 2)
            {
                return NO;
            }
           
        }
        //samman sir code begins
        NSString * text = textField.text;
        if ([string length] != 0)
            text = [NSString stringWithFormat:@"%@%@", text, string];
        else
            text = [text substringToIndex:[text length]-1];
        [delegate didChangeText:text];
        //code ends
        return TRUE;
    }
    if([self.control_type isEqualToString:@"currency"])
    {
        if([string isEqualToString: @"."])
        {
            NSString * substring = [textField.text substringFromIndex:0];
            NSRange range = [substring rangeOfString:@"."];
            if(range.location == NSNotFound)
            {
                countflag = TRUE;
                //samman sir code begins
                NSString * text = textField.text;
                if ([string length] != 0)
                    text = [NSString stringWithFormat:@"%@%@", text, string];
                else
                    text = [text substringToIndex:[text length]-1];
                [delegate didChangeText:text];
                //code ends
                return TRUE;
            }
            
            return FALSE;
        }
            
        if (!isInt && (![string length] == 0))
            return  NO;
        if(countflag == TRUE)
        {
            NSString * substring = [textField.text substringFromIndex:0];
            NSRange range = [substring rangeOfString:@"."];
            NSInteger textlength = [textField.text length];
            NSUInteger rangeLength = range.location;
            NSInteger forceLength = textlength - rangeLength;
            
            if(forceLength > 2)
            {
                return NO;
            }
            
        }
        //samman sir code begins
        NSString * text = textField.text;
        if ([string length] != 0)
            text = [NSString stringWithFormat:@"%@%@", text, string];
        else
            text = [text substringToIndex:[text length]-1];
        [delegate didChangeText:text];
        //code ends
        return TRUE;
    }
    if([self.control_type isEqualToString:@"double"])
    {
        if([string isEqualToString: @"."])
        {
            NSString * substring = [textField.text substringFromIndex:0];
            NSRange range = [substring rangeOfString:@"."];
            if(range.location == NSNotFound)
            {
                countflag = TRUE;
                //samman sir code begins
                NSString * text = textField.text;
                if ([string length] != 0)
                    text = [NSString stringWithFormat:@"%@%@", text, string];
                else
                    text = [text substringToIndex:[text length]-1];
                [delegate didChangeText:text];
                //code ends
                return TRUE;
            }
            
            return FALSE;
        }
        
        if (!isInt && (![string length] == 0))
            return  NO;
        if(countflag == TRUE)
        {
            NSString * substring = [textField.text substringFromIndex:0];
            NSRange range = [substring rangeOfString:@"."];
            NSInteger textlength = [textField.text length];
            NSUInteger rangeLength = range.location;
            NSInteger forceLength = 0;
            if (range.length > 0)
                forceLength = textlength - rangeLength;
            
            if(forceLength > 2)
            {
                if([string length] == 0)
                {
                    //samman sir code begins
                    NSString * text = textField.text;
                    if ([string length] != 0)
                        text = [NSString stringWithFormat:@"%@%@", text, string];
                    else
                        text = [text substringToIndex:[text length]-1];
                    [delegate didChangeText:text];
                    //code ends
                    return YES;
                }
                return NO;
            }
            
        }
        NSString * text = textField.text;
        if ([string length] != 0)
            text = [NSString stringWithFormat:@"%@%@", text, string];
        else
            text = [text substringToIndex:[text length]-1];
        [delegate didChangeText:text];

        [delegate didChangeText:text];
        return TRUE;

    }
    if([self.control_type isEqualToString:@"phone"])
    {
        if (!isInt && (![string length] == 0))
            return  NO;
        //samman sir code begins
        NSString * text = textField.text;
        if ([string length] != 0)
            text = [NSString stringWithFormat:@"%@%@", text, string];
        else
            text = [text substringToIndex:[text length]-1];
        [delegate didChangeText:text];
        //code ends
        return  TRUE;

    }
    if (!isInt && (![string length] == 0))
        return  NO;
    //samman sir code begins
    NSString * text = textField.text;
    if ([string length] != 0)
        text = [NSString stringWithFormat:@"%@%@", text, string];
    else
        text = [text substringToIndex:[text length]-1];
    [delegate didChangeText:text];
    //code ends
    return  TRUE;

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{    
    CTextField * parent = delegate;
    [parent.controlDelegate controlIndexPath:parent.indexPath];
    return YES;
}

/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
{
    NSString * text = textField.text;
    if ([string length] != 0)
        text = [NSString stringWithFormat:@"%@%@", text, string];
    else
        text = [text substringToIndex:[text length]-1];

    [delegate didChangeText:text];
    return YES;
}
*/


@end
