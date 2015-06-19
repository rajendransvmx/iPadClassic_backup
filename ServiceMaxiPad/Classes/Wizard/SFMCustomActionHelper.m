//
//  SFMCustomActionHelper.m
//  ServiceMaxiPad
//
//  Created by Apple on 12/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "SFMCustomActionHelper.h"
#import "DBCriteria.h"
#import "DBRequestSelect.h"
#import "DatabaseQueue.h"
#import "CustomActionURLModel.h"
#import "DatabaseManager.h"
#import "SFObjectModel.h"
#import "TransactionObjectDAO.h"
#import "FactoryDAO.h"

@implementation SFMCustomActionHelper
@synthesize objectId;
@synthesize objectName;
@synthesize ObjectFieldname;
@synthesize URLValue;

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        //Initialization
    }
    return self;
}
-(NSArray *)fetchInformatio:(NSArray *)array{
    NSMutableArray *fieldNames=[[NSMutableArray alloc] init];
    for(CustomActionURLModel *customModel in array) {
        if ([customModel.ParameterType isEqualToString:@"Field Name"]) {
            [fieldNames addObject:customModel.ParameterValue];
        }
    }
    return fieldNames;
}
-(void)loadURL:(WizardComponentModel *)model withParams:(NSArray *)params
{
    if ([params count]>0) {
        NSArray *wizardComponentParamArray = [self getCustomActionParams:objectId params:params];
        NSDictionary *workOrderSummaryDict= [[NSDictionary alloc] init];
        for (TransactionObjectModel *transObjModel in wizardComponentParamArray) {
            workOrderSummaryDict=[transObjModel getFieldValueDictionary];
        }
        UIApplication *ourApplication = [UIApplication sharedApplication];
        NSString *url = [NSString stringWithFormat:@"%@?%@",model.customUrl,[self loadWebpage:workOrderSummaryDict paramArray:params]];
        [ourApplication openURL:[NSURL URLWithString:[url stringByReplacingOccurrencesOfString:@"?&" withString:@"?"]]];
    }else{
        UIApplication *ourApplication = [UIApplication sharedApplication];
        [ourApplication openURL:[NSURL URLWithString:model.customUrl]];
    }
}

-(void)callWebService:(WizardComponentModel *)model withparams:(NSArray *)params{
    if ([params count]>0) {
        NSArray *wizardComponentParamArray = [self getCustomActionParams:objectId params:params];
        NSDictionary *workOrderSummaryDict= [[NSDictionary alloc] init];
        for (TransactionObjectModel *transObjModel in wizardComponentParamArray) {
            workOrderSummaryDict=[transObjModel getFieldValueDictionary];
        }
       // NSString *url = [NSString stringWithFormat:@"%@%@",model.customUrl,[self loadWebpage:workOrderSummaryDict paramArray:params]];
       // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[url stringByReplacingOccurrencesOfString:@"?&" withString:@"?"]]];
    }else{
        
    }
}
-(void)loadApp:(WizardComponentModel *)model withparams:(NSArray *)params{
    NSArray *wizardComponentParamArray = [self getCustomActionParams:objectId params:params];
    NSDictionary *workOrderSummaryDict= [[NSDictionary alloc] init];
    for (TransactionObjectModel *transObjModel in wizardComponentParamArray) {
        workOrderSummaryDict=[transObjModel getFieldValueDictionary];
    }
    NSString *url = [NSString stringWithFormat:@"%@://?%@",model.customUrl,[self loadWebpage:workOrderSummaryDict paramArray:params]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[url stringByReplacingOccurrencesOfString:@"?&"
                                                                                                   withString:@"?"]]];}
-(void)fetchWorkOrderDetail:(NSArray *)paramList{
    if (objectId) {
        if ([objectName isEqualToString:kWorkOrderTableName]) {
            [self getCustomActionParams:objectId params:paramList];
        }
    }
}
- (NSArray * )fetchWizardComponentParamsInfoByFields:(NSArray *)fieldNames
                                         andCriteria:(NSArray *)criteria
                                       andExpression:(NSString *)expression
{
    DBRequestSelect * requestSelect = [[DBRequestSelect alloc] initWithTableName:objectName andFieldNames:fieldNames whereCriterias:criteria andAdvanceExpression:expression];
    
    [requestSelect setDistinctRowsOnly];
    
    NSMutableArray * records = [[NSMutableArray alloc] initWithCapacity:0];
    @autoreleasepool {
        DatabaseQueue *queue = [[DatabaseManager sharedInstance] databaseQueue];
        
        [queue inTransaction:^(SMDatabase *db, BOOL *rollback) {
            
            NSString * query = [requestSelect query];
            
            SQLResultSet * resultSet = [db executeQuery:query];
            
            while ([resultSet next]) {
                SFObjectModel * model = [[SFObjectModel alloc] init];
               [resultSet kvcMagic:model];
                [records addObject:model];
            }
            [resultSet close];
        }];
    }
    return records;
}
-(NSArray *)fetchDataFromWorkOrderObject:(NSString *)objectNameTable
                                   fields:(NSArray *)fieldNames
                               expression:(NSString *)advancaeExpression
                                 criteria:(NSArray *)criteria
{
    id <TransactionObjectDAO> transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    NSArray *dataArray = [transactionService fetchDataForObject:objectNameTable fields:fieldNames expression:advancaeExpression criteria:criteria];
    return dataArray;
}

- (NSArray *)getCustomActionParams:(NSString *)wizardComponentId params:(NSArray *)array{
    DBCriteria * criteriaOne = [[DBCriteria alloc] initWithFieldName:ObjectFieldname
                                                        operatorType:SQLOperatorEqual
                                                       andFieldValue:objectId];
    NSArray * fieldNames = [self fetchInformatio:array];
    
    NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:criteriaOne, nil];
    
    NSArray *wizardComponentParamArray=[self fetchDataFromWorkOrderObject:objectName fields:fieldNames expression:nil criteria:criteriaObjects];
    return  wizardComponentParamArray;
}
-(NSString *)loadWebpage:(NSDictionary *)dictinory paramArray:(NSArray *)array{
    NSString *param = @"";
    for(CustomActionURLModel *customModel in array) {
        //Making parameter from model with respect type
        if ([customModel.ParameterType isEqualToString:@"Field Name"]) {
            param = [param stringByAppendingFormat:@"&%@=%@",customModel.ParameterName,[dictinory objectForKey:customModel.ParameterValue]];
        }else if([customModel.ParameterType isEqualToString:@"Value"]) {
            param = [param stringByAppendingFormat:@"&%@=%@",customModel.ParameterName,customModel.ParameterValue];
        }else{
            
        }
    }
    return param;
}
- (void)otherApplication:(NSString *)customURLSchemes paramiter:(NSArray *)array
{
    customURLSchemes =  [NSString stringWithFormat:@"%@//",customURLSchemes];//@"schemesd://";
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:customURLSchemes]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:customURLSchemes]];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL error"
                                                        message:[NSString stringWithFormat:@"No custom URL defined for %@",customURLSchemes]
                                                       delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
}
@end
