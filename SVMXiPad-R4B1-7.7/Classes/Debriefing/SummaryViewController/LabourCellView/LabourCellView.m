//
//  LabourCellView.m
//  Debriefing
//
//  Created by Sanchay on 9/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LabourCellView.h"


@implementation LabourCellView

@synthesize SrNo, Labour, Rate, Hours, LinePrice;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		NSArray *objs = [[NSBundle mainBundle] loadNibNamed:@"LabourCellView" owner:self options:nil];
		[self addSubview:(UIView *)[objs objectAtIndex:0]];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
