//
//  SFNameSearchDAO.h
//  ServiceMaxMobile
//
//  Created by Anoop on 8/22/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   SFNamedSearchDAO.h
 *  @class  SFNamedSearchDAO
 *
 *  @brief  Protocol class for SFNamedSearch DAO service
 *
 *
 *
 *  @author  Anoopsaai Ramani
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
#import "SFNamedSearchModel.h"

@protocol SFNamedSearchDAO <CommonServiceDAO>

-(SFNamedSearchModel *)getLookUpRecordsForDBCriteria:(NSArray *)criteriaArray  advancedExpression:(NSString *)advancedExpression  fields:(NSArray *)fields;

@end
