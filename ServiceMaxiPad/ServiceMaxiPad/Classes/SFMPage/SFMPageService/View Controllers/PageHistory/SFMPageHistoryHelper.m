//
//  SFMPageHistoryHelper.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 25/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "SFMPageHistoryHelper.h"
#import "SFMPageHelper.h"
#import "NonTagConstant.h"
#import "SFMPageHistoryInfo.h"
#import "CacheManager.h"

@implementation SFMPageHistoryHelper

+ (TransactionObjectModel *)getAccountHistoryInfo:(NSString *)objectName recordId:(NSString *)recordId
{
    TransactionObjectModel *model = [SFMPageHelper getRequiredInfoForPageHistory:objectName
                                                                         localId:recordId
                                                                          fields:[self accountHistoryFields]];
    
    return model;
}
+ (TransactionObjectModel *)getProductHistoryInfo:(NSString *)objectName recordId:(NSString *)recordId
{
    TransactionObjectModel *model = [SFMPageHelper getRequiredInfoForPageHistory:objectName
                                                                         localId:recordId
                                                                          fields:[self productHistoryFields]];
    return model;
}

+ (NSArray *)accountHistoryFields
{
    return @[kWorkOrderCompanyId, kId, kTextCreateDate];
}

+ (NSArray *)productHistoryFields
{
    return @[kComponentId, kTopLevelId, kId, kTextCreateDate];
}

+ (void)pushPageHistoryResultsToCache:(NSArray *)resultSet
{
    NSMutableArray *historyInfo = [NSMutableArray new];
    
    for (NSDictionary *dict in resultSet) {
        SFMPageHistoryInfo *model = [[SFMPageHistoryInfo alloc] initWithDictionary:dict];
        if (model != nil) {
            [model updateCreatedDateToUserRedableFormat];
            [historyInfo addObject:model];
        }
    }
    [[CacheManager sharedInstance] pushToCache:historyInfo byKey:@"PageHistoryResults"];
}

@end
