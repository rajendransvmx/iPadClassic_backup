//
//  SFNamedSearchComponentDAO.h
//  ServiceMaxMobile
//
//  Created by Anoop on 8/25/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   SFNamedSearchComponentDAO.h
 *  @class  SFNamedSearchComponentDAO
 *
 *  @brief  Protocol class for SFSearchObjectDetail DAO service
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

/* SFSearchObjectDetail */
 
#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"

@protocol SFNamedSearchComponentDAO <CommonServiceDAO>
-(NSDictionary *)getNamedSearchComponentWithDBcriteria:(NSArray *)DBCriteria  advanceExpression:(NSString *)advanceExpression fields:(NSArray *)fields  orderbyField:(NSArray *)orderBy distinct:(BOOL)distinctOnly;


@end
