//
//  ChatterViewController.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 15/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ChatterViewController.h"
#import "TagManager.h"
#import "StyleManager.h"
#import "ChatterCell.h"
#import "ChatterFooterView.h"
#import "ChatterSectionView.h"
#import "ChatterManager.h"
#import "ChatterHelper.h"


@interface ChatterViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UILabel *topProductLabel;

@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *leftProductLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong)UIImageView *imageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightContraint;

@property NSInteger leftViewOriginalWidth;
@property NSInteger topViewOriginalHeight;

@end

@implementation ChatterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialSetUp];
    [self setUpTableView];
    
    [self pushProductIdToCache];
    
    ChatterManager *manager = [[ChatterManager alloc] init];
    
    [manager getProductIamgeAndChatterPostDetails];
    
    
    
}

- (void)initialSetUp
{
    self.navigationItem.titleView =  [UILabel navBarTitleLabel:[[TagManager sharedInstance] tagByName:kTagChatterTitle]];
    self.navigationController.navigationBar.barTintColor = [UIColor navBarBG]; //Only for iOS7.0 and more than 7.0
    self.navigationController.navigationBar.translucent = NO;
    
    self.leftViewOriginalWidth = self.leftViewWidthConstraint.constant;
    self.topViewOriginalHeight = self.topViewHeightContraint.constant;
}

- (void)pushProductIdToCache
{
    [ChatterHelper pushDataToCahcche:self.productId forKey:@"ChatterProductId"];
}

- (void)setUpTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:@"ChatterCell" bundle:nil] forCellReuseIdentifier:@"Chatter"];
    [self.tableView registerClass:[ChatterFooterView class] forHeaderFooterViewReuseIdentifier:@"Footer"];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = [self tableHeaderView];
    self.tableView.backgroundColor = [UIColor whiteColor];
}

- (void)updateLabelText:(UILabel *)label
{
    label.text = self.productName;
    label.textColor = [UIColor colorWithHexString:@"#262626"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        self.topViewHeightContraint.constant = 0;
        self.leftViewWidthConstraint.constant = self.leftViewOriginalWidth;
        [self updateLabelText:self.leftProductLabel];
    }
    else {
        self.leftViewWidthConstraint.constant = 0;
        self.topViewHeightContraint.constant = self.topViewOriginalHeight;
        [self updateLabelText:self.topProductLabel];
    }
    
    
    self.leftImageView.layer.cornerRadius = 150;
    self.leftImageView.layer.borderWidth = 1.0f;
    self.leftImageView.layer.borderColor = [UIColor colorWithHexString:kSeperatorLineColor].CGColor;
    
    self.topImageView.layer.cornerRadius = 70;
    self.topImageView.layer.borderWidth = 1.0f;
    self.topImageView.layer.borderColor = [UIColor colorWithHexString:kSeperatorLineColor].CGColor;
}

- (UIView *)tableHeaderView
{    
    CGRect frame = self.tableView.frame;
    
    ChatterSectionView *view = [[ChatterSectionView alloc] initWithFrame:CGRectMake(frame.origin.x,
                                                            frame.origin.y, frame.size.width, 50)];
    return view;
}

- (void)pushProductDetailsToCache
{
    
}

#pragma mark - TableView Delegate and DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Chatter" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[ChatterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Chatter"];
    }

    cell.separatorInset =  UIEdgeInsetsMake(0, 85, 0, 0);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    ChatterFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Footer"];
    
    if (footerView == nil) {
        footerView = [[ChatterFooterView alloc] initWithReuseIdentifier:@"Footer"];
    }
    return footerView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithHexString:kActionBgColor];
}

#pragma mark - End
@end
