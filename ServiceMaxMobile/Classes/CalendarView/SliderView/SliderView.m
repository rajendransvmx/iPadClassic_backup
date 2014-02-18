//
//  SliderView.m
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 21/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SliderView.h"


@implementation SliderView

@synthesize totalDays;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    // grab current graphics context
	CGContextRef g = UIGraphicsGetCurrentContext();
    
    // draw hour numbers
	CGContextSetShouldAntialias(g, YES);
	[[UIColor blackColor] set];
	UIFont *numberFont = [UIFont boldSystemFontOfSize:14.0];
    
    // Obtain multiples for CGRect based on sliderView width which is 735 in landscape mode
    double multiple = 735/totalDays;
    
    for (int i = 1; i <= totalDays; i++)
    {
        NSString * date = [NSString stringWithFormat:@"%d", i];
        CGSize textSize = [date sizeWithFont:numberFont];
        [date drawInRect:CGRectMake(textSize.width+i*multiple,
                                    textSize.height,
                                    textSize.width, 
                                    textSize.height)
                withFont:numberFont];
    }
}

- (void)dealloc {
    [super dealloc];
}


@end
