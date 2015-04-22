//
//  AttachmentLocalService.m
//  ServiceMaxMobile
//
//  Created by Anoop on 03/13/2015.
//  Copyright (c) 2015 Servicemax. All rights reserved.
//

#import "AttachmentLocalService.h"
#import "AttachmentLocalModel.h"
#import "ParserUtility.h"
#import "DBRequestUpdate.h"

@implementation AttachmentLocalService

-(NSString*)tableName
{
    return kAttachmentLocalTableName;
}

-(NSArray*)fetchAllRecordsFromLocalAttachment
{
    return [super fetchDataForFields:nil criterias:nil objectName:[self tableName] andModelClass:[AttachmentLocalModel class]];
}

-(NSArray*)fetchRecordsFromLocalAttachmentFields:(NSArray*)fields
                                     andCriterias:(NSArray*)criterias
{
    return [super fetchDataForFields:fields criterias:criterias objectName:[self tableName] andModelClass:[AttachmentLocalModel class]];
}

-(BOOL)saveAttachmentLocalModel:(AttachmentLocalModel*)attachmentLocalModel
{
    return [super saveRecordModel:attachmentLocalModel];
}


-(BOOL)saveAttachmentLocalModels:(NSMutableArray*)attachmentLocalModels
{
    return [super saveRecordModels:attachmentLocalModels];
}


-(BOOL)deleteRecordsWithParentLocalIds:(NSArray *)parentLocalIds
{
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:@"parentLocalId"
                                                      operatorType:SQLOperatorIn
                                                    andFieldValues:parentLocalIds];
    
    BOOL status = [self deleteRecordsFromObject:[self tableName]
                                  whereCriteria:[NSArray arrayWithObject:criteriaOne]
                           andAdvanceExpression:nil];
    return status;
}


-(BOOL)deleteRecordWithParentLocalId:(NSString *)parentLocalId
{
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:@"parentLocalId"
                                                      operatorType:SQLOperatorEqual
                                                    andFieldValue:parentLocalId];
    
    BOOL status = [self deleteRecordsFromObject:[self tableName]
                                  whereCriteria:[NSArray arrayWithObject:criteriaOne]
                           andAdvanceExpression:nil];
    return status;
}

@end
