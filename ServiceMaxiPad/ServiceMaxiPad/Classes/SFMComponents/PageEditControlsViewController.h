//
//  PageEditControlsViewController.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 10/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFMRecordFieldData.h"
#import "PageEditControlDelegate.h"

@interface PageEditControlsViewController : UIViewController <PageEditControlDelegate>


@property(nonatomic, strong)SFMRecordFieldData *recordData;
@property(nonatomic, strong)NSIndexPath *indexPath;

@property(weak, nonatomic)id <PageEditControlDelegate> delegate;


- (void)upadeteControlValueOnDismiss;


@end
