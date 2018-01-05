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
#import "DateUtil.h"

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
        
        if ([StringUtil isStringEmpty:expComp.fieldType]) {
            DataTypeUtility *dataTypeUtil = [DataTypeUtility new];
            expComp.fieldType = [dataTypeUtil getDataTypeForObjectName:self.expression.sourceObjectName fieldName:expComp.componentLHS];
        }
        
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
     
     // IPAD-4596
     
     DBCriteria *innerCriteria = nil;
     DBCriteria *emptyValueCriteria = nil; // needed if source record field's value is empty.
     NSString *advancedExpression = nil;
     
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
     [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]]; // IPAD-4660
     
     [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

     
     if ([fieldType caseInsensitiveCompare:kSfDTDateTime] == NSOrderedSame && !([rhsValue caseInsensitiveCompare:kLiteralNow] == NSOrderedSame)) //IPAD-4596
     {
         sqlOperator = [self overrideOperatorTypeForDatetime:operator
                                                       value:rhsValue
                                                    operator:sqlOperator];
         
         if (sqlOperator == SQLOperatorGreaterThan)
         {
             literalValue = [NSString stringWithFormat:@"%@ 23:59:59", literalValue];
         }
         
         else if (sqlOperator == SQLOperatorLessThanEqualTo)
         {
             literalValue = [NSString stringWithFormat:@"%@ 23:59:59", literalValue];
         }
         else if (sqlOperator == SQLOperatorLike)
             
         {
             sqlOperator = SQLOperatorGreaterThanEqualTo;
             NSString *startTimeString = [NSString stringWithFormat:@"%@ 00:00:00", literalValue];
             NSString *endTimeString = [NSString stringWithFormat:@"%@ 23:59:59", literalValue];
             
             literalValue = startTimeString;

            // NSDate *newDate = [formatter dateFromString:endTimeString];
             //endTimeString = [DateUtil gmtStringFromDate:newDate inFormat:kDateFormatDefault];
             endTimeString = [self getGMTDateStringForDateString:endTimeString];//Fix:IPAD-4679

             innerCriteria = [[DBCriteria alloc] initWithFieldName:lhsValue operatorType:SQLOperatorLessThanEqualTo andFieldValue:endTimeString];
             advancedExpression = @"AND";
         }
         
         else if (sqlOperator == SQLOperatorNotEqualWithIsNull)
         {
             
             sqlOperator = SQLOperatorLessThan;
             NSString *startTimeString = [NSString stringWithFormat:@"%@ 00:00:00", literalValue];
             NSString *endTimeString = [NSString stringWithFormat:@"%@ 23:59:59", literalValue];
             
             literalValue = startTimeString;
             
             //NSDate *newDate = [formatter dateFromString:endTimeString];
             //endTimeString = [DateUtil gmtStringFromDate:newDate inFormat:kDateFormatDefault];
             endTimeString = [self getGMTDateStringForDateString:endTimeString];//Fix:IPAD-4679
             innerCriteria = [[DBCriteria alloc] initWithFieldName:lhsValue operatorType:SQLOperatorGreaterThan andFieldValue:endTimeString];
             
             emptyValueCriteria = [[DBCriteria alloc] initWithFieldName:lhsValue operatorType:SQLOperatorIsNull andFieldValue:nil];
         }
         
         else
         {
             literalValue = [NSString stringWithFormat:@"%@ 00:00:00", literalValue];
         }
         
         //NSDate *newDate = [formatter dateFromString:literalValue];
         //literalValue = [DateUtil gmtStringFromDate:newDate inFormat:kDateFormatDefault];
         literalValue = [self getGMTDateStringForDateString:literalValue];//Fix:IPAD-4679

     }
    else
    {
        sqlOperator = [self overrideOperatorTypeForMultipleValue:operator value:rhsValue operator:sqlOperator withFieldType:fieldType];
    }
    
    //if it is equal operator and ter (check the values parameter and rhs value check for if its more than one parameter)
    

    if (literalValue != nil) {
        rhsValue = literalValue;
    }
    
    if ((sqlOperator == SQLOperatorIn) || (sqlOperator == SQLOperatorNotIn))
    {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        NSArray *seperatedArray = [rhsValue componentsSeparatedByString:@","];
        for (NSString *eachRhsValue in seperatedArray) {
            NSString *finalValue = [eachRhsValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            [tempArray addObject:finalValue];
        }
        criteria = [[DBCriteria alloc]initWithFieldName:lhsValue operatorType:sqlOperator andFieldValues:tempArray];
    }
    else
    {
        criteria = [[DBCriteria alloc] initWithFieldName:lhsValue operatorType:sqlOperator andFieldValue:rhsValue];
        if(innerCriteria)
        {
            NSArray *innnerCriterias = (emptyValueCriteria)?@[innerCriteria, emptyValueCriteria]:@[innerCriteria];
            [criteria addOrCriterias:innnerCriterias withExpression:advancedExpression];
        }
    }
    
     criteria.isCaseInsensitive = YES;
     
    return criteria;
}

//Fix:IPAD-4679
-(NSString *)getGMTDateStringForDateString:(NSString *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *test = [dateFormatter dateFromString:localDate];
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    NSString *dateString = [dateFormatter stringFromDate:test];
    return dateString;
}



- (SQLOperator) sqlOperatorForSFOperator:(NSString *)sfOperator fieldType:(NSString *)fieldType
{
    SQLOperator sqlOperator = SQLOperatorNone;
    if([sfOperator isEqualToString:@"eq"] || [sfOperator isEqualToString:@"="])
    {
        if ( [fieldType caseInsensitiveCompare:kSfDTDate] == NSOrderedSame ||
             [fieldType caseInsensitiveCompare:kSfDTDateTime] == NSOrderedSame ) {
            sqlOperator = SQLOperatorLike;
        }
        else {
             sqlOperator = SQLOperatorEqual;
        }
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
        sqlOperator = SQLOperatorIn;//HS 24 Dec test
    }
    else if ([sfOperator isEqualToString:@"notin"])
    {
        sqlOperator = SQLOperatorNotLikeWithIsNull;
        
        if ([fieldType caseInsensitiveCompare:kSfDTReference] == NSOrderedSame || [fieldType caseInsensitiveCompare:kSfDTPicklist] == NSOrderedSame)
        {
            //sqlOperator = SQLOperatorNotLike;
            sqlOperator = SQLOperatorNotIn;//HS 24 Dec test
        }
    }
    else if ([sfOperator  isEqualToString:@"starts"])
    {
        sqlOperator = SQLOperatorStartsWith;
    }
    else if( [sfOperator  isEqualToString:@"isnull"])
    {
        sqlOperator = SQLOperatorIsNull;
    }
    return sqlOperator;
}

- (SQLOperator)overrideOperatorTypeForDatetime:(NSString *)sfOperator value:(NSString *)rhsValue
                                      operator:(SQLOperator)sqlOperator
{
    SQLOperator operator = sqlOperator;
    
    if (([rhsValue caseInsensitiveCompare:kLiteralNow] == NSOrderedSame) &&
        ([sfOperator isEqualToString:@"eq"] ||
         [sfOperator isEqualToString:@"="])  ) {
            sqlOperator = SQLOperatorEqual;
    }
    return operator;
}

//HS 18 Dec for issue Fix :013213
- (SQLOperator)overrideOperatorTypeForMultipleValue:(NSString *)sfOperator value:(NSString *)rhsValue
                                           operator:(SQLOperator)sqlOperator withFieldType:(NSString *)fieldType
{
    SQLOperator operator = sqlOperator;
    
   // if ([fieldType caseInsensitiveCompare:kSfDTPicklist])
    if ( [fieldType caseInsensitiveCompare:kSfDTPicklist] == NSOrderedSame
        || [fieldType caseInsensitiveCompare:kSfDTReference] == NSOrderedSame)

    {
        NSArray *rhsValues = [rhsValue componentsSeparatedByString:@","];
        
        if ([rhsValues count]>1 && ([sfOperator isEqualToString:@"eq"] || [sfOperator isEqualToString:@"="])
            )
        {
            //sqlOperator = SQLOperatorLike; //HS 24Dec fix for Equal support multiple value
            operator = SQLOperatorIn;
            
        }
        else if([rhsValues count]>1 && ([sfOperator isEqualToString:@"ne"] || [sfOperator isEqualToString:@"!="])
                )
        {
            //operator = SQLOperatorNotLikeWithIsNull;
            //if ([fieldType isEqualToString:kSfDTReference] || [fieldType isEqualToString:kSfDTPicklist] ||[fieldType isEqualToString:@"PICKLIST"]) {
                //sqlOperator = SQLOperatorNotLike; //HS 24Dec fix for Equal support multiple value
                operator  = SQLOperatorNotIn;
            //}
        }
    }
   
    return operator;
}


//HS 18 Dec ends here

- (NSString *) advanceExpression
{
    return self.expression.expression;
}


- (NSString *)valueOfLiteral:(NSString *)literal dataType:(NSString *)dataType
{
    if(![StringUtil isStringEmpty:literal])
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
            else if([literal caseInsensitiveCompare:kLiteralToday]== NSOrderedSame ||
                    [literal caseInsensitiveCompare:kLiteralSVMXNow]== NSOrderedSame )
            {
                literalValue = [Utility today:0 andJusDate:YES];
                if ([literalValue length] >= 10 ) {
                    literalValue = [literalValue substringToIndex:10];
                }
                
            }
            else if([literal caseInsensitiveCompare:kLiteralTomorrow]== NSOrderedSame)
            {
                literalValue = [Utility today:1 andJusDate:YES];
                if ([literalValue length] >= 10 ) {
                    literalValue = [literalValue substringToIndex:10];
                }
                
            }
            else if([literal caseInsensitiveCompare:kLiteralYesterday]== NSOrderedSame)
            {
                literalValue = [Utility today:-1 andJusDate:YES];
                if ([literalValue length] >= 10 ) {
                    literalValue = [literalValue substringToIndex:10];
                }
                
            }
            if ([dataType caseInsensitiveCompare:kSfDTDate] == NSOrderedSame){
                if ([literalValue length] >= 10 ) {
                    literalValue = [literalValue substringToIndex:10];
                }
            }
        }
        else
        {
            if(([literal caseInsensitiveCompare:kLiteralCurrentUser]== NSOrderedSame) || ([literal caseInsensitiveCompare:kLiteralOwner]== NSOrderedSame) || ([literal caseInsensitiveCompare:kLiteralCurrentUserId]== NSOrderedSame))
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
    return nil;
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
        
       NSString *dataType = [dataTypeUtil getDataTypeForObjectName:self.expression.sourceObjectName
                                                         fieldName:expComp.componentLHS];
        expComp.fieldType = dataType;
        
        DBCriteria *criteriaObj = [self criteriaForOperator:expComp.operatorValue
                                                   lhsValue:expComp.componentLHS
                                                   rhsValue:expComp.componentRHS
                                                  fieldType:expComp.fieldType];
        criteriaObj.dataType = expComp.fieldType;

        
        [self addInnerCriteria:criteriaObj expressionComponent:expComp];
        
        if (criteriaObj != nil) {
            [criteriaObjArray addObject:criteriaObj];
        }
        
    }
    return criteriaObjArray;
}

@end
