//
//  DODRecordsService.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 14/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "DODRecordsService.h"

@implementation DODRecordsService

- (NSString *)tableName
{
    return @"DODRecords";
}

-(BOOL)deleteRecordWithSfId:(NSString *)sfId
{
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:@"parentLocalId"
                                                      operatorType:SQLOperatorEqual
                                                     andFieldValue:sfId];
    
    BOOL status = [self deleteRecordsFromObject:[self tableName]
                                  whereCriteria:[NSArray arrayWithObject:criteriaOne]
                           andAdvanceExpression:nil];
    return status;
}
@end
