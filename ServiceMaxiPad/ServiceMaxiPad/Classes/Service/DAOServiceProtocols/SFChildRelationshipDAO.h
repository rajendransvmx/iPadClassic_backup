//
//  SFChildRelationshipDAO.h
//  ServiceMaxMobile
//
//  Created by shravya on 23/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
@protocol SFChildRelationshipDAO <CommonServiceDAO>
- (NSArray * )fetchSFObjectFieldsInfoByFields:(NSArray *)fieldNames andCriteria:(DBCriteria *)criteria;
@end
