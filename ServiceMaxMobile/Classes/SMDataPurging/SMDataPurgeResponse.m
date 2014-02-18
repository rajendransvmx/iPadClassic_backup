//
//  SMDataPurgeResponse.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 1/2/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

#import "SMDataPurgeResponse.h"

@implementation SMDataPurgeResponse

@synthesize partialExecutedObjects;
@synthesize hasMoreData;
@synthesize resultDictionary;
@synthesize resultObjectNameToObjectDictionary;
@synthesize error;
@synthesize lastConfigTime;
@synthesize values;
@synthesize lastIndex;


- (void)setPartialExecutedObject:(NSString *)object
{
    if (partialExecutedObjects == nil)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        self.partialExecutedObjects = dict;
        [dict  release];
    }
    
    [self.partialExecutedObjects setObject:object forKey:@"PARTIAL_EXECUTED_OBJECT"];
}


- (void)addMoreResults:(NSArray *)results toType:(NSString *)objectType
{
    if (resultDictionary == nil)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        self.resultDictionary = dict;
        [dict  release];
    }
    
    NSMutableArray *storedArray = [[self.resultDictionary objectForKey:objectType] retain];
    
    if (storedArray == nil)
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        storedArray = [array retain];
        [array  release];
    }
    [storedArray addObjectsFromArray:results];
    
    [self.resultDictionary setObject:storedArray forKey:objectType];
    
    [storedArray release];
}


- (void)addPurgeableObject:(SMDataPurgeModel *)purgeModel
{
    if (resultObjectNameToObjectDictionary == nil)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        self.resultObjectNameToObjectDictionary = dict;
        [dict  release];
    }
    
    SMDataPurgeModel * model = [self.resultObjectNameToObjectDictionary objectForKey:purgeModel.name];
    
    if (model != nil)
    {
        NSMutableArray * array = model.advancedOrDownloadedCriteriaRecords;
        
        for (NSString * recordId in array)
        {
            [purgeModel addDownloadedCriteriaObject:recordId];
            
        }
        
    }
    [self.resultObjectNameToObjectDictionary setObject:purgeModel forKey:purgeModel.name];
    
}


- (void)addResult:(NSString *)recordId byType:(NSString *)objectType
{
    [self addMoreResults:[NSArray arrayWithObject:recordId] toType:objectType];
}

- (void) setRemainingValues:(NSArray *)data
{
    self.values = data;
}


- (BOOL)hasError
{
    BOOL errorExist = NO;
    
    if (self.error != nil)
    {
        errorExist = YES;
    }
    
    return errorExist;
}

- (void)createPurgeModelForDownloadedCriteriaAndGPRecords
{
    NSArray * allkeys = [self.resultDictionary allKeys];
    
    for (NSString * objectName in allkeys)
    {
        SMDataPurgeModel * purgeModel = [[SMDataPurgeModel alloc] initWithName:objectName];
        
        NSArray * ids = [self.resultDictionary objectForKey:objectName];
        
        for (NSString * recordId in ids)
        {
            [purgeModel addDownloadedCriteriaObject:recordId];
        }
        
        [self addPurgeableObject:purgeModel];
        [purgeModel release];
        purgeModel = nil;
        
    }
}



- (void)dealloc
{
    [partialExecutedObjects release];
    [resultObjectNameToObjectDictionary release];
    [resultDictionary release];
    [lastIndex release];
    [values release];
    values = nil;
    [super dealloc];
}
@end
