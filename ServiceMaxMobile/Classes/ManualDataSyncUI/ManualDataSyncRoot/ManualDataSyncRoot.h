//
//  ManualDataSyncRoot.h
//  iService
//
//  Created by Parashuram on 14/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ManualDataSyncRootDelegate;
@class ManualDataSyncDetail;

@interface ManualDataSyncRoot : UITableViewController <UITableViewDataSource, UITableViewDelegate>
{
    
    id <ManualDataSyncRootDelegate> dataSyncRootDelegate;
    
    NSIndexPath * lastSelectedIndexPath;
    UILabel * lab;
    NSMutableArray * recordIdArray;
    NSMutableArray * objectsArray;
    
    NSMutableDictionary * objectsDict;
    NSMutableArray * objectDetailsArray;
    BOOL attachmentErrorExists;
}


@property (nonatomic, assign) id <ManualDataSyncRootDelegate> dataSyncRootDelegate;

@property (nonatomic, retain) NSMutableArray * recordIdArray;
@property (nonatomic, retain) NSMutableArray * objectsArray;

@property (nonatomic, retain) NSMutableDictionary * objectsDict;
@property (nonatomic, retain) NSMutableArray * objectDetailsArray;

- (void)reloadViews;//9195
@end;

@protocol ManualDataSyncRootDelegate <NSObject>

@optional
- (void) didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void) didSelectHeader :(id) sender;
- (void) rowSelected;
@end


