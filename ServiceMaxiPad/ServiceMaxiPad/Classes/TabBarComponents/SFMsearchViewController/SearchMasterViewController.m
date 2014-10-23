//
//  SearchMasterViewController.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 07/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SearchMasterViewController.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "StringUtil.h"
#import "SFMSearchProcessModel.h"
#import "SearchProcessDAO.h"
#import "FactoryDAO.h"
#import "SearchDetailViewController.h"

#define SRCH_ROW_HEIGHT 60
@interface SearchMasterViewController ()

@end

@implementation SearchMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (NSArray *) getSearchProcessDataSource {
    
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFMSearchProcess];
    
    if ([daoService conformsToProtocol:@protocol(SearchProcessDAO)]) {
        self.searchProcessArray = [daoService fetchAllSearchProcess];
    }
    return self.searchProcessArray;
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getSearchProcessDataSource];
    [self reloadData];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchMasterTableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftPanelBG.png"]];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {

}

#pragma mark -
#pragma mark - Table View Data source and delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
        
        cell.textLabel.highlightedTextColor = [UIColor colorWithHexString:kWhiteColor];
        cell.detailTextLabel.highlightedTextColor = [UIColor colorWithHexString:kWhiteColor];
        UIView *bgColorView = [[UIView alloc] init];
        [bgColorView setBackgroundColor:[UIColor colorWithHexString:kMasterSelectionColor]];
        [cell setSelectedBackgroundView:bgColorView];
        
        UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(10, (SRCH_ROW_HEIGHT - 1), self.searchMasterTableView.frame.size.width - 10, 1)];
        seperatorView.backgroundColor = [UIColor colorWithHexString:kSeperatorLineColor];
        [cell.contentView addSubview:seperatorView];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithHexString:kOrangeColor];
    cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize18];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.font = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize14];
    
    SFMSearchProcessModel *model = [self.searchProcessArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = model.processName;
    cell.detailTextLabel.text = model.processDescription;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchProcessArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SRCH_ROW_HEIGHT;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Send the selected process to detail VC.
    [self selectedSearchProcess:[self.searchProcessArray objectAtIndex:indexPath.row]];
}

#pragma mark - Set view controllers to detail view.
- (void)selectedSearchProcess:(SFMSearchProcessModel *)searchProcessObject
{
    SearchDetailViewController *detailViewController = (SearchDetailViewController *)[self.containerViewControlerDelegate detailViewController];
    [detailViewController selectedProcess:searchProcessObject];
}

- (void)reloadData {
    
    [self.searchMasterTableView reloadData];
    
}



@end
