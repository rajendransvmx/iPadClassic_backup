//
//  SFMPageHistoryViewController.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 16/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum HistoryType : NSUInteger
{
    HistoryTypeNone = 0,
    HistoryTypeAccount = 1,
    HistoryTypeProduct = 2,
}
HistoryType;


@interface SFMPageHistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(retain, nonatomic) IBOutlet UITableView *historyTableView;

@property(nonatomic,strong) NSArray *historyInfo;
@property(nonatomic,assign) HistoryType historyInfoType;
@property(nonatomic,assign) BOOL shouldScrollContent;

@end
