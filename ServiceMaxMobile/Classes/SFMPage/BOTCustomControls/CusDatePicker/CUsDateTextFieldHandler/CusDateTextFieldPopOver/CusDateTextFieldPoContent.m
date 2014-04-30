//
//  CusDateTextFieldPoContent.m
//  CustomClassesipad
//
//  Created by Developer on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CusDateTextFieldPoContent.h"


@implementation CusDateTextFieldPoContent
@synthesize datePicker;
@synthesize datePickerDelegate;
@synthesize datepickerreleaseDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [datePicker release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [datePicker release];
    datePicker = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSDateFormatter *frm =[[[NSDateFormatter alloc] init] autorelease];
    [frm setDateFormat:@"MMM dd yyyy"];
    NSString * date = [frm stringFromDate:datePicker.date];
    [datePickerDelegate setDateTextField:date];
    
    [datepickerreleaseDelegate cusDatePickerRelease];
}

- (IBAction)DatePickerValueChanhed:(id)sender 
{
    NSDateFormatter *frm =[[[NSDateFormatter alloc] init] autorelease];
    [frm setDateFormat:@"MMM dd yyyy"];
    NSString * date = [frm stringFromDate:datePicker.date];
    [datePickerDelegate setDateTextField:date];
    
}
- (IBAction)deleteDatePickerCOntrolValue:(id)sender
{
    [datePickerDelegate deleteDateTextField];
    [datepickerreleaseDelegate cusDatePickerRelease];
}
@end
