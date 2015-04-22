//
//  TroubleShootDatahelper.h
//  ServiceMaxMobile
//
//  Created by Chinnababu on 09/10/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TroubleshootingDataHelper : NSObject

+ (NSArray*)fetchProductDetailsbyProductName:(NSString *)productName;
+ (NSArray *)fetchProductDetailsByProductIds:(NSArray *)sFIds;
+ (void)deleteTroubleShootFilesForTheIds:(NSArray *)sFIdArray;
@end
