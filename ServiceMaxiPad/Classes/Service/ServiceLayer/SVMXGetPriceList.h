//
//  SVMXGetPriceList.h
//  ServiceMaxiPad
//
//  Created by Apple on 26/08/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonServiceDAO.h"

@interface SVMXGetPriceList : NSObject

-(NSArray *)getPricebookIds;
-(NSArray *)getServicePricebookIds;
@end
