//
//  ResetAppDetailViewController.h
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 03/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailParentViewController.h"
#import "SMAlertView.h"


@interface ResetAppDetailViewController : DetailParentViewController<SMAlertViewDelegate, UIAlertViewDelegate>
{
    
    IBOutlet UILabel *resetAppLabel;
    
    
    IBOutlet UIButton *resetAppBtn;
}

- (IBAction)resetAppClicked:(id)sender;



@end
