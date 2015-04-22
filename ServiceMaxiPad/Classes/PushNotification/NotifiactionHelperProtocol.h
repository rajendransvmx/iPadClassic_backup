//
//  NotifiactionHelperProtocol.h
//  ServiceMaxiPad
//
//  Created by Sahana on 09/03/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NotifiactionHelperProtocol <NSObject>

-(void)downloadStatusForRequest:(PushNotificationModel * )currentRequest withError:(NSError *)error;
@end
