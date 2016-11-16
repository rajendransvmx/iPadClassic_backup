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
    
    self.tableView.backgroundColor = [UIColor colorFromHexString:kActionBgColor];
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
    cell.backgroundColor = [UIColor colorFromHexString:kActionBgColor];
        cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueLight size:16.0];
    cell.textLabel.textColor = [UIColor colorFromHexString:kOrangeColor];
    
    UIView *seperatorLine = [[UIView alloc]initWithFrame:CGRectMake(10,39
                                                                    , 295, 1)];

    seperatorLine.backgroundColor = [UIColor colorFromHexString:kSeperatorLineColor];
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorFromHexString:kMasterSelectionColor]];
    [cell setSelectedBackgroundView:bgColorView];   
    [cell.contentView addSubview:seperatorLine];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        [self.delegate loadProductmanual];
    }
    else if (indexPath.row == 1)    
    {
        [self.delegate loadChatter];
    }
    if ([self.sideMenu hasShownSideBar])
    {
        [self.sideMenu dismissAnimated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)] ;
    view.backgroundColor =  [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}



@end
