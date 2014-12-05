//
//  PageEditPickerFieldController.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 08/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageEditControlsViewController.h"
//#import "SFMRecordFieldData.h"
//#import "PageEditControlDelegate.h"

@interface PageEditPickerFieldController : PageEditControlsViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property(nonatomic, strong)NSArray *dataSource;
/*@property(nonatomic, strong)SFMRecordFieldData *recordData;
@property(nonatomic, strong)NSIndexPath *indexPath;

@property(weak, nonatomic)id <PageEditControlDelegate> delegate;*/

- (void)setPickerValue:(NSInteger )index;

@end
