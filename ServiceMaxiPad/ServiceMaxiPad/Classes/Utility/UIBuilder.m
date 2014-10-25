//
//  UIBuilder.m
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 27/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "UIBuilder.h"
#import "StyleManager.h"

@implementation UIBuilder

+(UIButton *)getTabBarButton:(CGRect)inFrame withImage:(NSString *)inBGImage withSelectedImage:(NSString *)inSelectedImage withTitle:(NSString*)inTitle
{
    UIButton *btn =  [UIButton buttonWithType:UIButtonTypeCustom];
    //theFrame.origin.x = theFrame.origin.x + theFrame.size.width + spaceMargin +5 ;
    btn.frame = inFrame;
    btn.autoresizingMask =  UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
	[btn setImage:[UIImage imageNamed:inBGImage] forState:UIControlStateNormal];
	[btn setImage:[UIImage imageNamed:inSelectedImage] forState:UIControlStateSelected];
    //btn.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 20,0);
    //[btn setTitleEdgeInsets:UIEdgeInsetsMake(60.f, -60.f, 8.f, 5.f)];
    [btn setTitle:inTitle forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:kHelveticaNeueLight size:kFontSize14];
    [btn setTitleColor:[UIColor colorWithHexString:@"#797979"] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor clearColor];
    return btn;
    
}


@end
