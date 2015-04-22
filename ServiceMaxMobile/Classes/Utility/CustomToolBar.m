//
//  CustomToolBar.m
//  iPublishCentral
//
//  Created by Ranjeet Kumar Singh on 25/09/10.
//  Copyright 2010 Techjini. All rights reserved.
//

#import "CustomToolBar.h"


@implementation CustomToolBar


- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		// Initialization code
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		self.translucent = YES;

	}
	return self;
}



- (void)drawRect:(CGRect)rect
{
	// Drawing code
}


- (void)dealloc
{
	[super dealloc];
}


@end
