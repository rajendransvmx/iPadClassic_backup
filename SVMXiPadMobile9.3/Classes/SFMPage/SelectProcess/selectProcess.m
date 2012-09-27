//
//  selectProcess.m
//  project
//
//  Created by Samman on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "selectProcess.h"
#import "DetailViewController.h"

@implementation selectProcess

@synthesize delegate, popOver;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)editClicked:(id)sender
{
    //DetailViewController *dv = [[DetailViewController alloc]init];
    //dv.isInViewMode = YES;
    [delegate isEditable];

}

- (IBAction)viewClicked:(id)sender
{
    [delegate isViewable];
}


- (IBAction) btnClick:(id)sender
{
    [delegate didSubmitProcess:processIdField.text forRecord:recordIdField.text];
    [popOver dismissPopoverAnimated:YES];
    [popOver release];
}

- (void) setProcessId:(NSString *)processId forRecordId:(NSString *)recordId
{
    processIdField.text = processId;
    recordIdField.text = recordId;
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [processIdField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [processIdField release];
    processIdField = nil;
    [recordIdField release];
    recordIdField = nil;

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
