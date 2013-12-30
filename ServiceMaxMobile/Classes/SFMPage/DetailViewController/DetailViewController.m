//
//  DetailViewController.m
//  project
//
//  Created by Developer on 26/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"
#import "AppDelegate.h"
#import "ZKServerSwitchboard.h"
#import "WSIntfGlobals.h"
#import <QuartzCore/QuartzCore.h>
#import "LocalizationGlobals.h"
#import "LookupFieldPopover.h"
#import "OPDocViewController.h"
#import "SummaryViewController.h"
#import "TimerClass.h"
#import "Troubleshooting.h"
#import "Chatter.h"
#import "databaseIntefaceSfm.h"
#import "ManualDataSync.h"
#import "CustomToolBar.h"
#import "SMXMonitor.h"

 //Debrief
//#import "SFMEditDetailViewController.h"
#import "SVMAccessoryButton.h"

#import "Utility.h"
#import "Util.h"
#import "HTMLJSWrapper.h"

//Radha :- Child SFM UI 6/june/2012 
#import "SWitchViewButton.h"
//SFM Biz Rules
#import "JSExecuter.h"
#import "SBJson.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AttachmentWebView.h"
#import "AttachmentUtility.h"
#import "AttachmentDatabase.h"
#define kLeftPaddingForiOS7 40

#define SUPPORTED_IOS_VERSION 6.0 // Dam - Win14 changes

void SMXLog(int level,const char *methodContext,int lineNumber,NSString *message);
enum BizRuleConfirmViewStatus{
    kBizRuleConfirmMessageInit = 0,
    kBizRuleConfirmMessageCancelled = 1,
    kBizRuleConfirmMessageSaved = 2,
}alertViewStatus;


@interface DetailViewController ()
@property (nonatomic,retain) NSMutableDictionary * headerValueMappingDict;
@property (nonatomic,retain) NSString * s2t_recordId;
@property (nonatomic ) BOOL business_rules_success;
@property (nonatomic, retain) UIPopoverController * popoverController;
@property (nonatomic, retain) NSMutableDictionary * child_sfm_process_node;
@property (nonatomic, retain) NSIndexPath * SfmChildSelectedIndexPath;//childSfm Jul 1st
@property (nonatomic, retain) NSString * sfmChildSelectedRecordId;


-(void)addAttachment:(NSString *)recordId;
-(void)createAttachment:(int)indexRow;
-(void)removeAttachmentView;
- (void)configureView;
- (SFMEditDetailViewController *) getEditViewOfLine; // KRI
- (BOOL) isValidUrl:(NSString *)url;
- (void) showAlertForInvalidUrl;
- (void) resetTableViewFrame;
//Radha :- Debrief :- 19 june '13
//Radha :- Implementation  for  Required Field alert in Debrief UI
- (void) showCurrentRowForMandatoryFields:(NSDictionary *)details isLine:(BOOL)IsLine;
- (void) populateMandatoryRow:(NSInteger)section indexpath:(NSIndexPath *)currentindexpath;
//Radha :- Implementation for cancel button in Debrief UI
- (BOOL) cancelIfNewLineAdded:(NSInteger)index;
//Radha Defect Fix 7446
- (NSIndexPath *) getCurrentIndexPath:(NSInteger)section;

-(void)pushtViewProcessToStack:(NSString *)process_id  record_id:(NSString *)record_id;
//Radha :- Child SFM UI
- (SFMChildView *) allocChildLinkedViewProcess;
- (void) hideChildLinkedViewProcess;
- (void) showChildViewProcessTable:(UIView *)parentView indexpath:(NSIndexPath *)_indexpath;

-(void)FindLinkedProcessForLayoutId:(NSString *)layout_id;

-(NSArray *)getAllLinkedProcessForDetailLine:(NSString *)layout_id;

//-(NSInteger)findHeightOftheChildSfmView:(NSIndexPath *)index_path;

//sahana child sfm  -July 1st
-(void)invokeChildSfMForProcess_id:(NSString *)child_process_id records_id:(NSString *)child_record_id ChildobjectName:(NSString *)child_obj_name selectedIndexPath:(NSIndexPath *)indexPath;
-(void)getRecordIdForChildSfmForSection:(NSInteger)section row:(NSInteger)row recordId:(NSString *)localRecordId  actiondict:(NSDictionary *)actionDict;
-(NSInteger)getSection:(NSIndexPath *)_indexpath;
-(NSInteger)getRow:(NSIndexPath *)_indexpath;
-(BOOL)isInvokedFromChildSfm:(NSDictionary *)actionDict;
-(BOOL)checkForEmptyRequireFields;
-(void)SaveCreatedRecordInfoIntoPlistForRecordId:(NSString *)recordId objectName:(NSString *)ObjectName;
-(void)reloadCurrentProcess:(NSString *)processType;
-(void)updateParentReferenceForDetailLines:(NSMutableDictionary * )pageLayout;
- (BOOL) startCameraControllerFromViewControllerisImageFromCamera:(BOOL)isCameraCapture isVideoMode:(BOOL)isVideoMode;
//Aparna: FORMFILL
- (void) setFormFillInfo:(NSDictionary *)formFillDict
       forPageLayoutDict:(NSMutableDictionary *)pageLayoutDict
                recordId:(NSString *)recordId;

@end

@implementation DetailViewController
@synthesize imageCollectionView;
@synthesize bizRuleResult;
@synthesize bizRuleExecutionStatus;
@synthesize headerValueMappingDict;

//ChildSfm
@synthesize SfmChildSelectedIndexPath,sfmChildSelectedRecordId;
@synthesize business_rules_success,s2t_recordId;

//KRI
@synthesize editDetailObject;
@synthesize EventUpdate_Continue;
@synthesize child_sfm_process_node = _child_sfm_process_node;
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
@synthesize jsExecuter;
@synthesize bizRuleJSExecuter;
@synthesize priceBookData;

 //Debrief
@synthesize selectedIndexPathForEdit;
//Radha :- Child SFM UI
@synthesize SFMChildTableview;
@synthesize selectedIndexPathForchildView;

@synthesize documentView;
//Adjusting WIDTH across Debrief Ui
#define WIDTH	617

- (BOOL) isValidUrl:(NSString *)url
{
    NSString * urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate * urlPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    BOOL isValidUrl = [urlPredicate evaluateWithObject:url];
    
    SMLog(kLogLevelVerbose,@"***** Is %@ valid url %d",url,isValidUrl);
    return isValidUrl;
}

- (void) showAlertForInvalidUrl
{
    NSString * warning = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_WARNING];
    NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    NSString * invalidUrlMessage = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_TEXT_INVALID_URL];
    
    BOOL isAlertShowing = NO;
    for( UIView* subview in [UIApplication sharedApplication].keyWindow.subviews )
    {
        if( [subview isKindOfClass:[UIAlertView class]] )
        {
            SMLog(kLogLevelVerbose, @"Alert is showing" );
            isAlertShowing = YES;
            break;
        }
    }
    if (!isAlertShowing) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:warning message:invalidUrlMessage delegate:self cancelButtonTitle:alert_ok otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
}

//Aparna : FORMFILL
#pragma mark -
#pragma mark FORMFILL

- (void) setFormFillInfo:(NSDictionary *)formFillDict
       forPageLayoutDict:(id)pageLayoutDict
                recordId:(NSString *)recordId
{
    NSMutableDictionary *headerDictionary = pageLayoutDict;
    NSString *headerObjectName = [headerDictionary objectForKey:gHEADER_OBJECT_NAME];
    NSMutableArray *headerSections = [headerDictionary objectForKey:gHEADER_SECTIONS];
    for(NSMutableDictionary *sectionFieldDict in headerSections)
    {
        NSMutableArray *fieldsArray = [sectionFieldDict objectForKey:gSECTION_FIELDS];
        for (NSMutableDictionary *fieldDictionary in fieldsArray)
        {
            
            NSString * fieldApiName = [fieldDictionary valueForKey:gFIELD_API_NAME];
            NSString * fieldDataType = [fieldDictionary valueForKey:gFIELD_DATA_TYPE];
            
            NSArray *formFillFieldArray = [formFillDict allKeys];
            if([formFillFieldArray containsObject:fieldApiName])
            {
                NSString *fieldValue = [formFillDict valueForKey:fieldApiName];
                
                NSString *evaluatedLiteral = [appDelegate.dataBase evaluateLiteral:fieldValue forControlType:fieldDataType];
                if ([evaluatedLiteral length] > 0 )
                {
                    fieldValue = evaluatedLiteral;
                }
                
                if ([fieldDataType isEqualToString:@"date"] || [fieldDataType isEqualToString:@"datetime"])
                {
                    fieldValue = [fieldValue stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                }
                
                [fieldDictionary setValue:fieldValue forKey:gFIELD_VALUE_KEY];
                NSString *value = [self getValueForApiName:fieldApiName dataType:fieldDataType object_name:headerObjectName field_key:fieldValue];
                [fieldDictionary setValue:value forKey:gFIELD_VALUE_VALUE];
            }
        }
        
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    [self hideExpandedChildViews];
    self.selectedIndexPathForEdit = nil;
	//Radha :- Child SFM UI - 11/June/2013
	[self hideChildLinkedViewProcess];
	self.selectedIndexPathForchildView = nil;
    
    if (detailViewObject != nil)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }

    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    selectedSection = -1;
    selectedRow = -1;
    self.currentEditRow = nil;
    if(section != 3)
    {
        [self removeAttachmentView];
    }
      BOOL isAttchmentEnable = [appDelegate.dataBase getAttchmentValueforProcess:appDelegate.sfmPageController.processId];
    switch (section)
    {
        case 0:
            section = SHOW_HEADER_ROW;
            break;
            
        case 1:
        {
            NSArray *detail=[appDelegate.SFMPage objectForKey:@"details"];
            if([detail count])
            section = SHOW_LINES_ROW;
            else if (isAttchmentEnable)
            {
                section = SHOW_ATTACHMENT_INFO;
            }
            break;
        }
        case 2:
        {
            BOOL product_history = [[[appDelegate.SFMPage objectForKey:@"header"] objectForKey:gHEADER_SHOW_PRODUCT_HISTORY] boolValue];
            BOOL account_history = [[[appDelegate.SFMPage objectForKey:@"header"] objectForKey:gHEADER_SHOW_ACCOUNT_HISTORY] boolValue];
            NSDictionary *header = [appDelegate.SFMPage objectForKey:@"header"];
            
            NSString * header_object_name = [header objectForKey:gHEADER_OBJECT_NAME];
            BOOL Work_order = FALSE;
            if([header_object_name hasSuffix:@"Service_Order__c"])
            {
                Work_order = TRUE;
            }
        
            if(!isInViewMode && (product_history || account_history) && Work_order)
            {
                section = SHOW_ADDITIONALINFO_ROW;
            }
            else
            {
               section=SHOW_ATTACHMENT_INFO;
            }
            break;
        }
        case 3:
        {
            section = SHOW_ATTACHMENT_INFO;
            break;
        }
        default:
            break;
    }
    NSIndexPath * indexPath = nil;
    
    indexPath=[NSIndexPath indexPathForRow:row inSection:section];
    switch (section) {
        
        case SHOWALL_HEADERS:
            selectedSection = SHOWALL_HEADERS;
            isDefault = YES;
            [tableView reloadData];
            break;
	
        case SHOW_HEADER_ROW:
            isDefault = NO;
            selectedSection = SHOW_HEADER_ROW;
            selectedRow = row;
            [tableView reloadData];
            break;
        
         
        case SHOWALL_LINES:
            selectedSection = SHOWALL_LINES;
            isDefault = YES;
            [tableView reloadData];
            break;
        
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
            
        case SHOW_ATTACHMENT_INFO:
            [self createAttachment:indexPath.row];
            [tableView reloadData];
            break;
        
        default:
            break;
    }

    [self.popoverController dismissPopoverAnimated:YES];
}

-(void) didselectSection:(NSInteger) section;
{
     //Debrief
    [self hideExpandedChildViews];
    [self removeAttachmentView];
	
    //Radha 22 June 13
	//Radha :- Implementation  for  Required Field alert in Debrief UI
    [self hideEditViewOfLine];
    
    if (detailViewObject != nil)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
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
	@try{
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
	}@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name databaseInterfaceSfm :didSwitchProcess %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason databaseInterfaceSfm :didSwitchProcess %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
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
	
	//Defect Fix :- 7382
	[self getEditViewOfLine];
	
	CGRect rect = self.view.frame;
	self.navigationController.navigationBar.frame = CGRectMake(0, 0, rect.size.width, self.navigationController.navigationBar.frame.size.height);
    
    EventUpdate_Continue = FALSE;
    
    didRunOperation = YES;
    
    isShowingSaveError = NO;
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
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
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    isDefault = YES;
    
    self.currentRecordId =  appDelegate.sfmPageController.recordId;//shr-retain 008595
    currentProcessId = appDelegate.sfmPageController.processId;

    if (!isInEditDetail)
    {
        appDelegate.isWorkinginOffline = TRUE;
        [self fillSFMdictForOfflineforProcess:currentProcessId forRecord:currentRecordId];
        [self didReceivePageLayoutOffline];
         // Dam - Win14 changes
        CFDictionaryRef dictRef = CGRectCreateDictionaryRepresentation(self.navigationController.navigationBar.frame);
		SMLog(kLogLevelVerbose,@"%@", dictRef);
        CFRelease(dictRef);
        
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
	//Defect Fixed 7364
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorColor = [UIColor clearColor];

}

- (void) didInternetConnectionChange:(NSNotification *)notification
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSNumber * currentReach = (NSNumber *) notification.object;
    BOOL isReachable = [currentReach boolValue];
    if (isReachable)
    {
        SMLog(kLogLevelVerbose,@"DetailViewController Internet Reachable");
    }
    else
    {
        SMLog(kLogLevelWarning,@"DetailViewController Internet Not Reachable");
        
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
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.isDetailActive = YES;
    
    [self enableSFMUI];
    
    
    if( !self.parentReference )
        [self addNavigationButtons:detailTitle];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.isDetailActive = YES;
    
    //6347 & 6757: Aparna
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleIncrementalDataSyncNotification:) name:kIncrementalDataSyncDone object:nil];
	
	//Defect Fixed 7364
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorColor = [UIColor clearColor];
    
    //[appDelegate setSyncStatus:appDelegate.SyncStatus];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];

    //6347 & 6757: Aparna
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kIncrementalDataSyncDone object:nil];

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

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

// Back Button Methods
- (void) DismissModalViewController:(id)sender
{
    appDelegate.showUI = TRUE;     //btn merge
    clickedBack = YES;
    [appDelegate.sfmPageController.rootView hideErrors];
	//Radha :- Child SFM UI
    [self hideChildLinkedViewProcess];
	[self hideEditViewOfLine];
    
    [self resetTableViewFrame];
    if([appDelegate.sfmPageController.process_stack count] != 0)
    {
        
        NSString * next_process_id = nil , *next_record_id = nil;
        
        while([appDelegate.sfmPageController.process_stack count] != 0)
        {
            NSDictionary * dict = [appDelegate.sfmPageController.process_stack objectAtIndex:[appDelegate.sfmPageController.process_stack count] -1];
            NSString * process_id = [[dict objectForKey:PROCESSID] retain]; // Dam - Win14 changes - revoked to fix crash
             NSString * record_id = [[dict objectForKey:RECORDID] retain]; // Dam - Win14 changes - revoked to fix crash

            [appDelegate.sfmPageController.process_stack removeLastObject];
            
            NSString * top_process_obejct = [appDelegate.databaseInterface getObjectNameForProcessId:process_id];
            
            NSString * current_process_object = [appDelegate.databaseInterface getObjectNameForProcessId:appDelegate.sfmPageController.processId];
            
            if([top_process_obejct isEqualToString:current_process_object] && [record_id isEqualToString:appDelegate.sfmPageController.recordId] && [[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"VIEWRECORD"] ) //check for top process is view process
            {
                continue;
            }
            else
            {
                next_process_id = process_id;
                next_record_id = record_id;
                break;
            }
            
        }
        
        if(next_process_id == nil && next_record_id == nil)
        {
            NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
            NSString * headerObjName = [hdr_object objectForKey:gHEADER_OBJECT_NAME];
            if([headerObjName isEqualToString:@"Event"])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EVENT_DATA_SYNC object:nil];
            }
            
            appDelegate.SFMPage = nil;
            appDelegate.SFMoffline = nil;
            [delegate Back:sender];
            return;
        }
        else
        {
            [self fillSFMdictForOfflineforProcess:next_process_id  forRecord:next_record_id];
            [self didReceivePageLayoutOffline];
        }
     }
    else
    {
        
        NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
        NSString * headerObjName = [hdr_object objectForKey:gHEADER_OBJECT_NAME];
        if([headerObjName isEqualToString:@"Event"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EVENT_DATA_SYNC object:nil];
        }
        appDelegate.SFMPage = nil;
        appDelegate.SFMoffline = nil;
        [delegate Back:sender];
    }
    return;
    

    if ([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"EDIT"] || [[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"SOURCETOTARGETONLYCHILDROWS"]) 
    {
        [activity startAnimating];
        if([appDelegate.sfmPageController.sourceProcessId length] == 0 && [appDelegate.sfmPageController.sourceRecordId length] == 0)
        {
            NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
            NSString * headerObjName = [hdr_object objectForKey:gHEADER_OBJECT_NAME];
            if([headerObjName isEqualToString:@"Event"])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EVENT_DATA_SYNC object:nil];
                appDelegate.SFMPage = nil;
                appDelegate.SFMoffline = nil;
                [delegate Back:sender];
                return;
            }
        }
        
        appDelegate.sfmPageController.processId = appDelegate.sfmPageController.sourceProcessId;
        appDelegate.sfmPageController.recordId  = appDelegate.sfmPageController.sourceRecordId ;

        
        SMLog(kLogLevelVerbose,@"%@",appDelegate.sfmPageController.sourceProcessId);
	 //Debrief
		[self resetTableViewFrame];
        [self fillSFMdictForOfflineforProcess:appDelegate.sfmPageController.sourceProcessId  forRecord:appDelegate.sfmPageController.sourceRecordId];
        [self didReceivePageLayoutOffline];
    }
    else
    {
        
        if([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"SOURCETOTARGET"] || [[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"STANDALONECREATE"] || [[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"VIEWRECORD"])
        {
            NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
            NSString * headerObjName = [hdr_object objectForKey:gHEADER_OBJECT_NAME];
            if([headerObjName isEqualToString:@"Event"])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EVENT_DATA_SYNC object:nil];
            }
        }
        appDelegate.SFMPage = nil;
        appDelegate.SFMoffline = nil;
        [delegate Back:sender];
    }
 	//Debrief
	if (self.currentEditRow != nil)
		self.currentEditRow = nil;
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
	
	NSString *action = [appDelegate.wsInterface.tagsDictionary objectForKey:ACTIONS];
    UIButton * actionButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 67, 37)] autorelease];
    [actionButton setTitle:action forState:UIControlStateNormal];

    UIImage * actionImage = [UIImage imageNamed:@"SFM-Screen-Done-Back-Button"];
    [actionImage stretchableImageWithLeftCapWidth:9 topCapHeight:9];
    [actionButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [actionButton setBackgroundImage:actionImage forState:UIControlStateNormal];
	//Defect Fix :- 7454
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= SUPPORTED_IOS_VERSION)
        actionButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    else
        actionButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [actionButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];

    // Adding the label
    UILabel * label = [[[UILabel alloc] initWithFrame:CGRectMake(64, 0, self.view.frame.size.width-64, 44)] autorelease];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:14.0];
	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= SUPPORTED_IOS_VERSION)
        label.textAlignment = NSTextAlignmentCenter;
    else
        label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor blackColor];
	label.text = detailTitle;	
    SMLog(kLogLevelVerbose,@"%@",detailTitle);
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
    
    UIBarButtonItem * syncBarButton = [[UIBarButtonItem alloc] initWithCustomView:appDelegate.SyncProgress];
    [buttons addObject:syncBarButton];
    [syncBarButton setTarget:self];
	//Radha Sync ProgressBar
//    syncBarButton.width =26;
    toolBarWidth += syncBarButton.width;
    [syncBarButton release];
    // Samman - 20 July, 2011 - Signature Capture - BEGIN

    BOOL isStandAloneCreate = [[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"STANDALONECREATE"];
    if (appDelegate.signatureCaptureUpload && !isInEditDetail && !isStandAloneCreate && !isInViewMode)
    {
		NSString *act = [appDelegate.wsInterface.tagsDictionary objectForKey:ACTIONS];
        actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 43, 35)];
        [actionButton setTitle:act forState:UIControlStateNormal];
        [actionButton setImage:[UIImage imageNamed:@"sfm_signature_capture"] forState:UIControlStateNormal];
        [actionButton addTarget:self action:@selector(ShowSignature) forControlEvents:UIControlEventTouchUpInside];
        actionButton.isAccessibilityElement = YES;
        actionButton.accessibilityLabel = @"sfm_signature_capture";

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
    
    SMLog(kLogLevelVerbose,@"Tool Bar Width = %d",toolBarWidth);
    
    /*ios7_support shravya-custom toolbar*/
    CustomToolBar* toolbar;
    if (appDelegate.signatureCaptureUpload && !isInEditDetail && !isStandAloneCreate && !isInViewMode){

        toolbar = [[[CustomToolBar alloc] initWithFrame:CGRectMake(self.view.frame.size.width -220, 0, 220, 44)] autorelease];
    }
    else
    {
        toolbar = [[[CustomToolBar alloc] initWithFrame:CGRectMake(self.view.frame.size.width -100, 0, 170, 44)] autorelease];

    }
   
    SMLog(kLogLevelVerbose,@"Tool Bar Frame x = %f y = %f w = %f h = %f",[toolbar frame].origin.x,[toolbar frame].origin.y,[toolbar frame].size.width,[toolbar frame].size.height);

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
     // Dam - Win14 changes
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= SUPPORTED_IOS_VERSION)
        label.textAlignment = NSTextAlignmentCenter;
    else
        label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor blackColor];
	label.text = detailTitle;	
    SMLog(kLogLevelVerbose,@"%@",detailTitle);
    //adding the action Button
    if (actionBtn == nil)
    {
        UIButton * actionButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 67, 31)] autorelease];
        [actionButton setTitle:@"Actions" forState:UIControlStateNormal];
        UIImage * actionImage = [UIImage imageNamed:@"SFM-Screen-Done-Back-Button"];
        [actionImage stretchableImageWithLeftCapWidth:9 topCapHeight:9];
        [actionButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
		//Defect Fix :- 7454
         // Dam - Win14 changes
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= SUPPORTED_IOS_VERSION)
            actionButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        else
            actionButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
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
    
    UIBarButtonItem * syncBarButton = [[UIBarButtonItem alloc] initWithCustomView:appDelegate.SyncProgress];
    [buttons addObject:syncBarButton];
    [syncBarButton setTarget:self];
    
    
    BOOL isStandAloneCreate = [[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"STANDALONECREATE"];
    if (appDelegate.signatureCaptureUpload && !isInEditDetail && !isStandAloneCreate && !isInViewMode)
    {
        UIButton * actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 33)];
        [actionButton setImage:[UIImage imageNamed:@"sfm_signature_capture"] forState:UIControlStateNormal];
        [actionButton addTarget:self action:@selector(ShowSignature) forControlEvents:UIControlEventTouchUpInside];
        actionButton.isAccessibilityElement = YES;
        actionButton.accessibilityLabel = @"sfm_signature_capture";

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
        RootViewController * master = [[[RootViewController alloc] init] autorelease];
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
-(void)FindLinkedProcessForLayoutId:(NSString *)detail_layout_id
{
    //compatibility check
    BOOL doesTableExists = [appDelegate.databaseInterface checkForTheTableInTheDataBase:LINKED_SFMProcess];
    if(!doesTableExists)
    {
        return;
    }

    //check for enableChild SFM for Layout_id
    NSArray * linked_process_ids = [self   getAllLinkedProcessForDetailLine:detail_layout_id];
    if([linked_process_ids count] != 0)
    {
        [_child_sfm_process_node setObject:linked_process_ids forKey:[detail_layout_id mutableCopy]]; // Damodar - Win14 - MemMgt - revoked to fix crash
    }
}
-(void)updateParentReferenceForDetailLines:(NSMutableDictionary * )pageLayout
{
    NSMutableDictionary * _header =  [pageLayout objectForKey:@"header"];
    NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];

    NSMutableArray * details = [pageLayout objectForKey:gDETAILS];
    for(int j= 0; j < [details count]; j++)
    {
        NSMutableDictionary * detailDict = [details objectAtIndex:j];
        NSString * detailObjectName = [detailDict objectForKey:gDETAIL_OBJECT_NAME];

        NSString * parent_column_name = [detailDict objectForKey:gDETAIL_HEADER_REFERENCE_FIELD];
        if([parent_column_name length] == 0)
        {
            NSString * NewParentColumnName = [appDelegate.databaseInterface getRefernceToFieldnameForObjct:detailObjectName reference_table:headerObjName table_name:SFREFERENCETO];
            [detailDict setObject:NewParentColumnName forKey:gDETAIL_HEADER_REFERENCE_FIELD];
        }

    }

}

#pragma mark = fill the sfmData equivalent for didsubmitProcess method in offline
-(void)fillSFMdictForOfflineforProcess:(NSString *) processId forRecord:(NSString *)recordId
{
	@try{
        
    self.headerValueMappingDict = nil;
        
    appDelegate.sfmPageController.processId = processId;
    appDelegate.sfmPageController.recordId = recordId;
        
        
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
      // For Attachment End  //
        
    if([process_type isEqualToString:VIEWRECORD] || [process_type isEqualToString:EDIT ] || [process_type isEqualToString:SOURCETOTARGET] || [process_type isEqualToString:SOURCETOTARGETONLYCHILDROWS])
    {
        
        if(_child_sfm_process_node == nil)
        {
            _child_sfm_process_node = [[NSMutableDictionary alloc] initWithCapacity:0];
            
        }
        else
        {
            [_child_sfm_process_node removeAllObjects];
        }

    }
        
        
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
    
    SMLog(kLogLevelVerbose,@"Header  describe dict %@" , descibeDict);
    
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
            if([filed_api_name isEqualToString:@"WhatId"] && [headerObjName isEqualToString:@"Event"])
            {
                field_label = [appDelegate.wsInterface.tagsDictionary objectForKey:Opportunity_Account];
            }
            
            [filed_info setObject:field_label forKey:gFIELD_LABEL];
            SMLog(kLogLevelVerbose,@"fiel Info   %@", filed_info);
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
            //1: Aparna: 7120
            processInfo *processInfo = [appDelegate getViewProcessForObject:headerObjName record_id:recordId processId:processId isswitchProcess:NO];
            SMLog(kLogLevelVerbose,@"***************** process_exists: %d process_id: %@",processInfo.process_exists,processInfo.process_id);
            
            if (processInfo.process_exists)
            {
                [self initAllrequriredDetailsForProcessId:processInfo.process_id recordId:recordId object_name:headerObjName];
                [self fillSFMdictForOfflineforProcess:processInfo.process_id forRecord:recordId];
                return;
            }
            else{
                
                // 8303 - Vipindas Sep 4 2013
                
                // Load custom error message if exists
                NSString * message = [appDelegate.dataBase expressionErrorMessageById:expression_id];
                
                if (! [Util isValidString:message] )
                {
                    message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_no_pagelayout];
                }
                
                NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
                NSString * cancel_ = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE];
                
                UIAlertView * no_page_Layout = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel_ otherButtonTitles:nil, nil];
                
                [no_page_Layout show];
                [no_page_Layout release];
            }

        
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
                                //krishna defect : 4655
                            	if([field_value isEqualToString:@""]) 
                            	{
                                	field_value = field_key;
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
                                
                                if([filed_api_name isEqualToString:@"WhatId"])
                                {
                                    //   below code is the correct way of finding out the referece field name
                                    NSString * keyPrefix = [field_key substringWithRange:NSMakeRange(0, 3)];
                                    
                                    NSString * referencetoObject = [appDelegate.databaseInterface getTheObjectApiNameForThePrefix:keyPrefix tableName:SFOBJECT];
                                    
                                    NSString * Name_field  = [appDelegate.dataBase getApiNameForNameField:referencetoObject];
                                    
                                    field_value = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:referencetoObject field_name:Name_field record_id:field_key];
                                    
                                }
                                else
                                {
                                    NSMutableArray * referenceTotableNames = [appDelegate.databaseInterface getReferenceToForField:filed_api_name objectapiName:headerObjName tableName:SF_REFERENCE_TO];
                                    
                                    
                                    if([referenceTotableNames count ] > 0)
                                    {
                                        NSString * reference_to_tableName = [referenceTotableNames objectAtIndex:0];
                                        
                                        NSString * referenceTo_Table_fieldName = [appDelegate.databaseInterface getFieldNameForReferenceTable:reference_to_tableName tableName:SFOBJECTFIELD];
                                        
                                        field_value = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:reference_to_tableName field_name:referenceTo_Table_fieldName record_id:field_key];
                                        
                                        
                                        //Aparna: 6889
                                        if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
                                        {
                                            NSString *sf_id =  [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:reference_to_tableName local_id:field_key];
                                            
                                            field_value = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:reference_to_tableName field_name:referenceTo_Table_fieldName record_id:sf_id];
                                        }
                                        
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
            NSMutableArray * detail_Values_id = [dict objectForKey:gDETAIL_VALUES_RECORD_ID];

            //check for enableChild SFM for Layout_id
            [self FindLinkedProcessForLayoutId:detail_layout_id];
            
            
            for(int k =0 ;k<[filedsArray count];k++)
            {
                NSMutableDictionary * detailFiled_info =[filedsArray objectAtIndex:k];
                NSString * api_name = [detailFiled_info objectForKey:gFIELD_API_NAME];
                [details_api_keys addObject:api_name];
            }
            
            NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGETCHILD process_id:processId layoutId:detail_layout_id objectName:detailObjectName];
            
            NSString * expressionId = [process_components objectForKey:EXPRESSION_ID];
            NSString * parent_column_name = [process_components objectForKey:PARENT_COLUMN_NAME];
            NSString * sorting_order = ([process_components objectForKey:SORTING_ORDER]!= nil)?[process_components objectForKey:SORTING_ORDER]:@"";
            
            NSMutableArray * detail_values = [appDelegate.databaseInterface queryLinesInfo:details_api_keys detailObjectName:detailObjectName headerObjectName:headerObjName detailaliasName:detailaliasName headerRecordId:appDelegate.sfmPageController.recordId expressionId:expressionId parent_column_name:parent_column_name sorting_order:sorting_order];
            
            for(int l = 0 ;l < [detail_values count]; l++)
            {
                [detailValuesArray addObject:[detail_values objectAtIndex:l]]; 
                
                //sahana - child sfm
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
                  
                }
                if(value_id_flag)
                {
                    [detail_Values_id addObject:id_];
                }
                
            }
            
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
                    
                    synchronized_sqlite3_finalize(stmt);
                    
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
                
                 synchronized_sqlite3_finalize(stmt);

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
        
        NSString * expression_id = [process_components objectForKey:EXPRESSION_ID];
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
            
            // 8303 - Vipindas Sep 4 2013
            
            // Load custom error message if exists
            NSString * message = [appDelegate.dataBase expressionErrorMessageById:expression_id];
            
            if (! [Util isValidString:message] )
            {
                message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_swich_process];
            }
            NSString * title   = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
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
            
            //check for enableChild SFM for Layout_id
            [self FindLinkedProcessForLayoutId:detail_layout_id];

            for(int k =0 ;k<[filedsArray count];k++)
            {
                NSMutableDictionary * detailFiled_info =[filedsArray objectAtIndex:k];
                NSString * api_name = [detailFiled_info objectForKey:gFIELD_API_NAME];
                [details_api_keys addObject:api_name];
            }
            
            NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGETCHILD process_id:processId layoutId:detail_layout_id objectName:detailObjectName];
			
            NSString * expressionId = [process_components objectForKey:EXPRESSION_ID];
            NSString * parent_column_name = [dict objectForKey:gDETAIL_HEADER_REFERENCE_FIELD];
			NSString * sorting_order = ([process_components objectForKey:SORTING_ORDER]!= nil)?[process_components objectForKey:SORTING_ORDER]:@"";
			//6279 - DefectFix
			
			NSMutableDictionary * detailFieldMappingDict = [appDelegate.databaseInterface getObjectMappingForMappingId:process_components mappingType:FIELD_MAPPING];
					
			NSArray * field_values = [detailFieldMappingDict allValues];
			
			for (int val = 0;  val < [field_values count]; val++)
			{
				if (![details_api_keys containsObject:[field_values objectAtIndex:val]])
				{
					[details_api_keys addObject:[field_values objectAtIndex:val]];
				}
			}
			
            NSMutableArray * detail_values = [appDelegate.databaseInterface queryLinesInfo:details_api_keys detailObjectName:detailObjectName headerObjectName:headerObjName detailaliasName:detailaliasName headerRecordId:appDelegate.sfmPageController.recordId expressionId:expressionId parent_column_name:parent_column_name sorting_order:sorting_order];
            
            for(int l = 0 ;l < [detail_values count]; l++)
            {
                [detailValuesArray addObject:[detail_values objectAtIndex:l]];
                NSMutableArray *  eachArray = [detail_values objectAtIndex:l];
                for(int m = 0 ; m < [eachArray count];m++)
                {
                    NSMutableDictionary * dict = [eachArray objectAtIndex:m];
                    NSString * api_name = [dict objectForKey:gVALUE_FIELD_API_NAME];
					
					//6279 - Defect Fix
					if ([details_api_keys containsObject:api_name])
					{
						NSString * value = [detailFieldMappingDict objectForKey:api_name];
						
						NSString * fieldMappingValue = @"";
						
						for(int t = 0 ; t < [eachArray count];t++)
						{
							NSDictionary * tempDict = [eachArray objectAtIndex:t];
							
							if ([value isEqualToString:[tempDict objectForKey:gVALUE_FIELD_API_NAME]])
							{
								fieldMappingValue = [tempDict objectForKey:gVALUE_FIELD_VALUE_VALUE];
								if (![value isEqualToString:api_name])
								{
									[dict setValue:fieldMappingValue forKey:gVALUE_FIELD_VALUE_KEY];
								}
								[dict setValue:fieldMappingValue forKey:gVALUE_FIELD_VALUE_VALUE];
								break;
							}
							
						}

					}
					
					if([api_name isEqualToString:@"local_id"])
                    {
                        [eachArray  removeObjectAtIndex:m];
                    }
				}
                
                [detail_Values_id addObject:@""];
            }
            
            
        }
    }
    else if ([process_type isEqualToString:@"STANDALONECREATE"])
    {
        //HEADER VALUE MAPPING
        //fetch all value for value mapping 
        
        NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGET process_id:processId layoutId:layout_id objectName:headerObjName];
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
        self.headerValueMappingDict = headerValueDict;
        
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
                                
                                if([filed_api_name isEqualToString:@"WhatId"])
                                {
                                    //   below code is the correct way of finding out the referece field name
                                    NSString * keyPrefix = [field_key substringWithRange:NSMakeRange(0, 3)];
                                    
                                    NSString * referencetoObject = [appDelegate.databaseInterface getTheObjectApiNameForThePrefix:keyPrefix tableName:SFOBJECT];
                                    
                                    NSString * Name_field  = [appDelegate.dataBase getApiNameForNameField:referencetoObject];
                                    
                                    field_value = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:referencetoObject field_name:Name_field record_id:field_key];
                                    
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
            
            //check for enableChild SFM for Layout_id
            [self FindLinkedProcessForLayoutId:detail_layout_id];
            
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
               
                
                //sahana jul15
              
                [appDelegate.databaseInterface replaceCURRENTRECORDLiteral:object_mapping_dict sourceDict:headerValueDict];

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
        EventUpdate_Continue = FALSE;
        NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGET process_id:processId layoutId:layout_id objectName:headerObjName];
        //[appDelegate.databaseInterface  getValueMappingForlayoutId:layout_id process_id:processId objectName:headerObjName];
        
        NSString * expression_id = [process_components objectForKey:EXPRESSION_ID];
        //SMLog(kLogLevelVerbose," record id %@" ,appDelegate.sfmPageController.recordId);
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
			
            // 8303 - Vipindas Sep 4 2013
            
            // Load custom error message if exists
            NSString * message = [appDelegate.dataBase expressionErrorMessageById:expression_id];
            
            if (! [Util isValidString:message] )
            {
                message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_swich_process];
            }
            
            //NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_swich_process];
            NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
            NSString * cancel_ = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE];
			
            UIAlertView * enty_criteris = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel_ otherButtonTitles:nil, nil];
            [enty_criteris show];
            [enty_criteris release];
			return;
        }
		
		
		NSMutableDictionary * value_mapping_dict = [appDelegate.databaseInterface getObjectMappingForMappingId:process_components mappingType:VALUE_MAPPING];
        self.headerValueMappingDict = value_mapping_dict;
		
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
            
            //check for enableChild SFM for Layout_id
            [self FindLinkedProcessForLayoutId:detail_layout_id];
            
            
            for(int k =0 ;k<[filedsArray count];k++)
            {
                NSMutableDictionary * detailFiled_info =[filedsArray objectAtIndex:k];
                NSString * api_name = [detailFiled_info objectForKey:gFIELD_API_NAME];
                [details_api_keys addObject:api_name];
            }
            
            NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGETCHILD process_id:processId layoutId:detail_layout_id objectName:detailObjectName];
			NSMutableDictionary * detail_value_mapping_dict = [appDelegate.databaseInterface getObjectMappingForMappingId:process_components mappingType:VALUE_MAPPING];
			
            //sahana jul15
            [appDelegate.databaseInterface replaceCURRENTRECORDLiteral:detail_value_mapping_dict sourceDict:value_mapping_dict];

            
            NSString * expressionId = [process_components objectForKey:EXPRESSION_ID];
            NSString * parent_column_name = [dict objectForKey:gDETAIL_HEADER_REFERENCE_FIELD];
            NSString * sorting_order = ([process_components objectForKey:SORTING_ORDER]!= nil)?[process_components objectForKey:SORTING_ORDER]:@"";
            
            NSMutableArray * detail_values = [appDelegate.databaseInterface queryLinesInfo:details_api_keys detailObjectName:detailObjectName headerObjectName:headerObjName detailaliasName:detailaliasName headerRecordId:appDelegate.sfmPageController.recordId expressionId:expressionId parent_column_name:parent_column_name sorting_order:sorting_order];
            
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
        
        
    [self addAttachment:recordId];
        
    //Fix for defect #7820
    [self updateParentReferenceForDetailLines:appDelegate.SFMoffline];

    appDelegate.didsubmitModelView = TRUE;
	}@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name DetailViewController :fillSFMdictForOfflineforProcess %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason DetailViewController :fillSFMdictForOfflineforProcess %@",exp.reason);
         [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
     }

    
}

-(void)addAttachment:(NSString *)recordId
{
    // For Attachment Start //
    
    NSMutableDictionary * attachmentDetails = nil;

    BOOL isAttachmentAvailable= [appDelegate.dataBase getAttchmentValueforProcess:appDelegate.sfmPageController.processId];
    if(isAttachmentAvailable)
    {
        attachmentDetails=[appDelegate.dataBase getAttachmentDetailsforRecord:recordId];
        NSMutableDictionary *imgDict= [attachmentDetails objectForKey:@"IMAGES"];
        [imgDict setObject:[NSMutableArray  array] forKey:@"deleted_ids"];
        [imgDict setObject:[NSMutableArray  array] forKey:@"new_Added_ids"];
      
        NSMutableDictionary *docDict=[attachmentDetails objectForKey:@"DOCUMENT"];
        [docDict setObject:[NSMutableArray  array] forKey:@"deleted_ids"];
        [docDict setObject:[NSMutableArray  array] forKey:@"new_Added_ids"];

        [appDelegate.SFMoffline setObject:attachmentDetails forKey:@"Attachments"];

    }
    else
    {
        return;
    }

}
-(NSArray *)getAllLinkedProcessForDetailLine:(NSString *)layout_id
{
//    childSFM = TRUE;
    
    //get sf_id for Process
    NSString * process_sf_id = [appDelegate.databaseInterface getProcessSfIdForProcess_uniqueName:appDelegate.sfmPageController.processId];
    
    //get layout_id for the clicked process  
    NSString * processNode_id = [appDelegate.databaseInterface getProcessNodeIdForLayoutId:layout_id process_id:appDelegate.sfmPageController.processId];
    
    // pass these to infor to fetch all the linked processes
    NSArray * linked_process_ids = [appDelegate.databaseInterface getLinkedProcessIdsForProcess_node_id:processNode_id process_sf_id:process_sf_id];
    
    NSArray * linked_process_sf_ids = [appDelegate.databaseInterface getAllProcessId_forProcess_sf_id:linked_process_ids];
    return linked_process_sf_ids;
}

-(void)pushtViewProcessToStack:(NSString *)process_id  record_id:(NSString *)record_id
{
    
    NSString * temp_process_id = [process_id mutableCopy]; // Damodar - Win14 - MemMgt - revoked to fix crash
    NSString * temp_record_id = [record_id mutableCopy]; // Damodar - Win14 - MemMgt - reovked to fix crash
    
    if(appDelegate.sfmPageController.process_stack == nil)
    {
        NSMutableArray * temp_arry = [[NSMutableArray alloc] initWithCapacity:0];
        appDelegate.sfmPageController.process_stack = temp_arry;
        [temp_arry release];
    }
    
    [appDelegate.sfmPageController.process_stack addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:temp_process_id,temp_record_id, nil] forKeys:[NSArray arrayWithObjects:PROCESSID,RECORDID, nil]]];
    
//    [temp_process_id release];
//    [temp_record_id release];
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
    self.currentRecordId = recordId;////shr-retain 008595
    
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
        SMLog(kLogLevelVerbose,@"didSubmitProcess In While Loop");
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
	
	if (self.selectedIndexPathForchildView != nil)
	{
		self.editDetailObject = nil;
		[self hideChildLinkedViewProcess];
		[self.tableView reloadData];
	}
	if (self.selectedIndexPathForEdit != nil)
	{
		self.SFMChildTableview = nil;
		[self hideExpandedChildViews];
	}
	
	
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
    @try{    
    if ([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"VIEWRECORD"]) 
    {
         wizard_dict =[appDelegate.databaseInterface getWizardInformationForObjectname:heder_object_name record_id:appDelegate.sfmPageController.recordId];
         buttonsArray_offline  = [wizard_dict objectForKey:SFW_WIZARD_BUTTONS];
    }
    // Insert 3 buttons at the beginning
    NSMutableArray  *keys_event = nil, *objects_event = nil;
    
    objects_event = [NSMutableArray arrayWithObjects:@"",save,@"",@"",gBUTTON_TYPE_TDM_IPAD_ONLY ,@"",@"true",nil];
    keys_event = [NSMutableArray arrayWithObjects:SFW_ACTION_ID,SFW_ACTION_DESCRIPTION,SFW_EXPRESSION_ID,SFW_PROCESS_ID,SFW_ACTION_TYPE ,SFW_WIZARD_ID,SFW_ENABLE_ACTION_BUTTON,nil];
    NSMutableDictionary * dict_events_save = [NSMutableDictionary dictionaryWithObjects:objects_event forKeys:keys_event];
    //8915 - cancel , categorise cancel button
    objects_event = [NSMutableArray arrayWithObjects:@"",cancel,@"",@"",gBUTTON_TYPE_TDM_IPAD_ONLY_CANCEL ,@"",@"true",nil];
    keys_event = [NSMutableArray arrayWithObjects:SFW_ACTION_ID,SFW_ACTION_DESCRIPTION,SFW_EXPRESSION_ID,SFW_PROCESS_ID,SFW_ACTION_TYPE ,SFW_WIZARD_ID,SFW_ENABLE_ACTION_BUTTON,nil];
    NSMutableDictionary * dict_events_cancel = [NSMutableDictionary dictionaryWithObjects:objects_event forKeys:keys_event];
    
    objects_event = [NSMutableArray arrayWithObjects:@"",summary,@"",@"",gBUTTON_TYPE_TDM_IPAD_ONLY ,@"",@"true",nil];
    keys_event = [NSMutableArray arrayWithObjects:SFW_ACTION_ID,SFW_ACTION_DESCRIPTION,SFW_EXPRESSION_ID,SFW_PROCESS_ID,SFW_ACTION_TYPE ,SFW_WIZARD_ID,SFW_ENABLE_ACTION_BUTTON,nil];
    NSMutableDictionary * dict_events_summury = [NSMutableDictionary dictionaryWithObjects:objects_event forKeys:keys_event];
    
    objects_event = [NSMutableArray arrayWithObjects:@"",troubleShooting,@"",@"",gBUTTON_TYPE_TDM_IPAD_ONLY ,@"",@"true",nil];
    keys_event = [NSMutableArray arrayWithObjects:SFW_ACTION_ID,SFW_ACTION_DESCRIPTION,SFW_EXPRESSION_ID,SFW_PROCESS_ID,SFW_ACTION_TYPE ,SFW_WIZARD_ID,SFW_ENABLE_ACTION_BUTTON,nil];
    NSMutableDictionary * dict_events_troubleShooting = [NSMutableDictionary dictionaryWithObjects:objects_event forKeys:keys_event];
	
	//New Wizard buttons fro refreshing the record.
    
   
	objects_event = [NSMutableArray arrayWithObjects:@"",dod_title,@"",@"",gBUTTON_TYPE_TDM_IPAD_ONLY ,@"",@"true",nil];
    keys_event = [NSMutableArray arrayWithObjects:SFW_ACTION_ID,SFW_ACTION_DESCRIPTION,SFW_EXPRESSION_ID,SFW_PROCESS_ID,SFW_ACTION_TYPE ,SFW_WIZARD_ID,SFW_ENABLE_ACTION_BUTTON,nil];
    NSMutableDictionary * dict_refresh_record = [NSMutableDictionary dictionaryWithObjects:objects_event forKeys:keys_event];

    
	objects_event = [NSMutableArray arrayWithObjects:@"",quick_save,@"",@"",gBUTTON_TYPE_TDM_IPAD_ONLY ,@"",@"true",nil];
    keys_event = [NSMutableArray arrayWithObjects:SFW_ACTION_ID,SFW_ACTION_DESCRIPTION,SFW_EXPRESSION_ID,SFW_PROCESS_ID,SFW_ACTION_TYPE ,SFW_WIZARD_ID,SFW_ENABLE_ACTION_BUTTON,nil];
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
        
            
        objects_event = [NSMutableArray arrayWithObjects:@"",([button_dict objectForKey:@"button_Title"] != nil)?[button_dict objectForKey:@"button_Title"]:@"",@"",@"",button_type ,@"",flag_,nil];
        keys_event = [NSMutableArray arrayWithObjects:SFW_ACTION_ID,SFW_ACTION_DESCRIPTION,SFW_EXPRESSION_ID,SFW_PROCESS_ID,SFW_ACTION_TYPE ,SFW_WIZARD_ID,SFW_ENABLE_ACTION_BUTTON,nil];
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
        
        SMLog(kLogLevelVerbose,@" action buttons %@",actionMenu.buttons);
        
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
            
            //Vipin  28 th Jan
            
            CGFloat popoverHeight = 0.0f;
            
            CGFloat maxAllowedPopoverHeight = ((appDelegate.sfmPageController.rootView.view.frame.size.height * 107) / 100.0);
            
            if (Total_height > maxAllowedPopoverHeight)
            {
                popoverHeight = maxAllowedPopoverHeight;
                
            } else {
                
                popoverHeight = Total_height;
            }
            
            
            UIPopoverController * popover = [[[UIPopoverController alloc] initWithContentViewController:sfwToolBar] autorelease];
            
            // Set up SFM Wizard tool bar view size
            CGRect toolBarViewFrame =  sfwToolBar.view.frame;
            toolBarViewFrame.size.height = popoverHeight;
            sfwToolBar.view.frame = toolBarViewFrame;
            
            // Set up SFM Wizard tool bar table view size
            CGRect tableViewFrame =  sfwToolBar.sfw_tableview.frame;
            tableViewFrame.size.height = popoverHeight;
            sfwToolBar.sfw_tableview.frame = tableViewFrame;
            
            // Need to set content size
            [popover setPopoverContentSize:sfwToolBar.view.frame.size];
            popover.delegate = self;
            CGPoint p ;
            CGSize q;
            q.width = appDelegate.sfmPageController.rootView.view.frame.size.width;
            
            p.x = appDelegate.sfmPageController.detailView.view.frame.origin.x;
            p.y = appDelegate.sfmPageController.detailView.view.frame.origin.y;
             UIImageView * bgImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM_left_panel_bg_main_2.png"]] autorelease];
            sfwToolBar.sfw_tableview.backgroundView = bgImage;
            sfwToolBar.ipad_only_view.backgroundColor = [UIColor whiteColor];
//            [popover presentPopoverFromRect:CGRectMake(900, 21, 67, 20) inView:appDelegate.sfmPageController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
           // Defect Fix #4690
            [popover presentPopoverFromBarButtonItem:actionBtn permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

            sfwToolBar.popOver = popover;
            //[sfwToolBar showIpadOnlyButtons];

        }
    }
	}@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name DetailViewController :action %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason DetailViewController :action %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
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
	@try{
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
                SMLog(kLogLevelVerbose,@"DetailViewController.m : didInvokeWebService: GetPrice1");
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
            SMLog(kLogLevelVerbose,@"DetailViewController.m : didInvokeWebService: GetPrice2");
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
            SMLog(kLogLevelVerbose,@" evnt is executing");
            while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
            {
#ifdef kPrintLogsDuringWebServiceCall
                SMLog(kLogLevelVerbose,@"DetailViewController.m : didInvokeWebService: GetPrice3");
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
                SMLog(kLogLevelVerbose,@" evnt is NOT executing");
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.event_timer];
            }            
        }   
        
		//OAuth.
		[[ZKServerSwitchboard switchboard] doCheckSession];

        SMLog(kLogLevelVerbose,@" getPrice1");
        NSMutableDictionary * sfm_temp = [appDelegate.SFMPage mutableCopy];
        NSArray * keys = [NSArray arrayWithObjects:WEBSERVICE_NAME, SFM_DICTIONARY, nil];
        NSArray * objects = [NSArray arrayWithObjects:targetCall, sfm_temp, nil];
        NSDictionary * dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [activity startAnimating];
        appDelegate.wsInterface.getPrice = FALSE;
        SMLog(kLogLevelVerbose,@" getPrice2");
        if ([appDelegate isInternetConnectionAvailable])
        {
            SMXMonitor *monitor = [[[SMXMonitor alloc] init] autorelease];
            [monitor monitorSMMessageWithName:@"[DetailViewController.m didInvokeWebService]"
                                 withUserName:appDelegate.currentUserName
                                     logLevel:kPerformanceLevelWarning
                                   logContext:@"Start"
                                 timeInterval:kWSExecutionDuration];
            [appDelegate.wsInterface callSFMEvent:dict event_name:event_name];
            while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, FALSE))
            {
#ifdef kPrintLogsDuringWebServiceCall
                SMLog(kLogLevelVerbose,@"DetailViewController.m : didInvokeWebService: customwebservicecall");
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
            [monitor monitorSMMessageWithName:@"[DetailViewController.m didInvokeWebService]"
                                 withUserName:appDelegate.currentUserName
                                     logLevel:kPerformanceLevelWarning
                                   logContext:@"Stop"
                                 timeInterval:kWSExecutionDuration];
     
        }
        
        SMLog(kLogLevelVerbose,@" getPrice3");
        [self.tableView reloadData];
        [appDelegate.sfmPageController.rootView refreshTable];
        [self  didselectSection:0];    
        [activity stopAnimating];
        [appDelegate ScheduleIncrementalDatasyncTimer];
        [appDelegate ScheduleIncrementalMetaSyncTimer];
        [appDelegate ScheduleTimerForEventSync];
		//Radha Defect Fix 5542
		[appDelegate updateNextDataSyncTimeToBeDisplayed:[NSDate date]];
		
        [self enableSFMUI];
        SMLog(kLogLevelVerbose,@" getPrice4");
    }
	}@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name DetailViewController :didInvokeWebService %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason DetailViewController :didInvokeWebService %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }

}


- (void) startSummaryDataFetch
{
	@try{
    [self disableSFMUI];
    
    BOOL isworkingInOffline = TRUE;
    clickedBack = NO;
    
    didGetParts = didGetExpenses = didGetLabor = didGetReportEssentials = NO;
    
    if (Labor != nil)
    {
        [Labor release];
        Labor = nil;
    }
    
       
    NSMutableArray *travelArray = nil;
    if(isworkingInOffline)
    {
		//Get Parts for the Work Order
        Parts    = [appDelegate.calDataBase queryForParts:appDelegate.sfmPageController.recordId];
        
		//Get Expense for the Work Order
		
        Expenses = [appDelegate.calDataBase queryForExpenses:appDelegate.sfmPageController.recordId];
        
		//Get Labor
		LaborArray = [appDelegate.calDataBase  queryForLabor:appDelegate.sfmPageController.recordId];
        
        travelArray  = [appDelegate.calDataBase  queryForTravel:appDelegate.sfmPageController.recordId];

        reportEssentials  = [[appDelegate.calDataBase getReportEssentials:appDelegate.sfmPageController.recordId] retain];
        SMLog(kLogLevelVerbose,@" reportEssentis array ==%@",reportEssentials);
        //Labor = nil;
    }
   
    Summary = [[[SummaryViewController alloc] initWithNibName:[SummaryViewController description] bundle:nil] autorelease];
    Summary.delegate = self;
    Summary.reportEssentials = reportEssentials;
        
    /* Set show billable amount 6773 */
        BOOL showBillablePrice = [self shouldShowBillableAmountInServiceReport];
        Summary.shouldShowBillablePrice = showBillablePrice;
        Summary.shouldShowBillableQty =  [self shouldShowBillableQuantityInServiceReport];
	
        //Radha Fix for defect 6337
	BOOL showParts, showLabour ,showExpenses;
		
	showParts = showLabour = showExpenses = FALSE;
		
	showParts = [[appDelegate.serviceReport objectForKey:@"IPAD004_SET006"] boolValue];
	showLabour = [[appDelegate.serviceReport objectForKey:@"IPAD004_SET007"] boolValue];
	showExpenses = [[appDelegate.serviceReport objectForKey:@"IPAD004_SET008"] boolValue];
    
    SMLog(kLogLevelVerbose,@"%@",reportEssentials);
    NSDictionary * headerDict = [appDelegate.SFMPage objectForKey:gHEADER];
    NSDictionary * headerDataDict = [headerDict objectForKey:gHEADER_DATA];
    Summary.workDescription = [self getObjectNameFromHeaderData:headerDataDict forKey:PROBLEMSUMMARY];
	//Radha Fix for defect 6337
	if (showParts)
		Summary.Parts = Parts;
	if (showExpenses)
		Summary.Expenses = Expenses;
                        
     if([travelArray count] > 0) {
        Summary.travel = travelArray;
     }
    Summary.recordId = currentRecordId;
    Summary.objectApiName = appDelegate.sfmPageController.objectName;
    SMLog(kLogLevelVerbose,@"%@",Parts);
    SMLog(kLogLevelVerbose,@"%@",Expenses);
    NSArray * _keys = [NSArray arrayWithObjects:SVMXC__Activity_Type__c, SVMXC__Actual_Price2__c, SVMXC__Actual_Quantity2__c, SVMXC__Billable_Quantity__c,SVMXC__Billable_Line_Price__c,nil];
    // Calculate Labor
	
	for (LabourValuesDictionary in LaborArray)
	{
		NSArray * allKeys = [LabourValuesDictionary allKeys];
		for (NSString * key in allKeys)
		{
          NSString *newKey = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
			if ([newKey hasPrefix:@"QTY_"])
			{
				NSString * quantity = [LabourValuesDictionary objectForKey:key];
                
				float _quantity = [quantity floatValue]; //#3736
				if (_quantity || showBillablePrice )
				{
					NSString * item = [key stringByReplacingOccurrencesOfString:@"QTY_" withString:@""];
                    if (item == nil) {
                        item = @"";
                    }
					NSString * _rate = [LabourValuesDictionary objectForKey:[NSString stringWithFormat:@"Rate_%@", item]];
                    if (_rate == nil) {
                        _rate = @"0.0";
                    }
                    NSString *billaBleQty = [LabourValuesDictionary objectForKey:[NSString stringWithFormat:@"Bill_QTY_%@", item]];
                    if (billaBleQty == nil) {
                        billaBleQty = @"0";
                    }
                     NSString *billaBlePrice = [LabourValuesDictionary objectForKey:[NSString stringWithFormat:@"Bill_Rate_%@", item]];
                    
                    if (billaBlePrice == nil) {
                        billaBlePrice = @"0.0";
                    }
                    
					NSArray * _objects = [NSArray arrayWithObjects:item, _rate, quantity,billaBleQty,billaBlePrice, nil];
					
					if (Labor == nil)
						Labor = [[NSMutableArray alloc] initWithCapacity:0];
					NSDictionary * laborDictionary = [NSDictionary dictionaryWithObjects:_objects forKeys:_keys];
					[Labor addObject:laborDictionary];
				}
			}
		}

	}
	
	SMLog(kLogLevelVerbose,@"%@",Labor);
	//Radha Fix for defect 6337
	if (showLabour)
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
    
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name DetailViewController :startSummaryDataFetch %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason DetailViewController :startSummaryDataFetch %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    @finally {
    [activity stopAnimating];
    didRunOperation = NO;
    
    [self enableSFMUI];
	}
}

- (NSString *) getObjectNameFromHeaderData:(NSDictionary *)dictionary forKey:(NSString *)key
{
	@try{
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
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name DetailViewController :getObjectNameFromHeaderData %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason DetailViewController :getObjectNameFromHeaderData %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
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
    @try{
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
    
    }@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name DetailViewController :showChatter %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason DetailViewController :showChatter %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
    }
    @finally
    {
        [activity stopAnimating];
        [self enableSFMUI];
    }
}

/*- (void) BackOnSave:(NSString *)targetCall
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
            SMLog(kLogLevelVerbose,@"BackOnSave in while loop");
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
    @try {
        if (detailViewObject.isInEditDetail)  //Shrinivas detailViewObject.isInEditDetail
        {
            
            [detailViewObject.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
        }
        else
        {
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
        }
        
    }
    @catch (NSException *exception) {
        
        SMLog(kLogLevelError,@"Exception Name DetailViewController :animation1DidStop %@",exception.name);
        SMLog(kLogLevelError,@"Exception Reason DetailViewController :animation1DidStop %@",exception.reason);

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

		SMLog(kLogLevelVerbose,@"SVMXC__Product__c = %@", [dict objectForKey:gSVMXC__Product__c] );
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
	@try{
	for (int i = 0; i < [array count]; i++)
    {
        ZKSObject * obj = [array objectAtIndex:i];
        NSDictionary * fields = [obj fields];
        [Expenses addObject:fields];
    }
	}@catch (NSException *exp) {
        SMLog(kLogLevelError,@"Exception Name DetailViewController :getExpenses %@",exp.name);
        SMLog(kLogLevelError,@"Exception Reason DetailViewController :getExpenses %@",exp.reason);
        [appDelegate CustomizeAletView:nil alertType:APPLICATION_ERROR Dict:nil exception:exp];
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
	SMLog(kLogLevelVerbose,@"getExistingLabor = %@", query);
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
		SMLog(kLogLevelVerbose,@"getPriceForLabor = %@", query);
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
		SMLog(kLogLevelVerbose,@"%@", [[obj fields] objectForKey:@"SVMXC__Billable_Cost2__c"]);
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
    
    if(popoverController == label_popOver)
    {
        [label_popOver release];
        label_popOver = nil;
    }
    if( popoverController == _popoverImageViewController )
    {
        [_popoverImageViewController release];
        _popoverImageViewController =nil;
    }
}

#pragma mark - WSInterface Delegate Method

-(void) didReceivePageLayoutOffline
{
     // Damodar - Win14 - MemMgt
    CFDictionaryRef dictRef = CGRectCreateDictionaryRepresentation(self.navigationController.navigationBar.frame);
	SMLog(kLogLevelVerbose,@"%@", dictRef);
    CFRelease(dictRef);
    
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
        NSMutableDictionary * header_ =  [appDelegate.SFMPage objectForKey:@"header"];
        NSString * headerObjName = [header_ objectForKey:gHEADER_OBJECT_NAME];
        [appDelegate.wsInterface saveSwitchView:appDelegate.sfmPageController.processId forObject:headerObjName];
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
    {
        isInViewMode = YES;
    }
    
    appDelegate.isSFMReloading = FALSE;
    [self.tableView reloadData];
    [appDelegate.sfmPageController.rootView refreshTable];
    
    [self  didselectSection:0];    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:14.0];
	label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
     // Dam - Win14 changes
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= SUPPORTED_IOS_VERSION)
        label.textAlignment = NSTextAlignmentCenter;
    else
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
    //6347 & 6757 : Aparna
    if([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"VIEWRECORD"] && !self.isInEditDetail)
    {
        [self addNavigationButtons:detailTitle];
    }
    
    [appDelegate.sfmPageController.rootView displaySwitchViews];
    [appDelegate.sfmPageController.rootView showLastModifiedTimeForSFMRecord];
    [self enableSFMUI];
    
     // Damodar - Win14 - MemMgt
    CFDictionaryRef dictReference = CGRectCreateDictionaryRepresentation(self.navigationController.navigationBar.frame);
	SMLog(kLogLevelVerbose,@"%@", dictReference);
    CFRelease(dictReference);
}

- (void) didFinishWithSuccess:(NSString *) response_msg
{
    NSString * response = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_RESPONSE];
    NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    UIAlertView * localAlert = [[UIAlertView alloc] initWithTitle:response message:response_msg  delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
    [localAlert show];
    
    [localAlert release];
    [activity stopAnimating];
}

- (void) requireFieldWarning
{
    //defect 006690 krishna
    [activity stopAnimating];
    NSString * response = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_RESPONSE];
    NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    NSString * required_fields = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_REQUIRED_FIELDS];
	//Radha :- Implementation  for  Required Field alert in Debrief UI
    requiredFields = [[UIAlertView alloc] initWithTitle:response message:required_fields delegate:nil cancelButtonTitle:alert_ok otherButtonTitles:nil];
	requiredFields.delegate = self;
    [requiredFields show];
    [requiredFields release];
   

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
        SMLog(kLogLevelVerbose,@"%@", [descObj name]);
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
	     //Debrief
            if(self.selectedIndexPathForEdit != nil && indexPath.section == self.selectedIndexPathForEdit.section && indexPath.row == self.selectedIndexPathForEdit.row) {
				float height = [self.editDetailObject getHeightForEditView];
				//Adjusting HEIGHT across Debrief UI
                if ( height >= 1) {
                    return height+40;
                }
				return gSTANDARD_TABLE_ROW_HEIGHT;
            }
			
			else if (self.selectedIndexPathForchildView != nil && indexPath.section == self.selectedIndexPathForchildView.section && indexPath.row == self.selectedIndexPathForchildView.row)
			{
				//Adjusting HEIGHT across Debrief UI
				float height = [self.SFMChildTableview getHeightForChildLinkedProcess];
				if (height >= 1) {
					return height + 40;
                }
				return gSTANDARD_TABLE_ROW_HEIGHT;
			}
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
 //Debrief
    if(self.selectedIndexPathForEdit != nil && indexPath.section == self.selectedIndexPathForEdit.section && indexPath.row == self.selectedIndexPathForEdit.row) {
        float height = [self.editDetailObject getHeightForEditView];
		//Adjusting HEIGHT across Debrief UI
		if ( height >= 1) {
			return height+40;
		}
        return gSTANDARD_TABLE_ROW_HEIGHT;
    }
	else if (self.selectedIndexPathForchildView != nil && indexPath.section == self.selectedIndexPathForchildView.section && indexPath.row == self.selectedIndexPathForchildView.row)
	{
		float height = [self.SFMChildTableview getHeightForChildLinkedProcess];
		if (height >= 1) {
			return height + 40;
		}
		return gSTANDARD_TABLE_ROW_HEIGHT;
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
        return section_title; // KRI
    }    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44; // 44
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
        title.text = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_SeeMore];
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

    //8483
    view.backgroundColor = [UIColor clearColor];
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!isInEditDetail)
    {
		//Fix for avoiding crash
		NSUInteger rowCount = 0;
		
        if (isDefault)
        {
            if (selectedSection == SHOWALL_HEADERS)
            {
                NSMutableDictionary *_header = [appDelegate.SFMPage objectForKey:gHEADER];
                NSMutableArray *header_sections = [_header objectForKey:gHEADER_SECTIONS];
				
				if (header_sections != nil && [header_sections count] > 0)
				{
					rowCount = [header_sections count];
				}
				return rowCount;
            }
            else if (selectedSection == SHOWALL_LINES)
            {
                NSMutableArray *details = [appDelegate.SFMPage objectForKey:gDETAILS];
				if (details != nil && [details count] > 0)
				{
					rowCount = [details count];
				}
				return rowCount;
            }
            else if (selectedSection == SHOW_ALL_ADDITIONALINFO)
            {
                // NSArray * array = appDelegate.additionalInfo;
                // NSInteger count_info = [appDelegate.additionalInfo count];
				if (appDelegate.additionalInfo != nil && [appDelegate.additionalInfo count] > 0)
				{
					rowCount = [appDelegate.additionalInfo  count];
				}
				return rowCount;
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
                int fields = 0;
                BOOL SLA_FLAG = [[header_section objectForKey:gSLA_CLOCK] boolValue];
                int rows=0 ;
                if(SLA_FLAG)
                {
                    return 2;
                }
                else
                {
                    NSArray * array = [header_section  objectForKey:gSECTION_FIELDS];
					//Fix for avoiding crash
                    if ([array isKindOfClass:[NSArray class]] && [array count] > 0 && array != nil)
                        fields = [array count];
                    //defect 007403
                    for (int i=0; i<fields; i++)
                    {
                        if (rows <[[[array objectAtIndex:i] objectForKey:gFIELD_DISPLAY_ROW]intValue])
                        {
                            rows=[[[array objectAtIndex:i] objectForKey:gFIELD_DISPLAY_ROW]intValue];
                        }
                    }
                    SMLog(kLogLevelVerbose,@"Rows %d",rows);
                    return rows;
                }
                
                return rows;
            }
            else if (selectedSection == SHOWALL_LINES)
            {
                NSMutableArray * details = [appDelegate.SFMPage objectForKey:gDETAILS];
                NSMutableDictionary * detail = [details objectAtIndex:section];
				//Fix for avoiding crash
                if (detail == nil && [detail count] > 0)
                    return 0;
                int rows = [[detail objectForKey:gDETAILS_VALUES_ARRAY] count];

                return rows+1; //an extra row for coloumn titles
            } //currently Working
            else if (selectedSection == SHOW_ALL_ADDITIONALINFO)
            {
                // NSString * additional_info = [appDelegate.additionalInfo objectAtIndex:section];
                NSDictionary * additional_info_dict = [appDelegate.additionalInfo objectAtIndex:section];
                NSString * additional_info = [[additional_info_dict allKeys] objectAtIndex:0];
                NSInteger count_info = 0;
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
                
                int fields;
                int rows=0;
                BOOL SLA_FLAG = [[header_section objectForKey:gSLA_CLOCK] boolValue];
                if(SLA_FLAG)
                {
                    return 2;
                }
                else
                {
                    fields = [[header_section  objectForKey:gSECTION_FIELDS] count];
                    //defect 007403
                    for (int i=0; i<fields; i++)
                    {
                        if (rows <[[[[header_section  objectForKey:gSECTION_FIELDS]  objectAtIndex:i] objectForKey:gFIELD_DISPLAY_ROW]intValue])
                        {
                            rows=[[[[header_section  objectForKey:gSECTION_FIELDS]  objectAtIndex:i] objectForKey:gFIELD_DISPLAY_ROW]intValue];
                        }
                    }
                    SMLog(kLogLevelVerbose,@"Rows %d",rows);
                    return rows;
                }

                return rows;
            }
            else if (selectedSection == SHOW_LINES_ROW)
            {
                NSMutableArray * details = [appDelegate.SFMPage objectForKey:gDETAILS];
                NSMutableDictionary * detail = [details objectAtIndex:selectedRow];
                if (detail == nil && [detail count] > 0)
                    return 0;
                int rows = [[detail objectForKey:gDETAILS_VALUES_ARRAY] count];
                
                return rows+1; //an extra row for coloumn titles
            }
            else if(selectedSection == SHOW_ADDITIONALINFO_ROW)
            {
                // NSString * additional_info = [appDelegate.additionalInfo objectAtIndex:selectedRow];
                NSDictionary * additional_info_dict = [appDelegate.additionalInfo objectAtIndex:selectedRow];
                NSString * additional_info = [[additional_info_dict allKeys] objectAtIndex:0];
				//Fix for avoiding crash
				NSUInteger row = 0;
                if([additional_info isEqualToString:PRODUCT_ADDITIONALINFO])
                {
					row = [[appDelegate.SFMPage objectForKey:PRODUCTHISTORY] count]+1;
                    return row;
                }
                if([additional_info isEqualToString:ACCOUNT_ADITIONALINFO])
                {
					row = [[appDelegate.SFMPage objectForKey:ACCOUNTHISTORY] count]+1;
                    return row; 
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		//Debrief
        CGRect cellframe = cell.frame;
        cellframe.size.width = 704;
        cell.frame = cellframe;
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
			//Defect Fix :- 007391
			for (UIView * view in [cell.contentView subviews])
			{
				[view removeFromSuperview];
			}
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
            CGRect label_frame = CGRectMake(x, 3, width1, 31);
            SMLog(kLogLevelVerbose,@"Label Frame %f %f %f %f",label_frame.origin.x,label_frame.origin.y,label_frame.size.width,label_frame.size.height);
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
               SMLog(kLogLevelVerbose,@"control Frame %f %f %f %f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
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
            
            //Aparna: 5878
            if([field_datatype isEqualToString: @"picklist"] || [field_datatype isEqualToString: @"multipicklist"])
            {
               if(appDelegate.isWorkinginOffline)
               {
                   NSMutableArray * descObjArray = [[NSMutableArray alloc] initWithCapacity:0];
                   NSMutableArray * descObjValidFor = [[NSMutableArray alloc] initWithCapacity:0];
                   
                   NSMutableDictionary * _header =  [appDelegate.SFMPage objectForKey:@"header"];
                   
                   NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];
                   
                   //isdependentPicklist
                   
                   isdependentPicklist = [[appDelegate.databaseInterface getPicklistINfo_isdependentOrControllername_For_field_name:DEPENDENT_PICKLIST field_api_name:fieldAPIName object_name:headerObjName] boolValue];
                 
                   dependPick_controllerName = [appDelegate.databaseInterface getPicklistINfo_isdependentOrControllername_For_field_name:CONTROLLER_FIRLD field_api_name:fieldAPIName object_name:headerObjName];
                   
                        //query to acces the picklist values for lines 
                   NSMutableDictionary * picklistValues = [appDelegate.databaseInterface  getPicklistValuesForTheFiled:fieldAPIName tableName:SFPicklist objectName:headerObjName];
                   
                   NSArray * actual_keys = [picklistValues allKeys];
                   
                   NSArray * allvalues = [picklistValues allValues];
                   
				   //Fix for Defect #4656
				   allvalues = [appDelegate.calDataBase sortPickListUsingIndexes:allvalues WithfieldAPIName:fieldAPIName tableName:SFPicklist objectName:headerObjName];
					
                   NSMutableArray * allkeys_ordered = [[NSMutableArray alloc] initWithCapacity:0];
                   //5878:
                   if ([field_datatype isEqualToString: @"picklist"])
                   {
                       [allkeys_ordered addObject:@" "];
                       [descObjArray addObject:@" "];
                       [descObjValidFor addObject:@" "];

                   }
                   

        
				   
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
                   
                   arr = [[[NSMutableArray  alloc] initWithArray:descObjArray]autorelease];
                   validFor = [[[NSMutableArray alloc] initWithArray:descObjValidFor]autorelease];
                   
                   [descObjArray release];
                   [descObjValidFor release];
                   [allkeys_ordered release];
                   
               }
            
            }

            NSString * refObjName = nil;
            NSString * refObjSearchId = nil;

            if ([field_datatype isEqualToString:@"reference"] && [fieldAPIName isEqualToString:@"RecordTypeId"])
            {
                NSMutableDictionary * _header =  [appDelegate.SFMPage objectForKey:@"header"];
                NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];
                arr = [appDelegate.databaseInterface getRecordTypeValuesForObjectName:headerObjName];
                             
            }
            
            SMLog(kLogLevelVerbose,@"%@", arr);
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
	BOOL isEditRow = NO;
	if (selectedSection == SHOW_LINES_ROW || selectedSection == SHOWALL_LINES)
	{
        header = FALSE;
    
		NSMutableArray * details = [appDelegate.SFMPage objectForKey:gDETAILS];
		NSMutableDictionary * detail = [details objectAtIndex:index];
		NSMutableArray * detail_fields = [detail objectForKey:gDETAILS_FIELDS_ARRAY];
        NSInteger columns = [[detail objectForKey:gDETAILS_NUMBER_OF_COLUMNS] intValue];
        NSString * detail_layout_id = [detail objectForKey:gDETAILS_LAYOUT_ID];
		NSInteger field_width = background_width/columns;
        BOOL allowEdit = [[detail objectForKey:gDETAILS_ALLOW_NEW_LINES] boolValue];
		if (row == 0) //display the column titles
		{
            background.clipsToBounds = YES;
			for (int j = 0; j < columns; j++)
			{
				UILabel * lbl = [[[UILabel alloc] initWithFrame:CGRectMake(j*field_width+8, 5, field_width-125, control_height)] autorelease];
				NSString * label_name = nil;
                if ([detail_fields count] > j)//sahana
                {
                    label_name = [[detail_fields objectAtIndex:j] objectForKey:gFIELD_LABEL];
                }
				lbl.text = label_name;
                lbl.textColor = [UIColor whiteColor];
                // Dam - Win14 changes
                if([[[UIDevice currentDevice] systemVersion] floatValue] >= SUPPORTED_IOS_VERSION)
                    lbl.textAlignment = NSTextAlignmentLeft ;
                else
                    lbl.textAlignment = UITextAlignmentLeft;
                lbl.font = [UIFont fontWithName:@"HelveticaBold" size:19];
                lbl.font = [UIFont boldSystemFontOfSize:lbl.font.pointSize];
                lbl.backgroundColor = [UIColor clearColor];
				//Debrief
                // Dam - Win14 changes
                if([[[UIDevice currentDevice] systemVersion] floatValue] >= SUPPORTED_IOS_VERSION)
                    lbl.lineBreakMode = NSLineBreakByTruncatingTail;
                else
                    lbl.lineBreakMode = UILineBreakModeTailTruncation;
				
				//Radha :- WO Debrief
				lbl.userInteractionEnabled = YES;
                /*Radha set accesibility UIAutomation */
                lbl.isAccessibilityElement = YES;
                lbl.accessibilityValue = label_name;

				UITapGestureRecognizer * tapMe = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizedForEdit:)];
				[lbl addGestureRecognizer:tapMe];
				[tapMe release];
				[background addSubview:lbl];
			}

            flag = 1;
            
            //UIView * addLinesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 23)];
            //8483
            CGFloat multiButtonWidth = 90;
            if (![Utility notIOS7]) {
                multiButtonWidth = 120.0;
            }
            UIView * addLinesView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, multiButtonWidth, 31)] autorelease];
            
            // Add Item
            UIImage * image = [UIImage imageNamed:@"add.png"];
            UIButton * c = [[UIButton alloc] initWithFrame:(CGRect){CGPointZero, image.size}];
            c.backgroundColor = [UIColor clearColor];
            c.tag = index;
            [c setImage:image forState:UIControlStateNormal];
            [c setImage:image forState:UIControlStateHighlighted];
            c.isAccessibilityElement = YES;
            [c setAccessibilityIdentifier:@"AddLinesButton"];
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
                control.isAccessibilityElement = YES;
                [control setAccessibilityIdentifier:@"AddMultiLinesButton"];
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
         //   [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];

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
					CGRect   frame = CGRectMake(j*field_width, 8, field_width-40,control_height-6);
					
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
						lbl2 = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x+5, frame.origin.y+2, frame.size.width, frame.size.height)];
						SMLog(kLogLevelVerbose,@"%@", value);
                        
                        //#Defect Fix :- Radha 7372
                        // Dam - Win14 changes
                        if([[[UIDevice currentDevice] systemVersion] floatValue] >= SUPPORTED_IOS_VERSION)
                            lbl2.lineBreakMode = NSLineBreakByTruncatingTail;
                        else
                            lbl2.lineBreakMode = UILineBreakModeTailTruncation;
                        
                        //#Defect Fix :- Radha 7372
                        lbl2.userInteractionEnabled = YES;
                        UITapGestureRecognizer * tapMe = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
                        [lbl2 addGestureRecognizer:tapMe];
                        [tapMe release];

                        

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
                        // Dam - Win14 changes
                        if([[[UIDevice currentDevice] systemVersion] floatValue] >= SUPPORTED_IOS_VERSION)
                            lbl2.textAlignment = NSTextAlignmentLeft;
                        else
                            lbl2.textAlignment = UITextAlignmentLeft;
                        lbl2.backgroundColor = [UIColor clearColor];
                        [background addSubview:lbl2];
                        }
                    }
                }
            }
            
            //KRI to remove the header part
            //KRI get edit view from sfmeditVC
            UIImage *disclosureImg = [UIImage imageNamed:@"disclosure.png"];
            float xValForDisclosure = tableView.frame.size.width - ( disclosureImg.size.width + 100 ); //8613

            CGRect disclosurebtnFrame = CGRectMake(xValForDisclosure, 4, 30, 30);
            SVMAccessoryButton *triangleBtn = [[SVMAccessoryButton alloc] initWithFrame:disclosurebtnFrame];;
            triangleBtn.indexpath = indexPath;
			//Radha Defect Fix 7446
			triangleBtn.index = index;
            triangleBtn.tag = 9746;
            [triangleBtn setBackgroundImage:disclosureImg forState:UIControlStateNormal];
            [triangleBtn addTarget:self action:@selector(lineDetailBtnActionCheck:) forControlEvents:UIControlEventTouchUpInside];
            [background addSubview:triangleBtn];
            [triangleBtn release];
			
			//Radha : 3/june/2013
			//			UIImage * switchImage = [UIImage imageNamed:@"SFM-Screen-Switch-Views-button.png"];
            
            //8915 - link sfm
            
            UIImage * switchImage = [[UIImage imageNamed:@"more.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:30];
            UIImage * hoverImage = [[UIImage imageNamed:@"more-hover.png"]stretchableImageWithLeftCapWidth:24 topCapHeight:30];
			
		if([[_child_sfm_process_node  allKeys] containsObject:detail_layout_id])
        {
            {
                
                int fontSize = 16;
                int insetPaddint = 24;
                int paddingWithDisclosure = 50;
                
                SWitchViewButton * switchButton = [[SWitchViewButton alloc] init];
                [switchButton setBackgroundImage:switchImage forState:UIControlStateNormal];
                //8915 - link sfm
                [switchButton setBackgroundImage:hoverImage forState:UIControlStateHighlighted];
                
                switchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                
                //extra space to give look and feel as discussed with anish
                NSString *titleString = [[appDelegate.wsInterface.tagsDictionary objectForKey:MOREBUTTONTEXT] stringByAppendingFormat:@" "];
                [switchButton setTitle:titleString forState:UIControlStateNormal] ;
                [switchButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:fontSize]];
                
                //get variable frame based on font.
                switchButton.titleEdgeInsets = UIEdgeInsetsMake(0, insetPaddint, 0, 0);
                CGSize frameSize = [Utility getBoundSizeForString:switchButton.titleLabel.text withFont:[UIFont fontWithName:@"Helvetica" size:fontSize] andheight:1024];
                
                float buttonWidth = frameSize.width;
                float xVal = xValForDisclosure - (buttonWidth + paddingWithDisclosure);
                switchButton.frame = CGRectMake(xVal, 4, (frameSize.width + insetPaddint), 28);
                
                switchButton.indexPath = indexPath;
                switchButton.tag = 2345;
                [switchButton addTarget:self action:@selector(showChildLinkedProcess:) forControlEvents:UIControlEventTouchUpInside];
                [background addSubview:switchButton];
                [switchButton release];
            }
        }

			if(self.selectedIndexPathForEdit != nil && indexPath.section == self.selectedIndexPathForEdit.section && indexPath.row == self.selectedIndexPathForEdit.row && self.selectedIndexPathForchildView == nil)
            {
				
                cell.clipsToBounds = YES;
					
				[[background subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
				
//                self.editDetailObject = nil;
				
                //8915 - link sfm
                UIImage * switchImage = [[UIImage imageNamed:@"more.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:30];
                UIImage * hoverImage = [[UIImage imageNamed:@"more-hover.png"]stretchableImageWithLeftCapWidth:24 topCapHeight:30];
                
//				UIImageView *seperatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, 32)];
				//Adding Macro for Width
				UIImageView *seperatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 32)];
                seperatorView.image = [UIImage imageNamed:@"shadow_gray_light_blue-1.png" ];
                seperatorView.tag = 87445;
                [background addSubview:seperatorView];
                [seperatorView release];
				
		if([[_child_sfm_process_node  allKeys] containsObject:detail_layout_id])
                {
                    {
                        int fontSize = 16;
                        int insetPaddint = 24;
                        int paddingWithDisclosure = 50;
                        SWitchViewButton * switchButton = [[SWitchViewButton alloc] init];
                        [switchButton setBackgroundImage:switchImage forState:UIControlStateNormal];
                        
                        //8915 - link sfm
                        [switchButton setBackgroundImage:hoverImage forState:UIControlStateHighlighted];
                        
                        switchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                        NSString *titleString = [[appDelegate.wsInterface.tagsDictionary objectForKey:MOREBUTTONTEXT] stringByAppendingFormat:@" "];

                        [switchButton setTitle:titleString forState:UIControlStateNormal];
                        [switchButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:fontSize]];
                        
                        //get variable frame based on font.
                        switchButton.titleEdgeInsets = UIEdgeInsetsMake(0, insetPaddint, 0, 0);
                        CGSize frameSize = [Utility getBoundSizeForString:switchButton.titleLabel.text withFont:[UIFont fontWithName:@"Helvetica" size:fontSize] andheight:1024];
                        
                        float xVal = xValForDisclosure - (frameSize.width + paddingWithDisclosure );
                        switchButton.frame = CGRectMake(xVal, 4, (frameSize.width + insetPaddint), 28);

						switchButton.indexPath = indexPath;
						[switchButton addTarget:self action:@selector(showChildLinkedProcess:) forControlEvents:UIControlEventTouchUpInside];
						[background addSubview:switchButton];
						[switchButton release];
		    }
                }
				
                
                UIImage *disclosureImg = [UIImage imageNamed:@"disclosure-down.png"];
                UIImage *savImg = [UIImage imageNamed:@"SFM-Screen-Done-Back-Button.png"];
                int padding = 100;
                UIView *viewPadding=[[UIView alloc] initWithFrame:cell.frame];
                viewPadding.backgroundColor=[UIColor clearColor];
                [background  addSubview:viewPadding];
//                [viewPadding release]; // Damodar - Win14 - MemMgt - revoked to fix crash
                float xValForDisclosure = cell.frame.size.width - ( disclosureImg.size.width + padding );
                
                CGRect disclosurebtnFrame = CGRectMake(xValForDisclosure, 2, 30, 30);
                
                SVMAccessoryButton *triangleBtn = [[SVMAccessoryButton alloc] initWithFrame:disclosurebtnFrame];;
                triangleBtn.indexpath = self.selectedIndexPathForEdit;
                triangleBtn.tag = 9743;
				//Radha Defect Fix 7446
				triangleBtn.index = index;
                [triangleBtn setBackgroundImage:disclosureImg forState:UIControlStateNormal];
                [triangleBtn addTarget:self action:@selector(lineDetailBtnAction:) forControlEvents:UIControlEventTouchUpInside];
                [background addSubview:triangleBtn];
                [triangleBtn release];
			
                CGRect btnFrame = CGRectMake(6, 4, 70, 28);      //TODO : PLEASE CHANGE (hard coded)
                
				//Radha Defect Fix 7446
                SVMAccessoryButton *saveBtn = [[SVMAccessoryButton alloc] initWithFrame:btnFrame];
                saveBtn.tag = 9742;
				saveBtn.index = index;
				 NSString * done = [appDelegate.wsInterface.tagsDictionary objectForKey:DONE_BUTTON_TITLE];
				[saveBtn setTitle:done forState:UIControlStateNormal];
				//Defect Fix :- 7454
				[savImg stretchableImageWithLeftCapWidth:9 topCapHeight:9];
				[saveBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
                // Dam - Win14 changes
                if([[[UIDevice currentDevice] systemVersion] floatValue] >= SUPPORTED_IOS_VERSION)
                    saveBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                else
                    saveBtn.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
				
                [saveBtn setBackgroundImage:savImg forState:UIControlStateNormal];
                [saveBtn addTarget:self action:@selector(lineDetailBtnAction:) forControlEvents:UIControlEventTouchUpInside];
                [background addSubview:saveBtn];
                			
				
				CGRect removeBtnFrame = CGRectMake(saveBtn.frame.size.width+10, 4, 70, 28);
				
				UIButton * removeBtn = [[UIButton alloc] initWithFrame:removeBtnFrame];
				removeBtn.tag= index;
				NSString * cancelTitle = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON];
				[removeBtn setTitle:cancelTitle forState:UIControlStateNormal];
				//Defect Fix :- 7454
				[savImg stretchableImageWithLeftCapWidth:9 topCapHeight:9];
				[removeBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
                // Dam - Win14 changes
                if([[[UIDevice currentDevice] systemVersion] floatValue] >= SUPPORTED_IOS_VERSION)
                    removeBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                else
                    removeBtn.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
				
                [removeBtn setBackgroundImage:savImg forState:UIControlStateNormal];
                [removeBtn addTarget:self action:@selector(removeDetailLine:) forControlEvents:UIControlEventTouchUpInside];
                [background addSubview:removeBtn];
				
				[saveBtn release];
                [removeBtn release];

				[self showEditViewOfLineInView:background forIndexPath:indexPath forEditMode:YES];
					isEditRow = YES;

                background.backgroundColor = [UIColor clearColor];//kri
            }
			else
            {
                background.backgroundColor = [UIColor clearColor];//kri
            }
            if(self.selectedIndexPathForchildView != nil && indexPath.section == self.selectedIndexPathForchildView.section && indexPath.row == self.selectedIndexPathForchildView.row && self.selectedIndexPathForEdit == nil)
            {
                self.SFMChildTableview = nil;
				
				
				//Radha :- 14/June/2013
				//Remove the child view button and add it again
				
				[[background viewWithTag:2345] removeFromSuperview];
				
                //8915 - link sfm
                UIImage * switchImage = [[UIImage imageNamed:@"more.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:30];
                UIImage * hoverImage = [[UIImage imageNamed:@"more-hover.png"]stretchableImageWithLeftCapWidth:24 topCapHeight:30];

				UIImageView *seperatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 32)];
                seperatorView.image = [UIImage imageNamed:@"shadow_gray_light_blue-1.png" ];
                seperatorView.tag = 87445;
                [background addSubview:seperatorView];
                [seperatorView release];
				
				//8915 - link sfm
                int fontSize = 16;
                int insetPaddint = 24;
                int paddingWithDisclosure = 50;
                SWitchViewButton * switchButton = [[SWitchViewButton alloc] init];
                [switchButton setBackgroundImage:switchImage forState:UIControlStateNormal];
                
                //8915 - link sfm
                [switchButton setBackgroundImage:hoverImage forState:UIControlStateHighlighted];
                
                switchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                NSString *titleString = [[appDelegate.wsInterface.tagsDictionary objectForKey:MOREBUTTONTEXT] stringByAppendingFormat:@" "];

                [switchButton setTitle:titleString forState:UIControlStateNormal];
                [switchButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:fontSize]];
                
                //get variable frame based on font.
                switchButton.titleEdgeInsets = UIEdgeInsetsMake(0, insetPaddint, 0, 0);
                CGSize frameSize = [Utility getBoundSizeForString:switchButton.titleLabel.text withFont:[UIFont fontWithName:@"Helvetica" size:fontSize] andheight:1024];
                
                float xVal = xValForDisclosure - (frameSize.width + paddingWithDisclosure );
                switchButton.frame = CGRectMake(xVal, 4, (frameSize.width + insetPaddint), 28);

				switchButton.indexPath = indexPath;
				switchButton.tag = 2345;
				[switchButton addTarget:self action:@selector(closeSFMChildViewProcess:) forControlEvents:UIControlEventTouchUpInside];
				[background addSubview:switchButton];
				[switchButton release];

               [self showChildViewProcessTable:cell.contentView indexpath:indexPath];
                            isEditRow = YES;
                background.backgroundColor = [UIColor clearColor];
            }
            else
            {
                background.backgroundColor = [UIColor clearColor];//kri
            }
            
		}
		[cell.contentView addSubview:background];
    }

    //8483
    if (![Utility notIOS7]) {
        CGRect someFrame =  background.frame;
        someFrame.origin.x = kLeftPaddingForiOS7;
        background.frame =someFrame;
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
    //8483
    UIImageView *finalImageView = nil;
    if(![Utility notIOS7]){
        
        if (background.frame.size.height > 40) {
             bgView.frame = CGRectMake(kLeftPaddingForiOS7, 0, 620, 93);
        }
        else {
             bgView.frame = CGRectMake(kLeftPaddingForiOS7, 0, 620, 40);
        }
       
        finalImageView = [[[UIImageView alloc] init] autorelease];
        [finalImageView addSubview:bgView];
        finalImageView.frame = CGRectMake(0, 0, _tableView.frame.size.width, 32);
        finalImageView.backgroundColor = [UIColor clearColor];
        finalImageView.clipsToBounds = YES;
        cell.backgroundView = isEditRow ? nil : finalImageView;
        
    }
    else{
        cell.backgroundView = isEditRow ? nil : bgView;
    }
    
    if (![Utility notIOS7]) {
        cell.backgroundColor = [UIColor clearColor]; //8483
    }
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CGRect cellframe = cell.frame;
        cellframe.size.width = 704;
        cell.frame = cellframe;

        background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 28)];
	}
	else
    {
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
        background = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 100)] autorelease];
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
            
            SMLog(kLogLevelVerbose,@"%@", header_dict);
            
            if (row == 0)
            {
                for (int i = 0; i < 2; i++)
                {
                    UILabel * lbl; 
                    if (i == 0)
                    {
                        lbl = [[[UILabel alloc] initWithFrame:CGRectMake((i+1)*20, 0, width, control_height)] autorelease];
                        lbl.text = [appDelegate.wsInterface.tagsDictionary objectForKey:SLA_RESTORATION];
                    }
                    else
                    {
                        lbl = [[[UILabel alloc] initWithFrame:CGRectMake(i*400, 0, width, control_height)] autorelease];
                        lbl.text = [appDelegate.wsInterface.tagsDictionary objectForKey:SLA_RESOLUTION];
                    }
                    lbl.font = [UIFont fontWithName:@"HelveticaBold" size:19];
                    lbl.font = [UIFont boldSystemFontOfSize:lbl.font.pointSize];
                    lbl.textColor = [appDelegate colorForHex:@"2d5d83"];
                    lbl.backgroundColor = [UIColor clearColor];
                    [background addSubview:lbl];
                }
                [cell.contentView addSubview:background];
               
                //8483
                if (![Utility notIOS7]) {
                    CGRect someFrame = background.frame;
                    if (someFrame.origin.x < 5) {
                        someFrame.origin.x = kLeftPaddingForiOS7;
                    }
                    background.frame = someFrame;
                    
                    bgView.frame = CGRectMake(kLeftPaddingForiOS7, 0, 620, 40);
                    UIImageView *finalImageView = [[[UIImageView alloc] init] autorelease];
                    [finalImageView addSubview:bgView];
                    finalImageView.backgroundColor = [UIColor clearColor];
                    cell.backgroundView = finalImageView;
                    
                    
                }
                else{
                    cell.backgroundView = bgView;
                }
                cell.accessoryType = UITableViewCellAccessoryNone;
                [cell setBackgroundColor:[UIColor clearColor]];
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
				//Defect Fix :- 7421
                restorationTimer.view.frame = CGRectMake(0, 0, width, control_height-10);
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
				//Defect Fix :- 7421
                resolutionTimer.view.frame = CGRectMake(380, 0, width, control_height-10);
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
				//Defect Fix :- 7421
				[background setFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
                [background addSubview:resolutionTimer.view];
                
                [cell.contentView addSubview:background];

                //8483
                if (![Utility notIOS7]) {
                    CGRect someFrame =  background.frame;
                    someFrame.origin.x = kLeftPaddingForiOS7;
                    background.frame = someFrame;
                }
                
                bgView.alpha = 0.0;
                cell.backgroundView = bgView;
                cell.accessoryType = UITableViewCellAccessoryNone;
                [cell setBackgroundColor:[UIColor clearColor]];
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
                       
            UILabel * lbl = [[[UILabel alloc] initWithFrame:CGRectMake(x, 5, width,control_height)] autorelease];
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
                CusLabel * custLabel = [[CusLabel alloc] initWithFrame:CGRectMake((2*j+1)*field_width , 10, field_width,control_height-8)];
                //8801 and 9168 pointed fix
                custLabel.numberOfLines = 1;
                custLabel.lineBreakMode = NSLineBreakByTruncatingTail;
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
				custLabel.isInDetailMode = NO;
                
                
                //Radha 2012june08
                BOOL recordExists = [appDelegate.dataBase checkIfRecordExistForObject:related_to_table_name Id:key];
                
                //Aparna: 6889
                if (!recordExists)
                {
                    NSString *sf_id =  [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:related_to_table_name local_id:key];
                    recordExists = [appDelegate.dataBase checkIfRecordExistForObject:related_to_table_name Id:sf_id];
                }
                
                
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
                        custLabel.isAccessibilityElement = YES;
                        custLabel.accessibilityValue = @"{text_color: blue}";
                    }
                    else
                    {              
                    }
                }
                
                [background addSubview:custLabel];
                
            }
            
            else
            {
                lbl1 = [[UILabel alloc]initWithFrame:CGRectMake((2*j+1)*field_width , 10, field_width,control_height-8)];
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
                        v1.frame = CGRectMake((2*j+1)*field_width +10, 8, 18, 18);
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
    BOOL isEditRow = NO;
    if (selectedSection == SHOW_LINES_ROW || selectedSection == SHOWALL_LINES)
	{
        header = FALSE;
		NSMutableArray * details = [appDelegate.SFMPage objectForKey:gDETAILS];
		NSMutableDictionary * detail = [details objectAtIndex:index];
		NSMutableArray * detail_fields = [detail objectForKey:gDETAILS_FIELDS_ARRAY];
        NSInteger columns = [[detail objectForKey:gDETAILS_NUMBER_OF_COLUMNS] intValue];
        NSString * detail_layout_id = [detail objectForKey:gDETAILS_LAYOUT_ID];
        
		
		NSInteger field_width = 0;
		//Fix for crash  when tap on back button
		if (columns > 0)
			field_width = background_width/columns;
            
        if (row == 0) //display the column titles
		{
            [background setClipsToBounds:YES];
            // If fields are not present - ERROR CONDITION - then columns should not be added
            if ([detail_fields count] > 0)
            {
                for (int j=0;j<columns && j<[detail_fields count];j++)
                {
					//#Defect Fix :- Radha 7372
                    UILabel * lbl = [[[UILabel alloc] initWithFrame:CGRectMake(j*field_width+8, 5, field_width-80,control_height)] autorelease];
                    NSString * label_name = [[detail_fields objectAtIndex:j] objectForKey:gFIELD_LABEL];
                    lbl.text = label_name;
                    lbl.font = [UIFont fontWithName:@"HelveticaBold" size:19];
                    lbl.font = [UIFont boldSystemFontOfSize:lbl.font.pointSize];
                    lbl.textColor = [UIColor whiteColor];
                    lbl.backgroundColor = [UIColor clearColor];
					//#Defect Fix :- Radha 7372
                    // Dam - Win14 changes
                    if([[[UIDevice currentDevice] systemVersion] floatValue] >= SUPPORTED_IOS_VERSION)
                        lbl.lineBreakMode = NSLineBreakByTruncatingTail;
                    else
                        lbl.lineBreakMode = UILineBreakModeTailTruncation;
					
					//Radha :- WO Debrief #7372
					lbl.userInteractionEnabled = YES;
                    /*Radha set accesibility UIAutomation */

                    lbl.isAccessibilityElement = YES;
                    lbl.accessibilityValue = label_name;
					UITapGestureRecognizer * tapMe = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizedForEdit:)];
					[lbl addGestureRecognizer:tapMe];
					[tapMe release];

					[background addSubview:lbl];
					[background bringSubviewToFront:lbl];
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
            NSInteger ValueCount = 0;
			NSMutableArray * detail_values = [[detail objectForKey:gDETAILS_VALUES_ARRAY] objectAtIndex:row-1];
             NSString * record_id  = @"";
                        
            
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
            //krishna 8288 - hyperlink
            //hyperlink is not limited to only refernce fields
            
            NSString * objectName_  =  [detail objectForKey:gDETAIL_OBJECT_NAME];
            
            NSString * newProcessId = @"";
            
            for (int j = 0; j < [appDelegate.view_layout_array count]; j++)
            {
                NSDictionary * viewLayoutDict = [appDelegate.view_layout_array objectAtIndex:j];
                NSString * objName = [viewLayoutDict objectForKey:VIEW_OBJECTNAME];
                
                SMLog(kLogLevelVerbose,@"%@ %@", objName , objectName_);
                if ([objName isEqualToString:objectName_])
                {
                    SMLog(kLogLevelVerbose,@" after %@ %@", objName , objectName_);
                    newProcessId = [viewLayoutDict objectForKey:@"SVMXC__ProcessID__c"];
                    break;
                }
            }
           
			for (int j = 0; j < columns && j < [detail_fields count]; j++)//[detail_values count ]
			{
                CGRect frame =  CGRectMake(j*field_width+6, 9, field_width-40,control_height-6);
                lbl2 = [[UILabel alloc]initWithFrame:frame];
                NSString * field_data_type = [[detail_fields objectAtIndex:j] objectForKey:gFIELD_DATA_TYPE];
                NSString * value = [[detail_values objectAtIndex:j] objectForKey:gVALUE_FIELD_VALUE_VALUE];
                
                //8288 krishna
                //hyperlink
                
                //#Defect Fix :- Radha 7372
                // Dam - Win14 changes
                if([[[UIDevice currentDevice] systemVersion] floatValue] >= SUPPORTED_IOS_VERSION)
                    lbl2.lineBreakMode = NSLineBreakByTruncatingTail;
                else
                    lbl2.lineBreakMode = UILineBreakModeTailTruncation;
                
                //Radha :- WO Debrief #7372
                lbl2.userInteractionEnabled = YES;
                
                //adding single tap and double tap guesture on lbl2
                
                UIGestureRecognizer * tapMe = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
                
                UITapGestureRecognizer * doubleTapMe = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(celltapRecognizer:)];
                doubleTapMe.numberOfTapsRequired = 2;

                [tapMe requireGestureRecognizerToFail:doubleTapMe];
                
                [lbl2 addGestureRecognizer:tapMe];
                [lbl2 addGestureRecognizer:doubleTapMe];
                
                [doubleTapMe release];
                [tapMe release];

                
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
				
                //krishna 8288 - hyperlink
                //hyperlink is not limited to only refernce fields
                if([newProcessId length] != 0 && newProcessId != nil && [record_id length] != 0 && record_id  != nil )
                {
                    lbl2.textColor = [UIColor blueColor];
                }
                
                [background addSubview:lbl2];
				                
                if ( [field_data_type isEqualToString:@"boolean"] )
                {
                    UIImageView * v1 = nil;

                    [lbl2 removeFromSuperview];

                    NSString * control_value = [[detail_values objectAtIndex:j] objectForKey:gVALUE_FIELD_VALUE_KEY];
                    
                    if ([control_value isEqualToString:@"True"] || [control_value isEqualToString:@"true"] || [value isEqualToString:@"1"]) 
                    {
                        v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-tick-Icon.png"]] autorelease];
                        v1.backgroundColor = [UIColor clearColor];
                        v1.frame = CGRectMake(j*field_width+20, 15, 18, 18);
                        v1.contentMode = UIViewContentModeCenter;
                        [background addSubview:v1];
                    }
                    else
                    {
                        v1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SFM-Screen-boolean-Cancel-Icon.png"]] autorelease];
                        v1.backgroundColor = [UIColor clearColor];
                        v1.contentMode = UIViewContentModeCenter;
                        v1.frame = CGRectMake(j*field_width+20, 15, 18, 18);
                        [background addSubview:v1];
                    }
                }                   
			}
            cell.accessoryView = nil;
		}
        background.backgroundColor = [UIColor clearColor];
        //Kri
        //background.frame = CGRectMake(0, 0, cell.contentView.frame.size.width-42, cell.contentView.frame.size.height);
        
        
        //KRI to remove the header part
        //KRI get edit view from sfmeditVC
        
        if (row!=0)
		{
            //Radha : 3/june/2013
			UIImage * switchImage = [UIImage imageNamed:@"SFM-Screen-Switch-Views-button_transparent.png"];
			float xValForSwitchbutton = cell.frame.size.width - ( switchImage.size.width + 130 );
			
			CGRect swithchButtonFrame = CGRectMake(xValForSwitchbutton, 6, 35, 30);
			
	    if([[_child_sfm_process_node  allKeys] containsObject:detail_layout_id])
            {
                {
					SWitchViewButton * switchButton = [[SWitchViewButton alloc] initWithFrame:swithchButtonFrame];
					[switchButton setBackgroundImage:switchImage forState:UIControlStateNormal];
					switchButton.indexPath = indexPath;
					switchButton.tag = 2345;
					[switchButton addTarget:self action:@selector(showChildLinkedProcess:) forControlEvents:UIControlEventTouchUpInside];
					[background addSubview:switchButton];
					[switchButton release];
		}
            }
			
            UIImage *disclosureImg = [UIImage imageNamed:@"disclosure.png"];
            float xValForDisclosure = tableView.frame.size.width - ( disclosureImg.size.width + 100 ); //8613

            CGRect disclosurebtnFrame = CGRectMake(xValForDisclosure, 4, 30, 30);
            SVMAccessoryButton *triangleBtn = [[SVMAccessoryButton alloc] initWithFrame:disclosurebtnFrame];;
            triangleBtn.indexpath = indexPath;
			//Radha Defect Fix 7446
			triangleBtn.index = index;
            triangleBtn.tag = 9746;
            [triangleBtn setBackgroundImage:disclosureImg forState:UIControlStateNormal];
            [triangleBtn addTarget:self action:@selector(lineDetailBtnActionCheck:) forControlEvents:UIControlEventTouchUpInside];
			
			
            [background addSubview:triangleBtn];
            [triangleBtn release];
        }
        if(self.selectedIndexPathForEdit != nil && indexPath.section == self.selectedIndexPathForEdit.section && indexPath.row == self.selectedIndexPathForEdit.row )
        {
            cell.clipsToBounds = YES;
            
            [[background subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
//            self.editDetailObject = nil;
			
			//Adding Macro for Width            
            UIImageView *seperatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 32)];
            seperatorView.image = [UIImage imageNamed:@"shadow_gray_light_blue-1.png" ];
            seperatorView.tag = 87445;
            [background addSubview:seperatorView];
            [seperatorView release];
            
            UIImage *disclosureImg = [UIImage imageNamed:@"disclosure-down.png"];
            int padding = 100;
            
            float xValForDisclosure = cell.frame.size.width - ( disclosureImg.size.width + padding );
            
            CGRect disclosurebtnFrame = CGRectMake(xValForDisclosure, 2, 30, 30);
            SVMAccessoryButton *triangleBtn = [[SVMAccessoryButton alloc] initWithFrame:disclosurebtnFrame];;
            triangleBtn.indexpath = self.selectedIndexPathForEdit;
            triangleBtn.tag = 9743;
			//Radha Defect Fix 7446
			triangleBtn.index = index;
            [triangleBtn setBackgroundImage:disclosureImg forState:UIControlStateNormal];
            [triangleBtn addTarget:self action:@selector(lineDetailBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [background addSubview:triangleBtn];
            [triangleBtn release];
			
			//Radha : 3/june/2013
			UIImage * switchImage = [UIImage imageNamed:@"SFM-Screen-Switch-Views-button_transparent.png"];
			float xValForSwitchbutton = cell.frame.size.width - ( switchImage.size.width + 130 );
			
			CGRect swithchButtonFrame = CGRectMake(xValForSwitchbutton, 6, 35, 30);
			

			if([[_child_sfm_process_node  allKeys] containsObject:detail_layout_id])
            {
                {
					SWitchViewButton * switchButton = [[SWitchViewButton alloc] initWithFrame:swithchButtonFrame];
					[switchButton setBackgroundImage:switchImage forState:UIControlStateNormal];
					switchButton.indexPath = indexPath;
					[switchButton addTarget:self action:@selector(showChildLinkedProcess:) forControlEvents:UIControlEventTouchUpInside];
					[background addSubview:switchButton];
					[switchButton release];
                }
            }


            
            [self showEditViewOfLineInView:background forIndexPath:indexPath forEditMode:NO];
            
            background.backgroundColor = [UIColor clearColor];
            isEditRow = YES;
        }
		
		if(self.selectedIndexPathForchildView != nil && indexPath.section == self.selectedIndexPathForchildView.section && indexPath.row == self.selectedIndexPathForchildView.row )
		{
			self.SFMChildTableview = nil;
			
			
			//Radha :- 14/June/2013
			//Remove the child view button and add it again
			
			[[background viewWithTag:2345] removeFromSuperview];
			
			UIImage * switchImage = [UIImage imageNamed:@"SFM-Screen-Switch-Views-button_transparent.png"];
			float xValForSwitchbutton = cell.frame.size.width - ( switchImage.size.width + 130 );
			//Adding Macro for Width
			UIImageView *seperatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 32)];
            seperatorView.image = [UIImage imageNamed:@"shadow_gray_light_blue-1.png" ];
            seperatorView.tag = 87445;
            [background addSubview:seperatorView];
            [seperatorView release];
			
			CGRect swithchButtonFrame = CGRectMake(xValForSwitchbutton, 6, 35, 30);
			
			SWitchViewButton * switchButton = [[SWitchViewButton alloc] initWithFrame:swithchButtonFrame];
			[switchButton setBackgroundImage:switchImage forState:UIControlStateNormal];
			switchButton.indexPath = indexPath;
			switchButton.tag = 2345;
			[switchButton addTarget:self action:@selector(closeSFMChildViewProcess:) forControlEvents:UIControlEventTouchUpInside];
			[background addSubview:switchButton];
			[switchButton release];			
            
			[self showChildViewProcessTable:cell.contentView indexpath:indexPath ];
            isEditRow = YES;
             background.backgroundColor = [UIColor clearColor];
		}
        
        //krishna 8288 - hyperlink
        //on double tap on cell it should take to its object screen
        cell.userInteractionEnabled = TRUE;
        UITapGestureRecognizer * cellTap;
        cellTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(celltapRecognizer:)] autorelease];
        [cellTap setNumberOfTapsRequired:2];
        NSInteger cellCount = 10000;
        int section_ = index + 1;
        cell.tag = (cellCount * section_) + row;
        [cell addGestureRecognizer:cellTap];
		[cell.contentView addSubview:background];
	}
    else if(selectedSection == SHOW_ADDITIONALINFO_ROW || selectedSection == SHOW_ALL_ADDITIONALINFO)
    {
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
            
			NSString *probDes = [appDelegate.wsInterface.tagsDictionary objectForKey:SERVICE_REPORT_PROBLEM_DESCRIPTION];
			NSString *createdDate = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_CreatedDate];
            NSArray * array = [[[NSArray alloc] initWithObjects:probDes,createdDate, nil] autorelease];
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
                NSInteger colmn_count = 0;
                for (int j = 0; j < [keys count]; j++)
                {
                    CGRect frame =  CGRectMake(j*field_width+8, 0, field_width-8,control_height);
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
                                                      
                            id date = [info_dict objectForKey:@"CreatedDate"];
                            NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
                            [frm setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
                            
                            //Aparna: FIx for the defect 4611
                            if([date isKindOfClass:[NSDate class]])
                            {
                                value = [frm stringFromDate:date];
                            }
                            else
                            {
                                value = date;
                                value = [iOSInterfaceObject getLocalTimeFromGMT:value];
                            }

                            
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
    
    //8483
    if (![Utility notIOS7]) {
        CGRect someFrame =  background.frame;
        someFrame.origin.x = kLeftPaddingForiOS7;
        background.frame =someFrame;
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
    
    //8483
    UIImageView *finalImageView = nil;
    if(![Utility notIOS7]){
        
        if (background.frame.size.height > 40) {
            bgView.frame = CGRectMake(kLeftPaddingForiOS7, 0, 620, 93);
        }
        else {
            bgView.frame = CGRectMake(kLeftPaddingForiOS7, 0, 620, 40);
        }
        
        
        finalImageView = [[[UIImageView alloc] init] autorelease];
        [finalImageView addSubview:bgView];
        finalImageView.frame = CGRectMake(0, 0, _tableView.frame.size.width, 32);
        finalImageView.backgroundColor = [UIColor clearColor];
        finalImageView.clipsToBounds = YES;
        cell.backgroundView = isEditRow ? nil : finalImageView;
        
    }
    else {
        bgView.frame = CGRectMake(0, 0, _tableView.frame.size.width, 32);
        cell.backgroundView = isEditRow ? nil : bgView;
    }
    
    if(self.selectedIndexPathForchildView != nil && indexPath.section == self.selectedIndexPathForchildView.section && indexPath.row == self.selectedIndexPathForchildView.row )
	{
		[cell.contentView bringSubviewToFront:self.SFMChildTableview.view];
	}
	else if(self.selectedIndexPathForEdit != nil && indexPath.section == self.selectedIndexPathForchildView.section && indexPath.row == self.selectedIndexPathForEdit.row )
	{
		[cell.contentView bringSubviewToFront:self.editDetailObject.view];
	}
    if (![Utility notIOS7]) {
         cell.backgroundColor = [UIColor clearColor]; //8483
    }
   
 	return cell;
}


-(void)celltapRecognizer:(id)sender
{
    if (!isInViewMode)
    {       
        SMLog(kLogLevelVerbose,@"cell being tapped ");
        UITapGestureRecognizer * tap = sender;
        
        //krishna 8288 - hyperlink
        //On double tap on label or tableview cell, it should take to object screen.
        //since label is within cell, we need to get cell by traversing from containerview,contentview,scrollview.
        UIView *container = nil;
        UIView *contentView = nil;
        UIView *contentScrollView = nil;
        UIView *tableViewCell = nil;
        
        if([tap.view isKindOfClass:[UILabel class]]) {
            container = tap.view.superview;
            contentView = [container superview];
            contentScrollView = [contentView superview];
        }
        //view heirarchy in iOS7 is different
        if([Utility notIOS7]) {
            tableViewCell = contentScrollView;
        }
        else {
            tableViewCell = [contentScrollView superview];
        }
        if ([tap.view isKindOfClass:[UITableViewCell class]] || [tableViewCell isKindOfClass:[UITableViewCell class]] )
        {
            UITableViewCell * cell = ([tap.view isKindOfClass:[UITableViewCell class]] ? ((UITableViewCell *) tap.view) : ((UITableViewCell *)tableViewCell));
            
            //krishna 8288
            //hyperlink -
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            NSInteger indexpath = cell.tag;
            SMLog(kLogLevelVerbose,@"%d",indexpath);
            NSInteger row     = indexpath % 10000;
            NSInteger section = indexpath /10000;
            SMLog(kLogLevelVerbose,@"%d %d" , row , section);
            
            
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

                    
            
            NSString * objectName_  =  [detail objectForKey:gDETAIL_OBJECT_NAME];;
            
            NSString * record_id = temp_record_id;
           
            NSString * newProcessId = @"";
            
            for (int j = 0; j < [appDelegate.view_layout_array count]; j++)
            {
                NSDictionary * viewLayoutDict = [appDelegate.view_layout_array objectAtIndex:j];
                NSString * objName = [viewLayoutDict objectForKey:VIEW_OBJECTNAME];
                
                SMLog(kLogLevelVerbose,@"%@ %@", objName , objectName_);
                if ([objName isEqualToString:objectName_])
                {
                    SMLog(kLogLevelVerbose,@" after %@ %@", objName , objectName_);
                    newProcessId = [viewLayoutDict objectForKey:@"SVMXC__ProcessID__c"];
                    break;
                }
            }
            
            if([newProcessId length] != 0 && newProcessId != nil && [record_id length] != 0 && record_id  != nil )
            {
                
                [activity startAnimating];
                [self initAllrequriredDetailsForProcessId:newProcessId recordId:record_id object_name:objectName_];
                [self fillSFMdictForOfflineforProcess:newProcessId forRecord:record_id ];
                [self didReceivePageLayoutOffline];
                return;
            }
          
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
    SMLog(kLogLevelVerbose,@"%f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);

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
            custLabel.isInDetailMode = NO;
            
            //Radha 2012june08
            BOOL recordExists = [appDelegate.dataBase checkIfRecordExistForObject:related_to_table_name Id:key];
            
            
            //Aparna: 6889
            if (!recordExists)
            {
                NSString *sf_id =  [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:related_to_table_name local_id:key];
                recordExists = [appDelegate.dataBase checkIfRecordExistForObject:related_to_table_name Id:sf_id];
            }

            
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
                    custLabel.isAccessibilityElement = YES;
                    custLabel.accessibilityValue = @"{text_color: blue}";
                    
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

   
    if([control_type isEqualToString:@"picklist"] || [control_type isEqualToString:@"multipicklist"])
    {
        if(appDelegate.isWorkinginOffline)
        {
            NSString * detail_objectName = [Disclosure_dict objectForKey:gDETAIL_OBJECT_NAME];
            NSMutableArray * descObjArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
            NSMutableArray * descObjValidFor = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
            
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
                self.currentEditRow = nil;
                return;
            }
        }
    }
     self.currentEditRow = [indexPath retain];
    
    SMLog(kLogLevelVerbose,@"DetailView didselectrow %@", indexPath);
}

- (void)viewDidUnload
{

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

    }
    else
    {
        DetailViewController * newDetail = (DetailViewController *)viewController;
        newDetail->didRunOperation = NO;
    }
    
    DetailViewController * detailView = (DetailViewController *)viewController;
    [detailView.tableView reloadData];

    
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
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.isDetailActive)
    {
    }
    
    didReceiveMemoryWarning = YES;
}

- (void)dealloc
{
    //sahana
    
//    [attachmentview release];
//    attachmentview = nil;
    
    //Radha :- Child SFM UI
    [SFMChildTableview release];
    SFMChildTableview = nil;
    [bizRuleResult release];

    //KRI
    [editDetailObject release];
	editDetailObject = nil;
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
    //Radha :- Child SFM UI
    [selectedIndexPathForEdit release];
    [editViewOfLine release]; 
    [jsExecuter release];
    [bizRuleJSExecuter release];
    [priceBookData release];
    
    
    //sahana child SFM
    [sfmChildSelectedRecordId release];
    sfmChildSelectedRecordId = nil;
    
    [SfmChildSelectedIndexPath release];
    SfmChildSelectedIndexPath = nil;
    
    
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
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
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
    self.currentEditRow = [indexPath retain];
    SMLog(kLogLevelVerbose,@"%@", currentEditRow);
}

// This one's ONLY for LOOKUP
- (void) selectControlAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentEditRow = [indexPath retain];
}

- (void) deselectControlAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void) control:(id)control didChangeValue:(NSString *)value atIndexPath:(NSIndexPath *)indexPath
{
    // Obtain the section and row for the control being edited curently
    // Modify the field according to the Field_API_Name
    SMLog(kLogLevelVerbose,@"%@", value);
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
                        SMLog(kLogLevelVerbose,@"%@",date);
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
                    
                    //Aparna: FORMFILL
                    if([control_type isEqualToString:@"reference"])
                    {
                        NSString * fieldMapping = [dict objectForKey:gFIELD_MAPPING];
                        if ([fieldMapping length] != 0)
                        {
                            NSString * referenceObj = [dict objectForKey:gFIELD_RELATED_OBJECT_NAME];
                            NSDictionary * formfillDict = [appDelegate.databaseInterface recordsToUpdateForObjectId:fieldKeyValue mappingId:fieldMapping objectName:referenceObj];
                            [self setFormFillInfo:formfillDict forPageLayoutDict:[appDelegate.SFMPage objectForKey:gHEADER] recordId:nil];

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
                        SMLog(kLogLevelVerbose,@"%@",date);
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
            SMLog(kLogLevelVerbose,@"%@", value);
            botSpinner.indexPath = indexPath;
            botSpinner.fieldAPIName = fieldType;
            botSpinner.required = required;
            botSpinner.controlDelegate = self;
            botSpinner.control_type = controlType;
            botSpinner.TFHandler.isdependentPicklist =isdependentPicklist;
            botSpinner.TFHandler.validFor = validFor;
            botSpinner.TFHandler.controllerName = dependPick_controllerName;
            SMLog(kLogLevelVerbose,@" isdepentent value  validFor%@  controlType %@" , validFor , controlType);
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
		//Keyboard fix for readonly fields
        BOOL isFieldEnable;
        if (!isInViewMode)
        {
            isFieldEnable=NO;
        }
        else
        {
            isFieldEnable=readOnly;
        }
        PercentType = [[CTextField alloc] initWithFrame:frame lableValue:labelValue controlType:@"percent" isinViewMode:isInViewMode isEditable:isFieldEnable];
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
		//Keyboard fix for readonly fields
        BOOL isFiledEditable;
        if (!isInViewMode)
        {
            isFiledEditable=NO;
        }
        else
        {
            isFiledEditable=readOnly;
        }
        phonetype = [[CTextField  alloc] initWithFrame:frame lableValue:labelValue controlType:@"phone" isinViewMode:isInViewMode isEditable:isFiledEditable];
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
            currency = [[CTextField  alloc] initWithFrame:frame lableValue:labelValue controlType:@"currency" isinViewMode:isInViewMode isEditable:readOnly]; //Keyboard fix for readonly fields
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
			//Keyboard fix for readonly fields
			BOOL isFieldEditable;
			if (!isInViewMode)
				isFieldEditable=NO;
			else
				isFieldEditable=readOnly;
			doubleType = [[CTextField  alloc] initWithFrame:frame lableValue:labelValue controlType:@"double" isinViewMode:isInViewMode isEditable:isFieldEditable];
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
		//Keyboard fix for readonly fields
        BOOL isFieldEditable ;
        if (!isInViewMode)
        {
            isFieldEditable=NO;
        }
        else
        {
            isFieldEditable=readOnly;
        }
        
        CusTextView * textarea = [[CusTextView alloc] initWithFrame:frame lableValue:labelValue isEditable:isFieldEditable];
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
		//Keyboard fix for readonly fields
        BOOL isFieldEditable;
        if (!isInViewMode)
            isFieldEditable = NO;
        else
            isFieldEditable = readOnly;
        
        cusTextFieldAlpha  * string_control = [[cusTextFieldAlpha alloc] initWithFrame:frame control_type:controlType isInViewMode:isInViewMode isEditable:isFieldEditable];
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
		//Keyboard fix for readonly fields
        BOOL isFieldEditable;
        if (!isInViewMode)
            isFieldEditable = NO;
        else
            isFieldEditable = readOnly;

        cusTextFieldAlpha  * email_control = [[cusTextFieldAlpha alloc] initWithFrame:frame control_type:controlType isInViewMode:isInViewMode isEditable:isFieldEditable];
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
		//Keyboard fix for readonly fields
        cusTextFieldAlpha  * url_control = [[cusTextFieldAlpha alloc] initWithFrame:frame control_type:controlType isInViewMode:isInViewMode isEditable:YES];
        url_control.controlDelegate = self;
        url_control.text = value;
        url_control.enabled = readOnly; // defect 007354
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
        
        //5878:Aparna
        multipicklist_type.TextFieldDelegate.isdependentPicklist =isdependentPicklist;
        multipicklist_type.TextFieldDelegate.validFor = validFor;
        multipicklist_type.TextFieldDelegate.controllerName = dependPick_controllerName;
        
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
    //Radha :- Child SFM UI 9/June/2013
    if (self.selectedIndexPathForEdit != nil)
    {
        [self hideEditViewOfLine];
    }
	if (self.selectedIndexPathForchildView != nil)
	{
		[self hideChildLinkedViewProcess];
	}
    
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
        
        //sahana July15        
        [appDelegate.databaseInterface replaceCURRENTRECORDLiteral:object_mapping_dict sourceDict:self.headerValueMappingDict];

        
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
        
		
		//Radha
		if (currentEditRow)
		{
			self.currentEditRow = nil;
		}
		self.currentEditRow = indexPath;
        
        Disclosure_dict = nil;
        Disclosure_Details = nil;
        [self fillDictionary:_indexPath];
        
//      if(isEditingDetail)
		{
            self.editDetailObject = nil;
			[self getEditViewOfLine];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            //Radha Defect Fix 7446
	    currentRowIndex = index;
            [self showEditViewOfLineInView:cell.contentView forIndexPath:_indexPath forEditMode:YES];
			
		}
		//Defect Fix :- 7356
		[self addNavigationButtons:@""];
		
		if (appDelegate.sfmPageController.conflictExists)
		{
			NSMutableString *Confilct= [appDelegate isConflictInEvent:[appDelegate.dataBase getApiNameFromFieldLabel: appDelegate.sfmPageController.objectName] local_id:appDelegate.sfmPageController.recordId];
			
			if([Confilct length]>0)
			{
				[self moveTableViewforDisplayingConflict:Confilct];
			}
		}
        [self enableSFMUI];
        self.selectedIndexPathForEdit = indexPath;
        [self.tableView reloadData];//Kri
    }

}


#pragma mark- multiAccessoryTapped:Method
- (IBAction) multiAccessoryTapped:(id)sender
{
    //Radha :- Child SFM UI 9/June/2013
    if (self.selectedIndexPathForEdit != nil)
    {
        [self hideExpandedChildViews];
        [self hideEditViewOfLine];
        
    }
	if (self.selectedIndexPathForchildView != nil)
	{
		[self hideChildLinkedViewProcess];
		[self.tableView reloadData];
	}

	self.currentEditRow = nil;

    control = (UIControl *)sender;
    NSInteger  _section = control.tag;
    SMLog(kLogLevelVerbose,@"buttonclicked");
    NSMutableArray * details = [appDelegate.SFMPage objectForKey:gDETAILS];
    
    NSString * multiadd_search_filed = [[details objectAtIndex:_section] objectForKey:gDETAIL_MULTIADD_SEARCH];
    NSString * multiadd_seach_object = [[details objectAtIndex:_section] objectForKey:gDETAIL_MULTIADD_SEARCH_OBJECT];
    NSMutableArray * detailFieldsArray = [[details objectAtIndex:_section] objectForKey:gDETAILS_FIELDS_ARRAY];
    NSString * multiadd_label = nil;
	
	//Radha - Defect Fix 6483
	NSString * nameSearchId = @"";
	
    for(int i= 0;i<[detailFieldsArray count]; i++)
    {
        NSDictionary * dict = [detailFieldsArray objectAtIndex:i];
        NSString * field_api_name = [dict objectForKey:gFIELD_API_NAME];
        if([field_api_name isEqualToString: multiadd_search_filed] )
        { 
            multiadd_label = [dict objectForKey:gFIELD_LABEL];
			//Radha - Defect Fix 6483
			nameSearchId = ([dict objectForKey:gFIELD_RELATED_OBJECT_SEARCH_ID] != nil)?[dict objectForKey:gFIELD_RELATED_OBJECT_SEARCH_ID]:@"";
            break;
        }
    }
    
    multiAddLookup = [[MultiAddLookupView alloc] initWithNibName:@"MultiAddLookupView" bundle:nil];
    objectName = multiadd_seach_object;
    multiAddLookup.objectName = multiadd_seach_object;
    multiAddLookup.search_field = multiadd_search_filed;
    multiAddLookup.index = _section;
    multiAddLookup.delegate = self;
	//Radha - Defect Fix 6483
	multiAddLookup.searchId = nameSearchId;
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
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
    
    UIPopoverArrowDirection popOverDirection = UIPopoverArrowDirectionAny;
    CGFloat yPadding = 0.0,xPadding = 0.0;
    if (![Utility notIOS7]) {
        popOverDirection = UIPopoverArrowDirectionRight;
        yPadding = 20.0;
        xPadding = 0.0;
    }
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
		// Defect Fix #7517
		if(appDelegate.sfmPageController.conflictExists)
		{
			 [multiLookupPopover presentPopoverFromRect:CGRectMake(900 + xPadding, 200 + yPadding, 10, 20) inView:appDelegate.sfmPageController.view permittedArrowDirections:popOverDirection animated:YES];
		}
		else
		{
			 [multiLookupPopover presentPopoverFromRect:CGRectMake(900 + xPadding, 100 + yPadding, 10, 20) inView:appDelegate.sfmPageController.view permittedArrowDirections:popOverDirection animated:YES];
		}
	}
    else
    {
		// Defect Fix #7517
		if(appDelegate.sfmPageController.conflictExists)
		{
			[multiLookupPopover presentPopoverFromRect:CGRectMake(900 + xPadding, 200 + yPadding, 10, 20) inView:appDelegate.sfmPageController.view permittedArrowDirections:popOverDirection animated:YES];
		}
		else
		{
			[multiLookupPopover presentPopoverFromRect:CGRectMake(900 + xPadding, 100 + yPadding, 10, 20) inView:appDelegate.sfmPageController.view permittedArrowDirections:popOverDirection animated:YES];
		}
    }
}

#pragma mark - MultiLookUpView Delegate Method
- (void) addMultiChildRows:(NSMutableDictionary *)_array forIndex:(NSInteger)index  
{
    SMLog(kLogLevelVerbose,@"%@", appDelegate.SFMPage);
    multiLookArray = _array;
    SMLog(kLogLevelVerbose,@"%@", multiLookArray);
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
            
            //sahana July15
            [appDelegate.databaseInterface replaceCURRENTRECORDLiteral:object_mapping_dict sourceDict:self.headerValueMappingDict];
            

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
			//Radha :- Implementation  for  Required Field alert in Debrief UI : - Replaced value 1 to 0
            NSMutableArray * objects = [NSMutableArray arrayWithObjects:gDETAIL_SAVED_RECORD,[NSNumber numberWithInt:0],[NSNumber numberWithInt:0], nil];
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
			
			//Radha :- Implementation  for  Required Field alert in Debrief UI
			Disclosure_dict = nil;
			Disclosure_Details = nil;
			[self fillDictionary:indexPath];

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
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    [appDelegate.sfmPageController presentViewController: reader
                                                     animated: YES completion:nil];
    [reader release];
    SMLog(kLogLevelVerbose,@"Launch Bar Code Scanner");

}

- (void) imagePickerController: (UIImagePickerController*) readerController
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =[info objectForKey: ZBarReaderControllerResults];
    SMLog(kLogLevelVerbose,@"result=%@",results);
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
    SMLog(kLogLevelVerbose,@"symbol.data=%@",_text);
    [multiAddLookup searchBarcodeResult:_text];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    SMLog(kLogLevelVerbose,@"Dismissing Barcode Scanner");
    [reader dismissViewControllerAnimated: YES completion:nil];
    [multiAddLookup updateTxtField:@""];
    [self performSelector:@selector(DismissBarCodeReader:) withObject:@"" afterDelay:0.1f];
    [multiAddLookup searchBarcodeResult:@""];
    
}
- (void) readerControllerDidFailToRead:(ZBarReaderController*)barcodeReader withRetry:(BOOL)retry
{
    SMLog(kLogLevelWarning,@"Failed to Scan the Barcode");
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

} 

#pragma  mark - tableView delegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
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

    UIBarButtonItem * syncBarButton = [[UIBarButtonItem alloc] initWithCustomView:appDelegate.SyncProgress];
    
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
    
    NSInteger reqiredFieldCount = 0;
    // COLLECT ALL DATA FROM EDIT DETAIL SCREEN AND DUMP THEM ON APP DELEGATE SFM PAGE DATA (PROBABLY BUBBLE INFO)
    //control type
   
    for (int i = 0; i < [Disclosure_Details count]; i++)
    {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        NSString * fieldValue = @"";
        
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
              
                fieldValue = [dict objectForKey:Dvalue];
                if([fieldValue length] == 0 && check_required == TRUE)
                {
                    reqiredFieldCount ++;
                }
            }
             
        }
        SMLog(kLogLevelVerbose,@"Values Altered Successfully");
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
	NSUInteger headerCount = 0;
	if (Disclosure_Fields != nil && [Disclosure_Fields count] > 0)
	{
		headerCount = [Disclosure_Fields count];

	}
	return headerCount;
}

-(NSInteger) linesColumns
{
	NSUInteger lineCount = 0;
	if (Disclosure_Details != nil && [Disclosure_Details count] > 0)
	{
		lineCount = [Disclosure_Details count];
		
	}
	return lineCount;
}

-(void) fillDictionary:(NSIndexPath *)indexPath
{
    NSMutableArray * details = [appDelegate.SFMPage objectForKey:gDETAILS];
    
    if ([details count]>0)
    {
        NSMutableDictionary * detail = [details objectAtIndex:indexPath.section];
        Disclosure_dict = detail;
        Disclosure_Details = [detail objectForKey:gDETAILS_FIELDS_ARRAY];
        //6347 & 6757: Aparna
        if (selectedSection == SHOW_LINES_ROW || selectedSection == SHOWALL_LINES)
        {
            self.line = YES;
            self.header = NO;
        }

    }
}

// Override to support conditional editing of the table view.

- (BOOL)tableView:(UITableView *)_tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Defect Fix :- 7394
    if (self.selectedIndexPathForchildView || self.selectedIndexPathForEdit)
        return NO;
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
			
			//Radha - Defect Fix 4833
			NSString * viewProcess = [appDelegate.SFMPage objectForKey:@"PROCESSTYPE"];
			
			if ([viewProcess caseInsensitiveCompare:@"VIEWRECORD"] == NSOrderedSame)
			{
				return NO;
			}
			
            BOOL allowDeleteLines = [[detail objectForKey:@"details_Allow_Delete_Lines"] boolValue];
            //TA_BOT :
            UITableViewCell *theCurrentCell = [_tableView cellForRowAtIndexPath:indexPath];
            NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
            [dict setValue:[NSNumber numberWithBool:allowDeleteLines] forKey:@"DeleteAppeared"];
            SBJsonWriter *writer = [[[SBJsonWriter alloc] init] autorelease];
            NSString *json = [writer stringWithObject:dict];
            [theCurrentCell setAccessibilityValue:json];
            if(allowDeleteLines)
            {
                if([indexPath isEqual:self.selectedIndexPathForEdit] ) {
                    return NO;  //KRI
                }
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
        SMLog(kLogLevelVerbose,@"%d", a);

        [tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self hideExpandedChildViews];
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
//    SMLog(kLogLevelVerbose,@"%d", rows);
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
    NSLog(@"%@",NSStringFromCGRect(cell.frame));
    if (isInEditDetail)
    {
    }
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
//    CGRect bgFrame =  cell.backgroundView.frame;
//    NSArray *subVies = [cell.backgroundView subviews];
//    for (int counter = 0; counter < [subVies count]; counter++) {
//        
//        UIView *someView = [[subVies objectAtIndex:counter] retain];
//        if ([someView isKindOfClass:[UIImageView class]]) {
//            
//        }
//    }
//    NSLog(@"%@",NSStringFromCGRect(cell.frame));

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
    SMLog(kLogLevelVerbose,@"%@", lookupData);
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
        // Dam - Win14 changes
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= SUPPORTED_IOS_VERSION) {
            contentView_textView.textAlignment = NSTextAlignmentCenter;
        }
        else {
            contentView_textView.textAlignment = UITextAlignmentCenter;
        }
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
-(void)tapRecognizedForEdit:(id)sender
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
            label_popOver_content.view.frame = CGRectMake(0, 0, label_popOver_content.view.frame.size.width, 70);
            contentView_textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, label_popOver_content.view.frame.size.width, 70)];
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
        // Dam - Win14 changes
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= SUPPORTED_IOS_VERSION) {
            contentView_textView.textAlignment = NSTextAlignmentCenter;
        }
        else {
            contentView_textView.textAlignment = UITextAlignmentCenter;
        }

        [label_popOver_content.view addSubview:contentView_textView];
        
        CGSize size_po = CGSizeMake(label_popOver_content.view.frame.size.width, label_popOver_content.view.frame.size.height);
        label_popOver = [[UIPopoverController alloc] initWithContentViewController:label_popOver_content];
        [label_popOver setPopoverContentSize:size_po animated:YES];
        
        label_popOver.delegate = self;
		
        [label_popOver presentPopoverFromRect:CGRectMake(label.frame.size.width/2,14, 10, 10) inView:label permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		
        [contentView_textView release];
        [label_popOver_content release];
        
    }
}


-(void)tapRecognized1:(UIGestureRecognizer *)sender
{
    
    
    SMLog(kLogLevelVerbose,@"Tapped");
}

#pragma mark -  Action Delegate Method
//  Unused methods
//-(void) stopActivityIndicator
//{
//    [activity stopAnimating];
//}

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
    SMLog(kLogLevelVerbose,@"Date 1 = %@",date1);
    
    NSDate *date2 = [dateFormatter dateFromString:fromDate];
    SMLog(kLogLevelVerbose,@"Date 2 = %@",date2);
    
    NSTimeInterval diff_time = [date2 timeIntervalSinceDate:date1];
    SMLog(kLogLevelVerbose,@"Difference = %f",diff_time);
    
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
                    //Aparna
                    if ([control_type length] == 0 || control_type == nil)
                    {
                        control_type = [[Disclosure_Details objectAtIndex:i] objectForKey:@"Field_Data_Type"];
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
                                SMLog(kLogLevelVerbose,@"%@",date);
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
                            //Aparna: Fix for the defect 4547
                            /*if ([control_type isEqualToString:@"url"])
                            {
                                BOOL isValidUrl = [self isValidUrl:fieldValue];
                                if ((isValidUrl == NO) && ([fieldValue length] > 0))
                                {
                                    [self showAlertForInvalidUrl];
//                                    [self enableSFMUI];
                                    [activity stopAnimating];
                                    return;
                                    
                                }

                            }*/

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
            SMLog(kLogLevelVerbose,@"Values Altered Successfully");
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

		if ([detail_values count] > 0)
		{
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
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

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
    
    //krishna opdoc added signName
    [appDelegate.calDataBase insertSignatureData:imageData WithId:WoNumber RecordId:appDelegate.sfmPageController.recordId apiName:HeaberObjectName WONumber:WoNumber flag:@"ViewWorkOrder" andSignName:@""];
    
    isShowingSignatureCapture = NO;
}
 
#pragma mark - ShowHelp Method
- (void) showHelp
{
	//Radha Fix for defect - 4690
	[self dismissActionMenu];
    HelpController * help = [[HelpController alloc] initWithNibName:@"HelpController" bundle:nil];
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    NSString *lang=[appDelegate.dataBase checkUserLanguage];
    NSString *html=@"";
    if (!isInViewMode)
        html = @"view-record";
    else
        html = @"create-edit-record";
    NSString *isfileExists = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_%@",html,lang] ofType:@"html"];
    
    if( (isfileExists ==NULL)|| [lang isEqualToString:@"en_US"] || !([lang length]>0))
    {
        help.helpString=[NSString stringWithFormat:@"%@.html",html];
    }
    else
    {
        help.helpString = [NSString stringWithFormat:@"%@_%@.html",html,lang];
    }
  
    [(SFMPageController *)delegate presentViewController:help animated:YES completion:nil];
    [help release];
    appDelegate.isDetailActive = NO;
}


- (void)loadOPDocViewControllerForProcessId:(NSString *)processId andRecordId:(NSString *)recordId
{
    //krishna : OPDOC oflline generation. Now we pass LocalId as the parameter
    OPDocViewController *sfmopdoc = [[OPDocViewController alloc] initWithNibName:@"OPDocViewController" bundle:[NSBundle mainBundle] forRecordId:recordId andProcessId:processId andLocalId:appDelegate.sfmPageController.recordId];
   
    NSMutableDictionary * header_ =  [appDelegate.SFMPage objectForKey:@"header"];
    NSString * headerObjName = [header_ objectForKey:gHEADER_OBJECT_NAME];
    
    NSString * objName = [appDelegate.databaseInterface getObjectName:headerObjName recordId:appDelegate.sfmPageController.recordId];
        
    sfmopdoc.opdocTitleString = objName;
    sfmopdoc.modalPresentationStyle = UIModalPresentationFullScreen;
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:sfmopdoc] autorelease];
	navController.delegate = sfmopdoc;
	navController.modalPresentationStyle = UIModalPresentationFullScreen;
	navController.navigationBar.hidden = NO;
    [(SFMPageController *)delegate presentViewController:navController animated:YES completion:nil];
    [sfmopdoc release];
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

//Shravya-8639
//This change is done to dismiss the pop over very fast
-(void)offlineActions:(NSDictionary *)buttonDict
{
    BOOL isActionMenuVisible = NO;
    if ([actionMenu.popover isPopoverVisible]) {
        NSLog(@"Action menu is visible");
        isActionMenuVisible = YES;
    }
    
    [self dismissActionMenu];
    
    [self disableSFMUI];
    
     NSString * action_type = [buttonDict objectForKey:SFW_ACTION_TYPE];
    NSString * targetCall = [buttonDict objectForKey:SFW_ACTION_DESCRIPTION];
    
    //8741
    if (isActionMenuVisible || ([action_type isEqualToString:@"SFW_Custom_Actions"]) || [targetCall isEqualToString:dod_title]) {
        if ([NSThread isMainThread]) {
            
            //8741 & 8761
            if([targetCall isEqualToString:save] || [action_type isEqualToString:@"SFW_Custom_Actions"] || [targetCall isEqualToString:dod_title] || [action_type isEqual:@"WEBSERVICE"] || [action_type isEqual:@"JAVASCRIPT"]) {
                
                [activity startAnimating];
            }
            [self performSelector:@selector(continuedOfflineActions:) withObject:buttonDict  afterDelay:0.01];
        }
        else {
            [self continuedOfflineActions:buttonDict];
        }
    }
    else{
        [self continuedOfflineActions:buttonDict];
    }
}
//Shravya-8639
- (void)continuedOfflineActions:(NSDictionary *)buttonDict
{

	//Radha - june/10/2013 - child Sfm
	[self hideChildLinkedViewProcess];
	
    
    NSString * warning = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_WARNING];
    NSString * invalidEmail = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_TEXT_INVALID_EMAIL]; 
    NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    
    [self disableSFMUI];
    
    NSString * targetCall = [buttonDict objectForKey:SFW_ACTION_DESCRIPTION];
    NSString * action_type = [buttonDict objectForKey:SFW_ACTION_TYPE];
    NSString * action_process_id = [buttonDict objectForKey:SFW_PROCESS_ID];
    //SFM Biz Rule
    BOOL executeBizRule = [appDelegate doesServerSupportsModule:kMinPkgForSFMBizRuleModule];
    BOOL bizRulesAvailable = NO;
    if(executeBizRule)
    {
       bizRulesAvailable = [self bizRuleResourcesAvailable];
    }
    if(([targetCall isEqualToString:save] || [targetCall isEqualToString:quick_save]) && bizRulesAvailable)
    {
        SMLog(kLogLevelVerbose,@"Save / Quick Save Called.");
        if([self executeBizRules])
            return;
    }
    
    
    if(([targetCall isEqualToString:save] || [targetCall isEqualToString:quick_save]))
    {
        /*Shravya-Calendar 7751*/
        [Utility setRefreshCalendarView];
    }
    
    //Krishna OpDoc
    
    
    NSString * objNameForRecord = [[appDelegate.SFMPage objectForKey:@"header"] objectForKey:gHEADER_OBJECT_NAME];
      NSString *action_rec_id = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:objNameForRecord local_id:appDelegate.sfmPageController.recordId];

    if([action_type isEqualToString:SFM] ||
       [action_type isEqualToString:@"WEBSERVICE"] ||
       [action_type isEqualToString:@"JAVASCRIPT"] ||
       ![action_type isEqualToString:@"SFW_Custom_Actions"])
    {
        if ([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"VIEWRECORD"]) 
        {
            if ([targetCall isEqualToString:summary])
            {
                [activity startAnimating];
                didRunOperation = YES;
                [self startSummaryDataFetch];
                appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
                 [activity stopAnimating]; //8741
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
					//Sync_Override
                    webserviceName = nil;
					className = nil;
					syncType = nil;
					
                    NSString * process_type = [appDelegate.databaseInterface getprocessTypeForProcessId:action_process_id];
                    
                    if([process_type isEqualToString:@"EDIT"] || [process_type isEqualToString:@"SOURCETOTARGETONLYCHILDROWS"])
                    {
						//Sync Override :Radha
						webserviceName = ([buttonDict objectForKey:@"method_name"] != nil)?[buttonDict objectForKey:@"method_name"]:@"";
						className = ([buttonDict objectForKey:@"class_name"] != nil)?[buttonDict objectForKey:@"class_name"]:@"";
												
						if ((![webserviceName isEqualToString:@""]) && (![className isEqualToString:@""]))
						{
							syncType = CUSTOMSYNC;
						}
						else
						{
							syncType = AGRESSIVESYNC;
						}
																						 
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
                            // 8303 - Vipindas Sep 4 2013
                            
                            // Load custom error message if exists
                            NSString * message = [appDelegate.dataBase expressionErrorMessageById:expression_id];
                            
                            if (! [Util isValidString:message] )
                            {
                                message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_swich_process];
                            }
                            
                            //NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_swich_process];
                            NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
                            NSString * cancel_ = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE];
                            
                            UIAlertView * enty_criteris = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel_ otherButtonTitles:nil, nil];
                            [enty_criteris show];
                            [enty_criteris release];
                        }
                        else
                        {
                            [self pushtViewProcessToStack:appDelegate.sfmPageController.processId record_id:appDelegate.sfmPageController.recordId];
                            
                            appDelegate.sfmPageController.sourceProcessId = appDelegate.sfmPageController.processId;
                            appDelegate.sfmPageController.sourceRecordId = appDelegate.sfmPageController.recordId;
                            
                            appDelegate.sfmPageController.processId = action_process_id;
                            appDelegate.sfmPageController.recordId  = appDelegate.sfmPageController.recordId ;
                            
                            self.currentRecordId  = appDelegate.sfmPageController.recordId;//shr-retain 8595
                            currentProcessId = action_process_id;
                            //check For view process - dont require
                            [self fillSFMdictForOfflineforProcess:action_process_id forRecord:currentRecordId];
                            [self didReceivePageLayoutOffline];
                        }
                    }
                    //Radha 15/5/11
                    if ([process_type isEqualToString:@"STANDALONECREATE"])
                    {
						//Sync Override :Radha
                        webserviceName = ([buttonDict objectForKey:@"method_name"] != nil)?[buttonDict objectForKey:@"method_name"]:@"";
						className = ([buttonDict objectForKey:@"class_name"] != nil)?[buttonDict objectForKey:@"class_name"]:@"";
						
						if ((![webserviceName isEqualToString:@""]) && (![className isEqualToString:@""]))
						{
							syncType = CUSTOMSYNC;
			 			}
						else
						{
							syncType = AGRESSIVESYNC;
						}
                        
                         [self pushtViewProcessToStack:appDelegate.sfmPageController.processId record_id:appDelegate.sfmPageController.recordId];
                        
                        appDelegate.sfmPageController.sourceProcessId = appDelegate.sfmPageController.processId;
                        appDelegate.sfmPageController.sourceRecordId = nil;
                        
                        appDelegate.sfmPageController.processId = action_process_id;
                        appDelegate.sfmPageController.recordId  = nil;
                        
                        self.currentRecordId  = nil;//8595
                        currentProcessId = action_process_id;
                        //check For view process - dont require
                        [self fillSFMdictForOfflineforProcess:action_process_id forRecord:currentRecordId];
                        [self didReceivePageLayoutOffline];
                    }
                        
                    if([process_type isEqualToString:@"SOURCETOTARGET"] )
                    {
                        //Sync Override :Radha
						webserviceName = ([buttonDict objectForKey:@"method_name"] != nil)?[buttonDict objectForKey:@"method_name"]:@"";
						className = ([buttonDict objectForKey:@"class_name"] != nil)?[buttonDict objectForKey:@"class_name"]:@"";
						
						if ((![webserviceName isEqualToString:@""]) && (![className isEqualToString:@""]))
						{
							syncType = CUSTOMSYNC;
						}
						else
						{
							syncType = AGRESSIVESYNC;
						}
						
                        //check out the record any child or parent  local_id
                        
                        NSMutableDictionary * page_layoutInfo = [appDelegate.databaseInterface  queryProcessInfo:action_process_id object_name:@""];
                        
                        NSMutableDictionary * _header =  [page_layoutInfo objectForKey:@"header"];
                        
                        NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];
                        
                        NSString * layout_id = [_header objectForKey:gHEADER_HEADER_LAYOUT_ID];
                        
                        NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGET process_id:action_process_id layoutId:layout_id objectName:headerObjName];
                        NSString * source_parent_object_name = [process_components objectForKey:SOURCE_OBJECT_NAME];
                        NSString * expression_id = [process_components objectForKey:EXPRESSION_ID];

                        BOOL Entry_criteria = [appDelegate.databaseInterface EntryCriteriaForRecordFortableName:source_parent_object_name record_id:appDelegate.sfmPageController.recordId expression:expression_id];
                        
                        
                        if(!Entry_criteria)
                        {
                            // 8303 - Vipindas Sep 4 2013
                            
                            // Load custom error message if exists
                            NSString * message = [appDelegate.dataBase expressionErrorMessageById:expression_id];
                            
                            if (! [Util isValidString:message] )
                            {
                                message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_swich_process];
                            }
                            
                            //NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_swich_process];
                            NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
                            NSString * cancel_ = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE];
                            
                            UIAlertView * enty_criteris = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel_ otherButtonTitles:nil, nil];
                            [enty_criteris show];
                            [enty_criteris release];
                            
                        }
                        else  // Damodar - Win14 - MemMgt - unused block!!
                        {
                             // Damodar - Win14 - MemMgt : Unused!! - revoked to fix crash
                            if ([source_parent_object_name length] == 0)
                                source_parent_object_name = headerObjName;
                            
                         /*   NSString * parent_sf_id =  [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:source_parent_object_name local_id:appDelegate.sfmPageController.recordId];
                            
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
                            {*/
                                
                                [self pushtViewProcessToStack:appDelegate.sfmPageController.processId record_id:appDelegate.sfmPageController.recordId];
                                
                                appDelegate.sfmPageController.sourceProcessId = appDelegate.sfmPageController.processId;
                                appDelegate.sfmPageController.sourceRecordId = appDelegate.sfmPageController.recordId;
                                
                                appDelegate.sfmPageController.processId = action_process_id;
                                appDelegate.sfmPageController.recordId  = nil;
                                
                                self.currentRecordId  = nil;////shr-retain 008595
                                currentProcessId = action_process_id;
                                //check For view process  - dont require
                                [self fillSFMdictForOfflineforProcess:action_process_id forRecord:currentRecordId];
                                [self didReceivePageLayoutOffline];
                           //}
                        }
                    }
                    //OUTPUT docs Entry criteria : 8166
                    if ( [process_type isEqualToString:@"OUTPUT DOCUMENT"] )
                    {
                        
                        BOOL Entry_criteria = NO;
                        NSArray *componentsArray = [appDelegate.databaseInterface getExpressionIdsForOPDocForProcessId:action_process_id];

                        // 8303 - Vipindas Sep 4 2013
                        NSString *expressionId = nil;
                        if([componentsArray count] > 0) {
                            
                            for (NSDictionary *dict in componentsArray) {
                                // 8303 - Vipindas Sep 4 2013
                                expressionId  = [dict objectForKey:EXPRESSION_ID];
                                NSString *targetObjectName = [dict objectForKey:TARGET_OBJECT_NAME];
                                
                                Entry_criteria = [appDelegate.databaseInterface EntryCriteriaForRecordFortableName:targetObjectName record_id:appDelegate.sfmPageController.recordId expression:expressionId];
                                if (!Entry_criteria) {
                                    break;
                                }
                                
                            }
                        
                        }
                        
                        if(!Entry_criteria)
                        {
                            // 8303 - Vipindas Sep 4 2013
                            
                            // Load custom error message if exists
                            NSString * message = [appDelegate.dataBase expressionErrorMessageById:expressionId];
                            
                            if (! [Util isValidString:message] )
                            {
                                message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_swich_process];
                            }
                            
                            //NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_swich_process];
                            NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
                            NSString * cancel_ = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE];
                            
                            UIAlertView * enty_criteris = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel_ otherButtonTitles:nil, nil];
                            [enty_criteris show];
                            [enty_criteris release];
                        }
                        else
                        {
                            [self loadOPDocViewControllerForProcessId:action_process_id andRecordId:action_rec_id];
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
            //No save in [attDBOperation saveAttachmentRecords];
 
        }
    
        if( [[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"STANDALONECREATE"])
        {
            if([targetCall isEqualToString:save])
            {
                save_status = EDIT_SAVE;
                
                [self pageLevelEventsForEvent:BEFORESAVE];
                [self pageLevelEventsForEvent:AFTERSAVE];
               
                NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
                
                NSArray * header_sections = [hdr_object objectForKey:@"hdr_Sections"];
                NSString * headerObjName = [hdr_object objectForKey:gHEADER_OBJECT_NAME];
                NSString * layout_id = [hdr_object objectForKey:gHEADER_HEADER_LAYOUT_ID];
                NSString * processId = appDelegate.sfmPageController.processId;
                NSMutableDictionary * SFM_header_fields = [[NSMutableDictionary alloc] initWithCapacity:0];
				
				NSMutableDictionary * customDataDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
                
				//Radha 21 june '13
				//Radha :- Implementation  for  Required Field alert in Debrief UI
				NSInteger headerRow = -1;
                
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
                            //krishna defect 6690
                            value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            if([value length] == 0)
                            {
								//Radha :- Implementation  for  Required Field alert in Debrief UI
								if (headerRow < 0 && !error)
								{
									headerRow = i;
								}
                                error = TRUE;
                                //sahana TEMP change
                                break;
                            }
                        }
                        if ([dataType isEqualToString:@"email"] )  //Shrinivas Fix for Email Validation 03/04/2012
                        {
                            /*
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
                            }*/
                            
                        }
                        // Fix for the defect 4547: Url validation
                        /*else if ([dataType isEqualToString:@"url"] )
                        {
                            BOOL isValidUrl = [self isValidUrl:value];
                            if ((isValidUrl == NO) && ([value length] > 0))
                            {
                                [self showAlertForInvalidUrl];
                                [self enableSFMUI];
                                return;

                            }
                        }*/

                    }
                }
                if(error == TRUE)
                {
					//Radha :- Implementation  for  Required Field alert in Debrief UI
					NSDictionary * details = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", headerRow], ROW,
											  [NSString stringWithFormat:@"%d", 0], CURRENTSECTION,  nil];
					
					mandatoryRowDetails = [[NSDictionary alloc] initWithDictionary:details];
                    [self requireFieldWarning];
                    requiredFieldCheck = TRUE;
                    [self enableSFMUI];
                    return;
                }
                
                //child records
                BOOL line_error = FALSE;
				
				//Radha :- Debrief :- 19 june '13
				//Radha :- Implementation  for  Required Field alert in Debrief UI
				NSInteger row = -1;
				NSInteger currentRow = -1;

               
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
                                        //krishna defect 6690
                                        deatil_value = [deatil_value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                        if([deatil_value length]== 0)
                                        {
											//Radha :- Implementation  for  Required Field alert in Debrief UI
											if ((row < 0 || currentRow < 0) && !line_error)
											{
												row = i;
												currentRow = j+1;
											}

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
                                // Fix for the defect 4547: Url validation
                                /*else if ([detailDataType isEqualToString:@"url"])
                                {
                                    BOOL isValidUrl = [self isValidUrl:deatil_value];
                                    if ((isValidUrl == NO) && ([deatil_value length] > 0))
                                    {
                                        [self showAlertForInvalidUrl];
                                        [self enableSFMUI];
                                        return;
                                        
                                    }
                                }*/

                            }
                        }
                    }        
                }
                
                if(line_error)
                {
					//Radha :- Debrief :- 19 june '13
					//Radha :- Implementation  for  Required Field alert in Debrief UI
					NSDictionary * details = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", row], ROW,
											[NSString stringWithFormat:@"%d", currentRow], CURRENTROW, [NSString stringWithFormat:@"%d", 1], CURRENTSECTION,  nil];
					
					mandatoryRowDetails = [[NSDictionary alloc] initWithDictionary:details];
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
                NSString * header_record_local_id = [AppDelegate GetUUID];
                [header_fields_dict setObject:header_record_local_id forKey:@"local_id"];
                
                if([headerObjName isEqualToString:@"Event"])
                {
                    appDelegate.databaseInterface.databaseInterfaceDelegate = self;
                    NSString * event_local_id = [appDelegate.databaseInterface getLocal_idFrom_Event_local_id:Event_local_Ids];
                    if([event_local_id length] != 0)
                    {
                        header_record_local_id = event_local_id;
                        [header_fields_dict setObject:header_record_local_id forKey:@"local_id"];
                    }
                    
                }
                
                //sahana currentRecord fix
                [appDelegate.databaseInterface replaceCurrentRecordOrheaderLiteral:header_fields_dict headerRecordId:@"" headerObjectName:@"" currentRecordId:header_record_local_id currentObjectName:headerObjName];
                
                BOOL data_inserted = [appDelegate.databaseInterface insertdataIntoTable:headerObjName data:header_fields_dict];
                
                //AttchmentPosition
                [appDelegate.attachmentDataBase saveAttachmentRecords:header_record_local_id];

                if([headerObjName isEqualToString:@"Event"])
                {
                    appDelegate.databaseInterface.databaseInterfaceDelegate = nil;;
                }
                if(data_inserted)
                {
                    //fill the detail tables
                    //***************************************************** DETAIL SECTION ***************************************************
                    
                    //blank
                    [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:header_record_local_id SF_id:@"" record_type:MASTER operation:INSERT object_name:headerObjName sync_flag:@"false" parentObjectName:@"" parent_loacl_id:@"" webserviceName:webserviceName className:className synctype:syncType headerLocalId:header_record_local_id  requestData:customDataDictionary finalEntry:NO];
                    
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
                            
                            
                            //8321
                            NSString *childCurrencyCode = [detail_fields_dict valueForKey:gCurrencyIsoCode];
                            if ((childCurrencyCode == nil) || ([childCurrencyCode length] == 0))
                            {
                                BOOL isFieldExists = [appDelegate.databaseInterface ColumnExists:gCurrencyIsoCode tableName:headerObjName];
                                if (isFieldExists)
                                {
                                    NSString *currencyISOCode = [appDelegate.databaseInterface getValueForField:gCurrencyIsoCode objectName:headerObjName recordId:header_record_local_id];
                                    if ([currencyISOCode length]>0)
                                    {
                                        [detail_fields_dict setObject:currencyISOCode forKey:gCurrencyIsoCode];
                                    }
                                }
                            }

                            
                            //get the GUID
                            NSString * detail_record_local_id = [AppDelegate GetUUID];
                            [detail_fields_dict setObject:detail_record_local_id forKey:@"local_id"];
                            
                            [appDelegate.databaseInterface replaceCurrentRecordOrheaderLiteral:detail_fields_dict headerRecordId:header_record_local_id headerObjectName:headerObjName currentRecordId:@"" currentObjectName:detail_object_name];
                            
                            //sahana currentRecord_fix
                            BOOL data_inserted = [appDelegate.databaseInterface insertdataIntoTable:detail_object_name data:detail_fields_dict];
                        
                            if(data_inserted )
                            {
                                SMLog(kLogLevelVerbose,@"insertion success");
                                //childSfmofflineAction
                                [self getRecordIdForChildSfmForSection:i row:j recordId:detail_record_local_id actiondict:buttonDict];
                                
                                
                                [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:detail_record_local_id SF_id:@"" record_type:DETAIL  operation:INSERT object_name:detail_object_name sync_flag:@"false"  parentObjectName:headerObjName parent_loacl_id:header_record_local_id webserviceName:webserviceName className:className synctype:syncType headerLocalId:header_record_local_id requestData:customDataDictionary finalEntry:NO];

                            }
                            else
                            {
                                SMLog(kLogLevelError,@"insertion failed");
                            }
                            
                        }
                    }
                  
                    if(![self isInvokedFromChildSfm:buttonDict])
                    {
                        //need to split the below method it does both saving the record to plist and invoking the sfmpage
                        [self SaveRecordIntoPlist:header_record_local_id objectName:headerObjName];
                    }
                    else
                    {
                        [self SaveCreatedRecordInfoIntoPlistForRecordId:header_record_local_id objectName:headerObjName];
                    }
                    //[appDelegate.wsInterface  CallIncrementalDataSync];
                    [appDelegate setAgrressiveSync_flag];
                    if ([syncType isEqualToString:CUSTOMSYNC])
					{
						[appDelegate.databaseInterface insertdataIntoTrailerTableForRecord:header_record_local_id SF_id:@"" record_type:@"" operation:headerObjName object_name:headerObjName sync_flag:@"false" parentObjectName:headerObjName parent_loacl_id:header_record_local_id webserviceName:webserviceName className:className synctype:syncType headerLocalId:header_record_local_id requestData:customDataDictionary finalEntry:YES];
					}
					
                    //RADHA Defect Fix 5542
		   			appDelegate.shouldScheduleTimer = YES;
                   // [appDelegate.attachmentDataBase saveAttachmentRecords];
                    [appDelegate callDataSync];
                                   
                }
                else
                {
                    //pop up the message saving failed 
                }

//                [SFM_header_fields release]; // Damodar - Win14 - MemMgt - revoked to fix crash
            }
            if([action_type isEqual:@"JAVASCRIPT"])
            {
                SMLog(kLogLevelVerbose,@"Java Script");
                if(([[appDelegate.wsInterface getValueFromUserDefaultsForKey:@"doesGetPriceRequired"] boolValue]) && ([appDelegate doesServerSupportsModule:kMinPkgForGetPriceModule]))
                {
                    // Get Price Code Should Go Here Shr
                    /* GET_PRICE_JS-shr*/
                    [self getPriceForCurrentContext];
                }
                else
                {
                     [activity stopAnimating];//8761
                   // Alert the user that it requires Meta Sync
                    NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:getPrice_Objects_not_found];
                    NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
                    NSString * Ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
                    
                    UIAlertView * getPriceAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:Ok otherButtonTitles:nil];
                    [getPriceAlertView show];
                    [getPriceAlertView release];
                    return;
                }                    
            }
            else if([action_type isEqual:@"WEBSERVICE"])
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
                    save_status = EDIT_QUICKSAVE;
                }
                else
                {
                    save_status = EDIT_SAVE;                    
                }
                
                [self pageLevelEventsForEvent:BEFORESAVE];
                [self pageLevelEventsForEvent:AFTERSAVE];
                
                NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
                
                NSArray * header_sections = [hdr_object objectForKey:@"hdr_Sections"];
                NSString * headerObjName = [hdr_object objectForKey:gHEADER_OBJECT_NAME];
                NSString * layout_id = [hdr_object objectForKey:gHEADER_HEADER_LAYOUT_ID];
                NSMutableDictionary * hdrData = [hdr_object objectForKey:gHEADER_DATA];
                NSString * processId = appDelegate.sfmPageController.processId;
                    
                NSMutableDictionary * customDataDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
				
				//Radha 21 june '13
				//Radha :- Implementation  for  Required Field alert in Debrief UI
				NSInteger headerRow = -1;
				
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
                            //krishna defect 6690
                            value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                            if([value length] == 0)
                            {
								//Radha :- Implementation  for  Required Field alert in Debrief UI
								if (headerRow < 0 && !error)
								{
									headerRow = i;
								}
                                error = TRUE;
                                break;
                            }
                        }
                        
                        if ([dataType isEqualToString:@"email"] )  //Shrinivas Fix for Email Validation 03/04/2012
                        {
                            /*
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
                             */
                            
                        }
                        //Aparna://Fix for the defect 4547
                        /*else if ([dataType isEqualToString:@"url"] )
                        {
                            BOOL isValidUrl = [self isValidUrl:value];
                            if ((isValidUrl == NO) && ([value length] > 0))
                            {
                                [self showAlertForInvalidUrl];
                                [self enableSFMUI];
                                return;
                                
                            }
                        }*/

                        
                    }        
                }
                if(error == TRUE)
                {
                    

		    //Defect Fix :- Radha 5716
		    [activity stopAnimating];
		    //Radha :- Implementation  for  Required Field alert in Debrief UI
		    NSDictionary * details = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", headerRow], ROW,
											  [NSString stringWithFormat:@"%d", 0], CURRENTSECTION,  nil];
					
		    mandatoryRowDetails = [[NSDictionary alloc] initWithDictionary:details];
		    [self requireFieldWarning];
                    requiredFieldCheck = TRUE;
                    [self enableSFMUI];
                    return;
                }
                
                //child records
                BOOL line_error = FALSE;
                
				//Radha :- Debrief :- 19 june '13
				//Radha :- Implementation  for  Required Field alert in Debrief UI
				NSInteger row = -1;
				NSInteger currentRow = -1;
				
				
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
                                        //krishna defect 6690
                                        deatil_value = [deatil_value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                                        if([deatil_value length]== 0)
                                        {										//Radha :- Implementation  for  Required Field alert in Debrief UI	
											if ((row < 0 || currentRow < 0) && !line_error)
											{
												row = i;
												currentRow = j+1;
											}
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
                                //Aparna: Fix for thr defect 4547 - Invalid Url
                                /*else if ([detailDataType isEqualToString:@"url"] )
                                {
                                    BOOL isValidUrl = [self isValidUrl:deatil_value];
                                    if ((isValidUrl == NO) && ([deatil_value length] > 0))
                                    {
                                        [self showAlertForInvalidUrl];
                                        [self enableSFMUI];
                                        return;
                                        
                                    }
                                }*/

                            }
                        }
                    }        
                }
                
                if(line_error)
                {
					//Radha :- Debrief :- 19 june '13
					//Radha :- Implementation  for  Required Field alert in Debrief UI
					NSDictionary * details = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", row], ROW,
											[NSString stringWithFormat:@"%d", currentRow], CURRENTROW, [NSString stringWithFormat:@"%d", 1], CURRENTSECTION,  nil];
					
					mandatoryRowDetails = [[NSDictionary alloc] initWithDictionary:details];
					
					//Defect Fix :- Radha 5716
					[activity stopAnimating];
					
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
                    appDelegate.databaseInterface.databaseInterfaceDelegate = self;
                    [all_header_fields setObject:@"" forKey:@"DurationInMinutes"];
                    [appDelegate.databaseInterface deleteRecordsFromEventLocalIdsFromTable:LOCAL_EVENT_UPDATE];
                    if(!EventUpdate_Continue)
                    {
                        [appDelegate.databaseInterface insertIntoEventsLocal_ids:appDelegate.sfmPageController.recordId fromEvent_temp_table:LOCAL_EVENT_UPDATE];
                    }
                    
                }
                [appDelegate.databaseInterface replaceCurrentRecordOrheaderLiteral:all_header_fields headerRecordId:@"" headerObjectName:@"" currentRecordId:currentRecordId currentObjectName:headerObjName];
                
                BOOL success_flag = [appDelegate.databaseInterface  UpdateTableforId:currentRecordId forObject:headerObjName data:all_header_fields];
              
                //AttchmentPosition
                [appDelegate.attachmentDataBase saveAttachmentRecords:currentRecordId];
                
                if([headerObjName isEqualToString:@"Event"])
                {
                    appDelegate.databaseInterface.databaseInterfaceDelegate = nil;
                    if(!success_flag)
                    {
                        [self enableSFMUI];
                        return;
                    }
                }
                
               
                
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
					if ([syncType isEqualToString:AGRESSIVESYNC])
					{
						BOOL does_exists = [appDelegate.databaseInterface DoesTrailerContainTheRecord:currentRecordId operation_type:UPDATE object_name:headerObjName];
						if(!does_exists)
						{
							[appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:currentRecordId SF_id:id_value record_type:MASTER operation:UPDATE object_name:headerObjName sync_flag:@"false" parentObjectName:@"" parent_loacl_id:@"" webserviceName:webserviceName className:className synctype:syncType
																				  headerLocalId:appDelegate.sfmPageController.recordId requestData:customDataDictionary finalEntry:NO];
						}
					}
					else
					{
                        //RAdha
						[appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:currentRecordId SF_id:id_value record_type:MASTER operation:UPDATE object_name:headerObjName sync_flag:@"false" parentObjectName:@"" parent_loacl_id:@"" webserviceName:webserviceName className:className synctype:syncType
																			  headerLocalId:appDelegate.sfmPageController.recordId requestData:customDataDictionary finalEntry:NO];
					}
					
                    
                }
                else
                {
                    if([syncType isEqualToString:CUSTOMSYNC])
					{
                        //RAdha
						[appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:currentRecordId SF_id:id_value record_type:MASTER operation:INSERT object_name:headerObjName sync_flag:@"false" parentObjectName:@"" parent_loacl_id:@"" webserviceName:webserviceName className:className synctype:syncType
																			  headerLocalId:appDelegate.sfmPageController.recordId requestData:customDataDictionary finalEntry:NO];
					}
                }
                //sahana need to remove below code
                success_flag = TRUE;
            
                if(success_flag)
                {
                    SMLog(kLogLevelVerbose,@"Success");
                    
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
                                
                                NSString * line_local_id = [AppDelegate GetUUID];
                                [detail_fields_dict  setObject:line_local_id forKey:@"local_id"];
                                
                                
                                //8321
                                NSString *childCurrencyCode = [detail_fields_dict valueForKey:gCurrencyIsoCode];
                                if ((childCurrencyCode == nil) || ([childCurrencyCode length] == 0))
                                {
                                    BOOL isFieldExists = [appDelegate.databaseInterface ColumnExists:gCurrencyIsoCode tableName:headerObjName];
                                    if (isFieldExists)
                                    {
                                        NSString *currencyISOCode = [appDelegate.databaseInterface getValueForField:gCurrencyIsoCode objectName:headerObjName recordId:appDelegate.sfmPageController.recordId];
                                        if ([currencyISOCode length]>0)
                                        {
                                            [detail_fields_dict setObject:currencyISOCode forKey:gCurrencyIsoCode];
                                        }
                                    }
                                }

                                
                                //sahana currentRecord_fix
                                [appDelegate.databaseInterface replaceCurrentRecordOrheaderLiteral:detail_fields_dict headerRecordId:currentRecordId headerObjectName:headerObjName currentRecordId:line_local_id currentObjectName:detail_object_name];
                                
                                BOOL data_inserted = [appDelegate.databaseInterface insertdataIntoTable:detail_object_name data:detail_fields_dict];
                                
                                if(data_inserted )
                                {
                                    //childSfmofflineAction
                                    
                                    [self getRecordIdForChildSfmForSection:i row:j recordId:line_local_id actiondict:buttonDict];
                                    
                                    SMLog(kLogLevelVerbose,@"insertion success");
                                    if(isSalesForceRecord)
                                    {
                                        //update  String SF_ID 
                                        
                                       // NSString * parent_SFId = [NSString stringWithFormat:@"SFID%@", id_value];
                                        [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:line_local_id SF_id:@"" record_type:DETAIL operation:INSERT object_name:detail_object_name sync_flag:@"false" parentObjectName:headerObjName parent_loacl_id:currentRecordId webserviceName:webserviceName className:className synctype:syncType headerLocalId:appDelegate.sfmPageController.recordId  requestData:customDataDictionary finalEntry:NO];
                                    }
                                    else
                                    {
                                        [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:line_local_id SF_id:@"" record_type:DETAIL operation:INSERT object_name:detail_object_name sync_flag:@"false"  parentObjectName:headerObjName parent_loacl_id:currentRecordId webserviceName:webserviceName className:className synctype:syncType headerLocalId:appDelegate.sfmPageController.recordId requestData:customDataDictionary finalEntry:NO];
                                    }
                                }
                                else
                                {
                                    SMLog(kLogLevelError,@"insertion failed");
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

                                //fill for each row
								//FILL OBJECTMAPPING VALUE
                            
                                for(NSString * detail_key in detail_object_mapping_keys )
                                {
                                    if([[sfm_detail_field_keyValue allKeys] containsObject:detail_key])
                                    {
                                        NSString * mappingValue = [detail_object_mapping_dict objectForKey:detail_key];
                                        NSString * Displayvalue = [sfm_detail_field_keyValue objectForKey:detail_key];
                                        if([Displayvalue length ] == 0 || Displayvalue == nil)
                                        {
                                            if([mappingValue length] != 0 && mappingValue != nil)
                                            {
                                                [sfm_detail_field_keyValue setObject:mappingValue forKey:detail_key];
                                            }
                                        }
                                    }
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
                                    
                                    
                                    //sahana currentRecord_fix
                                    [appDelegate.databaseInterface replaceCurrentRecordOrheaderLiteral:sfm_detail_field_keyValue headerRecordId:currentRecordId headerObjectName:headerObjName currentRecordId:@"" currentObjectName:detail_object_name];
                                    
                                    BOOL data_inserted = [appDelegate.databaseInterface insertdataIntoTable:detail_object_name data:sfm_detail_field_keyValue];
                                    
                                    if(data_inserted )
                                    {
                                        //childSfmofflineAction
                                        [self getRecordIdForChildSfmForSection:i row:j recordId:line_record_id actiondict:buttonDict];
                                        
                                        SMLog(kLogLevelVerbose,@"insertion success");
                                        if(isSalesForceRecord)
                                        {
                                            //update  String SF_ID 
                                            [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:line_record_id SF_id:@"" record_type:DETAIL operation:INSERT object_name:detail_object_name sync_flag:@"false" parentObjectName:headerObjName parent_loacl_id:currentRecordId webserviceName:webserviceName className:className synctype:syncType headerLocalId:appDelegate.sfmPageController.recordId  requestData:customDataDictionary finalEntry:NO];
                                        }
                                        else
                                        {
                                            [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:line_record_id SF_id:@"" record_type:DETAIL operation:INSERT object_name:detail_object_name sync_flag:@"false" parentObjectName:headerObjName parent_loacl_id:currentRecordId webserviceName:webserviceName className:className synctype:syncType headerLocalId:appDelegate.sfmPageController.recordId requestData:customDataDictionary finalEntry:NO];
                                        }
                                    }
                                    else
                                    {
                                        SMLog(kLogLevelError,@"insertion failed");
                                    }
                                    //Save on Get Price Implementation Ends 
                                }
                                else
                                {
                                    //sahana currentrecord_fix
                                    [appDelegate.databaseInterface replaceCurrentRecordOrheaderLiteral:sfm_detail_field_keyValue headerRecordId:currentRecordId headerObjectName:headerObjName currentRecordId:line_record_id currentObjectName:detail_object_name];
                                
                                    BOOL detail_success_flag = [appDelegate.databaseInterface  UpdateTableforId:line_record_id forObject:detail_object_name data:sfm_detail_field_keyValue];
                                    if(detail_success_flag)
                                    {
                                        
                                        //childSfmofflineAction
                                        [self getRecordIdForChildSfmForSection:i row:j recordId:line_record_id actiondict:buttonDict];
                                        
                                        SMLog(kLogLevelVerbose,@"detail Update succeded");
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
										
										if ([syncType isEqualToString:AGRESSIVESYNC])
										{
											BOOL does_exists = [appDelegate.databaseInterface  DoesTrailerContainTheRecord:line_record_id operation_type:UPDATE object_name:detail_object_name];
											if(!does_exists)
											{
												
												if(child_isSalesForceRecord)
												{
													if(isSalesForceRecord)
													{
                                                        BOOL Does_exist_sf_id = [appDelegate.databaseInterface DoesTrailerContainTheRecordForSf_id:childSfId operation_type:UPDATE object_name:detail_object_name];
                                                        if(!Does_exist_sf_id )
                                                        {
                                                            [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:line_record_id SF_id:childSfId record_type:DETAIL operation:UPDATE object_name:detail_object_name sync_flag:@"false" parentObjectName:headerObjName parent_loacl_id:currentRecordId webserviceName:webserviceName className:className synctype:syncType headerLocalId:appDelegate.sfmPageController.recordId  requestData:customDataDictionary finalEntry:NO];//idvalue
                                                        }
													}
												}
												else
												{
                                                    BOOL does_exists = [appDelegate.databaseInterface  DoesTrailerContainTheRecord:line_record_id operation_type:INSERT object_name:detail_object_name];

                                                    if(!does_exists)
                                                    {
                                                        [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:line_record_id SF_id:@"" record_type:DETAIL operation:INSERT object_name:detail_object_name sync_flag:@"false" parentObjectName:headerObjName parent_loacl_id:currentRecordId webserviceName:webserviceName className:className synctype:syncType headerLocalId:appDelegate.sfmPageController.recordId requestData:customDataDictionary finalEntry:NO];

                                                    }
                                                    else
                                                    {
                                                        [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:line_record_id SF_id:@"" record_type:DETAIL operation:UPDATE object_name:detail_object_name sync_flag:@"false" parentObjectName:headerObjName parent_loacl_id:currentRecordId webserviceName:webserviceName className:className synctype:syncType headerLocalId:appDelegate.sfmPageController.recordId requestData:customDataDictionary finalEntry:NO];
                                                    }
												}
											}
										}
										else
										{
                                            //Radha
											if(child_isSalesForceRecord)
											{
												if(isSalesForceRecord)
												{
													[appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:line_record_id SF_id:childSfId record_type:DETAIL operation:UPDATE object_name:detail_object_name sync_flag:@"false" parentObjectName:headerObjName parent_loacl_id:currentRecordId webserviceName:webserviceName className:className synctype:syncType headerLocalId:appDelegate.sfmPageController.recordId  requestData:customDataDictionary finalEntry:NO];//idvalue
												}
											}
											else
											{
												[appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:line_record_id SF_id:@"" record_type:DETAIL operation:INSERT object_name:detail_object_name sync_flag:@"false" parentObjectName:headerObjName parent_loacl_id:currentRecordId webserviceName:webserviceName className:className synctype:syncType headerLocalId:appDelegate.sfmPageController.recordId requestData:customDataDictionary finalEntry:NO];
												
											}
										}
										
                                       
								}
								else
								{
									SMLog(kLogLevelError,@"detail Update failed");
								}
							}
						}
					}
                        
                     
                        [self UpdateAlldeletedRecordsIntoSFTrailerTable:detail_deleted_records  object_name:detail_object_name webserviceName:webserviceName className:className synctype:syncType headerLocalId:appDelegate.sfmPageController.recordId requestData:customDataDictionary];;
                    }
					
					
                    [appDelegate.databaseInterface deleteRecordsFromEventLocalIdsFromTable:Event_local_Ids];
                    [appDelegate.databaseInterface deleteRecordsFromEventLocalIdsFromTable:LOCAL_EVENT_UPDATE];
                    [appDelegate setAgrressiveSync_flag];
                    if ([syncType isEqualToString:CUSTOMSYNC])
					{
						[appDelegate.databaseInterface insertdataIntoTrailerTableForRecord:currentRecordId SF_id:id_value record_type:@"" operation:headerObjName object_name:headerObjName sync_flag:@"false" parentObjectName:headerObjName parent_loacl_id:currentRecordId webserviceName:webserviceName className:className synctype:syncType headerLocalId:appDelegate.sfmPageController.recordId requestData:customDataDictionary finalEntry:YES];
					}
					//RADHA Defect Fix 5542
					appDelegate.shouldScheduleTimer = YES;

                  //  [appDelegate.attachmentDataBase saveAttachmentRecords];

					SMLog(kLogLevelVerbose,@"Data sync is called");

                    [appDelegate callDataSync];
                }
                else
                {
                      SMLog(kLogLevelError,@"data sync failed");
                }
                
            }
            if([targetCall isEqualToString:save] && ![self isInvokedFromChildSfm:buttonDict])
            {
                NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
                NSString * headerObjName = [hdr_object objectForKey:gHEADER_OBJECT_NAME];
                if([appDelegate.sfmPageController.sourceProcessId length] == 0 && [appDelegate.sfmPageController.sourceRecordId length] == 0)
                {
                    if([headerObjName isEqualToString:@"Event"])
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_EVENT_DATA_SYNC object:nil];
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
            
            if([action_type isEqual:@"JAVASCRIPT"])
            {
                SMLog(kLogLevelVerbose,@"Java Script");
                if(([[appDelegate.wsInterface getValueFromUserDefaultsForKey:@"doesGetPriceRequired"] boolValue]) && ([appDelegate doesServerSupportsModule:kMinPkgForGetPriceModule]))
                {
                    // Get Price Code Should Go HereShr
                    /* GET_PRICE_JS-shr*/
                    [self getPriceForCurrentContext];
                }
                else
                {
                    [activity stopAnimating];//8761
                    // Alert the user that it requires Meta Sync
                    NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:getPrice_Objects_not_found];
                    NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
                    NSString * Ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
                    
                    UIAlertView * getPriceAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:Ok otherButtonTitles:nil];
                    [getPriceAlertView show];
                    [getPriceAlertView release];
                    return;
                }

            }
            else if([action_type isEqual:@"WEBSERVICE"])
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
                save_status = EDIT_SAVE;
                
                [self pageLevelEventsForEvent:BEFORESAVE];
                [self pageLevelEventsForEvent:AFTERSAVE];
                
                NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
                
                NSArray * header_sections = [hdr_object objectForKey:@"hdr_Sections"];
                NSString * headerObjName = [hdr_object objectForKey:gHEADER_OBJECT_NAME];
                NSString * layout_id = [hdr_object objectForKey:gHEADER_HEADER_LAYOUT_ID];
                NSString * processId = appDelegate.sfmPageController.processId;
                NSMutableDictionary * SFM_header_fields = [[NSMutableDictionary alloc] initWithCapacity:0];
				
				NSMutableDictionary * customDataDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
                
				//Radha 21 june '13
				//Radha :- Implementation  for  Required Field alert in Debrief UI
				NSInteger headerRow = -1;
				
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
                            //krishna defect 6690
                            value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                            if([value length] == 0)
                            {
								//Radha :- Implementation  for  Required Field alert in Debrief UI
								if (headerRow < 0 && !error)
								{
									headerRow = i;
								}
                                error = TRUE;
                                //sahana TEMP change
                                break;
                            }
                        }
                        
                        if ([dataType isEqualToString:@"email"] )  //Shrinivas Fix for Email Validation 03/04/2012
                        {
                            /*
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
                            */
                        }
                        //Aparna: Fix for the defect 4547- Invalid Url
                        /*else if ([dataType isEqualToString:@"url"] )
                        {
                            BOOL isValidUrl = [self isValidUrl:value];
                            if ((isValidUrl == NO) && ([value length] > 0))
                            {
                                [self showAlertForInvalidUrl];
                                [self enableSFMUI];
                                return;
                                
                            }
                        }*/

                        
                    }        
                }
                if(error == TRUE)
                {
					//Radha :- Implementation  for  Required Field alert in Debrief UI
					NSDictionary * details = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", headerRow], ROW,
											  [NSString stringWithFormat:@"%d", 0], CURRENTSECTION,  nil];
					
					mandatoryRowDetails = [[NSDictionary alloc] initWithDictionary:details];

                    [self requireFieldWarning];
                    requiredFieldCheck = TRUE;
                    [self enableSFMUI];
                    return;
                }
                
                //child records
                BOOL line_error = FALSE;
                
				//Radha :- Debrief :- 19 june '13
				//Radha :- Implementation  for  Required Field alert in Debrief UI
				NSInteger row = -1;
				NSInteger currentRow = -1;
				
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
                                        //krishna defect 6690
                                        deatil_value = [deatil_value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                                        if([deatil_value length]== 0)
                                        {
											//Radha :- Implementation  for  Required Field alert in Debrief UI
											if ((row < 0 || currentRow < 0) && !line_error)
											{
												row = i;
												currentRow = j+1;
											}

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
                                //Aparna: Fix for the defect 4547: Invalid Url
                                /*else if ([detailValue isEqualToString:@"url"] )
                                {
                                    BOOL isValidUrl = [self isValidUrl:deatil_value];
                                    if ((isValidUrl == NO) && ([deatil_value length] > 0))
                                    {
                                        [self showAlertForInvalidUrl];
                                        [self enableSFMUI];
                                        return;
                                        
                                    }
                                }*/


                            }
                        }
                    }        
                }
                
                if(line_error)
                {
					//Radha :- Debrief :- 19 june '13
					//Radha :- Implementation  for  Required Field alert in Debrief UI
					NSDictionary * details = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", row], ROW,
											[NSString stringWithFormat:@"%d", currentRow], CURRENTROW, [NSString stringWithFormat:@"%d", 1], CURRENTSECTION,  nil];
					
					mandatoryRowDetails = [[NSDictionary alloc] initWithDictionary:details];
                    [self requireFieldWarning];
                    requiredFieldCheck = TRUE;
                    [self enableSFMUI];
                    return;
                }

                
                NSMutableDictionary * header_fields_dict  = [appDelegate.databaseInterface getAllObjectFields:headerObjName tableName:SFOBJECTFIELD]; //method to get the all the fields from the objectField table
                
                NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGET process_id:processId layoutId:layout_id objectName:headerObjName];
                
                //[appDelegate.databaseInterface  getValueMappingForlayoutId:layout_id process_id:processId objectName:headerObjName];
                
                NSMutableArray * object_mapping_dict= [[appDelegate.databaseInterface getObjectMappingForMappingId:process_components source_record_id:appDelegate.sfmPageController.sourceRecordId field_name:@"local_id"] retain]; // Damodar - Win14 - MemMgt - revoked to fix crash
                
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
                header_record_local_id = [AppDelegate GetUUID];
                [header_fields_dict  setObject:header_record_local_id forKey:@"local_id"];
                
                if([headerObjName isEqualToString:@"Event"])
                {
                    appDelegate.databaseInterface.databaseInterfaceDelegate = self;
                    NSString * event_local_id = [appDelegate.databaseInterface getLocal_idFrom_Event_local_id:Event_local_Ids];
                    if([event_local_id length] != 0)
                    {
                        header_record_local_id = event_local_id;
                        [header_fields_dict setObject:header_record_local_id forKey:@"local_id"];
                    }
                    
                }
                
                //sahana currentRecord_fix
                [appDelegate.databaseInterface replaceCurrentRecordOrheaderLiteral:header_fields_dict headerRecordId:@"" headerObjectName:@"" currentRecordId:@"" currentObjectName:headerObjName];
                
                BOOL data_inserted = [appDelegate.databaseInterface insertdataIntoTable:headerObjName data:header_fields_dict];
                //AttchmentPosition
                [appDelegate.attachmentDataBase saveAttachmentRecords:header_record_local_id];
                
                if(data_inserted)
                {
                   // NSString * header_record_local_id = [appDelegate.databaseInterface getTheRecordIdOfnewlyInsertedRecord:headerObjName]; 
                    //blank string
                    [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:header_record_local_id SF_id:@"" record_type:MASTER operation:INSERT object_name:headerObjName sync_flag:@"false" parentObjectName:@"" parent_loacl_id:@"" webserviceName:webserviceName className:className synctype:syncType headerLocalId:header_record_local_id  requestData:customDataDictionary finalEntry:NO];
                    
                    for (int i=0;i<[details count];i++) //parts, labor, expense for instance
                    {
                        NSDictionary *detail = [details objectAtIndex:i];
                        
                        NSArray *details_values = [detail objectForKey:gDETAILS_VALUES_ARRAY];
                        NSString * detail_object_name = [detail objectForKey:gDETAIL_OBJECT_NAME];
                        NSString * header_reference_field_name = [detail objectForKey:gDETAIL_HEADER_REFERENCE_FIELD];
                        
                        
                        //call database method to 
                        NSMutableDictionary * detail_fields_dict  = [appDelegate.databaseInterface getAllObjectFields:detail_object_name tableName:SFOBJECTFIELD]; //method to get the all the fields from the objectField table
                        
                        NSString * layout_id = [detail objectForKey:gDETAILS_LAYOUT_ID];
                        
                        NSMutableDictionary * processComponents = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGETCHILD process_id:appDelegate.sfmPageController.processId layoutId:layout_id objectName:detail_object_name];
                        
                        NSMutableDictionary * valueMappingDict = [appDelegate.databaseInterface getObjectMappingForMappingId:processComponents mappingType:VALUE_MAPPING];
                        NSArray * ValuemappingKeys = [valueMappingDict allKeys];

                        
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
                            for(int p = 0 ; p  < [detail_field_keys count]; p++)
                            {
                                NSString * detail_field_api_name = [detail_field_keys objectAtIndex:p];
                                if([ValuemappingKeys containsObject:detail_field_api_name])
                                {
                                    NSString * fieldValue = [detail_fields_dict objectForKey:detail_field_api_name];
                                    if([fieldValue length] == 0)
                                    {
                                        NSString * mappingValue = [valueMappingDict objectForKey:detail_field_api_name];
                                        [detail_fields_dict setObject:mappingValue forKey:detail_field_api_name];
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
                            
                            NSString * detail_local_id = [AppDelegate  GetUUID]; 
                            [detail_fields_dict  setObject:detail_local_id forKey:@"local_id"];
                            
                            //sahana currentRecord_fix
                            [appDelegate.databaseInterface replaceCurrentRecordOrheaderLiteral:detail_fields_dict headerRecordId:header_record_local_id headerObjectName:headerObjName currentRecordId:@"" currentObjectName:detail_object_name];
                            
                            //here add
                            //8321
                            NSString *childCurrencyCode = [detail_fields_dict valueForKey:gCurrencyIsoCode];
                            if ((childCurrencyCode == nil) || ([childCurrencyCode length] == 0))
                            {
                                BOOL isFieldExists = [appDelegate.databaseInterface ColumnExists:gCurrencyIsoCode tableName:headerObjName];
                                if (isFieldExists)
                                {
                                    NSString *currencyISOCode = [appDelegate.databaseInterface getValueForField:gCurrencyIsoCode objectName:headerObjName recordId:header_record_local_id];
                                    
                                    if ([currencyISOCode length]>0)
                                    {
                                        [detail_fields_dict setObject:currencyISOCode forKey:gCurrencyIsoCode];
                                    }
                                }
                            }

                            
                            BOOL data_inserted = [appDelegate.databaseInterface insertdataIntoTable:detail_object_name data:detail_fields_dict];
                            
                            if(data_inserted )
                            {
                                 //childSfmofflineAction
                                
                                [self getRecordIdForChildSfmForSection:i row:j recordId:detail_local_id actiondict:buttonDict];
                                
                                 [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:detail_local_id SF_id:@"" record_type:DETAIL operation:INSERT object_name:detail_object_name sync_flag:@"false" parentObjectName:headerObjName parent_loacl_id:header_record_local_id webserviceName:webserviceName className:className synctype:syncType headerLocalId:header_record_local_id requestData:customDataDictionary finalEntry:NO];
                                SMLog(kLogLevelVerbose,@"insertion success");
                            }
                            else
                            {
                                SMLog(kLogLevelError,@"insertion failed");
                            }
                            
                        }
                    }
                    
					if(![self isInvokedFromChildSfm:buttonDict])
                    {
                        [self SaveRecordIntoPlist:header_record_local_id objectName:headerObjName];
                    }
                    else
                    {
                        [self SaveCreatedRecordInfoIntoPlistForRecordId:header_record_local_id objectName:headerObjName];
                    }
                    [appDelegate setAgrressiveSync_flag];
                    if ([syncType isEqualToString:CUSTOMSYNC])
					{
						[appDelegate.databaseInterface insertdataIntoTrailerTableForRecord:header_record_local_id SF_id:@"" record_type:@"" operation:headerObjName object_name:headerObjName sync_flag:@"false" parentObjectName:headerObjName parent_loacl_id:header_record_local_id webserviceName:webserviceName className:className synctype:syncType headerLocalId:header_record_local_id requestData:customDataDictionary finalEntry:YES];
					}
					//RADHA Defect Fix 5542
					appDelegate.shouldScheduleTimer = YES;
                    //[appDelegate.attachmentDataBase saveAttachmentRecords];
					[appDelegate callDataSync];
                }
                
//                [customDataDictionary release]; // Damodar - Win14 - MemMgt - revoked to fix crash
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
            if([action_type isEqual:@"JAVASCRIPT"])
            {
                SMLog(kLogLevelVerbose,@"Java Script");
                if(([[appDelegate.wsInterface getValueFromUserDefaultsForKey:@"doesGetPriceRequired"] boolValue]) && ([appDelegate doesServerSupportsModule:kMinPkgForGetPriceModule]))
                {
                    // Get Price Code Should Go Here Shr
                    /* GET_PRICE_JS-shr*/
                    [self getPriceForCurrentContext];
                }
                else
                {
                     [activity stopAnimating];//8761
                    // Alert the user that it requires Meta Sync
                    NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:getPrice_Objects_not_found];
                    NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
                    NSString * Ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
                    
                    UIAlertView * getPriceAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:Ok otherButtonTitles:nil];
                    [getPriceAlertView show];
                    [getPriceAlertView release];
                    return;
                }

            }
            else if([action_type isEqual:@"WEBSERVICE"])
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
        SMLog(kLogLevelVerbose,@"Call Custom Action ");
        if (![appDelegate isInternetConnectionAvailable])
        {
            [activity stopAnimating];
            appDelegate.shouldShowConnectivityStatus = TRUE;
            [appDelegate displayNoInternetAvailable];
            return;
        } 
        
        //Radha #6950
        NSString * _className = [buttonDict objectForKey:@"class_name"];
        NSString *methodName = [buttonDict objectForKey:@"method_name"];
        
        _className = (_className != nil) ? _className : @"";
        methodName = (methodName != nil) ? methodName : @"";
        NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
        
        [dict setObject:_className forKey:@"class_name"];
        [dict setObject:methodName forKey:@"method_name"];

        NSDictionary *dataDict = [appDelegate.SFMPage copy];
        [appDelegate goOnlineIfRequired];
        [appDelegate.wsInterface callCustomSFMAction:dataDict withData:dict];
        [dataDict release];
        //Code change for get pirce  ---> 11/06/2012   --- Time: 1:23 PM.
        
        appDelegate.wsInterface.webservice_call = FALSE;
        
        [activity startAnimating];
        appDelegate.wsInterface.getPrice = FALSE;
        SMXMonitor *monitor = [[[SMXMonitor alloc] init] autorelease];
        [monitor monitorSMMessageWithName:@"[DetailViewController.m continuedOfflineActions]"
                             withUserName:appDelegate.currentUserName
                                 logLevel:kPerformanceLevelWarning
                               logContext:@"Start"
                             timeInterval:kWSExecutionDuration];

        SMLog(kLogLevelVerbose,@" getPrice2");
        while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, FALSE))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(kLogLevelVerbose,@"DetailViewController.m : offlineActions: customAction");
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
        [monitor monitorSMMessageWithName:@"[DetailViewController.m continuedOfflineActions]"
                             withUserName:appDelegate.currentUserName
                                 logLevel:kPerformanceLevelWarning
                               logContext:@"Stop"
                             timeInterval:kWSExecutionDuration];

        BOOL performSync = [[buttonDict objectForKey:@"perform_sync"] boolValue];
        if(performSync && !(appDelegate.connection_error))
        {
            if([appDelegate dataSyncRunning])
            {
                SMLog(kLogLevelVerbose,@"Wait For Data Sync to Finish");
                while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, FALSE))
                {
#ifdef kPrintLogsDuringWebServiceCall
                    SMLog(kLogLevelVerbose,@"DetailViewController.m : offlineActions: datasync thread status check");
#endif

                    if (appDelegate.dataSyncRunning == NO)
                    {
                        break;
                    }
                }
            }
            appDelegate.dataSyncRunning = YES;
            [activity startAnimating];
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMER_INVALIDATE object:appDelegate.datasync_timer];
			//RADHA Defect Fix 5542
			appDelegate.shouldScheduleTimer = YES;
            [appDelegate callDataSync];
            while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, FALSE))
            {
#ifdef kPrintLogsDuringWebServiceCall
                SMLog(kLogLevelVerbose,@"DetailViewController.m : offlineActions: datasync thread status check 2");
#endif

                if (![appDelegate isInternetConnectionAvailable])
                {
                    [activity stopAnimating];
                    SMLog(kLogLevelVerbose,@"Data Sync stopper due to Internet Connection Failure");
                    return;
                }
                
                if (appDelegate.dataSyncRunning == NO)
                {
                    SMLog(kLogLevelVerbose,@"Data Sync Completed ");
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
		
		//Radha Defect Fix 5542
		[appDelegate updateNextDataSyncTimeToBeDisplayed:[NSDate date]];

    
    }
    
    [self enableSFMUI];
    
}
- (BOOL) executeBizRules
{
    //Show Activity Indicator
    BOOL bizRuleStatus = FALSE;
    activity.hidden = NO;
    [activity startAnimating];
    [self.view bringSubviewToFront:activity];
    if(![self isBizRuleTablesAndFieldsAvailable])
    {
        SMLog(kLogLevelVerbose,@"Biz Rule related Tables/Fields are missing. Not executing Biz Rule.Please do Meta Sync.");
        return bizRuleStatus;
    }
    SBJsonWriter * jsonWriter_ = [[SBJsonWriter alloc] init];
    
    NSString *parentObjectName = [[appDelegate.SFMPage objectForKey:MHEADER] objectForKey:MHEADER_OBJECT_NAME];
    NSMutableDictionary *SFMPageHeaderDetail = [[NSMutableDictionary alloc] init]; // Damodar - Win14 - MemMgt - revoked to fix crash
    [SFMPageHeaderDetail setObject:parentObjectName forKey:MHEADER];
    NSArray *childObjectsArray = [appDelegate.SFMPage objectForKey:gDETAILS];
    NSMutableArray *childObjectNamesArray = [[NSMutableArray alloc] init];
    for(NSDictionary *childDict in childObjectsArray)
    {
        NSString *childObjectName = [childDict objectForKey:gDETAIL_OBJECT_NAME];
        if(childObjectName == nil)
            continue;
        if(![childObjectNamesArray containsObject:childObjectName])
        {
            [childObjectNamesArray addObject:childObjectName];
        }
    }
    [SFMPageHeaderDetail setObject:childObjectNamesArray forKey:gDETAILS];
    
    NSDictionary *rulesAndFields = [self getBizRulesAndFieldsForParentObject:parentObjectName
                                                                childObjects:childObjectsArray];
    NSDictionary *fullRulesDict = [rulesAndFields objectForKey:@"Rules"];
    NSDictionary *fieldsDict = [rulesAndFields objectForKey:@"Fields"];
    
    int ruleFieldsCount = [[fieldsDict objectForKey:parentObjectName] count];
    if(!ruleFieldsCount)
    {
        for(NSString *detailObjName in childObjectNamesArray)
        {
            ruleFieldsCount += [[fieldsDict objectForKey:detailObjName] count];
            if(ruleFieldsCount)
                break;
        }
    }
    if(ruleFieldsCount)
    {
        NSDictionary *fields = [self getFieldsInfoForRuleFields:fieldsDict
                                                    detailNames:childObjectNamesArray
                                               parentObjectName:parentObjectName];
        
        NSDictionary *dataToValidate = [self getDataForRulesWithFieldsInfo:fields
                                                               detailNames:childObjectNamesArray
                                                          withParentObject:parentObjectName];
        
        [childObjectNamesArray release];
        childObjectNamesArray = nil;
        NSString * rulesString = [jsonWriter_  stringWithObject:fullRulesDict];
        NSString * fieldsString = [jsonWriter_  stringWithObject:fields];
        NSString * dataToValidateString = [jsonWriter_  stringWithObject:dataToValidate];
        [jsonWriter_ release];
        jsonWriter_ = nil;
        
        SMLog(kLogLevelVerbose,@"Rules = %@",rulesString);
        SMLog(kLogLevelVerbose,@"Fields = %@",fieldsString);
        SMLog(kLogLevelVerbose,@"Data To Validate = %@",dataToValidateString);
        
        NSString *htmlString = [self getBizRuleHTMLStringWithFields:fieldsString
                                                          withRules:rulesString
                                                           withData:dataToValidateString];
        
        NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"mobile-bizrules-app" ofType:@"html"];
        NSString *htmlContent = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil];
        NSString *finalString = [htmlString stringByAppendingString:htmlContent];
        JSExecuter *jsExecuterObj = [[JSExecuter alloc] initWithParentView:self.view
                                                            andCodeSnippet:finalString
                                                               andDelegate:self
                                                                  andFrame:CGRectZero];
        
        self.bizRuleJSExecuter = jsExecuterObj;
        [jsExecuterObj release];
        jsExecuterObj = nil;
        
        bizRuleExecutionStatus = FALSE;
        while (CFRunLoopRunInMode( kCFRunLoopDefaultMode, kRunLoopTimeInterval, FALSE))
        {
            if (bizRuleExecutionStatus)
            {
                break;
            }
        }
        activity.hidden = YES;
        [activity stopAnimating];
        SMLog(kLogLevelVerbose,@"bizRuleResult Warnings = %@",[bizRuleResult objectForKey:@"warnings"]);
        SMLog(kLogLevelVerbose,@"bizRuleResult Errors = %@",[bizRuleResult objectForKey:@"errors"]);
        NSArray *errorsArray = [bizRuleResult objectForKey:@"errors"];
        
        if([errorsArray count])
        {
            if([[SFMPageHeaderDetail allKeys] count]>0 && SFMPageHeaderDetail != nil && SFMPageHeaderDetail != NULL)
            {
                NSMutableDictionary *dictResponse=[[NSMutableDictionary alloc]init];
                [dictResponse setObject:SFMPageHeaderDetail forKey:@"SFMPPAGE_DETAILS"];
                [dictResponse setObject:errorsArray forKey:@"RULE_ERROR"];
                [appDelegate.sfmPageController.rootView setErrorDictonary:dictResponse];
                [SFMPageHeaderDetail release]; // Damodar - Win14 - MemMgt - revoked to fix crash
                [dictResponse release];
            }
            appDelegate.sfmPageController.rootView.isErrorDisplayed = NO;
            [appDelegate.sfmPageController.rootView displayErrors];
        }
        else
        {
            [appDelegate.sfmPageController.rootView hideErrors];
        }
        
        NSArray *warningsArray = [bizRuleResult objectForKey:@"warnings"];
        if([self handleBizRuleWarnings:warningsArray errors:errorsArray])
        {
            bizRuleStatus = TRUE;
        }
    }
    else
    {
        SMLog(kLogLevelVerbose,@"No Business Rule Found for Header and Detail");
        [childObjectNamesArray release];
        childObjectNamesArray = nil;
        [jsonWriter_ release];
        jsonWriter_ = nil;
    }
    return bizRuleStatus;
}
- (BOOL) isBizRuleTablesAndFieldsAvailable
{
    BOOL isBusinessRuleTableExists = [appDelegate.databaseInterface checkForTheTableInTheDataBase: SFBUSINESSRULE];
    BOOL isProcessBusinessRuleTableExists = [appDelegate.databaseInterface checkForTheTableInTheDataBase: SFPROCESSBUSINESSRULE];
    BOOL isTargetObjLabelFieldPresent =[appDelegate.dataBase isColumnPresentInTable:SFPROCESSCOMPONENT columnName:@"target_object_label"];
    BOOL isSFIDFieldPresent =[appDelegate.dataBase isColumnPresentInTable:SFPROCESSCOMPONENT columnName:@"sfID"];
    BOOL isFieldTypeFieldPresent =[appDelegate.dataBase isColumnPresentInTable:SFEXPRESSIONCOMPONENT columnName:@"field_type"];
    BOOL isExpressionTypeFieldPresent =[appDelegate.dataBase isColumnPresentInTable:SFEXPRESSIONCOMPONENT columnName:@"expression_type"];
    BOOL isParameterTypeFieldPresent =[appDelegate.dataBase isColumnPresentInTable:SFEXPRESSIONCOMPONENT columnName:@"parameter_type"];
    
    BOOL result = isBusinessRuleTableExists &&
    isProcessBusinessRuleTableExists &&
    isTargetObjLabelFieldPresent &&
    isSFIDFieldPresent &&
    isFieldTypeFieldPresent &&
    isExpressionTypeFieldPresent &&
    isParameterTypeFieldPresent;
    return result;
}
- (NSString *) getPathForLibrary:(NSString *)library {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = documentsDirectory;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]){
        
    }
    return dataPath;
    
}
- (NSString *) getPathForBSLibrary:(NSString *)library {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath =[documentsDirectory stringByAppendingPathComponent:library];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]){
        
    }
    return dataPath;
    
}
- (NSDictionary *) getFieldsInfoForRuleFields:(NSDictionary *)ruleFields
                                  detailNames:(NSArray *)childObjectNamesArray
                             parentObjectName:(NSString *)parentObjectName
{
    NSArray *fieldsForHeader = [ruleFields objectForKey:parentObjectName];
    
    NSMutableDictionary *fields = [[NSMutableDictionary alloc] init];
    NSArray *columnsArray = [NSArray arrayWithObjects:MFIELD_API_NAME,MTYPEM, nil];
    NSString *filterCriteria = [NSString stringWithFormat:@"object_api_name = '%@'",parentObjectName];
    if([fieldsForHeader count])
    {
        NSArray *headerFieldsArray = [appDelegate.dataBase getAllRecordsFromTable:SFOBJECTFIELD
                                                                       forColumns:columnsArray
                                                                   filterCriteria:filterCriteria
                                                                            limit:nil];
        NSMutableDictionary *headerFieldsDict = [[NSMutableDictionary alloc] init];
        for(NSDictionary *dict in headerFieldsArray)
        {
            NSString *fieldName = [dict objectForKey:MFIELD_API_NAME];
            if([fieldsForHeader containsObject:fieldName])
            {
                NSString *fieldType = [dict objectForKey:MTYPEM];
                [headerFieldsDict setObject:fieldType forKey:fieldName];
            }
        }
        [fields setObject:headerFieldsDict forKey:parentObjectName];
        [headerFieldsDict release];
        headerFieldsDict = nil;
    }
    for(NSString *childObjName in childObjectNamesArray)
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSArray *fieldsForChild = [ruleFields objectForKey:childObjName];
        if([fieldsForChild count])
        {
            NSMutableDictionary *childFieldsDict = [[NSMutableDictionary alloc] init];
            filterCriteria = [NSString stringWithFormat:@"object_api_name = '%@'",childObjName];
            NSArray *childFieldsArray = [appDelegate.dataBase getAllRecordsFromTable:SFOBJECTFIELD
                                                                          forColumns:columnsArray
                                                                      filterCriteria:filterCriteria
                                                                               limit:nil];
            for(NSDictionary *dict in childFieldsArray)
            {
                NSString *fieldName = [dict objectForKey:MFIELD_API_NAME];
                if([fieldsForChild containsObject:fieldName])
                {
                    NSString *fieldType = [dict objectForKey:MTYPEM];
                    [childFieldsDict setObject:fieldType forKey:fieldName];
                }
            }
            [fields setObject:childFieldsDict forKey:childObjName];
            [childFieldsDict release];
            childFieldsDict = nil;
        }
        [pool drain];
        
    }
    return [fields autorelease];
}
- (NSDictionary *) getBizRulesAndFieldsForParentObject:(NSString *)parentObjectName
                                          childObjects:(NSArray *)childObjectsArray
{
    NSString *filterCriteria = [NSString stringWithFormat:@"process_id = '%@'",currentProcessId];
    NSArray *processColumn = [NSArray arrayWithObjects:@"sfID",nil];
    NSString *processID = [[[appDelegate.dataBase getAllRecordsFromTable:SFPROCESS
                                                              forColumns:processColumn
                                                          filterCriteria:filterCriteria
                                                                   limit:@"1"] objectAtIndex:0] objectForKey:@"sfID"];
    
    NSString *criteria = nil;
    NSArray *columns =nil;
    criteria = [NSString stringWithFormat:@"target_manager ='%@' order by sequence",processID];
    columns = [NSArray arrayWithObjects:@"error_msg",@"business_rule", nil];             // Defect 008607
    NSArray *processBusinessRulesArray = [appDelegate.dataBase getAllRecordsFromTable:@"ProcessBusinessRule"
                                                                          forColumns:columns
                                                                      filterCriteria:criteria
                                                                               limit:nil];
    NSMutableArray *headerBusinessRulesArray = [[NSMutableArray alloc] init] ;
    for(NSDictionary *processBizRuleDict in processBusinessRulesArray)
    {
        NSString *bizRuleId = [processBizRuleDict objectForKey:@"business_rule"];
     criteria = [NSString stringWithFormat:@"Id like  \"%@\" and source_object_name = '%@'",bizRuleId,parentObjectName];
    columns = [NSArray arrayWithObjects:@"Id",@"advanced_expression",@"source_object_name",@"message_type", nil];
        NSArray *headerBizRulesArray = [appDelegate.dataBase getAllRecordsFromTable:@"BusinessRule"
                                                                              forColumns:columns
                                                                          filterCriteria:criteria
                                                                                   limit:@"1"];
             // Defect 008607

        if([headerBizRulesArray count])
        {
            // Defect 008607
            NSMutableDictionary *headerInfoDict = [[NSMutableDictionary alloc] init];
            NSDictionary *headerDict = [headerBizRulesArray objectAtIndex:0];
            [headerInfoDict setObject:[headerDict objectForKey:@"Id"] forKey:@"Id"];
            [headerInfoDict setObject:[headerDict objectForKey:@"advanced_expression"] forKey:@"advanced_expression"];
            [headerInfoDict setObject:[headerDict objectForKey:@"source_object_name"] forKey:@"source_object_name"];
            [headerInfoDict setObject:[headerDict objectForKey:@"message_type"] forKey:@"message_type"];
            [headerInfoDict setObject:[processBizRuleDict objectForKey:@"error_msg"] forKey:@"error_msg"];
            [headerBusinessRulesArray addObject:headerInfoDict];
            [headerInfoDict release];
        }
    }
    NSMutableDictionary *fullRulesDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary    *fieldsDict = [[NSMutableDictionary alloc] init];
    
    NSArray *headerRulesArray = [self getBusinessRulesDict:headerBusinessRulesArray];
    [headerBusinessRulesArray release];
    NSMutableArray *headerFields = [[NSMutableArray alloc] init];
    for(NSDictionary *ruleDict in headerRulesArray)
    {
        NSDictionary *ruleInfo = [ruleDict objectForKey:@"ruleInfo"];
        if(ruleInfo)
        {
            NSArray *ruleDetails = [ruleInfo objectForKey:@"bizRuleDetails"];
            for(NSDictionary *rule in ruleDetails)
            {
                NSString *parameterType = [rule objectForKey:@"SVMXC__Parameter_Type__c"];
                NSString *fieldName = [rule objectForKey:@"SVMXC__Field_Name__c"];
                if(![headerFields containsObject:fieldName])
                    [headerFields addObject:fieldName];
                if([parameterType isEqualToString:@"Field Value"])
                {
                    NSString *operandFieldName = [rule objectForKey:@"SVMXC__Operand__c"];
                    if(![headerFields containsObject:operandFieldName])
                        [headerFields addObject:operandFieldName];
                }
            }
        }
    }
    if([headerFields count])
        [fieldsDict setObject:headerFields forKey:parentObjectName];
    [headerFields release];
    headerFields = nil;
    NSDictionary *headerRulesDict = [NSDictionary dictionaryWithObject:headerRulesArray forKey:@"rules"];
    [fullRulesDict setObject:headerRulesDict forKey:MHEADER];
    
    for(NSDictionary *dict in childObjectsArray)
    {
        NSAutoreleasePool *childReleasePool = [[NSAutoreleasePool alloc] init];
        NSString *layoutID = [dict objectForKey:gDETAILS_LAYOUT_ID];
        NSString *detailName = [dict objectForKey:gDETAILS_PAGE_LAYOUT_ID];
        NSString *childObjectName = [dict objectForKey:gDETAIL_OBJECT_NAME];
        
        NSMutableDictionary *childDict = [[NSMutableDictionary alloc] init];
        [childDict setObject:layoutID forKey:@"key"];
        criteria = [NSString stringWithFormat:@"process_id IN (select process_id from SFProcess where sfID = '%@') and target_object_label = '%@'",processID,detailName];
        columns = [NSArray arrayWithObjects:@"sfID", nil];
        NSArray *processBusinessRuleIDs = [appDelegate.dataBase getAllRecordsFromTable:PROCESS_COMPONENT
                                                                            forColumns:columns
                                                                        filterCriteria:criteria
                                                                                 limit:nil];
        if([processBusinessRuleIDs count] == 0)
        {
            [childDict release];
            [childReleasePool drain];
            continue;
        }
        NSDictionary *dict =  [processBusinessRuleIDs objectAtIndex:0]; //Asuming only one record
        NSString *processBizRuleID = [dict objectForKey:@"sfID"];
        criteria = [NSString stringWithFormat:@" process_node_object ='%@' order by sequence",processBizRuleID];
        // Defect 008607
        columns = [NSArray arrayWithObjects:@"business_rule",@"error_msg", nil];
        NSArray *detailBusinessRuleArray = [appDelegate.dataBase getAllRecordsFromTable:@"ProcessBusinessRule"
                                                                              forColumns:columns
                                                                          filterCriteria:criteria
                                                                                   limit:nil];
        NSMutableArray *detailBusinessRulesArray = [[NSMutableArray alloc] init];
        for(NSDictionary *dict in detailBusinessRuleArray)
        {
            NSString *childBizRuleId = [dict objectForKey:@"business_rule"];
            criteria = [NSString stringWithFormat:@"Id = '%@'",childBizRuleId];
            columns = [NSArray arrayWithObjects:@"Id",@"advanced_expression",SOURCE_OBJECT_NAME,@"message_type", nil];
            NSArray *detailBizRulesArray = [appDelegate.dataBase getAllRecordsFromTable:@"BusinessRule"
                                                                                  forColumns:columns
                                                                              filterCriteria:criteria
                                                                                       limit:@"1"];
            
            if([detailBizRulesArray count])
            {
                // Defect 008607
                NSMutableDictionary *childInfoDict = [[NSMutableDictionary alloc] init];
                NSDictionary *headerDict = [detailBizRulesArray objectAtIndex:0];
                [childInfoDict setObject:[headerDict objectForKey:@"Id"] forKey:@"Id"];
                [childInfoDict setObject:[headerDict objectForKey:@"advanced_expression"] forKey:@"advanced_expression"];
                [childInfoDict setObject:[headerDict objectForKey:@"source_object_name"] forKey:@"source_object_name"];
                [childInfoDict setObject:[headerDict objectForKey:@"message_type"] forKey:@"message_type"];
                [childInfoDict setObject:[dict objectForKey:@"error_msg"] forKey:@"error_msg"];
                [detailBusinessRulesArray addObject:childInfoDict];
                [childInfoDict release];
            }
        }
        NSArray *childRulesArray = [self getBusinessRulesDict:detailBusinessRulesArray];
        [detailBusinessRulesArray release];
        
        if([childRulesArray count] == 0)
        {
            [childDict release];
            childDict = nil;
            [childReleasePool drain];
            continue;
        }
        NSMutableArray *childFields = nil;
        childFields = [fieldsDict objectForKey:childObjectName];
        if(!childFields)
            childFields = [[[NSMutableArray alloc] init] autorelease];
        for(NSDictionary *ruleDict in childRulesArray)
        {
            NSDictionary *ruleInfo = [ruleDict objectForKey:@"ruleInfo"];
            if(ruleInfo)
            {
                NSArray *ruleDetails = [ruleInfo objectForKey:@"bizRuleDetails"];
                for(NSDictionary *rule in ruleDetails)
                {
                    NSString *parameterType = [rule objectForKey:@"SVMXC__Parameter_Type__c"];
                    NSString *fieldName = [rule objectForKey:@"SVMXC__Field_Name__c"];
                    if(![childFields containsObject:fieldName])
                        [childFields addObject:fieldName];
                    if([parameterType isEqualToString:@"Field Value"])
                    {
                        NSString *operandFieldName = [rule objectForKey:@"SVMXC__Operand__c"];
                        if(![childFields containsObject:operandFieldName])
                            [childFields addObject:operandFieldName];
                    }
                }
            }
        }
        [fieldsDict setObject:childFields forKey:childObjectName];
        [childDict setObject:childRulesArray forKey:@"rules"];
        if([childRulesArray count])
            [fullRulesDict setObject:childDict forKey:detailName];
        [childDict release];
        childDict = nil;
        [childReleasePool drain];
    }
    NSMutableDictionary *rulesAndFields = [[NSMutableDictionary alloc] init];
    [rulesAndFields setObject:fullRulesDict forKey:@"Rules"];
    [rulesAndFields setObject:fieldsDict forKey:@"Fields"];
    [fullRulesDict release];
    fullRulesDict = nil;
    [fieldsDict release];
    fieldsDict = nil;
    return [rulesAndFields autorelease];
}
- (NSMutableDictionary *) getValuesFromDBForKeys:(NSArray *)fields
                                    withDataType:(NSDictionary *)fieldsDataType
                                      objectName:(NSString *)tabelName
                                     withLocalID:(NSString *)localID
{
    NSMutableDictionary *valuesFromDB = [[NSMutableDictionary alloc] init];
    for(NSString *fieldName in fields)
    {
        [valuesFromDB setObject:@"" forKey:fieldName];
    }
    if(localID)
    {
        NSString *criteria = [NSString stringWithFormat:@"local_id = '%@'",localID];
        NSArray *valuesArray = [appDelegate.dataBase getAllRecordsFromTable:tabelName
                                                                       forColumns:fields
                                                                   filterCriteria:criteria
                                                                            limit:@"1"];
        if([valuesArray count])
        {
            NSDictionary *vaueDict = [valuesArray objectAtIndex:0];
            for(NSString *fieldName in fields)
            {
                NSString *fieldDataType = [fieldsDataType objectForKey:fieldName];
                NSString *fieldValue = [vaueDict objectForKey:fieldName];
                if(fieldValue)
                {
                    if([fieldDataType isEqualToString:@"reference"])
                    {
                        NSString *value = (NSString *)fieldValue;
                        NSString *referenceTableName = [appDelegate.dataBase getReferencetoFiledForObject:tabelName api_Name:fieldName];
                        NSString *nameField = [appDelegate.databaseInterface getNameFieldForObject:referenceTableName];
                        NSString *filterCriteria = [NSString stringWithFormat:@"Id = '%@'",value];
                        NSArray *columnList = [NSArray arrayWithObjects:nameField,nil];
                        NSArray *resultArray = [appDelegate.dataBase getAllRecordsFromTable:referenceTableName
                                                                                  forColumns:columnList
                                                                              filterCriteria:filterCriteria
                                                                                        limit:@"1"];
                        //009396
                        if([resultArray count] == 0)
                        {
                            filterCriteria = [NSString stringWithFormat:@"local_id = '%@'",value];
                            resultArray = [appDelegate.dataBase getAllRecordsFromTable:referenceTableName
                                                                                     forColumns:columnList
                                                                                 filterCriteria:filterCriteria
                                                                                          limit:@"1"];
                        }
                        if([resultArray count])
                        {
                            NSString *fieldRefValue = [[resultArray objectAtIndex:0] objectForKey:nameField];
                            if(!fieldRefValue)
                            {
                                columnList = [NSArray arrayWithObjects:@"value",nil];
                                //009396
                                filterCriteria = [NSString stringWithFormat:@"object_api_name ='%@' and Id ='%@'",referenceTableName,value];
                                NSArray *resultLookpArray = [appDelegate.dataBase getAllRecordsFromTable:@"LookUpFieldValue"
                                                                                         forColumns:columnList
                                                                                     filterCriteria:filterCriteria
                                                                                              limit:@"1"];
                                if([resultLookpArray count])
                                {
                                    NSDictionary *resultLookupDict = [resultLookpArray objectAtIndex:0];
                                    if([[resultLookupDict allKeys] count])
                                    {
                                        NSString *lookupValue = [resultLookupDict objectForKey:@"value"];
                                        if(lookupValue)
                                            fieldValue = lookupValue;
                                    }
                                }
                            }
                            else
                                fieldValue = fieldRefValue;
                        }
                        else
                        {
                            columnList = [NSArray arrayWithObjects:@"value",nil];
                            filterCriteria = [NSString stringWithFormat:@"object_api_name ='%@' and Id ='%@'",referenceTableName,value];//009396
                            NSArray *resultLookpArray = [appDelegate.dataBase getAllRecordsFromTable:@"LookUpFieldValue"
                                                                                          forColumns:columnList
                                                                                      filterCriteria:filterCriteria
                                                                                               limit:@"1"];
                            if([resultLookpArray count])
                            {
                                NSDictionary *resultLookupDict = [resultLookpArray objectAtIndex:0];
                                if([[resultLookupDict allKeys] count])
                                {
                                    NSString *lookupValue = [resultLookupDict objectForKey:@"value"];
                                    if(lookupValue)
                                        fieldValue = lookupValue;
                                }
                            }
                        }
                    }
                    if([fieldDataType isEqualToString:@"picklist"])
                    {
                        NSString *value = (NSString *)fieldValue;
                        if(([value length] == 1) && ([value isEqualToString:@" "]))
                        {
                            fieldValue = @"";
                        }
                    }
                    else if([fieldDataType isEqualToString:@"datetime"])
                    {
                        NSString *dateTimeFieldValue = [iOSInterfaceObject getLocalTimeFromGMT:(NSString *)fieldValue];
                        if(dateTimeFieldValue && ( [dateTimeFieldValue length] > 16))
                            fieldValue = [NSString stringWithFormat:@"%@:00z",[dateTimeFieldValue substringToIndex:16]];
                        else
                            fieldValue = dateTimeFieldValue;
                    }
                    else if([fieldDataType isEqualToString:@"boolean"])
                    {
                        NSString *value = (NSString *)fieldValue;
                        if(([value caseInsensitiveCompare:@"true"] == NSOrderedSame)||
                           ([value caseInsensitiveCompare:@"1"] == NSOrderedSame)    ||
                           ([value caseInsensitiveCompare:@"yes"] == NSOrderedSame)
                           )
                        {
                            fieldValue = @"True";
                        }
                        else
                        {
                            fieldValue = @"False";
                        }
                    }
                    [valuesFromDB setObject:fieldValue forKey:fieldName];
                }
                else
                {
                    [valuesFromDB setObject:@"" forKey:fieldName];
                }
                
            }
        }
    }
    return [valuesFromDB autorelease];
}
- (NSDictionary *) getDataForRulesWithFieldsInfo:(NSDictionary *)fields
                                     detailNames:(NSArray *)childObjectNamesArray
                                withParentObject:(NSString *)parentObjectName
{
    NSMutableDictionary *dataToValidate = [[NSMutableDictionary alloc] init];
    NSArray *fieldsForHeader = [[fields objectForKey:parentObjectName] allKeys];
    NSArray *childObjectsArray = [appDelegate.SFMPage objectForKey:gDETAILS];
    NSString *filterCriteria = nil;  
    NSArray *headerArray = [[appDelegate.SFMPage objectForKey:MHEADER] objectForKey:gHEADER_SECTIONS];
    NSString *sectionFieldName;
    id sectionFieldValue;
    NSDictionary *parentObjectFields = [fields objectForKey:parentObjectName];
    // initialize all the header fields with the blank value
    NSArray *headerFields = [parentObjectFields allKeys];
    NSDictionary *headerFieldDataType = [fields objectForKey:parentObjectName];
    NSMutableDictionary *dict = [[self getValuesFromDBForKeys:headerFields
                                                 withDataType:headerFieldDataType
                                                   objectName:parentObjectName
                                                  withLocalID:appDelegate.sfmPageController.recordId] retain];
    for(NSDictionary *sectionDict in headerArray)
    {
        NSArray *sectionFieldsArray = [sectionDict objectForKey:@"section_Fields"];
        for(NSDictionary *section in sectionFieldsArray)
        {
            sectionFieldName = [section objectForKey:gFIELD_API_NAME];
            if([fieldsForHeader containsObject:sectionFieldName])
            {
                sectionFieldValue = [section objectForKey:gFIELD_VALUE_KEY]; // defect 8541
                NSString *fieldType = [parentObjectFields objectForKey:sectionFieldName];
                if([fieldType isEqualToString:@"picklist"])
                {
                    NSString *value = (NSString *)sectionFieldValue;
                    if(([value length] == 1) && ([value isEqualToString:@" "]))
                    {
                        sectionFieldValue = @"";
                    }
                }
                else if([fieldType isEqualToString:@"datetime"])
                {
                    NSString *dateTimeFieldValue = [iOSInterfaceObject getLocalTimeFromGMT:(NSString *)sectionFieldValue];
                    if(dateTimeFieldValue && ( [dateTimeFieldValue length] > 16))
                        sectionFieldValue = [NSString stringWithFormat:@"%@:00z",[dateTimeFieldValue substringToIndex:16]];
                    else
                        sectionFieldValue = dateTimeFieldValue;
                }
                else if([fieldType isEqualToString:@"boolean"])
                {
                    NSString *value = (NSString *)sectionFieldValue;
                    if(([value caseInsensitiveCompare:@"true"] == NSOrderedSame)||
                       ([value caseInsensitiveCompare:@"1"] == NSOrderedSame)    ||
                       ([value caseInsensitiveCompare:@"yes"] == NSOrderedSame)
                       )
                    {
                        sectionFieldValue = @"True";
                    }
                    else
                    {
                        sectionFieldValue = @"False";
                    }
                }
                else if([fieldType isEqualToString:@"reference"])
                {
                    sectionFieldValue = [section objectForKey:gFIELD_VALUE_VALUE];//009396
                }
//                if(sectionFieldValue != nil) // Damodar - Win14 - MemMgt - revoked to fix crash
                    [dict setObject:sectionFieldValue forKey:sectionFieldName];
            }
        }
        SMLog(kLogLevelVerbose,@" New Record. Get the key and value from the SFMPage");
    }
    NSDictionary *attributeDict = [NSDictionary dictionaryWithObject:parentObjectName forKey:MTYPEM];
    [dict setObject:attributeDict forKey:@"attributes"];
    [dataToValidate setDictionary:dict];
    [dict release];
    dict = nil;
    
    NSMutableDictionary *detailsDict = [[NSMutableDictionary alloc] init];
    for(NSDictionary *childDict in childObjectsArray)
    {
        NSArray *valuesArray = [childDict objectForKey:gDETAILS_VALUES_ARRAY];
        if([valuesArray count] == 0)
            continue;
        NSString *layoutID = [childDict objectForKey:gDETAILS_LAYOUT_ID];
        NSString *childObjectName = [childDict objectForKey:gDETAIL_OBJECT_NAME];
        NSMutableDictionary *detailDict = [[NSMutableDictionary alloc] init];
        NSMutableArray *detailArray = [[NSMutableArray alloc] init];
        // Populate array
        filterCriteria = [NSString stringWithFormat:@"object_api_name_child = '%@'",childObjectName];
        NSArray *fieldApiNameArray = [appDelegate.dataBase getAllRecordsFromTable:SFCHILDRELATIONSHIP
                                                                       forColumns:[NSArray arrayWithObjects:@"field_api_name", nil]
                                                                   filterCriteria:filterCriteria
                                                                            limit:nil];
        
        if(![fieldApiNameArray count])
        {
            SMLog(kLogLevelVerbose,@"Child Relationship is not found");
            //object_api_name ='SVMXC__RMA_Shipment_Order__c' and reference_to= 'SVMXC__Service_Order__c'
            filterCriteria = [NSString stringWithFormat:@"object_api_name = '%@' and reference_to = '%@'",childObjectName,parentObjectName];
            fieldApiNameArray = [appDelegate.dataBase getAllRecordsFromTable:SFREFERENCETO
                                                                           forColumns:[NSArray arrayWithObjects:@"field_api_name", nil]
                                                                       filterCriteria:filterCriteria
                                                                                limit:nil];
            if(![fieldApiNameArray count])
            {
                [detailArray release];
                [detailDict release];
                continue;
            }
        }
        NSString *columnName = [[fieldApiNameArray objectAtIndex:0] objectForKey:_MFIELD_API_NAME];
        if(!columnName)
        {
            SMLog(kLogLevelVerbose,@"Column Name is not there");
            [detailArray release];
            [detailDict release];
            continue;
        }
        NSMutableArray *lines = [[NSMutableArray alloc] init];
        for(NSArray *lineInfoArray in valuesArray)
        {
            NSString *detailObjectName = [childDict objectForKey:@"detail_object_name"];
            if([detailObjectName caseInsensitiveCompare:childObjectName] == NSOrderedSame)
            {
                NSArray *detailsArray = [childDict objectForKey:gDETAILS_VALUES_ARRAY];
                
                NSString *detailFieldName;
                id detailFieldValue;
                for(NSArray *detailFieldsArray in detailsArray)
                {
                    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                    NSArray *fieldsForChild = [[fields objectForKey:childObjectName] allKeys];
                    NSString *localId = nil;
                    for(NSDictionary *detail in detailFieldsArray)
                    {
                        NSString *objectKey = [detail objectForKey:gVALUE_FIELD_API_NAME];
                        if([objectKey caseInsensitiveCompare:@"local_id"] == NSOrderedSame)
                        {
                            localId = [detail objectForKey:gVALUE_FIELD_VALUE_KEY];
                            break;
                        }
                        
                    }
                    NSDictionary *childFieldsDataType = [fields objectForKey:detailObjectName];
                    NSMutableDictionary *dict = [[self getValuesFromDBForKeys:fieldsForChild
                                                                 withDataType:childFieldsDataType
                                                                   objectName:detailObjectName
                                                                  withLocalID:localId] retain];
                    for(NSDictionary *detail in detailFieldsArray)
                    {
                        detailFieldName = [detail objectForKey:gVALUE_FIELD_API_NAME];
                        if([fieldsForChild containsObject:detailFieldName])
                        {
                            detailFieldValue = [detail objectForKey:gVALUE_FIELD_VALUE_KEY]; //defect 8541
                            NSString *fieldType = [[fields objectForKey:childObjectName] objectForKey:detailFieldName];
                            if([fieldType isEqualToString:@"picklist"])
                            {
                                NSString *value = (NSString *)detailFieldValue;
                                if(([value length] == 1) && ([value isEqualToString:@" "]))
                                {
                                    detailFieldValue = @"";
                                }
                            }
                            else if([fieldType isEqualToString:@"datetime"])
                            {
                                NSString *dateTimeFieldValue = [iOSInterfaceObject getLocalTimeFromGMT:(NSString *)detailFieldValue];
                                if(dateTimeFieldValue && ( [dateTimeFieldValue length] > 16))
                                    detailFieldValue = [NSString stringWithFormat:@"%@:00z",[dateTimeFieldValue substringToIndex:16]];
                                else
                                    detailFieldValue = dateTimeFieldValue;
                            }
                            else if([fieldType isEqualToString:@"boolean"])
                            {
                                NSString *value = (NSString *)detailFieldValue;
                                if(([value caseInsensitiveCompare:@"true"] == NSOrderedSame)||
                                   ([value caseInsensitiveCompare:@"1"] == NSOrderedSame)    ||
                                   ([value caseInsensitiveCompare:@"yes"] == NSOrderedSame)
                                   )
                                {
                                    detailFieldValue = @"True";
                                }
                                else
                                {
                                    detailFieldValue = @"False";
                                }
                            }
                            else if([fieldType isEqualToString:@"reference"])
                            {
                                detailFieldValue = [detail objectForKey:gVALUE_FIELD_VALUE_VALUE];//009396
                            }
//                            if(detailFieldValue != nil) // Damodar - Win14 - MemMgt - revoked to fix crash
                                [dict setObject:detailFieldValue forKey:detailFieldName];
                        }
                    }
                    if([dict count])
                    {
                        NSDictionary *attributeDict = [NSDictionary dictionaryWithObject:childObjectName forKey:MTYPEM];
                        [dict setObject:attributeDict forKey:@"attributes"];
                        [lines addObject:dict];
                    }
                    [dict release];
                    dict = nil;
                    [pool drain];
                }
            }
        }
        [detailDict setObject:lines forKey:@"lines"];
        [lines release];
        lines = nil;
        [detailArray release];
        detailArray = nil;
        [detailsDict setObject:detailDict forKey:layoutID];
        [detailDict release];
        detailDict = nil;
    }
    [dataToValidate setObject:detailsDict forKey:gDETAILS];
    [detailsDict release];
    detailsDict = nil;
    return [dataToValidate autorelease];
}
- (NSString *)getBizRuleHTMLStringWithFields:(NSString *)fieldsString
                                   withRules:(NSString *)rulesString
                                    withData:(NSString *)dataToValidateString
{
    NSString *bootstrapPath = [self getPathForBSLibrary:@"com.servicemax.client.lib/src/bootstrap.js"];
    NSString *pathToLibrary = [[self getPathForLibrary:@"com.servicemax.client.lib"] stringByAppendingString:@"/com.servicemax.client.lib"];
    NSString *pathToModule = [self getPathForLibrary:@"modules"];
    NSString *appConfig = [NSString stringWithFormat:@"var appConfig = { \"title\" : \"Mobile business rules application\", \"version\" : \"1.0.0\",\
                           \"modules\" : [{ \"id\" : \"com.servicemax.client.app\",      			\"version\" : \"1.0.0\" , \"codebase\" : pathToModule },\
                           { \"id\" : \"com.servicemax.client.runtime\",      		\"version\" : \"1.0.0\" , \"codebase\" : pathToModule },\
                           { \"id\" : \"com.servicemax.client.sfmbizrules\",       \"version\" : \"1.0.0\" , \"codebase\" : pathToModule }\
                           ],\"app-config\" : {\"application-id\" : \"application\",\"enable-cache\" : true,\"enable-log\" : true},\"platform-config\" : {}};"];
    
    NSString *temp = [NSString stringWithFormat:@"var __SVMX_LOAD_VERSION__ = \"debug\";\
                      __SVMX_LOAD_APPLICATION__({appParams : {},\
                      configType : \"local\",\
                      loadVersion : __SVMX_LOAD_VERSION__,\
                      configData : appConfig,handler : function(){var bizrules = SVMX.create(\"com.servicemax.client.sfmbizrules.impl.BusinessRuleValidator\");"];
    
    NSString *htmlString = [NSString stringWithFormat:@"<html><script type=\"text/javascript\" src=\"%@\"></script><script type=\"text/javascript\" src=\"%@\"></script><script type=\"text/javascript\" src=\"CommunicationBridgeJS.js\"></script><script type=\"text/javascript\" src=\"bizRules-index.js\"></script><script>jQuery(document).ready(function(){ var pathToModule=\"%@\";var __SVMX_CLIENT_LIB_PATH__ = \"%@\"; %@ %@ var fields = %@; var dataToValidate = %@; var rules = %@;",bootstrapPath,pathToLibrary,pathToModule,pathToLibrary,appConfig,temp,fieldsString,dataToValidateString,rulesString];
    return htmlString;
}
- (NSArray *) getBusinessRulesDict:(NSArray *)businessRulesArray
{
    NSMutableArray *rulesArray = [[NSMutableArray alloc] init];
    
    NSString *criteria;
    NSArray *columns;
    int sequence = 0;
    for(NSDictionary *dict in businessRulesArray)
    {
        NSMutableDictionary *rulesDict = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *ruleInfoDict = [[NSMutableDictionary alloc] init];
        NSNumber *sequenceNumber = [NSNumber numberWithInt:sequence++];
        [rulesDict setValue:sequenceNumber forKey:@"sequence"];
        [rulesDict setObject:[dict objectForKey:@"error_msg"] forKey:@"message"];
        NSString *expressionID = [dict objectForKey:@"Id"];
        criteria = [NSString stringWithFormat:@"expression_id = '%@'",expressionID];
        columns = [NSArray arrayWithObjects:@"parameter_type",@"operator",@"component_lhs",@"component_rhs", nil];
        NSArray *bizRuleDetailsArray = [appDelegate.dataBase getAllRecordsFromTable:@"SFExpressionComponent"
                                                                         forColumns:columns
                                                                     filterCriteria:criteria
                                                                              limit:nil];
        
        NSString *defaultValue = @"";
        NSMutableArray *bizRulesDetailsArray = [[NSMutableArray alloc] init];
        for(NSDictionary *detailsDict in bizRuleDetailsArray)
        {
            NSString *parameterType = [detailsDict objectForKey:@"parameter_type"];
            NSString *operator = [detailsDict objectForKey:@"operator"];
            NSString *fieldName = [detailsDict objectForKey:@"component_lhs"];
            NSString *operand = [detailsDict objectForKey:@"component_rhs"];
            
            if(parameterType == nil) parameterType = defaultValue;
            if(operator == nil)  operator = defaultValue;
            if(fieldName == nil) fieldName = defaultValue;
            if(operand == nil) operand = defaultValue;
            
            NSMutableDictionary *details = [[NSMutableDictionary alloc] init];
            
            [details setObject:operand forKey:@"SVMXC__Operand__c"];
            [details setObject:expressionID forKey:@"SVMXC__Expression_Rule__c"];
            [details setObject:parameterType forKey:@"SVMXC__Parameter_Type__c"];
            [details setObject:operator forKey:@"SVMXC__Operator__c"];
            [details setObject:fieldName forKey:@"SVMXC__Field_Name__c"];
            
            [bizRulesDetailsArray addObject:details];
            [details release];
        }
        [ruleInfoDict setObject:bizRulesDetailsArray forKey:@"bizRuleDetails"];
        [bizRulesDetailsArray release];
        
        NSString *sourceObjectName = [dict objectForKey:@"source_object_name"];
        NSString *advancedExpression = [dict objectForKey:@"advanced_expression"];
        NSString *messageType = [dict objectForKey:@"message_type"];
        
        if(sourceObjectName == nil) sourceObjectName = defaultValue;
        if(advancedExpression == nil) advancedExpression = defaultValue;
        if(messageType == nil) messageType = defaultValue;
        
        NSMutableDictionary *ruleDict = [[NSMutableDictionary alloc] init];
        [ruleDict setObject:sourceObjectName forKey:@"SVMXC__Source_Object_Name__c"];
        [ruleDict setObject:advancedExpression forKey:@"SVMXC__Advance_Expression__c"];
        [ruleDict setObject:messageType forKey:@"SVMXC__Message_Type__c"];
        
        [ruleInfoDict setObject:ruleDict forKey:@"bizRule"];
        [ruleDict release];
        
        [rulesDict setObject:ruleInfoDict forKey:@"ruleInfo"];
        [ruleInfoDict release];
        
        [rulesArray addObject:rulesDict];
        [rulesDict release];
    }
    
    return [rulesArray autorelease];
}
- (BOOL) handleBizRuleWarnings:(NSArray *)warningsArray errors:(NSArray *)errorsArray
{
    BOOL shouldStopSave = FALSE;
    int warningsCount = [warningsArray count];
    int tag ;
    alertViewStatus = kBizRuleConfirmMessageInit;
    for(int i = 0; i< warningsCount; i++)
    {
        NSString * message = [[warningsArray objectAtIndex:i] objectForKey:@"message"];
        NSString * alertTitle = [appDelegate.wsInterface.tagsDictionary objectForKey:BIZ_RULE_WARNING_TITLE];
        NSString *title = [NSString stringWithFormat:@"%@ (%d/%d)",alertTitle,i+1,warningsCount];
        NSString * okButtonTitle = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
        NSString * cancelButtonTitle = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE];
        UIAlertView *bizRuleAlertView = [[UIAlertView alloc] initWithTitle:title
                                                                   message:message
                                                                  delegate:self
                                                         cancelButtonTitle:okButtonTitle
                                                         otherButtonTitles:cancelButtonTitle, nil];
        tag = i + 1000;
        [bizRuleAlertView setTag:tag];
        alertViewStatus = kBizRuleConfirmMessageInit;
        [bizRuleAlertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        [bizRuleAlertView release];
        bizRuleAlertView = nil;
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, YES))
        {
            if (alertViewStatus == kBizRuleConfirmMessageCancelled || alertViewStatus == kBizRuleConfirmMessageSaved)
                break;
        }
        if (alertViewStatus == kBizRuleConfirmMessageCancelled)
            break;
    }
    if ((alertViewStatus == kBizRuleConfirmMessageCancelled) || ([errorsArray count]))
    {
        SMLog(kLogLevelVerbose,@"Don't Save the record");
        [self enableSFMUI];
        business_rules_success = FALSE;
        shouldStopSave = TRUE;
        return shouldStopSave;
    }
    return shouldStopSave;
}
- (BOOL) bizRuleResourcesAvailable
{
    BOOL resourcesAvailable = NO;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [appDelegate getAppCustomSubDirectory]; // [paths objectAtIndex:0]; // Get documents folder
    
    NSString *dataPath = nil;
    NSArray * resourceList = [NSArray arrayWithObjects:@"com.servicemax.client.lib",@"com.servicemax.client.runtime",@"com.servicemax.client.app",@"com.servicemax.client.sfmbizrules", nil];
    for(NSString *library in resourceList)
    {
        dataPath =[documentsDirectory stringByAppendingPathComponent:library];
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        {
            SMLog(kLogLevelWarning,@"Resource %@ is not available",dataPath);
            resourcesAvailable  = NO;
            break;
        }
        resourcesAvailable = YES;
    }
    return resourcesAvailable;
}
-(void) initAllrequriredDetailsForProcessId:(NSString *)process_id recordId:(NSString *)recordId object_name:(NSString *)object_name
{
    appDelegate.sfmPageController.recordId = recordId;
    appDelegate.sfmPageController.processId = process_id;
    
    appDelegate.sfmPageController.objectName = object_name;
    self.currentRecordId  = recordId; //shr-retain 008595
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
            
            if([filed_api_name isEqualToString:@"WhatId"])
            {
                //   below code is the correct way of finding out the referece field name 
                NSString * keyPrefix = [field_key substringWithRange:NSMakeRange(0, 3)];
                
                NSString * referencetoObject = [appDelegate.databaseInterface getTheObjectApiNameForThePrefix:keyPrefix tableName:SFOBJECT];
                
                NSString * Name_field  = [appDelegate.dataBase getApiNameForNameField:referencetoObject];
                
                field_value = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:referencetoObject field_name:Name_field record_id:field_key];
               
            }
            else
            {
               
                //sahana - wrong way of handling reference fields
                NSMutableArray * referenceTotableNames = [appDelegate.databaseInterface getReferenceToForField:filed_api_name objectapiName:object_name tableName:SF_REFERENCE_TO];
                           
                if([referenceTotableNames count ] > 0)
                {
                    
                    NSString * reference_to_tableName = [referenceTotableNames objectAtIndex:0];
                    
                    NSString * referenceTo_Table_fieldName = [appDelegate.databaseInterface getFieldNameForReferenceTable:reference_to_tableName tableName:SFOBJECTFIELD];
                    
                    //field_value = [appDelegate.databaseInterface getReferencefield_valueFromReferenceToTable:reference_to_tableName field_name:referenceTo_Table_fieldName record_id:field_key];
                    field_value = [appDelegate.databaseInterface getReferenceValueFromReferenceToTable:reference_to_tableName field_name:referenceTo_Table_fieldName record_id:field_key];
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
        //7976: Comment this value

        /*if([field_value isEqualToString:@"" ]||[field_value isEqualToString:@" "] || field_value == nil)
        {
            field_value = field_key;
        }*/
        
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
//  Unused Methods
//-(NSArray *)orderingAnArray:(NSArray *)array
//{
//    NSArray * arr = nil;
//    NSMutableArray * sortedArray = [[[NSMutableArray alloc] initWithArray:array] autorelease];
//    int i = 0;
//    for (i = 0; i < [sortedArray count] - 1; i++)
//    {
//        
//        for (int j = 0; j < ([sortedArray count] - (i +1)); j++)
//        {
//            NSString * label = [sortedArray objectAtIndex:j];
//            NSString * label1;
//            label1 = [sortedArray objectAtIndex:j+1];
//            if (strcmp([label UTF8String], [label1 UTF8String]) > 0)
//            {
//                [sortedArray exchangeObjectAtIndex:j withObjectAtIndex:j+1];
//            }
//        }
//    } 
//    arr = sortedArray;
//    return arr;
//}

- (void) SeeMoreButtonClicked:(id)sender
{
    
    if (![appDelegate isInternetConnectionAvailable])
    {
        [activity stopAnimating];
        appDelegate.shouldShowConnectivityStatus = TRUE;
        [appDelegate displayNoInternetAvailable];
        return;
    } 
	
	//OAuth.
	if ( ![[ZKServerSwitchboard switchboard] doCheckSession] )
		return;

	[activity startAnimating];

    if ([appDelegate.syncThread isExecuting])
    {
        
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(kLogLevelVerbose,@"DetailViewController.m : seeMoreButtonsClicked: checkfor Data Sync");
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
            SMLog(kLogLevelVerbose,@"DetailViewController.m : seeMoreButtonsClicked: checkfor Meta Sync");
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
            SMLog(kLogLevelVerbose,@"DetailViewController.m : seeMoreButtonsClicked: checkfor Event Sync");
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
    SMLog(kLogLevelVerbose,@"%d", button.tag);
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
		synchronized_sqlite3_finalize(stmt);
    }

    if (button.tag == 1)
    {
        SMXMonitor *monitor = [[[SMXMonitor alloc] init] autorelease];
        [monitor monitorSMMessageWithName:@"[DetailViewController.m seeMoreButtonsClicked:PRODUCTHISTORY]"
                             withUserName:appDelegate.currentUserName
                                 logLevel:kPerformanceLevelWarning
                               logContext:@"Start"
                             timeInterval:kWSExecutionDuration];
        [appDelegate.wsInterface getProductHistoryForWorkOrderId:Id];
        
        appDelegate.wsInterface.didGetProductHistory = FALSE;
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(kLogLevelVerbose,@"DetailViewController.m : seeMoreButtonsClicked: product History");
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
        [monitor monitorSMMessageWithName:@"[DetailViewController.m seeMoreButtonsClicked:PRODUCTHISTORY]"
                             withUserName:appDelegate.currentUserName
                                 logLevel:kPerformanceLevelWarning
                               logContext:@"Stop"
                             timeInterval:kWSExecutionDuration];

        if ([appDelegate.wsInterface.productHistory count] > 0)
            [appDelegate.SFMPage setValue:appDelegate.wsInterface.productHistory forKey:PRODUCTHISTORY];
    }
    else if (button.tag == 2)
    {
        SMXMonitor *monitor = [[[SMXMonitor alloc] init] autorelease];
        [monitor monitorSMMessageWithName:@"[DetailViewController.m seeMoreButtonsClicked:AccountHistory]"
                             withUserName:appDelegate.currentUserName
                                 logLevel:kPerformanceLevelWarning
                               logContext:@"Start"
                             timeInterval:kWSExecutionDuration];
        [appDelegate.wsInterface getAccountHistoryForWorkOrderId:Id];
        appDelegate.wsInterface.didGetAccountHistory = FALSE;
        while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, kRunLoopTimeInterval, YES))
        {
#ifdef kPrintLogsDuringWebServiceCall
            SMLog(kLogLevelVerbose,@"DetailViewController.m : seeMoreButtonsClicked: account history");
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
        [monitor monitorSMMessageWithName:@"[DetailViewController.m seeMoreButtonsClicked:AccountHistory]"
                             withUserName:appDelegate.currentUserName
                                 logLevel:kPerformanceLevelWarning
                               logContext:@"Start"
                             timeInterval:kWSExecutionDuration];

        if ([appDelegate.wsInterface.accountHistory count] > 0)
            [appDelegate.SFMPage setValue:appDelegate.wsInterface.accountHistory forKey:ACCOUNTHISTORY];
    }
    [activity stopAnimating];
    [self.tableView reloadData];
    [appDelegate ScheduleIncrementalMetaSyncTimer];
    [appDelegate ScheduleIncrementalDatasyncTimer];
    [appDelegate ScheduleTimerForEventSync];
	//Radha Defect Fix 5542
	[appDelegate updateNextDataSyncTimeToBeDisplayed:[NSDate date]];
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
     synchronized_sqlite3_finalize(stmt);
        
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
    synchronized_sqlite3_finalize(stmt);
    
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
         synchronized_sqlite3_finalize(stmt);
    }
    return productName;
}

-(void)UpdateAlldeletedRecordsIntoSFTrailerTable:(NSArray *)deleted_record_array   object_name:(NSString *)object_name webserviceName:(NSString *)webservice_name className:(NSString *)class_name synctype:(NSString *)sync_type headerLocalId:(NSString *)header_localId requestData:(NSMutableDictionary *)request_data
{
    
     NSMutableDictionary *requestDictionary = nil;
    for(int i = 0; i < [deleted_record_array count]; i++)
    {
        NSString  * deleted_record_id =   [deleted_record_array objectAtIndex:i];
        NSString * sf_id_for_deleted_record  = [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:object_name local_id:deleted_record_id];
        
        if(![sf_id_for_deleted_record isEqualToString:@""])
        {
            
            //Shravya-8282
            //Get JSON string of this record Id and pass it as requestDictionary
            if (![sync_type isEqualToString:CUSTOMSYNC] && [request_data count] <= 0) {
                requestDictionary = [appDelegate.databaseInterface getRecordForSfId:deleted_record_id andTableName:object_name];
            }
            BOOL delete_Flag = [appDelegate.databaseInterface DeleterecordFromTable:object_name Forlocal_id:deleted_record_id];
            
            if(delete_Flag)
            {
                //Shravya-8282
                //Store the deleted record data in data trailer table
                if ([requestDictionary count] > 0) {
                    [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:deleted_record_id SF_id:sf_id_for_deleted_record record_type:DETAIL operation:DELETE object_name:object_name sync_flag:@"false" parentObjectName:@"" parent_loacl_id:@"" webserviceName:webserviceName className:className synctype:syncType headerLocalId:header_localId requestData:requestDictionary finalEntry:NO];
                    requestDictionary = nil;
                }
                else {
                [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:deleted_record_id SF_id:sf_id_for_deleted_record record_type:DETAIL operation:DELETE object_name:object_name sync_flag:@"false" parentObjectName:@"" parent_loacl_id:@"" webserviceName:webserviceName className:className synctype:syncType headerLocalId:header_localId requestData:request_data finalEntry:NO];
                }
            }
        }
    }
    
    //Radha #6951  && 6963
    if ([deleted_record_array count] == 0 && [sync_type isEqualToString:CUSTOMSYNC])
    {
        [appDelegate.databaseInterface  insertdataIntoTrailerTableForRecord:@"" SF_id:@"" record_type:DETAIL operation:DELETE object_name:object_name sync_flag:@"false" parentObjectName:@"" parent_loacl_id:@"" webserviceName:webserviceName className:className synctype:syncType headerLocalId:header_localId requestData:request_data finalEntry:NO];
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
        // Dam - Win14 changes
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= SUPPORTED_IOS_VERSION) {
            contentView_textView.textAlignment = NSTextAlignmentCenter;
        }
        else {
            contentView_textView.textAlignment = UITextAlignmentCenter;
        }

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
        
        //Aparna: 6889
        if (!recordExists)
        {
            NSString *sf_id =  [appDelegate.databaseInterface getSfid_For_LocalId_From_Object_table:reffered_to_table_name local_id:temp_record_id];
            recordExists = [appDelegate.dataBase checkIfRecordExistForObject:reffered_to_table_name Id:sf_id];
        }
        
        if (recordExists == FALSE)
            return;
    
        NSString * record_id = [appDelegate.databaseInterface  getLocalIdFromSFId:temp_record_id tableName:reffered_to_table_name];
        
        //Aparna: 6889
        if (record_id == nil || [record_id isEqualToString:@""] || [record_id isEqualToString:@" "])
        {
            record_id = temp_record_id;
        }

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
                            SMLog(kLogLevelVerbose,@"DictValue %@" , dict_value);
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
                //5878: Aparna
                if([controlType isEqualToString: @"picklist"] || [controlType isEqualToString: @"multipicklist"])
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
                    
                    if([control_type isEqualToString:@"picklist"] || [control_type isEqualToString:@"multipicklist"])
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
                            SMLog(kLogLevelVerbose,@"Fields Info ========= %@" , filed_info);
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
            
            //5878: Aparna
            if([control_type isEqualToString:@"picklist"] || [control_type isEqualToString:@"multipicklist"])
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
//  Unused Methods
//- (void) refreshStatusImage
//{
////    [statusButton setBackgroundImage:[self getStatusImage] forState:UIControlStateNormal];
//    //[appDelegate setSyncStatus:appDelegate.SyncStatus];
//}

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
    view.isAccessibilityElement = YES;
    view.accessibilityIdentifier = @"DetailViewError";
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
-(void)displayALertViewinSFMDetailview:(NSString *)excp_message
{
    NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_OVERLAP];
    message = [message stringByAppendingFormat:@"%@",excp_message];
//    [[NSString  alloc] initWithUTF8String:excp_message];
    UIAlertView * exeption_alert = [[UIAlertView alloc] initWithTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:sync_error_message] message:message delegate:self cancelButtonTitle:[appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_RESCHEDULE_NO] otherButtonTitles:[appDelegate.wsInterface.tagsDictionary objectForKey:EVENT_RESCHEDULE_YES], nil];

    [exeption_alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    [exeption_alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
	//Radha :- Implementation  for  Required Field alert in Debrief UI
    NSInteger alertTag = alertView.tag;
    if(alertTag >= 1000)
    {
        if(buttonIndex)
        {
            alertViewStatus = kBizRuleConfirmMessageCancelled;
            SMLog(kLogLevelVerbose,@"[Alert %d] Confirm Message Cancelled",alertView.tag);
        }
        else
        {
            alertViewStatus = kBizRuleConfirmMessageSaved;
            SMLog(kLogLevelVerbose,@"[Alert %d] Confirm Message Saved",alertView.tag);
        }
    }
    else
    {
        if([requiredFields isEqual:alertView])
        {
            if (buttonIndex == 0)
            {
                [self showCurrentRowForMandatoryFields:mandatoryRowDetails isLine:YES];
                [mandatoryRowDetails release];
            }
            
        }
        //Radha :- Implementation  for  Required Field alert in Debrief UI
        else
        {
            if(buttonIndex == 1)
            {
                EventUpdate_Continue = TRUE;
                [appDelegate.databaseInterface deleteRecordsFromEventLocalIdsFromTable:LOCAL_EVENT_UPDATE];
                NSMutableArray  *keys_event = nil, *objects_event = nil;
                keys_event = [NSMutableArray arrayWithObjects:SFW_ACTION_ID,SFW_ACTION_DESCRIPTION,SFW_EXPRESSION_ID,SFW_PROCESS_ID,SFW_ACTION_TYPE ,SFW_WIZARD_ID,SFW_ENABLE_ACTION_BUTTON,nil];// Dam - Win14 changes
                if(save_status == EDIT_QUICKSAVE)
                {
                    
                    objects_event = [NSMutableArray arrayWithObjects:@"",quick_save,@"",@"",gBUTTON_TYPE_TDM_IPAD_ONLY ,@"",@"true",nil];// Dam - Win14 changes
                }
                else
                {
                    objects_event = [NSMutableArray arrayWithObjects:@"",save,@"",@"",gBUTTON_TYPE_TDM_IPAD_ONLY ,@"",@"true",nil];// Dam - Win14 changes
                }
                NSMutableDictionary * dict_events_save = [NSMutableDictionary dictionaryWithObjects:objects_event forKeys:keys_event];
                [self offlineActions:dict_events_save];
                
            }
            else if(buttonIndex == 0){
                
                EventUpdate_Continue =FALSE;
                [appDelegate.databaseInterface deleteRecordsFromEventLocalIdsFromTable:Event_local_Ids];
                [appDelegate.databaseInterface deleteRecordsFromEventLocalIdsFromTable:LOCAL_EVENT_UPDATE];
            }

        }
    }
}

/* GET_PRICE_JS-shr*/
#pragma mark -
#pragma mark Get price

- (void)getPriceForCurrentContext {
    activity.hidden = NO;
    [activity startAnimating];
    [self.view bringSubviewToFront:activity];
   
    NSDictionary * sfm_temp = appDelegate.SFMPage;
    self.jsExecuter = nil;
    BOOL shouldContinue =  [self recordsAvailableForPriceCalculation:appDelegate.sfmPageController.recordId];
    if (!shouldContinue) {
        return;
    }
    
    PriceBookData *tempData = [[PriceBookData alloc] initWithSfmPage:sfm_temp];
    self.priceBookData = tempData;
    [tempData getJSONRepresentationForJS];
    tempData.targetObject = nil;
    tempData.priceBookComponents = nil;
    [tempData release];
    tempData = nil;
    
    
    NSString *codeSnipppet = [appDelegate.calDataBase getGetPriceCodeSnippet:@"Standard Get Price"];
  
    codeSnipppet = [codeSnipppet stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    codeSnipppet = [codeSnipppet stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    codeSnipppet = [codeSnipppet stringByReplacingOccurrencesOfString:@"\n" withString:@"  "];
    codeSnipppet = [codeSnipppet stringByReplacingOccurrencesOfString:@"\r" withString:@"  "];
    codeSnipppet = [codeSnipppet stringByReplacingOccurrencesOfString:@"\t" withString:@"  "];
    codeSnipppet = [codeSnipppet stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
    
    NSString *wrappedCode = [HTMLJSWrapper getWrapperForCodeSnippet:codeSnipppet];
    [self createJSExcecuter:self.view andCodeSnippet:wrappedCode];
}

- (void)createJSExcecuter:(UIView *)parentView andCodeSnippet:(NSString *)codeSnippet{
    
    JSExecuter *tempVar = [[JSExecuter alloc] initWithParentView:self.view andCodeSnippet:codeSnippet andDelegate:self];
    self.jsExecuter = tempVar;
    [tempVar release];
    tempVar = nil;
}


- (void)eventOccured:(NSString *)eventName andParameter:(NSString *)jsonParameterString {
    SMLog(kLogLevelVerbose,@"Event name is %@ and %@",eventName,jsonParameterString);
    
    if ([eventName isEqualToString:@"console"]) {
        NSDictionary *paramDict =  [Utility getTheParameterFromUrlParameterString:jsonParameterString];
        NSString *message =  [paramDict objectForKey:@"msg"];
        BOOL shouldDisplay = [self shouldDisplayMessage:message];
        if (shouldDisplay) {
               [self performSelectorOnMainThread:@selector(showAlertView:) withObject:message waitUntilDone:NO];
        }
    }
    else  if ([eventName isEqualToString:@"pricebook"])  {
        SMLog(kLogLevelVerbose,@"GP_request_JSExcecuter %@",self.priceBookData.jsonRepresentation);
        NSString *responseRecieved =  [self.jsExecuter response:self.priceBookData.jsonRepresentation forEventName:eventName];
        SMLog(kLogLevelVerbose,@"GP_response_JSExcecuter %@",responseRecieved);
        SBJsonParser *jsonParser =  [[SBJsonParser alloc] init];
        NSDictionary *finalDictionary = [jsonParser objectWithString:responseRecieved];
        [jsonParser release];
        jsonParser = nil;
        [self performSelectorOnMainThread:@selector(updateWorkOrderWithPrice:) withObject:finalDictionary waitUntilDone:NO];
    } else  if ([eventName isEqualToString:@"showmessage"])  {
        
        NSDictionary *paramDict =  [Utility getTheParameterFromUrlParameterString:jsonParameterString];
        NSString *message =  [paramDict objectForKey:@"msg"];
       
        if (message != nil) {
            [self performSelectorOnMainThread:@selector(showAlertView:) withObject:message waitUntilDone:NO];
        }
    }
    else if ([eventName isEqualToString:@"bizruleresult"])
    {
        bizRuleExecutionStatus = TRUE;
        SBJsonParser * jsonParser = [[[SBJsonParser alloc] init] autorelease];
        self.bizRuleResult = [jsonParser objectWithString:jsonParameterString];
        SMLog(kLogLevelVerbose,@"Event Name = %@",eventName);
        SMLog(kLogLevelVerbose,@"Data  = %@",jsonParameterString);
    }
}

- (BOOL)shouldDisplayMessage:(NSString *)message {
    message = [message lowercaseString];
    if ([Utility containsString:@" not " inString:message] || [Utility containsString:@" no " inString:message] || [Utility containsString:@" error " inString:message]) {
        return YES;
    }
    return NO;
}

- (void)showAlertView:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Get Price" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
    alertView = nil;
}

- (void)updateWorkOrderWithPrice:(NSDictionary *)updatedWo  {
    
    
    NSString *tableName = @"SVMXC__Service_Order__c";
    
    NSDictionary *tagHeaderDictionary = [self getServiceBooleanTypeDictionary:tableName];
    NSDictionary *fieldTypeDictionaryNew = [appDelegate.calDataBase getAllObjectFields:tableName tableName:SFOBJECTFIELD];
    
    NSDictionary *oldDictionary = appDelegate.SFMPage;
    
    
    NSMutableDictionary *finalHeaderDictionary = [[NSMutableDictionary alloc] initWithDictionary:[oldDictionary objectForKey:@"header"]];
    
    NSDictionary *headerDictionary = [updatedWo objectForKey:@"headerRecord"];
    NSArray *recordsArray =  [headerDictionary objectForKey:@"records"];
    NSDictionary *targetDict = [recordsArray objectAtIndex:0];
    
    if ([targetDict count] <= 0) {
        return;
    }
    
    NSDictionary *currentHDRData = [finalHeaderDictionary objectForKey:@"hdr_Data"];
    NSMutableDictionary *updatedColumnDictionary =  [[NSMutableDictionary alloc] initWithDictionary:currentHDRData];
    
    NSArray *targetRecAsKeyValue = [targetDict objectForKey:@"targetRecordAsKeyValue"];
    for (int counter = 0; counter < [targetRecAsKeyValue count]; counter++) {
        NSDictionary *keyAsValueDict = [targetRecAsKeyValue objectAtIndex:counter];
        
        NSString *key = [keyAsValueDict objectForKey:@"key"];
        NSString *value = [keyAsValueDict objectForKey:@"value"];
        
        if ([tagHeaderDictionary objectForKey:key] == nil) {
            if (![Utility isStringNotNULL:value]) {
                 [updatedColumnDictionary setObject:[NSString stringWithFormat:@""] forKey:key];
            }
            else {
                 [updatedColumnDictionary setObject:[NSString stringWithFormat:@"%@",value] forKey:key];
            }
           
        }
   }
    [finalHeaderDictionary setObject:updatedColumnDictionary forKey:@"hdr_Data"];
    
    
    /* update the page layout data */
    NSArray *displayFieldSections = [finalHeaderDictionary objectForKey:@"hdr_Sections"];
    NSMutableArray *someArray = [[NSMutableArray alloc] init];
    for (int n = 0; n < [displayFieldSections count]; n++) {
        NSDictionary *sectionDict = [displayFieldSections objectAtIndex:n];
        
        NSMutableDictionary *sectionDictMutable = [[NSMutableDictionary alloc] initWithDictionary:sectionDict];
        NSArray *sectionOne = [sectionDict objectForKey:@"section_Fields"];
        
        NSMutableArray *sectionOneArry = [[NSMutableArray alloc] init];
        
        for (int cc = 0; cc < [sectionOne count]; cc++) {
            
            NSDictionary *fieldDict = [sectionOne objectAtIndex:cc];
            NSMutableDictionary *fieldDictMutable = [[NSMutableDictionary alloc] initWithDictionary:fieldDict];
            NSString *fieldKey = [fieldDictMutable objectForKey:@"Field_API_Name"];
            
            NSString *tempStr = [updatedColumnDictionary objectForKey:fieldKey];
            if (tempStr != nil && [Utility isStringNotNULL:tempStr]) {
              
                NSString *fieldtype = [fieldTypeDictionaryNew objectForKey:fieldKey];
                [fieldDictMutable setObject:[NSString stringWithFormat:@"%@",tempStr] forKey:@"Field_Value_Key"];
                NSString *ffData  =  [self getValueForApiName:fieldKey dataType:fieldtype object_name:tableName field_key:tempStr];
                if (ffData != nil) {
                    [fieldDictMutable setObject:[NSString stringWithFormat:@"%@",ffData] forKey:@"Field_Value_Value"];
                }
            }
            [sectionOneArry addObject:fieldDictMutable];
            [fieldDictMutable release];
            fieldDictMutable = nil;
        }
        
        [sectionDictMutable setObject:sectionOneArry forKey:@"section_Fields"];
        [someArray addObject:sectionDictMutable];
        [sectionDictMutable release];
        sectionDictMutable = nil;
        [sectionOneArry release];
        sectionOneArry = nil;
    }
    [finalHeaderDictionary setObject:someArray forKey:@"hdr_Sections"];
    [someArray release];
    someArray = nil;
    [updatedColumnDictionary release];
    updatedColumnDictionary = nil;
    
    NSString *tableNameTwo = @"SVMXC__Service_Order_Line__c";
    NSDictionary *tagDetailDictionary = [self getServiceBooleanTypeDictionary:tableNameTwo];
    NSDictionary *fieldTypeDictionary = [appDelegate.calDataBase getAllObjectFields:tableNameTwo tableName:SFOBJECTFIELD];
    NSArray *detailRecords = [updatedWo objectForKey:@"detailRecords"];
    
    NSArray *oldDetailRecords  = [oldDictionary objectForKey:@"details"];
    
    NSMutableArray *brandNewDetailArray = [[NSMutableArray alloc] init];
    
    for (int counter = 0; counter < [oldDetailRecords count]; counter++) {
        
        NSDictionary *detailDictionary = [oldDetailRecords objectAtIndex:counter];
        NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] initWithDictionary:detailDictionary];
        
        NSString *aliasName = [newDictionary objectForKey:@"detail_object_alias_name"];
        NSArray *detailFieldValues = [newDictionary objectForKey:@"details_Values_Array"];
        
        NSMutableArray *detailFieldValuesMutable = [[NSMutableArray alloc] init];
        
        for (int j = 0; j < [detailFieldValues count]; j++) {
            
            NSArray *allFields = [detailFieldValues objectAtIndex:j];
            NSMutableArray *allFieldsMutable = [[NSMutableArray alloc] init]; // Damodar - Win14 - MemMgt - revoked to fix crash
            for (int k = 0; k < [allFields count]; k++) {
                
                NSDictionary *finalDictionary = [allFields objectAtIndex:k];
                NSMutableDictionary *keysDictionary = [[NSMutableDictionary alloc] initWithDictionary:finalDictionary];
                
                NSString *key = [keysDictionary objectForKey:@"value_Field_API_Name"];
                if ([tagDetailDictionary objectForKey:key] != nil) {
                    [allFieldsMutable addObject:keysDictionary];
                    [keysDictionary release];
                    keysDictionary = nil;
                    continue;
                }
                
                NSDictionary *updatedDictObj =  [self getTheValueFOrKey:key andAliasName:aliasName andIndex:j andArray:detailRecords];
                NSString *value = [updatedDictObj objectForKey:@"value"];
                NSString *valueOne = [updatedDictObj objectForKey:@"value1"];
                
                NSString *fieldtype = [fieldTypeDictionary objectForKey:key];
                if (value != nil && [Utility isStringNotNULL:value]) {
                    if ([fieldtype isEqualToString:@"datetime"]) {
                        value = [Utility replaceSpaceinDateByT:value];
                    }
                    [keysDictionary setObject:[NSString stringWithFormat:@"%@",value] forKey:@"value_Field_Value_key"];
                }
                else {
                     [keysDictionary setObject:[NSString stringWithFormat:@""] forKey:@"value_Field_Value_key"];
                     valueOne = @"";
                }
                if (valueOne != nil) {
                    NSString *ffData  =  [self getValueForApiName:key dataType:fieldtype object_name:tableNameTwo field_key:value];
                    if (ffData != nil) {
                        [keysDictionary setObject:[NSString stringWithFormat:@"%@",ffData] forKey:@"value_Field_Value_value"];
                    }
                }
                [allFieldsMutable addObject:keysDictionary];
                [keysDictionary release];
                keysDictionary = nil;
                
            }
            if ([allFieldsMutable count] > 0) {
                [detailFieldValuesMutable addObject:allFieldsMutable];
            }
        }
        if ([detailFieldValuesMutable count] == [detailFieldValues count]) {
            [newDictionary setObject:detailFieldValuesMutable forKey:@"details_Values_Array"];
        }
        [brandNewDetailArray addObject:newDictionary];
        
        [newDictionary release];
        newDictionary = nil;
        [detailFieldValuesMutable release];
        detailFieldValuesMutable = nil;
    }
    NSMutableDictionary *masterDictionary = [[NSMutableDictionary alloc] initWithDictionary:oldDictionary];
    
    if ([finalHeaderDictionary count] > 0) {
        [masterDictionary setObject:finalHeaderDictionary forKey:@"header"];
    }
    if ([brandNewDetailArray count] > 0) {
        [masterDictionary setObject:brandNewDetailArray forKey:@"details"];
    }
    
    if ([masterDictionary count] > 0) {
        appDelegate.SFMPage = masterDictionary;
    }
   
    [masterDictionary release];
    masterDictionary = nil;
    
    // Damodar - Win14 - MemMgt - revoked to fix crash
//    [finalHeaderDictionary release];
//    finalHeaderDictionary = nil;
//    [brandNewDetailArray release];
//    brandNewDetailArray = nil;
    
    [self.tableView reloadData];
    [appDelegate.sfmPageController.rootView refreshTable];
    [self  didselectSection:0];
    activity.hidden = YES;
    [activity stopAnimating];
    
}

- (NSDictionary *)getTheValueFOrKey:(NSString *)key andAliasName:(NSString *)aliasName andIndex:(NSInteger)index andArray:(NSArray *)detailArray{
    
    for (int counter = 0; counter < [detailArray count]; counter++) {
        
        NSDictionary *someDictioanry = [detailArray objectAtIndex:counter];
        NSString *aliasNameNew = [someDictioanry objectForKey:@"aliasName"];
        if ([aliasNameNew isEqualToString:aliasName]) {
            
        }
        else {
            continue;
        }
        
        NSArray *detailValuesArray = [someDictioanry objectForKey:@"records"];
        if ([detailValuesArray count] > index) {
            
            NSDictionary *valuesDictionary = [detailValuesArray objectAtIndex:index];
            NSArray *targetDictionaryAsKeyValue = [valuesDictionary objectForKey:@"targetRecordAsKeyValue"];
            for (int j = 0; j < [targetDictionaryAsKeyValue count]; j++) {
                NSDictionary *tempDictionary =  [targetDictionaryAsKeyValue objectAtIndex:j];
                NSString *keyNew =  [tempDictionary objectForKey:@"key"];
                if ([keyNew isEqualToString:key]) {
                    
                    return tempDictionary;
                }
            }
        }
    }
    return nil;
}

- (NSDictionary *)getServiceBooleanTypeDictionary:(NSString *)tableName {
    
    /* Get the columnName whose type is boolean */
    NSDictionary *someDictionaryNew =  [appDelegate.calDataBase getAllBooleanFieldsForTable:tableName];
    NSMutableDictionary *someDictionary = [[NSMutableDictionary alloc] initWithDictionary:someDictionaryNew];
    if ([tableName isEqualToString:@"SVMXC__Service_Order__c"]) {
        [someDictionary setObject:@"invalid_address_c" forKey:@"invalid_address_c"];
        [someDictionary setObject:@"svmxc_invoice_created_c" forKey:@"svmxc_invoice_created_c"];
        [someDictionary setObject:@"auto_calc_drive_time_c" forKey:@"auto_calc_drive_time_c"];
        [someDictionary setObject:@"svmxc_clock_paused_forever_c" forKey:@"svmxc_clock_paused_forever_c"];
        [someDictionary setObject:@"svmxc_optimax_error_occured_c" forKey:@"svmxc_optimax_error_occured_c"];
        [someDictionary setObject:@"svmxc_is_pm_work_order_c" forKey:@"svmxc_is_pm_work_order_c"];
        [someDictionary setObject:@"svmxc_is_sla_calculated_c" forKey:@"svmxc_is_sla_calculated_c"];
        [someDictionary setObject:@"svmxc_apply_business_hours_for_optimax_c" forKey:@"svmxc_apply_business_hours_for_optimax_c"];
        [someDictionary setObject:@"regulatory_4_c" forKey:@"regulatory_4_c"];
        [someDictionary setObject:@"svmxc_locked_by_dc_c" forKey:@"svmxc_locked_by_dc_c"];
        [someDictionary setObject:@"svmxc_sla_clock_paused_c" forKey:@"svmxc_sla_clock_paused_c"];
        [someDictionary setObject:@"geoviatrigger_c" forKey:@"geoviatrigger_c"];
        [someDictionary setObject:@"svmxc_is_service_covered_c" forKey:@"svmxc_is_service_covered_c"];
        [someDictionary setObject:@"svmxc_pm_tasks_created_c" forKey:@"svmxc_pm_tasks_created_c"];
        [someDictionary setObject:@"svmxc_customer_down_c" forKey:@"svmxc_customer_down_c"];
        [someDictionary setObject:@"svmxc_perform_auto_entitlement_c" forKey:@"svmxc_perform_auto_entitlement_c"];
        [someDictionary setObject:@"cust_bool_c" forKey:@"cust_bool_c"];
        [someDictionary setObject:@"svmxc_is_entitlement_performed_c" forKey:@"svmxc_is_entitlement_performed_c"];
        [someDictionary setObject:@"svmxc_isPartnerRecord_c" forKey:@"svmxc_isPartnerRecord_c"];
        [someDictionary setObject:@"parts_required_c" forKey:@"parts_required_c"];
        
    }
    else {
        [someDictionary setObject:@"svmxc_service_order_line_c" forKey:@"svmxc_service_order_line_c"];
        [someDictionary setObject:@"svmxc_use_price_fromPricebook_c" forKey:@"svmxc_use_price_fromPricebook_c"];
        [someDictionary setObject:@"isDeleted" forKey:@"isDeleted"];
        [someDictionary setObject:@"svmxc_posted_to_inventory_c" forKey:@"svmxc_posted_to_inventory_c"];
        [someDictionary setObject:@"svmxc_is_billable_c" forKey:@"svmxc_is_billable_c"];
        [someDictionary setObject:@"svmxc_include_in_quote_c" forKey:@"svmxc_include_in_quote_c"];
        [someDictionary setObject:@"svmxc_select_c" forKey:@"svmxc_select_c"];
    }
    return [someDictionary autorelease];
}
//  Unused Methods
//- (BOOL)checkIfAllAnyOneLinePresent {
//   
//    NSArray *detailRecords = [appDelegate.SFMPage objectForKey:@"details"];
//    for (int counter = 0; counter < [detailRecords count]; counter++) {
//        NSDictionary *oneDict = [detailRecords objectAtIndex:counter];
//        NSArray *valuesArra = [oneDict objectForKey:@"details_Values_Array"];
//        if ([valuesArra count] > 0) {
//             return YES;
//        }
//    }
//    return NO;
//}

- (BOOL)recordsAvailableForPriceCalculation:(NSString *)workOrderLocalId {
    
    NSString *tableName = @"SVMXC__Service_Order__c";
    NSString *sfmId = [appDelegate.calDataBase getSFIdForlocalId:workOrderLocalId andTableName:tableName];
    
    if (![Utility isStringEmpty:sfmId]) {
        
        NSString *status = [appDelegate.calDataBase getEntitlementStatus:sfmId recordIdFromTable:tableName];
        if ([Utility isItTrue:status]) {
            
            BOOL doesRecordAvailable = [appDelegate.calDataBase doesAllRecordsForGetPriceCalculationExist:sfmId];
            if (!doesRecordAvailable) {
                BOOL finalResult =  [self getPriceDataFromOnline:sfmId];
                if (!finalResult) {
                    NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:getPrice_Objects_not_found];
                    [self showAlertViewWhenGPCalculationNotPossible:message];
                }
                return finalResult;
            }
        }
        return YES;
    }
    
    return YES;
}

- (void)showAlertViewWhenGPCalculationNotPossible:(NSString * )message {
    
    NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
    NSString * Ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    
    UIAlertView * getPriceAlertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:Ok otherButtonTitles:nil];
    [getPriceAlertView show];
    [getPriceAlertView release];
}

- (BOOL)getPriceDataFromOnline:(NSString *)someIdentifier {
    
    if ([appDelegate isInternetConnectionAvailable]) {
        
        /*Invalidate all time and wait for current sync to finish */
        [self disableAllRunningNetworkOperations];
       
        
        /* Make a request for the sfmid*/
        BOOL isSucess = [appDelegate.wsInterface  getPriceInformationForWorkOrderId:someIdentifier];
        
        /*  Enable all timers  */
        [self enableAllNetworkOpertaions];
        
        
        return isSucess;
    }
    return NO;
}


- (void)disableAllRunningNetworkOperations {
     [appDelegate invalidateAllTimers];
}
- (void)enableAllNetworkOpertaions {
    [appDelegate ScheduleIncrementalDatasyncTimer];
    [appDelegate ScheduleIncrementalMetaSyncTimer];
    [appDelegate ScheduleTimerForEventSync];
    [appDelegate scheduleLocationPingTimer];
}


//6347 & 6757 : Aparna
#pragma mark -
#pragma mark Incremental Data Sync Notification Handler

- (void)handleIncrementalDataSyncNotification:(NSNotification *)notification
{
    
    [self performSelectorOnMainThread:@selector(refreshDetails) withObject:nil waitUntilDone:YES];
}

- (void)refreshDetails
{
    if([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"VIEWRECORD"])
    {
        [self fillSFMdictForOfflineforProcess:appDelegate.sfmPageController.processId forRecord:appDelegate.sfmPageController.recordId];
        [self didReceivePageLayoutOffline];
        [self fillDictionary:selectedIndexPath];
        [self.tableView reloadData];
    }
}



- (BOOL)shouldShowBillableAmountInServiceReport {
    return [appDelegate.calDataBase checkIfBillablePriceExistForWorkOrderId:appDelegate.sfmPageController.recordId andFieldName:@"SVMXC__Billable_Line_Price__c"];
}

- (BOOL)shouldShowBillableQuantityInServiceReport {
    
    
    return [appDelegate.calDataBase checkIfBillablePriceExistForWorkOrderId:appDelegate.sfmPageController.recordId andFieldName:@"SVMXC__Billable_Quantity__c"];
}
#pragma mark -
#pragma mark Manage edit view od lines
- (SFMEditDetailViewController *) getEditViewOfLine {
    
    if(self.editDetailObject == nil) {
        
    SFMEditDetailViewController *editDetailObj = [[SFMEditDetailViewController alloc] initWithNibName:@"SFMEditDetailViewController" bundle:nil];
        self.editDetailObject = editDetailObj;
		self.editDetailObject.detailDelegate = self;
        [editDetailObj release];
    }
    return self.editDetailObject;
}
- (IBAction)lineDetailBtnActionCheck:(id)sender {
    
	SVMAccessoryButton *btn = (SVMAccessoryButton *)sender;
    NSIndexPath *indexpath = btn.indexpath;
	//Radha Defect Fix 7446
	currentRowIndex = btn.index;
	
	//Defect Fix :- 007391
	self.selectedIndexPathForchildView = nil;
	[self.SFMChildTableview.view removeFromSuperview];
	
	//Defect Fix :- 007391
	self.selectedIndexPathForEdit = nil;
	[self.editDetailObject.view removeFromSuperview];
	[self.tableView reloadData];
	
	if(self.selectedIndexPathForchildView != nil && indexpath.section == self.selectedIndexPathForchildView.section && indexpath.row == self.selectedIndexPathForchildView.row )
	{
        [self hideChildLinkedViewProcess];
		[self.tableView reloadData];
		
	}
	else if (self.selectedIndexPathForchildView != nil)
	{
		[self hideChildLinkedViewProcess];
	}
    
	//Krishna debrief
    
//	self.editDetailObject = nil;
 	
	self.currentEditRow = indexpath;
    
    if(self.selectedIndexPathForEdit != nil && indexpath.section == self.selectedIndexPathForEdit.section && indexpath.row == self.selectedIndexPathForEdit.row) {
        
        [self hideEditViewOfLine];
        return;
    }
    

    NSInteger index;
    NSInteger section = indexpath.section;
    if (isDefault)
        index = section;
    else
        index = selectedRow;
    Disclosure_dict = nil;
    Disclosure_Details = nil;
    NSIndexPath * _indexPath = [NSIndexPath indexPathForRow:indexpath.row inSection:index];
    
    //KRI : check for new class
    [self fillDictionary:_indexPath];
	self.showSyncUI = self.showSyncUI;
    showSyncUI=YES;
    
    
	if (appDelegate.sfmPageController.conflictExists)
	{
		NSMutableString *Confilct= [appDelegate isConflictInEvent:[appDelegate.dataBase getApiNameFromFieldLabel: appDelegate.sfmPageController.objectName] local_id:appDelegate.sfmPageController.recordId];
		
		if([Confilct length]>0)
		{
			[self moveTableViewforDisplayingConflict:Confilct];
		}
	}
    [self showEditViewOfLineInView:nil forIndexPath:indexpath forEditMode:YES];
    self.selectedIndexPathForEdit = indexpath;
    
	[self.editDetailObject.tableView reloadData];
	[self.tableView reloadData];//Kri
    
	
}

- (void)showEditViewOfLineInView:(UIView *)parentView forIndexPath:(NSIndexPath *)_indexpath forEditMode:(BOOL)isEditMode {
    
//	self.editDetailObject = nil;
	//Defect Fix 7446
	NSIndexPath * currentIndexPath = [self getCurrentIndexPath:currentRowIndex];
	    
	[self getEditViewOfLine];
	self.selectedIndexPathForEdit = _indexpath;
    self.navigationController.delegate = self;
    self.editDetailObject.parentReference = self;
    self.editDetailObject.selectedIndexPath = currentIndexPath;
    self.editDetailObject.selectedRowForDetailEdit = currentIndexPath.row-1;
    self.editDetailObject.selectedSection = selectedSection;
    
    self.editDetailObject.header = self.header;
    self.editDetailObject.line = self.line;
    self.editDetailObject.isInEditDetail = isEditMode;
    self.editDetailObject.isInViewMode = isInViewMode;
    
    
    self.editDetailObject.Disclosure_dict = self.Disclosure_dict;
    self.editDetailObject.Disclosure_Fields = self.Disclosure_Fields;
    self.editDetailObject.Disclosure_Details = self.Disclosure_Details;
    self.editDetailObject.navigationItem.leftBarButtonItem = nil;
    [self.editDetailObject.navigationItem setHidesBackButton:YES animated:YES];

    self.editDetailObject.tableView.hidden = NO;
        
    parentView.clipsToBounds = YES;
	
	NSInteger height = [self.editDetailObject getHeightForEditView];

    CGRect tblViewHt = self.editDetailObject.tableView.frame;
    tblViewHt.size.height = height;
	//#Defect Fix :- 7365, 7373
	editDetailObject.view.frame = tblViewHt;
    editDetailObject.tableView.frame = tblViewHt;
    if (parentView == nil)
	{
		CGRect viewFrame = self.editDetailObject.view.frame;
		//#Defect Fix :- 7365, 7373
		viewFrame.origin.y = 40;
		viewFrame.size.width = self.tableView.frame.size.width;
		self.editDetailObject.view.frame = viewFrame;
	}
	
	else
	{
		//make tableview compatible to parent view ie cells content view
		CGRect viewFrame = self.editDetailObject.view.frame;
		//#Defect Fix :- 7365, 7373
		viewFrame.origin.y = 40;
		viewFrame.size.width = parentView.frame.size.width;
		self.editDetailObject.view.frame = viewFrame;
	}
    
    //change height of parent view
    CGRect parentFrame = parentView.frame;
    parentFrame.size.height = self.editDetailObject.tableView.frame.size.height+40;
    parentView.frame = parentFrame;
	
	//Radha - Debrief changes - 18th June '13
	self.editDetailObject.tableView.clipsToBounds = YES;
    //#Defect Fix :- 7365, 7373
    self.editDetailObject.tableView.frame = CGRectMake(0, 0, parentView.frame.size.width, self.editDetailObject.view.frame.size.height);		
    [parentView addSubview:self.editDetailObject.view];
	
	CGFloat heightOfTable = self.tableView.frame.size.height+ parentFrame.size.height;
	if (heightOfTable > self.view.frame.size.height)
	{
		@try {
			SMLog(kLogLevelVerbose,@"Soubld move");
			//Radha - #007381
			[self.tableView scrollToRowAtIndexPath:_indexpath atScrollPosition:UITableViewScrollPositionTop animated:YES];

		}
		@catch (NSException *exception) {
			SMLog(kLogLevelVerbose,@"%@", exception.name);
		}
	}
		
	[self.editDetailObject.tableView reloadData];

}
- (void)hideEditViewOfLine {

    self.selectedIndexPathForEdit = nil;
    self.editDetailObject.isInEditDetail = NO; //Defect Fix #7407
    [self.editDetailObject.view removeFromSuperview];
}

- (void) hideExpandedChildViews{
    if(self.selectedIndexPathForEdit != nil) {
        [self hideEditViewOfLine];
    }
    [self.tableView reloadData];
}
- (IBAction)lineDetailBtnAction:(id)sender {
	
	
	//Radha Defect Fix 7446
    SVMAccessoryButton *btn = (SVMAccessoryButton *) sender;
	currentRowIndex = btn.index;
    if(btn.tag == 9742) {
        if(![self.editDetailObject isNecessaryFieldsFilled]) {
            return;
        }
		[self.editDetailObject lineseditingDone];   //done saving for now
        [self hideExpandedChildViews];
                
    }
    else if(btn.tag == 9743) {
        
        [self hideExpandedChildViews];
    }
}
//Radha :- Implementation for cancel button in Debrief UI
- (IBAction)removeDetailLine:(id)sender
{
	UIButton * detail = (UIButton *) sender;
	NSInteger index = detail.tag;
	
    BOOL isNewLine = [self cancelIfNewLineAdded:index];
    
    if (isNewLine)
    {
        [tableView beginUpdates];
        
        [tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:self.selectedIndexPathForEdit] withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView endUpdates];
    }
	[self hideExpandedChildViews];
	
}

//Radha 22 June '13
//Radha :- Implementation for cancel button in Debrief UI 
- (BOOL) cancelIfNewLineAdded:(NSInteger)index
{
//    NSInteger section = self.editDetailObject.selectedIndexPath.section;
	NSInteger section = index;
    NSMutableArray * details = [appDelegate.SFMPage objectForKey:gDETAILS];
	
    
    NSMutableDictionary * detail = [details objectAtIndex:section];
    NSMutableArray * detail_values = [detail objectForKey:gDETAILS_VALUES_ARRAY];
    NSMutableArray * detail_Values_RECID = [detail objectForKey:gDETAIL_VALUES_RECORD_ID];
    
    
    NSMutableArray * detailValue = [detail_values objectAtIndex:self.editDetailObject.selectedRowForDetailEdit];
    NSString * record_id = [detail_Values_RECID objectAtIndex:self.editDetailObject.selectedRowForDetailEdit];
    
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
        {
            [detail_values removeObjectAtIndex:self.editDetailObject.selectedRowForDetailEdit];
            return YES;
        }
    }

    return NO;
    
}

- (void) populateMandatoryRow:(NSInteger)section indexpath:(NSIndexPath *)currentindexpath
{
	NSMutableArray * details = [appDelegate.SFMPage objectForKey:@"details"];
	NSMutableArray * detailFieldsArray = [[details objectAtIndex:section] objectForKey:gDETAILS_FIELDS_ARRAY];
	NSString * layout_id = [[details objectAtIndex:section] objectForKey:gDETAILS_LAYOUT_ID];
	NSString * process_id = currentProcessId;
	
	
	NSMutableDictionary * detail = [details objectAtIndex:section];
	NSString * detailObjectName = [detail objectForKey:gDETAIL_OBJECT_NAME];
	
	NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGETCHILD process_id:process_id layoutId:layout_id objectName:detailObjectName];
	
	NSMutableDictionary * object_mapping_dict = [appDelegate.databaseInterface getObjectMappingForMappingId:process_components mappingType:VALUE_MAPPING];
	
	NSArray * all_Keys_values = [object_mapping_dict allKeys];
	
	
	NSMutableArray * detailValue = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
	for (int i = 0; i < [detailFieldsArray count]; i++)
	{
		NSString * value = @"";
		NSString * key = @"";
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
	
	NSIndexPath * indexPath = nil;
	if (selectedSection == SHOWALL_LINES)
	{
		indexPath = [NSIndexPath indexPathForRow:currentindexpath.row inSection:section];
	}
	if(selectedSection == SHOW_LINES_ROW)
	{
		indexPath = [NSIndexPath indexPathForRow:currentindexpath.row inSection:0];
	}
	
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
	//Radha
	if (currentEditRow)
	{
		self.currentEditRow = nil;
	}
	self.currentEditRow = indexPath;
	
	Disclosure_dict = nil;
	Disclosure_Details = nil;
	[self fillDictionary:_indexPath];
}

//Defect Fix 7446
- (NSIndexPath *) getCurrentIndexPath:(NSInteger)section
{
	NSIndexPath * indexPath = nil;
	
	if (selectedSection == SHOWALL_LINES)
	{
		indexPath = [NSIndexPath indexPathForRow:self.selectedIndexPathForEdit.row inSection:section];
	}
	if(selectedSection == SHOW_LINES_ROW)
	{
		indexPath = [NSIndexPath indexPathForRow:self.selectedIndexPathForEdit.row inSection:0];
	}
	
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
	
	
	return _indexPath;
}


- (void)moveTableviewForKeyboardHeight:(NSNotification *)notification
{
    //Defect Fix :- #7390 #7407
    if((selectedSection != SHOWALL_HEADERS) && (selectedSection != SHOW_HEADER_ROW) && self.editDetailObject.isInEditDetail)
        self.selectedIndexPathForEdit = self.currentEditRow;
	
	@try {
		if ([[notification name] isEqual:UIKeyboardDidShowNotification])
		{
			NSDictionary * info = [notification userInfo];
			NSValue * keyBounds = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
			
			CGRect boundRect;
			[keyBounds getValue:&boundRect];
            
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:self.currentEditRow];
            if(boundRect.origin.x >700 || boundRect.origin.x <0 ) // External Keyboard used
            {
                CGFloat Y_Pos = 0,default_frame_Y=625;
        
                 Y_Pos = cell.frame.origin.y ;
                if(appDelegate.sfmPageController.conflictExists)
                {
                    if(Y_Pos >default_frame_Y)
                    {
                        Y_Pos=(Y_Pos-default_frame_Y)+146;
                    }

                    tableView.frame= CGRectMake(cell.frame.origin.x, 0, self.view.frame.size.width,self.view.frame.size.height - 146);
                    [self resetTableViewFrame];

                }
                else
                {
                    if(Y_Pos >default_frame_Y)
                    {
                        Y_Pos=(Y_Pos-default_frame_Y)+46;
                    }
                    
                    tableView.frame = CGRectMake(cell.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
                }
                    [self.tableView setContentOffset:CGPointMake(0, Y_Pos) animated:YES];
                return;
            }
			
			
			
			//Fix for keyboard movement for header section. 
			if ( !self.editDetailObject.isInEditDetail )
			{
				UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
				if ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
				{
                    // defect krishna : 007310
					if(appDelegate.sfmPageController.conflictExists)
						tableView.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height - boundRect.size.width - 100);
					else
						tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height) - boundRect.size.width);
				}
				else
				{
					if(appDelegate.sfmPageController.conflictExists)
						tableView.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height - boundRect.size.width - 100);
					else
						tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height) - boundRect.size.width);
					
				}
				
				if (cell != nil)
				{
					[self.tableView scrollRectToVisible:cell.frame animated:YES];
					
				}
			}
			//Shrinivas
			//Fix for keyboard movement for details section. //Defect Fix :- 7382
			else if (self.currentEditRow != nil && self.selectedIndexPathForEdit != nil)
			{
				
				if (cell != nil)
				{
					CGFloat Y_Pos = 0;
                    if(appDelegate.sfmPageController.conflictExists)
                    {
                        Y_Pos = self.editDetailObject.currentEditRow.row * 42 + (cell.frame.origin.y + self.editDetailObject.currentEditRow.row);
                    }
                    else
                    {
                        Y_Pos = self.editDetailObject.currentEditRow.row * 40 + (cell.frame.origin.y + self.editDetailObject.currentEditRow.row);
                    }
					
					[self.tableView setContentOffset:CGPointMake(0, Y_Pos) animated:YES];
					
				}
			}
		}
		//Defect Fix :- 7382
		else if ([[notification name] isEqualToString:UIKeyboardWillHideNotification])
		{
			//Defect Fix :- 7382
			if (!self.editDetailObject.isInEditDetail)
			{
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
                NSDictionary * info = [notification userInfo];
                NSValue * keyBounds = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
                
                CGRect boundRect;
                [keyBounds getValue:&boundRect];

                if(boundRect.origin.x >700 || boundRect.origin.x <0 )
                {
                    [self  resetTableViewFrame];
                }
				
				if (self.editDetailObject.lookupPopover)
				{
					if (UIDeviceOrientationIsLandscape(interfaceOrientation))
					{
						[self.editDetailObject.lookupPopover setPopoverContentSize:CGSizeMake(320, self.tableView.frame.size.height) animated:YES];
					}
					else
					{
						[self.editDetailObject.lookupPopover setPopoverContentSize:CGSizeMake(320, self.tableView.frame.size.height) animated:YES];
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
            else
            {
                [self resetTableViewFrame];
            }
            
		}

	}
	@catch (NSException *exception) {
		SMLog(kLogLevelVerbose,@"%@", exception.name);
	}
		
}
- (void) resetTableViewFrame
{
	tableView.frame = CGRectMake(0, 0, 0, 0);
    
    if (appDelegate.sfmPageController.conflictExists)
    {
        tableView.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height);
    }
    else
    {
        tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }

}
//KRI
//Radha :- Debrief :- 19 june '13
//Radha :- Implementation  for  Required Field alert in Debrief UI 
- (void) showCurrentRowForMandatoryFields:(NSDictionary *)details isLine:(BOOL)IsLine
{
	NSInteger row = [[details objectForKey:ROW] integerValue];
	
	NSInteger currentRow = [[details objectForKey:CURRENTROW] integerValue];
	
	NSInteger currentSection = [[details objectForKey:CURRENTSECTION] integerValue];
	
	NSIndexPath * indexpath = [NSIndexPath indexPathForRow:currentRow inSection:0];
		
	[self didSelectRow:row ForSection:currentSection];
	   
	//Defect Fix 7477
    NSIndexPath * rowIndexpath = [NSIndexPath indexPathForRow:row inSection:currentSection];
	
    
    [appDelegate.sfmPageController.rootView highlightSelectRowWithIndexpath:rowIndexpath];
	
	if (currentSection == 1)
	{
			[self populateMandatoryRow:row indexpath:indexpath];
		
		UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexpath];
		self.selectedIndexPathForEdit = indexpath;
		//Radha Defect Fix 7446
		currentRowIndex = row;
		[self showEditViewOfLineInView:cell.contentView forIndexPath:indexpath forEditMode:YES];

		
		[self.tableView reloadData];
	}
}


#pragma mark END

#pragma mark -
#pragma mark - SHOW CHILD VIEW PROCESS
- (SFMChildView *) allocChildLinkedViewProcess
{
    if(self.SFMChildTableview == nil) {
        
        SFMChildView * object  = [[SFMChildView alloc] initWithNibName:@"SFMChildView" bundle:nil];
        self.SFMChildTableview = object;
		
        self.SFMChildTableview.childViewDelegate = self;
        [object release];
    }
    return self.SFMChildTableview; // Damodar - Win14 - MemMgt : Not sure about the usecase : TODO-Discuss with developer
}

- (void) hideChildLinkedViewProcess
{
    self.selectedIndexPathForchildView = nil;
    [self.SFMChildTableview.view removeFromSuperview];
}

- (IBAction) closeSFMChildViewProcess:(id)sender
{
	if (self.selectedIndexPathForchildView != nil)
	{
		[self hideChildLinkedViewProcess];
	}
	[self.tableView reloadData];
}


- (IBAction) showChildLinkedProcess:(id)sender
{
	SWitchViewButton * button = (SWitchViewButton *)sender;
	
	NSIndexPath * indexpath = button.indexPath;
    
	self.selectedIndexPathForchildView = nil;
	[self.SFMChildTableview.view removeFromSuperview];
	
	self.selectedIndexPathForEdit = nil;
	[self.editDetailObject.view removeFromSuperview];
	// Defect Fix 007391
	[self.tableView reloadData];
	
	if(self.selectedIndexPathForchildView != nil && indexpath.section == self.selectedIndexPathForchildView.section && indexpath.row == self.selectedIndexPathForchildView.row )
	{
		[self hideChildLinkedViewProcess];
		[self.tableView reloadData];
		return;
        
	}
	
	if(self.selectedIndexPathForEdit != nil && indexpath.section == self.selectedIndexPathForEdit.section && indexpath.row == self.selectedIndexPathForEdit.row) {
        
        [self hideEditViewOfLine];
    }
	 if (self.selectedIndexPathForEdit != nil)
	{
		[self hideEditViewOfLine];
	}
	
	self.selectedIndexPathForchildView = indexpath;
    

    [self showChildViewProcessTable:nil indexpath:indexpath];
	[self.tableView reloadData];
}


- (void) showChildViewProcessTable:(UIView *)parentView indexpath:(NSIndexPath *)_indexpath
{
	NSInteger index;
    NSInteger section = _indexpath.section;
    if (isDefault)
        index = section;
    else
        index = selectedRow;
	
	NSMutableArray * details = [appDelegate.SFMPage objectForKey:@"details"];
    NSMutableDictionary * detail = [details objectAtIndex:index];
	NSString * detailObjectName = [detail objectForKey:gDETAIL_OBJECT_NAME];
    NSString * layout_id = [detail objectForKey:gDETAILS_LAYOUT_ID];
    NSMutableArray * detail_Values_id = [detail objectForKey:gDETAIL_VALUES_RECORD_ID];
    NSString * local_id = [detail_Values_id objectAtIndex:(_indexpath.row)-1];
    
    NSArray * linkedProcess = [_child_sfm_process_node objectForKey:layout_id];
    
    
    
	self.SFMChildTableview = nil;
	
	self.SFMChildTableview = [self allocChildLinkedViewProcess];
    
    self.SFMChildTableview.linkedProcess = linkedProcess;
	self.SFMChildTableview.detailObjectname = detailObjectName;
	self.SFMChildTableview.record_id = local_id;
	self.SFMChildTableview.selectedIndexPath  = _indexpath;
    
	self.SFMChildTableview.childTableview.hidden = NO;
    
	parentView.clipsToBounds = YES;
    self.tableView.clipsToBounds = YES;
	
	NSInteger incrementHeight = [self.SFMChildTableview getHeightForChildLinkedProcess];
	
	
	CGRect viewFrame = self.SFMChildTableview.view.frame;
    
	viewFrame.origin.y =  40;
    viewFrame.size.height =  incrementHeight; //[self.SFMChildTableview getHeightForChildLinkedProcess];
//    viewFrame.size.width = parentView.frame.size.width;
	viewFrame.size.width = WIDTH;
	
    
	
	
	CGRect frame = parentView.frame;
    frame.origin.x = 0;
	frame.origin.y = 0; // REmove later
	frame.size.height = frame.size.height; //+ incrementHeight;
	parentView.frame = frame;
	
    //8483
    if (![Utility notIOS7]) {
        viewFrame.origin.x = 40;
    }
    self.SFMChildTableview.view.frame = viewFrame;
	self.SFMChildTableview.childTableview.frame = CGRectMake(0, 0, WIDTH, self.SFMChildTableview.view.frame.size.height);
    
    
    self.SFMChildTableview.view.clipsToBounds=YES;
    [parentView addSubview:self.SFMChildTableview.view];

    [self.SFMChildTableview.childTableview reloadData];
}

//Delagte Method to show child process when click on button;
- (void) showSFMPageForChildLinkedProcessWithProcessId:(NSString *)processId record_id:(NSString *)recordId  detailObjectName:(NSString *)detailObjectName selectedIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.SFMChildTableview != nil)
    {
        [self hideChildLinkedViewProcess];
        [self.tableView reloadData];
    }
	
	[self hideEditViewOfLine];
    
   
	if([[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"VIEWRECORD"])
    {
        [self pushtViewProcessToStack:appDelegate.sfmPageController.processId record_id:appDelegate.sfmPageController.recordId];
    }
    
    [self invokeChildSfMForProcess_id:processId records_id:recordId ChildobjectName:detailObjectName selectedIndexPath:indexPath];

    
}
#pragma END


-(void)invokeChildSfMForProcess_id:(NSString *)child_process_id records_id:(NSString *)child_record_id_ ChildobjectName:(NSString *)child_obj_name selectedIndexPath:(NSIndexPath *)indexPath
{
    SfmChildSelectedIndexPath = nil;
    sfmChildSelectedRecordId = nil;
    s2t_recordId = nil;
    business_rules_success = TRUE;
    //check all require fields are filled
    NSString * current_processType = [appDelegate.SFMPage objectForKey:gPROCESSTYPE];
    
    NSString * process_type = [appDelegate.databaseInterface getprocessTypeForProcessId:child_process_id];
    if(![[appDelegate.SFMPage objectForKey:gPROCESSTYPE] isEqualToString:@"VIEWRECORD"] )
    {
        BOOL proceedSave = [self checkForEmptyRequireFields];
        if(proceedSave)
        {
            SfmChildSelectedIndexPath = indexPath;
            
            NSMutableArray  *keys_event = nil, *objects_event = nil;
            keys_event = [NSMutableArray arrayWithObjects:SFW_ACTION_ID,SFW_ACTION_DESCRIPTION,SFW_EXPRESSION_ID,SFW_PROCESS_ID,SFW_ACTION_TYPE ,SFW_WIZARD_ID,SFW_ENABLE_ACTION_BUTTON,CHILD_SFM,nil];// Dam - Win14 changes
           
            objects_event = [NSMutableArray arrayWithObjects:@"",save,@"",@"",gBUTTON_TYPE_TDM_IPAD_ONLY ,@"",@"true",@"",nil];// Dam - Win14 changes
            
            NSMutableDictionary * dict_events_save = [NSMutableDictionary dictionaryWithObjects:objects_event forKeys:keys_event];
            [self continuedOfflineActions:dict_events_save];//Shravya-8639
        }
        else
        {
            return;
        }
    }
    
    NSString * child_record_id = nil;
    
    if([child_record_id_ length] != 0)
    {
        child_record_id = child_record_id_;
    }
    else
    {
        child_record_id = sfmChildSelectedRecordId;
    }
    if([child_record_id isEqualToString:sfmChildSelectedRecordId])
    {
        SMLog(kLogLevelVerbose,@"Both Ids are Equal");
    }
    if(child_record_id == nil || [child_record_id length] == 0 || !business_rules_success)
    {
        [self reloadCurrentProcess:current_processType];
        return;
    }
    
    if([process_type isEqualToString:@"EDIT"] || [process_type isEqualToString:@"SOURCETOTARGETONLYCHILDROWS"])
    {
        
        NSMutableDictionary * page_layoutInfo = [appDelegate.databaseInterface  queryProcessInfo:child_process_id object_name:@""];
        
        NSMutableDictionary * _header =  [page_layoutInfo objectForKey:@"header"];
        
        NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];
        
        NSString * layout_id = [_header objectForKey:gHEADER_HEADER_LAYOUT_ID];
        
        NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGET process_id:child_process_id layoutId:layout_id objectName:headerObjName];
        // NSString * source_parent_object_name = [process_components objectForKey:SOURCE_OBJECT_NAME];
        NSString * expression_id = [process_components objectForKey:EXPRESSION_ID];
        
        BOOL Entry_criteria = [appDelegate.databaseInterface EntryCriteriaForRecordFortableName:headerObjName record_id:child_record_id expression:expression_id];
        if(!Entry_criteria)
        {
            // 8303 - Vipindas Sep 4 2013
            
            // Load custom error message if exists
            NSString * message = [appDelegate.dataBase expressionErrorMessageById:expression_id];
            
            if (! [Util isValidString:message] )
            {
                message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_swich_process];
            }
            
            //NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_swich_process];
            NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
            NSString * cancel_ = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE];
            
            UIAlertView * enty_criteris = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel_ otherButtonTitles:nil, nil];
            [enty_criteris show];
            [enty_criteris release];
            [self reloadCurrentProcess:current_processType];
        }
        else
        {
                
            processInfo * pinfo =  [appDelegate getViewProcessForObject:headerObjName record_id:child_record_id processId:@"" isswitchProcess:FALSE];
            NSString *  dest_process_id = pinfo.process_id;
            
            
            appDelegate.sfmPageController.sourceProcessId = dest_process_id;
            appDelegate.sfmPageController.sourceRecordId =  child_record_id;
            
            appDelegate.sfmPageController.processId = child_process_id;
            appDelegate.sfmPageController.recordId  = child_record_id;
            
            self.currentRecordId  = child_record_id;//shr-retain 008595
            currentProcessId = child_process_id;
            //check For view process - dont require
            [self fillSFMdictForOfflineforProcess:child_process_id forRecord:child_record_id];
            [self didReceivePageLayoutOffline];
        }
    }
          
    else if([process_type isEqualToString:@"SOURCETOTARGET"] )
    {
        
        //check out the record any child or parent  local_id
        
        NSMutableDictionary * page_layoutInfo = [appDelegate.databaseInterface  queryProcessInfo:child_process_id object_name:@""];
        
        NSMutableDictionary * _header =  [page_layoutInfo objectForKey:@"header"];
        
        NSString * headerObjName = [_header objectForKey:gHEADER_OBJECT_NAME];
        
        NSString * layout_id = [_header objectForKey:gHEADER_HEADER_LAYOUT_ID];
        
        NSMutableDictionary * process_components = [appDelegate.databaseInterface getProcessComponentsForComponentType:TARGET process_id:child_process_id layoutId:layout_id objectName:headerObjName];
        NSString * source_parent_object_name = [process_components objectForKey:SOURCE_OBJECT_NAME];
        NSString * expression_id = [process_components objectForKey:EXPRESSION_ID];
        
        BOOL Entry_criteria = [appDelegate.databaseInterface EntryCriteriaForRecordFortableName:source_parent_object_name record_id:child_record_id expression:expression_id];
        
        
        if(!Entry_criteria)
        {
            // 8303 - Vipindas Sep 4 2013
            
            // Load custom error message if exists
            NSString * message = [appDelegate.dataBase expressionErrorMessageById:expression_id];
            
            if (! [Util isValidString:message] )
            {
                message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_swich_process];
            }
            
            //NSString * message = [appDelegate.wsInterface.tagsDictionary objectForKey:sfm_swich_process];
            NSString * title = [appDelegate.wsInterface.tagsDictionary objectForKey:alert_ipad_error];
            NSString * cancel_ = [appDelegate.wsInterface.tagsDictionary objectForKey:CANCEL_BUTTON_TITLE];
            
            UIAlertView * enty_criteris = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel_ otherButtonTitles:nil, nil];
            [enty_criteris show];
            [enty_criteris release];
            [self reloadCurrentProcess:current_processType];
        }
        else
        {
            // Dam - Win14 - MemMgt - revoked to fix crash
            if ([source_parent_object_name length] == 0)
                source_parent_object_name = headerObjName;
          
                appDelegate.sfmPageController.sourceProcessId = @"";
                appDelegate.sfmPageController.sourceRecordId = child_record_id;
                
                appDelegate.sfmPageController.processId = child_process_id;
                appDelegate.sfmPageController.recordId  = nil;
                
                self.currentRecordId  = nil;//shr-retain 008595
                currentProcessId = child_process_id;
                //check For view process  - dont require
                [self fillSFMdictForOfflineforProcess:child_process_id forRecord:currentRecordId];
                [self didReceivePageLayoutOffline];
        }
    }

}
-(void)reloadCurrentProcess:(NSString *)processType
{
    if([processType isEqualToString:@"SOURCETOTARGET"])
    {
        if(self.s2t_recordId != nil)
        {
            NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
            NSString * headerObjName = [hdr_object objectForKey:gHEADER_OBJECT_NAME];
            
            processInfo * pinfo =  [appDelegate getViewProcessForObject:headerObjName record_id:self.s2t_recordId processId:@"" isswitchProcess:FALSE];
            NSString * process_id = pinfo.process_id;

            [self fillSFMdictForOfflineforProcess:process_id forRecord:s2t_recordId];
            [self didReceivePageLayoutOffline];
        }
    }
    else 
    {
        [self fillSFMdictForOfflineforProcess:appDelegate.sfmPageController.processId forRecord:appDelegate.sfmPageController.recordId];
        [self didReceivePageLayoutOffline];
    }
}

- (NSDictionary *)getCurrentSelectedIndex {
    
    NSIndexPath *selectedRootIndexPath = [appDelegate.sfmPageController.rootView getSelectedIndexPath];
     NSInteger isHeader = -1, detailRow = 0, detailSection = 0;
    if (selectedSection == SHOW_HEADER_ROW || selectedSection == SHOWALL_HEADERS ) {
            isHeader = 1;
    }
    else {
        isHeader = 2;
        if (selectedSection == SHOWALL_LINES ) {
            detailSection = currentEditRow.section;
            if (currentEditRow.row > 0) {
                detailRow = currentEditRow.row - 1;
            }
        }
        else if (selectedSection == SHOW_LINES_ROW){
            detailSection = selectedRootIndexPath.row;
            if (currentEditRow.row > 0) {
                detailRow = currentEditRow.row - 1;
            }
        }
    }
    if(isHeader == 1) {
        SMLog(kLogLevelVerbose,@"HEADER");
    }
    else {
        SMLog(kLogLevelVerbose,@"DETAIL  %d  %d",detailSection,detailRow);
    }

    NSIndexPath *finalIndexPath = [NSIndexPath indexPathForRow:detailRow inSection:detailSection];
    NSDictionary *someDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",isHeader],@"isHeader",finalIndexPath,@"detail", nil];

    return someDict;
}

-(BOOL)checkForEmptyRequireFields
{
    NSString * warning = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_WARNING];
    NSString * invalidEmail = [appDelegate.wsInterface.tagsDictionary objectForKey:SFM_TEXT_INVALID_EMAIL];
    NSString * alert_ok = [appDelegate.wsInterface.tagsDictionary objectForKey:ALERT_ERROR_OK];
    
    NSDictionary *hdr_object = [appDelegate.SFMPage objectForKey:@"header"];
    
    NSArray * header_sections = [hdr_object objectForKey:@"hdr_Sections"];

    //Radha 21 june '13
    //Radha :- Implementation  for  Required Field alert in Debrief UI
    NSInteger headerRow = -1;
    
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
            NSString * key = [section_field objectForKey:gFIELD_VALUE_KEY];
            NSString * dataType = [section_field objectForKey:gFIELD_DATA_TYPE];
            if(key == nil)
            {
                key = @"";
            }
            
            BOOL required = [[section_field objectForKey:gFIELD_REQUIRED] boolValue];
            if(required)
            {
                if([value length] == 0 )
                {
                    //Radha :- Implementation  for  Required Field alert in Debrief UI
                    if (headerRow < 0 && !error)
                    {
                        headerRow = i;
                    }
                    error = TRUE;
                    //sahana TEMP change
                    break;
                }
            }
            if ([dataType isEqualToString:@"email"] )  //Shrinivas Fix for Email Validation 03/04/2012
            {
                /*
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
                 }*/
                
            }
            // Fix for the defect 4547: Url validation
            /*else if ([dataType isEqualToString:@"url"] )
             {
             BOOL isValidUrl = [self isValidUrl:value];
             if ((isValidUrl == NO) && ([value length] > 0))
             {
             [self showAlertForInvalidUrl];
             [self enableSFMUI];
             return;
             
             }
             }*/
            
        }
    }
    if(error == TRUE)
    {
        //Radha :- Implementation  for  Required Field alert in Debrief UI
        NSDictionary * details = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", headerRow], ROW,
                                  [NSString stringWithFormat:@"%d", 0], CURRENTSECTION,  nil];
        
        mandatoryRowDetails = [[NSDictionary alloc] initWithDictionary:details];
        [self requireFieldWarning];
        requiredFieldCheck = TRUE;
        [self enableSFMUI];
        return FALSE;
    }
    
    //child records
    BOOL line_error = FALSE;
    
    //Radha :- Debrief :- 19 june '13
    //Radha :- Implementation  for  Required Field alert in Debrief UI
    NSInteger row = -1;
    NSInteger currentRow = -1;
    
    
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
                                //Radha :- Implementation  for  Required Field alert in Debrief UI
                                if ((row < 0 || currentRow < 0) && !line_error)
                                {
                                    row = i;
                                    currentRow = j+1;
                                }
                                
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
                            return FALSE;
                        }
                        
                    }
                    // Fix for the defect 4547: Url validation
                    /*else if ([detailDataType isEqualToString:@"url"])
                     {
                     BOOL isValidUrl = [self isValidUrl:deatil_value];
                     if ((isValidUrl == NO) && ([deatil_value length] > 0))
                     {
                     [self showAlertForInvalidUrl];
                     [self enableSFMUI];
                     return;
                     
                     }
                     }*/
                    
                }
            }
        }
    }
    
    if(line_error)
    {
        //Radha :- Debrief :- 19 june '13
        //Radha :- Implementation  for  Required Field alert in Debrief UI
        NSDictionary * details = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d", row], ROW,
                                  [NSString stringWithFormat:@"%d", currentRow], CURRENTROW, [NSString stringWithFormat:@"%d", 1], CURRENTSECTION,  nil];
        
        mandatoryRowDetails = [[NSDictionary alloc] initWithDictionary:details];
        [self requireFieldWarning];
        requiredFieldCheck = TRUE;
        [self enableSFMUI];
        return FALSE;
    }
    
    return TRUE;
}

-(void)getRecordIdForChildSfmForSection:(NSInteger)section row:(NSInteger)row recordId:(NSString *)localRecordId  actiondict:(NSDictionary *)actionDict
{
    //sahana child sfm
    if(![self isInvokedFromChildSfm:actionDict])
    {
        return;
    }
    if((section == [self getSection:SfmChildSelectedIndexPath]) && (row == [self getRow:SfmChildSelectedIndexPath]))
    {
        self.sfmChildSelectedRecordId = localRecordId ;
    }
    
}

-(NSInteger)getSection:(NSIndexPath *)_indexpath
{
    //sahana child sfm
    NSInteger index;
    NSInteger section = _indexpath.section;
    if (isDefault)
        index = section;
    else
        index = selectedRow;
    return index;
}

-(NSInteger)getRow:(NSIndexPath *)_indexpath
{
    return [_indexpath row]-1;
}
-(BOOL)isInvokedFromChildSfm:(NSDictionary *)actionDict
{
    if([[actionDict allKeys] containsObject:CHILD_SFM])
    {
        
        return TRUE;
    }
    return FALSE;
}

-(void)SaveCreatedRecordInfoIntoPlistForRecordId:(NSString *)recordId objectName:(NSString *)ObjectName
{
    self.s2t_recordId = recordId;
    
    NSDate * date = [NSDate date];
    NSDateFormatter * frm = [[[NSDateFormatter alloc] init] autorelease];
    [frm setDateFormat:DATETIMEFORMAT];
    NSString * date_str = [frm stringFromDate:date];
    
    NSString * object_label = [appDelegate.databaseInterface getObjectLabel:SFOBJECT objectApi_name:ObjectName];
    
    NSMutableDictionary * created_object_info = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    [created_object_info setObject:ObjectName forKey:OBJECT_NAME];
    NSString * process_id = @"";
    
    processInfo * pinfo =  [appDelegate getViewProcessForObject:ObjectName record_id:recordId processId:@"" isswitchProcess:FALSE];    
    process_id = pinfo.process_id;
    
    [created_object_info setObject:process_id forKey:gPROCESS_ID];
    [created_object_info setObject:date_str forKey:gDATE_TODAY];
    [created_object_info setObject:recordId forKey:RESULTID];
    //Need to changed when the proper incremental data sync happens.
    [created_object_info setObject:@"" forKey:NAME_FIELD];
    [created_object_info setObject:object_label forKey:OBJECT_LABEL];
    [appDelegate.wsInterface saveDictionaryToPList:created_object_info];
}

//Attachment Code begins

-(void)createAttachment:(int )indexRow
{
    //9270
    BOOL isAttachmentFeatureSupported = [appDelegate doesServerSupportsModule:kMinPkgForAttachment];

    if (! isAttachmentFeatureSupported)
    {
        // No Server version is not supporting Attachment feature.
        //NSLog(@" Detail : No. Server version is not supporting Attachment feature. ");
        return;
    }

    
    /*if(attachmentview.view == nil)
    {
        self.attachmentview = [[AttachmentViewController alloc] init];
        self.attachmentview.indexpath = indexPath;
    }
    [self.view addSubview:attachmentview.view];*/
//       =[[DocumentViewController alloc]init];
    if(!isInViewMode)
        NSLog(@"View Mode");
    else
        NSLog(@"Edit Mode");
    
    if(indexRow == 0)
    {
        if(imageCollectionView.view == nil)
        {
            self.imageCollectionView = [[ImageCollectionView alloc] init];
        }
        self.imageCollectionView.imageViewDelegate = self;
        self.imageCollectionView.isViewMode = !isInViewMode;
        self.imageCollectionView.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        CGRect collectionViewRect = self.imageCollectionView.CollectionView.frame;
        collectionViewRect.size.width =self.imageCollectionView.view.frame.size.width;
        collectionViewRect.size.height = self.imageCollectionView.view.frame.size.height;
        self.imageCollectionView.CollectionView.frame = collectionViewRect;
	//defect #9224
      //  self.imageCollectionView.view.backgroundColor=[UIColor clearColor];

        [self.imageCollectionView.view removeFromSuperview];
        [self.view addSubview:imageCollectionView.view];
        [self.documentView.view removeFromSuperview];

    }
    else if (indexRow ==1 )
    {
        if(documentView== nil)
        {
            self.documentView=[[DocumentViewController alloc]initWithNibName:@"DocumentViewController" bundle:nil];
             self.documentView.isViewProcess =!isInViewMode;
            documentView.delegate = self;
        }
        self.documentView.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        CGRect viewFrame = self.documentView.mainTableView.frame;
        viewFrame.size.width = self.documentView.view.frame.size.width;
        viewFrame.size.height = 610;
        viewFrame.origin.x = 13;
        self.documentView.mainTableView.frame = viewFrame;
        [self.documentView.view removeFromSuperview];
        self.documentView.isViewProcess =!isInViewMode;
        [self.view addSubview:self.documentView.view];
        [self.imageCollectionView.view removeFromSuperview];
        
    }
    
}
-(void)removeAttachmentView
{
    /*if(attachmentview.view != nil)
    {
        [attachmentview.view removeFromSuperview];
        attachmentview.view = nil;
    }*/
    if(imageCollectionView!= nil)
    {
        [imageCollectionView cleanUpBeforeUnload];
        [self.imageCollectionView.view removeFromSuperview];
        self.imageCollectionView = nil;
    }
    if(documentView != nil)
    {   [imageCollectionView cleanUpBeforeUnload];
        [self.documentView.view removeFromSuperview];
        self.documentView =  nil;
    }
}

-(void) displayAttachment:(NSString *)attachmentId fielName:(NSString *)fileName
{
    AttachmentWebView * attachmentView = [[AttachmentWebView alloc] initWithNibName:@"AttachmentWebView" bundle:[NSBundle mainBundle]];

    attachmentView.attachmentLocalId = attachmentId;
    attachmentView.attachmentFileName = fileName;
    attachmentView.isInViewMode = !isInViewMode;
     //fix for defect #9219
    attachmentView.webviewdelgate = self;
    attachmentView.modalPresentationStyle = UIModalPresentationFullScreen;
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:attachmentView] autorelease];
	//navController.delegate = attachmentView;
	navController.modalPresentationStyle = UIModalPresentationFullScreen;
	navController.navigationBar.hidden = NO;
    [(SFMPageController *)delegate presentViewController:navController animated:YES completion:nil];
    [attachmentView release];
}

-(void)ButtonClick:(int)selectedIndex{
   
    if(selectedIndex == IMPORT_GALLERY)
    {
        [self startCameraControllerFromViewControllerisImageFromCamera:NO isVideoMode:NO];
    }
    else if (selectedIndex == CAPTURE_IMAGES)
    {
        [self startCameraControllerFromViewControllerisImageFromCamera:YES isVideoMode:NO];
    }
    else if(selectedIndex == CAPTURE_VIDEOS)
    {
        [self startCameraControllerFromViewControllerisImageFromCamera:YES isVideoMode:YES];
    }

}
-(void)dismissImageView
{
    [cameraViewController dismissViewControllerAnimated:YES completion:nil];
    if(_popoverImageViewController)
    {
        [_popoverImageViewController dismissPopoverAnimated:YES];
    }
}
//-(void)actionStartVideoRecord {
//    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
//        return;
//    }
//    UIImagePickerController* imagePicker = [[[UIImagePickerController alloc] init] autorelease];
//    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
//    imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
//    imagePicker.delegate = self;
//    imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
//
//    [self presentModalViewController:imagePicker animated:YES];
//}

- (BOOL) startCameraControllerFromViewControllerisImageFromCamera:(BOOL)isCameraCapture isVideoMode:(BOOL)isVideoMode {
    
    cameraViewController = [[SVMXImagePickerController alloc] init];
    /**< Check isSourceTypeAvailable for possible sources (camera and photolibrary) */
    
    if (([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] == NO) || ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary] == NO))
        return NO;
    
    /**< if editing is required*/
    
    cameraViewController.allowsEditing = NO;
    cameraViewController.delegate = imageCollectionView;
    
    cameraViewController.videoQuality=UIImagePickerControllerQualityTypeMedium;
    if(isCameraCapture) {
        
        // still camera image,
        cameraViewController.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraViewController.videoMaximumDuration=30;
        // if video is not needed then remove below line
        cameraViewController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if(isVideoMode)
        {
           
            cameraViewController.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;
        }
        else
        {
            cameraViewController.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;

        }
        
        cameraViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [(SFMPageController * )delegate presentViewController:cameraViewController animated:YES completion:nil];
    }
    else {
        //capture image from gallery
        cameraViewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraViewController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];

        UIPopoverController *popOver = [[UIPopoverController alloc] initWithContentViewController:cameraViewController];
        popOver.delegate = self;
        self.popoverImageViewController = popOver;
        
        [self.popoverImageViewController presentPopoverFromRect:CGRectMake(20, 54,400, 400) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];

    }
    
    return YES;
    
}
-(void) displayAttachment:(NSString *)attachmentId fielName:(NSString *)fileName category:(NSString *)category
{
    AttachmentWebView * attachmentView = [[AttachmentWebView alloc] initWithNibName:@"AttachmentWebView" bundle:[NSBundle mainBundle]];
    attachmentView.attachmentLocalId = attachmentId;
    attachmentView.attachmentFileName = fileName;
    attachmentView.attachmentCategory = category;
    attachmentView.modalPresentationStyle = UIModalPresentationFullScreen;
    attachmentView.webviewdelgate = self;
    attachmentView.isInViewMode = !isInViewMode;
	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:attachmentView] autorelease];
	//navController.delegate = attachmentView;
	navController.modalPresentationStyle = UIModalPresentationFullScreen;
	navController.navigationBar.hidden = NO;
    [(SFMPageController *)delegate presentViewController:navController animated:YES completion:nil];
    [attachmentView release];
}

#pragma mark -
#pragma mark AttachmentwebView Delegate Methods

- (void) didDeleteAttchment:(NSString *) attachmentLocalId
{
//    [self.documentView deleteAttachment:attachmentLocalId];
    [appDelegate.attachmentDataBase updateTrailerTableWithDeletedIds:[NSArray arrayWithObject:attachmentLocalId]];
    [self.documentView refreshDocuments];
}
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

//Added for 9219
-(void)deleteLocalAttachment:(NSString *)localAttachment
{
    localAttachment = (localAttachment != nil)?localAttachment:@"";
    [AttachmentUtility  removeSelectedAttachmentFiles:[NSArray arrayWithObject:localAttachment]];
    [self.documentView refreshDocuments];
}
@end
