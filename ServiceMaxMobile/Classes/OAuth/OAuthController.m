//
//  OAuthController.m
//  ServiceMaxMobile
//
//  Created by AnilKumar on 3/27/14.
//  Copyright (c) 2014 SivaManne. All rights reserved.
//

#import "OAuthController.h"

#import "Utility.h"

@interface OAuthController ()

@end

@implementation OAuthController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if(![Utility notIOS7])
        self.view.backgroundColor = [UIColor colorWithRed:42.0/255.0 green:148.0/255.0 blue:214.0/255.0 alpha:1.0];
    
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}



-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	if ( toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight )
		return YES;
	else
		return NO;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

@end
