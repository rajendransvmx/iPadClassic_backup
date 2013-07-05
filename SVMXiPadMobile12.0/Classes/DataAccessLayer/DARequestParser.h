//
//  DARequestParser.h
//  JavascriptInterface
//
//  Created by Shravya shridhar on 4/22/13.
//  Copyright (c) 2013 Shravya shridhar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DARequest.h"
@interface DARequestParser : NSObject {
    
    NSArray *numberArray ;
}

@property(nonatomic,retain)NSArray *numberArray ;

- (NSString *)selectSqliteQueryRepresentationOfDARequest:(DARequest *)requestObject;
- (NSString *)decodeAdvanceExpression:(NSString *)newAdvanceExpression andExpressionArray:(NSArray *)expressionArray;
- (NSString *)insertSqliteQueryRepresentationOfDARequest:(DARequest *)requestObject ;
- (NSString *)updateSqliteQueryRepresentationOfDARequest:(DARequest *)requestObject;
- (NSString *)deleteSqliteQueryRepresentationOfDARequest:(DARequest *)requestObject;
- (NSMutableDictionary *)parseJsonToSqlFunction:(NSArray *)allObjects
                                    andRecordId:(NSString *)recordIdentifier
                            andRecordDictionary:(NSDictionary *)recordDictionary;
- (NSArray *)parseFieldsFromQuery:(NSString *)query;
- (NSDictionary *)getOperatorForString:(NSDictionary *)criterion;
- (BOOL)isNumber:(NSString *)string;
@end
