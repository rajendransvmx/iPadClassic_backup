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
/////
#import "TaskModel.h"
#import "TaskGenerator.h"
#import "TaskManager.h"
////
#import "WebserviceResponseStatus.h"
#import "CustomActionWebServiceLayer.h"
#import "SFCustomActionURLService.h"

@implementation SFMCustomActionHelper
@synthesize objectId;
@synthesize objectName;
@synthesize ObjectFieldname;

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        //Initialization
    }
    return self;
}

-(NSString *)loadURL:(WizardComponentModel *)model
{
    NSArray *paramList = [self fetchParamsForWizardComponent:model];
    if ([paramList count]>0) {
        NSArray *wizardComponentParamArray = [self getCustomActionParams:paramList];
        NSDictionary *workOrderSummaryDict= [[NSDictionary alloc] init];
        for (TransactionObjectModel *transObjModel in wizardComponentParamArray) {
            workOrderSummaryDict=[transObjModel getFieldValueDictionary];
        }
        //UIApplication *ourApplication = [UIApplication sharedApplication];
        NSString *url = [NSString stringWithFormat:@"%@?%@",model.customUrl,[self addParameters:workOrderSummaryDict paramArray:paramList]];
        return [url stringByReplacingOccurrencesOfString:@"?&" withString:@"?"];
    }else{
        return model.customUrl;
    }
    return @"";
}

-(NSDictionary *)fetchWebServiceParams:(WizardComponentModel *)model withparams:(NSArray *)params{
    if ([params count]>0) {
        NSArray *wizardComponentParamArray = [self getCustomActionParams:params];
        NSDictionary *workOrderSummaryDict= [[NSDictionary alloc] init];
        for (TransactionObjectModel *transObjModel in wizardComponentParamArray) {
            workOrderSummaryDict=[transObjModel getFieldValueDictionary];
        }
       return [self addParameterValues:workOrderSummaryDict paramArray:params];
        //[self callWebService];
    }
    return nil;
}

-(void)fetchWorkOrderDetail:(NSArray *)paramList{
    if (objectId) {
        if ([objectName isEqualToString:kWorkOrderTableName]) {
            [self getCustomActionParams:paramList];
        }
    }
}

-(NSArray *)fetchDataFromObjectNameObject:(NSString *)objectNameTable
                                   fields:(NSArray *)fieldNames
                               expression:(NSString *)advancaeExpression
                                 criteria:(NSArray *)criteria
{
    id <TransactionObjectDAO> transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    
    NSArray *dataArray = [transactionService fetchDataForObject:objectNameTable fields:fieldNames expression:advancaeExpression criteria:criteria];
    return dataArray;
}

- (NSArray *)getCustomActionParams:(NSArray *)array{
    DBCriteria * criteriaOne = [[DBCriteria alloc] initWithFieldName:ObjectFieldname
                                                        operatorType:SQLOperatorEqual
                                                       andFieldValue:objectId];
    NSArray * fieldNames = [self fetchColumnName:array];
    
    NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:criteriaOne, nil];
    
    NSArray *wizardComponentParamArray=[self fetchDataFromObjectNameObject:objectName fields:fieldNames expression:nil criteria:criteriaObjects];
    return  wizardComponentParamArray;
}
-(NSString *)addParameters:(NSDictionary *)dictinory paramArray:(NSArray *)array{
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
-(NSDictionary *)addParameterValues:(NSDictionary *)dictinory paramArray:(NSArray *)array{
    NSMutableDictionary *parametersWithKey=[[NSMutableDictionary alloc] init];
    for(CustomActionURLModel *customModel in array) {
        //Making parameter from model with respect type
        if ([customModel.ParameterType isEqualToString:@"Field Name"]) {
            [parametersWithKey setObject:[dictinory objectForKey:customModel.ParameterValue] forKey:customModel.ParameterName];
            //param = [param stringByAppendingFormat:@"&%@=%@",customModel.ParameterName,[dictinory objectForKey:customModel.ParameterValue]];
        }else if([customModel.ParameterType isEqualToString:@"Value"]) {
            [parametersWithKey setObject:customModel.ParameterValue forKey:customModel.ParameterName];
            //param = [param stringByAppendingFormat:@"&%@=%@",customModel.ParameterName,customModel.ParameterValue];
        }else{
            
        }
    }
    return parametersWithKey;
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
-(NSArray *)fetchColumnName:(NSArray *)array{
    NSMutableArray *fieldNames=[[NSMutableArray alloc] init];
    for(CustomActionURLModel *customModel in array) {
        if ([customModel.ParameterType isEqualToString:@"Field Name"]) {
            [fieldNames addObject:customModel.ParameterValue];
        }
    }
    return fieldNames;
}
-(NSArray *)fetchParamsForWizardComponent:(WizardComponentModel *)wizardComponent{
    SFCustomActionURLService *wizardComponentparamService = [[SFCustomActionURLService alloc]init];
    NSArray *paramList= [wizardComponentparamService getCustomActionParams:wizardComponent.processId];
    return paramList;
}
//-(void)callWebService{
//    TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeCustomWebServiceCall
//                                             requestParam:nil
//                                           callerDelegate:self];
//    
//    [[TaskManager sharedInstance] addTask:taskModel];
//}
//
//
//#pragma mark FLOW DELEGATE
//- (void)flowStatus:(id)status;
//{
//    if([status isKindOfClass:[WebserviceResponseStatus class]])
//    {
//        WebserviceResponseStatus *st = (WebserviceResponseStatus*)status;
//        if (st.syncStatus == SyncStatusSuccess) {
//        
//        }
//        else if (st.syncStatus == SyncStatusFailed)
//        {
//            
//        }
//    }
//}

@end
