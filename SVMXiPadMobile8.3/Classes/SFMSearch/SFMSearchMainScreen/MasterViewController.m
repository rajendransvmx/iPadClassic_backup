//
//  MasterViewController.m
//  SFMSearchTemplate
//
//  Created by Siva Manne on 10/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewControllerForSFM.h"
#import "SearchCriteriaViewController.h"
#import "iServiceAppDelegate.h"
@interface MasterViewController ()
{
    NSMutableArray *_objects;
}
@property(retain, nonatomic) NSMutableArray *sfmArray;
@end

@implementation MasterViewController
@synthesize sfmArray = _sfmArray;
@synthesize searchCriteria,searchString;
@synthesize searchFilterSwitch;
@synthesize pickerData;
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    SearchCriteriaViewController *searchPicker = [[SearchCriteriaViewController alloc] init];
    searchPicker.pickerData = pickerData ;
    UIPopoverController *pop = [[UIPopoverController alloc] initWithContentViewController:searchPicker];
    searchPicker.pickerDelegate = self;
    [pop presentPopoverFromRect:[textField frame] inView:searchCriteria permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    [pop setPopoverContentSize:CGSizeMake(320, 216)];
    NSInteger indexOfText = [searchPicker.pickerData indexOfObject:textField.text];
    [searchPicker.picker selectRow:indexOfText inComponent:0 animated:YES];

    [searchPicker release];

    return NO;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Master", @"Master");
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        pickerData = [[NSArray alloc] initWithObjects:@"Contains",@"Exact Match",@"Ends With",@"Starts With", nil];
    }
    return self;
}
							
- (void)dealloc
{
    [searchFilterSwitch release];
    [searchString release];
    [searchCriteria release];
    [_objects release];
    [_sfmArray release];
    [super dealloc];
}
- (void) reachabilityChanged: (NSNotification* )notification 
{
    NSLog(@"Notification :-%@",[notification name]);
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.isInternetConnectionAvailable)
    {
        NSLog(@"Internet is Available");
        searchFilterSwitch.enabled=TRUE;
    }
    else
    {
        NSLog(@"Internet is Not Available");
        [searchFilterSwitch setOn:NO];
        searchFilterSwitch.enabled=FALSE;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [searchCriteria setText:[pickerData objectAtIndex:0]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reachabilityChanged:) 
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.isInternetConnectionAvailable)
    {
        searchFilterSwitch.enabled=TRUE;
    }
    else
    {
        [searchFilterSwitch setOn:NO];
        searchFilterSwitch.enabled=FALSE;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(void) setTextField :(NSString *)str
{
    searchCriteria.text = str;
}

@end
