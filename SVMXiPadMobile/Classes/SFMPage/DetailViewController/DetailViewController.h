//
//  DetailViewController.h
//  project
//
//  Created by Developer on 26/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "selectProcess.h"
#import "WSInterface.h"
#import "BotSpinnerTextField.h"
#import "BOTGlobals.h"
#import "ActionMenu.h"
#import "BOTControlDelegate.h"
#import "MultiAddLookupView.h"
#import "LabelPOContentView.h"
#import "SignatureViewController.h"
#import "offlineGlobles.h"


@protocol DetailViewControllerDelegate;
@protocol SummaryViewControllerDelegate;
@protocol ChatterDelegate;

@class iServiceAppDelegate;
@class RootViewController;
@class TimerClass;

NSInteger multiAddFlag;
NSString * objectLabel;

@interface DetailViewController : UIViewController
<UIPopoverControllerDelegate,
UISplitViewControllerDelegate,
UITableViewDelegate,
UITableViewDataSource, 
UIScrollViewDelegate,
RootViewControllerDelegate,
selectProcessDelegate,
WSInterfaceDelegate,
ActionMenuDelegate,
ControlDelegate,
UINavigationControllerDelegate,
UITextFieldDelegate,
MultiAddLookupViewDelegate,
WSInterFaceDelegateForDetailView,
SignatureDelegate,
SummaryViewControllerDelegate,
ChatterDelegate>
{
    id <DetailViewControllerDelegate> delegate;

    IBOutlet UITableView * tableView;
    iServiceAppDelegate * appDelegate;
    RootViewController * rootViewController;
    
    BOOL isDefault;
    NSInteger selectedSection;
    NSInteger selectedRow;
    
    UILabel * lbl1, *lbl2;
    UITextField *txtfld, *txtfld1;
    IBOutlet UIActivityIndicatorView *activity;
    //sahana
    UIBarButtonItem * rootViewBarButton;
    
    UIBarButtonItem * backBtn;
    UIBarButtonItem * actionBtn;
    selectProcess * sp;
    NSString * currentProcessId, * currentRecordId;
    NSString * objectAPIName;
    
    BOOL isInViewMode;
    //sahana
   
    UIBarButtonItem * barButtonItem_detail;
    BOOL line;
    BOOL header;
    //sahana 16th may
   
    //sahana 17th 
    NSArray * Disclosure_Fields;
    NSArray * Disclosure_Details;
    DetailViewController * detailViewObject;
    NSDictionary * Disclosure_dict;
    BOOL isInEditDetail;
    BOOL editable;
    
    IBOutlet UIWebView *webView;
    ActionMenu * actionMenu;
    
    NSString * detailTitle;
    //sahana -  for keybord notification
    CGRect originalRect;
    BOOL isKeyboardShowing;
    NSIndexPath * currentEditRow;

    UIPopoverController * masterPopover;

    NSInteger count;
    IBOutlet UIActivityIndicatorView *indicatorForAddRow;
    
    NSIndexPath * selectedIndexPath;
    NSInteger selectedRowForDetailEdit;

    // Samman - Lookup Popover repositioning
    UIPopoverController * lookupPopover;
    
    //Radha recordId
    NSDictionary * lookupData;
    NSMutableArray * multi_add_info;
    //Radha - Multi Lookup popover
    UIPopoverController * multiLookupPopover;
    UITextField * text;
    NSString * objectName;
   // NSInteger _section;
    NSMutableDictionary * multiLookArray;
    BOOL didMultiAddAccessoryTapped;
    // sfm label popover
    UIPopoverController * label_popOver;
    LabelPOContentView * label_popOver_content;
    BOOL flag;
    NSString * multi_add_seach_object;
    NSString * multi_add_search;
    NSString * mutlti_add_config;
    NSString * mutlti_add_label;
    NSString * save_response_message;
    BOOL table_view_moved;
    
    // Summary Report
    NSDictionary * ExpenseDictionary;
    NSMutableArray * Parts, * Expenses, * Labor, * reportEssentials;
    
    BOOL didGetParts, didGetExpenses, didGetLabor, didGetReportEssentials;
    
    BOOL flag1;
    NSString * value1, *value2;
    
    //RADHA SLA Clocks
    NSString *  resolution, * restoration;
    TimerClass * restorationTimer, * resolutionTimer;
    
    NSString * editTitle;
    
    BOOL sourceToTarget, isEditingDetail;
    BOOL requiredFieldCheck;
    
    NSString * cancel, * save, * quick_save, * summary, * troubleShooting, * chatter;
    
    BOOL clickedBack;
    
    SignatureViewController * sign;
    NSData *signimagedata;
    IBOutlet UIImageView *signature;
    BOOL isShowingSignatureCapture;
    
    // Switch View Layouts
    BOOL didSelectViewLayout;
    
    BOOL isActive;
    
    NSDictionary * mLookupDictionary;
    
    NSMutableDictionary * LabourValuesDictionary;
    NSMutableArray * linePriceItems;
    BOOL groupCostsPresent;
    NSString *rate;
    BOOL calculateLaborPrice;
    BOOL settingsPresent;
    
    BOOL isShowingSaveError;

    BOOL didWeLoseInternetConnection;
    UIAlertView * alert;
    
    BOOL didRunOperation;
    
    SummaryViewController * Summary;
}

@property (nonatomic, retain) id <DetailViewControllerDelegate> delegate, calendarDelegate;

@property(nonatomic ) BOOL table_view_moved;
@property (nonatomic,retain) NSString * save_response_message;
@property (nonatomic , retain)  NSMutableArray * multi_add_info;
@property (nonatomic , retain)  NSString * mutlti_add_label;
@property (nonatomic ,retain) NSString * mutlti_add_config;
@property (nonatomic , retain)  NSString * multi_add_seach_object;
@property (nonatomic , retain) NSString * multi_add_search;
@property (nonatomic , retain) IBOutlet UIWebView *webView;
@property (nonatomic) BOOL flag; 
@property (nonatomic , retain) LabelPOContentView * label_popOver_content;
@property (nonatomic , retain)  UIPopoverController * label_popOver;
@property (nonatomic, retain) NSString * currentProcessId, * currentRecordId;
@property (nonatomic, retain) NSString * objectAPIName;
@property (nonatomic )  NSInteger count ;
@property (nonatomic ) CGRect originalRect;
@property (nonatomic )BOOL isKeyboardShowing;
@property (nonatomic ,retain) NSIndexPath * currentEditRow;
@property (nonatomic,retain) NSArray * Disclosure_Fields;
@property (nonatomic,retain) NSArray * Disclosure_Details;
@property (nonatomic,retain)  NSDictionary * Disclosure_dict;
@property (nonatomic ) BOOL isInEditDetail;
@property (nonatomic) BOOL line;
@property (nonatomic) BOOL header;
@property (nonatomic ,retain) UIBarButtonItem * barButtonItem_detail;
@property (nonatomic ,retain) UIBarButtonItem * rootViewBarButton;
@property (nonatomic, retain) IBOutlet UIToolbar * toolbar;
@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) IBOutlet UILabel * detailDescriptionLabel;
@property (nonatomic, retain) IBOutlet UITableView * tableView;

@property (nonatomic, retain) UILabel *lbl1, *lbl2;
@property (nonatomic, retain) UITextField *txtfld,*txtfld1;
@property (nonatomic) BOOL editable;
@property (nonatomic) BOOL isInViewMode;

@property (nonatomic, retain) NSIndexPath * selectedIndexPath;
@property (nonatomic) NSInteger selectedRowForDetailEdit;

@property (nonatomic, assign) BOOL didMultiAddAccessoryTapped;
@property (nonatomic, retain) NSString * objectLabel;
@property (nonatomic , retain) IBOutlet UIActivityIndicatorView *indicatorForAddRow;

@property (nonatomic, retain) NSString * detailTitle;
@property (nonatomic, retain) NSDictionary * mLookupDictionary;

@property (nonatomic, retain) NSMutableDictionary * LabourValuesDictionary;


- (id) getControl:(NSString *)controlType withRect:(CGRect )frame withData:(NSArray *)datasource withValue:(NSString *)value fieldType:(NSString *)fieldType labelValue:(NSString *)lableValue enabled:(BOOL)readOnly refObjName:(NSString *)refObjName referenceView:(UIView *)POView indexPath:(NSIndexPath *)indexPath required:(BOOL)required valueKeyValue:(NSString *)valueKeyValue lookUpSearchId:(NSString *)searchid overrideRelatedLookup:(NSNumber *)Override_Related_Lookup fieldLookupContext:(NSString *)Field_Lookup_Context fieldLookupQuery:(NSString *)Field_Lookup_Query;
- (UITableViewCell *) SFMViewCellForTable:(UITableView *)_tableView AtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *) SFMEditCellForTable:(UITableView *)_tableView AtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *) SFMEditDetailCellForTable:(UITableView *)_tableView AtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger) HeaderColumns;
- (NSInteger) linesColumns;
- (void) fillDictionary:(NSIndexPath *)indexPath;
- (NSDictionary *) valueForcontrol:(UIView *) control_Type;
- (void) didShrinkTable:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
// - (void) Back:(id)sender;
- (IBAction) showMaster:(id)sender;
// sahana
-(BOOL)getViewRequired:(UIView *) view;
-(BOOL)gettheChangedValue:(UIView *)view;
// - (void) addNavigationButtons;
- (void) addNavigationButtons:(NSString *)sectionTitle;
- (void) moveTableView;
- (void) setLookupData:(NSDictionary *)lookupDictionary;
// color 

- (void) startSummaryDataFetch;
- (void) showTroubleshooting;
- (void) showChatter;

// SLA Clock Methos
- (void) restorationTimeLeftFromDateTime:(NSString *)_restoration;
- (void) resolutionTimeLeftFromDateTime:(NSString *)_restoration;

//SLA Clock offline
- (void) restorationTimeLeftFromDateTimeOffline:(NSString *)_restoration;
- (void) resolutionTimeLeftFromDateTimeOffline:(NSString *)_resolution;


// DescribeObjects Methods
- (NSString *) getLabelForObject:(NSString *)objName;

// Back Button Methods
- (void) DismissModalViewController:(id)sender;
- (void) PopNavigationController:(id)sender;
-(void) requireFieldWarning;

- (NSString *) getObjectNameFromHeaderData:(NSDictionary *)dictionary forKey:(NSString *)key;
- (NSMutableString *) removeDuplicatesFromSOQL:(NSString *)soql withString:(NSString *)_query;

- (void) enableSFMUI;
- (void) disableSFMUI;

#define SHOWALL_HEADERS                     0
#define SHOW_HEADER_ROW                     1
#define SHOWALL_LINES                       2
#define SHOW_LINES_ROW                      3
#define SHOW_ALL_ADDITIONALINFO             4
#define SHOW_ADDITIONALINFO_ROW             5


#define Dvalue                              @"value"
#define DapiName                            @"apiName"
#define Dcontrol_type                       @"control_type"
#define Didtype                             @"id_type"


#define SFPROCESS                           @"SFProcess"
#define SFOBJECT                            @"SFObject"
#define SFOBJECTFIELD                       @"SFObject_Field"
#define SVMXC_LINES                         @"SVMXC__Service_Order_Line__c"
#define SVMXC_WORK_ORDER                    @"SVMXC__Service_Order__c"

#pragma mark = offline
//sahana and shrinivas 3rd November
-(void)fillSFMdictForOfflineforProcess:(NSString *) processId forRecord:(NSString *)recordId;
-(void) didReceivePageLayoutOffline;
-(void) initAllrequriredDetailsForProcessId:(NSString *)process_id recordId:(NSString *)recordId object_name:(NSString *)object_name;
@end

@protocol DetailViewControllerDelegate

@optional
- (void) Back:(id)sender;
- (void) BackOnSave;
@end
