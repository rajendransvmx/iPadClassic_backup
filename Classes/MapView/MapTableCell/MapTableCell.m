//
//  MapTableCell.m
//  iService
//
//  Created by Samman Banerjee on 27/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MapTableCell.h"

#import <QuartzCore/QuartzCore.h>


@implementation MapTableCell


- (void) setCellLabel:(NSString *)_label Color:(UIColor *)color Timing:(NSString *)timing;
{
    [_label retain];
    cellImage.layer.cornerRadius = 5;
    cellImage.alpha = 0.75;
    [self setEventColor:color];
    cellText.text = _label;
    cellLabel.text = timing;
}

- (void) setEventColor:(UIColor *)color;
{
    cellImage.backgroundColor = color;
}

- (void)dealloc
{
    [super dealloc];
}


@end
