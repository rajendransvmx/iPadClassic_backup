//
//  SFMResultMainViewController.h
//  SFMSearch
//
//  Created by Siva Manne on 11/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFMResultDetailViewController.h"
#import "iServiceAppDelegate.h"
@class SFMResultMasterViewController;
@class SFMResultDetailViewController;
@interface SFMResultMainViewController : UIViewController<UISplitViewControllerDelegate,SFMResultDetailViewControllerDelegate>
{
    iServiceAppDelegate * appDelegate;
}
@property (nonatomic, retain) NSString *filterString;
@property (nonatomic, retain) NSString *searchCriteriaString;
@property (nonatomic, retain) NSString *masterTableHeader;
@property (nonatomic, retain) NSString *sfmConfiguration;
@property (nonatomic, retain) NSString *processId;
@property (nonatomic, retain) SFMResultMasterViewController *resultmasterView;
@property (nonatomic, retain) SFMResultDetailViewController *resultdetailView;
@property (nonatomic, retain) NSArray *masterTableData;
@property (nonatomic, assign) BOOL switchStatus;
@end
