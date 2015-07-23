//
//  APNSParser.m
//  ServiceMaxiPad
//
//  Created by Himanshi Sharma on 24/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "APNSParser.h"
#import "TXFetchHelper.h"
#import "StringUtil.h"
#import "TransactionObjectModel.h"
#import "DODRecordsModel.h"
#import "DODRecordsDAO.h"
#import "FactoryDAO.h"
#import "DateUtil.h"
#import "ResponseCallback.h"
#import "TagManager.h"
#import "TagConstant.h"




@interface APNSParser ()

@property(nonatomic, strong) TXFetchHelper *helper;

@end

@implementation APNSParser


-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData {
    
    @synchronized([self class]) {
        
        
        if ([responseData isKindOfClass:[NSDictionary class]]) {
            
            NSString * requestId = nil;
            
            for(NSDictionary * internalDict in  requestParamModel.valueMap){
                NSArray * internalValueMap = [internalDict objectForKey:kSVMXSVMXMap];
                for (NSDictionary  * finalValueMapdict in internalValueMap) {
                    NSString * key = [finalValueMapdict objectForKey:kSVMXKey];
                    if([key isEqualToString:@"Record_Id"]){
                        requestId = [finalValueMapdict objectForKey:kSVMXValue];
                    }
                }
            }
            
            self.helper = [[TXFetchHelper alloc] initWithCheckForDuplicateRecords:YES];
            
            NSDictionary *response = (NSDictionary *)responseData;
            
            NSArray *valueMap = [response objectForKey:kSVMXSVMXMap];
            
            NSMutableArray *objectrecords;
            
            for (NSDictionary *map in valueMap) {
                
                objectrecords  = [[NSMutableArray alloc] init];
                
                NSString *objectName = [map objectForKey:kSVMXKey];
                if ([objectName isEqualToString:@"DELETE"] )//HS 30 Mar added , if record is deleted from server end , we get "DELETE" as objectName
                {
                    NSArray *values = [map objectForKey:kSVMXValues];
                    if(requestId != nil && [values containsObject:requestId]){
                        
                        ResponseCallback *responseCallback = [[ResponseCallback alloc]init];
                        NSMutableDictionary *userInfoDict =[[NSMutableDictionary alloc]init];
                        [userInfoDict setObject:[[TagManager sharedInstance]tagByName:kTag_ThisRecordDeletedFromServer] forKey:SMErrorUserMessageKey];
                        
                        NSError *error =[[NSError alloc]initWithDomain:@"APNSDODRecordFail" code:0 userInfo:userInfoDict];
                        
                        //error.description = @"This record has been already deleted";
                        responseCallback.errorInParsing = error;
                        return responseCallback;
                    }
                }
                
                else if ([StringUtil isStringEmpty:objectName]) {
                    continue;
                }
                else
                {
                
                    NSString *jsonStr = [map objectForKey:kSVMXValue];
                    
                    
                    objectrecords = [self getTxnObjectForJsonString:jsonStr objectName:objectName];
                  //  BOOL isEventWebServiceCall =[self isEventWebServiceCall:requestParamModel];

                    //[objectrecords addObject:model];
                    
                    if ([objectrecords count] > 0) {
                        
                        //here we need to check whether this record exist in respectiveTable ,if not give a entry in DOD ,if its there update respectivetable
                        for  (TransactionObjectModel *model in objectrecords) {
                            NSString *objectName = model.objectAPIName;
                            //NSDictionary *valueDict = model.v
                            
                            NSString *sfID = [model valueForField:kId];
                          //  BOOL isRecordExists = [self isRecordExistwithObjectName:objectName andSFID:sfID];
                            NSArray *objectArray = [[NSArray alloc]initWithObjects:model, nil];
                            
                        
                            
                                    //update in objecttable
                                    [self.helper insertObjects:objectArray withObjectName:objectName]; //it will check if not exist it will insert or update if exists
                                    
                                    //check in DOD ,if there delete
                            
                                    if(![objectName isEqualToString:kEventObject ] && ![objectName isEqualToString:kSVMXTableName])
                                    {
                                        id dodService = [FactoryDAO serviceByServiceType:ServiceTypeDOD];
                                        BOOL isDODRecord = [dodService doesRecordAlreadyExistWithfieldName:kSyncRecordSFId withFieldValue:sfID inTable:@"DODRecords"];
                                        if (isDODRecord)
                                        {
                                            //Delete the record from DOD Table
                                            
                                            DBCriteria *criteriaOne = [[DBCriteria alloc]initWithFieldName:kSyncRecordSFId
                                                                                              operatorType:SQLOperatorEqual
                                                                                             andFieldValue:sfID];
                                            
                                            BOOL status = [dodService deleteRecordsFromObject:@"DODRecords"
                                                                          whereCriteria:[NSArray arrayWithObject:criteriaOne]
                                                                   andAdvanceExpression:nil];
                                        }
                                    }
                                    
                            
                                
                            }
                        
                            
                            }
                            
                            
                        }

                        [objectrecords removeAllObjects];
                    
                }
            
            }
           

            
        
    }
    return nil;
}

- (NSMutableArray *)getTxnObjectForJsonString:(NSString *)jsonString objectName:(NSString *)objectName
{
    NSData *recordData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:recordData options:NSJSONReadingMutableContainers error:&e];
    NSDictionary *jsonDict;
    NSMutableArray *objectRecordsArray = [[NSMutableArray alloc]init];
    for(jsonDict in jsonArray)
    {
        TransactionObjectModel *model = [[TransactionObjectModel alloc] initWithObjectApiName:objectName];
        [model setFieldValueDictionaryForFields:jsonDict];
        [objectRecordsArray addObject:model];
        
    }
    
    
    
    return objectRecordsArray;
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

//function to check whether the record is DOD record by comapring in respective objects
-(BOOL)isRecordExistwithObjectName:(NSString *)objectName andSFID:(NSString *)sfID
{
    //NSString *sfID = @"a1LF0000002O2t8MAC";

    
    id dodService = [FactoryDAO serviceByServiceType:ServiceTypeDOD];
    
    BOOL isRecordAlreadyExists = [dodService doesRecordAlreadyExistWithfieldName:@"Id" withFieldValue:sfID
                                                                       inTable:objectName];
    
    return isRecordAlreadyExists;
}

-(BOOL)isEventWebServiceCall:(RequestParamModel *)requestParamModel
{
    BOOL isEventRecord = NO;
    NSArray *objectValueMapArray = requestParamModel.valueMap;
    if ([objectValueMapArray count]!=0)
    {
        NSDictionary *valueMapDict =  [objectValueMapArray objectAtIndex:0];
        if (valueMapDict)
        {
            NSString *objectName = [valueMapDict objectForKey:kSVMXValue];
            if ([objectName isEqualToString:@"Event"])
            {
                isEventRecord = YES;
            }
        }
    }
    return isEventRecord;
}
@end
