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
#import "SFWToolBar.h"
#import "databaseIntefaceSfm.h"
#import "JSExecuter.h"
#import "PriceBookData.h"
#import "SFMEditDetailViewController.h"
#import "ImageCollectionView.h"
#import "DocumentViewController.h"
//Radha
#import "SFMChildView.h"
#import "SVMXImagePickerController.h"
#import "AttachmentWebView.h"                        //fix for defect #9219
//@class SFMEditDetailViewController;
@protocol DetailViewControllerDelegate;
@protocol SummaryViewControllerDelegate;
@protocol ChatterDelegate;
@protocol SyncButtonProtocol;


@class AppDelegate;
@class RootViewController;
@class TimerClass;
@class ManualDataSyncDetail;

NSInteger multiAddFlag;
NSString * objectLabel;

typedef enum Onclick{
    EDIT_SAVE = 0,
    EDIT_QUICKSAVE = 1,
    
}SAVE_STATUS;


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
ChatterDelegate,
SFWToolBarDelegate,RefreshSyncStatusButton,ZBarReaderDelegate,databaseInterfaceProtocol,JSExecuterDelegate, SFMEditDetailDelegate, SFMChildViewDelegate, UIAlertViewDelegate,ImageViewControllerDelegate,UIImagePickerControllerDelegate,AttachmentWebviewdelegate>  //fix for defect #9219//Radha :- Implementation  for  Required Field alert in Debrief UI
{
    SAVE_STATUS save_status;
    
    BOOL EventUpdate_Continue;
    
    id <DetailViewControllerDelegate> delegate;
    SFWToolBar * sfwToolBar;
    IBOutlet UITableView * tableView;
    AppDelegate * appDelegate;
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
    
    NSString * cancel, * save, * quick_save, * summary, * troubleShooting, * chatter,* dod_title;
    
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
	
	//Radha #3214
	NSMutableArray * LaborArray;
	
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
    UIControl *control;
    UIControl *multiControl;
    MultiAddLookupView *multiAddLookup;
    //Drill Down
    DetailViewController * parentReference;
    
    // Memory Warning Related
    BOOL didReceiveMemoryWarning;
    
    //Shrinivas
    UIButton  * statusButton;
    ZBarReaderViewController *reader;
    
    //Debrief
    NSIndexPath  *selectedIndexPathForEdit;
    UIView       *editViewOfLine;
	//Radha :- Implementation  for  Required Field alert in Debrief UI
	UIAlertView * requiredFields;
	NSDictionary * mandatoryRowDetails;
	
	//Radha Defect Fix 7446
	NSInteger currentRowIndex;
	
    /* GET_PRICE_JS-shr*/
    JSExecuter *jsExecuter;
    PriceBookData *priceBookData;
	
	//SYNC_Override
	NSString * webserviceName;
	NSString * className;
	NSString * syncType;
    //Attachment
    ImageCollectionView * imageCollectionView;
    UIImagePickerController *cameraViewController;
    
    NSMutableDictionary *sourceUpdateConfiguration;//4850

}

@property (nonatomic,retain)  ImageCollectionView * imageCollectionView;
@property (nonatomic,retain)     DocumentViewController * documentView;

@property (nonatomic, retain) NSDictionary *bizRuleResult;
@property (nonatomic) BOOL bizRuleExecutionStatus; 
// SFM OPDocs
@property (nonatomic, retain) JSExecuter *executer;

@property (nonatomic) BOOL EventUpdate_Continue;
//0:uninitialized
//1:first controller flag
//2:second controller flag
@property (nonatomic, assign) short int updateGreenButtonFlag;
 //Debrief
@property (nonatomic, retain) SFMEditDetailViewController   *editDetailObject;
@property (nonatomic, retain) DetailViewController * parentReference;

@property (nonatomic, retain) id <DetailViewControllerDelegate> delegate, calendarDelegate;
@property (nonatomic , retain) SFWToolBar * sfwToolBar;
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
@property (nonatomic, assign) BOOL showSyncUI;
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
@property (nonatomic,assign)   UIPopoverController * multiLookupPopover;

 //Debrief
@property (nonatomic,retain) NSIndexPath  *selectedIndexPathForEdit;
//Child SFM UI
@property (nonatomic,retain) SFMChildView * SFMChildTableview;
@property (nonatomic,retain) NSIndexPath *  selectedIndexPathForchildView;



@property(nonatomic,retain) JSExecuter *jsExecuter;
@property(nonatomic,retain) JSExecuter *bizRuleJSExecuter;
@property(nonatomic,retain) PriceBookData *priceBookData;
@property (nonatomic,retain) UIPopoverController *popoverImageViewController;

@property(atomic,retain)    NSMutableDictionary *sourceUpdateConfiguration;

//Sync_Overide :- Adding the new parameters to the existing method (webservice_name, class_name, synctype)
-(void)UpdateAlldeletedRecordsIntoSFTrailerTable:(NSArray *)deleted_record_array   object_name:(NSString *)object_name webserviceName:(NSString *)webservice_name className:(NSString *)class_name synctype:(NSString *)sync_type headerLocalId:(NSString *)header_localId requestData:(NSMutableDictionary *)request_data;

//Radha DefectFix - 5721 - Adding objectName parameter in the below method
//krishna CONTEXTFILTER
- (id) getControl:(NSString *)controlType withRect:(CGRect )frame withData:(NSArray *)datasource withValue:(NSString *)value fieldType:(NSString *)fieldType labelValue:(NSString *)lableValue enabled:(BOOL)readOnly refObjName:(NSString *)refObjName referenceView:(UIView *)POView indexPath:(NSIndexPath *)indexPath required:(BOOL)required valueKeyValue:(NSString *)valueKeyValue lookUpSearchId:(NSString *)searchid overrideRelatedLookup:(NSNumber *)Override_Related_Lookup fieldLookupContext:(NSString *)Field_Lookup_Context fieldLookupQuery:(NSString *)Field_Lookup_Query   dependentPicklistControllerName:(NSString *)dependPick_controllerName picklistValidFor:(NSMutableArray *)validFor picklistIsdependent:(BOOL)isdependentPicklist objectAPIName:(NSString *)object_api_name forSourceObject:(NSString *)lookupContextSourceObject;
- (UITableViewCell *) SFMViewCellForTable:(UITableView *)_tableView AtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *) SFMEditCellForTable:(UITableView *)_tableView AtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *) SFMEditDetailCellForTable:(UITableView *)_tableView AtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger) HeaderColumns;
- (NSInteger) linesColumns;
- (void) fillDictionary:(NSIndexPath *)indexPath;
- (NSDictionary *) valueForcontrol:(UIView *) control_Type;
- (void) didShrinkTable:(NSString *)animationID finished:(BOOL)finished context:(void *)context;
// - (void) Back:(id)sender;
- (IBAction) showMaster:(id)sender;//  Unused Methods
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

- (NSString *) timeDifferenceFrom:(NSString *)fromDate toDate:(NSString *)toDate;



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
//Abinash Fix
//-(NSArray *)orderingAnArray:(NSArray *)array;//  Unused Methods

//To get the status Image
//- (UIImage *) getStatusImage;
//- (void) refreshStatusImage;//  Unused Methods
-(void)pageLevelEventsForEvent:(NSString *)event_Name;
//Bar code
-(void)launchBarcodeScanner;
-(void) LaunchMultiAddPopover;
//-(void) reDrawBackground;//  Unused Methods

- (NSDictionary *)getCurrentSelectedIndex;

/* GetPrice - shr */
- (void)getPriceForCurrentContext;
- (void)updateWorkOrderWithPrice:(NSDictionary *)updatedWo;
- (NSDictionary *)getTheValueFOrKey:(NSString *)key andAliasName:(NSString *)aliasName andIndex:(NSInteger)index andArray:(NSArray *)detailArray;
- (NSDictionary *)getServiceBooleanTypeDictionary:(NSString *)tableName;
- (void)createJSExcecuter:(UIView *)parentView andCodeSnippet:(NSString *)codeSnippet;
//- (BOOL)checkIfAllAnyOneLinePresent;//  Unused Methods
- (void)showAlertView:(NSString *)message;
- (BOOL)shouldDisplayMessage:(NSString *)message;
- (void)showAlertViewWhenGPCalculationNotPossible:(NSString * )message;
- (BOOL)recordsAvailableForPriceCalculation:(NSString *)workOrderLocalId;

- (void)disableAllRunningNetworkOperations;
- (void)enableAllNetworkOpertaions;
- (BOOL)getPriceDataFromOnline:(NSString *)someIdentifier;


- (BOOL)shouldShowBillableAmountInServiceReport;
- (BOOL)shouldShowBillableQuantityInServiceReport;

 //Debrief
/* Manage edit view of lines*/
- (void)showEditViewOfLineInView:(UIView *)parentView forIndexPath:(NSIndexPath *)_indexpath forEditMode:(BOOL)isEditMode;

//Radha :- Child SFM UI
- (void)hideEditViewOfLine;
- (void)hideExpandedChildViews;

//Biz Rules
- (BOOL) executeBizRules;
- (BOOL) isBizRuleTablesAndFieldsAvailable;
- (NSArray *) getBusinessRulesDict:(NSArray *)businessRulesArray;
- (NSString *) getPathForBSLibrary:(NSString *)library;
- (NSString *) getPathForLibrary:(NSString *)library;
- (BOOL) bizRuleResourcesAvailable;
- (NSDictionary *) getBizRulesAndFieldsForParentObject:(NSString *)parentObjectName
                                          childObjects:(NSArray *)childObjectsArray;
- (NSDictionary *) getFieldsInfoForRuleFields:(NSDictionary *)ruleFields
                                  detailNames:(NSArray *)childObjectNamesArray
                             parentObjectName:(NSString *)parentObjectName;
- (NSDictionary *) getDataForRulesWithFieldsInfo:(NSDictionary *)fields
                                     detailNames:(NSArray *)childObjectNamesArray
                                withParentObject:(NSString *)parentObjectName;
- (NSString *) getBizRuleHTMLStringWithFields:(NSString *)fieldsString
                                    withRules:(NSString *)rulesString
                                     withData:(NSString *)dataToValidateString;
- (BOOL) handleBizRuleWarnings:(NSArray *)warningsArray errors:(NSArray *)errorsArray;

//Aparna: Source Update
- (void)refreshDetails;


#define SHOWALL_HEADERS                     0
#define SHOW_HEADER_ROW                     1
#define SHOWALL_LINES                       2
#define SHOW_LINES_ROW                      3
#define SHOW_ALL_ADDITIONALINFO             4
#define SHOW_ADDITIONALINFO_ROW             5
#define SHOW_ATTACHMENT_INFO                6


#define Dvalue                              @"value"
#define DapiName                            @"apiName"
#define Dcontrol_type                       @"control_type"
#define Didtype                             @"id_type"


#define SFPROCESS                           @"SFProcess"
#define SFOBJECT                            @"SFObject"
#define SFOBJECTFIELD                       @"SFObjectField"
#define SVMXC_LINES                         @"SVMXC__Service_Order_Line__c"
#define SVMXC_WORK_ORDER                    @"SVMXC__Service_Order__c"

#define AFTERSAVE                           @"AfterSave"
#define BEFORESAVE                          @"BeforeSave"
#define ONLOAD                              @"Onload"
#define GETPRICE                            @"GETPRICE"

#define DOD_BUTTON                          @"Refresh from Salesforce"

//Debrief :- Radha
#define ROW									@"ROW"
#define CURRENTROW							@"CURRENTROW"
#define CURRENTSECTION						@"CURRENTSCTION"

#pragma mark = offline
//sahana and shrinivas 3rd November
-(void)fillSFMdictForOfflineforProcess:(NSString *) processId forRecord:(NSString *)recordId;
-(void) didReceivePageLayoutOffline;
-(void) initAllrequriredDetailsForProcessId:(NSString *)process_id recordId:(NSString *)recordId object_name:(NSString *)object_name;
-(NSString *)getValueForApiName:(NSString *)filed_api_name dataType:(NSString *)field_data_type  object_name:(NSString *)object_name field_key:(NSString *) field_key;
-(void)SaveRecordIntoPlist:(NSString *)record_id objectName:(NSString *) object_name;

//Radha 
- (NSString *) getProductIdForRecordId:(NSString *)recordId;
- (NSString *) getProductNameForId:(NSString *)productId;

-(void) moveTableViewforDisplayingConflict:(NSMutableString*)error;

//4850
- (void)addRecords:(NSString *)recordId ofObjectName:(NSString *)objectName forComponentId:(NSString *)processCompId ToDictionary:(NSMutableDictionary*)sourceToTargetDetailDictionary;
- (void)removeSourceRecordAsDetalRecordDeletedAtIndex:(NSInteger)index forProcessLayoutId:(NSString *)processLayoutId;
- (void)applySourceUpdateConfigurationFor:(NSString *)processId
                          withComponentId:(NSString *)componentId
                            componentType:(NSString *)type
                                andRecord:(NSDictionary *)record andIndex:(NSInteger)index;

@end

@protocol DetailViewControllerDelegate

@optional
-(void)presentProgressBar:(NSString *)object_name sf_id:(NSString *)sf_id  reocrd_name:(NSString *)record_name;
- (void) Back:(id)sender;
- (void) BackOnSave;
@end
