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
#import "SVMXSystemConstant.h"

@interface TimeLogCacheManager ()

@property (nonatomic, strong) NSMutableDictionary *timeCacheDictionary;
@property (nonatomic, strong) NSMutableDictionary *getPriceTimeCacheDictionary;

@property (nonatomic, strong) NSMutableArray      *logIdTimeCacheArray;
@property (nonatomic, strong) NSMutableArray      *logIdGetPriceTimeCacheArray;

@property (nonatomic, strong) NSMutableArray      *syncRequestTimeCacheIdForFailure;
@property (nonatomic, strong) NSMutableArray      *syncRequestGetPriceTimeCacheIdForFailure;

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

- (void)addEntryToFailureList:(NSString *)requestId
              forCategoryType:(CategoryType)categoryType
{
    if (categoryType == CategoryTypeGetPriceData)
    {
        if (self.syncRequestGetPriceTimeCacheIdForFailure == nil) {
            self.syncRequestGetPriceTimeCacheIdForFailure = [[NSMutableArray alloc] initWithCapacity:0];
        }
        [self.syncRequestGetPriceTimeCacheIdForFailure addObject:requestId];
    }
    else
    {
        if (self.syncRequestTimeCacheIdForFailure == nil) {
            self.syncRequestTimeCacheIdForFailure = [[NSMutableArray alloc] initWithCapacity:0];
        }
        [self.syncRequestTimeCacheIdForFailure addObject:requestId];
    }
}

- (void) clearAllFailureListforCategoryType:(CategoryType)categoryType
{
    if (categoryType == CategoryTypeGetPriceData)
    {
        [self.syncRequestGetPriceTimeCacheIdForFailure removeAllObjects];
        self.syncRequestGetPriceTimeCacheIdForFailure = nil;
    }
    else
    {
        [self.syncRequestTimeCacheIdForFailure removeAllObjects];
        self.syncRequestTimeCacheIdForFailure = nil;
    }
}

- (void) clearAllLogEntryForCategoryType:(CategoryType)categoryType
{
    if (categoryType == CategoryTypeGetPriceData)
    {
        [self.timeCacheDictionary removeAllObjects];
        self.timeCacheDictionary = nil;
        [self.logIdTimeCacheArray removeAllObjects];
        self.logIdTimeCacheArray = nil;
    }
    else
    {
        [self.getPriceTimeCacheDictionary removeAllObjects];
        self.getPriceTimeCacheDictionary = nil;
        [self.logIdGetPriceTimeCacheArray removeAllObjects];
        self.logIdGetPriceTimeCacheArray = nil;
    }
}

#pragma mark - Cache method
- (void) logEntryForSyncResponceTime:(TimeLogModel *)modelObject
                     forCategoryType:(CategoryType)categoryType {
    
    if (modelObject.timeT4 == nil || modelObject.timeT5 == nil ) {
        return;
    }
    
    NSMutableArray *logIdArray = nil;
    NSMutableDictionary *cacheDictionary = nil;
    
    if (categoryType == CategoryTypeGetPriceData)
    {
        if (self.logIdGetPriceTimeCacheArray == nil) {
            self.logIdGetPriceTimeCacheArray = [[NSMutableArray alloc] init];
        }
        if (self.getPriceTimeCacheDictionary == nil) {
            self.getPriceTimeCacheDictionary = [[NSMutableDictionary alloc] init];
        }
        logIdArray = self.logIdGetPriceTimeCacheArray;
        cacheDictionary = self.getPriceTimeCacheDictionary;
    }
    else
    {
        if (self.logIdTimeCacheArray == nil) {
            self.logIdTimeCacheArray = [[NSMutableArray alloc] init];
        }
        if (self.timeCacheDictionary == nil) {
            self.timeCacheDictionary = [[NSMutableDictionary alloc] init];
        }
        logIdArray = self.logIdTimeCacheArray;
        cacheDictionary = self.timeCacheDictionary;
    }
    
    NSMutableDictionary *dictionary = [cacheDictionary objectForKey:modelObject.timeLogIdvalue];
    if (dictionary == nil) {
        
        dictionary = [[NSMutableDictionary alloc] init];
    }
    [dictionary setObject:modelObject.timeT4 forKey:kTimeT4];
    [dictionary setObject:modelObject.timeT5 forKey:kTimeT5];
    [dictionary setObject:modelObject.syncRequestStatus forKey:kTimeLogStatus];
    
    [cacheDictionary setObject:dictionary forKey:modelObject.timeLogIdvalue];
    
    [logIdArray addObject:modelObject.timeLogIdvalue];
}

- (void) deleteLogEntryForId:(NSString *)logId
             forCategoryType:(CategoryType)categoryType
{
    NSMutableArray *logIdArray = nil;
    NSMutableDictionary *cacheDictionary = nil;
    
    if (categoryType == CategoryTypeGetPriceData)
    {
        logIdArray = self.logIdGetPriceTimeCacheArray;
        cacheDictionary = self.getPriceTimeCacheDictionary;
    }
    else
    {
        logIdArray = self.logIdTimeCacheArray;
        cacheDictionary = self.timeCacheDictionary;
    }
    
    NSMutableDictionary *dictionary = [cacheDictionary objectForKey:logId];
    if (dictionary != nil)
    {
        [cacheDictionary removeObjectForKey:logId];
        [logIdArray removeObject:logId];
    }
}

- (NSDictionary *) getLogEntryforCategoryType:(CategoryType)categoryType
{
    NSMutableArray *logIdArray = nil;
    NSMutableDictionary *cacheDictionary = nil;
    
    if (categoryType == CategoryTypeGetPriceData)
    {
        logIdArray = self.logIdGetPriceTimeCacheArray;
        cacheDictionary = self.getPriceTimeCacheDictionary;
    }
    else
    {
        logIdArray = self.logIdTimeCacheArray;
        cacheDictionary = self.timeCacheDictionary;
    }
    
    NSString *logId = [logIdArray lastObject];
    NSMutableDictionary *logIDDict = nil;
    if ([cacheDictionary count] > 0 && logId.length > 0) {
        
        logIDDict = [[NSMutableDictionary alloc] init];
        NSDictionary * tempDict = [cacheDictionary objectForKey:logId];
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

- (NSDictionary *)getAllLogEntryforCategoryType:(CategoryType)categoryType
{
    if (categoryType == CategoryTypeGetPriceData)
    {
        return self.getPriceTimeCacheDictionary;
    }
    else
    {
        return self.timeCacheDictionary;
    }
}

- (BOOL) isCacheEmptyforCategoryType:(CategoryType)categoryType
{
    if (categoryType == CategoryTypeGetPriceData)
    {
        if ([self.getPriceTimeCacheDictionary count] == 0) {
            return YES;
        }
        return NO;
    }
    else
    {
        if ([self.timeCacheDictionary count] == 0) {
            return YES;
        }
        return NO;
    }
}

#pragma mark - Get entry for request parameter
//special request parameters
-(NSArray *) getCompleteLogEntryforCategoryType:(CategoryType)categoryType andCurrentRequestId:(NSString *)currentID
{
    NSMutableArray *logIdArray = nil;
    NSMutableArray *failureIdArray = nil;
    NSMutableDictionary *cacheDictionary = nil;
    
    if (categoryType == CategoryTypeGetPriceData)
    {
        logIdArray = self.logIdGetPriceTimeCacheArray;
        cacheDictionary = self.getPriceTimeCacheDictionary;
        failureIdArray = self.syncRequestGetPriceTimeCacheIdForFailure;
        if (!failureIdArray) {
            failureIdArray = [NSMutableArray array];
        }
        
        [failureIdArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:kSTLGetPriceSyncIdKey]];
        [failureIdArray removeObject:currentID]; // IPAD-4764
    }
    else
    {
        logIdArray = self.logIdTimeCacheArray;
        cacheDictionary = self.timeCacheDictionary;
        failureIdArray = self.syncRequestTimeCacheIdForFailure;
        if (!failureIdArray) {
            failureIdArray = [NSMutableArray array];
        }
        
        [failureIdArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:kSTLMetaDataSyncIdKey]];
        [failureIdArray removeObject:currentID]; // IPAD-4764
    }
    
    NSMutableArray *finalArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSDictionary *attributeValue = [[NSDictionary alloc] initWithObjectsAndKeys:ktimeLogType,kRequestTypeKey , nil];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableDictionary *dictFailure = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    for (NSString *logid in logIdArray) {
        
        NSDictionary *logDict = [cacheDictionary objectForKey:logid];
        NSMutableDictionary *finalValueDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [finalValueDict setObject:attributeValue forKey:kAttributeKey];
        
        //Special request we need to send in format required compatible with salesforce.
        
        //NSDate *dateT4 = [DateUtil dateFromString:[logDict objectForKey:kTimeT4] inFormat:kDateFormatType1];
        // [DateUtil stringFromDate:dateT4 inFormat:kDateFormatType4];
        
        NSString *dateStringT4 = [[logDict objectForKey:kTimeT4] stringByReplacingOccurrencesOfString:@" " withString:@"T"];
        
        //        NSDate *dateT5 =[DateUtil dateFromString:[logDict objectForKey:kTimeT5] inFormat:kDateFormatType1];
        //        NSString *dateStringT5 = [DateUtil stringFromDate:dateT5 inFormat:kDateFormatType4];
        
        NSString *dateStringT5 = [[logDict objectForKey:kTimeT5] stringByReplacingOccurrencesOfString:@" " withString:@"T"];
        
        
        [finalValueDict setObject:dateStringT4 forKey:kTimeLogClientReceivingTimeStamp];
        [finalValueDict setObject:dateStringT5 forKey:kTimeLogClientProcessingTimeStamp];
        [finalValueDict setObject:[logDict objectForKey:kTimeLogStatus] forKey:kTimeLogStatus];
        [finalValueDict setObject:logid forKey:kId];
        
        [finalArray addObject:finalValueDict];
    }
    if ([finalArray count] > 0) {
        
        [dict setObject:kTimeLogRequestID forKey:kSVMXRequestKey];
        NSString *jsonString = [self jsonStringForArray:finalArray WithPrettyPrint:YES];
        [dict setObject:jsonString forKey:kSVMXRequestValue];
        
        if ([failureIdArray count] > 0) {
            
            [dictFailure setObject:kTimeLogFailureID forKey:kSVMXRequestKey];
            // NSString *jsonArray = [self jsonStringForArray:self.syncRequestTimeCacheIdForFailure WithPrettyPrint:YES];
            [dictFailure setObject:failureIdArray forKey:kSVMXRequestValues];
        }
        if ([dictFailure count] > 0) {
            return @[dict,dictFailure];
        }
        
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
        SXLogError(@"json error: %@", error.localizedDescription);
        return @"[]";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}


/**
 * @name  title
 *
 * @author Chinnababu k
 *
 * @brief
 *
 * \par
 *  <Longer description starts here>
 *  Adding t1,t4,t5,logID,category to the request
 *
 *
 *
 * @return void
 *
 */

- (NSArray *)getRequestParameterForTimeLogWithCategory:(NSString *)category
                                       forCategoryType:(CategoryType)categoryType
{
    //T1 - time.
    NSString *timeT1 = [DateUtil gmtStringFromDate:[NSDate date] inFormat:kDateFormatType1];
    //[DateUtil stringFromDate:[NSDate date] inFormat:kDateFormatType1];
    
    //key - t1 value - t1 timestamp
    NSDictionary *t1 = @{kSVMXRequestKey:kTimeT1, kSVMXRequestValue:timeT1};
    NSDictionary *context = @{kSVMXRequestKey:kSVMXContextKey, kSVMXRequestValue:category};
    
    //t4 + t5
    NSDictionary *dictForRequestParameter = [self getLogEntryforCategoryType:categoryType];
    
    NSDictionary *t45Dict = nil;
    
    if (dictForRequestParameter != nil) {
        
        NSString *logId = (dictForRequestParameter.count > 0) ? [[dictForRequestParameter allKeys] lastObject] : nil;
        
        
        NSArray * internalValues = [dictForRequestParameter objectForKey:logId];
        
        if (internalValues && [internalValues count]) {
            t45Dict = @{kSVMXRequestKey:kTimeLogId, kSVMXRequestValue:(logId) ? logId:kEmptyString,
                        kSVMXRequestSVMXMap:internalValues?internalValues:@[]};
        }
        if (logId == nil) {
            t45Dict = nil;
        }
        else {
            [self deleteLogEntryForId:logId forCategoryType:categoryType];
        }
        
    }
    NSArray *result = nil;
    if (t45Dict) {
        result = @[context,t1,t45Dict];
        
        NSDictionary *dict = @{kSVMXRequestKey:kTimeLogKey,kSVMXRequestSVMXMap:result};
        
        //if t4 and t5 value is present in cache we are sending as part of request along with t1, category type and logId
        result =@[dict];
        
    } else {
        NSArray *array = @[t1,context];
        NSDictionary *dict = @{kSVMXRequestKey:kTimeLogKey,
                               kSVMXRequestSVMXMap:array};
        
        //if t4 and t5 value is not present in cache : t1, category type and logId
        result =@[dict];
    }
    return result;
}


@end
