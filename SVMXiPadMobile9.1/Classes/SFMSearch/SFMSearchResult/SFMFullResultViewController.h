//
//  SFMFullResultViewController.h
//  SFMSearch
//
//  Created by Siva Manne on 12/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iServiceAppDelegate.h"
#import "LabelPOContentView.h"
#define SectionHeaderHeight      45 
@protocol SFMFullResultViewControllerDelegate
@optional
- (void) DismissSplitViewControllerByLaunchingSFMProcess;
-(void)LoadResultDetailViewController;
@end

@class iServiceAppDelegate;
@interface SFMFullResultViewController : UIViewController<SFMFullResultViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIPopoverControllerDelegate>
{
    iServiceAppDelegate * appDelegate;
    UIPopoverController * label_popOver;
    LabelPOContentView * label_popOver_content;
}
@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) NSString *objectName;
@property (nonatomic, retain) NSArray *tableHeaderArray;
@property (nonatomic, assign) BOOL isOnlineRecord;
@property (nonatomic, assign) id <SFMFullResultViewControllerDelegate> fullMainDelegate;
@property(nonatomic,retain) IBOutlet UITableView *resultTableView;
@property(nonatomic,retain) IBOutlet UIImageView *onlineImageView;
@property(nonatomic,retain) IBOutlet UIButton *actionButton,*detailButton;
- (IBAction)dismissView:(id)sender;
- (IBAction) accessoryButtonTapped:(id)sender;
- (void) tapRecognized:(id)sender;
@property(nonatomic,retain) IBOutlet UILabel *TitleForResultWindow;
@end
