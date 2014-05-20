//
//  Item.m
//  iServiceHomeScreen
//
//  Created by Aparna on 09/01/13.
//  Copyright (c) 2013 Aparna. All rights reserved.
//

/**
 *  @file   Item.m
 *  @class  Item
 *
 *  @brief  This will store home view menu item details.
 *
 *
 *  This contains the prototypes for the console
 *  driver and eventually any macros, constants,
 *  or global variables you will need.
 *
 *  @author  Aparna
 *  @author  Vipindas Palli
 *
 *  @bug     No known bugs.
 *
 *  @copyright 2014 ServiceMax, Inc. All rights reserved.
 *
 **/

#import "Item.h"
#import "LocalizationGlobals.h"
#import "TagManager.h"


@interface Item ()

- (void)populateMenuItem;
- (void)loadItemDetails;

- (NSString *)itemTitleKey;
- (NSString *)itemDescriptionKey;

@end



@implementation Item

@synthesize detailedDescription;
@synthesize title;
@synthesize icon;
@synthesize name;
@synthesize accessibilityIdentifier;


/**
 * @name  initWithMenuItemType
 *
 * @author Vipindas Palli
 *
 * @brief Constructor method will recieve type of the menu item and return Object
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return Item object
 *
 */

- (id)initWithMenuItemType:(MenuItemType)type
{
    self = [super init];
    
    if (self)
    {
        self.itemType = type;
        [self populateMenuItem];
    }
    
    return self;
}


- (id)initWithTitle:(NSString *)theTitle
        description:(NSString *)theDescription
               icon:(UIImage *)theIcon
{
    self = [super init];
    if(self)
    {
        self.title = theTitle;
        self.detailedDescription = theDescription;
        self.icon = theIcon;
    }
    return self;
}

- (void)dealloc
{
    self.title = nil;
    self.detailedDescription = nil;
    self.icon = nil;
    self.name = nil;
    [super dealloc];
}

/**
 * @name  loadItemDetails
 *
 * @author Vipindas Palli
 *
 * @brief Load item details from Tagcache
 *
 * \par
 *  <Longer description starts here>
 *
 * @return void
 *
 */

- (void)loadItemDetails
{
    NSString *titleKey  = [self itemTitleKey];
    NSString *descriptionKey  = [self itemDescriptionKey];
    
    if ((titleKey != nil) && (descriptionKey != nil))
    {
        self.title = [[TagManager sharedInstance] tagByName:titleKey];
        self.detailedDescription = [[TagManager sharedInstance] tagByName:descriptionKey];
    }
}

/**
 * @name  reloadItem
 *
 * @author Vipindas Palli
 *
 * @brief Reload details of menu items
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return void
 *
 */

- (void)reloadItem
{
    [self loadItemDetails];
}

/**
 * @name  itemTitleKey
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

- (NSString *)itemTitleKey
{
    NSString *titleKey = nil;
    
    switch (self.itemType)
    {
        case MenuItemTypeCalendar:
            titleKey = HOME_CALENDAR;
            break;
            
        case MenuItemTypeCreateNew:
            titleKey = HOME_CREATENEW;
            break;
            
        case MenuItemTypeHelp:
            titleKey = HOME_HELP;
            break;
            
        case MenuItemTypeLogout:
            titleKey = ipad_logout_label;
            break;
            
        case MenuItemTypeMap:
            titleKey = HOME_MAP;
            break;
            
        case MenuItemTypeRecents:
            titleKey = HOME_RECENTS;
            break;
            
        case MenuItemTypeSearch:
            titleKey = SFM_Search;
            break;
            
        case MenuItemTypeSync:
            titleKey = ipad_sync_label;
            break;
            
        case MenuItemTypeTasks:
            titleKey = HOME_TASKS;
            break;
            
        default:
            break;
    }
    
    return titleKey;
}

/**
 * @name  itemDescriptionKey
 *
 * @author Vipindas Palli
 *
 * @brief Dscription Key
 *
 * \par
 *  <Longer description starts here>
 *
 *
 *
 * @return Description key for current object
 *
 */
- (NSString *)itemDescriptionKey
{
    NSString *descriptionKey = nil;
    
    switch (self.itemType)
    {
        case MenuItemTypeCalendar:
            descriptionKey = HOME_CALENDAR_TEXT;
            break;
            
        case MenuItemTypeCreateNew:
            descriptionKey = HOME_CREATENEW_TEXT;
            break;
            
        case MenuItemTypeHelp:
            descriptionKey = HOME_HELP_TEXT;
            break;
            
        case MenuItemTypeLogout:
            descriptionKey = ipad_logout_text;
            break;
            
        case MenuItemTypeMap:
            descriptionKey = HOME_MAP_TEXT;
            break;
            
        case MenuItemTypeRecents:
            descriptionKey = HOME_RECENTS_TEXT;
            break;
            
        case MenuItemTypeSearch:
            descriptionKey = SFM_Search_Description;
            break;
            
        case MenuItemTypeSync:
            descriptionKey = ipad_sync_text;
            break;
            
        case MenuItemTypeTasks:
            descriptionKey = HOME_TASKS_TEXT;
            break;
            
        default:
            break;
    }
    return descriptionKey;
}


/**
 * @name  populateMenuItem
 *
 * @author Vipindas Palli
 *
 * @brief  populate menu item details
 *
 * \par
 *  <Longer description starts here>
 *
 *
 * @return void
 *
 */

- (void)populateMenuItem
{
    int imageName = -1;
    
    switch (self.itemType)
    {
        case MenuItemTypeCalendar:
            self.name = @"Calendar";
            self.accessibilityIdentifier = @"HomeCalendar";
            imageName = 0;
            break;
            
        case MenuItemTypeCreateNew:
            self.name = @"StandaloneProcessGenerator";
            self.accessibilityIdentifier = @"HomeCreateNew";
            imageName = 2;
            break;
            
        case MenuItemTypeHelp:
            self.name = @"Help";
            self.accessibilityIdentifier = @"HomeHelp";
            imageName = 7;
            break;
            
        case MenuItemTypeLogout:
            self.name = @"Logout";
            self.accessibilityIdentifier = @"HomeLogout";
            imageName = 8;
            break;
            
        case MenuItemTypeMap:
            self.name = @"Map";
            self.accessibilityIdentifier = @"HomeMap";
            imageName = 3;
            break;
            
        case MenuItemTypeRecents:
            self.name = @"Recents";
            self.accessibilityIdentifier = @"HomeRecents";
            imageName = 4;
            break;
            
        case MenuItemTypeSearch:
            self.name = @"SFM Search";
            self.accessibilityIdentifier = @"HomeSFMSearch";
            imageName = 1;
            break;
            
        case MenuItemTypeSync:
            self.name = @"Sync";
            self.accessibilityIdentifier = @"HomeSync";
            imageName = 6;
            break;
            
        case MenuItemTypeTasks:
            self.name = @"Tasks";
            self.accessibilityIdentifier = @"HomeTasks";
            imageName = 5;
            break;
            
        default:
            break;
    }
    
    if ( (-1 < imageName) && (imageName < 9))
    {
        self.icon = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png", imageName]];
    }
    
    [self loadItemDetails];
    
}

@end
