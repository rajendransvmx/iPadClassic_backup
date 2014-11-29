//
//  ProductManualDAO.h
//  ServiceMaxiPad
//
//  Created by Chinnababu on 06/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"

@protocol ProductManualDAO <CommonServiceDAO>

- (void)insertIntoDBWithObjectName:(NSString *)objectName
                      andSfIdArray:(NSArray *)sfIdArray;

- (NSArray * )fetchRecordsByFields:(NSArray *)fieldNames
                       andCriteria:(DBCriteria *)criteria
                  withDistinctFlag:(BOOL)isDistinct;

- (NSArray *)getTheProductIdDetailsForTheProductId:(NSString *)productMId;

- (NSArray *)getTheProductManualDetails;




@end
