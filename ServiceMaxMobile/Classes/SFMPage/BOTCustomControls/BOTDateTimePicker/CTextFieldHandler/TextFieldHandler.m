//
//  TextFieldHandler.m
//  CustomClassesipad
//
//  Created by Developer on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TextFieldHandler.h"
#import "BOTGlobals.h"
#import "CtextFieldWithDatePicker.h"

@implementation TextFieldHandler 

@synthesize delegate;
@synthesize pickerFrame;
@synthesize super_view;
@synthesize datepicker;
@synthesize popOver;
@synthesize date;
@synthesize classdelegate;

- (id) init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
   [self didShowDatePicker];
    return NO;
}

- (void)didShowDatePicker
{
    CtextFieldWithDatePicker * parent = (CtextFieldWithDatePicker *)delegate;
    [parent.controlDelegate controlIndexPath:parent.indexPath];

    datepicker = [[DatePickerClass alloc] initWithNibName:@"DatePickerClass" bundle:nil];
    datepicker.delegate = delegate;
    classdelegate = delegate;
   
    // datepicker.picker.date=date;
    [date release];
    datepicker.datePickerDelegate = self;
    
    datePickerPopOver = [[UIPopoverController alloc] initWithContentViewController:datepicker];
    datePickerPopOver.delegate = datepicker;
    
    [datePickerPopOver setPopoverContentSize:datepicker.view.frame.size];
    
    datepicker.delegate = delegate;
    CGRect rect = CGRectMake(0, 0, pickerFrame.size.width, pickerFrame.size.height);
    
    //10775- Shubha
    if (super_view.window != nil) {
        
        [datePickerPopOver presentPopoverFromRect:rect inView:super_view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }
    [parent.controlDelegate resignAllPrevResponsder:parent.indexPath];
    [parent.controlDelegate controlIndexPath:parent.indexPath];
    
    [classdelegate setDatePickerDatetoTextFielddate];
}

-(void) tapDateTimePicker:(id)sender
{
    [self didShowDatePicker];
    
}

#pragma mark - DatePickerClass Delegate
- (void) didDatePickerDismiss
{
    datepicker.delegate = nil;
    datepicker.datePickerDelegate = nil;
    [datePickerPopOver dismissPopoverAnimated:YES];
    [datePickerPopOver release];
    [datepicker release];
}

@end