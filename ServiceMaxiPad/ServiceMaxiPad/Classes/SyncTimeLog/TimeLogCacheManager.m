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
//special request parameters
-(NSArray *) getCompleteLogEntry {
    
    NSMutableArray *finalArray = [[NSMutableArray alloc]init];
    
    NSDictionary *attributeValue = [[NSDictionary alloc]initWithObjectsAndKeys:ktimeLogType,kRequestTypeKey , nil];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (NSString *logid in self.logIdArray) {
        
        NSDictionary *logDict = [self.timeCacheDictionary objectForKey:logid];
        
        NSMutableDictionary *finalValueDict = [[NSMutableDictionary alloc] init];
        
        [finalValueDict setObject:attributeValue forKey:kAttributeKey];
        
        //Special request we need to send in format required compatible with salesforce.
        
        NSDate *dateT4 = [DateUtil dateFromString:[logDict objectForKey:kTimeT4] inFormat:kDateFormatType1];
        NSString *dateStringT4 = [DateUtil stringFromDate:dateT4 inFormat:kDateFormatDefault];
        
        NSDate *dateT5 =[DateUtil dateFromString:[logDict objectForKey:kTimeT5] inFormat:kDateFormatType1];
        NSString *dateStringT5 = [DateUtil stringFromDate:dateT5 inFormat:kDateFormatDefault];

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
{
    //T1 - time.
    NSString *timeT1 = [DateUtil stringFromDate:[NSDate date] inFormat:kDateFormatType1];

    //key - t1 value - t1 timestamp
    NSDictionary *t1 = @{kSVMXRequestKey:kTimeT1, kSVMXRequestValue:timeT1};
    NSDictionary *context = @{kSVMXRequestKey:kSVMXContextKey, kSVMXRequestValue:category};

    //t4 + t5
    NSDictionary *dictForRequestParameter = [self getLogEntry];
    
    NSDictionary *t45Dict = nil;
    
    if (dictForRequestParameter != nil) {
        
        NSString *logId = (dictForRequestParameter.count > 0) ? [[dictForRequestParameter allKeys] lastObject] : nil;
      
        
        NSArray * internalValues = [dictForRequestParameter objectForKey:logId];
        
        if (internalValues && [internalValues count]) {
             t45Dict = @{kSVMXRequestKey:kTimeLogId, kSVMXRequestValue:logId,kSVMXRequestSVMXMap:internalValues};
        }
        if (logId == nil) {
            t45Dict = nil;
        }
        else {
            [self deleteLogEntryForId:logId];
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
