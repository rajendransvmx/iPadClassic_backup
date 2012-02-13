//
//  iServiceAppDelegate.h
//  iService
//
//  Created by Samman Banerjee on 27/08/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "zkSforce.h"
#import "WSInterface.h"
#import "iOSInterfaceObject.h"
#import "HelpController.h"
#import "ZKLoginResult.h"
#import "SFMPageController.h"
#import "Reachability.h"

@class iServiceViewController;
@class LoginController;
@class JobViewController;
@class ModalViewController;

@class ZKLoginResult;

BOOL didSessionResume;

#define kInternetConnectionChanged          @"kInternetConnectionChanged"

@interface iServiceAppDelegate : NSObject
<UIApplicationDelegate, UIActionSheetDelegate, WSInterfaceDelegate>
{
    //sahana RecorsdTypeId
    BOOL recordtypeId_webservice_called;
    UIWindow *window;
    LoginController * loginController;
    
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;

    // Alert View for displaying login error result
    UIAlertView *alert;
    // Login user id to be used across the entire app
    NSString * loggedInUserId;
    
    iOSInterfaceObject * _iOSObject;
    
    // Persistence
    NSString * username, * password;
    NSMutableArray * savedReference;
    NSString * kRestoreLocationKey; // preference key to obtain our restore location

    //locationid
	NSString *locationid, *currentWorkOrderId;
    // NSString *technicianid, *serviceTeamId;
    NSString * appTechnicianId, * appServiceTeamId;
    
    // Technician Address
    NSString * technicianAddress;
    
    // Restore Operatives
    BOOL didDayViewUnload, didMapViewUnload, didJobViewUnload, didTroubleshootingUnload, didProductManualUnload, didChatterUnload, didDebriefUnload, didSFMUnload;
    NSMutableArray * lastSelectedDate;
    NSString * troubleshootProductName;

    // Chatter Feed / Product2Feed
    BOOL chatterFeedPresent;

    // Service Report Customization - sr = service report
    NSMutableDictionary * serviceReport;
    NSMutableString * addressType;

    // Service Report Logo
    UIImage * serviceReportLogo;
       
    // Refresh Calendar
    BOOL refreshCalendar;

    //radha 26th April 2011
    ZKLoginResult * loginResult;
    
    // Modal View Controller
    ModalViewController * modalCalendar;
    
    NSString * dateClicked;
    
    // SFM Page instance members
    SFMPageController * sfmPageController;
    NSDictionary * dict;
    NSMutableArray * headerArray, *linesArray;
    NSDictionary * SFMPage;
    NSArray * describeObjectsArray;
    WSInterface * wsInterface;
    
    // Lookup History
    NSMutableDictionary * lookupHistory;
    NSDictionary * lookupData;
    
    //MulitiAdd Rows
    NSString * objectName;
    
    // Standalone Create
    BOOL didCreateStandalone;
    BOOL createProcess;
    BOOL sfmSave;
    BOOL cancel_save;
    BOOL sfmSaveError;
    
	NSArray * additionalInfo;

    // Debriefing
    NSMutableDictionary *Dictionaries;
    // Time and Material
    NSMutableArray * timeAndMaterial;
    // Usage/Consumption
    NSString * usageConsumptionRecordId;
    NSArray * partsZKSArray, * laborZKSArray, * expensesZKSArray;
    NSString * workOrderCurrency;
    NSMutableArray * Parts, * Labour, * Expenses;
    NSString * priceBookName;
    NSMutableArray * productIdList;
    NSMutableArray * serviceReportValueMapping;
    ZKDescribeSObject * workOrderDescription;
    NSMutableString * currentUserName, * loggedInOrg;

    //Radha Save Create Object
    NSMutableDictionary * createObjectContext; //contains object api name, label, name field, record id. This is for storing create object history
    NSMutableArray * recentObject;
    NSString * cur_nameField;
    NSString * cur_Field_label;
    
    //sahana
    NSString * oldProcessId;
    NSString * oldRecordId;
    NSString * newProcessId;
    NSString * newRecordId;
    NSString * newProcessIdForEdit;
    NSString * newRecordIdForEdit;
    
    NSMutableArray * objectNames_array;
    NSMutableArray * StandAloneCreateProcess;
    NSMutableArray * objectLabel_array;
    NSMutableArray * objectLabelName_array;
    BOOL isSFMReloading;
    NSString * currentServerUrl;
    
    // For Service Report by Settings
    NSMutableString * soqlQuery;
    
    //MapView
    NSMutableArray * workOrderEventArray;
    NSMutableArray * workOrderInfo;
    
    NSString * firstUsername;
    
    // DORMA
    BOOL signatureCaptureUpload;
    
    // Switch View Layouts
    NSMutableDictionary * switchViewLayouts;
    
    NSMutableArray * userNameImageList;
    
    BOOL isDetailActive;
    //sahana 25th August
    NSString * SVMX_Version;
    BOOL didGetVersion;
    
    BOOL connectionAvailable;
    
    BOOL isInternetConnectionAvailable;
    NSMutableArray * allURLConnectionsArray;
}
@property (nonatomic) BOOL recordtypeId_webservice_called;
@property (nonatomic) BOOL didGetVersion;
@property (nonatomic , retain) NSString * SVMX_Version;
@property (nonatomic , retain)  NSString * newProcessId;
@property (nonatomic , retain) NSString * newRecordId;
@property (nonatomic , retain)  NSString * newProcessIdForEdit;
@property (nonatomic , retain) NSString * newRecordIdForEdit;
@property (nonatomic)  BOOL isSFMReloading;
@property (nonatomic , retain)  NSMutableArray * objectLabel_array;
@property (nonatomic , retain) NSMutableArray * objectNames_array;
@property (nonatomic , retain)  NSMutableArray * StandAloneCreateProcess;
@property(nonatomic , retain)  NSString * oldProcessId;
@property(nonatomic , retain)   NSString * oldRecordId;
@property(nonatomic , retain) NSString * cur_nameField;
@property(nonatomic , retain)  NSString * cur_Field_label;
@property (nonatomic , retain) NSArray  * additionalInfo;
@property(nonatomic)  BOOL sfmSaveError;
@property (nonatomic) BOOL cancel_save;
//@property (nonatomic) BOOL sfmSaveCancelled;
@property (nonatomic )BOOL sfmSave; 
@property (nonatomic, retain) NSString * currentProcessID;
@property (nonatomic) BOOL createProcess;
//For Localization
//RADHA 20th April 2011
@property (nonatomic, retain) ZKLoginResult * loginResult;
@property (nonatomic , retain) NSMutableArray * deleted_detail_Fields;
@property (nonatomic, retain) NSString * dateClicked;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet LoginController * viewController;
@property (nonatomic, retain) NSString * loggedInUserId;
@property (nonatomic, retain) iOSInterfaceObject * _iOSObject;

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSMutableArray * savedReference;
@property (nonatomic, retain) NSString * kRestoreLocationKey;

@property (nonatomic, copy) NSString *locationid, *currentWorkOrderId;
@property (nonatomic, retain) NSString * appTechnicianId, * appServiceTeamId;

@property (nonatomic, retain) NSDictionary * tempSummary;

@property (nonatomic, retain) NSString * technicianAddress;

// Restore Operatives
@property BOOL didDayViewUnload, didMapViewUnload, didJobViewUnload, didTroubleshootingUnload, didProductManualUnload, didChatterUnload, didDebriefUnload, didSFMUnload;
@property (nonatomic, retain) NSMutableArray * lastSelectedDate;
@property (nonatomic, retain) NSString * troubleshootProductName;

// Service Report Logo
@property (nonatomic, retain) UIImage * serviceReportLogo;

// Refresh Calendar
@property BOOL refreshCalendar;
@property (nonatomic, retain) ModalViewController * modalCalendar;

// SFM Page
@property (nonatomic, retain) SFMPageController * sfmPageController;
@property (nonatomic, retain) WSInterface * wsInterface;
@property (nonatomic, retain) NSDictionary * dict;
@property (nonatomic, retain) NSMutableArray *headerArray,*linesArray;
@property (nonatomic, retain) NSDictionary * SFMPage;
@property (nonatomic, retain) NSArray * describeObjectsArray;

// Lookup History
@property (nonatomic, retain) NSMutableDictionary * lookupHistory;

@property (nonatomic, retain) NSDictionary * lookupData;

//MulitiAdd Rows
@property (nonatomic, retain) NSString * objectName;

//Standalone
@property (nonatomic, assign) BOOL didCreateStandalone;

// Debriefing
@property (nonatomic, retain) NSMutableDictionary * Dictionaries;
// Time and Material
@property (nonatomic, retain) NSMutableArray * timeAndMaterial;
// Usage/Consumption
@property (nonatomic, retain) NSString * usageConsumptionRecordId;
@property (nonatomic, retain) NSArray * partsZKSArray, * laborZKSArray, * expensesZKSArray;
@property (nonatomic, retain) NSString * workOrderCurrency;
@property (nonatomic, retain) NSMutableArray * Parts, * Labour, * Expenses;
@property (nonatomic, retain) NSString * priceBookName;
@property (nonatomic, retain) NSMutableArray * productIdList;
@property (nonatomic, retain) NSMutableString * addressType;
@property (nonatomic, retain) NSMutableArray * serviceReportValueMapping;
@property (nonatomic, retain) ZKDescribeSObject * workOrderDescription;
@property (nonatomic, retain) NSMutableDictionary * serviceReport;
@property (nonatomic, retain) NSMutableString * currentUserName, * loggedInOrg;

//Radha save create object
@property (nonatomic, retain) NSMutableDictionary * createObjectContext;
@property (nonatomic, retain) NSMutableArray * recentObject;
@property (nonatomic, retain) NSMutableArray * objectLabelName_array;

@property (nonatomic, retain) NSString * currentServerUrl;

// Service Report
@property (nonatomic, retain) NSMutableString * soqlQuery;

//Mapview
@property (nonatomic, retain) NSMutableArray * workOrderEventArray;
@property (nonatomic, retain) NSMutableArray * workOrderInfo;

@property (nonatomic, retain) NSString * firstUsername;

// DORMA
@property BOOL signatureCaptureUpload;

// Switch View Layouts
@property (nonatomic, retain) NSMutableDictionary * switchViewLayouts;

@property (nonatomic, retain) NSMutableArray * userNameImageList;

@property BOOL isDetailActive;

@property BOOL connectionAvailable;

@property BOOL isInternetConnectionAvailable;

@property (nonatomic, retain) NSMutableArray * allURLConnectionsArray;

@property (nonatomic, retain) Reachability *hostReach;
@property (nonatomic, retain) Reachability *internetReach;

@property (nonatomic) BOOL isInternetPresentAfterWake;
@property (nonatomic) BOOL didAppBecomeActive;
@property (nonatomic) BOOL didUserInteract, internetConnectionStatus;

// Reachability
- (void) updateInterfaceWithReachability:(Reachability*)curReach;
- (void) PostInternetNotificationUnavailable;
- (void) PostInternetNotificationAvailable;
- (void) displayNoInternetAvailable;

// isInternetConnectionAvailable 
// Getter
- (BOOL) isInternetConnectionAvailable;
// Setter
- (void) setIsInternetConnectionAvailable:(BOOL)isInternetConnectionAvailable;

// Get Color from HEX
- (UIColor *) colorForHex:(NSString *)hexColor;

-(void)popupActionSheet:(NSString *)message;

@end

// ALog always displays output regardless of the DEBUG setting
// #define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
