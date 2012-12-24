//
//  DetailViewController.m
//  project
//
//  Created by Developer on 26/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"
#import "iServiceAppDelegate.h"
#import "ZKServerSwitchboard.h"
#import "WSIntfGlobals.h"
#import <QuartzCore/QuartzCore.h>
#import "LocalizationGlobals.h"
#import "LookupFieldPopover.h"

#import "SummaryViewController.h"
#import "TimerClass.h"
#import "Troubleshooting.h"
#import "Chatter.h"
#import "databaseIntefaceSfm.h"
#import "ManualDataSync.h"
extern void SVMXLog(NSString *format, ...);


@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end

@implementation DetailViewController


@synthesize updateGreenButtonFlag;
@synthesize parentReference;

@synthesize delegate, calendarDelegate;

@synthesize currentProcessId, currentRecordId;@synthesize toolbar = _toolbar;
@synthesize objectAPIName;

@synthesize detailItem = _detailItem;

@synthesize detailDescriptionLabel = _detailDescriptionLabel;

@synthesize popoverController = _myPopoverController, tableView, lbl1, lbl2, txtfld, txtfld1, line, isInEditDetail , header, editable,isInViewMode;
@synthesize webView;
@synthesize count;
@synthesize flag;

@synthesize sfwToolBar;
@synthesize Disclosure_Fields;
@synthesize Disclosure_Details;

@synthesize Disclosure_dict;
@synthesize barButtonItem_detail;
@synthesize currentEditRow;
@synthesize originalRect;
@synthesize  isKeyboardShowing;
@synthesize rootViewBarButton;

@synthesize selectedIndexPath;
@synthesize selectedRowForDetailEdit;

@synthesize didMultiAddAccessoryTapped;
@synthesize objectLabel;

@synthesize indicatorForAddRow;
@synthesize label_popOver;
@synthesize label_popOver_content;
@synthesize multi_add_search;
@synthesize multi_add_seach_object;
@synthesize mutlti_add_config;
@synthesize mutlti_add_label;
@synthesize multi_add_info;
@synthesize save_response_message;
@synthesize table_view_moved;

@synthesize detailTitle;
@synthesize mLookupDictionary;
@synthesize LabourValuesDictionary;
@synthesize showSyncUI;
@synthesize multiLookupPopover;
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInternetConnectionChange:) name:kInternetConnectionChanged object:nil];
		detailTitle = nil;
    }
    
    return self;
}

#pragma mark - Managing the detail item

- (void) didSelectRow:(NSInteger)row ForSection:(NSInteger)section
{
    
    if (detailViewObject != nil)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }

    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    selectedSection = -1;
    selectedRow = -1;
    currentEditRow = nil;
    
    switch (section)
    {
        case 0:
            section = SHOW_HEADER_ROW;
            break;
            
        case 1:
            section = SHOW_LINES_ROW;
            break;
        case 2:
        {
            section = SHOW_ADDITIONALINFO_ROW;
            break;
        }
        default:
            break;
    }
    
    switch (section) {
        /*
        case SHOWALL_HEADERS:
            selectedSection = SHOWALL_HEADERS;
            isDefault = YES;
            [tableView reloadData];
            break;
        */
        case SHOW_HEADER_ROW:
            isDefault = NO;
            selectedSection = SHOW_HEADER_ROW;
            selectedRow = row;
            [tableView reloadData];
            break;
        /*
         
        case SHOWALL_LINES:
            selectedSection = SHOWALL_LINES;
            isDefault = YES;
            [tableView reloadData];
            break;
        */
        case SHOW_LINES_ROW:
            isDefault = NO;
            selectedSection = SHOW_LINES_ROW;
            selectedRow = row;
            [tableView reloadData];
            break;
        case SHOW_ADDITIONALINFO_ROW:
            isDefault = NO;
            selectedSection = SHOW_ADDITIONALINFO_ROW;
            selectedRow = row;
            [tableView reloadData];
            break;
        
        default:
            break;
    }

    [self.popoverController dismissPopoverAnimated:YES];
}

-(void) didselectSection:(NSInteger) section;
{
    
    if (detailViewObject != nil)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    selectedSection = -1;
    selectedRow = -1;
    
    switch (section) 
    {
        case 0:
            selectedSection = SHOWALL_HEADERS;
            isDefault = YES;
            [tableView reloadData];
            break;
        case 1:
            selectedSection = SHOWALL_LINES;
            isDefault = YES;
            [tableView reloadData];
            break;
        case 2:
            selectedSection = SHOW_ALL_ADDITIONALINFO ;
            isDefault= YES;
            [tableView  reloadData];
        default:
            break;    
            
            
    }
}

- (void) didSwitchProcess:(NSDictionary *)objectDictionary
{
    didRunOperation = YES;
    NSString * newProcess = [objectDictionary objectForKey:gPROCESS_ID];
    self.objectAPIName = [objectDictionary objectForKey:VIEW_OBJECTNAME];
    //check For view process
    
    processInfo * pinfo =  [appDelegate getViewProcessForObject:objectAPIName record_id:currentRecordId processId:newProcess isswitchProcess:TRUE];
    BOOL process_exist = pinfo.process_exists;
    
    if(process_exist)
    {
        //check For view process
        didSelectViewLayout = YES;
        appDelegate.sfmPageController.processId = pinfo.process_id;
        [self fillSFMdictForOfflineforProcess:newProcess forRecord:appDelegate.sfmPageController.recordId];
        [self didReceivePageLayoutOffline];
    }
    else
    {
        NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:NO_VIEW_LAYOUT];
        NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
        NSString * Ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
        
        UIAlertView * alert1 = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:Ok otherButtonTitles:nil];
        [alert1 show];
        [alert1 release];
        return;
    }
}

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
*/
- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem)
    {
        [_detailItem release];
        _detailItem = [newDetailItem retain];
        
        // Update the view.
                
        [self configureView];
    }

    if (self.popoverController != nil)
    {
        [self.popoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.
   
    self.detailDescriptionLabel.text = [self.detailItem description];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	CGRect rect = self.view.frame;
	self.navigationController.navigationBar.frame = CGRectMake(0, 0, rect.size.width, self.navigationController.navigationBar.frame.size.height);
    
    didRunOperation = YES;
    
    isShowingSaveError = NO;
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.isDetailActive = YES;
    appDelegate.wsInterface.refreshSyncButton = self;
    
    self.navigationController.delegate = self;
    
    cancel = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON];
    save = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_ACTION_BUTTON_SAVE];
    quick_save = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_ACTION_BUTTON_QSAVE];
    summary = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_ACTIONPOPOVER_LIST_3];
    troubleShooting = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_TROUBLESHOOTING];
    chatter = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_ACTIONPOPOVER_LIST_1];
    dod_title = [appDelegate.wsInterface.tagsDictionary objectForKey:Refresh_from_SalesForce];

    
    UIImageView * bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_right_panel_bg_main_top.png"]];
	bgImage.frame = CGRectMake(0, -12, bgImage.frame.size.width, bgImage.frame.size.height+12);
	self.tableView.backgroundView = bgImage;
	[bgImage release];
	self.tableView.backgroundColor = [UIColor clearColor];
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    isDefault = YES;
    // Set up keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
    currentRecordId =  appDelegate.sfmPageController.recordId;
    currentProcessId = appDelegate.sfmPageController.processId;
    if (!isInEditDetail)
    {
        appDelegate.isWorkinginOffline = TRUE;
        [self fillSFMdictForOfflineforProcess:currentProcessId forRecord:currentRecordId];
        [self didReceivePageLayoutOffline];
		SMLog(@"%@", CGRectCreateDictionaryRepresentation(self.navigationController.navigationBar.frame));
        // ################ BACK BUTTON HERE ################# //
        UIImage *image = [UIImage imageNamed:@"SFM-Screen-Back-Arrow-Button"];
		UIButton * backButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)] autorelease];
		[backButton setBackgroundImage:image forState:UIControlStateNormal];
		[backButton addTarget:self action:@selector(DismissModalViewController:) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem * backBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
		self.navigationItem.leftBarButtonItem = backBarButtonItem;
        // ################################################### //
    }
      
    //[appDelegate setSyncStatus:appDelegate.SyncStatus];
     showSyncUI = YES;
}

- (void) didInternetConnectionChange:(NSNotification *)notification
{
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber * currentReach = (NSNumber *) notification.object;
    BOOL isReachable = [currentReach boolValue];
    if (isReachable)
    {
        SMLog(@"DetailViewController Internet Reachable");
    }
    else
    {
        SMLog(@"DetailViewController Internet Not Reachable");
        
        if (didRunOperation)
        {
            [activity stopAnimating];
            //[appDelegate displayNoInternetAvailable];
            didRunOperation = NO;
            
        }
        
        [tableView reloadData];
        [appDelegate.sfmPageController.rootView refreshTable];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.isDetailActive = YES;
    
    [self enableSFMUI];
    
    
    if( !self.parentReference )
        [self addNavigationButtons:detailTitle];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.isDetailActive = YES;
    
    //[appDelegate setSyncStatus:appDelegate.SyncStatus];
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
    if (lookupPopover)
    {
        if (UIDeviceOrientationIsLandscape(interfaceOrientation))
        {
            [lookupPopover setPopoverContentSize:CGSizeMake(320, self.tableView.frame.size.height) animated:YES];
            [lookupPopover presentPopoverFromRect:CGRectMake(1024, 0, 0, 0) inView:self.view permittedArrowDirections:0 animated:YES];
        }
        else
        {
            [lookupPopover setPopoverContentSize:CGSizeMake(320, self.tableView.frame.size.height) animated:YES];
            [lookupPopover presentPopoverFromRect:CGRectMake(768, 0, 0, 0) inView:self.view permittedArrowDirections:0 animated:YES];
        }
    }
    return YES;
}


// Back Button Methods
- (void) DismissModalViewController:(id)sender
{
    appDelegate.showUI = TRUE;     //btn merge
    clickedBack = YES;
    if ([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"EDIT"] || [[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"SOURCETOTARGETONLYCHILDROWS"]) 
    {
        [activity startAnimating];
        if([appDelegate.sfmPageController.sourceProcessId length] == 0 && [appDelegate.sfmPageController.sourceRecordId length] == 0)
        {
            NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
            NSString * headerObjName = [hdr_object objectForKey:gHEADER_OBJECT_NAME];
            if([headerObjName isEqualToString:@"Event"])
            {
                appDelegate.SFMPage = nil;
                appDelegate.SFMoffline = nil;
                [delegate Back:sender];
                return;
            }
        }
        
        appDelegate.sfmPageController.processId = appDelegate.sfmPageController.sourceProcessId;
        appDelegate.sfmPageController.recordId  = appDelegate.sfmPageController.sourceRecordId ;

        
        SMLog(@"%@",appDelegate.sfmPageController.sourceProcessId);
        [self fillSFMdictForOfflineforProcess:appDelegate.sfmPageController.sourceProcessId  forRecord:appDelegate.sfmPageController.sourceRecordId];
        [self didReceivePageLayoutOffline];
    }
    else
    {
        appDelegate.SFMPage = nil;
        appDelegate.SFMoffline = nil;
        [delegate Back:sender];
    }
}


- (void) PopNavigationController:(id)sender
{
    //sahana 20th Aug 2011
    if(isInViewMode)
    {
        NSInteger section = self.selectedIndexPath.section;
        NSMutableArray * details = [appDelegate.SFMPage objectForKey:gDETAILS];
        
        NSMutableDictionary * detail = [details objectAtIndex:section];
        NSMutableArray * detail_values = [detail objectForKey:gDETAILS_VALUES_ARRAY];
        NSMutableArray * detail_Values_RECID = [detail objectForKey:gDETAIL_VALUES_RECORD_ID];
        
        
        NSMutableArray * detailValue = [detail_values objectAtIndex:self.selectedRowForDetailEdit];
        NSString * record_id = [detail_Values_RECID objectAtIndex:self.selectedRowForDetailEdit];
        
        BOOL deleteFlag = FALSE;
        for(int i =0; i< [detailValue count]; i++)
        {
            NSMutableDictionary  * dict = [detailValue objectAtIndex:i];
            NSString * api_name = [dict objectForKey:gVALUE_FIELD_API_NAME];
            if([api_name isEqualToString:gDETAIL_SAVED_RECORD])
            {
                 deleteFlag = [[dict  objectForKey:gVALUE_FIELD_VALUE_VALUE] boolValue];
            }
        }
        if([record_id isEqualToString:@""])
        {
            if(deleteFlag == FALSE)
                [detail_values removeObjectAtIndex:self.selectedRowForDetailEdit];
        }
        //sahana 20th Aug 2011 - code ends
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) addNavigationButtons:(NSString *)sectionTitle
{
    int toolBarWidth = 0;
    // Adding the Back button
    UIButton * actionButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 67, 37)] autorelease];
    [actionButton setTitle:@"Actions" forState:UIControlStateNormal];

    UIImage * actionImage = [UIImage imageNamed:@"SFM-Screen-Done-Back-Button"];
    [actionImage stretchableImageWithLeftCapWidth:9 topCapHeight:9];
    [actionButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [actionButton setBackgroundImage:actionImage forState:UIControlStateNormal];
    [actionButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];

    // Adding the label
    UILabel * label = [[[UILabel alloc] initWithFrame:CGRectMake(64, 0, self.view.frame.size.width-64, 44)] autorelease];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:14.0];
	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor blackColor];
	label.text = detailTitle;	
    SMLog(@"%@",detailTitle);
    // Adding the action Button
    if (actionBtn == nil)
    {
        actionBtn = [[[UIBarButtonItem alloc] initWithCustomView:actionButton] autorelease];
        actionBtn.width = 67;
        [actionBtn setTarget:self];
        [actionBtn setAction:@selector(action:)];
    }
    toolBarWidth += 67; //Action Button Width
    NSMutableArray * buttons = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    //[appDelegate setSyncStatus:appDelegate.SyncStatus];
    
    UIBarButtonItem * syncBarButton = [[UIBarButtonItem alloc] initWithCustomView:appDelegate.animatedImageView];
    [buttons addObject:syncBarButton];
    [syncBarButton setTarget:self];
    syncBarButton.width =26;
    toolBarWidth += syncBarButton.width;
    [syncBarButton release];
    // Samman - 20 July, 2011 - Signature Capture - BEGIN

    BOOL isStandAloneCreate = [[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"STANDALONECREATE"];
    if (appDelegate.signatureCaptureUpload && !isInEditDetail && !isStandAloneCreate && !isInViewMode)
    {
        actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 35)];
        [actionButton setTitle:@"Actions" forState:UIControlStateNormal];
        [actionButton setImage:[UIImage imageNamed:@"sfm_signature_capture"] forState:UIControlStateNormal];
        [actionButton addTarget:self action:@selector(ShowSignature) forControlEvents:UIControlEventTouchUpInside];
    
        UIBarButtonItem * actionBtn1 = [[UIBarButtonItem alloc] initWithCustomView:actionButton];
        actionBtn1.width = 43;
        [actionBtn1 setTarget:self];
        [actionBtn1 setAction:@selector(ShowSignature)];
        [buttons addObject:actionBtn1];
        toolBarWidth += actionBtn1.width;
        [actionBtn1 release];
        [actionButton release];
    }

    
    // Samman - 20 July, 2011 - Signature Capture - END
     [buttons addObject:actionBtn];
    //Add help button Radha - 26 August, 2011
    if(appDelegate.isWorkinginOffline)
    {
        actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 35)];
        [actionButton setImage:[UIImage imageNamed:@"iService-Screen-Help.png"] forState:UIControlStateNormal];
        actionButton.alpha = 1.0;
        [actionButton addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem * helpBarButton = [[UIBarButtonItem alloc] initWithCustomView:actionButton];
        [helpBarButton setTarget:self];
        [helpBarButton setAction:@selector(showHelp)];
         [buttons addObject:helpBarButton];
        toolBarWidth += 43;
        [helpBarButton release];
        [actionButton release];
    }
    //Add help button Radha - 26 August, 2011 - END
    
    SMLog(@"Tool Bar Width = %d",toolBarWidth);
    
        UIToolbar* toolbar;
    if (appDelegate.signatureCaptureUpload && !isInEditDetail && !isStandAloneCreate && !isInViewMode){

        toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(self.view.frame.size.width -220, 0, 220, 44)] autorelease];
    }
    else
    {
        toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(self.view.frame.size.width -100, 0, 170, 44)] autorelease];

    }
   
    SMLog(@"Tool Bar Frame x = %f y = %f w = %f h = %f",[toolbar frame].origin.x,[toolbar frame].origin.y,[toolbar frame].size.width,[toolbar frame].size.height);

      [toolbar setItems:buttons];
    self.navigationItem.titleView = label;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolbar] autorelease];
}

#pragma mark - Split view support
// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if (masterPopover)
    {
        [masterPopover dismissPopoverAnimated:YES];
        masterPopover = nil;
    }

    self.popoverController = nil;
    
    //[tableView reloadData];  //uncomment
    
    [self enableSFMUI];
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController: (UIPopoverController *)pc
{
    //adding the label
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(64, 0, self.view.frame.size.width-64, 44)] autorelease];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:14.0];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor blackColor];
	label.text = detailTitle;	
    SMLog(@"%@",detailTitle);
    //adding the action Button
    if (actionBtn == nil)
    {
        UIButton * actionButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 67, 31)] autorelease];
        [actionButton setTitle:@"Actions" forState:UIControlStateNormal];
        UIImage * actionImage = [UIImage imageNamed:@"SFM-Screen-Done-Back-Button"];
        [actionImage stretchableImageWithLeftCapWidth:9 topCapHeight:9];
        [actionButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [actionButton setBackgroundImage:actionImage forState:UIControlStateNormal];
        [actionButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        
        actionBtn = [[[UIBarButtonItem alloc] initWithCustomView:actionButton] autorelease];
        actionBtn.width = 67;
        [actionBtn setTarget:self];
        [actionBtn setAction:@selector(action:)];
    }
    
    NSMutableArray * buttons = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    //[buttons addObject:actionBtn];  -- Shrinivas
    
    //if (appDelegate.signatureCaptureUpload)
    //[appDelegate setSyncStatus:appDelegate.SyncStatus];
    showSyncUI=YES;
    
    UIBarButtonItem * syncBarButton = [[UIBarButtonItem alloc] initWithCustomView:appDelegate.animatedImageView];
    [buttons addObject:syncBarButton];
    [syncBarButton setTarget:self];
    
    
    BOOL isStandAloneCreate = [[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"STANDALONECREATE"];
    if (appDelegate.signatureCaptureUpload && !isInEditDetail && !isStandAloneCreate && !isInViewMode)
    {
        UIButton * actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 33)];
        [actionButton setImage:[UIImage imageNamed:@"sfm_signature_capture"] forState:UIControlStateNormal];
        [actionButton addTarget:self action:@selector(ShowSignature) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem * actionBtn1 = [[UIBarButtonItem alloc] initWithCustomView:actionButton];
        actionBtn1.width = 37;
        [actionBtn1 setTarget:self];
        [actionBtn1 setAction:@selector(ShowSignature)];
        // [buttons insertObject:actionBtn1 atIndex:0];
        [buttons addObject:actionBtn1];
        
        [actionBtn1 release];
        [actionButton release];
    }
    
    [buttons addObject:actionBtn];//Shrinivas
    //Add help button Radha - 26 August, 2011
    UIButton * actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 35)];
    [actionButton setImage:[UIImage imageNamed:@"iService-Screen-Help.png"] forState:UIControlStateNormal];
    actionButton.alpha = 1.0;
    [actionButton addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * helpBarButton = [[UIBarButtonItem alloc] initWithCustomView:actionButton];
    [helpBarButton setTarget:self];
    [helpBarButton setAction:@selector(showHelp)];
    [buttons addObject:helpBarButton];
    [syncBarButton release];
    [helpBarButton release];
    [actionButton release];
    //Add help button Radha - 26 August, 2011 - END
    CGFloat toolbarWidth = 0;
    if (appDelegate.signatureCaptureUpload && !isInEditDetail && !isStandAloneCreate && !isInViewMode)
        toolbarWidth = 220;
    else
        toolbarWidth = 170;
    UIToolbar* toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, toolbarWidth, 44)] autorelease];
    [toolbar setItems:buttons];

    // ################ BACK BUTTON HERE ################# //
    UIButton * backButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 35)] autorelease];
    [backButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Back-Arrow-Button"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(DismissModalViewController:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem * backBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    // ################################################### //

    self.navigationItem.titleView = label;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolbar] autorelease];
    
    //[tableView reloadData];
    
    [self enableSFMUI];
}

- (void)splitViewController:(UISplitViewController*)svc popoverController:(UIPopoverController*)pc willPresentViewController:(UIViewController *)aViewController
{
    if (sp != nil)
    {
        [sp.popOver dismissPopoverAnimated:YES];
        [sp release];
        sp = nil;
    }
    
    [self enableSFMUI];
}

// Returns YES if a view controller should be hidden by the split view controller in a given orientation.
// (This method is only called on the leftmost view controller and only discriminates portrait from landscape.)
- (BOOL)splitViewController: (UISplitViewController*)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
//    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
//    if (deviceOrientation == UIInterfaceOrientationPortrait || deviceOrientation == UIInterfaceOrientationPortraitUpsideDown)
//        return YES;
    return NO;
}

- (IBAction) showMaster:(id)sender
{
    if (masterPopover == nil)
    {
        RootViewController * master = [[[RootViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:master];
        masterPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
        [masterPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        [navController release];
    }
    else
    {
        [masterPopover dismissPopoverAnimated:YES];
        masterPopover = nil;
    }
}

#pragma mark - selectProcess method delegate
-(void)isViewable //for editing mode
{
    self.isInViewMode = NO;
    [tableView reloadData];
}

-(void)isEditable //for editing mode
{
    self.isInViewMode = YES;
    [tableView reloadData];
}

#pragma mark = fill the sfmData equivalent for didsubmitProcess method in offline
-(void)fillSFMdictForOfflineforProcess:(NSString *) processId forRecord:(NSString *)recordId
{
    appDelegate.isWorkinginOffline = TRUE;
    
   // databaseIntefaceSfm * database = [[databaseIntefaceSfm alloc] init];
    //[appDelegate.databaseInterface openDB:SFMDATABASE_NAME];
    if( processId == nil)
        return;
   
    NSString * object_name = [NSString stringWithFormat:@"%@", appDelegate.sfmPageController.objectName];
    
    if(object_name == nil || [object_name length] == 0)
    {
        return;
    }
    
    NSMutableDictionary * page_layoutInfo = [appDelegate.databaseInterface  queryProcessInfo:processId object_name:object_name];
    
    if(page_layoutInfo == nil)
    {
        NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_no_pagelayout];
        NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
        NSString * cancel_ = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE];
        
        UIAlertView * no_page_Layout = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel_ otherButtonTitles:nil, nil];
        
        [no_page_Layout show];
        [no_page_Layout release];
        return;
    }
    NSString * process_type = [page_layoutInfo objectForKey:gPROCESSTYPE];
        
    NSMutableDictionary * _header =  [page_layoutInfo objectForKey:@"header"];
    
    NSMutableArray * details = [page_layoutInfo objectForKey:gDETAILS];
    
    NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];
    
    NSString * layout_id = [_header objectForKey:gHEADER_HEADER_LAYOUT_ID];

    
    NSMutableArray * header_sections =  [_header objectForKey:@"hdr_Sections"];
    
    NSMutableArray * api_names = [[[NSMutableArray alloc ] initWithCapacity:0] autorelease];
    
    for(int i=0; i <[header_sections count] ;i++)
    {
        NSDictionary * section_info = [header_sections objectAtIndex:i];
        NSMutableArray * sectionFileds= [section_info objectForKey:@"section_Fields"];
        
        for(int j= 0;j<[sectionFileds count]; j++)
        {
            NSDictionary * filed_info =[sectionFileds objectAtIndex:j];
            NSString * filed_api_name = [filed_info objectForKey:gFIELD_API_NAME];
            [api_names  addObject:filed_api_name];
        }
    }

    
    // NSMutableDictionary * dict = [database queryTheObjectInfoTable:api_names tableName:SFOBJECTFIELD objectName:@""];
    NSMutableDictionary * descibeDict = [appDelegate.databaseInterface queryTheObjectInfoTable:api_names tableName:SFOBJECTFIELD object_name:headerObjName];
    
    SMLog(@"Header  describe dict %@" , descibeDict);
    
    NSArray * allKeys = [descibeDict allKeys];
    
    for(int i=0; i <[header_sections count] ;i++)
    {
        NSMutableDictionary * section_info = [header_sections objectAtIndex:i];
        NSMutableArray * sectionFileds= [section_info objectForKey:@"section_Fields"];
        
        for(int j= 0;j<[sectionFileds count]; j++)
        {
            NSMutableDictionary * filed_info =[sectionFileds objectAtIndex:j];
            NSString * filed_api_name = [filed_info objectForKey:gFIELD_API_NAME];
            NSString * field_label = @"";
            
            for(int k=0;k < [allKeys count];k++)
            {
                NSString * key = [allKeys objectAtIndex:k];
                if([key isEqualToString:filed_api_name])
                {
                    field_label = [descibeDict objectForKey: [allKeys objectAtIndex:k]];
                    
                    break;
                }
            }
            
            [filed_info setObject:field_label forKey:gFIELD_LABEL];
            SMLog(@"fiel Info   %@", filed_info);
        }
    }
    
    //retrieve data from the  lines Table
    for(int j= 0; j < [details count]; j++)
    {
        NSMutableDictionary * dict = [details objectAtIndex:j];
        NSMutableArray * filedsArray = [dict objectForKey:gDETAILS_FIELDS_ARRAY];
        NSString * detailObjectName = [dict objectForKey:gDETAIL_OBJECT_NAME];
        NSMutableArray * details_api_keys = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        for(int k =0 ;k<[filedsArray count];k++)
        {
            NSMutableDictionary * detailFiled_info =[filedsArray objectAtIndex:k];
            NSString * api_name = [detailFiled_info objectForKey:gFIELD_API_NAME];
            [details_api_keys addObject:api_name];
        }
        
        NSMutableDictionary * descibeDict_detail = [appDelegate.databaseInterface queryTheObjectInfoTable:details_api_keys tableName:SFOBJECTFIELD object_name:detailObjectName];
        
        NSArray * allKeys_detail = [descibeDict_detail allKeys];
        for(int k =0 ;k<[filedsArray count];k++)
        {
            NSMutableDictionary * detailFiled_info =[filedsArray objectAtIndex:k];
            NSString * api_name = [detailFiled_info objectForKey:gFIELD_API_NAME];
            for(int k= 0; k< [allKeys_detail count]; k++)
            {
                if([api_name isEqualToString:[allKeys_detail objectAtIndex:k]])
                {
                    [detailFiled_info  setObject:[descibeDict_detail objectForKey:api_name] forKey:gFIELD_LABEL];
                }
            }
        }
//        [details_api_keys release];
    }
        
    if([process_type isEqualToString:@"VIEWRECORD"] )
    {
            
        NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGET process_id:processId layoutId:layout_id objectName:headerObjName];
        //[appDelegate.databaseInterface  getValueMappingForlayoutId:layout_id process_id:processId objectName:headerObjName];
        
        NSString * expression_id = [process_components objectForKey:EXPRESSION_ID];
        
        BOOL Entry_criteria = [appDelegate.databaseInterface EntryCriteriaForRecordFortableName:headerObjName record_id:recordId expression:expression_id];
        
                
        if(!Entry_criteria)
        {
            NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_swich_process];
            NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
            NSString * cancel_ = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE];

            UIAlertView * enty_criteris = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel_ otherButtonTitles:nil, nil];
            [enty_criteris show];
            [enty_criteris release];
        
        }

        NSMutableDictionary * headerValueDict = [appDelegate.databaseInterface queryDataFromObjectTable:api_names tableName:headerObjName record_id:appDelegate.sfmPageController.recordId expression:expression_id];

        NSArray * all_Keys_values = [headerValueDict allKeys];
        
        for(int i=0; i <[header_sections count] ;i++)
        {
            NSDictionary * section_info = [header_sections objectAtIndex:i];
            NSMutableArray * sectionFileds= [section_info objectForKey:@"section_Fields"];
            
            for(int j= 0;j<[sectionFileds count]; j++)
            {
                NSMutableDictionary * filed_info =[sectionFileds objectAtIndex:j];
                NSString * filed_api_name = [filed_info objectForKey:gFIELD_API_NAME];
                NSString * field_data_type = [[filed_info objectForKey:gFIELD_DATA_TYPE] lowercaseString];
                NSString * field_value = @"";
                NSString * field_key = @"";
                
                for(int k=0;k < [all_Keys_values count];k++)
                {
                    NSString * key = [all_Keys_values objectAtIndex:k];
                    if([key isEqualToString:filed_api_name])
                    {
                        field_key = [headerValueDict objectForKey:[all_Keys_values objectAtIndex:k]];
                        
                        if([field_data_type isEqualToString:@"picklist"])
                        {
                            //query to acces the picklist values for lines 
                            NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:filed_api_name tableName:SFPicklist objectName:headerObjName];
                            NSArray * allKeys = [picklistValues allKeys];
                            for(NSString * value_dict in allKeys)
                            {
                                if([value_dict isEqualToString:field_key])
                                {
                                    field_value =[picklistValues objectForKey:field_key];
                                    break;
                                }
                            }
                        }
                        
                        else if([field_data_type isEqualToString:@"reference"] && (![filed_api_name isEqualToString:@"RecordTypeId"]))
                        {
                            if([field_key isEqualToString:@""] || [field_key length ] == 0 || field_key == nil )
                            {
                                field_value = field_key;
                            }
                            else
                            {
                                NSMutableArray * referenceTotableNames = [appDelegate.databaseInterface getReferenceToForField:filed_api_name objectapiName:headerObjName tableName:SF_REFERENCE_TO];
                                
                                
                                if([referenceTotableNames count ] > 0)
                                {
                                    NSString * reference_to_tableName = [referenceTotableNames objectAtIndex:0];
                                    
                                    NSString * referenceTo_Table_fieldName = [appDelegate.databaseInterface getFieldNameForReferenceTable:reference_to_tableName tableName:SFOBJECTFIELD];
                                    
                                    field_value = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:reference_to_tableName field_name:referenceTo_Table_fieldName record_id:field_key];
                                    
                                }
                                if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
                                {
                                    field_value = [appDelegate.databaseInterface getLookUpNameForId:field_key];
                                    if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
                                    {
                                        field_value = field_key;
                                    }
                                }
                                 break;
                            }
                            
                        }
                        else if([field_data_type isEqualToString:@"reference"] && [filed_api_name isEqualToString:@"RecordTypeId"])
                        {
                            if([field_key isEqualToString:@""] || [field_key length ] == 0 || field_key == nil )
                            {
                                field_value = field_key;
                            }
                            else
                            {
                                NSMutableArray * referenceTotableNames = [appDelegate.databaseInterface getReferenceToForField:filed_api_name objectapiName:headerObjName tableName:SF_REFERENCE_TO];
                                
                                
                                if([referenceTotableNames count ] > 0)
                                {
                                    NSString * reference_to_tableName = [referenceTotableNames objectAtIndex:0];
                                    
                                    NSString * referenceTo_Table_fieldName = [appDelegate.databaseInterface getFieldNameForReferenceTable:reference_to_tableName tableName:SFOBJECTFIELD];
                                    
                                    field_value = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:reference_to_tableName field_name:referenceTo_Table_fieldName record_id:field_key];
                                    
                                    if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
                                    {
                                        field_value = [appDelegate.dataBase getValueForRecordtypeId:field_key object_api_name:headerObjName];
                                    }

                                    
                                }
                                if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
                                {
                                    field_value = [appDelegate.databaseInterface getLookUpNameForId:field_key];
                                    if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
                                    {
                                        field_value = field_key;
                                    }
                                }
                                break;
                            }
                            
                        }

                        else if([field_data_type isEqualToString:@"datetime"])
                        {
                            NSString * date = field_key;
                            date = [date stringByDeletingPathExtension];
                            field_key = date;
                            field_value = date;
                        }
                        
                        else if([field_data_type isEqualToString:@"date"])
                        {
                            NSString * date = field_key;
                            date = [date stringByDeletingPathExtension];
                            field_key = date;
                            field_value = date;
                        }
                        
                        else if([field_data_type isEqualToString:@"multipicklist"])
                        {
                            NSArray * fieldKeys = [field_key componentsSeparatedByString:@";"];
                            NSMutableArray * valuesArray = [[NSMutableArray alloc] initWithCapacity:0];
                            //query to acces the picklist values for lines 
                            NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:filed_api_name tableName:SFPicklist objectName:headerObjName];
                            
                            NSArray * allKeys = [picklistValues allKeys];
                            for(NSString * value_dict in allKeys)
                            {
                                for(NSString * key  in fieldKeys)
                                {
                                    if([value_dict isEqualToString:key])
                                    {
                                        [valuesArray addObject:[picklistValues objectForKey:key]];
                                        break;
                                    }
                                }
                            }
                            NSInteger count_ = 0;
                            for(NSString * each_label in valuesArray)
                            {
                                if(count_ != 0)
                                    field_value = [field_value stringByAppendingString:@";"];
                                field_value = [field_value stringByAppendingString:each_label];
                                count_ ++;
                                
                            }
                            
                            if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
                            {
                                field_value = field_key;
                            }

                        }
                        else
                        {
                            field_value = field_key;
                        }
                        
                        break;
                    }
                }
                
                [filed_info setObject:field_key forKey:gFIELD_VALUE_KEY];
                [filed_info setObject:field_value forKey:gFIELD_VALUE_VALUE];
            }
        }
        
               
        for(int j= 0; j < [details count]; j++)
        {
            NSMutableDictionary * dict = [details objectAtIndex:j];
            NSMutableArray * filedsArray = [dict objectForKey:gDETAILS_FIELDS_ARRAY];
            NSMutableArray * detailValuesArray = [dict objectForKey:gDETAILS_VALUES_ARRAY];
            NSMutableArray * details_api_keys = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
            NSString * detailObjectName = [dict objectForKey:gDETAIL_OBJECT_NAME];
            NSString * detailaliasName = [dict objectForKey:gDETAIL_OBJECT_ALIAS_NAME];
            NSString * detail_layout_id = [dict objectForKey:gDETAILS_LAYOUT_ID];
            
            for(int k =0 ;k<[filedsArray count];k++)
            {
                NSMutableDictionary * detailFiled_info =[filedsArray objectAtIndex:k];
                NSString * api_name = [detailFiled_info objectForKey:gFIELD_API_NAME];
                [details_api_keys addObject:api_name];
            }
            
            NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGETCHILD process_id:processId layoutId:detail_layout_id objectName:detailObjectName];
            
            NSString * expressionId = [process_components objectForKey:EXPRESSION_ID];
            NSString * parent_column_name = [dict objectForKey:gDETAIL_HEADER_REFERENCE_FIELD];
            
            NSMutableArray * detail_values = [appDelegate.databaseInterface queryLinesInfo:details_api_keys detailObjectName:detailObjectName headerObjectName:headerObjName detailaliasName:detailaliasName headerRecordId:appDelegate.sfmPageController.recordId expressionId:expressionId parent_column_name:parent_column_name];
            
            for(int l = 0 ;l < [detail_values count]; l++)
            {
                [detailValuesArray addObject:[detail_values objectAtIndex:l]]; 
                
            }
            
//            [details_api_keys release];
            
        }
        
        //for workorder  if their Product history and account history associated with it should be  
        //write the contion here
        
        NSString * processType = [page_layoutInfo objectForKey:gPROCESSTYPE];
        
        
        BOOL product_history = [[_header objectForKey:gHEADER_SHOW_PRODUCT_HISTORY] boolValue];
        BOOL account_history = [[_header  objectForKey:gHEADER_SHOW_ACCOUNT_HISTORY] boolValue];
        
        NSString * object_api_name = [headerObjName uppercaseString];
        NSString * temp = @"SVMXC__Service_Order__c";
        NSString * work_order = [temp uppercaseString];
        if([object_api_name isEqualToString:work_order] && [processType isEqualToString:@"VIEWRECORD"])
        {
            
            NSMutableDictionary * additionalInfo = [appDelegate.databaseInterface  gettheAdditionalInfoForForaWorkOrder:appDelegate.sfmPageController.recordId tableName:headerObjName];
            
            NSString * account_id  = [additionalInfo objectForKey:@"SVMXC__Company__c"];
            NSString * toplevelId  = [additionalInfo objectForKey:@"SVMXC__Top_Level__c"];
            NSString * componentId = [additionalInfo objectForKey:@"SVMXC__Component__c"];
            
            if(account_history == TRUE)
            {
                if(account_id != nil && [account_id length] != 0)
                {
                    //shrinivas
                    NSString * Id = @"";
                    NSString *query = [NSString stringWithFormat:@"Select Id From SVMXC__Service_Order__c Where local_id = '%@'", appDelegate.sfmPageController.recordId];
                    sqlite3_stmt *stmt;
                    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
                    {
                        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
                        {
                            char * _id = (char *) synchronized_sqlite3_column_text(stmt, 0);
                            if (_id != nil && strlen(_id))
                                Id = [NSString stringWithUTF8String:_id];
                        }
                    }
                    
                    NSMutableArray * accountHistory = [appDelegate.databaseInterface getAccountHistoryForanWorkOrder:Id account_id:account_id tableName:headerObjName ];
                    if(accountHistory != nil)
                    {
                        [page_layoutInfo setObject:accountHistory forKey:ACCOUNTHISTORY];
                    }
                }
            }
            
            
            if(product_history == TRUE)
            {
                //shrinivas
                NSString * Id = @"";
                NSString *query = [NSString stringWithFormat:@"Select Id From SVMXC__Service_Order__c Where local_id = '%@'", appDelegate.sfmPageController.recordId];
                sqlite3_stmt *stmt;
                if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
                {
                    if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
                    {
                        char * _id = (char *) synchronized_sqlite3_column_text(stmt, 0);
                        if (_id != nil && strlen(_id))
                            Id = [NSString stringWithUTF8String:_id];
                    }
                }

                NSMutableArray * productHistory = nil;
                if(toplevelId != nil && [toplevelId length] != 0)
                {
                    productHistory = [appDelegate.databaseInterface getProductHistoryForanWorkOrder:Id filedName:@"SVMXC__Top_Level__c" tableName:headerObjName fieldValue:toplevelId];
                }
                if(componentId != nil && [componentId length] != 0)
                {
                    productHistory = [appDelegate.databaseInterface getProductHistoryForanWorkOrder:Id filedName:@"SVMXC__Component__c" tableName:headerObjName fieldValue:componentId];
                }
                if(productHistory   != nil)
                {
                    [page_layoutInfo setObject:productHistory forKey:PRODUCTHISTORY];
                }
            }
        }
    }
    else if ([process_type isEqualToString:@"SOURCETOTARGETONLYCHILDROWS"])
    {
        NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGET process_id:processId layoutId:layout_id objectName:headerObjName];
        //[appDelegate.databaseInterface  getValueMappingForlayoutId:layout_id process_id:processId objectName:headerObjName];
        
        NSString * expression_id = [process_components objectForKey:EXPRESSION_ID];
        //SMLog(" record id %@" ,appDelegate.sfmPageController.recordId);
        NSMutableDictionary * headerValueDict = [appDelegate.databaseInterface queryDataFromObjectTable:api_names tableName:headerObjName record_id:appDelegate.sfmPageController.recordId expression:expression_id];
        
		//Change of Code for quick save. --> 10/07/2012  -- #4665
		BOOL Entry_criteria = [appDelegate.databaseInterface EntryCriteriaForRecordFortableName:headerObjName record_id:appDelegate.sfmPageController.recordId expression:expression_id];
        
        if(!Entry_criteria)
        {
			NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
            NSString * headerObjName = [hdr_object objectForKey:gHEADER_OBJECT_NAME];
            
            [self initAllrequriredDetailsForProcessId:appDelegate.sfmPageController.sourceProcessId recordId:appDelegate.sfmPageController.recordId object_name:headerObjName];
            [self fillSFMdictForOfflineforProcess:appDelegate.sfmPageController.sourceProcessId forRecord:appDelegate.sfmPageController.recordId ];
            [self didReceivePageLayoutOffline]; 
			
            NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_swich_process];
            NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
            NSString * cancel_ = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE];
			
            UIAlertView * enty_criteris = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel_ otherButtonTitles:nil, nil];
            [enty_criteris show];
            [enty_criteris release];
			return;
        }
		
		NSMutableDictionary * value_mapping_dict = [appDelegate.databaseInterface getObjectMappingForMappingId:process_components mappingType:VALUE_MAPPING];
		
		NSArray * valueMapping_keys = [value_mapping_dict allKeys];

        NSArray * all_Keys_values = [headerValueDict allKeys];
        
        for(int i=0; i <[header_sections count] ;i++)
        {
            NSDictionary * section_info = [header_sections objectAtIndex:i];
            NSMutableArray * sectionFileds= [section_info objectForKey:@"section_Fields"];
            
            for(int j= 0;j<[sectionFileds count]; j++)
            {
                NSMutableDictionary * filed_info =[sectionFileds objectAtIndex:j];
                NSString * filed_api_name = [filed_info objectForKey:gFIELD_API_NAME];
                NSString * field_data_type = [filed_info objectForKey:gFIELD_DATA_TYPE];
                NSString * field_value = @"";
                NSString * field_key = @"";
                
                for(int k=0;k < [all_Keys_values count];k++)
                {
                    NSString * key = [all_Keys_values objectAtIndex:k];
                    if([key isEqualToString:filed_api_name])
                    {
                        field_key = [headerValueDict objectForKey:[all_Keys_values objectAtIndex:k]];
                        if([field_key length] != 0)
                        {
                            field_value = [self getValueForApiName:filed_api_name dataType:field_data_type object_name:headerObjName field_key:field_key];
                            
                            if([field_data_type isEqualToString:@"datetime"] || [field_data_type isEqualToString:@"date"])
                            {
                                field_key = field_value ;
                            }
                            else if([field_data_type isEqualToString:@"multipicklist"])
                            {
                            }
                            else if([field_data_type isEqualToString:@"reference"])
                            {
                                
                            } 
                            else if([field_data_type isEqualToString:@"picklist"])
                            {
                            }
                            else
                            {
                                field_value = field_key; 
                            }
                        }
                    }
                }
				for(int e = 0 ; e <[valueMapping_keys count]; e++)
				{
					NSString * key = [valueMapping_keys objectAtIndex:e];
                    if([key isEqualToString:filed_api_name])
                    {
                        field_key = [value_mapping_dict objectForKey:key];
                        if([field_key length] != 0)
                        {
                            field_value = [self getValueForApiName:filed_api_name dataType:field_data_type object_name:headerObjName field_key:field_key];
                            
                            if([field_data_type isEqualToString:@"datetime"] || [field_data_type isEqualToString:@"date"])
                            {
                                field_key = field_value ;
                            }
                            else if([field_data_type isEqualToString:@"multipicklist"])
                            {
                            }
                            else if([field_data_type isEqualToString:@"reference"])
                            {
                                
                            } 
                            else if([field_data_type isEqualToString:@"picklist"])
                            {
                            }
                            else
                            {
                                field_value = field_key; 
                            }
                        }
                    }
				}
				
                
                [filed_info setObject:field_key forKey:gFIELD_VALUE_KEY];
                [filed_info setObject:field_value forKey:gFIELD_VALUE_VALUE];
            }
        }
        
        for(int j= 0; j < [details count]; j++)
        {
            NSMutableDictionary * dict = [details objectAtIndex:j];
            NSMutableArray * filedsArray = [dict objectForKey:gDETAILS_FIELDS_ARRAY];
            NSMutableArray * detailValuesArray = [dict objectForKey:gDETAILS_VALUES_ARRAY];
            NSMutableArray * detail_Values_id = [dict objectForKey:gDETAIL_VALUES_RECORD_ID];
            NSMutableArray * details_api_keys = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
            NSString * detailObjectName = [dict objectForKey:gDETAIL_OBJECT_NAME];
            NSString * detailaliasName = [dict objectForKey:gDETAIL_OBJECT_ALIAS_NAME];
            NSString * detail_layout_id = [dict objectForKey:gDETAILS_LAYOUT_ID];
            
            for(int k =0 ;k<[filedsArray count];k++)
            {
                NSMutableDictionary * detailFiled_info =[filedsArray objectAtIndex:k];
                NSString * api_name = [detailFiled_info objectForKey:gFIELD_API_NAME];
                [details_api_keys addObject:api_name];
            }
            
            NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGETCHILD process_id:processId layoutId:detail_layout_id objectName:detailObjectName];
            NSMutableDictionary * detail_value_mapping_dict = [appDelegate.databaseInterface getObjectMappingForMappingId:process_components mappingType:VALUE_MAPPING];
			
			NSArray * detail_value_mapping_keys = [detail_value_mapping_dict allKeys];
			
			NSMutableDictionary * api_name_dataType = [appDelegate.databaseInterface getAllFieldsAndItsDataTypesForObject:detailObjectName tableName:SFOBJECTFIELD];
			
            NSString * expressionId = [process_components objectForKey:EXPRESSION_ID];
            NSString * parent_column_name = [dict objectForKey:gDETAIL_HEADER_REFERENCE_FIELD];
            
            NSMutableArray * detail_values = [appDelegate.databaseInterface queryLinesInfo:details_api_keys detailObjectName:detailObjectName headerObjectName:headerObjName detailaliasName:detailaliasName headerRecordId:appDelegate.sfmPageController.recordId expressionId:expressionId parent_column_name:parent_column_name];
            
            for(int l = 0 ;l < [detail_values count]; l++)
            {
                [detailValuesArray addObject:[detail_values objectAtIndex:l]];
                NSMutableArray *  eachArray = [detail_values objectAtIndex:l];
                for(int m = 0 ; m < [eachArray count];m++)
                {
//                    NSMutableDictionary * dict = [eachArray objectAtIndex:m];
//                    NSString * api_name = [dict objectForKey:gVALUE_FIELD_API_NAME];
//					[dict setObject:@"" forKey:gVALUE_FIELD_VALUE_VALUE];
//					[dict setObject:@"" forKey:gVALUE_FIELD_VALUE_KEY];
                    NSMutableDictionary * dict = [eachArray objectAtIndex:m];
                    NSString * api_name = [dict objectForKey:gVALUE_FIELD_API_NAME];
					if([api_name isEqualToString:@"local_id"])
                    {
                        [eachArray  removeObjectAtIndex:m];
                    }
					
//					for(int e = 0 ; e < [detail_value_mapping_keys count]; e++)
//					{
//						NSString  * detail_value_api = [detail_value_mapping_keys objectAtIndex:e];
//						if([detail_value_api isEqualToString:api_name])
//						{
//							if([detail_value_api length] != 0)
//							{
//								NSString *  detail_value_key  =  [detail_value_mapping_dict objectForKey:detail_value_api];
//								NSString * field_data_type  = [api_name_dataType objectForKey:detail_value_api];
//                                // Sahana fix for defect 5826
//								NSString * detil_value_value = [self getValueForApiName:detail_value_api dataType:field_data_type object_name:detailObjectName field_key:detail_value_key];
//								[dict setObject:detail_value_key forKey:gVALUE_FIELD_VALUE_KEY];
//								[dict setObject:detil_value_value forKey:gVALUE_FIELD_VALUE_VALUE];
//							}
//							break;
//						}
//						
//					}
                }
                
                [detail_Values_id addObject:@""];
            }
            
            
        }
    }
    else if ([process_type isEqualToString:@"STANDALONECREATE"])
    {
        //HEADER VALUE MAPPING
        //fetch all value for value mapping 
            
        NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGET process_id:processId layoutId:layout_id objectName:headerObjName];//[appDelegate.databaseInterface  getValueMappingForlayoutId:layout_id process_id:processId objectName:headerObjName];
       
        NSMutableDictionary * object_mapping_dict = [appDelegate.databaseInterface getObjectMappingForMappingId:process_components mappingType:VALUE_MAPPING];
        
        NSArray * all_Keys_values = [object_mapping_dict allKeys];
        
        for(int i=0; i <[header_sections count] ;i++)
        {
            NSDictionary * section_info = [header_sections objectAtIndex:i];
            NSMutableArray * sectionFileds= [section_info objectForKey:@"section_Fields"];
            
            for(int j= 0;j<[sectionFileds count]; j++)
            {
                NSMutableDictionary * filed_info =[sectionFileds objectAtIndex:j];
                NSString * filed_api_name = [filed_info objectForKey:gFIELD_API_NAME];
                NSString * field_data_type = [filed_info objectForKey:gFIELD_DATA_TYPE];
                NSString * field_value = @"";
                NSString * field_key = @"";
                
                for(int k=0;k < [all_Keys_values count];k++)
                {
                    NSString * key = [all_Keys_values objectAtIndex:k];
                    if([key isEqualToString:filed_api_name])
                    {
                        field_key = [object_mapping_dict objectForKey:[all_Keys_values objectAtIndex:k]];
                        
                        if([field_data_type isEqualToString:@"picklist"])
                        {
                            //query to acces the picklist values for lines 
                            NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:filed_api_name tableName:SFPicklist objectName:headerObjName];
                            NSArray * allKeys = [picklistValues allKeys];
                            for(NSString * value_dict in allKeys)
                            {
                                if([value_dict isEqualToString:field_key])
                                {
                                    field_value =[picklistValues objectForKey:field_key];
                                    break;
                                }
                            }
                        }
                        
                        else if([field_data_type isEqualToString:@"reference"] && (![filed_api_name isEqualToString:@"RecordTypeId"]))
                        {
                            if([field_key isEqualToString:@""] || [field_key length ] == 0 || field_key == nil )
                            {
                                field_value = field_key;
                            }
                            else
                            {
                                NSMutableArray * referenceTotableNames = [appDelegate.databaseInterface getReferenceToForField:filed_api_name objectapiName:headerObjName tableName:SF_REFERENCE_TO];
                                
                                if([referenceTotableNames count ] > 0)
                                {
                                    NSString * reference_to_tableName = [referenceTotableNames objectAtIndex:0];
                                    
                                    NSString * referenceTo_Table_fieldName = [appDelegate.databaseInterface getFieldNameForReferenceTable:reference_to_tableName tableName:SFOBJECTFIELD];
                                    
                                    field_value = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:reference_to_tableName field_name:referenceTo_Table_fieldName record_id:field_key];
                                    
                                }
                                if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
                                {
                                    field_value = [appDelegate.databaseInterface getLookUpNameForId:field_key];
                                    if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
                                    {
                                        field_value = field_key;
                                    }
                                }
                                break;
                            }
                            
                        }
                        
                        else if([field_data_type isEqualToString:@"reference"] && [filed_api_name isEqualToString:@"RecordTypeId"])
                        {
                            if([field_key isEqualToString:@""] || [field_key length ] == 0 || field_key == nil )
                            {
                                field_value = field_key;
                            }
                            else
                            {
                                NSMutableArray * referenceTotableNames = [appDelegate.databaseInterface getReferenceToForField:filed_api_name objectapiName:headerObjName tableName:SF_REFERENCE_TO];
                                
                                if([referenceTotableNames count ] > 0)
                                {
                                    NSString * reference_to_tableName = [referenceTotableNames objectAtIndex:0];
                                    
                                    NSString * referenceTo_Table_fieldName = [appDelegate.databaseInterface getFieldNameForReferenceTable:reference_to_tableName tableName:SFOBJECTFIELD];
                                    
                                    field_value = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:reference_to_tableName field_name:referenceTo_Table_fieldName record_id:field_key];
                                    
                                    
                                    
                                    if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
                                    {
                                        field_value = [appDelegate.dataBase getValueForRecordtypeId:field_key object_api_name:headerObjName];
                                    }
                                    
                                    
                                }
                                if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
                                {
                                    field_value = [appDelegate.databaseInterface getLookUpNameForId:field_key];
                                    if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
                                    {
                                        field_value = field_key;
                                    }
                                }
                                break;
                            }
                            
                        }

                        
                        
                        else if([field_data_type isEqualToString:@"datetime"])
                        {
                            NSString * date = field_key;
                            date = [date stringByDeletingPathExtension];
                            field_key = date;
                            field_value = date;
                        }
                        
                        else if([field_data_type isEqualToString:@"date"])
                        {
                            NSString * date = field_key;
                            date = [date stringByDeletingPathExtension];
                            field_key = date;
                            field_value = date;
                        }
                        
                        else if([field_data_type isEqualToString:@"multipicklist"])
                        {
                            NSArray * fieldKeys = [field_key componentsSeparatedByString:@";"];
                            NSMutableArray * valuesArray = [[NSMutableArray alloc] initWithCapacity:0];
                            //query to acces the picklist values for lines 
                            NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:filed_api_name tableName:SFPicklist objectName:headerObjName];
                            
                            NSArray * allKeys = [picklistValues allKeys];
                            for(NSString * value_dict in allKeys)
                            {
                                for(NSString * key  in fieldKeys)
                                {
                                    if([value_dict isEqualToString:key])
                                    {
                                        [valuesArray addObject:[picklistValues objectForKey:key]];
                                        break;
                                    }
                                }
                            }
                            NSInteger count_ = 0;
                            for(NSString * each_label in valuesArray)
                            {
                                if(count_ != 0)
                                    field_value = [field_value stringByAppendingString:@";"];
                                field_value = [field_value stringByAppendingString:each_label];
                                count_ ++;
                                
                            }
                            
                            if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
                            {
                                field_value = field_key;
                            }
                            
                        }
                        else
                        {
                            field_value = field_key;
                        }
                        
                        break;
                    }
                }
                
                [filed_info setObject:field_key forKey:gFIELD_VALUE_KEY];
                [filed_info setObject:field_value forKey:gFIELD_VALUE_VALUE];
            }
        }
        
    }
    
    else if ([process_type isEqualToString:@"SOURCETOTARGET"] )
    {
        NSMutableDictionary * process_components =  [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGET process_id:processId layoutId:layout_id objectName:headerObjName];
        //[appDelegate.databaseInterface  getValueMappingForlayoutId:layout_id process_id:processId objectName:headerObjName];
        
        NSString * source_parent_object_name = [process_components objectForKey:SOURCE_OBJECT_NAME];
        NSMutableArray * header_Value_array= [appDelegate.databaseInterface getObjectMappingForMappingId:process_components source_record_id:appDelegate.sfmPageController.sourceRecordId field_name:@"local_id"];
        NSMutableDictionary * headerValueDict = nil ;
        if([header_Value_array count] != 0)
        {
           headerValueDict = [header_Value_array objectAtIndex:0];
        }
        
        NSArray *  all_Keys_values = [headerValueDict allKeys];
        
        for(int i=0; i <[header_sections count] ;i++)
        {
            NSDictionary * section_info = [header_sections objectAtIndex:i];
            NSMutableArray * sectionFileds= [section_info objectForKey:@"section_Fields"];
            
            for(int j= 0;j<[sectionFileds count]; j++)
            {
                NSMutableDictionary * filed_info =[sectionFileds objectAtIndex:j];
                NSString * filed_api_name = [filed_info objectForKey:gFIELD_API_NAME];
                NSString * field_data_type = [filed_info objectForKey:gFIELD_DATA_TYPE];
                NSString * field_value = @"";
                NSString * field_key = @"";
                
                for(int k=0;k < [all_Keys_values count];k++)
                {
                    NSString * key = [all_Keys_values objectAtIndex:k];
                    if([key isEqualToString:filed_api_name])
                    {
                        field_key = [headerValueDict objectForKey:[all_Keys_values objectAtIndex:k]];
                        
                        if([field_data_type isEqualToString:@"picklist"])
                        {
                            //query to acces the picklist values for lines 
                            NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:filed_api_name tableName:SFPicklist objectName:headerObjName];
                            NSArray * allKeys = [picklistValues allKeys];
                            for(NSString * value_dict in allKeys)
                            {
                                if([value_dict isEqualToString:field_key])
                                {
                                    field_value =[picklistValues objectForKey:field_key];
                                    break;
                                }
                            }
                        }
                        
                        else if([field_data_type isEqualToString:@"reference"] && (![filed_api_name isEqualToString:@"RecordTypeId"]))
                        {
                            if([field_key isEqualToString:@""] || [field_key length ] == 0 || field_key == nil )
                            {
                                field_value = field_key;
                            }
                            else
                            {
                                NSMutableArray * referenceTotableNames = [appDelegate.databaseInterface getReferenceToForField:filed_api_name objectapiName:headerObjName tableName:SF_REFERENCE_TO];
                                
                                
                                if([referenceTotableNames count ] > 0)
                                {
                                    NSString * reference_to_tableName = [referenceTotableNames objectAtIndex:0];
                                    
                                    NSString * referenceTo_Table_fieldName = [appDelegate.databaseInterface getFieldNameForReferenceTable:reference_to_tableName tableName:SFOBJECTFIELD];
                                    
                                    field_value = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:reference_to_tableName field_name:referenceTo_Table_fieldName record_id:field_key];
                                    
                                }
                                if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
                                {
                                    field_value = [appDelegate.databaseInterface getLookUpNameForId:field_key];
                                    if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
                                    {
                                        field_value = field_key;
                                    }
                                }
                                break;

                            }
                        }
                        
                        else if([field_data_type isEqualToString:@"reference"] && [filed_api_name isEqualToString:@"RecordTypeId"])
                        {
                            if([field_key isEqualToString:@""] || [field_key length ] == 0 || field_key == nil )
                            {
                                field_value = field_key;
                            }
                            else
                            {
                                NSMutableArray * referenceTotableNames = [appDelegate.databaseInterface getReferenceToForField:filed_api_name objectapiName:headerObjName tableName:SF_REFERENCE_TO];
                                
                                
                                if([referenceTotableNames count ] > 0)
                                {
                                    NSString * reference_to_tableName = [referenceTotableNames objectAtIndex:0];
                                    
                                    NSString * referenceTo_Table_fieldName = [appDelegate.databaseInterface getFieldNameForReferenceTable:reference_to_tableName tableName:SFOBJECTFIELD];
                                    
                                    field_value = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:reference_to_tableName field_name:referenceTo_Table_fieldName record_id:field_key];
                                    
                                    if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
                                    {
                                        field_value = [appDelegate.dataBase getValueForRecordtypeId:field_key object_api_name:headerObjName];
                                    }
                                    
                                }
                                if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
                                {
                                    field_value = [appDelegate.databaseInterface getLookUpNameForId:field_key];
                                    if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
                                    {
                                        field_value = field_key;
                                    }
                                }
                                break;
                                
                            }
                        }

                        else if([field_data_type isEqualToString:@"datetime"])
                        {
                            NSString * date = field_key;
                            date = [date stringByDeletingPathExtension];
                            field_key = date;
                            field_value = date;
                        }
                        
                        else if([field_data_type isEqualToString:@"date"])
                        {
                            NSString * date = field_key;
                            date = [date stringByDeletingPathExtension];
                            field_key = date;
                            field_value = date;
                        }
                        
                        else if([field_data_type isEqualToString:@"multipicklist"])
                        {
                            NSArray * fieldKeys = [field_key componentsSeparatedByString:@";"];
                            NSMutableArray * valuesArray = [[NSMutableArray alloc] initWithCapacity:0];
                            //query to acces the picklist values for lines 
                            NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:filed_api_name tableName:SFPicklist objectName:headerObjName];
                            
                            NSArray * allKeys = [picklistValues allKeys];
                            for(NSString * value_dict in allKeys)
                            {
                                for(NSString * key  in fieldKeys)
                                {
                                    if([value_dict isEqualToString:key])
                                    {
                                        [valuesArray addObject:[picklistValues objectForKey:key]];
                                        break;
                                    }
                                }
                            }
                            NSInteger count_ = 0;
                            for(NSString * each_label in valuesArray)
                            {
                                if(count_ != 0)
                                    field_value = [field_value stringByAppendingString:@";"];
                                field_value = [field_value stringByAppendingString:each_label];
                                count_ ++;
                                
                            }
                            
                            if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
                            {
                                field_value = field_key;
                            }
                            
                        }
                        else
                        {
                            field_value = field_key;
                        }
                        
                        break;
                    }
                }
                
                [filed_info setObject:field_key forKey:gFIELD_VALUE_KEY];
                [filed_info setObject:field_value forKey:gFIELD_VALUE_VALUE];
            }
        }
        
        
        //coding for detail Section 
        
        for(int j= 0; j < [details count]; j++)
        {
            NSMutableDictionary * dict = [details objectAtIndex:j];
            NSMutableArray * filedsArray = [dict objectForKey:gDETAILS_FIELDS_ARRAY];
            NSMutableArray * detailValuesArray = [dict objectForKey:gDETAILS_VALUES_ARRAY];
            NSMutableArray * detail_Values_id = [dict objectForKey:gDETAIL_VALUES_RECORD_ID];
            NSMutableArray * details_api_keys = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
            NSString * detailObjectName = [dict objectForKey:gDETAIL_OBJECT_NAME];
            
            //NSString * detailaliasName = [dict objectForKey:gDETAIL_OBJECT_ALIAS_NAME];
            NSString * detail_layout_id = [dict objectForKey:gDETAILS_LAYOUT_ID];
            
            for(int k =0 ;k<[filedsArray count];k++)
            {
                NSMutableDictionary * detailFiled_info =[filedsArray objectAtIndex:k];
                NSString * api_name = [detailFiled_info objectForKey:gFIELD_API_NAME];
                [details_api_keys addObject:api_name];
            }
            
            NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGETCHILD process_id:processId layoutId:detail_layout_id objectName:detailObjectName];
            
            NSString * source_child_object_name = [process_components objectForKey:SOURCE_OBJECT_NAME];
            NSString * source_child_parent_column = [process_components objectForKey:SOURCE_CHILD_PARENT_COLUMN];
            
            if([source_child_parent_column isEqualToString:@""] || [source_child_parent_column length] == 0)
            {
               source_child_parent_column  =  [ appDelegate.databaseInterface getParentColumnNameFormChildInfoTable:SFChildRelationShip childApiName:source_child_object_name parentApiName:source_parent_object_name];
            }
         
            
//            NSString * parent_column_name = [process_components objectForKey:PARENT_COLUMN_NAME];
            
            NSArray * detailkeys = [NSArray arrayWithObjects:gVALUE_FIELD_API_NAME,gVALUE_FIELD_VALUE_KEY,gVALUE_FIELD_VALUE_VALUE, nil];
            
                            
            NSMutableArray * object_mapping_array = [appDelegate.databaseInterface getObjectMappingForMappingId:process_components source_record_id:appDelegate.sfmPageController.sourceRecordId field_name:source_child_parent_column];
            
            for(int p = 0 ; p <[object_mapping_array count]; p++)
            {   
                NSMutableDictionary * object_mapping_dict = [object_mapping_array  objectAtIndex:p];
                NSArray * object_mapping_keys = [object_mapping_dict allKeys];
                NSMutableArray * each_detail_array = [[NSMutableArray alloc] initWithCapacity:0];
                
                for(int x = 0 ; x < [object_mapping_keys count]; x++)
                {
                    NSString * object_mapping_key = [object_mapping_keys objectAtIndex:x]; 
                    BOOL field_exist = FALSE;
                    NSString * field_key = @"" , * field_value = @"" ;
                    NSString * data_type= @"";
                    
                    for (int q = 0 ; q < [filedsArray count]; q++)
                    {
                        NSMutableDictionary * field = [filedsArray objectAtIndex:q];
                        NSString * field_api_name = [field objectForKey:gFIELD_API_NAME];
                        data_type = [field objectForKey:gFIELD_DATA_TYPE];
                        
                        if([object_mapping_key isEqualToString:field_api_name])
                        {
                            field_key = [object_mapping_dict objectForKey:object_mapping_key];
                            field_exist = TRUE;
                            break;
                        }
                    }
                    
                    if(field_exist == TRUE)
                    {
                        if([field_key length] != 0)
                        {
                            
                            field_value = [self getValueForApiName:object_mapping_key dataType:data_type object_name:detailObjectName field_key:field_key];
                            
                            if([data_type isEqualToString:@"datetime"] || [data_type isEqualToString:@"date"])
                            {
                                field_key = field_value ;
                            }
                            else if([data_type isEqualToString:@"multipicklist"])
                            {
                            }
                            else if([data_type isEqualToString:@"reference"])
                            {
                                
                            } 
                            else if([data_type isEqualToString:@"picklist"])
                            {
                            }
                            else
                            {
                                field_value = field_key; 
                            }
                        }
                        
                    }

                    if(!field_exist)
                    {
                        field_key = [object_mapping_dict objectForKey:object_mapping_key];
                        field_value = [object_mapping_dict objectForKey:object_mapping_key];
                    }
                    
                    NSMutableArray * detailObjects = [NSMutableArray arrayWithObjects:
                                                      object_mapping_key,
                                                      field_key,
                                                      field_value,
                                                      nil];
                    
                    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:detailObjects forKeys:detailkeys];
                    
                    [each_detail_array addObject:dict];

            }
            for (int q = 0 ; q < [filedsArray count]; q++)
            {
                NSMutableDictionary * field = [filedsArray objectAtIndex:q];
                BOOL field_exist = FALSE;
                NSString * field_api_name = [field objectForKey:gFIELD_API_NAME];
                for(NSString * object_mapping_key in object_mapping_keys)
                {
                    if([object_mapping_key isEqualToString:field_api_name])
                    {
                        field_exist = TRUE;
                        break;
                    }
                }
                if(field_exist)
                {
                    
                }
                else
                {
                    NSMutableArray * detailObjects = [NSMutableArray arrayWithObjects:
                                                      field_api_name,
                                                      @"",
                                                      @"",
                                                      nil];
                    
                    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:detailObjects forKeys:detailkeys];
                    
                    [each_detail_array addObject:dict];
                }
            }

        
            //adding additional flag to the values array 
            NSMutableArray * detailObjects = [NSMutableArray arrayWithObjects:
                                              gDETAIL_SAVED_RECORD,
                                              [NSNumber numberWithInt:1],
                                              [NSNumber numberWithInt:1], nil];
                
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:detailObjects forKeys:detailkeys];
            [each_detail_array addObject:dict];
                
            [detailValuesArray addObject:each_detail_array];
            [detail_Values_id  addObject:@""];
          }
        
        }
    }
    
    else if([process_type isEqualToString:@"EDIT"])
    {
        NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGET process_id:processId layoutId:layout_id objectName:headerObjName];
        //[appDelegate.databaseInterface  getValueMappingForlayoutId:layout_id process_id:processId objectName:headerObjName];
        
        NSString * expression_id = [process_components objectForKey:EXPRESSION_ID];
        //SMLog(" record id %@" ,appDelegate.sfmPageController.recordId);
        NSMutableDictionary * headerValueDict = [appDelegate.databaseInterface queryDataFromObjectTable:api_names tableName:headerObjName record_id:appDelegate.sfmPageController.recordId expression:expression_id];
        
		//Change of Code for quick save. --> 10/07/2012  -- #4665
		BOOL Entry_criteria = [appDelegate.databaseInterface EntryCriteriaForRecordFortableName:headerObjName record_id:appDelegate.sfmPageController.recordId expression:expression_id];
        
        if(!Entry_criteria)
        {
			NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
            NSString * headerObjName = [hdr_object objectForKey:gHEADER_OBJECT_NAME];
            
            [self initAllrequriredDetailsForProcessId:appDelegate.sfmPageController.sourceProcessId recordId:appDelegate.sfmPageController.recordId object_name:headerObjName];
            [self fillSFMdictForOfflineforProcess:appDelegate.sfmPageController.sourceProcessId forRecord:appDelegate.sfmPageController.recordId ];
            [self didReceivePageLayoutOffline]; 
			
            NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_swich_process];
            NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
            NSString * cancel_ = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE];
			
            UIAlertView * enty_criteris = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel_ otherButtonTitles:nil, nil];
            [enty_criteris show];
            [enty_criteris release];
			return;
        }
		
		
		NSMutableDictionary * value_mapping_dict = [appDelegate.databaseInterface getObjectMappingForMappingId:process_components mappingType:VALUE_MAPPING];
		
		NSArray * valueMapping_keys = [value_mapping_dict allKeys];

		
        NSArray * all_Keys_values = [headerValueDict allKeys];
        
        for(int i=0; i <[header_sections count] ;i++)
        {
            NSDictionary * section_info = [header_sections objectAtIndex:i];
            NSMutableArray * sectionFileds= [section_info objectForKey:@"section_Fields"];
            
            for(int j= 0;j<[sectionFileds count]; j++)
            {
                NSMutableDictionary * filed_info =[sectionFileds objectAtIndex:j];
                NSString * filed_api_name = [filed_info objectForKey:gFIELD_API_NAME];
                NSString * field_data_type = [filed_info objectForKey:gFIELD_DATA_TYPE];
                NSString * field_value = @"";
                NSString * field_key = @"";
                
                for(int k=0;k < [all_Keys_values count];k++)
                {
                    NSString * key = [all_Keys_values objectAtIndex:k];
                    if([key isEqualToString:filed_api_name])
                    {
                        field_key = [headerValueDict objectForKey:[all_Keys_values objectAtIndex:k]];
                        if([field_key length] != 0)
                        {
                            field_value = [self getValueForApiName:filed_api_name dataType:field_data_type object_name:headerObjName field_key:field_key];
                            
                            if([field_data_type isEqualToString:@"datetime"] || [field_data_type isEqualToString:@"date"])
                            {
                                field_key = field_value ;
                            }
                            else if([field_data_type isEqualToString:@"multipicklist"])
                            {
                            }
                            else if([field_data_type isEqualToString:@"reference"])
                            {
                                
                            } 
                            else if([field_data_type isEqualToString:@"picklist"])
                            {
                            }
                            else
                            {
                                field_value = field_key; 
                            }
                        }
                    }
                }
                
				
				for(int e = 0 ; e <[valueMapping_keys count]; e++)
				{
					NSString * key = [valueMapping_keys objectAtIndex:e];
                    if([key isEqualToString:filed_api_name])
                    {
                        field_key = [value_mapping_dict objectForKey:key];
                        if([field_key length] != 0)
                        {
                            field_value = [self getValueForApiName:filed_api_name dataType:field_data_type object_name:headerObjName field_key:field_key];
                            
                            if([field_data_type isEqualToString:@"datetime"] || [field_data_type isEqualToString:@"date"])
                            {
                                field_key = field_value ;
                            }
                            else if([field_data_type isEqualToString:@"multipicklist"])
                            {
                            }
                            else if([field_data_type isEqualToString:@"reference"])
                            {
                                
                            } 
                            else if([field_data_type isEqualToString:@"picklist"])
                            {
                            }
                            else
                            {
                                field_value = field_key; 
                            }
                        }
                    }
				}
				
				
                [filed_info setObject:field_key forKey:gFIELD_VALUE_KEY];
                [filed_info setObject:field_value forKey:gFIELD_VALUE_VALUE];
            }
        }
        
        for(int j= 0; j < [details count]; j++)
        {
            NSMutableDictionary * dict = [details objectAtIndex:j];
            NSMutableArray * filedsArray = [dict objectForKey:gDETAILS_FIELDS_ARRAY];
            NSMutableArray * detailValuesArray = [dict objectForKey:gDETAILS_VALUES_ARRAY];
            NSMutableArray * detail_Values_id = [dict objectForKey:gDETAIL_VALUES_RECORD_ID];
            NSMutableArray * details_api_keys = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
            NSString * detailObjectName = [dict objectForKey:gDETAIL_OBJECT_NAME];
            NSString * detailaliasName = [dict objectForKey:gDETAIL_OBJECT_ALIAS_NAME];
            NSString * detail_layout_id = [dict objectForKey:gDETAILS_LAYOUT_ID];
            
            for(int k =0 ;k<[filedsArray count];k++)
            {
                NSMutableDictionary * detailFiled_info =[filedsArray objectAtIndex:k];
                NSString * api_name = [detailFiled_info objectForKey:gFIELD_API_NAME];
                [details_api_keys addObject:api_name];
            }
            
            NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGETCHILD process_id:processId layoutId:detail_layout_id objectName:detailObjectName];
			NSMutableDictionary * detail_value_mapping_dict = [appDelegate.databaseInterface getObjectMappingForMappingId:process_components mappingType:VALUE_MAPPING];
			
			NSArray * detail_value_mapping_keys = [detail_value_mapping_dict allKeys];
            NSString * expressionId = [process_components objectForKey:EXPRESSION_ID];
            NSString * parent_column_name = [dict objectForKey:gDETAIL_HEADER_REFERENCE_FIELD];
            
            NSMutableArray * detail_values = [appDelegate.databaseInterface queryLinesInfo:details_api_keys detailObjectName:detailObjectName headerObjectName:headerObjName detailaliasName:detailaliasName headerRecordId:appDelegate.sfmPageController.recordId expressionId:expressionId parent_column_name:parent_column_name];
            
			NSMutableDictionary * api_name_dataType = [appDelegate.databaseInterface getAllFieldsAndItsDataTypesForObject:detailObjectName tableName:SFOBJECTFIELD];
			
			
            for(int l = 0 ;l < [detail_values count]; l++)
            {
                [detailValuesArray addObject:[detail_values objectAtIndex:l]]; 
                NSMutableArray *  eachArray = [detail_values objectAtIndex:l];
                BOOL value_id_flag = FALSE;
                NSString  * id_ = @"";
                for(int m = 0 ; m < [eachArray count];m++)
                {   
                    NSMutableDictionary * dict = [eachArray objectAtIndex:m];
                    NSString * api_name = [dict objectForKey:gVALUE_FIELD_API_NAME];
                    NSString * key = [dict objectForKey:gVALUE_FIELD_VALUE_KEY];
                    if([api_name isEqualToString:@"local_id"])
                    {
                        id_ = key;
                        value_id_flag = TRUE;
                    }
					
//					for(int e = 0 ; e < [detail_value_mapping_keys count]; e++)
//					{
//						NSString  * detail_value_api = [detail_value_mapping_keys objectAtIndex:e];
//					
//						if([detail_value_api isEqualToString:api_name])
//						{
//							if([detail_value_api length] != 0)
//							{
//								NSString *  detail_value_key  =  [detail_value_mapping_dict objectForKey:detail_value_api];
//								NSString * field_data_type  = [api_name_dataType objectForKey:detail_value_api];
//                                // Sahana fix for defect 5826
//								NSString * detil_value_value = [self getValueForApiName:detail_value_api dataType:field_data_type object_name:detailObjectName field_key:detail_value_key];
//								[dict setObject:detail_value_key forKey:gVALUE_FIELD_VALUE_KEY];
//								[dict setObject:detil_value_value forKey:gVALUE_FIELD_VALUE_VALUE];
//								break;
//							}
//						}
//					}
                }
				
                if(value_id_flag)
                {
                    [detail_Values_id addObject:id_];
                }
            }
            
//            [details_api_keys release];
            
        }

    }
    appDelegate.SFMoffline = page_layoutInfo;

    appDelegate.didsubmitModelView = TRUE;
    
    
}


#pragma mark = Select Process ID
- (void) didSubmitProcess:(NSString *)processId forRecord:(NSString *)recordId
{
    [activity startAnimating];
    
    if ((processId == nil) || ([processId length] == 0))
    {
        [activity stopAnimating];
        
        [self enableSFMUI];
        return;
    }
        // processId = @"TDM016";  //@"CREATEWO";//@"TDM003"; //TDM016 for work order lines
    //recordId = nil;
    if ((recordId == nil) || ([recordId length] == 0))
        recordId = nil; //@"a0oA0000004lDTg"; //nil;
    currentProcessId = processId;
    currentRecordId = recordId;
    
    appDelegate.currentProcessID = currentProcessId;
    
    WSInterface * wsinterface = [[WSInterface alloc] init];
    wsinterface.delegate = self;
    wsinterface.detailDelegate = self;
    [wsinterface getPageLayoutWithProcessId:processId RecordId:recordId];
    // [self getPageLayout];
    [sp release];
    sp = nil;
    
   while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
    {
        SMLog(@"didSubmitProcess In While Loop");
        if(appDelegate.isWorkinginOffline)
        {
            
        }
        else
        {
            if (![appDelegate isInternetConnectionAvailable])
            {
                [activity stopAnimating];
                appDelegate.wsInterface.sfm_response = FALSE;
                //[appDelegate displayNoInternetAvailable];
                /*if (appDelegate.SFMPage != nil)
                {
                    [appDelegate.SFMPage release];
                    appDelegate.SFMPage = nil;
                }*/
                [self enableSFMUI];
                return;
            }
        }
        if(appDelegate.wsInterface.sfm_response == TRUE)
        {
            appDelegate.wsInterface.sfm_response = FALSE;
            break;
        }
    }
    if(appDelegate.wsInterface.errorLoadingSFM == TRUE)
    {
        [self enableSFMUI];
        return;
    }
    else
    {
        [activity startAnimating];
    }
    
    [self enableSFMUI];
}

- (void) selectProcess:(id)sender
{
    // Dismiss Content PopOver if already showing
    if (self.popoverController != nil)
    {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    
    if (sp != nil)
    {
        [sp.popOver dismissPopoverAnimated:YES];
        [sp release];
        sp = nil;
        
        return;
    }

    sp = [[selectProcess alloc] initWithNibName:@"selectProcess" bundle:nil];
    sp.delegate = self;
    [sp view];
    [sp setProcessId:currentProcessId forRecordId:currentRecordId];
    
    UIPopoverController * popover = [[UIPopoverController alloc] initWithContentViewController:sp];
    popover.popoverContentSize = sp.view.frame.size;
    popover.delegate = self;
    sp.popOver = popover;
    [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    [sp release];
}

- (void) action:(id)sender
{
    if (actionMenu)
    {
        [actionMenu.popover dismissPopoverAnimated:YES];
        actionMenu = nil;
        return;
    }
    
    if (sfwToolBar)
    {
        [sfwToolBar.popOver dismissPopoverAnimated:YES];
        sfwToolBar = nil;
    }


    NSMutableDictionary * headerDataDictionary = [appDelegate.SFMPage objectForKey:gHEADER];
    NSString * heder_object_name = [headerDataDictionary  objectForKey:gHEADER_OBJECT_NAME];
    NSMutableArray * headerButtons = [headerDataDictionary objectForKey:gHEADER_BUTTONS];
    
    actionMenu = [[ActionMenu alloc] initWithNibName:@"ActionMenu" bundle:nil];
    
    sfwToolBar = [[SFWToolBar alloc] initWithNibName:@"SFWToolBar" bundle:nil];
    
    sfwToolBar.delegate = self;

    
    NSMutableArray * buttonsArray_offline = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    NSMutableDictionary * wizard_dict= [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    
    NSMutableArray * ipad_only_array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        
    if ([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"VIEWRECORD"]) 
    {
         wizard_dict =[appDelegate.databaseInterface getWizardInformationForObjectname:heder_object_name record_id:appDelegate.sfmPageController.recordId];
         buttonsArray_offline  = [wizard_dict objectForKey:SFW_WIZARD_BUTTONS];
    }
    // Insert 3 buttons at the beginning
    NSMutableArray  *keys_event = nil, *objects_event = nil;
    
    objects_event = [NSArray arrayWithObjects:@"",save,@"",@"",gBUTTON_TYPE_TDM_IPAD_ONLY ,@"",@"true",nil];
    keys_event = [NSArray arrayWithObjects:SFW_ACTION_ID,SFW_ACTION_DESCRIPTION,SFW_EXPRESSION_ID,SFW_PROCESS_ID,SFW_ACTION_TYPE ,SFW_WIZARD_ID,SFW_ENABLE_ACTION_BUTTON,nil]; 
    NSMutableDictionary * dict_events_save = [NSMutableDictionary dictionaryWithObjects:objects_event forKeys:keys_event];
    
    objects_event = [NSArray arrayWithObjects:@"",cancel,@"",@"",gBUTTON_TYPE_TDM_IPAD_ONLY ,@"",@"true",nil];
    keys_event = [NSArray arrayWithObjects:SFW_ACTION_ID,SFW_ACTION_DESCRIPTION,SFW_EXPRESSION_ID,SFW_PROCESS_ID,SFW_ACTION_TYPE ,SFW_WIZARD_ID,SFW_ENABLE_ACTION_BUTTON,nil]; 
    NSMutableDictionary * dict_events_cancel = [NSMutableDictionary dictionaryWithObjects:objects_event forKeys:keys_event];
    
    objects_event = [NSArray arrayWithObjects:@"",summary,@"",@"",gBUTTON_TYPE_TDM_IPAD_ONLY ,@"",@"true",nil];
    keys_event = [NSArray arrayWithObjects:SFW_ACTION_ID,SFW_ACTION_DESCRIPTION,SFW_EXPRESSION_ID,SFW_PROCESS_ID,SFW_ACTION_TYPE ,SFW_WIZARD_ID,SFW_ENABLE_ACTION_BUTTON,nil]; 
    NSMutableDictionary * dict_events_summury = [NSMutableDictionary dictionaryWithObjects:objects_event forKeys:keys_event];
    
    objects_event = [NSArray arrayWithObjects:@"",troubleShooting,@"",@"",gBUTTON_TYPE_TDM_IPAD_ONLY ,@"",@"true",nil];
    keys_event = [NSArray arrayWithObjects:SFW_ACTION_ID,SFW_ACTION_DESCRIPTION,SFW_EXPRESSION_ID,SFW_PROCESS_ID,SFW_ACTION_TYPE ,SFW_WIZARD_ID,SFW_ENABLE_ACTION_BUTTON,nil]; 
    NSMutableDictionary * dict_events_troubleShooting = [NSMutableDictionary dictionaryWithObjects:objects_event forKeys:keys_event];
	
	//New Wizard buttons fro refreshing the record.
    
   
	objects_event = [NSArray arrayWithObjects:@"",dod_title,@"",@"",gBUTTON_TYPE_TDM_IPAD_ONLY ,@"",@"true",nil];
    keys_event = [NSArray arrayWithObjects:SFW_ACTION_ID,SFW_ACTION_DESCRIPTION,SFW_EXPRESSION_ID,SFW_PROCESS_ID,SFW_ACTION_TYPE ,SFW_WIZARD_ID,SFW_ENABLE_ACTION_BUTTON,nil];
    NSMutableDictionary * dict_refresh_record = [NSMutableDictionary dictionaryWithObjects:objects_event forKeys:keys_event];

    
	objects_event = [NSArray arrayWithObjects:@"",quick_save,@"",@"",gBUTTON_TYPE_TDM_IPAD_ONLY ,@"",@"true",nil];
    keys_event = [NSArray arrayWithObjects:SFW_ACTION_ID,SFW_ACTION_DESCRIPTION,SFW_EXPRESSION_ID,SFW_PROCESS_ID,SFW_ACTION_TYPE ,SFW_WIZARD_ID,SFW_ENABLE_ACTION_BUTTON,nil];
    NSMutableDictionary * dict_events_quicksave = [NSMutableDictionary dictionaryWithObjects:objects_event forKeys:keys_event];
    
  
   // if ([headerButtons count] > 0)
        
    for(int i = 0 ; i< [headerButtons count];i++)   
    {
        NSMutableDictionary * dict_events_getPrice = nil;
        NSDictionary * button_dict = [headerButtons objectAtIndex:i];
        NSString * flag_ = @"";
        NSNumber * enable = [button_dict objectForKey:@"Enable"];   
        NSInteger value = [enable integerValue];
      
        if (value == 1)
            flag_ = @"true";
        else
            flag_ = @"false";
        
        NSMutableArray * array = [button_dict objectForKey:@"button_Events"];
        NSString * button_type = ([[array objectAtIndex:0] objectForKey:@"SVMXC__Event_Call_Type__c"]!= nil)?[[array objectAtIndex:0] objectForKey:@"SVMXC__Event_Call_Type__c"]:@"";
        
            
        objects_event = [NSArray arrayWithObjects:@"",([button_dict objectForKey:@"button_Title"] != nil)?[button_dict objectForKey:@"button_Title"]:@"",@"",@"",button_type ,@"",flag_,nil];
        keys_event = [NSArray arrayWithObjects:SFW_ACTION_ID,SFW_ACTION_DESCRIPTION,SFW_EXPRESSION_ID,SFW_PROCESS_ID,SFW_ACTION_TYPE ,SFW_WIZARD_ID,SFW_ENABLE_ACTION_BUTTON,nil]; 
        if(dict_events_getPrice == nil)
            dict_events_getPrice = [NSMutableDictionary dictionaryWithObjects:objects_event forKeys:keys_event];
        
        if(value)
        {
            [buttonsArray_offline addObject:dict_events_getPrice];
        }
    }

    
    if ([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"VIEWRECORD"]) 
    {
        NSDictionary * header_dict = [appDelegate.SFMPage objectForKey:@"header"];
        
        if([heder_object_name isEqualToString:@"SVMXC__Service_Order__c"])
        {
            BOOL enable_troubleShooting = [[header_dict objectForKey:gENABLE_TROUBLESHOOTING] boolValue];
            if (enable_troubleShooting)
            {
                [ipad_only_array addObject:dict_events_troubleShooting];   
            }
            
            BOOL enable_summary = [[header_dict objectForKey:gENABLE_SUMMARY] boolValue];
            if (enable_summary)
            {
                [ipad_only_array addObject:dict_events_summury];
            }
          
        }
    
        BOOL check_On_demand = [appDelegate.databaseInterface checkOndemandRecord:currentRecordId];
        if(check_On_demand)
        {
            [ipad_only_array addObject:dict_refresh_record];
        }
    }
    if ([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"EDIT"] || [[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"SOURCETOTARGETONLYCHILDROWS"]) 
    {
        //[buttonsArray_offline  addObject:];
        appDelegate.wsInterface.refreshSyncButton = self;

        NSDictionary * header_dict = [appDelegate.SFMPage objectForKey:@"header"];
        
//        NSInteger value = 0;
        if ([headerButtons count] > 0)
        {
            //NSDictionary * button_dict = [headerButtons objectAtIndex:0];
//            NSNumber * enable = [button_dict objectForKey:@"Enable"];   
//            value = [enable integerValue];
        }
        
        NSString * hideQuickSave = [NSString stringWithFormat:@"%@", [header_dict objectForKey:gHEADER_SHOW_HIDE_QUICK_SAVE]];
        
        NSString * hideSave = [NSString stringWithFormat:@"%@", [header_dict objectForKey:gHEADER_SHOW_HIDE_SAVE]];
        
        if([hideSave isEqualToString:@""])
        {
            [buttonsArray_offline  addObject:dict_events_save];
        }
        if([hideQuickSave isEqualToString:@""])
        {
            [buttonsArray_offline  addObject:dict_events_quicksave];
        }
        
        if([hideQuickSave length ] != 0)
        {
            BOOL qick_save_flag = [hideQuickSave boolValue];
            
            if(!qick_save_flag)
            {            
                [buttonsArray_offline  addObject:dict_events_quicksave];
            }
            
        }       
        if([hideSave length ] != 0)
        {
            BOOL save_flag = [hideSave boolValue];
            if(!save_flag)
            {
              [buttonsArray_offline  addObject:dict_events_save]; 
                
            }
        }
        [buttonsArray_offline  addObject:dict_events_cancel];
        
        /*if (value == 1)
        {
            [buttonsArray_offline addObject:dict_events_getPrice];
        }*/
        
    }
    if([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"STANDALONECREATE"] || [[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"SOURCETOTARGET"])
    {
        
        NSDictionary * header_dict = [appDelegate.SFMPage objectForKey:@"header"];
                
        NSString * hideSave =[NSString stringWithFormat:@"%@", [header_dict objectForKey:gHEADER_SHOW_HIDE_SAVE]];
        
        if([hideSave length] == 0)
        {
            [buttonsArray_offline  addObject:dict_events_save];        
        }
        else
        {   
            //BOOL qick_save_flag = [HideQickSave boolValue];
            BOOL save_flag = [hideSave boolValue];
            if(!save_flag)
            {
                [buttonsArray_offline  addObject:dict_events_save];
            }
            
        }
        [buttonsArray_offline addObject:dict_events_cancel];
    }

    actionMenu.buttons = buttonsArray_offline;
    
    sfwToolBar.ipad_only_array = ipad_only_array;
    sfwToolBar.buttonsArray_offline = buttonsArray_offline;
    sfwToolBar.wizard_info = wizard_dict;

      
    if (appDelegate.SFMPage != nil)
    {
        
        SMLog(@" action buttons %@",actionMenu.buttons);
        
        if([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"EDIT"]||[[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"STANDALONECREATE"] || [[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"SOURCETOTARGET"]||[[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"SOURCETOTARGETONLYCHILDROWS"])
        {
            actionMenu.delegate = self;
            UIPopoverController * popover = [[UIPopoverController alloc] initWithContentViewController:actionMenu];
            popover.delegate = self;
            actionMenu.popover = popover;
            [popover presentPopoverFromBarButtonItem:actionBtn permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        }
        
        if ([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"VIEWRECORD"]) 
        {
            
            NSMutableDictionary * wizard_buttons = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
            
            //shrinivas fix for defect #4333
            if ([ipad_only_array count] > 0)
            {
                
                NSString * str = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_sfw_header];
                
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:str,@"0001TS",str, nil] forKeys:[NSArray arrayWithObjects:@"wizard_description",@"wizard_id", @"wizard_name", nil]];
                
                [[wizard_dict objectForKey:@"sfw_wizard_info"] insertObject:dict atIndex:0];
                
                
                for (int i = 0;i < [ipad_only_array count]; i++)
                {
                    [[ipad_only_array objectAtIndex:i] setValue:@"0001TS" forKey:@"wizard_id"];
                    [[wizard_dict objectForKey:@"sfw_wizard_button"] insertObject:[ipad_only_array objectAtIndex:i] atIndex:i];
                }
                
            }

            NSMutableArray * array = [wizard_dict objectForKey:SFW_WIZARD_INFO];
            
            int Total_height = 0;
            for(int i = 0; i < [array count];i++)
            {
                NSDictionary * dict = [array objectAtIndex:i];
                NSString * wizard_id = [dict objectForKey:WIZARD_ID];
                NSMutableArray * buttons_ = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                for(int j = 0 ; j < [buttonsArray_offline count];j++)
                {
                    NSDictionary * dict = [buttonsArray_offline objectAtIndex:j];
                    NSString * id_  = [dict objectForKey:WIZARD_ID];
                    if([id_ isEqualToString:wizard_id])
                    {
                        [buttons_ addObject:dict];
                    }
                }
                
                [wizard_buttons setObject:buttons_ forKey:wizard_id];
            }
            
            for(int section = 0; section < [array count]; section ++)
            {
                NSDictionary * dict = [array objectAtIndex:section];
                NSString * wizard_id = [dict objectForKey:WIZARD_ID];
               
                NSArray * allkeys = [wizard_buttons allKeys];
                for(int k = 0 ; k< [allkeys count]; k++)
                {
                    NSString * key_id = [allkeys objectAtIndex:k];
                    if([key_id isEqualToString:wizard_id])
                    {
                        NSArray * wizard = [wizard_buttons objectForKey:key_id];
//                        int button_count = [wizard count];
                        int row; 
                        NSInteger quotient = [wizard count] / 6;
                        NSInteger reminder = [wizard count] % 6;
                        if(reminder != 0)
                        {
                            row =  quotient +1;
                        }
                        else
                        {
                            row =  quotient;
                        }
                        
                        for(int row_count = 0 ;row_count < row; row_count++)
                        {
                           //int row_count ;
                            int x = row_count * 6;
                            CGFloat final_height = 0;
                            CGFloat temp_height  = 0;

                            for(int j = x ; j < (x+6) ;j++)
                            {
                                
                                if(j >= [wizard count])
                                {
                                    break;
                                }
                                NSDictionary * each_button = [wizard objectAtIndex:j];
                                NSString * str = [each_button objectForKey:SFW_ACTION_DESCRIPTION];
                                CGSize size1 = [str sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(150, 9999)];
                                temp_height = size1.height;
                                
                                if(temp_height > final_height)
                                {
                                    final_height = temp_height;
                                }
                            }
                            
                            if(final_height < 40)
                                Total_height = Total_height+ 60+30;
                            else
                                Total_height = Total_height+final_height+30+30;
                            

                        }

                        
                    }
                    
                }
                //Total_height = Total_height + 20;
                
            }
            
            /*if([ipad_only_array count] > 0)
            {
                Total_height = Total_height +40 ;
            }*/
            

            UIPopoverController * popover = [[[UIPopoverController alloc] initWithContentViewController:sfwToolBar] autorelease];
            [popover setPopoverContentSize:CGSizeMake(1024, Total_height)];
            popover.delegate = self;
            CGPoint p ;
            CGSize q;
            q.width = appDelegate.sfmPageController.rootView.view.frame.size.width;
            
            p.x = appDelegate.sfmPageController.detailView.view.frame.origin.x;
            p.y = appDelegate.sfmPageController.detailView.view.frame.origin.y;
             UIImageView * bgImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_left_panel_bg_main_2.png"]] autorelease];
            sfwToolBar.sfw_tableview.backgroundView = bgImage;
            sfwToolBar.ipad_only_view.backgroundColor = [UIColor whiteColor];
            [popover presentPopoverFromRect:CGRectMake(900, 21, 67, 20) inView:appDelegate.sfmPageController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            sfwToolBar.popOver = popover;
            //[sfwToolBar showIpadOnlyButtons];

        }
    }
}
    
#pragma mark - wsInterface Delegate Methods
- (void) didFinishWithError:(SOAPFault *)sFault
{
    [activity stopAnimating];
    NSString *   soap_fault =  sFault.faultstring;
//    if([soap_fault Contains:@"System.LimitException"])
//    {
//        soap_fault = @"Meta Sync Failed Due To Too Many Script. Please contact your System Administrator.";
//       // appDelegate.didFinishWithError = TRUE;
//    }

    NSString * response_error = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_RESPONSE_ERROR];
    NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    UIAlertView * _alert = [[UIAlertView alloc] initWithTitle:response_error message:soap_fault delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
	
	[_alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
	[_alert release];
}

#pragma mark - ActionMenu Delegate Method
- (void) didSubmitAction:(NSString *)processId processTitle:(NSString *)processTitle
{
    
    [self disableSFMUI];
    
    didRunOperation = YES;
    
    [activity startAnimating];
    appDelegate.oldRecordId = currentRecordId;
    appDelegate.oldProcessId = currentProcessId;
    [self didSubmitProcess:processId forRecord:currentRecordId];
    
    if (editTitle != nil)
        [editTitle release];
    editTitle = @"";
    editTitle = [processTitle retain];
}

- (void) didInvokeWebService:(NSString *)targetCall  event_name:(NSString *)event_name
{    
    if([event_name isEqualToString:BEFORESAVE] || [event_name isEqualToString:AFTERSAVE])
    {
        NSMutableDictionary * sfm_temp = [appDelegate.SFMPage mutableCopy];
        NSArray * keys = [NSArray arrayWithObjects:WEBSERVICE_NAME, SFM_DICTIONARY, nil];
        NSArray * objects = [NSArray arrayWithObjects:targetCall, sfm_temp, nil];
        NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [appDelegate.wsInterface callSFMEvent:dict event_name:event_name];
    }
    else
    {
        didRunOperation = YES;
        if (![appDelegate isInternetConnectionAvailable] && [event_name isEqualToString:GETPRICE])
        {
            [activity stopAnimating];
            appDelegate.shouldShowConnectivityStatus = TRUE; //shrinivas.
            [appDelegate displayNoInternetAvailable];
            [self enableSFMUI];
            return;
        }    
        
       if([appDelegate.syncThread isExecuting])
        {
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
            {
#ifdef kPrintLogsDuringWebServiceCall
                SMLog(@"DetailViewController.m : didInvokeWebService: GetPrice1");
#endif

                if (![appDelegate isInternetConnectionAvailable])
                {
                    [activity stopAnimating];
                    [self enableSFMUI];
                    break;
                }
                
                if ([appDelegate.syncThread isFinished])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.datasync_timer];
                    break;
                }
            }
        }
        else
        {
            if ([appDelegate.datasync_timer isValid])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.datasync_timer];
            }            
        }   

    if ([appDelegate.metaSyncThread isExecuting])
    {
        
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"DetailViewController.m : didInvokeWebService: GetPrice2");
#endif

            if (![appDelegate isInternetConnectionAvailable])
            {
                [activity stopAnimating];
                [self enableSFMUI];
                break;
            }
            
            if ([appDelegate.metaSyncThread isFinished])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.metasync_timer];
                break;
            }
        }
    }
    else
    {
        if ([appDelegate.metasync_timer isValid])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.metasync_timer];
        }            
    }   

        
        if ([appDelegate.event_thread isExecuting])
        {
            SMLog(@" evnt is executing");
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
            {
#ifdef kPrintLogsDuringWebServiceCall
                SMLog(@"DetailViewController.m : didInvokeWebService: GetPrice3");
#endif

                if (![appDelegate isInternetConnectionAvailable])
                {
                    [activity stopAnimating];
                    [self enableSFMUI];
                    break;
                }
                
                if ([appDelegate.event_thread isFinished])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.event_timer];
                    break;
                }
            }
        }
        else
        {
            if ([appDelegate.event_timer isValid])
            {
                SMLog(@" evnt is NOT executing");
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.event_timer];
            }            
        }   
        
        [appDelegate goOnlineIfRequired];
        SMLog(@" getPrice1");
        NSMutableDictionary * sfm_temp = [appDelegate.SFMPage mutableCopy];
        NSArray * keys = [NSArray arrayWithObjects:WEBSERVICE_NAME, SFM_DICTIONARY, nil];
        NSArray * objects = [NSArray arrayWithObjects:targetCall, sfm_temp, nil];
        NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [activity startAnimating];
        appDelegate.wsInterface.getPrice = FALSE;
        SMLog(@" getPrice2");
        if ([appDelegate isInternetConnectionAvailable])
        {
            [appDelegate.wsInterface callSFMEvent:dict event_name:event_name];
            while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, FALSE))
            {
#ifdef kPrintLogsDuringWebServiceCall
                SMLog(@"DetailViewController.m : didInvokeWebService: customwebservicecall");
#endif

                if (![appDelegate isInternetConnectionAvailable])
                {
                    appDelegate.wsInterface.getPrice = TRUE;
                    [activity stopAnimating];
                    //appDelegate.shouldShowConnectivityStatus = TRUE;
                    //[appDelegate displayNoInternetAvailable];
                    [self enableSFMUI];
                    return;
                }
                if (appDelegate.connection_error)
                {
                    break;
                }

                if (appDelegate.wsInterface.getPrice == TRUE)
                {
                    appDelegate.wsInterface.getPrice = FALSE; 
                    break;
                }
            }
     
        }
        
        SMLog(@" getPrice3");
        [self.tableView reloadData];
        [appDelegate.sfmPageController.rootView refreshTable];
        [self  didselectSection:0];    
        [activity stopAnimating];
        [appDelegate ScheduleIncrementalDatasyncTimer];
        [appDelegate ScheduleIncrementalMetaSyncTimer];
        [appDelegate ScheduleTimerForEventSync];
        [self enableSFMUI];
        SMLog(@" getPrice4");
            
    }
}


- (void) startSummaryDataFetch
{
    [self disableSFMUI];
    
    BOOL isworkingInOffline = TRUE;
    clickedBack = NO;
    

    
    didGetParts = didGetExpenses = didGetLabor = didGetReportEssentials = NO;
    
    if (Labor != nil)
    {
        [Labor release];
        Labor = nil;
    }
    
    if(isworkingInOffline)
    {
		//Get Parts for the Work Order
        Parts    = [appDelegate.calDataBase queryForParts:appDelegate.sfmPageController.recordId];
        
		//Get Expense for the Work Order
        Expenses = [appDelegate.calDataBase queryForExpenses:appDelegate.sfmPageController.recordId];
        
		//Get Labor
		LaborArray = [appDelegate.calDataBase  queryForLabor:appDelegate.sfmPageController.recordId];
        
        reportEssentials  = [[appDelegate.calDataBase getReportEssentials:appDelegate.sfmPageController.recordId] retain];
        SMLog(@" reportEssentis array ==%@",reportEssentials);
        //Labor = nil;
    }
    else
    {
        NSString *query = [NSString stringWithFormat:@"SELECT Id, SVMXC__Product__c, SVMXC__Product__r.Name, SVMXC__Actual_Quantity2__c, SVMXC__Actual_Price2__c, SVMXC__Work_Description__c, SVMXC__Discount__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Line_Type__c = 'Parts' AND SVMXC__Service_Order__c = '%@' AND SVMXC__Actual_Quantity2__c > 0 AND SVMXC__Actual_Price2__c >= 0 AND SVMXC__Is_Billable__c = true", currentRecordId];
        [[ZKServerSwitchboard switchboard] query:query target:self selector:@selector(getParts:error:context:) context:nil];
        
        query = [NSString stringWithFormat:@"SELECT Id, SVMXC__Activity_Type__c, SVMXC__Actual_Quantity2__c, SVMXC__Actual_Price2__c, SVMXC__Work_Description__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Line_Type__c = 'Labor' AND SVMXC__Service_Order__c = '%@' AND SVMXC__Actual_Quantity2__c > 0 AND SVMXC__Actual_Price2__c >= 0 AND SVMXC__Is_Billable__c = true", currentRecordId];
        [[ZKServerSwitchboard switchboard] query:query target:self selector:@selector(getExistingLabor:error:context:) context:nil];
        
        query = [NSString stringWithFormat:@"SELECT Id, SVMXC__Expense_Type__c, SVMXC__Actual_Quantity2__c, SVMXC__Actual_Price2__c, SVMXC__Work_Description__c FROM SVMXC__Service_Order_Line__c WHERE SVMXC__Line_Type__c = 'Expenses' AND SVMXC__Service_Order__c = '%@' AND SVMXC__Is_Billable__c = true", currentRecordId];
        [[ZKServerSwitchboard switchboard] query:query target:self selector:@selector(getExpenses:error:context:) context:nil];
        
        // Service Report Essentials
        
        query = @""; // [NSString stringWithFormat:@"Name,SVMXC__Problem_Description__c,SVMXC__Contact__r.Name,SVMXC__Contact__r.Phone,SVMXC__Work_Performed__c"];
        NSString * cleanQuery = [self removeDuplicatesFromSOQL:appDelegate.soqlQuery withString:query];
        // query = [NSString stringWithFormat:@"%@%@ FROM SVMXC__Service_Order__c WHERE Id = '%@'", query, cleanQuery, currentRecordId];
        [[ZKServerSwitchboard switchboard] query:cleanQuery target:self selector:@selector(getReportEssentials:error:context:) context:nil];
        
        while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, FALSE))
        {
            SMLog(@"startSummaryDataFetch in while loop");
            /*if (![appDelegate isInternetConnectionAvailable])
            {
                [activity stopAnimating];
                [appDelegate displayNoInternetAvailable];
                didRunOperation = NO;
                
                [self enableSFMUI];
                
                return;
            }*/
            SMLog(@"Waiting for summary data...");
            if (didGetParts && didGetExpenses && didGetLabor)
                break;
            if (clickedBack)
            {
                didRunOperation = NO;
                
                [self enableSFMUI];
                
                return;
            }
        }
    }
    Summary = [[[SummaryViewController alloc] initWithNibName:[SummaryViewController description] bundle:nil] autorelease];
    Summary.delegate = self;
    Summary.reportEssentials = reportEssentials;
    
    SMLog(@"%@",reportEssentials);
    NSDictionary * headerDict = [appDelegate.SFMPage objectForKey:gHEADER];
    NSDictionary * headerDataDict = [headerDict objectForKey:gHEADER_DATA];
    Summary.workDescription = [self getObjectNameFromHeaderData:headerDataDict forKey:PROBLEMSUMMARY];
    Summary.Parts = Parts;
    Summary.Expenses = Expenses;
    Summary.recordId = currentRecordId;
    Summary.objectApiName = appDelegate.sfmPageController.objectName;
    SMLog(@"%@",Parts);
    SMLog(@"%@",Expenses);
    NSArray * _keys = [NSArray arrayWithObjects:SVMXC__Activity_Type__c, SVMXC__Actual_Price2__c, SVMXC__Actual_Quantity2__c, nil];
    // Calculate Labor
	
	
	for (LabourValuesDictionary in LaborArray)
	{
		NSArray * allKeys = [LabourValuesDictionary allKeys];
		for (NSString * key in allKeys)
		{
			if ([key Contains:@"QTY_"])
			{
				NSString * quantity = [LabourValuesDictionary objectForKey:key];
				float _quantity = [quantity floatValue]; //#3736
				if (_quantity)
				{
					NSString * item = [key stringByReplacingOccurrencesOfString:@"QTY_" withString:@""];
					NSString * _rate = [LabourValuesDictionary objectForKey:[NSString stringWithFormat:@"Rate_%@", item]];
					NSArray * _objects = [NSArray arrayWithObjects:item, _rate, quantity, nil];
					
					if (Labor == nil)
						Labor = [[NSMutableArray alloc] initWithCapacity:0];
					NSDictionary * laborDictionary = [NSDictionary dictionaryWithObjects:_objects forKeys:_keys];
					[Labor addObject:laborDictionary];
				}
			}
		}

	}
	
	SMLog(@"%@",Labor);
    Summary.Labour = Labor;
    
    Summary.view.frame = CGRectMake(0, 20, 768, 1004);
    Summary.modalPresentationStyle = UIModalPresentationFullScreen;
    Summary.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:Summary] autorelease];
	navController.delegate = Summary;
	navController.modalPresentationStyle = UIModalPresentationFullScreen;
	navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	navController.navigationBar.hidden = YES;
    [(SFMPageController *)delegate presentViewController:navController animated:YES completion:nil];
    
    [activity stopAnimating];
    didRunOperation = NO;
    
    [self enableSFMUI];
}

- (NSString *) getObjectNameFromHeaderData:(NSDictionary *)dictionary forKey:(NSString *)key
{
    NSArray * allKeys = [dictionary allKeys];
    for (NSString * _key in allKeys)
    {
        NSString * uppercaseKey = [_key uppercaseString];
        NSString * argKey = [key uppercaseString];
        
        if ([uppercaseKey isEqualToString:argKey])
        {
            // Found correct key, retrieve value for key and return
            return [dictionary objectForKey:_key];
        }
    }

    return @"";
}

- (NSMutableString *) removeDuplicatesFromSOQL:(NSString *)soql withString:(NSString *)_query
{
    NSMutableArray * array1 = [[[_query componentsSeparatedByString:@","] mutableCopy] autorelease];
    NSArray * array2 = [[array1 lastObject] componentsSeparatedByString:@" "]; // Need to read only first object
    [array1 addObject:[array2 objectAtIndex:0]];
    NSMutableArray * array3 = [[[soql componentsSeparatedByString:@","] mutableCopy] autorelease];
    
    // remove 0 length strings from array3, they create confusion and also crashes
    for (int n = 0; n < [array3 count]; n++)
    {
        if ([[array3 objectAtIndex:n] length] == 0)
            [array3 removeObjectAtIndex:n];
    }
    
    for (int i = 0; i < [array1 count]; i++)
    {
        NSString * array1Obj = [array1 objectAtIndex:i];
        array1Obj = [array1Obj stringByReplacingOccurrencesOfString:@"," withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [array1Obj length])];
        for (int j = 0; j < [array3 count]; j++)
        {
            NSString * array3Obj = [array3 objectAtIndex:j];
            array3Obj = [array3Obj stringByReplacingOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [array3Obj length])];
            if ([array1Obj isEqualToString:array3Obj])
            {
                [array3 removeObjectAtIndex:j];
                j--;
            }
        }
    }
    
    NSMutableString * result = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
    for (int k = 0; k < [array3 count]; k++)
    {
        // Did we forget to remove duplicates from the result itself?
        NSString * item = [array3 objectAtIndex:k];
        if (![result Contains:item])
            [result appendFormat:@", %@", item];
    }
    
    return result;
}

- (void) showTroubleshooting
{
    Troubleshooting * troubleshooting = [[Troubleshooting alloc] initWithNibName:@"Troubleshooting" bundle:nil];
//    NSDictionary * headerDataDict = [appDelegate.SFMPage objectForKey:gHEADER];
//    NSDictionary * headerData = [headerDataDict objectForKey:gHEADER_DATA];
    
  /*  troubleshooting.productId = [self getObjectNameFromHeaderData:headerData forKey:gSVMXC__Product__c];
    troubleshooting.productName = [self getObjectNameFromHeaderData:headerData forKey:gSVMXC__Product_Name__c];*/
    
    troubleshooting.productId = [self getProductIdForRecordId:appDelegate.sfmPageController.recordId];
    troubleshooting.productName = [self getProductNameForId:troubleshooting.productId];
    
    troubleshooting.modalPresentationStyle = UIModalPresentationFullScreen;
    troubleshooting.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [(SFMPageController *)delegate presentViewController:troubleshooting animated:YES completion:nil];
    [troubleshooting release];
    
    [activity stopAnimating];
}



- (void) showChatter
{
       
    [self disableSFMUI];
    
    Chatter * _chatter = [[Chatter alloc] initWithNibName:@"Chatter" bundle:nil];
    _chatter.delegate = self;
    NSDictionary * headerDataDict = [appDelegate.SFMPage objectForKey:gHEADER];
    NSDictionary * headerData = [headerDataDict objectForKey:gHEADER_DATA];
    _chatter.productId = [self getObjectNameFromHeaderData:headerData forKey:gSVMXC__Product__c];
    _chatter.productName = @"";
    _chatter.modalPresentationStyle = UIModalPresentationFullScreen;
    _chatter.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [(SFMPageController *)delegate presentViewController:_chatter animated:YES completion:nil];
    [_chatter release];
    
    [activity stopAnimating];
    
    [self enableSFMUI];
}

/*- (void) BackOnSave:(NSString *)targetCall
{
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (actionMenu)
    {
        [actionMenu.popover dismissPopoverAnimated:YES];
//        [actionMenu release];
        actionMenu = nil;
    }

    if(requiredFieldCheck == TRUE)
    {
        requiredFieldCheck = FALSE;
        return;
    }
    
    if([targetCall isEqualToString:cancel])
    {

    }
    else
    {
        [activity  startAnimating];

       while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES)) 
        {
            SMLog(@"BackOnSave in while loop");
            if (![appDelegate isInternetConnectionAvailable])
            {
                [activity stopAnimating];
                appDelegate.wsInterface.sfm_response = FALSE;
//                [appDelegate displayNoInternetAvailable];
                return;
            }

            if(appDelegate.sfmSave == TRUE )
            {
                appDelegate.sfmSave = FALSE;
                break;
            }
        }
        
        [activity stopAnimating];
    }
    if(appDelegate.sfmSaveError)
    {
        appDelegate.sfmSaveError = FALSE;
        [self moveTableView];
        return;
    }
    //check whether the sender is save or quick save
    if([targetCall isEqualToString:quick_save])
    {
        [activity startAnimating];
        [self didSubmitProcess:currentProcessId forRecord:currentRecordId];
        
        //sahana 2nd August sfm page events
        NSMutableDictionary * headerDataDictionary = [appDelegate.SFMPage objectForKey:gHEADER];
        NSMutableArray * pageLevelEvents = [[[headerDataDictionary objectForKey:gPAGELEVEL_EVENTS] mutableCopy] autorelease];
        for(int i = 0; i< [pageLevelEvents count];i++)
        {
            NSDictionary * eventsDictionary = [pageLevelEvents objectAtIndex:i];
            if ([eventsDictionary count]> 0)
            {
                NSString * eventType = [eventsDictionary objectForKey:gEVENT_TYPE];
                NSString * TargetCall = [eventsDictionary objectForKey:gEVENT_TARGET_CALL];
                if([eventType isEqualToString:@"After Save/Update"])
                {
                    if([TargetCall isEqualToString:@""])
                    {
                        
                    }
                    else
                    {
                        [self didInvokeWebService:TargetCall];
                    }
                }
                if([eventType isEqualToString:@"After Save/Insert"])
                {
                    if([TargetCall isEqualToString:@""])
                    {
                    }
                    else
                    {
                        [self didInvokeWebService:TargetCall];
                    }
                }                

            }
        }
    }
            //create save
    if([targetCall isEqualToString:cancel])
    {
        [appDelegate.SFMPage release];
        appDelegate.SFMPage = nil;
        [delegate BackOnSave]; //for testing purpose code has been comented this is the actual fuctionality             
    }
    if([targetCall isEqualToString:save] && [[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"EDIT"] )
    {
        //sahana 2nd August sfm page events
        NSMutableDictionary * headerDataDictionary = [appDelegate.SFMPage objectForKey:gHEADER];
        NSMutableArray * pageLevelEvents = [[[headerDataDictionary objectForKey:gPAGELEVEL_EVENTS] mutableCopy] autorelease];
        for(int i = 0; i< [pageLevelEvents count];i++)
        {
            NSDictionary * eventsDictionary = [pageLevelEvents objectAtIndex:i];
            if ([eventsDictionary count]> 0)
            {
                
                NSString * eventType = [eventsDictionary objectForKey:gEVENT_TYPE];
                NSString * TargetCall = [eventsDictionary objectForKey:gEVENT_TARGET_CALL];
                
                if([eventType isEqualToString:@"After Save/Update"])
                {
                    if([TargetCall isEqualToString:@""])
                    {
                        
                    }
                    else
                    {
                        [self didInvokeWebService:TargetCall];
                    }
                }
                if([eventType isEqualToString:@"After Save/Insert"])
                {
                    if([TargetCall isEqualToString:@""])
                    {
                    }
                    else
                    {
                        [self didInvokeWebService:TargetCall];
                    }
                }                

                
            }
            
        }

            
        [activity startAnimating];
        appDelegate.isSFMReloading = TRUE;
        [self didSubmitProcess:appDelegate.oldProcessId forRecord:appDelegate.oldRecordId];
        return;
    }
    if([targetCall isEqualToString:save] && [[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"STANDALONECREATE"])
    {
        //sahana 2nd August sfm page events
        NSMutableDictionary * headerDataDictionary = [appDelegate.SFMPage objectForKey:gHEADER];
        NSMutableArray * pageLevelEvents = [[[headerDataDictionary objectForKey:gPAGELEVEL_EVENTS] mutableCopy] autorelease];
        for(int i = 0; i< [pageLevelEvents count];i++)
        {
            NSDictionary * eventsDictionary = [pageLevelEvents objectAtIndex:i];
            if ([eventsDictionary count]> 0)
            {
                NSString * eventType = [eventsDictionary objectForKey:gEVENT_TYPE];
                NSString * TargetCall = [eventsDictionary objectForKey:gEVENT_TARGET_CALL];
                
                if([eventType isEqualToString:@"After Save/Update"])
                {
                    if([TargetCall isEqualToString:@""])
                    {
                        
                    }
                    else
                    {
                        [self didInvokeWebService:TargetCall];
                    }
                }
                if([eventType isEqualToString:@"After Save/Insert"])
                {
                    if([TargetCall isEqualToString:@""])
                    {
                    }
                    else
                    {
                        [self didInvokeWebService:TargetCall];
                    }
                }                
            }
            
        }

        [activity startAnimating];
        appDelegate.isSFMReloading = TRUE;
        if (appDelegate.newProcessId == nil)
        {
            [self DismissModalViewController:nil];
            return;
        }
        [self didSubmitProcess:appDelegate.newProcessId forRecord:appDelegate.newRecordId];
        return;
    }
    if([targetCall isEqualToString:save] && [[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"SOURCETOTARGET"] )
    {
        //sahana 2nd August sfm page events
        NSMutableDictionary * headerDataDictionary = [appDelegate.SFMPage objectForKey:gHEADER];
        NSMutableArray * pageLevelEvents = [[[headerDataDictionary objectForKey:gPAGELEVEL_EVENTS] mutableCopy] autorelease];
        for(int i = 0; i< [pageLevelEvents count];i++)
        {
            NSDictionary * eventsDictionary = [pageLevelEvents objectAtIndex:i];
            if ([eventsDictionary count]> 0)
            {
                
                NSString * eventType = [eventsDictionary objectForKey:gEVENT_TYPE];
                NSString * TargetCall = [eventsDictionary objectForKey:gEVENT_TARGET_CALL];
                
                if([eventType isEqualToString:@"After Save/Update"])
                {
                    if([TargetCall isEqualToString:@""])
                    {
                        
                    }
                    else
                    {
                        [self didInvokeWebService:TargetCall];
                    }
                }
                if([eventType isEqualToString:@"After Save/Insert"])
                {
                    if([TargetCall isEqualToString:@""])
                    {
                    }
                    else
                    {
                        [self didInvokeWebService:TargetCall];
                    }
                }                
            }
            
        }

        [activity startAnimating];
        appDelegate.isSFMReloading = TRUE;
        if (appDelegate.newProcessId == nil)
        {
            [self DismissModalViewController:nil];
            return;
        }
        [self didSubmitProcess:appDelegate.newProcessId forRecord:appDelegate.newRecordId];
        return;
    }
    
    if([targetCall isEqualToString:save] && [[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"SOURCETOTARGETONLYCHILDROWS"] )
    {
        //sahana 2nd August sfm page events
        NSMutableDictionary * headerDataDictionary = [appDelegate.SFMPage objectForKey:gHEADER];
        NSMutableArray * pageLevelEvents = [[[headerDataDictionary objectForKey:gPAGELEVEL_EVENTS] mutableCopy] autorelease];
        for(int i = 0; i< [pageLevelEvents count];i++)
        {
            NSDictionary * eventsDictionary = [pageLevelEvents objectAtIndex:i];
            if ([eventsDictionary count]> 0)
            {
                
                NSString * eventType = [eventsDictionary objectForKey:gEVENT_TYPE];
                NSString * TargetCall = [eventsDictionary objectForKey:gEVENT_TARGET_CALL];
                
                if([eventType isEqualToString:@"After Save/Update"])
                {
                    if([TargetCall isEqualToString:@""])
                    {
                        
                    }
                    else
                    {
                        [self didInvokeWebService:TargetCall];
                    }
                }
                if([eventType isEqualToString:@"After Save/Insert"])
                {
                    if([TargetCall isEqualToString:@""])
                    {
                    }
                    else
                    {
                        [self didInvokeWebService:TargetCall];
                    }
                }                                
            }
            
        }

        [activity startAnimating];
        appDelegate.isSFMReloading = TRUE;
        if (appDelegate.newProcessId == nil)
        {
            [self DismissModalViewController:nil];
            return;
        }
        [self didSubmitProcess:appDelegate.oldProcessId forRecord:appDelegate.oldRecordId];
        return;
        
    }
    if([targetCall isEqualToString:save] )
    {
        [appDelegate.SFMPage release];
        appDelegate.SFMPage = nil;
        [delegate BackOnSave];
    }
}*/

- (void) dismissActionMenu
{
    if (actionMenu)
    {
        [actionMenu.popover dismissPopoverAnimated:YES];
//        [actionMenu release];
        actionMenu = nil;
    }
    if (sfwToolBar)
    {
        [sfwToolBar.popOver dismissPopoverAnimated:YES];
        sfwToolBar = nil;
        return;
    }

}

#pragma mark - move the table view if there is a save error
- (void) moveTableView
{
    table_view_moved = TRUE;
    [UIView beginAnimations:@"animateTable" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
    [UIView commitAnimations];
    CGRect frame = CGRectMake(10, 10, self.webView.frame.size.width, 90); 
    UITextView * view = [[[UITextView alloc] initWithFrame:frame] autorelease];
    view.text = save_response_message;
    view.font = [UIFont boldSystemFontOfSize:18.0];
    view.textColor = [UIColor blackColor];
    view.editable = NO;
    [self.webView addSubview:view];
    
    isShowingSaveError = YES;
}

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [UIView beginAnimations:@"animateTable" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animation1DidStop:finished:context:)];
	
	if (detailViewObject.isInEditDetail)  //Shrinivas detailViewObject.isInEditDetail changed
	{
		detailViewObject.tableView.frame = CGRectMake(detailViewObject.tableView.frame.origin.x, 100, detailViewObject.tableView.frame.size.width, detailViewObject.view.frame.size.height-100);
	}
	else
	{
		self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, 100, self.tableView.frame.size.width, self.view.frame.size.height-100);
	}
    
    [UIView commitAnimations];
}

- (void) animation1DidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if (detailViewObject.isInEditDetail)  //Shrinivas detailViewObject.isInEditDetail
	{
		[detailViewObject.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];

	}
	else
	{
		[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];

	}

}

/*
- (void) getParts:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (Parts != nil)
    {
        [Parts release];
        Parts = nil;
    }
    Parts = [[NSMutableArray alloc] initWithCapacity:0];
	NSArray * array = [result records];
    if (appDelegate.partsZKSArray != nil)
    {
        [appDelegate.partsZKSArray release];
        appDelegate.partsZKSArray = nil;
    }
    appDelegate.partsZKSArray = array;
    [appDelegate.partsZKSArray retain];
	for (int i = 0; i < [array count]; i++)
	{
		ZKSObject * obj = [array objectAtIndex:i];
		NSDictionary * dict = [obj fields];

		SMLog(@"SVMXC__Product__c = %@", [dict objectForKey:gSVMXC__Product__c] );
        NSMutableDictionary *Part = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
        
        ZKSObject * obj2 = [[obj fields] objectForKey:gSVMXC__Product__r];
        NSDictionary * SVMXC__Product__r = [obj2 isKindOfClass:[NSNull class]]?nil:[obj2 fields];
        if (SVMXC__Product__r != nil)
        {
            NSString * partName = [[SVMXC__Product__r objectForKey:gName] isKindOfClass:[NSString class]]?[SVMXC__Product__r objectForKey:gName]:@"";
            [Part setObject:partName forKey:gName];
        }
        
        NSString * numPartsUsed = [dict objectForKey:gSVMXC__Actual_Quantity2__c];
        if ([numPartsUsed isKindOfClass:[NSString class]])
            [Part setObject:[NSString stringWithFormat:@"%d", [numPartsUsed intValue]] forKey:gPartsUsed];
        
        NSString * description = [dict objectForKey:gSVMXC__Work_Description__c];
        if ([description isKindOfClass:[NSString class]])
            [Part setObject:[NSString stringWithFormat:@"%@", description] forKey:KEY_PARTDESCRIPTION];
        
        [Part setObject:obj forKey:CONSUMEDPARTS];
        
        if ([Part objectForKey:KEY_COSTPERPART] == nil)
            [Part setObject:[[obj fields] objectForKey:gSVMXC__Actual_Price2__c] forKey:KEY_COSTPERPART];
        
        if ([Part objectForKey:KEY_PRODUCTID] == nil)
            [Part setObject:[[obj fields] objectForKey:gSVMXC__Product__c] forKey:KEY_PRODUCTID];
		
		//pavaman 26th Feb 2011 - adding discount field
        NSString * discount = [dict objectForKey:gSVMXC__Discount__c];
        if ([discount isKindOfClass:[NSString class]])
            [Part setObject:[NSString stringWithFormat:@"%@", discount] forKey:KEY_DISCOUNT];
        
        [Parts addObject:Part];
	}
    
    didGetParts = YES;
}
*/

- (void) getExpenses:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (Expenses != nil)
        [Expenses release];
    Expenses = [[NSMutableArray alloc] initWithCapacity:0];
	NSArray * array = [result records];
	for (int i = 0; i < [array count]; i++)
    {
        ZKSObject * obj = [array objectAtIndex:i];
        NSDictionary * fields = [obj fields];
        [Expenses addObject:fields];
    }
    
    didGetExpenses = YES;
}

- (void) getExistingLabor:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
	NSArray * array = [result records];

    if (LabourValuesDictionary != nil)
    {
        [LabourValuesDictionary release];
        LabourValuesDictionary = nil;
    }
    LabourValuesDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    linePriceItems = [[NSMutableArray alloc] initWithCapacity:0];
    
    [LabourValuesDictionary setValue:@"0" forKey:CALIBRATION];
	[LabourValuesDictionary setValue:@"0" forKey:CLEANUP];
	[LabourValuesDictionary setValue:@"0" forKey:INSTALLATION];
	[LabourValuesDictionary setValue:@"0" forKey:REPAIR];
	[LabourValuesDictionary setValue:@"0" forKey:SERVICE];

    for (int j = 0; j < [array count]; j++)
    {
        ZKSObject * obj = [array objectAtIndex:j];
        if ([[[obj fields] objectForKey:@"SVMXC__Activity_Type__c"] isEqualToString:CALIBRATION])
        {
            [LabourValuesDictionary setValue:[[obj fields] objectForKey:@"SVMXC__Actual_Price2__c"] forKey:RATE_CALIBRATION];
            [LabourValuesDictionary setValue:[[obj fields] objectForKey:@"SVMXC__Actual_Quantity2__c"] forKey:QTY_CALIBRATION];
        }
        if ([[[obj fields] objectForKey:@"SVMXC__Activity_Type__c"] isEqualToString:CLEANUP])
        {
            [LabourValuesDictionary setValue:[[obj fields] objectForKey:@"SVMXC__Actual_Price2__c"] forKey:RATE_CLEANUP];
            [LabourValuesDictionary setValue:[[obj fields] objectForKey:@"SVMXC__Actual_Quantity2__c"] forKey:QTY_CLEANUP];
        }
        if ([[[obj fields] objectForKey:@"SVMXC__Activity_Type__c"] isEqualToString:INSTALLATION])
        {
            [LabourValuesDictionary setValue:[[obj fields] objectForKey:@"SVMXC__Actual_Price2__c"] forKey:RATE_INSTALLATION];
            [LabourValuesDictionary setValue:[[obj fields] objectForKey:@"SVMXC__Actual_Quantity2__c"] forKey:QTY_INSTALLATION];
        }
        if ([[[obj fields] objectForKey:@"SVMXC__Activity_Type__c"] isEqualToString:REPAIR])
        {
            [LabourValuesDictionary setValue:[[obj fields] objectForKey:@"SVMXC__Actual_Price2__c"] forKey:RATE_REPAIR];
            [LabourValuesDictionary setValue:[[obj fields] objectForKey:@"SVMXC__Actual_Quantity2__c"] forKey:QTY_REPAIR];
        }
        if ([[[obj fields] objectForKey:@"SVMXC__Activity_Type__c"] isEqualToString:SERVICE])
        {
            [LabourValuesDictionary setValue:[[obj fields] objectForKey:@"SVMXC__Actual_Price2__c"] forKey:RATE_SERVICE];
            [LabourValuesDictionary setValue:[[obj fields] objectForKey:@"SVMXC__Actual_Quantity2__c"] forKey:QTY_SERVICE];
        }
    }
    
    NSString * query = [NSString stringWithFormat:@"SELECT SVMXC__Billable_Cost2__c FROM SVMXC__Service_Group_Costs__c	WHERE SVMXC__Group_Member__c = '%@' AND SVMXC__Cost_Category__c = 'Straight' LIMIT 1", appDelegate.appTechnicianId];
    [[ZKServerSwitchboard switchboard] query:query target:self selector:@selector(getPriceForLabor:error:context:) context:nil];
}

- (void) getPriceForLabor:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    NSArray * array = [result records];
    
    if ((array == nil) || ([array count] == 0))
        groupCostsPresent = NO;
    else
        groupCostsPresent = YES;

    if( array != nil && ![array count] )
	{
		//25th jan 2011 pavaman - multicurrency handling
		NSString * query = [NSString stringWithFormat:@"SELECT SVMXC__Billable_Cost2__c FROM SVMXC__Service_Group_Costs__c WHERE SVMXC__Service_Group__c = '%@' AND SVMXC__Cost_Category__c = 'Straight' LIMIT 1", appDelegate.appServiceTeamId];
        [[ZKServerSwitchboard switchboard] query:query target:self selector:@selector(getPriceForServiceTeam:error:context:) context:nil];
	}
	else
	{
        ZKSObject * obj = [array objectAtIndex:0];
        rate = [[[obj fields] objectForKey:@"SVMXC__Billable_Cost2__c"] retain];
		
		if (rate == nil || [rate isKindOfClass:[NSNull class]])
			rate = @"0.0";
        
		NSArray *keys = [LabourValuesDictionary allKeys];
        for( int i = 0; i < [keys count]; i++ )
        {
            NSRange range = [(NSString *)[keys objectAtIndex:i] rangeOfString:@"Rate_"];
            if( !NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) )
            {
                if (calculateLaborPrice)
                    if ([[LabourValuesDictionary valueForKey:[keys objectAtIndex:i]] isEqualToString: @"0.0"])
                        [LabourValuesDictionary setValue:rate forKey:[keys objectAtIndex:i]];
            }
        }
        didGetLabor = YES;
	}
}

- (void) getPriceForServiceTeam:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    NSArray * array = [result records];
    
    if ((array == nil) || ([array count] == 0))
        groupCostsPresent = NO;
    else
        groupCostsPresent = YES;
	
	for (int i = 0; i < [array count]; i++)
	{
		ZKSObject * obj = [array objectAtIndex:i];
		
		// Check the query. use dictionary value extraction technique, for e.g.
		SMLog(@"%@", [[obj fields] objectForKey:@"SVMXC__Billable_Cost2__c"]);
		rate = [[[obj fields] objectForKey:@"SVMXC__Billable_Cost2__c"] retain];
        if (rate == nil || [rate isKindOfClass:[NSNull class]])
			rate = @"0.0";
	}
    
    if ([appDelegate.timeAndMaterial count] > 0)
        settingsPresent = YES;
    else
        settingsPresent = NO;
	
	NSArray *keys = [LabourValuesDictionary allKeys];
    if (settingsPresent)
    {
        if (groupCostsPresent)
        {
            if (calculateLaborPrice)
            {
                for( int i = 0; i < [keys count]; i++ )
                {
                    NSRange range = [(NSString *)[keys objectAtIndex:i] rangeOfString:@"Rate_"];
                    if( !NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) )
                    {
                        BOOL _flag = NO;
                        for (int j = 0; j < [linePriceItems count]; j++)
                        {
                            NSString * str = [NSString stringWithFormat:@"Rate_%@", [linePriceItems objectAtIndex:j]];
                            if ([[keys objectAtIndex:i] isEqualToString:str])
                            {
                                _flag = YES;
                                break;
                            }
                        }
                        if (!_flag)
                            [LabourValuesDictionary setValue:rate forKey:[keys objectAtIndex:i]];
                    }
                }
            }
        }
    }
    else
    {
        if (groupCostsPresent)
        {
            for( int i = 0; i < [keys count]; i++ )
            {
                NSRange range = [(NSString *)[keys objectAtIndex:i] rangeOfString:@"Rate_"];
                if( !NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) )
                {
                    // Overwrite only if Rate value = 0
                    float _rate = [[LabourValuesDictionary objectForKey:[keys objectAtIndex:i]] floatValue];
                    if (_rate == 0.0 && calculateLaborPrice)
                        [LabourValuesDictionary setValue:rate forKey:[keys objectAtIndex:i]];
                }
            }
        }
    }
    
    didGetLabor = YES;
}

- (void) getReportEssentials:(ZKQueryResult *)result error:(NSError *)error context:(id)context
{
    if (reportEssentials != nil)
        [reportEssentials release];
    
    reportEssentials = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray * array = [result records];
    
    for (int i = 0; i < [array count]; i++)
    {
        ZKSObject * obj = [array objectAtIndex:i];
        
        NSDictionary * fields = [obj fields];
        
        [reportEssentials addObject:fields];
    }
    
    didGetReportEssentials = YES;
}

#pragma mark - PopOverController Delegate Method
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (actionMenu)
    {
//        [actionMenu release];
        actionMenu = nil;
    }
    
    if (sp)
    {
        [sp release];
        sp = nil;
    }
    
    if(label_popOver)
    {
        [label_popOver release];
        label_popOver = nil;
    }
}

#pragma mark - WSInterface Delegate Method

-(void) didReceivePageLayoutOffline
{
	SMLog(@"%@", CGRectCreateDictionaryRepresentation(self.navigationController.navigationBar.frame));
    didRunOperation = NO;
    if (isShowingSaveError)
    {
        // Restore table back to original position and hide web view
        [UIView beginAnimations:@"animateTable" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animation1DidStop:finished:context:)];
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, 0, self.tableView.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
        isShowingSaveError = NO;
    }
    
    // Received PageLayout, Save View Layout as default for current object type
    if (didSelectViewLayout)
    {
        didSelectViewLayout = NO;
        [appDelegate.wsInterface saveSwitchView:appDelegate.sfmPageController.processId forObject:appDelegate.sfmPageController.objectName];
    }
    
    if (appDelegate.SFMoffline != nil)
    {  
        appDelegate.describeObjectsArray = nil;
        appDelegate.SFMPage = appDelegate.SFMoffline;
    }
    
    
    //[self pageLevelEventsForEvent:ONLOAD];
    
    
    isDefault = YES;
    
    if ([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"VIEWRECORD"])
    {
        isInViewMode = NO;
        
                
        NSMutableDictionary * header_ =  [appDelegate.SFMPage objectForKey:@"header"];
        NSString * headerObjName = [header_ objectForKey:gHEADER_OBJECT_NAME];
        
        NSString * object_label = [appDelegate.databaseInterface getObjectLabel:SFOBJECT objectApi_name:headerObjName];
        
        NSString * objName = [appDelegate.databaseInterface getObjectName:headerObjName recordId:appDelegate.sfmPageController.recordId];

        NSString * title = object_label;
        int titleLength = [title length];
        title = [title stringByAppendingString:@": "];
        title = [title stringByAppendingString:objName];
        int objNameLength = [objName length];
        
        if (appDelegate.sfmPageController.conflictExists)
        {
            NSMutableString *Confilct= [appDelegate isConflictInEvent:[appDelegate.dataBase getApiNameFromFieldLabel: appDelegate.sfmPageController.objectName] local_id:appDelegate.sfmPageController.recordId];
            if([Confilct length]>0)
            {
               // [self.webView removeFromSuperview];
                [self moveTableViewforDisplayingConflict:Confilct];
                
            }
        }
        
        [detailTitle release];
        if ((titleLength + objNameLength) > 0)
            detailTitle = [title copy];
        else
            detailTitle = [@"" copy];
        
    }
    else if ([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"EDIT"] ||[[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"SOURCETOTARGETONLYCHILDROWS"])
    {
        isInViewMode = YES; //CRAZZZZY STUFF - PLEASE CHANGE THE SEMANTICS OF isInViewMode to the reverse of what it is now - pavaman
             
        NSMutableDictionary * header_ =  [appDelegate.SFMPage objectForKey:@"header"];
        NSString * headerObjName = [header_ objectForKey:gHEADER_OBJECT_NAME];
        
        NSString * object_label = [appDelegate.databaseInterface getObjectLabel:SFOBJECT objectApi_name:headerObjName];
        
        NSString * objName = [appDelegate.databaseInterface getObjectName:headerObjName recordId:appDelegate.sfmPageController.recordId];
        
        NSString * title = object_label;
        int titleLength = [title length];
        title = [title stringByAppendingString:@": "];
        title = [title stringByAppendingString:objName];
        int objNameLength = [objName length];
        
		[detailTitle release];
        if ((titleLength + objNameLength) > 0)
            detailTitle = [title copy];
        else
            detailTitle = [@"" copy];

    }
    else if ([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"STANDALONECREATE"])
    {
        isInViewMode = YES;
       
        
        NSMutableDictionary * header_ =  [appDelegate.SFMPage objectForKey:@"header"];
        NSString * headerObjName = [header_ objectForKey:gHEADER_OBJECT_NAME];
        
        NSString * object_label = [appDelegate.databaseInterface getObjectLabel:SFOBJECT objectApi_name:headerObjName];
		
        [detailTitle release];
        detailTitle = [object_label copy];

    }
    else if ([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"SOURCETOTARGET"])
    {
        isInViewMode = YES;
		[detailTitle release];
        detailTitle = [[appDelegate.SFMPage objectForKey:@"processTitle"] copy];
    }
    else
        isInViewMode = YES;
    
    appDelegate.isSFMReloading = FALSE;
    [self.tableView reloadData];
    [appDelegate.sfmPageController.rootView refreshTable];
    
    [self  didselectSection:0];    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:14.0];
	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor blackColor];
	label.text = detailTitle;
	[label sizeToFit];
	self.navigationItem.titleView = label;
	[label release];
    
    [activity stopAnimating];
    
    if ([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"STANDALONECREATE"])
    {
        [self addNavigationButtons:detailTitle];
    }
    if([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"VIEWRECORD"])
    {
        [self addNavigationButtons:detailTitle];
    }
    
    [appDelegate.sfmPageController.rootView displaySwitchViews];
    [appDelegate.sfmPageController.rootView showLastModifiedTimeForSFMRecord];
    [self enableSFMUI];
	SMLog(@"%@", CGRectCreateDictionaryRepresentation(self.navigationController.navigationBar.frame));
}

- (void) didFinishWithSuccess:(NSString *) response_msg
{
    NSString * response = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_RESPONSE];
    NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:response message:response_msg  delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
    [alert show];
    
    [alert release];
    [activity stopAnimating];
}

- (void) requireFieldWarning
{
    NSString * response = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_RESPONSE];
    NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    NSString * required_fields = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_REQUIRED_FIELDS];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:response message:required_fields delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
    [alert show];
    [alert release];
   

}

-(void) didFinshSave:(NSString *) responseMsg;
{
    save_response_message = responseMsg;
    
    [self enableSFMUI];
}

- (NSString *) getLabelForObject:(NSString *)objName
{
    NSString * retVal = @"";
    for (int i = 0; i < [appDelegate.describeObjectsArray count]; i++)
    {
        ZKDescribeSObject * descObj = [appDelegate.describeObjectsArray objectAtIndex:i];
        SMLog(@"%@", [descObj name]);
        if ([objName isEqualToString:[descObj name]])
        {
            retVal = [descObj label];
            break;
        }
        ZKDescribeField * descField = [descObj fieldWithName:objName];
        if (descField == nil)
        {
            continue;
        }
        else
        {
            retVal = [descField label];
            break;
        }
    }
    
    return retVal;
}

#pragma mark - UITableView Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSInteger row = indexPath.row;
    if (!isInEditDetail)
    {
        if(isInViewMode)
        {
            
            if (selectedSection == SHOW_HEADER_ROW || selectedSection == SHOWALL_HEADERS)
            {
                NSInteger index;
                NSInteger section = indexPath.section;
                if (isDefault)
                    index = section;
                else
                    index = selectedRow;
                
                NSMutableDictionary *header_section = [appDelegate.wsInterface GetHeaderSectionForSequenceNumber:index];	
                
                int coloumns = [[header_section objectForKey:gSECTION_NUMBER_OF_COLUMNS] intValue];
                NSMutableArray * fields = [header_section objectForKey:gSECTION_FIELDS];
                NSMutableDictionary *fieldc1 = nil;
                NSMutableDictionary *fieldc2 = nil;
                
                BOOL SLA_FLAG;
                SLA_FLAG = [[header_section objectForKey:gSLA_CLOCK] boolValue];
                if(SLA_FLAG)
                {
                    return gSTANDARD_TABLE_ROW_HEIGHT;
                }
                
                for (int i=0;i < [fields count];i++)
                {
                    if ([[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_ROW] intValue] == row+1
                        && [[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_COLUMN] intValue] == 1)
                        fieldc1 = [fields objectAtIndex:i];
                    
                    if (coloumns == 2)
                    {
                        if ([[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_ROW] intValue] == row+1
                            && [[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_COLUMN] intValue] == 2)
                            fieldc2 = [fields objectAtIndex:i];
                    }
                }
                //8th Sept 2011
                //if there is only coloumn2 present, but not coloumn1, swap them! - pavamamn - check this. this does not sound right!  
                if (fieldc1 == nil && fieldc2 != nil)
                {
                    fieldc1 = fieldc2;
                    fieldc2 = nil;
                }

                NSMutableArray * field_columns = [NSMutableArray arrayWithObjects:fieldc1, fieldc2, nil];
                
                for (int j = 0; j < [field_columns count]; j++)
                {
                    NSMutableDictionary * dict = [field_columns objectAtIndex:j];
                    NSString *field_datatype=[dict objectForKey:gFIELD_DATA_TYPE];
                    if([field_datatype isEqualToString:@"textarea"])
                    {
                        return 93;
                    }
                }
            }
        }
        else
        {
            return gSTANDARD_TABLE_ROW_HEIGHT;
        }
    }
    else
    {
        if(isInViewMode)
        {
            NSString * control_type = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_DATA_TYPE];
            if([control_type isEqualToString:@"textarea"])
            {
                return 93;
            }
        }
        
    }
    return gSTANDARD_TABLE_ROW_HEIGHT;
}

- (NSString *) getDictionary
{
    NSString * sectionName = nil;
    switch (selectedSection)
    {
        case SHOWALL_HEADERS:
        case SHOW_HEADER_ROW:
            sectionName = HEADER;
            break;
        case SHOWALL_LINES:
        case SHOW_LINES_ROW:
            sectionName = LINES;
            break;
        default:
            break;
    }
    
    return sectionName;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSInteger index;
   
	if (isDefault)
		index = section;
	else
		index = selectedRow;

	if (!isInEditDetail)
    {
        if (selectedSection == SHOW_HEADER_ROW || selectedSection == SHOWALL_HEADERS)
        {            
            NSString * section_title =  [[appDelegate.wsInterface GetHeaderSectionForSequenceNumber:index] objectForKey:gSECTION_TITLE];
            if([section_title isEqualToString:@""])
            {
                NSDictionary *header1 = [appDelegate.SFMPage objectForKey:gHEADER];
                section_title = [header1 objectForKey:gHEADER_OBJECT_LABEL];
                section_title = [section_title stringByAppendingString:@" information"];
                
            }
            if(section_title == nil)
            {
                NSDictionary *header1 = [appDelegate.SFMPage objectForKey:gHEADER];
                section_title = [header1 objectForKey:gHEADER_OBJECT_LABEL];
                section_title = [section_title stringByAppendingString:@" information"];
            }
            return section_title;
                   
        }
        else if (selectedSection == SHOW_LINES_ROW || selectedSection == SHOWALL_LINES)
        {
            NSMutableArray *details = [appDelegate.SFMPage objectForKey:gDETAILS];
            if ([details count] == 0)
                return nil;
            NSMutableDictionary *detail = [details objectAtIndex:index];
            return [detail objectForKey:gDETAILS_OBJECT_LABEL];
        }
        else  if( selectedSection == SHOW_ADDITIONALINFO_ROW || selectedSection == SHOW_ALL_ADDITIONALINFO)
        {
            // NSString * additional_info = [appDelegate.additionalInfo objectAtIndex:index];
            NSDictionary * additional_info_dict = [appDelegate.additionalInfo objectAtIndex:index];
            NSString * additional_info = [[additional_info_dict allKeys] objectAtIndex:0];
//            NSInteger count_info = 0;
            if([additional_info isEqualToString:PRODUCT_ADDITIONALINFO])
            {
//                count_info = [[appDelegate.SFMPage objectForKey:PRODUCTHISTORY] count];
                return [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_LEFT_PANE_PRODUCTHISTORY];
            }
            if([additional_info isEqualToString:ACCOUNT_ADITIONALINFO])
            {
//                count_info = [[appDelegate.SFMPage objectForKey:ACCOUNTHISTORY] count];
                return [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_LEFT_PANE_ACCOUNTHISTORY];
            }
        }
    }
    else
    {
        if([Disclosure_dict count] == 0)
            return nil;
        NSString * section_title = [Disclosure_dict objectForKey:gDETAILS_OBJECT_LABEL];
        return section_title;
    }    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 31; // 44
}

- (UIView *) tableView:(UITableView *)_tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = nil;
    NSString * sectionTitle = nil;
    
    sectionTitle = [self tableView:_tableView titleForHeaderInSection:section];
    
    if (sectionTitle == nil)
    {
        return nil;
    }

    // Create label with section title
    UILabel * label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(20, 6, 500, 33);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [appDelegate colorForHex:@"2d5d83"];// [UIColor whiteColor];

    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    
    //See More Button - Shrinivas
    UIButton *seeMoreButton;
    if( selectedSection == SHOW_ADDITIONALINFO_ROW || selectedSection == SHOW_ALL_ADDITIONALINFO)
    {
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(7, 4, 80, 20)];
        title.backgroundColor = [UIColor clearColor];
        title.text = @"See More";
        title.textColor = [UIColor whiteColor];
        seeMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        seeMoreButton.frame = CGRectMake(550, 2, 100, 30);
        [seeMoreButton addTarget:self action:@selector(SeeMoreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *buttonImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Done-Back-Button.png"]];
        buttonImage.frame = CGRectMake(0, 0, 100, 30);
        [seeMoreButton addSubview:buttonImage];
        [seeMoreButton addSubview:title];
        
        [buttonImage release];
        [title release];
    }
    
    if( selectedSection == SHOW_ALL_ADDITIONALINFO)
    {
       if ( section == 0 ) 
           seeMoreButton.tag = 1;
       else
            seeMoreButton.tag = 2;
    }
    if( selectedSection == SHOW_ADDITIONALINFO_ROW )
    {
        if ( [label.text isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_LEFT_PANE_PRODUCTHISTORY]])
            seeMoreButton.tag = 1;
        
        else if ( [label.text isEqualToString:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_LEFT_PANE_ACCOUNTHISTORY]])
            seeMoreButton.tag = 2;
    }
    
    // Create header view and add label as a subview
    view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 31)] autorelease];
    UIImageView * imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_section_header_bg.png"]] autorelease];
    imageView.frame = CGRectMake(12, 0, _tableView.frame.size.width - 24, 31);
    imageView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    [view addSubview:imageView];
    [view addSubview:label];
    if( selectedSection == SHOW_ADDITIONALINFO_ROW || selectedSection == SHOW_ALL_ADDITIONALINFO)
        [view addSubview:seeMoreButton];

    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!isInEditDetail)
    {
        if (isDefault)
        {
            if (selectedSection == SHOWALL_HEADERS)
            {
                NSMutableDictionary *_header = [appDelegate.SFMPage objectForKey:gHEADER];
                NSMutableArray *header_sections = [_header objectForKey:gHEADER_SECTIONS];
                return [header_sections count];
            }
            else if (selectedSection == SHOWALL_LINES)
            {
                NSMutableArray *details = [appDelegate.SFMPage objectForKey:gDETAILS];
                return [details count];
            }
            else if (selectedSection == SHOW_ALL_ADDITIONALINFO)
            {
                // NSArray * array = appDelegate.additionalInfo;
                // NSInteger count_info = [appDelegate.additionalInfo count];
                return [appDelegate.additionalInfo count];
            }
        }
        else
        {
            // Will always be 1 section
            return 1;
        }
    }
    else
        return 1;
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!isInEditDetail)
    {
        if (isDefault)
        {
            if (selectedSection == SHOWALL_HEADERS)
            {
                NSMutableDictionary *header_section = [appDelegate.wsInterface GetHeaderSectionForSequenceNumber:section];
                if (header_section == nil)
                    return 0;
                int coloumns = [[header_section objectForKey:gSECTION_NUMBER_OF_COLUMNS] intValue];
                int fields = 0;
                BOOL SLA_FLAG = [[header_section objectForKey:gSLA_CLOCK] boolValue];
                int rows ;
                if(SLA_FLAG)
                {
                    return 2;
                }
                else
                {
                    NSArray * array = [header_section  objectForKey:gSECTION_FIELDS];
                    if ([array isKindOfClass:[NSArray class]])
                        fields = [array count];
                    rows = 1.0*fields/coloumns+0.5;
                    return rows;
                }
                
                return rows;
            }
            else if (selectedSection == SHOWALL_LINES)
            {
                NSMutableArray * details = [appDelegate.SFMPage objectForKey:gDETAILS];
                NSMutableDictionary * detail = [details objectAtIndex:section];
                if (detail == nil)
                    return 0;
                int rows = [[detail objectForKey:gDETAILS_VALUES_ARRAY] count];

                return rows+1; //an extra row for coloumn titles
            } //currently Working
            else if (selectedSection == SHOW_ALL_ADDITIONALINFO)
            {
                // NSString * additional_info = [appDelegate.additionalInfo objectAtIndex:section];
                NSDictionary * additional_info_dict = [appDelegate.additionalInfo objectAtIndex:section];
                NSString * additional_info = [[additional_info_dict allKeys] objectAtIndex:0];
                NSInteger count_info;
                if([additional_info isEqualToString:PRODUCT_ADDITIONALINFO])
                {
                    count_info = [[appDelegate.SFMPage objectForKey:PRODUCTHISTORY] count];
                    return count_info +1;
                }
                if([additional_info isEqualToString:ACCOUNT_ADITIONALINFO])
                {
                    count_info = [[appDelegate.SFMPage objectForKey:ACCOUNTHISTORY] count];
                    return count_info +1;
                }
            }
        }
        else
        {
            if (selectedSection == SHOW_HEADER_ROW)
            {
                NSMutableDictionary *header_section = [appDelegate.wsInterface GetHeaderSectionForSequenceNumber:selectedRow];
                if (header_section == nil)
                    return 0;
                int coloumns = [[header_section  objectForKey:gSECTION_NUMBER_OF_COLUMNS] intValue];
                
                int fields;
                int rows;
                BOOL SLA_FLAG = [[header_section objectForKey:gSLA_CLOCK] boolValue];
                if(SLA_FLAG)
                {
                    return 2;
                }
                else
                {
                    fields = [[header_section  objectForKey:gSECTION_FIELDS] count];
                    rows = 1.0*fields/coloumns+0.5;
                    return rows;
                }

                return rows;
            }
            else if (selectedSection == SHOW_LINES_ROW)
            {
                NSMutableArray * details = [appDelegate.SFMPage objectForKey:gDETAILS];
                NSMutableDictionary * detail = [details objectAtIndex:selectedRow];
                if (detail == nil)
                    return 0;
                int rows = [[detail objectForKey:gDETAILS_VALUES_ARRAY] count];
                
                return rows+1; //an extra row for coloumn titles
            }
            else if(selectedSection == SHOW_ADDITIONALINFO_ROW)
            {
                // NSString * additional_info = [appDelegate.additionalInfo objectAtIndex:selectedRow];
                NSDictionary * additional_info_dict = [appDelegate.additionalInfo objectAtIndex:selectedRow];
                NSString * additional_info = [[additional_info_dict allKeys] objectAtIndex:0];
                if([additional_info isEqualToString:PRODUCT_ADDITIONALINFO])
                {
                    return [[appDelegate.SFMPage objectForKey:PRODUCTHISTORY] count]+1;
                }
                if([additional_info isEqualToString:ACCOUNT_ADITIONALINFO])
                {
                    return [[appDelegate.SFMPage objectForKey:ACCOUNTHISTORY] count]+1;
                }

            }
        }
    }
    else
    {
        NSInteger row;
        if (self.header == YES && self.line == NO)
        {
            row = [self HeaderColumns];
        }
        else
        {
            row = [self linesColumns];
        }
        return row;
        // Return number of items in the row dictionary
    }
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isInEditDetail)
    {
        if (!isInViewMode)
            return [self SFMViewCellForTable:_tableView AtIndexPath:indexPath];
        else
            return [self SFMEditCellForTable:_tableView AtIndexPath:indexPath];
    }
    else
    {
        return [self SFMEditDetailCellForTable:_tableView AtIndexPath:indexPath];
    }
    flag1 = TRUE;
}

- (UITableViewCell *) SFMEditCellForTable:(UITableView *)_tableView AtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell";

    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	NSInteger width = 0; // tableView.frame.size.width;
    width = 620;
    UIView * background = nil;
    // BOOL lineselected;
	if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 28)];
	}
	else
    {
        cell.backgroundView = nil;
        
        
        if([[cell.contentView  subviews] count] == 0)
        {
            // Do nothing
            cell.backgroundView = nil;
        }
        else
        {
            //sahana 16th August
            for(int j = 0; j< [[cell.contentView subviews] count]; j++)
            {
                background = [[cell.contentView subviews] objectAtIndex:j];
                
                NSArray * backgroundSubViews = [background subviews];
               
                for (int i = 0; i < [backgroundSubViews count]; i++)
                {
                    [[backgroundSubViews objectAtIndex:i] removeFromSuperview];
                }
                [background removeFromSuperview];
            }
            background = nil;
        }
        
    }
    //sahana 12th Aug for testing
    if(background == nil)
    {
        background = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 28)] autorelease];
    }
    
    NSInteger background_width = background.frame.size.width;
    
	int row = indexPath.row;
	int section = indexPath.section;
	int index = 0;
	NSInteger control_height = 28;
    
	if (isDefault)
		index = section;
	else
		index = selectedRow;

	if (selectedSection == SHOW_HEADER_ROW || selectedSection == SHOWALL_HEADERS)
	{
        header = TRUE;
        UIView * id_Type;
		NSMutableDictionary *header_section = [appDelegate.wsInterface GetHeaderSectionForSequenceNumber:index];	
		
		int coloumns = [[header_section objectForKey:gSECTION_NUMBER_OF_COLUMNS] intValue];
        NSInteger field_width = 0;
        if (coloumns > 0)
            field_width = background_width/(2*coloumns);
        
		NSMutableArray * fields = [header_section objectForKey:gSECTION_FIELDS];
		NSMutableDictionary *fieldc1 = nil;
		NSMutableDictionary *fieldc2 = nil;
        
		for (int i=0;i < [fields count];i++)
		{
			if ([[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_ROW] intValue] == row+1
				&& [[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_COLUMN] intValue] == 1)
				fieldc1 = [fields objectAtIndex:i];
			
			if (coloumns == 2)
			{
				if ([[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_ROW] intValue] == row+1
					&& [[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_COLUMN] intValue] == 2)
					fieldc2 = [fields objectAtIndex:i];
			}
		}
        //if there is only coloumn2 present, but not coloumn1, swap them! - pavamamn - check this. this does not sound right!  
        if (fieldc1 == nil && fieldc2 != nil)
        {
            fieldc1 = fieldc2;
            fieldc2 = nil;
        }
        
        NSMutableArray * field_columns = [NSMutableArray arrayWithObjects:fieldc1, fieldc2, nil];
        
        for (int j = 0; j < [field_columns count]; j++)
		{
            NSMutableDictionary * dict = [field_columns objectAtIndex:j];
            NSString *field_datatype = [dict objectForKey:gFIELD_DATA_TYPE];
            if([field_datatype isEqualToString:@"textarea"])
            {
                control_height = 90;
                background.frame = CGRectMake(0, 0, width, 90);
                field_width =  background_width/(2*coloumns);
            }
        }
        
        NSInteger tag = 1;
        for (int j = 0; j < [field_columns count]; j++)
		{
            NSMutableDictionary * dict = [field_columns objectAtIndex:j];
            NSString * label_name = [dict objectForKey:gFIELD_LABEL];
            NSString *field_datatype=[dict objectForKey:gFIELD_DATA_TYPE];

            CGFloat x = 2*j*field_width+8;
            CGFloat width1 = (CGFloat)field_width-8;
            UILabel * lbl;
            CGRect label_frame = CGRectMake(x, 0, width1, 31);
            SMLog(@"Label Frame %f %f %f %f",label_frame.origin.x,label_frame.origin.y,label_frame.size.width,label_frame.size.height);
            if (label_name == nil )
            {
                lbl = [[UILabel alloc] initWithFrame:label_frame];
                lbl.text = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_DETAIL_FIELD_NOT_ACCESIBLE];
            }
            else
            {
                lbl = [[[UILabel alloc] initWithFrame:label_frame] autorelease];
                lbl.text = label_name;
            }
            
            lbl.backgroundColor = [UIColor clearColor];
            lbl.font = [UIFont boldSystemFontOfSize:lbl.font.pointSize];
            lbl.textColor = [appDelegate colorForHex:@"2d5d83"];//[UIColor blueColor];
            lbl.userInteractionEnabled = TRUE;
            
            
            UITapGestureRecognizer * tapMe = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
            [lbl addGestureRecognizer:tapMe];
            [tapMe release];

            // Retrieve  values for to get the control
           
            CGRect  frame = CGRectMake((2*j+1)*field_width - 5, 6, field_width,control_height-3);//sahana 13th sept control_height-6
               SMLog(@"control Frame %f %f %f %f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
            if(control_height == 90 )
            {
                if([field_datatype isEqualToString:@"textarea"])
                {
                    
                }
                else
                {
                    frame = CGRectMake((2*j+1)*field_width - 5, 6, field_width,28-3);//sahana 13th sept  28 is control_height
                }
            }
            NSString * value = [[field_columns objectAtIndex:j] objectForKey:gFIELD_VALUE_VALUE];
            NSString * keyValue = [[field_columns objectAtIndex:j] objectForKey:gFIELD_VALUE_KEY];
            NSMutableArray *arr = nil;
            
            //sahana added  below code for dependent picklist 
            
            NSMutableArray * validFor = nil;
            BOOL isdependentPicklist = FALSE;
            NSString * dependPick_controllerName = @"";           
            NSString * fieldAPIName = [dict objectForKey:gFIELD_API_NAME];
            
            if([field_datatype isEqualToString: @"picklist"])
            {
               if(appDelegate.isWorkinginOffline)
               {
                   NSMutableArray * descObjArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                   NSMutableArray * descObjValidFor = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                   
                   NSMutableDictionary * _header =  [appDelegate.SFMPage objectForKey:@"header"];
                   
                   NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];
                   
                   //isdependentPicklist
                   
                   isdependentPicklist = [[appDelegate.databaseInterface getPicklistINfo_isdependentOrControllername_For_field_name:DEPENDENT_PICKLIST field_api_name:fieldAPIName object_name:headerObjName] boolValue];
                 
                   dependPick_controllerName = [appDelegate.databaseInterface getPicklistINfo_isdependentOrControllername_For_field_name:CONTROLLER_FIRLD field_api_name:fieldAPIName object_name:headerObjName];
                   [descObjArray addObject:@" "];
                   [descObjValidFor addObject:@" "];
                   
                        //query to acces the picklist values for lines 
                   NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:fieldAPIName tableName:SFPicklist objectName:headerObjName];
                   
                   NSArray * actual_keys = [picklistValues allKeys];
                   
                   NSArray * allvalues = [picklistValues allValues];
                   
				   //Fix for Defect #4656
				   allvalues = [appDelegate.calDataBase sortPickListUsingIndexes:allvalues WithfieldAPIName:fieldAPIName tableName:SFPicklist objectName:headerObjName];
					
                   NSMutableArray * allkeys_ordered = [[NSMutableArray alloc] initWithCapacity:0];
                   [allkeys_ordered addObject:@" "];
        
				   
                   for (NSString * str in allvalues) 
                   {
                       [descObjArray addObject:str];
                       
                       for(NSString * actual_key in actual_keys)
                       {
                          NSString * temp_actual_value =  [picklistValues objectForKey:actual_key];
                           if([temp_actual_value isEqualToString:str])
                           {
                               [allkeys_ordered  addObject:actual_key];
                               break;
                           }
                        
                       }
                   }
                   
                   if(isdependentPicklist)
                   {
                       
                       NSMutableDictionary * temp_valid_for = [appDelegate.databaseInterface  getValidForDictForObject:headerObjName field_api_name:fieldAPIName];
                       
                       NSArray * validForKeys  = [temp_valid_for allKeys];
                       
                       for(NSString * orderd_key  in allkeys_ordered)
                       {
                          BOOL flag_ =  [validForKeys containsObject:orderd_key];
                           if(flag_)
                           {
                               NSString * value_validFor =  [temp_valid_for objectForKey:orderd_key];
                               [descObjValidFor addObject:(value_validFor!= nil)?value_validFor:@""];
                           }
                           
                       }
                   }
                   
                   arr = [[NSMutableArray  alloc] initWithArray:descObjArray];
                   validFor = [[NSMutableArray alloc] initWithArray:descObjValidFor];
               }
            
            }
            
            if([field_datatype isEqualToString: @"multipicklist"])
            {
               
                    NSMutableDictionary * _header =  [appDelegate.SFMPage objectForKey:@"header"];
                    NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];
                    
                    NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:fieldAPIName tableName:SFPicklist objectName:headerObjName];
                    NSArray * allvalues = [picklistValues allValues];
				
					//Shrinivas Fix for Defect : 6011.
					allvalues = [appDelegate.calDataBase sortPickListUsingIndexes:allvalues WithfieldAPIName:fieldAPIName tableName:SFPicklist objectName:headerObjName];
                    
                    arr = [[NSMutableArray  alloc] initWithArray:allvalues];
                   
                
                                
            }

            NSString * refObjName = nil;
            NSString * refObjSearchId = nil;

            if ([field_datatype isEqualToString:@"reference"] && [fieldAPIName isEqualToString:@"RecordTypeId"])
            {
                NSMutableDictionary * _header =  [appDelegate.SFMPage objectForKey:@"header"];
                NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];
                arr = [appDelegate.databaseInterface getRecordTypeValuesForObjectName:headerObjName];
                             
            }
            
            SMLog(@"%@", arr);
            // Special handling for Lookup Additional Filter
            NSNumber * overrideRelatedLookUp = 0;
            NSString * lookupContext = nil, * lookupQuery = nil;
            if ([field_datatype isEqualToString:@"reference"])
            {
                refObjSearchId = [dict objectForKey:gFIELD_RELATED_OBJECT_SEARCH_ID];
                refObjName = [dict objectForKey:gFIELD_RELATED_OBJECT_NAME];
                overrideRelatedLookUp = [dict objectForKey:gFIELD_OVERRIDE_RELATED_LOOKUP];
                lookupContext = [dict objectForKey:gFIELD_LOOKUP_CONTEXT];
                lookupQuery = [dict objectForKey:gFIELD_LOOKUP_QUERY];
            }

            BOOL readOnly = [[dict objectForKey:gFIELD_READ_ONLY] boolValue];
            BOOL required = [[dict objectForKey:gFIELD_REQUIRED] boolValue];
			
			NSString * object_api_name	=  [[appDelegate.SFMPage objectForKey:@"header"] objectForKey:gHEADER_OBJECT_NAME];
            
            id_Type = [self getControl:field_datatype withRect:frame withData:arr withValue:value fieldType:fieldAPIName labelValue:label_name enabled:!readOnly refObjName:refObjName referenceView:self.view indexPath:indexPath required:required valueKeyValue:keyValue lookUpSearchId:refObjSearchId overrideRelatedLookup:overrideRelatedLookUp fieldLookupContext:lookupContext fieldLookupQuery:lookupQuery dependentPicklistControllerName:dependPick_controllerName picklistValidFor:validFor picklistIsdependent:isdependentPicklist objectAPIName:object_api_name];
            id_Type.tag = tag;
            tag++;
            [background addSubview:lbl];
            if (id_Type != nil) 
            {
                [background addSubview:id_Type];
            }
		}

        background.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:background];
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        
	}
	else if (selectedSection == SHOW_LINES_ROW || selectedSection == SHOWALL_LINES)
	{
        header = FALSE;
    
		NSMutableArray * details = [appDelegate.SFMPage objectForKey:gDETAILS];
		NSMutableDictionary * detail = [details objectAtIndex:index];

		NSMutableArray * detail_fields = [detail objectForKey:gDETAILS_FIELDS_ARRAY];
        
        NSInteger columns = [[detail objectForKey:gDETAILS_NUMBER_OF_COLUMNS] intValue];
		//columns = [detail_fields count];
		NSInteger field_width = background_width/columns;
        
//        NSMutableArray * lines_fields_array = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        
        BOOL allowEdit = [[detail objectForKey:gDETAILS_ALLOW_NEW_LINES] boolValue];
		if (row == 0) //display the column titles
		{
            background.clipsToBounds = YES;
			for (int j = 0; j < columns; j++)
			{
				UILabel * lbl = [[[UILabel alloc] initWithFrame:CGRectMake(j*field_width+8, 0, field_width-8, control_height)] autorelease];
				NSString * label_name = nil;
                if ([detail_fields count] > j)//sahana
                {
                    label_name = [[detail_fields objectAtIndex:j] objectForKey:gFIELD_LABEL];
//                    [lines_fields_array addObject:[[detail_fields objectAtIndex:j] objectForKey:gFIELD_API_NAME]];
                }
				lbl.text = label_name;
                lbl.textColor = [UIColor whiteColor];
                lbl.textAlignment = UITextAlignmentLeft ;
                lbl.font = [UIFont fontWithName:@"HelveticaBold" size:19];
                lbl.font = [UIFont boldSystemFontOfSize:lbl.font.pointSize];
                lbl.backgroundColor = [UIColor clearColor];
				[background addSubview:lbl];
			}

            flag = 1;
            
            //UIView * addLinesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 23)];
            UIView * addLinesView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 31)] autorelease];
            
            // Add Item
            UIImage * image = [UIImage imageNamed:@"add.png"];
            UIControl * c = [[UIControl alloc] initWithFrame:(CGRect){CGPointZero, image.size}];
            c.backgroundColor = [UIColor clearColor];
            c.tag = index;
            c.layer.contents = (id)image.CGImage;
            [c addTarget:self action:@selector(accessoryTapped:) forControlEvents:UIControlEventTouchUpInside];
            //c.frame = CGRectMake(30, 0, 23, 23);
            c.frame = CGRectMake(45, 0, 38, 31);
            if(allowEdit)
            {
                [addLinesView addSubview:c];
            }
            [c release]; 
            multi_add_search = [detail objectForKey:gDETAIL_MULTIADD_SEARCH];
            multi_add_seach_object = [detail objectForKey:gDETAIL_MULTIADD_SEARCH_OBJECT];
            mutlti_add_config = [detail objectForKey:gDETAIL_MULTIADD_SEARCH_OBJECT];
            //sahana  15th Nov 2011
           // if(multi_add_search != @"" && multi_add_seach_object != @"")
            if([multi_add_search length] != 0 && [multi_add_seach_object length] != 0)
            {
                UIImage * image1 = [UIImage imageNamed:@"multi_add.png"];
                control = [[UIControl alloc] initWithFrame:CGRectMake(width-36, 4, 23, 23)];
                control.backgroundColor = [UIColor clearColor];
                control.tag = index;
                control.layer.contents = (id)image1.CGImage;
                [control addTarget:self action:@selector(multiAccessoryTapped:) forControlEvents:UIControlEventTouchUpInside];
                //control.frame = CGRectMake(0, 0, 23, 23);
                control.frame = CGRectMake(0, 0, 38, 31);
                [addLinesView addSubview:control];
                multiControl = [control retain];
                [control release];
            }
            //multi add rows
            cell.accessoryView = addLinesView;
		}
		else // Display the column values for the row
		{
            cell.accessoryView = nil;
            [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];

            {
               
                NSMutableArray * detail_values = [[detail objectForKey:gDETAILS_VALUES_ARRAY] objectAtIndex:row-1];
                           
                for (int j = 0; j < columns; j++)
                {
                        if([detail_fields count]>j)
                        {
                        NSString * control_type = [[detail_fields objectAtIndex:j]objectForKey:gFIELD_DATA_TYPE];
                        NSString * api_name = [[detail_fields objectAtIndex:j]objectForKey:gFIELD_API_NAME];
                        NSString * value = @"";
                        for (int i = 0; i < [detail_values count]; i++)
                        {
                            NSString * value_Field_API = [[detail_values objectAtIndex:i] objectForKey:gVALUE_FIELD_API_NAME];
                            if ([api_name isEqualToString:value_Field_API])
                            {
                                value = [[detail_values objectAtIndex:i] objectForKey:gVALUE_FIELD_VALUE_VALUE];
                                break;
                            }
                        }
                            
                            
                       // NSString * value = [[detail_values objectAtIndex:j] objectForKey:gVALUE_FIELD_VALUE_VALUE];
                        CGRect   frame = CGRectMake(j*field_width, 6, field_width-4,control_height-6);
                        
                        if ([control_type isEqualToString:@"boolean"] )
                        {
                            UIImageView *v1;
                            if ([value isEqualToString:@"True"] || [value isEqualToString:@"true"] || [value isEqualToString:@"1"] ) 
                            {
                                v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-tick-Icon.png"]] autorelease];
                                v1.backgroundColor = [UIColor clearColor];
                                v1.frame = CGRectMake(frame.origin.x+30, 12, 18, 18);
                                v1.contentMode = UIViewContentModeCenter;
                                [background addSubview:v1];
                            }
                            else
                            {  
                                v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-Cancel-Icon.png"]] autorelease];
                                v1.backgroundColor = [UIColor clearColor];
                                v1.frame = CGRectMake(frame.origin.x+30, 12, 18, 18);
                                v1.contentMode = UIViewContentModeCenter;
                                [background addSubview:v1];
                            }
                        }
                        else
                        {
                            lbl2 = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
                            SMLog(@"%@", value);

                            if([control_type isEqualToString:@"datetime"])
                            {
                                value = [value stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                                value = [value stringByReplacingOccurrencesOfString:@".000Z" withString:@""];
                                value = [iOSInterfaceObject getLocalTimeFromGMT:value];
                                value = [value stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                                value = [value stringByReplacingOccurrencesOfString:@"Z" withString:@""];
                                NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                                [frm setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
                                NSDate * date = [frm dateFromString:value];
                                [frm  setDateFormat:DATETIMEFORMAT];
                                value = [frm stringFromDate:date];
                            }
                            if([control_type isEqualToString:@"date"])
                            {
                                NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
                                [formatter setDateFormat:@"yyyy-MM-dd"];
                                NSDate * date = [formatter dateFromString:value];
                                [formatter setDateFormat:DATEFORMAT];
                                value = [formatter stringFromDate:date];
                            }

                            lbl2.text = value;
                            lbl2.textAlignment = UITextAlignmentLeft;
                            lbl2.backgroundColor = [UIColor clearColor];
                            [background addSubview:lbl2];
                        }
                    }
                }
            }
		}
        
        background.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:background];
    }

    UIImageView * bgView = nil;
    if (selectedSection == SHOW_HEADER_ROW || selectedSection == SHOWALL_HEADERS)
	{
         bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]] autorelease];
    }
    if (selectedSection == SHOW_LINES_ROW || selectedSection == SHOWALL_LINES)
    {
        if(flag == FALSE)
            bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]] autorelease];
        else
        {
            flag = FALSE;
            bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Header.png"]] autorelease];
        }
    }
    cell.backgroundView = bgView;
	return cell;
}


- (UITableViewCell *) SFMViewCellForTable:(UITableView *)_tableView AtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell";

    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	NSInteger width = 0; // tableView.frame.size.width-44*2;
	width = 620;
	
//    BOOL isCellNew = NO;
    
    UIView *background = nil;
	if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:@"Cell"];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 28)];
//        isCellNew = YES;
	}
	else
    {
//        isCellNew = NO;
        NSArray * recognizers = [cell gestureRecognizers];
        for(id gest_recognizer in recognizers)
        {
            [cell removeGestureRecognizer:gest_recognizer];
        }
        
        if([[cell.contentView subviews] count] == 0)
        {
            cell.imageView.image = nil;
        }
        else
        {
            NSArray * subViews = [cell.contentView subviews];
            for (int i = 0; i < [subViews count]; i++)
            {
                [[subViews objectAtIndex:i] removeFromSuperview];
            }
        }   
    }
    
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
	
    if(background == nil)
    {
        background = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 28)] autorelease];
    }

    NSInteger background_width = background.frame.size.width;
    NSInteger control_height = 28;

	int row = indexPath.row;
	int section = indexPath.section;
	int index;

	if (isDefault)
		index = section;
	else
		index = selectedRow;

	if (selectedSection == SHOW_HEADER_ROW || selectedSection == SHOWALL_HEADERS)
	{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        header = TRUE;

		NSMutableDictionary *header_section = [appDelegate.wsInterface GetHeaderSectionForSequenceNumber:index];	
		
		int coloumns = [[header_section objectForKey:gSECTION_NUMBER_OF_COLUMNS] intValue];
        NSInteger field_width = 0;
        if (coloumns == 0)
            field_width = background_width;
        else
            field_width = background_width/(2*coloumns);
        
		NSMutableArray * fields = [header_section objectForKey:gSECTION_FIELDS];
		NSMutableDictionary *fieldc1 = nil;
		NSMutableDictionary *fieldc2 = nil;
       
        UIImageView * bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]] autorelease];

        BOOL SLA_FLAG = [[header_section objectForKey:gSLA_CLOCK] boolValue];
        if(SLA_FLAG)
        {
            NSDictionary * header_dict = [appDelegate.SFMPage objectForKey:gHEADER];
            
            SMLog(@"%@", header_dict);
            
            if (row == 0)
            {
                for (int i = 0; i < 2; i++)
                {
                    UILabel * lbl; 
                    if (i == 0)
                    {
                        lbl = [[[UILabel alloc] initWithFrame:CGRectMake((i+1)*20, 0, width, control_height)] autorelease];
                        lbl.text = [appDelegate.wsInterface.tagsDictionary objectForKey:SLA_RESTORATION];
                        // [self getLabelForObject:@"SVMXC__Resolution_Customer_By__c"];

                    }
                    else
                    {
                        lbl = [[[UILabel alloc] initWithFrame:CGRectMake(i*400, 0, width, control_height)] autorelease];
                        lbl.text = [appDelegate.wsInterface.tagsDictionary objectForKey:SLA_RESOLUTION];
                        // [self getLabelForObject:@"SVMXC__Restoration_Customer_By__c"];
                    }
                    lbl.font = [UIFont fontWithName:@"HelveticaBold" size:19];
                    lbl.font = [UIFont boldSystemFontOfSize:lbl.font.pointSize];
                    lbl.textColor = [appDelegate colorForHex:@"2d5d83"];
                    lbl.backgroundColor = [UIColor clearColor];
                    [background addSubview:lbl];
                }
                [cell.contentView addSubview:background];
                cell.backgroundView = bgView;
                cell.accessoryType = UITableViewCellAccessoryNone;
                return cell;
            }
            else
            {
                NSMutableDictionary * slaTimer = [appDelegate.SFMPage objectForKey:SLATIMER];
                
                NSString * resolutionTimerValue = nil;
                
                NSString * restorationTimerValue = nil;
                NSString * sla_clock_paused = nil;
                NSString *actual_resolution = nil;
                NSString *actual_restoration = nil;
                NSString *restorationCustomerBy = nil;
                NSString *resolutionCustomerBy = nil;
                NSString *pausedTime = nil;
                
                if(appDelegate.isWorkinginOffline)
                {
                   
                    NSMutableDictionary * header_ =  [appDelegate.SFMPage objectForKey:@"header"];
                    NSString * headerObjName = [header_ objectForKey:gHEADER_OBJECT_NAME];
                    
                    NSMutableDictionary *  SLADict = [appDelegate.databaseInterface  getRestorationAndResolutionTimeForWorkOrder:appDelegate.sfmPageController.recordId tableName:headerObjName];
                    slaTimer = SLADict;
                    
                    resolutionTimerValue = [SLADict objectForKey:RESOLUTIONTIME];
                     resolutionTimerValue = [resolutionTimerValue stringByDeletingPathExtension];
                    
                    restorationTimerValue = [SLADict objectForKey:RESTORATIONTIME];
                    restorationTimerValue = [restorationTimerValue stringByDeletingPathExtension];
                    //[self restorationTimeLeftFromDateTimeOffline:];
                    sla_clock_paused = [SLADict objectForKey:@"Svmxc__Sla_Clock_Paused__C"];
                    actual_resolution = [SLADict objectForKey:@"Svmxc__Actual_Resolution__C"];
                    actual_restoration = [SLADict objectForKey:@"Svmxc__Actual_Restoration__C"];
                    restorationCustomerBy = [SLADict objectForKey:@"Svmxc__Restoration_Customer_By__C"];
                    resolutionCustomerBy = [SLADict objectForKey:@"Svmxc__Resolution_Customer_By__C"];
                    pausedTime = [SLADict objectForKey:@"Svmxc__Sla_Clock_Pause_Time__C"];
                    

                }
                else
                {
                    resolutionTimerValue =[slaTimer objectForKey:RESOLUTIONTIME];//@"1:24:30:00.000Z";;//[slaTimer objectForKey:RESOLUTIONTIME];
                    restorationTimerValue = [slaTimer objectForKey:RESTORATIONTIME];// @"2011-11-10T06:30:00.000Z";
                }
                
                if (!restorationTimer)
                {
                    restorationTimer = [[TimerClass alloc] initWithNibName:@"TimerClass" bundle:nil];
                }
                restorationTimer.type = TimerClassTypeRestoration;
                restorationTimer.slaTimer = slaTimer;
                restorationTimer.view.frame = CGRectMake(0, 10, width, control_height-10);
                [restorationTimer ResetTimer];
                if (restorationTimerValue != nil)
                {
                    if(appDelegate.isWorkinginOffline)
                    {
                        if(actual_restoration!=nil && [actual_restoration length] > 0)
                        {
                            [restorationTimer updateTimerLabel:[self timeDifferenceFrom:restorationCustomerBy toDate:actual_restoration]];
                            
                        }
                        else
                            if([sla_clock_paused isEqualToString:@"1"])
                            {
                                [restorationTimer updateTimerLabel:[self timeDifferenceFrom:restorationCustomerBy toDate:pausedTime]];
                            }
                            else
                                [self restorationTimeLeftFromDateTimeOffline:restorationTimerValue];
                    }
                    else
                    {
                        [self restorationTimeLeftFromDateTime:restorationTimerValue];
                    }
                }
                [background addSubview:restorationTimer.view];

                if (!resolutionTimer)
                        resolutionTimer = [[TimerClass alloc] initWithNibName:@"TimerClass" bundle:nil];
                    
                resolutionTimer.type = TimerClassTypeResolution;
                resolutionTimer.slaTimer = slaTimer;
                resolutionTimer.view.frame = CGRectMake(380, 10, width, control_height-10);
                [resolutionTimer ResetTimer];
                if (resolutionTimerValue != nil)
                {
                    if(appDelegate.isWorkinginOffline)
                    {
                        if(actual_resolution!=nil && [actual_resolution length] > 0)
                        {
                            [resolutionTimer updateTimerLabel:[self timeDifferenceFrom:resolutionCustomerBy toDate:actual_resolution]];                            
                        }
                        else
                            if([sla_clock_paused isEqualToString:@"1"])
                            {
                                [resolutionTimer updateTimerLabel:[self timeDifferenceFrom:resolutionCustomerBy toDate:pausedTime]];
                            }
                            else
                                [self resolutionTimeLeftFromDateTimeOffline:resolutionTimerValue];
                    }
                    else
                    {
                        [self resolutionTimeLeftFromDateTime:resolutionTimerValue];
                    }
                    
                }
                [background addSubview:resolutionTimer.view];
                
                [cell.contentView addSubview:background];

                bgView.alpha = 0.0;
                cell.backgroundView = bgView;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            return cell;
        }
        
		for (int i=0;i < [fields count];i++)
		{
			if ([[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_ROW] intValue] == row+1
				&& [[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_COLUMN] intValue] == 1)
				fieldc1 = [fields objectAtIndex:i];
			
			if (coloumns == 2)
			{
				if ([[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_ROW] intValue] == row+1
					&& [[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_COLUMN] intValue] == 2)
					fieldc2 = [fields objectAtIndex:i];
			}
           
		}
        
        //if there is only coloumn2 present, but not coloumn1, swap them! - pavamamn - check this. this does not sound right!  
        if (fieldc1 == nil && fieldc2 != nil)
        {
            fieldc1 = fieldc2;
            fieldc2 = nil;
        }
        
        NSMutableArray * field_columns = [NSMutableArray arrayWithObjects:fieldc1, fieldc2, nil];
        for (int j = 0; j < [field_columns count]; j++)
		{
            NSMutableDictionary * dict = [field_columns objectAtIndex:j];
            
            CGFloat x = 2*j*field_width+8;
            CGFloat width = (CGFloat)field_width-8;
            
            //get  the control Type
            NSString * field_data_type = [dict objectForKey:gFIELD_DATA_TYPE];
                       
            UILabel * lbl = [[[UILabel alloc] initWithFrame:CGRectMake(x, 0, width,control_height)] autorelease];
            lbl.backgroundColor = [UIColor clearColor];
            NSString * label_name = [dict objectForKey:gFIELD_LABEL];
			lbl.text = label_name;
            lbl.textColor = [appDelegate colorForHex:@"2d5d83"];
            lbl.font = [UIFont boldSystemFontOfSize:lbl.font.pointSize];
            lbl.userInteractionEnabled = TRUE;
            
            UITapGestureRecognizer * tapMe = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
            [lbl addGestureRecognizer:tapMe];
            [tapMe release];
            [background addSubview:lbl];
            
            //Radha 29 - Feb
            
            if ([field_data_type isEqualToString:@"reference"])
            {
                NSString * key = [dict objectForKey:gFIELD_VALUE_KEY];
                NSString * related_to_table_name = [dict objectForKey:gFIELD_RELATED_OBJECT_NAME];
                NSString * api_name = [dict objectForKey:gFIELD_API_NAME];
                NSString * value = [[field_columns objectAtIndex:j] objectForKey:gFIELD_VALUE_VALUE];
                CusLabel * custLabel = [[CusLabel alloc] initWithFrame:CGRectMake((2*j+1)*field_width , 6, field_width,control_height-8)];
                custLabel.backgroundColor = [UIColor clearColor];
                
                custLabel.tapRecgLabel=value;
                if ([value length]>15) {
                    value= [value substringToIndex:15];    
                    value=[value stringByAppendingFormat:@"..."];
                }
                custLabel.text = value;
                custLabel.userInteractionEnabled = TRUE;
                custLabel.controlDelegate = self;
                custLabel.id_ = key;
                custLabel.refered_to_table_name = related_to_table_name;
                custLabel.object_api_name = api_name;
                
                
                //Radha 2012june08
                BOOL recordExists = [appDelegate.dataBase checkIfRecordExistForObject:related_to_table_name Id:key];
                
                BOOL flag_ = FALSE;
                
                if (recordExists)
                {
                    for (int j = 0; j < [appDelegate.view_layout_array count]; j++)
                    {
                        NSDictionary * viewLayoutDict = [appDelegate.view_layout_array objectAtIndex:j];
                        NSString * objName = [viewLayoutDict objectForKey:@"SVMXC__Source_Object_Name__c"];
                        if ([objName isEqualToString:related_to_table_name])
                        {
                            flag_ = TRUE;
                            break;
                        }
                    }
                    if(flag_)
                    {
                        custLabel.textColor = [UIColor blueColor];
                    }
                    else
                    {              
                    }
                }
                
                [background addSubview:custLabel];
                
            }
            
            else
            {
                lbl1 = [[UILabel alloc]initWithFrame:CGRectMake((2*j+1)*field_width , 6, field_width,control_height-8)];
                NSString * value = [[field_columns objectAtIndex:j] objectForKey:gFIELD_VALUE_VALUE];
                lbl1.text =  [[field_columns objectAtIndex:j] objectForKey:gFIELD_VALUE_VALUE];
                lbl1.backgroundColor = [UIColor clearColor];
                lbl1.userInteractionEnabled = TRUE;
                //TAPING FOR LABEL VALUE
                UITapGestureRecognizer * tapMe_Value = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
                [lbl1 addGestureRecognizer:tapMe_Value];
                [tapMe_Value release];
                
                
                [background addSubview:lbl];
                
                UIImageView * v1 = nil;
                if([field_data_type isEqualToString:@"boolean"])
                {
                    
                    if ([value isEqualToString:@"True"] || [value isEqualToString:@"true"] ||[value isEqualToString:@"1"]) 
                    {
                        v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-tick-Icon.png"]] autorelease];
                        v1.backgroundColor = [UIColor clearColor];
                        v1.frame = CGRectMake((2*j+1)*field_width +10, 6, 18, 18);
                        v1.contentMode = UIViewContentModeCenter;
                        [background addSubview:v1];
                    }
                    else
                    {
                        v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-Cancel-Icon.png"]] autorelease];
                        v1.backgroundColor = [UIColor clearColor];
                        v1.contentMode = UIViewContentModeCenter;
                        v1.frame = CGRectMake((2*j+1)*field_width+10 , 6, 18, 18);
                        [background addSubview:v1];
                    }
                }
                else
                {
                    if([field_data_type isEqualToString:@"datetime"])
                    {
                        value = [value stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                        value = [value stringByReplacingOccurrencesOfString:@".000Z" withString:@""];
                        value = [iOSInterfaceObject getLocalTimeFromGMT:value];
                        value = [value stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                        value = [value stringByReplacingOccurrencesOfString:@"Z" withString:@""];
                        NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                        [frm setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
                        NSDate * date = [frm dateFromString:value];
                        [frm  setDateFormat:DATETIMEFORMAT];
                        value = [frm stringFromDate:date];
                    }
                    if([field_data_type isEqualToString:@"date"])
                    {
                        
                        NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
                        if ([value length] > 11 )
                            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        else
                            [formatter setDateFormat:@"yyyy-MM-dd"];
                        NSDate * date = [formatter dateFromString:value];
                        NSDateFormatter * format =[[[NSDateFormatter alloc]init] autorelease];
                        [format setDateFormat:@"MMM dd yyyy"];
                        value = [format stringFromDate:date];
                    }
                    lbl1.text = value;
                    
                    [background addSubview:lbl1];
                }

            }            		
        }
		
        
        background.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:background];
	}
	else if (selectedSection == SHOW_LINES_ROW || selectedSection == SHOWALL_LINES)
	{
        header = FALSE;
		NSMutableArray * details = [appDelegate.SFMPage objectForKey:gDETAILS];
		NSMutableDictionary * detail = [details objectAtIndex:index];
		NSMutableArray * detail_fields = [detail objectForKey:gDETAILS_FIELDS_ARRAY];
        NSInteger columns = [[detail objectForKey:gDETAILS_NUMBER_OF_COLUMNS] intValue];
		NSInteger field_width = background_width/columns;   
            
        if (row == 0) //display the column titles
		{
            [background setClipsToBounds:YES];
            // If fields are not present - ERROR CONDITION - then columns should not be added
            if ([detail_fields count] > 0)
            {
                for (int j=0;j<columns && j<[detail_fields count];j++)
                {
                    UILabel * lbl = [[[UILabel alloc] initWithFrame:CGRectMake(j*field_width+8, 0, field_width-8,control_height)] autorelease];
                    NSString * label_name = [[detail_fields objectAtIndex:j] objectForKey:gFIELD_LABEL];
                    lbl.text = label_name;
                    lbl.font = [UIFont fontWithName:@"HelveticaBold" size:19];
                    lbl.font = [UIFont boldSystemFontOfSize:lbl.font.pointSize];
                    lbl.textColor = [UIColor whiteColor];
                    lbl.backgroundColor = [UIColor clearColor];
                    [background addSubview:lbl];
                }
                flag = TRUE;
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
            background.backgroundColor = [UIColor clearColor];
            background.frame = CGRectMake(0, 0, cell.contentView.frame.size.width-42, cell.contentView.frame.size.height);
            [cell.contentView addSubview:background];
            cell.imageView.image = nil;
		}
		else //display the column values for the row
		{
            NSInteger ValueCount;
			NSMutableArray * detail_values = [[detail objectForKey:gDETAILS_VALUES_ARRAY] objectAtIndex:row-1];
             NSString * record_id  = @"";
                        
            /*NSMutableArray * array  =  [detail objectForKey:@"local_id"];
            if ([array count] > 0)
                record_id  =  [array objectAtIndex:row-1];*/
            
            //#4683 - Radha
            for (int i = 0; i < [detail_values count]; i++)
            {
                NSDictionary * dict = [detail_values objectAtIndex:i];
                
                NSString * value_Field_API_Name = [dict objectForKey:@"value_Field_API_Name"];
                
                if ([value_Field_API_Name isEqualToString:@"local_id"])
                {
                    record_id = [dict objectForKey:@"value_Field_Value_key"];
                }
                
            }

           
            NSString * objectName_  =  [detail objectForKey:gDETAIL_OBJECT_NAME];
            
            NSString * newProcessId = @"";
            
            for (int j = 0; j < [appDelegate.view_layout_array count]; j++)
            {
                NSDictionary * viewLayoutDict = [appDelegate.view_layout_array objectAtIndex:j];
                NSString * objName = [viewLayoutDict objectForKey:VIEW_OBJECTNAME];
                
                SMLog(@"%@ %@", objName , objectName_);
                if ([objName isEqualToString:objectName_])
                {
                    SMLog(@" after %@ %@", objName , objectName_);
                    newProcessId = [viewLayoutDict objectForKey:@"SVMXC__ProcessID__c"];
                    break;
                }
            }


			for (int j = 0; j < columns && j < [detail_fields count]; j++)//[detail_values count ]
			{
                CGRect frame =  CGRectMake(j*field_width, 6, field_width-4,control_height-6);
                lbl2 = [[UILabel alloc]initWithFrame:frame];
                NSString * field_data_type = [[detail_fields objectAtIndex:j] objectForKey:gFIELD_DATA_TYPE];
                NSString * value = [[detail_values objectAtIndex:j] objectForKey:gVALUE_FIELD_VALUE_VALUE];
                
                if([field_data_type isEqualToString:@"datetime"])
                {
                    value = [value stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                    value = [value stringByReplacingOccurrencesOfString:@".000Z" withString:@""];
                    value = [iOSInterfaceObject getLocalTimeFromGMT:value];
                    value = [value stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                    value = [value stringByReplacingOccurrencesOfString:@"Z" withString:@""];
                    NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                    [frm setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
                    NSDate * date = [frm dateFromString:value];
                    [frm  setDateFormat:DATETIMEFORMAT];
                    value = [frm stringFromDate:date];
                }
                
                if([field_data_type isEqualToString:@"date"])
                {
                    NSRange range = [value rangeOfString:value];
                    
                    NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
                    if (range.length > 11 )
                        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    else
                        [formatter setDateFormat:@"yyyy-MM-dd"];
                    NSDate * date = [formatter dateFromString:value];
                    NSDateFormatter * format =[[[NSDateFormatter alloc]init] autorelease];
                    [format setDateFormat:@"MMM dd yyyy"];
                    value = [format stringFromDate:date];
                }
                
                lbl2.text = value;
                if(lbl2.text == nil)
                {
                    ValueCount++;
                }

                lbl2.backgroundColor = [UIColor clearColor];
                
                if([newProcessId length] != 0 && newProcessId != nil && [record_id length] != 0 && record_id  != nil )
                {
                    lbl2.textColor = [UIColor blueColor];
                }
                
                [background addSubview:lbl2];
                

               // [background addSubview:lbl2];
                
                
                if ( [field_data_type isEqualToString:@"boolean"] )
                {
                    UIImageView * v1 = nil;

                    [lbl2 removeFromSuperview];

                    NSString * control_value = [[detail_values objectAtIndex:j] objectForKey:gVALUE_FIELD_VALUE_KEY];
                    
                    if ([control_value isEqualToString:@"True"] || [control_value isEqualToString:@"true"] || [value isEqualToString:@"1"]) 
                    {
                        v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-tick-Icon.png"]] autorelease];
                        v1.backgroundColor = [UIColor clearColor];
                        v1.frame = CGRectMake(j*field_width+20, 12, 18, 18);
                        v1.contentMode = UIViewContentModeCenter;
                        [background addSubview:v1];
                    }
                    else
                    {
                        v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-Cancel-Icon.png"]] autorelease];
                        v1.backgroundColor = [UIColor clearColor];
                        v1.contentMode = UIViewContentModeCenter;
                        v1.frame = CGRectMake(j*field_width+20, 12, 18, 18);
                        [background addSubview:v1];
                    }
                }                   
			}
            
            [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
            
            
            //Radha 29
            cell.userInteractionEnabled = TRUE;
            UITapGestureRecognizer * cellTap;
            cellTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(celltapRecognizer:)] autorelease];
            [cellTap setNumberOfTapsRequired:2];
            NSInteger cellCount = 10000;
            int section_ = index + 1;
            cell.tag = (cellCount * section_) + row;
            [cell addGestureRecognizer:cellTap];
		}
        background.backgroundColor = [UIColor clearColor];
        background.frame = CGRectMake(0, 0, cell.contentView.frame.size.width-42, cell.contentView.frame.size.height);
		[cell.contentView addSubview:background];
	}
    else if(selectedSection == SHOW_ADDITIONALINFO_ROW || selectedSection == SHOW_ALL_ADDITIONALINFO)
    {
        // NSString * additional_info = [appDelegate.additionalInfo objectAtIndex:index];
        NSDictionary * additional_info_dict = [appDelegate.additionalInfo objectAtIndex:index];
        NSString * additional_info = [[additional_info_dict allKeys] objectAtIndex:0];
        NSMutableArray * additional_dict = nil;
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        if([additional_info isEqualToString:PRODUCT_ADDITIONALINFO])
        {
            additional_dict = [appDelegate.SFMPage objectForKey:PRODUCTHISTORY];
        }
        if([additional_info isEqualToString:ACCOUNT_ADITIONALINFO])
        {
            additional_dict = [appDelegate.SFMPage objectForKey:ACCOUNTHISTORY] ;
        }
        NSInteger field_width = background_width/2;
        if (indexPath.row  == 0) //display the column titles
		{
            int columns_count  = 2;
            
            NSArray * array = [[[NSArray alloc] initWithObjects:@"Problem Description",@"Created Date", nil] autorelease];
            // If fields are not present - ERROR CONDITION - then columns should not be added
            if ([additional_dict count] > 0)
            {
                NSString * label_name;
                for (int j=0;j<columns_count;j++)
                {
                    UILabel * lbl = [[[UILabel alloc] initWithFrame:CGRectMake(j*field_width+8, 0, field_width-8,control_height)] autorelease];
                   
                    label_name = [array objectAtIndex:j];
                                       
                    lbl.text = label_name;
                    lbl.font = [UIFont fontWithName:@"HelveticaBold" size:19];
                    lbl.font = [UIFont boldSystemFontOfSize:lbl.font.pointSize];
                    lbl.textColor = [UIColor blackColor];
                    lbl.backgroundColor = [UIColor clearColor];
                    [background addSubview:lbl];
                }
                [cell.contentView addSubview:background];
            }
           
		}
        else
        {
            NSDictionary * info_dict =[additional_dict objectAtIndex:indexPath.row-1];
            if(info_dict != nil)
            {
                
                NSArray * keys = [info_dict allKeys];
                UILabel * lbl = nil;
                NSInteger colmn_count = 0;
                for (int j = 0; j < [keys count]; j++)
                {
                    CGRect frame =  CGRectMake(j*field_width+8, 0, field_width-8,control_height);//(colmn_count*field_width, 6, field_width-4,control_height-6);
                    
                    //CGRect frame = CGRectMake(colmn_count*field_width, 6, field_width-4,control_height-6);

                    UILabel * lbl = [[[UILabel alloc]initWithFrame:frame] autorelease];
                    
                //    UILabel * lbl = [[[UILabel alloc]init] autorelease];
                    NSString  * value = @"";                
                    NSString * str = [keys objectAtIndex:j];
                    
                    //sahana sept 23, 2011
                    lbl.userInteractionEnabled = YES;
                    UITapGestureRecognizer * tapMe = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
                    [lbl addGestureRecognizer:tapMe];
                    [tapMe release];
                    if ([str isEqualToString:@"CreatedDate"])
                    {
                        
                        if(appDelegate.isWorkinginOffline)
                        {   
                           /* value = [info_dict objectForKey:@"CreatedDate"];
                            value = [value stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                            value = [value stringByReplacingOccurrencesOfString:@".000Z" withString:@""];
                            value = [iOSInterfaceObject getLocalTimeFromGMT:value];
                            value = [value stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                            value = [value stringByReplacingOccurrencesOfString:@"Z" withString:@""];
                            NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                            [frm setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
                            NSDate * date = [frm dateFromString:value];
                            [frm  setDateFormat:DATETIMEFORMAT];
                            value = [frm stringFromDate:date];
                            lbl.text = value;
                            lbl.backgroundColor = [UIColor clearColor];
                            [background addSubview:lbl];
                            colmn_count ++;*/
                            
                            NSDate * date = [info_dict objectForKey:@"CreatedDate"];
                            NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                            [frm setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
                            
                            value = [frm stringFromDate:date];
                            value = [iOSInterfaceObject getLocalTimeFromGMT:value];
                            value = [value stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                            value = [value stringByReplacingOccurrencesOfString:@"Z" withString:@""];
                            
                            NSDate * _date = [frm dateFromString:value];
                            
                            [frm setDateFormat:DATETIMEFORMAT];
                            value = [frm stringFromDate:_date];
                       ///     lbl.frame = CGRectMake(j*field_width+8, 0, field_width-8,control_height);
                            lbl.text = value;
                            lbl.backgroundColor = [UIColor clearColor];
                            [background addSubview:lbl];
                            colmn_count ++;
                        }
                        else
                        {    
                            NSDate * date = [info_dict objectForKey:@"CreatedDate"];
                            NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                            [frm setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
                            
                            value = [frm stringFromDate:date];
                            value = [iOSInterfaceObject getLocalTimeFromGMT:value];
                            value = [value stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                            value = [value stringByReplacingOccurrencesOfString:@"Z" withString:@""];
                            
                            NSDate * _date = [frm dateFromString:value];
                            
                            [frm setDateFormat:DATETIMEFORMAT];
                            value = [frm stringFromDate:_date];
                            
                            
                            lbl.text = value;
                            lbl.backgroundColor = [UIColor clearColor];
                            [background addSubview:lbl];
                            colmn_count ++;
                        
                        }
                        
                    }
                    
                    if ([str isEqualToString:gSVMXC__Problem_Description__c])
                    {
                        value = [info_dict objectForKey:gSVMXC__Problem_Description__c];
                        lbl.backgroundColor = [UIColor clearColor];
                        lbl.text = value;
                        [background addSubview:lbl];
                    }
                }
                [cell.contentView addSubview:background];
            }   
        }
    }
            
    UIImageView * bgView = nil;
    if (selectedSection == SHOW_HEADER_ROW || selectedSection == SHOWALL_HEADERS)
	{
        bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]] autorelease];
    }
    if (selectedSection == SHOW_LINES_ROW || selectedSection == SHOWALL_LINES)
    {
        if(flag == FALSE)
            bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]] autorelease];
        else
        {
            flag = FALSE;
            bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Header.png"]] autorelease];
        }
    }
    if(selectedSection == SHOW_ADDITIONALINFO_ROW || selectedSection == SHOW_ALL_ADDITIONALINFO)
    {
         bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]] autorelease];
    }
    
    bgView.frame = CGRectMake(0, 0, _tableView.frame.size.width, 32);
    cell.backgroundView = bgView;
 	return cell;
}


-(void)celltapRecognizer:(id)sender
{
    if (!isInViewMode)
    {       
        SMLog(@"cell being tapped ");
        UITapGestureRecognizer * tap = sender;
        if ([tap.view isKindOfClass:[UITableViewCell class]])    
        {
            UITableViewCell * cell = (UITableViewCell *) tap.view;
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            
            NSInteger indexpath = cell.tag;
            SMLog(@"%d",indexpath);
            NSInteger row     = indexpath % 10000;
            NSInteger section = indexpath /10000;
            SMLog(@"%d %d" , row , section);
            
            
            NSMutableArray * details = [appDelegate.SFMPage objectForKey:gDETAILS];
            NSMutableDictionary * detail = [details objectAtIndex:section-1];
            
            //#4683 - RADHA
            NSString * temp_record_id  = @"";
            
            NSArray * detailArray = [detail objectForKey:@"details_Values_Array"];
            
            NSArray * array = [detailArray objectAtIndex:row - 1];
            
            
            for (NSDictionary * detailDict in array)
            {
                NSString * value_Field_API_Name = [detailDict objectForKey:@"value_Field_API_Name"];
                
                if ([value_Field_API_Name isEqualToString:@"local_id"])
                {
                    temp_record_id = [detailDict objectForKey:@"value_Field_Value_key"];
                }
            }

            
           /* NSMutableArray * array  =  [detail objectForKey:gDETAIL_VALUES_RECORD_ID];
           
            if ([array count] > 0)
               temp_record_id =  [array objectAtIndex:row-1];  */
            
                    
            
            NSString * objectName_  =  [detail objectForKey:gDETAIL_OBJECT_NAME];;
          //  NSString * record_id = [appDelegate.databaseInterface  getLocalIdFromSFId:temp_record_id tableName:objectName_];
            
            NSString * record_id = temp_record_id;
           
            NSString * newProcessId = @"";
            
            for (int j = 0; j < [appDelegate.view_layout_array count]; j++)
            {
                NSDictionary * viewLayoutDict = [appDelegate.view_layout_array objectAtIndex:j];
                NSString * objName = [viewLayoutDict objectForKey:VIEW_OBJECTNAME];
                
                SMLog(@"%@ %@", objName , objectName_);
                if ([objName isEqualToString:objectName_])
                {
                    SMLog(@" after %@ %@", objName , objectName_);
                    newProcessId = [viewLayoutDict objectForKey:@"SVMXC__ProcessID__c"];
                    break;
                }
            }
            
            if([newProcessId length] != 0 && newProcessId != nil && [record_id length] != 0 && record_id  != nil )
            {
                
                [activity startAnimating];
               /* appDelegate.oldRecordId = currentRecordId;
                appDelegate.oldProcessId = currentProcessId;
                appDelegate.sfmPageController.objectName = objectName_;*/
                [self initAllrequriredDetailsForProcessId:newProcessId recordId:record_id object_name:objectName_];
                [self fillSFMdictForOfflineforProcess:newProcessId forRecord:record_id ];
                [self didReceivePageLayoutOffline];
                return;
            }
           /* else
            {
                NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_referred_record_error];
                NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_synchronize_error];
                NSString * Ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];

                
                UIAlertView * alert_view = [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:Ok otherButtonTitles:nil, nil] autorelease];
                [alert_view  show];
                
            } */
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
        }
    }
}

- (UITableViewCell *)SFMEditDetailCellForTable:(UITableView *)_tableView AtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"identifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSInteger width = tableView.frame.size.width;
    NSDictionary * oldValue = nil;
//    UIView * oldBackgroundView =nil;

    UIView * background = nil;
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        background = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 28)] autorelease];
//        oldBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 28)] autorelease];
        [background setAutoresizingMask:( UIViewAutoresizingFlexibleRightMargin )];
        [background setAutoresizesSubviews:YES];
        [cell setAutoresizesSubviews:YES];
    }  
    else
    {      
        background = [[cell.contentView subviews] objectAtIndex:0];
//        oldBackgroundView = [[cell.contentView subviews] objectAtIndex:0];
        NSArray * backgroundSubViews = [background subviews];
        // testing
     
        for (int i = 0; i < [backgroundSubViews count]; i++)
        {
            UIView * view = [backgroundSubViews objectAtIndex:i];
            if(view.tag == 1)
            {
                oldValue = [self valueForcontrol:view];
            
                break;
            }
        }
        //end
        //sahana  16th Aug 
        for(int j = 0; j< [[cell.contentView subviews] count]; j++)
        {
            background = [[cell.contentView subviews] objectAtIndex:j];
            NSArray * backgroundSubViews = [background subviews];
            
            for (int i = 0; i < [backgroundSubViews count]; i++)
            {
                [[backgroundSubViews objectAtIndex:i] removeFromSuperview];
            }
            [background removeFromSuperview];
        }
        background = nil;
    }
    if(background == nil)
    {
        background = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 28)] autorelease];
    }
    if (self.header == YES)
    {
        return cell;
    }

    UIView * id_Type = nil;
    
    NSInteger control_height = 28;
    NSInteger row = [indexPath row];
    //adding label
    CGPoint p = cell.frame.origin;
    p.x = p.x + 10;
    CGSize size = cell.frame.size;
    size.width = size.width/2;
    NSMutableArray * arr = nil;
    CGRect lableframe = CGRectMake(background.frame.origin.x, background.frame.origin.y,240, background.frame.size.height);
    CGRect idFrame = CGRectMake(background.frame.origin.x+250, background.frame.origin.y, 350, background.frame.size.height);
     NSString * control_type = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_DATA_TYPE];
    //sahana 22nd Aug 2011
    if(isInViewMode)
    {
        if([control_type isEqualToString:  @"textarea"])
        {
            background.frame = CGRectMake(0, 0, width, 90);
            lableframe = CGRectMake(background.frame.origin.x, background.frame.origin.y,240,90);
            idFrame = CGRectMake(background.frame.origin.x+250, background.frame.origin.y, 350, 90);
        }
    }
    UILabel * lbl = [[[UILabel alloc] initWithFrame:lableframe] autorelease];
    NSString * label_name = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_LABEL];
    lbl.text = label_name;
    lbl.textColor = [appDelegate colorForHex:@"2d5d83"];
    lbl.backgroundColor = [UIColor clearColor];
    //sahana 23rd sept 2011
    if(!isInViewMode)
    {
        lbl.userInteractionEnabled = TRUE;
        UITapGestureRecognizer * tapMe_Value = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
        [lbl addGestureRecognizer:tapMe_Value];
        [tapMe_Value release];
        
    }
    
    NSString * field_API_Name = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_API_NAME];
    
    //control type
    NSMutableArray * array = [Disclosure_dict objectForKey:gDETAILS_VALUES_ARRAY];
    NSMutableArray * detail_values = [array objectAtIndex:self.selectedRowForDetailEdit];
    NSMutableArray * details_Fields_Array = [Disclosure_dict objectForKey:gDETAILS_FIELDS_ARRAY];
    BOOL readOnly = [[[details_Fields_Array objectAtIndex:row] objectForKey:gFIELD_READ_ONLY] boolValue];
    
    NSString * value = @"";
    NSString * keyValue = nil;
    
    for (int i = 0; i < [detail_values count]; i++)
    {
        NSString * value_Field_API = [[detail_values objectAtIndex:i] objectForKey:gVALUE_FIELD_API_NAME];
        if ([field_API_Name isEqualToString:value_Field_API])
        {
            value = [[detail_values objectAtIndex:i] objectForKey:gVALUE_FIELD_VALUE_VALUE];
            keyValue = [[detail_values objectAtIndex:i]  objectForKey:gVALUE_FIELD_VALUE_KEY];
            break;
        }
        
    }

    CGRect frame = CGRectMake(p.x+250, 6, tableView.frame.size.width-256-20,control_height);
    SMLog(@"%f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);

    [background addSubview:lbl];
    // the process type is in View Mode 
    if(!isInViewMode)
    {
        if([control_type isEqualToString:@"reference"])
        {
            NSString * key = keyValue;
            NSString * related_to_table_name = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_RELATED_OBJECT_NAME];
            NSString * api_name = field_API_Name;
            
            CusLabel * custLabel = [[CusLabel alloc] initWithFrame:idFrame];
            custLabel.backgroundColor = [UIColor clearColor];
            
            custLabel.text = value;
            custLabel.tapRecgLabel = value;  //RADHA 2012june07 
            custLabel.controlDelegate = self;
            //custLabel.textColor = [UIColor blueColor];
            //custLabel.font = [UIFont boldSystemFontOfSize:custLabel.font.pointSize];
            custLabel.userInteractionEnabled = TRUE;
            custLabel.id_ = key;
            custLabel.refered_to_table_name = related_to_table_name;
            custLabel.object_api_name = api_name;
            
            
            //Radha 2012june08
            BOOL recordExists = [appDelegate.dataBase checkIfRecordExistForObject:related_to_table_name Id:key];
            
            
            BOOL flag_ = FALSE;
            
            if (recordExists)
            {
                for (int j = 0; j < [appDelegate.view_layout_array count]; j++)
                {
                    NSDictionary * viewLayoutDict = [appDelegate.view_layout_array objectAtIndex:j];
                    NSString * objName = [viewLayoutDict objectForKey:@"SVMXC__Source_Object_Name__c"];
                    if ([objName isEqualToString:related_to_table_name])
                    {
                        flag_ = TRUE;
                        break;
                    }
                }
                if(flag_)
                {
                    custLabel.textColor = [UIColor blueColor];
                    
                }
            }
            [background addSubview:custLabel];
            
            
        }
        
        else
        {
            UILabel * value_lbl = [[[UILabel alloc] initWithFrame:idFrame] autorelease];
            
            value_lbl.backgroundColor = [UIColor clearColor];
            
            //sahana 23rd sept  2011
            value_lbl.userInteractionEnabled = TRUE;
            UITapGestureRecognizer * tapMe_Value = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
            [value_lbl addGestureRecognizer:tapMe_Value];
            [tapMe_Value release];
            
            if ([control_type isEqualToString:@"boolean"])
            {
                UIImageView *v1 = nil;
                
                if ([value isEqualToString:@"True"] || [value isEqualToString:@"true"] || [value isEqualToString:@"1"]) 
                {
                    v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-tick-Icon.png"]] autorelease];
                    v1.backgroundColor = [UIColor clearColor];
                    v1.frame = CGRectMake(idFrame.origin.x, 12, 18, 18);
                    v1.contentMode = UIViewContentModeCenter;
                    [background addSubview:v1];
                }
                else
                {
                    v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-Cancel-Icon.png"]] autorelease];
                    v1.backgroundColor = [UIColor clearColor];
                    v1.contentMode = UIViewContentModeCenter;
                    v1.frame = CGRectMake(idFrame.origin.x, 12, 18, 18);
                    [background addSubview:v1];
                }
                UIImageView * bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]] autorelease];
                cell.backgroundView = bgView;
                
                [cell.contentView addSubview:background];
                return cell;
            }
            
            //sahana Aug 10th 2010
            if([control_type isEqualToString:@"datetime"])
            {
                value = [value stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                value = [value stringByReplacingOccurrencesOfString:@".000Z" withString:@""];
                value = [iOSInterfaceObject getLocalTimeFromGMT:value];
                value = [value stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                value = [value stringByReplacingOccurrencesOfString:@"Z" withString:@""];
                NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                [frm setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
                NSDate * date = [frm dateFromString:value];
                [frm  setDateFormat:DATETIMEFORMAT];
                value = [frm stringFromDate:date];
            }
            //sahana Aug 10th 2010
            if([control_type isEqualToString:@"date"])
            {
                NSRange range = [value rangeOfString:value];
                
                NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
                if (range.length > 11 )
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                else
                    [formatter setDateFormat:@"yyyy-MM-dd"];
                NSDate * date = [formatter dateFromString:value];
                NSDateFormatter * format =[[[NSDateFormatter alloc]init] autorelease];
                [format setDateFormat:@"MMM dd yyyy"];
                value = [format stringFromDate:date];
            }
            value_lbl.text = value;
            [background addSubview:value_lbl];
        }
    
        
        [cell.contentView addSubview:background];
        UIImageView * bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]] autorelease];
        cell.backgroundView = bgView;
        return cell;
    }
    
    NSString * refObjName = nil;
    NSString * refObjSearchId = nil;
    BOOL idAvailable = NO;
    
    // Special handling for Lookup Additional Filter
    NSNumber * Override_Related_Lookup = nil;
    NSString * Field_Lookup_Context = @"";
    NSString * Field_Lookup_Query = @"";
    
    
    
    
    NSMutableArray * validFor = nil;
    BOOL isdependentPicklist = FALSE;
    NSString * dependPick_controllerName = @""; 
    
    
    
    if ([control_type isEqualToString:@"reference"])
    {
        refObjName = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_RELATED_OBJECT_NAME];
        refObjSearchId = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_RELATED_OBJECT_SEARCH_ID];
        
        Override_Related_Lookup = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_OVERRIDE_RELATED_LOOKUP];
        Field_Lookup_Context = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_LOOKUP_CONTEXT];
        Field_Lookup_Query = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_LOOKUP_QUERY];
    }

    NSString * fieldAPIName = [[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_API_NAME];

   
    if([control_type isEqualToString:  @"picklist"])
    {   
        if(appDelegate.isWorkinginOffline)

        {
            NSString * detail_objectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
            NSMutableArray * descObjArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
            NSMutableArray * descObjValidFor = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
            
//            NSMutableDictionary * _header =  [appDelegate.SFMPage objectForKey:@"header"];
            
//            NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];
            
            isdependentPicklist  = [[appDelegate.databaseInterface getPicklistINfo_isdependentOrControllername_For_field_name:DEPENDENT_PICKLIST field_api_name:fieldAPIName object_name:detail_objectName] boolValue];
            
            dependPick_controllerName = [appDelegate.databaseInterface getPicklistINfo_isdependentOrControllername_For_field_name:CONTROLLER_FIRLD field_api_name:fieldAPIName object_name:detail_objectName];
            [descObjArray addObject:@" "] ;
            [descObjValidFor addObject:@" "];
            
            //query to acces the picklist values for lines 
            NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:fieldAPIName tableName:SFPicklist objectName:detail_objectName];
            
            NSArray * actual_keys = [picklistValues allKeys];
            
            NSArray * allvalues = [picklistValues allValues];
            
            NSMutableArray * allkeys_ordered = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
            [allkeys_ordered addObject:@" "];
            
            //Abinash Fix
            
//            if ([allvalues count] > 0)
//            {
//                //                       allvalues = [self orderingAnArray:allvalues];
//                allvalues = [allvalues sortedArrayUsingSelector:@selector(compare:)];
//            }

			
			//Fix for Defect #4656
			allvalues = [appDelegate.calDataBase sortPickListUsingIndexes:allvalues WithfieldAPIName:fieldAPIName tableName:SFPicklist objectName:detail_objectName];
			
			for (NSString * str in allvalues ) 
            {
                [descObjArray addObject:str];
                
                for(NSString * actual_key in actual_keys)
                {
                    NSString * temp_actual_value =  [picklistValues objectForKey:actual_key];
                    if([temp_actual_value isEqualToString:str])
                    {
                        [allkeys_ordered  addObject:actual_key];
                        break;
                    }
                    
                }
            }
            
            if(isdependentPicklist)
            {
                
                NSMutableDictionary * temp_valid_for = [appDelegate.databaseInterface  getValidForDictForObject:detail_objectName field_api_name:fieldAPIName];
                
                NSArray * validForKeys  = [temp_valid_for allKeys];
                
                for(NSString * orderd_key  in allkeys_ordered)
                {
                    BOOL flag_ =  [validForKeys containsObject:orderd_key];
                    if(flag_)
                    {
                        NSString * value_validFor =  [temp_valid_for objectForKey:orderd_key];
                        [descObjValidFor addObject:(value_validFor!= nil)?value_validFor:@""];
                    }
                    
                }
            }
            
            arr = [[[NSMutableArray  alloc] initWithArray:descObjArray] autorelease];
            validFor = [[[NSMutableArray alloc] initWithArray:descObjValidFor] autorelease];

        }
               
    }
    
    if([control_type isEqualToString:@"multipicklist"])
    {   
        if(appDelegate.isWorkinginOffline)
        {
            NSString * detail_objectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
            NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:fieldAPIName tableName:SFPicklist objectName:detail_objectName];
            
            NSArray * allvalues = [picklistValues allValues];
			
			//Shrinivas Fix for Defect : 6011.
			allvalues = [appDelegate.calDataBase sortPickListUsingIndexes:allvalues WithfieldAPIName:fieldAPIName tableName:SFPicklist objectName:detail_objectName];
			
            arr = [[[NSMutableArray  alloc] initWithArray:allvalues] autorelease];
        }
    }
   
      
    if ([control_type isEqualToString:@"reference"] && [fieldAPIName isEqualToString:@"RecordTypeId"])
    {
        NSString * detail_objectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
        arr = [appDelegate.databaseInterface getRecordTypeValuesForObjectName:detail_objectName];
    }
    if(oldValue != nil)
    {
        if([control_type isEqualToString:@"reference"])
        {
            
        }
        else
        {
            NSString * apiName = [oldValue objectForKey:DapiName];
            if([apiName isEqualToString:fieldAPIName])
            {
               // value = [oldValue  objectForKey:Dvalue];
            }
        }
    }
    
    BOOL required = [[[Disclosure_Details objectAtIndex:row] objectForKey:gFIELD_REQUIRED] boolValue];
	
	NSString * object_api_name = [Disclosure_dict objectForKey:@"detail_object_name"];
    
    id_Type = [self getControl:control_type withRect:idFrame withData:arr withValue:value fieldType:fieldAPIName labelValue:label_name enabled:!readOnly refObjName:refObjName referenceView:self.view indexPath:indexPath required:required valueKeyValue:keyValue lookUpSearchId:refObjSearchId overrideRelatedLookup:Override_Related_Lookup fieldLookupContext:Field_Lookup_Context fieldLookupQuery:Field_Lookup_Query dependentPicklistControllerName:dependPick_controllerName picklistValidFor:validFor picklistIsdependent:isdependentPicklist objectAPIName:object_api_name];

    id_Type.tag = 1;

    if (readOnly) 
    {
        if ([control_type isEqualToString:@"boolean"])
        {
            UIImageView *v1 = nil;
            
            if ([value isEqualToString:@"True"] || [value isEqualToString:@"true"] || [value isEqualToString:@"1"]) 
            {
                v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-tick-Icon.png"]] autorelease];
                v1.backgroundColor = [UIColor clearColor];
                v1.frame = CGRectMake(idFrame.origin.x, 12, 18, 18);
                v1.contentMode = UIViewContentModeCenter;
                [background addSubview:v1];
            }
            else
            {
                v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-Cancel-Icon.png"]] autorelease];
                v1.backgroundColor = [UIColor clearColor];
                v1.contentMode = UIViewContentModeCenter;
                v1.frame = CGRectMake(idFrame.origin.x, 12, 18, 18);
                [background addSubview:v1];
            }
            [cell.contentView addSubview:background];
            return cell;
        }
    }

    [id_Type setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin)];
    [background addSubview:id_Type];
    [cell.contentView addSubview:background];
    
    UIImageView * bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-Table-Strip.png"]] autorelease];
    
    cell.backgroundView = bgView;
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isInEditDetail)
    {
        if (selectedSection == SHOW_LINES_ROW || selectedSection == SHOWALL_LINES)
        {

            NSInteger i =  indexPath.row ;
            if(i == 0)
            {
                currentEditRow = nil;
                return;
            }
        }
    }
     currentEditRow = [indexPath retain];
}

- (void)viewDidUnload
{
    /*
    [tableView release];
    tableView = nil;
    [indicatorForAddRow release];
    indicatorForAddRow = nil;
    [signature release];
    signature = nil;
    [activity release];
    activity = nil;
    [indicatorForAddRow release];
    indicatorForAddRow = nil;
    [webView release];
    webView = nil;
    */
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	// self.popoverController = nil;
}

#pragma mark - UIScrollView Delegate Method
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}

#pragma mark - UINavigationController Delegate Method
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self != viewController)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
    else
    {
        DetailViewController * newDetail = (DetailViewController *)viewController;
        newDetail->didRunOperation = NO;
    }
    
    DetailViewController * detailView = (DetailViewController *)viewController;
    [detailView.tableView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:detailView selector:@selector(keyBoardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:detailView selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:detailView selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self enableSFMUI];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //[appDelegate setSyncStatus:appDelegate.SyncStatus];
    if(appDelegate.isWorkinginOffline)
    {
        
    }
    else
    {
        if (![appDelegate isInternetConnectionAvailable])
        {
            if (appDelegate.SFMPage != nil)
            {
                    [self.tableView reloadData];
                    [appDelegate.sfmPageController.rootView refreshTable];
            }
                
            [activity stopAnimating];
            [self enableSFMUI];
            return;
        }
    }
    [self enableSFMUI];
    
    [self.tableView reloadData];
    
    if (didReceiveMemoryWarning)
    {
        didReceiveMemoryWarning = NO;
        [self didSelectRow:selectedRow ForSection:selectedSection];
    }
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    appDelegate.wsInterface.sfm_response = TRUE;
	
	// Release any cached data, images, etc that aren't in use.
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.isDetailActive)
    {
    }
    
    didReceiveMemoryWarning = YES;
}

- (void)dealloc
{
    if ([self.view isHidden])
    {
        
    }
    [_myPopoverController release];
    [mLookupDictionary release];
    [_toolbar release];
    [_detailItem release];
    [_detailDescriptionLabel release];
    [activity release];
    [indicatorForAddRow release];
    indicatorForAddRow = nil;
    [webView release];
    [backBtn release];
	[super dealloc];
}

#pragma mark - Custom Controls' Delegate Method

// Called when the Lookup value is updated by the user.
- (void) didUpdateLookUp:(NSString *)updatedValue fieldApiName:(NSString *)fieldApiName valueKey:(NSString *)key
{
    [tableView reloadData];
}

// Lookup History
- (void) addLookupHistory:(NSMutableArray *)lookupHistory forRelatedObjectName:(NSString *)relatedObjectName
{
    if(appDelegate.isWorkinginOffline)
    {
        
    }
    else
    {
        
    }
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.lookupHistory == nil)
        appDelegate.lookupHistory = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];

    [appDelegate.lookupHistory setObject:lookupHistory forKey:relatedObjectName];
}

- (void) setLookupPopover:(UIPopoverController *)popover
{
    lookupPopover = popover;
}

- (void) controlIndexPath:(NSIndexPath *)indexPath
{
    currentEditRow = [indexPath retain];
    SMLog(@"%@", currentEditRow);
}

// This one's ONLY for LOOKUP
- (void) selectControlAtIndexPath:(NSIndexPath *)indexPath
{
    currentEditRow = [indexPath retain];
}

- (void) deselectControlAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void) control:(id)control didChangeValue:(NSString *)value atIndexPath:(NSIndexPath *)indexPath
{
    // Obtain the section and row for the control being edited curently
    // Modify the field according to the Field_API_Name
    SMLog(@"%@", value);
}

// Store values per session
- (void) updateDictionaryForCellAtIndexPath:(NSIndexPath *)indexPath fieldAPIName:(NSString *)fieldAPI fieldValue:(NSString *)fieldValue fieldKeyValue:(NSString *)fieldKeyValue controlType:(NSString *)control_type
{
    if (!isInEditDetail)
    {
        // Determine if section is SHOWALLHEADER or SHOWHEADERSECTION and only then set dictionary value for fieldAPIName key
        // Header will have array of dictionaries
        // fetch the dictionary based on the indexPath and control in that row being edited
        // update dictionary value for key (fieldAPIName)
        if (selectedSection == SHOW_HEADER_ROW || selectedSection == SHOWALL_HEADERS)
        {
            int row = indexPath.row;
            int section = indexPath.section;
            int index;
            
            if (isDefault)
                index = section;
            else
                index = selectedRow;
            
            NSMutableDictionary *header_section = [appDelegate.wsInterface GetHeaderSectionForSequenceNumber:index];
            int coloumns = [[header_section objectForKey:gSECTION_NUMBER_OF_COLUMNS] intValue];
            NSMutableArray * fields = [header_section objectForKey:gSECTION_FIELDS];
            NSMutableDictionary *fieldc1 = nil;
            NSMutableDictionary *fieldc2 = nil;
            
            for (int i=0;i < [fields count];i++)
            {
                if ([[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_ROW] intValue] == row+1
                    && [[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_COLUMN] intValue] == 1)
                    fieldc1 = [fields objectAtIndex:i];
                
                if (coloumns == 2)
                {
                    if ([[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_ROW] intValue] == row+1
                        && [[[fields objectAtIndex:i] objectForKey:gFIELD_DISPLAY_COLUMN] intValue] == 2)
                        fieldc2 = [fields objectAtIndex:i];
                }
            }
            //if there is only coloumn2 present, but not coloumn1, swap them! - pavamamn - check this. this does not sound right!  
            if (fieldc1 == nil && fieldc2 != nil)
            {
                fieldc1 = fieldc2;
                fieldc2 = nil;
            }
            NSMutableArray * field_columns = [NSMutableArray arrayWithObjects:fieldc1, fieldc2, nil];
            for (int j = 0; j < [field_columns count]; j++)
            {
                NSMutableDictionary * dict = [field_columns objectAtIndex:j];
                NSString * fieldAPIName = [dict objectForKey:gFIELD_API_NAME];
                
                if([fieldAPIName isEqualToString:fieldAPI])
                {
                    if([control_type isEqualToString: @"picklist"])
                    {
                        if(appDelegate.isWorkinginOffline)
                        {
                            NSMutableDictionary * _header =  [appDelegate.SFMPage objectForKey:@"header"];
                            NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];

                            //query to acces the picklist values for lines 
                            NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:fieldAPIName tableName:SFPicklist objectName:headerObjName];
                            
                            
                            NSArray * allvalues = [picklistValues allValues];
                            NSArray * allkeys = [picklistValues allKeys];
                            
                            for(int i =0; i<[picklistValues count];i++)
                            {
                                NSString * value = [allvalues objectAtIndex:i];
                                if([value isEqualToString:fieldValue])
                                {
                                    fieldKeyValue = [allkeys objectAtIndex:i];
                                    break;
                                }
                            } 
                            if(fieldKeyValue == nil)
                            {
                                fieldKeyValue = @"";
                            }

                        }
                        else
                        {
                            for (int i = 0; i < [appDelegate.describeObjectsArray count]; i++)
                            {
                                ZKDescribeSObject * descObj = [appDelegate.describeObjectsArray objectAtIndex:i];
                                ZKDescribeField * descField = [descObj fieldWithName:fieldAPIName];
                                if (descField == nil)
                                    continue;
                                else
                                {   
                                    NSArray * pickListEntryArray = [descField picklistValues];
                                    for (int k = 0; k < [pickListEntryArray count]; k++)
                                    {
                                        NSString * value = [[pickListEntryArray objectAtIndex:k] label];
                                        if([value isEqualToString:fieldValue])
                                        {
                                            fieldKeyValue =[[pickListEntryArray objectAtIndex:k] value];
                                            break;
                                        }
                                        else
                                        {
                                            fieldKeyValue = @"";
                                        }
                                    }
                                    break;
                                }
                            }
                        
                            if(fieldKeyValue == nil)
                            {
                                fieldKeyValue = @"";
                            }
                        }
                        
                    }
                    if([control_type isEqualToString:@"multipicklist"])
                    {
                        NSMutableArray * keyVal	 = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                        NSString * keyValueString =[[[NSString alloc] init] autorelease];
                        
                        
                        if(appDelegate.isWorkinginOffline)
                        {
                            NSMutableDictionary * _header =  [appDelegate.SFMPage objectForKey:@"header"];
                            NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];

                            //query to acces the picklist values for lines 
                            NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:fieldAPIName tableName:SFPicklist objectName:headerObjName];
                            
                            
                            NSArray * allvalues = [picklistValues allValues];
                            NSArray * allkeys = [picklistValues allKeys];
                            NSArray * array = [fieldValue componentsSeparatedByString:@";"];
                            
                            for(int j = 0; j < [array count]; j++)
                            {
                                NSString * value_field = [array objectAtIndex:j];
                                
                                for(int i = 0; i < [picklistValues count]; i++)
                                {
                                    NSString * value = [allvalues objectAtIndex:i];
                                    if([value isEqualToString:value_field])
                                    {
                                        [keyVal addObject:[allkeys objectAtIndex:i]];
                                        break;
                                    }
                                }
                            }
                       
                            for(int j = 0 ; j < [keyVal count]; j++)
                            {
                                if ([keyValueString length] > 0)
                                    keyValueString = [keyValueString stringByAppendingString:[NSString stringWithFormat:@";%@", [keyVal objectAtIndex:j]]];
                                else
                                    keyValueString = [keyValueString stringByAppendingString:[keyVal objectAtIndex:j]];
                            }
                            
                            if([keyValueString length] == 0)
                            {
                                keyValueString = @"";
                            }
                            
                            fieldKeyValue = keyValueString;
                        }

                    }
                    if([control_type isEqualToString: @"date"])
                    {
                        NSString * str = fieldValue;
                        NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                        [frm setDateFormat: @"MMM dd yyyy"];
                        NSDate * date = [frm dateFromString:str];
                        [frm  setDateFormat:@"yyyy-MM-dd"];
                        NSString * final_date = [frm stringFromDate:date];
                        if ((final_date != nil) && (![str isEqualToString:@""]))
                        {
                            fieldValue = final_date;
                            fieldKeyValue = final_date;
                        }
                        else
                        {
                            fieldValue = @"";
                            fieldKeyValue = @"";
                        }
                    }
                    if([control_type isEqualToString:@"datetime"])    
                    {
                        NSString * str = fieldValue;
                        
                        NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                        [frm setDateFormat:DATETIMEFORMAT];
                        NSDate * date = [frm dateFromString:str];
                        [frm  setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        NSString * str1 = [frm stringFromDate:date];//.000Z
                        
                        // Convert this str1 back into GMT
                        str1 = [iOSInterfaceObject getGMTFromLocalTime:str1];
                        str1 = [str1  stringByReplacingOccurrencesOfString:@"Z" withString:@".000Z"];
                        if ((str1 != nil) && (![str isEqualToString:@""]))
                        {
                            fieldValue = str1;
                            fieldKeyValue = str1;
                        }
                        else
                        {
                            fieldValue = @"";
                            fieldKeyValue = @"";
                        }
                        SMLog(@"%@",date);
                    }
                    if([fieldAPI isEqualToString:@"RecordTypeId"])
                    {
                        NSMutableDictionary * _header =  [appDelegate.SFMPage objectForKey:@"header"];
                        NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];

                       fieldKeyValue =  [appDelegate.databaseInterface getRecordTypeIdForRecordTypename:fieldValue objectApi_name:headerObjName];
                        if (fieldKeyValue == nil || fieldValue == nil || [fieldValue length] == 0 || [fieldKeyValue length] == 0)
                        {
                            fieldKeyValue = @"";
                            fieldValue = @"";
                        }
                    }
                    
                    [dict setValue:fieldKeyValue forKey:gFIELD_VALUE_KEY];
                    [dict setValue:fieldValue    forKey:gFIELD_VALUE_VALUE];
                }
            }
        }
    }
    else
    {
        //sahana 26th sept 2011
        //control type
        NSMutableArray * array = [Disclosure_dict objectForKey:gDETAILS_VALUES_ARRAY];
        NSMutableArray * detail_values = [array objectAtIndex:self.selectedRowForDetailEdit];
        
        for (int i = 0; i < [detail_values count]; i++)
        {
                NSString * value_Field_API = [[detail_values objectAtIndex:i] objectForKey:gVALUE_FIELD_API_NAME];
                if([fieldAPI isEqualToString:value_Field_API])
                {
                    if([control_type isEqualToString: @"picklist"])
                    {
                        if(appDelegate.isWorkinginOffline)
                        {
                            NSString * detailObjectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
                            //query to acces the picklist values for lines 
                            NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:value_Field_API tableName:SFPicklist objectName:detailObjectName];
                            
                            
                            NSArray * allvalues = [picklistValues allValues];
                            NSArray * allkeys = [picklistValues allKeys];
                            
                            for(int i =0; i<[picklistValues count];i++)
                            {
                                NSString * value = [allvalues objectAtIndex:i];
                                if([value isEqualToString:fieldValue])
                                {
                                    fieldKeyValue = [allkeys objectAtIndex:i];
                                    break;
                                }
                            } 
                            if(fieldKeyValue == nil)
                            {
                                fieldKeyValue = @"";
                            }
                        }
                        
                    }
                    if([control_type isEqualToString:@"multipicklist"])
                    {
                        
                        NSMutableArray * keyVal	 = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                        NSString * keyValueString =[[[NSString alloc] init] autorelease];
                        
                        if(appDelegate.isWorkinginOffline)
                        {
                            NSString * detailObjectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
                            
                            //query to acces the picklist values for lines 
                            NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:value_Field_API tableName:SFPicklist objectName:detailObjectName];
                            
                            
                            NSArray * allvalues = [picklistValues allValues];
                            NSArray * allkeys = [picklistValues allKeys];
                            NSArray * array = [fieldValue componentsSeparatedByString:@";"];
                            
                            for(int j = 0; j < [array count]; j++)
                            {
                                NSString * value_field = [array objectAtIndex:j];
                                
                                for(int i = 0; i < [picklistValues count]; i++)
                                {
                                    NSString * value = [allvalues objectAtIndex:i];
                                    if([value isEqualToString:value_field])
                                    {
                                        [keyVal addObject:[allkeys objectAtIndex:i]];
                                        break;
                                    }
                                }
                            }
                            
                            for(int j = 0 ; j < [keyVal count]; j++)
                            {
                                if ([keyValueString length] > 0)
                                    keyValueString = [keyValueString stringByAppendingString:[NSString stringWithFormat:@";%@", [keyVal objectAtIndex:j]]];
                                else
                                    keyValueString = [keyValueString stringByAppendingString:[keyVal objectAtIndex:j]];
                            }
                            
                            if([keyValueString length] == 0)
                            {
                                keyValueString = @"";
                            }
                            
                            fieldKeyValue = keyValueString;
                        }
                    }
                    
                    if([control_type isEqualToString: @"date"])
                    {
                        NSString * str = fieldValue;
                        NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                        [frm setDateFormat: @"MMM dd yyyy"];
                        NSDate * date = [frm dateFromString:str];
                        [frm  setDateFormat:@"yyyy-MM-dd"];
                        NSString * final_date = [frm stringFromDate:date];
                        if ((final_date != nil) && (![str isEqualToString:@""]))
                        {
                            fieldValue = final_date;
                            fieldKeyValue = final_date;
                        }
                        else
                        {
                            fieldValue = @"";
                            fieldKeyValue = @"";
                        }
                    }
                    if([control_type isEqualToString:@"datetime"])    
                    {
                        NSString * str = fieldValue;
                        
                        NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                        [frm setDateFormat:DATETIMEFORMAT];
                        NSDate * date = [frm dateFromString:str];
                        [frm  setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        NSString * str1 = [frm stringFromDate:date];//.000Z
                        
                        // Convert this str1 back into GMT
                        str1 = [iOSInterfaceObject getGMTFromLocalTime:str1];
                        str1 = [str1  stringByReplacingOccurrencesOfString:@"Z" withString:@".000Z"];

                        if ((str1 != nil) && (![str isEqualToString:@""]))
                        {
                            fieldValue = str1;
                            fieldKeyValue = str1;
                        }
                        else
                        {
                            fieldValue = @"";
                            fieldKeyValue = @"";
                        }
                        SMLog(@"%@",date);
                    }
                    if([fieldAPI isEqualToString:@"RecordTypeId"])
                    {
                      
                        NSString * detailObjectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
                        fieldKeyValue =  [appDelegate.databaseInterface getRecordTypeIdForRecordTypename:fieldValue objectApi_name:detailObjectName];
                        if (fieldKeyValue == nil || fieldValue == nil || [fieldValue length] == 0 || [fieldKeyValue length] == 0)
                        {
                            fieldKeyValue = @"";
                            fieldValue = @"";
                        }
                    }
                
                    [[detail_values objectAtIndex:i] setValue:fieldValue forKey:gVALUE_FIELD_VALUE_VALUE];
                    [[detail_values objectAtIndex:i] setValue:fieldKeyValue forKey:gVALUE_FIELD_VALUE_KEY];
                    break;
            }
            
        }

        
    }
}


#pragma mark - getControls to tableView cell
-(id)getControl:(NSString *)controlType withRect:(CGRect)frame withData:(NSArray *)datasource withValue:(NSString *)value fieldType:(NSString *)fieldType labelValue:(NSString *)labelValue enabled:(BOOL)readOnly refObjName:(NSString *)refObjName referenceView:(UIView *)POView indexPath:(NSIndexPath *)indexPath required:(BOOL)required valueKeyValue:(NSString *)valueKeyValue lookUpSearchId:(NSString *)searchid overrideRelatedLookup:(NSNumber *)Override_Related_Lookup fieldLookupContext:(NSString *)Field_Lookup_Context fieldLookupQuery:(NSString *)Field_Lookup_Query dependentPicklistControllerName:(NSString *)dependPick_controllerName picklistValidFor:(NSMutableArray *)validFor picklistIsdependent:(BOOL)isdependentPicklist objectAPIName:(NSString *)object_api_name
{
    if([controlType isEqualToString:@"picklist"])
    {
        BotSpinnerTextField * botSpinner;
        //[datasource  addObject:@""];
        
        if (labelValue == nil)
        {
            botSpinner = nil;
            return botSpinner;
        }
        else
        {
            botSpinner = [[BotSpinnerTextField alloc] initWithFrame:frame initArray:datasource];
            botSpinner.text = value;
            if(!isInViewMode)
            {
                botSpinner.enabled = NO;
            }
            else
            {
                botSpinner.enabled = readOnly;
            }
            SMLog(@"%@", value);
            botSpinner.indexPath = indexPath;
            botSpinner.fieldAPIName = fieldType;
            botSpinner.required = required;
            botSpinner.controlDelegate = self;
            botSpinner.control_type = controlType;
            botSpinner.TFHandler.isdependentPicklist =isdependentPicklist;
            botSpinner.TFHandler.validFor = validFor;
            botSpinner.TFHandler.controllerName = dependPick_controllerName;
            SMLog(@" isdepentent value  validFor%@  controlType %@" , validFor , controlType);
            return botSpinner;
        }
    }
    
    if([controlType isEqualToString:@"boolean"])
    {
        frame.origin.y = 3;
        CSwitch * switchType = [[CSwitch alloc] initWithFrame:frame];
        
        if (!isInViewMode)
            switchType.enabled = NO;
        else
            switchType.enabled = readOnly;
        switchType.indexPath = indexPath;
        if([value isEqualToString:@"True"] || [value isEqualToString:@"true"] || [value isEqualToString:@"1"])
        {
            [switchType setOn:YES];
        }
        else
        {
             [switchType setOn:NO];
        }
        switchType.fieldAPIName = fieldType;
        switchType.required = required;
        switchType.controlDelegate = self;
        switchType.control_type = controlType;
        return switchType;
    }
    
    if([controlType isEqualToString:@"percent"])
    {
        CTextField * PercentType;
        PercentType = [[CTextField alloc] initWithFrame:frame lableValue:labelValue controlType:@"percent" isinViewMode:isInViewMode];
        PercentType.controlDelegate = self;
        PercentType.indexPath = indexPath;
        if (!isInViewMode)
            PercentType.enabled = NO;
        else
            PercentType.enabled = readOnly;
        
        PercentType.text = value;
        PercentType.fieldAPIName = fieldType;
        PercentType.required = required;
        PercentType.control_type = controlType;
        return PercentType;
          
    }
    if([controlType isEqualToString:@"phone"])
    {
        CTextField * phonetype;
        phonetype = [[CTextField  alloc] initWithFrame:frame lableValue:labelValue controlType:@"phone" isinViewMode:isInViewMode];
        phonetype.controlDelegate = self;
        phonetype.indexPath = indexPath;
        if (!isInViewMode)
            phonetype.enabled = NO;
        else
            phonetype.enabled = readOnly;
        
        phonetype.text=value;
        phonetype.fieldAPIName = fieldType;
        phonetype.required = required;
        phonetype.control_type = controlType;
        return phonetype;
        
    }
     
    if([controlType isEqualToString:@"currency"])
    {
        CTextField * currency = nil;
        
        if ( labelValue == nil )
        {
            currency = nil;
            return currency;
        }
        else 
        {
            currency = [[CTextField  alloc] initWithFrame:frame lableValue:labelValue controlType:@"currency" isinViewMode:isInViewMode];
            currency.controlDelegate = self;
            currency.indexPath = indexPath;
            // if (!isInViewMode)
            currency.enabled = readOnly;
            currency.text = value;
            currency.fieldAPIName = fieldType;
            currency.required = required;
            currency.control_type = controlType;
            return currency;
        }
    }
    
    if([controlType isEqualToString:@"double"])
    {
        CTextField * doubleType;
 
        if (labelValue == nil)
        {
            doubleType = nil;
            return doubleType;
        }
        else
	{
        doubleType = [[CTextField  alloc] initWithFrame:frame lableValue:labelValue controlType:@"double" isinViewMode:isInViewMode];
        doubleType.controlDelegate = self;
        doubleType.text = value;
        doubleType.indexPath = indexPath;
        if (!isInViewMode)
            doubleType.enabled = NO;
        else
            doubleType.enabled = readOnly;
        doubleType.fieldAPIName = fieldType;
        doubleType.required = required;
        doubleType.control_type = controlType;
        return doubleType;
	}
    }
    
    if([controlType isEqualToString:@"textarea"])    
    {
        CusTextView * textarea = [[CusTextView alloc] initWithFrame:frame lableValue:labelValue];
        textarea.controlDelegate = self;
        if (!isInViewMode)
            textarea.editable = NO;
        else
            textarea.editable = readOnly;
        textarea.indexPath = indexPath;
        textarea.text=value;
	    textarea.object_api_name = object_api_name;
        textarea.font = [UIFont fontWithName:@"Helvetica" size:14];
        textarea.layer.cornerRadius = 5;
        textarea.fieldAPIName = fieldType;
        textarea.required = required;
        textarea.control_type = controlType;
        return textarea;
    }
    
    if([controlType isEqualToString:@"datetime"])    
    {
        CtextFieldWithDatePicker * datetimeType = [[CtextFieldWithDatePicker alloc] initWithFrame:frame];
        //datetimeType.text = @"2011-05-25T03:30:00.000Z";
        datetimeType.text = value;
        NSString * string;
//        string = datetimeType.text;
        if (!isInViewMode)
            datetimeType.enabled = NO;
        else
            datetimeType.enabled = readOnly;
        datetimeType.fieldAPIName = fieldType;
        datetimeType.required = required;
        datetimeType.controlDelegate = self;
        datetimeType.control_type = controlType;
        datetimeType.indexPath = indexPath;
  
         //sahana 16ht Aug
        NSRange range = [value  rangeOfString:@"-"];
        if(range.location == NSNotFound)
        {
            if(value != nil)
            {
                datetimeType.text =  value;
            }
            else
            {
                datetimeType.text = @"";
            }
            return datetimeType;
        } 
//        string = [string stringByReplacingOccurrencesOfString:@"T" withString:@" "];
//        string = [string stringByReplacingOccurrencesOfString:@".000Z" withString:@""];
        string = [iOSInterfaceObject getLocalTimeFromGMT:value];
        string = [string stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        string = [string stringByReplacingOccurrencesOfString:@"Z" withString:@""];
        NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
        [frm setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        NSDate * date = [frm dateFromString:string];
        [frm  setDateFormat:DATETIMEFORMAT];
        datetimeType.text = [frm stringFromDate:date];
        
        //sahana 16ht Aug
        if (datetimeType.text == nil)
        {
            datetimeType.text = @"";
        }
       
        return datetimeType;
    }

    if([controlType isEqualToString:@"reference"] && [fieldType isEqualToString:@"RecordTypeId"])
    {
        BotSpinnerTextField * botSpinner = [[[BotSpinnerTextField alloc] initWithFrame:frame initArray:datasource] autorelease];
        botSpinner.text = value;
        if (!isInViewMode)
            botSpinner.enabled = NO;
        else
            botSpinner.enabled = readOnly;
        botSpinner.indexPath = indexPath;
        botSpinner.fieldAPIName = fieldType;
        botSpinner.required = required;
        botSpinner.control_type = controlType;
        botSpinner.controlDelegate = self;
        return botSpinner;
    }
    else if([controlType isEqualToString:@"reference"])
    {
        LookupField * lookup = nil;
        
        if (labelValue == nil)
        {
            lookup = nil;
            return lookup;
        }        
        else
        {
            lookup = [[LookupField alloc] initWithFrame:frame labelValue:labelValue inView:POView];
            lookup.controlDelegate = self;
            [lookup settextField:value];
            if (!isInViewMode)
                lookup.enabled = NO;
            else
                lookup.enabled = readOnly;
            
            if (isInEditDetail)
            {
                lookup.selectedIndexPath = selectedIndexPath;
                lookup.Disclosure_dict = Disclosure_dict;
            }
            else
            {
                lookup.selectedIndexPath = nil;
            }
            
            lookup.first_idValue = valueKeyValue;
            lookup.indexPath = indexPath;
            lookup.searchId = searchid;
            lookup.objectName = refObjName;
            lookup.objectLabel = labelValue;
            lookup.fieldAPIName = fieldType;
            lookup.required = required;
            lookup.control_type = controlType;
            lookup.Override_Related_Lookup = Override_Related_Lookup;
            lookup.Field_Lookup_Context = Field_Lookup_Context;
            lookup.Field_Lookup_Query = Field_Lookup_Query;
            return lookup;
        }
    }

    if([controlType isEqualToString:@"date"])
    {
        CusDateTextField * date_type = nil;
        
        if (labelValue == nil)
        {
            date_type = nil;
            return date_type;
        }
        else
        {        
            date_type = [[CusDateTextField alloc] initWithFrame:frame];

            if (!isInViewMode)
                date_type.enabled = NO;
            else
                date_type.enabled = readOnly;
            date_type.indexPath = indexPath;
            date_type.fieldAPIName = fieldType;
            date_type.required = required;
            date_type.controlDelegate = self;
            date_type.control_type = controlType;

            //sahana 16ht Aug
            NSRange range = [value  rangeOfString:@"-"];
            if(range.location == NSNotFound)
            {
                if(value != nil)
                {
                    date_type.text =  value;
                }
                else
                {
                    date_type.text = @"";
                }
                return date_type;
            }

            NSRange range1 = [value rangeOfString:value];
            
            NSDateFormatter * formatter = [[[NSDateFormatter alloc] init] autorelease];
            if (range1.length > 11 )
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            else
                [formatter setDateFormat:@"yyyy-MM-dd"];
            NSDate * d = [formatter dateFromString:value];
            NSDateFormatter *format =[[[NSDateFormatter alloc]init] autorelease];
            [format setDateFormat:@"MMM dd yyyy"];
            NSString * str = [format stringFromDate:d];
            date_type.text = str;
             //sahana 16ht Aug
            if(value != nil && str == nil)
            {
                date_type.text = value;
            }
            //sahana 16ht Aug
            if(date_type.text == nil)
            {
                date_type.text = @"";
            }
            
            return date_type;
        }
    }

    if([controlType isEqualToString:@"string"])
    {
        cusTextFieldAlpha  * string_control = [[cusTextFieldAlpha alloc] initWithFrame:frame control_type:controlType isInViewMode:isInViewMode];
        string_control.controlDelegate = self;
        string_control.text = value;
        if (!isInViewMode)
            string_control.enabled = NO;
        else
            string_control.enabled = readOnly;
        string_control.indexPath = indexPath;
        string_control.fieldAPIName = fieldType;
        string_control.required = required;
        string_control.control_type = controlType;
        return string_control;
    }
    if([controlType isEqualToString:@"email"])
    {
        cusTextFieldAlpha  * email_control = [[cusTextFieldAlpha alloc] initWithFrame:frame control_type:controlType isInViewMode:isInViewMode];
        email_control.controlDelegate = self;
        email_control.text = value;
        if (!isInViewMode)
            email_control.enabled = NO;
        else
            email_control.enabled = readOnly;
        email_control.indexPath = indexPath;
        email_control.fieldAPIName = fieldType;
        email_control.required = required;
        email_control.control_type = controlType;
        return email_control;
        
    }
    if([controlType isEqualToString:@"url"])
    {
        cusTextFieldAlpha  * url_control = [[cusTextFieldAlpha alloc] initWithFrame:frame control_type:controlType isInViewMode:isInViewMode];
        url_control.controlDelegate = self;
        url_control.text = value;
        // url_control.enabled = readOnly;
        url_control.indexPath = indexPath;
        url_control.fieldAPIName = fieldType;
        url_control.required = required;
        url_control.control_type = controlType;
        return url_control; 
    }
    if([controlType isEqualToString:@"multipicklist"])
    {
        BMPTextView  * multipicklist_type = [[BMPTextView alloc] initWithFrame:frame initArray:datasource];
        multipicklist_type.text = value;
        if (!isInViewMode)
            multipicklist_type.enabled = NO;
        else
            multipicklist_type.enabled = readOnly;
        multipicklist_type.indexPath = indexPath;
        multipicklist_type.fieldAPIName = fieldType;
        multipicklist_type.required = required;
        multipicklist_type.control_type= controlType;
        multipicklist_type.controlDelegate = self;
        return multipicklist_type;
    }
    return nil;

}

#pragma  mark - GetvalueForcontrol
- (NSDictionary *) valueForcontrol:(UIView *) control_Type
{
    if([control_Type isKindOfClass:[CusTextView class]])
    {
        CusTextView * textarea ;
        textarea =( CusTextView *) control_Type;
        return [NSDictionary dictionaryWithObjectsAndKeys:textarea.text,Dvalue,
                textarea.fieldAPIName,DapiName,
                @"textarea", Dcontrol_type,
                @"", Didtype,
                nil];
    }
    if([control_Type isKindOfClass:[CSwitch class]])
    {
        CSwitch *switch_control;
        switch_control=(CSwitch *) control_Type;
        
        NSArray * keys = [NSArray arrayWithObjects:Dvalue, DapiName, Dcontrol_type, Didtype, nil];
        
        if(switch_control.on)
        {
            NSArray * objects = [NSArray arrayWithObjects:@"True", switch_control.fieldAPIName, @"boolean", @"", nil];
            return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        }
        else
        {
            NSArray * objects = [NSArray arrayWithObjects:@"False", switch_control.fieldAPIName, @"boolean", @"", nil];
            return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        }
       
    }
    if([control_Type isKindOfClass:[CTextField class]])
    {
        CTextField * textFieldType ;
        textFieldType = (CTextField *) control_Type;
        //return [NSDictionary dictionaryWithObject:textFieldType.text forKey:textFieldType.fieldAPIName];
        return [NSDictionary dictionaryWithObjectsAndKeys:textFieldType.text,Dvalue,textFieldType.fieldAPIName,DapiName,nil];
    }
    if([control_Type isKindOfClass:[cusTextFieldAlpha class]])
    {
        cusTextFieldAlpha * string_type;
        string_type = (cusTextFieldAlpha *) control_Type;
        return [NSDictionary dictionaryWithObjectsAndKeys:string_type.text,Dvalue,string_type.fieldAPIName,DapiName,nil];
        //return [NSDictionary dictionaryWithObject:string_type.text forKey:string_type.text];
    }
    if([control_Type isKindOfClass:[CusDateTextField class]])
    {
        CusDateTextField * date ;
        date = (CusDateTextField *) control_Type;
        if (date.text == nil)
            date.text = @"";
        NSString * value = date.text;
        return [NSDictionary dictionaryWithObjectsAndKeys:value,Dvalue,date.fieldAPIName,DapiName,date.control_type,Dcontrol_type,nil];
        //return [NSDictionary dictionaryWithObject:date.text forKey:date.fieldAPIName];
    }
    if([control_Type isKindOfClass:[LookupField class]])
    {
        LookupField * lookup_type;
        lookup_type = (LookupField *)control_Type;
        NSString * test = lookup_type.control_type;
        if(lookup_type.idValue == nil)
        {
             if(lookup_type.first_idValue == nil)
             {
                lookup_type.idValue =  @"";
             }
            else
            {
                lookup_type.idValue =  lookup_type.first_idValue;
                
            }
        }
        
        return [NSDictionary dictionaryWithObjectsAndKeys:lookup_type.text,Dvalue,lookup_type.fieldAPIName,DapiName,lookup_type.idValue,Didtype,test,Dcontrol_type, nil];
    }
    if([control_Type isKindOfClass:[CtextFieldWithDatePicker class]])
    {
        CtextFieldWithDatePicker *dateTime;
        dateTime = (CtextFieldWithDatePicker *) control_Type;
        if (dateTime.text == nil)
        {
            dateTime.text = @"";
        }
        //sahana Aug 16th
        NSString * dateTimeValue = dateTime.text ;
        return [NSDictionary dictionaryWithObjectsAndKeys:dateTimeValue,Dvalue,dateTime.fieldAPIName,DapiName,dateTime.control_type,Dcontrol_type,nil];
    }
    if([control_Type isKindOfClass:[BotSpinnerTextField class]])
    {
        BotSpinnerTextField * picklist;
        picklist = (BotSpinnerTextField *)control_Type;
        return [NSDictionary dictionaryWithObjectsAndKeys:picklist.text,Dvalue,picklist.fieldAPIName,DapiName,picklist.control_type,Dcontrol_type, nil];
    }
    //Radha and sahana 9th Aug 2011
    if([control_Type isKindOfClass:[BMPTextView class]])
    {
        BMPTextView * Mppicklist;
        Mppicklist = (BMPTextView *)control_Type;
        return [NSDictionary dictionaryWithObjectsAndKeys:Mppicklist.text,Dvalue,Mppicklist.fieldAPIName,DapiName,Mppicklist.control_type,Dcontrol_type, nil];

    }
    return nil;
}

#pragma mark - accessoryTapped: Method
- (void) accessoryTapped:(id)sender
{
    if(appDelegate.isWorkinginOffline)
    {
       
        [activity startAnimating];
        
        // Create new line item with default values
        UIControl * control = (UIControl *)sender;
        NSInteger section = control.tag;
        NSMutableArray * details = [appDelegate.SFMPage objectForKey:@"details"];
        NSMutableArray * detailFieldsArray = [[details objectAtIndex:section] objectForKey:gDETAILS_FIELDS_ARRAY];
        NSString * layout_id = [[details objectAtIndex:section] objectForKey:gDETAILS_LAYOUT_ID];
        NSString * process_id = currentProcessId;
        
        
        NSMutableDictionary * detail = [details objectAtIndex:section];
        NSMutableArray * detail_values = [detail objectForKey:gDETAILS_VALUES_ARRAY];
        NSMutableArray * detail_Values_id = [detail objectForKey:gDETAIL_VALUES_RECORD_ID];
        NSMutableArray * detail_sobject = [detail objectForKey:gDETAIL_SOBJECT_ARRAY];
        NSString * detailObjectName = [detail objectForKey:gDETAIL_OBJECT_NAME];
        
        NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGETCHILD process_id:process_id layoutId:layout_id objectName:detailObjectName];
        
        NSMutableDictionary * object_mapping_dict = [appDelegate.databaseInterface getObjectMappingForMappingId:process_components mappingType:VALUE_MAPPING];
        
        NSArray * all_Keys_values = [object_mapping_dict allKeys];
        

        NSMutableArray * detailValue = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        for (int i = 0; i < [detailFieldsArray count]; i++)
        {
            NSString * value = @"";
            NSString * key = @"";
            //NSString * label ;
            NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                                     gVALUE_FIELD_API_NAME,
                                     gVALUE_FIELD_VALUE_KEY,
                                     gVALUE_FIELD_VALUE_VALUE,
                                     nil];
            NSMutableDictionary * field = [detailFieldsArray objectAtIndex:i];
            NSString * field_api_name = [field objectForKey:gFIELD_API_NAME];
            
            for(int j = 0 ; j < [all_Keys_values count];j++)
            {
                NSString * field_api = [all_Keys_values  objectAtIndex:j];
                if([field_api isEqualToString:field_api_name])
                {
                    key = [object_mapping_dict objectForKey:field_api];
                    
                    NSString * filedDataType = [appDelegate.databaseInterface getFieldDataType:detailObjectName filedName:field_api_name];
                    
                    
                    if([filedDataType isEqualToString:@"picklist"])
                    {
                        //query to acces the picklist values for lines 
                        NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:field_api_name tableName:SFPicklist objectName:detailObjectName];
                        NSArray * allKeys = [picklistValues allKeys];
                        for(NSString * value_dict in allKeys)
                        {
                            if([value_dict isEqualToString:key])
                            {
                                value =[picklistValues objectForKey:key];
                                break;
                            }
                        }
                    }
                    
                    //Radha
                    else if([filedDataType isEqualToString:@"reference"] && (![field_api_name isEqualToString:@"RecordTypeId"]))
                    {
                        if([key isEqualToString:@""] || key == nil || [key length] == 0 )
                        {
                            value = key;
                            
                        }
                        else
                        {
                            NSMutableArray * referenceTotableNames = [appDelegate.databaseInterface getReferenceToForField:field_api_name objectapiName:detailObjectName tableName:SF_REFERENCE_TO];
                                                        
                            if([referenceTotableNames count ] > 0)
                            {
                                NSString * reference_to_tableName = [referenceTotableNames objectAtIndex:0];
                                
                                NSString * referenceTo_Table_fieldName = [appDelegate.databaseInterface getFieldNameForReferenceTable:reference_to_tableName tableName:SFOBJECTFIELD];
                                
                                
                                value = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:reference_to_tableName field_name:referenceTo_Table_fieldName record_id:key];
                                
                            }
                            if([value isEqualToString:@"" ]||[value isEqualToString:@" "] || value == nil)
                            {
                                value = [appDelegate.databaseInterface getLookUpNameForId:key];
                                if([value isEqualToString:@"" ]||[value isEqualToString:@" "] || value == nil)
                                {
                                    value = key;
                                }
                            }
                            

                            
                        }
                        
                    }
                    
                    
                    else if([filedDataType isEqualToString:@"reference"] && [field_api_name isEqualToString:@"RecordTypeId"])
                    {
                        if([key isEqualToString:@""] || key == nil || [key length] == 0 )
                        {
                            value = key;
                            
                        }
                        else
                        {
                            NSMutableArray * referenceTotableNames = [appDelegate.databaseInterface getReferenceToForField:field_api_name objectapiName:detailObjectName tableName:SF_REFERENCE_TO];
                            
                            if([referenceTotableNames count ] > 0)
                            {
                                NSString * reference_to_tableName = [referenceTotableNames objectAtIndex:0];
                                
                                NSString * referenceTo_Table_fieldName = [appDelegate.databaseInterface getFieldNameForReferenceTable:reference_to_tableName tableName:SFOBJECTFIELD];
                                

                                value = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:reference_to_tableName field_name:referenceTo_Table_fieldName record_id:key];
                                if([value isEqualToString:@"" ]||[value isEqualToString:@" "] || value == nil)
                                {
                                    value = [appDelegate.dataBase getValueForRecordtypeId:key object_api_name:detailObjectName];
                                }
                                
                                

                                
                            }
                            if([value isEqualToString:@"" ]||[value isEqualToString:@" "] || value == nil)
                            {
                                value = [appDelegate.databaseInterface getLookUpNameForId:key];
                                if([value isEqualToString:@"" ]||[value isEqualToString:@" "] || value == nil)
                                {
                                    value = key;
                                }
                            }
                            
                            
                            
                        }
                        
                    }

                    
                    else if([filedDataType isEqualToString:@"datetime"])
                    {
                        NSString * date = key;
                        date = [date stringByDeletingPathExtension];
                        value = date;
                        key = date;
                    }
                    else if([filedDataType isEqualToString:@"date"])
                    {
                        NSString * date = key;
                        date = [date stringByDeletingPathExtension];
                        value = date;
                        key = date;
                    }
                    else if([filedDataType isEqualToString:@"multipicklist"])
                    {
                        NSArray * valuearray = [key componentsSeparatedByString:@";"];
                        NSMutableArray * labelArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                        //query to acces the picklist values for lines 
                        NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:field_api_name tableName:SFPicklist objectName:detailObjectName];
                        
                        NSArray * allKeys = [picklistValues allKeys];
                        for(NSString * value_dict in allKeys)
                        {
                            for(NSString * key  in valuearray)
                            {
                                if([value_dict isEqualToString:key])
                                {
                                    [labelArray addObject:[picklistValues objectForKey:key]];
                                    break;
                                }
                            }
                        }
                        
                        NSInteger count_ = 0;
                        for(NSString * each_label in labelArray)
                        {
                            if(count_ != 0)
                                value = [value stringByAppendingString:@";"];
                            
                            value = [value stringByAppendingString:each_label];
                            count_++;
                        }
                        
                    }
                    else
                    {
                        value = key;
                    }

                }
                
            }
            
            NSMutableArray * objects = [NSMutableArray arrayWithObjects:field_api_name, key, value, nil];
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
            [detailValue addObject:dict];
        }
        
        //sahana 20th August 2011
        NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                                 gVALUE_FIELD_API_NAME,
                                 gVALUE_FIELD_VALUE_KEY,
                                 gVALUE_FIELD_VALUE_VALUE,
                                 nil];
        NSMutableArray * objects = [NSMutableArray arrayWithObjects:gDETAIL_SAVED_RECORD,[NSNumber numberWithInt:0],[NSNumber numberWithInt:0], nil];
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
        [detailValue addObject:dict];
        //ends

        [activity stopAnimating];
        NSIndexPath * indexPath = nil;
        if (selectedSection == SHOWALL_LINES)
        {
            indexPath = [NSIndexPath indexPathForRow:[detail_values count]+1 inSection:section];
        }
        if(selectedSection == SHOW_LINES_ROW)
        {
            indexPath = [NSIndexPath indexPathForRow:[detail_values count]+1 inSection:0];
        }
        
        [detail_values addObject:detailValue];
        [detail_Values_id addObject:@""];
        //sahana 9th sept 2011
        [detail_sobject addObject:@""];
        
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // Automatically navigate to the detail edit screen
        
        NSInteger index;
        NSInteger _section1 = indexPath.section;
        
        if (isDefault)
            index = _section1;
        else
            index = selectedRow;
        
        NSIndexPath  *_indexPath = nil;
        if (selectedSection == SHOWALL_LINES)
        {
            _indexPath = indexPath;
        }
        if(selectedSection == SHOW_LINES_ROW)
        {
            _indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:index];
        }
        
        
        Disclosure_dict = nil;
        Disclosure_Details = nil;
        [self fillDictionary:_indexPath];
        detailViewObject = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
        self.navigationController.delegate = self;
        detailViewObject.parentReference = self;
        detailViewObject.selectedIndexPath = _indexPath;
        detailViewObject.selectedRowForDetailEdit = _indexPath.row-1;
        detailViewObject.isInEditDetail = YES;
        detailViewObject.isInViewMode = isInViewMode;
        detailViewObject.header = self.header;
        detailViewObject.line = self.line;
        detailViewObject.Disclosure_dict = self.Disclosure_dict;
        detailViewObject.Disclosure_Fields = self.Disclosure_Fields;
        detailViewObject.Disclosure_Details = self.Disclosure_Details;
        detailViewObject.showSyncUI = self.showSyncUI;
        //sahana navigation custom butto
        detailViewObject.navigationItem.leftBarButtonItem = nil;
        [detailViewObject.navigationItem setHidesBackButton:YES animated:YES];
        
        // ################ BACK BUTTON HERE ################# //
        UIButton * backButton = [[[UIButton alloc] initWithFrame:CGRectZero] autorelease];
        [backButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Back-Arrow-Button"] forState:UIControlStateNormal];
        [backButton addTarget:detailViewObject action:@selector(PopNavigationController:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[backButton sizeToFit];
        UIBarButtonItem * backBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
        detailViewObject.navigationItem.leftBarButtonItem = backBarButtonItem;
        // ################################################### //
        
        //Radha 20th august 2011
        UIButton * actionButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [actionButton setBackgroundImage:[UIImage imageNamed:@"iService-Screen-Help.png"] forState:UIControlStateNormal];
		[actionButton sizeToFit];
        [actionButton addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * helpBarButton = [[UIBarButtonItem alloc] initWithCustomView:actionButton];  
        
        NSMutableArray * buttons = [[NSMutableArray alloc] initWithCapacity:0];
        showSyncUI=YES;
        //[appDelegate setSyncStatus:appDelegate.SyncStatus];
        
        UIBarButtonItem * syncBarButton = [[UIBarButtonItem alloc] initWithCustomView:appDelegate.animatedImageView];
        [buttons addObject:syncBarButton];
        [syncBarButton setTarget:self];
        //sahana offline
        UIToolbar * toolBar;
        // adding the done button
        // ################ DONE BUTTON HERE ################# //
        if(isInViewMode)
        {
			UIButton * doneButton = [[[UIButton alloc] initWithFrame:CGRectZero] autorelease];
            [doneButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Done-Back-Button.png"] forState:UIControlStateNormal];
            [doneButton addTarget:detailViewObject action:@selector(lineseditingDone) forControlEvents:UIControlEventTouchUpInside];
            [doneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
			[doneButton sizeToFit];
            NSString * done = [appDelegate.wsInterface.tagsDictionary objectForKey:DONE_BUTTON_TITLE];
            
            [doneButton setTitle:done forState:UIControlStateNormal];
            [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            UIBarButtonItem * doneBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
//            [actionButton release];
            [buttons addObject:doneBarButtonItem];
            [doneBarButtonItem release];
			
            toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 190, 44)] autorelease];
			 //toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, actionButton.frame.size.width + syncBarButton.width + doneButton.frame.size.width, 44)] autorelease];
        }
        // ################################################### //
        else
		{
            toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, actionButton.frame.size.width + syncBarButton.width, 44)] autorelease];
		}
        [buttons addObject:helpBarButton];
        [toolBar setItems:buttons];
        [helpBarButton release];
        [actionButton release];
        [syncBarButton release];
        [buttons release];
        
		SMLog(@"%@", CGRectCreateDictionaryRepresentation(self.navigationController.navigationBar.frame));
		detailViewObject.navigationController.navigationBar.frame = self.navigationController.navigationBar.frame;
        detailViewObject.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBar] autorelease];
        showSyncUI=YES;
        [self.navigationController pushViewController:detailViewObject animated:YES];
		if (appDelegate.sfmPageController.conflictExists)
		{
			NSMutableString *Confilct= [appDelegate isConflictInEvent:[appDelegate.dataBase getApiNameFromFieldLabel: appDelegate.sfmPageController.objectName] local_id:appDelegate.sfmPageController.recordId];
			
			if([Confilct length]>0)
			{
				[self moveTableViewforDisplayingConflict:Confilct];
			}
		}
        [self enableSFMUI];
        
    }
    else
    {
        
    
        //Special handling only for accessory tap
        didRunOperation = NO;
        //[self disableSFMUI];
        [activity startAnimating];
        // Create new line item with default values
        UIControl * control = (UIControl *)sender;
        NSInteger section = control.tag;
        NSMutableArray * details = [appDelegate.SFMPage objectForKey:@"details"];
        NSMutableArray * detailFieldsArray = [[details objectAtIndex:section] objectForKey:gDETAILS_FIELDS_ARRAY];
        NSString * layout_id = [[details objectAtIndex:section] objectForKey:gDETAILS_LAYOUT_ID];
        
        //calling the web service to add the rows to 
        NSString * process_id = currentProcessId;
        
        WSInterface * wsinterface = [[WSInterface alloc] init];
        wsinterface.delegate = self;
        wsinterface.add_WS = FALSE;
        [wsinterface  AddRecordForLines:process_id ForDetailLayoutId:layout_id];

       while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
            SMLog(@"accessoryTapped in while loop");
            if(appDelegate.isWorkinginOffline)
            {
                
            }
            else
            {
                if (![appDelegate isInternetConnectionAvailable])
                {
                    [activity stopAnimating];
                    //[appDelegate displayNoInternetAvailable];
                    [self enableSFMUI];
                    return;
                }
            }
            if(wsinterface.add_WS == YES)
            {
                break;
            }
            if (appDelegate.connection_error)
            {
                break;
            }
        }
        
        NSMutableDictionary * insert_items = wsinterface.detail_addRecordItems;
        NSArray * insert_keys = nil;
        if([insert_items  count]!= 0)
           insert_keys = [insert_items allKeys];
        
        NSMutableDictionary * detail = [details objectAtIndex:section];
        NSMutableArray * detail_values = [detail objectForKey:gDETAILS_VALUES_ARRAY];
        NSMutableArray * detail_Values_id = [detail objectForKey:gDETAIL_VALUES_RECORD_ID];
        //sahana 9th sept 2011
        NSMutableArray * detail_sobject = [detail objectForKey:gDETAIL_SOBJECT_ARRAY];
        // [detail_values removeObjectAtIndex:indexPath.row-1];
        
        NSMutableArray * detailValue = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        for (int i = 0; i < [detailFieldsArray count]; i++)
        {
            NSString * value = @"";
            NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                                    gVALUE_FIELD_API_NAME,
                                    gVALUE_FIELD_VALUE_KEY,
                                    gVALUE_FIELD_VALUE_VALUE,
                                    nil];
            NSMutableDictionary * field = [detailFieldsArray objectAtIndex:i];
            NSString * field_api_name = [field objectForKey:gFIELD_API_NAME];
            if(insert_keys  != nil)
            {
                for(int j = 0 ; j< [insert_keys count];j++)
                {
                    NSString * api_key = [insert_keys objectAtIndex:j];
                   if([api_key isEqualToString:field_api_name] )
                   {
                       value = [insert_items objectForKey:api_key];
                       break;
                   }
                }
            }
            
            NSMutableArray * objects = [NSMutableArray arrayWithObjects:[field objectForKey:gFIELD_API_NAME], value, value, nil];
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
            [detailValue addObject:dict];
        }
        
        if(insert_keys  != nil)
        {
            for(int j = 0 ;j<[insert_keys count]; j++)
            {
                NSString * api_name = [insert_keys objectAtIndex:j];
                NSInteger count1 = 0;
                for(int k=0; k < [detailValue count];k++)
                {
                     NSString  * field_api_name = [[detailValue objectAtIndex:k] objectForKey:gVALUE_FIELD_API_NAME];
                    if([api_name isEqualToString:field_api_name])
                    {
                        
                    }
                    else
                    {
                        count1++;
                    }
                }
                if(count1 == [detailValue count])
                {
                    NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                                             gVALUE_FIELD_API_NAME,
                                             gVALUE_FIELD_VALUE_KEY,
                                             gVALUE_FIELD_VALUE_VALUE,
                                             nil];
                    NSMutableArray * objects = [NSMutableArray arrayWithObjects:api_name, [insert_items objectForKey:api_name],[insert_items objectForKey:api_name], nil];
                    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
                    [detailValue addObject:dict];
                }
            }
        }
        
        //sahana 20th August 2011
        NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                                 gVALUE_FIELD_API_NAME,
                                 gVALUE_FIELD_VALUE_KEY,
                                 gVALUE_FIELD_VALUE_VALUE,
                                 nil];
        NSMutableArray * objects = [NSMutableArray arrayWithObjects:gDETAIL_SAVED_RECORD,[NSNumber numberWithInt:0],[NSNumber numberWithInt:0], nil];
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
        [detailValue addObject:dict];
        
        //ends
        
        [activity stopAnimating];
        NSIndexPath * indexPath = nil;
        if (selectedSection == SHOWALL_LINES)
        {
            indexPath = [NSIndexPath indexPathForRow:[detail_values count]+1 inSection:section];
        }
        if(selectedSection == SHOW_LINES_ROW)
        {
            indexPath = [NSIndexPath indexPathForRow:[detail_values count]+1 inSection:0];
        }
            
        [detail_values addObject:detailValue];
        [detail_Values_id addObject:@""];
        //sahana 9th sept 2011
        [detail_sobject addObject:@""];
        
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // Automatically navigate to the detail edit screen
        
        NSInteger index;
        NSInteger _section1 = indexPath.section;
        
        if (isDefault)
            index = _section1;
        else
            index = selectedRow;
        
        NSIndexPath  *_indexPath = nil;
        if (selectedSection == SHOWALL_LINES)
        {
            _indexPath = indexPath;
        }
        if(selectedSection == SHOW_LINES_ROW)
        {
            _indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:index];
        }

    [wsinterface release];
    Disclosure_dict = nil;
    Disclosure_Details = nil;
    [self fillDictionary:_indexPath];
    detailViewObject = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
    self.navigationController.delegate = self;
    detailViewObject.selectedIndexPath = _indexPath;
    detailViewObject.selectedRowForDetailEdit = _indexPath.row-1;
    detailViewObject.isInEditDetail = YES;
    detailViewObject.isInViewMode = isInViewMode;
    detailViewObject.header = self.header;
    detailViewObject.line = self.line;
    detailViewObject.Disclosure_dict = self.Disclosure_dict;
    detailViewObject.Disclosure_Fields = self.Disclosure_Fields;
    detailViewObject.Disclosure_Details = self.Disclosure_Details;
    
    
    //sahana navigation custom button
    detailViewObject.navigationItem.leftBarButtonItem = nil;
    [detailViewObject.navigationItem setHidesBackButton:YES animated:YES];
    
    // ################ BACK BUTTON HERE ################# //
    UIButton * backButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 35)] autorelease];
    [backButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Back-Arrow-Button"] forState:UIControlStateNormal];
    [backButton addTarget:detailViewObject action:@selector(PopNavigationController:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem * backBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    detailViewObject.navigationItem.leftBarButtonItem = backBarButtonItem;
    // ################################################### //

        //Radha 20th august 2011
        UIButton * actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 35)];
        [actionButton setBackgroundImage:[UIImage imageNamed:@"iService-Screen-Help.png"] forState:UIControlStateNormal];
        [actionButton addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * helpBarButton = [[UIBarButtonItem alloc] initWithCustomView:actionButton];  
        
        NSMutableArray * buttons = [[NSMutableArray alloc] initWithCapacity:0];
        //[appDelegate setSyncStatus:appDelegate.SyncStatus];
        showSyncUI=YES;

        UIBarButtonItem * syncBarButton = [[UIBarButtonItem alloc] initWithCustomView:appDelegate.animatedImageView];
        [buttons addObject:syncBarButton];
        [syncBarButton setTarget:self];
        //sahana offline
        UIToolbar * toolBar;
        // adding the done button
        // ################ DONE BUTTON HERE ################# //
        if(isInViewMode)
        {
			UIButton * doneButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 67, 31)] autorelease];
            [actionButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Done-Back-Button.png"] forState:UIControlStateNormal];
            [actionButton addTarget:detailViewObject action:@selector(lineseditingDone) forControlEvents:UIControlEventTouchUpInside];
            [actionButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
            NSString * done = [appDelegate.wsInterface.tagsDictionary objectForKey:DONE_BUTTON_TITLE];
            
            [actionButton setTitle:done forState:UIControlStateNormal];
            [actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            UIBarButtonItem * doneBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
            //[actionButton release];
            [buttons addObject:doneBarButtonItem];
            [doneBarButtonItem release];
            toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 200, 44)] autorelease];
        }
        // ################################################### //
        else
            toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 44)] autorelease];
        [buttons addObject:helpBarButton];
        [toolBar setItems:buttons];
        [syncBarButton release];
        [actionButton release];
        [helpBarButton release];
        [buttons release];
        
        detailViewObject.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBar] autorelease];
        
        
        if (![appDelegate isInternetConnectionAvailable])
        {
            if (appDelegate.SFMPage != nil)
            {
                //[appDelegate.SFMPage release];
                //appDelegate.SFMPage = nil;
                
                [self.tableView reloadData];
                [appDelegate.sfmPageController.rootView refreshTable];
            }
            
            [activity stopAnimating];
            //[appDelegate displayNoInternetAvailable];
            [self enableSFMUI];
            return;
        }
       showSyncUI=YES;
        [self.navigationController pushViewController:detailViewObject animated:YES];
        [detailViewObject release];
        
        [self enableSFMUI];
    
    }
    
}


#pragma mark- multiAccessoryTapped:Method
- (IBAction) multiAccessoryTapped:(id)sender
{
    if(appDelegate.isWorkinginOffline)
    {
        
    }
    else
    {
        
    }

    control = (UIControl *)sender;
    NSInteger  _section = control.tag;
    SMLog(@"buttonclicked");
    NSMutableArray * details = [appDelegate.SFMPage objectForKey:gDETAILS];
    
    NSString * multiadd_search_filed = [[details objectAtIndex:_section] objectForKey:gDETAIL_MULTIADD_SEARCH];
    NSString * multiadd_seach_object = [[details objectAtIndex:_section] objectForKey:gDETAIL_MULTIADD_SEARCH_OBJECT];
//    NSString * mutlti_add_config = [[details objectAtIndex:_section] objectForKey:gDETAIL_MULTIADD_SEARCH_OBJECT];
    NSMutableArray * detailFieldsArray = [[details objectAtIndex:_section] objectForKey:gDETAILS_FIELDS_ARRAY];
    NSString * multiadd_label = nil;
    for(int i= 0;i<[detailFieldsArray count]; i++)
    {
        NSDictionary * dict = [detailFieldsArray objectAtIndex:i];
        NSString * field_api_name = [dict objectForKey:gFIELD_API_NAME];
        if([field_api_name isEqualToString: multiadd_search_filed] )
        { 
            multiadd_label = [dict objectForKey:gFIELD_LABEL];
            break;
        }
    }
    
    multiAddLookup = [[MultiAddLookupView alloc] initWithNibName:@"MultiAddLookupView" bundle:nil];
    objectName = multiadd_seach_object;
    multiAddLookup.objectName = multiadd_seach_object;
    multiAddLookup.search_field = multiadd_search_filed;
    multiAddLookup.index = _section;
    multiAddLookup.delegate = self;
    NSString * searchBarTitle = nil;
    
    
    // Obtain Search Bar Title from gFIELD_RELATED_OBJECT_NAME in Describe
    if(appDelegate.isWorkinginOffline)
    {
        NSString * searchBarTitle =  [appDelegate.databaseInterface getObjectLabel:SFOBJECT objectApi_name:objectName];
        
        if([searchBarTitle isEqualToString:mutlti_add_label])
        {
            NSString * search = [NSString stringWithFormat:@"%@ ", searchBarTitle];
            search = [search  stringByAppendingString:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_LOOKUP_SEARCH]];
            multiAddLookup.title = search;
        }
        else
        {
            // Append a space to the searchBarTitle
            NSString * title = [NSString stringWithFormat:@"%@ ", searchBarTitle];
            // Append the remaining searchBarTag
            title = [title stringByAppendingString:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_LOOKUP_SEARCH_FOR]];
            if(multiadd_label != nil)
                title = [title stringByAppendingString:[NSString stringWithFormat:@" %@", multiadd_label]];
            multiAddLookup.title = title;
        }
    }
    else
    {
        appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
        for (int i = 0; i < [appDelegate.describeObjectsArray count]; i++)
        {
            ZKDescribeSObject * descObj = [appDelegate.describeObjectsArray objectAtIndex:i];
            if ([[descObj name] isEqualToString:objectName])
                searchBarTitle = [NSString stringWithFormat:@"%@", [descObj label]];
        }
        
        if([searchBarTitle isEqualToString:mutlti_add_label])
        {
            NSString * search = [NSString stringWithFormat:@"%@ ", searchBarTitle];
            search = [search  stringByAppendingString:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_LOOKUP_SEARCH]];
            multiAddLookup.title = search;
        }
        else
        {
            // Append a space to the searchBarTitle
            NSString * title = [NSString stringWithFormat:@"%@ ", searchBarTitle];
            // Append the remaining searchBarTag
            title = [title stringByAppendingString:[appDelegate.wsInterface.tagsDictionary objectForKey:SFM_LOOKUP_SEARCH_FOR]];
            if(multiadd_label != nil)
                title = [title stringByAppendingString:[NSString stringWithFormat:@" %@", multiadd_label]];
            multiAddLookup.title = title;
        }
    }
    UINavigationController * navController = [[[UINavigationController alloc] initWithRootViewController:multiAddLookup] autorelease];
    
    
    [multiAddLookup.searchBar becomeFirstResponder];
    multiLookupPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
    
    multiLookupPopover.delegate = self;
    multiAddLookup.popOver = multiLookupPopover;
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        [multiLookupPopover presentPopoverFromRect:CGRectMake(5, 10, 10, 10) inView:control permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//        [multiLookupPopover release];
    }
    else
    {
        [multiLookupPopover presentPopoverFromRect:CGRectMake(5, 0, 10, 20) inView:control permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//        [multiLookupPopover release];
    }
}

#pragma mark - MultiLookUpView Delegate Method
- (void) addMultiChildRows:(NSMutableDictionary *)_array forIndex:(NSInteger)index  
{
    SMLog(@"%@", appDelegate.SFMPage);
    multiLookArray = _array;
    SMLog(@"%@", multiLookArray);
    multiAddFlag  = 1;
    [multiLookupPopover dismissPopoverAnimated:YES];
    
    NSMutableArray * details = [appDelegate.SFMPage objectForKey:gDETAILS];
                                    
    NSString * multiadd_search_filed = [[details objectAtIndex:index] objectForKey:gDETAIL_MULTIADD_SEARCH];

    [activity startAnimating];
   
    NSMutableArray * detailFieldsArray = [[details objectAtIndex:index] objectForKey:gDETAILS_FIELDS_ARRAY];
    NSString * layout_id = [[details objectAtIndex:index] objectForKey:gDETAILS_LAYOUT_ID];

    //calling the web service to add the rows to 
    NSString * process_id = currentProcessId;
     NSArray * multi_add_result = nil;
    if([multiLookArray count] != 0)
        multi_add_result = [multiLookArray allKeys];
    if(appDelegate.isWorkinginOffline)
    {
        for(int p= 0; p<[_array count];p++)
        {
            NSMutableDictionary * detail = [details objectAtIndex:index];
            NSMutableArray * detail_values = [detail objectForKey:gDETAILS_VALUES_ARRAY];
            NSMutableArray * detail_Values_id = [detail objectForKey:gDETAIL_VALUES_RECORD_ID];
            NSMutableArray * detail_sobject = [detail objectForKey:gDETAIL_SOBJECT_ARRAY];
            NSString * detailObjectName = [detail objectForKey:gDETAIL_OBJECT_NAME];
            
            NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGETCHILD process_id:process_id layoutId:layout_id objectName:detailObjectName];
            //[appDelegate.databaseInterface  getValueMappingForlayoutId:layout_id process_id:process_id objectName:detailObjectName];
            
            NSMutableDictionary * object_mapping_dict = [appDelegate.databaseInterface getObjectMappingForMappingId:process_components mappingType:VALUE_MAPPING];
            
            NSArray * all_Keys_values = [object_mapping_dict allKeys];
            
            
            NSMutableArray * detailValue = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
            for (int i = 0; i < [detailFieldsArray count]; i++)
            {
                NSString * value = @"";
                NSString * key = @"";
                //NSString * label ;
                NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                                         gVALUE_FIELD_API_NAME,
                                         gVALUE_FIELD_VALUE_KEY,
                                         gVALUE_FIELD_VALUE_VALUE,
                                         nil];
                NSMutableDictionary * field = [detailFieldsArray objectAtIndex:i];
                NSString * field_api_name = [field objectForKey:gFIELD_API_NAME];
                
                for(int j = 0 ; j < [all_Keys_values count];j++)
                {
                    NSString * field_api = [all_Keys_values  objectAtIndex:j];
                    if([field_api isEqualToString:field_api_name])
                    {
                        key = [object_mapping_dict objectForKey:field_api];
                        
                        NSString * filedDataType = [appDelegate.databaseInterface getFieldDataType:detailObjectName filedName:field_api_name];
                        
                        
                        if([filedDataType isEqualToString:@"picklist"])
                        {
                            //query to acces the picklist values for lines 
                            NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:field_api_name tableName:SFPicklist objectName:detailObjectName];
                            NSArray * allKeys = [picklistValues allKeys];
                            for(NSString * value_dict in allKeys)
                            {
                                if([value_dict isEqualToString:key])
                                {
                                    value =[picklistValues objectForKey:key];
                                    break;
                                }
                            }
                        }
                        else if([filedDataType isEqualToString:@"reference"])
                        {
                            if([key isEqualToString:@""] || key == nil || [key length] == 0 )
                            {
                                value = key;
                                
                            }
                            else
                            {
                                NSMutableArray * referenceTotableNames = [appDelegate.databaseInterface getReferenceToForField:field_api_name objectapiName:detailObjectName tableName:SF_REFERENCE_TO];
                                if([referenceTotableNames count ] > 0)
                                {
                                    NSString * reference_to_tableName = [referenceTotableNames objectAtIndex:0];
                                    
                                    NSString * referenceTo_Table_fieldName = [appDelegate.databaseInterface getFieldNameForReferenceTable:reference_to_tableName tableName:SFOBJECTFIELD];
                                    
                                    value = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:reference_to_tableName field_name:referenceTo_Table_fieldName record_id:key];
                                    
                                }
                                if([value isEqualToString:@"" ]||[value isEqualToString:@" "] || value == nil)
                                {
                                    value = [appDelegate.databaseInterface getLookUpNameForId:key];
                                    if([value isEqualToString:@"" ]||[value isEqualToString:@" "] || value == nil)
                                    {
                                        value = key;
                                    }
                                }
                                break;
                            }
                            
                        }
                        
                        else if([filedDataType isEqualToString:@"datetime"])
                        {
                            NSString * date = key;
                            date = [date stringByDeletingPathExtension];
                            value = date;
                            key = date;
                        }
                        else if([filedDataType isEqualToString:@"date"])
                        {
                            NSString * date = key;
                            date = [date stringByDeletingPathExtension];
                            value = date;
                            key = date;
                        }
                        else if([filedDataType isEqualToString:@"multipicklist"])
                        {
                            NSArray * valuearray = [key componentsSeparatedByString:@";"];
                            NSMutableArray * labelArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                            //query to acces the picklist values for lines 
                            NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:field_api_name tableName:SFPicklist objectName:detailObjectName];
                            
                            NSArray * allKeys = [picklistValues allKeys];
                            for(NSString * value_dict in allKeys)
                            {
                                for(NSString * key  in valuearray)
                                {
                                    if([value_dict isEqualToString:key])
                                    {
                                        [labelArray addObject:[picklistValues objectForKey:key]];
                                        break;
                                    }
                                }
                            }
                            
                            NSInteger count_ = 0;
                            for(NSString * each_label in labelArray)
                            {
                                if(count_ != 0)
                                    value = [value stringByAppendingString:@";"];
                                
                                value = [value stringByAppendingString:each_label];
                                count_++;
                            }
                            
                        }
                        else
                        {
                            value = key;
                        }
                        
                    }
                                       
                }
                //to match multi add 
                if( [field_api_name isEqualToString:multiadd_search_filed])
                {
                    value = [_array  objectForKey:[multi_add_result objectAtIndex:p]];
                    key = [multi_add_result objectAtIndex:p];
                }
                

                NSMutableArray * objects = [NSMutableArray arrayWithObjects:field_api_name, key, value, nil];
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
                [detailValue addObject:dict];
            }
            
            //sahana 20th August 2011
            NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                                     gVALUE_FIELD_API_NAME,
                                     gVALUE_FIELD_VALUE_KEY,
                                     gVALUE_FIELD_VALUE_VALUE,
                                     nil];
            NSMutableArray * objects = [NSMutableArray arrayWithObjects:gDETAIL_SAVED_RECORD,[NSNumber numberWithInt:1],[NSNumber numberWithInt:1], nil];
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
            [detailValue addObject:dict];
            //ends

            NSIndexPath * indexPath = nil;
            if (selectedSection == SHOWALL_LINES)
            {
                indexPath = [NSIndexPath indexPathForRow:[detail_values count]+1 inSection:index];
            }
            if(selectedSection == SHOW_LINES_ROW)
            {
                indexPath = [NSIndexPath indexPathForRow:[detail_values count]+1 inSection:0];
            }
            
            [detail_values addObject:detailValue];
            [detail_Values_id addObject:@""];
            //sahana 9th sept 2011
            [detail_sobject addObject:@""];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];    
        }
        
    }
    else
    {
        for(int i= 0; i<[_array count];i++)
        {
            WSInterface * wsinterface = [[WSInterface alloc] init];
            wsinterface.delegate = self;
            wsinterface.add_WS = FALSE;
            [wsinterface  AddRecordForLines:process_id ForDetailLayoutId:layout_id];
            
           while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
            {
                SMLog(@"addMultiChildRows in while loop");
                if(appDelegate.isWorkinginOffline)
                {
                    
                }
                else
                {
                    
                }
                if(wsinterface.add_WS == TRUE)
                {
                    break;
                }
                if (appDelegate.connection_error)
                {
                    break;
                }
            }
            
            NSMutableDictionary * insert_items = wsinterface.detail_addRecordItems;
            [wsinterface release];
            NSArray * insert_keys = nil;
            
            if([insert_items  count]!= 0)
                insert_keys = [insert_items allKeys];
            
            NSMutableDictionary * detail = [details objectAtIndex:index];
            NSMutableArray * detail_values = [detail objectForKey:gDETAILS_VALUES_ARRAY];
            NSMutableArray * detail_Values_id = [detail objectForKey:gDETAIL_VALUES_RECORD_ID];
            //sahana 9th sept 2011
            NSMutableArray * detail_sobject = [detail objectForKey:gDETAIL_SOBJECT_ARRAY];
            
            NSMutableArray * detailValue = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
            for (int l = 0; l < [detailFieldsArray count]; l++)
            {
                NSString * value = @"";
                NSString * key = @"";
                NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                                         gVALUE_FIELD_API_NAME,
                                         gVALUE_FIELD_VALUE_KEY,
                                         gVALUE_FIELD_VALUE_VALUE,
                                         nil];
                NSMutableDictionary * field = [detailFieldsArray objectAtIndex:l];
                NSString * field_api_name = [field objectForKey:gFIELD_API_NAME];
                if(insert_keys  != nil)
                {
                    for(int j = 0 ; j< [insert_keys count];j++)
                    {
                        NSString * api_key = [insert_keys objectAtIndex:j];
                        if([api_key isEqualToString:field_api_name] )
                        {
                            value = [insert_items objectForKey:api_key];
                            key = [insert_items  objectForKey:api_key];
                            break;
                        }
                        
                        
                    }
                }
                SMLog(@"%@",multi_add_search);
                if( [field_api_name isEqualToString:multiadd_search_filed])
                {
                    value = [_array  objectForKey:[multi_add_result objectAtIndex:i]];
                    key = [multi_add_result objectAtIndex:i];
                }
                
                NSMutableArray * objects = [NSMutableArray arrayWithObjects:[field objectForKey:gFIELD_API_NAME], key, value, nil];
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
                [detailValue addObject:dict];
            }
            if(insert_keys  != nil)
            {
                for(int j = 0 ;j<[insert_keys count]; j++)
                {
                    NSString * api_name = [insert_keys objectAtIndex:j];
                    NSInteger count1 = 0;
                    for(int k=0; k < [detailValue count];k++)
                    {
                        NSString  * field_api_name = [[detailValue objectAtIndex:k] objectForKey:gVALUE_FIELD_API_NAME];
                        if([api_name isEqualToString:field_api_name])
                        {
                            
                        }
                        else
                        {
                            count1++;
                        }
                    }
                    if(count1 == [detailValue count])
                    {
                        NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                                                 gVALUE_FIELD_API_NAME,
                                                 gVALUE_FIELD_VALUE_KEY,
                                                 gVALUE_FIELD_VALUE_VALUE,
                                                 nil];
                        NSMutableArray * objects = [NSMutableArray arrayWithObjects:api_name, [insert_items objectForKey:api_name],[insert_items objectForKey:api_name], nil];
                        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
                        [detailValue addObject:dict];
                    }
                }
            }
            
            //sahana 20th August 2011
            NSMutableArray * keys = [NSMutableArray arrayWithObjects:
                                     gVALUE_FIELD_API_NAME,
                                     gVALUE_FIELD_VALUE_KEY,
                                     gVALUE_FIELD_VALUE_VALUE,
                                     nil];
            NSMutableArray * objects = [NSMutableArray arrayWithObjects:gDETAIL_SAVED_RECORD,[NSNumber numberWithInt:1],[NSNumber numberWithInt:1], nil];
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
            [detailValue addObject:dict];
            
            //ends
            
            NSIndexPath * indexPath = nil;
            if (selectedSection == SHOWALL_LINES)
            {
                indexPath = [NSIndexPath indexPathForRow:[detail_values count]+1 inSection:index];
            }
            if(selectedSection == SHOW_LINES_ROW)
            {
                indexPath = [NSIndexPath indexPathForRow:[detail_values count]+1 inSection:0];
            }
            
            [detail_values addObject:detailValue];
            [detail_Values_id addObject:@""];
            //sahana 9th sept 2011
            [detail_sobject addObject:@""];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];        
        }

    }
    
    [activity stopAnimating];
}
#pragma MultiAddLookupViewDelegate
-(void) dismissMultiaddLookup
{
    [multiLookupPopover dismissPopoverAnimated:YES];
    [self launchBarcodeScanner];
}

#pragma Bar Code
-(void)launchBarcodeScanner
{
    // ADD: present a barcode reader that scans from the camera feed
    reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    if (appDelegate ==nil) 
    {
        appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    [appDelegate.sfmPageController presentViewController: reader
                                                     animated: YES completion:nil];
    [reader release];
    SMLog(@"Launch Bar Code Scanner");

}

- (void) imagePickerController: (UIImagePickerController*) readerController
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =[info objectForKey: ZBarReaderControllerResults];
    SMLog(@"result=%@",results);
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissViewControllerAnimated: YES completion:nil];
    [self performSelector:@selector(DismissBarCodeReader:) withObject:symbol.data afterDelay:0.1f];
}

- (void) DismissBarCodeReader:(NSString *)_text
{
    [self LaunchMultiAddPopover];
    [multiAddLookup updateTxtField:_text];
    SMLog(@"symbol.data=%@",_text);
    [multiAddLookup searchBarcodeResult:_text];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    SMLog(@"Dismissing Barcode Scanner");
    [reader dismissViewControllerAnimated: YES completion:nil];
    [multiAddLookup updateTxtField:@""];
    [self performSelector:@selector(DismissBarCodeReader:) withObject:@"" afterDelay:0.1f];
    [multiAddLookup searchBarcodeResult:@""];
    
}
- (void) readerControllerDidFailToRead:(ZBarReaderController*)barcodeReader withRetry:(BOOL)retry
{
    SMLog(@"Failed to Scan the Barcode");
    [barcodeReader dismissViewControllerAnimated: YES completion:nil];
    [multiAddLookup updateTxtField:@""];
    [self performSelector:@selector(DismissBarCodeReader:) withObject:@"" afterDelay:0.1f];
    [multiAddLookup searchBarcodeResult:@""];
    
}

-(void) LaunchMultiAddPopover
{
    UINavigationController * navController = [[[UINavigationController alloc] initWithRootViewController:multiAddLookup] autorelease];
    [multiAddLookup.view setBackgroundColor:[UIColor clearColor]];
    [multiAddLookup.searchBar becomeFirstResponder];
    multiLookupPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
    multiLookupPopover.delegate = self;
    multiAddLookup.popOver = multiLookupPopover;
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        [multiLookupPopover presentPopoverFromRect:CGRectMake(5, 10, 10, 10) inView:multiControl permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [multiLookupPopover presentPopoverFromRect:CGRectMake(5, 0, 10, 20) inView:multiControl permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

} 

#pragma  mark - tableView delegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    NSInteger index;
    NSInteger section = indexPath.section;
    if (isDefault)
        index = section;
    else
        index = selectedRow;
    Disclosure_dict = nil;
    Disclosure_Details = nil;
    NSIndexPath * _indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:index];

    [self fillDictionary:_indexPath];
    detailViewObject = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
    self.navigationController.delegate = self;
    detailViewObject.parentReference = self;
    detailViewObject.selectedIndexPath = _indexPath;
    detailViewObject.selectedRowForDetailEdit = _indexPath.row-1;
    detailViewObject.isInEditDetail = YES;
    detailViewObject.isInViewMode = isInViewMode;
    detailViewObject.header = self.header;
    detailViewObject.line = self.line;
    detailViewObject.Disclosure_dict = self.Disclosure_dict;
    detailViewObject.Disclosure_Fields = self.Disclosure_Fields;
    detailViewObject.Disclosure_Details = self.Disclosure_Details;
    detailViewObject.navigationItem.leftBarButtonItem = nil;
    [detailViewObject.navigationItem setHidesBackButton:YES animated:YES];

    //adding the Back button
    UIButton * BackButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 35)] autorelease];

    BackButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [BackButton addTarget:detailViewObject action:@selector(PopNavigationController:) forControlEvents:UIControlEventTouchUpInside];
    UIImage * backButtonimage = [UIImage imageNamed:@"SFM-Screen-Back-Arrow-Button"];
    [BackButton setBackgroundImage:backButtonimage forState:UIControlStateNormal];
    detailViewObject.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:BackButton] autorelease];

    //Radha 20th august 2011
    UIButton * actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 35)];
    [actionButton setBackgroundImage:[UIImage imageNamed:@"iService-Screen-Help.png"] forState:UIControlStateNormal];
    [actionButton addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * helpBarButton = [[UIBarButtonItem alloc] initWithCustomView:actionButton]; 
    //[appDelegate setSyncStatus:appDelegate.SyncStatus];
    showSyncUI=YES;

    UIBarButtonItem * syncBarButton = [[UIBarButtonItem alloc] initWithCustomView:appDelegate.animatedImageView];
    
    NSMutableArray * buttons = [[NSMutableArray alloc] initWithCapacity:0];
    [buttons addObject:syncBarButton];
    [syncBarButton setTarget:self];
    UIToolbar * toolBar;
    // adding the done button
    // ################ DONE BUTTON HERE ################# //
    if(isInViewMode)
    {
		UIButton * doneButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 67, 31)] autorelease];
        [doneButton setBackgroundImage:[UIImage imageNamed:@"SFM-Screen-Done-Back-Button.png"] forState:UIControlStateNormal];
        [doneButton addTarget:detailViewObject action:@selector(lineseditingDone) forControlEvents:UIControlEventTouchUpInside];
        [doneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
        NSString * done = [appDelegate.wsInterface.tagsDictionary objectForKey:DONE_BUTTON_TITLE];

        [doneButton setTitle:done forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        UIBarButtonItem * doneBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
        //[actionButton release];
        [buttons addObject:doneBarButtonItem];
        [doneBarButtonItem release];
        toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 200, 44)] autorelease];
    }
    // ################################################### //
    else
        toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 44)] autorelease];
   // toolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(self.view.frame.origin.x -75, 0, 50, 44)] autorelease];

    [buttons addObject:helpBarButton];
    [toolBar setItems:buttons];
    [actionButton release];
    [helpBarButton release];
    [syncBarButton release];
    [buttons release];
    
    detailViewObject.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:toolBar] autorelease];
    if(appDelegate.isWorkinginOffline)
    {
        
    }
    else
    {
        if (![appDelegate isInternetConnectionAvailable])
        {
            if (appDelegate.SFMPage != nil)
            {
                //[appDelegate.SFMPage release];
                //appDelegate.SFMPage = nil;
                
                [self.tableView reloadData];
                [appDelegate.sfmPageController.rootView refreshTable];
            }
            
            [activity stopAnimating];
            //[appDelegate displayNoInternetAvailable];
            [self enableSFMUI];
            return;
        }
    }
    detailViewObject.showSyncUI = self.showSyncUI;
    showSyncUI=YES;
    [self.navigationController pushViewController:detailViewObject animated:YES];
	if (appDelegate.sfmPageController.conflictExists)
	{
		NSMutableString *Confilct= [appDelegate isConflictInEvent:[appDelegate.dataBase getApiNameFromFieldLabel: appDelegate.sfmPageController.objectName] local_id:appDelegate.sfmPageController.recordId];
		
		if([Confilct length]>0)
		{
			[self moveTableViewforDisplayingConflict:Confilct];
		}
	}

}

-(void)backForNavigation:(id)sender
{
    if (self.isInEditDetail)
    {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
//    NSInteger section = self.selectedIndexPath.section;
//    NSMutableArray * details = [appDelegate.SFMPage objectForKey:gDETAILS];

//    NSMutableDictionary * detail = [details objectAtIndex:section];

    NSInteger reqiredFieldCount = 0;
    // COLLECT ALL DATA FROM EDIT DETAIL SCREEN AND DUMP THEM ON APP DELEGATE SFM PAGE DATA (PROBABLY BUBBLE INFO)
    //control type
   
    for (int i = 0; i < [Disclosure_Details count]; i++)
    {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        NSString * fieldValue = @"", * fieldType = @"";
        
        UIView * background = [[cell.contentView subviews] objectAtIndex:0];
        NSArray * backgroundSubViews = [background subviews];
        // testing
        
        for (int j = 0; j < [backgroundSubViews count]; j++)
        {
            UIView * view = [backgroundSubViews objectAtIndex:j];
            if(view.tag == 1)
            {
                                                           
                BOOL check_required = [self getViewRequired:view];
                
                NSDictionary * dict = [self valueForcontrol:view];
              
//                fieldType = [dict objectForKey:DapiName];
                fieldValue = [dict objectForKey:Dvalue];
                if([fieldValue length] == 0 && check_required == TRUE)
                {
                    reqiredFieldCount ++;
                }
            }
             
        }
        SMLog(@"Values Altered Successfully");
    }
    
    if(reqiredFieldCount >0)
    {
        NSString * warning = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_WARNING];
        NSString * required_field = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_REQUIRED_FIELDS];
        NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
        
        UIAlertView * alert_view = [[UIAlertView alloc] initWithTitle:warning message:required_field delegate:self cancelButtonTitle:alert_ok otherButtonTitles:nil, nil];
        [alert_view show];
        [alert_view release];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(BOOL)getViewRequired:(UIView *) view
{
    BOOL Flag = NO;
    if([view isKindOfClass:[CusTextView class]])
    {
        CusTextView * textarea ;
        textarea =( CusTextView *) view;
        return  textarea.required;
    }
    if([view isKindOfClass:[CSwitch class]])
    {
        CSwitch *switch_control;
        switch_control=(CSwitch *) view;
        
         return switch_control.required;        
    }
    if([view isKindOfClass:[CTextField class]])
    {
        CTextField * textFieldType ;
        textFieldType = (CTextField *) view;
        return textFieldType.required;
    }
    if([view isKindOfClass:[cusTextFieldAlpha class]])
    {
        cusTextFieldAlpha * string_type;
        string_type = (cusTextFieldAlpha *) view;
        return  string_type.required;
    }
    if([view isKindOfClass:[CusDateTextField class]])
    {
        CusDateTextField * date ;
        date = (CusDateTextField *) view;
        return date.required;
    }
    if([view isKindOfClass:[LookupField class]])
    {
        LookupField * lookup_type;
        lookup_type = (LookupField *)view;
        return lookup_type.required;
    }
    if([view isKindOfClass:[CtextFieldWithDatePicker class]])
    {
        CtextFieldWithDatePicker *dateTime;
        dateTime = (CtextFieldWithDatePicker *) view;
      
        return dateTime.required;
    }
    if([view isKindOfClass:[BotSpinnerTextField class]])
    {
        BotSpinnerTextField * picklist;
        picklist = (BotSpinnerTextField *)view;
        return picklist.required;
    }
    return Flag;
}

// get the columns for the descriptor 
-(NSInteger) HeaderColumns
{
    return [Disclosure_Fields count];    
}

-(NSInteger) linesColumns
{
    return [Disclosure_Details count];
}

-(void) fillDictionary:(NSIndexPath *)indexPath
{
    if (selectedSection == SHOW_LINES_ROW || selectedSection == SHOWALL_LINES)
	{
        NSMutableArray * details = [appDelegate.SFMPage objectForKey:gDETAILS];
		NSMutableDictionary * detail = [details objectAtIndex:indexPath.section];
        Disclosure_dict = detail;
		Disclosure_Details = [detail objectForKey:gDETAILS_FIELDS_ARRAY];
        self.line = YES;
        self.header = NO;
    }
}

// Override to support conditional editing of the table view.

- (BOOL)tableView:(UITableView *)_tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (self.isInEditDetail)
        return NO;
    if (selectedSection == SHOW_HEADER_ROW || selectedSection == SHOWALL_HEADERS)
        return NO;
    if (selectedSection == SHOW_LINES_ROW || selectedSection == SHOWALL_LINES)
    {
        if (indexPath.row == 0)
            return NO;
        else
        {
            NSInteger index;
            NSInteger section = indexPath.section;
            if (isDefault)
                index = section;
            else
                index = selectedRow;
            NSMutableArray * details = [appDelegate.SFMPage objectForKey:@"details"];
            NSMutableDictionary * detail = [details objectAtIndex:index];
            BOOL allowDeleteLines = [[detail objectForKey:@"details_Allow_Delete_Lines"] boolValue];
            if(allowDeleteLines)
            {
                return YES;
            }
            else
            {
                return NO;
            }
           
        }
    }
    
    // For ALL other conditions, return NO
    return NO;
}

// Override to support editing the table view.
- (void) tableView:(UITableView *)_tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView beginUpdates];
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSInteger index;
        NSInteger section = indexPath.section;
        if (isDefault)
            index = section;
        else
            index = selectedRow;
       
        NSIndexPath * _indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:index];

        
        // Delete the row from the data source.
        NSMutableArray * details = [appDelegate.SFMPage objectForKey:@"details"];
        NSMutableDictionary * detail = [details objectAtIndex:_indexPath.section];
        NSMutableArray * detail_values = [detail objectForKey:gDETAILS_VALUES_ARRAY];
        NSMutableArray * detail_record_id = [detail objectForKey:gDETAIL_VALUES_RECORD_ID];
        NSMutableArray * deleted_detail_records = [detail objectForKey:gDETAIL_DELETED_RECORDS];
        //code for delete the records
        
        NSString * deleted_record = @"";
        if ([detail_record_id count] > 0)
        {
            deleted_record = [detail_record_id objectAtIndex:_indexPath.row-1];
            [detail_values removeObjectAtIndex:_indexPath.row-1];
        }
        
        if([deleted_record isEqualToString:@""])
        {
            // Sahana - 29 July, 2011 - removed the following code
            // // Samman - 29 July, 2011 - added the following code
//            [detail_values removeObjectAtIndex:_indexPath.row-1];
        }
        else
        {
            [deleted_detail_records addObject:deleted_record];
        }
        
        // Sahana - 29 July, 2011
        if ([detail_record_id count] > 0)
        {
            [detail_record_id removeObjectAtIndex:_indexPath.row-1];
        }
        
        NSInteger  a = [tableView numberOfRowsInSection:indexPath.section];
        SMLog(@"%d", a);

        [tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [tableView endUpdates];
}

#pragma mark - KeyBoard notification
-(void)keyBoardDidShow:(NSNotification *)notification
{
    NSDictionary * info = [notification userInfo];
    NSValue * keyBounds = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
	
    CGRect boundRect;
    [keyBounds getValue:&boundRect];
    
	[UIView beginAnimations:@"Begin" context:notification];
	[UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(didShrinkTable:finished:context:)];
    CGRect frame = tableView.frame;
    originalRect = frame;
    
    CGFloat keyboardHeight = 0;
    UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
    if ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
    {
        keyboardHeight = boundRect.size.height;
		if(appDelegate.sfmPageController.conflictExists && !isEditingDetail)
			frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height - keyboardHeight - 100);
		else
			frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - keyboardHeight);
    }
    else
    {
        keyboardHeight = boundRect.size.width;
		if(appDelegate.sfmPageController.conflictExists && !isEditingDetail)
			frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height - keyboardHeight - 100);
		else
			frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - keyboardHeight);
    }
    
	if ( self.isInEditDetail )  //Shrinivas detailViewObject.isInEditDetail changed
		 self.tableView.frame = frame;
	else
		tableView.frame = frame;
		

	[UIView commitAnimations];
    
	//Check for lines :
	if (detailViewObject.currentEditRow != nil)
    {
        //Shrinivas --> Crash Fix
        NSInteger sections = [detailViewObject.tableView numberOfSections];
        
        int index = 0;
        
        for ( int i = 0; i < sections - 1; i++)
        {
			int j;
            for ( j = 0; j < [detailViewObject.tableView numberOfRowsInSection:i]; j++)
            {
				if (i == detailViewObject.currentEditRow.section && j == detailViewObject.currentEditRow.row)
				{
					break;
				}else{
					index ++;
				}
				
            }
			
			if (i == detailViewObject.currentEditRow.section && j == detailViewObject.currentEditRow.row)
				break;
        }
		
        NSArray * visible = [detailViewObject.tableView visibleCells];
		
		//New fix for a suspected crash -->
		UITableViewCell * cell = [detailViewObject.tableView cellForRowAtIndexPath:detailViewObject.currentEditRow];
		
		if (cell != nil)
		{
			if ([visible count] > index){
				
				[detailViewObject.tableView scrollRectToVisible:cell.frame animated:YES];
				
			}else{
				
				[detailViewObject.tableView scrollRectToVisible:cell.frame animated:YES];
				
			}

		}
		
    }
	
    if (currentEditRow != nil)
    {
        //Shrinivas --> Crash Fix
        NSInteger sections = [tableView numberOfSections];
        
        int index = 0;      
        
        for ( int i = 0; i < sections - 1; i++)
        {
			int j;
            for ( j = 0; j < [tableView numberOfRowsInSection:i]; j++)
            {
               if (i == currentEditRow.section && j == currentEditRow.row)
               {
                   break;
               }else{
                   index ++;
               }
               
            }
			
			if (i == currentEditRow.section && j == currentEditRow.row)
				break;
        }
		
        NSArray * visible = [self.tableView visibleCells];
		
		//New fix for a suspected crash -->
		UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:currentEditRow];
		if (cell != nil)
		{
			if ([visible count] > index){
				
				[self.tableView scrollRectToVisible:cell.frame animated:YES];
				
			}else{
				
				[self.tableView scrollRectToVisible:cell.frame animated:YES];
				
			}
			
		}
		
    }
    
    isKeyboardShowing = YES;
}

- (void) keyboardWillShow:(NSNotification *)notification
{
    
}

- (void) didShrinkTable:(NSString *)animationID finished:(BOOL)finished context:(void *)context
{
    if (currentEditRow == nil)
        return;
	
	currentEditRow = nil;
    
//    //Shrinivas --> Crash Fix
//    NSInteger sections = [tableView numberOfSections];
//    
//    if(sections == 0)
//    {
//        return;
//    }
//    NSInteger rows = [tableView numberOfRowsInSection:sections - 1];
//    SMLog(@"%d", rows);
//    int index = 0;
//    
//    for ( int i = 0; i < sections - 1; i++)
//    {
//		int j;
//        for ( j = 0; j < [tableView numberOfRowsInSection:i]; j++)
//        {
//            if (i == currentEditRow.section && j == currentEditRow.row)
//            {
//                break;
//            }else{
//                index ++;
//            }
//            
//        }
//		
//		if (i == currentEditRow.section && j == currentEditRow.row)
//			break;
//    }
	
}

- (void) shrinkTableFromRow:(NSIndexPath *)indexPath
{
    
}

- (void) keyboardDidHide:(NSNotification *)notification
{
    [UIImageView beginAnimations:@"Begin" context:nil];
	[UIImageView setAnimationDuration:0.3];

    UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
    if ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
    {
        if(!table_view_moved)
            tableView.frame = CGRectMake( 0, 0, self.view.frame.size.width, self.view.frame.size.height);
        else
            tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y,self.tableView.frame.size.width, self.tableView.frame.size.width);
    }
    else
    { 
        if(!table_view_moved)
            tableView.frame = CGRectMake( 0, 0, self.view.frame.size.width, self.view.frame.size.height);
        else
            tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y,self.tableView.frame.size.width, self.tableView.frame.size.width);
    }
	
	[UIImageView commitAnimations];
    
    isKeyboardShowing = NO;
    
    if (lookupPopover)
    {
        if (UIDeviceOrientationIsLandscape(interfaceOrientation))
        {
            [lookupPopover setPopoverContentSize:CGSizeMake(320, self.tableView.frame.size.height) animated:YES];
        }
        else
        {
            [lookupPopover setPopoverContentSize:CGSizeMake(320, self.tableView.frame.size.height) animated:YES];
        }
    }
	
	//Shrinivas Fix for #005845
	if (appDelegate.sfmPageController.conflictExists)
	{
		NSMutableString *Confilct= [appDelegate isConflictInEvent:[appDelegate.dataBase getApiNameFromFieldLabel: appDelegate.sfmPageController.objectName] local_id:appDelegate.sfmPageController.recordId];
		
		if([Confilct length]>0)
		{
			[self moveTableViewforDisplayingConflict:Confilct];
		}
	}

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isInEditDetail)
    {
    }
}
#pragma mark - Webservice Delegate Method

- (void) setLookupData:(NSDictionary *)lookupDictionary
{
    if (mLookupDictionary != nil)
    {
        [mLookupDictionary release];
        mLookupDictionary = nil;
    }
    mLookupDictionary = [lookupDictionary retain];
    NSDictionary * _lookupDetails = [lookupDictionary objectForKey:gLOOKUP_DETAILS];
    lookupData = _lookupDetails;
    [lookupData retain];
    appDelegate.wsInterface.didGetRecordTypeId = TRUE;
    SMLog(@"%@", lookupData);
}
-(void)tapRecognized:(id)sender
{ 
    UITapGestureRecognizer * tap = sender;
    if ([tap.view isKindOfClass:[UILabel  class]])    
    {
        UILabel * label = (UILabel *) tap.view;
        if(label.text == nil)
            return;
        //if the text length is 0 then dont show the popover
        if([label.text length] == 0)
            return;
        
        // content View class
        label_popOver_content = [[LabelPOContentView alloc ] init];
        
        // calculating the size for the popover
        UIFont * font = [UIFont systemFontOfSize:17.0];
        CGSize size =[label.text  sizeWithFont:font];
        
        //subview for the content view
        UITextView * contentView_textView;
        if(size.width > 240)
        {
            label_popOver_content.view.frame = CGRectMake(0, 0, label_popOver_content.view.frame.size.width, 90);
            contentView_textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, label_popOver_content.view.frame.size.width, 90)];
        }
        else
        {
            label_popOver_content.view.frame = CGRectMake(0, 0, label_popOver_content.view.frame.size.width, 34);
            contentView_textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, label_popOver_content.view.frame.size.width, 34)];  
        }
        
        contentView_textView.text = label.text;
        contentView_textView.font = font;
        contentView_textView.userInteractionEnabled = YES;
        contentView_textView.editable = NO;
        contentView_textView.textAlignment = UITextAlignmentCenter;
        [label_popOver_content.view addSubview:contentView_textView];
        
        CGSize size_po = CGSizeMake(label_popOver_content.view.frame.size.width, label_popOver_content.view.frame.size.height);
        label_popOver = [[UIPopoverController alloc] initWithContentViewController:label_popOver_content];
        [label_popOver setPopoverContentSize:size_po animated:YES];
        
        label_popOver.delegate = self;
        
        [label_popOver presentPopoverFromRect:CGRectMake(label.frame.size.width/2,0, 10, 10) inView:label permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        [contentView_textView release];
        [label_popOver_content release];
        
    }
}
-(void)tapRecognized1:(UIGestureRecognizer *)sender
{
    
    
    SMLog(@"Tapped");
}

#pragma mark -  Action Delegate Method
-(void) stopActivityIndicator
{
    [activity stopAnimating];
}

#pragma mark - SLA Clock Methods
- (void) restorationTimeLeftFromDateTime:(NSString *)_restoration
{
    if (![_restoration isKindOfClass:[NSString class]])
        return;
    NSArray * components = [_restoration componentsSeparatedByString:@":"];
    
    NSInteger days = [[components objectAtIndex:0] intValue];
    NSInteger hours = [[components objectAtIndex:1] intValue];
    NSInteger minutes = [[components objectAtIndex:2] intValue];
    NSInteger seconds = [[components objectAtIndex:3] intValue];
    
    [restorationTimer StartCountdownFromDays:days Hours:hours Minutes:minutes Seconds:seconds];
}

- (void) resolutionTimeLeftFromDateTime:(NSString *)_resolution
{
    if (![_resolution isKindOfClass:[NSString class]])
        return;
    NSArray * components = [_resolution componentsSeparatedByString:@":"];
    
    NSInteger days = [[components objectAtIndex:0] intValue];
    NSInteger hours = [[components objectAtIndex:1] intValue];
    NSInteger minutes = [[components objectAtIndex:2] intValue];
    NSInteger seconds = [[components objectAtIndex:3] intValue];
    
    [resolutionTimer StartCountdownFromDays:days Hours:hours Minutes:minutes Seconds:seconds];
}

- (void) restorationTimeLeftFromDateTimeOffline:(NSString *)_restoration
{
    _restoration = [_restoration stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    _restoration = [_restoration stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate * startDate = [NSDate date];
    //test code please verify
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    //test code please verify
    NSDate * endDate = [dateFormatter dateFromString:_restoration];
    
    NSTimeInterval startTimeInterval = [startDate timeIntervalSinceReferenceDate];
    NSTimeInterval endTimeInterval = [endDate timeIntervalSinceReferenceDate];
    
    if (endTimeInterval < startTimeInterval)
    {
        [restorationTimer ResetTimer];
        [dateFormatter release];
        return;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSUInteger unitFlags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *components = [gregorian components:unitFlags fromDate:startDate
                                                  toDate:endDate options:0];
    
    NSInteger days = [components day];
    NSInteger hours = [components hour];
    NSInteger minutes = [components minute];
    NSInteger seconds = [components second];
    
    [gregorian release];
    [dateFormatter release];
    
    [restorationTimer StartCountdownFromDays:days Hours:hours Minutes:minutes Seconds:seconds];
}

- (void) resolutionTimeLeftFromDateTimeOffline:(NSString *)_resolution
{
    _resolution = [_resolution stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    _resolution = [_resolution stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate * startDate = [NSDate date];
    //test code please verify
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:gmt];
    //test code please verify
    NSDate * endDate = [dateFormatter dateFromString:_resolution];
    
    NSTimeInterval startTimeInterval = [startDate timeIntervalSinceReferenceDate];
    NSTimeInterval endTimeInterval = [endDate timeIntervalSinceReferenceDate];
    
    if (endTimeInterval < startTimeInterval)
    {
        [resolutionTimer ResetTimer];
        [dateFormatter release];
        return;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSUInteger unitFlags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *components = [gregorian components:unitFlags fromDate:startDate
                                                  toDate:endDate options:0];
    
    NSInteger days = [components day];
    NSInteger hours = [components hour];
    NSInteger minutes = [components minute];
    NSInteger seconds = [components second];
    
    [gregorian release];
    [dateFormatter release];
    
    [resolutionTimer StartCountdownFromDays:days Hours:hours Minutes:minutes Seconds:seconds];
}

- (NSString *) timeDifferenceFrom:(NSString *)fromDate toDate:(NSString *)toDate
{
    
    if((fromDate == nil || toDate == nil) || ([fromDate length] == 0 || [toDate length] == 0))
        return [NSString stringWithFormat:@"00:00:00:00"];
    // 2012-03-22T13:20:18.000+0000
    fromDate = [fromDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    fromDate = [fromDate stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    toDate = [toDate stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    toDate = [toDate stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    //Radha
    if ([fromDate length] > 18)
        fromDate = [fromDate substringToIndex:19];
    if ([toDate length] > 18)
        toDate = [toDate substringToIndex:19];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date1 = [dateFormatter dateFromString:toDate];
    SMLog(@"Date 1 = %@",date1);
    
    NSDate *date2 = [dateFormatter dateFromString:fromDate];
    SMLog(@"Date 2 = %@",date2);
    
    NSTimeInterval diff_time = [date2 timeIntervalSinceDate:date1];
    SMLog(@"Difference = %f",diff_time);
    
    [dateFormatter release];
    
    if(diff_time < 0)
        return [NSString stringWithFormat:@"00:00:00:00"];
    
    int days  = diff_time / 86400;
    int days_rem = ((int)diff_time % 86400);
    
    int hours  = days_rem / 3600;
    int hours_rem = days_rem % 3600;
    
    int min = hours_rem / 60;
    int sec = hours_rem % 60;
    NSString *final_time = [NSString stringWithFormat:@"%d:%d:%d:%d",days,hours,min,sec];
    return final_time;
}


#pragma  mark - navigation Done Button
-(void) lineseditingDone
{
    [activity startAnimating];
    // APP DELEGATE SFM PAGE DATA
    NSInteger section = self.selectedIndexPath.section;
    NSMutableArray * details = [appDelegate.SFMPage objectForKey:gDETAILS];
    NSMutableDictionary * detail = [details objectAtIndex:section];
    NSMutableArray * detail_values = [detail objectForKey:gDETAILS_VALUES_ARRAY];
    NSInteger reqiredFieldCount = 0;
    // COLLECT ALL DATA FROM EDIT DETAIL SCREEN AND DUMP THEM ON APP DELEGATE SFM PAGE DATA (PROBABLY BUBBLE INFO)
    {
        for (int i = 0; i < [Disclosure_Details count]; i++)
        {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            NSString * fieldValue = @"", * fieldType = @"";
            
            UIView * background = [[cell.contentView subviews] objectAtIndex:0];
            NSArray * backgroundSubViews = [background subviews];
            // testing
            
            for (int j = 0; j < [backgroundSubViews count]; j++)
            {
                UIView * view = [backgroundSubViews objectAtIndex:j];
                if(view.tag == 1)
                {
                    BOOL check_required = [self getViewRequired:view];
                    NSDictionary * dict = [self valueForcontrol:view];
                    NSInteger dict_count = [dict count];
                    NSString * id_type = nil;
                    NSString * control_type = nil;
                    fieldType = [dict objectForKey:DapiName];
                    fieldValue = [dict objectForKey:Dvalue];
                    if([fieldValue length] == 0 && check_required == TRUE)
                    {
                        reqiredFieldCount ++;
                    }
                    if(fieldValue == nil)
                    {
                        fieldValue = @"";
                    }
                    if(dict_count > 1)
                    {
                        id_type = [dict objectForKey:Didtype];
                        control_type = [dict objectForKey:Dcontrol_type];
                    }
                    NSMutableArray * detailValue = [detail_values objectAtIndex:self.selectedRowForDetailEdit];
                    for(int l = 0; l < [detailValue count]; l++)
                    {
                        NSMutableDictionary * dict = [detailValue objectAtIndex:l];
                        if ([fieldType isEqualToString:[dict objectForKey:gVALUE_FIELD_API_NAME]])
                        {
                            if([control_type isEqualToString:@"reference"])
                            {
								NSString * field_api_name_temp = [dict objectForKey:gVALUE_FIELD_API_NAME];
								//Fix for defect : 6028 Shrinivas
								if([field_api_name_temp  isEqualToString:@"RecordTypeId"])
								{
									NSString * detailObjectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
									id_type =  [appDelegate.databaseInterface getRecordTypeIdForRecordTypename:fieldValue objectApi_name:detailObjectName];
									
								}
                                if(id_type == nil)
                                {
                                    id_type = @"";
                                }
                                [dict setObject:id_type forKey:gVALUE_FIELD_VALUE_KEY];
                                [dict setObject:fieldValue forKey:gVALUE_FIELD_VALUE_VALUE];
                                break;
                            }
                            if([control_type isEqualToString:@"picklist"])
                            {
                                if(appDelegate.isWorkinginOffline)
                                {
                                    NSString * detailObjectName = [detail objectForKey:gDETAIL_OBJECT_NAME];
                                    //query to acces the picklist values for lines 
                                    NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:fieldType tableName:SFPicklist objectName:detailObjectName];
                                    
                                    
                                    NSArray * allvalues = [picklistValues allValues];
                                    NSArray * allkeys = [picklistValues allKeys];
                                   
                                    for(int i =0; i<[picklistValues count];i++)
                                    {
                                        NSString * value = [allvalues objectAtIndex:i];
                                        if([value isEqualToString:fieldValue])
                                        {
                                            id_type = [allkeys objectAtIndex:i];
                                            break;
                                        }
                                    }
                                   
                                }
                                else
                                {
                                    for (int i = 0; i < [appDelegate.describeObjectsArray count]; i++)
                                    {
                                        ZKDescribeSObject * descObj = [appDelegate.describeObjectsArray objectAtIndex:i];
                                        ZKDescribeField * descField = [descObj fieldWithName:fieldType];
                                        if (descField == nil)
                                            continue;
                                        else
                                        {   
                                            NSArray * pickListEntryArray = [descField picklistValues];
                                            for (int k = 0; k < [pickListEntryArray count]; k++)
                                            {
                                                NSString * value = [[pickListEntryArray objectAtIndex:k] label];
                                                if([value isEqualToString:fieldValue])
                                                {
                                                    id_type =[[pickListEntryArray objectAtIndex:k] value];
                                                    break;
                                                }
                                            }
                                            break;
                                        }
                                    }
                                }
                                if(id_type == nil)
                                {
                                    id_type = @"";
                                }
                                [dict setObject:id_type forKey:gVALUE_FIELD_VALUE_KEY];
                                [dict setObject:fieldValue forKey:gVALUE_FIELD_VALUE_VALUE];
                                break;
                                
                            }
                            if([control_type isEqualToString:@"datetime"])    
                            {
                                //sahana 9th Aug 2011
                                NSString * str = fieldValue;
                                NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                                [frm setDateFormat:DATETIMEFORMAT];
                                NSDate * date = [frm dateFromString:str];
                                [frm  setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                NSString * str1 = [frm stringFromDate:date];//.000Z
                                
                                // Convert this str1 back into GMT
                                if(str1 != nil)
                                {
                                    str1 = [iOSInterfaceObject getGMTFromLocalTime:str1];
                                    str1 = [str1  stringByReplacingOccurrencesOfString:@"Z" withString:@".000Z"];
                                }

                                if(str1 != nil)
                                {
                                    if([str1 isEqualToString:@""])
                                        fieldValue = @"";
                                    else
                                        fieldValue = str1;
                                    
                                }
                                else
                                {
                                    fieldValue = @"";
                                }
                                SMLog(@"%@",date);
                            }
                            if([control_type isEqualToString: @"date"])
                            {
                                
                                NSString * str = fieldValue;
                                NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                                [frm setDateFormat: @"MMM dd yyyy"];
                                NSDate * date = [frm dateFromString:str];
                                [frm  setDateFormat:@"yyyy-MM-dd"];
                                NSString * final_date = [frm stringFromDate:date];
                                if(final_date != nil)
                                {
                                    fieldValue = final_date;
                                   
                                }
                                else
                                {
                                    fieldValue = @"";
                                  
                                }
                                
                            }

                            if([control_type isEqualToString:@"boolean"])
                            {
                                
                                BOOL changed =[self gettheChangedValue:view];
                                if (changed)
                                {
//                                    fieldValue = @"True";
                                    fieldValue = @"1";
                                }
                                else
                                {
//                                    fieldValue = @"False";
                                    fieldValue = @"0";
                                }
                            }
                            //Radha and sahana 9th Aug 2011
                            if([control_type isEqualToString:@"multipicklist"])
                            {
                                NSMutableArray * keyVal	 = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                                NSString * keyValueString =[[[NSString alloc] init] autorelease];
//                                NSInteger len;
                                
                                if(appDelegate.isWorkinginOffline)
                                {
                                    NSString * detailObjectName = [detail objectForKey:gDETAIL_OBJECT_NAME];
                                    //query to acces the picklist values for lines 
                                    NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:fieldType tableName:SFPicklist objectName:detailObjectName];
                                    
                                    
                                    NSArray * allvalues = [picklistValues allValues];
                                    NSArray * allkeys = [picklistValues allKeys];
                                    NSArray * array = [fieldValue componentsSeparatedByString:@";"];
                                   
                                    for(int j = 0; j < [array count]; j++)
                                    {
                                        NSString * value_field = [array objectAtIndex:j];
                                        
                                        for(int i = 0; i < [picklistValues count]; i++)
                                        {
                                            NSString * value = [allvalues objectAtIndex:i];
                                            if([value isEqualToString:value_field])
                                            {
                                                [keyVal addObject:[allkeys objectAtIndex:i]];
                                                break;
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    for (int i = 0; i < [appDelegate.describeObjectsArray count]; i++)
                                    {
                                        ZKDescribeSObject * sObj = [appDelegate.describeObjectsArray objectAtIndex:i];
                                        ZKDescribeField * desField = [sObj fieldWithName:fieldType];
                                        if (desField == nil)
                                            continue;
                                        else
                                        {
                                            NSArray * multipicklistArray = [desField picklistValues];
                                            NSArray * array = [fieldValue componentsSeparatedByString:@";"];
                                            for (int j = 0; j < [array count]; j++)
                                            {
                                                for (int i = 0; i < [multipicklistArray count]; i++)
                                                {
                                                    NSString * value = [[multipicklistArray objectAtIndex:i] label];
                                                    if ([value isEqualToString:[array objectAtIndex:j]])
                                                    {
                                                        [keyVal addObject:[[multipicklistArray objectAtIndex:i] value]];
                                                        break;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                for(int j = 0 ; j < [keyVal count]; j++)
                                {
                                    if ([keyValueString length] > 0)
                                        keyValueString = [keyValueString stringByAppendingString:[NSString stringWithFormat:@";%@", [keyVal objectAtIndex:j]]];
                                    else
                                        keyValueString = [keyValueString stringByAppendingString:[keyVal objectAtIndex:j]];
                                }
                                
                                if([keyValueString length] == 0)
                                {
                                    keyValueString = @"";
                                }
                                
                                [dict setObject:keyValueString forKey:gVALUE_FIELD_VALUE_KEY];
                                [dict setObject:fieldValue     forKey:gVALUE_FIELD_VALUE_VALUE];
                                break;
                            }
                            
                            [dict setObject:fieldValue forKey:gVALUE_FIELD_VALUE_KEY];
                            [dict setObject:fieldValue forKey:gVALUE_FIELD_VALUE_VALUE];
                            break;
                        }
                    }
                }
            }
            SMLog(@"Values Altered Successfully");
        }
    }
    [activity stopAnimating];
    //sahana temp change -  required fields check
    
    if(reqiredFieldCount  > 0)
    {
        NSString * warning = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_WARNING];
        NSString * required_field = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_REQUIRED_FIELDS];
        NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
        UIAlertView * alert_view = [[UIAlertView alloc] initWithTitle:warning message:required_field delegate:self cancelButtonTitle:alert_ok otherButtonTitles:nil, nil];
        [alert_view show];
        [alert_view release];
    }
    else
    {
        //sahana 20th August 2011
        NSMutableArray * detailValue = [detail_values objectAtIndex:self.selectedRowForDetailEdit];
        for(int i =0; i< [detailValue count]; i++)
        {
            NSMutableDictionary  * dict = [detailValue objectAtIndex:i];
            NSString * api_name = [dict objectForKey:gVALUE_FIELD_API_NAME];
            if([api_name isEqualToString:gDETAIL_SAVED_RECORD])
            {
                [dict  setObject:[NSNumber numberWithInt:1] forKey:gVALUE_FIELD_VALUE_VALUE];
                [dict  setObject:[NSNumber numberWithInt:1] forKey:gVALUE_FIELD_VALUE_KEY];
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(BOOL)gettheChangedValue:(UIView *)view
{
    BOOL flag_value = NO;
    if([view isKindOfClass:[CSwitch class]])
    {
        CSwitch * switchType =(CSwitch *) view;

        if(switchType.on)
        {
            flag_value = TRUE;
        }
        else
        {
            flag_value = FALSE; 
        }
    }
    return  flag_value;
}

#pragma mark -
#pragma mark ShowSignature method

- (void) ShowSignature
{
    if (isShowingSignatureCapture)
        return;
    
	sign = [[SignatureViewController alloc] initWithNibName:[SignatureViewController description] bundle:nil];

    sign.view.frame = CGRectMake(0, self.view.frame.size.height-sign.view.frame.size.height, self.view.frame.size.width, sign.view.frame.size.height);
    [sign.view setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
	sign.parent = nil;
    sign.delegate = self;
	if( signimagedata != nil )
	{
		sign.imageData = [signimagedata retain];
		[sign SetImage];
	}
	[self.view addSubview:sign.view];
    
    isShowingSignatureCapture = YES;
}

- (void) setSignImageData:(NSData *)imageData
{
    isShowingSignatureCapture = NO;

    /*if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        [appDelegate displayNoInternetAvailable];
        return;
    } */
    
    if (imageData == nil)
    {
        isShowingSignatureCapture = NO;
        return;
    }

    // Call appDelegate Method to save signature to SFDC
    appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];

    didRunOperation = YES;
   // [appDelegate._iOSObject setSignImageData:imageData];
    didRunOperation = NO;
    
    
    NSDictionary * dict = [appDelegate.SFMPage objectForKey:gHEADER];
    NSString * HeaberObjectName = [dict objectForKey:@"hdr_Object_Name"];
    
    NSString * WoNumber = @"";
    
    if ([detailTitle length] > 10)
        WoNumber = [detailTitle substringFromIndex:12];

    if ([WoNumber isEqualToString:nil] || [WoNumber isEqualToString:@""])
        WoNumber = @"";
    
    [appDelegate.calDataBase insertSignatureData:imageData WithId:WoNumber RecordId:appDelegate.sfmPageController.recordId apiName:HeaberObjectName WONumber:WoNumber flag:@"ViewWorkOrder"];
    
    isShowingSignatureCapture = NO;
}
 
#pragma mark - ShowHelp Method
- (void) showHelp
{
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    if (!isInViewMode)
        help.helpString = @"view-record.html";  
    else
        help.helpString = @"create-edit-record.html";
    [(SFMPageController *)delegate presentViewController:help animated:YES completion:nil];
    [help release];
    appDelegate.isDetailActive = NO;
}

#pragma SummaryViewController Delegate Method

- (void) CloseSummaryView
{
//    [(SFMPageController *)delegate dismissModalViewControllerAnimated:YES];
}

#pragma Chatter Delegate Method
- (void) closeChatter
{
    [self enableSFMUI];
}

- (void) enableSFMUI
{
    self.navigationItem.leftBarButtonItem.enabled = TRUE;
    rootViewController.navigationItem.leftBarButtonItem.enabled=TRUE;
    self.navigationItem.rightBarButtonItem.enabled = TRUE;
    [rootViewController.view setUserInteractionEnabled:YES];
    [self.view setUserInteractionEnabled:YES];
    [[super view] setUserInteractionEnabled:YES];
}

- (void) disableSFMUI
{
    self.navigationItem.leftBarButtonItem.enabled = FALSE;
    self.navigationItem.rightBarButtonItem.enabled = FALSE;
    rootViewController.navigationItem.leftBarButtonItem.enabled=FALSE;
    [rootViewController.view setUserInteractionEnabled:NO];
    [self.view setUserInteractionEnabled:NO];
    [[super view] setUserInteractionEnabled:NO];
    
}

-(void)offlineActions:(NSDictionary *)buttonDict
{  

    [self dismissActionMenu];
    NSString * warning = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_WARNING];
    NSString * invalidEmail = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_TEXT_INVALID_EMAIL]; 
    NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    
    [self disableSFMUI];
    
    NSString * targetCall = [buttonDict objectForKey:SFW_ACTION_DESCRIPTION];
    NSString * action_type = [buttonDict objectForKey:SFW_ACTION_TYPE];
    NSString * action_process_id = [buttonDict objectForKey:SFW_PROCESS_ID];
    if([action_type isEqualToString:SFM] || [action_type isEqualToString:@"WEBSERVICE"] || ![action_type isEqualToString:@"SFW_Custom_Actions"])
    {
        if ([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"VIEWRECORD"]) 
        {
            if ([targetCall isEqualToString:summary])
            {
                [activity startAnimating];
                didRunOperation = YES;
                [self startSummaryDataFetch];
                appDelegate = (iServiceAppDelegate *)[[UIApplication sharedApplication] delegate];
                appDelegate.isDetailActive = NO;
            }
            else if([targetCall isEqualToString:dod_title])
            {
                
                if(![appDelegate isInternetConnectionAvailable])
                {
                    [self enableSFMUI];
                    appDelegate.shouldShowConnectivityStatus = TRUE;
                    [appDelegate displayNoInternetAvailable];
                    return;
                }
                
                NSString * obejct_name = [appDelegate.dataBase  getFieldLabelForApiName:appDelegate.sfmPageController.objectName];
                [self disableSFMUI];
                
                NSString * sf_id = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:appDelegate.sfmPageController.objectName local_id:appDelegate.sfmPageController.recordId];
                [delegate presentProgressBar:appDelegate.sfmPageController.objectName sf_id:sf_id reocrd_name:obejct_name];
                [self enableSFMUI];
                [self fillSFMdictForOfflineforProcess:appDelegate.sfmPageController.processId   forRecord:appDelegate.sfmPageController.recordId];
                [self didReceivePageLayoutOffline];
                [self.tableView reloadData];
                [appDelegate.sfmPageController.rootView refreshTable];
               
                
            }
            else if ([targetCall isEqualToString:troubleShooting])
            {
                [self showTroubleshooting];
            }
            else
            {
                if(action_process_id != nil && [action_process_id length] != 0)
                {
                    
                    NSString * process_type = [appDelegate.databaseInterface getprocessTypeForProcessId:action_process_id];
                    
                    if([process_type isEqualToString:@"EDIT"] || [process_type isEqualToString:@"SOURCETOTARGETONLYCHILDROWS"])
                    {
                        //Deffect Num
                        NSMutableDictionary * page_layoutInfo = [appDelegate.databaseInterface  queryProcessInfo:action_process_id object_name:@""];
                        
                        NSMutableDictionary * _header =  [page_layoutInfo objectForKey:@"header"];
                        
                        NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];
                        
                        NSString * layout_id = [_header objectForKey:gHEADER_HEADER_LAYOUT_ID];
                        
                        NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGET process_id:action_process_id layoutId:layout_id objectName:headerObjName];
                       // NSString * source_parent_object_name = [process_components objectForKey:SOURCE_OBJECT_NAME];
                        NSString * expression_id = [process_components objectForKey:EXPRESSION_ID];
                        
                        BOOL Entry_criteria = [appDelegate.databaseInterface EntryCriteriaForRecordFortableName:headerObjName record_id:appDelegate.sfmPageController.recordId expression:expression_id];
                        if(!Entry_criteria)
                        {
                            NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_swich_process];
                            NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
                            NSString * cancel_ = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE];
                            
                            UIAlertView * enty_criteris = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel_ otherButtonTitles:nil, nil];
                            [enty_criteris show];
                            [enty_criteris release];
                        }
                        else
                        {
                            appDelegate.sfmPageController.sourceProcessId = appDelegate.sfmPageController.processId;
                            appDelegate.sfmPageController.sourceRecordId = appDelegate.sfmPageController.recordId;
                            
                            appDelegate.sfmPageController.processId = action_process_id;
                            appDelegate.sfmPageController.recordId  = appDelegate.sfmPageController.recordId ;
                            
                            currentRecordId  = appDelegate.sfmPageController.recordId;
                            currentProcessId = action_process_id;
                            //check For view process - dont require
                            [self fillSFMdictForOfflineforProcess:action_process_id forRecord:currentRecordId];
                            [self didReceivePageLayoutOffline];
                        }
                    }
                    //Radha 15/5/11
                    if ([process_type isEqualToString:@"STANDALONECREATE"])
                    {
                        
                        appDelegate.sfmPageController.sourceProcessId = appDelegate.sfmPageController.processId;
                        appDelegate.sfmPageController.sourceRecordId = nil;
                        
                        appDelegate.sfmPageController.processId = action_process_id;
                        appDelegate.sfmPageController.recordId  = nil;
                        
                        currentRecordId  = nil;
                        currentProcessId = action_process_id;
                        //check For view process - dont require
                        [self fillSFMdictForOfflineforProcess:action_process_id forRecord:currentRecordId];
                        [self didReceivePageLayoutOffline];
                    }
                        
                    if([process_type isEqualToString:@"SOURCETOTARGET"] )
                    {
                        
                        //check out the record any child or parent  local_id
                        
                        BOOL record_is_not_syncd = FALSE;
                        
                        NSMutableDictionary * page_layoutInfo = [appDelegate.databaseInterface  queryProcessInfo:action_process_id object_name:@""];
                        
                        NSMutableDictionary * _header =  [page_layoutInfo objectForKey:@"header"];
                        
                        NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];
                        
                        NSString * layout_id = [_header objectForKey:gHEADER_HEADER_LAYOUT_ID];
                        NSMutableArray * details = [page_layoutInfo objectForKey:gDETAILS];
                        
                        NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGET process_id:action_process_id layoutId:layout_id objectName:headerObjName];
                        NSString * source_parent_object_name = [process_components objectForKey:SOURCE_OBJECT_NAME];
                        NSString * expression_id = [process_components objectForKey:EXPRESSION_ID];

                        BOOL Entry_criteria = [appDelegate.databaseInterface EntryCriteriaForRecordFortableName:source_parent_object_name record_id:appDelegate.sfmPageController.recordId expression:expression_id];
                        
                        
                        if(!Entry_criteria)
                        {
                            NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_swich_process];
                            NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
                            NSString * cancel_ = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE];
                            
                            UIAlertView * enty_criteris = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel_ otherButtonTitles:nil, nil];
                            [enty_criteris show];
                            [enty_criteris release];
                            
                        }
                        else
                        {
                            if ([source_parent_object_name length] == 0)
                                source_parent_object_name = headerObjName;
                            
                            NSString * parent_sf_id =  [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:source_parent_object_name local_id:appDelegate.sfmPageController.recordId];
                            
                            if([parent_sf_id isEqualToString:@""] || parent_sf_id == nil || [parent_sf_id length] ==0)
                            {
                                record_is_not_syncd = TRUE;
                                
                            }
                            if(!record_is_not_syncd)
                            {
                                for(int j= 0; j < [details count]; j++)
                                {
                                    NSMutableDictionary * dict = [details objectAtIndex:j];
                                    NSMutableArray * filedsArray = [dict objectForKey:gDETAILS_FIELDS_ARRAY];
                                    NSMutableArray * details_api_keys = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
                                    NSString * detailObjectName = [dict objectForKey:gDETAIL_OBJECT_NAME];
                                    
                                    //NSString * detailaliasName = [dict objectForKey:gDETAIL_OBJECT_ALIAS_NAME];
                                    NSString * detail_layout_id = [dict objectForKey:gDETAILS_LAYOUT_ID];
                                    
                                    for(int k =0 ;k<[filedsArray count];k++)
                                    {
                                        NSMutableDictionary * detailFiled_info =[filedsArray objectAtIndex:k];
                                        NSString * api_name = [detailFiled_info objectForKey:gFIELD_API_NAME];
                                        [details_api_keys addObject:api_name];
                                    }
                                    
                                    NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGETCHILD process_id:action_process_id layoutId:detail_layout_id objectName:detailObjectName];
                                    
                                    NSString * source_child_object_name = [process_components objectForKey:SOURCE_OBJECT_NAME];
                                    NSMutableArray * source_child_ids = [appDelegate.databaseInterface getChildLocalIdForParentId:appDelegate.sfmPageController.sourceRecordId childTableName:source_child_object_name sourceTableName:source_parent_object_name];
                                    for(NSString * child_record_id in  source_child_ids)
                                    {
                                        NSString * Child_parent_sf_id = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:source_child_object_name local_id:child_record_id];
                                        if([Child_parent_sf_id isEqualToString:@""])
                                        {
                                            record_is_not_syncd = TRUE;
                                            break;
                                        }
                                    }
                                }
                            }
                            
                            if(record_is_not_syncd)
                            {
                                NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_sync_error];
                                NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_synchronize_error];
                                NSString * Ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
                                
                                UIAlertView * alert_view = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:Ok otherButtonTitles:nil, nil];
                                [alert_view show];
                            }
                            else
                            {
                                appDelegate.sfmPageController.sourceProcessId = appDelegate.sfmPageController.processId;
                                appDelegate.sfmPageController.sourceRecordId = appDelegate.sfmPageController.recordId;
                                
                                appDelegate.sfmPageController.processId = action_process_id;
                                appDelegate.sfmPageController.recordId  = nil;
                                
                                currentRecordId  = nil;
                                currentProcessId = action_process_id;
                                //check For view process  - dont require
                                [self fillSFMdictForOfflineforProcess:action_process_id forRecord:currentRecordId];
                                [self didReceivePageLayoutOffline];
                            }
                        }
                    }
                }
                //RADHA 2012june07 
                else 
                {
                    NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_no_pagelayout];
                    NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
                    NSString * cancel_ = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE];
                    
                    UIAlertView * no_page_Layout = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel_ otherButtonTitles:nil, nil];
                    
                    [no_page_Layout show];
                    [no_page_Layout release];
                }
                    
            }
            
        }
    
        if( [[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"STANDALONECREATE"])
        {
            if([targetCall isEqualToString:save])
            {
                [self pageLevelEventsForEvent:BEFORESAVE];
                [self pageLevelEventsForEvent:AFTERSAVE];
               
                NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
                
                NSArray * header_sections = [hdr_object objectForKey:@"hdr_Sections"];
                NSString * headerObjName = [hdr_object objectForKey:gHEADER_OBJECT_NAME];
                NSString * layout_id = [hdr_object objectForKey:gHEADER_HEADER_LAYOUT_ID];
                NSString * processId = appDelegate.sfmPageController.processId;
                NSMutableDictionary * SFM_header_fields = [[NSMutableDictionary alloc] initWithCapacity:0];
                
                
                BOOL error = FALSE;
                for (int i=0;i<[header_sections count];i++)
                {
                    NSDictionary * section = [header_sections objectAtIndex:i];
                    NSArray *section_fields = [section objectForKey:@"section_Fields"];
                    for (int j=0;j<[section_fields count];j++)
                    {
                        NSDictionary *section_field = [section_fields objectAtIndex:j];
                        
                        //add key values to SM_header_fields dictionary 
                        NSString * field_api = [section_field objectForKey:gFIELD_API_NAME];
                        NSString * value = [section_field objectForKey:gFIELD_VALUE_VALUE];
                        NSString * key = [section_field objectForKey:gFIELD_VALUE_KEY];
                        NSString * dataType = [section_field objectForKey:gFIELD_DATA_TYPE];
                        if(key == nil)
                        {
                            key = @"";
                        }
                        [SFM_header_fields setObject:key forKey:field_api];
                        
                        BOOL required = [[section_field objectForKey:gFIELD_REQUIRED] boolValue];
                        if(required)
                        {
                            if([value length] == 0 )
                            {
                                error = TRUE;
                                //sahana TEMP change
                                break;
                            }
                        }
                        if ([dataType isEqualToString:@"email"] )  //Shrinivas Fix for Email Validation 03/04/2012
                        {
                            BOOL result;
                            NSString * emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
                            NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
                            result = [emailTest evaluateWithObject:value];
                            
                            if (result == NO && [value length] > 0)
                            {
                                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:warning message:invalidEmail delegate:self cancelButtonTitle:alert_ok otherButtonTitles:nil, nil];
                                [alertView show];
                                [alertView release];

                                [self enableSFMUI];
                                return;
                            }
                            
                        }
                    }        
                }
                if(error == TRUE)
                {
                    [self requireFieldWarning];
                    requiredFieldCheck = TRUE;
                    [self enableSFMUI];
                    return;
                }
                
                //child records
                BOOL line_error = FALSE;
               
                NSArray * details = [appDelegate.SFMPage objectForKey:gDETAILS]; //as many as number of lines sections
                
                for (int i=0;i<[details count];i++) //parts, labor, expense for instance
                {
                    NSDictionary *detail = [details objectAtIndex:i];
                    
                    NSArray * fields_array = [detail  objectForKey:gDETAILS_FIELDS_ARRAY];
                    NSArray *details_values = [detail objectForKey:gDETAILS_VALUES_ARRAY];
                    
                    for (int j=0;j<[details_values count];j++) //parts for instance
                    {
                        NSArray *child_record_fields = [details_values objectAtIndex:j];
                        for (int k = 0; k < [child_record_fields count];k++) //fields of one part for instance
                        {
                            NSDictionary * field = [child_record_fields objectAtIndex:k];
                            NSString * detail_api_name = [field objectForKey:gVALUE_FIELD_API_NAME];
                            NSString * deatil_value = [field objectForKey:gVALUE_FIELD_VALUE_VALUE];
                            for(int l = 0 ;l < [fields_array count]; l++)
                            {
                                NSDictionary *field_array_value = [fields_array  objectAtIndex:l];
                                BOOL required  = [[field_array_value objectForKey:gFIELD_REQUIRED]boolValue];
                                NSString * api_name = [field_array_value objectForKey:gFIELD_API_NAME];
                                if([api_name isEqualToString:detail_api_name])
                                {
                                    if(required)
                                    {
                                        if([deatil_value length]== 0)
                                        {
                                            line_error = TRUE; 
                                            //sahana TEMP chage
                                            break;
                                        }
                                    }
                                }
                                
                                if ([detail_api_name isEqualToString:@"SVMXC__Email__c"] )  //Shrinivas Fix for Email Validation 03/04/2012
                                {
                                    BOOL result;
                                    NSString * emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
                                    NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
                                    result = [emailTest evaluateWithObject:deatil_value];
                                    
                                    if (result == NO && [deatil_value length] > 0)
                                    {
                                        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:warning message:invalidEmail delegate:self cancelButtonTitle:alert_ok otherButtonTitles:nil, nil];
                                        [alertView show];
                                        [alertView release];

                                        [self enableSFMUI];
                                        return;
                                    }
                                    
                                }

                            }
                        }
                    }        
                }
                
                if(line_error)
                {
                    [self requireFieldWarning];
                    requiredFieldCheck = TRUE;
                    [self enableSFMUI];
                    return;
                }

                // write a method to save the SFM values in the table
                // for header fill all the fields and insert into object table
                
                NSMutableDictionary * header_fields_dict  = [appDelegate.databaseInterface getAllObjectFields:headerObjName tableName:SFOBJECTFIELD]; //method to get the all the fields from the objectField table
                
                NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGET process_id:processId layoutId:layout_id objectName:headerObjName];//[appDelegate.databaseInterface  getValueMappingForlayoutId:layout_id process_id:processId objectName:headerObjName];
                
                NSMutableDictionary * object_mapping_dict = [appDelegate.databaseInterface getObjectMappingForMappingId:process_components mappingType:VALUE_MAPPING];

                NSArray * object_mapping_keys = [object_mapping_dict allKeys];
                
                // First fill all fileds with default values from  objectMapping table
                
                NSArray * header_object_keys = [header_fields_dict allKeys]; 
                NSString * value = @"";
                
                for(int i =0 ; i < [header_object_keys count]; i++)
                {
                    NSString * key = [header_object_keys objectAtIndex:i];
                    
                    for(NSString * object_mapping_key in object_mapping_keys)
                    {
                        if([key isEqualToString:object_mapping_key])
                        {
                            value = [object_mapping_dict objectForKey:key];
                            if(value == nil)
                            {
                                value = @"";
                            }
                            
                            [header_fields_dict setObject:value forKey:key];
                            break;
                        }
                    }
                    
                }
                
                //after filling the default values fill the object tables fields with the sfm header fields keys
                NSArray * SFM_Header_keys = [SFM_header_fields allKeys];
                
                
                for(int i =0 ; i < [header_object_keys count]; i++)
                {
                    NSString * key = [header_object_keys objectAtIndex:i];
                    
                    for(NSString * sfm_header_field_key in SFM_Header_keys)
                    {
                        if([key isEqualToString:sfm_header_field_key])
                        {
                            value = [SFM_header_fields objectForKey:key];
                            
                            if(value == nil)
                            {
                                value = @"";
                            }
                            [header_fields_dict setObject:value forKey:key];
                            break;
                        }
                    }
                    
                }
                
                //get the GUID 
                NSString * header_record_local_id = [iServiceAppDelegate GetUUID];
                [header_fields_dict setObject:header_record_local_id forKey:@"local_id"];
                
                if([headerObjName isEqualToString:@"Event"])
                {
                    appDelegate.databaseInterface.databaseInterfaceDelegate = self;
                    NSString * event_local_id = [appDelegate.databaseInterface getLocal_idFrom_Event_local_id];
                    if([event_local_id length] != 0)
                    {
                        header_record_local_id = event_local_id;
                        [header_fields_dict setObject:header_record_local_id forKey:@"local_id"];
                    }
                    
                }
                
                BOOL data_inserted = [appDelegate.databaseInterface insertdataIntoTable:headerObjName data:header_fields_dict];
                
                if([headerObjName isEqualToString:@"Event"])
                {
                    appDelegate.databaseInterface.databaseInterfaceDelegate = nil;;
                }
                if(data_inserted)
                {
                    //fill the detail tables
                    //***************************************************** DETAIL SECTION ***************************************************
                    
                    //blank
                    [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:header_record_local_id SF_id:@"" record_type:MASTER operation:INSERT object_name:headerObjName sync_flag:@"false" parentObjectName:@"" parent_loacl_id:@""];
                    
                    for (int i=0;i<[details count];i++) //parts, labor, expense for instance
                    {
                        NSDictionary *detail = [details objectAtIndex:i];
                        
                       // NSArray * fields_array = [detail  objectForKey:gDETAILS_FIELDS_ARRAY];
                        NSArray *details_values = [detail objectForKey:gDETAILS_VALUES_ARRAY];
                        NSString * detail_layout_id = [detail objectForKey:gDETAILS_LAYOUT_ID];
                        NSString * detail_object_name = [detail objectForKey:gDETAIL_OBJECT_NAME];
                        
                        
                        //call database method to 
                        NSMutableDictionary * detail_fields_dict  = [appDelegate.databaseInterface getAllObjectFields:detail_object_name tableName:SFOBJECTFIELD]; //method to get the all the fields from the objectField table
                        
                        NSMutableDictionary * process_components = [appDelegate.databaseInterface  getProcessComponentsForComponentType:TARGETCHILD process_id:processId layoutId:detail_layout_id objectName:detail_object_name];
                        //[appDelegate.databaseInterface  getValueMappingForlayoutId:detail_layout_id process_id:processId objectName:detail_object_name];
                        
                        NSMutableDictionary * detail_object_mapping_dict = [appDelegate.databaseInterface getObjectMappingForMappingId:process_components mappingType:VALUE_MAPPING];
                        
                        NSArray * detail_object_mapping_keys = [detail_object_mapping_dict allKeys];
                        NSString *parent_column_name = [detail objectForKey:gDETAIL_HEADER_REFERENCE_FIELD];//[appDelegate.databaseInterface getParentColumnNameFormChildInfoTable:SFChildRelationShip childApiName:detail_object_name parentApiName:headerObjName];
                        
                        for (int j=0;j<[details_values count];j++) //parts for instance
                        {
                            NSArray * child_record_fields = [details_values objectAtIndex:j];
                            
                            NSMutableDictionary * sfm_detail_field_keyValue = [[NSMutableDictionary alloc] initWithCapacity:0];
                            
                            for (int k = 0; k < [child_record_fields count];k++) //fields of one part for instance
                            {
                                NSDictionary * field = [child_record_fields objectAtIndex:k];
                                NSString * detail_api_name = [field objectForKey:gVALUE_FIELD_API_NAME];
                                NSString * deatail_value = [field objectForKey:gVALUE_FIELD_VALUE_KEY];
                                [sfm_detail_field_keyValue setObject:deatail_value forKey:detail_api_name];
                            }
                            
                            //fill for each row
                            NSArray * detail_field_keys = [detail_fields_dict allKeys];
                            for(int p = 0 ; p < [detail_field_keys count]; p++)
                            {
                                NSString * detail_field_api_name = [detail_field_keys objectAtIndex:p];
                                
                                for(NSString * detail_key in detail_object_mapping_keys )
                                {
                                     if([detail_field_api_name isEqualToString:detail_key])
                                     {
                                         NSString * key = [detail_object_mapping_dict objectForKey:detail_key];
                                         if(key == nil)
                                         {
                                             key = @"";
                                         }
                                         [detail_fields_dict setObject:key forKey:detail_field_api_name];
                                         break;
                                     }
                                    
                                }
                                
                            }
                            
                            NSArray * sfm_detail_field_keys = [sfm_detail_field_keyValue allKeys];
                            for(int p = 0 ; p  < [detail_field_keys count]; p++)
                            {
                                NSString * detail_field_api_name = [detail_field_keys objectAtIndex:p];
                                
                                for(NSString * sfm_field_key in sfm_detail_field_keys )
                                {
                                    if([detail_field_api_name isEqualToString:sfm_field_key])
                                    {
                                        NSString * key = [sfm_detail_field_keyValue objectForKey:sfm_field_key];
                                        if(key == nil)
                                        {
                                            key = @"";
                                        }
                                        [detail_fields_dict setObject:key forKey:detail_field_api_name];
                                         break;
                                    }
                                   
                                }
                                
                            }
                            //set newly created header object id in child table
                            for( int p= 0 ; p < [detail_field_keys count]; p++)
                            {
                                NSString * detail_field_api_name = [detail_field_keys objectAtIndex:p];
                                if([detail_field_api_name isEqualToString:parent_column_name])
                                {
                                    
                                    [detail_fields_dict setObject:header_record_local_id forKey:parent_column_name];
                                    break;;
                                }
                            }
                            
                            //get the GUID 
                            NSString * detail_record_local_id = [iServiceAppDelegate GetUUID];
                            [detail_fields_dict setObject:detail_record_local_id forKey:@"local_id"];
                            BOOL data_inserted = [appDelegate.databaseInterface insertdataIntoTable:detail_object_name data:detail_fields_dict];
                            
                            if(data_inserted )
                            {
                                SMLog(@"insertion success");
                              
                                [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:detail_record_local_id SF_id:@"" record_type:DETAIL  operation:INSERT object_name:detail_object_name sync_flag:@"false"  parentObjectName:headerObjName parent_loacl_id:header_record_local_id];

                            }
                            else
                            {
                                SMLog(@"insertion failed");
                            }
                            
                        }
                    }
                  
                    [self SaveRecordIntoPlist:header_record_local_id objectName:headerObjName];
                    //[appDelegate.wsInterface  CallIncrementalDataSync];
                  
                    [appDelegate callDataSync];
                                   
                }
                else
                {
                    //pop up the message saving failed 
                }
                
            }
            if([action_type isEqual:@"WEBSERVICE"])
            {
                
                // sahana Fix For Defect #5747
                
                //Code change for get pirce  ---> 11/06/2012   --- Time: 1:23 PM.
                NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
                NSArray * pagelevel_events = [hdr_object objectForKey:gHEADER_BUTTONS];
                NSString * action_desc = [buttonDict objectForKey:@"action_description"];


                for(int i = 0 ; i < [pagelevel_events count]; i++)
                {
                    NSDictionary * dict = [pagelevel_events objectAtIndex:i];
                    NSArray * local_ = [dict objectForKey:@"button_Events"];
                    NSDictionary * button_info  = [local_ objectAtIndex:0];
                    NSString * webServiceName = [button_info objectForKey:@"button_Event_Target_Call"];
                    NSString * title =  [dict objectForKey:@"button_Title"];
                    if([action_desc isEqualToString:title])
                    {
                        [self didInvokeWebService:webServiceName event_name:GETPRICE];
                        break;
                    }
                }
                               
                //Code change for get pirce  ---> 11/06/2012   --- Time: 1:23 PM.
                
                appDelegate.wsInterface.webservice_call = FALSE;
            }
            
            if([targetCall isEqualToString:cancel])
            {
                appDelegate.SFMPage = nil;
                appDelegate.SFMoffline = nil;
                [delegate BackOnSave];
            }
        }
    
        if([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"EDIT"] || [[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"SOURCETOTARGETONLYCHILDROWS"])
        {
            if([targetCall isEqualToString:save] || [targetCall isEqualToString:quick_save])
            {
                if ([targetCall isEqualToString:quick_save])
                {
                    [activity startAnimating];
                }
                
                [self pageLevelEventsForEvent:BEFORESAVE];
                [self pageLevelEventsForEvent:AFTERSAVE];
                
                NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
                
                NSArray * header_sections = [hdr_object objectForKey:@"hdr_Sections"];
                NSString * headerObjName = [hdr_object objectForKey:gHEADER_OBJECT_NAME];
                NSString * layout_id = [hdr_object objectForKey:gHEADER_HEADER_LAYOUT_ID];
                NSMutableDictionary * hdrData = [hdr_object objectForKey:gHEADER_DATA];
                NSString * processId = appDelegate.sfmPageController.processId;
                    
                
                BOOL error = FALSE;
                for (int i=0;i<[header_sections count];i++)
                {
                    NSDictionary * section = [header_sections objectAtIndex:i];
                    NSArray *section_fields = [section objectForKey:@"section_Fields"];
                    for (int j=0;j<[section_fields count];j++)
                    {
                        NSDictionary *section_field = [section_fields objectAtIndex:j];
                        
                        //add key values to SM_header_fields dictionary 
                        NSString * value = [section_field objectForKey:gFIELD_VALUE_VALUE];
                        NSString * dataType = [section_field objectForKey:gFIELD_DATA_TYPE];

                        BOOL required = [[section_field objectForKey:gFIELD_REQUIRED] boolValue];
                        if(required)
                        {
                            if([value length] == 0 )
                            {
                                error = TRUE;
                                break;
                            }
                        }
                        
                        if ([dataType isEqualToString:@"email"] )  //Shrinivas Fix for Email Validation 03/04/2012
                        {
                            BOOL result;
                            NSString * emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
                            NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
                            result = [emailTest evaluateWithObject:value];
                            
                            if (result == NO && [value length] > 0)
                            {
                                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:warning message:invalidEmail delegate:self cancelButtonTitle:alert_ok otherButtonTitles:nil, nil];
                                [alertView show];
                                [alertView release];

                                [self enableSFMUI];
                                return;
                            }
                            
                        }

                        
                    }        
                }
                if(error == TRUE)
                {
                    [self requireFieldWarning];
                    requiredFieldCheck = TRUE;
                    [self enableSFMUI];
                    return;
                }
                
                //child records
                BOOL line_error = FALSE;
                
                NSArray * details = [appDelegate.SFMPage objectForKey:gDETAILS]; //as many as number of lines sections
                
                for (int i=0;i<[details count];i++) //parts, labor, expense for instance
                {
                    NSDictionary *detail = [details objectAtIndex:i];
                    
                    NSArray * fields_array = [detail  objectForKey:gDETAILS_FIELDS_ARRAY];
                    NSArray *details_values = [detail objectForKey:gDETAILS_VALUES_ARRAY];
                    
                    for (int j=0;j<[details_values count];j++) //parts for instance
                    {
                        NSArray *child_record_fields = [details_values objectAtIndex:j];
                        for (int k = 0; k < [child_record_fields count];k++) //fields of one part for instance
                        {
                            NSDictionary * field = [child_record_fields objectAtIndex:k];
                            NSString * detail_api_name = [field objectForKey:gVALUE_FIELD_API_NAME];
                            NSString * deatil_value = [field objectForKey:gVALUE_FIELD_VALUE_VALUE];
                            for(int l = 0 ;l < [fields_array count]; l++)
                            {
                                NSDictionary *field_array_value = [fields_array  objectAtIndex:l];
                                BOOL required  = [[field_array_value objectForKey:gFIELD_REQUIRED]boolValue];
                                NSString * api_name = [field_array_value objectForKey:gFIELD_API_NAME];
                                if([api_name isEqualToString:detail_api_name])
                                {
                                    if(required)
                                    {
                                        if([deatil_value length]== 0)
                                        {
                                            line_error = TRUE; 
                                            //sahana TEMP chage
                                            break;
                                        }
                                    }
                                }
                                
                                if ([detail_api_name isEqualToString:@"SVMXC__Email__c"] )  //Shrinivas Fix for Email Validation 03/04/2012
                                {
                                    BOOL result;
                                    NSString * emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
                                    NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
                                    result = [emailTest evaluateWithObject:deatil_value];
                                    
                                    if (result == NO && [deatil_value length] > 0)
                                    {
                                        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:warning message:invalidEmail delegate:self cancelButtonTitle:alert_ok otherButtonTitles:nil, nil];
                                        [alertView show];
                                        [alertView release];

                                        [self enableSFMUI];
                                        return;
                                    }
                                }
                            }
                        }
                    }        
                }
                
                if(line_error)
                {
                    [self requireFieldWarning];
                    requiredFieldCheck = TRUE;
                    [self enableSFMUI];
                    return;
                }
                
                // write a method to Update  the SFM values into the table
                // for header fill all the fields and insert into object table
                
                NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGET process_id:processId layoutId:layout_id objectName:headerObjName];
                
                NSMutableDictionary * object_mapping_dict = [appDelegate.databaseInterface getObjectMappingForMappingId:process_components mappingType:VALUE_MAPPING];
                
                NSArray * object_mapping_keys = [object_mapping_dict allKeys];
                
                // collect all the fields  
                
                NSMutableDictionary * all_header_fields = [[NSMutableDictionary alloc] initWithCapacity:0];
                
                //override
                NSArray * header_data_allkeys  = [hdrData allKeys];
                
                for(int m = 0 ; m< [header_data_allkeys count] ; m++)
                {
                    NSString * header_data_key = [header_data_allkeys objectAtIndex:m];
                    NSString * object = [hdrData  objectForKey:header_data_key];
                    [all_header_fields  setObject:object forKey:header_data_key];
                }
                for(int i=0; i <[header_sections count] ;i++)
                {
                    NSDictionary * section_info = [header_sections objectAtIndex:i];
                    NSMutableArray * sectionFileds= [section_info objectForKey:@"section_Fields"];
                    
                    for(int j= 0;j<[sectionFileds count]; j++)
                    {
                        NSDictionary * field_info =[sectionFileds objectAtIndex:j];
                        NSString * filed_api_name = [field_info objectForKey:gFIELD_API_NAME];
                        NSString * field_value = [field_info objectForKey:gFIELD_VALUE_KEY];
                        //[api_names  addObject:filed_api_name];
                        if(field_value == nil)
                        {
                            field_value = @"";
                        }
                        [all_header_fields setObject:field_value forKey:filed_api_name];
                    }
                }
                NSArray * all_keys = [all_header_fields allKeys];
                for(NSString * mapping_key in object_mapping_keys)
                {
                    NSString * mapping_value = [ object_mapping_dict objectForKey:mapping_key];
                    BOOL mapping_flag = FALSE;
                    for(NSString * key in all_keys)
                    {
                       if([key isEqualToString:mapping_key])
                       {
                           NSString * value = [all_header_fields objectForKey:mapping_key];
						   NSString * temp_value = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
                           if([temp_value length] == 0 || temp_value == nil )
                           {
                               [ all_header_fields setObject:mapping_value forKey:mapping_key];
                           }
                           mapping_flag = TRUE;
                       }
                    }
                    if(!mapping_flag)
                    {
                        if(mapping_value == nil)
                        {
                            mapping_value = @"";
                        }
                        [ all_header_fields setObject:mapping_value forKey:mapping_key];
                    }
                }
                
                [ all_header_fields removeObjectForKey:@"Id"];
                [all_header_fields  removeObjectForKey:@"id"];
                
                NSDictionary * fields_dict = [appDelegate.databaseInterface getAllObjectFields:headerObjName tableName:SFOBJECTFIELD];
                NSArray * fields_array ; 
                fields_array = [fields_dict allKeys];
                NSArray * all_hdr_keys = [ all_header_fields  allKeys];
                for(NSString * header_key in all_hdr_keys)
                {
                    if(![fields_array containsObject:header_key])
                    {
                        [all_header_fields removeObjectForKey:header_key];
                    }
                }
                
                if([headerObjName isEqualToString:@"Event"])
                {
                    NSArray * all_event_keys = [all_header_fields allKeys];
                    if([all_event_keys containsObject:@"StartDateTime"] && [all_event_keys containsObject:@"EndDateTime"])
                    {
                
                        NSString * startDaterTime = [all_header_fields objectForKey:@"StartDateTime"];
                        NSString * endDateTime = [all_header_fields objectForKey:@"EndDateTime"];
                        NSDate * temp_startDateTime, * temp_enddatetime;
                        [all_header_fields setObject:startDaterTime forKey:@"ActivityDateTime"];
                        NSString * DurationInMinutes;
                        NSString * tmp_st_time = [[NSString alloc] initWithString:startDaterTime];
                        NSString * tmp_end_time = [[NSString alloc] initWithString:endDateTime];
                        tmp_st_time = [tmp_st_time stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                        tmp_st_time = [tmp_st_time stringByReplacingOccurrencesOfString:@".000Z" withString:@" "];
                        
                        tmp_end_time = [tmp_end_time stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                        tmp_end_time = [tmp_end_time stringByReplacingOccurrencesOfString:@".000Z" withString:@" "];
                        
                        NSDateFormatter * datetimeFormatter=[[[NSDateFormatter alloc]init]autorelease];
                        [datetimeFormatter  setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        NSTimeZone * gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                        [datetimeFormatter setTimeZone:gmt];
                        temp_startDateTime = [datetimeFormatter dateFromString:tmp_st_time];
                        temp_enddatetime = [datetimeFormatter dateFromString:tmp_end_time];
                        
                        NSTimeInterval interval;
                       
                        interval = [temp_enddatetime timeIntervalSinceDate:temp_startDateTime];
                    
                        [tmp_st_time release];
                        [tmp_end_time release];
                        if(interval > 0)
                        {
                            int duration_temp = interval/60;
                            DurationInMinutes = @"";
                            DurationInMinutes = [DurationInMinutes stringByAppendingFormat:@"%d",duration_temp];// [NSString stringWithFormat:@"%d",duration_temp];
                            
                            [all_header_fields setObject:DurationInMinutes forKey:@"DurationInMinutes"];
                        }
                        else
                        {
                            UIAlertView * Event_alert = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_error_message]  message:@"EndateTime is greater than StartDateTime Please" delegate:nil cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_RESCHEDULE_NO]  otherButtonTitles:nil, nil];
                            [Event_alert show];
                            [Event_alert release];
                            
                            [self enableSFMUI];
                            return;
                        }
                    }
                }
                    
                BOOL success_flag = [appDelegate.databaseInterface  UpdateTableforId:currentRecordId forObject:headerObjName data:all_header_fields];
                
                NSString *  id_value  =  [appDelegate.databaseInterface  checkforSalesForceIdForlocalId:headerObjName local_id:currentRecordId];
                
                id_value = [id_value stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                BOOL isSalesForceRecord = FALSE;
                
                if([id_value length] != 0)
                {
                   // return TRUE;
                    isSalesForceRecord = TRUE;
                }
                else
                {
                    //return FALSE;
                    isSalesForceRecord = FALSE;
                }
                if(isSalesForceRecord)
                {
                    BOOL does_exists = [appDelegate.databaseInterface DoesTrailerContainTheRecord:currentRecordId operation_type:UPDATE object_name:headerObjName];
                    if(!does_exists)
                    {
                        [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:currentRecordId SF_id:id_value record_type:MASTER operation:UPDATE object_name:headerObjName sync_flag:@"false" parentObjectName:@"" parent_loacl_id:@""];
                    }
                }
                //sahana need to remove below code
                success_flag = TRUE;
            
                if(success_flag)
                {
                    SMLog(@"Success");
                    
                    for (int i=0;i<[details count];i++) //parts, labor, expense for instance
                    {
                        NSDictionary *detail = [details objectAtIndex:i];
                        
                        // NSArray * fields_array = [detail  objectForKey:gDETAILS_FIELDS_ARRAY];
                        NSArray *details_values = [detail objectForKey:gDETAILS_VALUES_ARRAY];
                        NSArray * detail_values_ids = [detail objectForKey:gDETAIL_VALUES_RECORD_ID];
                        NSArray * detail_deleted_records = [detail objectForKey:gDETAIL_DELETED_RECORDS];
                        NSString * detail_layout_id = [detail objectForKey:gDETAILS_LAYOUT_ID];
                        NSString * detail_object_name = [detail objectForKey:gDETAIL_OBJECT_NAME];
                        
                        //call database method to 
                        NSMutableDictionary * detail_fields_dict  = [appDelegate.databaseInterface getAllObjectFields:detail_object_name tableName:SFOBJECTFIELD]; //method to get the all the fields from the objectField table
                        
                        NSMutableDictionary * process_components = [appDelegate.databaseInterface  getProcessComponentsForComponentType:TARGETCHILD process_id:processId layoutId:detail_layout_id objectName:detail_object_name];
                        
                        NSMutableDictionary * detail_object_mapping_dict = [appDelegate.databaseInterface getObjectMappingForMappingId:process_components mappingType:VALUE_MAPPING];
                        
                        NSArray * detail_object_mapping_keys = [detail_object_mapping_dict allKeys];
                        NSString *parent_column_name = [detail objectForKey:gDETAIL_HEADER_REFERENCE_FIELD];
                        //[appDelegate.databaseInterface getParentColumnNameFormChildInfoTable:SFChildRelationShip childApiName:detail_object_name parentApiName:headerObjName];
                        
                        
                        for (int j=0;j<[details_values count];j++) //parts for instance
                        {
                            NSArray * child_record_fields = [details_values objectAtIndex:j];
                            NSString * line_record_id = [detail_values_ids objectAtIndex:j];
                            
                            
                            if([line_record_id isEqualToString:@""])
                            {
                                NSMutableDictionary * sfm_detail_field_keyValue = [[NSMutableDictionary alloc] initWithCapacity:0];
                                
                                for (int k = 0; k < [child_record_fields count];k++) //fields of one part for instance
                                {
                                    NSDictionary * field = [child_record_fields objectAtIndex:k];
                                    NSString * detail_api_name = [field objectForKey:gVALUE_FIELD_API_NAME];
                                    NSString * deatail_value = [field objectForKey:gVALUE_FIELD_VALUE_KEY];
                                    
                                    if(deatail_value == nil)
                                    {
                                        deatail_value = @"";
                                    }
                                    [sfm_detail_field_keyValue setObject:deatail_value forKey:detail_api_name];
                                }
                                
                                //fill for each row
								//FILL OBJECTMAPPING VALUE 
                                NSArray * detail_field_keys = [detail_fields_dict allKeys];
                                for(int p = 0 ; p < [detail_field_keys count]; p++)
                                {
                                    NSString * detail_field_api_name = [detail_field_keys objectAtIndex:p];
                                    
                                    for(NSString * detail_key in detail_object_mapping_keys )
                                    {
                                        if([detail_field_api_name isEqualToString:detail_key])
                                        {
                                            NSString * key = [detail_object_mapping_dict objectForKey:detail_key];
                                            if(key == nil)
                                            {
                                                key = @"";
                                            }
                                            [detail_fields_dict setObject:key forKey:detail_field_api_name];
                                            break;
                                        }
                                    }
                                    
                                }
                                
                                NSArray * sfm_detail_field_keys = [sfm_detail_field_keyValue allKeys];
                                for(int p = 0 ; p  < [detail_field_keys count]; p++)
                                {
                                    NSString * detail_field_api_name = [detail_field_keys objectAtIndex:p];
                                    
                                    for(NSString * sfm_field_key in sfm_detail_field_keys )
                                    {
                                        if([detail_field_api_name isEqualToString:sfm_field_key])
                                        {
                                            NSString * key = [sfm_detail_field_keyValue objectForKey:sfm_field_key];
                                            if(key == nil)
                                            {
                                                key = @"";
                                            }
                                            [detail_fields_dict setObject:key forKey:detail_field_api_name];
                                            break;
                                        }
                                        
                                    }
                                    
                                }
                                //set newly created header object id in child table
                                for( int p= 0 ; p < [detail_field_keys count]; p++)
                                {
                                    NSString * detail_field_api_name = [detail_field_keys objectAtIndex:p];
                                    if([detail_field_api_name isEqualToString:parent_column_name])
                                    {
                                        [detail_fields_dict setObject:currentRecordId forKey:parent_column_name];
                                        break;;
                                    }
                                }
                                
                                //Save on Get Price Implementation starts 
                                NSArray * allkeys_sfm_detail_dict = [[detail_fields_dict allKeys] retain];
                                
                                
                                NSDictionary * fields_dict = [appDelegate.databaseInterface getAllObjectFields:detail_object_name tableName:SFOBJECTFIELD];
                                NSArray * fields_array ; 
                                fields_array = [fields_dict allKeys];
                                
                                for(NSString * str in allkeys_sfm_detail_dict)
                                {
                                    if(![fields_array containsObject:str])
                                    {
                                        [detail_fields_dict removeObjectForKey:str];
                                    }
                                }
                                
                                [allkeys_sfm_detail_dict release];
                                
                                //Save on Get Price Implementation Ends
                                
                                NSString * line_local_id = [iServiceAppDelegate GetUUID];
                                [detail_fields_dict  setObject:line_local_id forKey:@"local_id"];
                                
                                BOOL data_inserted = [appDelegate.databaseInterface insertdataIntoTable:detail_object_name data:detail_fields_dict];
                                
                                if(data_inserted )
                                {
                                    SMLog(@"insertion success");
                                    if(isSalesForceRecord)
                                    {
                                        //update  String SF_ID 
                                        
                                       // NSString * parent_SFId = [NSString stringWithFormat:@"SFID%@", id_value];
                                        [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:line_local_id SF_id:@"" record_type:DETAIL operation:INSERT object_name:detail_object_name sync_flag:@"false" parentObjectName:headerObjName parent_loacl_id:currentRecordId];
                                    }
                                    else
                                    {
                                        [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:line_local_id SF_id:@"" record_type:DETAIL operation:INSERT object_name:detail_object_name sync_flag:@"false" parentObjectName:headerObjName parent_loacl_id:currentRecordId];
                                    }
                                }
                                else
                                {
                                    SMLog(@"insertion failed");
                                }
                            
                            }
                            else
                            {
                                NSMutableDictionary * sfm_detail_field_keyValue = [[NSMutableDictionary alloc] initWithCapacity:0];
                                for (int k = 0; k < [child_record_fields count];k++) //fields of one part for instance
                                {
                                    NSDictionary * field = [child_record_fields objectAtIndex:k];
                                    NSString * detail_api_name = [field objectForKey:gVALUE_FIELD_API_NAME];
                                    NSString * deatail_value = [field objectForKey:gVALUE_FIELD_VALUE_KEY];
                                    if(deatail_value == nil)
                                    {
                                        deatail_value = @"";
                                    }
                                    [sfm_detail_field_keyValue setObject:deatail_value forKey:detail_api_name];
                                }

								//PLZ DONT DELETE THIS COMMENTED CODE
//                                NSArray * all_keys = [sfm_detail_field_keyValue allKeys];
//                                for(NSString * mapping_key in detail_object_mapping_keys)
//                                {
//                                    NSString * mapping_value = [ detail_object_mapping_dict objectForKey:mapping_key];
//                                    BOOL mapping_flag = FALSE;
//                                    for(NSString * key in all_keys)
//                                    {
//                                        if([key isEqualToString:mapping_key])
//                                        {
//                                            NSString * value = [sfm_detail_field_keyValue objectForKey:mapping_key];
//                                            if([value length] == 0 || value == nil)
//                                            {
//                                                [ sfm_detail_field_keyValue setObject:value forKey:mapping_key];
//                                            }
//                                            mapping_flag = TRUE;
//                                        }
//                                    }
//                                    if(!mapping_flag)
//                                    {
//                                        if(mapping_value == nil)
//                                        {
//                                            mapping_value = @"";
//                                        }
//
//                                        [sfm_detail_field_keyValue setObject:mapping_value forKey:mapping_key];
//                                    }
//                                }
                                
                                
                                NSArray * allkeys_sfm_detail_dict = [[sfm_detail_field_keyValue allKeys] retain];
                             
                                //before updating the record remove the local id  & details_saved_record
                                [sfm_detail_field_keyValue  removeObjectForKey:@"local_id"];
                                [sfm_detail_field_keyValue  removeObjectForKey:@"details_saved_record"];
                                                          
                                
                                
                                //Save on Get Price Implementation starts 
                                NSString * record_from_getPrice = nil;
                                
                                if([allkeys_sfm_detail_dict containsObject:@"_Id"])
                                {
                                    record_from_getPrice = [sfm_detail_field_keyValue objectForKey:@"_Id"];
                                }
                                
                                NSDictionary * fields_dict = [appDelegate.databaseInterface getAllObjectFields:detail_object_name tableName:SFOBJECTFIELD];
                                NSArray * fields_array ; 
                                fields_array = [fields_dict allKeys];
                              
                                for(NSString * str in allkeys_sfm_detail_dict)
                                {
                                    if(![fields_array containsObject:str])
                                    {
                                        [sfm_detail_field_keyValue removeObjectForKey:str];
                                    }
                                }
                                
                                [allkeys_sfm_detail_dict release];
                                BOOL  check_for_new_id = FALSE;
                                if(record_from_getPrice != nil)
                                {
                                    // check for the occurance of record id 
                                    check_for_new_id = [appDelegate.dataBase  checkForDuplicateId:detail_object_name sfId:record_from_getPrice];
                                    if(check_for_new_id)
                                    {
                                        check_for_new_id = TRUE;
                                    }
                                    else
                                    {
                                        check_for_new_id = FALSE;
                                    }
                                }
                                
                                if(check_for_new_id)
                                {
                                    //if record from get preice event then insert it  bec it is is SF record
                                    [detail_fields_dict  setObject:line_record_id forKey:@"local_id"];
                                    [detail_fields_dict   setObject:record_from_getPrice forKey:@"Id"];
                                                                    
                                    //set newly created header object id in child table
                                    [sfm_detail_field_keyValue setObject:currentRecordId forKey:parent_column_name];
                                    
                                    BOOL data_inserted = [appDelegate.databaseInterface insertdataIntoTable:detail_object_name data:sfm_detail_field_keyValue];
                                    
                                    if(data_inserted )
                                    {
                                        SMLog(@"insertion success");
                                        if(isSalesForceRecord)
                                        {
                                            //update  String SF_ID 
                                            [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:line_record_id SF_id:@"" record_type:DETAIL operation:INSERT object_name:detail_object_name sync_flag:@"false" parentObjectName:headerObjName parent_loacl_id:currentRecordId];
                                        }
                                        else
                                        {
                                            [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:line_record_id SF_id:@"" record_type:DETAIL operation:INSERT object_name:detail_object_name sync_flag:@"false" parentObjectName:headerObjName parent_loacl_id:currentRecordId];
                                        }
                                    }
                                    else
                                    {
                                        SMLog(@"insertion failed");
                                    }
                                    //Save on Get Price Implementation Ends 
                                }
                                else
                                {
                                
                                    BOOL detail_success_flag = [appDelegate.databaseInterface  UpdateTableforId:line_record_id forObject:detail_object_name data:sfm_detail_field_keyValue];
                                    if(detail_success_flag)
                                    {
                                        SMLog(@"detail Update succeded");
                                        //check whether the record is Salesforce record if it is insert into Data Trailer table
                                        
                                        NSString * childSfId = [appDelegate.databaseInterface checkforSalesForceIdForlocalId:detail_object_name local_id:line_record_id];
                                        
                                        childSfId = [childSfId stringByReplacingOccurrencesOfString:@" " withString:@""];
                                        
                                        BOOL child_isSalesForceRecord = FALSE;
                                        
                                        if([childSfId length] != 0)
                                        {
                                            // return TRUE;
                                            child_isSalesForceRecord = TRUE;
                                        }
                                        else
                                        {
                                            //return FALSE;
                                            child_isSalesForceRecord = FALSE;
                                        }
                                        
                                        //check whether the entry exists for an  id  in the DataTrailer table  if it exists dont insert it again 
                                        BOOL does_exists = [appDelegate.databaseInterface  DoesTrailerContainTheRecord:line_record_id operation_type:UPDATE object_name:detail_object_name];
                                        if(!does_exists)
                                        {
                                        
                                        
                                            if(child_isSalesForceRecord)
                                            {
                                                if(isSalesForceRecord)
                                                {
                                                    [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:line_record_id SF_id:childSfId record_type:DETAIL operation:UPDATE object_name:detail_object_name sync_flag:@"false" parentObjectName:headerObjName parent_loacl_id:currentRecordId];//idvalue
                                                }
                                            }
                                            else
                                            {
                                                [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:line_record_id SF_id:@"" record_type:DETAIL operation:UPDATE object_name:detail_object_name sync_flag:@"false" parentObjectName:headerObjName parent_loacl_id:currentRecordId];

                                        }
                                    }

                                    }
                                    else
                                    {
                                        SMLog(@"detail Update failed");
                                    }
                                }
                            }
                        }
                        
                        //delete all the detail deleted records in the table 
                        
                        [self UpdateAlldeletedRecordsIntoSFTrailerTable:detail_deleted_records  object_name:detail_object_name];
                    }
                    [appDelegate callDataSync];
                }
                else
                {
                      SMLog(@"failed");
                }
                
            }
            if([targetCall isEqualToString:save])
            {
                NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
                NSString * headerObjName = [hdr_object objectForKey:gHEADER_OBJECT_NAME];
                if([appDelegate.sfmPageController.sourceProcessId length] == 0 && [appDelegate.sfmPageController.sourceRecordId length] == 0)
                {
                    if([headerObjName isEqualToString:@"Event"])
                    {
                        appDelegate.SFMPage = nil;
                        appDelegate.SFMoffline = nil;
                        [delegate BackOnSave];
                        return;
                    }
                }
                
                [self initAllrequriredDetailsForProcessId:appDelegate.sfmPageController.sourceProcessId recordId:appDelegate.sfmPageController.recordId object_name:headerObjName];
                [self fillSFMdictForOfflineforProcess:appDelegate.sfmPageController.sourceProcessId forRecord:appDelegate.sfmPageController.recordId ];
                [self didReceivePageLayoutOffline]; 
            }

            if([targetCall isEqualToString:cancel])
            {
                if([targetCall isEqualToString:cancel])
                {
                    appDelegate.SFMPage = nil;
                    appDelegate.SFMoffline = nil;
                    [delegate BackOnSave];
                }

            }
            
            
            if([action_type isEqual:@"WEBSERVICE"])
            {
                //Code change for get pirce  ---> 11/06/2012   --- Time: 1:23 PM.
                // sahana Fix For Defect #5747
                NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
                NSArray * pagelevel_events = [hdr_object objectForKey:gHEADER_BUTTONS];
                NSString * action_desc = [buttonDict objectForKey:@"action_description"];
                
                
                for(int i = 0 ; i < [pagelevel_events count]; i++)
                {
                    NSDictionary * dict = [pagelevel_events objectAtIndex:i];
                    NSArray * local_ = [dict objectForKey:@"button_Events"];
                    NSDictionary * button_info  = [local_ objectAtIndex:0];
                    NSString * webServiceName = [button_info objectForKey:@"button_Event_Target_Call"];
                    NSString * title =  [dict objectForKey:@"button_Title"];
                    if([action_desc isEqualToString:title])
                    {
                        [self didInvokeWebService:webServiceName event_name:GETPRICE];
                        break;
                    }
                }
                
                appDelegate.wsInterface.webservice_call = FALSE;
            }
            if([targetCall isEqualToString:quick_save])
            {
                [activity startAnimating];
                [self fillSFMdictForOfflineforProcess:appDelegate.sfmPageController.processId forRecord:appDelegate.sfmPageController.recordId ];
                [self didReceivePageLayoutOffline];
            }
            [activity stopAnimating];
        }
    
        if([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"SOURCETOTARGET"])
        {
            //write a method to  save the header and lines 
            if([targetCall isEqualToString:save])
            {
                
                [self pageLevelEventsForEvent:BEFORESAVE];
                [self pageLevelEventsForEvent:AFTERSAVE];
                
                NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
                
                NSArray * header_sections = [hdr_object objectForKey:@"hdr_Sections"];
                NSString * headerObjName = [hdr_object objectForKey:gHEADER_OBJECT_NAME];
                NSString * layout_id = [hdr_object objectForKey:gHEADER_HEADER_LAYOUT_ID];
                NSString * processId = appDelegate.sfmPageController.processId;
                NSMutableDictionary * SFM_header_fields = [[NSMutableDictionary alloc] initWithCapacity:0];
                
                BOOL error = FALSE;
                for (int i=0;i<[header_sections count];i++)
                {
                    NSDictionary * section = [header_sections objectAtIndex:i];
                    NSArray *section_fields = [section objectForKey:@"section_Fields"];
                    for (int j=0;j<[section_fields count];j++)
                    {
                        NSDictionary *section_field = [section_fields objectAtIndex:j];
                        
                        //add key values to SM_header_fields dictionary 
                        NSString * field_api = ([section_field objectForKey:gFIELD_API_NAME] != nil)?[section_field objectForKey:gFIELD_API_NAME]:@"";
                        NSString * value = [section_field objectForKey:gFIELD_VALUE_VALUE];
                        NSString * key = ([section_field objectForKey:gFIELD_VALUE_KEY] != nil)?[section_field objectForKey:gFIELD_VALUE_KEY]:@"";
                        NSString * dataType = [section_field objectForKey:gFIELD_DATA_TYPE];
                        [SFM_header_fields setObject:key forKey:field_api];
                        BOOL readOnly = [[section_field objectForKey:gFIELD_READ_ONLY] boolValue];
                        BOOL required = [[section_field objectForKey:gFIELD_REQUIRED] boolValue];
                        if(readOnly && required)
                        {
                            continue;
                        }
                        if(required)
                        {
                            if([value length] == 0 )
                            {
                                error = TRUE;
                                //sahana TEMP change
                                break;
                            }
                        }
                        
                        if ([dataType isEqualToString:@"email"] )  //Shrinivas Fix for Email Validation 03/04/2012
                        {
                            BOOL result;
                            NSString * emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
                            NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
                            result = [emailTest evaluateWithObject:value];
                            
                            if (result == NO && [value length] > 0)
                            {
                                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:warning message:invalidEmail delegate:self cancelButtonTitle:alert_ok otherButtonTitles:nil, nil];
                                [alertView show];
                                [alertView release];

                                [self enableSFMUI];
                                return;
                            }
                            
                        }
                    }        
                }
                if(error == TRUE)
                {
                    [self requireFieldWarning];
                    requiredFieldCheck = TRUE;
                    [self enableSFMUI];
                    return;
                }
                
                //child records
                BOOL line_error = FALSE;
                
                NSArray * details = [appDelegate.SFMPage objectForKey:gDETAILS]; //as many as number of lines sections
                
                for (int i=0;i<[details count];i++) //parts, labor, expense for instance
                {
                    NSDictionary *detail = [details objectAtIndex:i];
                    
                    NSArray * fields_array = [detail  objectForKey:gDETAILS_FIELDS_ARRAY];
                    NSArray *details_values = [detail objectForKey:gDETAILS_VALUES_ARRAY];
                    
                    for (int j=0;j<[details_values count];j++) //parts for instance
                    {
                        NSArray *child_record_fields = [details_values objectAtIndex:j];
                        for (int k = 0; k < [child_record_fields count];k++) //fields of one part for instance
                        {
                            NSDictionary * field = [child_record_fields objectAtIndex:k];
                            NSString * detail_api_name = [field objectForKey:gVALUE_FIELD_API_NAME];
                            NSString * deatil_value = [field objectForKey:gVALUE_FIELD_VALUE_VALUE];
                            for(int l = 0 ;l < [fields_array count]; l++)
                            {
                                NSDictionary *field_array_value = [fields_array  objectAtIndex:l];
                                BOOL required  = [[field_array_value objectForKey:gFIELD_REQUIRED]boolValue];
                                NSString * api_name = [field_array_value objectForKey:gFIELD_API_NAME];
                                if([api_name isEqualToString:detail_api_name])
                                {
                                    if(required)
                                    {
                                        if([deatil_value length]== 0)
                                        {
                                            line_error = TRUE; 
                                            //sahana TEMP chage
                                            break;
                                        }
                                    }
                                }
                                
                                if ([detail_api_name isEqualToString:@"SVMXC__Email__c"] )  //Shrinivas Fix for Email Validation 03/04/2012
                                {
                                    BOOL result;
                                    NSString * emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
                                    NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
                                    result = [emailTest evaluateWithObject:deatil_value];
                                    
                                    if (result == NO && [deatil_value length] > 0)
                                    {
                                        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:warning message:invalidEmail delegate:self cancelButtonTitle:alert_ok otherButtonTitles:nil, nil];
                                        [alertView show];
                                        [alertView release];

                                        [self enableSFMUI];
                                        return;
                                    }
                                    
                                }

                            }
                        }
                    }        
                }
                
                if(line_error)
                {
                    [self requireFieldWarning];
                    requiredFieldCheck = TRUE;
                    [self enableSFMUI];
                    return;
                }

                
                NSMutableDictionary * header_fields_dict  = [appDelegate.databaseInterface getAllObjectFields:headerObjName tableName:SFOBJECTFIELD]; //method to get the all the fields from the objectField table
                
                NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGET process_id:processId layoutId:layout_id objectName:headerObjName];
                
                //[appDelegate.databaseInterface  getValueMappingForlayoutId:layout_id process_id:processId objectName:headerObjName];
                
                NSMutableArray * object_mapping_dict= [[appDelegate.databaseInterface getObjectMappingForMappingId:process_components source_record_id:appDelegate.sfmPageController.sourceRecordId field_name:@"local_id"] retain];
                
               // NSString * source_parent_api_name = [process_components objectForKey:]
                NSMutableDictionary * headerValueDict = nil ;
                if([object_mapping_dict count] != 0)
                {
                    headerValueDict = [object_mapping_dict objectAtIndex:0];
                }
                
                
                NSArray *  object_mapping_keys = [headerValueDict allKeys];
                
                // First fill all fileds with default values from  objectMapping table
                
                NSArray * header_object_keys = [header_fields_dict allKeys]; 
                NSString * value = @"";
               
                
                
                for(int i =0 ; i < [header_object_keys count]; i++)
                {
                    NSString * key = [header_object_keys objectAtIndex:i];
                    
                    for(NSString * object_mapping_key in object_mapping_keys)
                    {
                        if([key isEqualToString:object_mapping_key])
                        {
                            value = [headerValueDict objectForKey:key];
                            if(value == nil)
                            {
                                value = @"";
                            }
                            [header_fields_dict setObject:value forKey:key];
                            break;
                        }
                    }
                }
                
                //after filling the default values fill the object tables fields with the sfm header fields keys
                NSArray * SFM_Header_keys = [SFM_header_fields allKeys];
                
                
                for(int i =0 ; i < [header_object_keys count]; i++)
                {
                    NSString * key = [header_object_keys objectAtIndex:i];
                    
                    for(NSString * sfm_header_field_key in SFM_Header_keys)
                    {
                        if([key isEqualToString:sfm_header_field_key])
                        {
                            value = [SFM_header_fields objectForKey:key];
                            
                            if(value == nil)
                            {
                                value = @"";
                            }
                            [header_fields_dict setObject:value forKey:key];
                            break;
                        }
                    }
                    
                }
                
                NSString * header_record_local_id = @"";
                header_record_local_id = [iServiceAppDelegate GetUUID];
                [header_fields_dict  setObject:header_record_local_id forKey:@"local_id"];
                
                if([headerObjName isEqualToString:@"Event"])
                {
                    appDelegate.databaseInterface.databaseInterfaceDelegate = self;
                    NSString * event_local_id = [appDelegate.databaseInterface getLocal_idFrom_Event_local_id];
                    if([event_local_id length] != 0)
                    {
                        header_record_local_id = event_local_id;
                        [header_fields_dict setObject:header_record_local_id forKey:@"local_id"];
                    }
                    
                }
                BOOL data_inserted = [appDelegate.databaseInterface insertdataIntoTable:headerObjName data:header_fields_dict];

                if(data_inserted)
                {
                   // NSString * header_record_local_id = [appDelegate.databaseInterface getTheRecordIdOfnewlyInsertedRecord:headerObjName]; 
                    //blank string
                    [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:header_record_local_id SF_id:@"" record_type:MASTER operation:INSERT object_name:headerObjName sync_flag:@"false" parentObjectName:@"" parent_loacl_id:@""];
                    
                    for (int i=0;i<[details count];i++) //parts, labor, expense for instance
                    {
                        NSDictionary *detail = [details objectAtIndex:i];
                        
    //                    NSArray * fields_array = [detail  objectForKey:gDETAILS_FIELDS_ARRAY];
                        NSArray *details_values = [detail objectForKey:gDETAILS_VALUES_ARRAY];
    //                    NSString * detail_layout_id = [detail objectForKey:gDETAILS_LAYOUT_ID];
                        NSString * detail_object_name = [detail objectForKey:gDETAIL_OBJECT_NAME];
                        NSString * header_reference_field_name = [detail objectForKey:gDETAIL_HEADER_REFERENCE_FIELD];
                        
                        
                        //call database method to 
                        NSMutableDictionary * detail_fields_dict  = [appDelegate.databaseInterface getAllObjectFields:detail_object_name tableName:SFOBJECTFIELD]; //method to get the all the fields from the objectField table
                        
                        NSArray * detail_field_keys = [detail_fields_dict allKeys];
                        
                        for (int j=0;j<[details_values count];j++) //parts for instance
                        {
                            NSArray * child_record_fields = [details_values objectAtIndex:j];
                            
                            NSMutableDictionary * sfm_detail_field_keyValue = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
                            
                            for (int k = 0; k < [child_record_fields count];k++) //fields of one part for instance
                            {
                                NSDictionary * field = [child_record_fields objectAtIndex:k];
                                NSString * detail_api_name = [field objectForKey:gVALUE_FIELD_API_NAME];
                                NSString * deatail_value = [field objectForKey:gVALUE_FIELD_VALUE_KEY];
                                if(deatail_value == nil)
                                {
                                    deatail_value = @"";
                                }

                                [sfm_detail_field_keyValue setObject:deatail_value forKey:detail_api_name];
                            }
                            
                            
                            NSArray * sfm_detail_field_keys = [sfm_detail_field_keyValue allKeys];
                            for(int p = 0 ; p  < [detail_field_keys count]; p++)
                            {
                                NSString * detail_field_api_name = [detail_field_keys objectAtIndex:p];
                                
                                for(NSString * sfm_field_key in sfm_detail_field_keys )
                                {
                                    if([detail_field_api_name isEqualToString:sfm_field_key])
                                    {
                                        NSString * key = [sfm_detail_field_keyValue objectForKey:sfm_field_key];
                                        if(key == nil)
                                        {
                                            key = @"";
                                        }

                                        [detail_fields_dict setObject:key forKey:detail_field_api_name];
                                        break;
                                    }
                                    
                                }
                            }
                            
                            //set newly created header object id in child table
                            for( int p= 0 ; p < [detail_field_keys count]; p++)
                            {
                                NSString * detail_field_api_name = [detail_field_keys objectAtIndex:p];
                                if([detail_field_api_name isEqualToString:header_reference_field_name])
                                {
                                    [detail_fields_dict setObject:header_record_local_id forKey:header_reference_field_name];
                                    break;;
                                }
                            }
                            
                           // NSString * 
                            
                            NSString * detail_local_id = [iServiceAppDelegate  GetUUID]; 
                            [detail_fields_dict  setObject:detail_local_id forKey:@"local_id"];
                            BOOL data_inserted = [appDelegate.databaseInterface insertdataIntoTable:detail_object_name data:detail_fields_dict];
                            
                            if(data_inserted )
                            {
                                 [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:detail_local_id SF_id:@"" record_type:DETAIL operation:INSERT object_name:detail_object_name sync_flag:@"false" parentObjectName:headerObjName parent_loacl_id:header_record_local_id];
                                SMLog(@"insertion success");
                            }
                            else
                            {
                                SMLog(@"insertion failed");
                            }
                            
                        }
                    }
                    
                    [self SaveRecordIntoPlist:header_record_local_id objectName:headerObjName];
                    [appDelegate callDataSync];
                }
            }
            
            if([targetCall isEqualToString:cancel])
            {
                if([targetCall isEqualToString:cancel])
                {
                    appDelegate.SFMPage = nil;
                    appDelegate.SFMoffline = nil;
                    [delegate BackOnSave];
                }
            }
            if([action_type isEqual:@"WEBSERVICE"])
            {
                //Code change for get pirce  ---> 11/06/2012   --- Time: 1:23 PM.
                // sahana Fix For Defect #5747
                NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
                NSArray * pagelevel_events = [hdr_object objectForKey:gHEADER_BUTTONS];
                NSString * action_desc = [buttonDict objectForKey:@"action_description"];
                
                for(int i = 0 ; i < [pagelevel_events count]; i++)
                {
                    NSDictionary * dict = [pagelevel_events objectAtIndex:i];
                    NSArray * local_ = [dict objectForKey:@"button_Events"];
                    NSDictionary * button_info  = [local_ objectAtIndex:0];
                    NSString * webServiceName = [button_info objectForKey:@"button_Event_Target_Call"];
                    NSString * title =  [dict objectForKey:@"button_Title"];
                    if([action_desc isEqualToString:title])
                    {
                        [self didInvokeWebService:webServiceName event_name:GETPRICE];
                        break;
                    }
                }
                
                
                appDelegate.wsInterface.webservice_call = FALSE;
            }

        }  
    }
    else
    {
    	// Custom Actions for SFM Wizard
        SMLog(@"Call Custom Action ");
        if (![appDelegate isInternetConnectionAvailable])
        {
            [activity stopAnimating];
            appDelegate.shouldShowConnectivityStatus = TRUE;
            [appDelegate displayNoInternetAvailable];
            return;
        } 

        NSString *className = [buttonDict objectForKey:@"class_name"];
        NSString *methodName = [buttonDict objectForKey:@"method_name"];
        
        className = (className != nil) ? className : @"";
        methodName = (methodName != nil) ? methodName : @"";
        NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
        
        [dict setObject:className forKey:@"class_name"];
        [dict setObject:methodName forKey:@"method_name"];

        NSDictionary *dataDict = [appDelegate.SFMPage copy];
        [appDelegate goOnlineIfRequired];
        [appDelegate.wsInterface callCustomSFMAction:dataDict withData:dict];
        [dataDict release];
        //Code change for get pirce  ---> 11/06/2012   --- Time: 1:23 PM.
        
        appDelegate.wsInterface.webservice_call = FALSE;
        
        [activity startAnimating];
        appDelegate.wsInterface.getPrice = FALSE;
        SMLog(@" getPrice2");
        while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, FALSE))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"DetailViewController.m : offlineActions: customAction");
#endif

            if (![appDelegate isInternetConnectionAvailable])
            {
                appDelegate.wsInterface.getPrice = TRUE;
                [activity stopAnimating];
                [self enableSFMUI];
                return;
            }
            
            if (appDelegate.wsInterface.getPrice == TRUE)
            {
                appDelegate.wsInterface.getPrice = FALSE; 
                break;
            }
            
			if (appDelegate.connection_error)
			{
				break;
			}
        }
        
        BOOL performSync = [[buttonDict objectForKey:@"perform_sync"] boolValue];
        if(performSync && !(appDelegate.connection_error))
        {
            if([appDelegate dataSyncRunning])
            {
                SMLog(@"Wait For Data Sync to Finish");
                while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, FALSE))
                {
#ifdef kPrintLogsDuringWebServiceCall
                    SMLog(@"DetailViewController.m : offlineActions: datasync thread status check");
#endif

                    if (appDelegate.dataSyncRunning == NO)
                    {
                        break;
                    }
                }
            }
            appDelegate.dataSyncRunning = YES;
            [activity startAnimating];
            [appDelegate callDataSync];
            while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, FALSE))
            {
#ifdef kPrintLogsDuringWebServiceCall
                SMLog(@"DetailViewController.m : offlineActions: datasync thread status check 2");
#endif

                if (![appDelegate isInternetConnectionAvailable])
                {
                    [activity stopAnimating];
                    SMLog(@"Data Sync stopper due to Internet Connection Failure");
                    return;
                }
                
                if (appDelegate.dataSyncRunning == NO)
                {
                    SMLog(@"Data Sync Completed ");
                    break;
                }
                if (appDelegate.connection_error)
                {
                    break;
                }

            }
            [self.tableView reloadData];
            [appDelegate.sfmPageController.rootView refreshTable];
            [self  didselectSection:0];    
        }
        /*
        [self.tableView reloadData];
        [appDelegate.sfmPageController.rootView refreshTable];
        [self  didselectSection:0];    
         */
        [activity stopAnimating];
        [appDelegate ScheduleIncrementalDatasyncTimer];
        [appDelegate ScheduleIncrementalMetaSyncTimer];
        [appDelegate ScheduleTimerForEventSync];
    
    }
    
    [self enableSFMUI];
    
}

-(void) initAllrequriredDetailsForProcessId:(NSString *)process_id recordId:(NSString *)recordId object_name:(NSString *)object_name
{
    appDelegate.sfmPageController.recordId = recordId;
    appDelegate.sfmPageController.processId = process_id;
    
    appDelegate.sfmPageController.objectName = object_name;
    currentRecordId  = recordId;
    currentProcessId = process_id;
}
-(void) initAllrequiredDetailsForSourceToTargetForProcessId:(NSString *)processId record_id:(NSString *)record_id object_name:(NSString *)object_name
{
    
}


-(NSString *)getValueForApiName:(NSString *)filed_api_name dataType:(NSString *)field_data_type  object_name:(NSString *)object_name field_key:(NSString *) field_key
{
    
    NSString * field_value = @"";
    if([field_data_type isEqualToString:@"picklist"])
    {
        //query to acces the picklist values for lines 
        NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:filed_api_name tableName:SFPicklist objectName:object_name];
        NSArray * allKeys = [picklistValues allKeys];
        for(NSString * value_dict in allKeys)
        {
            if([value_dict isEqualToString:field_key])
            {
                field_value =[picklistValues objectForKey:field_key];
                break;
            }
        }
    }
    else if([field_data_type isEqualToString:@"reference"] && [filed_api_name isEqualToString:@"RecordTypeId"])
    {
        field_value = [appDelegate.databaseInterface getRecordTypeNameForObject:object_name forId:field_key];
        
    }
    else if([field_data_type isEqualToString:@"reference"])
    {
        if([field_key isEqualToString:@""] || [field_key length ] == 0 || field_key == nil )
        {
            field_value = field_key;
        }
        else
        {
            NSMutableArray * referenceTotableNames = [appDelegate.databaseInterface getReferenceToForField:filed_api_name objectapiName:object_name tableName:SF_REFERENCE_TO];
            
                       
            if([referenceTotableNames count ] > 0)
            {
                NSString * reference_to_tableName = [referenceTotableNames objectAtIndex:0];
                
                NSString * referenceTo_Table_fieldName = [appDelegate.databaseInterface getFieldNameForReferenceTable:reference_to_tableName tableName:SFOBJECTFIELD];
                
                //field_value = [appDelegate.databaseInterface getReferencefield_valueFromReferenceToTable:reference_to_tableName field_name:referenceTo_Table_fieldName record_id:field_key];
                field_value = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:reference_to_tableName field_name:referenceTo_Table_fieldName record_id:field_key];
            }
            if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
            {
                field_value = [appDelegate.databaseInterface getLookUpNameForId:field_key];
                if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
                {
                    field_value = field_key;
                }
            }
        }
    }
    
    else if([field_data_type isEqualToString:@"datetime"])
    {
        NSString * date = field_key;
        date = [date stringByDeletingPathExtension];
        field_key = date;
        field_value = date;
    }
    
    else if([field_data_type isEqualToString:@"date"])
    {
        NSString * date = field_key;
        date = [date stringByDeletingPathExtension];
        field_key = date;
        field_value = date;
    }
    
    else if([field_data_type isEqualToString:@"multipicklist"])
    {
        NSArray * fieldKeys = [field_key componentsSeparatedByString:@";"];
        NSMutableArray * valuesArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        //query to acces the picklist values for lines 
        NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:filed_api_name tableName:SFPicklist objectName:object_name];
        
        NSArray * allKeys = [picklistValues allKeys];
        for(NSString * value_dict in allKeys)
        {
            for(NSString * key  in fieldKeys)
            {
                if([value_dict isEqualToString:key])
                {
                    [valuesArray addObject:[picklistValues objectForKey:key]];
                    break;
                }
            }
        }
        NSInteger count_ = 0;
        for(NSString * each_label in valuesArray)
        {
            if(count_ != 0)
                field_value = [field_value stringByAppendingString:@";"];
            field_value = [field_value stringByAppendingString:each_label];
            count_ ++;
            
        }
        
        if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
        {
            field_value = field_key;
        }
        
    }
    else
    {
        field_value = field_key;
    }
    
    return field_value;

}

-(void)SaveRecordIntoPlist:(NSString *)record_id objectName:(NSString *) object_name;
{
    NSDate * date = [NSDate date];
    NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
    [frm setDateFormat:DATETIMEFORMAT];
    NSString * date_str = [frm stringFromDate:date];
    
    NSString * object_label = [appDelegate.databaseInterface getObjectLabel:SFOBJECT objectApi_name:object_name];
    
    NSMutableDictionary * created_object_info = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    [created_object_info setObject:object_name forKey:OBJECT_NAME];
    NSString * process_id = @"";
  
    processInfo * pinfo =  [appDelegate getViewProcessForObject:object_name record_id:record_id processId:@"" isswitchProcess:FALSE];
    BOOL process_exist = pinfo.process_exists;
    process_id = pinfo.process_id;
    
    
    [created_object_info setObject:process_id forKey:gPROCESS_ID];
    [created_object_info setObject:date_str forKey:gDATE_TODAY];
    [created_object_info setObject:record_id forKey:RESULTID];
    //Need to changed when the proper incremental data sync happens.
    [created_object_info setObject:@"" forKey:NAME_FIELD];
    [created_object_info setObject:object_label forKey:OBJECT_LABEL];
    [appDelegate.wsInterface saveDictionaryToPList:created_object_info];

    
   if(process_exist)
   {
        [self initAllrequriredDetailsForProcessId:process_id recordId:record_id object_name:object_name];
        //check For view process
        [self fillSFMdictForOfflineforProcess:process_id forRecord:record_id ];
        [self didReceivePageLayoutOffline];
   }
    else
    {
        NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_no_pagelayout];
        NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
        NSString * Ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
        
        UIAlertView * alert1 = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:Ok otherButtonTitles:nil];
        [alert1 show];
        [alert1 release];
        return;
        
    }
     
}

//Abinash Fix
-(NSArray *)orderingAnArray:(NSArray *)array
{
    NSArray * arr = nil;
    NSMutableArray * sortedArray = [[[NSMutableArray alloc] initWithArray:array] autorelease];
    int i = 0;
    for (i = 0; i < [sortedArray count] - 1; i++)
    {
        
        for (int j = 0; j < ([sortedArray count] - (i +1)); j++)
        {
            NSString * label = [sortedArray objectAtIndex:j];
            NSString * label1;
            label1 = [sortedArray objectAtIndex:j+1];
            if (strcmp([label UTF8String], [label1 UTF8String]) > 0)
            {
                [sortedArray exchangeObjectAtIndex:j withObjectAtIndex:j+1];
            }
        }
    } 
    arr = sortedArray;
    return arr;
}

- (void) SeeMoreButtonClicked:(id)sender
{
    
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        appDelegate.shouldShowConnectivityStatus = TRUE;
        [appDelegate displayNoInternetAvailable];
        return;
    } 

    
    [activity startAnimating];
    [appDelegate goOnlineIfRequired];
    
    
    
    if ([appDelegate.syncThread isExecuting])
    {
        
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"DetailViewController.m : seeMoreButtonsClicked: checkfor Data Sync");
#endif

            if (![appDelegate isInternetConnectionAvailable])
            {
                break;
            }
            
            if ([appDelegate.syncThread isFinished])
            {
               // [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.datasync_timer];
                break;
            }
        }
    }
    else
    {
        if ([appDelegate.datasync_timer isValid])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.datasync_timer];
        }            
    }   

    
    
    if ([appDelegate.metaSyncThread isExecuting])
    {
        
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"DetailViewController.m : seeMoreButtonsClicked: checkfor Meta Sync");
#endif

            if (![appDelegate isInternetConnectionAvailable])
            {
                break;
            }
            
            if ([appDelegate.metaSyncThread isFinished])
            {
                //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.metasync_timer];
                break;
            }
        }
    }
    else
    {
        if ([appDelegate.metasync_timer isValid])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.metasync_timer];
        }            
    }   
    
    
    
    if ([appDelegate.event_thread isExecuting])
    {
        
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"DetailViewController.m : seeMoreButtonsClicked: checkfor Event Sync");
#endif

            if (![appDelegate isInternetConnectionAvailable])
            {
                break;
            }
            
            if ([appDelegate.event_thread isFinished])
            {
               // [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.event_timer];
                break;
            }
        }
    }
    else
    {
        if ([appDelegate.event_timer isValid])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.event_timer];
        }            
    }   


       
    UIButton *button = (UIButton *)sender;
    SMLog(@"%d", button.tag);
    //shrinivas
    NSString * Id = @"";
    NSString *query = [NSString stringWithFormat:@"Select Id From SVMXC__Service_Order__c Where local_id = '%@'", appDelegate.sfmPageController.recordId];
    sqlite3_stmt *stmt;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * _id = (char *) synchronized_sqlite3_column_text(stmt, 0);
            if (_id != nil && strlen(_id))
                Id = [NSString stringWithUTF8String:_id];
        }
    }

    if (button.tag == 1)
    {
        [appDelegate.wsInterface getProductHistoryForWorkOrderId:Id];
        
        appDelegate.wsInterface.didGetProductHistory = FALSE;
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"DetailViewController.m : seeMoreButtonsClicked: product History");
#endif

            if (appDelegate.wsInterface.didGetProductHistory == TRUE)
                break;
            if (![appDelegate isInternetConnectionAvailable])
                break;
            if (appDelegate.connection_error)
            {
                break;
            }
        }
        
        if ([appDelegate.wsInterface.productHistory count] > 0)
            [appDelegate.SFMPage setValue:appDelegate.wsInterface.productHistory forKey:PRODUCTHISTORY];
    }
    else if (button.tag == 2)
    {
        [appDelegate.wsInterface getAccountHistoryForWorkOrderId:Id];
        appDelegate.wsInterface.didGetAccountHistory = FALSE;
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(@"DetailViewController.m : seeMoreButtonsClicked: account history");
#endif

            if (appDelegate.wsInterface.didGetAccountHistory == TRUE)
                break;
            
            if (![appDelegate isInternetConnectionAvailable])
                break;
            if (appDelegate.connection_error)
            {
                break;
            }
        }
        if ([appDelegate.wsInterface.accountHistory count] > 0)
            [appDelegate.SFMPage setValue:appDelegate.wsInterface.accountHistory forKey:ACCOUNTHISTORY];
    }
    [activity stopAnimating];
    [self.tableView reloadData];
    [appDelegate ScheduleIncrementalMetaSyncTimer];
    [appDelegate ScheduleIncrementalDatasyncTimer];
    [appDelegate ScheduleTimerForEventSync];
} 

#pragma mark - Get Product Info
- (NSString *) getProductIdForRecordId:(NSString *)recordId
{
    NSString * query = [NSString stringWithFormat:@"SELECT SVMXC__Product__c FROM SVMXC__Service_Order__c WHERE local_id = '%@'", recordId];
 
    NSString * productId = @"";
    sqlite3_stmt *stmt;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
             char * _productId = (char *) synchronized_sqlite3_column_text(stmt, 0);
             if (_productId != nil && strlen(_productId))
                productId = [NSString stringWithUTF8String:_productId];
        }
    }
        
    return productId;
}

-(NSString *) getProductNameForId:(NSString *)productId
{
    NSString * query = [NSString stringWithFormat:@"SELECT Name FROM Product2 WHERE Id = '%@'", productId];
     
    NSString * productName = @"";
    
    sqlite3_stmt *stmt;
    if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
        {
            char * _productName = (char *) synchronized_sqlite3_column_text(stmt, 0);
            if (_productName != nil && strlen(_productName))
                productName = [NSString stringWithUTF8String:_productName];
            else
                productName = @"";
        }
    }
    
    if ([productName isEqualToString:@""])
    {
        query = [NSString stringWithFormat:@"SELECT value FROM LookUpFieldValue WHERE Id = '%@'", productId];
        
        if (synchronized_sqlite3_prepare_v2(appDelegate.db, [query UTF8String], -1, &stmt, NULL) == SQLITE_OK)
        {
            if (synchronized_sqlite3_step(stmt) == SQLITE_ROW)
            {
                char * _productName = (char *) synchronized_sqlite3_column_text(stmt, 0);
                if (_productName != nil && strlen(_productName))
                    productName = [NSString stringWithUTF8String:_productName];
                else
                    productName = @"";
            }
        }
    }
    return productName;
}

-(void)UpdateAlldeletedRecordsIntoSFTrailerTable:(NSArray *)deleted_record_array   object_name:(NSString *)object_name
{
    for(int i = 0; i < [deleted_record_array count]; i++)
    {
        NSString  * deleted_record_id =   [deleted_record_array objectAtIndex:i];
        NSString * sf_id_for_deleted_record  = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:object_name local_id:deleted_record_id];
        
        if(![sf_id_for_deleted_record isEqualToString:@""])
        {
            BOOL delete_Flag = [appDelegate.databaseInterface DeleterecordFromTable:object_name Forlocal_id:deleted_record_id];
            
            if(delete_Flag)
            {
                [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:deleted_record_id SF_id:sf_id_for_deleted_record record_type:DETAIL operation:DELETE object_name:object_name sync_flag:@"false" parentObjectName:@"" parent_loacl_id:@""];
            }
        }
    }
    
}

-(void) manualDataSync:(id) sender
{
    /*ManualDataSync *manualDataSync = [[ManualDataSync alloc] initWithNibName:@"ManualDataSync" bundle:nil];
    
    manualDataSync.modalPresentationStyle = UIModalPresentationFullScreen;
    manualDataSync.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [(SFMPageController *)delegate presentViewController:manualDataSync animated:YES];

    [manualDataSync release];*/
}
- (void) showManualSyncScreen
{
    ManualDataSync *manualDataSync = [[[ManualDataSync alloc] initWithNibName:@"ManualDataSync" bundle:nil] autorelease];
    
    manualDataSync.modalPresentationStyle = UIModalPresentationFullScreen;
    manualDataSync.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    
    [(SFMPageController *)delegate presentViewController:manualDataSync animated:YES completion:nil];
}

-(void)singleTapOncusLabel:(id)cusLabel
{
    if([cusLabel isKindOfClass:[CusLabel  class]])
    {
        CusLabel * label = (CusLabel *)cusLabel;
        if(label.text == nil)
            return;
        //if the text length is 0 then dont show the popover
        if([label.text length] == 0)
            return;
        
        // content View class
        label_popOver_content = [[LabelPOContentView alloc ] init];
        
        // calculating the size for the popover
        UIFont * font = [UIFont systemFontOfSize:17.0];
        CGSize size =[label.text  sizeWithFont:font];
        
        //subview for the content view
        UITextView * contentView_textView;
        if(size.width > 240)
        {
            label_popOver_content.view.frame = CGRectMake(0, 0, label_popOver_content.view.frame.size.width, 90);
            contentView_textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, label_popOver_content.view.frame.size.width, 90)];
        }
        else
        {
            label_popOver_content.view.frame = CGRectMake(0, 0, label_popOver_content.view.frame.size.width, 34);
            contentView_textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, label_popOver_content.view.frame.size.width, 34)];  
        }
        
        contentView_textView.text = label.tapRecgLabel;
        contentView_textView.font = font;
        contentView_textView.userInteractionEnabled = YES;
        contentView_textView.editable = NO;
        contentView_textView.textAlignment = UITextAlignmentCenter;
        [label_popOver_content.view addSubview:contentView_textView];
        
        CGSize size_po = CGSizeMake(label_popOver_content.view.frame.size.width, label_popOver_content.view.frame.size.height);
        label_popOver = [[UIPopoverController alloc] initWithContentViewController:label_popOver_content];
        [label_popOver setPopoverContentSize:size_po animated:YES];
        
        label_popOver.delegate = self;
        
        [label_popOver presentPopoverFromRect:CGRectMake(label.frame.size.width/2,0, 10, 10) inView:label permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        [contentView_textView release];
        [label_popOver_content release];
        
    }
    
    
}
-(void)doubleTapOnCusLabel:(id)cusLabel
{
    if ([cusLabel isKindOfClass:[UILabel  class]])    
    {
        CusLabel * label = (CusLabel *) cusLabel;
        if(label.text == nil)
            return;
        //if the text length is 0 then dont show the popover
        if([label.text length] == 0)
            return;
        
        NSString * reffered_to_table_name = label.refered_to_table_name;
        NSString * temp_record_id = label.id_;

        //Radha 2012june08 08:00
        BOOL recordExists = [appDelegate.dataBase checkIfRecordExistForObject:reffered_to_table_name Id:temp_record_id];
        if (recordExists == FALSE)
            return;
    
        NSString * record_id = [appDelegate.databaseInterface  getLocalIdFromSFId:temp_record_id tableName:reffered_to_table_name];
        
        NSString * newProcessId = @"";
        for (int j = 0; j < [appDelegate.view_layout_array count]; j++)
        {
            NSDictionary * viewLayoutDict = [appDelegate.view_layout_array objectAtIndex:j];
            NSString * objName = [viewLayoutDict objectForKey:VIEW_OBJECTNAME];
            if ([objName isEqualToString:reffered_to_table_name])
            {
                newProcessId = [viewLayoutDict objectForKey:@"SVMXC__ProcessID__c"];
                break;
            }
        }
        
        if([newProcessId length] != 0 && newProcessId != nil && [record_id length] != 0 && record_id  != nil )
        {
            appDelegate.oldRecordId = currentRecordId;
            appDelegate.oldProcessId = currentProcessId;
            if(isInEditDetail)
            {
                [self initAllrequriredDetailsForProcessId:newProcessId recordId:record_id object_name:reffered_to_table_name];
                [parentReference fillSFMdictForOfflineforProcess:newProcessId forRecord:record_id ];
                [parentReference didReceivePageLayoutOffline];
            }
            else
            {
                [self initAllrequriredDetailsForProcessId:newProcessId recordId:record_id object_name:reffered_to_table_name];
                [self fillSFMdictForOfflineforProcess:newProcessId forRecord:record_id ];
                [self didReceivePageLayoutOffline];
            }

        }
//        else
//        {
//            NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:sync_referred_record_error];
//            NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_synchronize_error];
//            NSString * Ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
//            
//            
//            UIAlertView * alert_view = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:Ok otherButtonTitles:nil, nil];
//            [alert_view  show];
//            [alert_view release];  //Inconsistent Crash
//
//            
//        }
    }
    
}

-(NSInteger)getControlFieldPickListIndexForControlledPicklist:(NSString *)fieldApi_name atIndexPath:(NSIndexPath *)indexPath controlType:(NSString *)controlType
{
    
    if (!isInEditDetail)
    {
        // Determine if section is SHOWALLHEADER or SHOWHEADERSECTION and only then set dictionary value for fieldAPIName key
        // Header will have array of dictionaries
        // fetch the dictionary based on the indexPath and control in that row being edited
        // update dictionary value for key (fieldAPIName)
        if (selectedSection == SHOW_HEADER_ROW || selectedSection == SHOWALL_HEADERS)
        {
//            int section = indexPath.section;
//            int index = 0;
//            
//            if (isDefault)
//                index = section;
//            else
//                index = selectedRow;
            
         
            NSMutableDictionary *_header = [appDelegate.SFMPage objectForKey:gHEADER];
            NSMutableArray *header_sections = [_header objectForKey:gHEADER_SECTIONS];
            
                      
            for(int i=0; i <[header_sections count] ;i++)
            {
                NSDictionary * section_info = [header_sections objectAtIndex:i];
                NSMutableArray * sectionFileds= [section_info objectForKey:@"section_Fields"];
                
                for(int j= 0;j<[sectionFileds count]; j++)
                {
                    NSMutableDictionary * filed_info =[sectionFileds objectAtIndex:j];
                    NSString * filed_api_name = [filed_info objectForKey:gFIELD_API_NAME];
                    NSString * control_type = [filed_info objectForKey:gFIELD_DATA_TYPE];
                    NSString * dict_value = [filed_info objectForKey:gFIELD_VALUE_VALUE];
                    
                    if([filed_api_name isEqualToString:fieldApi_name])
                    {
                        if([control_type isEqualToString:@"picklist"])
                        {
                            SMLog(@"DictValue %@" , dict_value);
                            /*for (int i = 0; i < [appDelegate.describeObjectsArray count]; i++)
                            {
                                ZKDescribeSObject * descObj = [appDelegate.describeObjectsArray objectAtIndex:i];
                                ZKDescribeField * descField = [descObj fieldWithName:filed_api_name];
                                if (descField == nil)
                                    continue;
                                else
                                {   
                                    NSArray * pickListEntryArray = [descField picklistValues];
                                   
                                    for (int k = 0; k < [pickListEntryArray count]; k++)
                                    {
                                        NSString * value = [[pickListEntryArray objectAtIndex:k] label];
                                        if([dict_value isEqualToString:value])
                                        {
                                            return k;
                                        }
                                    }
                                    return 9999999;
                                    break;
                                }
                            }*/
                            
                            NSMutableDictionary * _header =  [appDelegate.SFMPage objectForKey:@"header"];
                            NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];
                            
                            //query to acces the picklist values for lines 
                          /*  NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:filed_api_name tableName:SFPicklist objectName:headerObjName];
                            
                            
                            NSArray * allvalues = [picklistValues allValues];
                            NSArray * allkeys = [picklistValues allKeys];
                            
                            for(int i =0; i<[picklistValues count];i++)
                            {
                                NSString * value = [allvalues objectAtIndex:i];
                                if([value isEqualToString:dict_value])
                                {
                                    return 0;
                                }
                            } */
                            
                            int index_value = [appDelegate.databaseInterface getIndexOfPicklistValueForOject_Name:headerObjName field_api_name:fieldApi_name value:dict_value];
                                
                            return index_value;
                            
                            
                        }
                        if([control_type isEqualToString:@"boolean"])
                        {
                            if([dict_value isEqualToString:@"True"] || [dict_value isEqualToString:@"true"] || [dict_value isEqualToString:@"1"])
                            {
                                return 1;
                            }
                            else
                            {
                                return 0;
                            }
                        }
                        
                    }
                }
            }
        }
    }
    else
    {
        //sahana 26th sept 2011
        //control type
        NSMutableArray * array = [Disclosure_dict objectForKey:gDETAILS_VALUES_ARRAY];
        NSMutableArray * detail_values = [array objectAtIndex:self.selectedRowForDetailEdit];
        
        for (int i = 0; i < [detail_values count]; i++)
        {
            NSString * value_Field_API = [[detail_values objectAtIndex:i] objectForKey:gVALUE_FIELD_API_NAME];
            NSString * dict_value =  [[detail_values objectAtIndex:i] objectForKey:gVALUE_FIELD_VALUE_VALUE];
            if([fieldApi_name isEqualToString:value_Field_API])
            {
                if([controlType isEqualToString: @"picklist"])
                {
                    /*for (int i = 0; i < [appDelegate.describeObjectsArray count]; i++)
                    {
                        ZKDescribeSObject * descObj = [appDelegate.describeObjectsArray objectAtIndex:i];
                        ZKDescribeField * descField = [descObj fieldWithName:value_Field_API];
                        if (descField == nil)
                            continue;
                        else
                        {   
                            
                            NSArray * pickListEntryArray = [descField picklistValues];
                            for (int k = 0; k < [pickListEntryArray count]; k++)
                            {
                                NSString * value = [[pickListEntryArray objectAtIndex:k] label];
                                if([dict_value isEqualToString:value])
                                {
                                    return k;
                                }
                            }
                            return 9999999;
                            break;
                        }
                    }*/
                    
                    
                   /* NSString * detailObjectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
                    //query to acces the picklist values for lines 
                    NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:value_Field_API tableName:SFPicklist objectName:detailObjectName];
                    
                    
                    NSArray * allvalues = [picklistValues allValues];
                    NSArray * allkeys = [picklistValues allKeys];
                    
                    for(int i =0; i<[picklistValues count];i++)
                    {
                        NSString * value = [allvalues objectAtIndex:i];
                        if([value isEqualToString:dict_value])
                        {
                            return i;
                        }
                    }
                    
                    return 9999999;*/
                    NSString * detailObjectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
                    
                    int index_value = [appDelegate.databaseInterface getIndexOfPicklistValueForOject_Name:detailObjectName field_api_name:value_Field_API value:dict_value];
                    
                    return index_value;
                }
                if([controlType isEqualToString:@"boolean"])
                {
                    if([dict_value isEqualToString:@"True"] || [dict_value isEqualToString:@"true"] || [dict_value isEqualToString:@"1"])
                    {
                        return 1;
                    }
                    else
                    {
                        return 0;
                    }
                }
            }
        }
    }
    return 9999999;
}
-(NSMutableDictionary *)getRecordTypeIdAndObjectNameForCellAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableDictionary * return_dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    if (!isInEditDetail)
    {
        // Determine if section is SHOWALLHEADER or SHOWHEADERSECTION and only then set dictionary value for fieldAPIName key
        // Header will have array of dictionaries
        // fetch the dictionary based on the indexPath and control in that row being edited
        // update dictionary value for key (fieldAPIName)
        if (selectedSection == SHOW_HEADER_ROW || selectedSection == SHOWALL_HEADERS)
        {
//            int row = indexPath.row;
//            int section = indexPath.section;
//            int index;
            
//            if (isDefault)
//                index = section;
//            else
//                index = selectedRow;
//            
            NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
            NSString * headerObjName = [hdr_object objectForKey:gHEADER_OBJECT_NAME];
            
            
            NSArray * header_sections = [hdr_object objectForKey:@"hdr_Sections"];
                        
            for (int i=0;i<[header_sections count];i++)
            {
                NSDictionary * section = [header_sections objectAtIndex:i];
                NSArray *section_fields = [section objectForKey:@"section_Fields"];
                for (int j=0;j<[section_fields count];j++)
                {
                    NSDictionary *section_field = [section_fields objectAtIndex:j];
                    
                     NSString * field_api = [section_field objectForKey:gFIELD_API_NAME];
                    if([field_api isEqualToString:@"RecordTypeId"])
                    {
                        NSString * key = [section_field objectForKey:gFIELD_VALUE_KEY];
                       /// NSString * key  = [dict objectForKey:gFIELD_VALUE_KEY];
                        [return_dict  setObject:(key!= nil)?key:@""  forKey:RecordType_Id];
                        [return_dict  setObject:headerObjName forKey:SFM_Object];
                        break;
                    }
                    //add key values to SM_header_fields dictionary 
                   
            }
            }
        }
    }
    else
    {
        //sahana 26th sept 2011
        //control type
        NSMutableArray * array = [Disclosure_dict objectForKey:gDETAILS_VALUES_ARRAY];
        NSMutableArray * detail_values = [array objectAtIndex:self.selectedRowForDetailEdit];
        NSString * detail_objectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
        
        for (int i = 0; i < [detail_values count]; i++)
        {
            NSString * value_Field_API = [[detail_values objectAtIndex:i] objectForKey:gVALUE_FIELD_API_NAME];
            if([value_Field_API isEqualToString:@"RecordTypeId"])
            {
                NSString *key =  [[detail_values objectAtIndex:i] objectForKey:gVALUE_FIELD_VALUE_KEY];
                [return_dict  setObject:(key!= nil)?key:@""  forKey:RecordType_Id];
                [return_dict  setObject:detail_objectName forKey:SFM_Object];
                break;
            }
        }
    }
    return return_dict;
}


-(void)clearTheDependentPicklistValue:(NSString *)fieldApi_name atIndexPath:(NSIndexPath *)indexPath controlType:(NSString *)controlType  fieldValue:(NSString *)field_value;
{
    if (!isInEditDetail)
    {
        if (selectedSection == SHOW_HEADER_ROW || selectedSection == SHOWALL_HEADERS)
        {
          
//            int section = indexPath.section;
//            int index;
//            
//            if (isDefault)
//                index = section;
//            else
//                index = selectedRow;
           
            NSMutableDictionary *_header    = [appDelegate.SFMPage objectForKey:gHEADER];
            NSMutableArray *header_sections = [_header objectForKey:gHEADER_SECTIONS];
            NSString * headerObjName        = [_header objectForKey:gHEADER_OBJECT_NAME];
            
            
            
            NSMutableArray   * dependent_picklists = nil ;
            if([fieldApi_name isEqualToString:@"RecordTypeId"])
            {
//                dependent_picklists = [[appDelegate.databaseInterface getRtDependentPicklistsForObject:headerObjName recordtypeName:field_value] retain];
				dependent_picklists = [appDelegate.databaseInterface getRtDependentPicklistsForObject:headerObjName recordtypeName:field_value];
            }
            else
            {
//                 dependent_picklists = [[appDelegate.databaseInterface   getAllDependentPicklistSWhenControllerValueChanged:headerObjName controller_name:fieldApi_name] retain];
				dependent_picklists = [appDelegate.databaseInterface   getAllDependentPicklistSWhenControllerValueChanged:headerObjName controller_name:fieldApi_name];
            }
               
                       
            for(int i=0; i <[header_sections count] ;i++)
            {
                NSDictionary * section_info = [header_sections objectAtIndex:i];
                NSMutableArray * sectionFileds= [section_info objectForKey:@"section_Fields"];
                
                for(int j= 0;j<[sectionFileds count]; j++)
                {
                    NSMutableDictionary * filed_info =[sectionFileds objectAtIndex:j];
                    
                    NSString * filed_api_name = [filed_info objectForKey:gFIELD_API_NAME];
                    NSString * control_type   = [filed_info objectForKey:gFIELD_DATA_TYPE];
                    
                   // NSString * dict_value = [filed_info objectForKey:gFIELD_VALUE_VALUE];
                    
                    if([control_type isEqualToString:@"picklist"])
                    {
                        if([dependent_picklists containsObject:filed_api_name])
                        {
                            if([fieldApi_name isEqualToString:@"RecordTypeId"])
                            {
                                NSString * label_ = [appDelegate.databaseInterface  getDefaultValueForRTPicklist:headerObjName recordtypeName:field_value field_api_name:filed_api_name type:@"Label"];
                                NSString  * value_ =[ appDelegate.databaseInterface  getDefaultValueForRTPicklist:headerObjName recordtypeName:field_value field_api_name:filed_api_name type:@"Value"];
                                
                                [filed_info setValue:label_ forKey:gFIELD_VALUE_VALUE];
                                [filed_info setValue:value_ forKey:gFIELD_VALUE_KEY];
                            }
                            else
                            {
                                [filed_info setValue:@"" forKey:gFIELD_VALUE_VALUE];
                                [filed_info setValue:@"" forKey:gFIELD_VALUE_KEY];
                            }
                            SMLog(@"Fields Info ========= %@" , filed_info);
                        }
                        
                        
                    }
                }
            }
        }
    }
    else
    {
        NSMutableArray  * array = [Disclosure_dict objectForKey:gDETAILS_VALUES_ARRAY];
        NSMutableArray  * field_array = [Disclosure_dict objectForKey:gDETAILS_FIELDS_ARRAY];
        NSMutableArray  * detail_values = [array objectAtIndex:self.selectedRowForDetailEdit];
        NSMutableDictionary * field_dataType_dict = [[[NSMutableDictionary alloc] initWithCapacity:0]autorelease];
        NSString * detailObjectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
        
        
        
        NSMutableArray   * dependent_picklists = nil ;
        
        if([fieldApi_name isEqualToString:@"RecordTypeId"])
        {
//            dependent_picklists = [[appDelegate.databaseInterface getRtDependentPicklistsForObject:detailObjectName recordtypeName:field_value] retain];
			dependent_picklists = [appDelegate.databaseInterface getRtDependentPicklistsForObject:detailObjectName recordtypeName:field_value];
        }
        else
        {
//            dependent_picklists = [[appDelegate.databaseInterface   getAllDependentPicklistSWhenControllerValueChanged:detailObjectName controller_name:fieldApi_name] retain];
				dependent_picklists = [appDelegate.databaseInterface   getAllDependentPicklistSWhenControllerValueChanged:detailObjectName controller_name:fieldApi_name];

        }
        
        for(int j = 0 ; j< [field_array count]; j++)
        {
            NSDictionary * dict = [field_array objectAtIndex:j];
           //[api_names addObject:[dict objectForKey:gFIELD_API_NAME]];
            NSString * api_name = [dict objectForKey:gFIELD_API_NAME];
            NSString * data_type = [dict objectForKey:gFIELD_DATA_TYPE];
            [field_dataType_dict setValue:data_type forKey:api_name];
        }
        NSArray * all_api_names = [field_dataType_dict allKeys];
        
        for (int i = 0; i < [detail_values count]; i++)
        {
            NSString * value_Field_API = [[detail_values objectAtIndex:i] objectForKey:gVALUE_FIELD_API_NAME];
            NSString * control_type = @"";
            for(NSString * api in all_api_names)
            {
                if([value_Field_API isEqualToString:api])
                {
                    control_type = [field_dataType_dict objectForKey:api];
                }
            }
            
             
            if([control_type isEqualToString:@"picklist"])
            {
                              
                if([dependent_picklists containsObject:value_Field_API])
                {
                    
                    if([fieldApi_name isEqualToString:@"RecordTypeId"])
                    {
                        NSString * label_ = [appDelegate.databaseInterface  getDefaultValueForRTPicklist:detailObjectName recordtypeName:field_value field_api_name:value_Field_API type:@"Label"];
                        NSString  * value_ =[ appDelegate.databaseInterface  getDefaultValueForRTPicklist:detailObjectName recordtypeName:field_value field_api_name:value_Field_API type:@"Value"];
                        
                        [[detail_values objectAtIndex:i] setValue:label_ forKey:gVALUE_FIELD_VALUE_VALUE];
                        [[detail_values objectAtIndex:i] setValue:value_ forKey:gVALUE_FIELD_VALUE_KEY]; 
                    }
                    else
                    {
                        [[detail_values objectAtIndex:i] setValue:@"" forKey:gVALUE_FIELD_VALUE_VALUE];
                        [[detail_values objectAtIndex:i] setValue:@"" forKey:gVALUE_FIELD_VALUE_KEY]; 
                    }
                  
                }
                
            }
            
        }
    }

}

- (void) showManualSyncUI
{
    //btn merge
    ManualDataSync * manualDataSync = [[[ManualDataSync alloc] initWithNibName:@"ManualDataSync" bundle:nil] autorelease] ;
    manualDataSync.modalPresentationStyle = UIModalPresentationFullScreen;
    manualDataSync.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    appDelegate._manualDataSync.didAppearFromSFMScreen = YES;
    
    if (appDelegate.showUI)
    {
        appDelegate.SFMPage = nil;
        appDelegate.SFMoffline = nil;
        [(SFMPageController *)delegate dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
       [(SFMPageController *)delegate presentViewController:manualDataSync animated:YES completion:nil];
    }
}

-(void) showSyncStatusButton
{
//    [statusButton setBackgroundImage:[self getStatusImage] forState:UIControlStateNormal]; 
    //[appDelegate setSyncStatus:appDelegate.SyncStatus];
}

- (void) refreshStatusImage
{
//    [statusButton setBackgroundImage:[self getStatusImage] forState:UIControlStateNormal];
    //[appDelegate setSyncStatus:appDelegate.SyncStatus];
}

-(void)pageLevelEventsForEvent:(NSString *)event_Name
{
    NSMutableDictionary * headerDataDictionary = [appDelegate.SFMPage objectForKey:gHEADER];
    NSMutableArray * pageLevelEvents = [[[headerDataDictionary objectForKey:gPAGELEVEL_EVENTS] mutableCopy] autorelease];
    for(int i = 0; i< [pageLevelEvents count];i++)
    {
        NSDictionary * eventsDictionary = [pageLevelEvents objectAtIndex:i];
        
        if([event_Name isEqualToString:AFTERSAVE])
        {
            if ([eventsDictionary count]> 0)
            {
                NSString * eventType = [eventsDictionary objectForKey:gEVENT_TYPE];
                NSString * TargetCall = [eventsDictionary objectForKey:gEVENT_TARGET_CALL];
                if([eventType isEqualToString:@"After Save/Update"])
                {
                    if([TargetCall isEqualToString:@""])
                    {
                        
                    }
                    else
                    {
                        [self didInvokeWebService:TargetCall event_name:AFTERSAVE];
                    }
                }
                if([eventType isEqualToString:@"After Save/Insert"])
                {
                    if([TargetCall isEqualToString:@""])
                    {
                    }
                    else
                    {
                        [self didInvokeWebService:TargetCall event_name:AFTERSAVE];
                    }
                }                
            }
        }
        else if([event_Name isEqualToString:BEFORESAVE])
        {
            if ([eventsDictionary count]> 0)
            {
                NSString * eventType = [eventsDictionary objectForKey:gEVENT_TYPE];
                NSString * TargetCall = [eventsDictionary objectForKey:gEVENT_TARGET_CALL];
                if([eventType isEqualToString:@"Before Save/Update"])
                {
                    if([TargetCall isEqualToString:@""])
                    {
                        
                    }
                    else
                    {
                        [self didInvokeWebService:TargetCall event_name:BEFORESAVE];
                    }
                }
                if([eventType isEqualToString:@"Before Save/Insert"])
                {
                    if([TargetCall isEqualToString:@""])
                    {
                    }
                    else
                    {
                        [self didInvokeWebService:TargetCall event_name:BEFORESAVE];
                    }
                }                
                
            }
        }
        else if([event_Name isEqualToString:ONLOAD])
        {
            if ([eventsDictionary count]> 0)
            {
                NSString * eventType = [eventsDictionary objectForKey:gEVENT_TYPE];
                NSString * TargetCall = [eventsDictionary objectForKey:gEVENT_TARGET_CALL];
                if([eventType isEqualToString:@"On Load"])
                {
                    if([TargetCall isEqualToString:@""])
                    {
                        
                    }
                    else
                    {
                        [self didInvokeWebService:TargetCall event_name:ONLOAD];
                    }
                }
            }
        }
    }
}


#pragma mark - MOVE TABLE VIEW

-(void)moveTableViewforDisplayingConflict:(NSMutableString*)error
{
    table_view_moved = TRUE;
    [UIView beginAnimations:@"animateTable" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    
   // self.webView.backgroundColor = [UIColor redColor];
    CGRect frame;
	if (detailViewObject.isInEditDetail)
	{
		detailViewObject.webView.frame = CGRectMake(0, 0, detailViewObject.view.frame.size.width, 100);
		detailViewObject.webView.alpha = 1.0;
		frame = CGRectMake(10, 10, detailViewObject.webView.frame.size.width, 90);
	}
	else
	{
		frame = CGRectMake(10, 10, self.webView.frame.size.width, 90);
		self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
		self.webView.alpha = 1.0;
	}
	
	
    [UIView commitAnimations];
	
    UITextView * view = [[[UITextView alloc] initWithFrame:frame] autorelease];
    view.text = error;
    view.font = [UIFont boldSystemFontOfSize:18.0];
    view.textColor = [UIColor blackColor];
    view.editable = NO;
    NSString * colourCode = @"#F75D59";
    UIColor * color = [appDelegate colorForHex:colourCode];
    
    view.backgroundColor = color;
	if (detailViewObject.isInEditDetail)
	{
		[detailViewObject.webView addSubview:view];
	}
	else
	{
		[self.webView addSubview:view];
	}
	
    
}


#pragma End
-(void)displayALertViewinSFMDetailview:(char *)excp_message
{
    NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_OVERLAP];
    
//    [[NSString  alloc] initWithUTF8String:excp_message];
    UIAlertView * exeption_alert = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_error_message] message:message delegate:self cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_RESCHEDULE_NO] otherButtonTitles:[appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_RESCHEDULE_YES], nil];

    [exeption_alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    [exeption_alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if(buttonIndex == 1)
    {
//        [appDelegate.databaseInterface insertdataIntoTable:@"Event" data:appDelegate.insert_event_dict];
//        appDelegate.insert_event_dict = nil;
        NSMutableArray  *keys_event = nil, *objects_event = nil;
        objects_event = [NSArray arrayWithObjects:@"",save,@"",@"",gBUTTON_TYPE_TDM_IPAD_ONLY ,@"",@"true",nil];
        keys_event = [NSArray arrayWithObjects:SFW_ACTION_ID,SFW_ACTION_DESCRIPTION,SFW_EXPRESSION_ID,SFW_PROCESS_ID,SFW_ACTION_TYPE ,SFW_WIZARD_ID,SFW_ENABLE_ACTION_BUTTON,nil];
        NSMutableDictionary * dict_events_save = [NSMutableDictionary dictionaryWithObjects:objects_event forKeys:keys_event];
        [self offlineActions:dict_events_save];
        
    }
     else if(buttonIndex == 0){
         [appDelegate.databaseInterface deleteRecordsFromEventLocalIds];
    }
    
}


@end
