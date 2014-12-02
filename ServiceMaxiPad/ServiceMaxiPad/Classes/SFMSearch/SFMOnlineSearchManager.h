//
//  SFMOnlineSearchManager.h
//  ServiceMaxiPad
//
//  Created by Shubha S on 12/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMSearchProcessModel.h"
#import "FlowNode.h"
#import "TransactionObjectModel.h"

@protocol  SFMOnlineSearchManagerDelegate <NSObject>

- (void)onlineSearchSuccessfullwithResponse:(NSMutableDictionary *)dataArray
                           forSearchProcess:(SFMSearchProcessModel*)searchProcess
                              andSearchText:(NSString *)searchText;
- (void)onlineSearchFailedwithError:(NSError *)error forSearchProcess:(SFMSearchProcessModel*)searchProcess;

@end

@interface SFMOnlineSearchManager : NSObject<FlowDelegate>


@property(nonatomic,weak) id <SFMOnlineSearchManagerDelegate> viewControllerDelegate;




- (void)performOnlineSearchWithSearchProcess:(SFMSearchProcessModel *)searchProcess
                             andSearchText:(NSString *)searchText;
+ (BOOL)isOnlineRecord:(TransactionObjectModel*)transactionObjectModel;

- (void)cancelAllPreviousOperations;

@end


