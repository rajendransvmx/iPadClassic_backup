//
//  SFMPageHistoryViewController.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 16/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFMPage.h"

typedef enum HistoryType : NSUInteger
{
    HistoryTypeNone = 0,
    HistoryTypeAccount = 1,
    HistoryTypeProduct = 2,
}
HistoryType;

@protocol SFMPageHistoryDelegate <NSObject>

-(void)reloadPageHistoryParentView;

@end


@interface SFMPageHistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(strong, nonatomic) IBOutlet UITableView *historyTableView;

@property(nonatomic,strong) NSArray *historyInfo;
@property(nonatomic,assign) HistoryType historyInfoType;
@property(nonatomic,assign) BOOL shouldScrollContent;
@property(nonatomic, strong) SFMPage *sfPage;
@property(nonatomic, weak) id <SFMPageHistoryDelegate> pageHistoryDelegate;
@property(nonatomic, assign) NSInteger selectedSection;

@end
