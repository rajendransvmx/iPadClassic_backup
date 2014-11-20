//
//  ActionDisplayTableViewController.m
//  ServiceMaxiPad
//
//  Created by Chinnababu on 18/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ActionDisplayTableViewController.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"

@interface ActionDisplayTableViewController ()

@end

@implementation ActionDisplayTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:kActionBgColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"list";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text =[self.list objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor colorWithHexString:kActionBgColor];
    
    UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(10,39
                                                                    , 295, 1)];
    seperatorLine.backgroundColor = [UIColor colorWithHexString:kSeperatorLineColor];
    [cell.contentView addSubview:seperatorLine];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 1)
    {
        [self.delegate loadProductmanual];
    }
    else
    {
        
    }
}



@end
