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
        }
    }
    return nil;
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
        NSArray *toBeUpdatedAllKeys = [toBeUpdatedDict allKeys];
        
        for (NSString *keyString in toBeUpdatedAllKeys)
        {
            NSString *valueToBeUpdated = [toBeUpdatedDict valueForKey:keyString];
            if (valueToBeUpdated != nil && [StringUtil isStringNotNULL:valueToBeUpdated] && [actualModelDict valueForKey:keyString])
            {
                [actualModelDict setValue:valueToBeUpdated forKey:keyString];
            }
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

@end
