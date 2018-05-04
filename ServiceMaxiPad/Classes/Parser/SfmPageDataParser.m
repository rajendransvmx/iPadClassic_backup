//
//  SfmPageDataParser.m
//  ServiceMaxiPhone
//
//  Created by Sahana on 30/01/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SfmPageDataParser.h"
#import "ResponseConstants.h"
#import "PageLayoutConstants.h"
#import "SFProcessModel.h"
#import "DBCriteria.h"
#import "SFProcessDAO.h"
#import "FactoryDAO.h"
#import "StringUtil.h"
#import "CacheManager.h"
#import "ServerRequestManager.h"
#import "TimeLogCacheManager.h"

@implementation SfmPageDataParser
@synthesize referenceObjects;
@synthesize recordTypeObjects;

-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData;
{
    if (![responseData isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
   /* handling attempt to dereference a null objec for page layout Ids */
//    BOOL isSuccess = [[responseData objectForKey:@"success"] intValue];
//    if(!isSuccess)
//    {
//        return nil;
//    }
    
    @synchronized([self class]){
        @autoreleasepool {
            NSDictionary *responseDict = (NSDictionary *)responseData;
            
            ResponseCallback * callBackObj = [[ResponseCallback alloc] init];
            NSArray * pageUIList =[responseDict objectForKey:kSVMXPageUi];
            
            
            [self parseAndInsertIntoProcessTable:pageUIList];
            NSArray * callbackIds = [responseDict objectForKey:kSVMXValues];
            if([callbackIds count] > 0){
                callBackObj.callBack = YES;;
            }
            
            NSMutableDictionary * otherCallsInfo = [[NSMutableDictionary alloc] init];
            
            if(self.referenceObjects != nil && [self.referenceObjects count] > 0)
            {
                [otherCallsInfo setObject:self.referenceObjects forKey:@"REFERENCE"];
            }
            if(self.recordTypeObjects != nil && [self.recordTypeObjects count] >0)
            {
                [otherCallsInfo setObject:self.recordTypeObjects forKey:@"RECORDTYPE"];
            }
            
            callBackObj.otherCallSInformation = otherCallsInfo;
            
            RequestParamModel *paramModel = [[RequestParamModel alloc] init];
            if([callbackIds count] < kPageLimit)
            {
                NSArray *tempArray;
                tempArray = [self getTheRemainingIdsFromCacheForTheArray:callbackIds];
                if([tempArray count] >0)
                {
                    callBackObj.callBack = YES;
                    paramModel.values = tempArray;
                    
                }else
                {
                    callBackObj.callBack = NO;
                }
            }
            else
            {
                paramModel.values = callbackIds;
                
            }
            
            NSString *contextValue =  [[ServerRequestManager sharedInstance]
                                       getTheContextvalueForCategoryType:self.categoryType];
            
            NSArray *finalarray = [[TimeLogCacheManager sharedInstance] getRequestParameterForTimeLogWithCategory:contextValue forCategoryType:self.categoryType];
            
            if([finalarray count] > 0)
            {
                paramModel.valueMap = finalarray;
            }
            
            callBackObj.callBackData  = paramModel;
            return callBackObj;
        }
    }
    return nil;
}
-(void)getReferenceObjectNames:(NSDictionary *)fieldDict
{
    NSString * relatedObj = [fieldDict objectForKey:kPageFieldRelatedObjectName];
    relatedObj = (relatedObj != nil)?relatedObj:@"";
    if(self.referenceObjects == nil)
    {
        self.referenceObjects =  [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    if([relatedObj length] != 0)
    {
        [self.referenceObjects setObject:relatedObj forKey:relatedObj];
    }
}
-(void)getRecordTypeSupportingObjectNames:(NSDictionary *)fieldDict ObjectName:(NSString *)objectName
{
    
    NSString * fieldDataType = [fieldDict objectForKey:kPageFieldDataType];
    fieldDataType = (fieldDataType != nil)?fieldDataType:@"";
    NSString * fieldApiName = [fieldDict objectForKey:kPageFieldApiName];
    fieldApiName = (fieldApiName != nil)?fieldApiName:@"";
    if([fieldDataType isEqualToString:@"reference"] && [fieldApiName isEqualToString:@"RecordTypeId"])
    {
        if(self.recordTypeObjects == nil)
        {
            self.recordTypeObjects =  [[NSMutableDictionary alloc] initWithCapacity:0];
        }
        if([objectName length] != 0)
        {
            [self.recordTypeObjects setObject:objectName forKey:objectName];
        }
    }
}

-(void)parseAndInsertIntoProcessTable:(NSArray *)pageArray
{
    NSMutableArray * parsedPageArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (int counter = 0; counter < [pageArray count]; counter++) {
        NSDictionary * eachDict = [pageArray objectAtIndex:counter];
        
        NSDictionary * page = [eachDict objectForKey:@"page"];
        NSDictionary * headerDict = [page objectForKey:kSVMXPageHeader];
        NSDictionary * headerLayoutDict = [headerDict objectForKey:kPageHeaderLayout];
        NSString * objectApiName = [headerLayoutDict objectForKey:kPageHeaderObjectName];
        NSString * pageLayoutId = [headerDict objectForKey:kSVMXHdrLayoutId];
        
        NSDictionary * finalPageDict  = [self sfmPageDict:page];
    
        SFProcessModel * processModel = [[SFProcessModel alloc] init];
        processModel.pageLayoutId = pageLayoutId;
        processModel.processInfo = [self getNsdataFromDicitonary:finalPageDict];
        processModel.objectApiName = objectApiName;
        
        [parsedPageArray addObject:processModel];
    }
    
    [self updatePageDataForPageLayoutIds:parsedPageArray];
  
}

-(void)updatePageDataForPageLayoutIds:(NSArray *)processArray
{
    if([processArray count] >0)
    {
        id <SFProcessDAO> processDao = [FactoryDAO serviceByServiceType:ServiceTypeProcess];
        [processDao updatePageDataForPageLayoutIds:processArray];
    }
}


-(NSDictionary *)sfmPageDict:(NSDictionary *)pageDict
{
    NSMutableArray * detailDataArray = [self getDetailDictForPage:pageDict];
    NSDictionary * headerDataDict = [self getHeaderForPageDict:pageDict];
    NSArray * keys = [[NSArray alloc] initWithObjects:kPageHeader, kPageDetails, nil];
    NSArray * objects = [[NSArray alloc] initWithObjects:headerDataDict,detailDataArray,nil];
    NSDictionary * finalPagedict = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    return finalPagedict;
  
}
-(NSMutableArray *)getDetailDictForPage:(NSDictionary *)pageDict
{
    NSArray * details = [pageDict objectForKey:kSVMXPageDetails];
    NSMutableArray * detailDataArray = [[NSMutableArray alloc] initWithCapacity:0];
    for ( int j = 0; j < [details count]; j++)
    {
        NSMutableArray * fieldDetailArray = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray * eventsDetailArray = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableDictionary *  detailsFinalDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        
        NSDictionary * pageDetail = [details objectAtIndex:j];
        NSDictionary * detailLayout = [pageDetail objectForKey:@"DetailLayout"];
        NSArray * eventArray = [pageDetail objectForKey:kEventDetails];
        NSArray * fieldsArray = [pageDetail objectForKey:kPageDetailFields];
        NSString * detailObjApiname = [detailLayout objectForKey:kPageDetailObjectName];
        
        //012254
        for (NSDictionary *eventDict in eventArray) {
            NSMutableDictionary *eventFinalDict = [[NSMutableDictionary alloc] init];
            
            NSString * identifier = [eventDict objectForKey:kId];
            identifier = (identifier != nil)?identifier:@"";
            [eventFinalDict setObject:identifier forKey:kId];
            
            NSString * eventName = [eventDict objectForKey:kName];
            eventName = (eventName != nil)?eventName:@"";
            [eventFinalDict setObject:eventName forKey:kName];
            
            NSString * eventTypeCall = [eventDict objectForKey:kPageHeaderBtnEventCall];
            eventTypeCall = (eventTypeCall != nil)?eventTypeCall:@"";
            [eventFinalDict setObject:eventTypeCall forKey:kPageHeaderBtnEventCall];
            
            NSString * eventType = [eventDict objectForKey:kPageHeaderBtnEventType];
            eventType = (eventType != nil)?eventType:@"";
            [eventFinalDict setObject:eventType forKey:kPageHeaderBtnEventType];
            
            NSString * isStandard = [eventDict objectForKey:kPageHeaderIsStandard];
            NSNumber * isStandardNum = [NSNumber numberWithBool:(isStandard != nil  && ![isStandard isKindOfClass:[NSNull class]])?isStandard.boolValue:NO];
            [eventFinalDict setObject:isStandardNum forKey:kPageHeaderIsStandard];
            
            NSString * pageLayoutId = [eventDict objectForKey:kPageLayoutId];
            pageLayoutId = (pageLayoutId != nil)?pageLayoutId:@"";
            [eventFinalDict setObject:pageLayoutId forKey:kPageLayoutId];
            
            NSString * targetCall = [eventDict objectForKey:kPageTargetCall];
            targetCall = (targetCall != nil)?targetCall:@"";
            [eventFinalDict setObject:targetCall forKey:kPageTargetCall];
            
            [eventsDetailArray addObject:eventFinalDict];
        }
        
        for (int k = 0; k < [fieldsArray count]; k++)
        {
            NSDictionary * detailUiField = [fieldsArray objectAtIndex:k];
            
            NSMutableDictionary * detailDict = [[NSMutableDictionary alloc] initWithCapacity:0];
            
            NSDictionary * fieldDetaildict = [detailUiField objectForKey:kPageDetailFieldDetail];
            
            [self getReferenceObjectNames:fieldDetaildict];
            [self getRecordTypeSupportingObjectNames:fieldDetaildict ObjectName:detailObjApiname];
            
            NSString * fieldApi = [fieldDetaildict objectForKey:kPageFieldApiName];
            fieldApi = (fieldApi != nil)?fieldApi:@"";
            [detailDict setObject:fieldApi forKey:kPageFieldApiName];
            
            NSString * displaycolumn = [fieldDetaildict objectForKey:kPageFieldDisplayColumn];
            displaycolumn = (displaycolumn != nil)?displaycolumn:@"";
            [detailDict setObject:displaycolumn forKey:kPageFieldDisplayColumn];
            
            NSString * displayrow = [fieldDetaildict objectForKey:kPageFieldDisplayRow];
            displayrow = (displayrow != nil)?displayrow:@"";
            [detailDict setObject:displayrow forKey:kPageFieldDisplayRow];
            
            NSString * readOnly = [fieldDetaildict objectForKey:kPageFieldReadOnly];
            NSNumber * readOnlyNumber = [NSNumber numberWithBool:(readOnly != nil  && ![readOnly isKindOfClass:[NSNull class]])? readOnly.boolValue:NO];
            [detailDict setObject:readOnlyNumber forKey:kPageFieldReadOnly];
            
            NSString * required = [fieldDetaildict objectForKey:kPageFieldRequired];
            NSNumber * requiredNumber = [NSNumber numberWithBool:(required != nil  && ![required isKindOfClass:[NSNull class]])?required.boolValue:NO];
            [detailDict setObject:requiredNumber forKey:kPageFieldRequired];
            
            NSString * lookUpcontext = [fieldDetaildict objectForKey:kPageFieldLookupContext];
            lookUpcontext = (lookUpcontext != nil)?lookUpcontext:@"";
            [detailDict setObject:lookUpcontext forKey:kPageFieldLookupContext];
            
            NSString * lookUpQuery = [fieldDetaildict objectForKey:kPageFieldLookupQuery];
            lookUpQuery = (lookUpQuery != nil)?lookUpQuery:@"";
            [detailDict setObject:lookUpQuery forKey:kPageFieldLookupQuery];
            
            NSString * lookupcontextSource = [fieldDetaildict objectForKey:kPageFieldContextSourceObject];
            lookupcontextSource = (lookupcontextSource != nil)?lookupcontextSource:@"";
            [detailDict setObject:lookupcontextSource forKey:kPageFieldContextSourceObject];
            
            NSString * sequence = [fieldDetaildict objectForKey:kPageFieldSequence];
            sequence = (sequence != nil)?sequence:@"";
            [detailDict setObject:sequence forKey:kPageFieldSequence];
            
            NSString * namedSearch = [fieldDetaildict objectForKey:kPageFieldRelatedObjectSearchId];
            namedSearch = (namedSearch != nil)?namedSearch:@"";
            [detailDict setObject:namedSearch forKey:kPageFieldRelatedObjectSearchId];
            
            NSString * relatedObj = [fieldDetaildict objectForKey:kPageFieldRelatedObjectName];
            relatedObj = (relatedObj != nil)?relatedObj:@"";
            [detailDict setObject:relatedObj forKey:kPageFieldRelatedObjectName];
            
            NSString * dataType = [fieldDetaildict objectForKey:kPageFieldDataType];
            dataType = (dataType != nil)?dataType:@"";
            [detailDict setObject:dataType forKey:kPageFieldDataType];
            
            NSString * OverrideLookUp = [fieldDetaildict objectForKey:kPageFieldOverrideRelatedLookup];
            NSNumber * overrideNo = [NSNumber numberWithBool:(OverrideLookUp != nil && ![OverrideLookUp  isKindOfClass:[NSNull class]])?OverrideLookUp.boolValue:NO];
            [detailDict setObject:overrideNo forKey:kPageFieldOverrideRelatedLookup];
            
            NSString * fieldMapping = [fieldDetaildict objectForKey:kPageFieldMapping];
            fieldMapping = (fieldMapping != nil)?fieldMapping:@"";
            [detailDict setObject:fieldMapping forKey:kPageFieldMapping];
            
            
            [detailDict setObject:@"" forKey:kPageFieldLabel];
            [detailDict setObject:@"" forKey:kPageFieldValueKey];
            [detailDict setObject:@"" forKey:kPageFieldValueValue];
            
            [fieldDetailArray addObject:detailDict];
        }
        //sort the array according to the sequence no
        
        for(int x = 0; x < [fieldDetailArray count]; x++)
        {
            for(int y = 0; y < [fieldDetailArray count]-1; y++)
            {
                NSDictionary * dict = [fieldDetailArray objectAtIndex:y];
                NSString * sequence=[dict objectForKey:kPageFieldSequence];
                NSInteger sequence_no = [sequence integerValue];
                NSDictionary *dict_nxt = [fieldDetailArray objectAtIndex:y+1];
                NSString * sequence_nxt=[dict_nxt objectForKey:kPageFieldSequence];
                NSInteger sequence_no_nxt = [sequence_nxt integerValue];
                if(sequence_no > sequence_no_nxt)
                    [fieldDetailArray exchangeObjectAtIndex:y withObjectAtIndex:y+1];
            }
        }
        
       
        
        [detailsFinalDict setObject:fieldDetailArray forKey:kPageDetailFieldsArray];
        
        //Set events array
        [detailsFinalDict setObject:eventsDetailArray forKey:kEventDetails];
        
        NSString * detailLayoutId = [pageDetail objectForKey:kPageDetailLayoutId];
        detailLayoutId = (detailLayoutId != nil)?detailLayoutId:@"";
        [detailsFinalDict setObject:detailLayoutId forKey:kPageDetailLayoutId];
        
        NSString * detailHeaderRefField =   [detailLayout objectForKey:kPageDetailHeaderRefField];
        detailHeaderRefField = (detailHeaderRefField != nil)?detailHeaderRefField:@"";
        [detailsFinalDict setObject:detailHeaderRefField forKey:kPageDetailHeaderRefField];
        
        
        NSString * tempAllowNewLines = [detailLayout objectForKey:kPageDetailAllowNewLines];
        NSNumber * allowNewLinesNo = [NSNumber numberWithBool:(tempAllowNewLines != nil && ![tempAllowNewLines  isKindOfClass:[NSNull class]])?tempAllowNewLines.boolValue:NO];
        [detailsFinalDict setObject:allowNewLinesNo forKey:kPageDetailAllowNewLines];
        
        NSString * tempAllowDeleteLines = [detailLayout objectForKey:kPageDetailAllowDeleteLines];
        NSNumber * allowdeleteLinesNo = [NSNumber numberWithBool:(tempAllowDeleteLines != nil && ![tempAllowDeleteLines  isKindOfClass:[NSNull class]])?tempAllowDeleteLines.boolValue:NO];
        [detailsFinalDict setObject:allowdeleteLinesNo forKey:kPageDetailAllowDeleteLines];
        
        NSString * actionOnZeroLines = [detailLayout objectForKey:kPageDetailActionOnZeroLines];
        actionOnZeroLines = (actionOnZeroLines != nil)?actionOnZeroLines:@"";
        [detailsFinalDict setObject:actionOnZeroLines forKey:kPageDetailActionOnZeroLines];
        
        NSString * noOfColumns = [detailLayout objectForKey:kPageDetailNumberOfColumns];
        noOfColumns = (noOfColumns != nil)?noOfColumns:@"";
        [detailsFinalDict setObject:noOfColumns forKey:kPageDetailNumberOfColumns];
        
        NSString * detailName = [detailLayout objectForKey:kPageDetailObjectLabel];
        detailName = (detailName != nil)?detailName:@"";
        [detailsFinalDict setObject:detailName forKey:kPageDetailObjectLabel];
        
        NSString * headerRefField = [detailLayout objectForKey:kPageDetailHeaderRefField];
        headerRefField = (headerRefField != nil)?headerRefField:@"";
        [detailsFinalDict setObject:headerRefField forKey:kPageDetailHeaderRefField];
        
        NSString * detailobjname = [detailLayout objectForKey:kPageDetailObjectName];
        detailobjname = (detailobjname != nil)?detailobjname:@"";
        [detailsFinalDict setObject:detailobjname forKey:kPageDetailObjectName];
        
        NSString * detailsequenceNo = [detailLayout objectForKey:kPageDetailSequenceNo];
        detailsequenceNo = (detailsequenceNo != nil)?detailsequenceNo:@"";
        [detailsFinalDict setObject:detailsequenceNo forKey:kPageDetailSequenceNo];
        
        NSString * detailObjAlias = [detailLayout objectForKey:kPageDetailObjectAliasName];
        detailObjAlias = (detailObjAlias != nil)?detailObjAlias:@"";
        [detailsFinalDict setObject:detailObjAlias forKey:kPageDetailObjectAliasName];
        
        NSString * multiaddConfig = [detailLayout objectForKey:kPageDetailMuliaddConfig];
        multiaddConfig = (multiaddConfig != nil)?multiaddConfig:@"";
        [detailsFinalDict setObject:multiaddConfig forKey:kPageDetailMuliaddConfig];
        
        NSString * multiaddSearchConfig = [detailLayout objectForKey:kPageDetailMultiAddSearch];
        multiaddSearchConfig = (multiaddSearchConfig != nil)?multiaddSearchConfig:@"";
        [detailsFinalDict setObject:multiaddSearchConfig forKey:kPageDetailMultiAddSearch];
        
        NSString * multiaddSearchObj = [detailLayout objectForKey:kPageDetailMultiaddSearchObject];
        multiaddSearchObj = (multiaddSearchObj != nil)?multiaddSearchObj:@"";
        [detailsFinalDict setObject:multiaddSearchObj forKey:kPageDetailMultiaddSearchObject];
        
        NSString * pageLayoutId = [detailLayout objectForKey:kPageDetailPageLayoutId];
        pageLayoutId = (pageLayoutId != nil)?pageLayoutId:@"";
        [detailsFinalDict setObject:pageLayoutId forKey:kPageDetailPageLayoutId];
        
        [detailDataArray addObject:detailsFinalDict];
    }
    
    for(int x = 0; x < [detailDataArray count]; x++)
    {
        for(int y = 0; y < [detailDataArray count]-1; y++)
        {
            NSDictionary * dict = [detailDataArray objectAtIndex:y];
            NSString * sequence = [dict objectForKey:kPageDetailSequenceNo];
            NSInteger sequence_no = [sequence integerValue];
            NSDictionary *dict_nxt = [detailDataArray objectAtIndex:y+1];
            NSString * sequence_nxt=[dict_nxt objectForKey:kPageDetailSequenceNo];
            NSInteger sequence_no_nxt = [sequence_nxt integerValue];
            if(sequence_no > sequence_no_nxt)
                [detailDataArray exchangeObjectAtIndex:y withObjectAtIndex:y+1];
        }
    }
    
    return detailDataArray;

}


-(NSMutableArray *)getButtonsListFromHeader:(NSDictionary *)headerDict
{
    
    NSMutableArray * buttons_array = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray * buttonsArray = [headerDict objectForKey:kPageHeaderButtons];
    
    for ( NSDictionary * button in buttonsArray)
    {
        NSMutableArray * buttonEventsArray = nil;
        NSArray * buttonEvents = [button objectForKey:kPageHeaderButtonEvents];
        NSDictionary * buttonDetail = [button objectForKey:kPageHeaderButtonDetail];
        
        
        for (int be = 0; be < [buttonEvents count]; be++)
        {
            NSDictionary * bEvent = [buttonEvents objectAtIndex:be];
            
            NSMutableDictionary * buttonDict = [[NSMutableDictionary alloc] initWithCapacity:0];
            
            NSString * targetCall = [bEvent objectForKey:kPageHeaderBtnEventTarget];
            targetCall = (targetCall != nil)?targetCall:@"";
            [buttonDict setObject:targetCall forKey:kPageHeaderBtnEventTarget];
            
            NSString * eventCall = [bEvent objectForKey:kPageHeaderBtnEventCall];
            eventCall = (eventCall != nil)?eventCall:@"";
            [buttonDict setObject:eventCall forKey:kPageHeaderBtnEventCall];
            
            NSString * eventType = [bEvent objectForKey:kPageHeaderBtnEventType];
            eventType = (eventType != nil)?eventType:@"";
            [buttonDict setObject:eventType forKey:kPageHeaderBtnEventType];
            
            if (buttonEventsArray == nil)
                buttonEventsArray = [[NSMutableArray alloc] initWithCapacity:0];
            
            [buttonEventsArray addObject:buttonDict];
        }
        
        NSArray * buttonKeys = [[NSArray  alloc] initWithObjects:
                                       kPageHeaderBtnTitle,
                                       kPageHeaderBtnEvents,
                                       kPageHeaderBtnEnable,
                                       nil];
        
        NSString * btnTitle = [buttonDetail objectForKey:kPageHeaderBtnTitle];
        btnTitle = (btnTitle != nil)?btnTitle:@"";
        
        NSArray * eventsArray = (buttonEventsArray != nil)?buttonEventsArray:[[NSArray alloc] init];
        
        NSString * btnEnable = [button objectForKey:kPageHeaderBtnEnable];

        
        NSNumber * tempBtnEnable = (btnEnable != nil && ![btnEnable isKindOfClass:[NSNull class]])?[NSNumber numberWithBool:btnEnable.boolValue]:[NSNumber numberWithInt:1];
        
        NSArray * buttonObjects = [[NSArray  alloc] initWithObjects:
                                                                    btnTitle,
                                                                    eventsArray,
                                                                    tempBtnEnable, nil];
        NSMutableDictionary * dict = [[NSMutableDictionary alloc ] initWithObjects:buttonObjects forKeys:buttonKeys];
        
        [buttons_array addObject:dict];
    }
    return buttons_array;
}


-(NSMutableArray *)getAllsectionFields:(NSArray *)sections headerObjectNAme:(NSString *)headerObjectApiName
{
    NSMutableArray * hdrSections = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i = 0; i < [sections count]; i++)
    {
        NSMutableArray * hdrSectionFields = nil;
        NSDictionary * section = [sections objectAtIndex:i];
        
        NSArray * fields = [section objectForKey:kPageHeaderFields];
        
        for (int j = 0; j < [fields count]; j++)
        {
            NSDictionary * uiField = [fields objectAtIndex:j];
            NSDictionary * fieldDetaildict = [uiField objectForKey:kPageHeaderFieldDetail];
            [self getReferenceObjectNames:fieldDetaildict];
            [self getRecordTypeSupportingObjectNames:fieldDetaildict ObjectName:headerObjectApiName];
            
            NSMutableDictionary * eachSectionDict = [[NSMutableDictionary alloc] initWithCapacity:0];
            
            NSString * name = [fieldDetaildict objectForKey:kPageHeaderName];
            name = (name != nil)?name:@"";
            [eachSectionDict setObject:name forKey:kPageHeaderName];
            
            NSString * fieldApi = [fieldDetaildict objectForKey:kPageFieldApiName];
            fieldApi = (fieldApi != nil)?fieldApi:@"";
            [eachSectionDict setObject:fieldApi forKey:kPageFieldApiName];
            
            NSString * displaycolumn = [fieldDetaildict objectForKey:kPageFieldDisplayColumn];
            displaycolumn = (displaycolumn != nil)?displaycolumn:@"";
            [eachSectionDict setObject:displaycolumn forKey:kPageFieldDisplayColumn];
            
            NSString * displayrow = [fieldDetaildict objectForKey:kPageFieldDisplayRow];
            displayrow = (displayrow != nil)?displayrow:@"";
            [eachSectionDict setObject:displayrow forKey:kPageFieldDisplayRow];
            
            NSString * readOnly = [fieldDetaildict objectForKey:kPageFieldReadOnly];
            NSNumber * readOnlyNumber = [NSNumber numberWithBool:(readOnly != nil  && ![readOnly  isKindOfClass:[NSNull class]])?readOnly.boolValue:NO];
            [eachSectionDict setObject:readOnlyNumber forKey:kPageFieldReadOnly];
            
            NSString * required = [fieldDetaildict objectForKey:kPageFieldRequired];
            NSNumber * requiredNumber = [NSNumber numberWithBool:(required != nil && ![required  isKindOfClass:[NSNull class]])?required.boolValue:NO];
            [eachSectionDict setObject:requiredNumber forKey:kPageFieldRequired];
            
            NSString * lookUpcontext = [fieldDetaildict objectForKey:kPageFieldLookupContext];
            lookUpcontext = (lookUpcontext != nil)?lookUpcontext:@"";
            [eachSectionDict setObject:lookUpcontext forKey:kPageFieldLookupContext];
            
            NSString * lookUpQuery = [fieldDetaildict objectForKey:kPageFieldLookupQuery];
            lookUpQuery = (lookUpQuery != nil)?lookUpQuery:@"";
            [eachSectionDict setObject:lookUpQuery forKey:kPageFieldLookupQuery];
            
            NSString * lookupcontextSource = [fieldDetaildict objectForKey:kPageFieldContextSourceObject];
            lookupcontextSource = (lookupcontextSource != nil)?lookupcontextSource:@"";
            [eachSectionDict setObject:lookupcontextSource forKey:kPageFieldContextSourceObject];
            
            NSString * sequence = [fieldDetaildict objectForKey:kPageFieldSequence];
            sequence = (sequence != nil)?sequence:@"";
            [eachSectionDict setObject:sequence forKey:kPageFieldSequence];
            
            NSString * namedSearch = [fieldDetaildict objectForKey:kPageFieldRelatedObjectSearchId];
            namedSearch = (namedSearch != nil)?namedSearch:@"";
            [eachSectionDict setObject:namedSearch forKey:kPageFieldRelatedObjectSearchId];
            
            NSString * relatedObj = [fieldDetaildict objectForKey:kPageFieldRelatedObjectName];
            relatedObj = (relatedObj != nil)?relatedObj:@"";
            [eachSectionDict setObject:relatedObj forKey:kPageFieldRelatedObjectName];
            
            NSString * dataType = [fieldDetaildict objectForKey:kPageFieldDataType];
            dataType = (dataType != nil)?dataType:@"";
            [eachSectionDict setObject:dataType forKey:kPageFieldDataType];
            
            NSString * OverrideLookUp = [fieldDetaildict objectForKey:kPageFieldOverrideRelatedLookup];
            NSNumber * overrideNo = [NSNumber numberWithBool:(OverrideLookUp != nil && ![OverrideLookUp  isKindOfClass:[NSNull class]])?OverrideLookUp.boolValue:NO];
            [eachSectionDict setObject:overrideNo forKey:kPageFieldOverrideRelatedLookup];
            
            NSString * fieldMapping = [fieldDetaildict objectForKey:kPageFieldMapping];
            fieldMapping = (fieldMapping != nil)?fieldMapping:@"";
            [eachSectionDict setObject:fieldMapping forKey:kPageFieldMapping];
            
            NSString * SLAClock = [fieldDetaildict objectForKey:kPageHeaderSLAClock];
            NSNumber * SLAClockNo = [NSNumber numberWithBool:(SLAClock != nil && ![SLAClock  isKindOfClass:[NSNull class]])?SLAClock.boolValue:NO];
            [eachSectionDict setObject:SLAClockNo forKey:kPageHeaderSLAClock];
            
            if (hdrSectionFields == nil)
                hdrSectionFields = [[NSMutableArray alloc] initWithCapacity:0];
            
            [hdrSectionFields addObject:eachSectionDict];
        }
        
        if ([hdrSectionFields count]) {
            NSSortDescriptor *sortDescriptorRow = [[NSSortDescriptor alloc] initWithKey:kPageFieldDisplayRow ascending:YES];
            
            NSSortDescriptor *sortDescriptorColumn = [[NSSortDescriptor alloc] initWithKey:kPageFieldDisplayColumn
                                                                                 ascending:YES];
            
            NSArray *newHeaderSections = [hdrSectionFields sortedArrayUsingDescriptors:@[sortDescriptorRow, sortDescriptorColumn]];
            if ([newHeaderSections count])
            {
                [hdrSectionFields removeAllObjects];
                [hdrSectionFields addObjectsFromArray:newHeaderSections];
            }
        }
        
        NSDictionary * sectionDetail = [section objectForKey:kPageHeadersectionDetail];
        
        NSString * noOfcolumns = [sectionDetail objectForKey:kPageHeaderSectionColumns];
        noOfcolumns = (noOfcolumns != nil)?noOfcolumns:@"";
        
        NSString * title = [sectionDetail objectForKey:kPageHeaderSectionTitle];
        title = (title != nil)?title:@"";
        
        NSString * sequence = [sectionDetail objectForKey:kPageHeaderSectionSequence];
        sequence = (sequence != nil)?sequence:@"";
        
        NSString * sectionSlaclock = [sectionDetail objectForKey:kPageHeaderSectionSLAClock];
        NSNumber * slaClock = [NSNumber numberWithBool:(sectionSlaclock != nil && ![sectionSlaclock  isKindOfClass:[NSNull class]])?sectionSlaclock.boolValue:NO];
        
        NSArray * hdrSectionKeys = [[NSArray alloc]  initWithObjects:
                                           kPageHeaderSectionColumns,
                                           kPageHeaderSectionTitle,
                                           kPageHeaderSectionSequence,
                                           kPageHeaderSectionsFields,
                                           kPageHeaderSectionSLAClock,
                                           nil];
        NSArray * hdrSectionValues = [[NSArray alloc]  initWithObjects:
                                             noOfcolumns,
                                             title,
                                             sequence,
                                             (hdrSectionFields != nil)?hdrSectionFields:[[NSArray alloc] init],
                                             slaClock,
                                             nil];
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObjects:hdrSectionValues forKeys:hdrSectionKeys];
        
        [hdrSections addObject:dict];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kPageHeaderSectionSequence ascending:YES];

    NSArray *sequence = [hdrSections sortedArrayUsingDescriptors:@[sortDescriptor]];
    if ([sequence count] && [hdrSections count])
    {
        [hdrSections removeAllObjects];
        [hdrSections addObjectsFromArray:sequence];
    }
    
    return hdrSections;
}

-(NSMutableArray *)getPageLevelEvents:( NSMutableArray *)pageLevelEvents
{
    
    NSMutableArray * sfmPageEvents = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0 ;i< [pageLevelEvents count]; i++)
    {
        NSDictionary * eventDetail = [pageLevelEvents objectAtIndex:i];
        
        NSString * headerName = [eventDetail objectForKey:kPageHeaderName];
        headerName = (headerName != nil)?headerName:@"";
        
        
        NSString * pEventName = [eventDetail objectForKey:kPageEventName];
        pEventName = (pEventName != nil)?pEventName:@"";
        
        
        NSString * targetCall = [eventDetail objectForKey:kPageTargetCall];
        targetCall = (targetCall != nil)?targetCall:@"";
        
        NSString * eventId = [eventDetail objectForKey:kPageEventId];
        eventId = (eventId != nil)?eventId:@"";
        
        NSString * layoutId = [eventDetail objectForKey:kPageEventPageLayout];
        layoutId = (layoutId != nil)?layoutId:@"";
        
        NSString * eventType = [eventDetail objectForKey:kPageEventType];
        eventType = (eventType != nil)?eventType:@"";
        
        NSString * eventCallType = [eventDetail objectForKey:kPageEventCallType];
        eventCallType = (eventCallType != nil)?eventCallType:@"";
        
        NSString * eventCodeSnippetId = [eventDetail objectForKey:kPageEventCodeSnippetId];
        eventCodeSnippetId = (eventCodeSnippetId != nil)?eventCodeSnippetId:@"";
        
        //clarify
        
        NSMutableDictionary * eventsDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        [eventsDictionary setObject:headerName forKey:kPageHeaderName];
        [eventsDictionary setObject:pEventName forKey:kPageEventName];
        [eventsDictionary setObject:targetCall forKey:kPageTargetCall];
        [eventsDictionary setObject:eventType forKey:kPageEventType];
        [eventsDictionary setObject:eventId forKey:kPageEventId];
        [eventsDictionary setObject:layoutId forKey:kPageEventPageLayout];
        [eventsDictionary setObject:eventCallType forKey:kPageEventCallType];
        [eventsDictionary setObject:eventCodeSnippetId forKey:kPageEventCodeSnippetId];
        
        [sfmPageEvents addObject:eventsDictionary];
    }
    return sfmPageEvents;
}

-(NSDictionary *)getHeaderForPageDict:(NSDictionary *)pageDict
{
    NSDictionary * header = [pageDict objectForKey:kPageHeader];
    NSDictionary * headerLayout = [header objectForKey:kPageHeaderLayout];
    NSArray * sections = [header objectForKey:kPageHeaderSections];
    NSMutableArray * pageLevelEvents = [header objectForKey:kPageHeaderEvents];
    
    NSString * headerObjApiName = [headerLayout objectForKey:kPageHeaderObjectName];
    
    NSMutableArray * hdrButtons   = [self getButtonsListFromHeader:header];
    
    NSMutableArray * hdrSections = [self getAllsectionFields:sections headerObjectNAme:headerObjApiName];
    
    NSMutableArray * sfmPageEvents = [self getPageLevelEvents:pageLevelEvents];
    
    NSMutableDictionary * hdrLayoutObjects = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    
    [hdrLayoutObjects setObject:hdrButtons forKey:kPageHeaderButtons];
    [hdrLayoutObjects setObject:hdrSections forKey:kPageHeaderSections];
    [hdrLayoutObjects setObject:sfmPageEvents forKey:kPageLevelEvents];
    
    
    NSString * pagelayoutId = [headerLayout objectForKey:kPageHeaderpageLayoutId];
    pagelayoutId = (pagelayoutId != nil)?pagelayoutId:@"";
    [hdrLayoutObjects setObject:pagelayoutId forKey:kPageHeaderpageLayoutId];
    
    NSString * headerSfName = [headerLayout objectForKey:kPageHeaderSfname];
    headerSfName = (headerSfName != nil)?headerSfName:@"";
    [hdrLayoutObjects setObject:headerSfName forKey:kPageHeaderSfname];
    
    NSString * headerobjName = [headerLayout objectForKey:kPageHeaderObjectName];
    headerobjName = (headerobjName != nil)?headerobjName:@"";
    [hdrLayoutObjects setObject:headerobjName forKey:kPageHeaderObjectName];
    
    NSString * allowNewLines = [headerLayout objectForKey:kPageHeaderAllowNewLines];
    NSNumber * allowNewLinesNo = [NSNumber numberWithBool:(allowNewLines != nil && ![allowNewLines  isKindOfClass:[NSNull class]])?allowNewLines.boolValue:NO];
    [hdrLayoutObjects setObject:allowNewLinesNo forKey:kPageHeaderAllowNewLines];
    
    NSString * allowDeleteLines = [headerLayout objectForKey:kPageHeaderAllowDeleteLines];
    NSNumber * allowdeleteLinesNo = [NSNumber numberWithBool:(allowDeleteLines != nil && ![allowDeleteLines  isKindOfClass:[NSNull class]])?allowDeleteLines.boolValue:NO];
    [hdrLayoutObjects setObject:allowdeleteLinesNo forKey:kPageHeaderAllowDeleteLines];
    
    NSString * isStandard = [headerLayout objectForKey:kPageHeaderIsStandard];
    NSNumber * isStandardNo = [NSNumber numberWithBool:(isStandard != nil && ![isStandard isKindOfClass:[NSNull class]])?isStandard.boolValue:NO];
    [hdrLayoutObjects setObject:isStandardNo forKey:kPageHeaderIsStandard];
    
    NSString * actionOnZerorLines = [headerLayout objectForKey:kPageHeaderActionOnZeroLines];
    NSNumber * actionOnZerorLinesNo = [NSNumber numberWithBool:(actionOnZerorLines != nil && ![actionOnZerorLines  isKindOfClass:[NSNull class]])?actionOnZerorLines.boolValue:NO];
    [hdrLayoutObjects setObject:actionOnZerorLinesNo forKey:kPageHeaderActionOnZeroLines];
    
    NSString * headerLayoutId = [header objectForKey:kPageHeaderLayoutId];
    headerLayoutId = (headerLayoutId != nil)?headerLayoutId:@"";
    [hdrLayoutObjects setObject:headerLayoutId forKey:kPageHeaderLayoutId];
    
    NSString * headerName = [headerLayout objectForKey:kPageHeaderName]; //clarify
    headerName = (headerName != nil)?headerName:@"";
    [hdrLayoutObjects setObject:headerName forKey:kPageHeaderName];
    
    NSString * ownerId = [headerLayout objectForKey:kPageHeaderOwnerId];
    ;
    ownerId = (ownerId != nil)?ownerId:@"";
    [hdrLayoutObjects setObject:ownerId forKey:kPageHeaderOwnerId];
    
    
    NSString * enableAttachments = [headerLayout objectForKey:kPageHeaderEnableAttachments];
    NSNumber * enableAttachmentsNo = [NSNumber numberWithBool:(enableAttachments != nil && ![enableAttachments  isKindOfClass:[NSNull class]])?enableAttachments.boolValue:NO];
    [hdrLayoutObjects setObject:enableAttachmentsNo forKey:kPageHeaderEnableAttachments];
    
    
    NSString * enablechatter = [headerLayout objectForKey:kPageEnableChatter];
    NSNumber * enablechatterNo = [NSNumber numberWithBool:(enablechatter != nil && ![enablechatter  isKindOfClass:[NSNull class]])?enablechatter.boolValue:NO];
    [hdrLayoutObjects setObject:enablechatterNo forKey:kPageEnableChatter];
    
    
    NSString * enableTroubleShooting = [headerLayout objectForKey:kPageEnableTroubleShooting];
    NSNumber * enableTroubleShootingNo = [NSNumber numberWithBool:(enableTroubleShooting != nil && ![enableTroubleShooting  isKindOfClass:[NSNull class]])?enableTroubleShooting.boolValue:NO];
    [hdrLayoutObjects setObject:enableTroubleShootingNo forKey:kPageEnableTroubleShooting];
    
    NSString * enableSummury = [headerLayout objectForKey:kPageEnableSummary];
    NSNumber * enableSummuryNo = [NSNumber numberWithBool:(enableSummury != nil && ![enableSummury  isKindOfClass:[NSNull class]])?enableSummury.boolValue:NO];
    [hdrLayoutObjects setObject:enableSummuryNo forKey:kPageEnableSummary];
    
    NSString * enableSummuryGen = [headerLayout objectForKey:kPageEnableSummaryGeneration];
    NSNumber * enableSummuryGenNo = [NSNumber numberWithBool:(enableSummuryGen != nil && ![enableSummuryGen  isKindOfClass:[NSNull class]])?enableSummuryGen.boolValue:NO];
    [hdrLayoutObjects setObject:enableSummuryGenNo forKey:kPageEnableSummaryGeneration];
    
    
    NSString * showAllSectBydefault = [headerLayout objectForKey:kPageHeaderShowAllSectionsByDefault];
    NSNumber * showAllSectBydefaultNo = [NSNumber numberWithBool:(showAllSectBydefault != nil && ![showAllSectBydefault  isKindOfClass:[NSNull class]])?showAllSectBydefault.boolValue:NO];
    [hdrLayoutObjects setObject:showAllSectBydefaultNo forKey:kPageHeaderShowAllSectionsByDefault];

    
    NSString * productHistory = [headerLayout objectForKey:kPageHeaderShowProductHistory];
    NSNumber * productHistoryNo = [NSNumber numberWithBool:(productHistory != nil && ![productHistory  isKindOfClass:[NSNull class]])?productHistory.boolValue:NO];
    [hdrLayoutObjects setObject:productHistoryNo forKey:kPageHeaderShowProductHistory];
    
    NSString * accountHistory = [headerLayout objectForKey:kPageHeaderShowAccountHistory];
    NSNumber * accountHistoryNo = [NSNumber numberWithBool:(accountHistory != nil && ![accountHistory  isKindOfClass:[NSNull class]])?accountHistory.boolValue:NO];
    [hdrLayoutObjects setObject:accountHistoryNo forKey:kPageHeaderShowAccountHistory];
    
    
    NSString * hideQuickSave = [headerLayout objectForKey:kPageShowHideQuickSave];
    NSNumber * hideQuickSaveNo = [NSNumber numberWithBool:(hideQuickSave != nil && ![hideQuickSave  isKindOfClass:[NSNull class]])?hideQuickSave.boolValue:NO];
    [hdrLayoutObjects setObject:hideQuickSaveNo forKey:kPageShowHideQuickSave];
    
    NSString * hideSave = [headerLayout objectForKey:kPageShowHideQuickSave];
    NSNumber * hideSaveNo = [NSNumber numberWithBool:(hideSave != nil && ![hideSave  isKindOfClass:[NSNull class]])?hideSave.boolValue:NO];
    [hdrLayoutObjects setObject:hideSaveNo forKey:kPageShowHideQuickSave];
    
    
    return hdrLayoutObjects;
}

-(NSData *)getNsdataFromDicitonary:(NSDictionary *)pageDict
{
    NSError *err = nil;
    NSData *data =  [NSJSONSerialization dataWithJSONObject:pageDict options:NSJSONWritingPrettyPrinted error:&err];
    return data;
}

/* Parallel Calls add the remainining Ids based on the pageLayOutlimit */
- (NSArray *)getTheRemainingIdsFromCacheForTheArray:(NSArray *)callIdArray
{
    NSMutableArray * pageIdArray = [NSMutableArray arrayWithArray:callIdArray];
    NSMutableArray *cachedPageIds =   [[CacheManager sharedInstance] getCachedObjectByKey:@"PageIds"];
    /* getting the values from cache */
    
    if(cachedPageIds == nil) {
        return callIdArray;
    }
    
        NSInteger count = kPageLimit - [pageIdArray count];
    
        if ([cachedPageIds count] > count)
        {
    
            NSArray *remainingArray = nil;
            remainingArray = [cachedPageIds subarrayWithRange:NSMakeRange(0, count)];
            [pageIdArray addObjectsFromArray:remainingArray];
    
            for(NSString *string in remainingArray)
            {
                [cachedPageIds removeObject:string];
            }
            if([cachedPageIds count]>0)
            {
                [[CacheManager sharedInstance] pushToCache:cachedPageIds byKey:@"PageIds"];
                /* updating the cache */
            }
            else
            {
                /*deleting the cache */
                [[CacheManager sharedInstance]clearCacheByKey:@"PageIds"];
            }
        }
        else
        {
            if([cachedPageIds count] > kPageLimit)
            {
                NSMutableArray *remainingArray = [[NSMutableArray alloc] init];
    
                [remainingArray  addObjectsFromArray:[cachedPageIds subarrayWithRange:NSMakeRange(0,15)]];
                [pageIdArray addObjectsFromArray:remainingArray];
    
                for(NSString *string in remainingArray)
                {
                    [cachedPageIds removeObject:string];
                }
                if([cachedPageIds count]>0)
                {
                    [[CacheManager sharedInstance] pushToCache:cachedPageIds byKey:@"PageIds"];
                }
                else
                {
                    [[CacheManager sharedInstance]clearCacheByKey:@"PageIds"];
                }
            }
            else
            {
                [pageIdArray addObjectsFromArray:cachedPageIds];
                
            }
            
            [[CacheManager sharedInstance]clearCacheByKey:@"PageIds"];
        }
    return pageIdArray;
    
    
}

@end
