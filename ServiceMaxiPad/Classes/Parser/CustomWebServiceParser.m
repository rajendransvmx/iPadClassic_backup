//
//  CustomWebServiceParser.m
//  ServiceMaxiPad
//
//  Created by Apple on 23/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "CustomWebServiceParser.h"
#import "DODHelper.h"
#import "TXFetchHelper.h"
#import "StringUtil.h"
#import "TransactionObjectModel.h"
#import "DODRecordsModel.h"
#import "DODRecordsDAO.h"
#import "FactoryDAO.h"
#import "DateUtil.h"
#import "Utility.h"
#import "DBRequestUpdate.h"
#import "TransactionObjectService.h"
#import "SyncManager.h"
#import "SFMPageEditManager.h"
#import "ModifiedRecordsDAO.h"

@interface CustomWebServiceParser ()

@property(nonatomic, strong) TXFetchHelper *helper;

@end

@implementation CustomWebServiceParser


-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData {
    
    @synchronized([self class]) {
        
        if ([responseData isKindOfClass:[NSDictionary class]])
        {
            self.helper = [[TXFetchHelper alloc] initWithCheckForDuplicateRecords:YES];
            NSDictionary *response = [NSDictionary dictionaryWithDictionary:responseData];
            NSArray *valueMap = [response objectForKey:kSVMXSVMXMap];
            
            if ([valueMap isKindOfClass:[NSArray class]])
            {
                for (NSDictionary *recordDict in valueMap)
                {
                    NSMutableDictionary *objectrecords = [[NSMutableDictionary alloc] initWithCapacity:0];
                    NSString *objectName = nil;
                    objectName = [recordDict objectForKey:kSVMXKey];
                    id str = [recordDict objectForKey:kSVMXValue];
                    NSMutableArray *dataArray = [Utility objectFromJsonString:str];
                   
                    if ([dataArray isKindOfClass:[NSArray class]])
                    {
                        for (NSDictionary *dict in dataArray)
                        {
                            TransactionObjectModel *model = [[TransactionObjectModel alloc] initWithObjectApiName:objectName];
                            [model setFieldValueDictionaryForFields:dict];
                            NSString *recordSFID = [dict objectForKey:kId];
                            if (![StringUtil isStringEmpty:recordSFID])
                                [objectrecords setObject:model forKey:recordSFID];
                        }
                    }
                    [self updateOrInsertTransactionObjectArray:objectrecords sfIdArray:[objectrecords allKeys] objectName:objectName];

                }
            }
            /* refresh all screens with new data*/
            [self sendNotification:kUpadteWebserviceData andUserInfo:nil];
        }
    }
    return nil;
}
- (void)sendNotification:(NSString *)notificationName andUserInfo:(NSDictionary *)userInfo {
    
    NSMutableDictionary *notificationDict = [[NSMutableDictionary alloc] init];
    [notificationDict setValue:notificationName forKey:@"NotoficationName"];
    [notificationDict setValue:userInfo forKey:@"UserInfo"];
    [self performSelectorOnMainThread:@selector(postNotification:) withObject:notificationDict waitUntilDone:YES];
    //[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userInfo];
}
- (void)postNotification:(NSDictionary *)notificationDict
{
    NSString *notificationName = [notificationDict objectForKey:@"NotoficationName"];
    NSDictionary *userInfo = [notificationDict objectForKey:@"UserInfo"];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userInfo];
}

- (void)updateOrInsertTransactionObjectArray:(NSMutableDictionary *)objectrecords sfIdArray:(NSArray*)sfidArray objectName:(NSString *)objectName
{
    NSArray *actualRecordsArray = [self getRecordsArrayForObjectName:objectName andSFIDArray:sfidArray];
    NSMutableArray *updatedModelArray =[[NSMutableArray alloc] initWithCapacity:0];
    for (TransactionObjectModel *model in actualRecordsArray)
    {
        NSMutableDictionary *actualModelDict = [model getFieldValueMutableDictionary];
        NSString *recordSFID = [actualModelDict objectForKey:kId];
        TransactionObjectModel *toBeUpdatedModel = [objectrecords objectForKey:recordSFID];
        
        NSMutableDictionary *toBeUpdatedDict = [toBeUpdatedModel getFieldValueMutableDictionary];
        if ([toBeUpdatedDict objectForKey:kAttributeKey]) {
            [toBeUpdatedDict removeObjectForKey:kAttributeKey];
        }
        [self fieldMergeHelper:toBeUpdatedDict andObjectName:objectName andRecordID:[actualModelDict objectForKey:kLocalId] andSfid:recordSFID];
        NSArray *toBeUpdatedAllKeys = [toBeUpdatedDict allKeys];
        
        for (NSString *keyString in toBeUpdatedAllKeys)
        {
            NSString *valueToBeUpdated = [toBeUpdatedDict valueForKey:keyString];
            if (![StringUtil isStringNotNULL:valueToBeUpdated])
            {
                valueToBeUpdated = @"";
            }
            [actualModelDict setValue:valueToBeUpdated forKey:keyString];
        }
        [model setFieldValueDictionaryForFields:actualModelDict];
        [updatedModelArray addObject:model];
    }
    [self.helper insertObjects:updatedModelArray withObjectName:objectName];
    
}

- (NSArray*)getRecordsArrayForObjectName:(NSString*)objName andSFIDArray:(NSArray*)array
{
    id <TransactionObjectDAO> transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:array];
    NSArray *dataArray = [transactionService fetchDataForObject:objName fields:nil expression:nil criteria:@[criteria]];
    return dataArray;
}

-(void)fieldMergeHelper:(NSDictionary *)toBeUpdatedRecords andObjectName:(NSString *)objectName andRecordID:(NSString *)recordID andSfid:(NSString *)sfid
{
    
    SFMPageEditManager *pageEditManager = [[SFMPageEditManager alloc]init];
    pageEditManager.dataDictionaryAfterModification = [[NSMutableDictionary alloc]initWithDictionary: toBeUpdatedRecords];
    
    NSString *modifiedFieldAsJson = [pageEditManager getJsonStringAfterComparisionForObject:objectName recordId:recordID sfid:sfid andSettingsFlag:YES];
    if (!modifiedFieldAsJson) {
        return;
    }
    
    id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    NSArray *modifiedRecordList =   [modifiedRecordService getModifiedRecordListforRecordId:recordID sfid:sfid];
    
    if (modifiedRecordList && modifiedRecordList.count) {
        ModifiedRecordModel *model = [modifiedRecordList objectAtIndex:0];
        model.fieldsModified = modifiedFieldAsJson;
        
        [modifiedRecordService updateFieldsModifed:model];

    }
    
}

@end
