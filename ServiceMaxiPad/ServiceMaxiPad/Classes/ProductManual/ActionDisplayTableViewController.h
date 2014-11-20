//
//  ActionDisplayTableViewController.h
//  ServiceMaxiPad
//
//  Created by Chinnababu on 18/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMActionSideBarViewController.h"

@protocol ProductManualDelegate

- (void)loadProductmanual;

@end

@interface ActionDisplayTableViewController : UITableViewController


@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) SMActionSideBarViewController *sideMenu;

@property (assign) id <ProductManualDelegate> delegate;

@end
