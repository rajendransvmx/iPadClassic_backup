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
	//Code change for keyboard retracting ---> 31/08/2012
    if ( [textView.text length] >= 255)
    {
		if ([text isEqualToString:@""])
		{
			//[delegate didChangeText:text];
		}else{
//			[textView resignFirstResponder];
			return NO;
		}
      
    }
    NSString * currentText = textView.text;
    if ([text length] != 0)
        currentText = [NSString stringWithFormat:@"%@%@", currentText, text];
    else if ([text length] > 0)
        currentText = [currentText substringToIndex:[currentText length]-1];
    
    [delegate didChangeText:currentText];
    return YES;
}

@end
