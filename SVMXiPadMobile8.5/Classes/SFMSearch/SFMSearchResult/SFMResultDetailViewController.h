//
//  SFMResultDetailViewController.h
//  SFMSearch
//
//  Created by Siva Manne on 11/04/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFMFullResultViewController.h"
#import "LabelPOContentView.h"
@class SFMResultMasterViewController;
@class iServiceAppDelegate;

@protocol SFMResultDetailViewControllerDelegate
@optional
- (void) DismissSplitViewController;
@end

@interface SFMResultDetailViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,SFMFullResultViewControllerDelegate,UIPopoverControllerDelegate>
{
    iServiceAppDelegate * appDelegate;
    SFMFullResultViewController *resultViewController;
    UIPopoverController * label_popOver;
    LabelPOContentView * label_popOver_content;

}
@property (nonatomic, retain) IBOutlet SFMResultMasterViewController *masterView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain)  UITableView *detailTable;
@property (nonatomic, retain) NSMutableArray *detailTableArray;
@property (nonatomic, retain) NSMutableDictionary *onlineDataDict;
@property (nonatomic, retain) NSString *sfmConfigName;
@property (nonatomic, assign) id<SFMResultDetailViewControllerDelegate> splitViewDelegate;

- (void)tapRecognized:(id)sender;
- (BOOL) isRecordFound:(NSString *)value ;
- (void) createTable;
- (void) showHelp;
- (void) showObjects:(NSArray *)tableData forAllObjects:(BOOL) makeOnlineSearch;
- (void) accessoryButtonTapped:(id)sender;
- (NSMutableArray *)getResultsForObject:(NSString *)object withConfigData:(NSDictionary *)dataForObject;
- (NSArray *) constructTableHeader : (NSArray *)data;
@end
