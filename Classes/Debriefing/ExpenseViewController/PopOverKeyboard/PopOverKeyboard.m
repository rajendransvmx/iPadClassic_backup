//
//  PopOverKeyboard.m
//  Debriefing
//
//  Created by Sanchay on 9/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PopOverKeyboard.h"


@implementation PopOverKeyboard

@synthesize txtField, parent, delegate;

-(id) init
{
	if (self = [super init])
	{
		// Custom initialization
		delegate = nil;
	}
	return self;
}

- (void) viewDidAppear:(BOOL)animated
{
	editingBegun = YES;
}

- (void) viewDidDisappear:(BOOL)animated
{
	editingBegun = NO;
	if (delegate == nil)
	{
		if( [parent respondsToSelector:@selector(SaveData)] )
		{
			[parent performSelector:@selector(SaveData)];
		}
	}
	else {
		if ([delegate respondsToSelector:@selector(didNumericKeyboardDisappear)]) {
			[delegate didNumericKeyboardDisappear];
		}
	}

}

- (IBAction) EnterNumber:(id)sender
{
	@try{
	if( editingBegun )
	{
        if (!didErasePreviousNum)
        {
            txtField.text = @"";
            didErasePreviousNum = YES;
        }
		NSMutableString *final = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
		if( [txtField.text isEqualToString:@"0"] )
		{
			[final setString:@"0"];
		}
		else
		{
			[final setString:txtField.text];
		}
		NSString *input = [(UIButton *)sender titleForState:UIControlStateNormal];
		//parse for decimal point
		if( [input isEqualToString:@"."] )
		{
			NSRange range = [txtField.text rangeOfString:@"."];
			if( NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) )
			{
				[final appendString:@"."];
				txtField.text = final;
			}
		}
		else
		{
			if( [final isEqualToString:@"0"] )
			{
				[final replaceCharactersInRange:[final rangeOfString:@"0"] withString:input];
			}
			else
			{
				[final appendString:input];
			}
			if( [final floatValue] != 0.0 )
			{
				txtField.text = final;
			}
		}
	}
	}@catch (NSException *exp) {
	SMLog(@"Exception Name PopOverKeyboard :EnterNumber %@",exp.name);
	SMLog(@"Exception Reason PopOverKeyboard :EnterNumber %@",exp.reason);
    }

    if ([delegate respondsToSelector:@selector(didKeyboardEditOccur)])
        [delegate didKeyboardEditOccur];
}

- (IBAction) BackSpace:(id)sender
{
	@try{
	if( editingBegun )
	{
        didErasePreviousNum = YES;
		NSMutableString *final = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
		if( [txtField.text isEqualToString:@"0"] )
		{
			[final setString:@"0"];
		}
		else
		{
			[final setString:txtField.text];
		}
		if( [final length] > 1 )
		{
			[final setString:[final substringToIndex:([final length]-1)]];
		}
		else
		{
			[final setString:@"0"];
		}
		txtField.text = final;
	}
	}@catch (NSException *exp) {
	SMLog(@"Exception Name PopOverKeyboard :BackSpace %@",exp.name);
	SMLog(@"Exception Reason PopOverKeyboard :BackSpace %@",exp.reason);
    }

    if ([delegate respondsToSelector:@selector(didKeyboardEditOccur)])
        [delegate didKeyboardEditOccur];
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

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
