//
//  DODParser.m
//  ServiceMaxiPad
//
//  Created by Himanshi Sharma on 12/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "DODParser.h"
#import "DODHelper.h"
#import "TXFetchHelper.h"
#import "StringUtil.h"
#import "TransactionObjectModel.h"
#import "DODRecordsModel.h"
#import "DODRecordsDAO.h"
#import "FactoryDAO.h"
#import "DateUtil.h"

@interface DODParser ()

@property(nonatomic, strong) TXFetchHelper *helper;

@end

@implementation DODParser

-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData {
 
    @synchronized([self class]) {
        
        
        if ([responseData isKindOfClass:[NSDictionary class]]) {
            
            self.helper = [[TXFetchHelper alloc] initWithCheckForDuplicateRecords:YES];
            
            NSDictionary *response = (NSDictionary *)responseData;
            
            NSArray *valueMap = [response objectForKey:kSVMXSVMXMap];
            NSMutableArray *objectrecords;
            
            for (NSDictionary *map in valueMap) {
                
               objectrecords  = [[NSMutableArray alloc] init];
                
                NSString *objectName = [map objectForKey:kSVMXValue];
                NSString *recordTye = @"";
                
                if ([StringUtil isStringEmpty:objectName]) {
                    continue;
                }
                NSArray *mapArray = [map objectForKey:kSVMXSVMXMap];
                
                for (NSDictionary *recordDict in mapArray) {
                    
                    NSString *key = [recordDict objectForKey:kSVMXKey];
                    
                    if ([key isEqualToString:@"Parent_Record"]) {
                        recordTye = @"MASTER";
                    }
                    else if ([key isEqualToString:@"Child_Record"]) {
                        recordTye = @"DETAIL";
                    }
                    
                    if ([key isEqualToString:@"PRICING_DATA"]) {
                        NSArray *getPriceData = [recordDict objectForKey:kSVMXSVMXMap];
                        
                        for (NSDictionary *priceData in getPriceData) {
                            NSMutableArray *priceDataobjectrecords = [[NSMutableArray alloc] init];
                            
                            NSString *objectName = [priceData objectForKey:kSVMXKey];
                            
                            if ([StringUtil isStringEmpty:objectName]) {
                                continue;
                            }
                            NSArray *values = [priceData objectForKey:kSVMXSVMXMap];
                            
                            for (NSDictionary *valueDict in values) {
                                NSString *jsonStr = [valueDict objectForKey:kSVMXValue];
                                TransactionObjectModel *model = [self getTxnObjectForJsonString:jsonStr objectName:objectName];
                                [priceDataobjectrecords addObject:model];
                            }
                            if ([priceDataobjectrecords count] > 0) {
                                [self.helper insertObjects:priceDataobjectrecords withObjectName:objectName];
                                [priceDataobjectrecords removeAllObjects];
                            }
                        }
                    }
                    else {
                        NSString *jsonStr = [recordDict objectForKey:kSVMXValue];
                        TransactionObjectModel *model = [self getTxnObjectForJsonString:jsonStr objectName:objectName];
                        if (model) {
                            [objectrecords addObject:model];
                        }
                    }
                }
                if ([objectrecords count] > 0) {
                    [self.helper insertObjects:objectrecords withObjectName:objectName];
                    [self insertRecordIntoDODTable:objectrecords recordType:recordTye objectName:objectName];
                    [objectrecords removeAllObjects];
                }
            }
//            ////HS 14 JanHandle for header records is deleted from Server DODRedresh issue
//            if ([objectrecords count] == 0)
//            {
//                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"DODRefresh Error" message:@"Record has been deleted" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                [alert show];
//                
//            }
            
        }
    }
    return nil;
}

- (TransactionObjectModel *)getTxnObjectForJsonString:(NSString *)jsonString objectName:(NSString *)objectName
{
    NSData *recordData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:recordData options:NSJSONReadingMutableContainers error:&e];
    if (!jsonDict) {
        return nil;
    }
    TransactionObjectModel *model = [[TransactionObjectModel alloc] initWithObjectApiName:objectName];
    [model setFieldValueDictionaryForFields:jsonDict];
    
    return model;
}

- (void)insertRecordIntoDODTable:(NSArray *)dataArray recordType:(NSString *)recordType
                      objectName:(NSString *)objectName
{
    NSMutableArray *recordArray = [NSMutableArray new];
    
    NSString *date = [DateUtil getDatabaseStringForDate:[NSDate date]];
    DODRecordsModel *dodModel;
    BOOL isRecordExist;
    for  (TransactionObjectModel *model in dataArray) {
        dodModel = [[DODRecordsModel alloc] init];
        dodModel.objectName = objectName;
        dodModel.recordType = recordType;
        dodModel.sfId = [model valueForField:kId];
        dodModel.timeStamp = date;
       isRecordExist = [self isRecordExistInDOD:dodModel];
        if (isRecordExist)
        {
            return;
        }
        [recordArray addObject:dodModel];
    }
    id dodService = [FactoryDAO serviceByServiceType:ServiceTypeDOD];
    
    if ([dodService conformsToProtocol:@protocol(DODRecordsDAO)]) {
        [dodService saveRecordModels:recordArray];
    }
}

-(BOOL)isRecordExistInDOD:(DODRecordsModel *)DODModel
{
    //HS 21 Nov
    //check if record already exist if yes then call update query else insert
    id dodService = [FactoryDAO serviceByServiceType:ServiceTypeDOD];

    BOOL isOnlineRecordExist = [dodService doesRecordAlreadyExistWithfieldName:kSyncRecordSFId withFieldValue:DODModel.sfId inTable:@"DODRecords"];
    BOOL status = NO;

    if (isOnlineRecordExist) {
        
        DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kSyncRecordSFId operatorType:SQLOperatorEqual andFieldValue:DODModel.sfId];
        
         status = [dodService updateEachRecord:DODModel withFields:[NSArray arrayWithObjects:kobjectName,kSyncRecordSFId,@"timeStamp",kSyncRecordType, nil] withCriteria:[NSArray arrayWithObjects:criteria1, nil]];
        if (!status) {
            SXLogInfo(@"Failed to update dod record")
        }
    }
  return isOnlineRecordExist;

}

@end
