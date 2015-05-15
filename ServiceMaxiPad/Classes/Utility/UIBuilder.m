//
//  UIBuilder.m
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 27/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "UIBuilder.h"
#import "StyleManager.h"
#import "CustomBadge.h"


@implementation UIBuilder

+(UIButton *)getTabBarButton:(CGRect)inFrame withImage:(NSString *)inBGImage withSelectedImage:(NSString *)inSelectedImage withTitle:(NSString*)inTitle
{
    UIButton *btn =  [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = inFrame;
    btn.autoresizingMask =  UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    if (inBGImage != nil)
    {
        [btn setImage:[UIImage imageNamed:inBGImage] forState:UIControlStateNormal];
    }
    
    if (inSelectedImage != nil)
    {
        [btn setImage:[UIImage imageNamed:inSelectedImage] forState:UIControlStateSelected];
    }
    
    if (inTitle.length) {
        
        NSAttributedString *normalTitle = [[NSAttributedString alloc]initWithString:inTitle attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueLight size:kFontSize14],
                                                                                                         NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#797979"]}];
        
        
        NSAttributedString *selectedTitle = [[NSAttributedString alloc]initWithString:inTitle attributes:@{NSFontAttributeName:[UIFont fontWithName:kHelveticaNeueBold size:kFontSize14],
                                                                                                           NSForegroundColorAttributeName:[UIColor colorWithHexString:kOrangeColor]}];
        
        
        [btn setAttributedTitle:normalTitle forState:UIControlStateNormal];
        [btn setAttributedTitle:selectedTitle forState:UIControlStateSelected];

    }
    
    btn.backgroundColor = [UIColor clearColor];
    return btn;
    
}

+ (UIButton *)getTabBarButton:(CGRect)inFrame withImage:(NSString *)inBGImage withSelectedImage:(NSString *)inSelectedImage withTitle:(NSString*)inTitle withBadge:(BOOL)showBadge
{
    
    UIButton *btn = [UIBuilder getTabBarButton:inFrame withImage:inBGImage withSelectedImage:inSelectedImage withTitle:inTitle];
    
    if(showBadge)
    {
        NSString *counterStr = [NSString stringWithFormat:@"0"];
        
        BadgeStyle *badgeStyle = [BadgeStyle freeStyleWithTextColor:[UIColor whiteColor]
                                                     withInsetColor:[UIColor navBarBG]
                                                     withFrameColor:nil
                                                          withFrame:NO
                                                         withShadow:NO
                                                        withShining:NO
                                                       withFontType:BadgeStyleFontTypeHelveticaNeueMedium];
        
        CustomBadge *badge = [CustomBadge customBadgeWithString:counterStr withScale:1.0 withStyle:badgeStyle];
        
        badge.tag = BADGE_TAG;
        
        
        CGRect r = btn.frame;
        CGPoint pt = CGPointZero;
        pt.x = r.size.width/2 + 12;
        pt.y = badge.frame.size.height/2 - 2;

        badge.center = pt;
        
        [btn addSubview:badge];
        
        badge.hidden = YES;
    }
    
    return btn;
}

@end
