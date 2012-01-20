//
//  CustomButton.m
//  Calendar_v1.0
//
//  Created by Samman Banerjee on 08/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	if (self)
	{
	}
	return self;
}

- (void) SetButtonTitle:(NSString *) title
{
	[self setTitle:title forState:UIControlStateNormal];
}

@end
