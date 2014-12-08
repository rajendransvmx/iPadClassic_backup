//
//  PriceBookTargetHandler.h
//  ServiceMaxiPhone
//
//  Created by Shravya shridhar on 6/17/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMPage.h"

/**
 This is a  data controller Class which handles target data containing work order and work detail information .
 @author Shravya shridhar http://www.servicemax.com shravya.shridhar@servicemax.com
 */

@interface PriceBookTargetHandler : NSObject {
    
}


@property(nonatomic,strong)NSMutableDictionary *targetDictionary;

/**
 This method  instantiate PriceBookTargetHandler
 @param page  sfm page
 @returns object instance.
 */
- (id)initWithSFPage:(SFMPage *)page;

/**
 This method updates sfpage with get price results
 @param currentPage:  sfm page
 @param priceResults:  work order dictionary after price caluclation
 @returns none.
 */
- (void)updateTargetSfpage:(SFMPage *)currentPage
          fromPriceResults:(NSDictionary *)priceResults;

@end
