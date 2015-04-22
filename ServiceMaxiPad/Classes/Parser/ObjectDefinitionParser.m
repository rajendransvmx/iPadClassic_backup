//
//  ObjectDefinitionParser.m
//  ServiceMaxMobile
//
//  Created by shravya on 21/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "ObjectDefinitionParser.h"
#import "RequestConstants.h"
#import "StringUtil.h"
#import "ResponseCallBack.h"
#import "RequestParamModel.h"
#import "SFRecordTypeModel.h"
#import "SFRecordTypeService.h"
#import "SFObjectModel.h"
#import "SFObjectService.h"
#import "SFObjectFieldModel.h"
#import "SFObjectFieldService.h"
#import "SFPicklistModel.h"
#import "SFPicklistService.h"
#import "SFChildRelationshipModel.h"
#import "SFChildRelationshipService.h"



@implementation ObjectDefinitionParser

-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)newResponseData {
        @synchronized(self){
             @autoreleasepool {
                 
                 if (![newResponseData isKindOfClass:[NSDictionary class]]) {
                     return nil;
                 }
                 
                 //dynamic value properties
                
                 NSString *kSVMXResponseKey = kSVMXRequestKey;
                 NSString *kSVMXValueMap = kSVMXRequestSVMXMap;
                 NSString *kSVMXResponseValue = kSVMXRequestValue;
  
                 
                 NSDictionary *responsedata = (NSDictionary *)newResponseData;
                 
                 NSArray *objects = requestParamModel.values;
                 NSMutableDictionary *objectsDictionary = [[NSMutableDictionary alloc] init];
                 for (int counter = 0; counter < [objects count]; counter++) {
                     NSString *objectKey = [objects objectAtIndex:counter];
                     if (objectKey != nil) {
                         
                         [objectsDictionary setObject:@"0" forKey:objectKey];
                     }
                 }
                 
                 NSArray *objectsDefnArray = [responsedata objectForKey:kSVMXValueMap];
                 if ([objectsDefnArray count] > 0) {
                     
                     NSDictionary *objectDefnDict = [objectsDefnArray objectAtIndex:0];
                     NSString *keyName = [objectDefnDict objectForKey:kSVMXResponseKey];
                     if ([keyName isEqualToString:kObjectDefinition]) {
                         
                         NSArray *objectsArray = [objectDefnDict objectForKey:kSVMXValueMap];
                         
                         for (int counter = 0; counter < [objectsArray count]; counter++) {
                             @autoreleasepool {
                                 NSDictionary *sfObject = [objectsArray objectAtIndex:counter];
                                 NSString *objectName = [sfObject objectForKey:kSVMXResponseValue];
                                 
                                 if (![StringUtil isStringEmpty:objectName]) {
                                     objectName = [objectName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                     [objectsDictionary removeObjectForKey:objectName];
                                 }
                                 
                                 //There is some issue with server due to which sometimes we get the pricebook value with upper or lower case and hence the below compares
                                 if ([[objectName lowercaseString]isEqualToString:@"pricebook2"]) {
                                     objectName = @"Pricebook2";
                                 }else if ([[objectName lowercaseString]isEqualToString:@"pricebookentry"]) {
                                     objectName = @"PricebookEntry";
                                 }
                                 
                                 NSArray *properties = [sfObject objectForKey:kSVMXValueMap];
                                 for (int counter = 0; counter < [properties count]; counter++) {
                                     NSDictionary *propertyDictionary = [properties objectAtIndex:counter];
                                     NSString *propertyKey = [propertyDictionary objectForKey:kSVMXResponseKey];
                                     if ([propertyKey isEqualToString:kAPIObjectDefnProperty]) {
                                         
                                         NSArray *objDefnProperties = [propertyDictionary objectForKey:kSVMXValueMap];
                                         NSInteger propCount = [objDefnProperties count];
                                         for (int i = 0; i < propCount; i++) {
                                             NSDictionary *outerDictionary = [objDefnProperties objectAtIndex:i];
                                             NSString *outerKey = [outerDictionary objectForKey:kSVMXResponseKey];
                                             if ([outerKey isEqualToString:kAPIObjDefnRecordType]) {
                                                 [self insertRecordTypeInformation:outerDictionary andObjectName:objectName];
                                             }
                                             else if ([outerKey isEqualToString:kAPIObjDefnObjDefn]){
                                                 
                                                 [self insertObjectDefinition:outerDictionary andObjectName:objectName];
                                             }
                                         }
                                     }
                                     else if([propertyKey isEqualToString:kAPIObjDefnFieldProperty]) {
                                         NSArray *fieldsArray = [propertyDictionary objectForKey:kSVMXValueMap];
                                         
                                         [self insertFieldInformationOfObject:objectName WithFieldInfo:fieldsArray];
                                     }
                                 }
                             }
                         }
                     }
                 }
                 
                ResponseCallback * callBackObj = [[ResponseCallback alloc] init];
                if ([objectsDictionary count] > 0) {
                     RequestParamModel *newRequestModel = [[RequestParamModel alloc] init];
                     callBackObj.callBack = YES;
                     newRequestModel.values = [objectsDictionary allKeys];
                     callBackObj.callBackData = newRequestModel;
                 }
                 return callBackObj;

                 
             }
            return nil;
        }
}

#pragma mark - Parse and insert object properties and record types

- (void)insertObjectDefinition:(NSDictionary *)objectInformation andObjectName:(NSString *)objectName {
    
    
    NSArray *valueMapArray = [objectInformation objectForKey:kSVMXRequestSVMXMap];
    NSInteger arrayCount = [valueMapArray count];
    SFObjectModel *sfObject = [[SFObjectModel alloc] init];
    sfObject.objectName = objectName;
    NSArray *masterDetailsArray = nil;
    for (int jCounter = 0; jCounter < arrayCount; jCounter++) {
        
        NSDictionary *valueMapDict = [valueMapArray objectAtIndex:jCounter];
        NSString *jKey = [valueMapDict objectForKey:kSVMXRequestKey];
        NSString *value = nil;
        if ([jKey isEqualToString:kAPIObjDefnKeyPrefix]) {
            value = [valueMapDict objectForKey:kSVMXRequestValue];
            if (![StringUtil isStringEmpty:value]) {
                sfObject.keyPrefix = value;
            }
        }
        else if([jKey isEqualToString:kAPIObjDefnlabel]){
            
            value = [valueMapDict objectForKey:kSVMXRequestValue];
            if (![StringUtil isStringEmpty:value]) {
                sfObject.label = value;
            }
            
        }else if ([jKey isEqualToString:kAPIObjDefnPluLabel]) {
            
            value = [valueMapDict objectForKey:kSVMXRequestValue];
            if (![StringUtil isStringEmpty:value]) {
                sfObject.labelPlural = value;
            }
        }
        else if ([jKey isEqualToString:kAPIObjDefnMasterDetails]) {
            
            NSArray *valueMapArray = [valueMapDict objectForKey:kSVMXRequestSVMXMap];
            if ([valueMapArray isKindOfClass:[NSArray class]]) {
                masterDetailsArray = valueMapArray;
            }
        }
    }
    
    SFObjectService *service = [[SFObjectService alloc] init]; //TODo: Add this factory
    if ([service conformsToProtocol:@protocol(CommonServiceDAO)]) {
        [service saveRecordModel:sfObject];
    }
    
   
    if ([masterDetailsArray count] > 0) {
        [self  createAndInsertChildRelationshipsModelsFrom:masterDetailsArray andObjectName:objectName];
    }
    
}

- (void)createAndInsertChildRelationshipsModelsFrom:(NSArray *)masterDetailsArray
                                      andObjectName:(NSString *)objectName {
    
    
    NSMutableArray *recordsArray = [[NSMutableArray alloc] init];
   
    for ( NSDictionary *eachJsonDict  in  masterDetailsArray) {
        SFChildRelationshipModel *aModel = [[SFChildRelationshipModel alloc] initWithDictionary:eachJsonDict];
        aModel.objectNameParent = objectName;
        [recordsArray addObject:aModel];
        
    }
    if ([recordsArray count] <= 0) {
        return;
    }
    SFChildRelationshipService *service = [[SFChildRelationshipService alloc] init];
    if ([service conformsToProtocol:@protocol(CommonServiceDAO)]) {
        [service saveRecordModels:recordsArray];
    }
}
    

- (void)insertRecordTypeInformation:(NSDictionary *)recordTypeDict andObjectName:(NSString *)objectName{
    
    NSMutableArray *recordsArray = [[NSMutableArray alloc] init];
    NSArray *recordTypeArray = [recordTypeDict objectForKey:kSVMXRequestSVMXMap];
    for ( NSDictionary *eachJsonDict  in  recordTypeArray) {
        SFRecordTypeModel *aModel = [[SFRecordTypeModel alloc] initWithDictionary:eachJsonDict];
        aModel.objectApiName = objectName;
        [recordsArray addObject:aModel];
        
    }
    
    SFRecordTypeService *service = [[SFRecordTypeService alloc] init];
    if ([service conformsToProtocol:@protocol(CommonServiceDAO)]) {
        [service saveRecordModels:recordsArray];
    }
}

- (void)insertFieldInformationOfObject:(NSString *)objectName WithFieldInfo:(NSArray *)fieldInfoArray {
    
    NSMutableArray *fieldsArray = [[NSMutableArray alloc] init];
    
//    if ([objectName isEqualToString:@"SVMXC__Service_Order__c"]) {
//        NSLog(@"wo");
//    }
    
    for (int counter = 0; counter < [fieldInfoArray count]; counter++) {
        
        SFObjectFieldModel *field = [[SFObjectFieldModel alloc] init];
        field.objectName = objectName;
        NSDictionary *fieldDictionary = [fieldInfoArray objectAtIndex:counter];
        
        NSString *fieldName = [fieldDictionary objectForKey:kSVMXRequestValue];
        if (![StringUtil isStringEmpty:fieldName]) {
            field.fieldName = fieldName;
        }
       
        NSArray *propertyArray = [fieldDictionary objectForKey:kSVMXRequestSVMXMap];
        NSInteger  totalCount= [propertyArray count];
        for (int j = 0; j < totalCount; j++) {
            NSDictionary *propertyDictionary = [propertyArray objectAtIndex:j];
            NSString *key = [propertyDictionary objectForKey:kSVMXRequestKey];
            NSString *value = [propertyDictionary objectForKey:kSVMXRequestValue];
            
            
            if ([StringUtil isStringEmpty:value]) {
                value = @"";
            }
            
            
            if ([key isEqualToString:kAPIObjDefnLength]) {
                field.length = [value integerValue];
            }
            else if([key isEqualToString:kAPIObjDefnType]){
                field.type = [value lowercaseString];
            }
            else if([key isEqualToString:kAPIObjDefnNameField]){
                field.nameField = [value lowercaseString];
            }
            else if([key isEqualToString:kAPIObjDefnlabel]){
                field.label = value;
            }
            else if([key isEqualToString:kAPIObjDefnReferencedTo]){
                field.referenceTo = value;
            }
            else if([key isEqualToString:kAPIObjDefnRelationShipName]){
                field.relationName = value;
            }
            else if([key isEqualToString:kAPIObjDefnDependentPickList]){
                
            }
            else if([key isEqualToString:kAPIObjDefnControllerField]){
                field.controlerField = value;
            }
            else if ([key isEqualToString:kAPIObjDefnPrecision]){
                field.precision = [value doubleValue];
            }
            else if ([key isEqualToString:kAPIObjDefnScale]){
                field.scale = [value doubleValue];
            }
            else if([key isEqualToString:kAPIObjDefnPicklistInfo]){
                NSArray *valueMap = [propertyDictionary objectForKey:kSVMXRequestSVMXMap];
                if ([valueMap count] > 0) {
                    NSString *isDependentPicklist =  [self insertPicklistValue:valueMap forObjectName:objectName andFieldName:fieldName];
                    if (isDependentPicklist != nil) {
                        field.dependentPicklist = isDependentPicklist;
                    }
                }
            }
        }
        [fieldsArray addObject:field];
    }
    if ([fieldsArray count] > 0) {
        SFObjectFieldService *service = [[SFObjectFieldService alloc] init];
        if ([service conformsToProtocol:@protocol(CommonServiceDAO)]) {
            [service saveRecordModels:fieldsArray];
        }
}
    
}

- (NSString *)insertPicklistValue:(NSArray *)pickListValues forObjectName:(NSString *)objectName andFieldName:(NSString *)fieldName {
    
    NSString *isDependent = nil;
    NSMutableArray *picklistObjects = [[NSMutableArray alloc] init];
    for (int innerCounter = 0; innerCounter < [pickListValues count]; innerCounter++) {
        NSDictionary *pickListDictionary = [pickListValues objectAtIndex:innerCounter];
        NSArray *valueMap = [pickListDictionary objectForKey:kSVMXRequestSVMXMap];
        SFPicklistModel *somePicklist = [[SFPicklistModel alloc] init];
        
        NSString *someKey = [pickListDictionary objectForKey:kSVMXRequestKey];
        if (innerCounter == 0 && ![StringUtil isStringEmpty:someKey] && [someKey isEqualToString:@"DEPENDENTPICKLIST"]) {
            
            NSString *value =  [pickListDictionary objectForKey:kSVMXRequestValue];
            if (![StringUtil isStringEmpty:value]) {
                isDependent = value;
            }
            continue;
        }
        
        somePicklist.objectName = objectName;
        somePicklist.fieldName = fieldName;
        
        if ([valueMap count] > 0) {
            NSDictionary *picklistDict =  [valueMap objectAtIndex:0];
            NSString *key = [picklistDict objectForKey:kSVMXRequestKey];
            if ([key isEqualToString:kAPIObjDefnPicklistvalue]) {
                NSString *keyValue =  [picklistDict objectForKey:kSVMXRequestValue];
                somePicklist.value = keyValue;
            }
        }
        
        if ([valueMap count] > 1) {
            NSDictionary *picklistDict =  [valueMap objectAtIndex:1];
            NSString *key = [picklistDict objectForKey:kSVMXRequestKey];
            if ([key isEqualToString:kAPIObjDefnPicklistLabel]) {
                NSString *keyValue =  [picklistDict objectForKey:kSVMXRequestValue];
                somePicklist.label = keyValue;
            }
        }
        
        if ([valueMap count] > 2) {
            NSDictionary *picklistDict =  [valueMap objectAtIndex:2];
            NSString *key = [picklistDict objectForKey:kSVMXRequestKey];
            if ([key isEqualToString:kAPIObjDefnPicklistDefalut]) {
                NSString *keyValue =  [picklistDict objectForKey:kSVMXRequestValue];
                somePicklist.defaultValue = keyValue;
            }
        }
        
        if (somePicklist.value != Nil) {
            [picklistObjects addObject:somePicklist];
        }
        
    }
    
    if ([picklistObjects count]) {
        SFPicklistService *service = [[SFPicklistService alloc] init];
        if ([service conformsToProtocol:@protocol(CommonServiceDAO)]) {
            [service saveRecordModels:picklistObjects];
        }
    }
    return isDependent;
}


@end
