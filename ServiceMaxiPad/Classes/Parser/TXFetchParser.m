//
//  TXFetchParser.m
//  ServiceMaxMobile
//
//  Created by shravya on 25/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "TXFetchParser.h"
#import "StringUtil.h"
#import "TXFetchHelper.h"
#import "TransactionObjectModel.h"
#import "EventTransactionObjectModel.h"

@interface TXFetchParser ()

@property(nonatomic,strong)TXFetchHelper *helper;

@end

@implementation TXFetchParser

-(ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel
                                     responseData:(id)newResponseData{
    
    if (![newResponseData isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    @synchronized([self class]) {
        @autoreleasepool {
            if (self.helper == nil) {
                if ((self.categoryType != CategoryTypeOneCallRestInitialSync) || (self.categoryType != CategoryTypeResetApp) ) {
                     self.helper = [[TXFetchHelper alloc] initWithCheckForDuplicateRecords:YES];
                }
                else{
                     self.helper = [[TXFetchHelper alloc] initWithCheckForDuplicateRecords:NO];
                }
               
            }
            
            NSDictionary *responsedata = (NSDictionary  *)newResponseData;
            NSMutableDictionary *requestDictionary = (NSMutableDictionary *)requestParamModel.requestInformation;
            
            NSArray *valueMaps = [responsedata valueForKey:kSVMXRequestSVMXMap];//Objects
            for(NSDictionary *dict in valueMaps)
            {
                @autoreleasepool {
                    NSString *responseKey  = [dict objectForKey:kSVMXRequestKey];
                    
                    if (![StringUtil isStringEmpty:responseKey] && [responseKey isEqualToString:kSafeToDelete]) {
                        [self handleSafeToDelete:dict andRequestDictionary:requestDictionary];
                        continue;
                    }
                    /*Insert into database to respective table(Object)*/
                    NSMutableArray *objectrecords = [[NSMutableArray alloc] init];
                    NSString *objectName = [dict valueForKey:kSVMXRequestValue];
                    if ([StringUtil isStringEmpty:objectName]) {
                        continue;
                    }
                    
                    NSMutableDictionary *allIdDictionary = [requestDictionary objectForKey:objectName];
                    
                    NSArray *objectValues = [dict valueForKey:kSVMXRequestSVMXMap];
                    for (NSDictionary *objectDict in objectValues) {
                        NSString *jsonStr = [objectDict valueForKey:kSVMXRequestValue];
                        
                        //NSDictionary *jsonDict = [self.parser objectWithString:jsonStr];
                        
                        NSData *recordData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *e = nil;
                        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:recordData options:NSJSONReadingMutableContainers error:&e];
                        
                        
                        NSString *sfId = [jsonDict objectForKey:kId];
                        if (![StringUtil isStringEmpty:sfId ]) {
                            [allIdDictionary removeObjectForKey:sfId];
                        }
                        
                        if ([objectName isEqualToString:kServicemaxEventObject] ||[objectName isEqualToString:kEventObject] ) {
                            EventTransactionObjectModel * model = [self getEventTransactionObjectModelForObject:objectName withData:jsonDict];
                            [objectrecords addObject:model];
                        } else {
                        
                        /* Create Model */
                        TransactionObjectModel *model = [[TransactionObjectModel alloc] initWithObjectApiName:objectName];
                        [model setFieldValueDictionaryForFields:jsonDict];
                        [objectrecords addObject:model];
                        }
                    }
                    if ([objectrecords count] > 0) {
                       [self.helper insertObjects:objectrecords withObjectName:objectName];
                    }
                }
            }
            
            /*Call back*/
            ResponseCallback *callBack = [[ResponseCallback alloc] init];
            callBack.callBack = NO;
            RequestParamModel *requestModel = [[RequestParamModel alloc] init];
            callBack.callBackData = requestModel;
            
            [self fillUpResponseCallBack:callBack andRequestObjectDictionary:requestDictionary];
            return callBack;
        }
    }
}

- (void)fillUpResponseCallBack:(ResponseCallback *)callBk andRequestObjectDictionary:(NSMutableDictionary *)globalObjectDictionary{
    @synchronized([self class]) {
        NSInteger currentCount = 0;
        
        NSArray *allObjectKeys = [globalObjectDictionary allKeys];
        for (NSString *objectnName in allObjectKeys) {
            
            NSMutableArray *idsArray = [globalObjectDictionary objectForKey:objectnName];
            currentCount+= [idsArray count];
        }
        
        if (currentCount < kOverallIdLimit) {
            
            NSMutableDictionary *objectListDictioanry = [self.helper getIdListFromSyncHeapTableWithLimit:(kOverallIdLimit - currentCount)];
            
            
            for (NSString *eachObjectName in [objectListDictioanry allKeys]) {
                
                NSMutableDictionary *newIdDictionary = [objectListDictioanry objectForKey:eachObjectName];
                
                NSMutableDictionary *paramsIdDict = [globalObjectDictionary objectForKey:eachObjectName];
                if (paramsIdDict == nil) {
                    [globalObjectDictionary setObject:newIdDictionary forKey:eachObjectName];
                    paramsIdDict = newIdDictionary;
                }
                else{
                    [paramsIdDict addEntriesFromDictionary:newIdDictionary];
                }
                
                currentCount = currentCount + [newIdDictionary count];
            }
        }
        if (currentCount > 0) {
            callBk.callBack = YES;
            callBk.callBackData.requestInformation = globalObjectDictionary;
            [self fillUpValueMapDictionaryInCallBack:callBk.callBackData];
        }
        
    }
}

- (void)handleSafeToDelete:(NSDictionary *)deletedDictionary
      andRequestDictionary:(NSMutableDictionary *)requestDictionary {
    
    NSArray *valueMap = [deletedDictionary objectForKey:kSVMXRequestSVMXMap];
    for (int counter = 0; counter < [valueMap count]; counter++) {
        
        NSDictionary *innerMap = [valueMap objectAtIndex:counter];
        
        /* Get object name*/
        NSString *objectName = [innerMap objectForKey:kSVMXRequestKey];
        if ([StringUtil isStringEmpty:objectName]) {
            continue;
        }
        NSMutableDictionary *allIdDictionary = [requestDictionary objectForKey:objectName];
        
        
        /* Get ids  */
        NSArray *idsArray = [innerMap objectForKey:kSVMXRequestValues];
        for (int innerCounter = 0; innerCounter < [idsArray count]; innerCounter++) {
            
            NSString *sfId = [idsArray objectAtIndex:innerCounter];
            if (![StringUtil isStringEmpty:sfId]) {
                [allIdDictionary removeObjectForKey:sfId];
            }
        }
        
    }
}

- (void)fillUpValueMapDictionaryInCallBack:(RequestParamModel *)paramModel {
    
    /* Form a request parameters and get client info */
    @autoreleasepool {
         paramModel.valueMap  =  [self.helper getValueMapDictionary:paramModel.requestInformation];
    }
}

- (EventTransactionObjectModel*)getEventTransactionObjectModelForObject:(NSString*)objectName withData:(NSDictionary*)dataDict
{
    EventTransactionObjectModel *model = [[EventTransactionObjectModel alloc] initWithObjectApiName:objectName];
    [model setFieldValueDictionaryForFields:dataDict];
    [model splittingTheEvent];
    [model isItMultiDay];
    
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSInteger secondsFromGmt = [timeZone secondsFromGMT];
    
    NSMutableDictionary *eventDict = [NSMutableDictionary dictionaryWithDictionary:dataDict];
    
    [eventDict setObject:[NSNumber numberWithBool:model.isItMultiDay] forKey:kIsMultiDayEvent];
    [eventDict setObject:[model convertToJsonString] forKey:kSplitDayEvents];
    [eventDict setObject:[NSString stringWithFormat:@"%ld",(long)secondsFromGmt] forKey:kTimeZone];
    [model setFieldValueDictionaryForFields:eventDict];
    return model;
}
@end
