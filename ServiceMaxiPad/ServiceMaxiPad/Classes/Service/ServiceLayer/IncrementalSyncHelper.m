//
//  IncrementalSyncHelper.m
//  ServiceMaxMobile
//
//  Created by Sahana on 08/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "IncrementalSyncHelper.h"
#import "ModifiedRecordModel.h"
#import "SMXiPad_Utility.h"
#import "FactoryDAO.h"
#import "SFObjectFieldDAO.h"
#import "ModifiedRecordsDAO.h"
#import "DBRequestSelect.h"
#import "TransactionObjectDAO.h"
#import "SFChildRelationshipModel.h"
#import "SFChildRelationshipDAO.h"
#import "StringUtil.h"
#import "PlistManager.h"

@implementation IncrementalSyncHelper

-(NSArray *)getFieldsForObject:(NSString *)obejctName
{
    NSMutableArray *fieldsArray = [[NSMutableArray alloc] init];
    
    id <SFObjectFieldDAO> daoObj = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    
    NSArray *sfObjectFields =  [daoObj getSFObjectFieldsForObjectWithLocalId:obejctName];
    
    for (SFObjectFieldModel *aFieldModel in sfObjectFields) {
        if (aFieldModel.fieldName != nil) {
            [fieldsArray  addObject:aFieldModel.fieldName];
        }
    }
    return fieldsArray;
}


-(NSDictionary *)getUpdateRecords
{
    id<ModifiedRecordsDAO> daoObj= [self getModifiedRecordsDAOInstance];
    NSDictionary *updatedRecords = [daoObj getUpdatedRecords];
    return updatedRecords;
}

-(NSDictionary *)getInsertRecords
{
    id<ModifiedRecordsDAO> daoObj= [self getModifiedRecordsDAOInstance];
    NSDictionary *updatedRecords = [daoObj getUpdatedRecords];
    return updatedRecords;
}

-(id<ModifiedRecordsDAO>)getModifiedRecordsDAOInstance
{
    id <ModifiedRecordsDAO> daoObj = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    return daoObj;
    
}

-(id<SFObjectFieldDAO>)getSFobjectFieldDAOInstance
{
    id <SFObjectFieldDAO> daoObj = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    return daoObj;
    
}

#pragma mark - Getting json string for a given records
- (NSArray *)getIdsStringFromSyncRecords:(NSArray *)syncRecords andDictionary:(NSMutableDictionary *)syncRecordDictionary{
    NSMutableArray * idsArray = [[NSMutableArray alloc] init];
    
    for (int counter = 0; counter < [syncRecords count]; counter++) {
        ModifiedRecordModel *syncRecord = [syncRecords objectAtIndex:counter];
        
        if(syncRecord.recordLocalId != nil)
        {
            [idsArray addObject:syncRecord.recordLocalId];
        }
      
        if (syncRecord.recordLocalId != nil) {
            [syncRecordDictionary setObject:syncRecord forKey:syncRecord.recordLocalId];
        }
    }
    
    
    return idsArray;
}

- (void)fillUpDataInSyncRecords:(NSArray *)syncRecords {
    @synchronized([self class]){
        @autoreleasepool {
            
            if ([syncRecords count] <= 0) {
                return ;
            }
            
            NSString *objectName = [[syncRecords objectAtIndex:0] objectName];
            
            NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
            NSArray *idArray = [self getIdsStringFromSyncRecords:syncRecords andDictionary:jsonDictionary];
            
            NSArray *allFields = [self getFieldsForObject:objectName];
            
            DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:@"localId" operatorType:SQLOperatorIn andFieldValues:idArray];
            
            NSArray * records = [self getRecordForObjectName:objectName withFieldsArray:allFields expression:@"1" criteria:[NSArray arrayWithObject:criteria]];
            
            [self getObjectDictionaryWithJSONRecords:jsonDictionary withReocrdsArray:records andObjectName:objectName];
        }
    }
}

- (void)getObjectDictionaryWithJSONRecords:(NSMutableDictionary *)jsonDictionary
                          withReocrdsArray:(NSArray *)recordsArray
                            andObjectName:(NSString *)objectName {
    
    NSString *parentColumnName = [self getMasterColumnNameForObject:objectName];
  
    
    
    for (TransactionObjectModel *  trnasactionObj  in recordsArray) {
        
        NSMutableDictionary * recordDictionary =  [trnasactionObj getFieldValueMutableDictionary];
        
        if ([recordDictionary count] > 0) {
            
            
            NSString *localId = [recordDictionary objectForKey:kLocalId];
            if (localId != nil) {
                ModifiedRecordModel *aRecord = [jsonDictionary objectForKey:localId];
                
                BOOL canContinue =  [self isAllReferenceFieldsHasSfid:trnasactionObj
                                                 withParentColumnName:parentColumnName
                                                        andSyncRecord:aRecord];
                if (!canContinue) {
                    aRecord.cannotSendToServer = YES;
                    continue;
                }
                
                // if operation type 'update' but no sfid, then fetch sfid..
                if([StringUtil isStringEmpty:aRecord.sfId] && [aRecord.operation isEqualToString:kModificationTypeUpdate]){
                   aRecord.sfId = [self getSfIDForRecord:aRecord];
                    if([StringUtil isStringEmpty:aRecord.sfId]){
                    aRecord.cannotSendToServer = YES;
                    continue;
                    }
                    else
                    {
                        //update Modified Records Table
                        [self updateModifiedRecordsTable:aRecord];
                    }
                }
                NSError *error;
                NSData * jsonData = [NSJSONSerialization dataWithJSONObject:recordDictionary options:0 error:&error];
                
                if (!jsonData) {
                } else {
                    
                    NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
                    aRecord.jsonRecord = JSONString;
                }
                
            }
        }

    }
    
}

-(NSArray *)getRecordForObjectName:(NSString *)objectName  withFieldsArray:(NSArray *)fieldsArray expression:(NSString *)expresseion criteria:(NSArray *)criteria
{
    //call DAO service for fetching transaction records
    id <TransactionObjectDAO>  transObj = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    NSArray * transactionRecords =  [transObj fetchDataWithhAllFieldsAsStringObjects:objectName fields:fieldsArray expression:expresseion criteria:criteria];
    
    return transactionRecords;
}
-(NSDictionary *)getReferenceFieldsFor:(NSString *)objectName
{
    NSMutableDictionary *referenceToDict = [[NSMutableDictionary alloc] init];
    
    DBCriteria * criteia1 = [[DBCriteria alloc] initWithFieldName:@"objectName" operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    
    DBCriteria * criteria2 = [[DBCriteria alloc] initWithFieldName:@"referenceTo" operatorType:SQLOperatorNotEqual andFieldValue:@"\\"];
    
    DBCriteria * criteria3 = [[DBCriteria alloc] initWithFieldName:@"referenceTo" operatorType:SQLOperatorIsNotNull andFieldValue:nil];
    
    
    id <SFObjectFieldDAO> objFieldDAO  = [self getSFobjectFieldDAOInstance];
    
 //   NSArray * sfFieldObjects =   [objFieldDAO fetchSFObjectFieldsInfoByFields:[NSArray arrayWithObjects:@"fieldName", @"referenceTo" , nil] andCriteria:[NSArray arrayWithObjects:criteia1,criteria2,criteria3, nil]];
    
    NSArray * sfFieldObjects =   [objFieldDAO fetchSFObjectFieldsInfoByFields:[NSArray arrayWithObjects:@"fieldName", @"referenceTo" , nil] andCriteriaArray:[NSArray arrayWithObjects:criteia1,criteria2,criteria3, nil] advanceExpression:@"(1 AND 2 AND 3)"];
    
    for (SFObjectFieldModel * objField in sfFieldObjects) {
        [referenceToDict setObject:objField.referenceTo forKey:objField.fieldName];
    }
    
    return referenceToDict;
}


- (BOOL)isAllReferenceFieldsHasSfid:(TransactionObjectModel *)transactionModel
               withParentColumnName:(NSString *)parentColumnName
                      andSyncRecord:(ModifiedRecordModel *)syncRecord {
    
    /* Fetch all reference table */
    
    id <TransactionObjectDAO>  transObj = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    
     NSMutableDictionary * recordDictionary = [transactionModel getFieldValueMutableDictionary];
    
    NSString *objectName = syncRecord.objectName;
    NSString *recordLocalId = [recordDictionary objectForKey:kLocalId];
    
    
    NSDictionary * referenceDictionary = [self getReferenceFieldsFor:objectName];
    
    
    BOOL allReferenceFields = YES;
    for (NSString *key in referenceDictionary) {
        
        NSString *tempReferenceId = [recordDictionary objectForKey:key];
        
        NSString *referenceId = nil;
        if(![StringUtil isStringEmpty:tempReferenceId])
        {
            referenceId = tempReferenceId;
        }
    
        NSString *referenceTo = [referenceDictionary objectForKey:key];
        
        if ( [objectName isEqualToString:@"Event"] && [key isEqualToString:@"WhatId"] && referenceId.length > 30) {
            /* Get object name from user defaults */
            referenceTo =  [PlistManager objectNameForId:referenceId];
            if (referenceTo.length < 3) {
                [recordDictionary setObject:@"" forKey:key];
                referenceTo = nil;
            //    [self setValue:[NSString stringWithFormat:@" %@ = '' ",key] forTable:objectName andWhereClause:[NSString stringWithFormat:@" %@ = '%@' ",kLocalId ,recordLocalId]];
                
                DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:recordLocalId];
                
                [transObj updateEachRecord:[NSDictionary dictionaryWithObject:@"" forKey:key] withFields:[NSArray arrayWithObject:key] withCriteria:[NSArray arrayWithObject:criteria] withTableName:objectName];
                
            }
        }
        if (referenceId.length > 30 && referenceTo.length > 1) {
            /* It is local Id , so get the sfid */
            NSString *sfIdValue =   [transObj getSfIdForLocalId:referenceId forObjectName:referenceTo];  //[self sfIdForLocalId:referenceId inTable:referenceTo];
            
            if (sfIdValue.length > 3) {
                
                /* Sfid exist and can be replaced */
                [recordDictionary setObject:sfIdValue forKey:key];
                
                /* Update given field Name  with id value  */
           //     [self setValue:[NSString stringWithFormat:@" %@ = '%@' ",key,sfIdValue] forTable:objectName andWhereClause:[NSString stringWithFormat:@" %@ = '%@' ",kLocalId ,recordLocalId]];
                
                DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:recordLocalId];

                [transObj updateEachRecord:[NSDictionary dictionaryWithObject:sfIdValue forKey:key] withFields:[NSArray arrayWithObject:key] withCriteria:[NSArray arrayWithObject:criteria] withTableName:objectName];

                
            }
            else {
                /* TO BE DONE: Conflict handling need to be done */
                
                BOOL recordExist  =  [transObj isRecordExistsForObject:referenceTo forRecordLocalId:referenceId ];// [self isRecordExist:referenceId inTable:referenceTo];
                if (recordExist) {
                    /* Record exists but is not synced to server*/
                    /* Dnt send this record */
                    //sbm save
                    if (parentColumnName != nil && [key isEqualToString:parentColumnName] && ![syncRecord.operation isEqualToString:kModificationTypeUpdate]) {
                        syncRecord.parentLocalId = referenceId;
                        continue;
                    }
                    else
                    {
                        allReferenceFields = NO;
                    }
                }
                else{
                    /* Record is deleted. Set record blank*/
                    [recordDictionary setObject:@"" forKey:key];
                  //  [self setValue:[NSString stringWithFormat:@" %@ = '' ",key] forTable:objectName andWhereClause:[NSString stringWithFormat:@" %@ = '%@' ",kLocalId ,recordLocalId]];
                    
                    
                    DBCriteria * criteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:recordLocalId];
                    
                    [transObj updateEachRecord:[NSDictionary dictionaryWithObject:@"" forKey:key] withFields:[NSArray arrayWithObject:key] withCriteria:[NSArray arrayWithObject:criteria] withTableName:objectName];
                }
                
            }
        }
    }
    return allReferenceFields;
}

- (NSString *)getMasterColumnNameForObject:(NSString *)objectName {
    
    id<SFChildRelationshipDAO> daoObj = [FactoryDAO serviceByServiceType:ServiceTypeSFChildRelationShip];
    
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:@"objectNameChild" operatorType:SQLOperatorEqual andFieldValue:objectName];

    NSArray * childRelationObj  = [daoObj  fetchSFObjectFieldsInfoByFields:[NSArray arrayWithObject:@"fieldName"] andCriteria:criteria1];
    
    if ([childRelationObj count] == 1) {
        SFChildRelationshipModel * model = [childRelationObj objectAtIndex:0];
        return model.fieldName;
    }
    return nil;
}
- (NSInteger)getMaximumLocalId {
    id<ModifiedRecordsDAO> daoObj= [self getModifiedRecordsDAOInstance];
    return  [daoObj getLastLocalId];
}

-(NSString *)getSfIDForRecord:(ModifiedRecordModel *)model
{
    id <TransactionObjectDAO>  transObj = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    NSString *sfIdValue =   [transObj getSfIdForLocalId:model.recordLocalId forObjectName:model.objectName];
    return sfIdValue;

}

-(void)updateModifiedRecordsTable:(ModifiedRecordModel *)model
{
    id <ModifiedRecordsDAO>  modifiedObj = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    [modifiedObj updateModifiedRecord:model];
    
}
@end