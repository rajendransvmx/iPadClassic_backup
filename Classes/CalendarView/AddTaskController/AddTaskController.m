    //
//  AddTaskController.m
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 17/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AddTaskController.h"
#import "CalendarController.h"
extern void SVMXLog(NSString *format, ...);

@implementation AddTaskController

@synthesize popOverController;
@synthesize taskView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [cancelBuuton setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:ADD_TASKS_CANCEL_BUTTON] forState:UIControlStateNormal];
    [cancelBuuton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	//Defect Fix :- 7454
    [cancelBuuton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
	cancelBuuton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [doneButton setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:ADD_TASKS_DONE_BUTTON] forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	//Defect Fix :- 7454
    [doneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
	doneButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    taskPrompt.text = [appDelegate.wsInterface.tagsDictionary objectForKey:ADD_TASKS_PROMPT];
    priority.text = [appDelegate.wsInterface.tagsDictionary objectForKey:ADD_TASKS_SET_PRIORITY_TITLE];
    
    NSString * high = [appDelegate.wsInterface.tagsDictionary objectForKey:ADD_TASKS_PRIORITY_HIGH];
    NSString * low = [appDelegate.wsInterface.tagsDictionary objectForKey:ADD_TASKS_PRIORITY_LOW];
    NSString * normal = [appDelegate.wsInterface.tagsDictionary objectForKey:ADD_TASKS_PRIORITY_NORMAL];
    // Set Picker to have only 3 values High, Medium, Low
    pickerValues = [[NSArray alloc] initWithObjects:low, normal, high, nil];
	
	[setPriorityLable setText:[appDelegate.wsInterface.tagsDictionary objectForKey:ADD_TASKS_SET_PRIORITY_TITLE]];
	//Defect Fix :- 7454
	setPriorityLable.lineBreakMode = UILineBreakModeTailTruncation;
	[enterTaskLabel setText:[appDelegate.wsInterface.tagsDictionary objectForKey:ADD_TASKS_PROMPT]];
	enterTaskLabel.font = [UIFont fontWithName:@"helvetica" size:20];
	//Defect Fix :- 7454
	enterTaskLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    return YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [textView release];
    textView = nil;
    [picker release];
    picker = nil;
    [cancelBuuton release];
    cancelBuuton = nil;
    [doneButton release];
    doneButton = nil;
    [taskPrompt release];
    taskPrompt = nil;
    [priority release];
    priority = nil;
	[enterTaskLabel release];
	enterTaskLabel = nil;
	[setPriorityLable release];
	setPriorityLable = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (NSMutableArray *) getTask
{
    //Shrinivas  --> Fix for Empty task getting created
    NSString *rawString = [textView text];
    NSCharacterSet * whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    
    if ([trimmed length] == 0) {
        SMLog(@"Empty String");
    }

    if ([textView.text length] > 0 && [trimmed length] != 0)
    {
        return [NSMutableArray arrayWithObjects:[pickerValues objectAtIndex:selectedPickerRow], textView.text, nil];
    }
    else
        return nil;
}

- (void)dealloc
{
    [cancelBuuton release];
    [doneButton release];
    [taskPrompt release];
    [priority release];
	[enterTaskLabel release];
	[setPriorityLable release];
    [super dealloc];
}

- (IBAction) Cancel
{
    [popOverController dismissPopoverAnimated:YES];
}

- (IBAction) Done
{
    [doneButton setEnabled:NO];
    [taskView AddTaskWithText:[self getTask]];
    [popOverController dismissPopoverAnimated:YES];
}

#pragma mark -
#pragma mark UIPickerView DataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [pickerValues count];
}

#pragma mark -
#pragma mark UIPickerView Delegate Methods


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [pickerValues objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedPickerRow = row;
}

@end
