//
//  OpDocFilesTableViewController.m
//  ServiceMaxiPad
//
//  Created by Rahman Sab C on 26/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "OpDocFilesTableViewController.h"
#import "TagManager.h"

@interface OpDocFilesTableViewController ()

@end

@implementation OpDocFilesTableViewController

@synthesize opDocFiles;

#pragma mark - View life cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preferredContentSize = CGSizeMake(450, 400);
    self.tableView.rowHeight = 40;
    self.navigationItem.title = [[TagManager sharedInstance] tagByName:KTagOpDocReportTitle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.opDocFiles.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"OpDocTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // Configure the cell...
    
    UILabel *numberLabel = nil;
    UILabel *nameLabel = nil;
    UIFont *textFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc ] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, tableView.rowHeight)];
        numberLabel.textAlignment = NSTextAlignmentCenter;
        numberLabel.font = textFont;
        [cell.contentView addSubview:numberLabel];
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(numberLabel.frame.origin.x + numberLabel.frame.size.width + 5, 0, self.preferredContentSize.width - 30, tableView.rowHeight)];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = textFont;
        [cell.contentView addSubview:nameLabel];
        
    }
    numberLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row + 1];
    nameLabel.text = [self.opDocFiles objectAtIndex:indexPath.row];
    nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    return cell;
}



@end
