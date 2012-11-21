//
//  DatePickerClass.m
//  CustomClassesipad
//
//  Created by Developer on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DatePickerClass.h"
#import "BOTGlobals.h"

@implementation DatePickerClass

@synthesize picker;
@synthesize delegate, datePickerDelegate;
@synthesize popOverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
         
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) setDate:(NSDate *)_date
{
    picker.date = _date;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [picker release];
    picker = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)pickerValueChanged:(id)sender
{
    NSDateFormatter *frm=[[NSDateFormatter alloc] init];
    [frm  setDateFormat:DATETIMEFORMAT];
    NSString *string = [frm stringFromDate:picker.date];
    [delegate setTextBoxToPickerValue:string];
    
    [frm release];
}

- (IBAction)DeleteTextFieldValue:(id)sender 
{
    [delegate deleteTextFieldValue];
    if ([datePickerDelegate respondsToSelector:@selector(didDatePickerDismiss)])
        [datePickerDelegate didDatePickerDismiss];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSDateFormatter *frm=[[[NSDateFormatter alloc] init] autorelease];
    [frm  setDateFormat:DATETIMEFORMAT];
    NSString *string = [frm stringFromDate:picker.date];
    [delegate setTextBoxToPickerValue:string];

    if ([datePickerDelegate respondsToSelector:@selector(didDatePickerDismiss)])
        [datePickerDelegate didDatePickerDismiss];
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

@end
