//
//  OneCallMetaDataParser.m
//  ServiceMaxMobile
//
//  Created by Krishna Shanbhag on 19/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//
#import "RequestConstants.h"
#import "OneCallMetaDataParser.h"
//#import "SFMetaDataModel.h"
#import "SFProcessModel.h"
#import "SFProcessTestModel.h"
#import "SFExpressionModel.h"
#import "SFExpressionComponentModel.h"
#import "SFNamedSearchModel.h"
#import "SFNamedSearchDAO.h"
#import "SFNamedSearchComponentModel.h"
#import "SFNamedSearchComponentDAO.h"
#import "SFNamedSearchFilterModel.h"
#import "SFObjectMappingModel.h"
#import "SFObjectMappingComponentModel.h"
#import "ResponseCallback.h"
#import "MobileDeviceSettingsModel.h"
#import "ParserUtility.h"
#import "SFWizardModel.h"
#import "FactoryDAO.h"
#import "CommonServiceDAO.h"
#import "SFProcessDAO.h"
#import "MobileDeviceSettingDAO.h"
#import "SFWizardService.h"
#import "WizardComponentModel.h"
#import "SFMWizardComponentDAO.h"
#import "SFCustomActionURLDAO.h"
#import "SFObjectMappingDAO.h"
#import "SFProcessComponentModel.h"
#import "SFObjectMappingComponentDAO.h"
#import "DocTemplateDetailModel.h"
#import "DocTemplateModel.h"
#import "DocTemplateDAO.h"
#import "DocTemplateDetailDAO.h"
#import "AttachmentModel.h"
#import "AttachmentsDAO.h"
#import "SFExpressionDAO.h"
#import "SFExpressionComponentDAO.h"
#import "SFMSearchProcessModel.h"
#import "SFMSearchObjectModel.h"
#import "SearchProcessDAO.h"
#import "SearchProcessObjectsDAO.h"
#import "BusinessRuleModel.h"
#import "BusinessRuleService.h"
#import "ProcessBusinessRuleModel.h"
#import "ProcessBusinessRuleService.h"
#import "SFMSearchFilterCriteriaModel.h"
#import "SFMSearchFilterCriteriaService.h"
#import "SFMSearchFieldModel.h"
#import "SFMSearchFieldService.h"
#import "ResponseConstants.h"
#import "SFSourceUpdateModel.h"
#import "SourceUpdateService.h"
#import "SFNamedSearchFilterDAO.h"
#import "LinkedSfmProcessDAO.h"
#import "CustomActionURLModel.h"

@interface OneCallMetaDataParser ()

/**Below method create a particular model fo the the response key **/
- (void)createAndInsertSfmWizardModel:(NSArray*)array;
- (void)createAndInsertSfmWizardStepModel:(NSArray*)array;
- (void)createAndInsertDocTemplateModel:(NSArray*)array;
- (void)createAndInsertDocTemplateDetailModel:(NSArray*)array;
- (void)createAndInsertAttachmentsModel:(NSArray*)array;
- (void)createAndInsertBusinessRuleModel:(NSArray*)array;
- (void)createAndInsertProcessBusinessRuleModel:(NSArray*)array;
- (void)createAndInsertNamedSearchModel:(NSArray*)array;
- (void)createAndInsertNamedSearchComponentModel:(NSArray*)array;//SFSearchObjDetail

@end

static NSString * kMobileConfig              = @"MOBILE_CONFIG";
static NSString * kMobileDevSettings         = @"MOBILE_DEVICE_SETTINGS";
static NSString * kSfmWizrd                  = @"SFM_WIZARD";
static NSString * kSfmWizardStep             = @"SFM_WIZARD_STEP";
static NSString * kSourceUpdate              = @"SOURCE_UPDATE";
static NSString * kSfmProcessNodeObj         = @"SFM_PROCESS_NODE_OBJECT";
static NSString * kSfmTargetManager          = @"SFM_TARGET_MANAGER";
static NSString * kObjectMapping             = @"OBJECT_MAPPING";
static NSString * kObjectMappingDetails      = @"OBJECT_MAPPING_DETAILS";
static NSString * kSfExpresion               = @"SFM_EXPRESSION";
static NSString * kSfExpresionDetails        = @"SFM_EXPRESSION_DETAILS";

static NSString * kNamedSearch               = @"NAMED_SEARCH";

static NSString * kSearchObjDetail           = @"SEARCH_OBJECT_DETAIL";

static NSString * kSearchProcessObjects      = @"SFM_SEARCH_PROCESS_OBJECTS";
static NSString * kSearchProcess             = @"SFM_SEARCH_PROCESS";
static NSString * kSearchDetails             = @"SFM_SEARCH_DETAILS";

static NSString * kDocumentTemplate          = @"DOC_TEMPLATE";
static NSString * kDocumentTemplateDetails   = @"DOC_TEMPLATE_DETAIL";
static NSString * kAttachments               = @"ATTACHMENTS";

static NSString * kBusinessRule              = @"SFM_BUSINESS_RULE";
static NSString * kProcessBusinessRule       = @"SFM_PROCESS_BUSINESS_RULE";

//static NSString * kCallBack                  = @"CALL_BACK";

static NSString * kProcess                   = @"SFMProcess";
static NSString * kProcessComponent          = @"SFProcess_component";
static NSString * kObjectMappingComponent    = @"SFObject_mapping_component";
static NSString * kExpression                = @"SFExpression";
static NSString * kExpressionComponent       = @"SFExpression_component";
static NSString * kNamedSearchCriteria       = @"SFNAMEDSEARCH_CRITERIA";
static NSString * kNamedSearchComponent      = @"SFNAMEDSEARCH_COMPONENT";

static NSString *kSearchObject =@"SEARCH_OBJECT";

static NSString *kLinkedProcess = @"LINKED_SFM_PROCESS";

static NSString *kSfmEvent = @"SFM_EVENT";
static NSString *kSfmWizardCustomAction=@"SFM_WIZARD_CUSTOM_ACTIONS";
static NSString *kSfmWizardCustomActionParams=@"SFM_WIZARD_CUSTOM_ACTIONS_PARAMS";

@implementation OneCallMetaDataParser

@synthesize sfProcess;
@synthesize sfProcessTest;
@synthesize sfExpression;
@synthesize sfExpressionComponent;
@synthesize sfNamedSearch;
@synthesize sfNamedSearchComponent;
@synthesize sfNamedSearchFilters;

/* Parse response with the type*/
-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responseData
{
    
    if (![responseData isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    @synchronized([self class]){
        @autoreleasepool {
            
            NSDictionary *responseDict = (NSDictionary *)responseData;
            
            //Since we are getting JSON string we need to get dict using JSON Parser
            ResponseCallback * callBackObj = [[ResponseCallback alloc] init];
            
            NSArray * svmxMaps =[responseDict objectForKey:kSVMXRequestSVMXMap];
            
            NSDictionary *callBackDictionary = nil;
            BOOL callBack = NO;
            for ( NSDictionary * eachDict in svmxMaps)
            {
                NSString * locEventName = [eachDict objectForKey:kSVMXRequestKey];
                NSString *svmxMapString =[eachDict objectForKey:kSVMXRequestValue];
                NSData *jsonData = nil;
                NSArray * valuesArray = nil;
                
                if (![svmxMapString isKindOfClass:[NSNull class]]) {
                    jsonData = [svmxMapString dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *e;
                    valuesArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
                }
                
                if([locEventName isEqualToString:kMobileConfig])
                {
                    [self createAndInsertMobileConfigIntoMobileDevSettingsModel:valuesArray];
                }
                else if([locEventName isEqualToString:kMobileDevSettings])
                {
                    
                    [self createAndInsertMobileDevSettingsModel:valuesArray];
                }
                else if ([locEventName isEqualToString:kSfmWizrd])
                {
                   [self createAndInsertSfmWizardModel:valuesArray];
                    
                }
                else if ([locEventName isEqualToString:kSfmWizardStep])
                {
                    [self createAndInsertSfmWizardStepModel:valuesArray];
                }
                else if ([locEventName isEqualToString:kSourceUpdate])
                {
                    [self createAndInsertSourceUpdateModel:valuesArray];
                }
                else if ([locEventName isEqualToString:kSfmProcessNodeObj])
                {
                    [self createAndInsertProcessComponentModels:valuesArray];
                }
                else if ([locEventName isEqualToString:kSfmTargetManager])
                {
                    [self createAndInsertProcessModel:valuesArray];
                }
                else if ([locEventName isEqualToString:kObjectMapping])
                {
                   [self createAndInsertObjectMappingModel:valuesArray];
                }
                else if ([locEventName isEqualToString:kObjectMappingDetails])
                {
                    [self createAndInsertObjectMappingComponentModel:valuesArray];
                }
                else if ([locEventName isEqualToString:kSfExpresion])
                {
                    [self createAndInsertExpressions:valuesArray];
                }
                else if ([locEventName isEqualToString:kSfExpresionDetails])
                {
                    [self createAndInsertExpressionComponent:valuesArray];
                }
                else if ([locEventName isEqualToString:kNamedSearch])
                {
                    [self createAndInsertNamedSearchModel:valuesArray];
                }
                else if ([locEventName isEqualToString:kSearchObjDetail])
                {
                    [self createAndInsertNamedSearchComponentModel:valuesArray];
                }
                else if ([locEventName isEqualToString:kSearchObject])
                {
                    [self createAndInsertNamedSearchFilters:valuesArray];
                }
                else if ([locEventName isEqualToString:kSearchProcessObjects])
                {
                   [self createAndInsertSFMSearchProcessObjectModel:valuesArray];
                }
                else if ([locEventName isEqualToString:kSearchProcess])
                {
                    [self createAndInsertSFMSearchProcessModel:valuesArray];
                }
                else if ([locEventName isEqualToString:kSearchDetails])
                {
                    [self createAndInsertSearchDetail:valuesArray];
                }
                else if ([locEventName isEqualToString:kDocumentTemplate])
                {
                    [self createAndInsertDocTemplateModel:valuesArray];
                }
                else if ([locEventName isEqualToString:kDocumentTemplateDetails])
                {
                    [self createAndInsertDocTemplateDetailModel:valuesArray];
                }
                else if ([locEventName isEqualToString:kAttachments])
                {
                    [self createAndInsertAttachmentsModel:valuesArray];
                }
                else if ([locEventName isEqualToString:kProcessBusinessRule])
                {
                    [self createAndInsertProcessBusinessRuleModel:valuesArray];
                }
                else if ([locEventName isEqualToString:kBusinessRule])
                {
                    [self createAndInsertBusinessRuleModel:valuesArray];
                }
                else if ([locEventName isEqualToString:kLinkedProcess]) {
                    
                    [self createAndInsertLinkedSFMModel:valuesArray];
                }
                else if ([locEventName caseInsensitiveCompare:kCallBack] == NSOrderedSame)
                {
                    NSString *value = [[eachDict objectForKey:kSVMXRequestValue] lowercaseString];
                    if ([value isEqualToString:kTrue]) {
                        callBack = YES;
                        callBackDictionary = eachDict;
                    }
                }
                
                else if ([locEventName isEqualToString:@"SFM_WIZARD_LAYOUT"])
                {
                    [self updateSfWizardModel:valuesArray];
                    //NSLog(@"%@",valuesArray);
                }
                else if ([locEventName isEqualToString:kSfmWizardCustomAction]) {
                    [self updateSfWizardComponentModelWithClassName:valuesArray];
                }
                else if ([locEventName isEqualToString:kSfmWizardCustomActionParams]){
                    [self updateSfWizardComponentModelWithClassNameActipnParam:valuesArray];
                }
                else if ([locEventName isEqualToString:kSfmEvent]) {
                    [self UpdateSFWizardCompomnet:valuesArray];
                }
                
                else {
                    SXLogInfo(@"UNPARSED :::::::::: %@ ",locEventName);
                }
            }
            callBackObj.callBack = callBack;
            RequestParamModel *paramModel = [[RequestParamModel alloc] init];
            paramModel.valueMap = [NSArray arrayWithObjects:callBackDictionary,nil];
            callBackObj.callBackData  = paramModel;
            return callBackObj;
        }
    }
}
#pragma mark - Mobile device settings and configuration
- (void)createAndInsertMobileDevSettingsModel:(NSArray *)valuesArray {
   
    
    NSMutableArray *mobileDevSettingsArray = [[NSMutableArray alloc] init];
    NSDictionary *mappingDict = [MobileDeviceSettingsModel getMappingDictionary];
    for (NSDictionary *dict in valuesArray) {
    
        MobileDeviceSettingsModel *model = [[MobileDeviceSettingsModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [mobileDevSettingsArray addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeMobileDeviceSettings];
    
    if ([daoService conformsToProtocol:@protocol(MobileDeviceSettingDAO)]) {
        [daoService saveRecordModels:mobileDevSettingsArray];
    }
}

- (void)createAndInsertMobileConfigIntoMobileDevSettingsModel:(NSArray *)valuesArray {
    
    NSMutableArray *mobileDevSettingsArray = [[NSMutableArray alloc] init];
    NSDictionary *mappingDict = [MobileDeviceSettingsModel getMappingDictionaryForMobileDeviceConfig];
    for (NSDictionary *dict in valuesArray) {
        
        MobileDeviceSettingsModel *model = [[MobileDeviceSettingsModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [mobileDevSettingsArray addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeMobileDeviceSettings];
    
    if ([daoService conformsToProtocol:@protocol(MobileDeviceSettingDAO)]) {
        [daoService saveRecordModels:mobileDevSettingsArray];
    }
    
}
#pragma mark - Expression and expression component
- (void)createAndInsertExpressions:(NSArray *)valuesArray {
    
    NSMutableArray *expressionsArray = [[NSMutableArray alloc] init];
    NSDictionary *mappingDict = [SFExpressionModel getMappingDictionary];
    for (NSDictionary *dict in valuesArray) {
        SFExpressionModel *model = [[SFExpressionModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [expressionsArray addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeExpression];
    if ([daoService conformsToProtocol:@protocol(SFExpressionDAO)]) {
        [daoService saveRecordModels:expressionsArray];
    }
}

- (void)createAndInsertExpressionComponent:(NSArray *)valuesArray {
    
    NSMutableArray *expressionsArray = [[NSMutableArray alloc] init];
    NSDictionary *mappingDict = [SFExpressionComponentModel getMappingDictionary];
    for (NSDictionary *dict in valuesArray) {
        SFExpressionComponentModel *model = [[SFExpressionComponentModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [expressionsArray addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeExpressionComponent];
    if ([daoService conformsToProtocol:@protocol(SFExpressionComponentDAO)]) {
        [daoService saveRecordModels:expressionsArray];
    }
}

#pragma mark - SFM Process and process component model
- (void)createAndInsertProcessModel:(NSArray *)valuesArray {
    
    NSMutableArray *processList = [[NSMutableArray alloc] init];
    NSDictionary *mappingDict = [SFProcessModel getMappingDictionary];
    for (NSDictionary *dict in valuesArray) {
        
        SFProcessModel *model = [[SFProcessModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [processList addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeProcess];
    
    if ([daoService conformsToProtocol:@protocol(SFProcessDAO)]) {
        [daoService saveRecordModels:processList];
    }
    
}

- (void)createAndInsertProcessComponentModels:(NSArray *)valuesArray {
    NSMutableArray *processComponentsList = [[NSMutableArray alloc] init];
    NSDictionary *mappingDict = [SFProcessComponentModel getMappingDictionary];
    for (NSDictionary *dict in valuesArray) {
        
        SFProcessComponentModel *model = [[SFProcessComponentModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [processComponentsList addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeProcessComponent];
    
    if ([daoService conformsToProtocol:@protocol(CommonServiceDAO)]) {
        [daoService saveRecordModels:processComponentsList];
    }
}

#pragma mark - Object mapping and object mapping component
- (void)createAndInsertObjectMappingModel:(NSArray *)valuesArray {
    
    NSMutableArray *ObjectMappingObjects = [[NSMutableArray alloc] init];
    NSDictionary *mappingDict = [SFObjectMappingModel getMappingDictionary];
    for (NSDictionary *dict in valuesArray) {
        
        SFObjectMappingModel *model = [[SFObjectMappingModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [ObjectMappingObjects addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectMapping];
    
    if ([daoService conformsToProtocol:@protocol(SFObjectMappingDAO)]) {
        [daoService saveRecordModels:ObjectMappingObjects];
    }
    
}

- (void)createAndInsertObjectMappingComponentModel:(NSArray *)valuesArray {
    NSMutableArray *ObjectMappingComponentObjects = [[NSMutableArray alloc] init];
    NSDictionary *mappingDict = [SFObjectMappingComponentModel getMappingDictionary];
    for (NSDictionary *dict in valuesArray) {
        
        SFObjectMappingComponentModel *model = [[SFObjectMappingComponentModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [ObjectMappingComponentObjects addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectMappingComponent];
    
    if ([daoService conformsToProtocol:@protocol(SFObjectMappingComponentDAO)]) {
        [daoService saveRecordModels:ObjectMappingComponentObjects];
    }

}
#pragma mark - SFM Search process
- (void)createAndInsertSFMSearchProcessModel:(NSArray *)valuesArray {
    
    NSMutableArray *sfmSearchProcessModels = [[NSMutableArray alloc] init];
    NSDictionary *mappingDict = [SFMSearchProcessModel getMappingDictionary];
    for (NSDictionary *dict in valuesArray) {
        
        SFMSearchProcessModel *model = [[SFMSearchProcessModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [sfmSearchProcessModels addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFMSearchProcess];
    
    if ([daoService conformsToProtocol:@protocol(SearchProcessDAO)]) {
        [daoService saveRecordModels:sfmSearchProcessModels];
    }
    
}
#pragma mark - SFM Search Object
- (void)createAndInsertSFMSearchProcessObjectModel:(NSArray *)valuesArray {
    
    NSMutableArray *sfmSearchObjectModels = [[NSMutableArray alloc] init];
    NSDictionary *mappingDict = [SFMSearchObjectModel getMappingDictionary];
    for (NSDictionary *dict in valuesArray) {
        
        SFMSearchObjectModel *model = [[SFMSearchObjectModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [sfmSearchObjectModels addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFMSearchProcessObject];
    
    if ([daoService conformsToProtocol:@protocol(SearchProcessObjectsDAO)]) {
        [daoService saveRecordModels:sfmSearchObjectModels];
    }
    
}

#pragma mark - SFM Search Detail
- (void)createAndInsertSearchDetail:(NSArray *)valuesArray {
    
    NSMutableArray *sfmSearchFieldModels = [[NSMutableArray alloc]init];
    NSDictionary *sfmSearchFieldMappingDict = [SFMSearchFieldModel getMappingDictionary];
    
    NSMutableArray *sfmSearchFilterCriteriaModels = [[NSMutableArray alloc]init];
    NSDictionary *sfmSearchFilterCriteriaMappingDict = [SFMSearchFilterCriteriaModel getMappingDictionary];
    
    for (NSDictionary *dict in valuesArray) {
        
        NSString *expresstion_type = [dict objectForKey:kSearchExpressionType];
        if([expresstion_type isEqualToString:kFILTER_CRITERIA_OBJ])
        {
            SFMSearchFilterCriteriaModel *model = [[SFMSearchFilterCriteriaModel alloc]init];
            [ParserUtility parseJSON:dict toModelObject:model withMappingDict:sfmSearchFilterCriteriaMappingDict];
            [sfmSearchFilterCriteriaModels addObject:model];
        }
        else
        {
            SFMSearchFieldModel *model = [[SFMSearchFieldModel alloc]init];
            [ParserUtility parseJSON:dict toModelObject:model withMappingDict:sfmSearchFieldMappingDict];
            [sfmSearchFieldModels addObject:model];
        }
        
    }
    
    id sfmSearchFieldDAO = [FactoryDAO serviceByServiceType:ServiceTypeSFMSearchField];
    
    if ([sfmSearchFieldDAO conformsToProtocol:@protocol(SFMSearchFieldDAO)]) {
        [sfmSearchFieldDAO saveRecordModels:sfmSearchFieldModels];
    }
    
    id sfmSearchFilterCriteriaDAO = [FactoryDAO serviceByServiceType:ServiceTypeSFMSearchFilterCriteria];
    
    if ([sfmSearchFilterCriteriaDAO conformsToProtocol:@protocol(SFMSearchFilterCriteriaDAO)]) {
        [sfmSearchFilterCriteriaDAO saveRecordModels:sfmSearchFilterCriteriaModels];
    }
    
}
#pragma mark - sfm wizard

- (void)updateSfWizardModel:(NSArray*)array
{
    NSMutableArray *sfmWizardAray = [[NSMutableArray alloc]init];
    NSDictionary *mappingDict = [SFWizardModel getMappingDictionaryForWizardLayout];
    for (NSDictionary *dict in array) {
        
        SFWizardModel *model = [[SFWizardModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [sfmWizardAray addObject:model];
    }
    
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFWizard];
    
    if ([daoService conformsToProtocol:@protocol(SFWizardDAO)]) {
        [daoService updateWizardWithModelArray:sfmWizardAray];
    }
}

- (void)createAndInsertSfmWizardModel:(NSArray*)array
{
    NSMutableArray *sfmWizardAray = [[NSMutableArray alloc]init];
    NSDictionary *mappingDict = [SFWizardModel getMappingDictionary];
    for (NSDictionary *dict in array) {
        
        SFWizardModel *model = [[SFWizardModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [sfmWizardAray addObject:model];
    }
    
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFWizard];
    
    if ([daoService conformsToProtocol:@protocol(SFWizardDAO)]) {
        [daoService saveRecordModels:sfmWizardAray];
    }
    
}

- (void)createAndInsertSfmWizardStepModel:(NSArray*)array
{
    NSMutableArray *sfmWizardStepAray = [NSMutableArray array];
    NSDictionary *mappingDict = [WizardComponentModel getMappingDictionary];
    for (NSDictionary *dict in array) {
        
        WizardComponentModel *model = [[WizardComponentModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [sfmWizardStepAray addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFWizardComponent];
    
    if ([daoService conformsToProtocol:@protocol(SFMWizardComponentDAO)]) {
        [daoService saveRecordModels:sfmWizardStepAray];
    }
}

- (void)updateSfWizardComponentModelWithClassName:(NSArray*)array
{
    NSMutableArray *sfmWizardStepAray = [NSMutableArray array];
    NSDictionary *mappingDict = [WizardComponentModel getMappingDictionaryForWizardLayoutClassName];
    NSDictionary *mappingDictUrl = [WizardComponentModel getMappingDictionaryForWizardLayoutUrl];
    for (NSDictionary *dict in array) {
        if ([[dict objectForKey:kWizardCompCustomActionType] isEqualToString:@"URL"]) {
            WizardComponentModel *model = [[WizardComponentModel alloc] init];
            [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDictUrl];
            [sfmWizardStepAray addObject:model];
        }else{
            WizardComponentModel *model = [[WizardComponentModel alloc] init];
            [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
            [sfmWizardStepAray addObject:model];
        }
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFWizardComponent];
    
    if ([daoService conformsToProtocol:@protocol(SFMWizardComponentDAO)]) {
        [daoService updateWizardComponentWithModelArray_withCustomActionFields:sfmWizardStepAray];
    }
}
- (void)updateSfWizardComponentModelWithClassNameActipnParam:(NSArray*)array
{
    NSMutableArray *customActionAray = [NSMutableArray array];
    NSDictionary *mappingDict = [CustomActionURLModel getMappingDictionary];
    for (NSDictionary *dict in array) {
        CustomActionURLModel *model = [[CustomActionURLModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [customActionAray addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeCustomUrlAction];
    
    if ([daoService conformsToProtocol:@protocol(SFCustomActionURLDAO)]) {
        [daoService saveRecordModels:customActionAray];
    }  
}
- (void)UpdateSFWizardCompomnet:(NSArray*)array
{
    NSMutableArray *sfmEventArray = [NSMutableArray array];
    NSDictionary *mappingDict = [WizardComponentModel getMappingDictionary];
    for (NSDictionary *dict in array) {
        
        WizardComponentModel *model = [[WizardComponentModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        
        /**
         * Lets check for "SVMXC__Target_Call__c" = "test_SyncOverride.test_SyncOverride_WS";
         * save it into different columns className and methodName.
         */
        if ([dict objectForKey:ORG_NAME_SPACE@"__Target_Call__c"]) {
            NSString *combinedString = [dict objectForKey:ORG_NAME_SPACE@"__Target_Call__c"];
            NSArray *strings = [combinedString componentsSeparatedByString:@"."];
            if ([strings count] == 2) {
                model.className = [strings firstObject];
                model.methodName = [strings lastObject];
            }
        }
        
        /**
         * Lets override the wizardComponentId to have "SVMXC__ServiceMax_Process__c"
         * Value.
         */
        if ([dict objectForKey:ORG_NAME_SPACE@"__ServiceMax_Process__c"]) {
            NSString *serviceMaxProcessId = [dict objectForKey:ORG_NAME_SPACE@"__ServiceMax_Process__c"];
            model.wizardComponentId = serviceMaxProcessId;
        }
        
        [sfmEventArray addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSFWizardComponent];
    
    if ([daoService conformsToProtocol:@protocol(SFMWizardComponentDAO)]) {
        [daoService updateWizardComponentWithModelArray:sfmEventArray];
    }
}


#pragma mark - Doc Template

- (void)createAndInsertDocTemplateModel:(NSArray*)array {
    
    NSMutableArray *docTemplateArray = [[NSMutableArray alloc] init];
    NSDictionary *mappingDict = [DocTemplateModel getMappingDictionary];
    for (NSDictionary *dict in array) {
        
        DocTemplateModel *model = [[DocTemplateModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [docTemplateArray addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeDocTemplate];
    
    if ([daoService conformsToProtocol:@protocol(DocTemplateDAO)]) {
        [daoService saveRecordModels:docTemplateArray];
    }
    
}

- (void)createAndInsertDocTemplateDetailModel:(NSArray*)array {
    
    NSMutableArray *docTemplateDetailArray = [[NSMutableArray alloc] init];
    NSDictionary *mappingDict = [DocTemplateDetailModel getMappingDictionary];
    for (NSDictionary *dict in array) {
        
        DocTemplateDetailModel *model = [[DocTemplateDetailModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [docTemplateDetailArray addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeDocTemplateDetail];
    
    if ([daoService conformsToProtocol:@protocol(DocTemplateDetailDAO)]) {
        [daoService saveRecordModels:docTemplateDetailArray];
    }
    
}

- (void)createAndInsertAttachmentsModel:(NSArray*)array {
    
    NSMutableArray *attachmentArray = [[NSMutableArray alloc] init];
    NSDictionary *mappingDict = [AttachmentModel getMappingDictionary];
    for (NSDictionary *dict in array) {
        
        AttachmentModel *model = [[AttachmentModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [attachmentArray addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeAttachments];
    
    if ([daoService conformsToProtocol:@protocol(AttachmentsDAO)]) {
        [daoService saveRecordModels:attachmentArray];
    }
    
}

#pragma - mark businessRule

- (void)createAndInsertBusinessRuleModel:(NSArray*)array {
    
    NSMutableArray *businessRuleArray = [[NSMutableArray alloc] init];
    NSDictionary *mappingDict = [BusinessRuleModel getMappingDictionary];
    for (NSDictionary *dict in array) {
        
        BusinessRuleModel *model = [[BusinessRuleModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [businessRuleArray addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeBusinessRule];
    
    if ([daoService conformsToProtocol:@protocol(BusinessRuleDAO)]) {
        [daoService saveRecordModels:businessRuleArray];
    }
}

- (void)createAndInsertProcessBusinessRuleModel:(NSArray*)array
{
    NSMutableArray *processBusinessRuleArray = [[NSMutableArray alloc] init];
    NSDictionary *mappingDict = [ProcessBusinessRuleModel getMappingDictionary];
    for (NSDictionary *dict in array) {
        
        ProcessBusinessRuleModel *model = [[ProcessBusinessRuleModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [processBusinessRuleArray addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeProcessBusinessRule];
    
    if ([daoService conformsToProtocol:@protocol(ProcessBusinessRuleDAO)]) {
        [daoService saveRecordModels:processBusinessRuleArray];
    }
}

#pragma - mark NamedSearchModel

- (void)createAndInsertNamedSearchModel:(NSArray*)array {
    
    NSMutableArray *namedSearchArray = [[NSMutableArray alloc] init];
    NSDictionary *mappingDict = [SFNamedSearchModel getMappingDictionary];
    
    for (NSDictionary *dict in array) {
        
        SFNamedSearchModel *model = [[SFNamedSearchModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [namedSearchArray addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeNamedSearch];
    
    if ([daoService conformsToProtocol:@protocol(SFNamedSearchDAO)]) {
        [daoService saveRecordModels:namedSearchArray];
    }
    
}

#pragma - mark SearchObjDetailModel

- (void)createAndInsertNamedSearchComponentModel:(NSArray*)array {
    
    NSMutableArray *searchObjDetailArray = [[NSMutableArray alloc] init];
    NSDictionary *mappingDict = [SFNamedSearchComponentModel getMappingDictionary];
    
    for (NSDictionary *dict in array) {
        
        SFNamedSearchComponentModel *model = [[SFNamedSearchComponentModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [searchObjDetailArray addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSearchObjectDetail];
    
    if ([daoService conformsToProtocol:@protocol(SFNamedSearchComponentDAO)]) {
        [daoService saveRecordModels:searchObjDetailArray];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K contains[c] %@) OR (%K contains[c] %@)",kNSComponentExpressionType, @"LKUP_Prefilter_Criteria",kNSComponentExpressionType,@"LKUP_Criteria"];
    
    NSArray *filterArray = [array filteredArrayUsingPredicate:predicate];
    
    [self createAndInsertExpressionComponent:filterArray];
}

#pragma mark - SearchFilters

- (void)createAndInsertNamedSearchFilters:(NSArray*)array {
    
    NSMutableArray *searchFilterArray = [[NSMutableArray alloc] init];
    NSDictionary *mappingDict = [SFNamedSearchFilterModel getMappingDictionary];
    
    for (NSDictionary *dict in array) {
        SFNamedSearchFilterModel *model = [[SFNamedSearchFilterModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [searchFilterArray addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeNamedSerachFilter];
    
    if ([daoService conformsToProtocol:@protocol(SFNamedSearchFilterDAO)]) {
        [daoService saveRecordModels:searchFilterArray];
    }
}

#pragma mark - sourceupdate

- (void)createAndInsertSourceUpdateModel:(NSArray*)array
{
    NSMutableArray *sourceUpdateArray = [[NSMutableArray alloc] init];
    NSDictionary *mappingDict = [SFSourceUpdateModel getMappingDictionary];
    for (NSDictionary *dict in array) {
        
        SFSourceUpdateModel *model = [[SFSourceUpdateModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [sourceUpdateArray addObject:model];
    }
    id daoService = [FactoryDAO serviceByServiceType:ServiceTypeSourceUpdate];
    
    if ([daoService conformsToProtocol:@protocol(SourceUpdateDAO)]) {
        [daoService saveRecordModels:sourceUpdateArray];
    }
}

#pragma mark
- (void)createAndInsertLinkedSFMModel:(NSArray*)array {
    
    NSMutableArray *linkedProcessArray = [NSMutableArray new];
    NSDictionary *mappingDict = [LinkedSfmProcessModel getMappingDictionary];
    
    for (NSDictionary *dict in array) {
        LinkedSfmProcessModel *model = [[LinkedSfmProcessModel alloc] init];
        [ParserUtility parseJSON:dict toModelObject:model withMappingDict:mappingDict];
        [linkedProcessArray addObject:model];
    }
    id service = [FactoryDAO serviceByServiceType:ServiceTypeLinkedSFMProcess];
    if ([service conformsToProtocol:@protocol(LinkedSfmProcessDAO)]) {
        [service saveRecordModels:linkedProcessArray];
    }
}

#pragma maek -End

@end

