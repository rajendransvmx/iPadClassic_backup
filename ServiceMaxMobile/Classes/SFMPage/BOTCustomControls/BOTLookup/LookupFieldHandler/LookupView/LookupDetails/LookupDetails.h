//
//  LookupDetails.h
//  SVNTest
//
//  Created by Samman on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LookupDetailsDelegate;

@interface LookupDetails : UIViewController
<UITableViewDelegate, UITableViewDataSource>
{
    id <LookupDetailsDelegate> delegate;
    UITableView * _tableView;
    NSArray * lookupDetailsArray;
    NSIndexPath * indexPath;
    IBOutlet UITableView *lookupDetailTable;
}

@property (nonatomic, assign) id <LookupDetailsDelegate> delegate;
@property (nonatomic, retain) NSArray * lookupDetailsArray;
@property (nonatomic, retain) NSIndexPath * indexPath;

@end

@protocol LookupDetailsDelegate <NSObject>

@optional
- (void)didSelectDetailAtIndexPath:(NSIndexPath *)indexPath;

@end