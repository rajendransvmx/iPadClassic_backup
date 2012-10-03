//
//  RootViewController.h
//  project
//
//  Created by Developer on 26/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZKSforce.h"
#import "SelectProcessController.h"

@class DetailViewController;

@class iServiceAppDelegate;

@protocol RootViewControllerDelegate;

#define SectionHeaderHeight      45  

#define BGIMAGETAG               1100
#define CELLLABELTAG             1101

@interface RootViewController : UITableViewController
<UISplitViewControllerDelegate,
SelectProcessControllerDelegate>
{
    UILabel * timeStamp ;
    UILabel * lastModifiedTime;
    id<RootViewControllerDelegate> delegate;
    iServiceAppDelegate * appDelegate;
    BOOL didLogin;
    BOOL isinViewMode;
    BOOL AdditionalInfo;
    BOOL Work_order;
    BOOL product_history;
    BOOL account_history;
    NSArray * addition_info_items;
    UIBarButtonItem * selProcessBarButtonItem;
    
    NSIndexPath * lastSelectedIndexPath;
    
    SelectProcessController * switchProcess;
}
@property (nonatomic , retain) NSArray * addition_info_items ;
@property (nonatomic) BOOL product_history;
@property (nonatomic) BOOL account_history;
@property (nonatomic) BOOL Work_order;
@property (nonatomic) BOOL AdditionalInfo;
@property (nonatomic, assign) id<RootViewControllerDelegate> delegate;
@property (nonatomic, retain)IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) iServiceAppDelegate *appDelegate;
@property (nonatomic ) BOOL isinViewMode;

- (void) receivedErrorFromAPICall:(NSError *)err;
- (void) describeSObject:(NSString *)sObjectType;
- (void) describeSObjectResult:(id)result error:(NSError *)error context:(id)context;
- (void) describeSObjects:(NSArray *)sObjectTypes;
- (void) describeSObjectsResult:(id)result error:(NSError *)error context:(id)context;

- (void) refreshTable;
- (void) displaySwitchViews;
- (void) showLastModifiedTimeForSFMRecord;

@end


@protocol RootViewControllerDelegate <NSObject>

@optional
- (void) didSelectRow:(NSInteger)row ForSection:(NSInteger)section;
- (void) didselectSection:(NSInteger) section;
- (void) didSwitchProcess:(NSDictionary *)newProcess;
@end
