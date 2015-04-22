//
//  DBRequestUpdate.m
//  ServiceMaxMobile
//
//  Created by Shravya on 10/08/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "DBRequestUpdate.h"
#import "DBField.h"

@implementation DBRequestUpdate

- (id)initWithTableName:(NSString *)tableName
        andFieldNames:(NSArray *)fieldNames{
    self = [super init];
    if (self != nil) {
        [self setObjectTableName:tableName];
        [self setFields:fieldNames];
         
    }
    return self;

}

//- (id)initWithTableName:(NSString *)tableName
//           andFieldObjects:(NSArray *)fieldObjects
//          whereCriteria:(NSArray *)criteriaArray
//   andAdvanceExpression:(NSString *)advanceExpression {
//    self = [super init];
//    if (self != nil) {
//        [self setObjectTableName:tableName];
//        [self setFields:fieldObjects];
//        
//        if ([criteriaArray count] > 0) {
//            [self setCriteria:criteriaArray andExpression:advanceExpression];
//        }
//    }
//    return self;
//}

- (id)initWithTableName:(NSString *)tableName
          andFieldNames:(NSArray *)fieldNames
          whereCriteria:(NSArray *)criteriaArray
   andAdvanceExpression:(NSString *)advanceExpression{
    self = [super init];
    if (self != nil) {
        [self setObjectTableName:tableName];
        [self setFields:fieldNames];
        
        if ([criteriaArray count] > 0) {
            [self setCriteria:criteriaArray andExpression:advanceExpression];
        }
    }
    return self;
}
- (NSString *)query {
    @synchronized([self class]){
        
        @autoreleasepool {
            NSMutableString *query = [[NSMutableString alloc] initWithFormat:@"UPDATE '%@' ",self.tableName];
            
            if ([[self fieldNames] count] > 0) {
                
                [query appendString:@" SET "];
                for (int counter = 0; counter < [self.fieldNames count]; counter++) {
                    NSString *fieldName = [self.fieldNames objectAtIndex:counter];
                    
                    if (counter == 0) {
                        [query appendFormat:@" %@ = :%@",fieldName,fieldName];
                    }
                    else {
                        [query appendFormat:@", %@ = :%@",fieldName,fieldName];
                    }
                }
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
            if (self.limit > 0) {
                [query appendFormat:@" LIMIT %ld OFFSET %ld ",(long)self.limit ,(long)self.offSet];
            }

            return query;
        }
    }
}

@end
