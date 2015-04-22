//
//  CreateObjectRoot.h
//  iService
//
//  Created by Samman on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@protocol CreateObjectRootDelegate;

@interface CreateObjectRoot : UITableViewController
{
    id <CreateObjectRootDelegate> delegate;
    AppDelegate * appDelegate;
    
    NSIndexPath * lastSelectedIndexPath;
    
    BOOL firstTimeLoad;
}

@property (nonatomic, assign) id <CreateObjectRootDelegate> delegate;

@end

@protocol CreateObjectRootDelegate <NSObject>

@optional
- (void) didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end