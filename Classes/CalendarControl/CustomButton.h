//
//  CustomButton.h
//  Calendar_v1.0
//
//  Created by Samman Banerjee on 08/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CustomButtonDelegate

@optional

- (void) SetButtonTitle:(NSString *) title;

@end


@interface CustomButton : UIButton
<CustomButtonDelegate>
{
}


@end
