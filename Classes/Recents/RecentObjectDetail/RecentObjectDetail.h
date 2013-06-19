//
//  RecentObjectDetail.h
//  iService
//
//  Created by Samman on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecentObjectRoot.h"

@protocol RecentObjectDetailDelegate;

@interface RecentObjectDetail : UIViewController
<RecentObjectRootDelegate,
UITableViewDelegate,
UITableViewDataSource
>
{
    id <RecentObjectDetailDelegate> delegate;
    iServiceAppDelegate * appDelegate;
    NSMutableArray * array;
    
    NSInteger selectedRootViewRow;
    
    IBOutlet UITableView * tableView;
    IBOutlet UIActivityIndicatorView * activity;
    
    NSMutableArray * recentObjectsArray;
}

@property (nonatomic, assign) id <RecentObjectDetailDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain) NSMutableArray * recentObjectsArray;

- (void) showSFMWithProcessId:(NSString *)processId recordId:(NSString *)recordId;

@end

@protocol RecentObjectDetailDelegate <NSObject>

@optional
- (void) dismissSelf;
- (void) showSFMWithProcessId:(NSString *)processId recordId:(NSString *)recordId objectName:(NSString *)objectName;
- (void) accessoryButtonTapped: (UIControl *) button withEvent:(UIEvent *) event;

@end
