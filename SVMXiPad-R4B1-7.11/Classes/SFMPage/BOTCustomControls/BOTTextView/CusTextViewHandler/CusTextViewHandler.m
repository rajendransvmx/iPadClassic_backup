//
//  CusTextViewHandler.m
//  CustomClassesipad
//
//  Created by Developer on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CusTextViewHandler.h"
#import "CusTextView.h"

@implementation CusTextViewHandler
@synthesize POP;
@synthesize delegate;
@synthesize popOverView;
@synthesize lableValue;


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    CusTextView * parent = delegate;
    [parent.controlDelegate controlIndexPath:parent.indexPath];
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString * currentText = textView.text;
    if([currentText length] > 0)
    {
        if ([text length] != 0)
            currentText = [NSString stringWithFormat:@"%@%@", currentText, text];
        else
            currentText = [currentText substringToIndex:[currentText length]-1];
        
        [delegate didChangeText:currentText];
    }
    return YES;
}

@end
