//
//  PriceBookDataHandler.m
//  ServiceMaxiPhone
//
//  Created by Shravya shridhar on 6/17/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "PriceBookDataHandler.h"
#import "PriceCalculationDBService.h"
#import "StringUtil.h"
#import "TagManager.h"
#import "TagConstant.h"

@interface PriceBookDataHandler()
@property(nonatomic,strong)NSString *targetRecordId;
@property(nonatomic,strong)NSString *targetRecordLocalId;
@property(nonatomic,strong)NSString *targetCurrencyCode;
@property(nonatomic,strong)NSString *contractIdServiceOffsering;
@property(nonatomic,strong)NSString *contractIdServiceCovered;
@property(nonatomic,strong)NSArray *products;
@property(nonatomic,strong)NSArray *activities;
@property(nonatomic,strong)NSMutableArray *partsPriceBookIdsArray;
@property(nonatomic,strong)NSMutableArray *labourPriceBookIdsArray;
@property(nonatomic,strong)NSMutableArray *namedExpressionArray;
@property(nonatomic,strong)NSString *usagePartsPbName;
@property(nonatomic,strong)NSString *usageLaborPbName;
@property(nonatomic,strong)NSString *estimateLaborPbName;
@property(nonatomic,strong)NSString *estimatePartPbName;

@property(nonatomic,strong)PriceCalculationDBService *dbService;
@end

@implementation PriceBookDataHandler

- (void)releaseResources {
    self.products = nil;
    self.partsPriceBookIdsArray = nil;
    self.labourPriceBookIdsArray = nil;
    self.namedExpressionArray = nil;
    self.activities = nil;
    self.contractIdServiceCovered = nil;
    
}
- (id)initWithTargetDictionary:(NSDictionary *)targetDictionary {
    
    self = [super init];
    if (self != nil) {
        [self updatePriceBookObjectsForGivenTarget:targetDictionary];
    }
    return self;
}

- (void)updatePriceBookObjectsForGivenTarget:(NSDictionary *)targetDictionary {

    [self getPriceBook:targetDictionary];
    [self releaseResources];
}

- (void)getPriceBook:(NSDictionary *)targetDictionary {
    
    NSMutableArray *priceBookObject = [[NSMutableArray alloc] init];
    NSMutableArray *partsPriceBookNames = [[NSMutableArray alloc] init];
    NSMutableArray *labourPriceBookNames = [[NSMutableArray alloc] init];
    self.partsPriceBookIdsArray = [[NSMutableArray alloc] init];
    self.labourPriceBookIdsArray = [[NSMutableArray alloc] init];
    self.namedExpressionArray = [[NSMutableArray alloc] init];
    
    self.dbService = [[PriceCalculationDBService alloc] init];
    @autoreleasepool {
        
        /* get record type ids  */
        NSArray *recordTypes = [NSArray arrayWithObjects:@"Usage/Consumption",@"Estimate",nil];
        NSDictionary *recordTypeIds =  [self.dbService getRecordTypeIdsForRecordType:recordTypes];
        
        @autoreleasepool {
            [self fillUpRecordTypeDefinition:recordTypeIds andPriceBookObject:priceBookObject];
            [self fillUpPartPriceBookNameFromSettings:partsPriceBookNames withDbService:self.dbService];
            [self fillUpLaborPriceBookNameFromSettings:labourPriceBookNames withDbService:self.dbService];
            [self getCurrencyAndPartsActivityInfoFromTargetDictionary:targetDictionary];
            [self fillUpPartsAndLaborPriceBookInto:priceBookObject andRecordTypeIds:recordTypeIds];
        }
        
       
        /*Entitlement has to be checked thouroughly */
        NSDictionary *entitlementDict = [self.dbService getEntitlementHistoryForWorkorder:self.targetRecordId];

       
        self.contractIdServiceCovered = @"NONCOVERED";
        NSString *warrantyId = [entitlementDict objectForKey:kEntitlementHistoryWarranty];
        NSString *contractId = [entitlementDict objectForKey:kEntitlementHistoryContract];
        NSString *__Entitled_By_Service__c =  [entitlementDict objectForKey:kEntitlementService];
        
        if (![StringUtil isStringEmpty:__Entitled_By_Service__c]) {
            self.contractIdServiceOffsering = __Entitled_By_Service__c;
        }

        NSString *__Entitled_Within_Threshold__c = [entitlementDict objectForKey:kEntitlementThreshold];
        if ([StringUtil isItTrue:__Entitled_Within_Threshold__c] ) {
            self.contractIdServiceCovered = @"COVERED";
        }

        
        /* Wo comes under warranty then get warranty_id */
        if (![StringUtil isStringEmpty:warrantyId]) {
            [self fillUpWarrantyRecordWithId:warrantyId intoPriceBook:priceBookObject];
        }
        else if(![StringUtil isStringEmpty:contractId]){
            [self fillUpContractInfo:contractId withRecordType:recordTypeIds intoPb:priceBookObject];
        }

       [self fullUpIBWarrantyIntoPriceBook:priceBookObject];
        [self fillUpLookUpinformation:targetDictionary intoPricebook:priceBookObject];
        [self fillUpPartsPriceBookEntriesInto:priceBookObject andPartsPriceBooks:partsPriceBookNames];
        [self fillUpLaborPriceBookEntriesInto:priceBookObject andLaborPriceBooks:labourPriceBookNames];
        [self fillUpTagsInto:priceBookObject];
        [self fillSettingDefinition:priceBookObject];
        self.priceBookInformation = priceBookObject;
    }
}

- (void)fillUpRecordTypeDefinition:(NSDictionary *)recordTypeIds
                andPriceBookObject:(NSMutableArray *)priceBookArray {
    
    NSMutableArray *someARrayNew = [[NSMutableArray alloc] init];
    
    NSString *usage = [recordTypeIds objectForKey:@"Usage/Consumption"];
    NSDictionary *someDictionary  = [NSDictionary dictionaryWithObjectsAndKeys: @"Usage/Consumption",@"key",usage,@"value", nil];
    [someARrayNew addObject:someDictionary];
    
    NSString *estimate = [recordTypeIds objectForKey:@"Estimate"];
    someDictionary  = [NSDictionary dictionaryWithObjectsAndKeys: @"Estimate",@"key",estimate,@"value", nil];
    [someARrayNew addObject:someDictionary];
    
    NSDictionary *finalDictOne = [[NSDictionary alloc] initWithObjectsAndKeys:@"RECORDTYPEDEFINITION",@"key",someARrayNew,@"valueMap", nil];
    [priceBookArray addObject:finalDictOne];

}

- (void)fillUpPartPriceBookNameFromSettings:(NSMutableArray *)partsPriceBookNames
                              withDbService:(PriceCalculationDBService *)dbService {
    NSString *pbPartsEstimateName =  [dbService getPricebookInformationForSettingId:@"WORD005_SET006"];
    if (pbPartsEstimateName != nil) {
        [partsPriceBookNames addObject:pbPartsEstimateName];
        self.estimatePartPbName = pbPartsEstimateName;
        
    }
    NSString *pbPartsUsageName =  [dbService getPricebookInformationForSettingId:@"WORD005_SET004"];
    if (pbPartsUsageName != nil) {
        [partsPriceBookNames addObject:pbPartsUsageName];
        self.usagePartsPbName = pbPartsUsageName;
    }
}

- (void)fillUpLaborPriceBookNameFromSettings:(NSMutableArray *)labourPriceBookNames
                               withDbService:(PriceCalculationDBService *)dbService {
    NSString *pbLabourEstimateName =  [dbService getPricebookInformationForSettingId:@"WORD005_SET018"];
    if (pbLabourEstimateName != nil) {
        [labourPriceBookNames addObject:pbLabourEstimateName];
          self.estimateLaborPbName = pbLabourEstimateName;
    }
    
    NSString *pbLabourUsageName =  [dbService getPricebookInformationForSettingId:@"WORD005_SET017"];
    if (pbLabourUsageName != nil) {
        [labourPriceBookNames addObject:pbLabourUsageName];
         self.usageLaborPbName = pbLabourUsageName;
    }
}

- (void)getCurrencyAndPartsActivityInfoFromTargetDictionary:(NSDictionary *)currentContext {
    /* get the header and detail records*/
    NSDictionary *headerRecord =  [currentContext objectForKey:@"headerRecord"];
    NSArray *detailRecords = [currentContext objectForKey:@"detailRecords"];
    
    NSArray *recordsArr = [headerRecord objectForKey:@"records"];
    if ([recordsArr count] <= 0) {
        return;
    }
    
    NSDictionary *headerDataDictionary = [recordsArr objectAtIndex:0];
    self.targetRecordId = [headerDataDictionary objectForKey:@"targetRecordId"];
    NSArray *headerFieldArray =  [headerDataDictionary objectForKey:@"targetRecordAsKeyValue"];
    NSString *currencyCode =  [self getValueFOrKey:@"CurrencyIsoCode" FromArray:headerFieldArray];
    if ([StringUtil isStringEmpty:currencyCode]) {
        currencyCode = nil;
    }
    self.targetCurrencyCode = currencyCode;
    
    self.targetRecordLocalId = [self getValueFOrKey:@"local_id" FromArray:headerFieldArray];
    
    NSString *productFieldName = [StringUtil appendOrgNameSpaceToString:@"__Product__c"];
    NSString *actiVityFieldName = [StringUtil appendOrgNameSpaceToString:@"__Activity_Type__c"];
    
    NSString *workOrderProduct = [self getValueFOrKey:productFieldName FromArray:headerFieldArray];
    NSMutableArray *productsArray = [[NSMutableArray alloc] init];
    NSMutableArray *labourArray = [[NSMutableArray alloc] init];
   
    for(int counter = 0;counter < [detailRecords count];counter++){
        
        NSDictionary *detailTargetDictionary = [detailRecords objectAtIndex:counter];
        NSArray *records = [detailTargetDictionary objectForKey:@"records"];
        for(int counter = 0;counter < [records count];counter++){
            
            NSDictionary *recordDict = [records objectAtIndex:counter];
            NSArray *detalFiledsArray = [recordDict objectForKey:@"targetRecordAsKeyValue"];
            
            NSString *productId =  [self getValueFOrKey:productFieldName FromArray:detalFiledsArray];
            if (![StringUtil isStringEmpty:productId]) {
                [productsArray addObject:productId];
            }
            
            NSString *activityType =  [self getValueFOrKey:actiVityFieldName FromArray:detalFiledsArray];
            if (![StringUtil isStringEmpty:activityType]) {
                [labourArray addObject:activityType];
            }
        }
    }
    
    /*For labor we need to consider work order product if work detail does not have product*/
    if(labourArray != nil && [labourArray count]> 0 && workOrderProduct.length > 0 )
    {
        [productsArray addObject:workOrderProduct];
    }
    self.products = productsArray;
    self.activities = labourArray;
    
}

- (NSString *)getValueFOrKey:(NSString *)key FromArray:(NSArray *)array {
    for (int counter = 0; counter < [array count]; counter++) {
        NSDictionary *tempDict = [array objectAtIndex:counter];
        NSString *keyNew = [tempDict objectForKey:@"key"];
        if ([keyNew isEqualToString:key]) {
            return [tempDict objectForKey:@"value"];
        }
    }
    return nil;
}

- (void)fillUpWarrantyRecordWithId:(NSString *)warrantyId
                     intoPriceBook:(NSMutableArray *)priceBookArray {
    
    NSString *tableName = [NSString stringWithFormat:@"%@__Warranty__c",ORG_NAME_SPACE];
    
    NSMutableDictionary *warrantyDictionary =  [self.dbService getRecordForId:warrantyId andObjectName:tableName];
    
    [warrantyDictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:tableName,@"type",nil] forKey:@"attributes"];
    NSArray *tempArray =[[NSArray alloc] initWithObjects:warrantyDictionary, nil];
    NSDictionary *finalDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"WARRANTYDEFINITION",@"key",tempArray, @"data",nil];
    
    [priceBookArray addObject:finalDictionary];
   
}

- (void)fillUpContractInfo:(NSString *)contractId
            withRecordType:(NSDictionary *)recordTypeIds
                    intoPb:(NSMutableArray *)priceBookArray {

    @autoreleasepool {
        
        @autoreleasepool {
            NSString *tableName = [NSString stringWithFormat:@"%@__Service_Contract__c",ORG_NAME_SPACE];
            NSString *partsPriceBookname = [NSString stringWithFormat:@"%@__Default_Parts_Price_Book__c",ORG_NAME_SPACE];
            NSString *laborPriceBookname = [NSString stringWithFormat:@"%@__Service_Pricebook__c",ORG_NAME_SPACE];
            
            /* else If wo comes under contract then get contract_id */
            NSMutableDictionary *serviceContractDictionary = [self.dbService getRecordForId:contractId andObjectName:tableName];
            
            
            /*Get Service Contract pricebook definition for Parts */
            NSString *default_Parts_Price_Book__c =  [serviceContractDictionary objectForKey:partsPriceBookname];
            if (![StringUtil  isStringEmpty:default_Parts_Price_Book__c]) {
                /* get the price book info */
                [self.partsPriceBookIdsArray addObject:default_Parts_Price_Book__c];
                NSDictionary *tempDictionary =  [self.dbService preparePBEstimateId:default_Parts_Price_Book__c andUsageValue:default_Parts_Price_Book__c andKey:@"RECORDTYPEINFO_PARTS_CONTRACT" andRecordTypeId:recordTypeIds];
                if (tempDictionary != nil) {
                    [priceBookArray addObject:tempDictionary];
                }
            }
            
            /*Get Service Contract pricebook definition for labor*/
            NSString *__Service_Pricebook__c =  [serviceContractDictionary objectForKey:laborPriceBookname];
            if (![StringUtil isStringEmpty:__Service_Pricebook__c]) {
                [self.labourPriceBookIdsArray addObject:__Service_Pricebook__c];
                NSDictionary *tempDictionary =  [self.dbService preparePBLaourEstimateId:__Service_Pricebook__c  andUsageValue:__Service_Pricebook__c andKey:@"RECORDTYPEINFO_LABOR_CONTRACT" andRecordTypeId:recordTypeIds];
                if (tempDictionary != nil) {
                    [priceBookArray addObject:tempDictionary];
                }
            }
            
            if (serviceContractDictionary != nil) {
                NSDictionary * someDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CONTRACT_DEFINITION",@"key",[NSArray arrayWithObject:serviceContractDictionary],@"data", nil];
                [priceBookArray addObject:someDict];
            }
            
            
            /* Getting data for SPR14__Pricing_Rule__,SPR14__Parts_Pricing__c,SPR14__Parts_Discount__c,,SPR14__Labor_Pricing__c,SPR14__Expense_Pricing__c,SPR14__Travel_Policy__c,SPR14__Mileage_Tiers__c,SPR14__Zone_Pricing__c
             */
            
            [self fillUpContractInformationInTheTargetArray:priceBookArray andContractId:contractId];
            [self fillUpNamedExpressionIntpPriceBookData:priceBookArray];
            [self fillUpProductRecordsInto:priceBookArray];
        }
        
    }
}

//- (void)fillUpIBWarrantyForWorkOrder:(NSString *)workOrder into:(NSMutableArray *)priceBookArray {
//    
//}
//
- (void)fillUpLookUpinformation:(NSDictionary *)targetDictionary
                  intoPricebook:(NSMutableArray *)priceBookArray {
    
    @autoreleasepool {
        NSString *tableName = kWorkOrderTableName;
        
        NSDictionary *headerRecord =  [targetDictionary objectForKey:@"headerRecord"];
        
        NSArray *recordsArr = [headerRecord objectForKey:@"records"];
        if ([recordsArr count] <= 0) {
            return;
        }
        
        NSDictionary *headerDataDictionary = [recordsArr objectAtIndex:0];
        
        NSMutableDictionary *targetRecordAsKeyValue = [[NSMutableDictionary alloc] init];
        /*Get the target record id and targetRecordAsKeyvalue */
        NSArray *detailFieldsArr = [headerDataDictionary objectForKey:@"targetRecordAsKeyValue"];
        for (int counter = 0; counter < [detailFieldsArr count]; counter++) {
            NSDictionary *tempDict = [detailFieldsArr objectAtIndex:counter];
            NSString *keyNew = [tempDict objectForKey:@"key"];
            NSString *value  = [tempDict objectForKey:@"value"];
            if (keyNew != nil ) {
                value = value?value:@"";
                [targetRecordAsKeyValue setObject:value forKey:keyNew];
            }
        }
        
        /*Prepare work order data  */
        NSArray *tempArray = [[NSArray alloc] initWithObjects:targetRecordAsKeyValue, nil];
        NSDictionary *finalDictioanry = [[NSDictionary alloc] initWithObjectsAndKeys:tempArray,@"data",@"WORKORDER_DATA",@"key",nil];
        [priceBookArray addObject:finalDictioanry];
        finalDictioanry = nil;
        
        NSMutableDictionary *referenceIdDictionary = [[NSMutableDictionary alloc] init];
        
        NSDictionary *referenceToDictionary = [self.dbService getReferenceToFieldsForObject:tableName];
        for (NSString *fieldName in referenceToDictionary) {
            
            NSString *fieldValue = [targetRecordAsKeyValue objectForKey:fieldName];
            if (fieldValue.length > 4) {
                [referenceIdDictionary setObject:fieldValue forKey:fieldName];
            }
        }
        [self.dbService updateReferenceFields:referenceIdDictionary andObjectNameDict:referenceToDictionary];
        NSMutableArray *finalKeyArray = [[NSMutableArray alloc] init];
        for (NSString *fieldName in referenceToDictionary) {
            NSString *fieldValue = [referenceIdDictionary objectForKey:fieldName];
            NSMutableDictionary *recordDictionary = [[NSMutableDictionary alloc] init];
            if (fieldValue.length  >2) {
                NSString *idValue = [targetRecordAsKeyValue objectForKey:fieldName];
                [recordDictionary setObject:idValue forKey:@"key"];
                [recordDictionary setObject:fieldValue forKey:@"value"];
                [finalKeyArray addObject:recordDictionary];
            }
            recordDictionary = nil;
        }
        
        NSDictionary *lookUpFinal = [NSDictionary dictionaryWithObjectsAndKeys:finalKeyArray,@"valueMap",@"LOOKUP_DEFINITION",@"key", nil];
        [priceBookArray addObject:lookUpFinal];
    }
    
    
}

- (void)fillUpPartsPriceBookEntriesInto:(NSMutableArray *)priceBookArray andPartsPriceBooks:(NSArray *)partsPriceBookNames{
    
    @autoreleasepool {
        /*Get the parts pricebook entry for the requested parts, pricebook(Contract special pricebook, Setting pricebook)*/
        if ([self.products count] > 0 && ([partsPriceBookNames count] > 0 || [self.partsPriceBookIdsArray count ] >0) ) {
            
            NSDictionary *dataDictionary =  [self.dbService getPriceBookDictionaryWithProductArray:self.products andPriceBookNames:partsPriceBookNames andPartsPriceBookIds:self.partsPriceBookIdsArray andCurrency:self.targetCurrencyCode];
            if(dataDictionary != nil) {
                [priceBookArray addObject:dataDictionary];
            }
        }

    }
}


- (void)fillUpLaborPriceBookEntriesInto:(NSMutableArray *)priceBookArray andLaborPriceBooks:(NSArray *)labourPriceBookNames {
    /*Get the labour pricebook entry for the requested parts, pricebook(Contract special pricebook, Setting pricebook)*/
    
     @autoreleasepool {
         if ([self.activities count] > 0 && ([labourPriceBookNames count] > 0 || [self.labourPriceBookIdsArray count ] >0) ) {
             
             NSDictionary *dataDictionary =  [self.dbService getPriceBookForLabourParts:self.activities andLabourPbNames:labourPriceBookNames andLabourPbIds:self.labourPriceBookIdsArray andCurrency:self.targetCurrencyCode];
             if (dataDictionary != nil) {
                 [priceBookArray addObject:dataDictionary];
             }
         }
     }
   
}

- (void)fillUpTagsInto:(NSMutableArray *)priceBookArray {
    
    /*Adding tags*/
    NSMutableArray *someArray = [[NSMutableArray alloc] init];
    
    NSString * message =  [[TagManager sharedInstance] tagByName:@"EVER005_TAG087"];
    if (message.length < 1) {
        message = @"Price not calculated, because entitlement check has not been performed";
    }
    if (message != nil) {
        NSDictionary *tempDict = [[NSDictionary alloc]initWithObjectsAndKeys:message,@"value",@"EVER005_TAG087", @"key", nil];
        [someArray addObject:tempDict];
    }
    NSDictionary *finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"TAGS",@"key",someArray,@"valueMap", nil];
    [priceBookArray addObject: finalDict];
}

- (void)fillSettingDefinition:(NSMutableArray *)priceBookArray {
    
    /*Adding settings*/
    NSString *settingValue =  [self.dbService getPricebookInformationForSettingId:@"WORD005_SET019"];
    NSMutableArray *someArray = [[NSMutableArray alloc] init];
   
    if (settingValue != nil) {
        NSDictionary *tempDict = [[NSDictionary alloc]initWithObjectsAndKeys:settingValue,@"value",@"WORD005_SET019", @"key", nil];
        [someArray addObject:tempDict];
    }
    NSDictionary *finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"SETTINGS",@"key",someArray,@"valueMap", nil];
    [priceBookArray addObject: finalDict];
}


- (void)fillUpContractInformationInTheTargetArray:(NSMutableArray *)priceBookArray
                                    andContractId:(NSString *)contractId

{
    NSString *orgNameSpace = ORG_NAME_SPACE;
    NSString *currencyCode = self.targetCurrencyCode;
    NSMutableArray *namedExpressionArray = self.namedExpressionArray;
    NSString *idOfServiceOffering = self.contractIdServiceOffsering;
    NSString *idServiceCovered = self.contractIdServiceCovered;
    NSString *contractColumnName = [NSString stringWithFormat:@"%@__Service_Contract__c",orgNameSpace];
    
    NSMutableDictionary *columnNames = [[NSMutableDictionary alloc] init];
    if (currencyCode != nil) {
        [columnNames setObject:currencyCode forKey:@"CurrencyIsoCode"];
    }
    [columnNames setObject:contractId forKey:contractColumnName];
    
    
    /* Get pricing rules for Contract*/
    NSArray *dataArray =  [self.dbService getRecordWhereColumnNamesAndValues:columnNames andTableName:[NSString stringWithFormat:@"%@__Pricing_Rule__c",orgNameSpace]];
    NSDictionary *finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CONTRACT_PRICINGRULES",@"key",dataArray,@"data", nil];
    if ([dataArray count] > 0) {
        [priceBookArray addObject: finalDict];
    }
    
    [self addNamedExpressionsFrom:dataArray ToArray:namedExpressionArray];
    dataArray = nil;
    finalDict = nil;
    
    /* Get special parts pricing definition if available*/
    [columnNames setObject:kTrue  forKey:kServicePricebookActive];
    
    dataArray =  [self.dbService getRecordWhereColumnNamesAndValues:columnNames andTableName:[NSString stringWithFormat:@"%@__Parts_Pricing__c",orgNameSpace]];
    finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CONTRACT_SPECIALPARTSPRICING",@"key",dataArray,@"data", nil];
    if ([dataArray count] > 0) {
        [priceBookArray addObject: finalDict];
    }
    dataArray = nil;
    finalDict = nil;
    
    /* get special parts discount is available*/
    
    dataArray =  [self.dbService getRecordWhereColumnNamesAndValues:columnNames andTableName:[NSString stringWithFormat:@"%@__Parts_Discount__c",orgNameSpace]];
    finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CONTRACT_PARTSDISCOUNT",@"key",dataArray,@"data", nil];
    if ([dataArray count] > 0) {
        [priceBookArray addObject: finalDict];
    }
    dataArray = nil;
    finalDict = nil;
    [columnNames removeObjectForKey:kServicePricebookActive];
    
    /* Get special labor pricing definition */
   
    dataArray =  [self.dbService getRecordWhereColumnNamesAndValues:columnNames andTableName: [NSString stringWithFormat:@"%@__Labor_Pricing__c",orgNameSpace]];
    finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CONTRACT_SPECIALLABORPRICING",@"key",dataArray,@"data", nil];
    if ([dataArray count] > 0) {
        [priceBookArray addObject: finalDict];
    }
    dataArray = nil;
    finalDict = nil;
    
    /*Get expense pricing if available*/
    ;
    dataArray =  [self.dbService getRecordWhereColumnNamesAndValues:columnNames andTableName:[NSString stringWithFormat:@"%@__Expense_Pricing__c",orgNameSpace]];
    finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CONTRACT_EXPENSE",@"key",dataArray,@"data", nil];
    if ([dataArray count] > 0) {
        [priceBookArray addObject: finalDict];
    }
    dataArray = nil;
    finalDict = nil;
    
    /*Get  travel policy is available*/
    
    dataArray =  [self.dbService getRecordWhereColumnNamesAndValues:columnNames andTableName:[NSString stringWithFormat:@"%@__Travel_Policy__c",orgNameSpace]];
    finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CONTRACT_TRAVELPOLICY",@"key",dataArray,@"data", nil];
    if ([dataArray count] > 0) {
        [priceBookArray addObject: finalDict];
    }
    [self addNamedExpressionsFrom:dataArray ToArray:namedExpressionArray];
    dataArray = nil;
    finalDict = nil;
    
    
    /*mileage tier pricing is available*/

    dataArray =  [self.dbService getRecordWhereColumnNamesAndValues:columnNames andTableName:[NSString stringWithFormat:@"%@__Mileage_Tiers__c",orgNameSpace]];
    finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CONTRACT_MILEAGETIERS",@"key",dataArray,@"data", nil];
    if ([dataArray count] > 0) {
        [priceBookArray addObject: finalDict];
    }
    dataArray = nil;
   finalDict = nil;
    
    /*zone based pricing is available*/
  
    dataArray =  [self.dbService getRecordWhereColumnNamesAndValues:columnNames andTableName:[StringUtil appendOrgNameSpaceToString:@"__Zone_Pricing__c"]];
    finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CONTRACT_ZONEPRICING",@"key",dataArray,@"data", nil];
    if ([dataArray count] > 0) {
        [priceBookArray addObject: finalDict];
    }
    
    dataArray = nil;
    finalDict = nil;
    
    
    /*Get included services for Contract, we retrieve this information only if warranty says this is the included service. In response to this we attach COVERED or NONCOVERED*/
    if (idOfServiceOffering != nil) {
        [columnNames removeObjectForKey:contractColumnName];
        [columnNames setObject:idOfServiceOffering forKey:@"Id"];
        
        dataArray =  [self.dbService getRecordWhereColumnNamesAndValues:columnNames andTableName:[NSString stringWithFormat:@"%@__Service_Contract_Services__c",orgNameSpace]];
        finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:idServiceCovered,@"value",@"CONTRACT_SERVICEOFFERING",@"key",dataArray,@"data", nil];
        
        if ([dataArray count] > 0) {
            [priceBookArray addObject: finalDict];
        }
        dataArray = nil;
        finalDict = nil;
        
    }
    columnNames = nil;
}

- (void)addNamedExpressionsFrom:(NSArray *)dataArray ToArray:(NSMutableArray *)namedExpressionArray {
    
    for (int counter = 0; counter < [dataArray count]; counter ++) {
        NSDictionary *tempDictionary = [dataArray objectAtIndex:counter];
        NSString  *nameExpressionId = [tempDictionary objectForKey:[StringUtil appendOrgNameSpaceToString:@"__Named_Expression__c"]];
        if (![StringUtil isStringEmpty:nameExpressionId]) {
            [namedExpressionArray addObject:nameExpressionId];
        }
    }
}
- (void)fillUpNamedExpressionIntpPriceBookData:(NSMutableArray *)priceBookData {
    /* Get the expression ids used in the process */
    if ([self.namedExpressionArray count] > 0) {
        NSArray *valueMapArray =  [self.dbService getNamedExpressionsForIds:self.namedExpressionArray];
        NSDictionary *finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"RULES",@"key",valueMapArray,@"valueMap", nil];
        [priceBookData addObject: finalDict];
    }

}
- (void)fillUpProductRecordsInto:(NSMutableArray *)priceBookArray {
    /* Getting product definition */
    if ([self.products count] > 0) {
        NSArray *dataArray =  [self.dbService getProductRecords:self.products];
        NSDictionary *finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"PRODUCT_DEFINITION",@"key",dataArray,@"data", nil];
        if ([dataArray count] > 0) {
            [priceBookArray addObject: finalDict];
        }

    }
}

- (void)fillUpPartsAndLaborPriceBookInto:(NSMutableArray *)priceBookArray
                        andRecordTypeIds:(NSDictionary *)recordTypeIds{
    if ([self.products count] > 0) {
        NSDictionary *partsDictionary =  [self preparePBForSettings:self.estimatePartPbName andUsageValue:self.usagePartsPbName andKey:@"RECORDTYPEINFO_PARTS" andRecordTypeId:recordTypeIds];
        if (partsDictionary != nil) {
            [priceBookArray addObject:partsDictionary];
        }
    }
    
    if ([self.activities count] > 0) {
        /*preparing key value for record type ­> pricebook definition that are defined as part of setting*/
        NSDictionary *labourDictionary =  [self preparePBForLabourSettings:self.estimateLaborPbName andUsageValue:self.usageLaborPbName andKey:@"RECORDTYPEINFO_LABOR" andRecordTypeId:recordTypeIds];
        if (labourDictionary != nil) {
            [priceBookArray addObject:labourDictionary];
        }
    }

}
- (NSDictionary *)preparePBForSettings:(NSString *)estimateValue
                         andUsageValue:(NSString *)usageValue
                                andKey:(NSString *)key
                       andRecordTypeId:(NSDictionary *)recordTypeIds {
    
    NSString *usageRecordTypeId = [recordTypeIds objectForKey:@"Usage/Consumption"];
    NSString *estimateRecordTypeId = [recordTypeIds objectForKey:@"Estimate"];
    NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
    if (usageRecordTypeId != nil) {
       if (usageValue != nil) {
            NSArray *pbArray = [self.dbService getPriceBookObjectsForPriceBookIds:nil OrPriceBookNames:[NSArray arrayWithObject:usageValue]];
            for (int counter = 0; counter < [pbArray count ]; counter++) {
                
                NSDictionary *pbBook = [pbArray objectAtIndex:counter];
                NSString *finalValue = [pbBook objectForKey:@"Id"];
                if (finalValue == nil) {
                    finalValue = @"";
                }
                NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:finalValue,@"value", usageRecordTypeId,@"key", nil];
                [arrayTemp addObject:tempDictionary];
             }
        }
    }
    
    if (estimateRecordTypeId != nil && estimateValue != nil) {
        
        NSArray *pbArray = [self.dbService getPriceBookObjectsForPriceBookIds:nil OrPriceBookNames:[NSArray arrayWithObject:estimateValue]];
        for (int counter = 0; counter < [pbArray count ]; counter++) {
            NSDictionary *pbBook = [pbArray objectAtIndex:counter];
            NSString *finalValue = [pbBook objectForKey:@"Id"];
            if (finalValue == nil) {
                finalValue = @"";
            }
            NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:finalValue,@"value", estimateRecordTypeId, @"key",nil];
            [arrayTemp addObject:tempDictionary];
        }
    }
    
    NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:arrayTemp,@"valueMap",key,@"key", nil];
    return tempDictionary;
}
- (NSDictionary *)preparePBForLabourSettings:(NSString *)estimateValue
                               andUsageValue:(NSString *)usageValue
                                      andKey:(NSString *)key
                             andRecordTypeId:(NSDictionary *)recordTypeIds {
    
    NSString *usageRecordTypeId = [recordTypeIds objectForKey:@"Usage/Consumption"];
    NSString *estimateRecordTypeId = [recordTypeIds objectForKey:@"Estimate"];
     NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
        
        if (usageValue != nil && usageRecordTypeId != nil) {
            NSArray *pbArray = [self.dbService getPriceBookObjectsForLabourPriceBookIds:nil OrPriceBookNames:[NSArray arrayWithObject:usageValue]];
            for (int counter = 0; counter < [pbArray count ]; counter++) {
                
                NSDictionary *pbBook = [pbArray objectAtIndex:counter];
                NSString *finalValue = [pbBook objectForKey:@"Id"];
                if (finalValue != nil) {
                    NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:finalValue,@"value", usageRecordTypeId,@"key", nil];
                    [arrayTemp addObject:tempDictionary];
                }
                
            }
        }
        
        if (estimateRecordTypeId != nil && estimateValue != nil) {
            
            NSArray *pbArray = [self.dbService getPriceBookObjectsForLabourPriceBookIds:nil OrPriceBookNames:[NSArray arrayWithObject:estimateValue]];
            for (int counter = 0; counter < [pbArray count ]; counter++) {
                NSDictionary *pbBook = [pbArray objectAtIndex:counter];
                NSString *finalValue = [pbBook objectForKey:@"Id"];
                if (finalValue != nil) {
                    NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:finalValue,@"value", estimateRecordTypeId, @"key",nil];
                    [arrayTemp addObject:tempDictionary];
                    
                }
            }
        }
        NSDictionary *tempDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:arrayTemp,@"valueMap",key,@"key", nil];
        return tempDictionary;
}

- (void)fullUpIBWarrantyIntoPriceBook:(NSMutableArray *)priceBookData {
    NSArray *allWarrantyArray = [self getIBWarrantyArray:self.targetRecordLocalId andWorkOrderSfid:self.targetRecordId];
    if ([allWarrantyArray count] > 0) {
        NSDictionary *finalDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"IBWARRANTY",@"key",allWarrantyArray,@"valueMap", nil];
        [priceBookData addObject: finalDict];
    }
    
    NSDictionary *offlineDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"TRUE",@"value",@"SVMX_OFFLINE_MODE",@"key",nil];
    [priceBookData addObject: offlineDict];
}
- (NSArray *)getIBWarrantyArray:(NSString *)wordOrderLocalId  andWorkOrderSfid:(NSString *)workOrderSfid {
    
     NSString *tableName = [NSString stringWithFormat:@"%@__Warranty__c",ORG_NAME_SPACE];
    if (workOrderSfid == nil) {
        workOrderSfid = @" ";
    }
    NSDictionary *productServiceWorkdDetail = [self.dbService getProductServiceWorkDetail:wordOrderLocalId andWorkorderSfid:workOrderSfid];
    
    if ([productServiceWorkdDetail count] > 0) {
        
        /* Get all work order ids which matches the condition */
        NSDictionary *allWorkOrderIds =  [self.dbService getWorkDetailForProductServiceArray:[productServiceWorkdDetail allKeys] andWorkOrderIds:wordOrderLocalId andSfid:workOrderSfid];
        
        /* Get All warranties */
        NSDictionary *allWarranties = [self.dbService getAllRecordForSfIds:[productServiceWorkdDetail allValues] andTableName:tableName];
        
        NSMutableArray *finalResult = [[NSMutableArray alloc] init];
        if ([allWarranties count] > 0 &&  [allWorkOrderIds count] > 0) {
            
            NSArray *allServiceIds = [allWorkOrderIds allKeys];
            for (NSString *serviceId in allServiceIds) {
                
                NSArray *workDetailIds = [allWorkOrderIds objectForKey:serviceId];
                
                NSString *warrantyId = [productServiceWorkdDetail objectForKey:serviceId];
                if (warrantyId != nil ) {
                    NSDictionary *warrantyRecord = [allWarranties objectForKey:warrantyId];
                    NSMutableDictionary *eachRecord = [[NSMutableDictionary alloc] init];
                    
                    if ([workDetailIds count] > 0) {
                        [eachRecord setObject:workDetailIds forKey:@"values"];
                    }
                    
                    if (warrantyRecord != nil) {
                        [eachRecord setObject:warrantyRecord forKey:@"record"];
                    }
                    
                    [finalResult addObject:eachRecord];
                    eachRecord = nil;
                }
                
            }
        }
        return finalResult;
    }
    return @[];
}

@end
