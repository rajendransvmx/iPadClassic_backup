//
//  PageEditDateFieldController.h
//  SampleDatePicker
//
//  Created by Shubha S on 01/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageEditControlsViewController.h"
//#import "SFMRecordFieldData.h"
//#import "PageEditControlDelegate.h"

@interface PageEditDateFieldController : PageEditControlsViewController

//@property(assign) id <PageEditControlDelegate> delegate;
//
//@property (strong, nonatomic) NSIndexPath *indexPath;
//@property (strong, nonatomic) SFMRecordFieldData *sfmRecordFieldData;

- (IBAction)pickerValueChanged:(id)sender;

@end
