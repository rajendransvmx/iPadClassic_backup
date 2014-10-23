//
//  JobLogDAO.h
//  ServiceMaxiPad
//
//  Created by Pushpak on 13/10/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

/**
 *  @file   JobLogDAO.h
 *  @class  JobLogDAO.h
 *
 *  @brief
 *
 *   This is a protocol class
 *
 *  @author Pushpak
 *  @bug No known bugs.
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/
#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
#import "JobLogModel.h"
@protocol JobLogDAO <CommonServiceDAO>

- (BOOL)deleteJobLogsIfRecordCountCrossedLimit;

- (NSMutableArray *)fetchNextBatchOfJobLogs;

- (BOOL)deleteJobLogsThatAreSent;

@end
