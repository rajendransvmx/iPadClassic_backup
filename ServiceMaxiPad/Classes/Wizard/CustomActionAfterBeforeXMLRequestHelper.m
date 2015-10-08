//
//  CustomActionAfterBeforeXMLRequestHelper.m
//  ServiceMaxiPad
//
//  Created by Apple on 17/07/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "CustomActionAfterBeforeXMLRequestHelper.h"
#import "CustomActionWebserviceModel.h"
#import "CacheManager.h"
#import "CacheConstants.h"
#import "SFMRecordFieldData.h"
#import "RequestConstants.h"
#import "CustomActionURLModel.h"
#import "SFCustomActionURLService.h"
#import "StringUtil.h"

#define kEventType @"eventType"
#define kSfmProcessId @"sfmProcessId"
#define KHeaderRecord @"headerRecord"
#define KObjName @"objName"
#define kAliasName @"aliasName"
#define kParentColumnName @"parentColumnName"
#define kDeleteRecID @"deleteRecID"
#define kPageLayoutId @"pageLayoutId"
#define kFieldsToNull @"fieldsToNull"
#define kRecords @"records"
#define kSourceRecordId @"sourceRecordId"
#define kTargetRecordAsKeyValue @"targetRecordAsKeyValue"
#define kKey @"key"
#define kSortValue @"sortValue"
#define kType @"type"
#define kValue1 @"value1"
#define kValue @"value"
#define kTargetRecordId @"targetRecordId"
#define kDetailRecords @"detailRecords"

@implementation CustomActionAfterBeforeXMLRequestHelper
NSMutableString *strquestion;
NSMutableString *currentElementValue;
-(NSString *)getXmlBody
{
    return [self getXMLRequestBodyFromSFMPage];
}

-(NSString *)getXMLRequestBodyFromSFMPage
{
    CustomActionWebserviceModel *customActionWebserviceModel = [[CacheManager sharedInstance] getCachedObjectByKey:kCustomWebServiceAction];
    SFMPage *page = customActionWebserviceModel.sfmPage;
    NSMutableString *xml = [[NSMutableString alloc] initWithString:@""];
    if (page)
    {
        [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kEventType,kEventType]];
        [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kFieldsToNull,kFieldsToNull]];
        [xml appendString:[NSString stringWithFormat:@"<%@>SCON_SC_Activate</%@>",kSfmProcessId,kSfmProcessId]];
        [xml appendString:[NSString stringWithFormat:@"%@",[self getHeaderRecordNode:customActionWebserviceModel.sfmPage]]];
        [xml appendString:[NSString stringWithFormat:@"%@",[self getDetailsRecordNode:customActionWebserviceModel.sfmPage]]];
    }
    return xml;
}

-(NSString *)getHeaderRecordNode:(SFMPage *)sfmPage
{
    NSMutableString *xml = [[NSMutableString alloc] initWithString:@""];
    [xml appendString:[NSString stringWithFormat:@"<%@>   </%@>",KHeaderRecord,KHeaderRecord]];
    [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",KHeaderRecord,[self getRecodeNode:sfmPage.headerRecord objectName:sfmPage.objectName recordType:KHeaderRecord pageLayout:sfmPage.process.pageLayout.headerLayout.hdrLayoutId],KHeaderRecord]];
    return xml;
}

-(NSString *)getDetailsRecordNode:(SFMPage *)sfmPage
{
    NSDictionary *dict = sfmPage.detailsRecord;
    NSMutableString *xml = [[NSMutableString alloc] initWithString:@""];
    NSDictionary *objectDict = [self getProcessComponentIdFromSfPage:sfmPage];
    NSDictionary *pageLayoutId = [self getPageLayoutIds:sfmPage.process.pageLayout.detailLayouts];
    if (dict)
    {
        for (NSString *key_Id in [dict allKeys])
        {
            NSString *objectName = [objectDict objectForKey:key_Id];
            NSArray *itemArray = [dict objectForKey:key_Id];
            for (NSDictionary *childDict in itemArray)
            {
                [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kDetailRecords,[self getRecodeNode:childDict objectName:objectName recordType:kDetailRecords pageLayout:[pageLayoutId objectForKey:key_Id]],kDetailRecords]];
            }
        }
    }
    return xml;
}
-(NSDictionary *)getPageLayoutIds:(NSArray *)layoutInfo
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (layoutInfo) {
        for (SFMDetailLayout *sfmDetailLayout in layoutInfo) {
            [dict setValue:sfmDetailLayout.pageLayoutId forKey:sfmDetailLayout.processComponentId];
        }
        return dict;
    }
    return dict;
}

-(NSString *)getRecodeNode:(NSDictionary *)dict objectName:(NSString *)objectName recordType:(NSString *)recordType pageLayout:(NSString *)pageLayoutId
{
    NSMutableString *xml = [[NSMutableString alloc] initWithString:@""];
    [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",KObjName,objectName,KObjName]];
    [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kAliasName,kAliasName]];
    [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kParentColumnName,kParentColumnName]];
    [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kDeleteRecID,kDeleteRecID]];
    [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kFieldsToNull,kFieldsToNull]];
    [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kPageLayoutId,pageLayoutId,kPageLayoutId]];
    [xml appendString:[NSString stringWithFormat:@"%@",[self getValuesNode:dict]]];
    return xml;
}

-(NSString *)getValuesNode:(NSDictionary *)dict
{
    NSMutableString *xml = [[NSMutableString alloc] initWithString:@""];
    [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kFieldsToNull,kFieldsToNull]];
//    [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kSourceRecordId,kSourceRecordId]];
    [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kRecords,[self getRecordXMLString:dict],kRecords]];
   // [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kTargetRecordId,[dict objectForKey:kId],kTargetRecordId]];
    return xml;
}

-(NSString *)getRecordXMLString:(NSDictionary *)dict
{
    NSMutableString *xml = [[NSMutableString alloc] initWithString:@""];
    if (dict)
    {
        for(NSString *string in [dict allKeys])
        {
            if (![string isEqualToString:@"localId"]) {
                [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kTargetRecordAsKeyValue,[self getValueNode:[dict objectForKey:string]],kTargetRecordAsKeyValue]];
            }
        }
    }
    [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kSourceRecordId,kSourceRecordId]];

    return xml;
}

-(NSString *)getValueNode:(SFMRecordFieldData *)recordFieldData
{
    NSMutableString *xml = [[NSMutableString alloc] initWithString:@""];
    [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kFieldsToNull,kFieldsToNull]];
    [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kKey,recordFieldData.name,kKey]];
    
    /* Testing on 22 sep  */
    //[xml appendString:[NSString stringWithFormat:@"<%@></%@>",kSortValue,kSortValue]];
    //[xml appendString:[NSString stringWithFormat:@"<%@></%@>",kType,kType]];
    [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kValue1,kValue1]];
    [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kValue,recordFieldData.internalValue,kValue]];
    return xml;
}

-(NSMutableDictionary *)getProcessComponentIdFromSfPage:(SFMPage *)sfmPage
{
    NSMutableDictionary *detailObjectName = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSArray *recordArray = sfmPage.process.pageLayout.detailLayouts;
    for (SFMDetailLayout *detailLayout in recordArray)
    {
        if ([StringUtil isStringNotNULL:detailLayout.objectName] && [StringUtil isStringNotNULL:detailLayout.processComponentId]) {
            [detailObjectName setObject:detailLayout.objectName forKey:detailLayout.processComponentId];
        }
    }
    return detailObjectName;
}

@end
