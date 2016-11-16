//
//  ProductManualMaster.m
//  ServiceMaxiPad
//
//  Created by Chinnababu on 06/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ProductManualMaster.h"
#import "ProductManualModel.h"
#import "ProductManualDetail.h"
#import "StyleGuideConstants.h"
#import "StyleManager.h"

@interface ProductManualMaster ()

@property (nonatomic) BOOL isSelected;


@end

@implementation ProductManualMaster

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.isSelected = NO;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftPanelBG.png"]];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.productDetailsArray count] ;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TroubleshootCell";
   
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    }
    
    ProductManualModel *model =[self.productDetailsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = model.prod_manual_name;
    cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize18];
    cell.textLabel.textColor = [UIColor colorFromHexString:kOrangeColor];
    cell.textLabel.highlightedTextColor = [UIColor colorFromHexString:kWhiteColor];
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor colorFromHexString:kMasterSelectionColor]];
    [cell setSelectedBackgroundView:bgColorView];
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self getTroubleshootingDataForIndex:indexPath.row];
 }

- (void)getTroubleshootingDataForIndex:(NSInteger)index
{
    ProductManualModel *model = [self.productDetailsArray objectAtIndex:index];
    ProductManualDetail *detailController = [self.smSplitViewController.viewControllers
                                             lastObject];
    if ((model.prod_manual_Id != nil) && (model.prod_manual_name != nil) )
    {
        NSString *title = [[model.prod_manual_name lastPathComponent] stringByDeletingPathExtension];
        [detailController setContentWithItem:title];
        [detailController loadWebViewForTheProductName:model.prod_manual_name
                                    AndProductManualID:model.prod_manual_Id];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)] ;
    view.backgroundColor =  [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}





@end
