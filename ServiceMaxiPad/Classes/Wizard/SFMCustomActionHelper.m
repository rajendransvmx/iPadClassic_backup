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
        if ([customModel.ParameterType isEqualToString:KFieldName])
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
                value=@"";
            }
            param = [param stringByAppendingFormat:@"&%@=%@",customModel.ParameterName,value];
            
        } else if ([customModel.ParameterType isEqualToString:kSVMXRequestValue])
        {
            param = [param stringByAppendingFormat:@"&%@=%@",customModel.ParameterName,customModel.ParameterValue];
        
        }else
        {
            
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


@end
