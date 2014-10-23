//
//  DBRequest.m
//  ServiceMaxMobile
//
//  Created by Shravya shridhar on 8/8/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import "DBRequest.h"
#import "DBField.h"
#import "StringUtil.h"
#import "WhereClauseCreator.h"


@interface DBRequest()

@property(nonatomic,assign)SQLOrderByType defaultOrderByType;
@property(nonatomic,strong) NSArray     *orderByFields;
@property(nonatomic,strong) NSArray     *groupByFields;

@end

@implementation DBRequest

- (id)init {

    self = [super init];
    if (self != nil) {
        
    }
    return self;
}


#pragma mark - Setter and getter functions to access private variables from derived class

- (void)setRequestType:(DBRequestQueryType)queryType {
    self.requestQueryType = queryType;
}

- (void)setObjectTableName:(NSString *)newTableName {
    self.tableName = newTableName;
}
- (NSString *)objectName {
    return self.tableName;
}

- (void)setFields:(NSArray *)fields {
    @synchronized([self class]) {
        if ([fields count] > 0) {
            
            id fieldObj = [fields objectAtIndex:0];
            if ([fieldObj isKindOfClass:[NSString class]]) {
                self.fieldNames = fields;
            }
            else{
                self.fieldObjects = fields;
            }
        }

    }
}

- (NSArray *)fields {
    if ([self.fieldNames count] > 0) {
        return self.fieldNames;
    }
    return self.fieldObjects;
}

- (BOOL)setCriteria:(NSArray *)criterias
      andExpression:(NSString *)expression {
     @synchronized([self class]) {
            self.criteriaArray = criterias;
            self.advancedExpression = expression;
            return [self isValidExpression];
     }
    
}


- (void)addOrderByFields:(NSArray *)newfields andDefaultOrderByOrder:(SQLOrderByType)newDefaultOrderType{
    self.orderByFields = newfields;
    self.defaultOrderByType = newDefaultOrderType;
    
}

- (void)addOrderByFields:(NSArray *)newfields {
    self.orderByFields = newfields;
    self.defaultOrderByType = SQLOrderByTypesAscending;
    
}

- (void)addGroupByFields:(NSArray *)fieldNames {
     self.groupByFields= fieldNames;
}

- (NSString *)getGroupByString {
    if (self.requestQueryType != DBRequestQueryTypeInsert) {
          return  [StringUtil getConcatenatedStringFromArray:self.groupByFields withSingleQuotesAndBraces:NO];
    }
    return nil;
}

- (NSString *)getOrderByString {
    
     if (self.requestQueryType != DBRequestQueryTypeInsert) {
        
         if ([self.orderByFields count] > 0) {
                id instanceVar = [self.orderByFields objectAtIndex:0];
             if ([instanceVar isKindOfClass:[NSString class]]) {
                 return  [StringUtil getConcatenatedStringFromArray:self.orderByFields withSingleQuotesAndBraces:NO];
             }
             else{
                 return [self getOrderByStringFromDbFields];
             }
             
         }
         
     }
    return nil;
}

- (NSString *)getOrderByStringFromDbFields {
    NSMutableString *orderByString = [[NSMutableString alloc] init];
    
    NSString *defaultsortOrder = (NSString *)kSQLOrderByTypeAscending;
    if (self.defaultOrderByType == SQLOrderByTypesDescending) {
        defaultsortOrder = (NSString *)kSQLOrderByTypeDescending;
    }
    NSString *sortOrder = nil;
    NSInteger totalCount =  [self.orderByFields   count];
    for (int counter = 0;counter < totalCount;counter++) {
        DBField *sortField = [self.orderByFields objectAtIndex:counter];
        
        if (sortField.orderType == SQLOrderByTypesDescending) {
            sortOrder = (NSString *)kSQLOrderByTypeDescending;
        }
        else if (sortField.orderType == SQLOrderByTypesAscending) {
            sortOrder = (NSString *)kSQLOrderByTypeAscending;
        }
        else{
            sortOrder = defaultsortOrder;
        }
        
        [orderByString appendFormat:@" '%@'.%@ COLLATE NOCASE %@ ",sortField.tableName,sortField.name,sortOrder];
        if (counter != (totalCount - 1)) {
            [orderByString appendString:@" , "];
        }
    }
    return orderByString;
}


- (void)addLimit:(NSInteger )newLimit andOffSet:(NSInteger)newOffSet{
    self.limit = newLimit;
    self.offSet = newOffSet;
}
#pragma mark -end

#pragma mark - checks whether given advanced expression is valid based on the components
- (BOOL)isValidExpression{
    return YES;
}

- (BOOL)isJoinExists {
    return NO;
}
- (NSString *)getFieldNamesSeperatedByCommas {
  
    if ([self isJoinExists]) {
        NSMutableString *concatenatedString = [[NSMutableString alloc] init];
        for (int counter = 0; counter < [self.fieldNames count]; counter++) {
            
            NSString *fName = [self.fieldNames objectAtIndex:counter];
            NSString *tableNameStr = self.tableName;
            if (counter == 0) {
                [concatenatedString appendFormat:@"%@.%@",tableNameStr,fName ];
            }
            else{
                [concatenatedString appendFormat:@",%@.%@",tableNameStr,fName];
            }
        }
        return  concatenatedString;
    }
    
   return  [StringUtil getConcatenatedStringFromArray:self.fieldNames withSingleQuotesAndBraces:NO];
}

- (NSString *)getFieldNamesWithTableNameSeparatedByCommas {
    NSMutableString *concatenatedString = [[NSMutableString alloc] init];
    
    if (self.requestQueryType == DBRequestQueryTypeInsert) {
        NSMutableArray *fieldNames = [[NSMutableArray alloc] init];
        for (int counter = 0; counter < [self.fieldObjects count]; counter++) {
            DBField *aField = [self.fieldObjects objectAtIndex:counter];
            [fieldNames addObject:aField.name];
        }
       return [StringUtil getConcatenatedStringFromArray:fieldNames withSingleQuotesAndBraces:YES];
    }
    else{
        for (int counter = 0; counter < [self.fieldObjects count]; counter++) {
            
            DBField *aField = [self.fieldObjects objectAtIndex:counter];
            NSString *tableNameStr = (aField.tableName < 0)?self.tableName:aField.tableName;
            if (counter == 0) {
                [concatenatedString appendFormat:@"%@.%@",tableNameStr,aField.name ];
            }
            else{
                [concatenatedString appendFormat:@",%@.%@",tableNameStr,aField.name];
            }
        }

    }
    return concatenatedString;
}
#pragma mark -end


#pragma mark - returns the query based on all the parameters
- (NSString *)query {
    return nil;
}

- (NSString *)whereClause {
    
    @synchronized([self class]){
        if ([self.criteriaArray count] > 0) {
            
            WhereClauseCreator *whereClauseeCreator = [[WhereClauseCreator alloc] initWithCriteriaArray:self.criteriaArray andAdvancedExpression:self.advancedExpression];
            return [whereClauseeCreator whereClause];
            
        }
        return nil;
    }
}



@end
