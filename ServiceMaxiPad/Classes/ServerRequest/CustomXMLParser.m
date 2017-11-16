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
#import "CustomActionWebserviceModel.h"
#import "CacheManager.h"
#import "CacheConstants.h"
#import "StringUtil.h"
#import "AlertViewHandler.h"
#import "TagManager.h"
#import "CustomActionsDAO.h"
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
    NSDictionary *temp = [responseData objectForKey:@"soapenv:Envelope"];
    if (temp) {
        if ([temp isKindOfClass:[NSDictionary class]]) {
            temp = [temp objectForKey:@"soapenv:Body"];
        }
        if (temp) {
            if ([temp isKindOfClass:[NSDictionary class]]) {
                //NSDictionary* tempClose = [temp objectForKey:@"takeWOOwnershipResponse"];
                //Defect fix:033695
                CustomActionWebserviceModel *customActionWebserviceModel = [[CacheManager sharedInstance] getCachedObjectByKey:kCustomWebServiceAction];
                NSString *methodName = customActionWebserviceModel.methodName;
                methodName = [self getMethodNameForParsing:methodName];
                NSDictionary* tempClose = [temp objectForKey:methodName];
                if (tempClose)
                {
                    temp = tempClose;
                    
                }

            }
            if (temp) {
                if ([temp isKindOfClass:[NSDictionary class]]) {
                    temp = [temp objectForKey:@"result"];
                }
                if (temp) {
                    if ([temp isKindOfClass:[NSDictionary class]]) {
//                        temp = [temp objectForKey:@"INTF_Response:valueMap"];
//                        Array of valueMaps
                        id valueMapArray=[temp objectForKey:@"INTF_Response:valueMap"];
                        if ([valueMapArray isKindOfClass:[NSDictionary class]]) {
                            temp = [valueMapArray objectForKey:@"INTF_Response:record"];
                            if ([temp isKindOfClass:[NSDictionary class]]) {
                                NSDictionary *dict = [self getRecords:temp];
                                NSString *objectName = [temp objectForKey:@"xsi:type"];
                                if ([temp isKindOfClass:[NSDictionary class]])
                                {
                                    NSDictionary *id_temp = [temp objectForKey:@"Id"];
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
                        else if ([valueMapArray isKindOfClass:[NSArray class]]){
                            for(NSDictionary *valueMapDict in valueMapArray){
                                NSDictionary * errorDict = [valueMapDict objectForKey:@"INTF_Response:key"];
                                NSString *errorKey;
                                if ([errorDict objectForKey:@"text"]) {
                                    errorKey = [errorDict objectForKey:@"text"];
                                }
                                if ([valueMapDict objectForKey:@"INTF_Response:valueMap"]) {
                                    NSDictionary *objectNameDict=[valueMapDict objectForKey:@"INTF_Response:value"];
                                    NSString *objectName;
                                    NSString *idValue;
                                    NSString *localIdValue;
                                    NSString *recordValues;
                                    if ([objectNameDict isKindOfClass:[NSDictionary class]]) {
                                        objectName = [objectNameDict objectForKey:@"text"];
                                    }
                                    NSArray *objectValueMapArray =[valueMapDict objectForKey:@"INTF_Response:valueMap"];
                                    for (NSDictionary *recordMap in objectValueMapArray) {
                                        if ([recordMap objectForKey:@"INTF_Response:key"]) {
                                            NSString *keyValue;
                                            NSDictionary *keyValueDict =[recordMap objectForKey:@"INTF_Response:key"];
                                            if ([keyValueDict isKindOfClass:[NSDictionary class]]) {
                                                keyValue = [keyValueDict objectForKey:@"text"];
                                            }
                                            if ([keyValue isEqualToString:@"UPDATED_IDS"]) {
                                                NSDictionary *idValueDict= [recordMap objectForKey:@"INTF_Response:values"];
                                                if ([idValueDict isKindOfClass:[NSDictionary class]]) {
                                                    idValue = [idValueDict objectForKey:@"text"];
                                                }
                                            }
                                            else if ([keyValue isEqualToString:@"INSERTED_IDS"]) {
                                                NSDictionary *localIdValueMapDict= [recordMap objectForKey:@"INTF_Response:valueMap"];
                                                if ([localIdValueMapDict isKindOfClass:[NSDictionary class]]) {
                                                    NSDictionary *localIdDict= [localIdValueMapDict objectForKey:@"INTF_Response:key"];
                                                    if ([localIdDict isKindOfClass:[NSDictionary class]]) {
                                                        localIdValue = [localIdDict objectForKey:@"text"];
                                                    }
                                                    NSDictionary *idValueDict= [localIdValueMapDict objectForKey:@"INTF_Response:value"];
                                                    if ([idValueDict isKindOfClass:[NSDictionary class]]) {
                                                        idValue = [idValueDict objectForKey:@"text"];
                                                        
                                                        DBField *aField = [[DBField alloc] initWithFieldName:kId andTableName:objectName];
                                                        DBCriteria *aDbcriteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorEqual andFieldValue:localIdValue];
                                                        TransactionObjectService *service = [[TransactionObjectService alloc] init];
                                                        [service updateField:aField withValue:idValue andDbCriteria:aDbcriteria];
                                                    }
                                                    
                                                }
                                            }
                                            else if ([[keyValue uppercaseString] isEqualToString:@"RECORD"]) {
                                                NSDictionary *recordValueDict= [recordMap objectForKey:@"INTF_Response:value"];
                                                if ([recordValueDict isKindOfClass:[NSDictionary class]]) {
                                                    recordValues = [recordValueDict objectForKey:@"text"];
                                                }
                                            }
                                        }
                                        
                                    }
                                    NSString *sfId = ([StringUtil checkIfStringEmpty:localIdValue])?idValue :localIdValue ;
                                    NSData *attributesData = [recordValues dataUsingEncoding:NSUTF8StringEncoding];
                                    NSArray *recordArray = [NSJSONSerialization JSONObjectWithData:attributesData options:0 error:nil];
                                    if (recordArray.count) {
                                        NSDictionary *dict=[recordArray objectAtIndex:0];
                                        TransactionObjectModel *model = [[TransactionObjectModel alloc] initWithObjectApiName:objectName];
                                        [model setFieldValueDictionaryForFields:dict];
                                        NSMutableDictionary *objectrecords = [[NSMutableDictionary alloc] initWithCapacity:0];
                                        if (![StringUtil isStringEmpty:sfId])
                                            [objectrecords setObject:model forKey:sfId];
                                        [self updateOrInsertTransactionObjectArray:objectrecords sfIdArray:[objectrecords allKeys] objectName:objectName];
                                        
                                        id <CustomActionsDAO>customActionRequestService = [FactoryDAO serviceByServiceType:ServiceTypeCustomActionRequestParams];
                                        [customActionRequestService deleteRecordsForRecordLocalIds:@[idValue,localIdValue]];
                                        
                                        id <ModifiedRecordsDAO>modifiedService = [FactoryDAO serviceByServiceType:ServiceTypeModifiedRecords];
                                        [modifiedService deleteRecordsForRecordLocalIds:@[idValue,localIdValue]];
                                        
                                    }
                                    SXLogDebug(@"VALUES %@  -- %@ ---\n record :%@",localIdValue,idValue,recordValues);
                                    
                                }
                                else if ([[errorKey uppercaseString]isEqualToString:@"ERROR"]){
                                    NSDictionary * errMsgDict = [valueMapDict objectForKey:@"INTF_Response:value"];
                                    if ([errMsgDict objectForKey:@"INTF_Response:value"]) {
                                        NSString *errorMsg = [errMsgDict objectForKey:@"INTF_Response:value"];
                                        if (![StringUtil checkIfStringEmpty:errorMsg]) {
                                            SXLogError(@"CUSTOM ACTIONS ERROR : %@",errorMsg);
                                            
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                AlertViewHandler *alert = [[AlertViewHandler alloc] init];
                                                [alert showAlertViewWithTitle:[[TagManager sharedInstance]tagByName:kTagSyncErrorMessage]
                                                                      Message:errorMsg
                                                                     Delegate:nil cancelButton:[[TagManager sharedInstance]tagByName:kTagAlertErrorOk]
                                                               andOtherButton:nil];
                                            });
                                        }
                                        
                                    }
                                    else{
                                        NSUserDefaults *userdefaults= [NSUserDefaults standardUserDefaults];
                                        [userdefaults removeObjectForKey:@"custom_actions_req_id"];
                                        [userdefaults synchronize];
                                    }
                                }
                                else{
                                    temp = [valueMapDict objectForKey:@"INTF_Response:record"];
                                    if ([temp isKindOfClass:[NSDictionary class]]) {
                                        NSDictionary *dict = [self getRecords:temp];
                                        NSString *objectName = [temp objectForKey:@"xsi:type"];
                                        if ([temp isKindOfClass:[NSDictionary class]])
                                        {
                                            NSDictionary *id_temp = [temp objectForKey:@"Id"];
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
                            
                        }


                    }
                }
            }
        }
    }
    /* refresh all screens with new data*/
    [self sendNotification:kUpadteWebserviceData andUserInfo:nil];
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
            /*
               NSDictionary* tempClose = [temp objectForKey:@"closeWorkOrderResponse"]; //HS Same fix take mothod nme from DB
                if (!tempClose)
                    temp = [temp objectForKey:@"WSNameResponse"];//dont need to check this
                else
                    temp = tempClose;
            }
            */
                //Defect fix:033695 - Part2 Fixed for CustomWebservice Also.
                CustomActionWebserviceModel *customActionWebserviceModel = [[CacheManager sharedInstance] getCachedObjectByKey:kCustomWebServiceAction];
                SFMPage *sfmpage = customActionWebserviceModel.sfmPage;
                
                NSString *methodName =  [self methodNameForCustomWebService:sfmpage.process.pageLayout.headerLayout.pageLevelEvents];
                if (methodName)
                {
                    temp = [temp objectForKey:methodName];
                }
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

//Defect fix:033695 - Part2 Fixed for CustomWebService Also.
-(NSString *)methodNameForCustomWebService:(NSArray *)thePageLevelEvent
{
    
    NSString *theMethodName = nil;
    NSString *theURL = nil;
    for (NSDictionary *tempDict in thePageLevelEvent) {
        NSString *eventCallType = [tempDict objectForKey:kPageEventCallType];
        NSString *eventType = [tempDict objectForKey:kPageEventType];
        
        if ([eventCallType isEqualToString:@"WEBSERVICE"]) {
            
            if (([StringUtil containsString:kAfterSaveInsertKey inString:eventType]) || ([StringUtil containsString:kBeforeSaveProcessKey inString:eventType]) || ([StringUtil containsString:kAfterSaveProcessKey inString:eventType])) {
                theURL = [tempDict objectForKey:kPageTargetCall];
            }
            
        }
    }
    
    theURL = [theURL stringByReplacingOccurrencesOfString:@"." withString:@"/"];
    if (theURL)
    {
        theMethodName = [theURL lastPathComponent];
        theMethodName = [self getMethodNameForParsing:theMethodName];
        
    }
    
    return theMethodName;
}
//As Server is expecting to append "Response" to methodName of CustomAction/CustomWebservice
-(NSString *)getMethodNameForParsing:(NSString *)methodName{
    NSString *methodNameforParsing = nil;
    methodNameforParsing = [methodName stringByAppendingString:@"Response"];
    return methodNameforParsing;
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

// IPAD-4687 - if child record count is more than 1, then response will of type NSArray,not NSDictionary
-(void)parshingChildRecord:(NSDictionary *)detailDictValue
{
    id detailDictValueTemp;
    if ([detailDictValue isKindOfClass:[NSDictionary class]]) {
        detailDictValueTemp = [detailDictValue objectForKey:@"SFM_PageData:pageDataSet"];
        if (detailDictValueTemp)
        {
            if ([detailDictValueTemp isKindOfClass:[NSDictionary class]]) {
                detailDictValueTemp = [detailDictValueTemp objectForKey:@"SFM_PageData:sobjectinfo"];
            }
            
            if([detailDictValueTemp isKindOfClass:[NSDictionary class]]) {
                [self updateChildRecordInDB:detailDictValueTemp];
            }
            
            if([detailDictValueTemp isKindOfClass:[NSArray class]]) {
                for (NSDictionary *tempDict in detailDictValueTemp) {
                    NSDictionary *objectInfoDict = [tempDict objectForKey:@"SFM_PageData:sobjectinfo"];
                    if([objectInfoDict isKindOfClass:[NSDictionary class]]) {
                        [self updateChildRecordInDB:objectInfoDict];
                    }
                }
            }
        }
    }
}

// IPAD-4687
-(void)updateChildRecordInDB:(NSDictionary *)recordDict
{
    NSDictionary *dict = [self getRecords:recordDict];
    NSString *objectName = [recordDict objectForKey:@"xsi:type"];
    if ([recordDict isKindOfClass:[NSDictionary class]]) {
        NSDictionary *id_temp = [recordDict objectForKey:@"Id"];
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
    DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:array];
    DBCriteria *criteria2 = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:SQLOperatorIn andFieldValues:array];

    NSArray *dataArray = [transactionService fetchDataForObject:objName fields:nil expression:@"(1 OR 2)" criteria:@[criteria1,criteria2]];
    return dataArray;
}

-(void)fieldMergeHelper:(NSDictionary *)toBeUpdatedRecords andObjectName:(NSString *)objectName andRecordID:(NSString *)recordID andSfid:(NSString *)sfid
{
    
    SFMPageEditManager *pageEditManager = [[SFMPageEditManager alloc]init];
    pageEditManager.dataDictionaryAfterModification = [[NSMutableDictionary alloc]initWithDictionary: toBeUpdatedRecords];
     NSString *modifiedFieldAsJson = [pageEditManager getModifiedJSONStringForObject:objectName recordId:recordID sfid:sfid];
//    NSString *modifiedFieldAsJson = [pageEditManager getJsonStringAfterComparisionForObject:objectName recordId:recordID sfid:sfid andSettingsFlag:YES];
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
