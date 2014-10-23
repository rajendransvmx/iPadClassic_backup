//
//  SFMPageShowAllViewController.h
//  ServiceMaxMobile
//
//  Created by Aparna on 18/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFMDebriefViewController.h"


@interface SFMPageShowAllViewController : UITableViewController <SFMDebriefViewControllerDelegate>

@property(nonatomic, retain) NSArray *selectedSectionViewControllers;


@end
