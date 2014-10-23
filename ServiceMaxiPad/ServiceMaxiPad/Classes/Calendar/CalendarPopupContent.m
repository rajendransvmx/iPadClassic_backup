//
//  CalendarPopupContent.m
//  ServiceMaxiPad
//
//  Created by Niraj Kumar on 10/20/14.
//  Copyright (c) 2014 ServiceMax Inc. All rights reserved.
//

#import "CalendarPopupContent.h"

@implementation CalendarPopupContent

static   UIColor* color;
static BOOL isDayPopup;
static CGFloat hight;
static CGFloat Width;
static CGFloat  tileWidth ;
static CGFloat  tileHeightAdjustment ;
static CGFloat  CalendarViewHeight ;
static CGFloat  CalendarTopBarHeight  ;
static NSString *NotificationKey;

+(UIColor *)getColor;
{
    return color;
}
+(void)setColor:(UIColor *)string{
    color=string;
}
+(CGFloat )getHight{
    return hight;
}
+(void)setHight:(CGFloat)hightLOC{
    hight=hightLOC;
}
+(CGFloat)getWidth{
    return Width;
}
+(void)setWidth:(CGFloat)widthLOC{
    Width=widthLOC;
}
+(BOOL)getDayPopup{
    return isDayPopup;
}
+(void)setdayPopup:(BOOL)popup{
    isDayPopup=popup;
}
+(CGFloat )getCalendarTopBarHeight{
    return CalendarTopBarHeight;
}
+(void)setCalendarTopBarHeight:(CGFloat )barHight{
    CalendarTopBarHeight=barHight;
}

+(CGFloat )getTileWidth{
    return tileWidth;
}
+(void)setTileWidth:(CGFloat )barHight{
    tileWidth=barHight;
}
+(CGFloat )getTileHeightAdjustment{
    return tileHeightAdjustment;
}
+(void)setTileHeightAdjustment:(CGFloat )barHight{
    tileHeightAdjustment=barHight;
}
+(CGFloat )getCalendarViewHeight{
    return CalendarViewHeight;
}
+(void)setCalendarViewHeight:(CGFloat )barHight{
    CalendarViewHeight=barHight;
}
+(NSString *)getNotificationKey{
    return NotificationKey;
}
+(void)setNotificationKey:(NSString *)key{
    NotificationKey=key;
}

@end
