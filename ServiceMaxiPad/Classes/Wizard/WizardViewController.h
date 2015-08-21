//
//  WizardViewController.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 09/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//


/**
 *  @file   WizardViewController.h
 *  @class  WizardViewController
 *
 *  @brief
 *
 *   This is a viewcontroller which has the business logic to disply wizard.
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <UIKit/UIKit.h>
#import "SMActionSideBarViewController.h"
#import "SFProcessModel.h"
#import "SFMPage.h"
#import "WizardComponentModel.h"
@protocol WizardDelegate

@optional
- (void)viewProcessTapped:(SFProcessModel*)sfProcess;
- (void)editProcessTapped:(NSString*)processId;
-(void)updateDODRecordFromSalesforce;
-(void)rescheduleEvent;
-(void)makeCustomUrlCall:(WizardComponentModel *)model;
-(void)makeWebserviceCall:(WizardComponentModel *)model;

- (void)loadTroublShootingViewForProduct;


//19-Aug-2015
-(void)displayProductIQViewController;

@end

@interface WizardViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong)NSArray *wizardsArray;
@property(nonatomic,strong)NSArray *viewProcessArray;
@property (nonatomic, strong) SMActionSideBarViewController *sideMenu;
@property(nonatomic, assign)BOOL shouldShowTroubleShooting;

@property (assign) id <WizardDelegate> delegate;

- (void)reloadTableView;

@end
