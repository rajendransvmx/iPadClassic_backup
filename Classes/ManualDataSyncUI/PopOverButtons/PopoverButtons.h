//
//  PopoverButtons.h
//  ManualDataSyncUI
//
//  Created by Parashuram on 12/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iServiceAppDelegate.h"


@protocol MyPopoverDelegate <NSObject>
-(void)dismisspopover;
- (void) activityStart;
- (void) activityStop;
//Radha
- (void) throwException;
- (void) enableControls;
- (void) disableControls;
//- (void) refreshRootView;//  Unused methods
//Radha 2012june16
- (void) resetTableview;
- (void) showInternetAletView;
//sahana 25th September
-(void)dismissSyncScreen;

@end

@protocol RefreshMetaSyncStatus <NSObject>
-(void)refreshMetaSyncStatus;

@end

@class ManualDataSyncDetail;


@interface PopoverButtons : UIViewController <UIPopoverControllerDelegate, UIAlertViewDelegate>
{
    id<MyPopoverDelegate> delegate;
    id<RefreshMetaSyncStatus> refreshMetaSyncDelegate;
    
    UIButton *button;
    UIButton *button1;
    UIButton *button2;
	UIButton *button3;
    
    NSMutableArray * objectsArray;
    NSMutableDictionary * objectsDict;
    NSMutableArray * objectDetailsArray;
    UIPopoverController * popover;
    
    
    iServiceAppDelegate * appDelegate;
    
    //RADHA - 21 MARCH
    BOOL syncConfigurationFailed;
    ManualDataSyncDetail * detail;
    
    BOOL fullDataSyncFailed;
    
    //Manual event sync thread
    NSThread * manualEventThread;
    
    //flag for metasync
    BOOL continueFalg;
    BOOL didDismissAlertView;
}


@property (nonatomic, retain)NSThread * manualEventThread; //10-June-2013 Shrini Oauth
@property (nonatomic) BOOL syncConfigurationFailed;

@property (nonatomic , retain)  UIPopoverController * popover;

@property (nonatomic, assign) id<MyPopoverDelegate> delegate;
@property (nonatomic, assign) id<RefreshMetaSyncStatus> refreshMetaSyncDelegate;;

@property (nonatomic, retain) UIButton *button;
@property (nonatomic, retain) UIButton *button1;
@property (nonatomic, retain) UIButton *button2;
@property (nonatomic, retain) UIButton *button3;
@property (nonatomic, retain) NSMutableDictionary * objectsDict;
@property (nonatomic, retain) NSMutableArray * objectDetailsArray;
@property (nonatomic, retain) NSMutableArray * objectsArray;

- (void) Syncronise;
- (void) synchronizeConfiguration;
- (void) synchronizeEvents;
//- (void) schdulesynchronizeConfiguration;//  Unused methods


- (void) startSyncEvents;
- (void) syncSuccess;
- (void) updateMetsSyncStatus:(NSString*)Status;

//RADHA 
- (void) startSyncConfiguration;
- (void) scheduletimer;
- (void) setSyncStatus;

//Radha 
- (void) refreshMetaSyncTimeStamp;

@end

extern PopoverButtons *popOver_view;
