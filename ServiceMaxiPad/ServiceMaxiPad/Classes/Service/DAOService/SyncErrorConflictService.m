//
//  SyncErrorConflictService.m
//  ServiceMaxMobile
//
//  Created by Pushpak on 17/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SyncErrorConflictService.h"
#import "DatabaseConstant.h"

@implementation SyncErrorConflictService


-(NSString *)tableName
{
    return kSyncErrorConflictTableName;
}


- (NSArray *)fieldNamesToBeRemovedFromQuery
{
    return @[@"objectLabel", @"recordValue", @"isWorkOrder", @"accountValue",@"scLocalId"];
}

- (BOOL)removeLocalIdField {
    return NO;
}

- (BOOL)enableInsertOrReplaceOption {
    return YES;
}
@end
