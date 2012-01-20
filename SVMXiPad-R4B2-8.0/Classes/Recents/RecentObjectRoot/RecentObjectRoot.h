//
//  RecentObjectRoot.h
//  iService
//
//  Created by Samman on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iServiceAppDelegate.h"

@protocol RecentObjectRootDelegate;

@interface RecentObjectRoot : UITableViewController
{
    id <RecentObjectRootDelegate> delegate;
    iServiceAppDelegate * appDelegate;
    NSMutableArray * recentObjectsArray;
    
    NSIndexPath * lastSelectedIndexPath;
    
    BOOL firstTimeLoad;
}

@property (nonatomic, assign) id <RecentObjectRootDelegate> delegate;
@property (nonatomic, retain) NSMutableArray * recentObjectsArray;

@end

@protocol RecentObjectRootDelegate <NSObject>

@optional
- (void) didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end