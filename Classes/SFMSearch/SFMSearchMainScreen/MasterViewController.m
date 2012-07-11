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
@property(retain, nonatomic) NSMutableArray *sfmArray;
@end

@implementation MasterViewController
@synthesize sfmArray = _sfmArray;
@synthesize searchCriteria,searchString;
@synthesize searchFilterSwitch;
@synthesize pickerData;
@synthesize searchCriteriaLabel;
@synthesize includeOnlineResultLabel;
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([textField tag] == 0)
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
    return YES;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"Master", @"Master");
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *contains = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_CONTAINS];
        NSString *exact_match = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_EXTACT_MATCH];
        NSString *ends_with = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_ENDS_WITH];
        NSString *starts_with = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_CRITERIA_STARTS_WITH];
        pickerData = [[NSArray alloc] initWithObjects:contains,exact_match,ends_with,starts_with, nil];
    }
    return self;
}
							
- (void)dealloc
{
    [searchCriteriaLabel release];
    [searchFilterSwitch release];
    [searchString release];
    [searchCriteria release];
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
    searchString.placeholder = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_SRCH_ENTER_TEXT];
    searchCriteriaLabel.text = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_SRCH_Criteria];
    includeOnlineResultLabel.text = [appDelegate.wsInterface.tagsDictionary objectForKey:INCLUDE_ONLINE_RESULTS];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.searchCriteriaLabel = nil;
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
- (IBAction) backgroundSelected:(id)sender
{
    [searchString resignFirstResponder];
}
@end
