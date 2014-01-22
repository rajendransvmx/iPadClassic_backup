//
//  CusTextViewHandler.m
//  CustomClassesipad
//
//  Created by Developer on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CusTextViewHandler.h"
#import "CusTextView.h"
#import "AppDelegate.h"

@implementation CusTextViewHandler
@synthesize POP;
@synthesize delegate;
@synthesize popOverView;
@synthesize lableValue;

//Radha DefectFix - 5721
@synthesize textlength;


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
	CusTextView * parent = delegate;
    [parent.controlDelegate controlIndexPath:parent.indexPath];

	//Radha DefectFix - 5721
	AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	self.textlength = [appDelegate.dataBase getTextareaLengthForFieldApiName:parent.fieldAPIName objectName:parent.object_api_name];

        
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	//Radha DefectFix - 5721
	SMLog(kLogLevelVerbose,@"%d", self.textlength);
	//Code change for keyboard retracting ---> 31/08/2012
    if ( [textView.text length] >= self.textlength)
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
     if((range.location == 0) && ([text length] == 0))//9082
        currentText = @"";

    [delegate didChangeText:currentText];
    [textView scrollRangeToVisible:range];

    return YES;
}

@end
