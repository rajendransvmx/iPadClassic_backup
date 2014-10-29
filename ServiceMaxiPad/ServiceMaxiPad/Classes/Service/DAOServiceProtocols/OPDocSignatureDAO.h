//
//  OPDocSignatureDAO.h
//  ServiceMaxiPad
//
//  Created by Damodar on 28/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

/**
 *  @file   OPDocSignatureDAO.h
 *  @class  OPDocSignatureDAO.h
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

@protocol OPDocSignatureDAO <CommonServiceDAO>

/* Add signatures and HTML file to tables */
- (void)addSignaturefile:(NSString*)fileName processId:(NSString*)processId recordId:(NSString*)recId signId:(NSString*)signId andHTML:(NSString*)htmlFile;

/* Update SFID of signatures and HTML file to tables */
- (void)updateSignature:(NSString*)signName withSFID:(NSString*)sfid;

/* DAO methods to access the process, header-object and other details to pre-load the smart doc */

/* DAO methods for SVMXDatabaseMaster */

@end
