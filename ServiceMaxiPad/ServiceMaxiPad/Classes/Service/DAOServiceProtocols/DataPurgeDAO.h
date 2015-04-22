//
//  DataPurgeDAO.h
//  ServiceMaxiPad
//
//  Created by Chinnababu on 05/11/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"
#import "AttachmentTXModel.h"

@protocol DataPurgeDAO <CommonServiceDAO>
- (NSArray *)fetchDistinctObjectNames;
- (NSMutableArray *)fetchSfIdsForObjectName:(NSString *)objectName;

@end

