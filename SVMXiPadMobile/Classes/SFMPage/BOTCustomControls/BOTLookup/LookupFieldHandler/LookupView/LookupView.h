//
//  LookupView.h
//  SVNTest
//
//  Created by Samman on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LookupDetails.h"
#import "ZKSforce.h"

@class iServiceAppDelegate;

@protocol LookupViewDelegate;

@interface LookupView : UIViewController
<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, LookupDetailsDelegate>
{
    id <LookupViewDelegate> delegate;
    
    iServiceAppDelegate * appDelegate;
    
    IBOutlet UISegmentedControl * segmentControl;
    IBOutlet UITableView * _tableView;
    NSDictionary * lookupData;
    UIPopoverController * popover;
    NSString * objectName, * searchKey ,* searchId;
    IBOutlet UIActivityIndicatorView * activity;
    
    IBOutlet UISearchBar * searchBar;
    
    LookupDetails * lookupDetails;
    ZKDescribeSObject * describeObject;
    
    BOOL history, idAvailable;
    //sahana offline
    NSMutableDictionary * label_key;
}
@property (nonatomic , retain) NSMutableDictionary * label_key;
@property (nonatomic, assign) id <LookupViewDelegate> delegate;
@property (nonatomic, retain) NSDictionary * lookupData;
@property (nonatomic, retain) UIPopoverController * popover;
@property (nonatomic, retain) NSString * objectName, * searchKey , * searchId;
@property BOOL history;

- (void) reloadData;
- (void) setLookupData:(NSDictionary *)_lookupDetails;
- (IBAction) segmentChanged:(id)sender;

@end

@protocol LookupViewDelegate

@optional
- (void) searchObject:(NSString *)keyword withObjectName:(NSString *)objectName returnTo:(id)caller setting:(BOOL)idAvailable;
//- (void) didSelectObject:(NSArray *)lookupObject;
- (void) didSelectObject:(NSArray *)lookupObject defaultDisplayColumn:(NSString *)defaultdisplayColumn;
- (void) getSearchIdandObjectName;

@end
