//
//  SyncMasterViewController.h
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 02/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMSplitViewController.h"

@interface SyncMasterViewController :UIViewController
{
    
    IBOutlet UIButton *syncStatusBtn;
    
    IBOutlet UIButton *resolveBtn;
    
    IBOutlet UIButton *purgeDataBtn;
    
    IBOutlet UIButton *pushLogBtn; /** This is wrong way, will refactor once this VC is taken up*/
    
    IBOutlet UIButton *notificationHistoryBtn;
    
    IBOutlet UIButton *textSizeBtn;
    
    
    
    IBOutlet UIButton *aboutBtn;
    
    
    IBOutlet UIButton *resetAppBtn;
    
    
    IBOutlet UIButton *signOutBtn;
    
    UIButton *selectedButton;
    
    
}

@property (nonatomic, weak) SMSplitViewController *smSplitViewController;
- (IBAction)syncStatusClicked:(id)sender;
- (IBAction)resolveConflictsClicked:(id)sender;


- (IBAction)purgeDataClicked:(id)sender;
- (IBAction)notificationHistoryClicked:(id)sender;

- (IBAction)textSizeClicked:(id)sender;

- (IBAction)aboutClicked:(id)sender;
- (IBAction)resetAppClicked:(id)sender;

- (IBAction)signOutClicked:(id)sender;




@end
