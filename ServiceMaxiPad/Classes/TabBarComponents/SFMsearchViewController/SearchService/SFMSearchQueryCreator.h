//
//  SFMSearchQueryCreator.h
//  ServiceMaxiPhone
//
//  Created by Shravya shridhar on 7/1/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMSearchObjectModel.h"

@interface SFMSearchQueryCreator : NSObject


- (id)initWithSearchObject:(SFMSearchObjectModel*)newSearchObject
       withOuterJoinTables:(NSDictionary *)outerJoinTables;
- (NSString *)generateQuery:(NSString *)expression andSearchText:(NSString *)searchString;
- (NSString *)generateQueryForReference:(SFMSearchObjectModel *)searchObject searchString:(NSString *)searchString expression:(NSString *)expression dataArray:(NSArray *)dataArray;

@end
