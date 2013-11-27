//
//  CreateObject.h
//  iService
//
//  Created by Samman on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SFMPageController.h"

#import "CreateObjectRoot.h"
#import "CreateObjectDetail.h"

@interface CreateObject : UIViewController
<UITableViewDataSource, 
UITableViewDelegate,
UIPopoverControllerDelegate,
CreateObjectDetailDelegate,
UISplitViewControllerDelegate>
{
    AppDelegate * appDelegate;
    IBOutlet UITableView * mTable;
    NSArray * tableArray;
    
    NSIndexPath * selectedIndexPath;
    
    UIActivityIndicatorView * activity;
}

@property (nonatomic, retain) NSArray * array;

- (IBAction) back;
- (IBAction) createObject;
- (void) showSFMCreateObjectWithProcessID:(NSString *)processId processTitle:(NSString *)processTitle;

// Display user name
- (IBAction) displayUser:(id)sender;

@end
