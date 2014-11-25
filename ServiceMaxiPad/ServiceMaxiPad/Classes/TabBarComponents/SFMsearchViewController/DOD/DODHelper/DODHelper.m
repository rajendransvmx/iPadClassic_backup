//
//  DODHelper.m
//  ServiceMaxiPad
//
//  Created by Himanshi Sharma on 12/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "DODHelper.h"
#import "DataTypeUtility.h"
#import "SFChildRelationshipDAO.h"
#import "FactoryDAO.h"
#import "SFChildRelationshipModel.h"
#import "SFObjectFieldDAO.h"
#import "SFMSearchFieldModel.h"

@implementation DODHelper

+ (NSString *)getFieldNamesForObject:(NSString *)objectName
{
    DataTypeUtility *utility = [[DataTypeUtility alloc] init];
    
    NSDictionary *fieldInfo = [utility fieldDataType:objectName];
    
    NSArray *fields = [fieldInfo allKeys];
    
    NSString *fieldString = [fields componentsJoinedByString:@","];
    
    return fieldString;
}

+ (NSDictionary *)getChildRelationshipForObject:(NSString *)objetcName
{
    NSMutableDictionary *relationshipDict = [NSMutableDictionary new];
    
    id  childRelationshipService = [FactoryDAO serviceByServiceType:ServiceTypeSFChildRelationShip];
    
    if ([childRelationshipService conformsToProtocol:@protocol(SFChildRelationshipDAO)]) {
        
        DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kCRObjectNameParentField operatorType:SQLOperatorEqual
                                                       andFieldValue:objetcName];
        NSArray *resultSet = [childRelationshipService fetchSFChildRelationshipInfoByFields:nil andCriterias:[NSArray arrayWithObject:criteria] andAdvanceExpresion:@"1"];
        
        for (SFChildRelationshipModel *model in resultSet) {
            if (model.objectNameChild != nil && model.fieldName != nil) {
                if ([model.objectNameChild isEqualToString:kEventObject]
                    || [model.objectNameChild isEqualToString:@"Task"]) {
                    continue;
                }
                else if ([self isObjectExists:model.objectNameChild]) {
                    [relationshipDict setObject:model.fieldName forKey:model.objectNameChild];
                }
            }
        }
    }
    return relationshipDict;
}

+ (BOOL)isObjectExists:(NSString *)objectName
{
    BOOL retValue = NO;
    
    id sfObjectField = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    
    if ([sfObjectField conformsToProtocol:@protocol(SFObjectFieldDAO)]) {
        
        DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual
                                                       andFieldValue:objectName];
        
        retValue = [sfObjectField isObjectExists:[NSArray arrayWithObject:criteria]];
        
    }
    return retValue;
}

+ (NSDictionary *)getLabelForDisplayFields:(NSArray *)displayFields object:(NSString *)objectName
{
    NSMutableDictionary *fieldLabelDict = [NSMutableDictionary new];
    
    id sfObjectField = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    
    if ([sfObjectField conformsToProtocol:@protocol(SFObjectFieldDAO)]) {
        
        NSMutableArray *fields = [NSMutableArray new];
        
        for (SFMSearchFieldModel *model in displayFields) {
            
            NSString *field = [model getDisplayField];
            if (field) {
                [fields addObject:field];
            }
        }
        DBCriteria *criteria = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual
                                                        andFieldValue:objectName];
        
        DBCriteria *criteria1 = [[DBCriteria alloc] initWithFieldName:kfieldname operatorType:SQLOperatorIn
                                                      andFieldValues:fields];
        
       NSArray *resultSet = [sfObjectField fetchSFObjectFieldsInfoByFields:nil
                                      andCriteriaArray:[NSArray arrayWithObjects:criteria, criteria1, nil]
                                     advanceExpression:@"1 AND 2"];
        
        for (SFObjectFieldModel *fieldModel in resultSet) {
            if (fieldModel.fieldName && fieldModel.label) {
                [fieldLabelDict setObject:fieldModel.label forKey:fieldModel.fieldName];
            }
        }
    }
    return fieldLabelDict;
}

@end
