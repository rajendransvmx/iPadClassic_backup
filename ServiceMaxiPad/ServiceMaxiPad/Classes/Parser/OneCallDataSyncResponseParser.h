//
//  OneCallDataSyncResponseParser.h
//  ServiceMaxiPhone
//
//  Created by Shravya shridhar on 3/17/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "WebServiceParser.h"
#import "SBJsonParser.h"

#import "ResponseCallback.h"

/*
 Parser Class which handles  parsing of response comes from One Call Data Sync request
 @author Shravya shridhar http://www.servicemax.com shravya.shridhar@servicemax.com
 */

@interface OneCallDataSyncResponseParser :  WebServiceParser {
    
}


/**
 Dictionary to hold the index of events(insert,update,delete..)using key as event name    
 */
@property(nonatomic,strong)NSDictionary *eventNameToIndex;





/**
 Response Call Back instance which holds the data for next call back i.e. callback flag and data    
 */
@property(nonatomic,strong)ResponseCallback *callBack;

@end
