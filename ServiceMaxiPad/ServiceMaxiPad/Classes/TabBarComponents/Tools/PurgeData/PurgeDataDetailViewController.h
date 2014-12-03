//
//  PurgeDataDetailViewController.h
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 03/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailParentViewController.h"
#import "FlowNode.h"
#import "WebserviceResponseStatus.h"
#import "PurgeDataLoader.h"


@interface PurgeDataDetailViewController : DetailParentViewController<FlowDelegate>
{
    
    IBOutlet UILabel *purgeDataLabel;
    IBOutlet UIButton *purgeDataBtn;
}

- (IBAction)purgeDataClicked:(id)sender;

- (void)test;

@end
