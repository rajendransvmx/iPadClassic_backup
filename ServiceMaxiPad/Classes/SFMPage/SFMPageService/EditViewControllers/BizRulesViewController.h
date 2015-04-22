//
//  BizRulesViewController.h
//  ServiceMaxiPad
//
//  Created by Narendra on 11/8/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BizRuleTableViewCell.h"
@protocol BizRuleUIDelegate;

@interface BizRulesViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,BizRuleCellDelegate>
@property(nonatomic, strong) NSMutableArray *bizRulesArray;
@property(nonatomic, weak) id <BizRuleUIDelegate> deleagte;
@property(nonatomic, strong) NSMutableArray *dataArray;

- (IBAction)footerViewTapped:(id)sender;
- (void)showDisclosureButton;
- (void)hideDisclosureButton;


@end



#define BizTableViewHeight   82


@protocol BizRuleUIDelegate <NSObject>

- (void)dismissBizRuleUI;
@end