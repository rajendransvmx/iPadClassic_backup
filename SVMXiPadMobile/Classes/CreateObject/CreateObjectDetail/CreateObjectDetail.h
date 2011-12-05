//
//  CreateObjectDetail.h
//  iService
//
//  Created by Samman on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateObjectRoot.h"

@protocol CreateObjectDetailDelegate;

@interface CreateObjectDetail : UIViewController
<CreateObjectRootDelegate,
UITableViewDelegate,
UITableViewDataSource>
{
    id <CreateObjectDetailDelegate> delegate;
    iServiceAppDelegate * appDelegate;
    NSArray * array;
    
    NSInteger selectedRootViewRow;
    
    IBOutlet UITableView * tableView;
    
    IBOutlet UIActivityIndicatorView * activity;
}

@property (nonatomic, assign) id <CreateObjectDetailDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView * tableView;

- (void) showSFMCreateObjectWithProcessID:(NSString *)processId processTitle:(NSString *)processTitle;
- (void) accessoryButtonTapped: (UIControl *) button withEvent:(UIEvent *) event;

@end

@protocol CreateObjectDetailDelegate <NSObject>

@optional
- (void) dismissSelf;
- (void) showSFMCreateObjectWithProcessID:(NSString *)processId processTitle:(NSString *)processTitle object_name:(NSString *) objectName;

@end
