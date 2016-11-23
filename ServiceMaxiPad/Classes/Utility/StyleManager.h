//
//  StyleManager.h
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 15/09/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StyleGuideConstants.h"


/*----------------------------------------------------------------------------------------------------
 Category for Nav Bar Background Color
 ----------------------------------------------------------------------------------------------------*/
@interface UIColor (iPad_Additions)
+ (UIColor*)dayViewTitleBG;
+ (UIColor*)navBarBG;
+ (UIColor*)navBarTitleColor;

+ (UIColor*)loginInfoText;

// values are from 0-255
+ (UIColor*)colorWithIntegerRed:(unsigned char)red green:(unsigned char)green blue:(unsigned char)blue alpha:(unsigned char)alpha;

+ (UIColor*)getUIColorFromHexValue:(NSString*)hxVal;
@end

/*----------------------------------------------------------------------------------------------------
 Category for Nav Bar Title Font ----------------------------------------------------------------------------------------------------*/
@interface UIFont (iPad_Additions)
+ (UIFont*)navbarTitle;
@end

/*----------------------------------------------------------------------------------------------------
 Category for Nav Bar Title ----------------------------------------------------------------------------------------------------*/

@interface UILabel (iPad_Additions)
+(UILabel *)navBarTitleLabel:(NSString *)titleText;

@end
