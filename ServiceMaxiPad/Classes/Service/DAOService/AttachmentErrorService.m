//
//  AttachmentErrorService.m
//  ServiceMaxiPad
//
//  Created by Vincent Sagar on 8/18/16.
//  Copyright © 2016 ServiceMax Inc. All rights reserved.
//

#import "AttachmentErrorService.h"
#import "AttachmentTXModel.h"
#import "ParserUtility.h"
#import "DBRequestUpdate.h"
#import "DatabaseConstant.h"
#import "DBRequestInsert.h"
#import "FactoryDAO.h"
#import "AttachmentDAO.h"
#import "TransactionObjectModel.h"
#import "TransactionObjectDAO.h"
#import "StringUtil.h"
#import "AttachmentUtility.h"

@implementation AttachmentErrorService
- (NSString*)tableName {
    
    return kAttachmentErrorTableName;
}


-(NSArray*)fetchAttachmentsErrorRecordsByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria withDistinctFlag:(BOOL)isDistinct{
    
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
                AttachmentTXModel *model = [[AttachmentTXModel alloc] init];
                NSDictionary *dict = [resultSet resultDictionary];
                [ParserUtility parseJSON:dict toModelObject:model withMappingDict:[AttachmentTXModel getMappingDictionary]];
                [records addObject:model];
            }
        }];
    }
    return records;

    
}

-(BOOL)insertAttachmentErrorTableWithModel:(AttachmentTXModel *)model{
    
    //TODO: Check the logic

    DBRequestInsert *insert = [[DBRequestInsert alloc] initWithTableName:kAttachmentErrorTableName andFieldNames:[self getAttachmentFields:model]];
    
    NSDictionary *dataDict = [self getDataDict:model];
    NSArray *models = @[[self getTransactiomModel:dataDict]];
    
    id <TransactionObjectDAO> transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    BOOL status = [transactionService insertTransactionObjects:models andDbRequest:[insert query]];
    return status;
}

-(BOOL)updateAttachmentErrorTableWithModel:(AttachmentTXModel *)attachmentModel{
    
    //TODO: Check the logic
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kAttachmentERlocalId operatorType:SQLOperatorEqual andFieldValue:attachmentModel.localId];
    
    id <TransactionObjectDAO> transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    BOOL status = [transactionService updateEachRecord:[self getDataDict:attachmentModel]
                                            withFields:[self getAttachmentFields:attachmentModel]
                                          withCriteria:[NSArray arrayWithObject:criteria]
                                         withTableName:kAttachmentErrorTableName];
    return status;
}

- (BOOL)deleteAttachmentsFromDBDirectoryForParentId:(NSString*)parentId
{
    
    //TODO: Check the logic
//    id <AttachmentDAO> attachmentService = [FactoryDAO serviceByServiceType:ServiceTypeAttachmentError];
//    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kAttachmentErrorParentSfId operatorType:SQLOperatorEqual andFieldValue:parentId];
//    NSArray *attachmentArray = [attachmentService fetchRecordsByFields:nil andCriteria:criteria withDistinctFlag:NO];
//    NSArray *downloadedAttachments = [AttachmentUtility downloadedAttachments];
//    
//    for (AttachmentTXModel *attachModel in attachmentArray)
//    {
//        NSRange range = [attachModel.name rangeOfString:@"." options:NSBackwardsSearch];
//        if (range.location != NSNotFound)
//        {
//            attachModel.extensionName = [attachModel.name substringFromIndex:range.location];
//            attachModel.extensionName = [attachModel.extensionName lowercaseString];
//            attachModel.nameWithoutExtension = [attachModel.name substringToIndex:range.location];
//            NSString *downloadedFileName = [AttachmentUtility fileNameForAttachment:attachModel];
//            attachModel.isDownloaded = [downloadedAttachments containsObject:downloadedFileName];
//            if (attachModel.isDownloaded)
//            {
//                [AttachmentUtility deleteAttachment:attachModel];
//            }
//        }
//    }
//    
//    [attachmentService deleteRecordsForParentId:parentId];
    
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kAttachmentERParentSFId operatorType:SQLOperatorEqual andFieldValue:parentId];
    
    BOOL status = [self deleteRecordsFromObject:[self tableName]
                                  whereCriteria:[NSArray arrayWithObject:criteria]
                           andAdvanceExpression:nil];
    return status;
}


#pragma mark -
#pragma mark Utility

- (NSMutableArray*)getAttachmentFields:(AttachmentTXModel*)model
{
    NSMutableArray *fields = [[NSMutableArray alloc] initWithArray:[[self getDataDict:model] allKeys]];
    return fields;
}

- (NSDictionary *)getDataDict:(AttachmentTXModel *)attachmentModel
{
    if (attachmentModel != nil){
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [dict setObject:![StringUtil isStringEmpty:attachmentModel.parentId] ? attachmentModel.parentId : @"" forKey:kAttachmentERParentSFId];
        [dict setObject:![StringUtil isStringEmpty:attachmentModel.idOfAttachment] ? attachmentModel.idOfAttachment : @"" forKey:kAttachmentERId];
        [dict setObject:![StringUtil isStringEmpty:attachmentModel.localId] ? attachmentModel.localId : @"" forKey:kAttachmentERlocalId];
        [dict setObject:![StringUtil isStringEmpty:attachmentModel.name] ? attachmentModel.name : @"" forKey:kAttachmentERName];
        [dict setObject:[NSNumber numberWithInteger:attachmentModel.errorCode] forKey:kAttachmentERErrorCode];
        [dict setObject:![StringUtil isStringEmpty:attachmentModel.errorMessage] ? attachmentModel.errorMessage : @"" forKey:kAttachmentERErrorMessage];
        return dict;
    }
    return nil;
}

- (TransactionObjectModel *)getTransactiomModel:(NSDictionary *)dataDict
{
    TransactionObjectModel *transactionModel = [[TransactionObjectModel alloc] initWithObjectApiName:kAttachmentErrorTableName];
    [transactionModel mergeFieldValueDictionaryForFields:dataDict];
    return transactionModel;
}

@end
