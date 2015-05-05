//
//  AttachmentErrorUtility.h
//  ServiceMaxMobile
//
//  Created by Sahana on 05/05/15.
//  Copyright (c) 2015 SivaManne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVMXSystemConstant.h"

@interface AttachmentErrorUtility : NSObject

+(SMAttachmentRequestErrorCode)getErrorCodeForNetworkError:(NSInteger)errorCode;

@end
