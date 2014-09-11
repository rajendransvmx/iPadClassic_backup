//
//  RouteController.h
//  iService
//
//  Created by Samman Banerjee on 02/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteControllerCell.h"

@interface RouteController : UITableViewController
{
    NSArray * directionArray;
    CGRect sectionRect;
    CGRect tableRect;
    NSArray * workOrderArray;    // Contains work order numbers and corresponding addresses
}

@property (nonatomic, retain) NSArray * directionArray;
@property (nonatomic, retain) NSArray * workOrderArray;

- (RouteControllerCell *) createCustomCellWithId:(NSString *) cellIdentifier;
- (void) scrollToSection:(NSNumber *)index;

@end
