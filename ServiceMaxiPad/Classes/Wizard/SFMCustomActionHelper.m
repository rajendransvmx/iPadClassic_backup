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
            [fieldNames addObject:customModel.ParameterName];
        }else{
            //URLValue value and key
        }
    }
    return fieldNames;
}
-(void)loadURL:(NSString *)url withParams:(NSArray *)params
{
    if ([params count]>0) {
        URLValue = [@"" stringByAppendingFormat:@"%@?",url];
        [self fetchWorkOrderDetail:params];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

-(void)callWebService:(WizardComponentModel *)model withparams:(NSArray *)params{
    
}
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

- (void)getCustomActionParams:(NSString *)wizardComponentId params:(NSArray *)array{
    DBCriteria * criteriaOne = [[DBCriteria alloc] initWithFieldName:ObjectFieldname
                                                        operatorType:SQLOperatorEqual
                                                       andFieldValue:objectId];
    NSArray * fieldNames = [self fetchInformatio:array];
    
    NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:criteriaOne, nil];
    
    NSArray *wizardComponentParamArray=[self fetchDataFromWorkOrderObject:objectName fields:fieldNames expression:nil criteria:criteriaObjects];
    NSDictionary *workOrderSummaryDict= [[NSDictionary alloc] init];
    for (TransactionObjectModel *transObjModel in wizardComponentParamArray) {
        workOrderSummaryDict=[transObjModel getFieldValueDictionary];
    }
    [self loadWebpage:workOrderSummaryDict];
}
-(void)loadWebpage:(NSDictionary *)dictinory{
    for (NSString *Key in [dictinory allKeys]) {
       URLValue = [URLValue stringByAppendingFormat:@"&%@=%@",Key,[dictinory objectForKey:Key]];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[URLValue stringByReplacingOccurrencesOfString:@"?"
                                                                                                   withString:@"?&"]]];
}
@end
