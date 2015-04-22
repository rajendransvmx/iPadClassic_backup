//
//  TroubleshootingDAO.h
//  ServiceMaxiPad
//
//  Created by Chinnababu on 27/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"

@protocol TroubleshootingDAO <CommonServiceDAO>

- (NSArray*)getListOfDocument;
- (NSArray * )fetchRecordsByFields:(NSArray *)fieldNames
                       andCriteria:(DBCriteria *)criteria
                  withDistinctFlag:(BOOL)isDistinct;

- (NSString *)getTheProductIdDetailsFromTheDocumentTableWithTheProductId:(NSString *)productId;
- (NSArray *)getDocumentDetails:(NSString *)docId;



@end
