//
//  SFObjectFieldDAO.h
//  ServiceMaxMobile
//
//  Created by Radha Sathyamurthy on 21/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFObjectFieldModel.h"
#import "DBCriteria.h"
#import "CommonServiceDAO.h"

@protocol SFObjectFieldDAO <CommonServiceDAO>

- (NSArray * )fetchSFObjectFieldsInfoByFields:(NSArray *)fieldNames andCriteria:(id)criteria;
- (NSArray * )fetchSFObjectFieldsInfoByFields:(NSArray *)fieldNames andCriteriaArray:(NSArray *)criteriaArray advanceExpression:(NSString *)advExp;

- (SFObjectFieldModel *)getSFObjectFieldInfo:(id)criteria advanceExpression:(NSString *)advExp;
- (SFObjectFieldModel *)getSFObjectFieldInfo:(NSArray *)fields criteria:(NSArray *)criteria
                           advanceExpression:(NSString *)advExp;
- (void)updateSFObjectField:(NSArray *)sfObjectFields;

- (NSMutableArray*)getDependantPickListObjectNames;
-(NSArray *)getSFObjectFieldsForObject:(NSString *)objectName;
-(NSArray *)getSFObjectFieldsForObjectWithLocalId:(NSString *)objectName;


-(NSDictionary *)getFieldsInformationFor:(NSArray *)fields objectName:(NSString *)obejctName;

- (NSString *)getFieldNameForRelationShipName:(NSString *)relationship withRelatedObjectName:(NSString *)relatedObjectName andObjectName:(NSString *)objectName;
- (NSArray * )fetchDistinctSFObjectFieldsInfoByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria;
-(NSArray *)getAllSFObjectFieldsForObject:(NSString *)objectName;

@end
