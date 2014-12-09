//
//  SLAClockViewController.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 06/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLAClock.h"

@interface SLAClockViewController : UIViewController
{
    IBOutlet UILabel *slaLabel;
    IBOutlet UIView *slaView;
}

@property(nonatomic, strong) SLAClock *slaClock;

- (CGFloat) contentViewHeight;


@end
