//
//  SFMResultMasterViewController.h
//  SFMSearch
//
//  Created by Siva Manne on 11/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchCriteriaViewController.h"

@class iServiceAppDelegate;
@class SFMResultDetailViewController;
@interface SFMResultMasterViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,setTextFieldPopoverForSFMSearch,UITextFieldDelegate,ZBarReaderDelegate>{
 NSIndexPath * lastSelectedIndexPath;
    iServiceAppDelegate * appDelegate;
    
    NSMutableDictionary * onlineRecordDict;
}

@property (nonatomic, retain) NSMutableDictionary * onlineRecordDict;
@property (nonatomic, retain) IBOutlet UILabel *searchCriteriaLabel;
@property (nonatomic, retain) IBOutlet UILabel *includeOnlineResultLabel;
@property (nonatomic, retain) IBOutlet UILabel *limitShowLabel;
@property (nonatomic, retain) IBOutlet UILabel *limitRecordLabel;
@property (nonatomic, retain) IBOutlet UITextField *searchCriteria;
@property (nonatomic, retain) IBOutlet UITextField *searchString;
@property (nonatomic, retain) IBOutlet UITextField *searchLimitString;
@property (nonatomic, retain) IBOutlet UISwitch    *searchFilterSwitch;
@property (nonatomic, retain) IBOutlet UITableView    *searchMasterTable;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activity;
@property (nonatomic, retain) NSString *tableHeader;
@property (nonatomic, retain) NSString *processId;
@property (nonatomic, retain) NSArray *tableArray;
@property (nonatomic, retain) NSArray *ObjectDescription;
@property (nonatomic, retain) NSString *searchData;
@property (nonatomic, retain) NSString *searchCriteriaString;
@property (nonatomic, retain) NSString *searchCriteriaLimitString;
@property (nonatomic, retain) SFMResultDetailViewController *resultDetailView;
@property (nonatomic, retain) NSArray *pickerData;
@property (nonatomic, retain) NSArray *searchLimitData;
@property (nonatomic, assign) BOOL switchStatus;
@property(nonatomic,retain) IBOutlet UIButton *actionButton;
@property (readwrite, retain) UIView *inputAccessoryView;

- (IBAction)refineSearch:(id)sender;
-(void) didSelectHeader:(id)sender;
- (void) reloadTableData;
- (IBAction) backgroundSelected:(id)sender;
- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)setState:(id)sender;

- (void)reloadTableWithOnlineData:(NSMutableDictionary *)_onlineDict;
@end
