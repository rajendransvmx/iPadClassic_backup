//
//  CalendarPopupContent.h
//  ServiceMaxiPad
//
//  Created by Niraj Kumar on 10/20/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarPopupContent : NSObject
+(UIColor *)getColor;
+(void)setColor:(UIColor *)string;
+(CGFloat )getHight;
+(void)setHight:(CGFloat)hight;
+(CGFloat)getWidth;
+(void)setWidth:(CGFloat)width;
+(BOOL)getDayPopup;
+(void)setdayPopup:(BOOL)popup;
+(CGFloat )getCalendarTopBarHeight;
+(void)setCalendarTopBarHeight:(CGFloat )barHight;

+(CGFloat )getTileWidth;
+(void)setTileWidth:(CGFloat )barHight;
+(CGFloat )getTileHeightAdjustment;
+(void)setTileHeightAdjustment:(CGFloat )barHight;
+(CGFloat )getCalendarViewHeight;
+(void)setCalendarViewHeight:(CGFloat )barHight;
+(NSString *)getNotificationKey;
+(void)setNotificationKey:(NSString *)key;

@end
