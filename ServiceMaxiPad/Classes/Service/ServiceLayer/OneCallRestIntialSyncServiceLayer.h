//
//  OneCallRestIntialSyncServiceLayer.h
//  ServiceMaxMobile
//
//  Created by Anoop on 8/14/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   OneCallRestIntialSyncServiceLayer.h
 *  @class  OneCallRestIntialSyncServiceLayer
 *
 *  @brief  Service layer for OneCallRestIntialSync categorytype
 *
 *
 *  @author  Anoopsaai Ramani
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "BaseServiceLayer.h"

@interface OneCallRestIntialSyncServiceLayer : BaseServiceLayer

-(NSArray*)getRequestParamModelForGetPriceData:(RequestType)getPriceDataType;
- (NSArray *)getTxFetcRequestParamsForRequestCount:(NSInteger )requestCount;
- (NSDictionary *)getLastSyncTimeForRecords;
-(NSArray*)getValuesArrayForLabour;
-(NSArray*)getValuesArrayForCurrencyISO;
@end
