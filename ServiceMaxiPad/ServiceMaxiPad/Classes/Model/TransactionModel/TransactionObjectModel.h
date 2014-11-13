//
//  TransactionObjectModel.h
//  ServiceMaxMobile
//
//  Created by Vipindas on 8/1/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//

/**
 *  @file   TransactionObjectModel.h
 *  @class  TransactionObjectModel
 *
 *  @brief  Function prototypes for the console driver.
 *
 *
 *  This contains the prototypes for the console
 *  driver and eventually any macros, constants,
 *  or global variables you will need.
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/


#import <Foundation/Foundation.h>

@interface TransactionObjectModel : NSObject

@property(nonatomic, strong) NSString *nameField;

- (NSString *)salesForceId;
- (NSString *)recordLocalId;

- (void)setValue:(NSString *)value forField:(NSString *)fieldName;
- (void)setRecordLocalId:(NSString *)recordId;

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

-(instancetype)initWithObjectApiName:(NSString *)objectName;

- (NSDictionary *)getFieldValueDictionaryForFields:(NSArray *)fields;

- (void)mergeFieldValueDictionaryForFields:(NSDictionary *)valueDictionary;
- (void)setFieldValueDictionaryForFields:(NSDictionary  *)valueDictionary;

- (BOOL)boolValueForField:(NSString *)fieldName;
- (int)intValueForField:(NSString *)fieldName;
- (float)floatValueForField:(NSString *)fieldName;

- (NSData *)dataForField:(NSString *)fieldName;
- (NSDate *)dateForField:(NSString *)fieldName;
- (NSString *)valueForField:(NSString *)fieldName;

- (NSString *)dataTypeForField:(NSString *)fieldName;

- (NSString *)tableName;
- (NSString *)objectAPIName;
- (NSString *)keyPrefixName;

- (BOOL)isSynchedRecord;
- (BOOL)isChildRecord;

- (BOOL)isKindOfTransactionObject:(NSString *)objectName;

- (NSDictionary *)getFieldValueDictionary;
- (NSMutableDictionary *)getFieldValueMutableDictionary;
- (void)setObjectName:(NSString *)objectName;

@end
