//
//  SMDataPurgeResponseParser.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 12/31/13.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "SMDataPurgeResponseParser.h"
#import "SMDataPurgeResponseError.h"
#import "Utility.h"

NSString * const kDPResponseParserCallBack              = @"CALL_BACK";
NSString * const kDPResponseParserPartialExecutedObject = @"PARTIAL_EXECUTED_OBJECT";
NSString * const kDPResponseParserDelete                = @"DELETE";
NSString * const kDPResponseParserParent                = @"Child_Object";
NSString * const kDPResponseParserChild                 = @"Parent_Object";
NSString * const kDPResponseParserDwnloadCrtObjects     = @"DOWNLOAD_CRITERIA_OBJECTS";
NSString * const kDPResponseParserErrorDomain           = @"NSURLErrorDomain";
NSString * const kDPResponseParserLastConfigTime        = @"CONFIG_LAST_MOD";
NSString * const kDPResponseParserLastIndex             = @"LAST_INDEX";
NSString * const KDPResponseParserPriceCalcData         = @"PRICING_DATA";


@implementation SMDataPurgeResponseParser

+ (SMDataPurgeResponseError *)parseResponseErrors:(NSArray *)errors
{
    [errors retain];
    
    SMDataPurgeResponseError *dpError = nil;
    
    if ( ([errors count] > 0)
        && (errors != NULL))
    {
        dpError = [[SMDataPurgeResponseError alloc] initWithErrorCode:DPErrorTypeResponseError];
        
        NSString *errorTitle = [[errors objectAtIndex:0] errorTitle];
        NSString *message = errorTitle;
        
        if (![errorTitle length]>0)
        {
            message = [[errors objectAtIndex:0] errorMsg];
        }
        
        NSString *type = [[errors objectAtIndex:0] errorType];
        
        NSString *userInfo = [[errors objectAtIndex:0] correctiveAction];
        
        [dpError setType:type];
        [dpError setTitle:errorTitle];
        [dpError setMessage:message];
        [dpError setCorrectiveAction:userInfo];
        if (dpError.userInfoDict == nil)
        {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
            dpError.userInfoDict = dict;
            [dict release];
        }
        
        if (userInfo != nil)
        {
            [dpError.userInfoDict setObject:userInfo forKey: @"userinfo"];
        }
        else
        {
            [dpError.userInfoDict setObject:@"" forKey: @"userinfo"];
            
        }
    }
    [errors release];
    
    return [dpError autorelease];
}


+ (SMDataPurgeResponseError *)parseSoapFaultResponseError:(SOAPFault *)sFault
{
    NSString * faultString = sFault.faultstring;
   SMDataPurgeResponseError *dpError  = [[SMDataPurgeResponseError alloc] initWithErrorCode:DPErrorTypeSoapFault];
    
    [dpError setType:sFault.faultcode];
    [dpError setTitle:faultString];
    [dpError setMessage:faultString];
    [dpError setCorrectiveAction:@""];
    
    if (dpError.userInfoDict == nil)
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
        dpError.userInfoDict = dict;
        [dict release];
    }
    [dpError.userInfoDict setObject:@"" forKey:@"userinfo"];
    
    return [dpError autorelease];
}


+ (SMDataPurgeResponseError *)parseResponseError:(INTF_WebServicesDefBindingResponse *)response withType:(BOOL)isMetaSync
{
    SMDataPurgeResponseError *dpError = nil;
    
    [response retain];

    NSError *error = response.error;
    
    // General  Error Parsing
    if (error != nil)
    {
        NSString *type = error.domain;
        
        if ( ([error isKindOfClass:[NSURLErrorDomain class]]) || ([type Contains:kDPResponseParserErrorDomain]))
        {
            dpError = [[SMDataPurgeResponseError alloc] initWithErrorCode:DPErrorTypeInternetNotReachableError];
            
            NSString * failureReason = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
            
            if ( failureReason != nil)
            {
                [dpError setMessage:failureReason];            }
            else
            {
               [dpError setMessage:[error localizedDescription]];
            }
        }
        else
        {
            dpError = [[SMDataPurgeResponseError alloc] initWithErrorCode:DPErrorTypeSystemError];
            NSDictionary *userinfo=error.userInfo;
            
            [dpError setType:type];
            [dpError setMessage:[error localizedDescription]];
            [dpError setCorrectiveAction:@""];
            if (dpError.userInfoDict == nil)
            {
                NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:0];
                dpError.userInfoDict = dict;
                [dict release];
            }
            if (userinfo != nil)
            {
                [dpError.userInfoDict setObject:userinfo forKey: @"userinfo"];
            }
            else
            {
                [dpError.userInfoDict setObject:@"" forKey: @"userinfo"];

            }
            
            
        }
    }
    
    //Event Related Error Parsing
    else if (dpError == nil && (![[response.bodyParts objectAtIndex:0] isKindOfClass:[SOAPFault class]]))
    {
        NSArray * errors = nil;
        if (isMetaSync)
        {
            INTF_WebServicesDefServiceSvc_INTF_MetaSync_WSResponse * wsResponse = [response.bodyParts objectAtIndex:0];
             errors = wsResponse.result.errors;
        }
        else
        {
            INTF_WebServicesDefServiceSvc_INTF_DataSync_WSResponse * wsResponse = [response.bodyParts objectAtIndex:0];
            errors = wsResponse.result.errors;
        }
        
        dpError = [[SMDataPurgeResponseParser parseResponseErrors:errors] retain];
    }
    else if ([[response.bodyParts objectAtIndex:0] isKindOfClass:[SOAPFault class]])
    {
        SOAPFault * sFault = [response.bodyParts objectAtIndex:0];
        
        dpError = [[SMDataPurgeResponseParser parseSoapFaultResponseError:sFault] retain];
    }
    
    return [dpError autorelease];
}


+ (void)parseResponse:(SMDataPurgeResponse *)dpResponse forWSResult:(NSMutableArray *)result
{
    
    for (INTF_WebServicesDefServiceSvc_SVMXMap * svmxMapObject in result)
    {
        NSString *designatedKey = svmxMapObject.key;
        
        if ([designatedKey isEqualToString:KDPResponseParserPriceCalcData])
        {
            NSArray *valueMapArray = [svmxMapObject valueMap];
            [self parseGetPriceResponse:dpResponse forWGPResult:valueMapArray call:[svmxMapObject.value intValue]];
            if ([svmxMapObject.values count] > 0)
                [dpResponse setRemainingValues:svmxMapObject.values];
        }
        if ([designatedKey isEqualToString:kDPResponseParserLastIndex])
        {
            [dpResponse setLastIndex:svmxMapObject.value];
        }
        
        if ([designatedKey isEqualToString:kDPResponseParserLastConfigTime])
        {
            //store the config last modified time
            [dpResponse setLastConfigTime:svmxMapObject.value];
        }
        
        if([designatedKey isEqualToString:kDPResponseParserDelete])
        {
            // Nothing much to do here. Since we are not listerning to this :)
        }
        else if ([designatedKey isEqualToString:kDPResponseParserCallBack])
        {
            // Do we have expecting more data from server.
            [dpResponse setHasMoreData:[svmxMapObject.value boolValue]];
        }
        else if ([designatedKey isEqualToString:kDPResponseParserPartialExecutedObject])
        {
            // Does anything incompleted data in server
            [dpResponse setPartialExecutedObject:svmxMapObject.value];
        }
        else if ([designatedKey isEqualToString:kDPResponseParserParent]
                 || [designatedKey isEqualToString:kDPResponseParserChild])
        {
            // Advanced-Download-Criteria : Let parse all SF_ids
            
            // API name or Object name as table name.
            NSString *objectApiName = nil;
            
            if (![designatedKey isEqualToString:@""])
            {
                objectApiName = (svmxMapObject.value != nil) ? svmxMapObject.value:@"";
            }
            
            NSMutableArray * valueMap = [svmxMapObject valueMap];
            
            for (int j = 0; j < [valueMap count]; j++)
            {
                INTF_WebServicesDefServiceSvc_SVMXMap * fieldSvmxMap = [valueMap objectAtIndex:j];
                
                // Field value as JSON
                NSString * fieldValueJsonString = (fieldSvmxMap.value != nil)?fieldSvmxMap.value:@"";
                NSMutableArray * values =  [[Utility getIdsFromJsonString:fieldValueJsonString] retain];
                
                if ( (values != nil) && ([values count] > 0) && (objectApiName != nil))
                {
                    [dpResponse addMoreResults:values toType:objectApiName];
                }
                [values release];
            }
        }
        else if ([designatedKey isEqualToString:kDPResponseParserDwnloadCrtObjects])
        {
            // Nothing much to do here. this is one of initial call in advance download criteria.
            
            SMLog(kLogLevelVerbose, @" DOWNLOAD_CRITERIA_OBJECTS  found - ");
        }
        else if (![designatedKey isEqualToString:KDPResponseParserPriceCalcData]) //9978 Defect Fix
        {
            //ADV_DOWNLOAD_CRITERIAL
            NSArray *arrayOfObjects = svmxMapObject.valueMap;
            NSMutableArray * array = [[NSMutableArray alloc] init];
            
            for (INTF_WebServicesDefServiceSvc_SVMXMap * obj in arrayOfObjects)
            {
                NSString * sf_Id = [obj.value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                if ( (sf_Id != nil) && (![sf_Id isEqualToString:@""]))
                {
                    [array addObject:sf_Id];
                }
            }
            if ([array count] >0 )
                [dpResponse  addMoreResults:array toType:designatedKey];
            [array release];
        }
    }
}

+ (void)parseGetPriceResponse:(SMDataPurgeResponse *)dpResponse forWGPResult:(NSArray *)result call:(int)call
{
    BOOL isWOCountZero = FALSE;
    for (INTF_WebServicesDefServiceSvc_SVMXMap * svmxMapObject in result)
    {
         
        NSString *designatedKey = svmxMapObject.key;
     
        if ([designatedKey isEqualToString:kDPResponseParserLastIndex])
        {
            [dpResponse setLastIndex:svmxMapObject.value];
        }
        else if ([designatedKey isEqualToString:kDPResponseParserCallBack])
        {
            // Do we have expecting more data from server.
            [dpResponse setHasMoreData:[svmxMapObject.value boolValue]];
        }
        else if ([designatedKey isEqualToString:kDPResponseParserPartialExecutedObject])
        {
             // Does anything incompleted data in server
            [dpResponse setPartialExecutedObject:svmxMapObject.value];
        }
        else if([designatedKey isEqualToString:@"SPR14__Service_Order__c"] && (call == 1))
        {
         
            NSString *jsonRecord = svmxMapObject.value;
            if(jsonRecord)
            {
                NSArray * json_array = [Utility getJsonArrayFromString:jsonRecord];
                if(json_array && [json_array count])
                {
                    SMLog(kLogLevelVerbose,@"WO Values = %@",json_array);
                    [dpResponse setRemainingValues:json_array];
                }
                else
                {
                    isWOCountZero = TRUE;
                }
            }
         
        }
        else if (call == 1)
        {
            NSString *jsonRecord = svmxMapObject.value;
            if(jsonRecord)
            {
                NSArray * json_array = [Utility getJsonArrayFromString:jsonRecord];
                if(json_array && [json_array count])
                {
                    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
                    for(int k=0; k<[json_array count]; k++)
                    {
                        NSString *obj = [json_array objectAtIndex:k];
                        if(((NSNull *) obj != [NSNull null]))
                        {
                            [dataArray addObject:obj];
                        }
                    }
                    if ([dataArray count] >0 )
                        [dpResponse  addMoreResults:dataArray toType:designatedKey];
                     [dataArray release];
                 }
             }
         }
    
        else
        {
            NSArray *valueMapGPArray = [svmxMapObject valueMap];
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            for(int k=0; k<[valueMapGPArray count]; k++)
            {
                INTF_WebServicesDefServiceSvc_SVMXMap * svmxGPObjectMap = [valueMapGPArray objectAtIndex:k];
                NSString *jsonRecord = svmxGPObjectMap.value;
                NSDictionary * json_Dict = [Utility getJsonArrayFromString:jsonRecord];
                if(json_Dict)
                {
                    NSString *obj = [json_Dict objectForKey:@"Id"];
                    if(((NSNull *) obj != [NSNull null]))
                    {
                        [dataArray addObject:obj];
                    }
                }
            }
            if ([dataArray count] >0 )
                [dpResponse  addMoreResults:dataArray toType:designatedKey];
            [dataArray release];

        }
    }
    if([dpResponse hasMoreData] && !isWOCountZero)
    {
        [dpResponse setHasMoreData:TRUE];
    }
}

+ (SMDataPurgeResponse *)parseWSResponse:(INTF_WebServicesDefBindingResponse *)response
                   operationTypeMetaSync:(BOOL)isMetaSync
{
    
    SMDataPurgeResponse *purgeResponse = [[SMDataPurgeResponse alloc] init];
    
    SMDataPurgeResponseError *dataPurgeError = nil;
    
    if (response.error != nil)
    {
        dataPurgeError  = [[SMDataPurgeResponseParser parseResponseError:response withType:isMetaSync] retain];
    }
    
    if (dataPurgeError == nil)
    {
        
        //Handle SoapFault
        
        if ([[response.bodyParts objectAtIndex:0] isKindOfClass:[SOAPFault class]])
        {
            dataPurgeError  = [[SMDataPurgeResponseParser parseResponseError:response withType:isMetaSync] retain];
        }
        else
        {
            [self parseResponse:purgeResponse forWSResult:[[[response.bodyParts objectAtIndex:0] result] valueMap]];
            
            NSArray * array = [[[response.bodyParts objectAtIndex:0] result] values];
            
            
            if ( [array count] > 0)
            {
                [purgeResponse setRemainingValues:array];
                [purgeResponse setHasMoreData:TRUE];
            }
            
            [purgeResponse createPurgeModelForDownloadedCriteriaAndGPRecords];

        }
    }
    
    
    
    // Will add here.
    [purgeResponse setError:dataPurgeError];
    
    [dataPurgeError release];
    
    return [purgeResponse autorelease];
}

@end
