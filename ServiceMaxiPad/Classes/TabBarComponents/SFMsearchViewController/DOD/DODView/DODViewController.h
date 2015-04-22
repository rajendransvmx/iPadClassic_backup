//
//  DODViewController.h
//  ServiceMaxiPad
//
//  Created by Pushpak on 13/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFMSearchObjectModel.h"
#import "TransactionObjectModel.h"

@protocol DownloadOnDemandDelegate <NSObject>

@optional

- (void)downloadedSuccessfullyForSFMSearchObject:(SFMSearchObjectModel *)searchObject transactionObject:(TransactionObjectModel *)transactionModel;

- (void)downloadCancelledForSFMSearchObject:(SFMSearchObjectModel *)searchObject transactionObject:(TransactionObjectModel *)transactionModel;

@end


@interface CustomDODButton: UIButton
@end

@interface DODViewController : UIViewController<UIPopoverControllerDelegate>

- (void)setupDODWithDelegate:(id<DownloadOnDemandDelegate>)delegate
                searchObject:(SFMSearchObjectModel *)searchModel
        andTransactionObject:(TransactionObjectModel *)transactionModel;
@end
