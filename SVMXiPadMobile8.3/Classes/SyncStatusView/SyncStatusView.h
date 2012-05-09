//
//  SyncStatusView.h
//  iService
//
//  Created by Parashuram on 19/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSInterface.h"

@class iServiceAppDelegate;

@interface SyncStatusView : UIViewController<RefreshSyncStatus>
{
    iServiceAppDelegate * appDelegate;
    
    NSString * lastSyncTime;
    NSString * nextSyncTime;
    NSString * syncStatus;
    
    UILabel * lastSync;
    UILabel * nextSync;
    UILabel * _status;
    
    UIPopoverController * popOver;
}

@property (nonatomic, retain) UIPopoverController * popOver;
@property (nonatomic, retain) NSString * lastSyncTime;
@property (nonatomic, retain) NSString * nextSyncTime;
@property (nonatomic, retain) NSString * syncStatus;


-(NSString *)getSyncronisationStatus;

@end
