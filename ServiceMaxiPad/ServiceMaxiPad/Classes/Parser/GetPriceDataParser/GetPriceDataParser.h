//
//  GetPriceDataParser.h
//  ServiceMaxMobile
//
//  Created by Anoop on 8/25/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

/**
 *  @file   GetPriceDataParser.h
 *  @class  GetPriceDataParser
 *
 *  @brief  This class is for parsing webservice response for
 *          four types of get price data calls
 *
 *
 *  @author  Anoopsaai Ramani
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "WebServiceParser.h"

@interface GetPriceDataParser : WebServiceParser

@property (nonatomic, strong) NSDictionary *rawResponseData;

@property (nonatomic, assign) BOOL isWOCountZero;
@property (nonatomic, assign) BOOL shouldCallBack;
@property (nonatomic, assign) BOOL warrantyHasValues;

@property (nonatomic, strong) NSString* lastIndex;
@property (nonatomic, strong) NSString* lastID;

@property (nonatomic, strong) NSMutableArray *callBackValuesFromFirstAPIResponse;

@property (nonatomic, strong) NSMutableDictionary *heapModelDict;
@property (nonatomic, strong) NSMutableDictionary *partiallyExecutedObjectValueMap;

@property (nonatomic, strong) NSMutableArray *objectNames;

@property (nonatomic, assign) RequestType requestType;

- (RequestType)getCurrentRequestType;

@end
