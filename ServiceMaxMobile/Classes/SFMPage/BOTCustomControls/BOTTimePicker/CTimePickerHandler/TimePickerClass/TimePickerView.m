//
//  TimePickerView.m
//  CustomClassesipad
//
//  Created by Developer on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TimePickerView.h"


@implementation TimePickerView
@synthesize picker;
@synthesize delegate;
@synthesize TimePickerDelegate;



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
    [picker release];
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
    [picker release];
    picker = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}
- (IBAction)timePickerValueChanged:(id)sender 
{
     NSDateFormatter *frm=[[[NSDateFormatter alloc] init] autorelease];
    [frm  setDateFormat:@"hh:mm:ss a"];
     NSString *string=[frm stringFromDate:picker.date];
    [delegate setTextBoxToPickerValue:string];
    
    
}
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if ([TimePickerDelegate respondsToSelector:@selector(didDatePickerDismiss)])
        [TimePickerDelegate didTimePickerDismiss];
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}


@end
