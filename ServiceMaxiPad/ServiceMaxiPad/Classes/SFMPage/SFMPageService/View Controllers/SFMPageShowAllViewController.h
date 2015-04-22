//
//  SFMPageShowAllViewController.h
//  ServiceMaxMobile
//
//  Created by Aparna on 18/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFMDebriefViewController.h"
#import "SFMPageHistoryViewController.h"

@interface SFMPageShowAllViewController : UITableViewController <SFMDebriefViewControllerDelegate,SFMPageHistoryDelegate>

@property(nonatomic, strong) NSArray *selectedSectionViewControllers;

- (void)resetViewPage:(SFMPageViewModel*)pageViewModel;
@end
