//
//  SFNamedSearchFilterDAO.h
//  ServiceMaxiPad
//
//  Created by Radha Sathyamurthy on 01/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
#import "SFNamedSearchFilterModel.h"

@protocol SFNamedSearchFilterDAO <CommonServiceDAO>

- (NSArray * )fetchSFNameSearchFiltersInfoByFields:(NSArray *)fieldNames andCriteria:(NSArray *)criteria;

@end
