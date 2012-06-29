//
//  ManualDataSyncDetail.h
//  iService
//
//  Created by Parashuram on 14/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFMPageController.h"
#import "PopoverButtons.h"
#import "DataSyncLabelPopover.h"
#import "ManualDataSyncRoot.h"
#import "SyncStatusView.h"
#import "WSInterface.h"

@protocol SyncRootViewProtocolDelegate;
@protocol ManualDataSync;
@protocol SyncButtonProtocol;

@class iServiceAppDelegate;

# define ERROR_MESSAGE   @"Error_message"

@interface ManualDataSyncDetail : UIViewController <UIPopoverControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISplitViewControllerDelegate, MyPopoverDelegate, ManualDataSyncRootDelegate, RefreshSyncUIStatusButton, ReloadSyncTable, UIAlertViewDelegate>
{
    UITableView * tableView;
    
    id <SFMPageDelegate> delegate;
    id <SyncRootViewProtocolDelegate> rootSyncDelegate;
    
    UIBarButtonItem * actionButton;
    UINavigationBar * navigationBar;
    UIBarButtonItem * syncroniseButton;
    
    UIButton * button;
    UIButton * statusButton;
    UIToolbar * toolBar;
    
    NSInteger  selectedSection;
    NSUInteger selectedRow;
    NSInteger  HeaderSelected;
    
    IBOutlet UITableView *_tableView;
    
    id <ManualDataSync> dataSync;

    UISegmentedControl * segmentControl;
    UIPopoverController* popoverController;
    
    
    PopoverButtons *popOver_view;
    iServiceAppDelegate * appDelegate;
    
    ManualDataSyncRoot * manualDataRoot;
    
    NSMutableArray * recordIdArray;
    NSMutableArray * objectsArray;
    NSMutableArray * objectDetailsArray;
    
    NSMutableDictionary * objectsDict;
    
    DataSyncLabelPopover * labelPopover;
    UIPopoverController  * label_popOver;
    
    NSInteger selectedRootViewRow;
    IBOutlet UIActivityIndicatorView *activity;
    
    SyncStatusView * syncStatus;  
    
    NSMutableArray * internet_Conflicts;

	//Shrinivas
    UIImageView* animatedImageView;
    
    //Radha 2012june16
    UIImageView * syncDueView;
}

@property (nonatomic, assign)   id <SyncRootViewProtocolDelegate> rootSyncDelegate;
@property (nonatomic, retain)  NSMutableArray * internet_Conflicts;
@property (nonatomic, retain)  UIToolbar *toolBar;
@property (nonatomic, retain)  IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain)  IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain)  UIBarButtonItem *syncroniseButton;
@property (nonatomic, retain)  IBOutlet UITableView *_tableView;
@property (nonatomic, retain)  UIPopoverController *popoverController;
@property (nonatomic, assign)  id <ManualDataSync> dataSync;

@property (nonatomic, retain)  NSMutableArray * recordIdArray;
@property (nonatomic, retain)  NSMutableArray * objectsArray;
@property (nonatomic, retain)  NSMutableDictionary * objectsDict;
@property (nonatomic, retain)  NSMutableArray * objectDetailsArray;
@property (nonatomic, assign)  id <SyncButtonProtocol> syncButtonDelegate;
@property (nonatomic, retain)  IBOutlet UIActivityIndicatorView *activity;
@property (nonatomic) BOOL didAppearFromSFMScreen;



- (UIColor *) colorForHex:(NSString *)hexColor;
- (void) _didSelectRow:(NSInteger )row ForSection:(NSInteger )section;
- (void) headerSelected;
//- (void) rowSelected;
//- (void) showSFMWithProcessId:(NSString *)processId recordId:(NSString *)recordId objectName:(NSString *)objectName;
- (void) deleteUndoneRecords;
- (NSString *) getlocalIdForSFId:(NSString *)SFId ForObject:(NSString *)Objectname;
- (UIImage *) getStatusImage;

- (void) moveTableView;

@end

@protocol ManualDataSync <NSObject>

- (void) dissmisController;
- (void) showSFMWithProcessId:(NSString *)processId recordId:(NSString *)recordId objectName:(NSString *)objectName;
- (void) throwException;

@end

@protocol SyncRootViewProtocolDelegate <NSObject>

- (void) disableRootControls;
- (void) enableRootControls;
- (void) reloadRootTable;

@end


