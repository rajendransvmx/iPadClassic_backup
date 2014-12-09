//
//  TroubleShootDataLoader.h
//  ServiceMaxMobile
//
//  Created by Chinnababu on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TroubleshootingDataLoader: NSObject

+ (void)makingRequestForDetailsByProductName:(NSString *)productName
                                 withTheCallerDelegate:(id)delegate;
+ (void)makingRequestForBodyByDocID:(NSString *)docId
                                      andCallerDelegate:(id)delegate;


@end
