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
@interface SFMResultMasterViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,setTextFieldPopover,UITextFieldDelegate>{
 NSIndexPath * lastSelectedIndexPath;
    iServiceAppDelegate * appDelegate;
}
@property (nonatomic, retain) IBOutlet UITextField *searchCriteria;
@property (nonatomic, retain) IBOutlet UITextField *searchString;
@property (nonatomic, retain) IBOutlet UISwitch    *searchFilterSwitch;
@property (nonatomic, retain) IBOutlet UITableView    *searchMasterTable;
@property (nonatomic, retain) NSString *tableHeader;
@property (nonatomic, retain) NSString *processId;
@property (nonatomic, retain) NSArray *tableArray;
@property (nonatomic, retain) NSString *searchData;
@property (nonatomic, retain) NSString *searchCriteriaString;
@property (nonatomic, retain) SFMResultDetailViewController *resultDetailView;
@property (nonatomic, retain) NSArray *pickerData;
@property (nonatomic, assign) BOOL switchStatus;
@property(nonatomic,retain) IBOutlet UIButton *actionButton;
- (IBAction)refineSearch:(id)sender;
-(void) didSelectHeader:(id)sender;
@end
