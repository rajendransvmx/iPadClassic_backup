//
//  SFMPageHistoryViewController.m
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 16/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SFMPageHistoryViewController.h"
#import "SFMPageHistoryHeaderSectionView.h"
#import "SFMPageHistoryInfo.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"
#import "SFMPageHistoryCell.h"
#import "TagManager.h"
#import "StringUtil.h"
#import "SFMPageViewModel.h"

@interface SFMPageHistoryViewController ()

@end

@implementation SFMPageHistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.shouldScrollContent = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect tableViewFrame = self.view.frame;
    tableViewFrame.origin.x = 10;
    tableViewFrame.size.width = self.view.frame.size.width - 20;
    tableViewFrame.origin.y = 10;
    tableViewFrame.size.height = self.view.frame.size.height - 40;
    self.historyTableView.frame = tableViewFrame;
    
    
    self.historyTableView.layer.borderColor = [UIColor colorWithHexString:kSeperatorLineColor].CGColor;
    self.historyTableView.layer.borderWidth = 1.0;
    self.historyTableView.layer.cornerRadius = 5.00;

    
    self.historyTableView.backgroundColor = [UIColor clearColor];
    self.historyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.historyTableView.tableHeaderView = [self viewForTableHeader];
    self.historyTableView.tableFooterView = [self viewForTableFooter];
    
    self.historyTableView.scrollEnabled = self.shouldScrollContent;
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setTableViewFrame];
}

- (void)setTableViewFrame
{
    
    CGFloat tableViewHeight = 0;
    CGFloat tableViewFooterHeight = CGRectGetHeight(self.historyTableView.tableFooterView.bounds);
    CGFloat tableViewHeaderHeight = CGRectGetHeight(self.historyTableView.tableHeaderView.bounds);
    tableViewHeight = tableViewFooterHeight+tableViewHeaderHeight;
    NSInteger numberOfRows = [self.historyInfo count] * 2;
    for (int rowIndex = 0; rowIndex<numberOfRows; rowIndex++) {
        tableViewHeight += 60;
    }
    
    CGFloat viewHeight = CGRectGetHeight(self.view.bounds);
    if (tableViewHeight<viewHeight-20) {
        CGRect frame = self.historyTableView.frame;
        frame.size.height = tableViewHeight+20;
        self.historyTableView.frame = frame;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    self.historyTableView = nil;
}

#pragma mark - UITableView Delegate and DataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.historyInfo count] * 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFMPageHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (cell == nil) {
        cell = [[SFMPageHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    
    cell.descriptionTitle.text = [self getDescriptionDataForIndex:indexPath.row];
    cell.descriptionTitle.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize16];
    
    cell.descriptionData.text = [self getDataForIndex:indexPath.row];
    cell.descriptionData.font = [UIFont fontWithName:kHelveticaNeueRegular size:kFontSize14];
    return cell;
}

- (UIView *)viewForTableHeader
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 06.0, self.historyTableView.frame.size.width, 60.0)];
  
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:headerView.frame];
    headerLabel.text = [self titleForHeaderInSection];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize20];
    headerLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [headerView addSubview:headerLabel];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}


- (UIView *) viewForTableFooter
{
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.historyTableView.frame.size.width, 60)];
    
    CGRect frame = CGRectMake(10, 15, 200, 40);
    
    UIButton *seeMore = [[UIButton alloc] initWithFrame:frame];
    seeMore.backgroundColor = [UIColor colorWithHexString:@"#FF6633"];;
    [seeMore setTitle:[[TagManager sharedInstance]tagByName:kTag_IncludeOnlineItems] forState:UIControlStateNormal];
    [seeMore setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    seeMore.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    seeMore.titleLabel.font = [UIFont fontWithName:kHelveticaNeueRegular  size:kFontSize16];
    [seeMore addTarget:self action:@selector(seeMoreClicked) forControlEvents:UIControlEventTouchUpInside];
    seeMore.userInteractionEnabled = YES;
    
    [footerView addSubview:seeMore];
    
    return footerView;
}

- (void)seeMoreClicked
{
    NSLog(@"Clicked");
}


#pragma mark -END

- (NSString *)titleForHeaderInSection
{
    NSString *title = @"";
    
    if (self.historyInfoType == HistoryTypeAccount) {
        title = [[TagManager sharedInstance] tagByName:kTag_AccountHistory];
    }
    else if (self.historyInfoType == HistoryTypeProduct){
        title =[[TagManager sharedInstance] tagByName:kTag_ProductHistory_Records];
    }
    return title;
}

- (NSString *)getDescriptionDataForIndex:(NSInteger)index
{
    NSInteger modValue = index % 2;
    if (modValue == 0) {
        return [[TagManager sharedInstance] tagByName:kTagServiceReportProblemDescription];
    }
    else{
        return [[TagManager sharedInstance] tagByName:kTagSfmCreatedDate];
    }
    return nil;
}


- (NSString *)getDataForIndex:(NSInteger)index
{
    NSString *string = @"";
    
    NSInteger modValue = index % 2;
    
    NSInteger value = index;
    if (index != 0) {
        value = index / 2;
    }
    
    SFMPageHistoryInfo *model = (SFMPageHistoryInfo *)[self.historyInfo objectAtIndex:value];
    
    if (modValue == 0) {
        string = model.problemDescription;
    }
    else{
        string = model.createdDate;
    }
    if ([StringUtil isStringEmpty:string]){
        string = @"--";
    }
    
    return string;
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self setTableViewFrame];
    
}

-(CGFloat)contentViewHeight
{
    CGFloat tableViewHeight = 0;
    CGFloat tableViewFooterHeight = 60;
    CGFloat tableViewHeaderHeight = 60;
    tableViewHeight = tableViewFooterHeight+tableViewHeaderHeight;
    NSInteger numberOfRows = [self.historyInfo count] * 2;
    for (int rowIndex = 0; rowIndex<numberOfRows; rowIndex++) {
        tableViewHeight += 60;
    }
    return tableViewHeight + 50;
}

- (void)resetViewPage:(SFMPageViewModel*)sfmViewPageModel
{
    if (self.historyInfoType == HistoryTypeProduct) {
        self.historyInfo = sfmViewPageModel.productHistory;
    }else if (self.historyInfoType == HistoryTypeAccount)
        self.historyInfo = sfmViewPageModel.accountHistory;
    [self.historyTableView reloadData];
}

@end
