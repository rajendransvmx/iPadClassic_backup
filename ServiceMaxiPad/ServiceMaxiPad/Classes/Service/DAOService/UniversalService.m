//
//  UniversalService.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 5/27/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "UniversalService.h"
#import "DatabaseManager.h"

@implementation UniversalService
-(BOOL)createTable:(NSString *)createQuery
{
    __block BOOL retValue = YES;
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        
        retValue = [db executeStatements:createQuery];
    }];
    }
    return retValue;
}

@end
