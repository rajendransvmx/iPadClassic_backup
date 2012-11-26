//
//  MasterViewController.m
//  SVMXiPadMobileLogger
//
//  Created by Siva Manne on 07/11/12.
//  Copyright (c) 2012 Siva Manne. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "AppLogsViewController.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Master", @"Master");
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    return self;
}
							
- (void)dealloc
{
    [_detailViewController release];
    [_objects release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!_objects)
        _objects = [[NSMutableArray alloc] init];
    [_objects insertObject:@"View Saved Logs" atIndex:0];
    [_objects insertObject:@"View Log From Device" atIndex:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    if([indexPath row] == 0)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.textLabel.text = _objects[indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // NSDate *object = _objects[indexPath.row];
    if(indexPath.row == 0)
    {
        NSLog(@"Push New View Controller");
        AppLogsViewController *logsViewController = [[AppLogsViewController alloc] init];
        logsViewController.detailViewController = self.detailViewController;
        [self.navigationController pushViewController:logsViewController animated:YES];
        [logsViewController release];
    }
    else
    {
        self.detailViewController.isLogFromFileSystem = 1;
        self.detailViewController.detailItem = _objects[indexPath.row];
        NSLog(@"Display Device Log");
    }
}

@end
