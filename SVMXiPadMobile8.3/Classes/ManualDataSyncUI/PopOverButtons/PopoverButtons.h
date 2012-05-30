//
//  PopoverButtons.h
//  ManualDataSyncUI
//
//  Created by Parashuram on 12/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iServiceAppDelegate.h"

@protocol MyPopoverDelegate <NSObject>
-(void)dismisspopover;
- (void) activityStart;
- (void) activityStop;
//Radha
- (void) throwException;
- (void) enableControls;
- (void) disableControls;

@end

@class ManualDataSyncDetail;


@interface PopoverButtons : UIViewController <UIPopoverControllerDelegate>
{
    id<MyPopoverDelegate> delegate;
    
    UIButton *button;
    UIButton *button1;
    UIButton *button2;
    
    NSMutableArray * objectsArray;
    NSMutableDictionary * objectsDict;
    NSMutableArray * objectDetailsArray;
    UIPopoverController * popover;
    
    
    iServiceAppDelegate * appDelegate;
    
    //RADHA - 21 MARCH
    BOOL syncConfigurationFailed;
    ManualDataSyncDetail * detail;
    
    BOOL fullDataSyncFailed;
    
}

@property (nonatomic , retain)  UIPopoverController * popover;

@property (nonatomic, assign) id<MyPopoverDelegate> delegate;
@property (nonatomic, retain) UIButton *button;
@property (nonatomic, retain) UIButton *button1;
@property (nonatomic, retain) UIButton *button2;

@property (nonatomic, retain) NSMutableDictionary * objectsDict;
@property (nonatomic, retain) NSMutableArray * objectDetailsArray;
@property (nonatomic, retain) NSMutableArray * objectsArray;

- (void) Syncronise;
- (void) synchronizeConfiguration;
- (void) synchronizeEvents;
- (void) schdulesynchronizeConfiguration;


- (void) startSyncEvents;

@end
