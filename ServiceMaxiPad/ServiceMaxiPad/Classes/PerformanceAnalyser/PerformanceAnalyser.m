//
//  PerformanceAnalyser.m
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 19/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "PerformanceAnalyser.h"
#import "AppMetaData.h"
#import "CustomerOrgInfo.h"
#import "FileManager.h"
#import "StringUtil.h"

@interface PerformanceAnalyser() {
    float totalNetworkLatency;
    float totalParsingLatency;
    float totalDBOperation;
    float totalDBOperationLatency;
    float networkLatencyRecordCount;
    float parseLatencyRecordCount;
    float totalTimeTakenForFlow;
}


@end

@implementation PerformanceAnalyser

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
}

#pragma mark - Public methods

- (void) startPerformanceAnalyser {
    
    self.startedPerformanceAnalyser = YES;
    
}
- (void) stopPerformanceAnalyser {

    self.startedPerformanceAnalyser = NO;
}
-(BOOL)isNumeric:(NSString*)inputString{
   
    BOOL isValid = NO;
    
    if (inputString.length == 0) {
        return isValid;
    }
    
    NSCharacterSet *alphaNumbersSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:inputString];
    isValid = [alphaNumbersSet isSupersetOfSet:stringSet];
    return isValid;
}
- (BOOL) valueExistsForString:(NSString *)string {

    PerformanceAnalyserModel *analyser = [self.completedAnalytics objectForKey:string];
    if (analyser!=nil) {
        return YES;
    }
    return NO;
    
}
- (NSString *) getSubContextNameForContext:(NSString *)contextName SubContext:(NSString *)subContext forOperationTYpe:(PAOperationType)operationType {
   
    PerformanceAnalyserModel *analyser = [self.completedAnalytics objectForKey:subContext];
    
    @autoreleasepool {
        
        if ([StringUtil containsString:subContext inString:analyser.subContextName]) {
            
            int integerValue = 0;
            
            while ([self valueExistsForString:subContext]) {
                
                if (integerValue == 0) {
                    subContext = [subContext stringByAppendingFormat:@"/%d",integerValue];
                    integerValue ++;
                }
                else {
                    NSString *integerStr1 = [[subContext componentsSeparatedByString:@"/"] lastObject];
                    
                    integerValue = [self isNumeric:integerStr1] ? [integerStr1 intValue] : 0;
                    
                    subContext = [subContext stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%d",integerValue] withString:[NSString stringWithFormat:@"/%d",integerValue+1]];
                    integerValue ++;
                    
                }
                
            }
            
        }
         return subContext;
    }
    
}

- (void)observePerformanceForContext:(NSString *)contextName
                      subContextName:(NSString *)subContextName
                       operationType:(PAOperationType)operationType
                      andRecordCount:(int)recordCount
{
    if (!self.startedPerformanceAnalyser || subContextName == nil) {
        return;
    }
    @synchronized([self class])
    {
        if (self.nonCompletedAnalytics == nil) {
            self.nonCompletedAnalytics = [[NSMutableDictionary alloc] init];
        }
        PerformanceAnalyserModel *analyser = [[PerformanceAnalyserModel alloc] init];
        analyser.contextName = contextName;
        if (operationType == PAOperationTypeParsing) {
            analyser.recordCountForParsing = [NSNumber numberWithInt:recordCount];
        }
        else if(operationType == PAOperationTypeDBOperation) {
            analyser.dbOperationRecordCount = [NSNumber numberWithInt:recordCount];
        }
        analyser.recordCount = [NSNumber numberWithInt:recordCount];
        analyser.subContextName = subContextName;
        analyser.operationType = operationType;
        analyser.startTime = CFAbsoluteTimeGetCurrent();
        [self.nonCompletedAnalytics setObject:analyser forKey:subContextName];
    }
}

- (void)ObservePerformanceCompletionForContext:(NSString *)contextName
                                subContextName:(NSString *)subContextName
                                 operationType:(PAOperationType)operationType
                                andRecordCount:(int)recordCount
{
    
    if (!self.startedPerformanceAnalyser) {
        return;
    }
    @synchronized([self class])
    {
        @autoreleasepool
        {
            for (int i=0; i<[self.nonCompletedAnalytics count] ; i++) {
              
                PerformanceAnalyserModel *analyserModel = [self.nonCompletedAnalytics objectForKey:subContextName];
                
                if (analyserModel == nil) {
                    
                    return;
                }
                else if (analyserModel.startTime < 0.0) {
                    return;
                }
                else {
                    analyserModel.endTime = CFAbsoluteTimeGetCurrent();
                }
                if (self.completedAnalytics == nil) {
                    self.completedAnalytics = [[NSMutableDictionary alloc] init];
                }
                
                int recordValue = [analyserModel.recordCount intValue] + recordCount;
                analyserModel.recordCount = [NSNumber numberWithInt:recordValue];
                
                CFTimeInterval difference = analyserModel.endTime - analyserModel.startTime;
                
                if (operationType == PAOperationTypeNetworkLatency) {
                    
                    analyserModel.networkLatencyTime = [NSString stringWithFormat:@"%f",difference];
                    networkLatencyRecordCount += [analyserModel.recordCount floatValue];
                    totalNetworkLatency += [analyserModel.networkLatencyTime floatValue];
                    
                }
                else if (operationType == PAOperationTypeParsing) {
                    analyserModel.parsingTime = [NSString stringWithFormat:@"%f",difference];
                    parseLatencyRecordCount += [analyserModel.recordCountForParsing floatValue];
                    totalParsingLatency += [analyserModel.parsingTime floatValue];
                    
                }
                else if (operationType == PAOperationTypeDBOperation) {
                    
                    analyserModel.dbOperationTime = [NSString stringWithFormat:@"%f",difference];
                    
                    totalDBOperationLatency += [analyserModel.dbOperationTime floatValue];
                    
                    float dboperationCount = [analyserModel.dbOperationRecordCount floatValue];
                    
                    totalDBOperation += ( dboperationCount + recordCount );
                    
                    analyserModel.dbOperationRecordCount = [NSNumber numberWithFloat:( dboperationCount + recordCount )];
                    
                }
                else if (operationType == PAOperationTypeTotalTimeLatency) {
                    totalTimeTakenForFlow = difference;
                    
                    [[PerformanceAnalyser sharedInstance] generatePerformanceAnalysisReportForContextName:analyserModel.contextName];
                    
                    if ([self.completedAnalytics count]) {
                        [self clearAllData];
                    }
                }
                else {
                    analyserModel.algorithTime = [NSString stringWithFormat:@"%f",difference];
                }
                [self.completedAnalytics setObject:analyserModel forKey:subContextName];
                [self.nonCompletedAnalytics removeObjectForKey:subContextName];
            }
        }
    }
}
- (void) clearDataForContext:(NSString *)context {
    
    if ([context isEqualToString:@"--"]) {
        [self.nonCompletedAnalytics removeObjectForKey:context];
    }
    else {
        [self.nonCompletedAnalytics removeObjectForKey:context];
        [self.completedAnalytics removeObjectForKey:context];
    }
}
- (void) clearAllData {
    
    [self.completedAnalytics removeAllObjects]; self.completedAnalytics = nil;
    [self.nonCompletedAnalytics removeAllObjects]; self.nonCompletedAnalytics = nil;
    totalNetworkLatency = 0;
    totalParsingLatency = 0;
    networkLatencyRecordCount = 0;
    parseLatencyRecordCount = 0;
    totalTimeTakenForFlow = 0;
    totalDBOperation = 0;
    totalDBOperationLatency = 0;
}
- (NSString *) getStringFromStringArray:(NSArray *)stringArray {
    
    NSMutableString *string = [[NSMutableString alloc] init];
    for (int i=0; i < [stringArray count] - 1; i++) {
        [string appendString:stringArray[i]];
    }
    return string;
}
- (NSDictionary *) getFormattedAnalytics:(NSString *)context {
    
    NSMutableDictionary *maindict = [[NSMutableDictionary alloc] init];
    NSArray *keys = [self.completedAnalytics allKeys];
    
    for (NSString *subContext in keys) {
        
        PerformanceAnalyserModel *model = [self.completedAnalytics objectForKey:subContext];
        
        NSArray *subArray = [subContext componentsSeparatedByString:@"/"];
        NSString *sub = @"";
        if ([subArray count] > 2) {
            sub = [self getStringFromStringArray:subArray];
        }
        else {
            sub = [subArray objectAtIndex:0];
        }
        
        NSMutableDictionary *dictionary = [maindict objectForKey:sub];
        if (dictionary == nil) {
            dictionary = [[NSMutableDictionary alloc] init];
        }
        
        if (model.operationType == PAOperationTypeParsing) {
            
            NSString *parseLatency = [self getPaddedStringWithLength:40 forString:@"Parse time"];
            if ([dictionary objectForKey:parseLatency]) {
                
                float value = [[dictionary objectForKey:parseLatency] floatValue] + [model.parsingTime floatValue];
                NSString *valueStr = [NSString stringWithFormat:@"%f",value];
                [dictionary setObject:valueStr forKey:parseLatency];
            }
            else {
                [dictionary setObject:model.parsingTime forKey:parseLatency];
            }
        }
        else if (model.operationType == PAOperationTypeNetworkLatency) {
            
            NSString *networkLatency = [self getPaddedStringWithLength:40 forString:@"Network Latency"];
            if ([dictionary objectForKey:networkLatency]) {
                
                float value = [[dictionary objectForKey:networkLatency] floatValue] + [model.networkLatencyTime floatValue];
                NSString *valueStr = [NSString stringWithFormat:@"%f",value];
                [dictionary setObject:valueStr forKey:networkLatency];
            }
            else {
                if (model.networkLatencyTime && networkLatency) {
                    [dictionary setObject:model.networkLatencyTime forKey:networkLatency];
                }
            }
        }
        else if (model.operationType == PAOperationTypeDBOperation) {
            
            NSString *dbOperation = [self getPaddedStringWithLength:40 forString:@"DBLatency"];
            NSString *dbOperationCount = [self getPaddedStringWithLength:40 forString:@"DBOperationCount"];
            NSString *dbOperationPerSec = [self getPaddedStringWithLength:40 forString:@"DBOperation/Sec"];
            if ([dictionary objectForKey:dbOperation]) {
                
                float latencyValue = [[dictionary objectForKey:dbOperation] floatValue] + [model.dbOperationTime floatValue];
                NSString *valueStr = [NSString stringWithFormat:@"%f",latencyValue];
                model.dbOperationTime = valueStr;
                
                [dictionary setObject:valueStr forKey:dbOperation];
            }
            else {
                [dictionary setObject:model.dbOperationTime forKey:dbOperation];
            }
            if ([dictionary objectForKey:dbOperationCount]) {
                
                int latencyCount = [[dictionary objectForKey:dbOperationCount] floatValue] + [model.dbOperationRecordCount floatValue];
                NSNumber *number = [NSNumber numberWithInt:latencyCount];
                model.dbOperationRecordCount = number;
                
                NSString *valueStr = [NSString stringWithFormat:@"%d",latencyCount];
                
                [dictionary setObject:valueStr forKey:dbOperationCount];
            }
            else {
                [dictionary setObject:model.dbOperationRecordCount forKey:dbOperationCount];
            }
            
            NSString *valueStr = [NSString stringWithFormat:@"%d",(int)([model.dbOperationRecordCount floatValue] / [model.dbOperationTime floatValue])];
            [dictionary setObject:valueStr forKey:dbOperationPerSec];
        }
        else if (model.operationType == PAOperationTypeAlgorithm) {
            
        }
        [maindict setObject:dictionary forKey:sub];
        //}
    }
    return maindict;
    
}
- (void) printGrandDataForContext:(NSString *)contextName forContentString:(NSMutableString *)contentString {
    
    [contentString appendString:@"\n**************************************************************************************\n"];
    
    //Total Time taken for the flow.
    float totalTime = 0.0;
    
    NSString *totalTimeString = [self getPaddedStringWithLength:40 forString:@"\nTotal Time taken"];
    
    if (totalTimeTakenForFlow/60.0 >= 1.0) {
        totalTime = totalTimeTakenForFlow/60.0;
        [contentString appendFormat:@"%@  %f minutes\n",totalTimeString,totalTime];
        
    }
    else {
        totalTime = totalTimeTakenForFlow;
        [contentString appendFormat:@"%@  %f seconds\n",totalTimeString,totalTime];
    }

    
    //network latency
    
    totalTime = 0.0;
    NSString *networkLatency = [self getPaddedStringWithLength:40 forString:@"\nTotal Network latency"];
    
    if (totalNetworkLatency/60.0 >= 1.0) {
        totalTime = totalNetworkLatency/60.0;
        [contentString appendFormat:@"%@  %f minutes\n",networkLatency,totalTime];
    }
    else {
        totalTime = totalNetworkLatency;
        [contentString appendFormat:@"%@  %f seconds\n",networkLatency,totalTime];
    }
    
    //parsing latency
    NSString *parsingLatency = [self getPaddedStringWithLength:40 forString:@"Total parse latency"];
    
    totalTime = 0.0;
    
    if (totalParsingLatency/60.0 >= 1.0) {
        totalTime = totalParsingLatency/60.0;
        [contentString appendFormat:@"%@ %f minutes\n",parsingLatency,totalTime];
        
    }
    else {
        totalTime = totalParsingLatency;
        [contentString appendFormat:@"%@ %f seconds\n",parsingLatency,totalTime];
    }
    
    //DBOperation latency
    NSString *dbOperationLatency = [self getPaddedStringWithLength:40 forString:@"Total DB operation latency"];
    
    totalTime = 0.0;
    
    if (totalDBOperationLatency/60.0 >= 1.0) {
        totalTime = totalDBOperationLatency/60.0;
        [contentString appendFormat:@"%@ %f minutes\n",dbOperationLatency,totalTime];
        
    }
    else {
        totalTime = totalDBOperationLatency;
        [contentString appendFormat:@"%@ %f seconds\n",dbOperationLatency,totalTime];
    }

    
    
    //Network operations count
    NSString *networkOp = [self getPaddedStringWithLength:40 forString:@"\nTotal network operation"];
    [contentString appendFormat:@"%@  %d\n",networkOp,(int)networkLatencyRecordCount];
    
    //parser operations count
    NSString *parsingLatencyC = [self getPaddedStringWithLength:40 forString:@"Total parsed Records"];
    [contentString appendFormat:@"%@ %d\n",parsingLatencyC, (int)parseLatencyRecordCount];
    
    //Network operations count
    NSString *dbOP = [self getPaddedStringWithLength:40 forString:@"Total DB operation"];
    [contentString appendFormat:@"%@ %d\n",dbOP,(int)totalDBOperation];
    
    //Average network latency
    totalTime = 0.0;
    
    NSString *avgNetwork = [self getPaddedStringWithLength:40 forString:@"\nAverage network Latency"];
    
    float average = totalNetworkLatency/networkLatencyRecordCount;
    if (average/60.0 >= 1.0) {
        totalTime = average/60.0;
        [contentString appendFormat:@"%@  %f minutes\n",avgNetwork,totalTime];
        
    }
    else {
        totalTime = average;
        [contentString appendFormat:@"%@  %f seconds\n",avgNetwork,totalTime];
    }
    
    //avg parsing latency
    NSString *avgParse = [self getPaddedStringWithLength:40 forString:@"Average Parsing Latency"];
    totalTime = 0.0;
    float averageParsing = totalParsingLatency/parseLatencyRecordCount;
    if (averageParsing/60.0 >= 1.0) {
        totalTime = averageParsing/60.0;
        [contentString appendFormat:@"%@ %f minutes\n",avgParse,totalTime];
        
    }
    else {
        totalTime = averageParsing;
        [contentString appendFormat:@"%@ %f seconds\n",avgParse,totalTime];
    }
    
    //avg DB latency
    NSString *avgDBop = [self getPaddedStringWithLength:40 forString:@"Average DB operation Latency"];
    totalTime = 0.0;
    float averageDBOp = totalDBOperationLatency/totalDBOperation;
    if (averageDBOp/60.0 >= 1.0) {
        totalTime = averageDBOp/60.0;
        [contentString appendFormat:@"%@ %f minutes\n",avgDBop,totalTime];
        
    }
    else {
        totalTime = averageDBOp;
        [contentString appendFormat:@"%@ %f seconds\n",avgDBop,totalTime];
    }
    
     [contentString appendString:@"\n**************************************************************************************\n"];

}
- (void) generatePerformanceAnalysisReportForContextName:(NSString *)contextName {
    
    @autoreleasepool {
        
        if ([contextName isEqualToString:@"--"]) {
            [self clearDataForContext:contextName];
            return;
        }
        NSMutableString *contentString = [[NSMutableString alloc] init];
        [contentString appendFormat:@"\nGrand data for : %@\n",contextName];
        
        [self printGrandDataForContext:contextName forContentString:contentString];
        
        [contentString appendFormat:@"\nContext : %@\n",contextName];
        NSString *string = [[self getFormattedAnalytics:contextName] description];
        string = [string stringByReplacingOccurrencesOfString:@"{" withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@"}" withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@");" withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@";" withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@"," withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@"=" withString:@""];
        
        [contentString appendString:string];
        [contentString appendString:@"\n**************************************************************************************\n"];

        NSString *corelibDir = [FileManager getPerformanceLogDirectoryPath];
        NSString *htmlFilePath = [NSString stringWithFormat:@"%@_%f",contextName,CFAbsoluteTimeGetCurrent()];
        htmlFilePath = [htmlFilePath stringByReplacingOccurrencesOfString:@"." withString:@""];
        htmlFilePath = [htmlFilePath stringByReplacingOccurrencesOfString:@" " withString:@""];
        htmlFilePath = [htmlFilePath stringByAppendingString:@".txt"];
        
        NSString *htmlfile = [corelibDir stringByAppendingPathComponent:htmlFilePath];
        
        if (contentString.length > 0) {
            
            if([[NSFileManager defaultManager] fileExistsAtPath:htmlfile])
                [[NSFileManager defaultManager] removeItemAtPath:htmlfile error:NULL];
            NSString *fileWritableString = [[self getApplicationMetaDataForReport]stringByAppendingString:contentString];
            
            NSLog(@"path : %@",htmlfile);
            [fileWritableString writeToFile:htmlfile
                                 atomically:NO
                                   encoding:NSUTF8StringEncoding
                                      error:NULL];
        }
        [self clearDataForContext:contextName];
    }
}


#pragma mark - Private methods

- (NSString *) getPaddedStringWithLength:(int)length forString:(NSString *)string {
    
    if (length > 0) {
        string = [string stringByPaddingToLength:length withString:@" " startingAtIndex:0];
    }
    return string;
}
- (NSString *) getApplicationMetaDataForReport {
    
    [[AppMetaData sharedInstance] loadApplicationMetaData];
    NSMutableString *fileWritableString = [[NSMutableString alloc] init] ;
    NSString *perforamanceAnalyserHeading = [NSString stringWithFormat:@"\n Performance Analyser Report \n"];
    [fileWritableString appendString:@"\n**************************************************************************************\n"];
    [fileWritableString appendString:perforamanceAnalyserHeading];
    [fileWritableString appendString:@"\n**************************************************************************************\n"];
    
    NSString *appName = [self getPaddedStringWithLength:40 forString:@"Application Version"];
    [fileWritableString appendFormat:@"%@ : %@ \n",appName,[[AppMetaData sharedInstance]getCurrentApplicationVersion]];
    
    NSString *userName = [self getPaddedStringWithLength:40 forString:@"User Name "];
    [fileWritableString appendFormat:@"%@ : %@ \n",userName,[CustomerOrgInfo sharedInstance].userDisplayName];
    
    NSString *date = [self getPaddedStringWithLength:40 forString:@"Date "];
    [fileWritableString appendFormat:@"%@ : %@ \n",date,[NSDate date]];
    
    NSString *userId = [self getPaddedStringWithLength:40 forString:@"User Org "];
    [fileWritableString appendFormat:@"%@ : %@ \n",userId,[CustomerOrgInfo sharedInstance].userLoggedInHost];
    
    NSString *deviceName = [self getPaddedStringWithLength:40 forString:@"Device Name "];
    [fileWritableString appendFormat:@"%@ : %@ \n",deviceName,[[AppMetaData sharedInstance]getCurrentDeviceVersion]];
    
    NSString *deviceType = [self getPaddedStringWithLength:40 forString:@"Device Type "];
    [fileWritableString appendFormat:@"%@ : %@ \n",deviceType,[[AppMetaData sharedInstance]getCurrentDeviceType]];
    
    NSString *osVersion = [self getPaddedStringWithLength:40 forString:@"OS Version "];
    [fileWritableString appendFormat:@"%@ : %@ \n",osVersion,[[AppMetaData sharedInstance]getCurrentOSVersion]];

    [fileWritableString appendString:@"\n**************************************************************************************\n"];
    return fileWritableString;
}

@end
