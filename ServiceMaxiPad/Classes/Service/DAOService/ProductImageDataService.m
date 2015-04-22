//
//  ProductImageDataService.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 08/01/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "ProductImageDataService.h"
#import "DBRequestDelete.h"
#import "DBRequestInsert.h"
#import "DBRequestSelect.h"

@implementation ProductImageDataService

- (BOOL)deleteRecord:(DBCriteria *)criteria
{
    DBRequestDelete *deleteQuery = [[DBRequestDelete alloc] initWithTableName:[self tableName] whereCriteria:@[criteria] andAdvanceExpression:nil];
    
    return [self executeStatement:[deleteQuery query]];
}

- (NSString *)tableName
{
    return @"ProductImageData";
}

@end
