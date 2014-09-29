//
//  CTextFieldHandlerNeum.m
//  CustomClassesipad
//
//  Created by Developer on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CTextFieldHandlerNeum.h"
#import "CTextField.h"
#import "Utility.h"

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
        BOOL isNegative = FALSE; //10346
        
        if([string isEqualToString: @"."])
        {
            NSString * substring = [textField.text substringFromIndex:0];
            NSRange dotrange = [substring rangeOfString:@"."];
            if(dotrange.location == NSNotFound)
            {
                countflag = TRUE;
                //10346
                NSString * text = textField.text;
                NSMutableString * teststring = [NSMutableString stringWithString:text];
                if ([string length] != 0)
                {
                    [teststring insertString:string atIndex:range.location];
                    text = teststring;
                }
                else
                    text = [text substringToIndex:[text length]-1];
                [delegate didChangeText:text];
                //code ends
                return TRUE;
            }
            
            return FALSE;
        }
        //10346
        else if ([string isEqualToString:@"-"] && range.location == 0)
        {
            isNegative = TRUE;
        }
        
        if (!isInt && (![string length] == 0) && !isNegative)
            return  NO;
    
        if(countflag == TRUE)
        {
            NSString * substring = [textField.text substringFromIndex:0];
            NSRange dotrange = [substring rangeOfString:@"."];
            NSInteger textlength = [textField.text length];
            NSUInteger rangeLength = dotrange.location;
            NSInteger forceLength = textlength - rangeLength;
          
            if(forceLength > 2 )
            {
                if([string length] == 0 || isNegative)
                {
                    //10346
                    NSString * text = textField.text;
                    NSMutableString * teststring = [NSMutableString stringWithString:text];
                    if ([string length] != 0)
                    {
                        [teststring insertString:string atIndex:range.location];
                        text = teststring;
                    }
                    else
                        text = [text substringToIndex:[text length]-1];
                    [delegate didChangeText:text];
                    //code ends
                    return YES;
                }
                return NO;
            }
           
        }
        //10346
        NSString * text = textField.text;
        NSMutableString * teststring = [NSMutableString stringWithString:text];
        if ([string length] != 0)
        {
            [teststring insertString:string atIndex:range.location];
            text = teststring;
        }
        else
            text = [text substringToIndex:[text length]-1];
        [delegate didChangeText:text];
        //code ends
        return TRUE;
    }
    if([self.control_type isEqualToString:@"currency"])
    {
        BOOL isNegative = FALSE; //10346
        
        if([string isEqualToString: @"."])
        {
            NSString * substring = [textField.text substringFromIndex:0];
            NSRange dotrange = [substring rangeOfString:@"."];
            if(dotrange.location == NSNotFound)
            {
//                countflag = TRUE;
                //10346
                NSString * text = textField.text;
                NSMutableString * teststring = [NSMutableString stringWithString:text];
                if ([string length] != 0)
                {
                    [teststring insertString:string atIndex:range.location];
                    text = teststring;
                }
                else
                    text = [text substringToIndex:[text length]-1];
                [delegate didChangeText:text];
                //code ends
                return TRUE;
            }
            
            return FALSE;
        }
        //10346
        else if ([string isEqualToString:@"-"] && range.location == 0)
        {
            isNegative = TRUE;
        }
        
        if (!isInt && (![string length] == 0) && !isNegative)
            return  NO;
      
        //10346
        if([Utility containsString:@"." inString:textField.text])
        {
            countflag = TRUE;
        }
        else
        {
            countflag = FALSE;
        }
        
        //10346
        if (precisionValue == 0) //Handling backward compatilbilty.
        {
            if(countflag == TRUE)
            {
                NSString * substring = [textField.text substringFromIndex:0];
                NSRange dotrange = [substring rangeOfString:@"."];
                NSInteger textlength = [textField.text length];
                NSUInteger rangeLength = dotrange.location;
                NSInteger forceLength = textlength - rangeLength;
                
                if(forceLength > 2)
                {
                    if([string length] == 0 || isNegative)
                    {
                        NSString * text = textField.text;
                        NSMutableString * teststring = [NSMutableString stringWithString:text];
                        if ([string length] != 0)
                        {
                            [teststring insertString:string atIndex:range.location];
                            text = teststring;
                        }
                        else
                            text = [text substringToIndex:[text length]-1];
                        [delegate didChangeText:text];
                        //code ends
                        return YES;
                    }
                    return NO;
                }
                
            }

        }
        
        //10346
        else if (!isNegative)
        {
            NSUInteger textlength = 0;
            if(countflag == TRUE)
            {
                if ([textField.text hasPrefix:@"-"])
                {
                    textlength = textField.text.length - 1;
                }
                else
                {
                    textlength = textField.text.length;
                }
                if (textlength > precisionValue)
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
            else
            {
                if ([textField.text hasPrefix:@"-"])
                {
                    textlength = textField.text.length - 1;
                    if (textlength == length && [string length] > 0)
                    {
                        return NO;
                    }
                }
                else
                {
                    textlength = textField.text.length + string.length;
                }
                
                if (textlength > length)
                {
                    if([string length] == 0)
                    {
                        //10346
                        NSString * text = textField.text;
                        NSMutableString * teststring = [NSMutableString stringWithString:text];
                        if ([string length] != 0)
                        {
                            [teststring insertString:string atIndex:range.location];
                            text = teststring;
                        }
                        else
                            text = [text substringToIndex:[text length]-1];
                        [delegate didChangeText:text];
                        //code ends
                        return YES;
                    }
                    return NO;
                }
            }
        }
        //10346
        NSString * text = textField.text;
        NSMutableString * teststring = [NSMutableString stringWithString:text];
        if ([string length] != 0)
        {
            [teststring insertString:string atIndex:range.location];
            text = teststring;
        }
        else
            text = [text substringToIndex:[text length]-1];
        [delegate didChangeText:text];
        //code ends
        return TRUE;
    }
    if([self.control_type isEqualToString:@"double"])
    {
        BOOL isNegative = FALSE; //10346
        
        if([string isEqualToString: @"."])
        {
            NSString * substring = [textField.text substringFromIndex:0];
            NSRange dotrange = [substring rangeOfString:@"."];
            if(dotrange.location == NSNotFound)
            {
                countflag = TRUE;
                //10346
                NSString * text = textField.text;
                NSMutableString * teststring = [NSMutableString stringWithString:text];
                if ([string length] != 0)
                {
                    [teststring insertString:string atIndex:range.location];
                    text = teststring;
                }
                else
                    text = [text substringToIndex:[text length]-1];
                [delegate didChangeText:text];
                //code ends
                return TRUE;
            }
            
            return FALSE;
        }
        //10346
        else if ([string isEqualToString:@"-"] && range.location == 0)
        {
            isNegative = TRUE;
        }
        
        if (!isInt && (![string length] == 0) && !isNegative)
            return  NO;
        
        if(countflag == TRUE)
        {
            NSString * substring = [textField.text substringFromIndex:0];
            NSRange dotrange = [substring rangeOfString:@"."];
            NSInteger textlength = [textField.text length];
            NSUInteger rangeLength = dotrange.location;
            NSInteger forceLength = 0;
            if (dotrange.length > 0)
                forceLength = textlength - rangeLength;
            
            if(forceLength > 2)
            {
                if([string length] == 0 || isNegative)
                {
                    //10346
                    NSString * text = textField.text;
                    NSMutableString * teststring = [NSMutableString stringWithString:text];
                    if ([string length] != 0)
                    {
                        [teststring insertString:string atIndex:range.location];
                        text = teststring;
                    }
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
        //10346
        NSString * text = textField.text;
        NSMutableString * teststring = [NSMutableString stringWithString:text];
        if ([string length] != 0)
        {
            [teststring insertString:string atIndex:range.location];
            text = teststring;
        }
        else
            text = [text substringToIndex:[text length]-1];
        [delegate didChangeText:text];
        //code ends
        return  TRUE;

    }
    if (!isInt && (![string length] == 0))
        return  NO;
    //10346
    NSString * text = textField.text;
    NSMutableString * teststring = [NSMutableString stringWithString:text];
    if ([string length] != 0)
    {
        [teststring insertString:string atIndex:range.location];
        text = teststring;
    }
    else
        text = [text substringToIndex:[text length]-1];
    [delegate didChangeText:text];
    //code ends
    return  TRUE;

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{    
    CTextField * parent = delegate;
    precisionValue = parent.precision; //10346
    length = parent.length;
    countflag = FALSE;

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
