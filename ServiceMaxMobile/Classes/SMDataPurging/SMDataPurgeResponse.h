//
//  SMDataPurgeResponse.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 1/2/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMDataPurgeModel.h"
#import "SMDataPurgeResponseError.h"

@interface SMDataPurgeResponse : NSObject

@property (nonatomic,assign) BOOL hasMoreData;
@property (nonatomic,retain) NSMutableDictionary * partialExecutedObjects;
@property (nonatomic,retain) NSMutableDictionary * resultDictionary;
@property (nonatomic,retain) NSMutableDictionary * resultObjectNameToObjectDictionary;
@property (nonatomic,retain) NSString * lastConfigTime;
@property (nonatomic, retain) NSArray * values;
@property (nonatomic, retain) NSString * lastIndex;

@property (nonatomic,retain) SMDataPurgeResponseError * error;


- (void)setPartialExecutedObject:(NSString *)object;
- (void)addPurgeableObject:(SMDataPurgeModel *)purgeModel;
- (void)addMoreResults:(NSArray *)results toType:(NSString *)objectType;
- (void)addResult:(NSString *)recordId byType:(NSString *)objectType;
- (void)setRemainingValues:(NSArray *)data;

- (void)createPurgeModelForDownloadedCriteriaAndGPRecords;

- (BOOL)hasError;

@end
