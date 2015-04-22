//
//  SMXMonthCellEvent.h
//  ServiceMaxiPad
//
//  Created by Service Max on 05/02/15.
//  Copyright (c) 2015 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMXMonthCellEvent : NSObject
{

}
+(int )getValueForKey:(NSString *)key;
+(void)setEventPlace:(NSString *)key value:(NSString *)value;
+(void)setEventPlace:(NSMutableDictionary *)locDict;
+(void)removeInfoForKey:(NSString *)key;
@end
