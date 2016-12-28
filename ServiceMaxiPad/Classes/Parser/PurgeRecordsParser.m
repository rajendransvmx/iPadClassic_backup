//
//  PurgeRecordsParser.m
//  ServiceMaxiPad
//
//  Created by Sruthi Ramakrishnan on 28/12/16.
//  Copyright © 2016 ServiceMax Inc. All rights reserved.
//

#import "PurgeRecordsParser.h"
#import "DBCriteria.h"
#import "DBRequestDelete.h"
#import "CommonServices.h"
#import "SuccessiveSyncManager.h"

@implementation PurgeRecordsParser

-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)responsedata {
    
    if (![responsedata isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    ResponseCallback *callback = [[ResponseCallback alloc] init];
    callback.callBack = NO;
    
    NSLog(@"Purge records response \n%@",responsedata);
    
    NSArray *maps = [responsedata objectForKey:@"valueMap"];
    
    NSString *excludeObject = [[NSString alloc] init];
    NSArray *partialObjectIds = [[NSArray alloc] init];
    NSMutableArray *callbackValueMapArray = [[NSMutableArray alloc] init];
    
    //find the partial executed object
    for (NSDictionary* mapObj in maps) {
        
        NSString *string = [mapObj valueForKey:kSVMXRequestKey];
        
        if ([string isEqualToString:kPartiallyExecutedobj]) {
            excludeObject = [mapObj objectForKey:kSVMXValue];
            break;
        }
    }
    
    /*
     Sample response:
     
     In this we send the following values as callback:
     
     1. values =             (
     a1dJ0000000zwZ1IAI,
     a1dJ0000000zwZ2IAI,
     a1dJ0000000zwZ3IAI,
     a1dJ0000000zwZ4IAI,
     a1dJ0000000zw5OIAQ,
     a1dJ0000000zwZQIAY,
     a1dJ0000000zwZRIAY
     ); ----> This is because SVMXDEV__Service_Order_Line__c is PARTIAL_EXECUTED_OBJECT
     
     2. Also we have to find SVMXDEV__Service_Order__c object values from the request.valueMapArray since it has not been processed (not present in the response) and send with callback
     
     {
     aplOrder = "<null>";
     errors =     (
     );
     eventName = "<null>";
     eventType = "<null>";
     message = "<null>";
     messageType = "<null>";
     pageUI = "<null>";
     success = "<null>";
     value = "<null>";
     valueMap =     (
     {
     data = "<null>";
     key = "Object_Name";
     "lstInternal_Request" = "<null>";
     "lstInternal_Response" = "<null>";
     record = "<null>";
     value = "SVMXDEV__Service_Order_Line__c";
     valueMap =             (
     );
     values =             (
     a1dJ0000000zwZ1IAI,
     a1dJ0000000zwZ2IAI,
     a1dJ0000000zwZ3IAI,
     a1dJ0000000zwZ4IAI,
     a1dJ0000000zw5OIAQ,
     a1dJ0000000zwZQIAY,
     a1dJ0000000zwZRIAY
     );
     },
     {
     data = "<null>";
     key = "PARTIAL_EXECUTED_OBJECT";
     "lstInternal_Request" = "<null>";
     "lstInternal_Response" = "<null>";
     record = "<null>";
     value = "SVMXDEV__Service_Order_Line__c";
     valueMap =             (
     );
     values =             (
     a1dJ0000000zw5NIAQ
     );
     }
     );
     values =     (
     );
     }
     */
    
    for (NSDictionary* mapObj in maps)
    {
        NSString *key = [mapObj valueForKey:kSVMXRequestKey];
        
        //find if the object is processed, ie, not in partial executed object and purge the record if so
        if ([key isEqualToString:kObjectName]) {
            
            NSString *objectName = [mapObj objectForKey:kSVMXValue];
            
            if (![objectName isEqualToString:excludeObject]) {
                
                NSArray *values  = [mapObj objectForKey:kSVMXValues];
                
                DBCriteria *aCriteria1 = [[DBCriteria alloc] initWithFieldName:kId operatorType:SQLOperatorIn andFieldValues:values];
                DBRequestDelete *deleteRequest = [[DBRequestDelete alloc] initWithTableName:objectName whereCriteria:@[aCriteria1] andAdvanceExpression:nil];
                CommonServices *commonServices = [[CommonServices alloc] init];
                [commonServices executeStatement:[deleteRequest query]];
            }
        }
    }
    
    //if callback needs to be made, find the partial executed and send the "values" in the Object_Name dictionary with the same object name
    if (excludeObject.length > 0) {
        
        NSMutableArray *processedObjects = [[NSMutableArray alloc] init];
        
        for (NSDictionary* mapObj in maps) {
            
            NSString *string = [mapObj valueForKey:kSVMXRequestKey];
            
            if ([string isEqualToString:@"Object_Name"]) {
                NSString *value = [mapObj valueForKey:kSVMXValue];
                if ([value isEqualToString:excludeObject]) {
                    NSArray *values = [mapObj objectForKey:kSVMXValues];
                    if (values) {
                        partialObjectIds = values;
                    }
                }
                else {
                    [processedObjects addObject:value];
                }
            }
        }
        
        //callback values for partial executed object
        NSMutableDictionary *callbackDict = [[NSMutableDictionary alloc] init];
        [callbackDict setObject:@"Object_Name" forKey:@"key"];
        [callbackDict setObject:excludeObject forKey:@"value"];
        [callbackDict setObject:partialObjectIds forKey:@"values"];
        [callbackValueMapArray addObject:callbackDict];
        
        //callback values for other objects, if any
        for (NSDictionary *valueMap in requestParamModel.valueMap) {
            
            NSString *objectName = [valueMap objectForKey:kSVMXValue];
            NSString *objectvalues = [valueMap objectForKey:kSVMXValues];
            
            //check whether the object got processed in the response
            BOOL isProcessed = NO;
            for (NSString *processed in processedObjects) {
                if ([processed isEqualToString:objectName]) {
                    isProcessed = YES;
                }
            }
            
            //add to callback if object is not processed in response
            if (![objectName isEqualToString:excludeObject] && !isProcessed) {
                callbackDict = [[NSMutableDictionary alloc] init];
                
                [callbackDict setObject:@"Object_Name" forKey:@"key"];
                [callbackDict setObject:objectName forKey:@"value"];
                [callbackDict setObject:objectvalues forKey:@"values"];
                
                [callbackValueMapArray addObject:callbackDict];
            }
        }
        
        callback.callBack = YES;
        
        RequestParamModel *callBackRequest = [[RequestParamModel alloc] init];
        callBackRequest.value = requestParamModel.value;
        callBackRequest.valueMap = callbackValueMapArray;
        
        callback.callBackData = callBackRequest;
    }
    
    if (callback == nil) {
        [[SuccessiveSyncManager sharedSuccessiveSyncManager] setWhatIdsToDelete:nil];
    }
    
    return callback;
}

@end
