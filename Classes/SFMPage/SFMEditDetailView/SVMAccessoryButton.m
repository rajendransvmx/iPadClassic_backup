//
//  SVMAccessoryButton.m
//  iService
//
//  Created by Krishna Shanbhag on 01/02/13.
//
//

#import "SVMAccessoryButton.h"

@implementation SVMAccessoryButton
@synthesize indexpath;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) dealloc {
    [indexpath release];
    [super dealloc];
}

@end
