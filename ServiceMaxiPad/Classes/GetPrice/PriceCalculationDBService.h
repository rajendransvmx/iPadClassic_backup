//
//  PriceCalculationDBService.h
//  ServiceMaxiPhone
//
//  Created by Shravya shridhar on 6/17/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kEntitlementHistoryWarranty   ORG_NAME_SPACE@"__Warranty__c"
#define kEntitlementHistoryContract   ORG_NAME_SPACE@"__Service_Contract__c"
#define kEntitlementService           ORG_NAME_SPACE@"__Entitled_By_Service__c"
#define kEntitlementThreshold         ORG_NAME_SPACE@"__Entitled_Within_Threshold__c"
#define kPriceBookActivityType        ORG_NAME_SPACE@"__Activity_Type__c"
#define kPriceBookType                ORG_NAME_SPACE@"__Price_Book__c"
#define kTableServicePricebookEntry   ORG_NAME_SPACE@"__Service_Pricebook_Entry__c"
#define kServicePricebookActive       ORG_NAME_SPACE@"__Active__c"
#define kTableServicePricebook        ORG_NAME_SPACE@"__Service_Pricebook__c"


/*Config table */
#define kConfigTableFieldName           ORG_NAME_SPACE@"__Field_Name__c"
#define kConfigTableOperator            ORG_NAME_SPACE@"__Operator__c"
#define kConfigTableOperand             ORG_NAME_SPACE@"__Operand__c"
#define kConfigTableSequence            ORG_NAME_SPACE@"__Sequence__c"
#define kConfigTableExpType             ORG_NAME_SPACE@"__Expression_Type__c"
#define kConfigTableExpRule             ORG_NAME_SPACE@"__Expression_Rule__c"


/* Code snippet and Code snippet manifest table*/
#define kCodeSnippetData                ORG_NAME_SPACE@"__Data__c"
#define kCodeSnippetName                ORG_NAME_SPACE@"__Name__c"
#define kTableCodeSnippet               ORG_NAME_SPACE@"__Code_Snippet__c"

#define kCodeSnippetReference           ORG_NAME_SPACE@"__Referenced_Code_Snippet__c"
#define kTableCodeManifest              ORG_NAME_SPACE@"__Code_Snippet_Manifest__c"


/**
 This is a  data base service Class which handles querying to database and formating the results for calling classes .
 @author Shravya shridhar http://www.servicemax.com shravya.shridhar@servicemax.com
 */

@interface PriceCalculationDBService : NSObject


//- (NSDictionary *)getObjectForLocalId:(NSString *)localId
//                           withFields:(NSArray *)fields
//                        andObjectname:(NSString *)objectName;
- (NSString *)getPricebookInformationForSettingId:(NSString *)settingId;
- (NSDictionary *)getRecordTypeIdsForRecordType:(NSArray *)recordTypes;
- (NSDictionary *)getEntitlementHistoryForWorkorder:(NSString *)workOrderId;

- (NSMutableDictionary *)getRecordForId:(NSString *)sfId andObjectName:(NSString *)objectName;

- (NSDictionary *)preparePBEstimateId:(NSString *)estimateValue
                        andUsageValue:(NSString *)usageValue
                               andKey:(NSString *)key
                      andRecordTypeId:(NSDictionary *)recordTypeIds;
- (NSDictionary *)preparePBLaourEstimateId:(NSString *)estimateValue
                             andUsageValue:(NSString *)usageValue
                                    andKey:(NSString *)key
                           andRecordTypeId:(NSDictionary *)recordTypeIds;
- (NSDictionary *)getPriceBookDictionaryWithProductArray:(NSArray *)productsArray
                                       andPriceBookNames:(NSArray *)partsPriceBookNames
                                    andPartsPriceBookIds:(NSArray *)partsPriceBookIdsArray
                                             andCurrency:(NSString *)currencyIsoCode;
- (NSDictionary *)getPriceBookForLabourParts:(NSArray *)labourArray
                            andLabourPbNames:(NSArray *)labourPbNames
                              andLabourPbIds:(NSArray *)labourPbIds
                                 andCurrency:(NSString *)currency;

- (NSDictionary *)getReferenceToFieldsForObject:(NSString *)objectName;
- (void )updateReferenceFields:(NSMutableDictionary *)fieldValueDictionary
                      andObjectNameDict:(NSDictionary *)objectnameDict;
- (NSArray *)getRecordWhereColumnNamesAndValues:(NSDictionary *)columnKeyAndValue
                                   andTableName:(NSString *)tableName;

- (NSArray *)getNamedExpressionsForIds:(NSArray *)namedExpressionArray;

- (NSArray *)getProductRecords:(NSArray *)productIdentifiers;

- (NSArray *)getPriceBookObjectsForPriceBookIds:(NSArray *)priceBookIds
                               OrPriceBookNames:(NSArray *)priceBookNames;
- (NSArray *)getPriceBookObjectsForLabourPriceBookIds:(NSArray *)priceBookIds
                                     OrPriceBookNames:(NSArray *)priceBookNames;

- (NSString *)getPriceCodeSnippet:(NSString *)codeSnippetName;
- (NSString *)getDisplayValueForPicklist:(NSString *)pickListValue withFieldName:(NSString *)fieldName
                           andObjectName:(NSString *)objetcName;

- (NSDictionary *)getProductServiceWorkDetail:(NSString *)wordOrderId andWorkorderSfid:(NSString *)woSfid;
- (NSDictionary *)getWorkDetailForProductServiceArray:(NSArray *)productServiceIds
                                      andWorkOrderIds:(NSString *)wordOrderId andSfid:(NSString *)wosfid;
- (NSDictionary *)getAllSfidsForLocalIds:(NSArray *)allLocalIds ;
- (NSMutableDictionary *)getAllRecordForSfIds:(NSArray *)allIds andTableName:(NSString *)tableName ;

#pragma mark - PS Lines Entitlement

-(NSArray *)getPSLineRecordsForHeaderRecord:(NSString *)sfId andObjectname:(NSString*)objectname;
-(NSDictionary *)getEntitlementHistoryForPSLine:(NSString *)psLineId;
-(NSDictionary *)getPSLineSconRecordForId:(NSString *)sconId;
-(NSArray *)getPSLinePartsPricingForId:(NSString *)sconId;
-(NSArray *)getPSLinePartsDiscountForId:(NSString *)sconId;
-(NSArray *)getPSLineLaborPricingForId:(NSString *)sconId;
-(NSArray *)getPSLineExpensePricingForId:(NSString *)sconId;
-(NSArray *)getPSLinePartsPBForId:(NSString *)sconId;
-(NSArray *)getRelatedDetailRecordsForPSline:(NSString *)psLineId;
-(NSDictionary *)getPSLineWarrantyRecordForId:(NSString *)warrantyId;

@end
