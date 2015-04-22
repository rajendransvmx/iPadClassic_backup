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


@end
