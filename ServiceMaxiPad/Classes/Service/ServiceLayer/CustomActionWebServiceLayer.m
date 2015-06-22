//
//  CustomActionWebServiceLayer.m
//  ServiceMaxiPad
//
//  Created by Apple on 22/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "CustomActionWebServiceLayer.h"
#import "WizardComponentModel.h"
#import "SFCustomActionURLService.h"
#import "TransactionObjectDAO.h"
#import "FactoryDAO.h"
#import "DBCriteria.h"
#import "CustomActionURLModel.h"
#import "SFMCustomActionWebServiceHelper.h"

@implementation CustomActionWebServiceLayer
- (instancetype) initWithCategoryType:(CategoryType)categoryType
                          requestType:(RequestType)requestType {
    
    self = [super initWithCategoryType:categoryType requestType:requestType];
    
    if (self != nil) {
        //Intialize if required
        
    }
    
    return self;
}


- (ResponseCallback*)processResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                        responseData:(id)responseData
{
    return nil;
}
- (NSArray*)getRequestParametersWithRequestCount:(NSInteger)requestCount
{
    return nil;
}
-(NSArray *)fetchParamsForWizardComponent:(WizardComponentModel *)wizardComponent{
    SFCustomActionURLService *wizardComponentparamService = [[SFCustomActionURLService alloc]init];
    NSArray *paramList= [wizardComponentparamService getCustomActionParams:wizardComponent.processId];
    return paramList;
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
    WizardComponentModel *WizardComponentModel = [SFMCustomActionWebServiceHelper getWizardComponentModel];
    DBCriteria * criteriaOne = [[DBCriteria alloc] initWithFieldName:WizardComponentModel.ObjectFieldName
                                                        operatorType:SQLOperatorEqual
                                                       andFieldValue:WizardComponentModel.objectFieldId];
    NSArray * fieldNames = [self fetchColumnName:array];
    
    NSArray * criteriaObjects = [[NSArray alloc] initWithObjects:criteriaOne, nil];
    
    NSArray *wizardComponentParamArray=[self fetchDataFromObjectNameObject:WizardComponentModel.objectName fields:fieldNames expression:nil criteria:criteriaObjects];
    return  wizardComponentParamArray;
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
@end
