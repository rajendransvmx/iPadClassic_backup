//
//  TaskViewController.h
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 17/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskViewCell.h"
#import "iServiceAppDelegate.h"
#import "iOSInterfaceObject.h"
#import "CalendarController.h"

@interface TaskViewController : UITableViewController
{
    iServiceAppDelegate * appDelegate;
    iOSInterfaceObject * iOSObject;
    NSMutableArray * tasks;
    CalendarController * calendar;
    
    //Radha 12th August
    NSString * resultId;
    BOOL didGetId;
    NSInteger selectedRow;
}

@property (nonatomic, retain) NSMutableArray * tasks;
@property (nonatomic, retain) CalendarController * calendar;

- (void) refreshWithTasks:(NSMutableArray *)_tasks;
- (void) AddTaskWithText:(NSMutableArray *)task;
//- (void) addNewTask:(NSArray*)task;
- (void) addNewTask:(NSMutableArray*)task;



- (TaskViewCell *) createNewTaskCell;
- (UIImage *)getImageForPriority:(NSString *)priority;

@end
