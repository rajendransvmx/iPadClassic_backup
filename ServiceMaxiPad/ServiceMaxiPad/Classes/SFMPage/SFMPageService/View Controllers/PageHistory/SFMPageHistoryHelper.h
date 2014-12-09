//
//  SFMPageHistoryHelper.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 25/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionObjectModel.h"

@interface SFMPageHistoryHelper : NSObject

+ (TransactionObjectModel *)getAccountHistoryInfo:(NSString *)objectName recordId:(NSString *)recordId;
+ (TransactionObjectModel *)getProductHistoryInfo:(NSString *)objectName recordId:(NSString *)recordId;

+ (void)pushPageHistoryResultsToCache:(NSArray *)resultSet;

@end
