//
//  OPDocDAO.h
//  ServiceMaxiPad
//
//  Created by Damodar on 28/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

/**
 *  @file   OPDocDAO.h
 *  @class  OPDocDAO.h
 *
 *  @brief
 *
 *   This is a protocol class
 *
 *  @author Damodar
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/
#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"

@protocol OPDocDAO <CommonServiceDAO>

/* Add signatures and HTML file to tables */
- (void)addHTMLfile:(NSString*)fileName forProcess:(NSString*)processId recordId:(NSString*)recId;

/* Update SFID of signatures and HTML file to tables */
- (void)updateHTML:(NSString*)htmlFileName withSFID:(NSString*)sfid;

/* DAO methods to access the process, header-object and other details to pre-load the smart doc */

/* DAO methods for SVMXDatabaseMaster */

@end
