//
//  SpinnerTFhandler.m
//  BOTCustmControll
//
//  Created by Developer on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SpinnerTFhandler.h"
#import "BotSpinnerTextField.h"

@implementation SpinnerTFhandler
@synthesize contentView;
@synthesize POC;
@synthesize rect;
@synthesize TextfieldView;
@synthesize delegate;
@synthesize spinnerData;
@synthesize setSpinnerValuedelegate;
@synthesize spinnerValue_index;
@synthesize flag;
@synthesize validFor;
@synthesize controllerName;
@synthesize isdependentPicklist;


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BotSpinnerTextField * parent = (BotSpinnerTextField *)delegate;
    [parent.controlDelegate controlIndexPath:parent.indexPath];
    
    setSpinnerValuedelegate = delegate;
    
    contentView = [[popOverContent alloc] init];
    if(isdependentPicklist && [controllerName length] != 0 && [validFor count] != 0)
    {
       contentView.spinnerData  = [setSpinnerValuedelegate  getValuesForDependentPickList];
    }
    else
    {
        //[setSpinnerValuedelegate clearTheDependentPickListValue];
        contentView.spinnerData = spinnerData;
    }
    
    contentView.spinnerDelegate = delegate;
    //setSpinnerValuedelegate = delegate;
     
    [setSpinnerValuedelegate setSpinnerValue];
    
    POC = [[UIPopoverController alloc] initWithContentViewController:contentView];
    [POC setPopoverContentSize:contentView.view.frame.size animated:YES];
    POC.delegate = contentView;
    [POC presentPopoverFromRect:CGRectMake(0, 0, rect.size.width, rect.size.height) inView:TextfieldView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
   
    NSInteger indexOfText = [spinnerData indexOfObject:textField.text];
    [contentView.valuePicker selectRow:indexOfText inComponent:0 animated:YES];
    
    return NO;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

@end
