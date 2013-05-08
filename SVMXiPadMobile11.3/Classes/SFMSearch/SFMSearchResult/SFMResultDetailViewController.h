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
#import <QuartzCore/QuartzCore.h>

@class SFMResultMasterViewController;
@class SFMResultMainViewController;
@class iServiceAppDelegate;

@protocol SFMResultDetailViewControllerDelegate
@optional
- (void) DismissSplitViewController;
-(void)presentProgressBar:(NSString *)object_name sf_id:(NSString *)sf_id reocrd_name:(NSString *)record_name;
-(void)dismissProgressBar;
@end

@interface SFMResultDetailViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,SFMFullResultViewControllerDelegate,UIPopoverControllerDelegate>
{
    iServiceAppDelegate * appDelegate;
    SFMFullResultViewController *resultViewController;
    UIPopoverController * label_popOver;
    LabelPOContentView * label_popOver_content;
    NSIndexPath         *lastSelectedIndexPath;
}
@property (nonatomic, retain) IBOutlet SFMResultMasterViewController *masterView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain)  UITableView *detailTable;
@property (nonatomic, retain) NSMutableArray *detailTableArray;
@property (nonatomic, retain) NSMutableDictionary *onlineDataDict;
@property (nonatomic, retain) NSString *sfmConfigName;
@property (nonatomic, assign) id<SFMResultDetailViewControllerDelegate> splitViewDelegate;
@property (nonatomic, assign) SFMResultMainViewController *mainView;
@property (nonatomic, retain) NSMutableArray          *tableDataArray;
@property (nonatomic, retain) NSMutableArray          *resultArray;
@property (nonatomic, assign) BOOL conflict;
@property (nonatomic, retain) NSMutableDictionary *onlineresultsObjectDict;
- (void)tapRecognized:(id)sender;
- (void) createTable;
- (void) showHelp;
- (void) showObjects:(NSArray *)tableData forAllObjects:(BOOL) makeOnlineSearch;
- (void) updateResultArray:(int) index;
- (void) accessoryButtonTapped:(id)sender;
- (void) onDemandDataFecthing:(id)sender;
- (int) getTagForRow:(int) row;
- (BOOL) isRecordPresentInOfflineResults:(NSArray *) offlineRecords record:(NSString *) onlineRecordId;
- (NSArray *) getOfflineRecordsForObjectID:(NSString *) objectID;
- (NSMutableArray *)getResultsForObject:(NSString *)object withConfigData:(NSDictionary *)dataForObject;
- (NSArray *) constructTableHeader : (NSArray *)data;
-(void) initilizeToolBar;
- (void) disableSFMUI;
- (void) enableSFMUI;
//- (void) presentProgressbarForFulview;

@end
