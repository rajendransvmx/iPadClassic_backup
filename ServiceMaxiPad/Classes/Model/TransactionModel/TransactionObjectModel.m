//
//  TransactionObjectModel.m
//  ServiceMaxMobile
//
//  Created by Vipindas on 8/1/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   TransactionObjectModel.h
 *  @class  TransactionObjectModel
 *
 *  @brief  Transaction model
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import "TransactionObjectModel.h"
#import "NSDictionary+Merge.h"

@interface TransactionObjectModel()
{
    
}

@property(nonatomic, strong) NSString *salesForceId;
@property(nonatomic, strong) NSString *recordLocalId;
@property(nonatomic, strong) NSString *objectAPIName;

@property(nonatomic, strong) NSMutableDictionary *fieldAndValues;
@property(nonatomic, strong) NSMutableDictionary *fieldAndDataTypes;
@property(nonatomic, strong) NSMutableDictionary *fieldAndReference;
@property(nonatomic, strong) NSMutableDictionary *fieldAndReferenceValues;

@end

@implementation TransactionObjectModel

@synthesize salesForceId;
@synthesize recordLocalId;

-(instancetype)initWithObjectApiName:(NSString *)objectName
{
    if (self = [super init]) {
        _objectAPIName = objectName;
    }
    return self;
}

- (NSString *)salesForceId
{
    return salesForceId;
}

- (NSString *)recordLocalId
{
    return recordLocalId;
}

- (void)setValue:(NSString *)value forField:(NSString *)fieldName
{
    
}

- (BOOL)boolValueForField:(NSString *)fieldName
{
    return YES;
}


- (int)intValueForField:(NSString *)fieldName
{
    return 0;
}

- (float)floatValueForField:(NSString *)fieldName
{
    return 1.0f;
}


- (NSData *)dataForField:(NSString *)fieldName
{
    return nil;
}

- (NSDate *)dateForField:(NSString *)fieldName
{
    return nil;
}

- (NSString *)valueForField:(NSString *)fieldName
{
    NSString * value = nil;
    if ([self.fieldAndValues count] > 0) {
        value = [self.fieldAndValues objectForKey:fieldName];
    }
    return value;
}


- (NSString *)dataTypeForField:(NSString *)fieldName
{
    return @"";
}


- (NSString *)tableName
{
    return @"";
}

- (NSString *)objectAPIName
{
    return _objectAPIName;
}

- (NSString *)keyPrefixName
{
    return @"";
}


- (BOOL)isSynchedRecord
{
    return NO;
}

- (BOOL)isChildRecord
{
    return NO;
}

- (BOOL)isKindOfTransactionObject:(NSString *)objectName
{
    return NO;
}

/**
 * @name   getFieldValueDictionaryForFields:(NSArray *)fields
 *
 * @author Vipindas Palli
 *
 * @brief  Get subset of field and value dictionary
 *
 * \par
 *  <Longer description starts here>
 *
 * @return subset of field and value
 *
 */

- (NSDictionary *)getFieldValueDictionaryForFields:(NSArray *)fields
{
    
    if (self.fieldAndValues == nil)
    {
        return nil;
    }
    
    NSDictionary *subset = [NSDictionary dictionaryWithObjects:
                            [self.fieldAndValues objectsForKeys:fields notFoundMarker:@""]
                                                       forKeys:fields];
    
    return subset;
    
}

/**
 * @name   mergeFieldValueDictionaryForFields:(NSArray *)valueDictionary
 *
 * @author Radha S
 *
 * @brief  Get subset of field and value dictionary
 *
 * \par
 *  <Longer description starts here>
 *
 * @return subset of field and value
 *
 */


- (void)mergeFieldValueDictionaryForFields:(NSDictionary *)valueDictionary
{
    if (self.fieldAndValues != nil && [self.fieldAndValues count] > 0)
    {
        NSDictionary * resultDict = [self.fieldAndValues dictionaryByMergingWithDictionary:valueDictionary];
        
        if ([resultDict count] > 0)
        {
            [self.fieldAndValues removeAllObjects];
            self.fieldAndValues =[NSMutableDictionary dictionaryWithDictionary:resultDict];;
        }
    }
    else  {
        self.fieldAndValues = [NSMutableDictionary dictionaryWithDictionary:valueDictionary];
    }
}

/**
 * @name   setFieldValueDictionaryForFields:(NSDictionary  *)valueDictionary
 *
 * @author Vipindas Palli
 *
 * @brief  Get subset of field and value dictionary
 *
 * \par
 *  <Longer description starts here>
 *
 * @return subset of field and value
 *
 */

- (void)setFieldValueDictionaryForFields:(NSDictionary  *)valueDictionary
{
    self.fieldAndValues = [NSMutableDictionary dictionaryWithDictionary:valueDictionary];

}

- (NSDictionary *)getFieldValueDictionary
{
    return self.fieldAndValues;
}

- (NSMutableDictionary *)getFieldValueMutableDictionary
{
    return self.fieldAndValues;
}

/*- (void)setRecordLocalId:(NSString *)recordId
{
    self.recordLocalId = recordId;
}*/

- (void)setObjectName:(NSString *)objectName {
    self.objectAPIName = objectName;
}
@end
