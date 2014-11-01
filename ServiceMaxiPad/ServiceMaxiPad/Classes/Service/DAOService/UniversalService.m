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
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    BOOL retValue = YES;
    if (didOpen)
    {
        [[DatabaseManager sharedInstance] beginTransaction];
        
        retValue = [[DatabaseManager sharedInstance] executeStatements:createQuery];
        
        [[DatabaseManager sharedInstance] commit];
    }
    return retValue;
}

@end
