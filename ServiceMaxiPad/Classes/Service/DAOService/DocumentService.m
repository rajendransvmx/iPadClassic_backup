//
//  DocumentService.m
//  ServiceMaxMobile
//
//  Created by Shubha S on 27/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "DocumentService.h"
#import "DocumentModel.h"
#import "DatabaseConstant.h"
#import "DBRequestUpdate.h"
#import "DBRequestSelect.h"
#import "DBRequestInsert.h"

@implementation DocumentService

- (NSString *)tableName
{
    return @"Document";
}

- (NSArray * )fetchRecordsByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria withDistinctFlag:(BOOL)isDistinct
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:[self tableName] andFieldNames:fieldNames whereCriteria:criteria];
    
    if (isDistinct) {
        
        [requestSelect setDistinctRowsOnly];
    }
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            
            DocumentModel * model = [[DocumentModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
        [resultSet close];
    }];
    }
    return records;
}

- (void)saveOPDocRecords:(NSArray*)modelArray
{
    NSMutableArray *fieldNames = [NSMutableArray arrayWithObjects:@"DeveloperName", @"Name", nil];
    DBRequestInsert *insert = [[DBRequestInsert alloc] initWithTableName:[self tableName] andFieldNames:fieldNames];
    
    DocumentModel * model = nil;
    for(model in modelArray)
    {
//        NSDictionary * docDict  = [model dictionaryWithValuesForKeys:[NSArray arrayWithObjects:@"DeveloperName",@"Name", nil]];
        [self updateEachRecord:model withQuery:[insert query]];
    }

}

- (NSArray*)getListOfDocument
{
    //   @"SELECT DeveloperName, Name From Document"]
    NSArray *documentModels = [self fetchRecordsByFields:@[@"DeveloperName"] andCriteria:nil withDistinctFlag:NO];
    return documentModels;
}

-(void)updateDocumentTableWithModelArray:(NSArray*)modelArray
{
    
    NSArray * fieldsArray = [[NSArray alloc] initWithObjects:KDocName,KDocKeyWords,@"Type",@"Id",@"BodyLength",@"ContentType",@"Description",@"FolderId",@"NamespacePrefix", nil];
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldNameToBeBinded:@"DeveloperName"]; // OPDoc specific : DONOT change
    
    if([modelArray count] >0)
    {
        [self updateRecords:modelArray withFields:fieldsArray withCriteria:[NSArray arrayWithObjects:criteria1, nil]];
    }
}

- (NSArray*)getListOfDocumentToDownload
{
    //   @"SELECT DeveloperName, Name From Document"]
    NSArray *documentModels = [self fetchRecordsByFields:@[@"DeveloperName",@"Name",@"Type",@"Id"] andCriteria:nil withDistinctFlag:NO];
    
    
    return documentModels;
}

- (NSArray *)getDocumentDetails:(NSString *)docId
{
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:@"Id" operatorType:SQLOperatorEqual andFieldValue:docId];
    
    return [self fetchRecordsByFields:@[@"DeveloperName",@"Name",@"Type",@"Id"] andCriteria:criteria withDistinctFlag:YES];
}
- (NSString *)insertIntoDocumentsTableWithTheProductDetails:(NSArray *)productDetails
{
    NSMutableArray *array = [[NSMutableArray alloc]initWithObjects:KDocId,KDocKeyWords,KDocName, nil];
    DBRequestInsert *insert = [[DBRequestInsert alloc] initWithTableName:[self tableName] andFieldNames:array];
    for(DocumentModel * model in productDetails)
    {
        NSDictionary * docDict  = [model dictionaryWithValuesForKeys:[NSArray arrayWithObjects:KDocName,KDocId,nil]];
        [self updateEachRecord:docDict withQuery:[insert query]];
    }
    return nil;
    
}

-(NSString *)getTheProductIdDetailsFromTheDocumentTableWithTheProductId:(NSString *)productId
{
    DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:KDocId
                                                   operatorType:SQLOperatorEqual andFieldValue:productId];
    DBRequestSelect *selectQuery = [[DBRequestSelect alloc]initWithTableName:[self tableName]
                                                               andFieldNames:@[KDocId] whereCriteria:criteria];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    DocumentModel * model = [[DocumentModel alloc] init];
    @autoreleasepool {
    DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
    
    [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
        NSString * query = [selectQuery query];
        
        SQLResultSet * resultSet = [db executeQuery:query];
        
        while ([resultSet next]) {
            
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
        [resultSet close];
    }];
    }
    for (DocumentModel * model in records)
    {
        return model.Id;
    }
    return nil;
}

- (BOOL )insertIntoDocumentsWithTheProductDetails:(NSArray *)productDetails
{
    NSMutableArray *array = [[NSMutableArray alloc]initWithObjects:KDocId,KDocKeyWords,KDocName,@"Type", nil];
    DBRequestInsert *insert = [[DBRequestInsert alloc] initWithTableName:[self tableName] andFieldNames:array];
    BOOL value = false;
    for(DocumentModel *model in productDetails)
    {
        value = [self updateEachRecord:model withQuery:[insert query]];
    }
    
    if(value)
    {
        return true;
    }
    else
    {
        return false;
    }
}



@end
