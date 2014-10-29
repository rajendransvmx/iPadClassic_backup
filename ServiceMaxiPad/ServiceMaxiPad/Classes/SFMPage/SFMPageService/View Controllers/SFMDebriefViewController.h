//
//  SFMDebriefViewController.h
//  ServiceMaxMobile
//
//  Created by Sahana on 12/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DebriefSectionView.h"
#import "SFMPageViewModel.h"

@protocol SFMDebriefViewControllerDelegate;


@interface SFMDebriefViewController : UIViewController  <UITableViewDelegate,UITableViewDataSource,DebriefSectionViewDelegate>
@property (retain, nonatomic) IBOutlet UITableView *debriefTableView;
@property (nonatomic,strong) SFMPageViewModel *sfmPageView;
@property (nonatomic) NSInteger selectedSection;
@property (nonatomic) BOOL isDetail;
@property (nonatomic) CGFloat cellGapFromBorder;
@property (nonatomic, assign)BOOL shouldScrollContent;
@property (nonatomic, assign) id <SFMDebriefViewControllerDelegate> debriefDelagte;

-(CGFloat)contentViewHeight;

- (void)resetViewPage:(SFMPageViewModel*)sfmViewPageModel;
@end



@protocol SFMDebriefViewControllerDelegate <NSObject>

-(void)reloadParentViewForSection:(NSInteger)section;

@end