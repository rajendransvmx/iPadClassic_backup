//
//  SFMPageController.h
//  iService
//
//  Created by Developer on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "DetailViewController.h"

@protocol SFMPageDelegate;

@interface SFMPageController : UIViewController
<UISplitViewControllerDelegate, DetailViewControllerDelegate>
{
    id <SFMPageDelegate> delegate;
    RootViewController * rootView;
    DetailViewController * detailView;
    UISplitViewController * splitView;
    UINavigationController * masterView, * detailViewController;
    UIBarButtonItem * barButton;
    UIPopoverController * popover;
    NSString * sourceProcessId;
    NSString * sourceRecordId;
    NSString * processId, * recordId, * objectName, * activityDate, * accountId, * topLevelId;
    
    BOOL _viewMode;
    
    BOOL conflictExists;
    int total_progress;
    int Total_calls;
    NSTimer *initial_sync_timer;
    int temp_percentage;
    NSMutableArray * process_stack;
    NSString * parent_process_id;
    NSString * parent_record_id;
}

@property (nonatomic,retain)  NSString * parent_process_id ,* parent_record_id;
@property (nonatomic, retain) NSMutableArray * process_stack;
@property (retain, nonatomic) IBOutlet UIView *progressView;
@property (retain, nonatomic) IBOutlet UILabel *progressTitle;
@property (retain, nonatomic) IBOutlet UILabel *display_percentage;
@property (retain, nonatomic) IBOutlet UILabel *download_desc_label;
@property (retain, nonatomic) IBOutlet UILabel *description_label;
@property (retain, nonatomic) IBOutlet UIProgressView *ProgressBar;
@property (retain, nonatomic) IBOutlet UIView *ProgressBarViewController;

@property (retain, nonatomic) IBOutlet UIView *titleBackground;


@property (nonatomic , assign) BOOL conflictExists;

@property (nonatomic , retain) NSString * sourceProcessId;
@property (nonatomic , retain) NSString * sourceRecordId;
@property (nonatomic, retain) id <SFMPageDelegate> delegate;
@property (nonatomic, retain) RootViewController * rootView;
@property (nonatomic, retain) DetailViewController * detailView;

@property (nonatomic, retain) NSString * processId, * recordId, * objectName, * activityDate, * accountId, * topLevelId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mode:(BOOL)viewMode;

-(void)fillNumberOfStepsCompletedLabel;
@end

@protocol SFMPageDelegate

@optional
- (void) Back:(id)sender;
-(void) BackOnSave;

@end
