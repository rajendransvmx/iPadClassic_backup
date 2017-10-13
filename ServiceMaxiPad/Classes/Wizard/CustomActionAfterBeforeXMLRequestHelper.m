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
        [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kSfmProcessId, page.process.processInfo.processId,kSfmProcessId]]; // IPAD-4687
        [xml appendString:[NSString stringWithFormat:@"%@",[self getHeaderRecordNode:customActionWebserviceModel.sfmPage]]];
        [xml appendString:[NSString stringWithFormat:@"%@",[self getDetailsRecordNode:customActionWebserviceModel.sfmPage]]];
    }
    return xml;
}

// IPAD-4687
-(NSString *)getHeaderRecordNode:(SFMPage *)sfmPage
{
    NSMutableString *xml = [[NSMutableString alloc] initWithString:@""];
    
    NSString *parentColumnName = @"";
    NSString *pageLayoutId = sfmPage.process.pageLayout.headerLayout.hdrLayoutId;
    
    NSMutableString *tempXML = [[NSMutableString alloc] initWithString:@""];
    
    [tempXML appendString:[NSString stringWithFormat:@"<%@>%@</%@>",KObjName,sfmPage.objectName,KObjName]];
    [tempXML appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kAliasName,pageLayoutId,kAliasName]];
    [tempXML appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kParentColumnName,parentColumnName,kParentColumnName]];
    [tempXML appendString:[NSString stringWithFormat:@"<%@></%@>",kDeleteRecID,kDeleteRecID]];
    [tempXML appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kPageLayoutId,pageLayoutId,kPageLayoutId]];
    
    NSMutableString *recordsXML = [NSMutableString stringWithString:@""];
    [recordsXML appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kRecords,[self getRecordXMLString:sfmPage.headerRecord], kRecords]];
    [tempXML appendString:recordsXML];
    
    [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",KHeaderRecord,tempXML,KHeaderRecord]];
    return xml;
}

// IPAD-4687 - aliasname, parentcolumn name, targetRecordId is mandatory
-(NSString *)getDetailsRecordNode:(SFMPage *)sfmPage
{
    NSDictionary *detailRecords = sfmPage.detailsRecord;
    NSMutableString *xml = [[NSMutableString alloc] initWithString:@""];
    NSDictionary *objectDict = [self getProcessComponentIdFromSfPage:sfmPage];
    NSDictionary *pageLayoutDict = [self getPageLayoutIds:sfmPage.process.pageLayout.detailLayouts];
    
    NSMutableString *tempXML = [[NSMutableString alloc] initWithString:@""];
    
    for (NSString *pageLayoutId in pageLayoutDict) {
        
        NSString *parentColumnName;
        SFProcessComponentModel *processComponent = [sfmPage.process.component objectForKey:pageLayoutId];
        if (processComponent) {
            parentColumnName = processComponent.parentColumnName;
        }
        
        if (parentColumnName == nil) {
            parentColumnName = @"";
        }
        
        NSString *objectName = [objectDict objectForKey:pageLayoutId];
        NSString *layoutId = [pageLayoutDict objectForKey:pageLayoutId];
        
        [tempXML appendString:[NSString stringWithFormat:@"<%@>%@</%@>",KObjName,objectName,KObjName]];
        [tempXML appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kAliasName,layoutId,kAliasName]];
        [tempXML appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kParentColumnName,parentColumnName,kParentColumnName]];
        [tempXML appendString:[NSString stringWithFormat:@"<%@></%@>",kDeleteRecID,kDeleteRecID]];
        [tempXML appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kPageLayoutId,layoutId,kPageLayoutId]];
        
        NSArray *componentLevelRecords = [detailRecords objectForKey:pageLayoutId];
        NSMutableString *recordsXML = [NSMutableString stringWithString:@""];
        for (NSDictionary *record in componentLevelRecords) {
            [recordsXML appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kRecords,[self getRecordXMLString:record], kRecords]];
        }
        
        [tempXML appendString:recordsXML];
        [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kDetailRecords,tempXML,kDetailRecords]];
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
                [xml appendString:[NSString stringWithFormat:@"%@",[self getValueNode:[dict objectForKey:string]]]];
            }
        }
    }
    
    SFMRecordFieldData *recordData = [dict objectForKey:kId];
    [xml appendString:[NSString stringWithFormat:@"<%@>%@</%@>",kTargetRecordId,recordData.internalValue,kTargetRecordId]];
    [xml appendString:[NSString stringWithFormat:@"<%@></%@>",kSourceRecordId,kSourceRecordId]];

    return xml;
}

-(NSString *)getValueNode:(SFMRecordFieldData *)recordFieldData
{
    NSMutableString *xml = [[NSMutableString alloc] initWithString:@""];
    
    NSString *key = [NSString stringWithFormat:@"<%@>%@</%@>",kKey,recordFieldData.name,kKey];
    
    NSString *inval = recordFieldData.internalValue;
    NSString *value = [NSString stringWithFormat:@"<%@>%@</%@>",kValue,inval,kValue];
    
    [xml appendString:[NSString stringWithFormat:@"<%@>%@%@</%@>", kTargetRecordAsKeyValue, key, value, kTargetRecordAsKeyValue]];
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
