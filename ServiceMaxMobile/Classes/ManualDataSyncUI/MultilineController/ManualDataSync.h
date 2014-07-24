//
//  ManualDataSync.h
//  iService
//
//  Created by Parashuram on 14/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManualDataSyncDetail.h"
#import "WSInterface.h"
#import "ManualDataSyncRoot.h"

#import "SMProgressBar.h" //Data Purge

@interface ManualDataSync : UIViewController <UISplitViewControllerDelegate, ManualDataSync, SyncRootViewProtocolDelegate, manualDataSyncDetailView,SMProgressBarDelegate>
{
    ManualDataSyncRoot *dataSyncRoot ;
    ManualDataSyncDetail *dataSyncDetail;
    NSMutableArray * objectsArray;
    NSMutableArray * objectDetailsArray;
    
    NSMutableDictionary * objectsDict;
    
    /*Radha - Data Purge*/
    IBOutlet UIView *transperentView;
    SMProgressBar * progressBar;
    UIButton * cancelButton;
}

@property (nonatomic) BOOL didAppearFromSFMScreen;
@property (nonatomic) BOOL didAppearFromSyncScreen;
//Data Purge
- (void)registerForServiceMaxDataPurgeProgressNotification;
- (void)deregisterForServiceMaxDataPurgeProgressNotification;

@end
