//
//  SMDataPurgeRequest.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 12/31/13.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "SMDataPurgeRequest.h"
#import "SVMXSystemConstant.h"
#import "AppDelegate.h"
#import "SMDataPurgeResponseParser.h"

#import "SMDataPurgeHelper.h"

@interface SMDataPurgeRequest()

/* Requesting */
- (void)makeRequest;

/* Getter for request Parameters */
- (NSString *)getEventTypeAsSync;
- (NSString *)getRequestEventName;
- (NSString *)getRequestIdentifier;

/* Methods for creating WS class instance */
- (INTF_WebServicesDefBinding *)getBinding;

- (INTF_WebServicesDefServiceSvc_CallOptions *)getCallOptions;
- (INTF_WebServicesDefServiceSvc_INTF_DataSync_WS *)getDataSync;
- (INTF_WebServicesDefServiceSvc_INTF_MetaSync_WS *)getMetaSync;
- (INTF_WebServicesDefServiceSvc_INTF_SFMRequest *)getSFMRequest;
- (INTF_WebServicesDefServiceSvc_SessionHeader *)getSessionHeader;
- (INTF_WebServicesDefServiceSvc_DebuggingHeader *)getDebuggingHeader;
- (INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader *)getFieldTruncationHeader;


/* Updating request Parameters */

- (void)configureParamForSFMRequest:(INTF_WebServicesDefServiceSvc_INTF_SFMRequest *)sfmRequest;

- (void)configureGetPriceParemForSFMRequest:(INTF_WebServicesDefServiceSvc_INTF_SFMRequest *)sfmRequest;

-(void)setGeneralParemetersForSFMRequest:(INTF_WebServicesDefServiceSvc_INTF_SFMRequest *)sfmRequest;


/*set valuemap*/
- (INTF_WebServicesDefServiceSvc_SVMXMap *) getLastIndexMap;
- (INTF_WebServicesDefServiceSvc_SVMXMap *) getPartiObjectMap;

- (INTF_WebServicesDefServiceSvc_SVMXMap *) getLaborMap:(NSArray *)value;
- (INTF_WebServicesDefServiceSvc_SVMXMap *) getCurrencyMap;
- (INTF_WebServicesDefServiceSvc_SVMXMap *) getPriceBookIdMap:(NSArray *)value;

@end



@implementation SMDataPurgeRequest

@synthesize requestId;
@synthesize eventName;
@synthesize isMetaSync;
@synthesize requestDelegate;
@synthesize index;
@synthesize data;
@synthesize partialObject;
@synthesize partialExecutedData;


- (id)initWithRequestIdentifier:(NSString *)identifier withCallBackValues:(SMDataPurgeCallBackData *)callBack
{
    self = [super init];
    if (self)
    {
        self.requestId = identifier;
        [self resetCallBackObj];
        if (callBack != nil)
        {
            self.index = callBack.lastIndex;
            self.partialObject = callBack.partialExecutedObject;
            self.partialExecutedData = callBack.partialExecutedObjData;
            self.data = callBack.values;
        }
        self.isMetaSync = NO;
    }
    return self;
}

- (void) resetCallBackObj
{
    self.index = @"0";
    self.partialObject = nil;
    self.partialExecutedData = nil;
    self.data = nil;
}

- (void)makeConfigurationLastModifiedDateRequest
{
    self.eventName = kWSDataPurgeEventNameConfigLastModifiedTime;
    self.isMetaSync = YES;
    [self makeRequest];
}


- (void)makeDownloadCriteriaRequest
{
    self.eventName = kWSDataPurgeEventNameDownloadCriteria;
    [self makeRequest];
}


- (void)makeAdvancedDownloadCriteriaRequest
{
    self.eventName = kWSDataPurgeEventNameAdvancedDownloadCriteria;
    [self makeRequest];
}

- (void) makeGetPriceRequest
{
    self.eventName = kWSDataPurgeEventNameGetPrice;
    [self makeRequest];
}


- (void)makeCleanUpRequest
{
    self.eventName = kWSDataPurgeEventNameCleanUp;
    [self makeRequest];
}

- (void)makeDataSyncRequest
{
    [INTF_WebServicesDefServiceSvc initialize];
    INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = [[self getSFMRequest] retain];
    
    
    INTF_WebServicesDefServiceSvc_SVMXDEVlient * client = [[appDelegate getSVMXDEVlientObject]retain];
    [sfmRequest addClientInfo:client];
    
    INTF_WebServicesDefServiceSvc_INTF_DataSync_WS  *sync = [[self getDataSync] retain];
    [sync setRequest:sfmRequest];
    
    INTF_WebServicesDefBinding * binding = [[self getBinding] retain];
    
    [binding INTF_DataSync_WSAsyncUsingParameters:sync
                                    SessionHeader:[self getSessionHeader]
                                      CallOptions:[self getCallOptions]
                                  DebuggingHeader:[self getDebuggingHeader]
                       AllowFieldTruncationHeader:[self getFieldTruncationHeader]
                                         delegate:self];
    
    [sfmRequest release];
    [client release];
    [sync release];
    [binding release];
}


- (void)makeMetaSyncRequest
{
    [INTF_WebServicesDefServiceSvc initialize];
    INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = [[self getSFMRequest] retain];
    
    
    INTF_WebServicesDefServiceSvc_SVMXDEVlient * client = [[appDelegate getSVMXDEVlientObject]retain];
    [sfmRequest addClientInfo:client];
    
    INTF_WebServicesDefServiceSvc_INTF_MetaSync_WS  *sync = [[self getMetaSync] retain];
    [sync setRequest:sfmRequest];
    
    INTF_WebServicesDefBinding * binding = [[self getBinding] retain];
    
    [binding INTF_MetaSync_WSAsyncUsingParameters:sync
                                    SessionHeader:[self getSessionHeader]
                                      CallOptions:[self getCallOptions]
                                  DebuggingHeader:[self getDebuggingHeader]
                       AllowFieldTruncationHeader:[self getFieldTruncationHeader]
                                         delegate:self];
    
    [sfmRequest release];
    [client release];
    [sync release];
    [binding release];
}


- (void)makeRequest
{
    if (self.isMetaSync)
    {
        [self makeMetaSyncRequest];
    }
    else
    {
        [self makeDataSyncRequest];
    }
}


- (NSString *)getEventTypeAsSync
{
    return kWSDataPurgeEventTypeSync;
}


- (NSString *)getRequestEventName
{
    return self.eventName;
}


- (NSString *)getRequestIdentifier
{
    return self.requestId;
}


- (INTF_WebServicesDefBinding *)getBinding
{
    INTF_WebServicesDefBinding * binding = nil;
    binding = [INTF_WebServicesDefServiceSvc INTF_WebServicesDefBindingWithServer:appDelegate.currentServerUrl];
    binding.logXMLInOut = [appDelegate enableLogs];
    
    return binding;
}


- (INTF_WebServicesDefServiceSvc_INTF_DataSync_WS *)getDataSync
{
    INTF_WebServicesDefServiceSvc_INTF_DataSync_WS * dataSync = nil;
    dataSync = [[INTF_WebServicesDefServiceSvc_INTF_DataSync_WS alloc] init];
    
    return [dataSync  autorelease];
}


- (INTF_WebServicesDefServiceSvc_INTF_MetaSync_WS *)getMetaSync
{
    INTF_WebServicesDefServiceSvc_INTF_MetaSync_WS * metaSync = nil;
    metaSync = [[INTF_WebServicesDefServiceSvc_INTF_MetaSync_WS alloc] init];
    
    return [metaSync  autorelease];
}


- (INTF_WebServicesDefServiceSvc_SVMXMap *) getLastIndexMap
{
    INTF_WebServicesDefServiceSvc_SVMXMap * lastIndex = nil;
    lastIndex = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
    lastIndex.key = @"LAST_INDEX";
    lastIndex.value = self.index;
    
    return [lastIndex  autorelease];
}
- (INTF_WebServicesDefServiceSvc_SVMXMap *) getPartiObjectMap
{
    INTF_WebServicesDefServiceSvc_SVMXMap * partialObjectMap = nil;
    partialObjectMap = [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
    partialObjectMap.key = @"PARTIAL_EXECUTED_OBJECT";
    partialObjectMap.value = [self.partialObject objectForKey:@"PARTIAL_EXECUTED_OBJECT"];
    [partialObjectMap.values addObjectsFromArray:self.partialExecutedData];
    
    return [partialObjectMap  autorelease];
}


- (INTF_WebServicesDefServiceSvc_SVMXMap *) getLaborMap:(NSArray *)value
{
    NSMutableArray *activityType = [[NSMutableArray alloc] init];
    for(NSDictionary *dict in value)
    {
        NSString *activityValue = [dict objectForKey:@"value"];
        [activityType addObject:activityValue];
    }
    
    if([activityType count])
    {
        INTF_WebServicesDefServiceSvc_SVMXMap * SVMXDEVObject =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
        
        SVMXDEVObject.key  = @"Labor";
        for(int i=0; i<[activityType count]; i++)
        {
            [SVMXDEVObject.values addObject:[activityType objectAtIndex:i]];
        }
        
        [activityType release];
        return [SVMXDEVObject autorelease];
    }
    [activityType release];
    return nil;
}

- (INTF_WebServicesDefServiceSvc_SVMXMap *) getCurrencyMap
{
    
    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXDEVMapCurrency =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
    SVMXDEVMapCurrency.key  = @"CurrencyISO";
    
    return [SVMXDEVMapCurrency autorelease];
    
}
- (INTF_WebServicesDefServiceSvc_SVMXMap *) getPriceBookIdMap:(NSArray *)value
{
    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXDEVMapUniqueCurrency =  [[INTF_WebServicesDefServiceSvc_SVMXMap alloc] init];
    SVMXDEVMapUniqueCurrency.key  = @"PRICEBOOK_ID";
    [SVMXDEVMapUniqueCurrency.values addObjectsFromArray:value];
    
    return [SVMXDEVMapUniqueCurrency autorelease];
}

- (void)configureParamForSFMRequest:(INTF_WebServicesDefServiceSvc_INTF_SFMRequest *)sfmRequest
{
    [self setGeneralParemetersForSFMRequest:sfmRequest];
    
    // Dummy value map
    INTF_WebServicesDefServiceSvc_SVMXMap * map =  [[self getLastIndexMap] retain];
    [sfmRequest.valueMap  addObject:map];
    [map release];
    
    if ((self.partialObject != nil) && [self.partialObject count] > 0)
    {
        if ([self.eventName isEqualToString:kWSDataPurgeEventNameAdvancedDownloadCriteria]) //Defect Fix - 010126
        {
            //PARTIAL_EXECUTED_OBJECT
            INTF_WebServicesDefServiceSvc_SVMXMap * objectMap = [[self getPartiObjectMap] retain];
            [sfmRequest.valueMap addObject:objectMap];
            [objectMap release];
        }
        else
        {
            if (self.partialExecutedData != nil && [self.partialExecutedData count] > 0)
                [sfmRequest.values addObjectsFromArray:self.partialExecutedData];
        }
     }
    
    if (self.data != nil && [self.data count] > 0)
        [sfmRequest.values addObjectsFromArray:self.data];

}

- (void)configureGetPriceParemForSFMRequest:(INTF_WebServicesDefServiceSvc_INTF_SFMRequest *)sfmRequest
{
    [self setGeneralParemetersForSFMRequest:sfmRequest];
    
    INTF_WebServicesDefServiceSvc_SVMXMap * lastIndexMap =  [[self getLastIndexMap] retain];
    [sfmRequest.valueMap addObject:lastIndexMap];
    [lastIndexMap release];
    
    
    if ((self.partialObject != nil) && [self.partialObject count] > 0)
    {
        //PARTIAL_EXECUTED_OBJECT
        INTF_WebServicesDefServiceSvc_SVMXMap * objectMap = [[self getPartiObjectMap] retain];
        [sfmRequest.valueMap addObject:objectMap];
        [objectMap release];
    }

    if([self.index isEqualToString:@"2"])
    {
        NSArray *columns = [NSArray arrayWithObject:kDataPurgeColumnName];
        
        NSString *filterCriteria = [NSString stringWithFormat:@"object_api_name = 'SVMXDEV__Service_Order_Line__c' and field_api_name = 'SVMXDEV__Activity_Type__c'"];
        NSArray * array = [NSArray arrayWithObjects:@"SFPicKlist", [NSArray arrayWithObject:@"value"], filterCriteria, @"",  nil];
        NSArray *activityTypeArray =  [[SMDataPurgeHelper getAllRecordsFromDatabase:array] retain];
    
        INTF_WebServicesDefServiceSvc_SVMXMap * map = [[self getLaborMap:activityTypeArray] retain];
        if (map != nil)
            [sfmRequest.valueMap addObject:map];
        [map release];
        [activityTypeArray release];
        
        array = [NSArray arrayWithObjects:kDataPurgePriceBook, columns, @"", @"", nil];
        
        NSArray *priceBookIds = [[SMDataPurgeHelper getAllRecordsFromDatabase:array] retain];
        
        
        array = [NSArray arrayWithObjects:kDataPurgeCustomPriceBook, columns, @"", @"", nil];
        
        
        NSArray *customPriceBookIds = [[SMDataPurgeHelper getAllRecordsFromDatabase:array] retain];
        
        if(([priceBookIds count] + [customPriceBookIds count]) > 0)
        {
            INTF_WebServicesDefServiceSvc_SVMXMap * mapCurrency =  [[self getCurrencyMap] retain];
            BOOL currencyPresent = NO;
            for(NSDictionary *priceBookDict in priceBookIds)
            {
                NSString *priceBookId = [priceBookDict objectForKey:kDataPurgeColumnName];
                NSString *filterCriteria = [NSString stringWithFormat:@"%@ = '%@'",kDataPurgePriceBookColumnName,priceBookId];
                
                array = nil;
                array = [NSArray arrayWithObjects:kDataPurgePriceBookEntry, kDataPurgePriceBookEntryColumnName, filterCriteria, nil];
                
                NSArray *uniqueCurrencyArray = [[SMDataPurgeHelper getUniqueRecordsFromDatabase:array] retain];
                
                
                if([uniqueCurrencyArray count] >0)
                {
                    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXDEVMapUniqueCurrency =  [[self getPriceBookIdMap:uniqueCurrencyArray] retain];
                    SVMXDEVMapUniqueCurrency.value = priceBookId;
                    [mapCurrency.valueMap addObject:SVMXDEVMapUniqueCurrency];
                    currencyPresent = YES;
                    [SVMXDEVMapUniqueCurrency release];
                }
                [uniqueCurrencyArray release];
            }
            
            for(NSDictionary *customPriceBookDict in customPriceBookIds)
            {
                NSString *priceBookId = [customPriceBookDict objectForKey:kDataPurgeColumnName];
                NSString *filterCriteria = [NSString stringWithFormat:@"%@ = '%@'",kDataPurgeCustomPriceBookColumnName,priceBookId];
                
                array = nil;
                array = [NSArray arrayWithObjects:kDataPurgeCustomPriceBookEntry, kDataPurgePriceBookEntryColumnName, filterCriteria, nil];
                
                NSArray *uniqueCurrencyArray = [[SMDataPurgeHelper getUniqueRecordsFromDatabase:array] retain];

                if([uniqueCurrencyArray count] >0)
                {
                    
                    INTF_WebServicesDefServiceSvc_SVMXMap * SVMXDEVMapUniqueCurrency =  [[self getPriceBookIdMap:uniqueCurrencyArray] retain];
                    SVMXDEVMapUniqueCurrency.value = priceBookId;
                    [mapCurrency.valueMap addObject:SVMXDEVMapUniqueCurrency];
                    currencyPresent = YES;
                    [SVMXDEVMapUniqueCurrency release];
                }
                [uniqueCurrencyArray release];
            }
            if(currencyPresent)
                [sfmRequest.valueMap addObject:mapCurrency];
            [mapCurrency release];

        }
        [priceBookIds release];
        [customPriceBookIds release];
    }
    if (self.data != nil && [self.data count] > 0)
       [sfmRequest.values addObjectsFromArray:self.data];
}

-(void)setGeneralParemetersForSFMRequest:(INTF_WebServicesDefServiceSvc_INTF_SFMRequest *)sfmRequest
{
    /* Request General Param Settings */
    sfmRequest.userId    = appDelegate.current_userId;
    sfmRequest.groupId   = appDelegate.organization_Id;
    sfmRequest.profileId = appDelegate.current_userId;
    
    /*  Request Instance Param Settings */
    sfmRequest.eventName = [self getRequestEventName];
    sfmRequest.eventType = [self getEventTypeAsSync];
    sfmRequest.value     = [self getRequestIdentifier];
}

- (INTF_WebServicesDefServiceSvc_INTF_SFMRequest *)getSFMRequest
{
    INTF_WebServicesDefServiceSvc_INTF_SFMRequest * sfmRequest = nil;
    sfmRequest = [[INTF_WebServicesDefServiceSvc_INTF_SFMRequest alloc] init];
    
    if ([self.eventName isEqualToString:kWSDataPurgeEventNameGetPrice])
    {
        [self configureGetPriceParemForSFMRequest:sfmRequest];
    }
    else
    {
       [self configureParamForSFMRequest:sfmRequest];
    }
    
    return  [sfmRequest autorelease];
}


- (INTF_WebServicesDefServiceSvc_SessionHeader *)getSessionHeader
{
    INTF_WebServicesDefServiceSvc_SessionHeader * sessionHeader = nil;
    sessionHeader =[[INTF_WebServicesDefServiceSvc_SessionHeader alloc] init];
    sessionHeader.sessionId = appDelegate.session_Id;
    return [sessionHeader autorelease];
}


- (INTF_WebServicesDefServiceSvc_CallOptions *)getCallOptions
{
    INTF_WebServicesDefServiceSvc_CallOptions * callOptions = nil;
    callOptions = [[INTF_WebServicesDefServiceSvc_CallOptions alloc] init];
    callOptions.client = nil;
    return [callOptions autorelease];
}


- (INTF_WebServicesDefServiceSvc_DebuggingHeader *)getDebuggingHeader
{
    INTF_WebServicesDefServiceSvc_DebuggingHeader * debuggingHeader = nil;
    debuggingHeader = [[INTF_WebServicesDefServiceSvc_DebuggingHeader alloc] init];
    debuggingHeader.debugLevel = 0;
    return [debuggingHeader autorelease];
}


- (INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader *)getFieldTruncationHeader
{
    INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader * allowFieldTruncationHeader = nil;
    allowFieldTruncationHeader = [[INTF_WebServicesDefServiceSvc_AllowFieldTruncationHeader alloc] init];
    allowFieldTruncationHeader.allowFieldTruncation = NO;
    return [allowFieldTruncationHeader autorelease];
}


#pragma mark - INTF_WebServicesDefBindingOperation Delegate Method

- (void) operation:(INTF_WebServicesDefBindingOperation *)operation
completedWithResponse:(INTF_WebServicesDefBindingResponse *)response
{
    /*
     1. According to the operation ?
        Send Response Object for Parsing
        
     2. Parsing Object will Parse entire Response according to the data and create Response Object
        If there are error Object exist It will come Response Object
     
     3. On recieve of response Object Will check whether does it have any error message?
     
     4. If does, It will send request and error to delegare method
     
     5. Otherwise it will send response and request to Delegate.
     
     */
    
    SMDataPurgeResponse *purgeResponse = [[SMDataPurgeResponseParser  parseWSResponse:response
                                                               operationTypeMetaSync:self.isMetaSync] retain];
    
    if ( purgeResponse.hasError )
    {
        if ( (self.requestDelegate != nil)
            && ([self.requestDelegate conformsToProtocol:@protocol(SMDataPurgeRequestDelegate)]))
        {
            [self.requestDelegate request:self failedWithError:purgeResponse.error];
        }
    }
    else
    {
        if ( (self.requestDelegate != nil)
            && ([self.requestDelegate conformsToProtocol:@protocol(SMDataPurgeRequestDelegate)]))
            
        {

            [self.requestDelegate request:self completedWithResponse:purgeResponse];
        }
    }
    
    [purgeResponse release];
}

- (void)dealloc
{
    [requestId release];
    [eventName release];
    [index release];
    [super dealloc];
}


@end
