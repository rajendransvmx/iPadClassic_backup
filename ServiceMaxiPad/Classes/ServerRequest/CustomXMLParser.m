//
//  CustomXMLParser.m
//  ServiceMaxiPad
//
//  Created by Admin on 27/07/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "CustomXMLParser.h"
#import "DODHelper.h"
#import "TXFetchHelper.h"
#import "StringUtil.h"
#import "TransactionObjectModel.h"
#import "DODRecordsModel.h"
#import "DODRecordsDAO.h"
#import "FactoryDAO.h"
#import "DateUtil.h"
#import "Utility.h"
#import "DBRequestUpdate.h"
#import "TransactionObjectService.h"
#import "SyncManager.h"
#import "SFMPageEditManager.h"
#import "ModifiedRecordsDAO.h"

@interface CustomXMLParser ()
@property(nonatomic, strong) NSMutableDictionary *something;
@property(nonatomic, strong) NSMutableDictionary *currentDictionary;
@property(nonatomic, strong) TXFetchHelper *helper;
@property (nonatomic, strong) NSString *elementName;
@property (nonatomic, strong) NSMutableString *outstring;
@property (nonatomic, strong) NSXMLParser *parser;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) id operation;
@property (nonatomic, assign) int status;
@property (nonatomic, strong) NSError *resError;
@end

@implementation CustomXMLParser
@synthesize customDelegate;
@synthesize resError;

-(instancetype)initwithNSXMLParserObject:(NSXMLParser *)responseData andError:(NSError *)error andOperation:(id)operation;
{
    if(self == [super init]) {
        self.parser = responseData;
        [self.parser setDelegate:self];
        self.error = error;
        self.operation = operation;
    }      
    return self;
}
-(instancetype)initwithNSXMLParserObject:(NSXMLParser *)responseData andOperation:(id)operation
{
    if(self == [super init]) {
        self.parser = responseData;
        [self.parser setDelegate:self];
        self.operation = operation;
    }
    return self;
}

-(void)parse
{
    [self.parser parse];
}
-(void)parseRequestBody:(NSString *)XMLString isAfterBefore:(BOOL)isAftrebefore
{
    NSError *error = nil;
    if (XMLString) {
        if (isAftrebefore)
            [self getJsonResponse:[XMLReader dictionaryForXMLString:XMLString error:&error]];
        else
            [self getJsonResponseForCustomAction:[XMLReader dictionaryForXMLString:XMLString error:&error]];
    }
    self.status = 1;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.something = [NSMutableDictionary dictionary];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser;
{
    NSLog(@"self.something :%@", self.something);
    if (self.status == 1)
    {
        NSLog(@"save record");
    }
    else
    {
        if ([customDelegate respondsToSelector:@selector(customErrorResponse:andError:andOperation:)]) {
            [customDelegate customErrorResponse:self.something andError:self.error andOperation:self.operation];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    self.elementName = elementName;
    if (self.status == 1)
    {
        NSLog(@"save record");
        if ([elementName isEqualToString:@"result"])
        {
            
        }
    }
    else
    {
    
        if ([elementName isEqualToString:@"faultcode"] ||
            [elementName isEqualToString:@"faultstring"]) {
            self.currentDictionary = [NSMutableDictionary dictionary];
        }
        
        self.outstring = [NSMutableString string];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (!self.elementName)
        return;
    
    [self.outstring appendFormat:@"%@", string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (self.status == 1)
    {
        NSLog(@"save record");
        if ([elementName isEqualToString:@"result"])
        {
            
        }
    }
    else
    {
        // 1
        if ([elementName isEqualToString:@"faultcode"] ||
            [elementName isEqualToString:@"faultstring"]) {
            self.currentDictionary[elementName] = self.outstring;
            self.something[elementName] = self.outstring;//@[self.currentDictionary];
            self.currentDictionary = nil;
        }
        /*
        // 2
        else if ([qName isEqualToString:@"weather"]) {
            
            // Initialize the list of weather items if it doesn't exist
            NSMutableArray *array = self.something[@"weather"] ?: [NSMutableArray array];
            
            // Add the current weather object
            [array addObject:self.currentDictionary];
            
            // Set the new array to the "weather" key on something dictionary
            self.something[@"weather"] = array;
            
            self.currentDictionary = nil;
        }
        // 3
        else if ([qName isEqualToString:@"value"]) {
            // Ignore value tags, they only appear in the two conditions below
        }
        // 4
        else if ([qName isEqualToString:@"weatherDesc"] ||
                 [qName isEqualToString:@"weatherIconUrl"]) {
            NSDictionary *dictionary = @{@"value": self.outstring};
            NSArray *array = @[dictionary];
            self.currentDictionary[qName] = array;
        }
         */
        // 5
    //    else
    //        if (elementName) {
        self.currentDictionary[elementName] = self.outstring;
    //    }
        
        self.elementName = nil;
    }
}
-(void)getJsonResponseForCustomAction:(NSDictionary *)responseData
{
    
}
-(void)getJsonResponse:(NSDictionary *)responseData
{
    NSDictionary *temp = [responseData objectForKey:@"soapenv:Envelope"];
    if (temp) {
        if ([temp isKindOfClass:[NSDictionary class]]) {
            temp = [temp objectForKey:@"soapenv:Body"];
        }
        if (temp) {
            if ([temp isKindOfClass:[NSDictionary class]]) {
               NSDictionary* tempClose = [temp objectForKey:@"closeWorkOrderResponse"];
                if (!tempClose)
                    temp = [temp objectForKey:@"WSNameResponse"];
                else
                    temp = tempClose;
            }
            if (temp) {
                if ([temp isKindOfClass:[NSDictionary class]]) {
                    temp = [temp objectForKey:@"result"];
                }
                
                //header parshing and update
                if (temp) {
                    if ([temp isKindOfClass:[NSDictionary class]]) {
                        /* for header record */
                        NSDictionary *headerDict;
                        headerDict = [temp objectForKey:@"SFM_PageData:pageDataSet"];
                        if (headerDict) {
                            [self parshingHeaderRecord:headerDict];
                        }
                        
                        /* for one child line */
                        NSDictionary *detailDictValue;
                        detailDictValue = [temp objectForKey:@"SFM_PageData:detailDataSet"];
                        if ([detailDictValue isKindOfClass:[NSDictionary class]])
                        {
                            [self parshingChildRecord:detailDictValue];
                        }
                        else
                        {
                            /* for multiple child line */
                            NSArray *detailDictValues = [temp objectForKey:@"SFM_PageData:detailDataSet"];
                            if ([detailDictValues isKindOfClass:[NSArray class]])
                            {
                                for(NSDictionary *detailValueDict in detailDictValues) {
                                    [self parshingChildRecord:detailValueDict];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    /* refresh all screens with new data*/
    [self sendNotification:kUpadteWebserviceData andUserInfo:nil];
}

-(void)parshingHeaderRecord:(NSDictionary *)detailDictValueTemp
{
    if ([detailDictValueTemp isKindOfClass:[NSDictionary class]]) {
        detailDictValueTemp = [detailDictValueTemp objectForKey:@"SFM_PageData:sobjectinfo"];
    }
    NSDictionary *dict = [self getRecords:detailDictValueTemp];
    NSString *objectName = [detailDictValueTemp objectForKey:@"xsi:type"];
    if ([detailDictValueTemp isKindOfClass:[NSDictionary class]]) {
        NSDictionary *id_temp = [detailDictValueTemp objectForKey:@"Id"];
        if (id_temp) {
            NSString *sfId = [id_temp objectForKey:@"text"];
            TransactionObjectModel *model = [[TransactionObjectModel alloc] initWithObjectApiName:objectName];
            [model setFieldValueDictionaryForFields:dict];
            NSMutableDictionary *objectrecords = [[NSMutableDictionary alloc] initWithCapacity:0];
            if (![StringUtil isStringEmpty:sfId])
                [objectrecords setObject:model forKey:sfId];
            [self updateOrInsertTransactionObjectArray:objectrecords sfIdArray:[objectrecords allKeys] objectName:objectName];
        }
    }
}
-(void)parshingChildRecord:(NSDictionary *)detailDictValue
{
    NSDictionary *detailDictValueTemp;
    if ([detailDictValue isKindOfClass:[NSDictionary class]]) {
        detailDictValueTemp = [detailDictValue objectForKey:@"SFM_PageData:pageDataSet"];
        if (detailDictValueTemp)
        {
            if ([detailDictValueTemp isKindOfClass:[NSDictionary class]]) {
                detailDictValueTemp = [detailDictValueTemp objectForKey:@"SFM_PageData:sobjectinfo"];
            }
            NSDictionary *dict = [self getRecords:detailDictValueTemp];
            NSString *objectName = [detailDictValueTemp objectForKey:@"xsi:type"];
            if ([detailDictValueTemp isKindOfClass:[NSDictionary class]]) {
                NSDictionary *id_temp = [detailDictValueTemp objectForKey:@"Id"];
                if (id_temp) {
                    NSString *sfId = [id_temp objectForKey:@"text"];
                    TransactionObjectModel *model = [[TransactionObjectModel alloc] initWithObjectApiName:objectName];
                    [model setFieldValueDictionaryForFields:dict];
                    NSMutableDictionary *objectrecords = [[NSMutableDictionary alloc] initWithCapacity:0];
                    if (![StringUtil isStringEmpty:sfId])
                        [objectrecords setObject:model forKey:sfId];
                    [self updateOrInsertTransactionObjectArray:objectrecords sfIdArray:[objectrecords allKeys] objectName:objectName];
                }
            }
        }
    }
}

-(NSDictionary *)getRecords:(NSDictionary *)responseInfo
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (NSString *key in [responseInfo allKeys]) {
        NSDictionary *id_temp = [responseInfo objectForKey:key];
        if (id_temp) {
            if ([id_temp isKindOfClass:[NSDictionary class]]) {
                NSString *sfId = [id_temp objectForKey:@"text"];
                if (sfId) {
                     [dict setObject:sfId forKey:key];
                }
            }
        }
    }
    return dict;
}
- (void)sendNotification:(NSString *)notificationName andUserInfo:(NSDictionary *)userInfo {
    
    NSMutableDictionary *notificationDict = [[NSMutableDictionary alloc] init];
    [notificationDict setValue:notificationName forKey:@"NotoficationName"];
    [notificationDict setValue:userInfo forKey:@"UserInfo"];
    [self performSelectorOnMainThread:@selector(postNotification:) withObject:notificationDict waitUntilDone:YES];
    //[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userInfo];
}
- (void)postNotification:(NSDictionary *)notificationDict
{
    NSString *notificationName = [notificationDict objectForKey:@"NotoficationName"];
    NSDictionary *userInfo = [notificationDict objectForKey:@"UserInfo"];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userInfo];
}

- (void)updateOrInsertTransactionObjectArray:(NSMutableDictionary *)objectrecords sfIdArray:(NSArray*)sfidArray objectName:(NSString *)objectName
{
    NSArray *actualRecordsArray = [self getRecordsArrayForObjectName:objectName andSFIDArray:sfidArray];
    NSMutableArray *updatedModelArray =[[NSMutableArray alloc] initWithCapacity:0];
    self.helper = [[TXFetchHelper alloc] initWithCheckForDuplicateRecords:YES];
    for (TransactionObjectModel *model in actualRecordsArray)
    {
        NSMutableDictionary *actualModelDict = [model getFieldValueMutableDictionary];
        NSString *recordSFID = [actualModelDict objectForKey:kId];
        TransactionObjectModel *toBeUpdatedModel = [objectrecords objectForKey:recordSFID];
        
        NSMutableDictionary *toBeUpdatedDict = [toBeUpdatedModel getFieldValueMutableDictionary];
        if ([toBeUpdatedDict objectForKey:kAttributeKey]) {
            [toBeUpdatedDict removeObjectForKey:kAttributeKey];
        }
        [self fieldMergeHelper:toBeUpdatedDict andObjectName:objectName andRecordID:[actualModelDict objectForKey:kLocalId] andSfid:recordSFID];
        NSArray *toBeUpdatedAllKeys = [toBeUpdatedDict allKeys];
        
        for (NSString *keyString in toBeUpdatedAllKeys)
        {
            NSString *valueToBeUpdated = [toBeUpdatedDict valueForKey:keyString];
            if (![StringUtil isStringNotNULL:valueToBeUpdated])
            {
                valueToBeUpdated = @"";
            }
            [actualModelDict setValue:valueToBeUpdated forKey:keyString];
        }
        [model setFieldValueDictionaryForFields:actualModelDict];
        [updatedModelArray addObject:model];
    }
    [self.helper insertObjects:updatedModelArray withObjectName:objectName];
}

- (NSArray*)getRecordsArrayForObjectName:(NSString*)objName andSFIDArray:(NSArray*)array
{
    id <TransactionObjectDAO> transactionService = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
    DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:array];
    NSArray *dataArray = [transactionService fetchDataForObject:objName fields:nil expression:nil criteria:@[criteria]];
    return dataArray;
}

-(void)fieldMergeHelper:(NSDictionary *)toBeUpdatedRecords andObjectName:(NSString *)objectName andRecordID:(NSString *)recordID andSfid:(NSString *)sfid
{
    
    SFMPageEditManager *pageEditManager = [[SFMPageEditManager alloc]init];
    pageEditManager.dataDictionaryAfterModification = [[NSMutableDictionary alloc]initWithDictionary: toBeUpdatedRecords];
    
    NSString *modifiedFieldAsJson = [pageEditManager getJsonStringAfterComparisionForObject:objectName recordId:recordID sfid:sfid andSettingsFlag:YES];
    if (!modifiedFieldAsJson) {
        return;
    }
    
    id <ModifiedRecordsDAO>modifiedRecordService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
    NSArray *modifiedRecordList =   [modifiedRecordService getModifiedRecordListforRecordId:recordID sfid:sfid];
    
    if (modifiedRecordList && modifiedRecordList.count) {
        ModifiedRecordModel *model = [modifiedRecordList objectAtIndex:0];
        model.fieldsModified = modifiedFieldAsJson;
        
        [modifiedRecordService updateFieldsModifed:model];
        
    }
    
}
@end
