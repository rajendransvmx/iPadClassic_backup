//
//  ChatterPostDetailDAO.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 24/12/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
#import "ChatterPostDetailModel.h"

@protocol ChatterPostDetailDAO <CommonServiceDAO>

- (BOOL)deleteRecords:(id)criteria;
- (NSMutableArray *)fetchRecordsForProductId:(NSArray *)criteria
                                     orderBy:(id)dbField;

@end
