//
//  SyncStatusDetailViewController.h
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 02/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailParentViewController.h"
#import "SMAlertView.h"
#import "SMCheckBoxBindedAlertView.h"
#import "SMRegularAlertView.h"
#import "SMProgressAlertView.h"

@interface SyncStatusDetailViewController : DetailParentViewController <CheckBoxDelegate>

{
    IBOutlet UIButton *syncConfigBtn;
    
    IBOutlet UIButton *syncDataBtn;
    
    IBOutlet UILabel *dataSyncLastSyncLabel;
    
    IBOutlet UILabel *dataSyncStatusLabel;
    
    IBOutlet UILabel *dataSyncNextSyncLabel;
    
    IBOutlet UILabel *configSyncLastSyncLabel;
    
    IBOutlet UILabel *configSyncNextSyncLabel;
    
    IBOutlet UILabel *configSyncStatusLabel;
    
}

- (IBAction)syncConfigClicked:(id)sender;
- (IBAction)syncDataClicked:(id)sender;

- (void)startScheduledConfigSync;

@end
