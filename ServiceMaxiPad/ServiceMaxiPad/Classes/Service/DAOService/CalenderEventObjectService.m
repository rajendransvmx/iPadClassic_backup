//
//  CalenderEventObjectService.m
//  ServiceMaxMobile
//
//  Created by Sudguru Prasad on 07/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "CalenderEventObjectService.h"
#import "DBRequestSelect.h"
#import "DatabaseManager.h"
#import "CalenderEventObjectModel.h"
#import "SQLResultSet.h"
#import "SFObjectModel.h"
#import "FactoryDAO.h"
#import "TransactionObjectModel.h"
#import "SFObjectDAO.h"
#import "TransactionObjectDAO.h"

#import "DBRequestUpdate.h"

@implementation CalenderEventObjectService

- (NSArray*)getRecordsFromQuery:(NSString*)query
{
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            CalenderEventObjectModel * model = [[CalenderEventObjectModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
    }
    return records;
}

- (NSArray *)fetchDataForObject:(NSString *)objectName  fields:(NSArray *)fieldNames expression:(NSString *)advancaeExpression criteria:(NSArray *)criteria
{
    
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:advancaeExpression];
    
    NSArray * detailsArray = [self getRecordsFromQuery:selectQuery.query];
    return detailsArray;
}

-(NSDictionary *) fetchSFObjectTableDataForFields:(NSArray *)fieldNames criteria:(NSArray *)criteria andExpression:(NSString *)expression
{
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:kSFObject andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:expression];
    
    NSMutableDictionary *lDataDict = [[NSMutableDictionary alloc] init];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    if (didOpen)
    {
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:selectQuery.query];
        
        while ([resultSet next]) {
            SFObjectModel *lModel = [[SFObjectModel alloc] init];
            [resultSet kvcMagic:lModel];
            [lDataDict setObject:lModel.objectName forKey:lModel.keyPrefix];
        }
    }
    return lDataDict;
    
}

- (TransactionObjectModel *)getRecordForSalesforceId:(NSString *)salesforceId {
    
    if (salesforceId.length != 18) {
        return nil;
    }
    
    NSString *keyPrefix = [salesforceId substringToIndex:3];
    
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:@"keyPrefix" operatorType:SQLOperatorEqual andFieldValue:keyPrefix];
    
    id <SFObjectDAO> objectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObject];
    
    SFObjectModel *model = [objectService getSFObjectInfo:criteria fieldName:@[@"objectName"]];
    
    if (model.objectName != nil) {
        id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
        
        DBCriteria * innerCriteria = [[DBCriteria alloc] initWithFieldName:@"Id" operatorType:SQLOperatorEqual andFieldValue:salesforceId];
        
        NSArray *objects =   [transObjectService fetchDataForObject:model.objectName fields:nil expression:nil criteria:@[innerCriteria]];
        if ([objects count] > 0) {
            TransactionObjectModel *record =  [objects objectAtIndex:0];
            [record setObjectName:model.objectName];
            return record;
        }
    }
    
    return nil;
}

- (TransactionObjectModel *)getRecordForSalesforceId:(NSString *)salesforceId
                                      andDBCriterias:(NSArray *)dbCriterias
                               andAdvancedExpression:(NSString *)expression {
    
    if (salesforceId.length != 18) {
        return nil;
    }
    
    NSString *keyPrefix = [salesforceId substringToIndex:3];
    
    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:@"keyPrefix" operatorType:SQLOperatorEqual andFieldValue:keyPrefix];
    
    id <SFObjectDAO> objectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObject];
    
    SFObjectModel *model = [objectService getSFObjectInfo:criteria fieldName:@[@"objectName"]];
    
    if (model.objectName != nil) {
        id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
        
        NSArray *objects =   [transObjectService fetchDataForObject:model.objectName fields:nil expression:expression criteria:dbCriterias];
        
        if ([objects count] > 0) {
            TransactionObjectModel *record =  [objects objectAtIndex:0];
            [record setObjectName:model.objectName];
            return record;
        }
    }
    
    return nil;
}


-(BOOL)updateEachRecord:(NSDictionary *)dictionary  withFields:(NSArray *)fieldsArray withCriteria:(NSArray *)criteriaArray withTableName:(NSString *)tableName
{
    DBRequestUpdate * updatequery = [[DBRequestUpdate alloc] initWithTableName:tableName andFieldNames:fieldsArray whereCriteria:criteriaArray andAdvanceExpression:nil];
    [[DatabaseManager sharedInstance] beginTransaction];
    BOOL status = [self updateEachRecord:dictionary withQuery:[updatequery query]];
    [[DatabaseManager sharedInstance] commit];
    return status;
}

-(BOOL)updateEachRecord:(NSDictionary *)dictionary  withQuery:(NSString *)query_
{
    BOOL returnValue = NO;
    NSString *query =  query_;
    
    if (![[DatabaseManager sharedInstance] inTransaction]) {
        NSLog(@"You need to start the transcation to use this functions");
        return NO;
    }
    returnValue = [[DatabaseManager sharedInstance] executeUpdate:query
                                          withParameterDictionary:dictionary];
    return returnValue;
}


-(NSArray *)conflictStatusOfChildInTable:(NSString *)tableName withWhatID:(NSString *)whatID andLocalID:(NSString *)localID forParentTable:(NSString *)parentTableName
{
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldName:parentTableName operatorType:SQLOperatorEqual andFieldValue:whatID];
    DBCriteria * criteria2 = [[DBCriteria alloc] initWithFieldName:parentTableName operatorType:SQLOperatorEqual andFieldValue:localID];


        id <TransactionObjectDAO> transObjectService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
        
    
        NSMutableArray *objects =   (NSMutableArray *)[transObjectService fetchDataForObject:tableName fields:nil expression:@"(1 OR 2)" criteria:@[criteria1, criteria2]];
    
        if ([objects count] > 0) {
            for (int i = 0; i<objects.count; i++) {
                TransactionObjectModel *record =  [objects objectAtIndex:i];
                [record setObjectName:tableName];
                [objects replaceObjectAtIndex:i withObject:record];
            }
           
            return objects;
        }
    
    return nil;
}

- (NSArray *)fetchDataForIPObject:(NSString *)objectName fields:(NSArray *)fieldNames expression:(NSString *)advancaeExpression criteria:(NSArray *)criteria
{
    
    DBRequestSelect * selectQuery = [[DBRequestSelect alloc] initWithTableName:objectName andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:advancaeExpression];
    
    NSMutableArray * detailsArray = [self getDetailsDataForQuery:selectQuery];
    return detailsArray;
}

- (NSMutableArray *)getDetailsDataForQuery:(DBRequestSelect *)selectQuery
{
    NSMutableArray * detailsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [selectQuery query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            NSDictionary * dict = [resultSet resultDictionary];
            //Method in model to set the values
                          [detailsArray addObject:[dict valueForKey:kIPProductNameField]];
            
        }
    }
    return detailsArray;
}

@end
