//
//  SearchViewController.h
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 07/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SMSplitViewController.h"

@protocol SearchViewControllerDelegate <NSObject>
- (void)reloadData;
@end

@interface SFMSearchViewController : SMSplitViewController <SMSplitViewControllerDelegate>
- (void)reloadDataOnTabButtonClick;
@end
