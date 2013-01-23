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
extern void SVMXLog(NSString *format, ...);

@interface MasterViewController ()
@property(retain, nonatomic) NSMutableArray *sfmArray;
@end

@implementation MasterViewController
@synthesize sfmArray = _sfmArray;
@synthesize searchCriteria,searchString,searchLimitString;
@synthesize searchFilterSwitch;
@synthesize pickerData;
@synthesize searchLimitData;
@synthesize searchCriteriaLabel;
@synthesize includeOnlineResultLabel;
@synthesize limitShowLabel;
@synthesize limitRecordLabel;
@synthesize inputAccessoryView;
@synthesize detailView;
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([textField tag] == 0)
    {
        SearchCriteriaViewController *searchPicker = [[SearchCriteriaViewController alloc] init];
        searchPicker.pickerData = pickerData ;
        searchPicker.tag = [textField tag];
        UIPopoverController *pop = [[UIPopoverController alloc] initWithContentViewController:searchPicker];
        searchPicker.pickerDelegate = self;
        CGRect frame = [textField frame];
        frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [pop setPopoverContentSize:searchPicker.view.frame.size];
        [pop presentPopoverFromRect:frame inView:searchCriteria permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
        NSInteger indexOfText = [searchPicker.pickerData indexOfObject:textField.text];
        [searchPicker.picker selectRow:indexOfText inComponent:0 animated:YES];

        [searchPicker release];

        return NO;
    }
    if([textField tag] == 2)
    {
        SearchCriteriaViewController *searchPicker = [[SearchCriteriaViewController alloc] init];
        searchPicker.pickerData = searchLimitData ;
        searchPicker.tag = [textField tag];
        UIPopoverController *pop = [[UIPopoverController alloc] initWithContentViewController:searchPicker];
        searchPicker.pickerDelegate = self;
        CGRect frame = [textField frame];
        frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [pop setPopoverContentSize:searchPicker.view.frame.size];
        [pop presentPopoverFromRect:frame inView:searchLimitString permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
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
        searchLimitData = [[NSArray alloc] initWithObjects:@"25",@"50",@"75",@"100", nil];
    }
    return self;
}
							
- (void)dealloc
{
    [limitShowLabel release];
    [limitRecordLabel release];
    [searchLimitString release];
    [searchLimitData release];
    [searchCriteriaLabel release];
    [searchFilterSwitch release];
    [searchString release];
    [searchCriteria release];
    [_sfmArray release];
    [super dealloc];
}
- (void) reachabilityChanged: (NSNotification* )notification 
{
    SMLog(@"Notification :-%@",[notification name]);
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    if([appDelegate isInternetConnectionAvailable])
    {
            SMLog(@"Internet is Available");
            searchFilterSwitch.enabled=TRUE;
    }
    else
    {
        SMLog(@"Internet is Not Available");
        [searchFilterSwitch setOn:NO];
        searchFilterSwitch.enabled=FALSE;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [searchCriteria setText:[pickerData objectAtIndex:0]];
    [searchLimitString setText:[searchLimitData objectAtIndex:0]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reachabilityChanged:) 
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    iServiceAppDelegate * appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    if([appDelegate isInternetConnectionAvailable])
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
    
    if([appDelegate isCameraAvailable])
    {
        UIView *barCodeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 46)];
        barCodeView.backgroundColor=[UIColor clearColor];
        barCodeView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"accessoryView_bg.png"]];
        UIButton *barCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(676, 4, 72, 37)];
        [barCodeButton setBackgroundImage:[UIImage imageNamed:@"BarCodeButton.png"] forState:UIControlStateNormal];
        barCodeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [barCodeButton addTarget:self 
                          action:@selector(launchBarcodeScanner:) 
                forControlEvents:UIControlEventTouchUpInside];
        [barCodeView addSubview:barCodeButton];
        self.inputAccessoryView = barCodeView;
    }

}
- (IBAction) launchBarcodeScanner:(id)sender
{
    
    [self resignFirstResponder];
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self.detailView.mainView  presentViewController: reader
                        animated: YES completion:nil];
    [reader release];
    SMLog(@"Launch Bar Code Scanner");
}

#pragma mark - ZBar Delegate Methods

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    @try{
    id<NSFastEnumeration> results =[info objectForKey: ZBarReaderControllerResults];
    SMLog(@"result=%@",results);
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    
    searchString.text = symbol.data;
    SMLog(@"symbol.data=%@",symbol.data);    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissViewControllerAnimated: YES completion:nil];
    }@catch (NSException *exp) {
        SMLog(@"Exception Name MasterViewController :imagePickerController %@",exp.name);
        SMLog(@"Exception Reason MasterViewController :imagePickerController %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.searchCriteriaLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//    return YES;
    
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(void) setTextField :(NSString *)str withTag:tag
{
    if(tag == 0)
        searchCriteria.text = str;
    else if(tag == 2)
        searchLimitString.text = str;
}
- (IBAction) backgroundSelected:(id)sender
{
    [searchString resignFirstResponder];
}
@end
