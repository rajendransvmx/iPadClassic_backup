//
//  SourceUpdateDAO.h
//  ServiceMaxMobile
//
//  Created by Shubha S on 23/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//


/**
 *  @file   SourceUpdateDAO
 *  @class  SourceUpdateDAO
 *
 *  @brief
 *
 *   protocol DAO for source update
 *
 *  @author Shubha S
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"

@protocol SourceUpdateDAO <CommonServiceDAO>
-(NSDictionary *)getSourceUpdateRecordsforProcessId:(NSString *)processId;
- (void)updateTargetObjectsForSmartDocProcess:(NSString *)processId forObject:(NSString*)objectName andLocalId:(NSString*)localId;
@end
