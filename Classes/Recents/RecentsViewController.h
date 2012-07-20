//
//  RecentsViewController.h
//  iService
//
//  Created by Samman on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iServiceAppDelegate.h"
#import "SFMPageController.h"

#import "RecentObjectRoot.h"
#import "RecentObjectDetail.h"

@interface RecentsViewController : UIViewController
<UITableViewDataSource, 
UITableViewDelegate,
UIPopoverControllerDelegate,
RecentObjectDetailDelegate,
UISplitViewControllerDelegate>
{
    iServiceAppDelegate * appDelegate;
    IBOutlet UITableView * mTable;
    IBOutlet UIActivityIndicatorView * activity;
}

@property (nonatomic, retain) NSArray * array;

- (IBAction) back;
//- (void) showSFMWithProcessId:(NSString *)processId recordId:(NSString *)recordId;

- (void) showSFMWithProcessId:(NSString *)processId recordId:(NSString *)recordId objectName:(NSString *)objectName;

// Display user name
- (IBAction) displayUser:(id)sender;

@end
