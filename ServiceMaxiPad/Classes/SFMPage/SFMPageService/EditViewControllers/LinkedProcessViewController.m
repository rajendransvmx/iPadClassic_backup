//
//  LinkedProcessViewController.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 09/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "LinkedProcessViewController.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "LinkedProcess.h"
#import "TagManager.h"

@interface LinkedProcessViewController ()

@end

@implementation LinkedProcessViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundColor = [UIColor colorFromHexString:kActionBgColor];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
   /* UIView *view = self.view;
    while (view != nil) {
        view = view.superview;
        if (view.layer.cornerRadius > 0) {
            view.layer.cornerRadius = 2.0;
            view = nil;
        }
    }*/
    self.view.superview.layer.cornerRadius = 0;
    self.preferredContentSize = self.tableView.contentSize;
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.preferredContentSize = self.tableView.contentSize;

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.linkedProces count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIndentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIndentifier"];
    }
    else {
        [self removeSubView:cell];
    }
    
    CGRect frame = cell.contentView.frame;
    
    LinkedProcess *model = [self.linkedProces objectAtIndex:indexPath.row];
    
    if (model != nil) {
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, frame.origin.y,
                                                                       frame.size.width, frame.size.height)];
        textLabel.text = model.processName;
        textLabel.textColor = [UIColor colorFromHexString:@"#E15001"];
        textLabel.font = [UIFont fontWithName:kHelveticaNeueThin size:kFontSize16];
        textLabel.numberOfLines = 2;
        
        [cell.contentView addSubview:textLabel];
    }
    if (([self.linkedProces count] - 1) != indexPath.row) {
        
        UIView *seperatorLine = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(frame) - 1, self.tableView.frame.size.width, 1)];
        seperatorLine.backgroundColor = [UIColor colorFromHexString:kSeperatorLineColor];
        
        [cell.contentView addSubview:seperatorLine];
    }
    cell.backgroundColor = [UIColor colorFromHexString:kActionBgColor];
    
    return cell;
}

- (void)removeSubView:(UITableViewCell *)cell
{
    NSArray *subViews = cell.contentView.subviews;
    for (UIView *view in subViews) {
        [view removeFromSuperview];
    }
}

- (void)removeHeaderSubView:(UITableViewHeaderFooterView *)view
{
    NSArray *subViews = view.contentView.subviews;
    for (UIView *view in subViews) {
        [view removeFromSuperview];
    }
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LinkedProcess *processModel = [self.linkedProces objectAtIndex:indexPath.row];
    
    if (processModel != nil) {
        
        processModel.objectName = self.objectName;
        processModel.recordId = self.recordId;
        
        if ([self.linkedProcessDelegate conformsToProtocol:@protocol(LinkedProcessDelegate)]) {
            [self.linkedProcessDelegate showLinkedProcess:processModel];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]])
    {
        [self removeHeaderSubView:(UITableViewHeaderFooterView *)view];
        
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.contentView.backgroundColor = [UIColor colorFromHexString:kActionBgColor];
      
        CGRect frame = headerView.contentView.frame;
      
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, frame.origin.y,
                                                                       frame.size.width, frame.size.height)];
        textLabel.text = [[TagManager sharedInstance]tagByName:kTag_LineItemActions];
        textLabel.textColor = [UIColor colorFromHexString:@"#434343"];
        textLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize16];
        [headerView addSubview:textLabel];
        
        UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(15, view.frame.size.height,
                                                                         tableView.frame.size.width, 1)];
        seperatorView.backgroundColor = [UIColor colorFromHexString:kSeperatorLineColor];
        [headerView.contentView addSubview:seperatorView];
    }
}

- (CGSize)getPopoverContentSize
{
    CGFloat tableViewHeight = 50;
    CGFloat tableViewHeaderHeight = 50;
    tableViewHeight += tableViewHeaderHeight;
    
    NSInteger numberOfRows = [self.linkedProces count] * 2;
    for (int rowIndex = 0; rowIndex<numberOfRows; rowIndex++) {
        tableViewHeight += 60;
    }
    if (tableViewHeight > 650) {
        tableViewHeight = 650;
    }
    return CGSizeMake(350, tableViewHeight);
}

@end
