//
//  OAuthController.m
//  iService
//
//  Created by Shrinivas Desai on 20/05/13.
//
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
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Part of Fix 008481. iOS 7: Keyboard keeps on retracting when user tries to enter the username on login screen
    if(![Utility notIOS7])
        self.view.backgroundColor = [UIColor colorWithRed:42.0/255.0 green:148.0/255.0 blue:214.0/255.0 alpha:1.0];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Fix for Defect #7167
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
