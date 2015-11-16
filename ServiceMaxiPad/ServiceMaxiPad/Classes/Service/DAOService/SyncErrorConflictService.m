//
//  SyncErrorConflictService.m
//  ServiceMaxMobile
//
//  Created by Pushpak on 17/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "SyncErrorConflictService.h"
#import "DatabaseConstant.h"
#import "SyncErrorConflictModel.h"

@implementation SyncErrorConflictService


-(NSString *)tableName
{
    return kSyncErrorConflictTableName;
}


- (NSArray *)fieldNamesToBeRemovedFromQuery
{
    return @[@"objectLabel", @"recordValue", @"isWorkOrder", @"accountValue",@"scLocalId"];
}

- (BOOL)removeLocalIdField {
    return NO;
}

- (BOOL)enableInsertOrReplaceOption {
    return YES;
}

- (BOOL)isConflictFoundForObject:(NSString*)objectName withSfId:(NSString*)sfId
{
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:@"errorType" operatorType:SQLOperatorEqual andFieldValue:@"ERROR"];
    DBCriteria *criteriaTwo = [[DBCriteria alloc]initWithFieldName:@"operationType" operatorType:SQLOperatorEqual andFieldValue:@"UPDATE"];
    DBCriteria *criteriaThree = [[DBCriteria alloc]initWithFieldName:@"objectName" operatorType:SQLOperatorEqual andFieldValue:objectName];
    DBCriteria *criteriaFour = [[DBCriteria alloc]initWithFieldName:@"sfId" operatorType:SQLOperatorEqual andFieldValue:sfId];
    NSInteger count = [self getNumberOfRecordsFromObject:objectName withDbCriteria:@[criteriaOne,criteriaTwo,criteriaThree,criteriaFour] andAdvancedExpression:nil];
    
    BOOL hasRecordFound = NO;
    if (count > 0)
    {
        hasRecordFound = YES;
    }
    return hasRecordFound;
}

- (NSString *)fetchExistingModifiedFieldsJsonFromConflictTableForRecordId:(NSString*)recordId
{
    DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:@"localId" operatorType:SQLOperatorEqual andFieldValue:recordId];
    DBCriteria *criteriaTwo = [[DBCriteria alloc]initWithFieldName:@"operation" operatorType:SQLOperatorEqual andFieldValue:@"UPDATE"];
    
    NSArray *tempArray = [self fetchDataForFields:@[@"fieldsModified"] criterias:@[criteriaOne,criteriaTwo] objectName:[self tableName] andModelClass:[SyncErrorConflictModel class]];
    if ([tempArray count] > 0) {
        SyncErrorConflictModel *syncErrorConflictModel = [tempArray objectAtIndex:0];
        return syncErrorConflictModel.fieldsModified;
    }
    return nil;
}
@end