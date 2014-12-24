//
//  ChatterPostParser.m
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 19/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "ChatterPostParser.h"
#import "ZKSQueryRequest.h"
#import "ZKSObject.h"
#import "ChatterHelper.h"

@implementation ChatterPostParser

- (ResponseCallback*)parseResponseWithRequestParam:(RequestParamModel*)requestParamModel responseData:(id)responseData {
    @synchronized([self class]){
        @autoreleasepool {
            
            NSMutableArray *resultSet = [NSMutableArray new];
            
            if ([responseData isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *response = (NSDictionary *)responseData;
                
                ZKQueryResult *queryresult = [response objectForKey:@"result"];
                NSArray *records = [queryresult records];
                
                for (ZKSObject *obj in records) {
                    
                    NSDictionary *fields = [obj fields];
                    
                    NSString *createdId = [fields objectForKey:@"CreatedById"];
                    
                    if (![resultSet containsObject:createdId]) {
                        [resultSet addObject:createdId];
                    }
                    ZKQueryResult *feeds = [fields objectForKey:@"FeedComments"];
                    resultSet = [self fillUserIdForFeedComments:feeds array:resultSet];
                }
            }
            [self pushUserIdsTochache:resultSet];
        }
    }
    return nil;
}

- (NSMutableArray *)fillUserIdForFeedComments:(ZKQueryResult *)feeds array:(NSMutableArray *)resultSet
{
    if ((feeds != nil) && ![feeds isKindOfClass:[NSNull class]]) {
        
        for (ZKSObject *feedData in [feeds records]) {
            NSDictionary *fields = [feedData fields];
            
            NSString *createdId = [fields objectForKey:@"CreatedById"];
            if (![resultSet containsObject:createdId]) {
                [resultSet addObject:createdId];
            }
        }
    }
    return resultSet;
}

- (void)pushUserIdsTochache:(NSArray *)resultSet
{
    NSString *idSeparetedByComas = nil;
    
    if ([resultSet count] > 1)
    {
        NSString *baseString = [resultSet componentsJoinedByString:@"','"];
        idSeparetedByComas = [NSString stringWithFormat:@"'%@'", baseString];
    }
    else
    {
        idSeparetedByComas = [NSString stringWithFormat:@"'%@'", [resultSet objectAtIndex:0]];
    }
    
    [ChatterHelper pushDataToCahcche:idSeparetedByComas forKey:@"ChatterPostIds"];
    
}

@end
