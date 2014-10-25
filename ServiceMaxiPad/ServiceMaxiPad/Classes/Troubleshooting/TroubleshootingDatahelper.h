//
//  TroubleShootDatahelper.h
//  ServiceMaxMobile
//
//  Created by Chinnababu on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TroubleshootingDatahelper : NSObject

+(NSArray*)getProductDetailsFromDbForProductName:(NSString *)productname;

@end
