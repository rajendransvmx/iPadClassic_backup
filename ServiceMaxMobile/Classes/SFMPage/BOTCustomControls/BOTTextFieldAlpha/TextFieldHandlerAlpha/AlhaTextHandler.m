//
//  AlhaTextHandler.m
//  CustomClassesipad
//
//  Created by Developer on 4/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlhaTextHandler.h"
#import "cusTextFieldAlpha.h"
#import "AppDelegate.h"
void SMXLog(const char *methodContext,NSString *message);
@implementation AlhaTextHandler

@synthesize delegate;
@synthesize POC;
@synthesize alphaContent;
@synthesize popOverView;
@synthesize rect;
@synthesize control_type;
@synthesize isInViewMode;

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    cusTextFieldAlpha * parent = (cusTextFieldAlpha *)delegate;
    [parent.controlDelegate controlIndexPath:parent.indexPath];
    
    if (!isInViewMode)
    {
        if ([control_type isEqualToString:@"url"])
        {
            NSURL * url = [NSURL URLWithString:textField.text];
            [[UIApplication sharedApplication] openURL:url];
            return NO;
        }
    }

    return YES;
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    if([control_type isEqualToString:@"email"])
    {
        /*
        BOOL result;
        NSString * emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        result = [emailTest evaluateWithObject:textField.text];
        if (result == YES)
        {
            return YES;
        }
        else if ([textField.text length] > 0 )
        {
            SMLog(@"email not in proper format");
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:warning message:invalidEmail delegate:self cancelButtonTitle:alert_ok otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
            
            return YES;
        }
        */
        return YES;

    }
    
    if([control_type isEqualToString:@"string"])
    {
        return YES;
    }

    if([control_type isEqualToString:@"url"])
    {
        //Aparna: Fix for the defect 4547
        NSString *text = textField.text;
        if ([text length] > 0)
         {
             
             if (!([text hasPrefix:@"http://"] || [text hasPrefix:@"https://"] || [text hasPrefix:@"ftp://"] || [text isEqualToString:@"http://"] || [text isEqualToString:@"https://"] || [text isEqualToString:@"ftp://"]))
             {
                 text = [NSString stringWithFormat:@"http://%@",text];
                 [textField setText:text];
             }
             
             
             /*BOOL result;
             NSString * urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
             NSPredicate * urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
             result =  [urlTest evaluateWithObject:textField.text];
             if (result == YES )
             {
                 return YES;
             }
             else
             {
                 UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:warning message:invalidUrl delegate:self cancelButtonTitle:alert_ok otherButtonTitles:nil, nil];
                 [alertView show];
                 [alertView release];
                 return YES; 
             }*/

         }
        [delegate didChangeText:text];
    }

    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
{
    id text = textField.text;
    
    if ([string length] != 0)
    {
        //text = [NSString stringWithFormat:@"%@%@", text, string];
        //Aparna: Substring is added to the specified location instead of appending it to the string.
        text = (NSMutableString *)[NSMutableString stringWithString:text];
        [text insertString:string atIndex:range.location];
    }
    else
    {
//        text = [text substringToIndex:[text length]-1];
        //Aparna: Substring is deleted from the specified location instead of removing the last character.
        
        text = (NSMutableString *)[NSMutableString stringWithString:text];
        [text deleteCharactersInRange:range];
    }

    [delegate didChangeText:text];

    return YES;
}
//  Unused Methods
//- (void) releaseTextHandlerPO
//{
//    [POC release];
//}

@end
