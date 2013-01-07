    //
//  LocationPopOver.m
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 21/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LocationPopOver.h"
#import "iServiceAppDelegate.h"

@implementation LocationPopOver

@synthesize delegate;

@synthesize popOver;
@synthesize workOrder, workOrderDetail, workOrderContact;
@synthesize annotationIndex;

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
    workOrderLabel.text = workOrder;
    workOrderDetailLabel.text = workOrderDetail;
    workOrderContactText.text = workOrderContact;
    if (workOrderDetail == nil)
    {
        jobDetailsButton.enabled = NO;
        self.view = homeLocationView;
        homeLocationAddress.text = workOrderContact;
    }
    
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    [drivingDirectionsButton setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:MAP_POPOVER_DRIVING_DIRECTION_BUTTON] forState:UIControlStateNormal];
    [jobDetailsButton setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:MAP_POPOVER_JOB_DETAILS_BUTTON] forState:UIControlStateNormal];
    [homeLocationDrivingDirections setTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:MAP_POPOVER_DRIVING_DIRECTION_BUTTON] forState:UIControlStateNormal];
}

- (void) disableJobDetails
{
    jobDetailsButton.enabled = NO;
}

- (IBAction) DrivingDirections
{
    [delegate showDrivingDirectionsForAnnotationIndex:annotationIndex];
    [popOver dismissPopoverAnimated:YES];
}

- (IBAction) JobDetails
{
    [delegate showJobDetailsForAnnotationIndex:annotationIndex];
    [popOver dismissPopoverAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [workOrderLabel release];
    [workOrderDetailLabel release];
    [workOrderContactText release];
    [workOrder release];
    [workOrderDetail release];
    [workOrderContact release];
    
    [super dealloc];
}


@end
