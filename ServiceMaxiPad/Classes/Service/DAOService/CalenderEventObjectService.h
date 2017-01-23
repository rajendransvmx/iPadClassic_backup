//
//  CalenderEventObjectService.h
//  ServiceMaxMobile
//
//  Created by Sudguru Prasad on 07/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "CommonServices.h"
#import "CalenderDAO.h"

@interface CalenderEventObjectService : CommonServices <CalenderDAO>


//- (NSArray*)getRecordsFromQuery:(NSString*)query;

//- (NSArray *)fetchDataForObject:(NSString *)objectName  fields:(NSArray *)fieldNames expression:(NSString *)advancaeExpression criteria:(NSArray *)criteria;

- (NSArray*)getRecordsFromTheQuery:(DBRequestSelect *)selectQuery;

-(BOOL)updateEachRecord:(NSDictionary *)dictionary  withFields:(NSArray *)fieldsArray withCriteria:(NSArray *)criteriaArray withTableName:(NSString *)tableName;

@end
