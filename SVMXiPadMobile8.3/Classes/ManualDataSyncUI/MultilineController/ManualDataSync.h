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

@interface ManualDataSync : UIViewController <UISplitViewControllerDelegate, ManualDataSync, SyncRootViewProtocolDelegate>
{
    ManualDataSyncRoot *dataSyncRoot ;
    ManualDataSyncDetail *dataSyncDetail;
    NSMutableArray * objectsArray;
    NSMutableArray * objectDetailsArray;
    
    NSMutableDictionary * objectsDict;
}

@property (nonatomic) BOOL didAppearFromSFMScreen;
@property (nonatomic) BOOL didAppearFromSyncScreen;

@end
