//
//  UIBuilder.h
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 27/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BADGE_TAG 171


@interface UIBuilder : NSObject

+(UIButton *)getTabBarButton:(CGRect)inFrame withImage:(NSString *)inBGImage withSelectedImage:(NSString *)inSelectedImage withTitle:(NSString*)inTitle;
+ (UIButton *)getTabBarButton:(CGRect)inFrame withImage:(NSString *)inBGImage withSelectedImage:(NSString *)inSelectedImage withTitle:(NSString*)inTitle withBadge:(BOOL)showBadge;

@end
