//
//  WhereClauseCreator.m
//  ServiceMaxMobile
//
//  Created by Shravya on 10/08/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import "WhereClauseCreator.h"
#import "DBCriteria.h"
#import "StringUtil.h"
#import "NSString+StringUtility.h"

@interface WhereClauseCreator ()

@property(nonatomic,strong) NSArray  *numberArray;
@property(nonatomic,strong) NSArray  *criteriaArray;
@property(nonatomic,strong) NSString  *expression;


@end

@implementation WhereClauseCreator

- (id)initWithCriteriaArray:(NSArray *)newCriteriaArray andAdvancedExpression:(NSString *)newExpression {
    self = [super init];
    if (self != nil) {
        self.numberArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
        self.criteriaArray = newCriteriaArray;
         self.expression = newExpression;
    }
    return self;
}

- (BOOL)isNumber:(NSString *)string {
    
    for (int counter = 0; counter < [self.numberArray count]; counter++) {
        if ([string isEqualToString:[self.numberArray objectAtIndex:counter]]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)generateAdvancedExpression {
    
    if ([self.criteriaArray count] > 0) {
        NSMutableString *someString = [[NSMutableString alloc] initWithFormat:@" 1 "];
        for (int counter = 2; counter <= [self.criteriaArray count]; counter++) {
            
             [someString appendFormat:@" AND %d ",counter];
            
        }
        //[someString appendString:@" ) "];
        return someString;
    }
    return nil;
}

- (NSString *)whereClause {
    
    @synchronized([self class]){
        @autoreleasepool {
            NSString *adavncedExpr = [self.expression lowercaseString];
            if (adavncedExpr.length <= 0) {
                adavncedExpr = [self generateAdvancedExpression];
            }
            NSInteger totalCharactersAdded = 0;
            NSMutableString *decodedString = [[NSMutableString alloc] initWithString:adavncedExpr];
            for (int counter = 0; counter < [adavncedExpr length]; counter++) {
                
                NSRange range = NSMakeRange(counter, 1);
                NSString *aCharacter = [adavncedExpr substringWithRange:range];
                if (![aCharacter isEqualToString:@""] && ![aCharacter isEqualToString:@" "]) {
                    
                    NSInteger someIntValue = [aCharacter intValue];
                    if (someIntValue > 0 && (counter + 1) < [adavncedExpr length]) {
                        NSRange rangeSecond = NSMakeRange(counter+1, 1);
                        NSString *aSecCharacter = [adavncedExpr substringWithRange:rangeSecond];
                        if ([self isNumber:aSecCharacter]) {
                            NSString *finChar =  [aCharacter stringByAppendingFormat:@"%@",aSecCharacter];
                            someIntValue = [finChar intValue];
                            aCharacter = finChar;
                            range.length = 2;
                            counter++;
                        }
                    }
                    if (someIntValue > 0 && [self.criteriaArray count] > (someIntValue - 1)  ) {
                        
                        DBCriteria *dbCriteria = [self.criteriaArray objectAtIndex:someIntValue - 1];
                        NSString *expression = [self getExpressionForCriteriaObject:dbCriteria];
                        if (![StringUtil isStringEmpty:expression]) {
                            
                            NSString *finalExpr = [NSString stringWithFormat:@" %@ ",expression];
                            
                            range.location = range.location + totalCharactersAdded;
                            [decodedString replaceOccurrencesOfString:aCharacter withString:finalExpr options:NSLiteralSearch range:range];
                            totalCharactersAdded = totalCharactersAdded + finalExpr.length - aCharacter.length;
                        }
                    }
                }
            }
            return decodedString;
        }
    }
}

- (NSString *)getExpressionForCriteriaObject:(DBCriteria *)dbCriteria {
    
    NSString *operatorString = [self getOperatorForType:dbCriteria.operatorType];
    
    NSString  *criteria = nil;
    NSString *rhsValue = [dbCriteria.rhsValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    NSString *tableName = @"";
    if (dbCriteria.tableName != nil) {
        tableName = [[NSString alloc] initWithFormat:@"'%@'.",dbCriteria.tableName];
    }
    else{
         tableName = [[NSString alloc] initWithFormat:@"'%@'.",self.primaryTable];
    }
    
    NSString *combinedQuery = [self getCombinedDbCriteria:dbCriteria];
    
    if ([dbCriteria innerQueryExists]) {
        
        NSString *innerQuery = [dbCriteria getInnerQuery];
        if (innerQuery.length > 2) {
            criteria = [[NSString alloc] initWithFormat:@" ( %@%@ %@ (%@ ) )",tableName,dbCriteria.lhsValue,operatorString,innerQuery];
        }
        if (combinedQuery != nil) {
            criteria = [[NSString alloc] initWithFormat:@"( %@ %@ )",criteria,combinedQuery];
        }
        return criteria;
    }
    else{
        if ([dbCriteria isBindingExist]) {
             criteria = [[NSString alloc] initWithFormat:@" ( %@%@ %@ :%@ )",tableName,dbCriteria.lhsValue,operatorString,dbCriteria.lhsValue];
            if (combinedQuery != nil) {
                criteria = [[NSString alloc] initWithFormat:@"( %@ %@ )",criteria,combinedQuery];
            }
             return criteria;
        }
    }
    
    
    
     switch (dbCriteria.operatorType) {
             
         case SQLOperatorIsNull:
         {
             criteria = [[NSString alloc] initWithFormat:@" (%@%@ IS NULL OR trim(%@) = '')",tableName,dbCriteria.lhsValue,dbCriteria.lhsValue];
         }
             break;
         case SQLOperatorIsNotNull:
         {
             criteria = [[NSString alloc] initWithFormat:@" (%@%@ IS NOT NULL AND trim(%@) != '')",tableName,dbCriteria.lhsValue,dbCriteria.lhsValue];
         }
         break;
           
         case SQLOperatorNotLikeWithIsNull:
        criteria = [[NSString alloc] initWithFormat:@" ( %@%@ %@ '%%%@%%'  OR %@%@ IS NULL OR trim(%@) = '')",tableName,dbCriteria.lhsValue,operatorString,rhsValue,tableName,dbCriteria.lhsValue,dbCriteria.lhsValue];
        break;
         case SQLOperatorNotEqualWithIsNull:
             criteria = [[NSString alloc] initWithFormat:@" ( %@%@ %@ '%@'  OR %@%@ IS NULL OR trim(%@) = '')",tableName,dbCriteria.lhsValue,operatorString,rhsValue,tableName,dbCriteria.lhsValue,dbCriteria.lhsValue];
        break;
         case SQLOperatorLike:
         case SQLOperatorNotLike:
         {
             criteria = [[NSString alloc] initWithFormat:@" ( %@%@ %@ '%%%@%%' )",tableName,dbCriteria.lhsValue,operatorString,rhsValue];
         }
             break;
         case SQLOperatorStartsWith:
         {
             criteria = [[NSString alloc] initWithFormat:@" ( %@%@ %@ '%@%%' )",tableName,dbCriteria.lhsValue,operatorString,rhsValue];
         }
             break;
         case SQLOperatorEndsWith:
         {
             criteria = [[NSString alloc] initWithFormat:@" ( %@%@ %@ '%%%@' )",tableName,dbCriteria.lhsValue,operatorString,rhsValue];
         }
         break;
         case SQLOperatorBetween:
         {
             NSString *value1 = nil,*value2 = nil;
             if ([dbCriteria.rhsValues count] > 0) {
                 value1 = [dbCriteria.rhsValues objectAtIndex:0];
                 value1 = [value1 stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
             }
             if ([dbCriteria.rhsValues count] > 1) {
                 value2 = [dbCriteria.rhsValues objectAtIndex:1];
                 value2 = [value2 stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
             }
             
             criteria = [[NSString alloc] initWithFormat:@" ( %@%@ %@ '%@' AND '%@' )",tableName,dbCriteria.lhsValue,operatorString,value1,value2];
         }
             break;
         case SQLOperatorIn:
         case SQLOperatorNotIn:
         {
             NSString *valuesString =  [StringUtil getConcatenatedStringFromArray:dbCriteria.rhsValues withSingleQuotesAndBraces:YES];
             criteria = [[NSString alloc] initWithFormat:@" ( %@%@ %@ %@ )",tableName,dbCriteria.lhsValue,operatorString,valuesString];
             break;
         }
         default:
         {
             
             criteria = [[NSString alloc] initWithFormat:@" ( %@%@ %@ '%@' )",tableName,dbCriteria.lhsValue,operatorString,rhsValue];
         }
     }
    
    if (combinedQuery != nil) {
        criteria = [[NSString alloc] initWithFormat:@"( %@ %@ )",criteria,combinedQuery];
    }
    return criteria;
}

- (NSString *)getCombinedDbCriteria:(DBCriteria *)mainDbCriteria {
    NSArray *subCriterias = [mainDbCriteria getSubCriterias];
    NSString *advancedExpression = [mainDbCriteria getAdavncedExpression];
    
    NSString *orCondition = @"OR";
    
    if (advancedExpression.length > 0) {
        orCondition = @"AND";
    }
    if ([subCriterias count] > 0) {
        
        NSMutableString *expressionString = [[NSMutableString alloc] init];
        
        for (DBCriteria *subC in subCriterias) {
            
            NSString *expression = [self getExpressionForCriteriaObject:subC];
            if (expression != nil) {
                [expressionString appendFormat:@" %@ %@ ",orCondition,expression];
            }
        }
        return expressionString;
    }
    return nil;
}

- (NSString *)getOperatorForType:(SQLOperator)operatorType {
    NSString *operator;
    
    switch (operatorType) {
        case SQLOperatorEqual:
            operator = (NSString *)kSqlOperatorEqual;
            break;
        case SQLOperatorNotEqual:
            operator = (NSString *)kSqlOperatorNotEqual;
            break;
        case SQLOperatorLessThan:
            operator = (NSString *)kSqlOperatorLessThan;
            break;
        case SQLOperatorGreaterThan:
            operator = (NSString *)kSqlOperatorGreaterThan;
            break;
        case SQLOperatorGreaterThanEqualTo:
            operator = (NSString *)kSqlOperatorGreaterThanEqualTo;
            break;
        case SQLOperatorLike:
            operator = (NSString *)kSqlOperatorLike;
            break;
        case SQLOperatorIn:
            operator = (NSString *)kSqlOperatorIn;
            break;
        case SQLOperatorNotIn:
            operator = (NSString *)kSqlOperatorNotIn;
            break;
        case SQLOperatorBetween:
            operator = (NSString *)kSqlOperatorBetween;
            break;
        case SQLOperatorIsNull:
            operator = (NSString *)kSqlOperatorIsNull;
            break;
        case SQLOperatorIsNotNull:
            operator = (NSString *)kSqlOperatorIsNotNull;
            break;
        case SQLOperatorStartsWith:
            operator = (NSString *)kSqlOperatorLike;
            break;
        case SQLOperatorEndsWith:
            operator = (NSString *)kSqlOperatorLike;
            break;
        case SQLOperatorNotLike:
            operator = (NSString *)kSqlOperatorNotLike;
            break;
        case SQLOperatorNotLikeWithIsNull:
            operator = (NSString *)kSqlOperatorNotLike;
            break;
        case SQLOperatorNotEqualWithIsNull:
            operator = (NSString *)kSqlOperatorNotEqual;
            break;
        case SQLOperatorLessThanEqualTo:
            operator = (NSString *)kSqlOperatorLessThanEqualTo;
            break;
       default:
             operator = (NSString *)kSqlOperatorLike;
            break;
    
    }
   return operator;
}


@end
