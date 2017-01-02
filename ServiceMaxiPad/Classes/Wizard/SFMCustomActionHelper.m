//
//  SFMCustomActionHelper.m
//  ServiceMaxiPad
//
//  Created by Apple on 12/06/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "SFMCustomActionHelper.h"
#import "CustomActionURLModel.h"
#import "SFMRecordFieldData.h"
#import "StringUtil.h"
#import "SFCustomActionURLService.h"
#import "RequestConstants.h"
#import "TransactionObjectService.h"

@implementation SFMCustomActionHelper

-(id)initWithSFMPage:(SFMPage *)sfmPageModel
     wizardComponent:(WizardComponentModel*)wizardModel
{
    self = [super init];
    if (self) {
        self.sfmPageModel = sfmPageModel;
        self.wizardCompModel = wizardModel;
    }
    return self;
}

-(NSString *)loadURL
{
    NSArray *paramList = [self fetchParamsForWizardComponent:self.wizardCompModel];
    
    if (paramList != nil && ![paramList isKindOfClass:[NSNull class]] && [paramList count])
    {
        if (self.sfmPageModel)
        {
            NSDictionary *workOrderSummaryDict = self.sfmPageModel.headerRecord;
            NSString *url = [NSString stringWithFormat:@"%@?%@",self.wizardCompModel.customUrl,[self addParameters:workOrderSummaryDict paramArray:paramList]];
            
            return [url stringByReplacingOccurrencesOfString:@"?&" withString:@"?"];
        }else
        {
            return @"";
        }
    }else
    {
        return self.wizardCompModel.customUrl;
    }
    return @"";
}

/* taking column name and making key value pair for URL */
-(NSString *)addParameters:(NSDictionary *)dictinory paramArray:(NSArray *)array
{
    NSString *param = @"";
 
    for(CustomActionURLModel *customModel in array) {
    
        //Making parameter from model with respect type
        if ([[customModel.ParameterType uppercaseString] isEqualToString:KFieldName])
        {
            NSString *value = @"";
            SFMRecordFieldData *recordFieldData = nil;
            if (![StringUtil isStringEmpty:customModel.ParameterValue])
            {
                recordFieldData = [dictinory objectForKey:customModel.ParameterValue];
            }
            if (recordFieldData)
            {
                value = recordFieldData.internalValue;
            }
            else
            {
                // 036705
                value  = [self getFieldValueForField:customModel.ParameterValue forRecord:self.sfmPageModel.recordId andObject:self.sfmPageModel.objectName];
            }
            param = [param stringByAppendingFormat:@"&%@=%@",customModel.ParameterName,value];
            
        }
        else if ([[customModel.ParameterType uppercaseString] isEqualToString:kSVMXRequestValueUpper])
        {
            param = [param stringByAppendingFormat:@"&%@=%@",customModel.ParameterName,customModel.ParameterValue];
        
        }
    }
    return param;
}

/* Fetching parameter from customActionParams table */
-(NSArray *)fetchParamsForWizardComponent:(WizardComponentModel *)wizardComponent
{
    SFCustomActionURLService *wizardComponentparamService = [[SFCustomActionURLService alloc]init];
    NSArray *paramList= [wizardComponentparamService getCustomActionParams:wizardComponent.processId];
    return paramList;
}

// 036705
-(NSString *)getFieldValueForField:(NSString *)fieldName forRecord:(NSString *)recordId andObject:(NSString *)objectName
{
    NSString *fieldValue;
    if (![StringUtil isStringEmpty:fieldName]) {
        TransactionObjectService *service = [[TransactionObjectService alloc] init];
        TransactionObjectModel *model = [service getDataForObject:objectName fields:@[fieldName] recordId:recordId];
        if (model) {
            NSDictionary *fieldValues = model.getFieldValueDictionary;
            fieldValue = [fieldValues objectForKey:fieldName];
        }
    }
    
    if (fieldValue == nil) {
        fieldValue = @"";
    }
    return fieldValue;
}

@end
