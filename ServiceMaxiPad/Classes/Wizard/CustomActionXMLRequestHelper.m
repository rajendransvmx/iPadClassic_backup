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
#import "CustomActionsDAO.h"
#import "FactoryDAO.h"
#import "StringUtil.h"
#import "AppManager.h"
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
#define kValueMap @"valueMap"


#define krecordLocalID @"recordLocalId"
#define kparentObjectName @"Parent_Object_Name"
#define kchildObjectName  @"Child_Object_Name"

#define krecord  @"Record"
#define krecord_id  @"RECORD_ID"
#define klocalIdRecord  @"LOCAL_ID"
#define kafterSave @"AFTER_SAVE"


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
    ;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *userId = [userDefaults objectForKey:@"ps_user_id"];
    NSString *existingReqId = [userDefaults objectForKey:@"custom_actions_req_id"];
    
    NSString *requestId= [StringUtil checkIfStringEmpty:existingReqId]?[AppManager generateUniqueId]:existingReqId;
    [userDefaults setObject:requestId forKey:@"custom_actions_req_id"];
    [userDefaults synchronize];
    NSString *deviceUDID =[[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kUserId,userId,kUserId]];
    [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kGroupId,requestId,kGroupId]];
    [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kProfileId,deviceUDID,kProfileId]];
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

- (NSString *)getSFMCustomActionsParamsRequest{
    CustomActionWebserviceModel *customActionWebserviceModel = [[CacheManager sharedInstance] getCachedObjectByKey:kCustomWebServiceAction];
    return [self updateCustomActionFlagAndGetAllHeaderAndChildRecords:customActionWebserviceModel.sfmPage.headerRecord];
}
- (NSString *) updateCustomActionFlagAndGetAllHeaderAndChildRecords:(NSDictionary *)headerDict{
    NSMutableString *xml;
    id <CustomActionsDAO>customActionRequestService = [FactoryDAO serviceByServiceType:ServiceTypeCustomActionRequestParams];
    SFMRecordFieldData *fieldData=[headerDict objectForKey:klocalId];
    NSArray *headerModelArray = [customActionRequestService recordForRecordId:fieldData.internalValue];
    for (ModifiedRecordModel* modifiedHeaderRecord in headerModelArray) {
        modifiedHeaderRecord.customActionFlag = TRUE;
        [customActionRequestService updateCustomActionFlagForRecord:modifiedHeaderRecord];
        NSArray *childModelArray = [customActionRequestService childRecordForParentLocalId:fieldData.internalValue];
        for (ModifiedRecordModel* modifiedChildRecord in childModelArray) {
            modifiedChildRecord.customActionFlag = TRUE;
            [customActionRequestService updateCustomActionFlagForRecord:modifiedChildRecord];
        }
    }
    NSArray *customActionRecords=[customActionRequestService getCustomActionRequestParamsRecord];
        xml = [[NSMutableString alloc] initWithString:@""];
    for (ModifiedRecordModel* modifiedRecord in customActionRecords) {
        [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kValueMap,[self generateXmlBodyWithRecord:modifiedRecord],kValueMap]];
    }
    //Parent record not modified
    if (headerModelArray.count == 0) {
         [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kValueMap,[self generateXmlForParentRecordWithoutModification:headerDict],kValueMap]];
    }
    return xml;
}

-(NSString *)generateXmlForParentRecordWithoutModification :(NSDictionary *)headerDict{
    CustomActionWebserviceModel *customActionWebserviceModel = [[CacheManager sharedInstance] getCachedObjectByKey:kCustomWebServiceAction];

    NSMutableString *xml = [[NSMutableString alloc] initWithString:@""];
    [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kSVMXRequestKey,kparentObjectName,kSVMXRequestKey]];
    [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kSVMXValue,customActionWebserviceModel.sfmPage.objectName,kSVMXRequestValue]];
    SFMRecordFieldData *fieldData=[headerDict objectForKey:kId];
    NSDictionary *idDict=[[NSDictionary alloc]initWithObjectsAndKeys:fieldData.internalValue,kId , nil];
    NSData * idData = [NSJSONSerialization dataWithJSONObject:idDict options:0 error:nil];
    NSString * idString = [[NSString alloc] initWithData:idData encoding:NSUTF8StringEncoding];
    [xml appendString:[NSString stringWithFormat:@"<%@><%@>%@</%@>",kValueMap,kSVMXRequestKey,krecord_id,kSVMXRequestKey]];
    [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@></%@>",kSVMXRequestValue,idString,kSVMXRequestValue,kValueMap]];

    return xml;
}

-(NSString *)generateXmlBodyWithRecord:(ModifiedRecordModel *)modifiedRecord{
    NSMutableString *xml = [[NSMutableString alloc] initWithString:@""];
    if (![StringUtil checkIfStringEmpty:modifiedRecord.fieldsModified]) {
        [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kSVMXRequestKey,([StringUtil isStringEmpty:modifiedRecord.parentLocalId])?kparentObjectName:kchildObjectName,kSVMXRequestKey]];
        [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kSVMXValue,modifiedRecord.objectName,kSVMXRequestValue]];
        // Take only after save to add to the record
        
        NSData *modifiedFieldsData = [modifiedRecord.fieldsModified dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:modifiedFieldsData options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *afterSaveFields = [jsonDict objectForKey:kafterSave];
        NSArray *allAfterSaveKeys= [afterSaveFields allKeys];
        NSMutableDictionary * tempDict=[[NSMutableDictionary alloc]init];
        for (NSString *key in allAfterSaveKeys) {
            if (![key isEqualToString:kLocalId]) {
                [tempDict setObject:[afterSaveFields objectForKey:key] forKey:key];
            }
        }
        NSError * err;
        NSData * afterSaveData = [NSJSONSerialization dataWithJSONObject:tempDict options:0 error:&err];
        NSString * afterSaveString = [[NSString alloc] initWithData:afterSaveData encoding:NSUTF8StringEncoding];
        if ([StringUtil isStringEmpty:modifiedRecord.sfId]){
            [xml appendString:[NSString stringWithFormat:@"<%@><%@>%@</%@>",kValueMap,kSVMXRequestKey,modifiedRecord.recordLocalId,kSVMXRequestKey]];
            [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@></%@>",kSVMXRequestValue,afterSaveString,kSVMXRequestValue,kValueMap]];
        }
        else{
            [xml appendString:[NSString stringWithFormat:@"<%@><%@>%@</%@>",kValueMap,kSVMXRequestKey,krecord_id,kSVMXRequestKey]];
            [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@></%@>",kSVMXRequestValue,afterSaveString,kSVMXRequestValue,kValueMap]];
        }
    }
    return xml;

}
@end
