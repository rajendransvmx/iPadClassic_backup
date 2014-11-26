//
//  JobLogServiceLayer.m
//  ServiceMaxiPad
//
//  Created by Pushpak on 13/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "JobLogServiceLayer.h"
#import "FactoryDAO.h"
#import "JobLogDAO.h"
#import "DBRequestSelect.h"

@implementation JobLogServiceLayer
- (ResponseCallback*)processResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                        responseData:(id)responseData {
    
    ResponseCallback *callBack = nil;
    id jobLogService = [FactoryDAO serviceByServiceType:ServiceTypeJobLog];
    
    if ([jobLogService conformsToProtocol:@protocol(JobLogDAO)]) {
        [jobLogService deleteJobLogsThatAreSent];
        NSInteger count = [jobLogService getNumberOfRecordsFromObject:kJobLogsTableName
                                                                withDbCriteria:nil
                                                         andAdvancedExpression:nil];
        if (count > 0) {
            callBack = [[ResponseCallback alloc]init];
            
            RequestParamModel *reqParModel = [[RequestParamModel alloc]init];
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self fetchFormattedJobLogs]
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                         encoding:NSUTF8StringEncoding];
            
            NSDictionary *valueMapDic = @{@"key":@"LOGS",
                                          @"value":jsonString};
            
            reqParModel.valueMap = @[valueMapDic];
            
            callBack.callBackData = reqParModel;
            callBack.callBack = YES;
        }
    }
    return callBack;
}


- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)requestCount {

    RequestParamModel *reqParModel = [[RequestParamModel alloc]init];

    NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization
                                                           dataWithJSONObject:[self fetchFormattedJobLogs]
                                                           options:0
                                                           error:nil]
                                                 encoding:4];
    
    NSDictionary *valueMapDic = @{@"key":@"LOGS",
                                  @"value":jsonString};
    
    reqParModel.valueMap = @[valueMapDic];
    return @[reqParModel];
}

- (NSArray *)fetchFormattedJobLogs
{
    id jobLogService = [FactoryDAO serviceByServiceType:ServiceTypeJobLog];
    
    if ([jobLogService conformsToProtocol:@protocol(JobLogDAO)]) {
        
    NSArray *modelList = [jobLogService fetchNextBatchOfJobLogs];
    NSMutableArray *finalArray = [[NSMutableArray alloc]initWithCapacity:0];
    for (JobLogModel *model in modelList) {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]initWithCapacity:0];
        [dictionary setObject:@{@"type":ORG_NAME_SPACE@"__SVMX_Job_Logs__c"} forKey:@"attributes"];
        [self validateAndSetObject:model.timeStamp
                            forKey:ORG_NAME_SPACE@"__Log_Timestamp__c"
                    intoDictionary:dictionary];
        [self validateAndSetObject:[NSString stringWithFormat:@"%ld", (long)model.level]
                            forKey:ORG_NAME_SPACE@"__Log_level__c"
                    intoDictionary:dictionary];
        [self validateAndSetObject:model.context
                            forKey:ORG_NAME_SPACE@"__Log_Context__c"
                    intoDictionary:dictionary];
        [self validateAndSetObject:model.message
                            forKey:ORG_NAME_SPACE@"__Message__c"
                    intoDictionary:dictionary];
        [self validateAndSetObject:model.type
                            forKey:ORG_NAME_SPACE@"__Type__c"
                    intoDictionary:dictionary];
        [self validateAndSetObject:model.profileId
                            forKey:ORG_NAME_SPACE@"__Profile_Id__c"
                    intoDictionary:dictionary];
        [self validateAndSetObject:model.groupId
                            forKey:ORG_NAME_SPACE@"__Group_Id__c"
                    intoDictionary:dictionary];
        [self validateAndSetObject:model.category
                            forKey:ORG_NAME_SPACE@"__Log_Category__c"
                    intoDictionary:dictionary];
        [self validateAndSetObject:model.operation
                            forKey:ORG_NAME_SPACE@"__Operation__c"
                    intoDictionary:dictionary];
        [finalArray addObject:dictionary];
    }
    return finalArray;
    }
    return nil;
}

- (void)validateAndSetObject:(id)object
                      forKey:(NSString *)key
              intoDictionary:(NSMutableDictionary *)dict
{
    if (object != nil && key != nil)
    {
        [dict setObject:object forKey:key];
    }
}
@end
