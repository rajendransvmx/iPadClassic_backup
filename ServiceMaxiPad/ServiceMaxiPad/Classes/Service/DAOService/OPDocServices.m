//
//  OPDocServices.m
//  ServiceMaxiPad
//
//  Created by Damodar on 28/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "OPDocServices.h"
#import "DBRequestInsert.h"
#import "DBRequestUpdate.h"
#import "DBRequestSelect.h"
#import "DBCriteria.h"

@implementation OPDocServices

- (NSString *)tableName
{
    return @"OPDocHTML";
}

/* Add signatures and HTML file to tables */
- (void)addHTMLfile:(OPDocHTML*)model
{
    [self saveRecordModel:model];
}

/* Update SFID of signatures and HTML file to tables */
- (void)updateHTML:(OPDocHTML*)model
{
    if(!model.sfid.length)
        return;
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kOPDocFileName operatorType:SQLOperatorEqual andFieldValue:model.Name];
    
    DBRequestUpdate * updatequery = [[DBRequestUpdate alloc] initWithTableName:[self tableName] andFieldNames:@[model.sfid] whereCriteria:@[criteria] andAdvanceExpression:nil];
    
    [[DatabaseManager sharedInstance] beginTransaction];
    BOOL status = [self updateEachRecord:model withQuery:[updatequery query]];
    [[DatabaseManager sharedInstance] commit];

    
    NSLog(@"Update %d HTML file %@ :: %@",status, model.Name, model.sfid);
}

/* Get the model object for file name */
- (OPDocHTML*)getHTML:(NSString*)htmlName
{
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kOPDocFileName operatorType:SQLOperatorEqual andFieldValue:htmlName];
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:nil whereCriteria:criteria];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        OPDocHTML * model = [[OPDocHTML alloc] init];
        
        if ([resultSet next]) {
            [resultSet kvcMagic:model];
        }
        return model;
    }
    return nil;

}

@end
