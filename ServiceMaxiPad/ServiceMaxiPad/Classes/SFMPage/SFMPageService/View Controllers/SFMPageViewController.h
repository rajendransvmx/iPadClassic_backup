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
#import "PageEditViewController.h"

@interface SFMPageViewController : SMSplitViewController<WizardDelegate,PageEditViewControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic, strong)SFMPageViewModel *sfmPageView;
@property(nonatomic) BOOL invokedFromSearch;
@end
