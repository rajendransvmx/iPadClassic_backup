//
//  CellRepository.m
//  MultipleDetailViews
//
//  Created by Samman Banerjee on 18/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CellRepository.h"


@implementation CellRepository

@synthesize mView, label;
//  Unused methods
//- (void) setLabelText:(NSString *)_text
//{
//    label.text = _text;
//}

- (void) setColor:(UIColor *)color
{
    mView.backgroundColor = color;
}

- (void)dealloc {
    [super dealloc];
}


@end
