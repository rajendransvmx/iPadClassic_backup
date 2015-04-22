//
//  GetPriceObjectParser.m
//  ServiceMaxMobile
//
//  Created by shravya on 26/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "GetPriceObjectParser.h"
#import "RequestConstants.h"
#import "StringUtil.h"
#import "ResponseCallBack.h"
#import "FactoryDAO.h"
#import "SFObjectFieldDAO.h"
#import "PlistManager.h"

@implementation GetPriceObjectParser

-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)newResponseData {
    
    if (![newResponseData isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    @synchronized([self class]) {
        
        @autoreleasepool {
            
            @synchronized(self){
                
                
                NSDictionary *responsedata = (NSDictionary *)newResponseData;
                
                NSMutableDictionary *requiredObjects = (NSMutableDictionary *)requestParamModel.requestInformation;
                NSMutableArray *objectsWithPermission = [[NSMutableArray alloc] init];
                
                NSArray *valuesArraytemp = [responsedata objectForKey:kSVMXRequestValues];
                NSMutableArray *valuesArray = nil;
                
                if([valuesArraytemp count] > 0){
                    valuesArray = [[NSMutableArray alloc] init];
                    for (int counter = 0; counter < [valuesArraytemp count]; counter++) {
                        
                        NSString *valuesString = [valuesArray objectAtIndex:counter ];
                        if (![StringUtil isStringEmpty:valuesString]) {
                            [valuesArray addObject:valuesString];
                        }
                    }
                }
                
                
               
                NSArray *objectsDefnArray = [responsedata objectForKey:kSVMXRequestSVMXMap];
                if ([objectsDefnArray count] > 0) {
                    NSInteger totalObjectsValueCount = [objectsDefnArray count];
                    for (int topCounter = 0; topCounter < totalObjectsValueCount; topCounter++) {
                        
                        NSDictionary *objectDefnDict = [objectsDefnArray objectAtIndex:topCounter];
                        NSString *keyName = [objectDefnDict objectForKey:kSVMXRequestKey];
                        if ([keyName isEqualToString:kAPIObjectDefnObject]) {
                            
                            NSString *objectName = [objectDefnDict objectForKey:kSVMXRequestValue];
                            
                            if (![StringUtil isStringEmpty:objectName]) {
                                objectName = [objectName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                [objectsWithPermission addObject:objectName];
                            }
                            
                            
                            /* Check if object already exist */
                             id <SFObjectFieldDAO>sfObjectService = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
                            BOOL alreadyExist =  [sfObjectService doesObjectAlreadyExist:objectName];
                            
                            if (alreadyExist) {
                                SXLogInfo(@"Get price Table already exist");
                                continue;
                            }
                            NSArray *properties = [objectDefnDict objectForKey:kSVMXRequestSVMXMap];
                            for (int counter = 0; counter < [properties count]; counter++) {
                                NSDictionary *propertyDictionary = [properties objectAtIndex:counter];
                                NSString *propertyKey = [propertyDictionary objectForKey:kSVMXRequestKey];
                                if ([propertyKey isEqualToString:kAPIObjectDefnProperty]) {
                                    
                                    NSArray *objDefnProperties = [propertyDictionary objectForKey:kSVMXRequestSVMXMap];
                                    NSInteger propCount = [objDefnProperties count];
                                    for (int i = 0; i < propCount; i++) {
                                        NSDictionary *outerDictionary = [objDefnProperties objectAtIndex:i];
                                        NSString *outerKey = [outerDictionary objectForKey:kSVMXRequestKey];
                                        if ([outerKey isEqualToString:kAPIObjDefnRecordType]) {
                                            [self insertRecordTypeInformation:outerDictionary andObjectName:objectName];
                                        }
                                        else if ([outerKey isEqualToString:kAPIObjDefnObjDefn]){
                                            
                                            [self insertObjectDefinition:outerDictionary andObjectName:objectName];
                                        }
                                    }
                                }
                                else if([propertyKey isEqualToString:kAPIObjDefnFieldProperty]) {
                                    NSArray *fieldsArray = [propertyDictionary objectForKey:kSVMXRequestSVMXMap];
                                    [self insertFieldInformationOfObject:objectName WithFieldInfo:fieldsArray];
                                }
                            }
                            
                        }
                        else if ([keyName isEqualToString:kAPIGetPriceRequiredObjects]){
                            /*Create required objet*/
                            if ([requiredObjects count] <= 0) {
                                requiredObjects = [[NSMutableDictionary alloc] init];
                                NSNumber *falseValue = @0;
                                NSArray *newRequiredObjects = [objectDefnDict objectForKey:kSVMXRequestValues];
                                for (NSString *eachobjectName in newRequiredObjects) {
                                    
                                    [requiredObjects setObject:falseValue forKey:eachobjectName];
                                    
                                }
                            }
                        }
                        
                    }
                    
                }
                
                ResponseCallback * callBackObj = [[ResponseCallback alloc] init];
                RequestParamModel *paramModel = [[RequestParamModel alloc] init];
                
                if ([valuesArray count] > 0) {
                    callBackObj.callBack = YES;
                    paramModel.values = valuesArray;
                }
                
                [self updateRequiredObjects:requiredObjects withobjectPermissionObjects:objectsWithPermission];
                if (!callBackObj.callBack) {
                    /* Update get price flag status */
                    [self updateGetPriceObjectPermissionStatus:requiredObjects];
                }
                else{
                    paramModel.requestInformation = requiredObjects;
                }
               
                return callBackObj;
            }
        }
        return nil;
    }
    return nil;
}

- (void)updateRequiredObjects:(NSMutableDictionary *)requiredObjects
  withobjectPermissionObjects:(NSArray *)objectWithPermission {
    NSNumber *trueValue = @1;
    
    for (int counter = 0; counter < [objectWithPermission count]; counter++) {
        NSString *objName = [objectWithPermission objectAtIndex:counter];
        [requiredObjects setObject:trueValue forKey:objName];
    }
}

- (void)updateGetPriceObjectPermissionStatus:(NSDictionary *)requiredObjects {
    /* Final required set objects */
    /* Update get price flag status */
    NSArray *allKeys = [requiredObjects allKeys];
    
    for (NSString *objectName in allKeys) {
        BOOL isTrue =  [[requiredObjects objectForKey:objectName] boolValue];
        if (!isTrue) {
           [PlistManager storePriceCaluclationHasPermission:NO];
            return;
        }
    }
    [PlistManager storePriceCaluclationHasPermission:YES];
}


@end
