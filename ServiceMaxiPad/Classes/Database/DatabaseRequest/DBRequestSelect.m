//
//  DBRequestSelect.m
//  ServiceMaxMobile
//
//  Created by Shravya on 10/08/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "DBRequestSelect.h"
#import "NSString+StringUtility.h"
#import "JoinObject.h"

@interface DBRequestSelect()

@property(nonatomic,assign)BOOL distinctRows;
@property(nonatomic,strong)NSString *distinctField;
@property(nonatomic,assign) SQLAggregateFunction aggregateFunction;
@property(atomic,assign)BOOL aggregateFunctionExists;
@property(nonatomic,strong)DBField *aggregateField;

@property(nonatomic,strong)NSMutableDictionary *joinTablesDict;

@end

@implementation DBRequestSelect


#pragma mark - Private functions
- (id)init{
    self = [super init];
    if (self != nil) {
    }
    return self;
}

- (BOOL)initAllVariables:(NSString *)tableName
                  fields:(NSArray *)fields
           criteriaArray:(NSArray *)crtierias
   andAdavncedExpression:(NSString *)expression {
    
    @synchronized([self class]){
        id someSelf;
        someSelf = [self init];
        
        if (self != nil) {
            
            [self setObjectTableName:tableName];
            [self setFields:fields];
            
            if ([crtierias count] > 0) {
                return  [self setCriteria:crtierias andExpression:expression];
            }
            
        }
        return YES;
    }
}



#pragma mark - End

#pragma mark - Initialize functions
- (id)initWithTableName:(NSString *)newTableName {
    [self initAllVariables:newTableName fields:nil criteriaArray:nil andAdavncedExpression:nil];
    return self;
}

- (id)initWithTableName:(NSString *)newTableName
          andFieldNames:(NSArray *)newFieldNames {
    [self initAllVariables:newTableName fields:newFieldNames criteriaArray:nil andAdavncedExpression:nil];
    return self;
}

- (id)initWithTableName:(NSString *)tableName
          andFieldNames:(NSArray *)fieldNames
          whereCriteria:(DBCriteria *)criteria{
    [self initAllVariables:tableName fields:fieldNames
             criteriaArray:[[NSArray alloc]
                            initWithObjects:criteria, nil] andAdavncedExpression:nil];
    return self;
}
- (id)initWithTableName:(NSString *)tableName
         whereCriterias:(NSArray *)criteriaArray
   andAdvanceExpression:(NSString *)advanceExpression{
    [self initAllVariables:tableName fields:nil criteriaArray:criteriaArray andAdavncedExpression:advanceExpression];
    return self;
}

- (id)initWithTableName:(NSString *)tableName
          andFieldNames:(NSArray *)fieldNames
         whereCriterias:(NSArray *)criteriaArray
   andAdvanceExpression:(NSString *)advanceExpression{
    [self initAllVariables:tableName fields:fieldNames criteriaArray:criteriaArray andAdavncedExpression:advanceExpression];
    return self;
}

- (id)initWithTableName:(NSString *)tableName
        andFieldObjects:(NSArray *)fieldObjects
         whereCriterias:(NSArray *)criteriaArray
   andAdvanceExpression:(NSString *)advanceExpression {
    [self initAllVariables:tableName fields:fieldObjects criteriaArray:criteriaArray andAdavncedExpression:advanceExpression];
    return self;
}

- (id)initWithTableName:(NSString *)tableName
      aggregateFunction:(SQLAggregateFunction)newAggregateFunction
         whereCriterias:(NSArray *)criteriaArray
   andAdvanceExpression:(NSString *)advanceExpression {
    self.aggregateFunction = newAggregateFunction;
    self.aggregateFunctionExists = YES;
    [self initAllVariables:tableName fields:nil criteriaArray:criteriaArray andAdavncedExpression:advanceExpression];
    return self;
}
- (id)initWithField:(DBField *)field
  aggregateFunction:(SQLAggregateFunction)newAggregateFunction
     whereCriterias:(NSArray *)criteriaArray
andAdvanceExpression:(NSString *)advanceExpression {
    
    self.aggregateFunction = newAggregateFunction;
    self.aggregateField = field;
    self.aggregateFunctionExists = YES;
    [self initAllVariables:field.tableName fields:nil criteriaArray:criteriaArray andAdavncedExpression:advanceExpression];
    return self;
}

- (void)setDistinctRowsOnly {
    self.distinctRows = YES;
}
- (void)setDistinctRowsOnField:(NSString *)newDistinctField {
    @synchronized([self class]){
        self.distinctRows = YES;
        self.distinctField = newDistinctField;
    }
}
#pragma mark - End

#pragma mark - Overriden functions
- (BOOL)hasFields {
    if ([self.fieldNames count] > 0 || [self.fieldObjects count] > 0 ) {
        return YES;
        
    }
    return NO;
}

- (NSString *)getFieldString {
    if ([self.fieldNames count] > 0) {
        return [self getFieldNamesSeperatedByCommas];
    }
    else if ([self.fieldObjects count] > 0 ){
        return [self getFieldNamesWithTableNameSeparatedByCommas];
    }
    return nil;
}

- (NSString *)getJoinString {
    if ([self.joinTablesDict count] > 0) {
        return [self getLeftOuterJoinPart];
    }
    return nil;
}

- (NSArray *)getRearrangedArray {
    @synchronized([self class]){
        return nil;
    }
}


// 012895
-(void)addJoinString:(NSString *)ajoinString {
    self.joinString = ajoinString;
}

- (NSString *)getAggregateFunction:(SQLAggregateFunction)functionType{
    
    NSString *functionName = nil;
    switch (functionType) {
        case SQLAggregateFunctionCount:
            functionName = (NSString *)kSQLAggregateFunctionCount;
            break;
        case SQLAggregateFunctionSum:
            functionName = (NSString *)kSQLAggregateFunctionSum;
            break;
        case SQLAggregateFunctionAvg:
            functionName = (NSString *)kSQLAggregateFunctionAvg;
            break;
        case SQLAggregateFunctionTotal:
            functionName = (NSString *)kSQLAggregateFunctionTotal;
            break;
        case SQLAggregateFunctionMax:
            functionName = (NSString *)kSQLAggregateFunctionMax;
            break;
        default:
            break;
    }
    return functionName;
}
- (NSString *)query {
    @synchronized([self class]){
        
        @autoreleasepool {
            NSMutableString *query = [[NSMutableString alloc] initWithString:@"SELECT "];
            
            
            if (self.aggregateFunctionExists) {
                NSString *functionName = [self getAggregateFunction:self.aggregateFunction];
                if (self.aggregateField.name != nil) {
                    if (self.distinctRows) {
                        [query appendFormat:@" %@(DISTINCT %@) ",functionName,self.aggregateField.name];
                    }
                    else{
                        [query appendFormat:@" %@(%@) ",functionName,self.aggregateField.name];
                    }
                }
                else{
                    [query appendFormat:@" %@(*) ",functionName];
                }
            }
            else{
                if ([self hasFields]) {
                    
                    NSString *distinctFieldName = @"",*distinctClause = @"";
                    if (self.distinctRows) {
                        distinctClause = @"DISTINCT";
                        if (self.distinctField.length > 1) {
                            distinctFieldName = [[NSString alloc] initWithFormat:@" %@, ",self.distinctField];
                        }
                    }
                    NSString *fieldString = [self getFieldString];
                    [query appendFormat:@" %@ %@ %@ ",distinctClause,distinctFieldName,fieldString];
                }
                else{
                    [query appendString:@" * "];
                }
            }
            
            /* Adding from clause */
            [query appendFormat:@" FROM '%@' ",self.tableName];
            
            /* Add join statements */
            NSString *joinString = [self getJoinString];
            if (joinString != nil) {
                [query appendFormat:@" %@",joinString];
            }
            
            // 012895
            if ([self.joinString length] > 0) {
                [query appendString:self.joinString];
            }
            
            /* Add where clause if exist */
            NSString *whereClause = [self whereClause];
            if (whereClause != nil) {
                [query appendFormat:@" WHERE ( %@ )",whereClause];
            }
            
            
            
            /* Add group by */
            NSString *groupByString = [self getGroupByString];;
            if (groupByString != nil) {
                [query appendFormat:@" GROUP BY %@ ",groupByString];
            }
            
            /* Add order by if exist */
            NSString *orderByString = [self getOrderByString];
            if (orderByString != nil) {
                [query appendFormat:@" ORDER BY %@ ",orderByString];
            }
            
            
            /* Add LIMIT and OFFSET  */
            if (self.limit != 0) {
                [query appendFormat:@" LIMIT %ld OFFSET %ld ",(long)self.limit ,(long)self.offSet];
            }
            //NSLog(@"QUERY : %@",query);
            return query;
        }
    }
}

#pragma mark -End

#pragma mark - Adding join tables

- (void)addJoinTables:(NSArray *)joinTables {
    
    if (self.joinTablesDict == nil) {
        self.joinTablesDict = [[NSMutableDictionary alloc] init];
    }
    
    for (JoinObject *jObject in joinTables) {
        
        JoinObject *oldJoinObject = [self.joinTablesDict objectForKey:jObject.objectName];
        if (oldJoinObject == nil) {
            [self.joinTablesDict setObject:jObject forKey:jObject.objectName];
        }
        else{
            for (NSString *fieldName in jObject.leftFieldNames) {
                [oldJoinObject addFieldName:fieldName];
            }
        }
    }
}

- (void)addLeftOuterJoinTable:(NSString *)joinTableName
     andPrimaryTableFieldName:(NSString *)leftFieldName {
    
    if (self.joinTablesDict == nil) {
        self.joinTablesDict = [[NSMutableDictionary alloc] init];
    }
    JoinObject *oldJoinObject = [self.joinTablesDict objectForKey:joinTableName];
    if (oldJoinObject == nil) {
        JoinObject *joinObject = [[JoinObject alloc] initWithObjectName:joinTableName andLeftFieldName:leftFieldName];
        [self.joinTablesDict setObject:joinObject forKey:joinTableName];
    }
    else{
        [oldJoinObject addFieldName:leftFieldName];
        
    }
}

#pragma mark -End

#pragma mark - Preparing Left Outer join query

- (NSString *)getLeftOuterJoinPart{
    
    NSMutableString *outerJoinString = [[NSMutableString alloc] init];
    NSString *sqliteString = @" LEFT OUTER JOIN ";
    
    NSArray *outerJoinObjects = [self.joinTablesDict allValues];
    
    for (JoinObject *joinObject in outerJoinObjects) {
        
        NSString *fieldMappingString = [self getFieldStringForFields:joinObject.leftFieldNames andObjectName:joinObject.objectName];
        [outerJoinString appendFormat:@" %@ '%@' on ( %@ ) " ,sqliteString, joinObject.objectName,fieldMappingString];
    }
    if (outerJoinString.length > 0) {
        return outerJoinString;
    }
    return nil;
}

- (NSString *)getFieldStringForFields:(NSArray *)fieldNames
                        andObjectName:(NSString *)joinObjectName {
    
    NSString *globalObjectName = self.objectName;
    NSMutableString *fieldNameString = [[NSMutableString alloc] init];
    
    int i = 0;
    for (NSString *fieldName in fieldNames) {
        if (i == 0) {
            [fieldNameString appendFormat:@" '%@'.'%@' = '%@'.'%@' ",globalObjectName,fieldName,joinObjectName,kId];
        }
        else{
            [fieldNameString appendFormat:@" OR '%@'.'%@' = '%@'.'%@' ",globalObjectName,fieldName,joinObjectName,kId];
        }
        i++;
    }
    return fieldNameString;
}
#pragma mark -End

- (BOOL)isJoinExists {
    if ([self.joinTablesDict count] > 0) {
        return YES;
    }
    return NO;
}

@end
