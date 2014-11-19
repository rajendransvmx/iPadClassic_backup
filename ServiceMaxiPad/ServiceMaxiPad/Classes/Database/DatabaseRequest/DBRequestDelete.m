//
//  DBRequestDelete.m
//  ServiceMaxMobile
//
//  Created by Shravya on 10/08/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "DBRequestDelete.h"
#import "DBField.h"

@implementation DBRequestDelete

- (id)initWithTableName:(NSString *)tableName
          whereCriteria:(NSArray *)criteriaArray
   andAdvanceExpression:(NSString *)advanceExpression{

    self = [super init];
    if (self != nil) {
        [self setObjectTableName:tableName];
        
        if ([criteriaArray count] > 0) {
            [self setCriteria:criteriaArray andExpression:advanceExpression];
        }
    }
    return self;
}

- (id)initWithTableName:(NSString *)tableName {
    self = [super init];
    if (self != nil) {
         [self setObjectTableName:tableName];
    }
    return self;
}

- (NSString *)query {
    @synchronized([self class]){
        
        @autoreleasepool {
            NSMutableString *query = [[NSMutableString alloc] initWithFormat:@"DELETE FROM '%@' ",self.tableName];
            
            
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
                [query appendFormat:@" LIMIT %d OFFSET %d ",self.limit ,self.offSet];
            }
            
            return query;
        }
    }
}

@end
