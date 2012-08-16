//
//  MasterViewController.h
//  SFMSearchTemplate
//
//  Created by Siva Manne on 10/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchCriteriaViewController.h"
#import "DetailViewControllerForSFM.h"

@interface MasterViewController : UIViewController <UITextFieldDelegate,setTextFieldPopoverForSFMSearch,ZBarReaderDelegate> 
@property (nonatomic, retain) IBOutlet UILabel *includeOnlineResultLabel;
@property (nonatomic, retain) IBOutlet UILabel      *searchCriteriaLabel;
@property (nonatomic, retain) IBOutlet UILabel      *limitShowLabel;
@property (nonatomic, retain) IBOutlet UILabel      *limitRecordLabel;
@property (nonatomic, retain) IBOutlet UITextField *searchCriteria;
@property (nonatomic, retain) IBOutlet UITextField *searchString;
@property (nonatomic, retain) IBOutlet UITextField *searchLimitString;
@property (nonatomic, retain) IBOutlet UISwitch    *searchFilterSwitch;
@property (nonatomic, retain) NSArray *pickerData;
@property (nonatomic, retain) NSArray *searchLimitData;
@property (readwrite, retain) UIView *inputAccessoryView;
- (IBAction) backgroundSelected:(id)sender;
@end
