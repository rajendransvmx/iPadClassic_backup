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
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    
    if (didOpen)
    {
        NSString * query = [requestSelect query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            
            DocumentModel * model = [[DocumentModel alloc] init];
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
    }
    return records;
}

- (NSArray*)getListOfDocument
{
    //   @"SELECT DeveloperName, Name From Document"]
    NSArray *documentModels = [self fetchRecordsByFields:@[@"developerName"] andCriteria:nil withDistinctFlag:NO];
    return documentModels;
}

-(void)updateDocumentTableWithModelArray:(NSArray*)modelArray
{
    NSArray * fieldsArray = [[NSArray alloc] initWithObjects:KDocName,KDocKeyWords, nil];
    DBCriteria * criteria1 = [[DBCriteria alloc] initWithFieldNameToBeBinded:KDocId];
    
    if([modelArray count] >0)
    {
        [self updateRecords:modelArray withFields:fieldsArray withCriteria:[NSArray arrayWithObjects:criteria1, nil]];
    }
}

- (NSArray*)getListOfDocumentToDownload
{
    //   @"SELECT DeveloperName, Name From Document"]
    NSArray *documentModels = [self fetchRecordsByFields:@[@"developerName",@"Name",@"Type",@"Id"] andCriteria:nil withDistinctFlag:NO];
    
    
    return documentModels;
}

- (NSArray *)getDocumentDetails:(NSString *)docId
{
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:@"Id" operatorType:SQLOperatorEqual andFieldValue:docId];
    
    return [self fetchRecordsByFields:@[@"developerName",@"Name",@"Type",@"Id"] andCriteria:criteria withDistinctFlag:YES];
}
-(NSString *)insertIntoDocumentsTableWithTheProductDetails:(NSArray *)productDetails
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

-(void)insertIntoDocumentsTableWithTheProductDetails_:(NSMutableArray *)productDetails
{
    
    
    DBRequestInsert *insert = [[DBRequestInsert alloc] initWithTableName:[self tableName] andFieldNames:productDetails];
    
    for(DocumentModel * model in productDetails){
        
        DocumentModel * model  = [[DocumentModel alloc] init];
        model.keywords = @"ads";
        
        NSDictionary * docDict  = [model dictionaryWithValuesForKeys:[NSArray arrayWithObjects:@"keywords",@"Id",@"Name", nil]];
        [self updateEachRecord:docDict withQuery:[insert query]];
    }
    
    
}
-(NSString *)getTheProductIdDetailsFromTheDocumentTableWithTheProductId:(NSString *)productId
{
    DBCriteria *criteria = [[DBCriteria alloc]initWithFieldName:KDocId
                                                   operatorType:SQLOperatorEqual andFieldValue:productId];
    DBRequestSelect *selectQuery = [[DBRequestSelect alloc]initWithTableName:[self tableName]
                                                               andFieldNames:@[KDocId] whereCriteria:criteria];
    
    BOOL didOpen = [[DatabaseManager sharedInstance] open];
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    
    DocumentModel * model = [[DocumentModel alloc] init];
    
    if (didOpen)
    {
        NSString * query = [selectQuery query];
        
        SQLResultSet * resultSet = [[DatabaseManager sharedInstance] executeQuery:query];
        
        while ([resultSet next]) {
            
            [resultSet kvcMagic:model];
            [records addObject:model];
        }
    }
    for (DocumentModel * model in records)
    {
        return model.Id;
    }
    return nil;
}


@end
