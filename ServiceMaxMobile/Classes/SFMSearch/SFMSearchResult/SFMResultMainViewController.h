//
//  SFMResultMainViewController.h
//  SFMSearch
//
//  Created by Siva Manne on 11/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFMResultDetailViewController.h"
#import "AppDelegate.h"
@class SFMResultMasterViewController;
@class SFMResultDetailViewController;
@interface SFMResultMainViewController : UIViewController<UISplitViewControllerDelegate,SFMResultDetailViewControllerDelegate>
{
    AppDelegate * appDelegate;
    int total_progress;
    int Total_calls;
    NSTimer *initial_sync_timer;
    int temp_percentage;
}
@property (retain, nonatomic) IBOutlet UIView *progressView;
@property (retain, nonatomic) IBOutlet UILabel *progressTitle;
@property (retain, nonatomic) IBOutlet UILabel *display_percentage;
@property (retain, nonatomic) IBOutlet UILabel *download_desc_label;
@property (retain, nonatomic) IBOutlet UILabel *description_label;
@property (retain, nonatomic) IBOutlet UIProgressView *ProgressBar;
@property (retain, nonatomic) IBOutlet UIView *ProgressBarViewController;

@property (retain, nonatomic) IBOutlet UIView *titleBackground;

@property (nonatomic, retain) NSString *filterString;
@property (nonatomic, retain) NSString *searchCriteriaString;
@property (nonatomic, retain) NSString *searchCriteriaLimitString;
@property (nonatomic, retain) NSString *masterTableHeader;
@property (nonatomic, retain) NSString *sfmConfiguration;
@property (nonatomic, retain) NSString *processId;
@property (nonatomic, retain) SFMResultMasterViewController *resultmasterView;
@property (nonatomic, retain) SFMResultDetailViewController *resultdetailView;
@property (nonatomic, retain) NSArray *masterTableData;
@property (nonatomic, assign) BOOL switchStatus;
//-(void)ShowProgressBar;//  Unused Methods
-(void)fillNumberOfStepsCompletedLabel;
@end
