//
//  SFRTPickListDAO.h
//  ServiceMaxMobile
//
//  Created by Pushpak on 25/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//
#import "CommonServiceDAO.h"
@class SFRTPicklistModel;

@protocol SFRTPicklistDAO <CommonServiceDAO>

- (NSArray * )fetchSFRTPicklistByFields:(NSArray *)fieldNames andCriteria:(id)criteria;


@end