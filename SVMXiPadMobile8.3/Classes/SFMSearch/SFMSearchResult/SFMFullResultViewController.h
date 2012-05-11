//
//  SFMFullResultViewController.h
//  SFMSearch
//
//  Created by Siva Manne on 12/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iServiceAppDelegate.h"
#define SectionHeaderHeight      45 
@protocol SFMFullResultViewControllerDelegate
@optional
- (void) DismissSplitViewControllerByLaunchingSFMProcess;
@end

@class iServiceAppDelegate;
@interface SFMFullResultViewController : UIViewController<SFMFullResultViewControllerDelegate>
{
    iServiceAppDelegate * appDelegate;
}
@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) NSArray *tableHeaderArray;
@property (nonatomic, assign) BOOL isOnlineRecord;
@property (nonatomic, assign) id <SFMFullResultViewControllerDelegate> fullMainDelegate;
@property(nonatomic,retain) IBOutlet UIButton *actionButton,*detailButton;
- (IBAction)dismissView:(id)sender;
- (IBAction) accessoryButtonTapped:(id)sender;
@end
