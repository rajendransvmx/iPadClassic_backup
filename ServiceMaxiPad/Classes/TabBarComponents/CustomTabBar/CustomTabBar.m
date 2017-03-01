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

#import "CustomBadge.h"
#import "ResolveConflictsHelper.h"
#import "NonTagConstant.h"

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
    [btn1 setSelected:true]; // Set this button as selected (we will select the others to false as we only want Tab 1 to be selected initially
    [btn1 setBackgroundColor:[UIColor clearColor]];
    btn1.layer.masksToBounds = NO;
    btn1.layer.cornerRadius = 4.f;
    btn1.layer.shadowOffset = CGSizeMake(4.0f,4.5f);
    btn1.layer.shadowRadius = 1.5f;
    
    // IPAD-4541 - Verifaya
    btn1.accessibilityLabel = kVToggleTabBar;
    
    [self addBadgeToHomeButton];
    
    CalendarHomeViewController *calendarVCDefault = [ViewControllerFactory createViewControllerByContext:ViewControllerCalendar];
    
    CalendarHomeViewController *calendarVC = [ViewControllerFactory createViewControllerByContext:ViewControllerCalendar];
    
    [(SMXCalendarViewController *)calendarVCDefault removeAllEvents];
    
    SFMSearchViewController *exploreVC = [ViewControllerFactory createViewControllerByContext:ViewControllerExplore];
    
    TaskHomeViewController *taskVC = [ViewControllerFactory createViewControllerByContext:ViewControllerTasks];
    
    NewItemViewController *newItemVC = [ViewControllerFactory createViewControllerByContext:ViewControllerNewItem];

    RecentHomeViewController *recentHomeViewController = [ViewControllerFactory createViewControllerByContext:ViewControllerRecents];

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
    UINavigationController *navController6 = [[UINavigationController alloc]initWithRootViewController:toolsCV];
    navController6.navigationBar.translucent = NO;
    
    NSArray *tabItems = [[NSArray alloc]initWithObjects:navController,navController1,navController2,navController3,navController4,navController5,navController6, nil];
    
    self.viewControllers = tabItems;
    
    /* HS 3 Dec */
    // this below code is to show the tab bar for first launch and to set Calendar as first view.
    [self addCustomElements];
    [self setSelectedIndex:1];
    _isTabClicked = YES;
    [self showNewTabBar];
    /* HS 3 Dc Ends here */
    
    //[self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:1]];
    
}

- (void)addBadgeToHomeButton
{
    BadgeStyle *badgeStyle = [BadgeStyle freeStyleWithTextColor:[UIColor whiteColor]
                                                 withInsetColor:[UIColor redColor]
                                                 withFrameColor:nil
                                                      withFrame:NO
                                                     withShadow:NO
                                                    withShining:NO
                                                   withFontType:BadgeStyleFontTypeHelveticaNeueMedium];
    
    CustomBadge *badge = [CustomBadge customBadgeWithString:@"0" withScale:1.0 withStyle:badgeStyle];
    
    badge.tag = BADGE_TAG;
    
    
    CGRect r = self.btn1.frame;
    CGPoint pt = CGPointZero;
    pt.x = r.size.width;
    pt.y = 0.0f;
    
    badge.center = pt;
    
    [self.btn1 addSubview:badge];
    
    badge.hidden = YES;
}

- (void)addShadowToMenuButton:(BOOL)shouldAdd
{
    if (shouldAdd) {
        btn1.layer.shadowOpacity=0.50f;
        btn1.layer.shadowColor=[UIColor grayColor].CGColor;
        
    } else {
        
        btn1.layer.shadowOpacity=0.0f;
        btn1.layer.shadowColor=[UIColor clearColor].CGColor;
    }
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
    self.transparentView.hidden = YES;
    //self.btn1.hidden = 0;
    
}

- (void)showNewTabBar
{
    if (_isTabClicked)
    {
        _isTabClicked = NO;
        [self hideNewTabBar];
        [self addShadowToMenuButton:YES];
    }
    else
    {
        [self addCustomElements]; //HS needs to optimize
        tabBarView.hidden = NO;
        [self addShadowToMenuButton:NO];
        _isTabClicked = YES;
    }
    
}

-(void)addCustomElements
{
    /*
     * Patching a view into this component as to support dismissal of menu when they tap outside.
     */
    if (self.transparentView) {
        [self.transparentView removeFromSuperview];
        self.transparentView = nil;
        self.tapGestureRecognizer.enabled = NO;
        self.tapGestureRecognizer.delegate = nil;
        self.tapGestureRecognizer = nil;
    }
    CGRect frame = [[UIScreen mainScreen] bounds];
    if (frame.size.width != [UIApplication sharedApplication].statusBarFrame.size.width) {
        frame = CGRectMake(0, 0, frame.size.height, frame.size.width);
    }
    self.transparentView = [[UIView alloc] initWithFrame:frame];
    self.transparentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.transparentView.contentMode = UIViewContentModeScaleToFill;
    self.transparentView.translatesAutoresizingMaskIntoConstraints = YES;
    self.transparentView.backgroundColor = [UIColor clearColor];
    self.transparentView.alpha = 1;
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.transparentView addGestureRecognizer:self.tapGestureRecognizer];
    [self.view addSubview:self.transparentView];
    /*
     * End
     */
    
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
    tabBarView.layer.masksToBounds = NO;
    tabBarView.layer.shadowOffset = CGSizeMake(.0f,-4.5f);
    tabBarView.layer.shadowRadius = 1.0f;
    tabBarView.layer.shadowOpacity = 0.35f;
    tabBarView.layer.shadowColor = [UIColor grayColor].CGColor;
    tabBarView.backgroundColor = [UIColor colorWithHexString:@"#F2F2F2"];
    [self.view addSubview:tabBarView];
    
    CGFloat spaceMargin = (self.view.bounds.size.width - btn1.frame.origin.x + btn1.frame.size.width)/7 - 108; //As per spec(70 from left , for 1st button - 92, rest btn margin -131
    
    
    theFrame = btn1.frame;
    theFrame.origin.x = theFrame.origin.x + theFrame.size.width + spaceMargin+5  ;
    //theFrame.origin.x = theFrame.origin.x + 150 ;
    theFrame.origin.y = 0.0f;
    theFrame.size.width = 110.0f;
    theFrame.size.height = 55.0f;
    
    
    if (!self.btn2) {
        self.btn2 = [UIBuilder getTabBarButton:theFrame withImage:@"Calendar" withSelectedImage:@"Calendar" withTitle:[[TagManager sharedInstance]tagByName:kTagHomeCalendar]];
        btn2.imageEdgeInsets = UIEdgeInsetsMake(5, 100/2-25/2, 22, 0);
        btn2.titleEdgeInsets = UIEdgeInsetsMake(25, -25, 0, 0);
        [btn2 setTag:TabBarItemIDCalendar];
        [btn2 setSelected:YES];
        btn2.backgroundColor = [UIColor clearColor];
        [btn2 setImage:[UIImage imageNamed:@"NavBarCal"] forState:UIControlStateNormal];
        [btn2 setImage:[UIImage imageNamed:@"SCalendar"] forState:UIControlStateSelected];
    }
    
    theFrame.origin.x = theFrame.origin.x + theFrame.size.width + spaceMargin + 5;
    
    if (!self.btn3) {
        self.btn3 = [UIBuilder getTabBarButton:theFrame withImage:@"Explore" withSelectedImage:@"Explore" withTitle:[[TagManager sharedInstance]tagByName:kTagExplore]];
        
        btn3.imageEdgeInsets = UIEdgeInsetsMake(5, 100/2-25/2, 22, 0);
        btn3.titleEdgeInsets = UIEdgeInsetsMake(25, -25, 0, 0);
        
        [btn3 setTag:TabBarItemIDExplore];
        btn3.backgroundColor = [UIColor clearColor];
        
        [btn3 setImage:[UIImage imageNamed:@"NavBarExplore"] forState:UIControlStateNormal];
        [btn3 setImage:[UIImage imageNamed:@"SExplore"] forState:UIControlStateSelected];
        
    }
    
    theFrame.origin.x = theFrame.origin.x + theFrame.size.width + spaceMargin +5 ;
    if (!self.btn4) {
        self.btn4 = [UIBuilder getTabBarButton:theFrame withImage:@"Task" withSelectedImage:@"Task" withTitle:[[TagManager sharedInstance]tagByName:kTagHomeTask]];
        
        
        btn4.imageEdgeInsets = UIEdgeInsetsMake(5, 100/2-25/2, 22, 0);
        btn4.titleEdgeInsets = UIEdgeInsetsMake(25, -25, 0, 0);
        
        [btn4 setTag:TabBarItemIDTask];
        btn4.backgroundColor = [UIColor clearColor];
        
        [btn4 setImage:[UIImage imageNamed:@"NavBarTasks"] forState:UIControlStateNormal];
        [btn4 setImage:[UIImage imageNamed:@"STasks"] forState:UIControlStateSelected];
        
    }
    
    theFrame.origin.x = theFrame.origin.x + theFrame.size.width + spaceMargin +5 ;
    if (!self.btn5) {
        self.btn5 = [UIBuilder getTabBarButton:theFrame withImage:@"NewItem" withSelectedImage:@"NewItem" withTitle:[[TagManager sharedInstance]tagByName:kTagNewItem]];
        btn5.imageEdgeInsets = UIEdgeInsetsMake(5, 100/2-25/2, 22, 0);
        btn5.titleEdgeInsets = UIEdgeInsetsMake(25, -25, 0, 0);
        
        [btn5 setTag:TabBarItemIDNewItem];
        btn5.backgroundColor = [UIColor clearColor];
        [btn5 setImage:[UIImage imageNamed:@"SNewItem"] forState:UIControlStateSelected];
        [btn5 setImage:[UIImage imageNamed:@"NavBarNew"] forState:UIControlStateNormal];
        
        
        
        
        
    }
    
    theFrame.origin.x = theFrame.origin.x + theFrame.size.width + spaceMargin +5 ;
    if (!self.btn6) {
        self.btn6 = [UIBuilder getTabBarButton:theFrame withImage:@"Recents" withSelectedImage:@"Recents" withTitle:[[TagManager sharedInstance]tagByName:kTagRecentlyCreated]];
        btn6.imageEdgeInsets = UIEdgeInsetsMake(5, 100/2-25/2, 22, 0);
        btn6.titleEdgeInsets = UIEdgeInsetsMake(25, -25, 0, 0);
        [btn6 setTag:TabBarItemIDRecents];
        btn6.backgroundColor = [UIColor clearColor];
        [btn6 setImage:[UIImage imageNamed:@"SRecents"] forState:UIControlStateSelected];
        [btn6 setImage:[UIImage imageNamed:@"NavBarRecents"] forState:UIControlStateNormal];
        
        
    }
    
    theFrame.origin.x = theFrame.origin.x + theFrame.size.width + spaceMargin +5 ;
    if (!self.btn7) {
        self.btn7 = [UIBuilder getTabBarButton:theFrame withImage:@"Tools" withSelectedImage:@"Tools" withTitle:[[TagManager sharedInstance]tagByName:kTagTools]  withBadge:YES];
        btn7.imageEdgeInsets = UIEdgeInsetsMake(5, 100/2-25/2, 22, 0);
        btn7.titleEdgeInsets = UIEdgeInsetsMake(25, -25, 0, 0);
        [btn7 setTag:TabBarItemIDTools];
        btn7.backgroundColor = [UIColor clearColor];
        [btn7 setImage:[UIImage imageNamed:@"STools"] forState:UIControlStateSelected];
        [btn7 setImage:[UIImage imageNamed:@"NavBarTools"] forState:UIControlStateNormal];
        
        [self updateBadge];
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
    [self showNewTabBar];
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

- (void)updateBadge
{
    NSInteger count = [ResolveConflictsHelper getConflictsCount];
    
    SXLogWarning(@"CustomTabBar: Conflicts count %ld",(long)count);
    
    CustomBadge *toolsBadge = (CustomBadge*)[self.btn7 viewWithTag:BADGE_TAG];
    CustomBadge *homeBadge = (CustomBadge*)[self.btn1 viewWithTag:BADGE_TAG];

    /*
    if(count == 0) {
        toolsBadge.hidden = YES;
        homeBadge.hidden = YES;
    }
    else
    {
        toolsBadge.hidden = NO;
        homeBadge.hidden = NO;
        
        NSString *counterStr = [NSString stringWithFormat:@"%ld",(long)count];
        
        if(toolsBadge != nil) {
            [toolsBadge autoBadgeSizeWithString:counterStr];
        }
        
        if(homeBadge != nil) {
            [homeBadge autoBadgeSizeWithString:counterStr];
        }
    }
     */
    //Defect Fix:033408 -An Error of "-1" is Displayed On the Tech's Ipad (Similar to Sync Conflict)
    if(count > 0)
    {
        toolsBadge.hidden = NO;
        homeBadge.hidden = NO;
        
        NSString *counterStr = [NSString stringWithFormat:@"%ld",(long)count];
        
        if(toolsBadge != nil) {
            [toolsBadge autoBadgeSizeWithString:counterStr];
        }
        
        if(homeBadge != nil) {
            [homeBadge autoBadgeSizeWithString:counterStr];
        }
    }
    else
    {
        toolsBadge.hidden = YES;
        homeBadge.hidden = YES;
    }

}

#pragma mark - TapGesture
- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer {
    [self showNewTabBar];
}
@end
