//
//  TPTextFieldHandler.m
//  CustomClassesipad
//
//  Created by Developer on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TPTextFieldHandler.h"


@implementation TPTextFieldHandler
@synthesize timePicker;
@synthesize timePickerPopOver;
@synthesize delegate;
@synthesize pickerFrame;
@synthesize superView;
@synthesize classdelegate;



- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;

}
-(void) tapTimePicker:(id)sender
{
    timePicker = [[TimePickerView alloc] init];
    timePicker.delegate=delegate;
    timePicker.TimePickerDelegate =self;
    classdelegate=delegate;
       
    timePickerPopOver=[[UIPopoverController alloc] initWithContentViewController:timePicker];
    [timePickerPopOver setPopoverContentSize:timePicker.view.frame.size ];
    timePickerPopOver.delegate=timePicker;
    
    CGRect rect = CGRectMake(0, 0, pickerFrame.size.width, pickerFrame.size.height);
    [timePickerPopOver presentPopoverFromRect:rect inView:superView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [classdelegate setTimePickertoTextFielddate];
}
- (void) didTimePickerDismiss
{
    timePicker.delegate = nil;
    timePicker.TimePickerDelegate = nil;
    [timePicker release];
    [timePickerPopOver release];
}


@end
