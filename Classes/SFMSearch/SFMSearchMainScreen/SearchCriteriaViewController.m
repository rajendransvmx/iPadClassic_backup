//
//  SearchCriteriaViewController.m
//  SFMSearch
//
//  Created by Siva Manne on 12/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import "SearchCriteriaViewController.h"

@interface SearchCriteriaViewController ()

@end

@implementation SearchCriteriaViewController
@synthesize picker;
@synthesize pickerData;
@synthesize tag;
@synthesize pickerDelegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) dealloc
{
    [picker release];
    [pickerData release];
    [super dealloc];
}
#pragma mark - Picker View Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [pickerData count];
    
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component 
{
    return [self.pickerData  objectAtIndex:row]; 
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString * str = nil;
    str = [pickerData objectAtIndex:row];
    [pickerDelegate setTextField:str withTag:tag];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [popoverController release];
}

@end
