//
//  TroubleShootDetailViewController.h
//  ServiceMaxMobile
//
//  Created by Chinnababu on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMSplitViewController.h"

@interface TroubleshootingDetailViewController : UIViewController<SMSplitViewControllerDelegate>
@property(nonatomic,assign)SMSplitViewController *smSplitViewController;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property(strong, nonatomic)IBOutlet UIButton *masterViewButton;
@property(strong,nonatomic)NSData *data;
-(void)loadwebViewForThedocId:(NSString *)docId
        andThedocName:(NSString *)docName;


@end
