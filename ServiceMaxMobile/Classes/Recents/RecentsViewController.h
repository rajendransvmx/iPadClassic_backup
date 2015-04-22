//
//  RecentsViewController.h
//  iService
//
//  Created by Samman on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
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
    AppDelegate * appDelegate;
    IBOutlet UITableView * mTable;
    IBOutlet UIActivityIndicatorView * activity;
	
	//6347: Refresh for recents screen
	RecentObjectRoot * rootView;
	RecentObjectDetail * detailView;
	
}

@property (nonatomic, retain) NSArray * array;

- (IBAction) back;
//- (void) showSFMWithProcessId:(NSString *)processId recordId:(NSString *)recordId;

- (void) showSFMWithProcessId:(NSString *)processId recordId:(NSString *)recordId objectName:(NSString *)objectName;

// Display user name
- (IBAction) displayUser:(id)sender;

//6347: Refresh for recents screen
- (NSMutableArray *) getRecentsArrayFromObjectHistoryPlist;

@end
