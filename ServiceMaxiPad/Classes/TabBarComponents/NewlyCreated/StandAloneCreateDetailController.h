//
//  StandAloneCreateDetailController.h
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMSplitViewController.h"
#import "SFObjectModel.h"
#import "PageEditViewController.h"

@interface StandAloneCreateDetailController : UITableViewController<
SMSplitViewControllerDelegate,PageEditViewControllerDelegate>

@property(nonatomic,assign)SMSplitViewController *smSplitViewController;
@property(nonatomic,strong)NSMutableArray *detailProcessArray;
@property(nonatomic,strong)SFObjectModel *objectModel;
- (void)reloaData;
@end
