//
//  WorkPerformedCellView.m
//  iService
//
//  Created by Samman Banerjee on 08/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WorkPerformedCellView.h"


@implementation WorkPerformedCellView

@synthesize workPerformed;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        // Initialization code
		NSArray *objs = [[NSBundle mainBundle] loadNibNamed:@"WorkPerformedCellView" owner:self options:nil];
		

		
		[self addSubview:(UIView *)[objs objectAtIndex:0]];
		
		CGRect textframe = workPerformed.frame;
		textframe.size.height = frame.size.height;
		
		workPerformed.frame = textframe;
        //008501
        workPerformed.font = [UIFont fontWithName:@"Helvetica" size:17];
        workPerformed.text = @"hello";
    }
    return self;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
