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

@interface ProductManualMaster ()

@end

@implementation ProductManualMaster

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
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
    return 50.0f;
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
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 1)
    {
        [self getTroubleshootingDataForIndex:indexPath.row];
 
    }
    else
    {
        // TO do chatter 
    }
}

- (void)getTroubleshootingDataForIndex:(NSInteger)index
{
    ProductManualModel *model = [self.productDetailsArray objectAtIndex:index];
    ProductManualDetail *detailController = [self.smSplitViewController.viewControllers
                                             lastObject];
    if ((model.prod_manual_Id != nil) && (model.prod_manual_name != nil) )
    {
        NSString *title = [model.prod_manual_name substringToIndex:
                           [model.prod_manual_name length]-4];
        [detailController setContentWithItem:title];
        [detailController loadWebViewForTheProductName:model.prod_manual_name
                                    AndProductManualID:model.prod_manual_Id];
    }
}




@end
