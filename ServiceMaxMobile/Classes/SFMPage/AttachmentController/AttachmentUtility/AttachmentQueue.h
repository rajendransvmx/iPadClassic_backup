//
//  AttachmentQueue.h
//  ServiceMaxMobile
//
//  Created by Kirti on 21/11/13.
//  Copyright (c) 2013 SivaManne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AttachmentQueue : NSObject
+ (AttachmentQueue *)sharedInstance;
- (void) startQueue;
- (void) stopQueue;

@end
