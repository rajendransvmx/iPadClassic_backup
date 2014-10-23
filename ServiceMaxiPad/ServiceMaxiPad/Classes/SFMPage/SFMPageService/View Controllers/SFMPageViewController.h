//
//  SFMPageViewController.h
//  ServiceMaxMobile
//
//  Created by Aparna on 01/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SMSplitViewController.h"
#import "SFMPageViewModel.h"
#import "WizardViewController.h"

@interface SFMPageViewController : SMSplitViewController<WizardDelegate>

@property(nonatomic, strong)SFMPageViewModel *sfmPageView;

@end
