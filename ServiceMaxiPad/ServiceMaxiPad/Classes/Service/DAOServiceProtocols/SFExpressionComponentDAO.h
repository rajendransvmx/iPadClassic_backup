//
//  SFExpressionComponentDAO.h
//  ServiceMaxMobile
//
//  Created by Aparna on 19/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//
#import "CommonServiceDAO.h"
#import <Foundation/Foundation.h>

@protocol SFExpressionComponentDAO <CommonServiceDAO>

- (NSArray *) getExpressionComponentsBySFId:(NSString *)expSFId;
- (NSArray * )fetchSfExpressionComponentInfoByFields:(NSArray *)fieldNames
                                         andCriteria:(DBCriteria *)criteria;


@end
