//
//  BizRulesViewController.h
//  ServiceMaxiPad
//
//  Created by Narendra on 11/8/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BizRuleUIDelegate;

@interface BizRulesViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic, strong) NSMutableArray *bizRulesArray;
@property(nonatomic, weak) id <BizRuleUIDelegate> deleagte;
@end



#define BizTableViewHeight   82


@protocol BizRuleUIDelegate <NSObject>

-(void)dismissBizRuleUIWithData:(NSMutableArray *)bizRuleArray;

@end