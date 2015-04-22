//
//  SFRTPickListDAO.h
//  ServiceMaxMobile
//
//  Created by Pushpak on 25/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//
#import "CommonServiceDAO.h"
#import "SFRTPicklistModel.h"

@protocol SFRTPicklistDAO <CommonServiceDAO>

- (NSArray * )fetchSFRTPicklistByFields:(NSArray *)fieldNames andCriteria:(id)criteria;
- (NSArray *)fetchSFRTPicklistByDistinctFields:(NSArray *)fieldNames andCriteria:(NSArray *)criteria;

@end