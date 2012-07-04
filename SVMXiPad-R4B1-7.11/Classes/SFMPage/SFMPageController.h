//
//  SFMPageController.h
//  iService
//
//  Created by Developer on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "DetailViewController.h"

@protocol SFMPageDelegate;

@interface SFMPageController : UIViewController
<UISplitViewControllerDelegate, DetailViewControllerDelegate>
{
    id <SFMPageDelegate> delegate;
    RootViewController * rootView;
    DetailViewController * detailView;
    UISplitViewController * splitView;
    UINavigationController * masterView, * detailViewController;
    UIBarButtonItem * barButton;
    UIPopoverController * popover;
    
    NSString * processId, * recordId, * objectName, * activityDate, * accountId, * topLevelId;
    
    BOOL _viewMode;
}

@property (nonatomic, retain) id <SFMPageDelegate> delegate;
@property (nonatomic, retain) RootViewController * rootView;
@property (nonatomic, retain) DetailViewController * detailView;

@property (nonatomic, retain) NSString * processId, * recordId, * objectName, * activityDate, * accountId, * topLevelId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mode:(BOOL)viewMode;

@end

@protocol SFMPageDelegate

@optional
- (void) Back:(id)sender;
-(void) BackOnSave;

@end
