//
//  SWitchViewButton.m
//  iService
//
//  Created by Radha S on 6/6/13.
//
//

#import "SWitchViewButton.h"

@implementation SWitchViewButton

@synthesize indexPath;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.userInteractionEnabled = YES;
		self.hidden = NO;
		
		self.enabled = YES; //Radha - 18th June - Linked Process Debrief
		self.highlighted = NO; 
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
    [indexPath release];
    [super dealloc];
}


@end
