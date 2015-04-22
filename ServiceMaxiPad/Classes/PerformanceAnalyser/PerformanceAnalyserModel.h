//
//  PerformanceAnalyserModel.h
//  ServiceMaxiPad
//
//  Created by Krishna Shanbhag on 19/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum PAOperationType : NSUInteger
{
    PAOperationTypeTotalTimeLatency = 1,
    PAOperationTypeNetworkLatency = 2,
    PAOperationTypeAlgorithm = 3,
    PAOperationTypeDBOperation = 4,
    PAOperationTypeParsing = 5
}
PAOperationType;

@interface PerformanceAnalyserModel : NSObject

@property (nonatomic,strong) NSString            *contextName;
@property (nonatomic) CFTimeInterval              startTime; //T1
@property (nonatomic) CFTimeInterval              endTime;   //T2
@property (nonatomic,strong) NSNumber            *recordCount;
@property (nonatomic,strong) NSString            *subContextName;
@property (nonatomic) PAOperationType            operationType;
@property (nonatomic,strong) NSString            *networkLatencyTime;
@property (nonatomic,strong) NSString            *algorithTime;
@property (nonatomic,strong) NSString            *parsingTime;
@property (nonatomic,strong) NSString            *dbOperationTime;
@property (nonatomic,strong) NSString            *totalTime;
@property (nonatomic,strong) NSNumber            *recordCountForParsing;
@property (nonatomic,strong) NSNumber            *dbOperationRecordCount;


@end
