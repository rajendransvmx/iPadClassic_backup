//
//  SyncProgressFactory.h
//  ServiceMaxMobile
//
//  Created by Sahana on 22/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestConstants.h"
#import "SyncConstants.h"

@interface SyncProgressFactory : NSObject

+(SyncProgressStatus)getSyncProcessStatusforRequestType:(RequestType)requestType;

@end
