//
//  PageEditDetailViewController.h
//  ServiceMaxMobile
//
//  Created by shravya on 29/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFMPage.h"
#import "SFMPageEditManager.h"
#import "PageEditViewController.h"
#import "ChildEditViewControllerDelegate.h"
#import "BizRulesViewController.h"

@interface PageEditDetailViewController : UIViewController <PageEditViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,SMSplitViewControllerDelegate,ChildEditViewControllerDelegate ,BizRuleUIDelegate> {
    
    
}

@property(nonatomic,strong)SFMPage *sfmPage;
@property(nonatomic,assign)id  containerViewControlerDelegate;
@property(nonatomic,strong)IBOutlet UITableView *tableView;

- (id)initWithSFPage:(SFMPage *)sfPage;
- (void)addChildViewControllersToData:(NSArray *)newChildViewControllers;
- (NSArray *)allChildViewController;
- (void)reloadData;
- (void)setContentWithItem:(id)item;



@end


@protocol PageEditDetailViewControllerDelegate <NSObject>

- (CGFloat)heightOfTheView;
- (CGFloat)internalOffsetToSelectedIndex;
- (void)willRemoveViewFromSuperView;
- (void)resignAllFirstResponders;


@end