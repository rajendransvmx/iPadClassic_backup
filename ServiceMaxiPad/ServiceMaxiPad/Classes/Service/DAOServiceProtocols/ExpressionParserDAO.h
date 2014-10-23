//
//  ExpressionParserDAO.h
//  ServiceMaxMobile
//
//  Created by Aparna on 18/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//


@protocol ExpressionParserDAO <NSObject>

- (BOOL) isRecordExistWithId:(NSString *)recordId
                  objectName:(NSString *)objectName
                    criteria:(NSArray *)criteriaArray
           advanceExpression:(NSString *)expression;

@end