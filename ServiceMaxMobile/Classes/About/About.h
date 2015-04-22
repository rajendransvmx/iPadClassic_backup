//
//  About.h
//  iService
//
//  Created by Samman on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface About : UIViewController
{
    IBOutlet UILabel * appVersionLabel;
    IBOutlet UILabel * userInfo;
    IBOutlet UILabel * userNameLabel, * userLoginLabel;
    
    UIPopoverController * popover;
}

@property (nonatomic, retain) UIPopoverController * popover;

@end
