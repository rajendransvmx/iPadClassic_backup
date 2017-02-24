//
//  ProductIQManager.m
//  ServiceMaxiPad
//
//  Created by Rahman Sab C on 02/10/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import "ProductIQManager.h"
#import "MobileDeviceSettingService.h"
#import "StringUtil.h"
#import "SFWizardModel.h"
#import "WizardComponentModel.h"
#import "SFMRecordFieldData.h"
#import "CommonServices.h"
#import "TransactionObjectModel.h"
#import "TransactionObjectService.h"
#import "SFMPageHelper.h"
#import "FactoryDAO.h"
#import "SFObjectFieldDAO.h"
#import "TagManager.h"
#import "TaskModel.h"
#import "TaskGenerator.h"
#import "TaskManager.h"
#import "WebserviceResponseStatus.h"

@implementation ProductIQManager

#pragma mark Singleton Methods

+ (instancetype) sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initInstance];
    });
    return sharedInstance;
}

- (instancetype) initInstance {
    self = [super init];
    _recordIds = [[NSMutableArray alloc] initWithCapacity:0];
    // Do any other initialisation stuff here
    // ...
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

/*
 Method Name:isProductIQEnabled
 Description: This method will check two conditions to enable ProductIQ wizard.
 They are:
 
 1. setting should be enabled.
 2. SFM Page should have IB or Location as fields.
 
 */
- (BOOL)isProductIQEnabledForSFMPage:(SFMPageViewModel*)sfmPageView {
    BOOL productIQEnabled = NO;
    
    if ([self isProductIQSettingEnable]) {
        if ([self isProductIQRelatedFieldsAvailableOnSFMPageView:sfmPageView]) {
            productIQEnabled = YES;
        }
    }
    return productIQEnabled;
}
/*
 Method Name: isProductIQEnabledForStandaAloneObject
 Description:
 Description: This method will check two conditions to enable ProductIQ wizard for Stand alone object.
 They are:
 
 1. setting should be enabled.
 2. SFM Page should have IB or Location as fields.
 */

- (BOOL)isProductIQEnabledForStandaAloneObject:(SFObjectModel*)sfObject {
    BOOL productIQEnabled = NO;
    
    if ([self  isProductIQSettingEnable]) {
        if ([self isProductIQRelatedFieldsAvailableForStandAloneObject:sfObject]) {
            productIQEnabled = YES;
        }
    }
    return productIQEnabled;
}

- (BOOL)isProductIQSettingEnable {
    BOOL settingEnabled = NO;
    MobileDeviceSettingService *mobileDeviceSettingService = [[MobileDeviceSettingService alloc]init];
    MobileDeviceSettingsModel *mobDeviceSettings = [mobileDeviceSettingService fetchDataForSettingId:@"PRODIQ002_SET001"];
    settingEnabled = [StringUtil isItTrue:mobDeviceSettings.value];
    
    return settingEnabled;
}
- (BOOL)isProductIQRelatedFieldsAvailableOnSFMPageView:(SFMPageViewModel*)sfmPageView {
    BOOL productIQFieldsAvailable = NO;
    
    if (self.recordIds != nil && self.recordIds.count > 0) {
        [self.recordIds removeAllObjects];
    }
    
    NSMutableArray *fieldsArray = [[NSMutableArray alloc] initWithCapacity:0];
    [fieldsArray addObject:kWorkOrderSite]; // Location
    [fieldsArray addObject:kInstalledProductTableName]; //IB
    
//    //Check view process object name. If view process for IB or Location then enable ProductIQ.
    
    if ([fieldsArray containsObject:sfmPageView.sfmPage.objectName]) {
        productIQFieldsAvailable = YES;
        NSString *sfId = [[sfmPageView.sfmPage.headerRecord objectForKey:@"Id"] internalValue];
        if (![StringUtil isStringEmpty:sfId]) {
            [self.recordIds addObject:sfId];
            NSString *fieldName = kWorkOrderCompanyId;
            
            if ([sfmPageView.sfmPage.objectName isEqualToString:kWorkOrderSite]) {
                fieldName = kSiteAccountId;
            }
            
            //get the accountId by using IB sfid.
            self.accountId = [self getAccountIdForObject:sfmPageView.sfmPage.objectName withObjectId:[self.recordIds firstObject] withFieldName:fieldName];
        }
    }
    
    //As per MFL app, ProductIQ will be enabled only for WorkOrder,IB,Location Objects.
    if (productIQFieldsAvailable == NO && [sfmPageView.sfmPage.objectName isEqualToString:kWorkOrderTableName]) {
        //This logic for header records to verify that IB or Location has value on SFMPage.
        
        NSDictionary *referenceDictionary = [self getReferenceFieldsFor:sfmPageView.sfmPage.objectName];
        NSArray *allKeys = [referenceDictionary allKeys];
        
        //get all Ibs from child to top level like (compoent,parent,top level)
        NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey:nil ascending: YES];
        allKeys =  [allKeys sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
        
        
        for (NSString *key in allKeys) {
            NSString *value = [referenceDictionary objectForKey:key];
            if ([value isEqualToString:kInstalledProductTableName]) {
                NSString *recordId = [self getRecordIdForProductIQRelatedFiledForObject:sfmPageView.sfmPage.objectName withFieldName:key withLocalId:sfmPageView.sfmPage.recordId];
                if (![StringUtil isStringEmpty:recordId]) {
                    productIQFieldsAvailable = YES;
                    //TODO:check this only for IB or need to include LocationId too.
                    [self.recordIds addObject:recordId];
                }
            }
        }
        
        NSString *workOrderSfId = [[sfmPageView.sfmPage.headerRecord objectForKey:@"Id"] internalValue];
        
        //Now check for WorkDetail object. (kWorkOrderDetailTableName)
        //This is specific to work detail --> serial number (record type: Products Serviced
        [self getInstallBaseIdsForWorkDetailObject:kWorkOrderDetailTableName withWorkOrderId:workOrderSfId];
        
        //get the accountId by using IB sfid.
        self.accountId = [self getAccountIdForObject:kInstalledProductTableName withObjectId:[self.recordIds firstObject] withFieldName:kWorkOrderCompanyId];

    }
    

    return productIQFieldsAvailable;
}

- (NSString*)getAccountIdForObject:(NSString*)objectName withObjectId:(NSString*)sfid withFieldName:(NSString*)fieldName{
    
    NSString *accountId = nil;
    NSString *locationId = nil;
    NSArray *fieldsArray = nil;
    DBCriteria * criteria1 = nil;
    DBCriteria *criteria2 = nil;
    
    if ([objectName isEqualToString:kInstalledProductTableName]) {
        fieldsArray = [NSArray arrayWithObjects:fieldName,kWorkOrderSite,nil];
    }
    
    TransactionObjectService *services = [[TransactionObjectService alloc] init];
    
    
    criteria1 = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:sfid];
    
    //kWorkOrderCompanyId
    NSArray *records = [services fetchDataForObjectForSfmPage:objectName fields:fieldsArray expression:nil criteria:@[criteria1]];
    
    for (TransactionObjectModel *model in records) {
        NSDictionary *dictionary = [model getFieldValueDictionary];
        accountId = [dictionary objectForKey:fieldName];
        locationId = [dictionary objectForKey:kWorkOrderSite];
    }
    
    if (accountId == nil && locationId != nil) { //kSiteAccountId
        criteria2 = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:locationId];
        NSArray *records = [services fetchDataForObjectForSfmPage:kWorkOrderSite fields:@[kSiteAccountId] expression:nil criteria:@[criteria2]];
        
        for (TransactionObjectModel *model in records) {
            NSDictionary *dictionary = [model getFieldValueDictionary];
            accountId = [dictionary objectForKey:kSiteAccountId];
        }
    }
    
    return accountId;
}

- (void)getInstallBaseIdsForWorkDetailObject:(NSString*)objectName withWorkOrderId:(NSString*)workOrderSfId{
    //get sfid from SFRecord table if record type is "Products Serviced".
    NSString *sfrecordTypeId = [self getRecordIdForObject:kSFRecordType withFieldName:kRecordTypeId withRecordType:kRecordType];
    
    TransactionObjectService *services = [[TransactionObjectService alloc] init];
    
    DBCriteria * criteria1 = nil;
    DBCriteria * criteria2 = nil;
    
    criteria1 = [[DBCriteria alloc] initWithFieldName: kRecordTypeId operatorType:SQLOperatorEqual andFieldValue:sfrecordTypeId];
    
    criteria2 = [[DBCriteria alloc] initWithFieldName:kWorkOrderTableName operatorType:SQLOperatorEqual andFieldValue:workOrderSfId];
    
    
    NSString * advExpression = @"(1 AND 2)";
    
    NSArray *records = [services fetchDataForObjectForSfmPage:objectName fields:@[kSerialNumber] expression:advExpression criteria:@[criteria1,criteria2]];
    
    for (TransactionObjectModel *model in records) {
        NSDictionary *dictionary = [model getFieldValueDictionary];
        NSString *installBaseId = [dictionary objectForKey:kSerialNumber];
        if (![StringUtil isStringEmpty:installBaseId] && ![self.recordIds containsObject:installBaseId]) {
            [self.recordIds addObject:installBaseId];
        }
    }
    
   }

/*
 
 Method Name:isProductIQRelatedFieldsAvailableForStandAloneObject
 
 Description: This method will verifies wheather selected stand alone object type is Location or IB.
 
 
 */

- (BOOL)isProductIQRelatedFieldsAvailableForStandAloneObject:(SFObjectModel*)sfObject {
    BOOL productIQFieldsAvailable = NO;
    
    NSMutableArray *fieldsArray = [[NSMutableArray alloc] initWithCapacity:0];
    [fieldsArray addObject:kWorkOrderSite]; // Location
    [fieldsArray addObject:kInstalledProductTableName]; //IB
    
    if ([fieldsArray containsObject:sfObject.objectName]) {
        productIQFieldsAvailable = YES;
    }
    
    
    return productIQFieldsAvailable;
}

/*
 Method Name:getRecordFieldForIndex
 Description: This method will get the recordData for matched child line for IB and Location objects.
 
 */

- (SFMRecordFieldData *)getRecordFieldForIndex:(NSInteger)selectedIndex
                                  andPageField:(SFMPageField *)pageField
                                andSFMPageView:(SFMPageViewModel*)sfmPageView andSFMDetailLayout:(SFMDetailLayout*)detailLayout {
    
    SFMRecordFieldData * recordField = nil;
    if (pageField.fieldName != nil) {
        NSMutableDictionary * detailDict =  sfmPageView.sfmPage.detailsRecord;
        NSArray * detailRecords = [detailDict objectForKey: detailLayout.processComponentId];
        for (NSDictionary * recordDict in detailRecords) {
            recordField = [recordDict objectForKey:pageField.fieldName];
        }
    }
    
    return recordField;
}
/*
 Method Name:getRecordFieldForIndex
 Description: This method will get the localId for matched child line for IB and Location objects.
 
 */
- (SFMRecordFieldData *)getLocalIdRecordFieldForIndex:(NSInteger)selectedIndex
                                  andPageField:(SFMPageField *)pageField
                                andSFMPageView:(SFMPageViewModel*)sfmPageView andSFMDetailLayout:(SFMDetailLayout*)detailLayout {
    
    SFMRecordFieldData * recordField = nil;
    if (pageField.fieldName != nil) {
        NSMutableDictionary * detailDict =  sfmPageView.sfmPage.detailsRecord;
        NSArray * detailRecords = [detailDict objectForKey: detailLayout.processComponentId];
        for (NSDictionary * recordDict in detailRecords) {
            recordField = [recordDict objectForKey:kLocalId];
        }
    }
    
    return recordField;
}

/*
 Method addProductIQWizardForAllWizardArray
 Description:
 Add ProductIQ wizard for ProductIQ.
 */

- (NSMutableArray*)addProductIQWizardForAllWizardArray:(NSMutableArray*)allWizards withWizardComponetService:(SFMWizardComponentService*)wizardComponentService{
    
    @autoreleasepool {
        //add ProductIQ wizard to allWizard array.
        SFWizardModel *wizardModel = [self getSFWizardForProductIQ];
        if (allWizards.count == 0) {
            allWizards = [[NSMutableArray alloc] initWithCapacity:0];
            [allWizards addObject:wizardModel];
        } else {
            [allWizards insertObject:wizardModel atIndex:0];
        }
        
        return allWizards;
    }
}
/*
 Method disableCreateOrEditProcessOfLocationOrIBForAllWizardArray
 Description:
 1. Get the all the process Ids(SFM,OUTPUT_DOCUMENT) from allWizardArray for each compoent.
 2. Compare the process Id. If matched then diasable the IB/Location creat/edit processes.
 3. Disable create/edit processes only for two objects i.e IB or Location as of now.
 */
- (NSMutableArray*)disableCreateOrEditProcessOfLocationOrIBForAllWizardArray:(NSMutableArray*)allWizards withWizardComponetService:(SFMWizardComponentService*)wizardComponentService {
    {
        NSMutableArray *sfmProcessIds = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray *outputDocProcessIds = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (SFWizardModel *wizardModel in allWizards) {
            for (WizardComponentModel *wizardComponentModel in wizardModel.wizardComponents) {
                
                if ([wizardComponentModel.actionType isEqualToString:@"SFM"]) {
                    [sfmProcessIds addObject:[NSString stringWithFormat:@"'%@'",wizardComponentModel.processId]];
                } else if ([wizardComponentModel.actionType isEqualToString:@"OUTPUT_DOCUMENT"]) {
                    [outputDocProcessIds addObject:[NSString stringWithFormat:@"'%@'",wizardComponentModel.processId]];
                }
            }
        }
        
        NSArray *sfmMatchedProcessIds = nil;
        NSArray *outputDocMatchedProcessIds = nil;
        if (sfmProcessIds.count > 0) {
            sfmMatchedProcessIds = [wizardComponentService getSFMProcessIdsWithSFMProcessArray:sfmProcessIds];
        }
        if (outputDocProcessIds.count > 0) {
            outputDocMatchedProcessIds = [wizardComponentService getOutputDocumentrocessIdsWithOutputDocumentArray:outputDocProcessIds];
        }
        
        NSMutableArray *matchedProcessIds = [[NSMutableArray alloc] initWithCapacity:0];
        
        if (sfmMatchedProcessIds.count > 0 ) {
            [matchedProcessIds addObjectsFromArray:sfmMatchedProcessIds];
            
        }
        if (outputDocMatchedProcessIds.count > 0) {
            [matchedProcessIds addObjectsFromArray:outputDocMatchedProcessIds];
        }
        
        //Now disable those process where processIds are going to match from matchProcessIds
        if (matchedProcessIds.count > 0) {
            for (NSString *processId in matchedProcessIds) {
                for (SFWizardModel *wizardModel in allWizards) {
                    for (WizardComponentModel *wizardComponentModel in wizardModel.wizardComponents) {
                        
                        if ([wizardComponentModel.actionType isEqualToString:@"SFM"] || [wizardComponentModel.actionType isEqualToString:@"OUTPUT_DOCUMENT"]) {
                            
                            if ([processId isEqualToString:wizardComponentModel.processId]) {
                                wizardComponentModel.isEntryCriteriaMatching = NO;
                            }
                        }
                    }
                }
            }
        }
        return allWizards;
    }
}

/*
 Method Name:getSFWizardForProductIQ
 Description: This method will create the wizard for ProductIQ, if productIQ is enabled.
 
 */
//TODO:replace hard coded values from Tags.
- (SFWizardModel*)getSFWizardForProductIQ {
    SFWizardModel *wizardModel = [[SFWizardModel alloc]init];
    wizardModel.wizardName = [[TagManager sharedInstance]tagByName:KWizardNameForProductIQ];
    
    WizardComponentModel *wizardCompModel = [[WizardComponentModel alloc]init];
    wizardCompModel.actionType = @"ProductIQ";
    wizardCompModel.actionName = [[TagManager sharedInstance]tagByName:KStepNameForProductIQ];
    wizardCompModel.isEntryCriteriaMatching = YES;
    if (wizardModel.wizardComponents == nil)
    {
        wizardModel.wizardComponents = [[NSMutableArray alloc]init];
    }
    [wizardModel.wizardComponents addObject:wizardCompModel];
    return wizardModel;
}

/*
 Method: loadDataIntoInstalledBaseObject
 Description: This method will load the data into InstallBaseObject table once Initial sync gets completes.
 
 */
- (BOOL)loadDataIntoInstalledBaseObject {
    
    @autoreleasepool {
        NSString *tableName = @"InstallBaseObject";
        NSString *tableField = @"objectName";
        
        NSArray *installBaseObjectRecords = nil;
        NSDictionary *workOrderRecord  = @{tableField:kWorkOrderSite};
        NSDictionary *installProductRecord = @{tableField:kInstalledProductTableName};
        NSDictionary *subLocationRecord = @{tableField:KSubLocationTableName};
        
        installBaseObjectRecords = @[workOrderRecord,installProductRecord,subLocationRecord];
        
        CommonServices *services = [[CommonServices alloc] init];
        BOOL insertedRecords = [services saveRecordsFromArray:installBaseObjectRecords inTable:tableName];
        return insertedRecords;
        
    }
}

- (NSString*)getRecordIdForObject:(NSString*)tableName withFieldName:(NSString*)fieldName withRecordType:(NSString*)recordType {
    
    DBCriteria * criteia = [[DBCriteria alloc] initWithFieldName:recordType operatorType:SQLOperatorEqual andFieldValue:@"Products Serviced"];
    
    TransactionObjectService *services = [[TransactionObjectService alloc] init];
    
    TransactionObjectModel *transactionObject = [services getDataForObject:tableName fields:@[fieldName] expression:nil criteria:@[criteia]];
    
    NSString *fieldValue = [[transactionObject getFieldValueDictionary] objectForKey:fieldName];
    
    return fieldValue;
}

/*
 Method verifyProductIQRelatedFiledForObject
 Description: This method will verify the field that will have the value in corresponding table.
 Used to check, if sfm view process doesn have field but record has the value. Hence enable the ProductIQ.
 */

- (NSString*)getRecordIdForProductIQRelatedFiledForObject:(NSString*)tableName withFieldName:(NSString*)fieldName withLocalId:(NSString*)localId {
    
    
    TransactionObjectService *services = [[TransactionObjectService alloc] init];
    
    TransactionObjectModel *transactionObject = [services getDataForObject:tableName fields:@[fieldName] recordId:localId];
    
    NSString *fieldValue = [[transactionObject getFieldValueDictionary] objectForKey:fieldName];
    
    return fieldValue;
}

- (BOOL)getAllFieldsForObject:(NSString*)tableName withId:(NSString*)localId {
    
    BOOL isSuccess = NO;
    
    NSMutableArray *fieldsArray = [[NSMutableArray alloc] initWithCapacity:0];
    [fieldsArray addObject:kWorkOrderSite]; // Location
    [fieldsArray addObject:kInstalledProductTableName]; //IB
    
    TransactionObjectService *services = [[TransactionObjectService alloc] init];
    
    TransactionObjectModel *transactionObject = [services getDataForObject:tableName fields:nil recordId:localId];
    NSDictionary *dictionary = [transactionObject getFieldValueDictionary];
    
    NSArray *allKeys = [dictionary allKeys];
    
    for (NSString *fieldName in allKeys) {
        
        if (![StringUtil isStringEmpty:fieldName]) {
             NSString *relatedObjectName = [SFMPageHelper getReferenceNameForObject:tableName fieldName:fieldName];
            if ([fieldsArray containsObject:relatedObjectName]) {
                
                if (![StringUtil isStringEmpty:[dictionary objectForKey:fieldName]]) {
                    isSuccess = YES;
                }
            }
        }
    }
    return isSuccess;
}

/*
 Method: getReferenceFieldsFor
 Params: objectName
 Description:
 This method will get reference columns for specified table.
 */
- (NSDictionary *)getReferenceFieldsFor:(NSString *)objectName
{
    NSMutableDictionary *referenceToDict = [[NSMutableDictionary alloc] init];
    
    DBCriteria * criteia1 = [[DBCriteria alloc] initWithFieldName:@"objectName" operatorType:SQLOperatorEqual andFieldValue:objectName];
    
    
    DBCriteria * criteria2 = [[DBCriteria alloc] initWithFieldName:@"referenceTo" operatorType:SQLOperatorNotEqual andFieldValue:@"\\"];
    
    DBCriteria * criteria3 = [[DBCriteria alloc] initWithFieldName:@"referenceTo" operatorType:SQLOperatorIsNotNull andFieldValue:nil];
    
    
    id <SFObjectFieldDAO> objFieldDAO = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    
    
    //   NSArray * sfFieldObjects =   [objFieldDAO fetchSFObjectFieldsInfoByFields:[NSArray arrayWithObjects:@"fieldName", @"referenceTo" , nil] andCriteria:[NSArray arrayWithObjects:criteia1,criteria2,criteria3, nil]];
    
    NSArray * sfFieldObjects =   [objFieldDAO fetchSFObjectFieldsInfoByFields:[NSArray arrayWithObjects:@"fieldName", @"referenceTo" , nil] andCriteriaArray:[NSArray arrayWithObjects:criteia1,criteria2,criteria3, nil] advanceExpression:@"(1 AND 2 AND 3)"];
    
    for (SFObjectFieldModel * objField in sfFieldObjects) {
        [referenceToDict setObject:objField.referenceTo forKey:objField.fieldName];
    }
    
    return referenceToDict;
}


- (NSArray *)getProdIQRelatedObjects {
    return  @[kInstalledProductTableName, kWorkOrderSite, KSubLocationTableName, kAccountTableName, KProductTable];
}

- (NSDictionary *)getProdIQTxFetcRequestParamsForRequestCount1:(NSArray *)fileds
                                                  andTableName:(NSString *)tableName
                                                         andId:(NSString *)sfId {
    @autoreleasepool {
        
        id <TransactionObjectDAO>  transObj = [FactoryDAO serviceByServiceType:ServiceTypeTransactionObject];
        DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kLocalId operatorType:(SQLOperatorEqual) andFieldValue:sfId];
        DBCriteria *criteri2 = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorEqual andFieldValue:sfId];
        NSArray * transactionRecords =  [transObj fetchDataWithhAllFieldsAsStringObjects:tableName fields:fileds expression:@"(1 OR 2)" criteria:@[criteria,criteri2]];
      
        if([transactionRecords count ]>0)
        {
            TransactionObjectModel *model = [transactionRecords objectAtIndex:0];
            return [model  getFieldValueDictionary];
            
        }
        return nil;
    }
}


#pragma mark - Prod IQ Data Sync

-(void)initiateProdIQDataSync {
    if (!self.isProdIQSyncInProgress) {
        self.isProdIQSyncInProgress = YES;
        TaskModel *taskModel = [TaskGenerator generateTaskFor:CategoryTypeProductIQData requestParam:nil callerDelegate:self];
        self.prodIQTaskId = taskModel.taskId;
        [[TaskManager sharedInstance] addTask:taskModel];
    }
}

-(void)cancelProdIQDataSync {
    if (self.prodIQTaskId != nil) {
        [[TaskManager  sharedInstance] cancelFlowNodeWithId:self.prodIQTaskId];
        [[TaskManager  sharedInstance] removeFlowNodeWithId:self.prodIQTaskId];
    }
}


- (void)flowStatus:(id)status {
    if ([status isKindOfClass:[WebserviceResponseStatus class]]) {
        WebserviceResponseStatus *wsResponseStatus = (WebserviceResponseStatus*)status;
        if (wsResponseStatus.category == CategoryTypeProductIQData) {
            if(wsResponseStatus.syncStatus == SyncStatusInQueue || wsResponseStatus.syncStatus == SyncStatusInProgress) {
                self.isProdIQSyncInProgress = YES;
            }
            else {
                    self.isProdIQSyncInProgress = NO;
                    self.prodIQTaskId = nil;
            }
        }
    }
}


- (BOOL)validateCustomUrl: (NSURL  *)url{
    
    return (url && [url scheme] && [url host]);
    
}

@end
