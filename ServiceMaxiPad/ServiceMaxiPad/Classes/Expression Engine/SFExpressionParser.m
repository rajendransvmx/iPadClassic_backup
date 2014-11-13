//
//  ExpressionParser.m
//  ServiceMaxiPhone
//
//  Created by Aparna on 17/02/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "SFExpressionParser.h"
#import "DBCriteria.h"
#import "SFExpressionModel.h"
#import "SFExpressionComponentModel.h"
#import "ExpressionParserDAO.h"
#import "FactoryDAO.h"
#import "DatabaseConstant.h"
#import "PlistManager.h"
#import "Utility.h"
#import "SFExpressionDAO.h"
#import "SFExpressionComponentDAO.h"
#import "StringUtil.h"
#import "DBRequestSelect.h"
#import "SFObjectFieldModel.h"
#import "SFObjectFieldDAO.h"
#import "DataTypeUtility.h"


#import "SFMSearchFilterCriteriaModel.h"
@interface SFExpressionParser ()

@property(nonatomic, strong) SFExpressionModel *expression;

@end


@implementation SFExpressionParser

- (id) initWithExpressionId:(NSString *)expressionId objectName:(NSString *)objectName
{
    self = [super init];
    if(self){
        self.expressionId = expressionId;
        self.objectName = objectName;
    }
    return self;
}

- (BOOL)isEntryCriteriaMatchingForRecordId:(NSString *)recordId
{
    
    id<ExpressionParserDAO> expParserService = [FactoryDAO serviceByServiceType:ServiceTypeExpressionParser];
    BOOL isEntryCriteriaMatching = [expParserService isRecordExistWithId:recordId
                                                              objectName:self.objectName
                                                                criteria:[self expressionCriteriaObjects]
                                                       advanceExpression:[self advanceExpression]];
    return isEntryCriteriaMatching;
}

- (NSString *) errorMessage
{
    return self.expression.errorMessage;
}

- (NSArray *)expressionCriteriaObjects
{
    NSMutableArray *criteriaObjArray = [[NSMutableArray alloc] init];
    id<SFExpressionComponentDAO> expCompService = [FactoryDAO serviceByServiceType:ServiceTypeExpressionComponent];
    NSArray *expCompArray =[expCompService getExpressionComponentsBySFId:self.expressionId];
    for (SFExpressionComponentModel *expComp in expCompArray) {
        
        DBCriteria *criteriaObj = [self criteriaForOperator:expComp.operatorValue
                                                   lhsValue:expComp.componentLHS
                                                   rhsValue:expComp.componentRHS
                                                  fieldType:expComp.fieldType];
        
        [self addInnerCriteria:criteriaObj expressionComponent:expComp];
        
        if (criteriaObj != nil) {
            [criteriaObjArray addObject:criteriaObj];
        }
        
    }
    return criteriaObjArray;
}
- (NSArray *)expressionCriteriaObjectsForComponents:(NSArray *)componentArray
{
    
    
    
    NSMutableArray *criteriaObjArray = [[NSMutableArray alloc] init];
    for (SFExpressionComponentModel *expComp in componentArray) {
                
        DBCriteria *criteriaObj = [self criteriaForOperator:expComp.operatorValue
                                                   lhsValue:expComp.componentLHS
                                                   rhsValue:expComp.componentRHS
                                                  fieldType:expComp.fieldType];
        
        [self addInnerCriteria:criteriaObj expressionComponent:expComp];
        
        if (criteriaObj != nil) {
            [criteriaObjArray addObject:criteriaObj];
        }
        
    }
    return criteriaObjArray;
}

- (DBCriteria *) criteriaForOperator:(NSString *)operator
                            lhsValue:(NSString *)lhsValue
                            rhsValue:(NSString *)rhsValue
                           fieldType:(NSString *)fieldType
{
    DBCriteria *criteria = nil;
    SQLOperator sqlOperator = [self sqlOperatorForSFOperator:operator fieldType:fieldType];
    NSString *literalValue = [self valueOfLiteral:rhsValue dataType:fieldType];
    if (literalValue != nil) {
        rhsValue = literalValue;
    }
    criteria = [[DBCriteria alloc] initWithFieldName:lhsValue operatorType:sqlOperator andFieldValue:rhsValue];
    return criteria;
}


- (SQLOperator) sqlOperatorForSFOperator:(NSString *)sfOperator fieldType:(NSString *)fieldType
{
    SQLOperator sqlOperator = SQLOperatorNone;
    if([sfOperator isEqualToString:@"eq"] || [sfOperator isEqualToString:@"="])
    {
        sqlOperator = SQLOperatorEqual;
    }
    else if([sfOperator isEqualToString:@"gt"] || [sfOperator isEqualToString:@">"])
    {
        sqlOperator = SQLOperatorGreaterThan;
    }
    else if([sfOperator isEqualToString:@"lt"] || [sfOperator isEqualToString:@"<"])
    {
        sqlOperator = SQLOperatorLessThan;
    }
    else if([sfOperator isEqualToString:@"Less or Equal To"]|| [sfOperator isEqualToString:@"<="])
    {
        sqlOperator = SQLOperatorLessThanEqualTo;
    }
    else if ([sfOperator isEqualToString:@"ne"] || [sfOperator isEqualToString:@"!="])
    {
        sqlOperator = SQLOperatorNotEqualWithIsNull;
        if ([fieldType caseInsensitiveCompare:kSfDTReference] == NSOrderedSame) {
            sqlOperator = SQLOperatorNotEqual;
        }
    }
    else if ([sfOperator isEqualToString:@"ge"] || [sfOperator isEqualToString:@">="])
    {
        sqlOperator = SQLOperatorGreaterThanEqualTo;
    }
    else if ([sfOperator isEqualToString:@"le"] || [sfOperator isEqualToString:@"<="])
    {
        sqlOperator = SQLOperatorLessThanEqualTo;
    }
    else if([sfOperator isEqualToString:@"isnotnull"])
    {
        sqlOperator = SQLOperatorIsNotNull;
    }
    else if([sfOperator isEqualToString:@"contains"] || [sfOperator isEqualToString:@"LIKE"])
    {
        sqlOperator = SQLOperatorLike;
    }
    else if([sfOperator isEqualToString:@"notcontain"])
    {
        sqlOperator =  SQLOperatorNotLikeWithIsNull;
        if ([fieldType caseInsensitiveCompare:kSfDTReference] == NSOrderedSame) {
            sqlOperator = SQLOperatorNotLike;
        }
    }
    else if ([sfOperator isEqualToString:@"in"])
    {
        sqlOperator = SQLOperatorLike;
    }
    else if ([sfOperator isEqualToString:@"notin"])
    {
        sqlOperator = SQLOperatorNotLikeWithIsNull;
        if ([fieldType isEqualToString:kSfDTReference]) {
            sqlOperator = SQLOperatorNotLike;
        }
    }
    else if ([sfOperator  isEqualToString:@"starts"])
    {
        sqlOperator = SQLOperatorLike;
    }
    else if( [sfOperator  isEqualToString:@"isnull"])
    {
        sqlOperator = SQLOperatorIsNull;
    }
    return sqlOperator;
}


- (NSString *) advanceExpression
{
    return self.expression.expression;
}


- (NSString *)valueOfLiteral:(NSString *)literal dataType:(NSString *)dataType
{
    NSString *literalValue = nil;
    if (([dataType caseInsensitiveCompare:kSfDTDate] == NSOrderedSame) || ([dataType caseInsensitiveCompare:kSfDTDateTime] == NSOrderedSame))
    {
        BOOL isDateOnly = NO;
        if ([dataType isEqualToString:kSfDTDate])
        {
            isDateOnly = YES;
        }
        if([literal caseInsensitiveCompare:kLiteralNow]== NSOrderedSame)
        {
            literalValue = [Utility today:0 andJusDate:isDateOnly];
        }
        else if([literal caseInsensitiveCompare:kLiteralToday]== NSOrderedSame)
        {
            literalValue = [Utility today:0 andJusDate:YES];
        }
        else if([literal caseInsensitiveCompare:kLiteralTomorrow]== NSOrderedSame)
        {
            literalValue = [Utility today:1 andJusDate:YES];
        }
        else if([literal caseInsensitiveCompare:kLiteralYesterday]== NSOrderedSame)
        {
            literalValue = [Utility today:-1 andJusDate:YES];
        }
        if ([dataType caseInsensitiveCompare:kSfDTDate] == NSOrderedSame){
            if ([literalValue length] >= 10 ) {
                literalValue = [literalValue substringToIndex:10];
            }
        }
    }
    else
    {
        if(([literal caseInsensitiveCompare:kLiteralCurrentUser]== NSOrderedSame) || ([literal caseInsensitiveCompare:kLiteralOwner]== NSOrderedSame))
        {
            literalValue = [PlistManager getLoggedInUserName];
        }
        else if(([literal caseInsensitiveCompare:kLiteralCurrentRecord]== NSOrderedSame) || ([literal caseInsensitiveCompare:kLiteralCurrentRecordHeader] == NSOrderedSame))
        {
        }
        else if([literal caseInsensitiveCompare:kLiteralUserTrunk] == NSOrderedSame)
        {
            literalValue = [PlistManager getTechnicianLocation];
        }
    }
    return literalValue;
}


- (SFObjectFieldModel *) getReferenceForField:(NSString *)fieldName
{
    id<SFObjectFieldDAO> objectFieldDao = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
    DBCriteria *objNameCriteria = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:self.objectName];
    DBCriteria *fieldNameCriteria = [[DBCriteria alloc] initWithFieldName:kfieldname operatorType:SQLOperatorEqual andFieldValue:fieldName];
    NSArray *criteriaArray = [[NSArray alloc] initWithObjects:objNameCriteria,fieldNameCriteria, nil];
    
    SFObjectFieldModel *objFieldModel = [objectFieldDao getSFObjectFieldInfo:criteriaArray advanceExpression:@"1 AND 2"];
    return objFieldModel;
}


- (NSString *)nameFieldForObject:(NSString *)objectName
{
    NSString * nameField = nil;
    
    if ([objectName length] > 0) {
        DBCriteria * objNameCriteria = [[DBCriteria alloc] initWithFieldName:kobjectName operatorType:SQLOperatorEqual andFieldValue:objectName];
        DBCriteria * nameFieldCriteria = [[DBCriteria alloc] initWithFieldName:kSFObjectNameField operatorType:SQLOperatorEqual andFieldValue:@"true"];
        NSArray *criteriaArray = [[NSArray alloc]initWithObjects:objNameCriteria,nameFieldCriteria, nil];
        
        id <SFObjectFieldDAO> objectFieldService = [FactoryDAO serviceByServiceType:ServiceTypeSFObjectField];
        
        SFObjectFieldModel * model = [objectFieldService getSFObjectFieldInfo:criteriaArray advanceExpression:@"1 AND 2"];
        if (model != nil) {
            nameField = model.fieldName;
        }
    }
    return nameField;
}

- (void) addInnerCriteria:(DBCriteria *)dbCriteria expressionComponent:(SFExpressionComponentModel *)expComp
{
    if ([expComp.fieldType caseInsensitiveCompare:kSfDTReference] == NSOrderedSame
        && expComp.fieldType != nil)
    {
        NSMutableArray *innerCriteriaArray = nil;
        if ([expComp.componentLHS isEqualToString:kSfDTRecordTypeId]) {
            innerCriteriaArray = [[NSMutableArray alloc]initWithArray:[self recordTypeCriteriaForExpComponent:expComp]];
            
        }
        else
        {
            innerCriteriaArray = [[NSMutableArray alloc]initWithArray:[self refereceFieldCriteriasForExpComponent:expComp]];
        }
        if ((dbCriteria.operatorType == SQLOperatorNotEqual) || (dbCriteria.operatorType == SQLOperatorNotLike)) {
            DBCriteria *nullCriteria = [self criteriaForOperator:@"isnull" lhsValue:expComp.componentLHS  rhsValue:nil fieldType:expComp.fieldType];
            [innerCriteriaArray addObject:nullCriteria];
        }
        [dbCriteria addOrCriterias:innerCriteriaArray withExpression:nil];

    }
    else{
        NSString *fieldType = expComp.fieldType;
        /*If integer values inserted as string, > & >= return empty string values*/
        if (([expComp.operatorValue isEqualToString: @"gt"]) || ([expComp.operatorValue isEqualToString: @"ge"])) {
            if (([fieldType caseInsensitiveCompare:kSfDTDouble] == NSOrderedSame) || ([fieldType caseInsensitiveCompare:kSfDTPercent]== NSOrderedSame) || ([fieldType caseInsensitiveCompare:kSfDTCurrency]== NSOrderedSame) || ([expComp.fieldType caseInsensitiveCompare:kSfDTInteger]== NSOrderedSame)){
                DBCriteria *innerCriteria = [[DBCriteria alloc] initWithFieldName:expComp.componentLHS operatorType:SQLOperatorIsNotNull andFieldValue:nil];
                NSArray *innerCriteriaArray = [NSArray arrayWithObject:innerCriteria];
                [dbCriteria addOrCriterias:innerCriteriaArray withExpression:@"AND"];
            }
            
        }

    }
}

- (NSArray *) refereceFieldCriteriasForExpComponent:(SFExpressionComponentModel *)expComp
{
    SFObjectFieldModel *objField = [self getReferenceForField:expComp.componentLHS];
    NSString *nameFieldValue = [self nameFieldForObject:objField.referenceTo];
    NSString *refrenceToTable = objField.referenceTo;
    
    DBCriteria *innerCriteria = [self criteriaForOperator:expComp.operatorValue lhsValue:nameFieldValue rhsValue:expComp.componentRHS fieldType:expComp.fieldType];
    
    NSArray *sfIdFieldsArray = [[NSArray alloc] initWithObjects:kId, nil];
    DBRequestSelect *sfIdSelectRequest = [[DBRequestSelect alloc] initWithTableName:refrenceToTable andFieldNames:sfIdFieldsArray whereCriteria:innerCriteria];
    NSArray *localIdFieldsArray = [[NSArray alloc] initWithObjects:kLocalId, nil];
    
    DBRequestSelect *localIdSelectRequest = [[DBRequestSelect alloc] initWithTableName:refrenceToTable andFieldNames:localIdFieldsArray whereCriteria:innerCriteria];
    
    DBCriteria *localIdCriteria = [[DBCriteria alloc] initWithFieldName:expComp.componentLHS operatorType:SQLOperatorIn andInnerQUeryRequest:localIdSelectRequest];
    
    DBCriteria *sfIdCriteria = [[DBCriteria alloc] initWithFieldName:expComp.componentLHS operatorType:SQLOperatorIn andInnerQUeryRequest:sfIdSelectRequest];
    
    NSMutableArray *innerCriteriaArray = [[NSMutableArray alloc] initWithObjects:localIdCriteria, sfIdCriteria,nil];
    return innerCriteriaArray;
}

- (NSArray *) recordTypeCriteriaForExpComponent:(SFExpressionComponentModel *)expComp
{
    
    NSMutableArray *innerCriteriaArray = nil;
    NSArray *fieldsArray = [[NSArray alloc] initWithObjects:kRecordTypeId,nil];
    DBCriteria *innerCriteria = [self criteriaForOperator:expComp.operatorValue lhsValue:kRecordType rhsValue:expComp.componentRHS fieldType:expComp.fieldType];
    DBRequestSelect *dbSelect = [[DBRequestSelect alloc] initWithTableName:kSFRecordType andFieldNames:fieldsArray whereCriteria:innerCriteria];
    DBCriteria *inCriteria = [[DBCriteria alloc] initWithFieldName:kRecordTypeId operatorType:SQLOperatorIn andInnerQUeryRequest:dbSelect];
    if (inCriteria != nil) {
        innerCriteriaArray = [[NSMutableArray alloc] initWithObjects:inCriteria, nil];

    }
    return innerCriteriaArray;
}

- (void)setExpressionId:(NSString *)expressionId
{
    _expressionId = expressionId;
    id<SFExpressionDAO> expService = [FactoryDAO serviceByServiceType:ServiceTypeExpression];
    self.expression = [expService getExpressionBySFId:self.expressionId];

}

- (void)setExpressionData:(SFExpressionModel *)expression
{
    _expression = expression;
}

- (NSArray *)expressionCriteriaObjectsForFilters
{
    NSMutableArray *criteriaObjArray = [[NSMutableArray alloc] init];
    DataTypeUtility *dataTypeUtil = [[DataTypeUtility alloc] init];
    id<SFExpressionComponentDAO> expCompService = [FactoryDAO serviceByServiceType:ServiceTypeExpressionComponent];
    NSArray *expCompArray =[expCompService getExpressionComponentsBySFId:self.expression.expressionId];
    for (SFExpressionComponentModel *expComp in expCompArray) {
        
       NSString *dataType = [dataTypeUtil getDataTypeForObjectName:self.expression.sourceObjectName fieldName:expComp.componentLHS];
        expComp.fieldType = dataType;
        
        DBCriteria *criteriaObj = [self criteriaForOperator:expComp.operatorValue
                                                   lhsValue:expComp.componentLHS
                                                   rhsValue:expComp.componentRHS
                                                  fieldType:expComp.fieldType];
        
        [self addInnerCriteria:criteriaObj expressionComponent:expComp];
        
        if (criteriaObj != nil) {
            [criteriaObjArray addObject:criteriaObj];
        }
        
    }
    return criteriaObjArray;
}

@end
