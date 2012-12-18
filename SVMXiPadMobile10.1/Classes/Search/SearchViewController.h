//
//  SearchViewController.h
//  iService
//
//  Created by Samman on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SearchViewController : UIViewController
<UITableViewDataSource,
UITableViewDelegate,
UISearchBarDelegate>
{
    IBOutlet UITableView * mTable;
    NSArray * array;
    NSIndexPath * selectedIndexPath;
}

@property (nonatomic, retain) NSArray * array;

- (IBAction) cancel;

@end
