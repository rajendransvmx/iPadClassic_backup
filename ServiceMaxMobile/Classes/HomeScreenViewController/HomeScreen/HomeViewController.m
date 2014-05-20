//
//  HomeViewController.m
//  ServiceMaxMobile
//
//  Created by AnilKumar on 5/8/14.
//  Copyright (c) 2014 ServiceMax, Inc. All rights reserved.
//
/**
 *  @file   HomeViewController.m
 *  @class  HomeViewController
 *
 *  @brief  This will display application home view.
 *
 *
 *  This contains the prototypes for the console
 *  driver and eventually any macros, constants,
 *  or global variables you will need.
 *
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "HomeViewController.h"
#import "TagManager.h"
#import "Item.h"
#import "GridViewCell.h"
#import "SNetworkReachabilityManager.h"
#import "OAuthService.h"
#import "AppManager.h"
#import "HelpController.h"
#import "HelpViewController.h"


static const NSInteger kGridColumnCount  = 3;

@interface HomeViewController ()


@property(nonatomic) BOOL logoutInProgress;
//@property (nonatomic) BOOL loadHelpView;

@property(nonatomic, strong)  IBOutlet UIImageView *backgroundImageView;
@property(nonatomic, strong)  IBOutlet UIImageView *servicemaxLogoImageView;
@property(nonatomic, strong)  IBOutlet UIImageView *customerLogoImageView;

@property(nonatomic, strong)  UITableView *menuTableView;

@property(nonatomic, strong)  NSMutableArray *menuItems;

- (void)loadMenuItems;
- (void)loadMenuTableView;
- (void)loadIconView;


- (void)loadCalendarView;
- (void)loadStandAloneProcessGeneratorView;
- (void)loadHelpView;
- (void)loadMapView;
- (void)loadRescentItemListView;
- (void)loadServiceFlowManageSearchView;
- (void)loadSyncView;
- (void)loadTaskListView;
- (void)logout;

- (void)registerNetworkChangeNotification;
- (void)deregisterNetworkChangeNotification;
- (void)makeActionAccordingToNetworkChangeNotification:(id)notification;

@end

@implementation HomeViewController

@synthesize backgroundImageView;
@synthesize servicemaxLogoImageView;
@synthesize customerLogoImageView;

@synthesize menuTableView;
@synthesize menuItems;


@synthesize logoutInProgress;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        logoutInProgress = NO;
        
        // Custom initialization
        [self loadMenuTableView];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadIconView];
    
    [self registerNetworkChangeNotification];
    // Do any additional setup after loading the view from its nib.
}


- (void)viewWillAppear:(BOOL)animated
{
    [self loadMenuItems];
    [menuTableView reloadData];
    
    [super viewWillAppear:animated];

    if (customerLogoImageView.image != nil)
    {
        [customerLogoImageView setIsAccessibilityElement:TRUE];
        [customerLogoImageView setAccessibilityIdentifier:@"customer_logo"];
    }
    else
    {
        [customerLogoImageView setAccessibilityIdentifier:@""];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    [self deregisterNetworkChangeNotification];
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        || (interfaceOrientation == UIInterfaceOrientationLandscapeRight) )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}


/**
 * @name  loadMenuItemsAndDescriptions
 *
 * @author Vipindas Palli
 *
 * @brief Load menu items and respective item description from tagcache
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return void
 *
 */

- (void)loadMenuItems
{
    if (menuItems != nil)
    {
        self.menuItems = nil;
    }

    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    [items addObject:[[[Item alloc] initWithMenuItemType:MenuItemTypeCalendar] autorelease]];     /** Calendar  */
    [items addObject:[[[Item alloc] initWithMenuItemType:MenuItemTypeSearch] autorelease]];       /** SFM Search  */
    [items addObject:[[[Item alloc] initWithMenuItemType:MenuItemTypeCreateNew] autorelease]];    /** Create New  */
    [items addObject:[[[Item alloc] initWithMenuItemType:MenuItemTypeMap] autorelease]];          /** Map  */
    [items addObject:[[[Item alloc] initWithMenuItemType:MenuItemTypeRecents] autorelease]];      /** Recents  */
    [items addObject:[[[Item alloc] initWithMenuItemType:MenuItemTypeTasks] autorelease]];        /** Tasks  */
    [items addObject:[[[Item alloc] initWithMenuItemType:MenuItemTypeSync] autorelease]];         /** Sync  */
    [items addObject:[[[Item alloc] initWithMenuItemType:MenuItemTypeHelp] autorelease]];         /** Help  */
    [items addObject:[[[Item alloc] initWithMenuItemType:MenuItemTypeLogout] autorelease]];       /** Logout  */
    
    self.menuItems = items;
    [items release];
    items = nil;
}

/**
 * @name  loadMenuTableView
 *
 * @author Vipindas Palli
 *
 * @brief <A short one line description>
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  Description of method's or function's input parameter
 * @param  ...
 *
 * @return Description of the return value
 *
 */

- (void)loadMenuTableView
{
    menuTableView = [[UITableView alloc] initWithFrame:CGRectZero];
    [menuTableView setDataSource:self];
    [menuTableView setDelegate:self];
    menuTableView.allowsSelection = NO;
    [self.view addSubview:menuTableView];
    [self.menuTableView setBackgroundColor:[UIColor clearColor]];
    self.menuTableView.scrollEnabled = NO;
    

}

/**
 * @name   fadeInLogoWithImageView:(UIImageView *)imageView
 *
 * @author Vipindas Palli
 *
 * @brief <A short one line description>
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  Description of method's or function's input parameter
 * @param  ...
 *
 * @return Description of the return value
 *
 */

- (void)fadeInLogoWithImageView:(UIImageView *)imageView
{
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:2];
    imageView.alpha = 1.0;
    [UIView commitAnimations];
}

/**
 * @name  populateIconView
 *
 * @author Vipindas Palli
 *
 * @brief <A short one line description>
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @param  Description of method's or function's input parameter
 * @param  ...
 *
 * @return Description of the return value
 *
 */

- (void)loadIconView
{
    servicemaxLogoImageView.image = [UIImage imageNamed:@"logo.png"];
    servicemaxLogoImageView.isAccessibilityElement = YES;
    [servicemaxLogoImageView setAccessibilityIdentifier:@"servicemaxlogo.png"];
    servicemaxLogoImageView.alpha = 0.0;
    
    CGRect menuTableViewFrame;
    
    menuTableViewFrame.origin.x = 20;
    menuTableViewFrame.origin.y = CGRectGetMaxY(servicemaxLogoImageView.frame);
    menuTableViewFrame.size.width = self.view.frame.size.width-40;
    menuTableViewFrame.size.height = self.view.frame.size.width-52;
    self.menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [menuTableView setFrame:menuTableViewFrame];
    
    // TODO :  vipind load customer logo from db
   // [customerLogoImageView setImage:appDelegate.serviceReportLogo];
    [customerLogoImageView setAlpha:0.0];
    [self performSelector:@selector(fadeInLogoWithImageView:) withObject:customerLogoImageView afterDelay:1];
    [self performSelector:@selector(fadeInLogoWithImageView:) withObject:servicemaxLogoImageView afterDelay:2];
}


#pragma mark -
#pragma mark UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = self.menuTableView.bounds.size.height/5.00;
    
    return rowHeight;
}


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


#pragma mark -
#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = [menuItems count]/kGridColumnCount;
    
    if (([menuItems count] % kGridColumnCount) != 0)
    {
        rowCount++;
    }
    return rowCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"HomeMenuItemCellIdentifier";
    
    GridViewCell *cell = (GridViewCell *) [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
   
    if (cell == nil)
    {
        cell = [[[GridViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:kCellIdentifier] autorelease];
        
        cell.columnCount = (menuItems.count - (indexPath.row * kGridColumnCount)) >= kGridColumnCount ? kGridColumnCount:(menuItems.count - (indexPath.row*kGridColumnCount))%kGridColumnCount;
        
        for (int i = 0; i < cell.columnCount; i++)
        {
            [[cell itemViewAtColumn:i] setDelegate:self];
        }
    }
    
    NSInteger itemIndex = (indexPath.row*kGridColumnCount);
    
    for (int i = 0; i < cell.columnCount; i++)
    {
        int columnIndex = itemIndex+i;
        
        ItemView *itemView = [cell itemViewAtColumn:i];
        itemView.index = columnIndex;
        
        Item *item = (Item *)[menuItems objectAtIndex:columnIndex];
        itemView.titleLabel.text = [item title];
        itemView.descriptionLabel.text = [item detailedDescription];
        itemView.menuItemType = [item itemType];
        
        [itemView.descriptionLabel setIsAccessibilityElement:YES];
        [itemView.descriptionLabel setAccessibilityIdentifier:[item accessibilityIdentifier]];
        [itemView.iconImageView setImage:[item icon]];
    }
        
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell
                                              forRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Need to customize Feature anabled and logout
    GridViewCell *gridCell = (GridViewCell *) cell;
    
    for (int i = 0; i < gridCell.columnCount; i++)
    {
        ItemView *itemView = (ItemView *)[gridCell itemViewAtColumn:i];
        
        if (itemView.menuItemType == MenuItemTypeLogout)
        {
            if ([[SNetworkReachabilityManager sharedInstance] isNetworkReachable])
            {
                /** Network reachable, lets make logout menu button enabled */
                itemView.alpha = 1.0;
				itemView.userInteractionEnabled = YES;
            }
            else
            {
                itemView.alpha = 0.5;
				itemView.userInteractionEnabled = NO;
            }
        }
        else if (itemView.menuItemType == MenuItemTypeSearch)
        {
            /** Service Flow manager serach is enabled, lets display respective menu item */
            if (YES)
            {
                CALayer *layer = [itemView layer];
                layer.borderColor = [UIColor lightGrayColor].CGColor;
            }
            else
            {
                CALayer *layer = [itemView layer];
                layer.borderColor = [UIColor clearColor].CGColor;
                itemView.titleLabel.text = nil;
                itemView.descriptionLabel.text = nil;
                itemView.iconImageView.image = nil;
                itemView.index = -1;
            }
        }
    }
}


#pragma mark -
#pragma mark ItemViewDelegate Method
    

- (void)tappedOnViewAtIndex:(int)index
{
    switch (index)
    {
        case MenuItemTypeCalendar:
            {
                [self loadCalendarView];
            }
            break;

            
        case MenuItemTypeCreateNew:
            {
                [self loadStandAloneProcessGeneratorView];
            }
            break;

            
        case MenuItemTypeHelp:
            {
                [self loadHelpView];
            }
            break;
    
            
        case MenuItemTypeMap:
            {
                [self loadMapView];
            }
            break;
            

        case MenuItemTypeRecents:
            {
                [self loadRescentItemListView];
            }
            break;
            
            
        case MenuItemTypeSearch:
            {
                [self loadServiceFlowManageSearchView];
            }
            break;
            
            
        case MenuItemTypeSync:
            {
                [self loadSyncView];
            }
            break;
            
            
        case MenuItemTypeTasks:
            {
                [self loadTaskListView];
            }
            break;

        case MenuItemTypeLogout:
            {
                [self logout];
            }
            break;
    
            
        default:
            break;
    }
}


- (void)loadCalendarView
{
    NSLog(@" pressed  loadCalendarView ");
}

- (void)loadStandAloneProcessGeneratorView
{
    NSLog(@" pressed  loadStandAloneProcessGeneratorView ");
}

- (void)loadHelpView
{
    NSLog(@" pressed  loadHelpView ");
    HelpViewController * help =[[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
    help.modalPresentationStyle = UIModalPresentationFullScreen;
    help.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [help setHelpPageName:HelpPageNameHome];
    [self presentViewController:help animated:YES completion:nil];
    
}

- (void)loadMapView
{
    NSLog(@" pressed  loadMapView ");
}

- (void)loadRescentItemListView
{
    NSLog(@" pressed  loadRescentItemListView ");
}

- (void)loadServiceFlowManageSearchView
{
    NSLog(@" pressed  loadServiceFlowManageSearchView ");
}

- (void)loadSyncView
{
    NSLog(@" pressed  loadSyncView ");
}

- (void)loadTaskListView
{
    NSLog(@" pressed  loadTaskListView ");
}

- (void)logout
{
    NSLog(@" pressed  logout ");
    
    if (self.logoutInProgress)
    {
        NSLog(@" pressed  logout Go BACK !!!");
        return;
    }
    else
    {
        self.logoutInProgress = YES;
    }
    
    @synchronized([self class])
    {
        BOOL isRevoked = [OAuthService revokeAccessToken];
    
        if (isRevoked)
        {
            [[AppManager sharedInstance] completedLogoutProcess];
        }
    }
    
    self.logoutInProgress = NO;
}


#pragma mark - Network Reachability Management 

/**
 * @name   registerNetworkChangeNotification
 *
 * @author Vipindas Palli
 *
 * @brief  Register for network change observation
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return void
 *
 */

- (void)registerNetworkChangeNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(makeActionAccordingToNetworkChangeNotification:)
                                                 name:kNetworkConnectionChanged
                                               object:nil];

}

/**
 * @name   registerNetworkChangeNotification
 *
 * @author Vipindas Palli
 *
 * @brief  Deregister for network change observation
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return void
 *
 */


- (void)deregisterNetworkChangeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNetworkConnectionChanged object:nil];
}


/**
 * @name   registerNetworkChangeNotification
 *
 * @author Vipindas Palli
 *
 * @brief  Handle once you recieved observation
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return void
 *
 */

- (void)makeActionAccordingToNetworkChangeNotification:(NSNotification *)notification
{
     NSLog(@" Network changed -- on home screen ");
    
    if ([notification isKindOfClass:[NSNotification class]])
     {
         NSLog(@" notification - %@", [notification description]);
         
         NSNumber *number = (NSNumber *) [notification object];
         
         NSLog(@" notification value - %d", [number intValue]);
     }
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [menuTableView reloadData];
    });
}


@end
