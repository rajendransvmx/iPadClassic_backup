//
//  SFRecordTypeDAO.h
//  ServiceMaxMobile
//
//  Created by Aparna on 20/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
@class SFRecordTypeModel;

@protocol SFRecordTypeDAO <CommonServiceDAO>

- (NSArray * )fetchSFRecordTypeByFields:(NSArray *)fieldNames andCriteria:(id)criteria;
- (NSArray * )fetchSFRecordTypeInfoByFields:(NSArray *)fieldNames
                                andCriteria:(NSArray *)criteria
                              andExpression:(NSString *)expression;
- (SFRecordTypeModel *) getSFRecordTypeBySFId:(NSString *)sfId;
- (NSArray*)fetchObjectAPINames;
- (NSMutableArray *)fetchSFRecordTypeByIdS;

-(void)updateRecordTypeLabels:(NSArray *)recordTypeModels;
//Madhusudhan, #024488 Record type value should be displayed in user language.
- (NSString * )fetchSFRecordTypeDisplayName:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria;
@end
