//
//  CusDateTextFieldHandler.m
//  CustomClassesipad
//
//  Created by Developer on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CusDateTextFieldHandler.h"
#import "CusDateTextField.h"

@implementation CusDateTextFieldHandler
@synthesize delegate;
@synthesize pickerFrame;
@synthesize superView;
@synthesize contentView;
@synthesize popOver;
@synthesize PODatePickerdelegate;

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self didShowDateTextField];
    return NO;
    
}
- (void)didShowDateTextField
{
    CusDateTextField * parent = (CusDateTextField *)delegate;
    [parent.controlDelegate controlIndexPath:parent.indexPath];

    contentView = [[CusDateTextFieldPoContent alloc] init];
    contentView.datePickerDelegate = delegate;
    contentView.datepickerreleaseDelegate = self;
    PODatePickerdelegate = delegate;
    popOver = [[UIPopoverController alloc] initWithContentViewController:contentView];
    [popOver setPopoverContentSize:contentView.view.frame.size];
    [popOver presentPopoverFromRect:CGRectMake(0, 0, pickerFrame.size.width, pickerFrame.size.height) inView:superView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    popOver.delegate = contentView;
    [PODatePickerdelegate setPODatepickerValue];
}

-(void)tapDatePicker:(id)sender
{
    [self didShowDateTextField];
}
-(void) cusDatePickerRelease;
{
    [popOver dismissPopoverAnimated:YES];
    [popOver release];
}
@end
