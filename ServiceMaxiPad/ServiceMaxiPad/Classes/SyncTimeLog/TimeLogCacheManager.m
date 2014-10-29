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

NSString *const kT4 = @"SVMX_LOG_T4";
NSString *const kT5 = @"SVMX_LOG_T5";

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

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
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
    [dictionary setObject:modelObject.timeT4 forKey:kT4];
    [dictionary setObject:modelObject.timeT5 forKey:kT5];
    
    [self.timeCacheDictionary setObject:dictionary forKey:modelObject.timeLogIdvalue];
    
    NSLog(@"Items in the cache %@",self.timeCacheDictionary);
    [self.logIdArray addObject:modelObject.timeLogIdvalue];
}

- (void) deleteLogEntryForId:(NSString *)logId {
    
    NSMutableDictionary *dictionary = [self.timeCacheDictionary objectForKey:logId];
    if (dictionary != nil) {
        NSLog(@"Deleted dict for id %@",logId);
        [self.timeCacheDictionary removeObjectForKey:logId];
    }
}
- (NSDictionary *) getLogEntry {
    
    NSString *logId = [self.logIdArray lastObject];
    NSMutableDictionary *logIDDict = nil;
    if ([self.timeCacheDictionary count] > 0 && logId.length > 0) {
        
        logIDDict = [[NSMutableDictionary alloc] init];
        NSDictionary * tempDict = [self.timeCacheDictionary objectForKey:logId];
        NSString * t4TimeStamp  = [tempDict objectForKey:kT4];
        NSString * t5TimeStamp  = [tempDict objectForKey:kT5];

        NSMutableDictionary * t4Dict = [[NSMutableDictionary alloc] init];
        [t4Dict setObject:kT4 forKey:kSVMXRequestKey];
        [t4Dict setObject:t4TimeStamp forKey:kSVMXRequestValue];
        
        NSMutableDictionary * t5Dict = [[NSMutableDictionary alloc] init];
        [t5Dict setObject:kT5 forKey:kSVMXRequestKey];
        [t5Dict setObject:t5TimeStamp forKey:kSVMXRequestValue];

        [logIDDict setValue:@[t4Dict,t5Dict] forKey:logId];
    }
    NSLog(@"Requested Value %@",logIDDict);
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
@end
