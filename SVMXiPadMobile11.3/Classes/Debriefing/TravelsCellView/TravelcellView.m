//
//  TravelcellView.m
//  iService
//
//  Created by Krishna Shanbhag on 05/03/13.
//
//

#import "TravelcellView.h"

@implementation TravelcellView
@synthesize SrNo, Travel, Qty, UnitPrice, LinePrice;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *objs = [[NSBundle mainBundle] loadNibNamed:@"TravelcellView" owner:self options:nil];
		[self addSubview:(UIView *)[objs objectAtIndex:0]];

    }
    return self;
}

- (void) dealloc {
    [SrNo release];
    [Travel release];
    [Qty release];
    [UnitPrice release];
    [LinePrice release];
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
