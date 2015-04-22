//
//  PushNotificationWebServiceHelper.h
//  ServiceMaxiPad
//
//  Created by Sahana on 06/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PushNotificationWebServiceProtocol.h"
#import "NotifiactionHelperProtocol.h"


@protocol APNSDownloadOnDemandDelegate <NSObject>

@optional
-(BOOL )downloadSuccessfully;
//- (void)downloadedSuccessfullyForSFMSearchObject:(SFMSearchObjectModel *)searchObject transactionObject:(TransactionObjectModel *)transactionModel;

//- (void)downloadCancelledForSFMSearchObject:(SFMSearchObjectModel *)searchObject transactionObject:(TransactionObjectModel *)transactionModel;

@end

@interface PushNotificationWebServiceHelper : NSObject <PushNotificationWebServiceProtocol>

@property(nonatomic, assign) id <NotifiactionHelperProtocol> delegate;

//-(void)startDownloadingRequest:()


@end
