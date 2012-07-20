//
//  iPadScrollerViewController.h
//  iPadScroller
//
//  Created by Samman on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocationManager.h>
#import "BSPreviewScrollView.h"
#import "TapImage.h"
#import "LocalizationGlobals.h"
#import "WSInterface.h"
@class CalendarController;
@class iServiceAppDelegate;

@interface iPadScrollerViewController : UIViewController
<BSPreviewScrollViewDelegate, TapImageDelegate,RefreshProgressBar,CLLocationManagerDelegate>
{
	NSMutableArray * scrollPages;
    IBOutlet UIView *ProgressView;
    IBOutlet UIView * transparent_layer;
    IBOutlet UILabel *display_pecentage;

    IBOutlet BSPreviewScrollView * scrollViewPreview;
    
    IBOutlet UILabel *progressTitle;
    //Abinash
    IBOutlet UIActivityIndicatorView * activity;

    
    IBOutlet UIImageView * animateImage;
    IBOutlet UIView * refFrame;
    IBOutlet UIImageView * lastFrame;
    
    NSArray * itemArray, * descriptionArray;
    
    CalendarController * calendar;
    
    iServiceAppDelegate * appDelegate;
    
    BOOL isInternetAvailable;
    NSTimer * initial_sync_timer;
    float total_progress;
    BOOL Sync_status;
    int Total_calls,current_num_of_call;
    NSInteger temp_percentage;
    
    UIAlertView * internet_alertView;
    
    //Location Ping
    CLLocationManager *locationManager;
}
@property (nonatomic , retain) UIAlertView * internet_alertView;
@property (nonatomic) NSInteger temp_percentage;
@property (nonatomic , retain) IBOutlet UILabel *display_pecentage;
@property (nonatomic)  int Total_calls;
@property (nonatomic) int current_num_of_call;
@property (nonatomic , retain) IBOutlet UIView * transparent_layer;
@property (nonatomic)  BOOL Sync_status;
@property (retain, nonatomic) IBOutlet UILabel *description_label;
@property (retain, nonatomic) IBOutlet UIView *titleBackground;
@property (retain, nonatomic) IBOutlet UILabel *download_desc_label;
//@property (retain, nonatomic) IBOutlet UILabel *StepLabel;
@property (nonatomic)  float total_progress;
@property (nonatomic , retain) NSTimer * initial_sync_timer;
@property (retain, nonatomic) IBOutlet UIProgressView *progressBar;
@property (nonatomic , retain)  IBOutlet UILabel *progressTitle;
@property (nonatomic, retain) NSArray * scrollPages;

//sahana
-(void)clearuserinfoPlist;
-(void)createUserInfoPlist;


- (NSMutableArray *) getScrollViewNames;
- (NSMutableArray *) getScrollViews;

- (void) showTasks;
- (void) showCreateObject;
- (void) showSearch;
- (void) showCalendar;
- (void) showChatter;
- (void) showMap;
- (void) showRecents;
- (void) showHelp;
- (NSString *)dateStringConversion:(NSDate*)date;

//Abinash
-(void)logout;
-(void)sync;
- (void) doMetaAndDataSync;
-(void)disableControls;
-(void)enableControls;
-(void)InitsyncSetting;
-(void)initialDataSetUpAfterSyncOrLogin;

- (void) refreshArray;


//sahana
-(void)fillNumberOfStepsCompletedLabel;
-(void)showAlertForInternetUnAvailability;
-(void)doMetaSync;
-(void)doDataSync;
-(void)doTxFetch;
-(void)doAfterSyncSetttings;
-(void)showAlertViewForAppwasinBackground;
- (void)continueMetaAndDataSync;
-(void)RefreshProgressBarNativeMethod:(NSString *)sync;

//Location Ping
- (void) scheduleLocationPingService;
#define NUM_CALLS_INTIAL_SYNC  15;
@end
