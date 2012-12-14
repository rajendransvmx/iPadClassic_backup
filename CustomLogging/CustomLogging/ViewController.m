//
//  ViewController.m
//  CustomLogging
//
//  Created by Siva Manne on 15/05/12.
//  Copyright (c) 2012 ServiceMax. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()

@end
@implementation ViewController
- (IBAction)logError:(id)sender
{
    SMFunctionStart
    int number =20;
    SMLogError(@"Error Message %d",number);
    SMFunctionEnd
}
- (IBAction)logWarn:(id)sender
{
    SMLogWarn(@"Warning Message");
}
- (IBAction)logInfo:(id)sender
{
     SMLogInfo(@"Info Message");
}
- (IBAction)logDebug:(id)sender
{
     SMLogDebug(@"Debug Message");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
