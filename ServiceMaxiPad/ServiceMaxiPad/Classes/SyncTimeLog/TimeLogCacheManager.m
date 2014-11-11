//
//  TimeLogCacheManager.m
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 28/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "TimeLogCacheManager.h"
#import "DateUtil.h"
#import "RequestConstants.h"
#import "ResponseConstants.h"

@interface TimeLogCacheManager ()

@property (nonatomic, strong) NSMutableDictionary *timeCacheDictionary;
@property (nonatomic, strong) NSMutableArray      *logIdArray;

@end

@implementation TimeLogCacheManager

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
    return self;
}
#pragma mark - Memory management
- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
#pragma mark - Cache method
- (void) logEntryForSyncResponceTime:(TimeLogModel *)modelObject {
    
    if (modelObject.timeT4 == nil || modelObject.timeT5 == nil ) {
        return;
    }
    if (self.logIdArray == nil) {
        self.logIdArray = [[NSMutableArray alloc] init];
    }
    if (self.timeCacheDictionary == nil) {
        self.timeCacheDictionary = [[NSMutableDictionary alloc] init];
    }
    
    NSMutableDictionary *dictionary = [self.timeCacheDictionary objectForKey:modelObject.timeLogIdvalue]; //if anything is available already
    if (dictionary == nil) {
        
        dictionary = [[NSMutableDictionary alloc] init];
    }
    [dictionary setObject:modelObject.timeT4 forKey:kTimeT4];
    [dictionary setObject:modelObject.timeT5 forKey:kTimeT5];
    [dictionary setObject:modelObject.syncRequestStatus forKey:kTimeLogStatus];
    
    [self.timeCacheDictionary setObject:dictionary forKey:modelObject.timeLogIdvalue];
    
    [self.logIdArray addObject:modelObject.timeLogIdvalue];
}
- (void) deleteLogEntryForId:(NSString *)logId {
    
    NSMutableDictionary *dictionary = [self.timeCacheDictionary objectForKey:logId];
    if (dictionary != nil) {
        [self.timeCacheDictionary removeObjectForKey:logId];
        [self.logIdArray removeObject:logId];
    }
}
- (NSDictionary *) getLogEntry {
    
    NSString *logId = [self.logIdArray lastObject];
    NSMutableDictionary *logIDDict = nil;
    if ([self.timeCacheDictionary count] > 0 && logId.length > 0) {
        
        logIDDict = [[NSMutableDictionary alloc] init];
        NSDictionary * tempDict = [self.timeCacheDictionary objectForKey:logId];
        NSString * t4TimeStamp  = [tempDict objectForKey:kTimeT4];
        NSString * t5TimeStamp  = [tempDict objectForKey:kTimeT5];

        NSMutableDictionary * t4Dict = [[NSMutableDictionary alloc] init];
        [t4Dict setObject:kTimeT4 forKey:kSVMXRequestKey];
        [t4Dict setObject:t4TimeStamp forKey:kSVMXRequestValue];
        
        NSMutableDictionary * t5Dict = [[NSMutableDictionary alloc] init];
        [t5Dict setObject:kTimeT5 forKey:kSVMXRequestKey];
        [t5Dict setObject:t5TimeStamp forKey:kSVMXRequestValue];

        [logIDDict setValue:@[t4Dict,t5Dict] forKey:logId];
    }
    return logIDDict;
}
- (NSDictionary *) getAllLogEntry {
    return self.timeCacheDictionary;
}
- (BOOL) isCacheEmpty {
    if ([self.timeCacheDictionary count] == 0) {
        return YES;
    }
    return NO;
}
#pragma mark - Get entry for request parameter
//Every request
- (NSArray *)getRequestParameterForLogging
{
    //T1 - time.
    NSString *timeT1 = [DateUtil getDatabaseStringForDate:[NSDate date]];
    
    //key - t1 value - t1 timestamp
    NSMutableDictionary *t1Dict = [[NSMutableDictionary alloc] init];
    [t1Dict setObject:kTimeT1 forKey:kSVMXRequestKey];
    [t1Dict setObject:timeT1 forKey:kSVMXRequestValue];
    
    //t4 + t5
    NSDictionary *dictForRequestParameter = [self getLogEntry];
    NSMutableDictionary *t45Dict = nil;
    
    if (dictForRequestParameter != nil) {
        
        t45Dict = [[NSMutableDictionary alloc] init];
        //key = logid value - Logid
        NSString *logId = (dictForRequestParameter.count > 0) ? [[dictForRequestParameter allKeys] lastObject] : nil;
        
        NSArray * internalValues = [dictForRequestParameter objectForKey:logId];
        [t45Dict setObject:kTimeLogId forKey:kSVMXRequestKey];
        [t45Dict setObject:logId forKey:kSVMXRequestValue];
        
        //t4 + t5
        if(internalValues != nil)
        {
            [t45Dict setObject:internalValues forKey:kSVMXRequestSVMXMap];
        }
        if (logId == nil) {
            t45Dict = nil;
        }
        else {
            [self deleteLogEntryForId:logId];
        }
    }
    
    //for first time t4 and t5 will be nil, so send only t1.
    if (t45Dict == nil) {
        return @[t1Dict];
    }
    
    return  @[t1Dict,t45Dict];
}
//special request parameters
-(NSArray *) getCompleteLogEntry {
    
    NSMutableArray *finalArray = [[NSMutableArray alloc]init];
    
    NSDictionary *attributeValue = [[NSDictionary alloc]initWithObjectsAndKeys:ktimeLogType,kRequestTypeKey , nil];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (NSString *logid in self.logIdArray) {
        
        NSDictionary *logDict = [self.timeCacheDictionary objectForKey:logid];
        
        NSMutableDictionary *finalValueDict = [[NSMutableDictionary alloc] init];
        
        [finalValueDict setObject:attributeValue forKey:kAttributeKey];
        [finalValueDict setObject:[logDict objectForKey:kTimeT4] forKey:kTimeLogClientReceivingTimeStamp];
        [finalValueDict setObject:[logDict objectForKey:kTimeT5] forKey:kTimeLogClientProcessingTimeStamp];
        [finalValueDict setObject:[logDict objectForKey:kTimeLogStatus] forKey:kTimeLogStatus];
        [finalValueDict setObject:logid forKey:kId];
        
        [finalArray addObject:finalValueDict];
    }
    if ([finalArray count] > 0) {
        
        [dict setObject:kTimeLogRequestID forKey:kSVMXRequestKey];
        NSString *jsonString = [self jsonStringForArray:finalArray WithPrettyPrint:YES];
        [dict setObject:jsonString forKey:kSVMXRequestValue];
        return @[dict];
    }
    return nil;
}
-(NSString*) jsonStringForArray:(NSArray *)array WithPrettyPrint:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array
                                                       options:(NSJSONWritingOptions) (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"json error: %@", error.localizedDescription);
        return @"[]";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
@end
