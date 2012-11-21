//
//  SFMFullResultViewController.h
//  SFMSearch
//
//  Created by Siva Manne on 12/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iServiceAppDelegate.h"
#import "LabelPOContentView.h"
#define SectionHeaderHeight      45 
@protocol SFMFullResultViewControllerDelegate
@optional
- (void) DismissSplitViewControllerByLaunchingSFMProcess;
-(void) LoadResultDetailViewController:(BOOL)isondemand;
@end

@class iServiceAppDelegate;
@interface SFMFullResultViewController : UIViewController<SFMFullResultViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIPopoverControllerDelegate>
{
    iServiceAppDelegate * appDelegate;
    UIPopoverController * label_popOver;
    LabelPOContentView * label_popOver_content;
    int total_progress;
    int Total_calls;
    NSTimer *initial_sync_timer;
    int temp_percentage;
    BOOL isOndemandRecord;
}
@property (retain, nonatomic) IBOutlet UIView *progressView;
@property (retain, nonatomic) IBOutlet UILabel *progressTitle;
@property (retain, nonatomic) IBOutlet UILabel *display_percentage;
@property (retain, nonatomic) IBOutlet UILabel *download_desc_label;
@property (retain, nonatomic) IBOutlet UILabel *description_label;
@property (retain, nonatomic) IBOutlet UIProgressView *ProgressBar;
@property (retain, nonatomic) IBOutlet UIView *ProgressBarViewController;

@property (retain, nonatomic) IBOutlet UIView *titleBackground;
@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) NSString *objectName;
@property (nonatomic, retain) NSArray *tableHeaderArray;
@property (nonatomic, assign) BOOL isOnlineRecord;
@property (nonatomic, assign) id <SFMFullResultViewControllerDelegate> fullMainDelegate;
@property (nonatomic, retain) IBOutlet UITableView *resultTableView;
@property (nonatomic, retain) IBOutlet UIImageView *onlineImageView;
@property (nonatomic, retain) IBOutlet UIButton *actionButton,*detailButton;
@property (nonatomic,retain) IBOutlet UIButton *download_on_demand;
@property (nonatomic, assign) BOOL conflict;

@property(nonatomic,retain) IBOutlet UILabel *TitleForResultWindow;

- (IBAction)dismissView:(id)sender;
- (IBAction) accessoryButtonTapped:(id)sender;
- (void) tapRecognized:(id)sender;
-(void)fillNumberOfStepsCompletedLabel;
-(void)presentProgressBar:(NSString *)object_name sf_id:(NSString *)sf_id  reocrd_name:(NSString *)record_name;
-(void)enableControl;
-(void)disableControl;
@end
