//
//  InitialSyncViewController.h
//  ServiceMaxMobile
//
//  Created by Damodar on 23/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PageViewController;
@interface InitialSyncViewController : UIViewController

@property (strong, nonatomic) IBOutlet PageViewController *pageViewController;
@property (strong, nonatomic) IBOutlet UILabel *progressMessage;
@property (strong, nonatomic) IBOutlet UIProgressView *progressIndicator;
@property (strong, nonatomic) IBOutlet UIView *tipsRotatorContainer;
@property (weak, nonatomic) IBOutlet UILabel *initialSyncTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel2;


@property (strong, nonatomic) IBOutlet UIPageControl *pageIndicator;


- (IBAction)pageIndicatorTapped:(id)sender;

@end
