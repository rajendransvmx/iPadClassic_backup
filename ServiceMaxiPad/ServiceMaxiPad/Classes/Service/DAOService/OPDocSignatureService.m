//
//  OPDocSignatureService.m
//  ServiceMaxiPad
//
//  Created by Damodar on 29/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "OPDocSignatureService.h"
#import "DBRequestInsert.h"
#import "DBRequestUpdate.h"
#import "DBRequestSelect.h"
#import "DBCriteria.h"
#import "DatabaseManager.h"

@implementation OPDocSignatureService


- (NSString *)tableName
{
    return @"OPDocSignature";
}

/* Add signatures and HTML file to tables */
- (void)addSignature:(OPDocSignature*)model
{
    [self saveRecordModel:model];
}

/* Update SFID of signatures and HTML file to tables */
- (void)updateSignature:(OPDocSignature*)model
{
    if(!model.sfid.length)
        return;
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kOPDocFileName operatorType:SQLOperatorEqual andFieldValue:model.Name];
    
    DBRequestUpdate * updatequery = [[DBRequestUpdate alloc] initWithTableName:[self tableName] andFieldNames:@[model.sfid] whereCriteria:@[criteria] andAdvanceExpression:nil];
    
    BOOL status = [self updateEachRecord:model withQuery:[updatequery query]];
    
    NSLog(@"Update %d signature file %@ :: %@",status, model.Name, model.sfid);
}

/* Get the model object for file name */
- (OPDocSignature*)getHTML:(NSString*)signatureName
{
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kOPDocFileName operatorType:SQLOperatorEqual andFieldValue:signatureName];
    
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:nil whereCriteria:criteria];
    __block OPDocSignature * model;
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {

        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        model = [[OPDocSignature alloc] init];
        if ([resultSet next]) {
            [resultSet kvcMagic:model];
        }
        [resultSet close];
    }];
    }
    return model;;

}

@end
