//
//  SyncProgressStatusHandler.h
//  ServiceMaxiPhone
//
//  Created by Radha Sathyamurthy on 28/06/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

/**
 This is a  Handler Class which handles Sync Progress Status   .
 @author Radha Sathyamurthy http://www.servicemax.com
 */

#import <Foundation/Foundation.h>
#import "SyncProgressDetailModel.h"
#import "WebserviceResponseStatus.h"


@interface SyncProgressStatusHandler : NSObject

- (SyncProgressDetailModel *)getProgressDetailsForStatus:(WebserviceResponseStatus *)responseStatus;
@end
