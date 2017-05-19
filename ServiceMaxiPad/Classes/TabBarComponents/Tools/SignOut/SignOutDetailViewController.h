//
//  SignOutDetailViewController.h
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 03/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailParentViewController.h"

#import "SMAlertView.h"
#import "SMRegularAlertView.h"
#import "OauthConnectionHandler.h"


@interface SignOutDetailViewController : DetailParentViewController <SMAlertViewDelegate>
{
    IBOutlet UIView *seperatorLine;
    IBOutlet UILabel *signOutLabel;
    IBOutlet UIButton *signOutBtn;
    __weak IBOutlet UILabel *signOutTitle;
}

- (IBAction)signOutClicked:(id)sender;

@end
