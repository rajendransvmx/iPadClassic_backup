//
//  CalendarHomeViewController.m
//  ServiceMaxMobile
//
//  Created by Himanshi Sharma on 27/08/14.
//  Copyright (c) 2014 Servicemax. All rights reserved.
//

#import "CalendarHomeViewController.h"
#import "SFMPageViewController.h"
#import "SFMPageViewManager.h"
#import "StyleManager.h"
#import "TagManager.h"
#import "StyleGuideConstants.h"
#import "AlertMessageHandler.h"
#import "TagManager.h"

@interface CalendarHomeViewController ()

@end

@implementation CalendarHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadView
{
    UIView *view = [[UIView alloc]initWithFrame:[[UIScreen mainScreen]applicationFrame]];
    view.backgroundColor = [UIColor getUIColorFromHexValue:@"ffccbc"];
    self.view = view ;
    
  
    //[self.view addSubview:label];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.titleView = [UILabel navBarTitleLabel:[[TagManager sharedInstance]tagByName:kTagHomeCalendar]];
    self.navigationController.navigationBar.barTintColor = [UIColor navBarBG]; //Only for iOS7.0 and more than 7.0
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    [self setNavigationBackButton];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setNavigationBackButton
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = [[TagManager sharedInstance] tagByName:kTagHomeCalendar];
    self.navigationItem.backBarButtonItem = backButton;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor],NSForegroundColorAttributeName,
                                                                     [UIFont fontWithName:kHelveticaNeueMedium size:kFontSize18], NSFontAttributeName, nil]];

}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
