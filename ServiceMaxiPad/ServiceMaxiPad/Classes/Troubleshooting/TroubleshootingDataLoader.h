//
//  TroubleShootDataLoader.h
//  ServiceMaxMobile
//
//  Created by Chinnababu on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TroubleshootingDataLoader: NSObject

+ (void)fetchProductDetailsFromServerForTheProductName:(NSString *)productname
                                 WithTheCallerDelegate:(id)delegate;
+ (void)getTroubleshootingBodyFromTheServerWithTheDocId:(NSString *)docId
                                      AndCallerDelegate:(id)delegate;


@end
