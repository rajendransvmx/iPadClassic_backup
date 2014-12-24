//
//  CustomTabBar.m
//  
//
//

#import "CustomTabBar.h"
#import <QuartzCore/QuartzCore.h>

#import "UIBuilder.h"

#import "CalendarHomeViewController.h"
#import "ExploreHomeViewController.h"
#import "NewItemViewController.h"
#import "NewlyCreatedHomeController.h"
#import "TaskHomeViewController.h"
#import "TroubleshootingHomeViewController.h"
#import "ToolsHomeController.h"
#import "StyleManager.h"
#import "RecentHomeViewController.h"
#import "TroubleshootingViewController.h"
#import "SMXCalendarViewController.h"


#import "SFMSearchViewController.h"
#import "TagManager.h"

typedef enum {
    TabBarItemIDCalendar = 1,
    TabBarItemIDExplore,
    TabBarItemIDTask,
    TabBarItemIDNewItem,
    TabBarItemIDRecents,
    TabBarItemIDTools
} TabBarItemID;

@implementation CustomTabBar

@synthesize btn1, btn2, btn3, btn4,btn5,btn6,btn7,btn8,tabBarView;



-(void)viewDidLoad
{
    [super viewDidLoad];
	

	[self hideTabBar];
    
    //self.view.backgroundColor = [UIColor colorWithHexString:@"f0f4c3"];
    self.view.backgroundColor = [UIColor clearColor];

    
    //HS
    //Add only 1st tab item not all
    UIImage *btnImage = [UIImage imageNamed:@"homeIcon.png"];
    
    CGRect theFrame;
    
    theFrame = self.view.bounds;
    
    theFrame.origin.x = 0;
    theFrame.origin.y  = theFrame.size.height - 48;
    theFrame.size.width = 35;
    theFrame.size.height = 50;
    
    btn1 = [UIBuilder getTabBarButton:theFrame withImage:nil withSelectedImage:nil withTitle:nil];
    [btn1 setBackgroundImage:btnImage forState:UIControlStateNormal]; // Set the image for the normal state of the button
    btn1.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin;
    
    [btn1 setTag:0]; // Assign the button a "tag" so when our "click" event is called we know which button was pressed.
    [btn1 addTarget:self action:@selector(btnPressShow:) forControlEvents:UIControlEventTouchUpInside];
    [btn1 setSelected:YES];
    [self.view addSubview:btn1];
    btn1.layer.shadowOpacity=0.50f;
    btn1.layer.shadowColor=[UIColor grayColor].CGColor;
    btn1.layer.masksToBounds = NO;
    btn1.layer.cornerRadius = 4.f;
    btn1.layer.shadowOffset = CGSizeMake(4.0f,4.5f);
    btn1.layer.shadowRadius = 1.5f;
    [btn1 setSelected:true]; // Set this button as selected (we will select the others to false as we only want Tab 1 to be selected initially
    [btn1 setBackgroundColor:[UIColor clearColor]];
    
    

    CalendarHomeViewController *calendarVCDefault = [ViewControllerFactory createViewControllerByContext:ViewControllerCalendar];
    
    CalendarHomeViewController *calendarVC = [ViewControllerFactory createViewControllerByContext:ViewControllerCalendar];

    [(SMXCalendarViewController *)calendarVCDefault removeAllEvents];
    
    SFMSearchViewController *exploreVC = [ViewControllerFactory createViewControllerByContext:ViewControllerExplore];
    
//    ExploreHomeViewController *exploreVC = [ViewControllerFactory createViewControllerByContext:ViewControllerExplore];
    
    TaskHomeViewController *taskVC = [ViewControllerFactory createViewControllerByContext:ViewControllerTasks];
   //TroubleshootingViewController *taskVC = [ViewControllerFactory createViewControllerByContext:ViewControllerTroubleshooting];

    
    NewItemViewController *newItemVC = [ViewControllerFactory createViewControllerByContext:ViewControllerNewItem];
    //    NewlyCreatedHomeController *newlyCreatedVC = [ViewControllerFactory createViewControllerByContext:ViewControllerNewlyCreated];
    RecentHomeViewController *recentHomeViewController = [ViewControllerFactory createViewControllerByContext:ViewControllerRecents];
    // TroubleshootingHomeViewController *trobleshootingVC = [ViewControllerFactory createViewControllerByContext:ViewControllerTroubleshooting];
    ToolsHomeController *toolsCV = [ViewControllerFactory createViewControllerByContext:ViewControllerTools];
    
    
    
    
    
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:calendarVCDefault];
    navController.navigationBar.translucent = NO;
    
    UINavigationController *navController1 = [[UINavigationController alloc]initWithRootViewController:calendarVC];
    navController1.navigationBar.translucent = NO;
    UINavigationController *navController2 = [[UINavigationController alloc]initWithRootViewController:exploreVC];
    navController2.navigationBar.translucent = NO;
    UINavigationController *navController3 = [[UINavigationController alloc]initWithRootViewController:taskVC];
    navController3.navigationBar.translucent = NO;
    UINavigationController *navController4 = [[UINavigationController alloc]initWithRootViewController:newItemVC];
    navController4.navigationBar.translucent = NO;
    UINavigationController *navController5 = [[UINavigationController alloc]initWithRootViewController:recentHomeViewController];
    //UINavigationController *navController6 = [[UINavigationController alloc]initWithRootViewController:trobleshootingVC];
    UINavigationController *navController6 = [[UINavigationController alloc]initWithRootViewController:toolsCV];
    navController6.navigationBar.translucent = NO;
    
    //navController7.navigationBar.tintColor = [UIColor orangeColor];
    
    NSArray *tabItems = [[NSArray alloc]initWithObjects:navController,navController1,navController2,navController3,navController4,navController5,navController6, nil];
    
    self.viewControllers = tabItems;
    
    /* HS 3 Dec */
    // this below code is to show the tab bar for first launch and to set Calendar as first view.
     [self addCustomElements];
    [self setSelectedIndex:1];
    _isTabClicked = YES;
    /* HS 3 Dc Ends here */

    //[self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:1]];
    
    
}




- (void)hideTabBar
{
	for(UIView *view in self.view.subviews)
	{
		if([view isKindOfClass:[UITabBar class]])
		{
			view.hidden = YES;
			break;
		}
	}
 }


-(BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)hideNewTabBar 
{
    
    // set up an animation for the transition between the views
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

    [[tabBarView layer] addAnimation:animation forKey:@"SwitchToView1"];
    //Animation done
    
    tabBarView.hidden = 1;
    //self.btn1.hidden = 0;

}

- (void)showNewTabBar
{
    if (_isTabClicked)
    {
        _isTabClicked = NO;
        [self hideNewTabBar];
    }
    else
    {
        [self addCustomElements]; //HS needs to optimize
        tabBarView.hidden = NO;
        
        _isTabClicked = YES;
    }
    
 
}

-(void)addCustomElements
{
	// Now we repeat the process for the other buttons
    CGRect theFrame;
    theFrame = btn1.frame;
    theFrame.origin.x = -2;
    theFrame.origin.y = theFrame.origin.y;
    theFrame.size.width = self.view.bounds.size.width + 10;
    theFrame.size.height = 50;
    
    if (tabBarView)
    {
        [tabBarView removeFromSuperview];
        tabBarView = nil;
    }
    tabBarView = [[UIView alloc]initWithFrame:theFrame];
    tabBarView.autoresizingMask =UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    tabBarView.autoresizesSubviews = YES;
    tabBarView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    tabBarView.layer.borderWidth = 1.0f;
    tabBarView.backgroundColor = [UIColor colorWithHexString:@"#F2F2F2"];
    [self.view addSubview:tabBarView];
    
    CGFloat spaceMargin = (self.view.bounds.size.width - btn1.frame.origin.x + btn1.frame.size.width)/7 - 108; //As per spec(70 from left , for 1st button - 92, rest btn margin -131


    theFrame = btn1.frame;
    theFrame.origin.x = theFrame.origin.x + theFrame.size.width + spaceMargin+5  ;
    //theFrame.origin.x = theFrame.origin.x + 150 ;
    theFrame.origin.y = 0;
    theFrame.size.width = 110;
    theFrame.size.height = 50;
    

    if (!self.btn2) {
        self.btn2 = [UIBuilder getTabBarButton:theFrame withImage:@"Calendar" withSelectedImage:@"Calendar" withTitle:[[TagManager sharedInstance]tagByName:kTagHomeCalendar]];
        btn2.imageEdgeInsets = UIEdgeInsetsMake(6, 100/2-25/2, 22, 0);
        btn2.titleEdgeInsets = UIEdgeInsetsMake(25, -25, 0, 0);
        [btn2 setTag:TabBarItemIDCalendar];
        [btn2 setSelected:YES];
        btn2.backgroundColor = [UIColor clearColor];
    }
    
    theFrame.origin.x = theFrame.origin.x + theFrame.size.width + spaceMargin +5 ;
    
    if (!self.btn3) {
        self.btn3 = [UIBuilder getTabBarButton:theFrame withImage:@"Explore" withSelectedImage:@"Explore" withTitle:[[TagManager sharedInstance]tagByName:kTagExplore]];
        
        btn3.imageEdgeInsets = UIEdgeInsetsMake(6, 100/2-25/2, 22, 0);
        btn3.titleEdgeInsets = UIEdgeInsetsMake(25, -25, 0, 0);
        
        [btn3 setTag:TabBarItemIDExplore];
        btn3.backgroundColor = [UIColor clearColor];
    }

    theFrame.origin.x = theFrame.origin.x + theFrame.size.width + spaceMargin +5 ;
    if (!self.btn4) {
        self.btn4 = [UIBuilder getTabBarButton:theFrame withImage:@"Task" withSelectedImage:@"Task" withTitle:[[TagManager sharedInstance]tagByName:kTagHomeTask]];
        
        
        btn4.imageEdgeInsets = UIEdgeInsetsMake(6, 100/2-25/2, 22, 0);
        btn4.titleEdgeInsets = UIEdgeInsetsMake(25, -25, 0, 0);
        
        [btn4 setTag:TabBarItemIDTask];
        btn4.backgroundColor = [UIColor clearColor];
    }
    
    theFrame.origin.x = theFrame.origin.x + theFrame.size.width + spaceMargin +5 ;
    if (!self.btn5) {
        self.btn5 = [UIBuilder getTabBarButton:theFrame withImage:@"NewItem" withSelectedImage:@"NewItem" withTitle:[[TagManager sharedInstance]tagByName:kTagNewItem]];
        btn5.imageEdgeInsets = UIEdgeInsetsMake(6, 100/2-25/2, 22, 0);
        btn5.titleEdgeInsets = UIEdgeInsetsMake(25, -25, 0, 0);
        
        [btn5 setTag:TabBarItemIDNewItem];
        btn5.backgroundColor = [UIColor clearColor];
    }

    theFrame.origin.x = theFrame.origin.x + theFrame.size.width + spaceMargin +5 ;
    if (!self.btn6) {
        self.btn6 = [UIBuilder getTabBarButton:theFrame withImage:@"Recents" withSelectedImage:@"Recents" withTitle:[[TagManager sharedInstance]tagByName:kTagRecentlyCreated]];
        btn6.imageEdgeInsets = UIEdgeInsetsMake(6, 100/2-25/2, 22, 0);
        btn6.titleEdgeInsets = UIEdgeInsetsMake(25, -25, 0, 0);
        [btn6 setTag:TabBarItemIDRecents];
        btn6.backgroundColor = [UIColor clearColor];
    }
    
    theFrame.origin.x = theFrame.origin.x + theFrame.size.width + spaceMargin +5 ;
    if (!self.btn7) {
        self.btn7 = [UIBuilder getTabBarButton:theFrame withImage:@"Tools" withSelectedImage:@"Tools" withTitle:[[TagManager sharedInstance]tagByName:kTagTools]];
        btn7.imageEdgeInsets = UIEdgeInsetsMake(6, 100/2-25/2, 22, 0);
        btn7.titleEdgeInsets = UIEdgeInsetsMake(25, -25, 0, 0);
        [btn7 setTag:TabBarItemIDTools];
        btn7.backgroundColor = [UIColor clearColor];

    }
    
    
    
    
    
	// Setup event handlers so that the buttonClicked method will respond to the touch up inside event.
	//[btn1 addTarget:self action:@selector(btnPressShow:) forControlEvents:UIControlEventTouchUpInside];
	[btn2 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[btn3 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[btn4 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btn5 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[btn6 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[btn7 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	//[btn8 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //HS new ends
    
    
    
	
	// Add my new buttons to the view
	//[self.view addSubview:btn1];
    
    // set up an animation for the transition between the views
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[tabBarView layer] addAnimation:animation forKey:@"SwitchToView1"];
    
    //Animation done
    
	[tabBarView addSubview:btn2];
	[tabBarView addSubview:btn3];
	[tabBarView addSubview:btn4];
    [tabBarView addSubview:btn5];
	[tabBarView addSubview:btn6];
	[tabBarView addSubview:btn7];
	//[tabBarView addSubview:btn8];
    if (btn1)
    {
        [btn1 removeFromSuperview];
        [self.view addSubview:btn1];
        
    }
    
    
}


- (void)btnPressShow:(id)sender {
    [self showNewTabBar];
}

- (void)buttonClicked:(id)sender
{
	NSInteger tagNum = [sender tag];
	[self selectTab:tagNum];
}

- (void)selectTab:(NSInteger)tabID
{
    [self updateButtonStateForSelectedTabId:tabID];
    if((tabID == TabBarItemIDExplore) && (self.selectedIndex == tabID))
    {
        UINavigationController *navCtr = [[self viewControllers] objectAtIndex:tabID];
        [navCtr popToRootViewControllerAnimated:YES];
        SFMSearchViewController *srchvc = (SFMSearchViewController*)[navCtr topViewController];
        [srchvc reloadDataOnTabButtonClick];
    }
    
	self.selectedIndex = tabID;
	
 }

- (void)updateButtonStateForSelectedTabId:(NSInteger)tabID {
    
    tabID --;
    NSArray *buttonArray = @[btn2,btn3,btn4,btn5,btn6,btn7];
    for (int i = 0; i < [buttonArray count]; i++) {
        UIButton *temp = [buttonArray objectAtIndex:i];
        if (tabID == i) {
            temp.selected = YES;
        } else {
            temp.selected = NO;
        }
    }
}

@end
