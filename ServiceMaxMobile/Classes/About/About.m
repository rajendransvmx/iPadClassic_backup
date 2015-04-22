//
//  About.m
//  iService
//
//  Created by Samman on 6/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "About.h"

@implementation About

@synthesize popover;

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
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if (userDefaults)
	{
		//appDelegate.currentUserName = [userDefaults objectForKey:USERFULLNAME]; //To get user display name not email id
		appDelegate.loggedInOrg = [userDefaults objectForKey:@"loggedInOrg"];
	}
	
    userNameLabel.text = appDelegate.userDisplayFullName; //Changing the variable
    userLoginLabel.text = appDelegate.username;
    NSString * version = [appDelegate.wsInterface.tagsDictionary objectForKey:ABOUT_VERSION_TITLE];
    NSString * loggedIn = [appDelegate.wsInterface.tagsDictionary objectForKey:ABOUT_LOGGED_INTO_TITLE];
    NSString * as = [appDelegate.wsInterface.tagsDictionary objectForKey:ABOUT_LOGGED_INTO_AS_TITLE];
    
    // Read version info from plist
    appVersionLabel.text = [NSString stringWithFormat:@"%@ %@", version, [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    
    userInfo.text = [NSString stringWithFormat:@"%@ %@", loggedIn, appDelegate.loggedInOrg];
	    
    userNameLabel.text = [NSString stringWithFormat:@"%@ %@", as, appDelegate.userDisplayFullName];//Changing the variable
    userLoginLabel.text = [NSString stringWithFormat:@"(%@)", appDelegate.username];
}

- (void)viewDidUnload
{
    [appVersionLabel release];
    appVersionLabel = nil;
    [userInfo release];
    userInfo = nil;
    [userNameLabel release];
    userNameLabel = nil;
    [userLoginLabel release];
    userLoginLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

@end
