//
//  SFMPageShowAllViewController.m
//  ServiceMaxMobile
//
//  Created by Aparna on 18/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageShowAllViewController.h"
#import "SFMPageLayoutViewController.h"

#define CELL_VIEW_TAG 999

@interface SFMPageShowAllViewController ()

@property(nonatomic, assign) int selectedSection;

@end

@implementation SFMPageShowAllViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 00, 10)];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    
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
    return [self.selectedSectionViewControllers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
         UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    id viewController = [self.selectedSectionViewControllers objectAtIndex:indexPath.row];
    
    [self addChildViewController:viewController];
    cell.contentView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, [viewController contentViewHeight]-10);
    UIView *view = [viewController view];
    view.frame = CGRectMake(0, 0, self.tableView.frame.size.width, [viewController contentViewHeight]-10);
    view.tag = CELL_VIEW_TAG;
    view.autoresizingMask =   UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth ;
    
    if ([viewController respondsToSelector:@selector(setScrollEnabled:)]) {
        [viewController setScrollEnabled:NO];
        
    }
    [cell.contentView addSubview:view];
    [viewController didMoveToParentViewController:self];

    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id viewController = [self.selectedSectionViewControllers objectAtIndex:indexPath.row];
    return [viewController contentViewHeight]-10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}


#pragma mark -
#pragma mark SFMDebriefViewControllerDelegate Methods

-(void)reloadParentViewForSection:(NSInteger)section
{
    NSArray *array = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:section inSection:0], nil];
    [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
}

- (void)resetViewPage:(SFMPageViewModel*)pageViewModel
{
    for (int i=0; i< [self.childViewControllers count];i++) {
       
        SFMPageLayoutViewController *childViewController = (SFMPageLayoutViewController*)[self.childViewControllers objectAtIndex:i];
        if ([childViewController respondsToSelector:@selector(resetViewPage:)]) {
            [childViewController resetViewPage:pageViewModel];
        }
    }
}

- (void)reloadPageHistoryParentView
{
    [self.tableView reloadData];
}


@end
