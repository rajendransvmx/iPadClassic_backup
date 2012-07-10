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

@interface MasterViewController : UIViewController <UITextFieldDelegate,setTextFieldPopover> 
@property (nonatomic, retain) IBOutlet UILabel *includeOnlineResultLabel;
@property (nonatomic, retain) IBOutlet UILabel      *searchCriteriaLabel;
@property (nonatomic, retain) IBOutlet UITextField *searchCriteria;
@property (nonatomic, retain) IBOutlet UITextField *searchString;
@property (nonatomic, retain) IBOutlet UISwitch    *searchFilterSwitch;
@property (nonatomic, retain) NSArray *pickerData;
- (IBAction) backgroundSelected:(id)sender;
@end
