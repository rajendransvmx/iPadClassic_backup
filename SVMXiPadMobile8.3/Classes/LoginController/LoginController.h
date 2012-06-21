//
//  LoginController.h
//  iService
//
//  Created by Samman Banerjee on 28/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iServiceAppDelegate.h"
#import "iPadScrollerViewController.h"
#import "OpenFlowAppViewController.h"

@class ModalViewController;

#define APPVERSION                                  8.30000

@interface LoginController : UIViewController <UIAlertViewDelegate>
{
    iServiceAppDelegate * appDelegate;

    IBOutlet UIView * portrait, * landscape;
    
    IBOutlet UITextField * txtUsernamePortrait, * txtPasswordPortrait;
    IBOutlet UITextField * txtUsernameLandscape, * txtPasswordLandscape;
    
    NSString * userId;
    
    //Abinash
    IBOutlet UIButton *IncrementalMetasync;
    BOOL isincrementalMetaSyncButtonChecked;
    IBOutlet UILabel *incrementalMetasync;
    BOOL didCompleteSync;

    
    
    IBOutlet UIActivityIndicatorView * activity;
    NSThread * localThread;
    
    ModalViewController * calendar;
    
    IBOutlet UIButton * sampleDataButton;
    BOOL isSampleDataButtonChecked;
    
    IBOutlet UIProgressView * progressBar;
    IBOutlet UILabel * progressTitle;
    
    NSString * dummyId;
    
    // samman 19th Feb, 2011
    NSMutableString * settingInfoId;
    NSMutableArray * settingsInfoArray, * settingsValueArray;
    
    // samman 17th Mar, 2011
    NSMutableString * groupProfileIdArray;
    
    NSString * ActiveGloProInfoId;

    //Radha 22nd April 2011
    //Localization...
    IBOutlet UIButton * login;
    IBOutlet UILabel * createSampleLabel;
    IBOutlet UIButton * newloginButton;
    NSMutableArray * eventInfoarray;

    OpenFlowAppViewController * homeView;
    iPadScrollerViewController * homeScreenView;
    
    ModalViewController * calendarView;
    
    BOOL didDebriefData;
    BOOL didQueryTechnician;

    // For Service Report Settings
    BOOL didRetrieveReportSettings;
    
    // Samman - 5 Aug, 2011, Sample Data Creation
    BOOL didCreateSampleData, didGetServiceReportLogo;
    
    NSString * _username;
    NSString * _password;

    BOOL didCancelURL;
    BOOL isShowingLogin;
    BOOL didRunProcess;
    
    
    //radha 7th december 2011
    IBOutlet UIButton * initialMetaSync;
    BOOL isinitialSyncButtonChecked;
    IBOutlet UILabel * checkBoxTitle;
    BOOL didLoginCompleted;
    
    //Abinash
    BOOL continueFalg;
    BOOL didDismissalertview;
    BOOL didEnterAlertView;
    
}

@property (nonatomic ) BOOL didEnterAlertView;

@property (nonatomic, retain) NSMutableArray * eventInfoarray;

//- (void) storeLoginDetails;

- (LoginController *) getViewForOrientation:(NSString *)toOrientation;

@property (nonatomic, retain) IBOutlet UITextField *txtUsernamePortrait;
@property (nonatomic, retain) IBOutlet UITextField *txtPasswordPortrait;

@property (nonatomic, retain) IBOutlet UITextField *txtUsernameLandscape;
@property (nonatomic, retain) IBOutlet UITextField *txtPasswordLandscape;
//Radha
@property (nonatomic, retain) NSString * startDateForResponse, * endDateForResponse;
//Abinash
@property (nonatomic, retain) NSString * _username;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * activity;



//Radha 27th April 2011
//-(void) callModalViewController;

//Abinash
- (IBAction)doIncrementalMetasync:(id)sender;
//Radha
- (IBAction)clickInitialMetaSync:(id)sender;

-(IBAction)callLogin:(id)sender;
-(void)hadLoginError:(ZKSoapException *)e;

- (NSString *) getUserId;

- (IBAction) signup:(id)sender;

- (IBAction) clickSampleDataButton;
- (void) checkSampleDataCreation;
- (void) createSampleData;
- (void) getSampleDataCreationProgressForServiceMax_List_Id:(NSString *)Id;
- (void) storeLoginDetails;
- (void) updateSampleDataCreationProgress;

- (void) showModalViewController;
- (void) showHomeScreenviewController;
//Methods to retrieve the technician id and address
- (void) initDebriefData:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) didQueryTechnician:(ZKQueryResult *)result error:(NSError *)error context:(id)context;

- (BOOL) checkVersion;

// Favorites delete cache functionality
- (void) checkFavoritesUser;
- (void) deleteFavoritesCache;

// Service Report Logo
- (void) getServiceReportLogo;
- (void) didGetServiceReportLogo:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
// Service Report Settings
- (void) startQueryConfiguration;
- (void) didGetModuleInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) didGetSubModuleInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) didGetSettingsInfo:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) didGetActiveGlobalProfile:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) didGetSettingsValue:(ZKQueryResult *)result error:(NSError *)error context:(id)context;
- (void) didDescribeSObject:(ZKDescribeSObject *)result error:(NSError *)error context:(id)context;

- (void) enableControls;
- (void) disableControls;

- (void) readUsernameAndPasswordFromKeychain;

-(void)getTagsForTheFirstTime;
//-(void) getCreateProcessArray:(NSMutableArray *)processes_array;



//Radha ->Login
- (void) doMetaAndDataSync;
//- (void) CheckForUserNamePassword;
- (BOOL) CheckForUserNamePassword;
- (void) loginWithUsernamePassword;


#define FIELDNAME                           @"sObjectFieldName"
#define TYPE                                @"sObjectType"

#define LASTMODIFIEDDATEDICT                @"LastModifiedDateDict"
#define LASTMODIFIEDDATE                    @"LastModifiedDate"

@end
