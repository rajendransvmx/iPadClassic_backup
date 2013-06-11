//
//  OpenFlowAppViewController.h
//  OpenFlowApp
//
//  Created by Samman on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFOpenFlowView.h"

@class CalendarController;

@interface OpenFlowAppViewController : UIViewController
<AFOpenFlowViewDataSource,
AFOpenFlowViewDelegate>
{
    AFOpenFlowView * afopenflowView;
    IBOutlet UILabel * selectedItem;
    NSArray * itemList;
    CalendarController * calendar;
}

- (void) showTasks;
- (void) showCreateObject;
- (void) showSearch;
- (void) showCalendar;
- (void) showChatter;
- (void) showMap;
- (void) showRecents;
- (void) showHelp;

@end
