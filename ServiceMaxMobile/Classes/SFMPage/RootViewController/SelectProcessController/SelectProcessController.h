//
//  SelectProcessController.h
//  iService
//
//  Created by Samman on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@protocol SelectProcessControllerDelegate;

@interface SelectProcessController:UIViewController
{
    id <SelectProcessControllerDelegate> delegate;
    AppDelegate * appDelegate;
    UIPopoverController * popOver;
    IBOutlet UITableView * table;
    
    CGFloat maxSize;
    
    NSMutableArray * array;
}

@property (nonatomic, assign) id <SelectProcessControllerDelegate> delegate;
@property (nonatomic, retain) UIPopoverController * popOver;

- (IBAction) Cancel:(id)sender;
- (IBAction) Done:(id)sender;

@end

@protocol SelectProcessControllerDelegate <NSObject>

@optional
- (void) didSwitchProcess:(NSDictionary *)newProcess;

@end