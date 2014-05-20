//
//  HomeScreen.h
//  ServiceMaxMobile
//
//  Created by AnilKumar on 4/17/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocationManager.h>
#import "LocalizationGlobals.h"
#import "WSInterface.h"
#import "AppDelegate.h"
#import "FirstDetailViewController.h"
//#import "CLLocationManagerDelegate.h"


#import "ItemView.h"
@class CalendarController;




@interface HomeScreen : UIViewController
<RefreshProgressBar,CLLocationManagerDelegate,UITableViewDataSource, UITableViewDelegate,ItemViewDelegate,UIAlertViewDelegate>

{
    IBOutlet UIView *ProgressView;
    IBOutlet UIView * transparent_layer;
    IBOutlet UILabel *display_pecentage;
    IBOutlet UILabel *progressTitle;
    IBOutlet UIActivityIndicatorView * activity;
    
    IBOutlet UIImageView * animateImage;
    IBOutlet UIView * refFrame;
    IBOutlet UIImageView * lastFrame;
    
    NSMutableArray * itemArray, * descriptionArray;
    
    //CalendarController * calendar;
    
    BOOL isInternetAvailable;
    NSTimer * initial_sync_timer;
    float total_progress;
    BOOL Sync_status;
    int Total_calls,current_num_of_call;
    NSInteger temp_percentage;
    UIAlertView * internet_alertView;
    CLLocationManager *locationManager;
    UITableView *menuTableView;
    IBOutlet UIImageView *customerLogoImageView;
    NSArray *accessIdentifiersHomeScreen;
}


@property (nonatomic,strong) UITableView *menuTableView;
@property (nonatomic , strong) UIAlertView * internet_alertView;
@property (nonatomic) NSInteger temp_percentage;
@property (nonatomic , strong) IBOutlet UILabel *display_pecentage;
@property (nonatomic)  int Total_calls;
@property (nonatomic) int current_num_of_call;
@property (nonatomic , strong) IBOutlet UIView * transparent_layer;
@property (nonatomic)  BOOL Sync_status;
@property (strong, nonatomic) IBOutlet UILabel *description_label;
@property (strong, nonatomic) IBOutlet UIView *titleBackground;
@property (strong, nonatomic) IBOutlet UILabel *download_desc_label;

@property (nonatomic)  float total_progress;
@property (nonatomic , strong) NSTimer * initial_sync_timer;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;
@property (nonatomic , strong)  IBOutlet UILabel *progressTitle;
@property (nonatomic , strong) CLLocationManager *locationManager;


-(void)clearuserinfoPlist;
-(void)createUserInfoPlist;

//---UIAutomation-Shra
@property (nonatomic,strong) NSArray *accessIdentifiersHomeScreen;


- (NSMutableArray *) getScrollViewNames;


- (void) showTasks;
- (void) showCreateObject;
- (void) showSearch;
- (void) showCalendar;
- (void) showChatter;
- (void) showMap;
- (void) showRecents;
- (void) showHelp;
- (NSString *)dateStringConversion:(NSDate*)date;


-(void)logout;
-(void)sync;
- (void) doMetaAndDataSync;//  Unused methods
-(void)disableControls;
-(void)enableControls;
-(void)InitsyncSetting;
-(void)initialDataSetUpAfterSyncOrLogin;

- (void) refreshArray;

- (NSString *)getAccessibilityForItemAtIndex:(NSInteger)index;
//---UIAutomation-Shra


-(void)fillNumberOfStepsCompletedLabel;
-(void)showAlertForInternetUnAvailability;
-(void)doMetaSync;
-(void)doDataSync;
-(void)doTxFetch;
-(void)doAfterSyncSetttings;

- (void)continueMetaAndDataSync;
-(void)RefreshProgressBarNativeMethod:(NSString *)sync;
-(void)refreshViewAfterMetaSync;

- (void) scheduleLocationPingService;
#define NUM_CALLS_INTIAL_SYNC  15;



# define LOCAL_ID	@"Local_Id"
-(void) UpdateUserDefaults;





@end
