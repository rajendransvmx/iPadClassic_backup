//
//  SyncStatusView.h
//  iService
//
//  Created by Parashuram on 19/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSInterface.h"
#import "PopoverButtons.h"
#import "SMDataPurgeManager.h" /*Radha - Data Purge*/


@class AppDelegate;

@interface SyncStatusView : UIViewController<RefreshSyncStatus, RefreshMetaSyncStatus>
{
    AppDelegate * appDelegate;
    
    NSString * lastSyncTime;
    NSString * nextSyncTime;
    NSString * syncStatus;
    
    UILabel * lastSync;
    UILabel * nextSync;
	
	//7444
	UILabel * lastConfigTime;
	UILabel * nextConfigTime;
	
    UILabel * _status;
    UILabel * _statusForMetaSync;
    
    UIPopoverController * popOver;
    
    PopoverButtons * popOverButtons;
	UIView * view;
    
    /*Radha - Data Purge*/
    UILabel * lastDataPurge;
	UILabel * nextDataPurge;
    UILabel * dataPurgeStatus;
    
    /*Radha - Data Purge*/
    
}

@property (nonatomic, retain) UIPopoverController * popOver;
@property (nonatomic, retain) NSString * lastSyncTime;
@property (nonatomic, retain) NSString * nextSyncTime;
@property (nonatomic, retain) NSString * syncStatus;


-(NSString *)getSyncronisationStatus;

//7444
- (NSDateComponents *) getTodatDateComponents;
- (NSDictionary *) getRootPlistDictionary;
- (NSString *) updateLastDataSynctime;
- (NSString *) updateNextDataSyncTime;
- (NSString *) updateLastConfigsyncTime;
- (NSString *) updateNextConfigsyncTime;
- (void) refreshSyncTime;

/*Radha - Data Purge*/
- (void) addDataPurgeDetails;

@end
