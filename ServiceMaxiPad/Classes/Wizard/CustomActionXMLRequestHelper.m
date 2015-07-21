//
//  CustomActionXMLRequestHelper.m
//  ServiceMaxiPad
//
//  Created by Apple on 17/07/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "CustomActionXMLRequestHelper.h"
#import "CustomActionWebserviceModel.h"
#import "CacheManager.h"
#import "CacheConstants.h"
#import "SFMRecordFieldData.h"
#import "RequestConstants.h"
#import "CustomActionURLModel.h"
#import "SFCustomActionURLService.h"
#import "CustomActionAfterBeforeXMLRequestHelper.h"

#define kUserId @"userId"
#define kGroupId @"groupId"
#define kProfileId @"profileId"
#define kFieldsToNull @"fieldsToNull"
#define kRecordIds @"recordIds"
#define kStringMap @"stringMap"
#define kStringListMap @"stringListMap"
#define kKey @"key"
#define kValue1 @"value1"
#define kValue @"value"

@implementation CustomActionXMLRequestHelper

-(NSString *)getXmlBody
{
    return [self parameterValue];
}

-(NSString *)parameterValue
{
    CustomActionWebserviceModel *customActionWebserviceModel = [[CacheManager sharedInstance] getCachedObjectByKey:kCustomWebServiceAction];
    return [self addParameters:customActionWebserviceModel];
}

/* taking column name and making key value pair for URL */
-(NSString *)addParameters:(CustomActionWebserviceModel *)customActionWebserviceModel//(NSDictionary *)dictinory wizardComponentProcessId:(NSString *)processId
{
    NSDictionary *dictinory= customActionWebserviceModel.sfmPage.headerRecord;
    NSMutableString *xml = [[NSMutableString alloc] initWithString:@""];
    [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kUserId,kUserId]];
    [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kGroupId,kGroupId]];
    [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kProfileId,kProfileId]];
    [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kFieldsToNull,kFieldsToNull]];
    [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kStringMap,[self getObjectNameAndId:customActionWebserviceModel.sfmPage.objectName sfId:[dictinory objectForKey:kId]],kStringMap]];

//    [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kRecordIds,kRecordIds]];
//    [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kStringListMap,kStringListMap]];
    if (customActionWebserviceModel.processId && ![customActionWebserviceModel.processId isEqualToString:@""]) {
        NSArray *paramList = [self fetchParamsForWizardComponent:customActionWebserviceModel.processId];
        for(CustomActionURLModel *customModel in paramList)
        {
            //Making parameter from model with respect type
            if ([[customModel.ParameterType uppercaseString] isEqualToString:KFieldName])
            {
                SFMRecordFieldData *recordFieldData = [dictinory objectForKey:customModel.ParameterValue];
                if (recordFieldData)
                {
                    customModel.ParameterValue = recordFieldData.internalValue;
                }
                else
                {
                    customModel.ParameterValue = @"";
                }
            }
            [xml appendString:[NSString stringWithFormat:@"%@",[self getValueNode:customModel]]];
        }
        return xml;
    }else{
        return @"";
    }
}
-(NSString *)getObjectNameAndId:(NSString *)objectName sfId:(SFMRecordFieldData *)recordFieldData
{
    NSMutableString *xml = [[NSMutableString alloc] initWithString:@""];
    [xml appendString:[NSString stringWithFormat:@"<%@>key</%@>",kKey,kKey]];
    if (recordFieldData) {
        [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kValue1,recordFieldData.internalValue,kValue1]];
    }
    else
    {
        [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kValue1,kValue1]];
    }
    [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kValue,objectName,kValue]];
    return xml;
}
-(NSString *)getValueNode:(CustomActionURLModel *)customActionURLModel
{
    NSMutableString *xml = [[NSMutableString alloc] initWithString:@""];
    NSMutableString *mapXml = [[NSMutableString alloc] initWithString:@""];
    if (customActionURLModel)
    {
        [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kSVMXRequestValue,customActionURLModel.ParameterValue,kSVMXRequestValue]];
        [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kSVMXRequestKey,customActionURLModel.ParameterName,kSVMXRequestKey]];
//        [xml appendString:[NSString stringWithFormat:@"<%@></%@>",KSVMXRequestData,KSVMXRequestData]];
        [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kSVMXRequestSVMXMap,kSVMXRequestSVMXMap]];
        [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kSVMXRequestValues,kSVMXRequestValues]];
    }
    [mapXml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kSVMXRequestSVMXMap,xml,kSVMXRequestSVMXMap]];
    return mapXml;
}

-(NSArray *)fetchParamsForWizardComponent:(NSString *)wizardComponentProcessId
{
    SFCustomActionURLService *wizardComponentparamService = [[SFCustomActionURLService alloc]init];
    NSArray *paramListValue= [wizardComponentparamService getCustomActionParams:wizardComponentProcessId];
    return paramListValue;
}
@end
