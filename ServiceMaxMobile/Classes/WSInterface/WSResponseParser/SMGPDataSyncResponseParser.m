//
//  SMGPDataSyncResponseParser.m
//  iService
//
//  Created by Siva Manne on 30/01/13.
//
//

#import "SMGPDataSyncResponseParser.h"
#import "INTF_WebServicesDefServiceSvc.h"
#import "databaseIntefaceSfm.h"

@implementation SMGPDataSyncResponseParser
@synthesize recordIDs;
@synthesize lastIndex;

//Anish: Fix for a potential crash when the object is deallocated  (iOS7)
- (id)init
{
    if (self = [super init])
    {
		self.recordIDs = nil;
        self.lastIndex = nil;
    }
    return self;
    
}

- (BOOL) parseResponse:(NSArray *)result
{
    BOOL callBack = FALSE;
    for(int i=0; i<[result count]; i++)
    {
        INTF_WebServicesDefServiceSvc_SVMXMap * svmxMapObject = [result objectAtIndex:i];
        NSString *key = svmxMapObject.key;
        if([key isEqualToString:@"PRICING_DATA"])
        {
            switch ([svmxMapObject.value intValue])
            {
                case 1:
                    SMLog(kLogLevelVerbose,@"Call One");
                    callBack = [self processFirstCallResponse:svmxMapObject];
                    break;
                case 2:
                    SMLog(kLogLevelVerbose,@"Call Two");
                    if ([svmxMapObject.values count]) 
                    {
                        /*Mem Opt*/
                        if (recordIDs)
                        {
                            [recordIDs release];
                            recordIDs = nil;
                        }
                        
                        recordIDs = [[NSMutableArray alloc] init];
                        NSArray *objectsList = [svmxMapObject.values retain];
                        [recordIDs insertObject:objectsList atIndex:0];
                        /*Mem Opt*/
                        [objectsList release];

                    }
                    callBack = [self processSecondCallResponse:svmxMapObject];
                    if([recordIDs count])
                        callBack = TRUE;
                    break;
                case 3:
                    SMLog(kLogLevelVerbose,@"Call Three");
                    if ([svmxMapObject.values count])
                    {
                        /*Mem Opt*/
                        if (recordIDs)
                        {
                            [recordIDs release];
                            recordIDs = nil;
                        }
                        recordIDs = [[NSMutableArray alloc] init];
                        NSArray *objectsList = [svmxMapObject.values retain];
                        [recordIDs insertObject:objectsList atIndex:0];
                        /*Mem Opt*/
                        [objectsList release];

                    }
                    callBack = [self processThirdCallResponse:svmxMapObject];
                    break;                    
                default:
                    break;
            }
        }
    }
    return callBack;
}
- (BOOL) processFirstCallResponse:(INTF_WebServicesDefServiceSvc_SVMXMap * )svmxMapObject
{
    
    BOOL isWOCountZero = FALSE;
    BOOL callback = FALSE;
    SBJsonParser * jsonParser = [[[SBJsonParser alloc] init] autorelease];
    NSAutoreleasePool *iPool = [[NSAutoreleasePool alloc] init];
    NSArray *valueMapArray = [svmxMapObject valueMap];
    NSMutableDictionary *GPDataDict = [[NSMutableDictionary alloc] init];
    for(int j=0; j<[valueMapArray count]; j++)
    {
        INTF_WebServicesDefServiceSvc_SVMXMap * svmxGPObject = [valueMapArray objectAtIndex:j];
        NSString *key = svmxGPObject.key;
        if([key isEqualToString:@"CALL_BACK"])
        {
            callback = [svmxGPObject.value boolValue];
        }
        else if([key isEqualToString:@"LAST_INDEX"])
        {
            if(lastIndex != svmxGPObject.value)
            {
                [lastIndex release];
                lastIndex = [svmxGPObject.value retain];
            }
            SMLog(kLogLevelVerbose,@"LAST_INDEX Values = %@",lastIndex);
        }
        else if([key isEqualToString:@"SVMXC__Service_Order__c"])
        {
            NSString *jsonRecord = svmxGPObject.value;
            if(jsonRecord)
            {
                NSArray * json_array = [jsonParser objectWithString:jsonRecord];
                if(json_array && [json_array count])
                {
                    SMLog(kLogLevelVerbose,@"WO Values = %@",json_array);
                    if(recordIDs != json_array)
                    {
                        [recordIDs release];
                        recordIDs = [json_array retain];
                    }
                }
                else
                {
                    isWOCountZero = TRUE;
                }
            }
        }
        else
        {
            NSString *jsonRecord = svmxGPObject.value;
            if(jsonRecord)
            {
                NSArray * json_array = [jsonParser objectWithString:jsonRecord];
                if(json_array && [json_array count])
                {
                    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
                    for(int k=0; k<[json_array count]; k++)
                    {
                        NSString *obj = [json_array objectAtIndex:k];
                        if(((NSNull *) obj != [NSNull null]))
                        {
                            NSAutoreleasePool *kPool = [[NSAutoreleasePool alloc] init];
                            NSDictionary *dict = [[self getSyncRecordHeapDictForSFID:obj withSyncType:@"DATA_SYNC"] retain];                            
                            [dataArray addObject:dict];
                            [dict release];
                            [kPool drain];
                        }
                    }
                    if([dataArray count])
                        [GPDataDict setObject:dataArray forKey:key];
                    [dataArray release];
                }
            }
        }
    }
    if([[GPDataDict allKeys] count])
    {
        SMLog(kLogLevelVerbose,@"Dict = %@",GPDataDict);
        [self.dataBaseInterface insertRecordIdsIntosyncRecordHeap:GPDataDict];
    }
    [GPDataDict release];
    [iPool drain];
    if(callback && !isWOCountZero)
    {
        callback = TRUE;
    }
    else
    {
        callback = FALSE;
    }
    return callback;
}
- (BOOL) processSecondCallResponse:(INTF_WebServicesDefServiceSvc_SVMXMap * )svmxMapObject
{
    BOOL callback = FALSE;
    SBJsonParser * jsonParser = [[[SBJsonParser alloc] init] autorelease];
    NSAutoreleasePool *iPool = [[NSAutoreleasePool alloc] init];
    NSArray *valueMapArray = [svmxMapObject valueMap];
    NSMutableDictionary *GPDataDict = [[NSMutableDictionary alloc] init];
    for(int j=0; j<[valueMapArray count]; j++)
    {
        INTF_WebServicesDefServiceSvc_SVMXMap * svmxGPObject = [valueMapArray objectAtIndex:j];
        NSString *key = svmxGPObject.key;
        if([key isEqualToString:@"CALL_BACK"])
        {
            callback = [svmxGPObject.value boolValue];
        }
        else if([key isEqualToString:@"LAST_INDEX"])
        {
            if(lastIndex != svmxGPObject.value)
            {
                [lastIndex release];
                lastIndex = [svmxGPObject.value retain];
            }
            SMLog(kLogLevelVerbose,@"LAST_INDEX Values = %@",lastIndex);
        }
        else if([key isEqualToString:@"PARTIAL_EXECUTED_OBJECT"])
        {
            NSString *partialObject = svmxGPObject.value;
            if(partialObject != nil)
            {
                NSDictionary *partialObjectDict = [NSDictionary dictionaryWithObject:partialObject forKey:@"partialObject"];
                [recordIDs insertObject:partialObjectDict atIndex:1];
            }
        }
        else
        {
            NSArray *valueMapGPArray = [svmxGPObject valueMap];
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            for(int k=0; k<[valueMapGPArray count]; k++)
            {
                INTF_WebServicesDefServiceSvc_SVMXMap * svmxGPObjectMap = [valueMapGPArray objectAtIndex:k];
                NSString *jsonRecord = svmxGPObjectMap.value;
                NSDictionary * json_Dict = [jsonParser objectWithString:jsonRecord];
                if(json_Dict)
                {
                    NSString *obj = [json_Dict objectForKey:@"Id"];
                    if(((NSNull *) obj != [NSNull null]))
                    {
                        
                        NSAutoreleasePool *kPool = [[NSAutoreleasePool alloc] init];
                        NSDictionary *dict = [[self getSyncRecordHeapDictForSFID:obj withSyncType:@"DATA_SYNC"] retain];
                        [dataArray addObject:dict];
                        [dict release];
                        [kPool drain];
                    }
                }
            }
            if([dataArray count])
                [GPDataDict setObject:dataArray forKey:key];
            [dataArray release];
        }
    }
    if([[GPDataDict allKeys] count])
    {
        SMLog(kLogLevelVerbose,@"Dict = %@",GPDataDict);
        [self.dataBaseInterface insertRecordIdsIntosyncRecordHeap:GPDataDict];
    }
    [GPDataDict release];
    [iPool drain];
    return callback;

}
- (BOOL) processThirdCallResponse:(INTF_WebServicesDefServiceSvc_SVMXMap * )svmxMapObject
{
    BOOL callback = FALSE;
    SBJsonParser * jsonParser = [[[SBJsonParser alloc] init] autorelease];
    NSAutoreleasePool *iPool = [[NSAutoreleasePool alloc] init];
    NSArray *valueMapArray = [svmxMapObject valueMap];
    NSMutableDictionary *GPDataDict = [[NSMutableDictionary alloc] init];
    for(int j=0; j<[valueMapArray count]; j++)
    {
        INTF_WebServicesDefServiceSvc_SVMXMap * svmxGPObject = [valueMapArray objectAtIndex:j];
        NSString *key = svmxGPObject.key;
        if([key isEqualToString:@"CALL_BACK"])
        {
            callback = [svmxGPObject.value boolValue];
        }
        else if([key isEqualToString:@"LAST_INDEX"])
        {
            if(lastIndex != svmxGPObject.value)
            {
                [lastIndex release];
                lastIndex = [svmxGPObject.value retain];
            }
            SMLog(kLogLevelVerbose,@"LAST_INDEX Values = %@",lastIndex);
        }
        else if([key isEqualToString:@"PARTIAL_EXECUTED_OBJECT"])
        {
            NSString *partialObject = svmxGPObject.value;
            if(partialObject != nil)
            {
                NSDictionary *partialObjectDict = [NSDictionary dictionaryWithObject:partialObject forKey:@"partialObject"];
                [recordIDs insertObject:partialObjectDict atIndex:1];
            }
        }
        else
        {
            NSArray *valueMapGPArray = [svmxGPObject valueMap];
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            for(int k=0; k<[valueMapGPArray count]; k++)
            {
                INTF_WebServicesDefServiceSvc_SVMXMap * svmxGPObjectMap = [valueMapGPArray objectAtIndex:k];
                NSString *jsonRecord = svmxGPObjectMap.value;
                NSDictionary * json_Dict = [jsonParser objectWithString:jsonRecord];
                if(json_Dict)
                {
                    NSString *obj = [json_Dict objectForKey:@"Id"];
                    if(((NSNull *) obj != [NSNull null]))
                    {
                        
                        NSAutoreleasePool *kPool = [[NSAutoreleasePool alloc] init];
                        NSDictionary *dict = [[self getSyncRecordHeapDictForSFID:obj withSyncType:@"DATA_SYNC"] retain];
                        [dataArray addObject:dict];
                        [dict release];
                        [kPool drain];
                    }
                }
            }
            if([dataArray count])
                [GPDataDict setObject:dataArray forKey:key];
            [dataArray release];
        }
    }
    if([[GPDataDict allKeys] count])
    {
        SMLog(kLogLevelVerbose,@"Dict = %@",GPDataDict);
        [self.dataBaseInterface insertRecordIdsIntosyncRecordHeap:GPDataDict];
    }
    [GPDataDict release];
    [iPool drain];
    return callback;

}
- (id) getRequiredData:(NSString *)key
{
    if([key isEqualToString:@"LAST_INDEX"])
        return lastIndex;
    if([key isEqualToString:@"RecordIds"])
        return recordIDs;
    return nil;
}
- (NSDictionary *) getSyncRecordHeapDictForSFID:(NSString *)sfId withSyncType:(NSString *)syncType
{
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    [dataDict setObject:@"MASTER" forKey:@"RECORD_TYPE"];
    [dataDict setObject:sfId forKey:@"SF_ID"];
    [dataDict setObject:syncType forKey:@"SYNC_TYPE"];
    return [dataDict autorelease];
}


- (void)dealloc
{
    //Anish: Fix for a potential crash when the object is deallocated (iOS7)
    /*Mem Opt*/
    if(recordIDs)
    {
        [recordIDs release];
        recordIDs = nil;
    }

    if(lastIndex)
    {
        [lastIndex release];
        lastIndex = nil;

    }
    //end
    
    [super dealloc];
}
@end