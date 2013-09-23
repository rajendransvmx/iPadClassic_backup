//
//  AlphaContentView.m
//  CustomClassesipad
//
//  Created by Developer on 4/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlphaContentView.h"


@implementation AlphaContentView
@synthesize poTextField;
@synthesize cVdelegate;
@synthesize relesePOdelegate;
@synthesize AlphaLabel;
void SMXLog(const char *methodContext,NSString *message);

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [AlphaLabel release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [AlphaLabel release];
    AlphaLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    return TRUE;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    /*NSString * str= [[NSString  alloc] init];
    str=poTextField.text;*/
//    [cVdelegate settextfieldValue:poTextField.text];//  Unused Methods
 }



@end
