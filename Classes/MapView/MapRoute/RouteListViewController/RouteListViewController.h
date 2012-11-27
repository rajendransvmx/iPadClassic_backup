//
//  RouteListViewController.h
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/12.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteListViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView * tableView;
	NSArray *routes;
}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain) NSArray *routes;

- (NSString *)flattenHTML:(NSString *)html;

@end
